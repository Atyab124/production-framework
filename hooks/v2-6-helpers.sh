#!/usr/bin/env bash
# =============================================================================
# v2-6-helpers.sh — v2.6.0 mechanical-floor functions, sourced by:
#   - hooks/pre-tool-use   (record_expected_outputs, check_write_scope,
#                            check_mig_precondition_disclosure)
#   - hooks/subagent-stop  (verify_expected_outputs_at_stop)
#   - hooks/post-tool-use  (run_mig_dry_apply — new in v2.6.0)
#
# Kept separate from the main hook scripts for reviewability + isolated
# rollback. The pre-tool-use / subagent-stop scripts source this file with
# a guard: if it doesn't exist, hooks no-op the new functions (graceful
# degradation; v2.5 behavior preserved).
#
# Citations (binding rule per CLAUDE.md):
#   - R1 verbatim: code.claude.com/docs/en/hooks (SubagentStop decision: block
#       prevents stopping; PreToolUse hookSpecificOutput.permissionDecision: deny)
#   - R2 binding: Sqitch declarative dependencies (verified 2026-05-27 verbatim);
#       Liquibase preconditions; Atlas migrate lint; Supabase Branching
#   - R3 binding (5/6 frameworks): CrewAI Task.output_file; LangGraph
#       runtime-enforced parallel-write scope; Anthropic file-artifact substrate
#   - R4 binding: HashiCorp Sentinel three-level taxonomy
# =============================================================================

# Kill switch + bypass-already-set guards run in the caller. These helpers
# assume the caller already established STATE_DIR, json_escape, log_decision,
# log_bypass, deny (PreToolUse-shape JSON), and standard variables (TOOL_NAME,
# FILE_PATH_NORM, AGENT_PROMPT, INPUT, SUBAGENT_TYPE).

# -----------------------------------------------------------------------------
# §1.1 record_expected_outputs — called on Agent dispatch (PreToolUse)
# -----------------------------------------------------------------------------
# Parse Agent dispatch prompt for `output_files: <paths>` declaration.
# Record in .framework-state/expected-outputs.jsonl so SubagentStop can verify
# the files actually landed when the sub-agent claims DONE.
#
# Backward compat: missing declaration → advisory log + allow (no block).
# Legacy "WRITE THE FILE" / "Hand off DONE with file at <path>" patterns get
# a "missing_output_files_declaration" hint logged for migration nudge.
#
# Citation: CrewAI Task.output_file declarative output contracts (R3 binding
# N=4-6/6 frameworks: CrewAI literal, LangGraph + AutoGen + Anthropic
# structural-fit).
# -----------------------------------------------------------------------------
record_expected_outputs() {
  local expected_file="${STATE_DIR}/expected-outputs.jsonl"
  mkdir -p "${STATE_DIR}" 2>/dev/null || true
  [ -f "${expected_file}" ] || touch "${expected_file}"

  # F-V41 Defect 1 fix: use the shared line-oriented parser (defined in
  # pre-tool-use, available at call time) instead of the truncating [^\n] regex.
  local output_files_str
  output_files_str=$(parse_labeled_field output_files "${AGENT_PROMPT}" | tr -d '"[]' || echo "")

  local now_epoch now_iso
  now_epoch=$(date +%s)
  now_iso=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  if [ -n "${output_files_str}" ]; then
    printf '{"started_at":"%s","started_at_epoch":%d,"subagent_type":"%s","output_files":"%s","retry_count":0,"event":"expected"}\n' \
      "${now_iso}" "${now_epoch}" "${SUBAGENT_TYPE:-unknown}" "${output_files_str}" \
      >> "${expected_file}"
  else
    local legacy_path
    legacy_path=$(printf '%s' "${AGENT_PROMPT}" \
      | grep -oE 'WRITE THE FILE.*|Hand off DONE with file at [^[:space:]]+' \
      | head -1 \
      || echo "")
    if [ -n "${legacy_path}" ]; then
      printf '{"timestamp":"%s","subagent_type":"%s","event":"missing_output_files_declaration","legacy_hint":"%s"}\n' \
        "${now_iso}" "${SUBAGENT_TYPE:-unknown}" "$(json_escape "${legacy_path}")" \
        >> "${STATE_DIR}/trigger-audit.jsonl"
    fi
  fi
}

