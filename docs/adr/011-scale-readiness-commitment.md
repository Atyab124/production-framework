# ADR-011 — Scale-Readiness Commitment (Tag + Project-Level Target + Roadmap-Visible Initiative)

**Status:** Proposed (Pass 3 of Pattern A; awaits Build cycle)
**Date:** 2026-05-12
**Author:** Atyab Rehman
**Producer-Consumer pass:** Researcher Pass 2 → Architect Pass 3 (this doc)
**Researcher inputs:**
- `docs/research/architecture-pre-recommendation-discipline-2026-05-12.md` (Lane R-2, Q2.3 + Q3.4)
- `docs/research/deferral-scheduling-scale-readiness-2026-05-12.md` (Lane R-3, Q3.3)

**Source feedback items addressed:** Item 9 (Architect defaults to incremental shipping; no scale-readiness commitment).

**Architecture doc reference:** `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (Clusters C2 + C3), §4 (Q2.3, Q3.3, Q3.4), §9 concerns.

---

## Context and Problem Statement

The TaskIt 2026-05-11 feedback log (Item 9) observed that the Architect's default recommendation shape is incremental: every plan ships the smallest atomic unit that produces a user-visible deliverable. When a project states scale targets — "support 100 concurrent tenants at 50 requests-per-second" — the Architect's incremental recommendations do not couple back to those targets. Scale-readiness foundation work (capacity planning, multi-region failover, RLS performance under N tenants, queue partitioning at expected throughput) is treated as deferral material rather than as a first-class plan-row category. The result: a project with stated scale targets ships features that, viewed individually, are tactical wins but, viewed at the scale target, leave the project unable to meet its commitments.

The framework needs (a) a project-level slot for scale targets, (b) a per-plan-row tag distinguishing tactical from scale-readiness work, (c) a pre-recommendation gate that the Architect uses to evaluate proposed plans against the targets, and (d) a roadmap-level communication surface so the scale-readiness commitment is visible to non-engineering stakeholders.

---

## Decision Drivers

1. **Project-stated targets must be machine-readable for the Architect.** Without a structured slot in `templates/PROJECT-PLAN.template.md`, the Architect relies on prose scanning of the spec — which empirically fails when the spec mentions targets but the plan-author does not.
2. **Tag granularity must be cheap.** A three-value enum (TACTICAL / SCALE-READINESS / UNCERTAIN) is the lowest-overhead tag set per Researcher Lane R-2 Q2.3 synthesis.
3. **Enterprise precedent is BINDING.** Researcher Q2.3 returned 5/5 unanimous on "scale-readiness is surfaced at planning, not folded into tactical feature delivery." Researcher Q3.3 returned 4/6 majority on "separate axis or budget for scale-readiness." Both findings reinforce a structured-tag approach over folding-into-impact.
4. **Stakeholder communication must compose.** Researcher Q3.4 returned 4/4 on "named theme/initiative/goal primitive exists for scale-readiness across roadmapping disciplines." The tag at plan-row level must compose into a roadmap-level theme.
5. **Pre-recommendation gate must be PRR-style left-shift.** Researcher Q2.3 cited Google's Production Readiness Review explicit migration from "review at end" to "engage at design" (the Early Engagement model). The Architect's gate must fire at design time, not at gate-3.

---

## Considered Options

### Option A — Fold scale-readiness into the existing Impact/Effort matrix (RICE/ICE style)

Keep the current plan-row schema. Add no new tag. Trust the Architect to weight scale-readiness work under the Impact axis.

- **Pros:** Zero new template surface. Trusts the orchestrator.
- **Cons:** Researcher Q3.3 explicitly disqualifies this for the question being asked: "RICE — Reach is users-per-time-period — would score 0 on Reach unless redefined… No — would score low on Impact unless redefined." 2 of 6 prioritization frameworks (RICE, ICE) fold scale-readiness into Impact and *acknowledge the known weakness*. This option ships the known weakness.
- **Status:** Neglected.

### Option B — Adopt WSJF's Risk-Reduction/Opportunity-Enablement axis as the scoring slot

Use SAFe's WSJF Risk-Reduction-and-Opportunity-Enablement component (one of three Cost-of-Delay components) as the scoring vocabulary for scale-readiness work.

- **Pros:** Closest direct-match enterprise precedent — Reinertsen designed the RR/OE component for exactly this case. Composes with the existing Scaled Agile vocabulary the framework already uses (Enabler in ADR-010).
- **Cons:** WSJF is a scoring model, not a tagging model. The framework needs a tag for binary classification at plan-row level, plus a separate roadmap-level theme. Pure WSJF scoring is overkill at row level.
- **Status:** Composed-with-Option-C-and-D rather than chosen alone. The WSJF RR/OE vocabulary is adopted as the *justification* slot for the SCALE-READINESS tag.

### Option C — Adopt AWS Well-Architected pillar-tag approach for plan rows + GitLab Reference Architectures for project-level target

Tag each plan row with one of `{ TACTICAL | SCALE-READINESS | UNCERTAIN }`. Add a project-level `scale_targets:` slot to `templates/PROJECT-PLAN.template.md` containing concrete numbers (concurrent users, RPS, tenants, storage). The Architect's pre-recommendation gate fires when stated targets exist but the proposed plan does not address them.

- **Pros:** 5/5 BINDING from Researcher Q2.3. Composes the strongest precedents — AWS pillar tag (Reliability / Performance Efficiency are two of six pillars), GitLab Reference Architectures (sized tiers with concrete RPS thresholds), and Google PRR Early-Engagement (gate fires at design, not at end).
- **Cons:** Adds two template surfaces (`scale_targets:` slot + tag column). Mitigated because both are tiny — one section + one column.
- **Status:** **Chosen.**

### Option D — Spotify-style separate capacity envelope

Reserve a fixed percentage of cycle capacity (~20%) for scale-readiness work; no tagging or per-row gate.

- **Pros:** Strongest budget guarantee. Researcher Q3.3 cited 4/6 majority including Spotify supporting "separate budget."
- **Cons:** The PF v2 cycle is work-shaped, not time-shaped. Spotify's 20% precedent was tagged secondary in the research (paraphrased by WebSearch rather than directly quoted). Adopting the budget alone without the tag still leaves the per-row classification gap.
- **Status:** Composed-with-Option-C — the capacity-floor structural check is inherited from ADR-010's cadence-floor rule, which is itself Spotify-shaped.

### Option E — Adopt Aha!-Initiative-named-for-a-theme as the roadmap-level primitive

Each PROJECT-PLAN wave gets a one-line theme using the Aha! convention (e.g., "Wave 3 — Multi-tenant scale-readiness foundation: support 100 concurrent tenants @ 50 RPS"); supplement with Pichler-style goal-with-metric for the success criterion.

- **Pros:** 4/4 BINDING from Researcher Q3.4 on "named theme/initiative/goal primitive exists." Stakeholder-visible by default.
- **Cons:** Standalone, does not solve the per-plan-row tagging gap.
- **Status:** **Composed with Option C** — the chosen decision combines C (per-row tag + project-level target + pre-recommendation gate) with E (wave-level theme for stakeholder communication).

---

## Decision Outcome

**Chosen:** Composite of **Option C (per-row tag + project target + PRR-style gate)** + **Option E (Aha!-style initiative theme at wave level)** + **WSJF RR/OE vocabulary for justification** + **Kano Must-Be language for stakeholder communication**.

Concrete shape:

1. **Project-level slot.** `templates/PROJECT-PLAN.template.md` gains a `scale_targets:` block at project root with concrete numbers (concurrent users, RPS, tenants, storage). Modelled on GitLab Reference Architectures — the scale tier IS the named target.

2. **Per-plan-row tag.** Every Tier-2 / Tier-3 plan row carries one of `{ TACTICAL | SCALE-READINESS | UNCERTAIN }`. Modelled on AWS Well-Architected pillar tag. Definitions:
   - `TACTICAL`: feature that ships without affecting the project's stated scale targets.
   - `SCALE-READINESS`: work whose primary justification is meeting the `scale_targets:` slot. Justification cites WSJF Risk-Reduction-or-Opportunity-Enablement vocabulary.
   - `UNCERTAIN`: needs investigation before tagging. Triggers Researcher dispatch if persistent.

3. **Pre-recommendation gate.** When a project has stated `scale_targets:` AND the proposed work does not address them, the Architect's recommendation must include either (a) a scale-readiness foundation item, OR (b) an explicit `DEFER-WITH-BLOCKER` per ADR-010 citing what would unblock it. Modelled on Google PRR Early-Engagement migration from "review at end" to "engage at design."

4. **Wave-level theme.** Each PROJECT-PLAN wave gains a one-line theme using the Aha! convention. Modelled on Aha! Initiatives + ProductPlan swimlane/legend + Pichler goal-with-metric. Example: `Wave 3 — Multi-tenant scale-readiness foundation: support 100 concurrent tenants @ 50 RPS`.

5. **Stakeholder-communication language.** When a SCALE-READINESS tag is presented to non-engineering stakeholders (e.g., in the CTO's wave-end summary), use Kano-Must-Be framing: "missing it makes customers very dissatisfied even though presence doesn't delight them." This is the stakeholder-facing translation of the WSJF RR/OE justification.

6. **Cadence-floor composition.** ADR-010's cadence-floor structural check applies: if N successive cycles ship without SCALE-READINESS work being promoted to active, the next cycle's plan MUST include a scale-readiness-review section. This is the Spotify-style budget guarantee, implemented as a structural check rather than a percentage allocation.

---

## Consequences

### Positive

- Project-stated scale targets are machine-readable; the Architect can evaluate plans against them without prose-scanning the spec.
- Per-row tagging surfaces scale-readiness work at the lowest grain (plan row) without forcing a separate planning track.
- Wave-level theme composition gives non-engineering stakeholders a visible commitment (Aha!-style); the CTO's wave-end summary becomes the stakeholder communication artifact (Pichler goal-with-metric format).
- Composes with ADR-010 (deferral-rigor) — capability-deferred scale-readiness items get `DEFER-WITH-BLOCKER` with a named scale-target gap.
- Composes with ADR-013 (pattern-enforcement-audit) — patterns that mitigate scale-readiness risk (e.g., RLS-indexing, tenant-partitioned cache) get `enforcement: structural-check` when their absence would breach the scale target.

### Negative

- Three template surfaces change (`scale_targets:` slot, per-row tag, wave-level theme). Ceremony cost is real; mitigated by tiny diffs.
- The framework defaults to requiring scale targets — projects without stated targets are unaffected, but the discipline is "you must declare them once" rather than "you may declare them." This is a knowing design choice.
- The WSJF + Aha! + Kano + GitLab composition is novel — no single enterprise framework prescribes this exact stack. The composition is grounded in 5/5 + 4/4 + 4/6 BINDING / majority precedents, but no single source endorses the full stack.

### Consequence path (what the ADR will eventually drive — NOT implemented here)

The downstream Build cycle implements:

- `templates/PROJECT-PLAN.template.md` — add `scale_targets:` slot + tag column + wave-theme convention.
- `agents/architect.md` — add the pre-recommendation gate (PRR Early-Engagement-style) to the intake checklist; add the scale-readiness-tag step.
- `skills/writing-plans/SKILL.md` — add the three-value tag to the plan-row schema.
- `skills/seven-validation-questions/SKILL.md` — add the scale-readiness-Q (count drift addressed under ADR-014).
- `skills/tier-selection/SKILL.md` — possibly add a `scale-readiness` axis trigger (per architecture doc §2 File List).
- `skills/cto-mode/SKILL.md` — add the wave-end stakeholder summary step (Pichler goal-with-metric format).

No source code is written by this ADR.

---

## Citations (verbatim, with re-verification flag)

All Researcher citations are tagged `(via WebSearch synthesis of canonical URL)` per Lane R-2 and Lane R-3 methodology disclosures (WebFetch was permission-denied throughout, except the AWS WAF Reliability welcome page which loaded directly). Re-verification before any Build-cycle code change is required.

1. **Google PRR — Early Engagement model (pre-recommendation gate precedent).** "There are three different but related engagement models (Simple PRR Model, Early Engagement Model, and Frameworks and SRE Platform), which address these limitations. With the Early Engagement model, SRE is involved early in the development process, which means SRE involves in the design, build, launch and post launch." — https://sre.google/sre-book/evolving-sre-engagement-model/ (Researcher Lane R-2 §Q2.3, verified 2026-05-12 via WebSearch synthesis).

2. **AWS Well-Architected Reliability pillar — pillar-tag precedent.** "The AWS Well-Architected Framework is based on six pillars: Operational Excellence, Security, Reliability, Performance Efficiency, Cost Optimization, Sustainability. This paper focuses on the reliability pillar and how to apply it to your solutions." — https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html (Researcher Lane R-2 §Q2.3, verified 2026-05-12 via direct WebFetch — the one URL that loaded).

3. **AWS Well-Architected Performance Efficiency — pillar-level distinction.** "The Performance Efficiency pillar includes the ability to use computing resources efficiently to meet system requirements, and to maintain that efficiency as demand changes and technologies evolve." — https://docs.aws.amazon.com/wellarchitected/latest/performance-efficiency-pillar/welcome.html (Researcher Lane R-2 §Q2.3, verified 2026-05-12 via WebSearch synthesis).

4. **Shopify BFCM — readiness as a distinct program-level scope.** "To handle expected traffic, Shopify rebuilt its BFCM readiness program from the ground up, involving thousands of engineers over nine months, five scale tests, and four days of peak commerce." — https://shopify.engineering/bfcm-readiness-2025 (Researcher Lane R-2 §Q2.3, verified 2026-05-12 via WebSearch synthesis).

5. **GitLab Reference Architectures — RPS-based sizing rubric (project-target precedent).** "The right architecture size depends primarily on your environment's expected peak load, with Requests per Second (RPS) being the primary metric for sizing a GitLab infrastructure." — https://docs.gitlab.com/administration/reference_architectures/sizing/ (Researcher Lane R-2 §Q2.3, verified 2026-05-12 via WebSearch synthesis).

6. **SAFe WSJF — Risk Reduction / Opportunity Enablement (scoring vocabulary precedent).** "Risk Reduction (RR) / opportunity enablement: enables new business opportunities or reduces the potential risks for present or near-future considerations." — https://framework.scaledagile.com/wsjf (Researcher Lane R-3 §Q3.3, verified 2026-05-12 via WebSearch synthesis).

7. **Aha! Initiatives — strategy-to-execution bridge (wave-theme precedent).** "Initiatives are the bridge between your strategy and work. They provide a framework to help you prioritize the right work — including releases, epics, and features — and give your team context for how their efforts contribute to the bigger picture." — https://www.aha.io/support/roadmaps/strategic-roadmaps/strategy/initiatives (Researcher Lane R-2 §Q3.4, verified 2026-05-12 via WebSearch synthesis).

8. **Aha! Initiatives — named for theme.** "Initiatives are named for a key theme of work needed to accomplish the goal, allowing teams to organize strategic efforts around meaningful themes." — https://www.aha.io (Researcher Lane R-2 §Q3.4, verified 2026-05-12 via WebSearch synthesis).

9. **Pichler GO Roadmap — goal+metric format for stakeholder summary.** "The roadmap consists of five elements: date, name, goal, features, and metrics. The most important element is the goal: It describes the outcome you want to achieve or the benefit you want to provide." — https://www.romanpichler.com/tools/the-go-product-roadmap/ (Researcher Lane R-2 §Q3.4, verified 2026-05-12 via WebSearch synthesis).

10. **Kano Must-Be — stakeholder-facing language precedent.** "Kano originally called these 'Must-be's' because they are the requirements that must be included and are the price of entry into a market. These are the requirements that the customers expect and are taken for granted. When done well, customers are just neutral, but when done poorly, customers are very dissatisfied." — https://asq.org/quality-resources/kano-model (Researcher Lane R-3 §Q3.3 citation 26, verified 2026-05-12 via WebSearch synthesis).

11. **Spotify ~20% engineering OKR capacity (acknowledged-but-secondary; informs cadence floor).** "Teams allocate approximately 20 percent of their team capacity to work against engineering OKRs for managing technical debt." — https://engineering.atspotify.com/2020/06/tech-migrations-the-spotify-way (Researcher Lane R-3 §Q3.3 citation 28, **tagged secondary** because paraphrased rather than directly quoted in the WebSearch result, verified 2026-05-12 via WebSearch synthesis).

---

## Re-verification disclosure

Per Researcher Lane R-2 §9 and Lane R-3 §"Methodology disclosure": WebFetch was permission-denied for all citations except AWS WAF Reliability welcome page. Every other quote above is via WebSearch synthesis of the canonical URL. The Build cycle MUST re-fetch each URL before committing the scale-targets-slot + tag-column code change. The Spotify 20% figure is tagged secondary and is informational only — treat as direction, not as binding percentage.

---

## More Information

- Architecture doc: `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (C2 + C3), §4 (Q2.3, Q3.3, Q3.4), §9 concerns.
- Researcher outputs: `docs/research/architecture-pre-recommendation-discipline-2026-05-12.md` §Q2.3, §Q3.4, §Citations; `docs/research/deferral-scheduling-scale-readiness-2026-05-12.md` §Q3.3, §Citations.
- Companion ADRs: `docs/adr/010-deferral-rigor-grammar.md` (capability-deferral / sequencing-deferral grammar), `docs/adr/017-dependency-inventory.md` (the pre-recommendation inventory step composes with the scale-readiness gate).
- Framework-internal precedent: `templates/PROJECT-PLAN.template.md` (target file for the `scale_targets:` slot); `skills/tier-selection/SKILL.md` (potential trigger axis); `skills/cto-mode/SKILL.md` (wave-end summary step).
