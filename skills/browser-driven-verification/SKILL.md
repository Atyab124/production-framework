---
name: browser-driven-verification
description: "Use when verifying any UI/UX deliverable, when reproducing timing-dependent bugs (race conditions, hydration mismatches, optimistic-rollback) that static reasoning can't reproduce, or when checking that pre-existing console errors aren't accumulating across cycles. Specializes verification-before-completion for browser-driven evidence. Pairs with gate-3 D19 (console-errors-clean)."
---

## Overview

Static reasoning + code review cannot reproduce timing-dependent bugs, can't detect pre-existing console errors that silently accumulate, and can't produce browser-state evidence for UI deliverables. PF v1 production data documented 3 sessions (Hier-2 panel-open false alarm; mention-picker race synthetic-event reproduction; notification-store popover verification) where Playwright was the load-bearing tool — none of those bugs were discoverable without driving the browser.

This skill prescribes Playwright (or equivalent browser-driven harness — Cypress, Selenium) as the verification primitive for the cases listed in **When to Use**. It is a specialization of `verification-before-completion`'s Iron Law, not a replacement.

**Enterprise grounding:** 5/5 BINDING on wait-for-condition discipline; 6/6 directional consensus on user-visible-behavior + semantic locators + isolation across Playwright Best Practices, Cypress Best Practices, Testing Library guiding principles, Selenium WebDriver patterns, BrowserStack + Microsoft Azure browser-testing guides.

## The Iron Law (inherited)

```
NO UI/UX COMPLETION CLAIM WITHOUT FRESH BROWSER-DRIVEN EVIDENCE.
```

Inherits SP `verification-before-completion` Iron Law (line 19): "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE." Specialized: for UI deliverables, "fresh evidence" means a browser-driven snapshot / console capture / semantic-query result captured in this session. A manual screenshot is not evidence. A "tested locally" claim is not evidence. The browser-driven harness's output is.

<HARD-GATE>
For any task whose deliverable is user-facing OR whose suspected bug is timing-dependent, you MUST capture browser-driven evidence in this session before claiming DONE. Acceptable evidence:

- **ARIA snapshot** (`browser_snapshot` from Playwright MCP — Anthropic-MCP-native; structured tree of accessible elements)
- **Console-message capture** (`browser_console_messages`) — REQUIRED on every route touched, even when the bug isn't console-related
- **Network-request capture** (`browser_network_requests`) when the bug involves a request lifecycle
- **`browser_evaluate` script result** when the bug requires synthetic event dispatch (e.g., race condition reproducible only via direct event injection)

A pixel screenshot is not evidence — it doesn't survive React rerender and can't be diffed semantically. ARIA-snapshot or structured event-log only.
</HARD-GATE>

## When to Use

- **Mandatory** for any deliverable touching `src/app/**/*.tsx`, `src/components/**/*.tsx`, or equivalent UI surfaces.
- **Mandatory** when the bug class is BC-1 (closure-staleness), BC-3 (race condition), BC-4 (hydration mismatch), BC-5 (optimistic-rollback) — per `docs/research/bug-class-taxonomy-2026-04-30.md`. Static reasoning cannot reproduce these.
- **Mandatory** as part of `gate-3-production-check` D19 (console-errors-clean on routes touched).
- **Recommended** as `systematic-debugging` Step 4 alternative when confidence < 90% on a code-reading-only investigation AND the bug surface is browser-rendered.
- **Skip** for backend-only or CLI-only deliverables — the harness adds no signal.

## Core Pattern

You MUST create a TodoWrite item per step.

### Step 1 — Identify the routes / surfaces under test

List every route the change touches (e.g., `/tasks`, `/notifications`, `/settings/profile`). For each, identify the user-flow trigger (which click / form submission / route transition reproduces the surface).

### Step 2 — Wait for condition, never `setTimeout`

5/5 BINDING: bind `wait_for(<text|role|alias>)` over arbitrary `setTimeout` / `cy.wait(N)` / `page.waitForTimeout`. Per Playwright official Best Practices and SP `condition-based-waiting.md`:

> "Wait for the actual condition you care about, not a guess about how long it takes."

