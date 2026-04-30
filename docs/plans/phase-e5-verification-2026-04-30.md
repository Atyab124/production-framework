# Phase E5 — Verification Plan

**Date:** 2026-04-30
**Status:** READY TO EXECUTE (manual user step)
**Scope:** Verify v2.0.0 plugin loads correctly in Claude Code; smoke-test a fresh non-trivial cycle; run the description-trigger-overlap audit per Option 1.

## Acceptance criteria

v2.0.0 ships when ALL of the following pass:

### 1. Plugin loads in Claude Code

- `/plugin install` completes without error.
- SessionStart hook fires on session open + on `/clear` + on `/compact` (matcher: `startup|clear|compact` per `hooks/hooks.json`).
- Bootstrap content (`skills/using-production-framework/SKILL.md`) is injected as system reminder.
- `.framework-state/session.json` is initialized at SessionStart (per `scripts/framework-state-init.sh`).
- Cursor / Codex / Copilot CLI loads work — inherits SP support.

### 2. PreToolUse hook fires correctly (D-A bundle)

For each of the 5 gates, run a positive AND negative test:

| Gate | Negative test (should DENY) | Positive test (should ALLOW) |
|---|---|---|
| `tier-selection` | Open fresh session; user prompt: "Build feature X"; agent attempts `Edit src/foo.ts` without invoking `production-framework:tier-selection` first | Same prompt; agent invokes `production-framework:tier-selection` first; then `Edit` |
| Destructive-ops | `Bash` command `rm -rf /tmp/foo` | `Bash` command `rm /tmp/foo` (single file, no `-rf`) |
| Phase-break | `Write src/feature/new.ts` when no current-phase marker in PROJECT-PLAN | Same `Write` after PROJECT-PLAN has `## Phase Status` row with `IN_PROGRESS` |
| Critical-finding | `Write src/foo.ts` when PROJECT-PLAN Open Findings has `Severity: CRITICAL` row | Same `Write` after CRITICAL findings closed |
| Dep-add | `Bash npm install lodash` without "Tool Selection Chain:" prefix in prior turn | Same after agent documents Tool Selection Chain |

For each: verify hook returns `permissionDecision: "deny"` JSON (NOT exit-code-2 — see ADR-002 § known CC bugs).

### 3. Bypass grammar works

Three-tier bypass (per ADR-002):

- `PF_BYPASS=tier-selection` — should allow ONE Edit/Write/Bash without tier-selection invocation; subsequent calls re-gated.
- `PF_BYPASS_ALL=1 PF_BYPASS_REASON="quick-fix"` — should allow session-wide; missing `PF_BYPASS_REASON` should DENY with explicit error.
- `touch .framework-state/PF_GATES_DISABLED` — project-level kill switch; all gates pass.
- All bypasses should append a row to `.framework-state/bypass-log.jsonl`.

### 4. Smoke-test a fresh cycle

Open a fresh session in a test project (or a worktree of an existing project). Issue a user prompt that triggers Tier 2 / Tier 3 work:

> "Add a comments feature with realtime updates and audit trail."

Verify the cycle dispatch:

- `using-production-framework` bootstrap fires (per CTO-mode entry session).
- `cycle-selection` skill invoked → Build cycle, Tier 3.
- `tier-selection` skill invoked (D-A gate satisfied).
- Architect agent dispatched → produces `docs/architecture/<feature>.md` with all 12 required sections (per `agents/architect.md` post-2026-04-30 amendment with entity-existence verification + client-shape column).
- `enterprise-research-first` skill invoked for non-obvious choices.
- `seven-validation-questions` skill runs against the plan.
- Builder dispatched.
- QA dispatched (two-stage review per `agents/qa.md`).
- `gate-3-production-check` invoked at cycle end (19 dimensions).
- `writing-handover` produces a rolling-single-doc per phase.

### 5. Description-trigger-overlap audit (per Option 1)

Run the audit on all 36 skills' frontmatter `description` fields:

1. Inventory: `find skills/ -name 'SKILL.md' | xargs grep -l '^description:'`
2. For each pair of skills (A, B): could a single user message plausibly trigger both? If yes:
   - Are A's and B's "When to Use" sections clearly distinct?
   - Does each skill's body explicitly cite the other in Composability section so the right one fires?
   - If still ambiguous: rewrite one of the descriptions to be more specific.
3. Test cases (smoke-test ambiguous prompts):
   - "I have a bug" → should fire `triage` only (NOT `systematic-debugging`, NOT `incident-response`)
   - "Production is down" → should fire `incident-response` only
   - "Before I write the plan" → should fire `enterprise-research-first` AND `find-similar-implementations` (both legitimate; verify both run, not one suppressing the other)
   - "After the build" → should fire `verification-before-completion` first, then optionally `gate-3-production-check`
   - "How should I structure this" → should fire `brainstorming` only

Output: `docs/audits/description-trigger-overlap-audit-<UTC>.md` with per-pair rating (CLEAR / AMBIGUOUS / OVERLAPPING) + remediation actions.

### 6. Skill body lint check

Per SP `post-write-md-lint.sh` hook (inherited): every skill body has the 4 required sections (`## Overview`, `## When to Use`, `## Core Pattern`, `## Quick Reference`).

```bash
bash scripts/structural-check.sh
```

Should report all 36 skills passing.

### 7. Eval gate (D-B)

If the user wants to ship the verification-before-completion override clause:

```bash
bash evals/verification-root-cause/run.sh
```

Run + verify PASS criteria (Corpus A 10/10 catch-mask + Corpus B 5/5 regression-guard + Corpus C ≥ SP on all). If PASS: ship the override clause. If FAIL: defer D-B; document failure mode in `evals/verification-root-cause/results-<date>.md`.

## Known limitations to document

- **D19 console-errors-clean** has no deterministic grep — Playwright execution is the sole enforcement mechanism. Document in skill body + RELEASE-NOTES.
- **D-A `permissionDecision` JSON** requires Claude Code 2.1.x or later (older versions may fall back to permissive). Document `min-cc-version` requirement.
- **SP override eval (D-B)** is conditional — if it fails, the override clause is deferred to v2.1 with stronger eval design.

## On verification failure

If any acceptance criterion fails:

1. Identify the failed criterion + the responsible artifact.
2. File as Open Finding in PROJECT-PLAN.md with severity (CRITICAL / HIGH / MEDIUM).
3. Dispatch the owning agent (per Pass 2 plan workstream → owner mapping):
   - Workstream B/D/H/I skills failing → re-write skill from research artifact
   - Workstream C hook failing → debug pre-tool-use.sh; may need permissionDecision JSON shape adjustment
   - Workstream F STACK-PATTERNS failing structural check → fix template
4. Re-run from the failed criterion forward.

## Citations

- ADR-002 — D-A hook bundle scope + bypass grammar
- ADR-003 — Broadened pattern ingest (un-deferred to v2.0.x)
- ADR-001 G3 amendment — UN-DEFER rationale
- `docs/plans/pass-2-implementation-2026-04-30.md` — 9-workstream plan
- `docs/audits/v1-feedback-vs-v2-2026-04-30.md` — 36-item audit; Phase E5 closes 35/36 (Item 33 truncated, awaits user)
- `RELEASE-NOTES.md` v2.0.0 section
