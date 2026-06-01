#!/usr/bin/env bash
# =============================================================================
# F-V41 regression test — scope_write / scope_read / output_files parsing must
# NOT truncate paths.
#
# Bug (RED before fix): hooks/pre-tool-use keeps JSON-escaped "\n" in the prompt
# and parses scope with `grep -oE '...[^\n]+'`. In grep ERE, [^\n] means
# "not backslash, not n", so every path truncates at its first literal 'n':
# "production-framework/..." -> "productio". GREEN after the proper fix.
#
# Drives the REAL hook end-to-end (integration test). Zero deps.
# =============================================================================
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="$(cd "${SCRIPT_DIR}/../../hooks" && pwd)/pre-tool-use"

fail=0
check() { # label want got
  if [ "$2" = "$3" ]; then
    printf 'PASS  %s\n' "$1"
  else
    printf 'FAIL  %s\n        want: [%s]\n        got:  [%s]\n' "$1" "$2" "$3"
    fail=1
  fi
}

TMP="$(mktemp -d)"
export CLAUDE_PROJECT_DIR="$TMP"
mkdir -p "$TMP/.framework-state"

# Realistic Agent dispatch: prompt is a JSON string with ESCAPED newlines (\n)
# and scope paths containing the letter 'n' (production-framework/...).
PROMPT='intro line\noutput_files: production-framework/docs/research/ci.md\nscope_write: production-framework/docs/research/ci.md\nscope_read: production-framework/docs/PROJECT-PLAN.md\ntrailer text'
INPUT=$(printf '{"tool_name":"Agent","subagent_type":"production-framework:researcher","prompt":"%s"}' "$PROMPT")

printf '%s' "$INPUT" | bash "$HOOK" >/dev/null 2>&1 || true

agents="$TMP/.framework-state/active-agents.jsonl"
expected="$TMP/.framework-state/expected-outputs.jsonl"

got_sw=$(grep -o '"scope_write":"[^"]*"'  "$agents"   2>/dev/null | head -1 | sed 's/^"scope_write":"//;  s/"$//')
got_sr=$(grep -o '"scope_read":"[^"]*"'   "$agents"   2>/dev/null | head -1 | sed 's/^"scope_read":"//;   s/"$//')
got_of=$(grep -o '"output_files":"[^"]*"' "$expected" 2>/dev/null | head -1 | sed 's/^"output_files":"//; s/"$//')

check "scope_write intact"  "production-framework/docs/research/ci.md"  "$got_sw"
check "scope_read intact"   "production-framework/docs/PROJECT-PLAN.md" "$got_sr"
check "output_files intact" "production-framework/docs/research/ci.md"  "$got_of"

rm -rf "$TMP"
[ "$fail" -eq 0 ] && echo "--- ALL GREEN ---" || echo "--- RED ---"
exit $fail