Arbitrary delays create flakiness — fast machines pass, CI fails. Use:
- `await page.waitForRole('button', { name: /submit/i })` — semantic
- `await page.waitForText('Saved')` — user-visible
- `await page.waitForFunction(() => window.appState === 'idle')` — only when no semantic alias works

### Step 3 — Capture ARIA snapshot as evidence (Anthropic-MCP-native)

Per Anthropic Playwright MCP server: structured snapshot of accessible elements is the durable evidence form. Pixel screenshots don't survive rerender and can't be diffed.

```
const snapshot = await page.snapshot();  // returns ARIA tree
// Compare against expected shape; commit to docs/audits/ as JSON
```

### Step 4 — Capture console messages on every route touched

REQUIRED — closes Audit Item 12. Pre-existing console errors (#418/#419/etc.) silently accumulate; per-cycle audit catches only the cycle's own changes:

```
const consoleMessages = await page.consoleMessages();
const errors = consoleMessages.filter(m => m.type === 'error');
```

If `errors.length > 0`: file as separate finding. Do NOT absorb silently. Do NOT pass D19.

### Step 5 — Synthetic event dispatch when timing-dependent

For BC-1 / BC-3 (closure-staleness, race condition): the bug requires events fired faster than React commit. Use `page.evaluate` to dispatch:

```
await page.evaluate(() => {
  const input = document.querySelector('[role="combobox"]');
  ['i', 'a'].forEach(char => {
    input.dispatchEvent(new InputEvent('input', { data: char, bubbles: true }));
    // No await — back-to-back synchronous dispatch
  });
});
```

This is the only deterministic way to reproduce the mention-picker race + similar timing bugs.

### Step 6 — Failing-test-first cross-reference

Per SP `systematic-debugging` Phase 4 Step 1: "Reproduction is mandatory — write the failing test BEFORE the fix." If you're using this skill in debug context, the harness invocation IS the failing test. Save it in `tests/e2e/<feature>.spec.ts` (or stack-equivalent) and run it on every CI cycle.

## Anti-Patterns

### "I tested it locally"

Local testing produces no durable evidence. Browser-driven evidence (ARIA snapshot, console capture, network log) is recordable, diff-able, and survives `/compact`. The harness output IS the test result.

### "The screenshot looks right"

Pixel screenshots are not evidence. They don't survive React rerender; can't be diffed semantically; don't capture timing. ARIA snapshots + structured event logs only.

### "The bug isn't reproducing — must be intermittent"

Timing-dependent bugs are reproducible — via synthetic event dispatch faster than React commit. If `page.click()` → `page.waitForText()` doesn't reproduce, drop to `page.evaluate(() => dispatchEvent(...))` for synchronous back-to-back dispatch. Per Microsoft Time-Travel Debugging principle: record-then-investigate, not reproduce-then-investigate-live.

### "Console errors were already there before this ship"

Pre-existing errors are still errors. File them as separate findings. Do NOT absorb. Per Audit Item 12: hydration errors #418/#419 visible across many ship cycles in PF v1 — never caught because each cycle audited only its own changes.

## Common Recovery

When the Playwright MCP server or browser harness fails mid-cycle, here are the failure modes and recovery paths.

| Symptom | Error class | Recovery path | Escalation if recovery fails |
|---|---|---|---|
| `Browser is already in use for ms-playwright/mcp-chrome-…/, use --isolated to run multiple instances.` | Lock-fail (orphaned Chrome process tree holds user-data-dir lock) | (1) Restart the Playwright MCP server first (R3 — first-line for transient state). (2) If lock persists: PowerShell — find Chrome processes matching the MCP user-data-dir + kill the tree; remove the lockfile. (3) Re-invoke `browser_navigate`. | Add `--isolated` flag to MCP invocation. If still fails, file under FD-02 MCP plugin compatibility. |
| `browser_evaluate` returns `Execution context was destroyed` | Page navigation interrupted the evaluate scope | Re-navigate, then re-run evaluate. Common when navigation triggers in the same tick as evaluate. | If reproducible after one retry, the test is racing real navigation; switch to `waitForFunction` first. |
| `browser_console_messages` returns empty array unexpectedly | Console buffer cleared by navigation | Capture immediately after action; do not navigate before capture. | If buffer still empty, the page may have its own console silencer; check for `console.log = () => {}` in init. |
| MCP tool times out (>30s) without response | Server hung; transport class | Restart the Playwright MCP server (R3 first-line). | If hangs repeat, file under FD-02 with frequency data; consider degradation path to manual smoke per F-V11 follow-on. |

If the recovery path doesn't fit one of these rows, document the new failure mode + recovery in `docs/PROJECT-PLAN.md` Open Findings as a new finding before proceeding.

## Red Flags

| Excuse | Reality |
|---|---|
| "Manual smoke is faster" | Manual smoke produces no record. Re-run cost on the next cycle is full re-execution. Playwright produces a re-runnable script. |
| "Tests pass in CI" | CI ran when PR opened. Iron Law requires fresh evidence in this session. Re-run the harness. |
| "setTimeout(500) works on my machine" | 5/5 BINDING — wait-for-condition over arbitrary `setTimeout`. Race conditions + slow CI break the assumption. |
| "Pixel diff matches" | Pixel diffs catch styling regressions, not user-visible behavior. ARIA snapshot is the deliverable evidence. |
| "Console errors aren't related to my change" | D19 requires console-clean on routes touched, regardless of whether errors are "yours." File pre-existing as separate findings. |

## Quick Reference

- Iron Law inherits from `verification-before-completion`: NO UI CLAIM WITHOUT FRESH BROWSER-DRIVEN EVIDENCE.
- Bind `wait_for(<text|role|alias>)`, NOT `setTimeout`. (5/5 BINDING.)
- ARIA snapshot, NOT pixel screenshot. (Anthropic-MCP-native.)
- Console-error capture mandatory on every route touched. (D19.)
- Synthetic event dispatch for timing-dependent bugs (BC-1, BC-3).
- Failing-test-first: save the harness invocation as a regression test.

## Composability

- **Specializes** `verification-before-completion` for UI deliverables.
- **Pairs with** `gate-3-production-check` D19 (console-errors-clean) — neither works without the other; D19 has no deterministic grep, so Playwright execution is the sole enforcement.
- **Invoked from** `systematic-debugging` Step 4 when confidence < 90% AND the bug surface is browser-rendered.
- **Composable with** `regression-scope` — every captured Playwright invocation becomes a regression test.

## Citations

**SP precedent (line-anchored):**
- `superpowers/5.0.7/skills/verification-before-completion/SKILL.md` lines 16–22 (Iron Law inheritance)
- `superpowers/5.0.7/skills/test-driven-development/SKILL.md` (failing-test-first discipline)
- `superpowers/5.0.7/skills/systematic-debugging/SKILL.md` Step 4 (decide-fix-or-instrument)
- `superpowers/5.0.7/skills/systematic-debugging/condition-based-waiting.md` ("Wait for the actual condition you care about, not a guess about how long it takes.")

**Anthropic guidance:**
- *Building Effective AI Agents* — ACI tool design / verification step
- *Effective Context Engineering* — file artifacts as evidence substrate
- Claude Code Playwright MCP server docs (ARIA snapshot, browser_console_messages, browser_network_requests)

**Enterprise / OSS (≥3, satisfied 6):**
- Playwright official Best Practices: https://playwright.dev/docs/best-practices
- Cypress Best Practices: https://docs.cypress.io/guides/references/best-practices (including `fail-on-console-error`)
- Testing Library guiding principles: https://testing-library.com/docs/guiding-principles
- Selenium WebDriver patterns
- Microsoft Azure browser-testing guides
- BrowserStack enterprise testing patterns

**Companion PF v2 research:**
- `docs/research/skill-design-browser-driven-verification.md` (Wave 1, Opus, 327L)
- `docs/research/skill-design-stack-patterns-extensions-2026-04-30.md` Pattern 3 (console-errors)
- `docs/research/bug-class-taxonomy-2026-04-30.md` (BC-1, BC-3, BC-4 trigger this skill)
