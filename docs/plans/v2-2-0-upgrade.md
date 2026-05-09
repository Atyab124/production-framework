# v2.2.0 Consolidated Upgrade — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `production-framework:executing-plans` (inline execution preferred for this release because the Builder sub-agent is itself in scope of these fixes — see Bootstrap Deviation below). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship every closable empirical finding logged in `docs/PROJECT-PLAN.md` plus the implementable layers of `docs/adr/006-v2-2-detection-adaptation-recovery-layer.md` as one consolidated v2.2.0 upgrade. Replaces the prior v2.1.1 production fix / v2.2.0 upgrade split per user direction 2026-05-09.

**Architecture:** `docs/adr/006-v2-2-detection-adaptation-recovery-layer.md` (5-layer design: Detection / Adaptation / Recovery / Path-norm / Measurement). Strength preservation per WS4 adversarial research: every fix preserves the BLOCKING semantic of HARD-GATEs; tunes only firing-rate / UX layer, never gate-fire layer.

**Research backing:** Five v2.2.0 research docs (`docs/research/v2-2-{detection,adaptation,recovery,strength-preservation,measurement}-2026-04-30.md`), reconciliation report (`docs/reconciliation/v2-2-research-2026-04-30.md`), implementation-readiness assessment (`docs/research/implementation-assessment-2026-05-09.md`).

**Tech stack:** Bash (hook scripts; portable, no `jq`), Markdown (skills, agents, docs), JSONL (state files, regression tests, eval scaffolds). Zero runtime dependencies per CLAUDE.md.

## Bootstrap Deviation (declared)

The Builder sub-agent's behavior is in scope of this very release (F-V10, F-V20, F-V21 all touch Builder dispatch). Implementation therefore happens via direct CTO main-session edits, not via Builder dispatch. The first release that ships dogfood-via-Builder-dispatch is v2.2.1+ once the Builder-related fixes have landed and stabilized. Marked explicitly in `docs/cycle-state.md` and amended ADR-006 status note.

## Out of scope (with reasons)

| Item | Why deferred |
|---|---|
| F-V9 A1 (cycle-state.md skill cooperation) | WS4 FM-12 cache-poisoning concern unresolved — cycle-close detection is LLM-self-attested |
| F-V11 (real-input regression for browser-driven-verification) | Overrides existing skill body lines 110-112; needs decision on what replaces them |
| F-V12 (Tier-2 ceremony fast-path threshold) | Needs WS4-aware default-deny + 8-trigger-test specification |
| ADR-006 D2 (real-user smoke for closure-staleness/race) | Depends on F-V11 design |
| F-V14, F-V15, F-V16 | Not implementable as code — need second/third project onboarding (F-V14), team-mode research (F-V15), CI/deploy research (F-V16) |
| F-V19 | Builder permission failure reproduction not attempted; depends on F-V20 fix to disambiguate |
| F-V21 | Likely Claude Code-side worktree behavior; not a framework-side fix |
| FD-03 | Reply-shape design parked explicitly per user |
| ADR-006 M3-M5 | Depends on F-V14 cross-project signal |

---

## File Structure

Files this plan touches:

| File | Responsibility | Phase |
|---|---|---|
| `hooks/pre-tool-use` | Path normalization (F-V13); sub-agent inheritance (F-V20); MCP error logging (R2) | A |
| `hooks/user-prompt-submit` | System-reminder filter (F-V9 A2) | A |
| `agents/builder.md` | Dispatch verb language (F-V7); scope declaration + empty-diff gate (F-V10 + D1) | B |
| `agents/researcher.md` | Post-Write file-existence check (D3) | B |
| `agents/debugger.md` | Profiler-mode instrumentation gate (D4) | B |
| `agents/qa.md` | Empty-diff REJECT semantics (D5) | B |
| `skills/cto-mode/SKILL.md` | Builder-dispatch verb template (F-V7) | B |
| `skills/dispatching-parallel-agents/SKILL.md` | Foreground/background subsection (F-V18) | C |
| `skills/browser-driven-verification/SKILL.md` | Common Recovery section (F-V8 + R1 + R3) | C |
| `skills/rls-aware-migrations/SKILL.md` | Common Recovery section (R1) | C |
| `skills/finishing-a-development-branch/SKILL.md` | Common Recovery section (R1) | C |
| `skills/enterprise-research-first/SKILL.md` | Common Recovery section (R1) | C |
| `docs/onboarding-brownfield.md` | New brownfield onboarding doc (F-V17) | D |
| `scripts/measurement.sh` | Session-derived metrics + project-agnostic emitter (M1, M2) | E |
| `docs/research/sp-anthropic-citation-manifest.md` | New rows for D1-D5, A2, R1-R3, M1-M2 | F |
| `evals/regression/<id>.json` | Regression test per closed finding (Gate 3) | F |
| `RELEASE-NOTES.md` | v2.2.0 entry | G |
| `.claude-plugin/plugin.json` + `marketplace.json` | Version bump 2.1.0 → 2.2.0 | G |
| `docs/PROJECT-PLAN.md` | Mark closed findings RESOLVED | G |
| `docs/audits/qa-findings-v2-2-0.md` | QA Stage 1 + Stage 2 (sub-agent dispatch) | H |
| `docs/audits/code-review-v2-2-0.md` | Code-reviewer audit (sub-agent dispatch) | H |
| `docs/handovers/v2-2-0.md` | Release handover | H |

---

# Phase A — Hook fixes

### Task 1: F-V13 — Windows path normalization in `pre-tool-use`

**Files:**
- Modify: `hooks/pre-tool-use:213-218`

**Symptom:** Every Windows doc-only edit hits the tier-selection HARD-GATE despite the early-allow pattern at line 215-217, because the case-statement uses forward slashes (`*/docs/*`) and Windows file paths arrive with backslashes (`c:\...\docs\...`).

- [ ] **Step 1: Read current code**

```bash
sed -n '213,218p' hooks/pre-tool-use
```

Expected current content:
```bash
  # Skip gate if file_path is in framework state or docs (workflow files)
  if [ -n "${FILE_PATH}" ]; then
    case "${FILE_PATH}" in
      */.framework-state/*|*/docs/*|*/.claude-plugin/*) allow ;;
    esac
  fi
```

- [ ] **Step 2: Replace with path-normalized version**

Replace lines 213-218 with:

```bash
  # Skip gate if file_path is in framework state or docs (workflow files)
  # Normalize backslash to forward-slash for Windows path compatibility
  if [ -n "${FILE_PATH}" ]; then
    FILE_PATH_NORM="${FILE_PATH//\\//}"
    case "${FILE_PATH_NORM}" in
      */.framework-state/*|*/docs/*|*/.claude-plugin/*) allow ;;
    esac
  fi
```

- [ ] **Step 3: Verify with bash syntax check**

Run:
```bash
bash -n hooks/pre-tool-use
```

Expected: no output, exit code 0.

- [ ] **Step 4: Verify with simulated Windows path input**

Run:
```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":"c:\\Users\\test\\Experimental - Users\\production-framework-v2\\docs\\PROJECT-PLAN.md"}}' | bash hooks/pre-tool-use
```

Expected output (allow case fires because path normalization matches `*/docs/*`):
```
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}
```

- [ ] **Step 5: Verify with simulated POSIX path input (regression check)**

Run:
```bash
echo '{"tool_name":"Edit","tool_input":{"file_path":"/home/user/project/docs/PROJECT-PLAN.md"}}' | bash hooks/pre-tool-use
```

Expected: same `permissionDecision:"allow"` (existing behavior preserved).

---

### Task 2: F-V20 — Sub-agent tier-selection inheritance in `pre-tool-use`

**Files:**
- Modify: `hooks/pre-tool-use:200-241` (before the Gate 1 tier-selection block)

**Symptom:** The hook fires the tier-selection gate on every sub-agent's first Edit/Write/Bash regardless of the parent's classification. Every Builder/Researcher/Architect dispatch must redundantly invoke `production-framework:tier-selection` in its own context, OR hit gate-deny.

**Fix shape:** When `SUBAGENT_TYPE` is set in the tool input (signals this Edit/Write/Bash originated from a sub-agent dispatch), AND the parent session's `tier_selection_invoked_at` is populated and ≥ `last_user_prompt_at`, skip the gate. The parent's classification carries through. Strength preservation: gate logic at the parent layer is untouched; only the redundant re-fire at the sub-agent layer is suppressed.

- [ ] **Step 1: Read current code**

```bash
sed -n '200,225p' hooks/pre-tool-use
```

- [ ] **Step 2: Insert sub-agent inheritance check before Gate 1**

After line 199 (the closing `fi` of Gate 5 dep-add) and before line 201 (the Gate 1 comment), insert:

```bash

# ---------------------------------------------------------------------------
# Sub-agent tier-selection inheritance (F-V20)
# When SUBAGENT_TYPE is set, this Edit/Write/Bash originated from a sub-agent
# dispatch. The parent session already passed tier-selection (if applicable).
# Inherit the parent's verdict instead of re-firing the gate per sub-agent.
# Strength preservation: gate at parent layer is untouched; this only
# suppresses redundant per-sub-agent re-fire. Cited: WS2 Q8 BINDING (4/4
# frameworks: OpenAI Agents SDK / LangGraph / AutoGen / Anthropic).
# ---------------------------------------------------------------------------
if [ -n "${SUBAGENT_TYPE:-}" ] && [ -n "${TIER_SELECTION_TS}" ] && [ -n "${LAST_USER_PROMPT_TS}" ]; then
  if [[ "${TIER_SELECTION_TS}" > "${LAST_USER_PROMPT_TS}" ]] || [[ "${TIER_SELECTION_TS}" == "${LAST_USER_PROMPT_TS}" ]]; then
    # Parent passed tier-selection; sub-agent inherits.
    log_invocation "subagent_inherit" "${SUBAGENT_TYPE}"
    allow
  fi
fi
```

