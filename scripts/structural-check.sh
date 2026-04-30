#!/usr/bin/env bash
# =============================================================================
# structural-check.sh — Framework-internal structural checks for PF v2
#
# v2.0 SCOPE: This is a MINIMAL port of PF v1's structural-check.sh.
# Only Rule #43 (check_incident_logged) is included in v2.0; other v1 checks
# (bloat-cap, fixture-gate, framework-health, etc.) ship with the proposing-
# patterns / ratify-pattern carryforward and may be added incrementally.
#
# USAGE:
#   bash scripts/structural-check.sh [target-dir]
#   target-dir defaults to current directory
# Exit: 0 = pass, 1 = one or more checks failed
#
# Adding checks:
#   1. Define a function check_<name>() returning 0 (pass) or 1 (fail)
#      and printing a human-readable message to stderr on failure.
#   2. Add the function name (as a string) to the CHECKS array below.
#   3. Re-run to verify.
#
# v2.0 framework checks (Rule #43 carryforward only — others scaffold for v2.1+):
#   check_incident_logged — Rule 43: incident row required when remediation-loop-count >1
#                           OR post-mortem-trigger flag exists
#
# CARRYFORWARD: function body ported verbatim from PF v1
# (production-framework/scripts/structural-check.sh:540-582).
# =============================================================================

set -euo pipefail

TARGET_DIR="${1:-.}"
FAILED=0

# ── Universal check functions ─────────────────────────────────────────────────

check_incident_logged() {
  # Rule 43: when remediation-loop-count >1 OR post-mortem trigger flag exists,
  # PROJECT-PLAN must have a new incident row with today's ISO date.
  #
  # This is the MACHINE-enforcement half of the v2 incident-loop primitive.
  # Item 41 (audit) names Rule #43 as "the most carefully engineered subsystem
  # in v1" — triple-enforced (this script + RULE(agent:deputy) + RULE(agent:post-mortem)).
  local STATE_DIR="${TARGET_DIR}/.framework-state"
  local LOOP_COUNT_FILE="${STATE_DIR}/remediation-loop-count"
  local PM_TRIGGER_FILE="${STATE_DIR}/post-mortem-trigger"

  [[ "${CHECKS_VERBOSE:-0}" == "1" ]] && echo "[structural] check_incident_logged: inspecting ${STATE_DIR}" >&2

  # Check if either trigger condition is active
  TRIGGER_ACTIVE=0
  if [ -f "$LOOP_COUNT_FILE" ]; then
    LOOP_COUNT=$(cat "$LOOP_COUNT_FILE" 2>/dev/null | tr -d '[:space:]' || echo "0")
    if [ "$LOOP_COUNT" -gt 1 ] 2>/dev/null; then
      TRIGGER_ACTIVE=1
    fi
  fi
  if [ -f "$PM_TRIGGER_FILE" ]; then
    TRIGGER_ACTIVE=1
  fi

  if [ "$TRIGGER_ACTIVE" -eq 0 ]; then
    return 0  # No trigger — check not applicable
  fi

  # Find PROJECT-PLAN.md — honor CONFIG.yaml file_paths.project_plan first (F-V5),
  # fall back to convention path docs/PROJECT-PLAN.md.
  local CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${TARGET_DIR}}"
  local CONFIG_FILE="${CLAUDE_PROJECT_DIR}/CONFIG.yaml"
  local PLAN_REL=""
  if [ -f "$CONFIG_FILE" ]; then
    # Match the project_plan: line under file_paths; tolerate quoted/unquoted values
    PLAN_REL=$(grep -E '^[[:space:]]+project_plan:' "$CONFIG_FILE" 2>/dev/null | head -1 | sed -E 's/^[[:space:]]+project_plan:[[:space:]]*"?([^"]+)"?[[:space:]]*$/\1/' | tr -d ' \r')
  fi
  local PLAN_FILE=""
  if [ -n "$PLAN_REL" ] && [ -f "${CLAUDE_PROJECT_DIR}/${PLAN_REL}" ]; then
    PLAN_FILE="${CLAUDE_PROJECT_DIR}/${PLAN_REL}"
  fi
  if [ -z "$PLAN_FILE" ] && [ -f "${CLAUDE_PROJECT_DIR}/docs/PROJECT-PLAN.md" ]; then
    PLAN_FILE="${CLAUDE_PROJECT_DIR}/docs/PROJECT-PLAN.md"
  fi
  if [ -z "$PLAN_FILE" ] && [ -f "${TARGET_DIR}/docs/PROJECT-PLAN.md" ]; then
    PLAN_FILE="${TARGET_DIR}/docs/PROJECT-PLAN.md"
  fi
  if [ -z "$PLAN_FILE" ]; then
    echo "[structural] FAIL check_incident_logged: remediation-loop-count >1 or post-mortem triggered but PROJECT-PLAN.md not found (checked CONFIG.yaml file_paths.project_plan + docs/PROJECT-PLAN.md). Create it with an incident row for today." >&2
    return 1
  fi

  # Check for today's ISO date in the incident table
  TODAY=$(date -u +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)
  if ! grep -q "$TODAY" "$PLAN_FILE" 2>/dev/null; then
    echo "[structural] FAIL check_incident_logged: remediation-loop or post-mortem triggered but no incident row with date ${TODAY} found in ${PLAN_FILE}. Rule 43: append an incident row before proceeding." >&2
    return 1
  fi
  return 0
}

# ── Check registry ────────────────────────────────────────────────────────────

CHECKS=(
  "check_incident_logged"
  # v2.1+: bloat_cap, duplicate_incident_hash, proposal_has_machine_check,
  # orphan_pattern_rows, proposal_has_revert, proposal_has_fixture, etc.
)

# ── Runner ────────────────────────────────────────────────────────────────────

echo "[structural] Running ${#CHECKS[@]} check(s) against ${TARGET_DIR}"

for CHECK in "${CHECKS[@]}"; do
  if ! $CHECK; then
    FAILED=1
  fi
done

if [ $FAILED -eq 0 ]; then
  echo "[structural] All checks PASSED"
  exit 0
else
  echo "[structural] One or more checks FAILED — see output above" >&2
  exit 1
fi