# -----------------------------------------------------------------------------
# §1.2 check_write_scope — called on Write/Edit (PreToolUse)
# -----------------------------------------------------------------------------
# Mirror of v2.5 PR-9 read-side check_file_scope_intersection. When a Write/Edit
# target is outside the in-flight sub-agent's declared scope_write[], deny via
# PreToolUse hookSpecificOutput.permissionDecision: "deny" (R1 verbatim).
#
# Heuristic correlation: looks for an in-flight start event (last 30 min) with
# scope_write declared. If no in-flight agent + scope_write → main-session
# write, no scope to enforce; allow. v2.7 follow-up to add true agent_id
# correlation per FEEDBACK §14.1.
# -----------------------------------------------------------------------------
check_write_scope() {
  [ -z "${FILE_PATH_NORM:-}" ] && return 0
  [ "${PF_BYPASS:-}" = "subagent-scope-write-enforcement" ] && {
    log_bypass "subagent-scope-write-enforcement" "explicit bypass"
    return 0
  }
  local active_agents_file="${STATE_DIR}/active-agents.jsonl"
  [ ! -f "${active_agents_file}" ] && return 0

  local now_epoch window_start_epoch
  now_epoch=$(date +%s)
  window_start_epoch=$((now_epoch - 1800))

  # F-V41 Defect 3: only a SUB-AGENT's own write is scope-restricted. The CC hook
  # contract carries agent_id/agent_type on subagent tool calls to distinguish
  # them from main-thread calls; a main-session write has none → allow. This is
  # what stopped the cascade where a stale in-flight marker blocked the CTO's own
  # writes. (Empirical-verify on re-enable: a main-session Write's PreToolUse
  # input must NOT carry agent_type; a sub-agent's MUST.)
  local cur_agent_type
  cur_agent_type=$(printf '%s' "${INPUT}" | grep -o '"agent_type"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")
  [ -z "${cur_agent_type}" ] && return 0

  # F-V41 Defect 2: starts MINUS stops (FIFO per type), restricted to THIS agent's
  # own declared scope so one sub-agent is never bound by another's scope_write.
  local in_flight_writes
  in_flight_writes=$(compute_in_flight_writes "${active_agents_file}" "${window_start_epoch}" "${cur_agent_type}")

  # This agent declared no scope_write → nothing to enforce.
  [ -z "${in_flight_writes}" ] && return 0

  # Check whether FILE_PATH_NORM matches any in-flight scope_write path.
  local matched=0
  local declared_scopes=""
  while IFS= read -r write_paths; do
    [ -z "${write_paths}" ] && continue
    declared_scopes="${declared_scopes}${declared_scopes:+ | }${write_paths}"
    local trimmed
    trimmed=$(printf '%s' "${write_paths}" | tr ',' '\n')
    while IFS= read -r single_path; do
      single_path=$(printf '%s' "${single_path}" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
      [ -z "${single_path}" ] && continue
      local normalized_scope="${single_path//\\//}"
      if printf '%s' "${FILE_PATH_NORM}" | grep -qF "${normalized_scope}"; then
        matched=1
        break 2
      fi
    done <<< "${trimmed}"
  done <<< "${in_flight_writes}"

  if [ "${matched}" -eq 0 ]; then
    deny "subagent-scope-write-enforcement (v2.6.0 §1.2): target '${FILE_PATH_NORM}' is outside declared scope_write of in-flight sub-agent. Declared scope(s): ${declared_scopes}. Options: (a) extend the dispatch's scope_write declaration, (b) use Bash + git apply for files outside scope, (c) PF_BYPASS=subagent-scope-write-enforcement if intentional. Mirrors v2.5 PR-9 read-side check. Citation: LangGraph runtime-enforced parallel-write scope (R3 binding)." "subagent-scope-write-enforcement"
  fi
}

# -----------------------------------------------------------------------------
# §2 Gate A check_mig_precondition_disclosure — called on mig Write/Edit/Bash apply
# -----------------------------------------------------------------------------
# When a migration file is written/edited OR a Bash command applies one, parse
# the file for DEPENDENCY v1 + ACTOR v1 disclosure blocks. Block on:
#   (a) missing DEPENDENCY v1 block
#   (b) ASSUMED-FROM-PM-SPEC tag present (forbidden — R57/F-22 root cause)
#   (c) missing ACTOR v1 block (framework-original; no direct precedent per R2)
#   (d) cross-dep scan: public.<table> referenced but not in LIVE-VERIFIED or
#       THIS-MIG-INTRODUCES
#
# Citation: Sqitch declarative dependencies (verified verbatim 2026-05-27);
# Liquibase preconditions; Atlas migrate lint. R2 binding N=3 sources for the
# DEPENDENCY block; ACTOR block is framework-original (Appendix D).
# -----------------------------------------------------------------------------
check_mig_precondition_disclosure() {
  [ "${PF_BYPASS:-}" = "mig-precondition-disclosure" ] && {
    log_bypass "mig-precondition-disclosure" "explicit bypass"
    return 0
  }

  local mig_file=""
  local mig_content=""

  if [ "${TOOL_NAME}" = "Edit" ] || [ "${TOOL_NAME}" = "Write" ]; then
    case "${FILE_PATH_NORM}" in
      */supabase/migrations/*.sql|*/migrations/*.sql|*/db/migrations/*.sql)
        mig_file="${FILE_PATH}"
        mig_content=$(printf '%s' "$INPUT" \
          | sed -n 's/.*"new_string"[[:space:]]*:[[:space:]]*"\(.*\)"[,}].*/\1/p' \
          | head -1)
        if [ -z "${mig_content}" ]; then
          mig_content=$(printf '%s' "$INPUT" \
            | sed -n 's/.*"content"[[:space:]]*:[[:space:]]*"\(.*\)"[,}].*/\1/p' \
            | head -1)
        fi
        mig_content="${mig_content//\\\"/\"}"
        ;;
      *)
        return 0
        ;;
    esac
  elif [ "${TOOL_NAME}" = "Bash" ]; then
    if printf '%s' "${COMMAND}" | grep -qE 'psql.*-f[[:space:]]+\S+\.sql|supabase[[:space:]]+migration[[:space:]]+(apply|up)'; then
      local sql_path
      sql_path=$(printf '%s' "${COMMAND}" | grep -oE '\S+\.sql' | head -1 || echo "")
      if [ -n "${sql_path}" ] && [ -f "${sql_path}" ]; then
        mig_file="${sql_path}"
        mig_content=$(cat "${sql_path}" 2>/dev/null || echo "")
      fi
    fi
    [ -z "${mig_file}" ] && return 0
  elif [[ "${TOOL_NAME}" == mcp__claude_ai_Supabase__apply_migration* ]]; then
    # MCP apply_migration carries inline 'query' field; extract directly
    mig_content=$(printf '%s' "$INPUT" \
      | sed -n 's/.*"query"[[:space:]]*:[[:space:]]*"\(.*\)"[,}].*/\1/p' \
      | head -1)
    mig_content="${mig_content//\\\"/\"}"
    mig_file="<mcp-apply-migration>"
  else
    return 0
  fi

  [ -z "${mig_content}" ] && return 0

  # (a) DEPENDENCY v1 block presence
  if ! printf '%s' "${mig_content}" | grep -qE '^--[[:space:]]*DEPENDENCY[[:space:]]+v1'; then
    deny "mig-precondition-disclosure (v2.6.0 §2 Gate A): migration lacks '-- DEPENDENCY v1' block. Required tags: LIVE-VERIFIED, PRIOR-WAVE-APPLIED, THIS-MIG-INTRODUCES. Citation: Sqitch declarative dependencies (R2 verified verbatim). Bypass: PF_BYPASS=mig-precondition-disclosure." "mig-precondition-disclosure"
  fi

  # (b) ASSUMED-FROM-PM-SPEC forbidden
  if printf '%s' "${mig_content}" | grep -qE '^--[[:space:]]*ASSUMED-FROM-PM-SPEC:'; then
    deny "mig-precondition-disclosure (v2.6.0 §2 Gate A): 'ASSUMED-FROM-PM-SPEC' tag forbidden. PM specs are not live-DB evidence. Query schema_migrations + information_schema; tag baseline with LIVE-VERIFIED + evidence. R57/F-22 incident root cause (8 recurrences in single TaskIt cycle)." "mig-precondition-disclosure"
  fi

  # (c) ACTOR v1 block presence (framework-original — Appendix D)
  if ! printf '%s' "${mig_content}" | grep -qE '^--[[:space:]]*ACTOR[[:space:]]+v1'; then
    deny "mig-precondition-disclosure (v2.6.0 §2 Gate A): migration lacks '-- ACTOR v1' block. Required tags: PRIVILEGES-REQUIRED, PRIVILEGES-AVAILABLE, WORKAROUND-IF-MISMATCH. Framework-original per FEEDBACK Appendix D (no direct enterprise precedent — R2). Closes the managed-Supabase ALTER DATABASE 42501 failure class. Bypass: PF_BYPASS=mig-precondition-disclosure." "mig-precondition-disclosure"
  fi

  # (d) Cross-dep scan — public.<table> references must appear in LIVE-VERIFIED
  #     or THIS-MIG-INTRODUCES sections.
  local referenced_tables
  referenced_tables=$(printf '%s' "${mig_content}" \
    | grep -oiE '(REFERENCES|FROM|JOIN|INTO)[[:space:]]+(public\.)?[a-z_][a-z0-9_]*' \
    | awk '{print tolower($NF)}' \
    | sed 's/^public\.//' \
    | sort -u \
    || echo "")
  local live_verified_block
  live_verified_block=$(printf '%s' "${mig_content}" \
    | awk '
        /^--[[:space:]]*LIVE-VERIFIED:/ {flag=1; print; next}
        /^--[[:space:]]*(PRIOR-WAVE-APPLIED|THIS-MIG-INTRODUCES|ACTOR|ASSUMED-FROM-PM-SPEC):/ {flag=0}
        flag
      ' \
    || echo "")
  local introduces_block
  introduces_block=$(printf '%s' "${mig_content}" \
    | awk '
        /^--[[:space:]]*THIS-MIG-INTRODUCES:/ {flag=1; print; next}
        /^--[[:space:]]*(ACTOR|ASSUMED-FROM-PM-SPEC):/ {flag=0}
        flag
      ' \
    || echo "")
  local missing_tables=""
  while IFS= read -r tbl; do
    [ -z "${tbl}" ] && continue
    case "${tbl}" in
      pg_*|information_schema*|public|null|true|false|on|using|select|into|from|where|by)
        continue
        ;;
    esac
    if ! printf '%s' "${live_verified_block}${introduces_block}" \
      | tr '[:upper:]' '[:lower:]' \
      | grep -qF "${tbl}"; then
      missing_tables="${missing_tables} ${tbl}"
    fi
  done <<< "${referenced_tables}"
  if [ -n "${missing_tables}" ]; then
    deny "mig-precondition-disclosure (v2.6.0 §2 Gate A): tables referenced but not in LIVE-VERIFIED or THIS-MIG-INTRODUCES:${missing_tables}. Cross-dep scan failure. Either add the table to LIVE-VERIFIED (with schema_migrations row evidence) or create it earlier in the apply sequence." "mig-precondition-disclosure"
  fi
}

# -----------------------------------------------------------------------------
# §1.1 verify_expected_outputs_at_stop — called from subagent-stop hook
# -----------------------------------------------------------------------------
# Look up the most-recent unverified expected-outputs entry for the completing
# sub-agent (matched by subagent_type heuristic — v2.7 will add agent_id
# correlation). For each declared output_file path, check whether it exists.
# Any missing → emit SubagentStop {decision: block, reason: ...} which
# *prevents the subagent from stopping* (R1 verbatim) — the subagent continues
# operation with the reason text as context, giving it a chance to call Write
# before terminating.
#
# Retry counter: max 2 prevent-stop events per expected-outputs row. After
# exhaustion → accept stop + audit-log (no further block) to avoid infinite
# extension. This is the failure mode caller — emits stdout JSON and exits 0.
# -----------------------------------------------------------------------------
verify_expected_outputs_at_stop() {
  local expected_file="${STATE_DIR}/expected-outputs.jsonl"
  [ ! -f "${expected_file}" ] && return 0

  local now_epoch
  now_epoch=$(date +%s)
  local window_start_epoch=$((now_epoch - 1800))

  # Find the most-recent expected-outputs row matching this subagent_type
  # within the last 30 min. We accept the heuristic correlation; v2.7 follow-up
  # adds agent_id matching per FEEDBACK §14.1.
  local match_line=""
  match_line=$(
    awk -v subagent="${SUBAGENT_TYPE:-unknown}" -v window_start="${window_start_epoch}" '
      /"event":"expected"/ {
        if (index($0, "\"subagent_type\":\"" subagent "\"") > 0) {
          match($0, /"started_at_epoch":[0-9]+/)
          if (RSTART > 0) {
            epoch_str = substr($0, RSTART, RLENGTH)
            sub(/.*:/, "", epoch_str)
            if (epoch_str + 0 >= window_start) {
              latest = $0
              latest_epoch = epoch_str + 0
            }
          }
        }
      }
      END { if (latest) print latest }
    ' "${expected_file}" 2>/dev/null
  )
  [ -z "${match_line}" ] && return 0

  # Already exhausted retries?
  local retry_count
  retry_count=$(printf '%s' "${match_line}" | grep -oE '"retry_count":[0-9]+' | sed 's/.*://' || echo "0")
  if [ "${retry_count}" -ge 2 ]; then
    # Audit-log + accept stop (no further block to avoid infinite-extension loop)
    printf '{"timestamp":"%s","event":"expected_outputs_exhausted_retries","subagent_type":"%s","retry_count":%d}\n' \
      "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "${SUBAGENT_TYPE:-unknown}" "${retry_count}" \
      >> "${STATE_DIR}/trigger-audit.jsonl" 2>/dev/null || true
    return 0
  fi

  # Parse output_files from the matched row
  local output_files_str
  output_files_str=$(printf '%s' "${match_line}" | grep -oE '"output_files":"[^"]*"' | sed 's/^"output_files":"//' | sed 's/"$//' || echo "")
  [ -z "${output_files_str}" ] && return 0

  # Check each path exists
  local missing=""
  while IFS= read -r single_path; do
    single_path=$(printf '%s' "${single_path}" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    [ -z "${single_path}" ] && continue
    if [ ! -f "${single_path}" ]; then
      missing="${missing} ${single_path}"
    fi
  done <<< "$(printf '%s' "${output_files_str}" | tr ',' '\n')"

  if [ -n "${missing}" ]; then
    # Increment retry count by re-writing the expected-outputs file
    local new_retry=$((retry_count + 1))
    local tmp
    tmp=$(mktemp)
    awk -v old="${match_line}" -v new_retry="${new_retry}" '
      $0 == old {
        sub(/"retry_count":[0-9]+/, "\"retry_count\":" new_retry)
      }
      { print }
    ' "${expected_file}" > "${tmp}"
    mv "${tmp}" "${expected_file}"

    # R1 verbatim: SubagentStop decision: block PREVENTS the subagent from
    # stopping; it continues working with the reason text as context.
    local reason
    reason="expected output file(s) not written:${missing}. Call the Write tool to create them before stopping. (retry ${new_retry}/2; further misses will accept stop with DONE_WITH_CONCERNS audit)"
    # Escape for JSON
    reason="${reason//\\/\\\\}"
    reason="${reason//\"/\\\"}"
    reason="${reason//$'\n'/\\n}"

    printf '{"timestamp":"%s","event":"expected_outputs_missing_block","subagent_type":"%s","missing":"%s","retry":%d}\n' \
      "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "${SUBAGENT_TYPE:-unknown}" "$(echo "${missing}" | sed 's/"/\\"/g')" "${new_retry}" \
      >> "${STATE_DIR}/decision-log.jsonl" 2>/dev/null || true

    # Output SubagentStop block JSON and EXIT — this prevents the subagent from stopping
    printf '{"decision":"block","reason":"%s"}\n' "${reason}"
    exit 0
  fi
}

# -----------------------------------------------------------------------------
# §2 Gate B run_mig_dry_apply — called from post-tool-use hook
# -----------------------------------------------------------------------------
# After a successful Write/Edit on a migration file, apply it against a Supabase
# Branch DB (or scratch DB) to catch SQL errors that pre-dispatch grep can't see.
#
# This is a graceful-degrade gate: requires either (a) Supabase MCP tools
# available in the session, OR (b) a PSQL scratch URL declared in
# STACK-PATTERNS. If neither available → advisory log + allow.
#
# Citation: Supabase Branching (verified verbatim — "Each branch is a separate
# environment with its own Supabase instance and API credentials"); Atlas
# migrate lint; gh-ost shadow table pattern. R2 binding N=4.
#
# Note: this function is invoked from post-tool-use, which fires AFTER the tool
# call succeeded. It cannot block the Write/Edit itself; it blocks the NEXT
# tool call in the cycle by emitting decision: block on the subsequent
# PreToolUse. v2.6.0 implementation just writes the result to state and surfaces
# via PreToolUse on the next dispatch — true PostToolUse-block-the-next-call
# wiring is deferred to v2.6.1.
# -----------------------------------------------------------------------------
run_mig_dry_apply() {
  [ "${PF_BYPASS:-}" = "mig-dry-apply" ] && {
    log_bypass "mig-dry-apply" "explicit bypass"
    return 0
  }

  # Only fire on successful Write/Edit on migration files
  case "${FILE_PATH_NORM:-}" in
    */supabase/migrations/*.sql|*/migrations/*.sql|*/db/migrations/*.sql)
      ;;
    *)
      return 0
      ;;
  esac

  # Check whether Supabase Branching is declared as available in STACK-PATTERNS.
  # Conservative default: if STACK-PATTERNS doesn't declare supabase_branching
  # capability → advisory log, no enforcement.
  local stack_patterns="${PROJECT_DIR}/docs/STACK-PATTERNS.md"
  [ ! -f "${stack_patterns}" ] && stack_patterns="${PROJECT_DIR}/templates/STACK-PATTERNS.template.md"
  if [ ! -f "${stack_patterns}" ] \
    || ! grep -qiE 'supabase[_-]branching:[[:space:]]*true|supabase_branching[[:space:]]*:[[:space:]]*true' "${stack_patterns}" 2>/dev/null; then
    printf '{"timestamp":"%s","event":"mig_dry_apply_skipped_no_branching","mig":"%s"}\n' \
      "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "${FILE_PATH_NORM}" \
      >> "${STATE_DIR}/trigger-audit.jsonl" 2>/dev/null || true
    return 0
  fi

  # Surface dry-apply requirement to the next dispatch via state file.
  # True end-to-end Supabase MCP apply_migration invocation from a bash hook
  # would require MCP credentials reachable from the hook's bash context;
  # this is unavailable in v2.6.0 (Claude Code hooks run outside the MCP
  # credential envelope). v2.6.0 ships the predicate + state file; the
  # actual Supabase MCP invocation is deferred to v2.6.1 (skill-driven).
  printf '{"timestamp":"%s","event":"mig_dry_apply_pending","mig":"%s","mode":"v2-6-0-predicate-only"}\n' \
    "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "${FILE_PATH_NORM}" \
    >> "${STATE_DIR}/mig-dry-apply-pending.jsonl" 2>/dev/null || true
}