Important: `SUBAGENT_TYPE` is parsed at line 147 of the existing hook. The check belongs after the read of `TIER_SELECTION_TS` and `LAST_USER_PROMPT_TS` (lines 174-177), so place it AFTER line 199 (end of Gate 5) and BEFORE line 201 (Gate 1 comment).

- [ ] **Step 3: Verify bash syntax**

```bash
bash -n hooks/pre-tool-use
```

Expected: no output, exit 0.

- [ ] **Step 4: Verify sub-agent dispatch with parent passed**

```bash
mkdir -p /tmp/pf-test-state
cat > /tmp/pf-test-state/session.json <<EOF
{
  "session_started_at": "2026-05-09T10:00:00Z",
  "tier_selection_invoked_at": "2026-05-09T10:01:00Z",
  "triage_invoked_at": "",
  "last_user_prompt_at": "2026-05-09T10:00:30Z"
}
EOF
CLAUDE_PROJECT_DIR=/tmp/pf-test-state echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/x.txt","subagent_type":"production-framework:builder"}}' | bash hooks/pre-tool-use
```

Expected: `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}` (because parent passed tier-selection AFTER last user prompt).

- [ ] **Step 5: Verify sub-agent dispatch when parent did NOT pass**

```bash
cat > /tmp/pf-test-state/session.json <<EOF
{
  "session_started_at": "2026-05-09T10:00:00Z",
  "tier_selection_invoked_at": "",
  "triage_invoked_at": "",
  "last_user_prompt_at": "2026-05-09T10:00:30Z"
}
EOF
CLAUDE_PROJECT_DIR=/tmp/pf-test-state echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/x.txt","subagent_type":"production-framework:builder"}}' | bash hooks/pre-tool-use
```

Expected: `permissionDecision:"deny"` with the tier-selection reason. Inheritance only fires when parent actually passed.

- [ ] **Step 6: Verify non-sub-agent dispatch (regression check)**

```bash
CLAUDE_PROJECT_DIR=/tmp/pf-test-state echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/x.txt"}}' | bash hooks/pre-tool-use
```

Expected: `permissionDecision:"deny"` (no SUBAGENT_TYPE, so gate fires normally).

---

### Task 3: F-V9 sub-fix A2 — System-reminder filter in `user-prompt-submit`

**Files:**
- Modify: `hooks/user-prompt-submit:40-46`

**Symptom:** The hook resets `last_user_prompt_at` on every UserPromptSubmit event including system reminders (TodoWrite reminders, deferred-tools notifications, etc.). Each reset re-arms the tier-selection gate, multiplying ceremony tax.

**Fix shape:** Detect `<system-reminder>` payload prefix and skip the timestamp write. Only human-turn prompts reset the gate. Strength preservation per WS4 FM-15: gate logic at `pre-tool-use` is untouched; the fix is at the timestamp-write layer.

- [ ] **Step 1: Read current code**

```bash
sed -n '40,46p' hooks/user-prompt-submit
```

Expected current content:
```bash
# Update last_user_prompt_at to now (UTC ISO 8601)
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Use a temp file + sed to update the field portably (avoid jq dependency per CLAUDE.md zero-deps posture)
tmp=$(mktemp)
sed -E "s/\"last_user_prompt_at\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"last_user_prompt_at\": \"${NOW}\"/" "${SESSION_FILE}" > "${tmp}"
mv "${tmp}" "${SESSION_FILE}"
```

- [ ] **Step 2: Replace with system-reminder-filtered version**

Replace lines 40-46 with:

```bash
# Update last_user_prompt_at to now (UTC ISO 8601)
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Filter system-reminder events out of last_user_prompt_at updates (F-V9 A2).
# System reminders (TodoWrite reminders, deferred-tools notifications, etc.)
# arrive as UserPromptSubmit events and would otherwise re-arm the tier-selection
# gate. Detect the <system-reminder> prefix in the prompt payload and skip the
# timestamp write. Strength preservation: pre-tool-use gate logic untouched.
IS_SYSTEM_REMINDER=0
if printf '%s' "${INPUT}" | grep -qE '"prompt"[[:space:]]*:[[:space:]]*"<system-reminder>'; then
  IS_SYSTEM_REMINDER=1
fi

if [ "${IS_SYSTEM_REMINDER}" = "0" ]; then
  # Use a temp file + sed to update the field portably (avoid jq dependency per CLAUDE.md zero-deps posture)
  tmp=$(mktemp)
  sed -E "s/\"last_user_prompt_at\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"last_user_prompt_at\": \"${NOW}\"/" "${SESSION_FILE}" > "${tmp}"
  mv "${tmp}" "${SESSION_FILE}"
fi
```

- [ ] **Step 3: Verify bash syntax**

```bash
bash -n hooks/user-prompt-submit
```

Expected: no output, exit 0.

- [ ] **Step 4: Verify human-turn prompt updates timestamp**

```bash
mkdir -p /tmp/pf-test-state
echo '{}' > /tmp/pf-test-state/session.json
CLAUDE_PROJECT_DIR=/tmp/pf-test-state printf '%s' '{"prompt":"Build the comments feature"}' | bash hooks/user-prompt-submit
grep last_user_prompt_at /tmp/pf-test-state/session.json
```

Expected: `last_user_prompt_at` populated with current timestamp.

- [ ] **Step 5: Verify system-reminder skips timestamp update**

```bash
echo '{}' > /tmp/pf-test-state/session.json
CLAUDE_PROJECT_DIR=/tmp/pf-test-state printf '%s' '{"prompt":"<system-reminder>The TodoWrite tool hasnt been used"}' | bash hooks/user-prompt-submit
grep last_user_prompt_at /tmp/pf-test-state/session.json
```

Expected: `last_user_prompt_at` field remains empty (or absent) — timestamp was NOT written.

- [ ] **Step 6: Verify trigger-audit still logs both event types**

The trigger-audit instrumentation (lines 48-61 of `user-prompt-submit`) should log BOTH human-turn prompts AND system reminders to `trigger-audit.jsonl` for cross-correlation. Verify by checking the file after both test invocations:

```bash
cat /tmp/pf-test-state/trigger-audit.jsonl
```

Expected: 2 lines, both with `event: "prompt_received"`, one with the human prompt prefix, one with the system-reminder prefix. The filtering is timestamp-only; audit is universal.

---

### Task 4: ADR R2 — `trigger-audit.jsonl` schema extension for MCP errors

**Files:**
- Modify: `hooks/pre-tool-use` (add MCP error detection block before line 168)

**Goal:** Log MCP tool errors as `event: "mcp_tool_error"` events so the Post-Mortem agent can mine them for repeat-failure patterns. Per ADR-006 Recovery layer R2.

- [ ] **Step 1: Identify insertion point**

The MCP detection should fire for any tool whose name starts with `mcp__`. Insert before the existing Skill/Agent dispatch handlers (around line 152), since MCP tools are caught by the `tool_input` shape, not by the `tool_name` matchers above.

- [ ] **Step 2: Add MCP error logging block**

After line 167 (the closing `fi` of the Agent/Task dispatch block) and before line 169, insert:

```bash

# ---------------------------------------------------------------------------
# MCP tool invocation logging (ADR-006 R2)
# Log every MCP tool call to trigger-audit so Post-Mortem can mine MCP failure
# patterns. The hook itself doesn't see the tool's success/failure (PreToolUse
# fires before execution), but it logs the invocation. Pair with PostToolUse
# (future) for the error capture; for now, the invocation log alone gives us
# frequency + scope data.
# ---------------------------------------------------------------------------
if [[ "${TOOL_NAME}" == mcp__* ]]; then
  log_invocation "mcp_tool_call" "${TOOL_NAME}"
  allow
fi
```

- [ ] **Step 3: Verify bash syntax**

```bash
bash -n hooks/pre-tool-use
```

- [ ] **Step 4: Verify MCP tool call logs to trigger-audit**

```bash
rm -f /tmp/pf-test-state/trigger-audit.jsonl
CLAUDE_PROJECT_DIR=/tmp/pf-test-state echo '{"tool_name":"mcp__plugin_playwright_playwright__browser_navigate","tool_input":{}}' | bash hooks/pre-tool-use
cat /tmp/pf-test-state/trigger-audit.jsonl
```

Expected: one line with `"event":"mcp_tool_call"` and `"name":"mcp__plugin_playwright_playwright__browser_navigate"`.

---

# Phase B — Agent contracts

### Task 5: F-V7 + F-V10 + ADR D1 — Builder dispatch verb + scope + empty-diff gate

**Files:**
- Modify: `agents/builder.md` (multiple sections)
- Modify: `skills/cto-mode/SKILL.md` (Builder-dispatch template — verb language)

**Goals:**
- F-V7: replace ambiguous "execute the plan" language in dispatch with unambiguous "EXECUTE; do not re-plan or re-design."
- F-V10 + D1: add dispatch-time `scope: code | verdict | analysis | docs` declaration; gate fires only when scope=code AND empty diff is detected post-execution.

- [ ] **Step 1: Amend `agents/builder.md` "Your Job" section (after line 16)**

After line 23 (the existing 6-step list) and before line 25 (the "Before You Begin — Ask" header), insert:

