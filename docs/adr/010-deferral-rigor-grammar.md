# ADR-010 — Deferral Rigor Grammar (DEFER-WITH-BLOCKER vs SCHEDULED-LATER)

**Status:** Proposed (Pass 3 of Pattern A; awaits Build cycle)
**Date:** 2026-05-12
**Author:** Atyab Rehman
**Producer-Consumer pass:** Researcher Pass 2 → Architect Pass 3 (this doc)
**Researcher inputs:**
- `docs/research/deferral-scheduling-scale-readiness-2026-05-12.md` (Lane R-3, Q3.1 + Q3.2)
- `docs/research/research-methodology-framing-2026-05-12.md` (Lane R-1, Q1.2 — Goals/Non-Goals discipline)

**Source feedback items addressed:** Item 7 (deferral classifications lack required justification) and the cross-cluster overlap with Item 9 (scale-readiness-as-deferral case — the scale-target-driven half lives in ADR-011; the bucket-grammar half lives here).

**Architecture doc reference:** `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (Cluster C3) and §7 (open question Q3.1, Q3.2).

---

## Context and Problem Statement

The framework currently allows three deferral disposition tokens — `DEFER`, `opportunistic`, `future` — to be used interchangeably as plan-row annotations. The TaskIt 2026-05-11 feedback log (Item 7) observed that this token set acts as default-procrastination grammar: a row labelled `DEFER` carries no named blocker, no eligibility criterion for re-ingestion, and no distinction between "deferred because we lack a capability" vs "deferred because it sits behind another sequence." When the orchestrator dispatches an AI sub-agent against an ambiguous backlog, the absence of a named justification means deferrals propagate without ever surfacing the *reason* — the rationalization risk the framework itself was built to counter.

The framework needs a controlled-vocabulary bucket grammar so that every deferral declares (a) the reason class, (b) the named blocker or sequencing dependency, and (c) the eligibility criterion for re-ingestion. The grammar must be cheap to author (one tag + one sentence), composable with the existing `seven-validation-questions` skill, and grounded in enterprise precedent — not invented from thin air.

---

## Decision Drivers

1. **AI-orchestrator context risk.** Human Product Owners exercise discretion within a single ordered backlog; an AI orchestrator without a controlled vocabulary will rationalize "out of scope" as the default reason. The grammar must replace discretion with a named justification.
2. **Composability with the existing skill cascade.** The bucket grammar must drop into `skills/writing-plans/SKILL.md` and `agents/architect.md` without forcing a new agent. The CLAUDE.md binding rule (this repo) requires either SP precedent OR enterprise citation per skill change.
3. **Enterprise precedent split.** Researcher Q3.1 returned 2/4 explicit (SAFe Enabler, Atlassian DoR) vs 2/4 discretionary (Scrum Guide, LeSS). The split is not BINDING per `enterprise-research-first` (N/N at N≥5 grammar). The architect chooses which model fits PF v2.
4. **Cadence floor must accompany the bucket.** Researcher Q3.2 returned 4/4 BINDING that *some* structured cadence is required to prevent deferrals from accumulating unacknowledged. A bucket grammar without a cadence floor is just relabelling.

---

## Considered Options

### Option A — Adopt the Scrum/LeSS "single ordered backlog + PO discretion" model

The Product Backlog is a single ordered list; deferral is just lower order; no named-blocker requirement. Cheap, low-ceremony, trusts the orchestrator's judgment.

- **Pros:** Lowest overhead. Aligned with 2 of 4 frameworks cited (Scrum Guide 2020, LeSS).
- **Cons:** Researcher Q3.1 synthesis explicitly flags the failure mode for AI orchestrators: "the Scrum Guide / LeSS 'PO discretion' model assumes a human PO is exercising judgment; PF v2's deferrals are exercised by an AI orchestrator inside a 13-agent dispatch, where the rationalization risk that motivated the entire `enterprise-research-first` skill (training-data-justified shortcuts) replays here" (Lane R-3 §Q3.1 recommendation).
- **Status:** Neglected.

### Option B — Adopt the SAFe Enabler + Atlassian DoR model (named-justification required)

Every deferred plan row carries one of two tags. `DEFER-WITH-BLOCKER` requires a named runway-gap (capability-deferral, SAFe Enabler precedent). `SCHEDULED-LATER` requires a named next-iteration target (sequencing-deferral, Scrum-style ordering). Both require the same one-line justification format.

- **Pros:** Replaces discretion with controlled vocabulary. SAFe Enabler is the closest enterprise precedent to PF v2's scale-readiness foundation case (Item 9 overlap). Atlassian DoR is the cheapest mechanical implementation — a fixed list of allowable defer-reasons.
- **Cons:** Two tokens add ceremony cost over single-token deferral. Mitigated because the existing seven-validation-questions skill already enforces fixed-list grammar.
- **Status:** **Chosen.**

### Option C — Adopt the DORA "small-batch, no batched cleanup" model

Reject batched cleanup outright; debt is repaid via continuous small-batch trunk integration. No deferral bucket at all — every plan row ships in the current cycle or is killed.

- **Pros:** Strongest discipline; eliminates deferral as a category.
- **Cons:** Mismatch with PF v2's empirical reality (single-project validation at N<3 means many candidate fixes are honest-deferrals waiting for project signal). Deletes the bucket rather than disciplining it.
- **Status:** Neglected; the DORA principle informs ADR-011's continuous-debt-paydown layer instead.

### Option D — Spotify-style separate capacity envelope (~20% reserved)

Allocate a fixed cycle-percentage to enabler/cleanup work; deferral is not a bucket but a budget line.

- **Pros:** Solves the "deferrals accumulate" failure mode by reserving budget.
- **Cons:** The PF v2 cycle is not a calendar-time allocation; cycles are work-shaped, not time-shaped. Spotify's 20% precedent is also tagged secondary in the research (the WebSearch summary paraphrased the Spotify blog rather than directly quoting).
- **Status:** Composed-with-Option-B rather than chosen alone — the capacity-floor structural check in ADR-011 inherits the Spotify shape.

---

## Decision Outcome

**Chosen:** **Option B** — adopt the SAFe Enabler + Atlassian DoR model. Plan-row deferrals must use exactly one of two tags:

| Tag | Class | Required field | Eligibility criterion |
|---|---|---|---|
| `DEFER-WITH-BLOCKER: <named-blocker>` | Capability-deferral (SAFe Enabler precedent) | One-line blocker description — what's missing, what would unblock it | When the blocker resolves (e.g., "when N≥3 project signal is collected per F-V14") |
| `SCHEDULED-LATER: <next-target>` | Sequencing-deferral (Scrum ordering precedent) | One-line target — which cycle / wave / release picks it up | When the named target arrives |

Bare `DEFER`, `opportunistic`, and `future` are deprecated. The existing `seven-validation-questions` skill gains a new Q (the "deferral-blocker" question flagged in §2 of the architecture doc) that fires DONE_WITH_CONCERNS if any plan row uses the deprecated grammar without the named field.

**Cadence floor (composes with the bucket).** Per Researcher Q3.2's 4/4 BINDING finding that structured cadence is required, the framework adds a structural check: if N successive cycles have shipped without any plan row tagged either `DEFER-WITH-BLOCKER` or `SCHEDULED-LATER` being re-promoted to active work, the next cycle's plan MUST surface a deferral-review section. This is the framework's structural-check analogue of Google SRE's 50% toil cap — applied not as a percentage of LOC but as a structural-check-fires-after-N-cycles rule. The exact value of N is left to the Build cycle; the Architect recommends N=3 (matches the framework's own Rule-of-Three N≥3 threshold for pattern promotion).

---

## Consequences

### Positive

- Every deferred row carries a named justification — replaces discretion with controlled vocabulary, which is the precise discipline the framework's `enterprise-research-first` skill was built to enforce at the research layer.
- Composes with ADR-011 (scale-readiness commitment) — capability-deferrals tagged for scale-readiness reasons consume ADR-011's `scale_targets:` slot.
- Composes with the existing `seven-validation-questions` fixed-list grammar — no new skill body required; one new Q added.
- Aligned with 2/4 explicit enterprise precedent (SAFe + Atlassian) and acknowledges 2/4 discretionary precedent (Scrum + LeSS) as a knowing departure.

### Negative

- Slight ceremony cost at plan-authoring time (one tag + one sentence per deferred row). Mitigated because the framework already enforces fixed-list grammar in `seven-validation-questions`.
- The N=3 cadence-floor threshold is a defensible-but-not-cited number. The Researcher's evidence supports "structured cadence is required" (4/4 BINDING) but does not prescribe a specific N. The Build cycle should pressure-test N=3 against an eval set per the architecture doc §9 concern.
- The framework departs from Scrum Guide 2020 / LeSS PO-discretion model. This is a knowing departure, grounded in the AI-orchestrator context risk.

### Consequence path (what the ADR will eventually drive — NOT implemented here)

The downstream Build cycle implements:

- `skills/writing-plans/SKILL.md` — add the two-tag bucket grammar to the plan-row schema.
- `skills/seven-validation-questions/SKILL.md` — add the new deferral-blocker Q (count drift addressed under ADR-014's "fixed-vs-open list" decision).
- `agents/architect.md` — add a "deferral classification" step to the intake checklist.
- `templates/PROJECT-PLAN.template.md` — add a "Deferred Work" section with the bucket grammar.

No source code is written by this ADR.

---

## Citations (verbatim, with re-verification flag)

All Researcher citations are tagged `(via WebSearch synthesis of canonical URL)` per the Lane R-3 methodology disclosure (WebFetch was permission-denied throughout). The canonical URL is named for every quote so the Build cycle can re-verify against the live page before any binding implementation lands. Per CLAUDE.md citation discipline, re-verification is required before any source-code change.

1. **SAFe — Enabler definition.** "Enablers are backlog items that extend the architectural runway of the solution under development or improve the performance of the development value stream." — https://framework.scaledagile.com/enablers/ (Researcher Lane R-3 citation 5, verified 2026-05-12 via WebSearch synthesis of canonical URL).

2. **SAFe — runway-investment commitment.** "If technical debt accrues, the Agile Release Train (ART) will be impeded, requiring the Product Manager and Solution Management to allocate sufficient capacity in subsequent PIs to build up the runway." — https://framework.scaledagile.com/architectural-runway (Researcher Lane R-3 citation 6, verified 2026-05-12 via WebSearch synthesis).

3. **Atlassian Agile Coach — Definition of Ready.** "A definition of ready (DoR) is an agreed-upon set of criteria to indicate whether a backlog item is ready for the team to work on. The DoR ensures the team understands what the work entails and can estimate the time needed for it to get done." — https://www.atlassian.com/agile/project-management/definition-of-ready (Researcher Lane R-3 citation 7, verified 2026-05-12 via WebSearch synthesis).

4. **Atlassian Agile Coach — DoR checklist examples (named blockers).** "More specifically, the checklist could include items such as 'Has no dependencies,' or 'Has defined acceptance criteria'." — https://www.atlassian.com/agile/project-management/definition-of-ready (Researcher Lane R-3 citation 8, verified 2026-05-12 via WebSearch synthesis).

5. **Google SRE — 50% engineering floor (cadence-floor precedent).** "Google's SRE organization has an advertised goal of keeping operational work (i.e., toil) below 50% of each SRE's time, with at least 50% of each SRE's time being spent on engineering project work that will either reduce future toil or add service features." — https://sre.google/sre-book/eliminating-toil/ (Researcher Lane R-3 citation 9, verified 2026-05-12 via WebSearch synthesis).

6. **Scrum Guide 2020 — Order influenced by named factors (acknowledged precedent for the neglected option A).** "The order of the Product Backlog will be influenced by such things as dependencies, efficient use of materials, availability of third parties and building codes." — https://scrumguides.org/scrum-guide.html (Researcher Lane R-3 citation 2, verified 2026-05-12 via WebSearch synthesis).

7. **DORA — technical debt as flow blocker (acknowledged precedent for the neglected option C).** "A large amount of technical debt blocks progress, and as teams come out of the J-curve, technical debt and increased complexity cause additional manual controls and layers of process around changes, slowing work." — https://dora.dev/capabilities/working-in-small-batches/ (Researcher Lane R-3 citation 15, verified 2026-05-12 via WebSearch synthesis).

---

## Re-verification disclosure

Per Researcher Lane R-3 §"Methodology disclosure": WebFetch was permission-denied throughout the lane. Every citation above is via WebSearch synthesis of the canonical URL. The Build cycle that implements this ADR MUST re-fetch each URL via direct WebFetch (or by the user manually verifying) before committing the bucket-grammar code change. If any quote fails to re-verify, the Architect (Pass 3) must be re-dispatched to refresh the citation list.

---

## More Information

- Architecture doc: `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (C3 cluster), §4 (Q3.1–Q3.2), §7 (Lane R-3 dispatch).
- Researcher output: `docs/research/deferral-scheduling-scale-readiness-2026-05-12.md` §Q3.1, §Q3.2, §Citations.
- Companion ADR: `docs/adr/011-scale-readiness-commitment.md` (the scale-targets half of Item 9 lives there).
- Framework-internal precedent: `skills/seven-validation-questions/SKILL.md` (fixed-list grammar that the new deferral-Q composes into) and `skills/proposing-patterns/SKILL.md` Path A (N≥3 threshold matches the Rule-of-Three cadence-floor rationale).
