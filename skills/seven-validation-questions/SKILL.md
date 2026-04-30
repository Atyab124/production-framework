---
name: seven-validation-questions
description: "Use after a build plan is written and before any builder dispatch on Tier 2 or Tier 3 plans — the CTO/Deputy answers 7 validation questions against the plan and source files (not assumptions). A plan that cannot answer all 7 returns BLOCKED with the specific question and missing-evidence path."
---

## Overview

A pre-execution validation gate the CTO/Deputy runs against any Tier 2/3 plan before dispatching builders. The 7 questions are drawn from industry-standard design disciplines: Amazon Working Backwards, Google Design Docs, AWS Well-Architected, MADR, Y-Statement (Zimmermann), INVEST, Google SRE Launch Checklist + PRR + Reliable Releases.

| # | Question | Discipline | Strongest grounding |
|---|---|---|---|
| Q1 | **Why now?** | Trigger / cost-of-inaction | Amazon "so what?" + Google DD "Context and scope" + MADR "Context and Problem Statement" |
| Q2 | **Why this approach?** | Alternatives considered | SP `brainstorming` + Google DD "Alternatives Considered" + Y-Statement + MADR "Considered Options" |
| Q3 | **What invariants must hold?** | Pre/post conditions, multi-tenant boundaries | AWS WAF Reliability + Google DD "Cross-Cutting Concerns" + Google SRE PRR |
| Q4 | **What's the contract?** | Input/output/error shape | SP `writing-plans` + Anthropic ACI + INVEST + Google DD "Detailed Design" |
| Q5 | **What's the failure mode?** | Partial-failure semantics, blast radius | AWS WAF Reliability + Google SRE blast-radius + Lunney post-mortem categories |
| Q6 | **How is it observed?** | Logs / metrics / traces / alerts | AWS WAF Operational Excellence + Google SRE Launch Checklist + Google DD Cross-Cutting |
| Q7 | **How is it reverted?** | Rollback, cleanup, feature-flag exit | SP `finishing-a-development-branch` + Google SRE "Rollback early" + Y-Statement `accepting that:` |

This skill is the **plan-time** sibling of `gate-3-production-check`'s **ship-time** gate — same disciplines, applied earlier, on a plan rather than on the built code.

<HARD-GATE>
Do NOT dispatch builders if any of the 7 questions returns BLOCKED. Answers must cite evidence from a file the CTO/Deputy has read in this session — file path + line range or section heading. Answering from memory or intuition invalidates the answer. A plan that cannot answer all 7 returns `BLOCKED` with the specific question number and the missing-evidence path.
</HARD-GATE>

## When to Use

- After `writing-plans` produces a Tier 2 or Tier 3 plan, BEFORE any `builder` dispatch.
- After `writing-arch-doc` for a Tier 3 plan, BEFORE the architecture is locked.
- When a build cycle resumes mid-stream — re-validate before re-dispatching.

Do NOT use for Tier 1 work (typo, single-line config, comment edits) — the gate's overhead exceeds the work's blast radius.

## Core Pattern

You MUST create a TodoWrite item per question and complete them in order. Each answer cites evidence; "from memory" is not an answer.

### Q1 — Why now?

**Purpose:** what triggered this work; what's the cost of not doing it.

**Required evidence:** the plan's `Goal:` line + the trigger (incident, customer ask, gate-3 failure, deadline). For Tier 3, the architecture doc's "Context and scope" section.

**Format:** apply Amazon's "so what?" filter. If the answer is "the team felt like building it," BLOCKED.

**Anti-Pattern:** "We've been meaning to do this for a while." Vague intent without a trigger fails Q1. Either name the trigger or defer the work.

### Q2 — Why this approach?

**Purpose:** what alternatives were considered and rejected.

**Required evidence:** either (a) `docs/research/<topic>.md` produced by `enterprise-research-first` with consensus strength, or (b) an inline "Alternatives Considered" section in the plan with ≥2 rejected options.

**Format — Y-Statement (Zimmermann SATURN 2012):**

> In context **{X}**, facing **{Y}**, we decided **{Z}**, neglecting alternatives **{A, B}**, to achieve **{Q}**, accepting that **{D}**.

This compresses two questions (Q1 trigger + Q2 alternatives) into one disciplined sentence. Use it in the plan's Decision Record entry.

**Anti-Pattern:** "It's the standard way." Standard for whom? Cite either consensus-from-research or alternatives-considered. "Standard" without a citation is not an answer.