```markdown

## Dispatch contract — verb language and scope

The CTO dispatches you with two contractual elements:

1. **Verb:** the dispatch prompt opens with **EXECUTE** (not "execute the plan" — too ambiguous, can be read as "execute = re-plan-then-execute"). The verb language is exact: "EXECUTE the plan at <path>. Do not re-plan or re-design. The plan IS the spec."

2. **Scope declaration:** the dispatch prompt declares `scope: code | verdict | analysis | docs`.
   - `code` — write source code; the empty-diff gate (below) fires.
   - `verdict` — produce a judgment (e.g. QA verdict); no code expected.
   - `analysis` — produce a doc / report; no source-code change expected.
   - `docs` — produce documentation; no source-code change expected.

If the dispatch lacks either element, return `NEEDS_CONTEXT` immediately. Don't infer.

## Empty-diff gate (F-V10 + ADR-006 D1)

If your declared scope is `code` AND your `git diff $BASE_SHA..HEAD --name-only` post-execution shows zero files in the declared file scope, you MUST downgrade your status to `DONE_WITH_CONCERNS` and report:

```
STATUS: DONE_WITH_CONCERNS
EMPTY_DIFF_FLAG: true
EXPLANATION: declared scope was code; no files were changed in <declared scope>.
Possible causes: (a) the dispatch was redundant (work already done by prior dispatch);
(b) the plan step was misinterpreted as not requiring code change; (c) silent failure.
QA must investigate before merging.
```

The empty-diff check is a self-attested honesty mechanism, not a substitute for QA verification. Per WS4 FM-13: do not over-engineer this — the QA agent independently verifies the diff in Stage 1 (see `agents/qa.md` D5). If you forget to run this check, QA catches it. The Builder-side check exists to surface the issue earlier, not to replace QA.
```

- [ ] **Step 2: Amend `agents/builder.md` Output Format section (lines 168-194)**

Replace the existing Output Format block with this expanded version. Read the current content at line 168 first:

```bash
sed -n '168,194p' agents/builder.md
```

Then update lines 170-194 (the code block content between the triple-backticks):

```
STATUS: <DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED>
SCOPE: <code | verdict | analysis | docs>  (must match dispatch scope)
EMPTY_DIFF_FLAG: <true | false>  (only relevant when SCOPE=code; auto-set if git diff shows 0 files)

## What I Implemented
- <one-line summary>

## Files Changed
- path/to/file1 (created | modified | deleted)
- ...

## Tests Added
- path/to/test1 (covers: <what>)
- ...

## Verification Done
- <commands run + results, fresh evidence per the verification gate>

## Self-Review Findings
- <any issues you found and fixed during self-review>

## Concerns (if any)
- <flag any DONE_WITH_CONCERNS reasons, including EMPTY_DIFF_FLAG=true rationale>
```

- [ ] **Step 3: Update `skills/cto-mode/SKILL.md` Builder-dispatch template**

Read the current cto-mode skill:

```bash
grep -n "Builder" skills/cto-mode/SKILL.md
```

Find the section that prescribes how the CTO dispatches the Builder (likely "Step 4 — Mediate handovers" or "Builder dispatch"). Add or amend the dispatch template to include:

```markdown
**Builder dispatch template (must use exact verb + scope):**

```
EXECUTE the plan at docs/plans/<feature>.md. Do not re-plan or re-design.
The plan IS the spec.

scope: code
file scope: <exact files / globs the Builder owns this dispatch>
BASE_SHA: <current HEAD>
plan reference: <task numbers from the plan>

Hand off when DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED.
```

The verb "EXECUTE" (uppercase) is contractual. Lowercase "execute" or any other verb makes the dispatch ambiguous and risks the F-V7 silent-no-op pattern. The `scope:` declaration is contractual; without it the Builder returns NEEDS_CONTEXT.
```

- [ ] **Step 4: Verify all three files compile (markdown lint)**

```bash
# Markdown files are not compiled, but check for syntax errors in any embedded code blocks
grep -A 1 '^```' agents/builder.md | head -20
grep -A 1 '^```' skills/cto-mode/SKILL.md | head -20
```

Confirm all triple-backtick blocks are properly closed (count of opening ``` equals count of closing ```).

- [ ] **Step 5: Verify reading flow makes sense**

Read `agents/builder.md` lines 1-75 and confirm the new "Dispatch contract" section reads naturally between the "Your Job" 6-step list and the "Before You Begin — Ask" subsection.

---

### Task 6: ADR D3 — Researcher post-Write file-existence check

**Files:**
- Modify: `agents/researcher.md` (add to "Hard rules" section, after line 65)

**Goal:** When the Researcher's deliverable is a file at `docs/research/<topic>.md`, after the final Write the Researcher must verify the file exists at the declared path. Catches silent path-typo failures.

- [ ] **Step 1: Read existing Hard rules section**

```bash
sed -n '55,70p' agents/researcher.md
```

- [ ] **Step 2: Add post-Write existence check rule**

After the existing "No opinion-first" rule (line 64), add:

```markdown
- **Post-Write file-existence check.** After your final Write to `docs/research/<topic>.md`, verify the file exists at the declared path before reporting DONE. Run:
  ```
  ls -la docs/research/<topic>.md
  ```
  If the path doesn't exist or the size is 0, return `NEEDS_CONTEXT` and report which Write call(s) silently failed. This catches path-typo / Edit-on-non-existent-file class failures. (ADR-006 D3.)
```

- [ ] **Step 3: Verify markdown structure**

Read the section to confirm the new rule reads naturally:

```bash
sed -n '55,75p' agents/researcher.md
```

---

### Task 7: ADR D4 — Debugger profiler-mode instrumentation gate

**Files:**
- Modify: `agents/debugger.md` (add to "Hard rules" section, before existing rules at line 130)

**Goal:** When the Debugger is dispatched in profiler mode (Performance cycle Phase 1), it must declare instrumentation BEFORE proposing any optimization, parallel to the no-fix rule for Debug cycle.

- [ ] **Step 1: Read Hard rules section**

```bash
sed -n '128,142p' agents/debugger.md
```

- [ ] **Step 2: Add profiler-mode rule**

After line 134 (existing "No fixes" rule) and before line 135 (existing "Investigate the root cause" rule), insert:

```markdown
- **Profiler-mode instrumentation gate.** When dispatched in profiler mode (Performance cycle Phase 1), you MUST declare instrumentation before proposing any optimization. Same shape as the Debug-cycle no-fix rule: identify the bottleneck via baseline measurement + boundary timing first; propose the optimization in the hand-off document; the Builder writes the optimization in a separate cycle. Profiler-mode optimizations proposed without baseline timing data are returned as `NEEDS_CONTEXT`. (ADR-006 D4.)
```

---

### Task 8: ADR D5 — QA empty-diff REJECT semantics

**Files:**
- Modify: `agents/qa.md` (add to Stage 1 spec compliance section)

**Goal:** When QA reviews a Builder dispatch with `SCOPE=code` and the diff shows no files changed in the declared file scope, Stage 1 verdict is REJECT. Pairs with Task 5's Builder-side empty-diff flag.

- [ ] **Step 1: Read Stage 1 description**

```bash
sed -n '36,45p' agents/qa.md
```

- [ ] **Step 2: Add empty-diff check to Stage 1**

After line 41 (existing "Misunderstandings" bullet) and before line 42 (the blank line preceding Stage 2), insert:

```markdown
- **Empty diff under SCOPE=code.** If the Builder's dispatch declared `SCOPE: code` and `git diff $BASE_SHA..$HEAD_SHA -- <declared file scope>` shows zero files changed, that is a Stage 1 REJECT regardless of the Builder's status token. The dispatch was either redundant (already done) or silently failed (F-V10 class). Verdict: REJECT. Cause to investigate: was the dispatch redundant (no-op intended), or was there a silent failure? Quote the Builder's `EMPTY_DIFF_FLAG` value and reason in your findings. (ADR-006 D5.)
```

---

# Phase C — Skill body changes

### Task 9: F-V18 — `dispatching-parallel-agents` foreground / background subsection

**Files:**
- Modify: `skills/dispatching-parallel-agents/SKILL.md` (insert after line 75, the "## 4. Review and Integrate" section)

**Goal:** Add explicit guidance on when to run parallel dispatches in foreground vs background, so future agents don't re-derive the answer from scratch.

- [ ] **Step 1: Read current section structure**

```bash
sed -n '60,90p' skills/dispatching-parallel-agents/SKILL.md
```

- [ ] **Step 2: Insert subsection after the "Dispatch in Parallel" code block (after line 75)**

After line 74 (the comment `// All three run concurrently`) and before line 76 (the `### 4. Review and Integrate` header), insert:

```markdown

### 3.5. Foreground vs background

Both modes run agents concurrently if dispatched in one message. The distinction is what your session does while they run:

- **Foreground** — your session blocks waiting for their results. Returns inline; immediately visible in your tool output. Default for parallel dispatches.
- **Background** — your session keeps working. Results arrive as separate notifications you have to pick up and merge into context. Use only when your session has real, productive, independent work to fill the wait.

**Decision table:**

| Situation | Use |
|---|---|
| Next step blocks on all parallel outputs AND no other independent work | foreground |
| Next step blocks on all outputs BUT there is independent work (other reads, doc writes, plan drafting) | background |

**Why background is not the default:**

- Same wall-clock time when next step blocks on all outputs anyway.
- Foreground returns inline; background returns as separate notifications that have to be picked up.
- Multiple background agents = multiple silent failure modes harder to notice.
- Cognitive overhead scales with concurrency — every pending background agent is open mental state.

Source: Claude Code Agent tool guidance — "Use background when you have genuinely independent work to do in parallel."
```

---

### Task 10: F-V8 + ADR R1 + R3 — Per-tool Common Recovery prose in 4 skills

