---
name: gate-3-production-check
description: "Use before declaring a feature production-ready, before deploying to production, or before merging a release branch — walks an 18-dimension production-readiness check covering tenant isolation, RLS, rollback, SLO/SLI, runbook, observability, security review, performance budget, migration phase, audit log, PII, error-budget headroom, feature flag, build/test, regression scope, 12-factor compliance, and PROJECT-PLAN update. Composable with verification-before-completion, requesting-code-review, and finishing-a-development-branch."
---

## Overview

The final pre-ship production gate. The CTO/Deputy invokes this skill at cycle end (after Builder + QA + Code Reviewer report DONE). It walks 18 dimensions drawn from Google SRE Book (Chs. 4 / 6 / 8 / 32) + Workbook (Chs. 2 / 5 / 16) + AWS Well-Architected (Operational Excellence / Security / Reliability / Performance Efficiency) + Twelve-Factor + DORA Four Keys + OWASP ASVS / API Top 10 / Multi-Tenant + NIST SP 800-53 + Honeycomb high-cardinality + Atlassian/GitHub deployment guides.

Every dimension is grounded in ≥3 enterprise sources OR carries SP precedent + 2 sources OR is explicitly tagged PF-internal with rationale. **Zero dimensions fail the binding rule.**

This skill is the **ship-time** sibling of `seven-validation-questions`'s **plan-time** gate. Together they form a coherent two-stage gate (plan → ship). A plan that passes the 7 questions feeds a build that walks Gate 3.

## The Iron Law

```
NO PRODUCTION-READY CLAIM WITHOUT FRESH GATE-3 EVIDENCE.
```

If you haven't produced fresh evidence for a dimension in this session, you cannot mark it PASS. "Tests passed yesterday" is not evidence; "build green last week" is not evidence. Re-run, read the output, count the failures.

<HARD-GATE>
Before claiming a feature production-ready, before deploying to production, or before merging a release branch, you MUST walk every applicable dimension in the 18-dimension table and produce, for each, ONE of:

- **PASS** — with cited evidence (command output, file path, control ID)
- **WAIVED** — with stated rationale tied to scope (e.g., "single-tenant — D1/D2/D7/D11 N/A, citing STACK-PATTERNS.md tenancy-model: single-tenant line N")
- **BLOCKED** — fix dispatched + re-run scheduled

A "✓" without evidence is dishonesty, not verification.
A skipped dimension is a gate failure.
A waiver without rationale is a gate failure.

Violating the letter of this rule is violating the spirit of this rule.
</HARD-GATE>

## The Gate Function

Adapted from SP `verification-before-completion` lines 26–38, specialized for production-readiness:

BEFORE claiming production-ready or deploying:

1. **IDENTIFY** — for each applicable dimension, what command / file read / artifact proves the claim?
2. **RUN** — execute the command fresh, in this session, in full
3. **READ** — full output, exit code, count of findings
4. **VERIFY** — does the output confirm the dimension passes its criterion?
5. **CITE** — record the dimension status with command output reference, control ID, or runbook URL
6. **ONLY THEN** — mark the dimension PASS

Skip any step = lying, not verifying.

## When to Use

- **Mandatory:** before declaring a feature production-ready (CTO synthesis step at cycle end).
- **Mandatory:** before deploying to production (CI/CD or manual deploy).
- **Mandatory:** before merging to a protected release branch (`main`, `release/*`).
- **Recommended:** before merging a feature branch when the change has cross-tenant or cross-service blast radius (D14 trigger).

Do NOT use this skill on Tier 1 changes (typo, comment, single-line config) — the gate's overhead exceeds the change's blast radius. Tier 2/3 only.

## Core Pattern

You MUST use TodoWrite to create one todo per applicable dimension before walking the table. Skip multi-tenant dimensions D1/D2/D7/D11 if and only if `tenancy-model: single-tenant` is declared in the project's `docs/STACK-PATTERNS.md` — and cite the path + line in the waiver.

