#!/usr/bin/env bash
# =============================================================================
# revert-{PATTERN_ID}.sh  —  Rollback script for pattern {PATTERN_ID}
#
# WHEN IS THIS SCRIPT REQUIRED?
#   Only when the pattern proposal has is_state_mutating: true in its
#   frontmatter. A grep-only pattern whose ratification does nothing beyond
#   inserting a row in STACK-PATTERNS.md does NOT need this script; a plain-
#   text revert_procedure field in the proposal frontmatter is sufficient.
#
#   Examples that DO require this script:
#     - Pattern installs or modifies a hook script
#     - Pattern adds/modifies a database schema, index, or config file
#     - Pattern generates files at ratification time that must be removed
#
# G5 STRENGTHENED REQUIREMENTS (Wave 2 R-2 / K8s graduation alignment):
#   - **Idempotency**: re-running this script after a successful revert MUST
#     exit 2 (already applied), NOT exit 1 (failure). The idempotent-guard
#     check below handles this.
#   - **Clean-branch test**: this script MUST be tested on a fresh git
#     checkout (no uncommitted changes) before being committed. The CI / G5
#     check requires evidence of this test.
#
# EXIT CODES:
#   0  — revert completed successfully
#   1  — revert failed (see stderr for details)
#   2  — revert already applied (idempotent guard: pattern row not found)
#
# HOW TO USE:
#   1. Copy this file to docs/pattern-proposals/revert-{PATTERN_ID}.sh
#   2. Replace every {PLACEHOLDER} with the real value for this pattern
#   3. Fill in the revert steps in the REVERT STEPS section below
#   4. chmod +x the script (required by G5 check_proposal_has_revert)
#   5. Test it twice: (a) on a clean branch — must exit 0; (b) immediately
#      re-run — must exit 2 (idempotency confirmation)
#
# CARRYFORWARD: ported from PF v1 with G5 strengthening per Wave 2 R-2.
# =============================================================================

set -euo pipefail

PATTERN_ID="{PATTERN_ID}"   # e.g. BP-12
STACK_PATTERNS_FILE="${STACK_PATTERNS_FILE:-STACK-PATTERNS.md}"
PROPOSALS_DIR="${PROPOSALS_DIR:-docs/pattern-proposals}"

# ---------------------------------------------------------------------------
# Idempotent guard: check pattern is actually present before reverting
# (G5 — re-run after revert MUST exit 2, not 1)
# ---------------------------------------------------------------------------
if ! grep -qE "^\| ${PATTERN_ID} \|" "${STACK_PATTERNS_FILE}" 2>/dev/null; then
  echo "[revert-${PATTERN_ID}] Pattern row not found in ${STACK_PATTERNS_FILE}. Already reverted or never ratified." >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Clean-branch precondition (G5 — Wave 2 R-2)
# Reject if uncommitted changes outside the pattern files we're about to touch.
# ---------------------------------------------------------------------------
if command -v git >/dev/null 2>&1 && [ -d ".git" ]; then
  UNCOMMITTED=$(git diff --name-only HEAD 2>/dev/null | grep -vE "^(${STACK_PATTERNS_FILE//./\\.}|${PROPOSALS_DIR//./\\.}/|tests/fixtures/proposals/${PATTERN_ID}/)" || true)
  if [ -n "$UNCOMMITTED" ]; then
    echo "[revert-${PATTERN_ID}] Uncommitted changes detected outside the pattern's file set:" >&2
    printf '  %s\n' $UNCOMMITTED >&2
    echo "[revert-${PATTERN_ID}] Commit or stash these before reverting (G5 clean-branch precondition)." >&2
    exit 1
  fi
fi

echo "[revert-${PATTERN_ID}] Starting revert..."

# ---------------------------------------------------------------------------
# REVERT STEPS — fill in for each state-mutating action performed at
# ratification. Each step should be idempotent where possible.
# ---------------------------------------------------------------------------

# Step 1 — Remove pattern row from STACK-PATTERNS.md
# (required for every state-mutating pattern)
if grep -qE "^\| ${PATTERN_ID} \|" "${STACK_PATTERNS_FILE}"; then
  # Use a temp file to avoid in-place sed portability issues (macOS vs Linux)
  tmp=$(mktemp)
  grep -vE "^\| ${PATTERN_ID} \|" "${STACK_PATTERNS_FILE}" > "${tmp}"
  mv "${tmp}" "${STACK_PATTERNS_FILE}"
  echo "[revert-${PATTERN_ID}] Removed row from ${STACK_PATTERNS_FILE}"
fi

# Step 2 — Remove fixture files
# (generated at ratification; remove if present)
FIXTURE_DIR="tests/fixtures/proposals/${PATTERN_ID}"
if [ -d "${FIXTURE_DIR}" ]; then
  rm -rf "${FIXTURE_DIR}"
  echo "[revert-${PATTERN_ID}] Removed fixture directory ${FIXTURE_DIR}"
fi

# Step 3 — {PATTERN-SPECIFIC REVERT STEPS}
# Add steps here for any state-mutating actions specific to this pattern.
# Examples:
#   - Remove a hook modification:  git checkout -- hooks/some-hook.sh
#   - Revert a schema file:        git checkout HEAD -- path/to/schema.sql
#   - Delete generated artifacts:  rm -f path/to/generated-file
#
# {TODO: replace this block with real steps. Each step should be idempotent
# (safe to re-run after partial completion).}

# Step 4 — Mark proposal as reverted (if archive entry exists)
ARCHIVE_GLOB="${PROPOSALS_DIR}/archive/*-${PATTERN_ID}.md"
for archive_file in ${ARCHIVE_GLOB}; do
  if [ -f "${archive_file}" ]; then
    # Replace state: ratified with state: reverted
    tmp=$(mktemp)
    sed 's/^state: ratified/state: reverted/' "${archive_file}" > "${tmp}"
    mv "${tmp}" "${archive_file}"
    echo "[revert-${PATTERN_ID}] Updated state to reverted in ${archive_file}"
  fi
done

echo "[revert-${PATTERN_ID}] Revert complete. Exit 0."
exit 0
