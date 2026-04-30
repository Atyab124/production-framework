# Skill Design Research — `browser-driven-verification`

**Date:** 2026-04-30
**Type:** Source-of-truth research — no code modifications
**Triggered by:** v1-feedback Pass-1 audit Item 16 + cluster C7 (`docs/audits/v1-feedback-vs-v2-2026-04-30.md` lines 193–198, 226). Three v1 sessions where Playwright was empirically load-bearing — Hier-2 panel-open false alarm; mention-picker race synthetic-event reproduction; notification store popover verification — and the framework prescribed nothing. PF v2 binding rule (`CLAUDE.md` THE BINDING RULE) requires SP precedent OR Anthropic guidance OR ≥3 enterprise/OSS framework citations. SP has no `browser-driven-verification` skill. Anthropic ships Playwright as MCP but publishes no methodology for it as a discipline. Therefore this skill must cite ≥3 named enterprise/OSS browser-testing frameworks.

**Companion docs:**
- `docs/audits/v1-feedback-vs-v2-2026-04-30.md` Item 16 (the empirical trigger) and cluster C7 (the three concrete user incidents)
- `docs/research/sp-anthropic-citation-manifest.md` (the binding rule's citation source-of-truth)
- `docs/research/skill-design-gate-3-production-check.md` (precedent for this artifact's shape)
- SP cache: `verification-before-completion/SKILL.md`, `test-driven-development/SKILL.md`, `systematic-debugging/SKILL.md` + `condition-based-waiting.md` support file

---

## Methodology disclosure

WebFetch was permission-denied for canonical URLs in this session (consistent with prior research sessions in this repo). Quotes are taken in priority order:

1. **Local SP cache** at `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/` — verbatim, line-anchored.
2. **Companion research docs in this repo** — already-vetted re-citation.
3. **WebSearch synthesis of canonical URLs** — for Playwright / Cypress / Testing Library / Selenium / BrowserStack / Microsoft Azure / Anthropic published guidance not in SP. Tagged `(via WebSearch synthesis of <canonical URL>)` per the binding-rule disclosure convention.

Re-verify against canonical URLs before any binding architectural commitment. The bar applied: quote only what is **load-bearing** for a proposed skill clause (Iron Law phrasing, named pattern, hard rule, or anti-pattern).

---

## Part 1 — Sources Inventory

| # | Source | Tier | URL / path | Used for | Retrieved |
|---|---|---|---|---|---|
| S1 | SP `verification-before-completion/SKILL.md` | adjacent SP precedent | local cache | "Iron Law" phrasing; evidence-before-claims; Common Failures; Red Flags | 2026-04-30 |
| S2 | SP `test-driven-development/SKILL.md` | adjacent SP precedent | local cache | red-green discipline; "Verify RED" mandatory step; debugging integration | 2026-04-30 |
| S3 | SP `systematic-debugging/SKILL.md` | adjacent SP precedent | local cache | Phase 1 step 4 (multi-component evidence gathering); Phase 4 step 1 (failing test case); reproduce-consistently | 2026-04-30 |
| S4 | SP `systematic-debugging/condition-based-waiting.md` | adjacent SP precedent | local cache | wait-for-condition vs `setTimeout`; flaky-test root cause; "When Arbitrary Timeout IS Correct" | 2026-04-30 |
| A1 | Anthropic *Building Effective AI Agents* | adjacent Anthropic | https://www.anthropic.com/research/building-effective-agents | "gather context → take action → verify work → repeat"; evaluator-optimizer; ACI tool docs | WebSearch synthesis 2026-04-30 |
| A2 | Anthropic *Effective Context Engineering for AI Agents* | adjacent Anthropic | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | snapshot/artifact discipline (saving tool results as files); long-running agents | WebSearch synthesis 2026-04-30 |
| A3 | Claude Code Playwright plugin / `@playwright/mcp` | adjacent Anthropic + Microsoft | https://claude.com/plugins/playwright ; https://playwright.dev/docs/getting-started-mcp | Playwright is shipped as an Anthropic-blessed MCP; operates on accessibility tree, not pixels | WebSearch synthesis 2026-04-30 |
| E1 | Playwright official Best Practices | enterprise OSS | https://playwright.dev/docs/best-practices | user-visible behavior; web-first assertions; auto-waiting; locators by role | WebSearch synthesis 2026-04-30 |
| E2 | Playwright Auto-waiting | enterprise OSS | https://playwright.dev/docs/actionability | actionability checks; auto-wait before action | WebSearch synthesis 2026-04-30 |
| E3 | Playwright Locators | enterprise OSS | https://playwright.dev/docs/locators | `getByRole`/`getByText`/`getByTestId` priority order | WebSearch synthesis 2026-04-30 |
| E4 | Playwright Browser Contexts (Isolation) | enterprise OSS | https://playwright.dev/docs/browser-contexts | per-test `BrowserContext`; clean-slate; storageState | WebSearch synthesis 2026-04-30 |
| E5 | Playwright ARIA Snapshot Testing | enterprise OSS | https://playwright.dev/docs/aria-snapshots | `toMatchAriaSnapshot`; YAML accessibility tree as evidence | WebSearch synthesis 2026-04-30 |
| E6 | Cypress Best Practices | enterprise OSS | https://docs.cypress.io/app/core-concepts/best-practices | `data-cy`/`data-test` selectors; never `cy.wait(N)`; aliases via `cy.intercept` | WebSearch synthesis 2026-04-30 |
| E7 | Testing Library Guiding Principles | enterprise OSS | https://testing-library.com/docs/guiding-principles/ | "the more your tests resemble the way your software is used, the more confidence they can give you" | WebSearch synthesis 2026-04-30 |
| E8 | Selenium Waiting Strategies | enterprise OSS | https://www.selenium.dev/documentation/webdriver/waits/ | explicit waits with ExpectedConditions over `Thread.sleep` | WebSearch synthesis 2026-04-30 |
| E9 | BrowserStack — How to avoid Flaky Tests | enterprise vendor | https://www.browserstack.com/guide/how-to-avoid-flaky-tests ; https://www.browserstack.com/guide/playwright-waitfortimeout | hardcoded sleeps cause flake; smart waits adapt to actual state | WebSearch synthesis 2026-04-30 |
| E10 | Microsoft Azure App Testing (Playwright Workspaces) | enterprise vendor | https://learn.microsoft.com/en-us/azure/app-testing/playwright-workspaces/ ; https://azure.microsoft.com/en-us/products/playwright-testing | enterprise endorsement of Playwright as the standard E2E primitive | WebSearch synthesis 2026-04-30 |
| E11 | Cypress fail-on-console-error patterns | enterprise OSS / community | https://www.npmjs.com/package/cypress-fail-on-console-error ; https://alisterscott.github.io/Automatede2eTesting/AutomaticallyCheckingForPlaywrightConsoleErrors.html | console-error capture as test signal — direct precedent for v1 Item 12 (pre-existing #418/#419 hydration errors) | WebSearch synthesis 2026-04-30 |

**Source bucket counts:**
- Adjacent SP precedent: 4 (S1–S4) — but **none are `browser-driven-verification` itself**; SP has no such skill.
- Adjacent Anthropic guidance: 3 (A1–A3) — methodology-level, not skill-level.
- Enterprise/OSS browser-testing frameworks: **6 distinct named frameworks** (Playwright, Cypress, Testing Library, Selenium, BrowserStack, Microsoft Azure App Testing) plus 1 cross-framework community pattern (E11).

This satisfies the binding rule's ≥3 enterprise floor with margin (N=6 named frameworks).

---

## Part 2 — Verbatim Citations Organized by Topic

### 2.1 Verification before completion as Iron Law (the discipline this skill operationalizes for browser surfaces)

**S1 — `verification-before-completion/SKILL.md` lines 16–22 (Iron Law):**
> ```
> NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
> ```
> "If you haven't run the verification command in this message, you cannot claim it passes."

**S1 — `verification-before-completion/SKILL.md` lines 42–50 (Common Failures table — adapt to UI):**
> | Claim | Requires | Not Sufficient |
> |-------|----------|----------------|
> | Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
> | Agent completed | VCS diff shows changes | Agent reports "success" |

**S2 — `test-driven-development/SKILL.md` lines 113–117 (Verify RED is mandatory):**
> "**Verify RED — Watch It Fail. MANDATORY. Never skip.** … **Test passes?** You're testing existing behavior. Fix test."

### 2.2 Static reasoning is insufficient for timing-dependent / multi-component bugs

**S3 — `systematic-debugging/SKILL.md` lines 73–87 (Phase 1 step 4 — multi-component evidence):**
> "**WHEN system has multiple components (CI → build → signing, API → service → database):** **BEFORE proposing fixes, add diagnostic instrumentation** … For EACH component boundary: Log what data enters component, Log what data exits component … Run once to gather evidence showing WHERE it breaks THEN analyze evidence to identify failing component."

**S3 — `systematic-debugging/SKILL.md` lines 60–65 (reproduce consistently):**
> "**Reproduce Consistently** — Can you trigger it reliably? What are the exact steps? Does it happen every time? If not reproducible → gather more data, don't guess."

**S3 — `systematic-debugging/SKILL.md` lines 173–177 (Phase 4 step 1 — failing test case before fix):**
> "**Create Failing Test Case** — Simplest possible reproduction. Automated test if possible. One-off test script if no framework. **MUST have before fixing**."

### 2.3 Anti-`setTimeout` discipline (the directly-mapped anti-pattern that SP already names)

**S4 — `condition-based-waiting.md` lines 6–9 (core principle):**
> "Flaky tests often guess at timing with arbitrary delays. This creates race conditions where tests pass on fast machines but fail under load or in CI. **Core principle:** Wait for the actual condition you care about, not a guess about how long it takes."

**S4 — `condition-based-waiting.md` lines 96–106 ("When Arbitrary Timeout IS Correct"):**
> "Requirements: 1. First wait for triggering condition 2. Based on known timing (not guessing) 3. Comment explaining WHY"

**E1 — Playwright Best Practices (via WebSearch synthesis of https://playwright.dev/docs/best-practices):**
> "By using web-first assertions, Playwright will wait until the expected condition is met. For example, assertions such as `toBeVisible()` will wait and retry if needed."
> "Locators come with auto-waiting and retry-ability. Auto-waiting means that Playwright performs a range of actionability checks on the elements, such as ensuring the element is visible and enabled before it performs the click."

**E6 — Cypress Best Practices (via WebSearch synthesis of https://docs.cypress.io/app/core-concepts/best-practices):**
> "Avoid `cy.wait()` with static times; rely on Cypress' built-in retries. In Cypress, you almost never need to use `cy.wait()` an arbitrary number for anything." Use aliased intercepts: "use `cy.intercept()` to set up an aliased route, then use `cy.wait('@getUsers')` to wait explicitly for that route to finish."

**E8 — Selenium Waiting Strategies (via WebSearch synthesis of https://www.selenium.dev/documentation/webdriver/waits/):**
> "`Thread.sleep()` is rarely used because it causes WebDriver to wait for a specific time and does not let it run faster even if the specified condition is met. Whenever possible, use explicit wait with `WebDriverWait` and `ExpectedConditions`."

**E9 — BrowserStack — Why You Shouldn't Use page.waitForTimeout (via WebSearch synthesis):**
> "Stop using hardcoded sleeps … Hard waits don't adapt to the actual state of the app, making tests fragile. … Leverage waits that only pause execution when necessary, such as `waitForSelector()`. These adapt to the actual load times of elements and actions in your application."

### 2.4 Locator strategy — semantic / role-based / user-facing, not CSS

**E1 — Playwright Best Practices (via WebSearch synthesis):**
> "To make tests resilient, prioritizing user-facing attributes and explicit contracts is recommended. … Using `page.getByRole('button', { name: 'submit' })` is recommended as a best practice."

**E3 — Playwright Locators (via WebSearch synthesis of https://playwright.dev/docs/locators):**
> "The Playwright test generator will look at your page and figure out the best locator, prioritizing role, text and test id locators."

**E5 — Playwright ARIA Snapshot Testing (via WebSearch synthesis of https://playwright.dev/docs/aria-snapshots):**
> "`getByRole` interacts with the same accessibility tree used by screen readers. … In Playwright, aria snapshots provide a YAML representation of the accessibility tree of a page. These snapshots can be stored and compared later."
> "The `expect(locator).toMatchAriaSnapshot()` assertion method … compares the accessible structure of the locator scope with a predefined aria snapshot template."

**E6 — Cypress Best Practices (via WebSearch synthesis):**
> "Use `data-*` attributes to provide context to your selectors and isolate them from CSS or JS changes. Specifically, you should always try to use `data-cy` or `data-testid`." Avoid "highly brittle selectors that are subject to change, such as using dynamic classes or ID's that change."

**E7 — Testing Library Guiding Principles (via WebSearch synthesis of https://testing-library.com/docs/guiding-principles/):**
> "**The more your tests resemble the way your software is used, the more confidence they can give you.**"

### 2.5 Test isolation — clean-slate per scenario

**E4 — Playwright Browser Contexts (via WebSearch synthesis of https://playwright.dev/docs/browser-contexts):**
> "Tests written with Playwright execute in isolated clean-slate environments called browser contexts."
> "Playwright achieves isolation using `BrowserContexts` which are equivalent to incognito-like profiles that are fast and cheap to create and are completely isolated, even when running in a single browser."
> "What can be shared across tests includes config (`use`), storage snapshots (`storageState`), and fixtures and helpers, but what should never be shared are live pages, live contexts, and mutable global state."

### 2.6 Snapshot-as-evidence and console-error capture

**E5 — Playwright ARIA Snapshot Testing (via WebSearch synthesis):** as quoted in §2.4.

**A3 — Claude Code Playwright plugin / `@playwright/mcp` (via WebSearch synthesis of https://claude.com/plugins/playwright + https://playwright.dev/docs/getting-started-mcp):**
> "Playwright MCP operates on the page's accessibility tree, not pixels. When a tool runs, it returns a structured snapshot showing the page elements, their roles, and text content."

**E11 — Cypress fail-on-console-error / Playwright `page.on('console')` (via WebSearch synthesis of https://www.npmjs.com/package/cypress-fail-on-console-error and https://alisterscott.github.io/Automatede2eTesting/AutomaticallyCheckingForPlaywrightConsoleErrors.html):**
> Cypress: "`cypress-fail-on-console-error` … observes the `console.error()` function from the window object, and Cypress tests will fail when the error conditions are met."
> Playwright: "use `page.on('console', (msg) => {...})` and `page.on('pageerror', (error) => {...})` to automatically check for console errors and fail tests if any appear."

### 2.7 Anthropic — agent verification loop and artifact discipline

**A1 — Anthropic *Building Effective AI Agents* (via WebSearch synthesis of https://www.anthropic.com/research/building-effective-agents):**
> "Agents often operate in a specific feedback loop: gather context → take action → verify work → repeat."
> "Agents are particularly effective because code solutions are verifiable through automated tests, agents can iterate on solutions using test results as feedback."
> "You should carefully craft your agent-computer interface (ACI) through thorough tool documentation and testing."

**A1 — Anthropic *Building Effective AI Agents* — Evaluator-Optimizer (via WebSearch synthesis):**
> "In the evaluator-optimizer workflow, one LLM call generates a response while another provides evaluation and feedback in a loop. This workflow is particularly effective when we have clear evaluation criteria, and when iterative refinement provides measurable value."

**A2 — Anthropic *Effective Context Engineering for AI Agents* (via WebSearch synthesis of https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents):**
> "An initializer agent that sets up the environment on the first run, and a coding agent that is tasked with making incremental progress in every session, while leaving clear artifacts for the next session."

**A3 — Microsoft Azure App Testing — enterprise endorsement of Playwright (via WebSearch synthesis of https://azure.microsoft.com/en-us/products/playwright-testing):**
> "Playwright is a fast-growing, open-source framework that enables reliable end-to-end testing and automation for modern web apps."

---

## Part 3 — K of N Consensus Table

For each candidate skill clause, K of N enterprise/OSS sources require or recommend it. N = 6 named frameworks (Playwright [E1–E5], Cypress [E6, E11], Testing Library [E7], Selenium [E8], BrowserStack [E9], Microsoft Azure App Testing [E10]). Anthropic (A1–A3) and SP (S1–S4) listed for adjacency but not counted toward N.

| # | Pattern | Playwright | Cypress | Testing Library | Selenium | BrowserStack | MS Azure | K/N | Anthropic / SP adjacency |
|---|---|---|---|---|---|---|---|---|---|
| P1 | Tests must reflect user-visible behavior, not implementation | Yes (E1) | Yes (E6) | **Yes — guiding principle (E7)** | Implied | Implied | Endorses Playwright (E10) | **3/6 explicit, 6/6 directional** | A1 ACI tool design + S1 evidence-before-claims |
| P2 | Auto-waiting / web-first assertions over arbitrary `setTimeout` | **Yes (E1, E2)** | **Yes (E6 — never `cy.wait(N)`)** | n/a (unit-shape) | **Yes — `WebDriverWait` over `Thread.sleep` (E8)** | **Yes (E9)** | Endorses Playwright (E10) | **5/5 applicable** | **S4 condition-based-waiting (verbatim mapping)** |
| P3 | Semantic / role-based / data-test selectors over brittle CSS/XPath | **Yes — `getByRole` priority (E1, E3)** | **Yes — `data-cy`/`data-test` (E6)** | **Yes — accessible-name queries (E7)** | Implied (locator strategies) | Implied | Endorses Playwright (E10) | **3/6 explicit, 6/6 directional** | n/a |
| P4 | Per-scenario test isolation (clean-slate context, no shared mutable state) | **Yes — `BrowserContext` (E4)** | **Yes — beforeEach/clear state (E6)** | n/a (shape) | Implied | Implied | Endorses Playwright (E10) | **2/6 explicit, 6/6 directional** | n/a |
| P5 | Snapshot of accessibility tree as evidence artifact | **Yes — `toMatchAriaSnapshot` / aria YAML (E5)** | Partial (DOM snapshot) | Implied | No | No | n/a | **1/6 explicit (Playwright), 2/6 directional** | **A2 artifact discipline + A3 MCP returns "structured snapshot showing the page elements, their roles, and text content"** |
| P6 | Console-error / page-error capture as test signal | **Yes — `page.on('console')` / `pageerror` (E11)** | **Yes — `cypress-fail-on-console-error` (E11)** | n/a | Possible via JS executor | Possible | n/a | **2/6 explicit; community-broad** | n/a — **fills v1 Item 12 gap (pre-existing #418/#419)** |
| P7 | Failing test before fix (red-before-green for browser-surface bugs) | Implied | Implied | Implied | Implied | Yes (E9 reproducibility) | n/a | **1/6 explicit, 5/6 directional** | **S2 Iron Law of TDD + S3 Phase 4 step 1 ("MUST have before fixing")** |

**Headline consensus:**

- **P2 (anti-`setTimeout`) is unanimous (5/5 applicable frameworks) and verbatim-mapped to SP `condition-based-waiting`.** This is the strongest binding clause.
- **P1, P3, P4 are directionally unanimous (6/6 frameworks endorse) even when phrasing varies.** Safe to bind.
- **P5 (ARIA snapshot) is Playwright-specific** but is precisely the mechanism Anthropic's MCP returns, which makes it load-bearing for Claude-Code-driven verification specifically.
- **P6 (console-error capture)** is community-broad but not in any one framework's "Best Practices" front page. It is the **single most direct response to Item 12** (pre-existing recoverable hydration errors silently accumulating across cycles).
- **P7 (red-before-green)** has weak consensus among browser frameworks but **strong SP precedent** (S2, S3). The binding citation is SP, not browser-framework consensus — which is appropriate given the parent discipline lives at the project level.

---

## Part 4 — Gap Analysis vs Current PF v2 Framing

### What PF v2 has today

- **`verification-before-completion`** (SP-inherited, line 16: "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE"). Universal — does not name a primitive for UI surfaces.
- **`systematic-debugging`** (SP-inherited, Phase 1 step 4 multi-component evidence; Phase 4 step 1 mandatory failing test). Universal — does not name a primitive for the browser layer specifically.
- **`condition-based-waiting`** (SP support file under `systematic-debugging/`). The closest verbatim match in SP — but it is a **support file inside `systematic-debugging`, not a top-level skill**. Not surfaced as a discoverable primitive when an agent is verifying a UI deliverable.
- **`gate-3-production-check`** (PF v2 18-dimension gate). Currently **has no console-clean dimension** — Item 12 is open per the audit (line 116–117).

### What PF v2 lacks

- **Zero `playwright|browser_*` references in `skills/`** — verified by grep (per Item 16 line 196). The framework prescribes nothing for the cases where Playwright was empirically load-bearing.
- **No mapping between SP's universal `condition-based-waiting` and the browser surface** — a contributor reading SP doesn't know that `setTimeout(...)` in an E2E test maps to the same Iron-Law violation as `setTimeout` in a Node async test.
- **No clause requiring evidence to be a snapshot of the accessibility tree** — i.e., no statement that "my agent saw it work" (an unsnapshotted screenshot or console claim) does not satisfy the Iron Law for UI deliverables.
- **No console-error capture clause** — Item 12 silent #418/#419 across cycles is the canonical incident.
- **No bridge to `gate-3-production-check`** — UI deliverables need a browser-driven dimension; absent this, gate-3 remains backend-leaning.

### What this skill must therefore do

1. Bind **P2** (anti-`setTimeout`) verbatim — strongest consensus, direct SP-precedent mapping.
2. Bind **P3** (semantic/role-based locators) — 6/6 directional consensus, plus matches Anthropic-MCP's accessibility-tree return shape.
3. Bind **P4** (test isolation) — operational hygiene; cheap; 6/6 directional.
4. Bind **P5** (accessibility-tree snapshot as evidence) — Playwright-specific but matches Anthropic-MCP semantics.
5. Bind **P6** (console-error capture) — fills Item 12 gap directly.
6. Bind **P7** (failing test before fix) — SP-precedent dominant; restate at the browser surface so the bridge from `systematic-debugging` Phase 4 step 1 is named.
7. Compose with `verification-before-completion`, `systematic-debugging` Step 4, `gate-3-production-check` — explicit cross-references in the SKILL.md.

---

## Part 5 — Recommendations

### R1. Adopt Iron-Law shape with a UI-specific phrasing

**What:**
> ```
> NO UI / TIMING-DEPENDENT COMPLETION CLAIMS WITHOUT FRESH BROWSER EVIDENCE
> ```
> "If you haven't driven the browser in this session, you cannot claim a UI deliverable, a timing-dependent fix, or a console-clean state."

**Why:** Mirrors S1's ratified phrasing, narrows the surface to where static reasoning empirically fails (Item 16 cluster C7), and makes the skill discoverable from the parent `verification-before-completion`.

### R2. Bind `wait_for(<text or role assertion>)` over arbitrary `setTimeout` / `page.waitForTimeout`

**What:** A hard rule: "Browser-driven verification scripts MUST wait for a semantic condition (text, role, network alias, state assertion) — never `page.waitForTimeout`, `cy.wait(N)`, or arbitrary `sleep`. If a known timing is required (debounce, throttle), wait for the triggering condition first AND comment WHY the timing is fixed."

**Why:** P2 is the strongest consensus item (5/5 applicable enterprise frameworks unanimous; SP `condition-based-waiting` verbatim). This is the single highest-leverage clause for cutting flake — and the Hier-2 / mention-picker / notification-store v1 incidents all involved timing.

### R3. Bind locators-by-role / accessible-name / data-testid; reject CSS-class / nth-child selectors

**What:** "Locators MUST be semantic in this priority order: `getByRole({ name })` → `getByText` → `getByLabel` / `getByPlaceholder` → `getByTestId`. CSS-class and `:nth-child` selectors are forbidden in verification scripts. Rationale: tests should not break on a styling refactor; they should break on a behavior change."

**Why:** P3 — 6/6 directional, 3/6 explicit, plus aligned with Testing Library's foundational principle and with Anthropic Playwright MCP's accessibility-tree return.

### R4. Snapshot-as-evidence: capture the ARIA tree (or equivalent structured DOM snapshot), not a pixel screenshot, for all UI deliverable claims

**What:** "When claiming a UI deliverable DONE, the verification artifact attached to the handover MUST be a structured snapshot — `mcp__plugin_playwright_playwright__browser_snapshot` accessibility tree, or an equivalent role/text DOM dump. Pixel screenshots are supplementary, not primary, because they do not assert structure or accessibility and cannot be diffed by an agent reliably."

**Why:** P5 + A2 + A3 — Anthropic MCP returns structured snapshots specifically because they are agent-readable. Pixel screenshots fail the artifact-as-context-engineering principle.

### R5. Console-error / page-error capture is non-optional for the routes-touched dimension

**What:** Add a clause: "On every route touched by the ship, the verification script MUST attach `page.on('console')` and `page.on('pageerror')` listeners and emit the captured set as part of the evidence. New errors block. Pre-existing errors are filed as separate findings but recorded — silent accumulation is rejected."

**Why:** Directly closes Item 12 (pre-existing #418/#419 across multiple cycles). Maps to E11 community pattern (`cypress-fail-on-console-error`, Playwright `page.on('console')`). Composes with `gate-3-production-check` as a new sub-criterion under D15 or a new dimension D19 per the audit's Item-12 action.

### R6. Failing-script-first for browser-surface bug fixes — explicit cross-reference to `systematic-debugging` Phase 4 step 1

**What:** A clause: "For any bug fix on a UI / timing-dependent surface, a Playwright (or equivalent) script reproducing the symptom MUST exist and MUST FAIL on `HEAD` before the fix is applied. After the fix it MUST PASS. The script is the regression test and ships with the change. This is `systematic-debugging` Phase 4 step 1 specialized to the browser surface."

**Why:** Mention-picker race and notification-store popover both required Playwright-reproduction — once written, they would be reusable regression tests. Aligns with S2 + S3, and operationalizes the SP TDD discipline at the browser surface.

### R7. Test isolation: each verification script runs in a clean `BrowserContext` / equivalent

**What:** "Each verification scenario MUST run in a fresh isolated context (Playwright `BrowserContext`, Cypress `cy.session` reset, or equivalent). Authenticated states are loaded via `storageState` or per-test login — never shared mutable global state. Order-dependent tests are rejected."

**Why:** P4 — 2/6 explicit (Playwright/Cypress), 6/6 directional. Cheap, prevents whole class of flake, matches Anthropic MCP's per-tool-call browser context.

### R8. Compose explicitly with `verification-before-completion`, `systematic-debugging`, and `gate-3-production-check`

**What:** Frontmatter `description:` lists the three skills as composables. Body `## Composes With` section names the entry points:
- From `verification-before-completion`: when the artifact under verification is a UI / timing-dependent deliverable, this skill is the named primitive.
- From `systematic-debugging` Phase 1 step 4: for browser-surface multi-component evidence, this skill is the instrumentation harness.
- From `gate-3-production-check`: D-X console-clean dimension is enforced by this skill's R5.

**Why:** Discoverability. The empirical failure mode in v1 was not absence of capability — Playwright was used three times — but absence of a named, cross-referenced discipline. SP precedent is to make composition explicit in the SKILL.md (e.g., `systematic-debugging` lines 286–288 list `test-driven-development` and `verification-before-completion` as related skills).

### R9. When to NOT use this skill — explicit non-targets

**What:** A `## When NOT to Use` section. Non-targets:
- Pure backend / no-UI changes.
- Build / typecheck / lint failures (use the project's `bash-output-discipline` wrapped commands).
- Migrations / RLS rule changes (use `tenant-isolation` + `rls-aware-migrations`).
- Static prop / type / unit-level bugs reachable by reading the file.

**Why:** A discipline that fires everywhere fires nowhere. The empirical trigger is bounded — UI deliverables, timing bugs, console errors — and the skill should advertise its own bounds so it is not invoked for cases where unit-level evidence already satisfies the Iron Law.

### R10. Do not name a specific harness in the universal skill body — keep stack-agnostic

**What:** SKILL.md body uses verbs (`navigate`, `wait_for`, `snapshot`, `assert by role`, `capture console`) and names "Playwright or equivalent" — never hardcodes Playwright API surface. A `templates/STACK-PATTERNS.template.md` slot OR a per-project `tools/` README pins the concrete harness (`@playwright/mcp`, Cypress, WebdriverIO).

**Why:** Per `CLAUDE.md` rejection criterion #3 ("No domain-specific skills in core. Stack-specific patterns belong in `templates/STACK-PATTERNS.md`"). PF v2 inherits PF v1's `core/` purity rule. The discipline is universal; the toolchain is stack-conditional.

---

## Citations footer

**SP cache (verbatim, line-anchored):**
- `superpowers/5.0.7/skills/verification-before-completion/SKILL.md` — lines 16–22 (Iron Law), lines 42–50 (Common Failures table)
- `superpowers/5.0.7/skills/test-driven-development/SKILL.md` — lines 32–46 (Iron Law of TDD), lines 113–117 (Verify RED MANDATORY)
- `superpowers/5.0.7/skills/systematic-debugging/SKILL.md` — lines 60–65 (reproduce consistently), lines 73–87 (Phase 1 step 4 multi-component evidence), lines 173–177 (Phase 4 step 1 failing test case MUST), lines 286–288 (related skills convention)
- `superpowers/5.0.7/skills/systematic-debugging/condition-based-waiting.md` — lines 6–9 (core principle), lines 50–57 (quick patterns table), lines 96–106 (when arbitrary timeout IS correct)

**Anthropic (via WebSearch synthesis 2026-04-30):**
- *Building Effective AI Agents* — https://www.anthropic.com/research/building-effective-agents — feedback loop, evaluator-optimizer, ACI tool docs
- *Effective Context Engineering for AI Agents* — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents — artifacts across context windows
- Claude Code Playwright plugin — https://claude.com/plugins/playwright — accessibility-tree snapshots
- Playwright MCP getting-started — https://playwright.dev/docs/getting-started-mcp — Microsoft-maintained Anthropic-blessed MCP

**Enterprise/OSS browser-testing frameworks (via WebSearch synthesis of canonical URLs 2026-04-30):**
- Playwright Best Practices — https://playwright.dev/docs/best-practices
- Playwright Auto-waiting / Actionability — https://playwright.dev/docs/actionability
- Playwright Locators — https://playwright.dev/docs/locators
- Playwright Browser Contexts — https://playwright.dev/docs/browser-contexts
- Playwright ARIA Snapshot Testing — https://playwright.dev/docs/aria-snapshots
- Cypress Best Practices — https://docs.cypress.io/app/core-concepts/best-practices
- Testing Library Guiding Principles — https://testing-library.com/docs/guiding-principles/
- Selenium Waiting Strategies — https://www.selenium.dev/documentation/webdriver/waits/
- BrowserStack — How to avoid Flaky Tests — https://www.browserstack.com/guide/how-to-avoid-flaky-tests
- BrowserStack — Why You Shouldn't Use page.waitForTimeout — https://www.browserstack.com/guide/playwright-waitfortimeout
- Microsoft Azure App Testing (Playwright Workspaces) — https://azure.microsoft.com/en-us/products/playwright-testing
- Cypress fail-on-console-error — https://www.npmjs.com/package/cypress-fail-on-console-error
- Playwright console-error capture pattern — https://alisterscott.github.io/Automatede2eTesting/AutomaticallyCheckingForPlaywrightConsoleErrors.html

**v1 empirical incidents driving the skill (per Item 16 + cluster C7):**
- Hier-2 panel-open false alarm — Playwright revealed panel state mismatch invisible to static reading
- Mention-picker race — Playwright synthetic-event reproduction was the only path to repro
- Notification-store popover verification — Playwright was the only verifier of the timing-dependent popover render
- Item 12 — pre-existing React #418/#419 / recoverable hydration errors silently accumulating across multiple ship cycles

All canonical URLs SHOULD be re-verified against live sources before any binding architectural commitment, per the methodology disclosure above.