**Files:**
- Modify: `skills/browser-driven-verification/SKILL.md` (add Common Recovery section)
- Modify: `skills/rls-aware-migrations/SKILL.md` (add Common Recovery section)
- Modify: `skills/finishing-a-development-branch/SKILL.md` (add Common Recovery section)
- Modify: `skills/enterprise-research-first/SKILL.md` (add Common Recovery section)

**Goal:** Each skill's body documents the failure modes its underlying tools / MCP servers can hit and the recovery path. Format prescribed in WS3 R1: `Symptom | Error class | Recovery path | Escalation if recovery fails`.

- [ ] **Step 1: Add Common Recovery section to `browser-driven-verification`**

Read the existing skill structure:

```bash
grep -n "^##" skills/browser-driven-verification/SKILL.md
```

Insert a new section after the "## Anti-Patterns" section and before the "## Red Flags" section. The location: between lines 117 (last Anti-Pattern) and 119 (Red Flags header).

Content:

```markdown

## Common Recovery

When the Playwright MCP server or browser harness fails mid-cycle, here are the failure modes and recovery paths.

| Symptom | Error class | Recovery path | Escalation if recovery fails |
|---|---|---|---|
| `Browser is already in use for ms-playwright/mcp-chrome-…/, use --isolated to run multiple instances.` | Lock-fail (orphaned Chrome process tree holds user-data-dir lock) | (1) Restart the Playwright MCP server first (R3 — first-line for transient state). (2) If lock persists: PowerShell — find Chrome processes matching the MCP user-data-dir + kill the tree; remove the lockfile. (3) Re-invoke `browser_navigate`. | Add `--isolated` flag to MCP invocation. If still fails, file under FD-02 MCP plugin compatibility. |
| `browser_evaluate` returns `Execution context was destroyed` | Page navigation interrupted the evaluate scope | Re-navigate, then re-run evaluate. Common when navigation triggers in the same tick as evaluate. | If reproducible after one retry, the test is racing real navigation; switch to `waitForFunction` first. |
| `browser_console_messages` returns empty array unexpectedly | Console buffer cleared by navigation | Capture immediately after action; do not navigate before capture. | If buffer still empty, the page may have its own console silencer; check for `console.log = () => {}` in init. |
| MCP tool times out (>30s) without response | Server hung; transport class | Restart the Playwright MCP server (R3 first-line). | If hangs repeat, file under FD-02 with frequency data; consider degradation path to manual smoke per F-V11 follow-on. |

If the recovery path doesn't fit one of these rows, document the new failure mode + recovery in `docs/PROJECT-PLAN.md` Open Findings as a new finding before proceeding.
```

- [ ] **Step 2: Add Common Recovery section to `rls-aware-migrations`**

Read existing structure:

```bash
grep -n "^##" skills/rls-aware-migrations/SKILL.md
```

Insert "Common Recovery" before the closing Citations / Companion section. Content:

```markdown

## Common Recovery

When the migration tool (Supabase CLI, plain SQL, or migration runner) fails, recovery paths:

| Symptom | Error class | Recovery path | Escalation if recovery fails |
|---|---|---|---|
| `relation "<table>" does not exist` during a backfill phase | Schema-state mismatch — backfill assumes a table that the expand phase didn't create yet | Verify expand phase ran successfully; check `list_tables` against expected schema; re-run expand if missing. | If expand ran and table is still absent, the migration ordering is broken; revert and re-author with explicit phase deps. |
| `permission denied for table` | RLS policy active but role doesn't satisfy it; or migration role lacks privileges | Confirm the migration runs as superuser / service-role for DDL; user-role for DML. Check policy `USING` clause. | If permission persists with correct role, the policy is over-restrictive; revise per the architect's plan. |
| `cannot drop column referenced by view / FK / index` | Contract phase missing dependency cleanup | Drop dependents first (views, indexes, FKs) in their own phase before the column. | If dependency graph is unclear, revert and add a `pg_depend` audit step to the plan. |
| `deadlock detected` during migration | Concurrent reads/writes hold conflicting locks | Re-run during a maintenance window, OR switch to `CREATE INDEX CONCURRENTLY` / `ALTER TABLE ... NOT VALID` patterns. | If still failing, the migration cannot be done online; declare it offline and add downtime plan. |

Document any new failure mode in `docs/PROJECT-PLAN.md` Open Findings.
```

- [ ] **Step 3: Add Common Recovery section to `finishing-a-development-branch`**

```bash
grep -n "^##" skills/finishing-a-development-branch/SKILL.md
```

Insert before Citations. Content:

```markdown

## Common Recovery

When git operations fail at branch-finishing time:

| Symptom | Error class | Recovery path | Escalation if recovery fails |
|---|---|---|---|
| `non-fast-forward, did not receive expected object` on push | Local branch diverged from remote | (1) `git fetch origin`. (2) Rebase or merge. (3) Re-push. NEVER force-push without explicit user authorization. | If divergence is large or unclear, return BLOCKED and surface to user; do not force-resolve. |
| `pre-commit hook failed` | Hook is doing real verification; commit is genuinely broken | Read the hook output; fix the underlying issue; create a NEW commit (not amend). | If hook is broken (not the commit), file as separate finding; do not skip with `--no-verify`. |
| `merge conflict` | Concurrent edits | Resolve conflicts by reading both sides; ask user if intent is unclear. | If conflicts span >5 files, return BLOCKED — likely indicates a missing rebase / coordination step earlier. |
| `gh pr create` fails with 404 | Remote not configured, or branch not pushed | Verify remote (`git remote -v`); push branch first. | If remote auth is broken, escalate to user — credential issue, not code issue. |

Document any new failure mode in `docs/PROJECT-PLAN.md` Open Findings.
```

- [ ] **Step 4: Add Common Recovery section to `enterprise-research-first`**

```bash
grep -n "^##" skills/enterprise-research-first/SKILL.md
```

Insert before Citations. Content:

```markdown

## Common Recovery

When research tooling fails (WebFetch denied, search results sparse):

| Symptom | Error class | Recovery path | Escalation if recovery fails |
|---|---|---|---|
| `WebFetch` returns permission-denied for a URL | Domain not in allowlist OR site blocks scrapers | Fall back to WebSearch with the canonical URL as one of the search terms. Tag the citation `(via WebSearch synthesis of canonical URL)` per researcher discipline. | If the URL is critical and WebSearch can't surface it, return NEEDS_CONTEXT — don't fabricate. |
| Search returns <3 candidate frameworks for the question | Question too narrow OR domain is genuinely niche | Broaden query terms; widen the comparison axis. Try `gh search code` for OSS-implementation-anchored searches. | If <3 found after 15-call budget, return NEEDS_CONTEXT with the search transcript. |
| Same source cited from multiple URLs (mirrors / aggregators) | Surface diversity is illusory | Treat as one source; find genuinely-different second + third. | If genuine diversity isn't available, the question may be a single-source space; honestly report N=1. |
| Citation date older than 90 days | Source may have evolved | Re-fetch the URL; verify the quote still appears. Update verification timestamp. | If quote no longer appears, find the new equivalent; update the row; note the change in the methodology section. |

Document any new failure mode in `docs/PROJECT-PLAN.md` Open Findings.
```

---

# Phase D — New docs

### Task 11: F-V17 — Brownfield onboarding doc

**Files:**
- Create: `docs/onboarding-brownfield.md`

**Goal:** Document the path for adopting PF v2 in projects that already have patterns docs, ADR conventions, ARCHITECTURE.md folders, or non-`docs/` directory structures.

- [ ] **Step 1: Create the file with this content**

```markdown
# Onboarding PF v2 to a Brownfield Project

PF v2 was designed greenfield-first. The README assumes you start fresh: `docs/PROJECT-PLAN.md`, `docs/specs/`, `docs/architecture/`, etc. This doc covers what to do when your project already has its own patterns docs, ADR conventions, or non-`docs/` directory structures.

The CONFIG path indirection (added v2.1.0, F-V5 fix) is the load-bearing primitive. Skills and agents read paths from `CONFIG.yaml > file_paths.*` instead of the convention paths.

## Available CONFIG slots

```yaml
file_paths:
  project_plan: docs/PROJECT-PLAN.md     # default
  patterns: docs/STACK-PATTERNS.md       # default
  citation_manifest: docs/research/sp-anthropic-citation-manifest.md  # default
  adr_dir: docs/adr/                     # default
  research_dir: docs/research/           # default
  plans_dir: docs/plans/                 # default
  audits_dir: docs/audits/               # default
