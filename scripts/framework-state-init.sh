#!/usr/bin/env bash
# =============================================================================
# framework-state-init.sh — Initialize .framework-state/session.json on SessionStart
#
# Called from hooks/session-start at session start (and on /compact via the
# SessionStart matcher) to ensure the per-session state file exists with the
# right shape.
#
# PURPOSE:
#   Per ADR-002 D-A bundle: hooks/pre-tool-use.sh reads session.json to gate
#   Edit/Write/Bash on prerequisite skill invocation timestamps. The init
#   script bootstraps the file with empty timestamps; skill invocations
#   update it.
#
# CARRYFORWARD: scaffolding-only. PF v1 had a similar primitive in
# scripts/setup-framework-state.sh (not directly ported; v2 has different
# state shape).
# =============================================================================

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
STATE_DIR="${PROJECT_DIR}/.framework-state"
SESSION_FILE="${STATE_DIR}/session.json"

mkdir -p "${STATE_DIR}"

# Always reset session state on SessionStart (matcher fires on startup|clear|compact).
# Each /clear or /compact resets the conversation, so timestamps reset too —
# user must re-invoke tier-selection on the next task-shape prompt.
cat > "${SESSION_FILE}" <<EOF
{
  "session_started_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "tier_selection_invoked_at": "",
  "triage_invoked_at": "",
  "last_user_prompt_at": ""
}
EOF

# Touch bypass-log if missing (append-only)
BYPASS_LOG="${STATE_DIR}/bypass-log.jsonl"
[ -f "${BYPASS_LOG}" ] || touch "${BYPASS_LOG}"

exit 0