### The 18 Dimensions

Walk in the order listed (cheap-and-fail-fast → expensive-and-confirmatory).

```
1.  D15 BUILD/TEST/LINT — run all stack verification commands (lint, typecheck, test, build); confirm exit 0; no debug artifacts.
2.  D16 REGRESSION SCOPE — every item on the plan's regression-scope list re-tested with fresh evidence in this session.
3.  D17 12-FACTOR — no secrets in client bundles; env-var config; dev/prod parity adequate.
4.  D9  PERFORMANCE BUDGET — P95 read < {stack:read-budget}; P95 write < {stack:write-budget}; query < {stack:query-latency-budget}; bundle < {stack:bundle-budget}.
5.  D2  RLS / DATA-LAYER ENFORCEMENT — every tenant-scoped table has policy + FORCE RLS (or non-owning role) + tested under ≥2 auth identities.
6.  D1  TENANT ISOLATION — Code-Reviewer multi-tenant greps clean; integration test executes under ≥2 tenant identities and returns disjoint result sets.
7.  D7  OBSERVABILITY TENANT-SCOPED — every log/trace/metric sample includes tenant_id field.
8.  D11 AUDIT LOG WRITES — every state-changing op writes an audit row with required fields.
9.  D12 NO PII IN LOGS — grep audit writers for credentials, raw email/phone, session tokens, payment details — clean.
10. D8  SECURITY REVIEW PASS — docs/security/<feature>.md exists; every finding cites a control ID; no open CRITICAL.
11. D4  SLO/SLI CATALOG — runbook declares SLIs (golden signals as floor) + SLOs (numeric, not derived from current perf) + error budget = 100%−target.
12. D5  BURN-RATE ALERTS — fast-burn + slow-burn windows wired; both required to page.
13. D6  RUNBOOK PER ALERT — every alert links to runbook with on-call owner + escalation path.
14. D13 ERROR-BUDGET HEADROOM — read burn-down; compare to risk band; if exhausted, defer per Error Budget Policy.
15. D10 MIGRATION PHASE — phase classified (expand/contract/mixed); backfill strategy named; rollback envelope declared; data-loss disclosure if irreversible.
16. D3  ROLLBACK PATH — rollback URL/command in runbook; rehearsed within 30 days; named owner.
17. D14 FEATURE FLAG / KILL-SWITCH — if blast radius is broad: flag named + owner + progressive rollout plan + kill-switch tested. Else: blast-radius assessment documenting why no flag is needed.
18. D18 PROJECT-PLAN UPDATE — phase status, incidents, remnants appended to docs/PROJECT-PLAN.md.
19. D19 CONSOLE-ERRORS CLEAN (added 2026-04-30) — Playwright browser_console_messages empty on every route touched by ship; pre-existing errors filed separately, not absorbed.
```

### Dimension detail

Each dimension carries: **Pass criterion** | **Cited control IDs / sources** | **Owning agent on fail**.

#### D1 — Tenant isolation verified (multi-tenant only)

- **Pass:** (a) Code-Reviewer multi-tenant grep run on diff, clean (per `templates/STACK-PATTERNS.md` "Code-Review Pre-Flight Greps"); (b) integration test executed under ≥2 tenant identities returns disjoint result sets.
- **Cite:** OWASP ASVS V4.2.1; OWASP API1:2023 (BOLA); NIST AC-3, SC-4; AWS Reliability REL10-BP03 (bulkhead).
- **Owner on fail:** Builder + Security/Compliance.

#### D2 — RLS / data-layer enforcement present

- **Pass:** (a) policy SQL exists for every tenant-scoped table; (b) `FORCE ROW LEVEL SECURITY` declared OR a non-owning application role is used; (c) policy tested under ≥2 `auth.uid()` values.
- **Cite:** NIST AC-3; PostgreSQL §5.9 ("Table owners normally bypass row security as well, though a table owner can choose to be subject to row security with `ALTER TABLE … FORCE ROW LEVEL SECURITY`"); OWASP Multi-Tenant Cheat Sheet ("Use database-level isolation as defense in depth").
- **Owner on fail:** Database Engineer.