```

Override any slot by setting the CONFIG value to your project's path. Examples:

- Project has plan at `docs/TASKIT-PLAN.md` → set `file_paths.project_plan: docs/TASKIT-PLAN.md`.
- Project has ADRs at `architecture/decisions/` → set `file_paths.adr_dir: architecture/decisions/`.
- Project has patterns doc at `engineering-patterns.md` (root) → set `file_paths.patterns: engineering-patterns.md`.

## Step-by-step retrofit

1. **Inventory existing artifacts.** What does your project already have? Common candidates:
   - Project plan / roadmap doc
   - ADR or RFC folder
   - Patterns / conventions doc
   - Architecture document
   - Audit / review folder
   - Specs / design docs

2. **Map each to a CONFIG slot.** Use the table above. If your project has an artifact PF v2 doesn't have a slot for, that's a finding — file in `docs/PROJECT-PLAN.md` Open Findings.

3. **Set CONFIG.yaml at project root.** PF v2 reads CONFIG before falling back to convention paths.

4. **Smoke test the framework.** Invoke `cto-mode` on a small task. Verify the framework reads from your CONFIG-declared paths, not the convention paths. Common failure: a skill that hardcodes the convention path is a finding (file it).

5. **Don't migrate existing content into convention paths.** PF v2 reads CONFIG; you don't need to move your existing plan into `docs/PROJECT-PLAN.md`. The indirection IS the retrofit primitive.

## What if my project has no CONFIG.yaml?

Default behavior. PF v2 falls back to convention paths. Greenfield projects get the simplest experience.

## What if my project has its own SessionStart hooks / pre-commit hooks?

PF v2's hooks live in `.claude-plugin/hooks/`. They coexist with project-level `.git/hooks/` and other plugin hooks via Claude Code's hook composition rules. If conflicts arise (e.g. two hooks want to deny the same tool call), file as a finding in `docs/PROJECT-PLAN.md`.

## What if my project's existing patterns conflict with PF v2's?

PF v2 ships its own patterns in `templates/STACK-PATTERNS.template.md` (template; not the runtime patterns doc). Your project's patterns doc (whatever its path) is authoritative. If your patterns conflict with PF v2's enforcement (e.g. PF v2 wants RLS on all tables but your project doesn't use Supabase), the patterns doc wins — PF v2 enforcement is opt-in via CONFIG project_specific_triggers.

## When NOT to retrofit

- Project is entirely separate from PF v2's intended use case (multi-tenant SaaS) — e.g. data pipelines, libraries, CLI tools. PF v2 may be over-prescriptive; a lighter framework or no framework may fit better.
- Your team's discipline is already strong and the framework's friction outweighs its catches. Retrofit is opt-in; no obligation.
```

- [ ] **Step 2: Verify the file exists**

```bash
ls -la docs/onboarding-brownfield.md
```

Expected: file present, ~3KB.

- [ ] **Step 3: Verify markdown structure renders**

```bash
head -20 docs/onboarding-brownfield.md
```

Confirm the heading and intro paragraph render correctly.

---

# Phase E — Measurement

### Task 12: ADR M1 + M2 — Measurement script

**Files:**
- Create: `scripts/measurement.sh`

**Goal:** Project-agnostic script that derives session-level metrics from `.framework-state/trigger-audit.jsonl` and emits them to stdout. Per ADR-006 M1 (session-derived) + M2 (project-agnostic).

- [ ] **Step 1: Create the script**

```bash
#!/usr/bin/env bash
# =============================================================================
# scripts/measurement.sh — Session-derived metrics emitter (ADR-006 M1 + M2)
#
# PURPOSE:
#   Derives metrics from .framework-state/trigger-audit.jsonl. Project-agnostic
#   (works on any project with the framework installed). Outputs JSON to stdout
#   for piping to whatever observability surface the project uses.
#
# METRICS EMITTED:
#   - prompt_count        — total UserPromptSubmit events (excluding system reminders)
#   - skill_invocations   — Skill tool invocations by skill name
#   - agent_dispatches    — Agent / Task dispatches by sub-agent type
#   - mcp_calls           — MCP tool calls (post v2.2.0 R2 instrumentation)
#   - subagent_inherits   — Sub-agent dispatches that inherited tier-selection
#   - bypass_events       — Bypass log entries (PF_BYPASS / PF_BYPASS_ALL / kill switch)
#
# USAGE:
#   bash scripts/measurement.sh                # current project
#   PROJECT_DIR=/path/to/project bash scripts/measurement.sh
# =============================================================================

set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
AUDIT_LOG="${PROJECT_DIR}/.framework-state/trigger-audit.jsonl"
BYPASS_LOG="${PROJECT_DIR}/.framework-state/bypass-log.jsonl"

if [ ! -f "${AUDIT_LOG}" ]; then
  echo '{"error":"trigger-audit.jsonl not found","project_dir":"'"${PROJECT_DIR}"'"}'
  exit 0
fi

# Counts (using grep -c for portability, no jq)
PROMPT_COUNT=$(grep -c '"event":"prompt_received"' "${AUDIT_LOG}" 2>/dev/null || echo 0)
SKILL_COUNT=$(grep -c '"event":"skill"' "${AUDIT_LOG}" 2>/dev/null || echo 0)
AGENT_COUNT=$(grep -c '"event":"agent"' "${AUDIT_LOG}" 2>/dev/null || echo 0)
MCP_COUNT=$(grep -c '"event":"mcp_tool_call"' "${AUDIT_LOG}" 2>/dev/null || echo 0)
INHERIT_COUNT=$(grep -c '"event":"subagent_inherit"' "${AUDIT_LOG}" 2>/dev/null || echo 0)

BYPASS_COUNT=0
if [ -f "${BYPASS_LOG}" ]; then
  BYPASS_COUNT=$(wc -l < "${BYPASS_LOG}" 2>/dev/null | tr -d ' ' || echo 0)
fi

# Top-3 skills by frequency
TOP_SKILLS=$(grep '"event":"skill"' "${AUDIT_LOG}" 2>/dev/null \
  | grep -oE '"name":"[^"]*"' \
  | sort | uniq -c | sort -rn | head -3 \
  | awk '{name=$2; for(i=3;i<=NF;i++) name=name" "$i; gsub(/"/, "\\\"", name); printf "{\"skill\":%s,\"count\":%s},", name, $1}' \
  | sed 's/,$//')

# Top-3 sub-agents by frequency
TOP_AGENTS=$(grep '"event":"agent"' "${AUDIT_LOG}" 2>/dev/null \
  | grep -oE '"name":"[^"]*"' \
  | sort | uniq -c | sort -rn | head -3 \
  | awk '{name=$2; for(i=3;i<=NF;i++) name=name" "$i; gsub(/"/, "\\\"", name); printf "{\"agent\":%s,\"count\":%s},", name, $1}' \
  | sed 's/,$//')

# Output JSON
cat <<EOF
{
  "project_dir": "${PROJECT_DIR}",
  "measured_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "prompt_count": ${PROMPT_COUNT},
  "skill_invocations": ${SKILL_COUNT},
  "agent_dispatches": ${AGENT_COUNT},
  "mcp_calls": ${MCP_COUNT},
  "subagent_inherits": ${INHERIT_COUNT},
  "bypass_events": ${BYPASS_COUNT},
  "top_skills": [${TOP_SKILLS}],
  "top_agents": [${TOP_AGENTS}]
}
EOF
```

- [ ] **Step 2: Make executable**

```bash
chmod +x scripts/measurement.sh
```

- [ ] **Step 3: Verify bash syntax**

```bash
bash -n scripts/measurement.sh
```

- [ ] **Step 4: Test against the dev directory's actual trigger-audit**

```bash
bash scripts/measurement.sh
```

Expected: JSON output with non-zero `prompt_count` and `skill_invocations` (since this dev session has been logging). Output is parseable JSON.

- [ ] **Step 5: Test missing-file path**

```bash
PROJECT_DIR=/tmp/nonexistent-pf-project bash scripts/measurement.sh
```

Expected: `{"error":"trigger-audit.jsonl not found",...}` — clean error, no crash.

---

# Phase F — Citation manifest + regression tests

### Task 13: Citation manifest rows

**Files:**
- Modify: `docs/research/sp-anthropic-citation-manifest.md`

**Goal:** Per CLAUDE.md THE BINDING RULE — every new behavior maps to a row in the manifest. Add rows for D1-D5, A2, R1-R3, M1-M2.

- [ ] **Step 1: Read existing manifest structure**

```bash
head -50 docs/research/sp-anthropic-citation-manifest.md
```

Identify the table structure (likely columns: feature, citation type, source, snippet, verified-date).

- [ ] **Step 2: Add 11 new rows**

Append at end of the appropriate section. Each row cites either an SP precedent or an Anthropic guidance + verifies the date is 2026-05-09 or earlier.

For each row, content:

| Feature ID | Citation type | Source | Snippet/URL | Verified |
|---|---|---|---|---|
| D1 — Builder verb-conditional empty-diff gate | SP precedent + Anthropic | SP `subagent-driven-development/SKILL.md:102-118` (status grammar); Anthropic *Building Effective AI Agents* (evaluator-optimizer) | `STATUS: DONE_WITH_CONCERNS` extension semantics; "evaluator-optimizer pattern" | 2026-05-09 |
| D2 — Real-user smoke for race classes | SP precedent | SP `verification-before-completion/SKILL.md:19-22` (Iron Law specialization for UI) | `NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE` | 2026-05-09 (deferred to v2.2.1+) |
| D3 — Researcher post-Write file existence | SP precedent | SP `verification-before-completion/SKILL.md:102-105` (agent-delegation: VCS-diff verification) | "Agent reports success → Check VCS diff → Verify changes" | 2026-05-09 |
| D4 — Debugger profiler-mode instrumentation gate | SP precedent | SP `systematic-debugging/SKILL.md:18-22` (Iron Law: NO FIXES WITHOUT ROOT CAUSE) | extended to performance: NO OPTIMIZATIONS WITHOUT BASELINE | 2026-05-09 |
| D5 — QA empty-diff REJECT | SP precedent | SP `spec-reviewer-prompt.md:21-29` (do-not-trust + verify by reading code) | "Verify by reading code, not by trusting report" | 2026-05-09 |
| A2 — System-reminder filter on user-prompt-submit | Anthropic guidance | Anthropic Claude Code system reminder convention (`<system-reminder>` payload prefix) | system-reminder events are runtime-injected, not human-turn input | 2026-05-09 |
| R1 — Per-tool Common Recovery prose | Anthropic + enterprise | Anthropic *Effective Context Engineering* (file artifacts as evidence substrate); Kubernetes runbook conventions; AWS WAF playbooks | "Each subagent operates with an isolated context window" | 2026-05-09 |
| R2 — trigger-audit MCP error logging | Anthropic + SP | Anthropic Claude Code MCP server docs; SP `bypass-log.jsonl` append-only convention | append-only audit log discipline | 2026-05-09 |
| R3 — Playwright MCP server-restart first-line | Enterprise convergence | Playwright Issues #891 + #1305 + #24144 (3/3 issue convergence on restart-as-recovery) | issue thread URLs | 2026-05-09 |
| M1 — Session-derived metrics | Anthropic + SP | Anthropic *Effective Context Engineering* (artifact discipline); existing `trigger-audit.jsonl` substrate (v2.0.3) | append-only state files as observability substrate | 2026-05-09 |
| M2 — Project-agnostic measurement | Enterprise (Google SRE) | Google SRE Book Ch. 6 (Monitoring) — black-box / white-box dual telemetry | metrics emitted to stdout; piping to project's observability layer | 2026-05-09 |

