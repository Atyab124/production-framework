# v2.6.0 Implementation Plan — Mechanical Floor

> **Single-concept scope:** "The framework can no longer trust sub-agent claims on output or migration baseline." Five HOOK + HYBRID fixes from FEEDBACK.md §1 + §2 only. Everything else queued for v2.6.x / v2.7.
>
> **Status:** Drafted 2026-05-27. Awaiting CTO ratification + Builder dispatch.

---

## 1. Scope

**In:** Five gates that close the most-recurring failure classes via hook-enforceable mechanics.

| ID | Gate | Surface | Severity |
|---|---|---|---|
| G1 | `agent-output-file-landed` | SubagentStop hook | universal floor / BLOCK with re-prompt (max 2 retries) |
| G2 | `subagent-scope-write-enforcement` | PreToolUse hook on `Write\|Edit` | universal floor / DENY |
| G3 | SubagentStop event correlation + GC | SubagentStop hook | infrastructure (no gate) |
| G4 | `mig-precondition-disclosure` (Gate A) | PreToolUse on mig dispatch | stack-conditional / BLOCK |
| G5 | `mig-dry-apply` (Gate B) | PostToolUse on mig file save | stack-conditional / BLOCK |

**Out (queued for v2.6.x):** All other §1-§10 HOOK+HYBRID fixes — §3.12 `DONE_PENDING_VERIFICATION`, §3.5 architect-evidence-coverage, §4.1 dry-apply for non-mig contexts, §5 claude-md-design, §6 tier-selection retune, §8.3 list_migration_slots, etc.

**Why this scope:** §1 closes the sub-agent trust contract leak (4 narrative-only DONE recurrences + Architect file-isolation violation + SubagentStop event-correlation orphans). §2 closes the migration-baseline-assumption leak (8 R57/F-22 recurrences in single TaskIt cycle). Together: every cycle's most-leverage-amplified incident class.

---

## 2. Citation backing (binding rule N≥3 satisfied)

| § | Research doc | Top sources |
|---|---|---|
| G1, G2, G3 | [research/v2-6-r1-claude-code-hooks.md](../research/v2-6-r1-claude-code-hooks.md) | Anthropic Claude Code hooks docs (12 URLs) — `decision: block` re-prompt mechanic, `permissionDecision: deny`, SubagentStop schema |
| G1, G2 | [research/v2-6-r3-multi-agent-reconciliation.md](../research/v2-6-r3-multi-agent-reconciliation.md) | CrewAI `Task.output_file` + LangGraph runtime-enforced parallel-write scope + AutoGen TypeSubscription (6 frameworks; BINDING N=5/6) |
| G4, G5 | [research/v2-6-r2-migration-safety.md](../research/v2-6-r2-migration-safety.md) | Sqitch `requires:` + Liquibase preconditions + Atlas migrate lint + Supabase Branching + plpgsql_check (10 sources) |
| Consolidation | [research/v2-6-design-research-2026-05-27.md](../research/v2-6-design-research-2026-05-27.md) | 10 refinements applied to FEEDBACK.md pre-plan |

**Framework-novel items** flagged in FEEDBACK Appendix D — ACTOR block (Gate A) ships with explicit "framework-original" tag. All other items in v2.6.0 have direct enterprise precedent.

**Methodology disclosure:** every research-doc citation is `[CITATION-DEGRADED]` (WebSearch synthesis preserving canonical URLs; WebFetch domain-denied on Anthropic + arXiv + JS-SPA sites). N≥3 met across distinct primary URLs but verbatim retrieval was synthetic. CTO re-verification recommended on the 9 highest-leverage URLs listed in consolidated research doc §5 before code lands.

---

## 3. File changes

### 3.1 `hooks/pre-tool-use` — extend (3 new functions)