#### D3 — Rollback path documented + tested

- **Pass:** (a) rollback URL/command in runbook; (b) rehearsal log within last 30 days; (c) named owner.
- **Cite:** Google SRE Ch. 8 ("Rollback early, rollback often"); Atlassian deployment checklist; Mercari production-readiness check.
- **Owner on fail:** SRE/DevOps.

#### D4 — SLO/SLI catalog has entries for new surface

- **Pass:** (a) SLI queries runnable for the new surface; (b) SLO targets numeric, NOT derived from current performance (Workbook Ch. 2); (c) error budget = 100%−target stated explicitly.
- **Cite:** Google SRE Ch. 4 ("SLOs specify a target level for the reliability of your service"; "Each objective has a separate error budget, defined as 100% minus (–) the goal for that objective"); SRE Ch. 6 four golden signals; AWS WAF Reliability; DORA Four Keys.
- **Owner on fail:** SRE/DevOps.

#### D5 — Burn-rate alerts wired

- **Pass:** (a) fast-burn window (e.g., 2% of budget burned in 1h); (b) slow-burn window (e.g., 5% in 6h); (c) both must fire to page.
- **Cite:** Workbook Ch. 5 ("In most cases, [Google believes] that the multiwindow, multi-burn-rate alerting technique is the most appropriate approach to defending your application's SLOs"); Datadog burn-rate post.
- **Owner on fail:** SRE/DevOps.

#### D6 — Runbook exists for every alert

- **Pass:** (a) runbook URL on every alert; (b) on-call rotation declared for launch window; (c) runbook covers symptoms, mitigation, rollback.
- **Cite:** Google SRE Ch. 32 (PRR emergency response); Ch. 6 ("Page on user-visible symptoms, ticket on causes"); AWS WAF Operational Excellence; Mercari; Atlassian.
- **Owner on fail:** SRE/DevOps.

#### D7 — Observability fields include tenant_id (multi-tenant)

- **Pass:** (a) structured/wide events used; (b) `tenant_id` field present in samples from each emitter (logs, traces, metrics).
- **Cite:** Honeycomb Observability 101 ("High cardinality refers to a field that can have many possible values… fields like userId, shoppingCartId, and orderId are often high-cardinality"); Honeycomb *OpenTelemetry Is Not Three Pillars*; Twelve-Factor Factor XI; STACK-PATTERNS observability section.
- **Owner on fail:** SRE/DevOps + Builder.

#### D8 — Security review pass with control IDs

- **Pass:** (a) `docs/security/<feature>.md` produced by Security/Compliance; (b) every finding tagged with OWASP/NIST/SOC2 ID; (c) no open CRITICAL findings.
- **Cite:** OWASP ASVS V4 / API Top 10 (2023); NIST 800-53 Rev. 5; SOC 2 TSC 2017.
- **Owner on fail:** Security/Compliance.

#### D9 — Performance budget met

- **Pass:** (a) P95 measured at scale targets, not dev data; (b) `{stack:explain-tool}` output for hot queries shows index usage; (c) bundle measurement for frontend within `{stack:bundle-budget}`.
- **Cite:** AWS WAF Performance Efficiency; Azure WAR Performance pillar; DORA Lead Time; STACK-PATTERNS budgets section.
- **Owner on fail:** Builder + Database Engineer.

#### D10 — Migration phase pattern followed

