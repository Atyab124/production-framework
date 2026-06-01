#!/usr/bin/env bash
# =============================================================================
# F-V41 Defects 2 & 3 — start/stop correlation + §1.2 writer-context.
# Drives the real pre-tool-use hook with crafted .framework-state state.
# =============================================================================
set -u
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="$(cd "${SCRIPT_DIR}/../../hooks" && pwd)/pre-tool-use"
NOW=$(date +%s)
fail=0
pass(){ printf 'PASS  %s\n' "$1"; }
bad(){ printf 'FAIL  %s\n        out: %s\n' "$1" "$2"; fail=1; }
setup(){ TMP=$(mktemp -d); export CLAUDE_PROJECT_DIR="$TMP"; mkdir -p "$TMP/.framework-state"; AA="$TMP/.framework-state/active-agents.jsonl"; }
teardown(){ rm -rf "$TMP"; }
run(){ printf '%s' "$1" | bash "$HOOK" 2>/dev/null; }
start_line(){ printf '{"started_at":"x","started_at_epoch":%d,"subagent_type":"%s","scope_write":"%s","scope_read":"","event":"start"}\n' "$NOW" "$1" "$2"; }
stop_line(){ printf '{"completed_at":"y","completed_at_epoch":%d,"subagent_type":"unknown","agent_id":"abc","agent_type":"%s","event":"stop"}\n' "$NOW" "$1"; }

SC="production-framework/docs/research/ci.md"

# Defect 2 — producer DONE (start + matching stop) → consumer read must be ALLOWED
setup; { start_line "production-framework:researcher" "$SC"; stop_line "production-framework:researcher"; } >> "$AA"
OUT=$(run "{\"tool_name\":\"Agent\",\"subagent_type\":\"production-framework:architect\",\"prompt\":\"scope_read: ${SC}\"}")
case "$OUT" in *'"permissionDecision":"deny"'*) bad "Defect2: completed producer must NOT block consumer" "$OUT";; *) pass "Defect2: completed producer -> consumer ALLOWED";; esac
teardown

# Control — producer STILL in-flight (start, no stop) → consumer must be BLOCKED
setup; start_line "production-framework:researcher" "$SC" >> "$AA"
OUT=$(run "{\"tool_name\":\"Agent\",\"subagent_type\":\"production-framework:architect\",\"prompt\":\"scope_read: ${SC}\"}")
case "$OUT" in *'file-scope-intersection'*) pass "Control: in-flight producer -> consumer BLOCKED (gate still works)";; *) bad "Control: in-flight producer SHOULD block" "$OUT";; esac
teardown

# Defect 3a — main-session write (no agent_type) must NOT be bound by §1.2
setup; start_line "production-framework:researcher" "$SC" >> "$AA"
OUT=$(run '{"tool_name":"Write","file_path":"src/foo.ts","content":"hello world"}')
case "$OUT" in *'subagent-scope-write-enforcement'*) bad "Defect3a: main-session write must NOT hit §1.2" "$OUT";; *) pass "Defect3a: main-session write NOT bound by in-flight sub-agent scope";; esac
teardown

# Defect 3b — sub-agent write OUTSIDE its scope → §1.2 must still DENY
setup; start_line "production-framework:researcher" "$SC" >> "$AA"
OUT=$(run '{"tool_name":"Write","file_path":"production-framework/docs/OTHER.md","content":"hi","agent_type":"production-framework:researcher"}')
case "$OUT" in *'subagent-scope-write-enforcement'*) pass "Defect3b: sub-agent write OUTSIDE scope -> DENY (gate still works)";; *) bad "Defect3b: sub-agent out-of-scope write SHOULD deny" "$OUT";; esac
teardown

# Defect 3c — sub-agent write INSIDE its scope → must NOT deny
setup; start_line "production-framework:researcher" "$SC" >> "$AA"
OUT=$(run "{\"tool_name\":\"Write\",\"file_path\":\"${SC}\",\"content\":\"hi\",\"agent_type\":\"production-framework:researcher\"}")
case "$OUT" in *'subagent-scope-write-enforcement'*) bad "Defect3c: in-scope sub-agent write must NOT deny" "$OUT";; *) pass "Defect3c: sub-agent write INSIDE scope ALLOWED";; esac
teardown

[ "$fail" -eq 0 ] && echo "--- ALL GREEN ---" || echo "--- RED ---"
exit $fail