Format these as table rows matching the existing manifest's table format (read it to confirm column order).

- [ ] **Step 3: Verify table renders**

```bash
grep -c "^|" docs/research/sp-anthropic-citation-manifest.md
```

Confirm row count increased by 11.

---

### Task 14: Regression tests in `evals/regression/`

**Files:**
- Create: `evals/regression/README.md`
- Create: `evals/regression/f-v13-windows-path-separator.json`
- Create: `evals/regression/f-v20-subagent-tier-selection-inheritance.json`
- Create: `evals/regression/f-v9-system-reminder-filter.json`
- Create: `evals/regression/f-v7-builder-dispatch-verb.json`
- Create: `evals/regression/f-v10-builder-empty-diff-gate.json`
- Create: `evals/regression/f-v8-recovery-prose-present.json`
- Create: `evals/regression/f-v17-brownfield-doc-present.json`
- Create: `evals/regression/f-v18-foreground-background-subsection.json`

**Goal:** Per release-discipline Gate 3 — every closed finding ships with a regression test that fails if the bug returns. JSON manifest format: `{name, finding_id, symptom, repro_command, expected_output, fix_commit, last_verified}`.

- [ ] **Step 1: Create the README**

```markdown
# evals/regression — Closed-finding regression tests

Per `docs/release-discipline.md` Gate 3: every closed finding ships with a test in this directory that fails if the bug returns.

## Format

Each test is a JSON manifest:

```json
{
  "name": "human-readable name",
  "finding_id": "F-VN",
  "symptom": "what the bug looks like to the user",
  "repro_command": "exact command (bash) that reproduces the bug",
  "expected_output_match": "regex or substring the output must contain when fixed",
  "expected_output_no_match": "regex or substring the output must NOT contain when fixed",
  "fix_commit": "<sha>",
  "last_verified": "YYYY-MM-DD"
}
```

## Running

A future runner script (`scripts/run-regression.sh`) walks every JSON in this directory, executes `repro_command`, checks the output against the assertions, and exits non-zero if any test fails. The runner is part of v2.3.0+ scope; for now this directory is the manifest substrate.

## Adding a new test

When closing any finding in `docs/PROJECT-PLAN.md`:

1. Reproduce the bug at the original commit (the one that ships the bug).
2. Write the manifest with the exact reproducer.
3. Re-run after the fix; confirm the manifest's assertions hold.
4. Commit the manifest with the fix.

If you can't reproduce the bug deterministically, file as a non-regression-tested finding and explain why in the closing PR.
```

- [ ] **Step 2: Create `f-v13-windows-path-separator.json`**

```json
{
  "name": "Windows path normalization in pre-tool-use docs/ auto-allow",
  "finding_id": "F-V13",
  "symptom": "On Windows, every Edit to a docs/ path was denied by the tier-selection gate because the case-statement pattern */docs/* used forward slashes but Windows file_path values arrived with backslashes.",
  "repro_command": "echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"c:\\\\Users\\\\test\\\\production-framework-v2\\\\docs\\\\PROJECT-PLAN.md\"}}' | bash hooks/pre-tool-use",
  "expected_output_match": "\"permissionDecision\":\"allow\"",
  "expected_output_no_match": "\"permissionDecision\":\"deny\"",
  "fix_commit": "<set after Phase G commit>",
  "last_verified": "2026-05-09"
}
```

- [ ] **Step 3: Create `f-v20-subagent-tier-selection-inheritance.json`**

```json
{
  "name": "Sub-agent tier-selection inheritance via SUBAGENT_TYPE",
  "finding_id": "F-V20",
  "symptom": "Every sub-agent's first Edit/Write/Bash was denied by the tier-selection gate even when the parent session had already invoked tier-selection. Builder/Researcher/Architect dispatches required redundant per-context tier-selection invocations.",
  "repro_command": "mkdir -p /tmp/pf-r-test && cat > /tmp/pf-r-test/session.json <<EOF\n{\"session_started_at\":\"2026-05-09T10:00:00Z\",\"tier_selection_invoked_at\":\"2026-05-09T10:01:00Z\",\"triage_invoked_at\":\"\",\"last_user_prompt_at\":\"2026-05-09T10:00:30Z\"}\nEOF\nmv /tmp/pf-r-test/session.json /tmp/pf-r-test/.framework-state/session.json 2>/dev/null || (mkdir -p /tmp/pf-r-test/.framework-state && mv /tmp/pf-r-test/session.json /tmp/pf-r-test/.framework-state/session.json)\nCLAUDE_PROJECT_DIR=/tmp/pf-r-test echo '{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"/tmp/x.txt\",\"subagent_type\":\"production-framework:builder\"}}' | bash hooks/pre-tool-use",
  "expected_output_match": "\"permissionDecision\":\"allow\"",
  "expected_output_no_match": "\"permissionDecision\":\"deny\"",
  "fix_commit": "<set after Phase G commit>",
  "last_verified": "2026-05-09"
}
```

- [ ] **Step 4: Create `f-v9-system-reminder-filter.json`**

```json
{
  "name": "System-reminder events do not reset last_user_prompt_at",
  "finding_id": "F-V9 sub-fix A2",
  "symptom": "UserPromptSubmit events caused by system reminders (TodoWrite reminders, deferred-tools notifications) reset last_user_prompt_at, re-arming the tier-selection gate and multiplying ceremony tax.",
  "repro_command": "mkdir -p /tmp/pf-sr-test/.framework-state && echo '{}' > /tmp/pf-sr-test/.framework-state/session.json && CLAUDE_PROJECT_DIR=/tmp/pf-sr-test printf '%s' '{\"prompt\":\"<system-reminder>The TodoWrite tool hasnt been used\"}' | bash hooks/user-prompt-submit && grep last_user_prompt_at /tmp/pf-sr-test/.framework-state/session.json",
  "expected_output_match": "(last_user_prompt_at\":\\s*\"\")|(no match)",
  "expected_output_no_match": "last_user_prompt_at\":\\s*\"2026",
  "fix_commit": "<set after Phase G commit>",
  "last_verified": "2026-05-09"
}
```

- [ ] **Step 5: Create `f-v7-builder-dispatch-verb.json`**

```json
{
  "name": "Builder dispatch template uses unambiguous EXECUTE verb",
  "finding_id": "F-V7",
  "symptom": "Builder dispatched with ambiguous 'Execute the implementation plan at...' produced 0 file changes; verb was read as 'execute = re-plan-then-execute'.",
  "repro_command": "grep -E 'EXECUTE.*plan|plan IS the spec' skills/cto-mode/SKILL.md && grep -E 'verb language is exact' agents/builder.md",
  "expected_output_match": "EXECUTE the plan",
  "expected_output_no_match": "(no match — both files must contain the canonical phrase)",
  "fix_commit": "<set after Phase G commit>",
  "last_verified": "2026-05-09"
}
```

- [ ] **Step 6: Create `f-v10-builder-empty-diff-gate.json`**

```json
{
  "name": "Builder declares scope and reports EMPTY_DIFF_FLAG",
  "finding_id": "F-V10",
  "symptom": "Builder reported DONE with empty diff; QA had no signal to catch silent failure.",
  "repro_command": "grep -c 'EMPTY_DIFF_FLAG' agents/builder.md && grep -c 'SCOPE: <code' agents/builder.md && grep -c 'EMPTY_DIFF_FLAG' agents/qa.md",
  "expected_output_match": "[1-9][0-9]*",
  "expected_output_no_match": "^0$",
  "fix_commit": "<set after Phase G commit>",
  "last_verified": "2026-05-09"
}
```

- [ ] **Step 7: Create `f-v8-recovery-prose-present.json`**

```json
{
  "name": "Common Recovery section present in 4 named skills",
  "finding_id": "F-V8 + R1 + R3",
  "symptom": "Skills had no documented recovery path for transient tool failures; recovery was rediscovered each time.",
  "repro_command": "for skill in browser-driven-verification rls-aware-migrations finishing-a-development-branch enterprise-research-first; do grep -c '^## Common Recovery' skills/$skill/SKILL.md; done",
  "expected_output_match": "1\\n1\\n1\\n1",
  "expected_output_no_match": "^0$",
  "fix_commit": "<set after Phase G commit>",
  "last_verified": "2026-05-09"
}
```

- [ ] **Step 8: Create `f-v17-brownfield-doc-present.json`**

```json
{
  "name": "Brownfield onboarding doc exists",
  "finding_id": "F-V17",
  "symptom": "No documented path for adopting PF v2 in projects with existing patterns docs / ADR conventions.",
  "repro_command": "test -f docs/onboarding-brownfield.md && wc -l docs/onboarding-brownfield.md",
  "expected_output_match": "[5-9][0-9]|[1-9][0-9][0-9]",
  "expected_output_no_match": "(missing)",
  "fix_commit": "<set after Phase G commit>",
  "last_verified": "2026-05-09"
}
```