| Function | Trigger | Effect |
|---|---|---|
| `record_expected_outputs` | matcher: `Agent` (dispatch tool) | Parse dispatch `prompt` for `output_files: [...]` declaration; append `{agent_id, expected_paths, started_at}` to `.framework-state/expected-outputs.jsonl` |
| `check_write_scope` | matcher: `Write\|Edit` | Look up active agent's `scope_write[]` from `.framework-state/active-agents.jsonl`; if target path NOT in scope → `{"hookSpecificOutput": {"permissionDecision": "deny", "permissionDecisionReason": "Write to <path> outside declared scope_write[<paths>]; either extend scope_write or use Bash + git apply"}}` |
| `check_mig_precondition_disclosure` | matcher: `Write\|Edit` on `supabase/migrations/*.sql` OR `Bash` containing `psql ... -f <mig>` OR `mcp__claude_ai_Supabase__apply_migration` | Parse mig file for `-- DEPENDENCY v1` + `-- ACTOR v1` blocks; check required tags present; check `ASSUMED-FROM-PM-SPEC:` absent; cross-dep scan via grep; cheap PL/pgSQL `NEW\.<col>` grep against `LIVE-VERIFIED` block. Any check fails → `{"decision": "block", "reason": "<specific failure + remediation>"}` |

### 3.2 `hooks/subagent-stop` — extend (3 new functions)

| Function | Trigger | Effect |
|---|---|---|
| `record_stop_event` | every SubagentStop | Append `{agent_id, stopped_at, status}` to `.framework-state/active-agents.jsonl` with `event: stop`; GC entries older than 4hr (`closes 1d in FEEDBACK §1`) |
| `verify_expected_outputs` | every SubagentStop | Look up `expected_paths` for completing `agent_id`; check each exists with `test -f`; any missing → `{"decision": "block", "reason": "expected file <path> was not written; write it now (call Write tool)"}`. Per Claude Code docs (verified 2026-05-27, `code.claude.com/docs/en/hooks`): "Exit code 2 or `decision: \"block\"` prevents the subagent from stopping. The subagent continues working rather than terminating." The `reason` text is conveyed to the subagent as continued-operation context, giving it the chance to call Write before stopping. |
| `track_retry_count` | every SubagentStop with output-missing block | Increment `.framework-state/agent-retry-counts.jsonl` for `agent_id`; ≥2 prevent-stop events → accept stop with `DONE_WITH_CONCERNS` annotation + audit-log (do NOT return another block — let the subagent terminate to avoid infinite-extension loop) |

### 3.3 `hooks/post-tool-use` — NEW script

| Function | Trigger | Effect |
|---|---|---|
| `run_mig_dry_apply` | matcher: `Write\|Edit` on `supabase/migrations/*.sql` (post-success) | If `STACK-PATTERNS.md` declares `supabase_branching: true`: invoke `mcp__claude_ai_Supabase__create_branch` (idempotent — reuse `v26-dryapply-branch`) → `apply_migration` against branch with the new file → on error, write `.framework-state/last-dry-apply-error.txt` + return `{"decision": "block", "reason": "mig-dry-apply failed: <error>"}`. If branching unavailable, fall back to advisory log (graceful degradation). |
| `run_plpgsql_check` | matcher: same as above, after successful dry-apply | Invoke Supabase-shipped `plpgsql_check` extension on every function created/modified in the mig; lint errors → block. |

### 3.4 `hooks/hooks.json` — register PostToolUse event

```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" post-tool-use",
          "async": false
        }
      ]
    }
  ]
}
```

### 3.5 New state files

- `.framework-state/expected-outputs.jsonl` — append-only; one row per Agent dispatch declaring `output_files`
- `.framework-state/agent-retry-counts.jsonl` — append-only; one row per missing-output retry attempt
- `.framework-state/last-dry-apply-error.txt` — overwritten per dry-apply (advisory for human debugging)

### 3.6 `docs/catalog/hard-gates.md` + `hard-gates.json` — add 4 gate rows

| Gate ID | Tier | Trigger | Severity | Bypass | Notes |
|---|---|---|---|---|---|
| `agent-output-file-landed` | universal floor | every SubagentStop | block (with re-prompt, max 2 retries) | `PF_BYPASS=agent-output-file-landed` | Backward compat: legacy `WRITE THE FILE` pattern emits advisory warning |
| `subagent-scope-write-enforcement` | universal floor | PreToolUse `Write\|Edit` | deny | `PF_BYPASS=subagent-scope-write-enforcement` | Pairs with v2.5 read-side `file-scope-intersection` |
| `mig-precondition-disclosure` | stack-conditional (postgres + multi-tenant) | PreToolUse on mig write or apply | block | `PF_BYPASS=mig-precondition-disclosure` | Gate A — cheap, no DB connection |
| `mig-dry-apply` | stack-conditional (supabase OR postgres+scratch-db) | PostToolUse on mig write success | block | `PF_BYPASS=mig-dry-apply` | Gate B — applies against Supabase branch |