### Q3 — What invariants must hold?

**Purpose:** pre-conditions, post-conditions, multi-tenant boundaries, cross-cutting concerns that must remain true through the change.

**Required evidence:** the architecture doc's "Quality Attribute Matrix" or "Cross-Cutting Concerns" section. For multi-tenant projects, an explicit row stating tenant isolation is preserved at the data layer (RLS / `tenant_id` filter / scope chain).

**Minimum invariant checklist (always applicable):**
- Authentication: which routes require it; what session shape
- Authorization: which roles are checked at which layer **AND name the client shape that activates the check** (per Wave 3 Pattern 4 — closes Audit Item 9 G-CRIT-1)
- Multi-tenancy: tenant scope enforced at the data layer (cite STACK-PATTERNS multi-tenant section)
- Data integrity: foreign keys, unique constraints, transactional boundaries
- Backwards compatibility: which API consumers must continue working
- Observability: which fields must remain on every log/trace (e.g., `tenant_id`, `request_id`)

**Client-shape naming (added 2026-04-30 per Wave 3 R-3):**

For every authorization invariant, name BOTH:

1. **The auth model** — RLS / RBAC / capability-based / explicit-tenant-filter / etc.
2. **The client shape that activates the model** — name the import path + client constructor:
   - **User-scoped JWT** → RLS applies (e.g., Supabase user-scoped client)
   - **Service-role + manual filter** → RLS bypassed; explicit `WHERE tenant_id = $X` required (e.g., Supabase admin client; PostgreSQL FORCE ROW LEVEL SECURITY)
   - **RPC with explicit `p_user_id`** → `SECURITY DEFINER` function with manual visibility check inside

A row that names "RLS applies" without naming the client shape is incomplete. Item 9 (PF v1 G-CRIT-1) shipped because the arch doc said `SECURITY INVOKER` but implementation used `supabaseAdmin` (RLS bypassed). Q3 must catch this at design-time, not Gate 3 at ship-time.

**Anti-Pattern:** "The tests will catch any regressions." Tests catch what they cover. Q3 is the explicit list of what MUST not break — required so the regression scope can verify each item.

### Q4 — What's the contract?

**Purpose:** input shape, output shape, error shape — for every public surface the plan changes.

**Required evidence:** the plan's task list with exact file paths + exact code blocks (per SP `writing-plans` lines 67–80). For each new or changed function, schema, route, or message:
- **Input:** typed shape, validated at the boundary
- **Output:** typed shape, including success and partial-success cases
- **Error:** typed shape — error envelope, status code, retry semantics

"JSON object" or "string" is not an answer. Cite types, schemas, or interface declarations.

