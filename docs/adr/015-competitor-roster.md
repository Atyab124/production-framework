# ADR-015 — Competitor Roster Artifact (Project-Level `docs/COMPETITORS.md`)

**Status:** Proposed (Pass 3 of Pattern A; awaits Build cycle)
**Date:** 2026-05-12
**Authors:** Production-framework Architect sub-agent (Opus 4.7), Pass 3 consolidation
**Producer-Consumer pass:** Researcher Pass 2 → Architect Pass 3 (this doc)
**Researcher inputs:**
- `docs/research/research-methodology-framing-2026-05-12.md` (Lane R-1, Q1.1 — competitor-roster artifact / mandatory inclusion, Q1.4 — comparable-set ratification)

**Source feedback items addressed:** Item 1 (Research-cycle scoping omitted direct competitors) and Item 6 (Researcher does not push back on prompt framing) — Item 6's competitor-coverage half lives here; the spectrum-vs-binary half lives in ADR-014.

**Architecture doc reference:** `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (Cluster C1), §4 (Q1.1, Q1.4), §7 (Lane R-1 dispatch).

---

## Context and Problem Statement

The TaskIt 2026-05-11 feedback log (Item 1) observed that the Researcher executes the comparable set named in the dispatch verbatim. When the orchestrator dispatches a research question without naming direct competitors, the Researcher does not push back; the resulting research passes the framework's enterprise-research-first BINDING grammar (≥3 enterprise/OSS citations) while *missing the actual competitive landscape*. The output is technically valid but practically misleading.

The framework needs (a) a project-level artifact that names the direct competitors, (b) a ratification mechanism so the comparable set has a named owner who ratifies it independently of the Researcher who consumes it, and (c) a positive-exclusion discipline so future researchers see why a "natural-looking" comparator was *not* included.

---

## Decision Drivers

1. **4/5 BINDING precedent on mandatory-roster (Researcher Q1.1).** PRISMA, Forrester Wave, Gartner Magic Quadrant, IDC MarketScape all treat named-roster definition as a mandatory gating step performed by a named owner before evaluation begins. The outlier (ThoughtWorks Tech Radar) uses emergent TAB voting — still a structured mechanism, just a different shape.
2. **5/5 BINDING precedent on two-role ratification (Researcher Q1.4).** Forrester (analyst + research director), Gartner (proposal → internal review), IDC (segment-defined criteria), CNCF (community submissions + TOC), ThoughtWorks (TAB vote) — every named framework requires a second role to ratify the comparable set; self-attestation is never terminal.
3. **PRISMA positive-exclusion discipline.** PRISMA 2020 Item 5 + the "studies that might appear to meet inclusion criteria but were excluded" rule — the strongest discipline for surfacing why a natural-looking comparator was skipped.
4. **The CTO → Researcher pair maps cleanly onto Forrester's analyst → research-director pair.** The framework already has the two-role dispatch shape; ADR-015 codifies the artifact that the pair ratifies together.

---

## Considered Options

### Option A — Leave the framework as-is; trust the Researcher to surface missing comparators

Status quo. The Researcher's intake step does not check for a competitor roster.

- **Pros:** Zero new artifact surface.
- **Cons:** Reproduces Item 1 exactly. The Researcher cannot push back on a comparable set that has no named ground-truth to push back against.
- **Status:** Neglected.

### Option B — Add a one-line "list direct competitors" sentence to the Researcher dispatch envelope

Minimal change. The dispatch envelope at `agents/researcher.md` lines 199-208 (per architecture doc citation) gains a "named direct competitors" field.

- **Pros:** Lowest overhead.
- **Cons:** Per-dispatch field is not the same as a project-level artifact. Direct competitors are a persistent property of the project, not a per-dispatch variable. Researcher Q1.1 finding (4/5 BINDING) was specifically that the roster is a project/market-segment artifact, refreshed per cycle, not regenerated per dispatch.
- **Status:** Neglected.

### Option C — Create a project-level `docs/COMPETITORS.md` roster artifact, owned by CTO orchestrator, refreshed per cycle, with positive-exclusion discipline

Modelled on Forrester Wave inclusion criteria (4/5 BINDING from Q1.1) + PRISMA positive-exclusion (the strongest discipline) + Forrester two-role pair (5/5 BINDING from Q1.4).

- **Pros:** Persistent project-level artifact; mandatory authorship at project-bootstrap time; refreshed per cycle that invokes enterprise-research-first; positive-exclusion subsection documents why natural-looking comparators were not included.
- **Cons:** Adds one new artifact per project. Mitigated because the artifact is small (one table + one positive-exclusion list) and lives in `docs/` (project-level, not framework-level).
- **Status:** **Chosen.**

### Option D — Centralize a framework-level competitor roster

Maintain `templates/COMPETITORS.template.md` AND ship a framework-level `docs/competitors-pfv2.md` listing PF v2's own competitors (other multi-agent frameworks).

- **Pros:** The framework eats its own dogfood.
- **Cons:** Mixes two concerns: (a) the template schema (which IS framework-level) and (b) the actual competitor list (which is project-level, even for the framework itself). The template ships in `templates/`; the framework's own competitor list is a project-level concern of the framework-repo as a project. Keep the framework's own list out of `core/`.
- **Status:** **Partially chosen** — the template ships at `templates/COMPETITORS.template.md`. The framework-repo's own competitor list is a separate concern handled by the framework's own bootstrap, not by this ADR.

---

## Decision Outcome

**Chosen:** **Option C (project-level `docs/COMPETITORS.md`) + Option D's template-only half (ship `templates/COMPETITORS.template.md`).**

### Artifact shape

Every project using PF v2 ships `docs/COMPETITORS.md` containing:

1. **Roster table.** One row per named direct competitor with columns: `name | category | overlap-with-our-product | last-verified | citation`. Modelled on Forrester Wave inclusion criteria + IDC MarketScape segment-specific thresholds (Q1.1 evidence).
2. **Positive-exclusion subsection.** PRISMA pattern: each "natural-looking-but-excluded" comparator is named with a one-line reason for exclusion. Example: "X — excluded because X serves segment Y, which is non-overlapping with our segment Z." This is the strongest discipline in the surveyed frameworks.
3. **Refresh trigger.** The roster is refreshed every cycle that invokes `enterprise-research-first`. The Researcher's intake step (per ADR-014) frame-checks the dispatched comparable set against the roster.
4. **Ownership.** The CTO orchestrator owns the roster (Forrester-analyst analog). The Researcher consumes it at intake (Forrester-research-director analog). Two-role pair per Q1.4 BINDING precedent.

### Template

`templates/COMPETITORS.template.md` ships in the framework, containing the schema above as a fill-in template. Projects copy it on bootstrap.

### Researcher intake composition

Per ADR-014's frame-check step, the Researcher's intake reads `docs/COMPETITORS.md` and:

1. Confirms the dispatched comparable set covers the named competitors AND surfaces the positive-exclusion reasons for any roster entry that was *not* in the dispatched set.
2. Returns NEEDS_CONTEXT with a re-framing proposal if the dispatched set omits a competitor without a positive-exclusion entry justifying the omission.

### CTO dispatch composition

`skills/cto-mode/SKILL.md` gains a dispatch-checklist item: "If dispatching a research lane that compares the project against alternatives, confirm the dispatch envelope's comparable set is consistent with `docs/COMPETITORS.md`." This is the analyst-side of the Forrester pair.

---

## Consequences

### Positive

- The Researcher can push back on a comparable set with a named ground-truth artifact — no more verbatim execution of under-specified dispatches.
- The two-role pair (CTO ratifies, Researcher consumes) maps cleanly onto 5/5 BINDING enterprise precedent for comparable-set ratification.
- PRISMA positive-exclusion discipline catches the failure mode where natural-looking comparators are silently skipped — the strongest discipline in the surveyed set.
- Composes with ADR-014 (spectrum-vs-binary) — the frame-check step explicitly reads the roster.
- Composes with ADR-017 (dependency inventory) — both are project-level "what exists in our space" artifacts, sister mechanisms.

### Negative

- Adds one new project-level artifact (`docs/COMPETITORS.md`). Mitigated because the artifact is small and template-driven.
- Refresh cadence is "per cycle that invokes enterprise-research-first" — projects with frequent research cycles refresh frequently. Mitigated by the small-size constraint.
- Single-tenant projects with no direct competitors still need to author the artifact (with positive-exclusion noting "no direct competitors at this market segment"). This is intentional — the discipline of *naming why there are no competitors* catches the failure mode of *assuming there are no competitors*.

### Consequence path (what the ADR will eventually drive — NOT implemented here)

The downstream Build cycle implements:

- `templates/COMPETITORS.template.md` — new file with the schema described above.
- `templates/PROJECT-PLAN.template.md` — add a `competitors_roster:` reference slot pointing at `docs/COMPETITORS.md` (per architecture doc §2).
- `agents/researcher.md` — add the competitor-roster frame-check to intake (composes with ADR-014).
- `skills/cto-mode/SKILL.md` — add the analyst-side dispatch-checklist item.
- `skills/enterprise-research-first/SKILL.md` — add a Step 1 sub-bullet requiring competitor-roster consistency for any comparative-research dispatch.

No source code is written by this ADR.

---

## Citations (verbatim, with re-verification flag)

All Researcher citations are tagged `(via WebSearch synthesis of canonical URL)` per Lane R-1 §"Methodology disclosure." Re-verification before Build-cycle implementation is required.

1. **PRISMA 2020 Item 5 — eligibility-criteria discipline (the canonical pattern for "specify inclusion and exclusion criteria").** "Specify the inclusion and exclusion criteria for the review and how studies were grouped for the syntheses." "Define inclusion and exclusion criteria, including study design, participants, interventions, comparators, outcomes, and time frame." — https://www.prisma-statement.org/prisma-2020-checklist (Researcher Lane R-1 §Q1.1, verified 2026-05-12 via WebSearch synthesis).

2. **PRISMA 2020 positive-exclusion discipline (the strongest mechanism for "why was this comparator NOT included?").** "Authors cite studies that might appear to meet the inclusion criteria but were excluded, and explain why they were excluded." — https://www.prisma-statement.org/prisma-2020-statement (Researcher Lane R-1 §Q1.1, verified 2026-05-12 via WebSearch synthesis).

3. **Forrester Wave — analyst owns inclusion criteria; research director ratifies (the two-role pair).** "The research analyst creates objective vendor inclusion criteria, as well as scoring rubrics that will help customers to differentiate between competing products." "The analyst determines the inclusion criteria… the research director works closely with the analyst to develop the inclusion criteria, evaluation criteria, and scoring framework." — https://www.forrester.com/policies/forrester-wave-methodology/ (Researcher Lane R-1 §Q1.1 + §Q1.4, verified 2026-05-12 via WebSearch synthesis).

4. **Gartner Magic Quadrant — inclusion-criteria specificity + per-cycle refresh.** "The criteria for inclusion may consist of market share, number of clients, installed base, types of products/services, target market or other defining characteristics. These criteria help narrow the scope of the research to those vendors that Gartner considers to be the most important — or best-suited to the evolving needs of Gartner's clients as buyers in the market." "For annual updates to previously published Magic Quadrants, the update will include changes to refine the market definition, vendor inclusion criteria and evaluation criteria, if required." — https://www.gartner.com/en/research/methodologies/magic-quadrants-research (Researcher Lane R-1 §Q1.1, verified 2026-05-12 via WebSearch synthesis).

5. **IDC MarketScape — concrete inclusion threshold example.** "Vendors should have at least 20 active customers reporting $20 million or more in annual revenue, must syndicate product data into a minimum of five different major commerce channels" [PIM segment example] — https://www.stibosystems.com/hubfs/resource-library/en/report/report-idc-pim-for-commerce-marketscape-2024-en.pdf (Researcher Lane R-1 §Q1.1; tagged secondary — syndicated IDC content, verified 2026-05-12 via WebSearch synthesis).

6. **IDC MarketScape — rigorous methodology (the discipline statement).** "The research methodology utilizes a rigorous scoring methodology based on both qualitative and quantitative criteria that results in a single graphic illustration of each vendor's position within a given market." — https://www.idc.com/promo/idcmarketscape/ (Researcher Lane R-1 §Q1.4, verified 2026-05-12 via WebSearch synthesis).

7. **ThoughtWorks Tech Radar — TAB vote ratification (the alternative ratification shape).** "Whoever nominated the blip gets to explain it to the group, it's then discussed and voted on using three different colored cards: green for 'yes', red for 'no', and yellow for questions or comments." — https://www.thoughtworks.com/insights/blog/how-we-create-technology-radar (Researcher Lane R-1 §Q1.4, verified 2026-05-12 via WebSearch synthesis).

8. **CNCF Landscape — community submission + TOC ratification (the open-source comparable-set shape).** "Projects increase their maturity by demonstrating their sustainability to CNCF's Technical Oversight Committee: that they have adoption, a healthy rate of changes, and committers from multiple organizations." — https://github.com/cncf/toc/blob/main/process/graduation_criteria.md (Researcher Lane R-1 §Q1.4, verified 2026-05-12 via WebSearch synthesis).

9. **Gartner — gated publication (carefully-upheld criteria).** "There are carefully upheld criteria for inclusion in a Magic Quadrant report, which means that being positioned is not a given for most vendors in a particular space." — https://www.gartner.com/en/about/magic-quadrant-faq (Researcher Lane R-1 §Q1.4, verified 2026-05-12 via WebSearch synthesis).

---

## Re-verification disclosure

Per Researcher Lane R-1 §"Methodology disclosure": WebFetch was permission-denied throughout. Every quote is via WebSearch synthesis. The Build cycle MUST re-fetch each URL before committing the COMPETITORS template + intake-check code change.

---

## More Information

- Architecture doc: `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (C1 cluster), §4 (Q1.1, Q1.4), §7 (Lane R-1 dispatch).
- Researcher output: `docs/research/research-methodology-framing-2026-05-12.md` §Q1.1, §Q1.4, §Citations.
- Companion ADRs: `docs/adr/014-spectrum-vs-binary-discipline.md` (the Researcher's frame-check step reads the COMPETITORS artifact), `docs/adr/017-dependency-inventory.md` (sister project-level inventory artifact for the code-layer).
- Framework-internal precedent: `agents/researcher.md` (target file for the intake frame-check); `skills/enterprise-research-first/SKILL.md` (Step 1 dispatch envelope target); `skills/cto-mode/SKILL.md` (dispatch checklist target).