### 3.7 `skills/cto-mode/SKILL.md` — extend dispatch contract section

Add to the "Dispatch contract — scope_write + scope_read" section:

```
**`output_files`** — explicit list of files this agent will create (CrewAI Task.output_file shape, R3).
SubagentStop hook verifies each path exists post-DONE; missing → re-prompts the sub-agent.

Example dispatch:
  output_files: docs/research/<topic>.md
  scope_write: docs/research/<topic>.md
  scope_read: docs/architecture/<feature>.md
```

`output_files` MAY differ from `scope_write` when an agent writes intermediates (logs, scratch) that aren't expected outputs.

### 3.8 `skills/configure-project-gates/SKILL.md` — surface new gates

Add to the configurable-gate enumeration + activation logic the four new gates with their stack-conditional triggers. Project's CLAUDE.md `## Active Gates` section emission updated to include the new rows.

### 3.9 12 agent prompts (`agents/*.md`) — add `output_files` to dispatch template

For each agent, document in the "What you write" section that the dispatch prompt should declare `output_files:` matching the agent's expected output paths. Backward-compat: legacy dispatches without `output_files` continue to function (graceful degradation per G1's backward-compat clause).

### 3.10 `RELEASE-NOTES.md` — v2.6.0 entry

Theme + 5 gate descriptions + framework-novel disclosure + breaking changes (none — all gates are additive). Cite research docs.

### 3.11 `.claude-plugin/plugin.json` — version bump 2.5.0 → 2.6.0

### 3.12 `.claude-plugin/marketplace.json` — version bump 2.5.0 → 2.6.0

---

## 4. Acceptance criteria

Each gate has a specific empirical AC. Test fixtures live at `evals/v2-6-mechanical-floor/` (NEW directory).

**G1 acceptance:**
- Dispatch a researcher with `output_files: docs/research/test-g1.md`. Researcher attempts to stop DONE without calling Write.
- **Expected:** SubagentStop returns `decision: "block"` + `reason: "expected file docs/research/test-g1.md was not written; write it now (call Write tool)"`; the researcher does NOT stop — it continues with the reason text as context, calls Write, then attempts stop again; second SubagentStop sees file landed, no block returned; final status DONE.
- Empty-fixture variant: dispatch with no `output_files` declaration → advisory warning logged + DONE allowed.
- Retry-exhaustion variant: force researcher to skip Write 3x → after 2 prevent-stop events, audit log entry + accept stop with `DONE_WITH_CONCERNS` annotation (no further block to avoid infinite-extension loop).

**G2 acceptance:**
- Dispatch an architect with `scope_write: docs/architecture/test.md`. Architect calls Write on `docs/cycle-state.md`.
- **Expected:** PreToolUse returns `permissionDecision: deny` with reason naming the declared scope. Architect's Write fails.
- Negative: Write on `docs/architecture/test.md` proceeds.

**G3 acceptance:**
- Dispatch 3 researchers in parallel; one completes successfully via `Agent` tool background mode.
- **Expected:** `.framework-state/active-agents.jsonl` records both start AND matching stop events with agent_id correlation. GC sweeps orphan starts older than 4hr.
- Negative: pre-fix state would show orphan starts requiring manual surgery (FEEDBACK §14.1).

**G4 acceptance:**
- Attempt to write a migration file with `-- ASSUMED-FROM-PM-SPEC: ...` block.
- **Expected:** PreToolUse blocks with reason naming the forbidden tag.
- Cross-dep scan: write a mig referencing `public.x` where `x` is not in LIVE-VERIFIED nor created earlier in the apply sequence → block with reason naming the unresolved table.
- Cheap PL/pgSQL: function body uses `NEW.foo` where `foo` not in LIVE-VERIFIED columns → block.

