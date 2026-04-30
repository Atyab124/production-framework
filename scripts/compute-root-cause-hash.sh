#!/usr/bin/env bash
# =============================================================================
# compute-root-cause-hash.sh — Deterministic SHA-256 hash for incident text
#
# PURPOSE:
#   Normalizes incident text and emits a SHA-256 hash. Two incidents with the
#   same root cause shape (differing only in UUIDs, ISO dates, line numbers,
#   or whitespace) produce the same hash. Used by the Post-Mortem agent to
#   cluster incidents and enforce the independent-incidence requirement
#   (3 distinct hashes required before a pattern proposal qualifies for Path A
#   per ADR-003).
#
# Also invoked by `fix-time-hash-check` skill at fix time to surface prior
# occurrences of the same root cause class.
#
# USAGE:
#   # From stdin:
#   echo "Server action shipped without error check on .single() call" | bash compute-root-cause-hash.sh
#
#   # As argument:
#   bash compute-root-cause-hash.sh "Server action shipped without error check on .single() call"
#
# OUTPUT:
#   A single SHA-256 hex string on stdout (64 characters), e.g.:
#   a3f9b2c1d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1
#
# EXIT CODES:
#   0 — hash computed successfully
#   1 — no input provided (stdin empty AND no argument given)
#
# NORMALIZATION RULES (pinned — do not edit without incrementing HASH_VERSION):
#   1. Lowercase entire string
#   2. Strip UUIDs (8-4-4-4-12 hex pattern)
#   3. Strip ISO 8601 dates (YYYY-MM-DD, YYYY-MM-DDTHH:MM:SSZ patterns)
#   4. Strip file:line references (e.g., "foo.ts:42" → "foo.ts")
#   5. Strip numeric-only tokens (standalone integers)
#   6. Collapse all whitespace (tabs, newlines, multiple spaces) to single space
#   7. Trim leading and trailing whitespace
#
# HASH_VERSION: 1
# If normalization rules change, bump HASH_VERSION and document the migration.
# Old hashes from HASH_VERSION 0 must be recomputed via:
#   bash scripts/compute-root-cause-hash.sh "$incident_text" > new_hash
#
# ENTERPRISE CORROBORATION:
#   Rollbar + Datadog independently corroborate this 7-rule normalization
#   grammar verbatim (per docs/research/skill-design-fix-time-hash-check.md).
#   This is enterprise-consensus, not a PF-bespoke invention.
#
# CARRYFORWARD: ported verbatim from PF v1 per ADR-001 G3 amendment + ADR-003.
# =============================================================================

set -euo pipefail

HASH_VERSION=1

# ---------------------------------------------------------------------------
# Read input: argument takes precedence over stdin
# ---------------------------------------------------------------------------
if [ $# -ge 1 ] && [ -n "$1" ]; then
  input="$1"
else
  # Read from stdin
  input=$(cat)
fi

if [ -z "$input" ]; then
  echo "Error: no incident text provided. Pass as argument or pipe to stdin." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Normalize
# ---------------------------------------------------------------------------

normalized=$(printf '%s' "$input" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}//gi' \
  | sed -E 's/[0-9]{4}-[0-9]{2}-[0-9]{2}(t[0-9]{2}:[0-9]{2}:[0-9]{2}(z|[+-][0-9]{2}:[0-9]{2}))?//gi' \
  | sed -E 's/:[0-9]+\b//g' \
  | sed -E 's/\b[0-9]+\b//g' \
  | tr -s '[:space:]' ' ' \
  | sed -E 's/^ //;s/ $//')

# ---------------------------------------------------------------------------
# Hash
# ---------------------------------------------------------------------------

# sha256sum (Linux) vs shasum -a 256 (macOS) — detect and use whichever is available
if command -v sha256sum >/dev/null 2>&1; then
  hash=$(printf '%s' "$normalized" | sha256sum | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
  hash=$(printf '%s' "$normalized" | shasum -a 256 | awk '{print $1}')
else
  echo "Error: neither sha256sum nor shasum found. Install coreutils (Linux) or use macOS built-in." >&2
  exit 1
fi

printf '%s\n' "$hash"

# =============================================================================
# Self-test comment block
# Run these manually to verify normalization determinism:
#
# TEST 1 — UUID stripping (same hash expected):
#   echo "Action failed on row 3f1a2b3c-1234-5678-9abc-def012345678" | bash compute-root-cause-hash.sh
#   echo "Action failed on row 99999999-aaaa-bbbb-cccc-dddddddddddd" | bash compute-root-cause-hash.sh
#   # Both should produce identical hashes.
#
# TEST 2 — Date stripping (same hash expected):
#   echo "Incident on 2026-03-14: server error in payments" | bash compute-root-cause-hash.sh
#   echo "Incident on 2024-11-02: server error in payments" | bash compute-root-cause-hash.sh
#   # Both should produce identical hashes.
#
# TEST 3 — Line number stripping (same hash expected):
#   echo "Null pointer at src/lib/payments.ts:142" | bash compute-root-cause-hash.sh
#   echo "Null pointer at src/lib/payments.ts:899" | bash compute-root-cause-hash.sh
#   # Both should produce identical hashes.
#
# TEST 4 — Distinct incidents (different hashes expected):
#   echo "Missing error check on database read" | bash compute-root-cause-hash.sh
#   echo "Unbounded query result set returned to client" | bash compute-root-cause-hash.sh
#   # Should produce DIFFERENT hashes.
#
# TEST 5 — Whitespace normalization (same hash expected):
#   echo "  action   failed   on   render   " | bash compute-root-cause-hash.sh
#   echo "action failed on render" | bash compute-root-cause-hash.sh
#   # Both should produce identical hashes.
# =============================================================================
