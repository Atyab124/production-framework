# Code Review — v2.2.0 consolidated upgrade

**Reviewer:** CTO main session (inline per bootstrap deviation)
**Date:** 2026-05-09
**Diff range:** 43a5286..HEAD

## Hook script correctness (cross-platform bash)

### `hooks/pre-tool-use`

- **Path normalization (F-V13)** — `${FILE_PATH//\\//}` is portable bash 3+ parameter expansion. Works on macOS (default bash 3.2), Linux (bash 4+), and Git Bash on Windows. **PASS.**
- **Sub-agent inheritance (F-V20)** — uses `[[ ... > ... ]]` lexical comparison on ISO 8601 timestamps. Lexical order matches chronological order for ISO 8601 — correct. SUBAGENT_TYPE parsed via the same regex pattern as other JSON fields. **PASS.**
- **MCP tool logging (R2)** — `[[ "${TOOL_NAME}" == mcp__* ]]` requires bash 3.2+ (works on all targets). The block runs BEFORE the Skill/Agent dispatch handlers, but doesn't conflict because MCP tool names start with `mcp__` not "Skill" or "Agent". **PASS.**
- **Order of new blocks** — sub-agent inheritance check runs after `TIER_SELECTION_TS` and `LAST_USER_PROMPT_TS` are read (lines 174-177). Correct ordering; the check needs both timestamps loaded. **PASS.**

### `hooks/user-prompt-submit`

- **System-reminder regex** — `'"prompt"[[:space:]]*:[[:space:]]*"<system-reminder>'` matches the start of the prompt value. **Concern (LOW):** if a legitimate human-turn prompt happens to start with the literal string `<system-reminder>`, it would be filtered out. Highly unlikely (CC-internal convention), but technically possible. **Acceptable risk.**
- **Conditional sed** — the existing sed runs only when `IS_SYSTEM_REMINDER=0`; trigger-audit logging at lines 48+ runs unconditionally (correct — audit is universal). **PASS.**

### `scripts/measurement.sh`

- **No `set -e`** — comment explains why (grep -c exits 1 on no-match, which is normal). **Acceptable.**
- **Defensive defaults** — `${VAR:-0}` after each grep keeps the script robust when grep returns 1 with mid-pipeline failure. **PASS.**
- **JSON output validity** — manually inspected; valid JSON. **PASS.**
- **Top-K skills/agents extraction** — uses awk to JSON-encode names with embedded quotes via `gsub(/"/, "\\\"", name)`. Correct escape. **PASS.**

## Agent prompt clarity

### `agents/builder.md`

- **Dispatch contract section** — clear before/after for the F-V7 verb language; explicit scope enum; NEEDS_CONTEXT routing when contract elements are missing. **PASS.**
- **Empty-diff gate section** — self-attested honesty mechanism is well-framed (not over-engineered per WS4 FM-13). The cross-reference to QA D5 is correct. **PASS.**
- **Output Format updates** — SCOPE and EMPTY_DIFF_FLAG fields added in the right place (top of the block, before "What I Implemented"). **PASS.**

### `agents/researcher.md` / `agents/debugger.md` / `agents/qa.md`

Each rule addition is one bullet, in the Hard Rules section, with the ADR citation. **PASS.**

### `skills/cto-mode/SKILL.md`

- **Builder dispatch template** — uppercase EXECUTE explicit; scope enum listed; explanatory paragraph below. **PASS.**

## Skill body internal consistency (F-V22 verification)

**Critical check:** F-V11's fix is DEFERRED in this release. The verification skill at `skills/browser-driven-verification/SKILL.md` lines 110-112 still says "Timing-dependent bugs are reproducible — via synthetic event dispatch."

Per F-V22, the F-V11 fix would have added a contradicting "Real-input regression" section. Since F-V11 is deferred, no contradiction was introduced.

What WAS added: a `## Common Recovery` section. Verified that none of the Common Recovery rows contradict lines 110-112. **PASS.**

The skill's internal consistency holds for v2.2.0. F-V22 is correctly closed (the override-not-add concern is logged as a binding constraint on F-V11's eventual fix, not a fix shipped now).

## Regression test manifest validity

Each of the 8 manifests parses as valid JSON. Verified by reading each file; no syntax errors observed. **PASS.**

The `expected_output_match` field uses inconsistent regex/substring forms across manifests (flagged in QA M-1). For v2.2.0 this is acceptable — the manifests are documentation until the runner ships.

## Citation manifest discipline

Part 5 added with 16 rows. Each row has all required columns (Feature ID, Behavior, Citation type, Source, Verified). Verification dates are 2026-05-09. Source citations include SP precedents, Anthropic guidance, and enterprise/OSS analogs per the binding rule.

**Concern (LOW):** I did not re-fetch the cited URLs to verify the quoted text. Relied on prior research session content. Per `enterprise-research-first` Common Recovery (newly added in this release): citation date older than 90 days requires re-fetch. The 5 v2.2.0 research docs were dated 2026-04-30, all within 90 days. **Acceptable.**

## Cross-platform considerations

This release was developed on Windows-via-Git-Bash. Per release-discipline Gate 2:
- Bash scripts use POSIX-portable constructs (`${var//\\//}`, `[[ == ]]`, `printf`, `grep -E`, `sed -E`). **PASS for portability theory.**
- Actual macOS / Linux smoke not run in this session (per declared single-platform asterisk). **DEFERRED to v2.2.1+.**

## Verdict

**APPROVE.**

No CRITICAL or HIGH findings. The Stage 2 LOWs (regex inconsistency, set -e removal, ADR line-number error, single-platform smoke) are tracked in QA findings + handover and do not block release.

Sign-off rationale: every change traces to a plan task, every task to an open finding or ADR-006 layer, every prescription to an SP precedent or Anthropic citation or N≥3 enterprise analog. The framework's binding rule holds for the framework's own release.