> "Is it obvious how to use this tool, based on the description and parameters, or would you need to think carefully about it? If so, then it's probably also true for the model. A good tool definition often includes example usage, edge cases, input format requirements, and clear boundaries from other tools."
> — Anthropic, *Building Effective AI Agents* (https://www.anthropic.com/research/building-effective-agents)

**Anti-Pattern:** the `clearLayers()` vs `clearFullLayers()` failure mode (SP `writing-plans` line 130). A function called `X()` in Task 3 but `Xy()` in Task 7 is a contract bug — Q4 catches it before dispatch.

### Q5 — What's the failure mode?

**Purpose:** partial-failure semantics, blast radius, what breaks for whom when the change goes wrong.

**Required evidence:** the architecture doc's failure-mode table OR the SRE/DevOps runbook draft. For each failure mode:
- **Trigger:** what causes it
- **Blast radius:** which tenants / users / dependencies are affected
- **Detection:** which alert or metric fires (forward-link to Q6)
- **Mitigation:** rollback, kill-switch, manual intervention

> "Automatically recover from failure by setting and monitoring workload KPIs and triggering automation when a threshold is breached. Test recovery procedures using automation to simulate or recreate scenarios that lead to failure."
> — *AWS Well-Architected: Reliability Pillar*

> "In order to reduce the blast radius of outages, avoid global changes and adopt advanced deployments strategies that allow you to gradually deploy changes."
> — *Google SRE: Reliable Releases and Rollbacks*

PF v2 imports the failure-mode discipline from AWS Well-Architected and Google SRE. SP's discipline ends at unit/integration test verification; Anthropic publishes no service-telemetry guidance. We extend the boundary explicitly.

**Anti-Pattern:** "If it breaks, we'll roll back." Without a named failure mode, you cannot confirm a rollback is sufficient — some failure modes (data corruption, leaked tenant data) are not rollback-recoverable.

### Q6 — How is it observed?

**Purpose:** which logs, metrics, traces, and alerts surface the change's behaviour in production.

**Required evidence:** the SRE/DevOps runbook draft listing:
- **Logs:** which fields are added; tenant_id present (multi-tenant)
- **Metrics / SLIs:** which gauges/counters are added; cardinality budget declared
- **Traces:** which spans are added
- **Alerts:** burn-rate windows; runbook URL per alert

> "How do you design your workload so that you can understand its state? Design your workload so that it provides the information necessary for you to understand its internal state (for example, metrics, logs, and traces) across all components."
> — *AWS Well-Architected: Operational Excellence Pillar*

> "Set up monitoring for your new service."
> — *Google SRE Launch Checklist* (https://sre.google/sre-book/launch-checklist/)

**Anti-Pattern:** "We'll add observability after the feature works." Observability gaps shipped to prod become observability gaps that block the next post-mortem. Wire it in the plan or BLOCKED.

### Q7 — How is it reverted?

**Purpose:** rollback path, cleanup, feature-flag exit, data migration reversal.

**Required evidence:**
- **Rollback runbook:** named in the plan
- **Feature flag (if blast radius is broad):** flag name + owner + kill-switch tested
- **Migration reversal:** if a schema migration is involved — phase pattern (expand → backfill → cutover → contract); if irreversible, an explicit Data-Loss Disclosure (cite Database Engineer agent's HARD-GATE shape)

> "If unexpected behavior is detected, roll back first and diagnose afterward in order to minimize Mean Time to Recovery."
> — *Google SRE: Reliable Releases and Rollbacks*

The Y-Statement `accepting that: {D}` clause forces the cost of revert to be named alongside the cost of adoption.

**Anti-Pattern:** "It's a small change, no flag needed." If the change crosses a tenant, a service boundary, or a data layer, the blast radius is not small. Either declare a flag or document why it isn't needed.

## Status Token Output

The skill terminates with one of four status tokens (matching SP `subagent-driven-development` lines 102–118 and the framework's `agent-return-parse` hook contract):

- **`DONE`** — all 7 questions answered with cited evidence; dispatch builders.
- **`DONE_WITH_CONCERNS`** — 7/7 answered, but ≥1 answer is weak or relies on an unverified assumption. Dispatch with caveats logged in the cycle state file.
- **`NEEDS_CONTEXT`** — 1+ answer requires information not yet in the plan or arch doc; the CTO is asked to retrieve it.
- **`BLOCKED`** — 1+ question cannot be answered. Output: `BLOCKED — Q<n>: <missing-evidence-path>`. Do not dispatch.

## Red Flags

| Excuse | Reality |
|---|---|
| "I know the answer, I don't need to read the file" | Answering from memory invalidates the answer. Cite evidence or BLOCKED. |
| "Q5/Q6 are SRE concerns, not plan concerns" | Failure-mode + observability are design-time questions per AWS WAF + Google SRE. Plan-time skipping → ship-time outage. |
| "It's a small change, the questions are overkill" | Tier 1 is the right call for small changes — and Tier 1 doesn't trigger this skill. If it triggered, it's not small. |
| "The tests cover Q3" | Tests cover what they cover. Q3 is the explicit invariant list — required so regression scope can verify each. |
| "We'll write the runbook after deploy" | Runbook-after-deploy means the first incident has no runbook. Wire it in the plan. |
| "Y-Statement is overhead" | Y-Statement compresses Q1+Q2 into one sentence. It is the opposite of overhead. |

## Quick Reference

- 7 questions, every answer cites evidence (file path + section).
- Q1+Q2 ⇒ Y-Statement format.
- Q3 ⇒ multi-tenant invariant must be stated explicitly if the project is multi-tenant.
- Q4 ⇒ types/schemas, not "object."
- Q5 ⇒ named failure modes, not "if it breaks."
- Q6 ⇒ wire observability before deploy, not after.
- Q7 ⇒ rollback path or feature-flag, named explicitly.
- Tier 1 → skip this skill.
- BLOCKED on ≥1 question → do not dispatch builders.

## Composability

- **Plan-time sibling of `gate-3-production-check`** — same disciplines, applied at plan-time vs ship-time. Cross-link both: a plan that passes 7-questions feeds a build that walks gate-3.
- **Consumes** `enterprise-research-first` output for Q2 (alternatives considered).
- **Consumes** `writing-plans` output (the plan being validated) and `writing-arch-doc` output (for Tier 3 invariants and failure modes).
- **Invoked by** `cto-mode` between step 2 (plan write) and step 3 (dispatch).

## Citations

**SP precedent (local cache, verbatim line-anchored):**

- `superpowers/5.0.7/skills/brainstorming/SKILL.md` lines 80–84, 142 — "Propose 2-3 different approaches with trade-offs"; "Always propose 2-3 approaches before settling" (Q2 grounding)
- `superpowers/5.0.7/skills/writing-plans/SKILL.md` lines 65–80, 113–115, 130 — task structure / no-placeholder rule / type-consistency self-review (Q4 grounding)
- `superpowers/5.0.7/skills/verification-before-completion/SKILL.md` lines 84, 96–98 — red-green revert drill / re-read-plan checklist (Q7 + Q3 adjacencies)
- `superpowers/5.0.7/skills/subagent-driven-development/SKILL.md` lines 102–118 — status token grammar
- `superpowers/5.0.7/skills/subagent-driven-development/spec-reviewer-prompt.md` lines 41–48 — "missing requirements / misunderstandings" frame (Q3 adjacency)
- `superpowers/5.0.7/skills/finishing-a-development-branch/SKILL.md` lines 18–63 — exit options + test-pass gate (Q7 grounding)

**Anthropic guidance (verified 2026-04-30; re-verify with WebFetch in a permitted session before binding decisions):**

- *Building Effective AI Agents* — https://www.anthropic.com/research/building-effective-agents — ACI discipline (Q4); "increase complexity only when it demonstrably improves outcomes"
- *Effective context engineering for AI agents* — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents — invariants vocabulary

**Enterprise / OSS sources (per question):**

- **Q1 — Amazon Working Backwards PR/FAQ** — https://workingbackwards.com/concepts/working-backwards-pr-faq-process/ ("so what?" filter)
- **Q1, Q3, Q6 — Google Design Docs at Google** — https://www.industrialempathy.com/posts/design-docs-at-google/ (Context/scope, Cross-Cutting Concerns)
- **Q1, Q2 — MADR** — https://adr.github.io/madr/ (Context and Problem Statement; Considered Options)
- **Q2 + Q7 — Y-Statement (Zimmermann SATURN 2012)** — https://medium.com/olzzio/y-statements-10eb07b5a177
- **Q3, Q5 — AWS Well-Architected (Reliability + Operational Excellence)** — https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html
- **Q3, Q5 — Google SRE PRR** — https://sre.google/sre-book/evolving-sre-engagement-model/
- **Q4 — INVEST** — https://en.wikipedia.org/wiki/INVEST_(mnemonic) (Testable, Valuable, Independent)
- **Q5, Q7 — Google SRE Reliable Releases and Rollbacks** — https://cloud.google.com/blog/products/gcp/reliable-releases-and-rollbacks-cre-life-lessons
- **Q5 — Lunney USENIX 2017** — https://www.usenix.org/system/files/login/articles/login_spring17_09_lunney.pdf (Mitigate / Detect / Prevent action-item taxonomy)
- **Q6 — Google SRE Launch Checklist** — https://sre.google/sre-book/launch-checklist/

**Companion PF v2 research:**

- `docs/research/skill-design-seven-validation-questions.md` — full sources inventory + per-question analog table
- `docs/research/sp-anthropic-citation-manifest.md` — binding-rule grounding
- `docs/research/agent-design-post-mortem.md` — Lunney USENIX 2017 categorization

**Methodology disclosure:** Anthropic and external quotes were retrieved via WebSearch synthesis of canonical URLs (WebFetch was permission-denied during research). Re-verify against live URLs before binding architectural decisions.

**Note on PF v1 lineage:** PF v1 had a different 7-question set (Simplest approach? / Pattern match? / Enterprise consensus? / Rule count? / Per-item auth? / Sibling data flow? / Performance at scale?). v2 deliberately replaces those PF-internal heuristics with industry-standard disciplines that align with SP, Anthropic, and enterprise OSS analogs. The v1 evidence-grounding rule ("answer against EVIDENCE, not memory or intuition") is carried forward verbatim.