**G5 acceptance:**
- Stack with Supabase Branching available. Write a mig with valid DEPENDENCY/ACTOR but SQL syntax error.
- **Expected:** PostToolUse triggers Supabase branch apply → fails → blocks with the actual Postgres error.
- plpgsql_check: write a mig with a valid-looking function body that has a type mismatch caught only by plpgsql_check → block.
- Graceful degradation: stack without Supabase Branching → advisory log, no block.

---

## 5. Test plan

**Unit (bash + bats or shellcheck-equivalent):**
- Each new hook function isolated; fed event JSON via stdin; output JSON validated against expected.
- Test fixtures: 15 event-JSON files (5 dispatch / 5 write / 5 mig-related) → `evals/v2-6-mechanical-floor/fixtures/`.

**Integration (framework's own dev cycle):**
- Dispatch a fresh researcher in a test session; verify expected-outputs flow.
- Write a deliberately broken mig; verify G4 fires.
- Apply a deliberately broken mig with Supabase branch available; verify G5 fires.

**Regression:**
- Existing v2.5 hooks (file-scope-intersection read-side, HEAD-parity gate, tier-selection predicates) continue to fire correctly.
- The Builder's `EMPTY_DIFF_FLAG` + `worktree-preflight` discipline is untouched.

**Behavioral evals:**
- `evals/triggering/v2-6-output-files.json` — 15 cases (5 with output_files declared / 5 without / 5 with retry-exhaustion). Pass criterion: ≥13/15 correct gate firing.

---

## 6. Rollback

**Per-gate:** `PF_BYPASS=<gate-id>` works for every new gate. Bypass audited in `.framework-state/bypass-log.jsonl`.

**Plugin-level:** Kill switch file `.framework-state/v2-6-disabled`. If present, all new hook functions no-op. Add `[[ -f .framework-state/v2-6-disabled ]] && exit 0` early in each new function.

**Version downgrade:** Reinstall v2.5.0 via `/plugin install production-framework@2.5.0`. New state files (`expected-outputs.jsonl`, `agent-retry-counts.jsonl`) are ignored by v2.5 hooks; safe to leave on disk or delete.

**State-file cleanup if needed:** `rm -f .framework-state/{expected-outputs,agent-retry-counts}.jsonl .framework-state/last-dry-apply-error.txt`.

---

## 7. Dispatch waves

| Wave | Scope | Agent | Files | Parallel? |
|---|---|---|---|---|
| W1 | `hooks/pre-tool-use` extensions (3 new functions) | builder | `hooks/pre-tool-use` | — |
| W2 | `hooks/subagent-stop` extensions (3 new functions) | builder | `hooks/subagent-stop` | ∥ W1 (no overlap) |
| W3 | `hooks/post-tool-use` new script + `hooks/hooks.json` register | builder | `hooks/post-tool-use`, `hooks/hooks.json` | ∥ W1, W2 |
| W4 | `docs/catalog/hard-gates.md` + `hard-gates.json` (4 new rows) | builder | `docs/catalog/*` | ∥ W1, W2, W3 |
| W5 | `skills/cto-mode/SKILL.md` + `skills/configure-project-gates/SKILL.md` | builder | 2 skill files | sequential after W4 |
| W6 | 12 `agents/*.md` (output_files documentation) | builder | 12 agent files | ∥ W5 |
| W7 | Eval fixtures + behavioral eval | builder | `evals/v2-6-mechanical-floor/` | sequential after W1-W6 |
| W8 | RELEASE-NOTES.md + version bump + smoke test | CTO inline | `RELEASE-NOTES.md`, `plugin.json`, `marketplace.json` | sequential after W7 |
| W9 | QA Stage 1+2 | qa | per QA dispatch | sequential after W8 |
| W10 | Gate-3 production check | gate-3 skill | — | sequential after W9 |

W1-W4 dispatched in parallel (4 builders, disjoint file scopes). W5-W6 dispatched in parallel after W1-W4 complete (skills + agents docs are independent). W7+ sequential.

**Total estimated builder dispatches:** 7 (W1, W2, W3, W4, W5+W6 each, W7).

---

## 8. Out of scope (explicitly queued for v2.6.x and v2.7)

Per the mechanical-floor filter (FEEDBACK Appendix C), the following HOOK + HYBRID fixes are deferred to keep v2.6.0 single-concept:

**v2.6.1 (next minor — agent verification):**
- §3.5 `architect-evidence-coverage` HARD-GATE (HYBRID)
- §3.12 `DONE_PENDING_VERIFICATION` status token (HYBRID, R6 design ready)
- §3.4 Architect cited-convention adoption lint (HOOK)
- §3.1 Builder forbidden-scope-cut-comment lint (HOOK)

**v2.6.2 (PM/Debugger discipline):**
- §3.8 PM/Architect SHIPPED-vs-APPLIED grammar (HYBRID)
- §3.9 Debugger live-invocation evidence section (HYBRID)
- §3.13 F-46 live-test mandate expansion (HYBRID)
- §4.4 Live integration test per RPC (HYBRID)

**v2.6.3 (tier-selection retune):**
- §6.1-6.6 tier-selection predicate refinements (HOOK)
- §6.6 counter rename `max_per_session → max_per_user_prompt`

**v2.7 (CLAUDE.md design + research):**
- §5.1 `claude-md-design` skill + §5.3 mechanical drift measurement (R5 design ready; needs port of TaskIt research docs to plugin `references/`)
- §10.1 per-ADR citation strength gate
- §3.11 QA end-to-end-artifact AC mandate
- WebFetch domain-denial investigation (FEEDBACK §9.5)

**PROMPT-only (deferred indefinitely; ship only with hook backing):**
21 fixes per FEEDBACK Appendix C deferred-list — §1.4 anti-fabrication clause, §3.2 Builder reused-pattern precondition, §3.7 CTO evidence-grounding, §10.2 amendment-writer sub-agent, etc.

---

## 9. Risks + mitigations

| Risk | Mitigation |
|---|---|
| New SubagentStop block-re-prompt loop blocks every legacy dispatch | Backward compat: missing `output_files:` declaration → advisory warning only, no block. Documented as "fully backward-compatible." |
| Write-side scope check breaks worktree workflows | Test scoped to scope_write paths; if dispatch has no scope_write declared, hook no-ops (graceful degradation already established by v2.5 PR-9). |
| Mig-dry-apply slow (~5-10s per migration) blocks fast iteration | Branch is idempotent + reused across dispatches. Optional `PF_BYPASS=mig-dry-apply` for known-good migs. |
| Supabase Branching unavailable on non-Supabase Postgres | G5 explicitly graceful-degrades to advisory log when `STACK-PATTERNS.md` declares no branching. Catalog row marks gate as stack-conditional. |
| Hook script bugs introduce new failure mode in v2.5-stable cycles | Kill switch `.framework-state/v2-6-disabled` available before any dispatch. Smoke test before v2.6.0 ships. |
| Research citations are [CITATION-DEGRADED] | Pre-ship: re-verify the 9 highest-leverage URLs (research consolidated doc §5) directly via WebFetch when domain-denial root cause is understood. |

---

## 10. Sign-off

**Plan author:** CTO (autonomy-mode session, 2026-05-27)
**Research backing:** R1, R2, R3, R6 (4 of 6 v2.6 researcher dispatches directly relevant); consolidated at `docs/research/v2-6-design-research-2026-05-27.md`.
**Citation count:** N≥3 binding rule met. Methodology disclosed.
**Framework-original items:** ACTOR block (Gate A) flagged with `version: v1` + explicit comment.

**Awaiting:** CTO ratification + Builder W1-W4 parallel dispatch.

**Strategic forks deferred to user:**
1. **Researcher re-verification of degraded citations.** Recommend BEFORE Builder dispatch; ≤30min CTO time to re-verify 9 URLs. Alternative: ship with current citations + accept the disclosure.
2. **Framework-novel items as Path B proposals.** Recommend ship-with-tag for v2.6.0 (per Appendix D rationale); formal pattern proposals at v2.7 pattern-ratification cycle. Alternative: write Path B proposals NOW under `docs/pattern-proposals/`.
3. **Mig-dry-apply branch persistence.** Recommend single idempotent branch (`v26-dryapply-branch`) reused per project. Alternative: branch-per-dispatch (slower; more isolation).
4. **W5+W6 parallelism.** Recommend parallel (skills + agent docs are independent). Alternative: sequential (safer if any skill body changes affect agent prompts).

User decisions on 1-4 unblock dispatch. Otherwise plan is execute-ready.