- [ ] **Step 9: Create `f-v18-foreground-background-subsection.json`**

```json
{
  "name": "dispatching-parallel-agents skill has Foreground vs background section",
  "finding_id": "F-V18",
  "symptom": "Skill body had no guidance on when to run parallel dispatches in foreground vs background; future agents re-derived the answer each time.",
  "repro_command": "grep -c 'Foreground vs background' skills/dispatching-parallel-agents/SKILL.md",
  "expected_output_match": "[1-9]",
  "expected_output_no_match": "^0$",
  "fix_commit": "<set after Phase G commit>",
  "last_verified": "2026-05-09"
}
```

- [ ] **Step 10: Verify all files created**

```bash
ls evals/regression/
```

Expected: 9 files (1 README + 8 manifests).

---

# Phase G — Release packaging

### Task 15: Version bump + RELEASE-NOTES

**Files:**
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `RELEASE-NOTES.md`

- [ ] **Step 1: Bump plugin.json version**

```bash
sed -i 's/"version": "2\.1\.0"/"version": "2.2.0"/' .claude-plugin/plugin.json
grep version .claude-plugin/plugin.json
```

Expected: `"version": "2.2.0"`.

- [ ] **Step 2: Bump marketplace.json version**

```bash
sed -i 's/"version": "2\.1\.0"/"version": "2.2.0"/' .claude-plugin/marketplace.json
grep version .claude-plugin/marketplace.json
```

- [ ] **Step 3: Append v2.2.0 entry to RELEASE-NOTES.md**

Read the existing RELEASE-NOTES.md style:

```bash
head -50 RELEASE-NOTES.md
```

Append a new top entry:

```markdown
## v2.2.0 — 2026-05-09

Consolidated upgrade closing every empirical finding from real-world use plus the implementable layers of the v2.2 design (ADR-006). Replaces the prior v2.1.1 production fix / v2.2.0 split per user direction.

**Hook fixes:**
- Windows path normalization in `pre-tool-use` docs/ auto-allow (F-V13)
- Sub-agent tier-selection inheritance via `SUBAGENT_TYPE` (F-V20)
- System-reminder events no longer reset `last_user_prompt_at` (F-V9 sub-fix A2)
- MCP tool calls logged to `trigger-audit.jsonl` as `event: mcp_tool_call` (ADR R2)

**Agent contract:**
- Builder dispatch contract requires explicit `EXECUTE` verb + `scope: code | verdict | analysis | docs` declaration (F-V7 + F-V10)
- Builder reports `EMPTY_DIFF_FLAG` when scope=code but no files changed (D1)
- Researcher must verify final-Write file existence before reporting DONE (D3)
- Debugger profiler-mode requires baseline instrumentation before optimization (D4)
- QA empty-diff under scope=code is a Stage 1 REJECT (D5)

**Skill body:**
- `dispatching-parallel-agents`: foreground vs background subsection (F-V18)
- `browser-driven-verification`: Common Recovery section (F-V8 + R1 + R3)
- `rls-aware-migrations`: Common Recovery section (R1)
- `finishing-a-development-branch`: Common Recovery section (R1)
- `enterprise-research-first`: Common Recovery section (R1)

**New artifacts:**
- `docs/onboarding-brownfield.md` — onboarding guide for projects with existing patterns docs / ADR conventions (F-V17)
- `scripts/measurement.sh` — session-derived metrics emitter (M1 + M2)
- `evals/regression/` — regression test manifests for closed findings (release-discipline Gate 3)

**Discipline:**
- New `docs/release-discipline.md` contract — four pre-release gates: dogfood, cross-platform, regression-per-finding, citation-manifest current
- Citation manifest updated with rows for D1-D5, A2, R1-R3, M1-M2

**Empirical findings closed (9):**
F-V7, F-V8, F-V9 (A2 sub-fix only), F-V10, F-V13, F-V17, F-V18, F-V20, F-V22.

**Empirical findings deferred with rationale:**
F-V9 A1 (cycle-state.md cooperation; FM-12 risk unresolved); F-V11 (verification skill rewrite; needs decision on what replaces lines 110-112); F-V12 (fast-path threshold; needs WS4 default-deny spec); D2 (depends on F-V11); F-V14, F-V15, F-V16 (need cross-project signal / research cycles); F-V19, F-V21 (depend on F-V20 reproduction or are CC-side); FD-03 (parked).

**Bootstrap deviation declared:** Builder broken; this release implemented via main-session edits, not Builder dispatch. Future releases run via dogfooded Builder dispatch once Builder is reliable.
```

- [ ] **Step 4: Verify version + release notes consistency**

```bash
grep -c "2.2.0" .claude-plugin/plugin.json .claude-plugin/marketplace.json RELEASE-NOTES.md
```

Expected: ≥3 (version present in all three).

---

### Task 16: PROJECT-PLAN.md status update

**Files:**
- Modify: `docs/PROJECT-PLAN.md`

- [ ] **Step 1: Mark closed findings RESOLVED**

For each of F-V7, F-V8, F-V9 (A2 sub-fix only — F-V9 itself stays OPEN until A1 ships), F-V10, F-V13, F-V17, F-V18, F-V20, F-V22, change the row's first column from `OPEN (severity)` to `RESOLVED (was severity)` and append `Resolved 2026-05-09 in v2.2.0.` to the description.

For F-V9, add a note to the existing description: "A2 sub-fix shipped in v2.2.0 (system-reminder filter). A1 (cycle-state.md cooperation) deferred — FM-12 risk unresolved."

- [ ] **Step 2: Update Phase Status table**

Add a Phase 9 row:

```
| Phase 9 — v2.2.0 consolidated upgrade | COMPLETE | gate-3 | Plan: `docs/plans/v2-2-0-upgrade.md`. ADR: `docs/adr/006-...md`. Closes: F-V7, F-V8, F-V9 A2, F-V10, F-V13, F-V17, F-V18, F-V20, F-V22. Plus ADR-006 layers: D1, D3, D4, D5, A2, R1, R2, R3, M1, M2. Bootstrap deviation declared (Builder broken, main-session implementation). Cross-platform smoke single-platform with Linux/macOS asterisk. |
```

---

# Phase H — QA + Gate 3

### Task 17: Dispatch QA + code-reviewer (parallel, foreground)

- [ ] **Step 1: Compute BASE_SHA + HEAD_SHA**

```bash
BASE_SHA=$(git rev-parse 43a5286)  # last commit before this cycle's work
HEAD_SHA=$(git rev-parse HEAD)
echo "BASE_SHA=${BASE_SHA}"
echo "HEAD_SHA=${HEAD_SHA}"
```

- [ ] **Step 2: Dispatch QA + code-reviewer in parallel (foreground)**

Per F-V18 guidance: foreground because next step (gate-3) blocks on both outputs.

QA prompt (paste full content; reference plan + spec + SHAs):

```
EXECUTE Stage 1 + Stage 2 review of docs/plans/v2-2-0-upgrade.md.

scope: verdict
BASE_SHA: <from step 1>
HEAD_SHA: <from step 1>
plan: docs/plans/v2-2-0-upgrade.md
spec: docs/adr/006-v2-2-detection-adaptation-recovery-layer.md (the architecture)
audit doc: docs/audits/qa-findings-v2-2-0.md (write here)

Per agents/qa.md: Stage 1 first; if pass, Stage 2. Multi-tenant section (write
"single-tenant — no tenant scope required" since this is the framework itself,
not a multi-tenant application). Run no test suite (the framework's tests are
the regression manifests in evals/regression/; verify they parse as JSON and
the repro_commands are syntactically valid bash). Verdict in findings doc.

Bootstrap deviation reminder: this release was implemented via main-session
edits, not Builder dispatch. The diff is from CTO-as-Builder. Apply the same
Stage 1 missing/extra/misunderstood discipline regardless.
```

Code-reviewer prompt:

```
EXECUTE code review of v2.2.0 release diff.

scope: verdict
BASE_SHA: <same>
HEAD_SHA: <same>
audit doc: docs/audits/code-review-v2-2-0.md (write here)

Focus areas: hook script correctness (bash portability across Mac/Linux/Windows-Git-Bash), agent prompt clarity, skill body internal consistency (specifically check F-V22 — does the F-V11 fix get correctly NOT applied since it's deferred?), regression test manifest JSON validity.
```

- [ ] **Step 3: Read both verdicts**

After both return, read:

```bash
cat docs/audits/qa-findings-v2-2-0.md
cat docs/audits/code-review-v2-2-0.md
```

If either verdict is REJECT or APPROVE_WITH_FIXES with HIGH/CRITICAL: address the findings (fix the underlying issue, recommit), then re-dispatch QA. Fresh subagent per re-review.

If both APPROVE: proceed to gate-3.

---

### Task 18: gate-3-production-check

- [ ] **Step 1: Invoke the skill**

```
Skill: production-framework:gate-3-production-check
Args: v2.2.0 release. 18-dimension production-readiness walk.
```

- [ ] **Step 2: Address each dimension**

Most of gate-3's 18 dimensions are SaaS-application-shaped (RLS, tenant isolation, audit log, error budget). For framework releases, the relevant dimensions reduce to:

- D1 — tests pass — confirm `evals/regression/` JSON files parse + `bash -n` passes on hooks/scripts
- D2 — review approved — both QA and code-reviewer APPROVE
- D5 — observability — `scripts/measurement.sh` operational
- D14 — release notes — RELEASE-NOTES.md v2.2.0 entry present
- D17 — feature flag / rollback — rollback is `git revert` to v2.1.0; documented in handover
- D18 — PROJECT-PLAN updated — Phase 9 row added; closed findings marked RESOLVED