- **Pass:** (a) phase classified (expand-only / contract / mixed); (b) backfill strategy declared (none / synchronous-batch / async-chunk); (c) rollback envelope declared (any-time / pre-cutover-only / post-cutover-only / irreversible). If irreversible: 3-line Data-Loss Disclosure (per Database Engineer agent's HARD-GATE shape).
- **Cite:** gh-ost README; pgRoll README; pt-osc docs (3/3 consensus on expand → backfill → cutover → contract).
- **Owner on fail:** Database Engineer.

#### D11 — Audit log writes for state-changing ops

- **Pass:** (a) audit table append-only; (b) every row contains `actor_id, tenant_id, action, target, timestamp` (per STACK-PATTERNS `audit-log-fields` slot); (c) log integrity protected (NIST AU-9).
- **Cite:** NIST AU-2 (Event Logging), AU-3 (Content of Audit Records), AU-9 (Audit Record Protection); ASVS V7.1.3, V7.2.1, V7.2.2; SOC 2 CC7.2.
- **Owner on fail:** Security/Compliance + Builder.

#### D12 — No PII in logs

- **Pass:** (a) grep audit writers for credentials, raw email/phone, session tokens, payment details — clean; (b) explicit redaction rule documented; (c) error messages are generic + correlation ID.
- **Cite:** ASVS V7.1.1, V7.1.2, V7.4.1; NIST AU-11, SI-12; SOC 2 CC6.7.
- **Owner on fail:** Security/Compliance.

#### D13 — Error-budget headroom checked

- **Pass:** EITHER (a) read current error-budget consumption, compare to risk band of change, headroom > 2× expected risk OR (b) explicit waiver: "budget tracking not yet wired; check skipped — see SRE/DevOps backlog item." Do not fake a number.
- **Cite:** Workbook Error Budget Policy ("If the service has exceeded its error budget for the preceding four-week window, we will halt all changes and releases other than P01 issues or security fixes until the service is back within its SLO"); DORA Change Failure Rate.
- **Owner on fail:** SRE/DevOps.

#### D14 — Feature flag / kill-switch in place if blast radius is broad

- **Pass:** if cross-tenant / cross-service / data-layer change: (a) flag named + owner declared; (b) progressive rollout plan (canary % bands: 1% → 10% → 50% → 100%); (c) kill-switch tested. ELSE: blast-radius assessment documenting why no flag is needed.
- **Cite:** Atlassian deployment checklist; GitHub deployments docs; Workbook Ch. 16 *Canarying Releases*; AWS Reliability REL10-BP03 (bulkhead analog); Mercari progressive rollout.
- **Owner on fail:** SRE/DevOps + Builder.

#### D15 — Build / test / lint / typecheck clean (fresh evidence)

- **Pass:** (a) Iron Law re-run in this session; (b) no `console.log`, no `[debug:*]` prefixes, no commented-out code; (c) build artifact produced.
- **Cite:** SP `verification-before-completion` Iron Law + Common Failures table; Twelve-Factor V (build/release/run); Mercari image-scan + lint required.
- **Owner on fail:** Builder.

#### D16 — Regression scope re-tested

- **Pass:** (a) regression-scope list present in plan; (b) each item has fresh-run evidence; (c) no previously-working feature broken.
- **Cite:** SP `requesting-code-review` (review-before-merge); AWS WAF Operational Excellence ("How do you mitigate deployment risks?").
- **Owner on fail:** QA + Builder.

#### D17 — Twelve-Factor compliance (config, dependencies, parity)

- **Pass:** (a) grep for hardcoded secrets — clean; (b) env vars documented; (c) deployment images built from same source as test images.
- **Cite:** Twelve-Factor III (Config: "Store config in the environment"), IX (Disposability), X (Dev/prod parity); Mercari probes + secrets.
- **Owner on fail:** SRE/DevOps + Builder.

#### D18 — PROJECT-PLAN updated with phase status, incidents, remnants

- **Pass:** (a) PROJECT-PLAN.md appended with phase status + outcome; (b) Open Findings table updated; (c) Remnant Watchlist documented for next cycle (debug logs, feature flags to remove, TODOs).
- **Cite (PF-internal):** Anthropic *Effective Context Engineering* — "save information from tool call results as artifacts"; cto-mode skill step 6.
- **Owner on fail:** CTO.

#### D19 — Console-errors clean on touched routes (added 2026-04-30; pairs with `browser-driven-verification`)

- **Pass:** (a) Playwright `browser_console_messages` is empty (no errors) on every route touched by the ship; (b) any pre-existing console errors filed as separate findings, NOT absorbed silently; (c) hydration-mismatch errors (#418/#419) treated as ship-blockers, not warnings.
- **Cite:** Wave 1 R-1 + Wave 3 Pattern 3 (`docs/research/skill-design-browser-driven-verification.md`; `skill-design-stack-patterns-extensions-2026-04-30.md` Pattern 3); Cypress `fail-on-console-error`; react.dev errors #418/#419; Web Vitals on hydration impact. Closes Audit Item 12.
- **Owner on fail:** Builder + SRE/DevOps.
- **Pairing note:** D19 has **no deterministic grep** — Playwright execution is the sole enforcement mechanism. D19 + the `browser-driven-verification` skill ship together; neither works without the other.

## Stack-Conditional Waivers

Single-tenant projects waive D1, D2, D7, D11 — but the waiver MUST cite STACK-PATTERNS.md by path + value:

```
WAIVED — STACK-PATTERNS.md tenancy-model: single-tenant (line N)
```

A waiver that just says "single-tenant" is the GAP-2 failure mode in disguise (drive-by waiver). Auditable waivers reverse cleanly when the project moves to multi-tenant.

Do NOT waive D14 (feature flag) for a project's first multi-tenant feature without a written blast-radius assessment.

## On Failure

If any dimension is BLOCKED:

1. **Identify the owning agent** from the dimension's `Owner on fail` line:
   - Builder → D9, D15, D16
   - Database Engineer → D2, D9, D10
   - Security/Compliance → D8, D11, D12
   - SRE/DevOps → D3, D4, D5, D6, D13, D14, D17
   - QA → D16
   - CTO → D18
2. **Dispatch that agent** with a scoped fix prompt referencing the failed dimension (cite this skill's dimension number + the specific control ID or pattern citation).
3. **Re-run THIS skill from the failed dimension forward.** Do not declare DONE until all dimensions PASS or WAIVED with rationale.

This skill never returns DONE_WITH_CONCERNS for a CRITICAL dimension. **D2, D8, D10, D14 (when triggered) are BLOCKED-only** — there is no "we'll fix it post-deploy" option.

## Output Artifact

Produce `docs/audits/gate-3-<feature>.md` with one row per dimension:

```
| # | Dimension | Status | Evidence | Cited control IDs / pattern phase / runbook URL |
|---|---|---|---|---|
| D1 | Tenant isolation | PASS | tests/integration/multi-tenant.test.ts (ran 2026-04-30 14:23, exit 0, 4 assertions across 2 tenants) | OWASP API1:2023 BOLA; NIST AC-3 |
| D2 | RLS enforcement | PASS | migrations/2026_04_29_force_rls.sql; tests/db/policy-test.sql | NIST AC-3; PostgreSQL §5.9 |
| ... |
```

This artifact is the durable record. The CTO reads it at cycle end. The Post-Mortem agent reads it if a production incident traces to a Gate 3 dimension that should have caught the bug.

## Anti-Patterns

### Anti-Pattern: "All checks pass" — without per-dimension evidence

A blanket "all green" with no per-dimension evidence row is dishonesty. Each dimension carries its own evidence, command output, or control ID. The artifact format exists so that any auditor can reproduce the check.

### Anti-Pattern: "We waived D5 because the project doesn't use SLOs yet"

D5 (burn-rate alerts) presupposes D4 (SLO/SLI catalog). If you don't have SLOs, you BLOCK on D4 first. Cascading waivers without addressing the root dimension is a gate-bypass.

### Anti-Pattern: "The CI pipeline already runs lint and tests"

CI ran when the PR opened. Gate 3 requires fresh evidence in this session. Re-run, read the output, count the failures. CI green ≠ gate green.

### Anti-Pattern: "The migration is reversible because we kept the old column"

D10 requires phase classification AND rollback envelope AND data-loss disclosure if irreversible. Keeping a column is necessary but not sufficient — reversibility means the application can revert without data loss, not that one DB column was preserved.

### Anti-Pattern: "Single-tenant — D1/D2/D7 waived"

Drive-by waiver. Cite STACK-PATTERNS.md `tenancy-model: single-tenant` by path + line number, or BLOCK on D1.

## Red Flags

| Excuse | Reality |
|---|---|
| "All green" | Per-dimension evidence required. Show your work. |
| "Tests pass in CI" | Gate 3 requires fresh evidence in this session. Re-run. |
| "Burn-rate alerts will be added in a follow-up" | D5 follow-ups bypass the gate. BLOCK or fix now. |
| "Rollback procedure documented" | Documented ≠ rehearsed. D3 requires rehearsal log within 30 days. |
| "Single-tenant for now, will add multi-tenant later" | Cite STACK-PATTERNS line + plan the migration as a separate Tier 3 cycle. |
| "Performance was fine in dev" | D9 measures at scale targets, not dev data. |
| "Migration is forward-only, that's fine" | Forward-only requires Data-Loss Disclosure (D10). State it explicitly. |
| "We'll fix it post-deploy" | D2/D8/D10/D14 are BLOCKED-only. There is no post-deploy fix lane. |

## Quick Reference

- 18 dimensions; walk in order; TodoWrite per dimension.
- Iron Law: NO PRODUCTION-READY CLAIM WITHOUT FRESH GATE-3 EVIDENCE.
- Each dimension: PASS (with evidence) / WAIVED (with cited rationale) / BLOCKED (with fix dispatched).
- Multi-tenant waiver requires STACK-PATTERNS.md path + line citation.
- D2, D8, D10, D14 (when triggered) are BLOCKED-only.
- Output: `docs/audits/gate-3-<feature>.md` row-per-dimension table.
- Composable with `verification-before-completion`, `requesting-code-review`, `finishing-a-development-branch`, `seven-validation-questions` (plan-time sibling).

## Composability

- **Composable with `verification-before-completion`** — Gate 3 is the production-readiness specialization of the generic SP gate. The Iron Law inherits.
- **Composable with `requesting-code-review`** — code review must pass (Stage 1 spec compliance + Stage 2 code quality) before Gate 3 is invoked. Gate 3 picks up where review leaves off (deploy-readiness).
- **Composable with `finishing-a-development-branch`** — `finishing-a-branch` presents the merge/PR/keep/discard menu; Gate 3 must pass before any merge or PR option is taken.
- **Plan-time sibling: `seven-validation-questions`** — Q5 (failure mode) and Q6 (observability) are the plan-time mirror of Gate 3 dimensions D5/D6/D7/D13/D14 (operational) and D11/D12 (audit/PII). A plan that passes 7-questions feeds a build that passes Gate 3.
- **Invoked by `cto-mode` step 5.**

## Citations

**SP precedent (local cache, verbatim line-anchored):**

- `superpowers/5.0.7/skills/verification-before-completion/SKILL.md` lines 16–22 — Iron Law verbatim ("NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE")
- `superpowers/5.0.7/skills/verification-before-completion/SKILL.md` lines 26–38 — Gate Function (IDENTIFY / RUN / READ / VERIFY / ONLY THEN)
- `superpowers/5.0.7/skills/verification-before-completion/SKILL.md` lines 42–50 — Common Failures table
- `superpowers/5.0.7/skills/requesting-code-review/SKILL.md` lines 13–17 — mandatory-before-merge framing
- `superpowers/5.0.7/skills/finishing-a-development-branch/SKILL.md` lines 18–38 — pre-merge test verification
- `superpowers/5.0.7/skills/brainstorming/SKILL.md` lines 22–32 — TodoWrite-per-item discipline

**Anthropic guidance (per citation manifest §2.6, §2.7, §2.17):**

- *Building Effective AI Agents* — https://www.anthropic.com/research/building-effective-agents — "Maintain simplicity in your agent's design. Prioritize transparency by explicitly showing the agent's planning steps."
- *How we built our multi-agent research system* — https://www.anthropic.com/engineering/multi-agent-research-system — lead agent records plan in memory
- *Effective context engineering for AI agents* — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents — "save information from tool call results as artifacts" (D18)

**Enterprise PRR frameworks (≥6 named, ≥17 distinct sources):**

- **Google SRE Book** — Ch. 4 (SLOs), Ch. 6 (Monitoring Distributed Systems / golden signals / symptoms-vs-causes), Ch. 8 (Release Engineering / "Rollback early, rollback often"), Ch. 32 (Evolving SRE Engagement Model / PRR). https://sre.google/sre-book/
- **Google SRE Workbook** — Ch. 2 (don't pick SLO from current perf), Ch. 5 (multi-window multi-burn-rate alerting), Ch. 16 (Canarying Releases), Error Budget Policy. https://sre.google/workbook/
- **AWS Well-Architected Framework** — six pillars (Operational Excellence / Security / Reliability / Performance Efficiency / Cost Optimization / Sustainability) + Reliability REL10-BP03 (bulkhead). https://docs.aws.amazon.com/wellarchitected/latest/framework/
- **Microsoft Azure Well-Architected Review** — five pillars. https://learn.microsoft.com/en-us/azure/well-architected/
- **CNCF / Mercari Engineering production-readiness check** — https://engineering.mercari.com/en/blog/entry/20211213-engineering-production-readiness-check-at-mercari/
- **Twelve-Factor App** — III (Config), V (Build/release/run), IX (Disposability), X (Dev/prod parity), XI (Logs). https://12factor.net/
- **DORA Four Keys** — deploy frequency / lead time / change-failure rate / MTTR. https://dora.dev/guides/dora-metrics-four-keys/
- **OWASP ASVS v4** — V4 (Access Control), V7 (Logging), V8 (Data Protection). https://github.com/OWASP/ASVS
- **OWASP API Security Top 10 (2023)** — API1 BOLA, API3 BOPLA. https://owasp.org/API-Security/editions/2023/en/
- **NIST SP 800-53 Rev. 5** — AC-3, AC-4, AU-2, AU-3, AU-9, AU-11, SC-4, SC-8, SC-13, SC-28, SI-11, SI-12. https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r5.pdf
- **SOC 2 TSC 2017** — CC6.1, CC6.2, CC6.3, CC6.7, CC7.2, CC7.3.
- **Honeycomb** — Observability 101 + *OpenTelemetry Is Not Three Pillars*. https://www.honeycomb.io/blog/observability-101-terminology-and-concepts
- **Atlassian deployment checklist** — https://www.atlassian.com/incident-management/handbook/deployment-checklist
- **GitHub deployments documentation** — https://docs.github.com/en/actions/deployment/about-deployments

**Companion PF v2 research:**

- `docs/research/skill-design-gate-3-production-check.md` — full sources inventory + dimension table (K/N consensus)
- `docs/research/sp-anthropic-citation-manifest.md` (GAP-2 statement of the problem)
- `docs/research/agent-design-sre-devops.md` (Google SRE + AWS WAF + DORA + Honeycomb verbatim quotes)
- `docs/research/agent-design-security-compliance.md` (control IDs)
- `docs/research/agent-design-database-engineer.md` (RLS FORCE + migration phase)
- `templates/STACK-PATTERNS.template.md` (slot syntax for stack-conditional fields)

**PF v1 carry-forward:**

- `c:/Users/atyab/Experimental - Users/production-framework/core/gate-3.md` — original 7-section checklist; every line above maps to a v2 dimension (D1-D18 superset).

**Methodology disclosure:** Direct WebFetch was permission-denied for several Anthropic and enterprise URLs during research. Quotes from those sources were retrieved via WebSearch synthesis or were already vetted in companion research docs. Re-verify all quotes against canonical URLs before any binding architectural commitment.