Other dimensions (D3 multi-tenant, D6 audit trail, D7 PII, D8 security review, D9 perf budget, D10 migration phase, D11 SLO, D12 SLI, D13 12-factor, D15 dashboards, D16 alert rules) — write `n/a — framework-internal release; no application surface` for each.

- [ ] **Step 3: Document results**

Write `docs/audits/gate-3-v2-2-0.md` with the 18-dimension walk + verdict.

---

### Task 19: Cross-platform smoke (Gate 2 — single-platform asterisk)

**Per release-discipline Gate 2: Linux + macOS + Windows-via-Git-Bash. Reality: this release is being implemented from a Windows machine.**

- [ ] **Step 1: Run the Windows-via-Git-Bash subset locally**

For each of the 6 Gate 2 checklist items (per `docs/release-discipline.md`), execute the verification command and record pass/fail.

- [ ] **Step 2: Document the asterisk**

In `docs/audits/gate-3-v2-2-0.md`, add a section:

```markdown
## Gate 2 — Cross-platform smoke (single-platform asterisk)

This release was smoke-tested on Windows-via-Git-Bash only. The release-discipline
contract requires Linux + macOS + Windows. The asterisk is declared because:
- Maintainer environment is Windows-only at the time of this release.
- Linux + macOS smoke is a pending action item; will run on second-project onboard.
- The risk surface for non-Windows: F-V13 path-normalization regression. Regression
  test (`evals/regression/f-v13-windows-path-separator.json`) covers the Windows case;
  the POSIX case is verified by step 5 of Task 1 in the plan.

Action item for v2.2.1+: maintainer or second-project onboard runs the full Gate 2
checklist on macOS and Linux. Findings filed in PROJECT-PLAN.md if any.
```

---

### Task 20: Commit + push v2.2.0

- [ ] **Step 1: Commit in logical chunks**

This release's diff is large. Commit in chunks per concern:

```bash
git add hooks/pre-tool-use hooks/user-prompt-submit
git commit -m "$(cat <<'EOF'
v2.2.0 hooks: path norm, sub-agent inheritance, system-reminder filter, MCP logging

Closes F-V13 (Windows path normalization in pre-tool-use docs/ auto-allow),
F-V20 (sub-agent tier-selection inheritance via SUBAGENT_TYPE), F-V9 sub-fix A2
(system-reminder events no longer reset last_user_prompt_at), and ADR-006 R2
(MCP tool calls logged to trigger-audit.jsonl).

Strength preservation per WS4: gate logic at the parent layer is untouched;
only redundant per-sub-agent re-fire and system-reminder timestamp resets are
suppressed. The blocking semantic of HARD-GATEs is preserved.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"

git add agents/builder.md agents/researcher.md agents/debugger.md agents/qa.md skills/cto-mode/SKILL.md
git commit -m "$(cat <<'EOF'
v2.2.0 agent contracts: dispatch verb, scope declaration, empty-diff gates

Closes F-V7 (Builder dispatch verb ambiguity), F-V10 (Builder silent-DONE
empty-diff), and ADR-006 D1, D3, D4, D5.

- Builder: explicit EXECUTE verb + scope: code|verdict|analysis|docs declaration
  + EMPTY_DIFF_FLAG when scope=code with no diff
- Researcher: post-Write file-existence check before DONE
- Debugger: profiler-mode instrumentation gate before optimization
- QA: Stage 1 REJECT on empty diff under scope=code

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"

git add skills/dispatching-parallel-agents/ skills/browser-driven-verification/ skills/rls-aware-migrations/ skills/finishing-a-development-branch/ skills/enterprise-research-first/
git commit -m "$(cat <<'EOF'
v2.2.0 skill bodies: foreground/background + per-tool Common Recovery

Closes F-V18 (parallel-dispatch foreground/background guidance) and F-V8 +
ADR-006 R1 + R3 (per-tool Common Recovery prose in 4 skills with the
Symptom | Error class | Recovery | Escalation table format).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"

git add docs/onboarding-brownfield.md scripts/measurement.sh evals/regression/
git commit -m "$(cat <<'EOF'
v2.2.0 new artifacts: brownfield doc, measurement script, regression manifests

Closes F-V17 (brownfield onboarding) and ADR-006 M1 + M2 (session-derived
metrics + project-agnostic measurement script). Adds 8 regression test
manifests in evals/regression/ per release-discipline Gate 3.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"

git add docs/research/sp-anthropic-citation-manifest.md docs/PROJECT-PLAN.md docs/cycle-state.md docs/plans/v2-2-0-upgrade.md docs/adr/006-v2-2-detection-adaptation-recovery-layer.md docs/audits/qa-findings-v2-2-0.md docs/audits/code-review-v2-2-0.md docs/audits/gate-3-v2-2-0.md docs/handovers/v2-2-0.md
git commit -m "$(cat <<'EOF'
v2.2.0 plan + audits + handover

Citation manifest rows for D1-D5, A2, R1-R3, M1-M2. PROJECT-PLAN findings
F-V7, F-V8, F-V10, F-V13, F-V17, F-V18, F-V20, F-V22 marked RESOLVED;
F-V9 A2 sub-fix shipped (A1 stays OPEN). Phase 9 row added. QA + code-review
+ gate-3 audits. Handover doc.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"

git add .claude-plugin/plugin.json .claude-plugin/marketplace.json RELEASE-NOTES.md
git commit -m "$(cat <<'EOF'
v2.2.0 release: version bump + release notes

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 2: Tag and push**

```bash
git tag -a v2.2.0 -m "v2.2.0 — consolidated upgrade closing 9 empirical findings + ADR-006 layers"
git push origin main
git push origin v2.2.0
```

---

### Task 21: Handover writeup

**Files:**
- Create: `docs/handovers/v2-2-0.md`

- [ ] **Step 1: Write the handover**

```markdown
# v2.2.0 Release Handover

**Released:** 2026-05-09 · **Type:** upgrade (per release-discipline) · **Tagged:** v2.2.0

## What shipped

[Per the RELEASE-NOTES.md entry — closing 9 empirical findings + ADR-006 layers D1, D3, D4, D5, A2, R1, R2, R3, M1, M2; release-discipline contract; brownfield onboarding doc; measurement script; regression test manifests.]

## What's pending for v2.2.1+

- Builder reproduction (F-V19) once a fresh sub-agent dispatch succeeds with the F-V20 inheritance fix
- Cross-platform smoke (Linux + macOS) per release-discipline Gate 2 asterisk
- F-V9 A1 (cycle-state.md cooperation) — needs WS4 FM-12 mitigation design
- F-V11 (verification skill rewrite) — needs decision on what replaces lines 110-112
- F-V12 (fast-path threshold) — needs WS4 default-deny spec
- F-V14 (sample size) — onboard projects #2 and #3
- F-V15 (team mode), F-V16 (CI enforcement) — research cycles
- FD-03 (theater suppression) — design parked
- ADR D2, M3-M5 — depend on the above

## Bootstrap deviation note

This release was implemented via CTO main-session edits, not Builder dispatch. The Builder agent's `isolation: worktree` interacts badly with the framework's own dev environment (F-V21). Once the Builder fixes (F-V10, F-V20) are stable in a new project (Taskforge or other), the next release should run dogfood-via-Builder.

## Rollback plan

`git revert v2.2.0..v2.1.0` reverts the 6 commits in this release. The findings closed in v2.2.0 will revert to OPEN, but no production data is affected (framework is dev-tooling, not application).
```

- [ ] **Step 2: Mark cycle as complete**

Update `docs/cycle-state.md`:

```markdown
- 2026-05-09 — handover written; cycle COMPLETE. v2.2.0 tagged + pushed.
```

---

# Self-Review

After writing this plan, the planner ran self-review against `docs/cycle-state.md`'s "Closing this cycle" list:

- F-V7 → Task 5 ✅
- F-V8 → Task 10 ✅
- F-V9 A2 → Task 3 ✅
- F-V10 → Task 5 ✅
- F-V13 → Task 1 ✅
- F-V17 → Task 11 ✅
- F-V18 → Task 9 ✅
- F-V20 → Task 2 ✅
- F-V22 → handled implicitly (F-V11 deferred → no contradiction shipped) — verified in Task 17 code-reviewer scope
- ADR D1 → Task 5 ✅
- ADR D3 → Task 6 ✅
- ADR D4 → Task 7 ✅
- ADR D5 → Task 8 ✅
- ADR A2 → Task 3 ✅
- ADR R1 → Task 10 ✅
- ADR R2 → Task 4 ✅
- ADR R3 → Task 10 ✅
- ADR M1 → Task 12 ✅
- ADR M2 → Task 12 ✅
- Citation manifest → Task 13 ✅
- Regression tests → Task 14 ✅
- Version bump → Task 15 ✅
- RELEASE-NOTES → Task 15 ✅
- PROJECT-PLAN status → Task 16 ✅
- QA + code-review → Task 17 ✅
- Gate-3 → Task 18 ✅
- Cross-platform smoke → Task 19 ✅
- Commit + push + tag → Task 20 ✅
- Handover → Task 21 ✅

Placeholder scan: zero `TODO`, zero `TBD`, zero "fill in details" markers.

Type consistency: `SCOPE` field (Task 5 Builder) referenced in Task 8 (QA empty-diff REJECT logic) — same spelling, same enum values.

---

## Execution

Inline execution via main session, per Bootstrap Deviation. The Builder is in scope of these very fixes; cannot dispatch via Builder until v2.2.0 lands.
