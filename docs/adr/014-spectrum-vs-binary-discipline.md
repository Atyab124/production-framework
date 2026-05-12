# ADR-014 — Spectrum-vs-Binary Discipline (Problem-Space Enumeration Before Solution-Space Comparison)

**Status:** Proposed (Pass 3 of Pattern A; awaits Build cycle)
**Date:** 2026-05-12
**Authors:** Production-framework Architect sub-agent (Opus 4.7), Pass 3 consolidation
**Producer-Consumer pass:** Researcher Pass 2 → Architect Pass 3 (this doc)
**Researcher inputs:**
- `docs/research/research-methodology-framing-2026-05-12.md` (Lane R-1, Q1.2 — Goals/Non-Goals discipline, Q2.2 — problem-space / solution-space separation, Q1.3 — pattern-vs-library distinction)

**Source feedback items addressed:** Item 5 (Architect collapses spectrum decisions to binary verdicts) and Item 6 (Researcher does not push back on prompt framing). Both items share one fix surface: problem-space enumeration as a named step preceding solution-space alternatives.

**Architecture doc reference:** `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (Clusters C1 + C2), §4 (Q1.2, Q1.3, Q2.2), §9 concerns (validation-question count drift).

---

## Context and Problem Statement

The TaskIt 2026-05-11 feedback log surfaced two failure modes of the same shape:

- **Item 5.** The Architect's recommendations frequently collapse multi-axis decisions to binary verdicts ("use X vs Y") without first enumerating the *category* of approach each option belongs to. The framework's existing seven-validation-questions and enterprise-research-first machinery operate on the solution space (which-specific-option) without forcing a problem-space (which-class-of-approach) enumeration step.
- **Item 6.** The Researcher executes prompt-framing verbatim. When dispatched to "evaluate libraries that implement pattern X," the Researcher does not push back even if the actual underlying question is "evaluate pattern X itself." Goals/Non-Goals are not enumerated; the prompt is treated as fixed input.

Both items live at the same architectural seam: the boundary between problem-space framing and solution-space comparison. Researcher Lane R-1 Q2.2 returned **5/5 unanimous (BINDING by enterprise-research-first grammar)** that every named enterprise design-doc template separates the problem space from the solution space as distinct named slots. The framework currently has no such separation.

---

## Decision Drivers

1. **5/5 BINDING enterprise precedent (Researcher Q2.2).** Rust RFC, KEP, Google DD, MADR, Y-statement — all five enterprise design-doc templates make spectrum/problem-space-framing a named, distinct slot from solution-space alternatives. Departing would violate the framework's own enterprise-research-first BINDING rule.
2. **5/5 BINDING precedent (Researcher Q1.2) for Goals/Non-Goals + "Yes, if" pushback.** Amazon PR/FAQ, Google DD, Squarespace RFC, Rust RFC, Kubernetes KEP — all five treat scope-and-framing challenge as a structurally-required document section, never an implicit cultural norm. Squarespace's "Yes, if" framing is the strongest: rejection is structurally forbidden, only "yes, if [conditions]" is allowed.
3. **5/5 BINDING precedent (Researcher Q1.3) for pattern-vs-library distinction.** ThoughtWorks Tech Radar (Techniques vs Tools quadrants), Gartner (Hype Cycle vs Magic Quadrant), MADR (define-pattern vs choose-between-technologies), PBAR, C4 Component vs Code levels — every enterprise framework operating at both abstraction layers makes the distinction structural, never discretionary.
4. **The fix surface is shared.** Items 5 and 6 are not two problems; they are one architectural seam observed from two angles (Architect-side and Researcher-side). One fix surface — adding a "Spectrum / Categories" step + Goals/Non-Goals enumeration — addresses both.
5. **Validation-question-count drift must be reconciled.** Architecture doc §9 flagged: Items 1, 5, 7, 9, 12 each propose a new validation question. The current skill is named "seven" — adding 5 makes it twelve. ADR-014 owns this count-drift decision.

---

## Considered Options

### Option A — Leave the framework as-is; trust Architect and Researcher judgment

Status quo. Treat spectrum enumeration as implicit good practice.

- **Pros:** Zero new skill surface.
- **Cons:** 5/5 BINDING precedent on Q2.2 forbids this — every named enterprise template has a structurally-required section, not implicit judgment. Reproduces Items 5 and 6 exactly.
- **Status:** Neglected.

### Option B — Add a named "Spectrum / Categories" step to `agents/architect.md` and a mirror frame-check step to `agents/researcher.md`

Both agents gain a first-action requirement: enumerate the categories of approach (one sentence each) before recommending one. The Researcher's NEEDS_CONTEXT trigger fires if the dispatched question conflates pattern-level with library-level analysis (Q1.3) or if Goals/Non-Goals contradict the dispatch (Q1.2).

- **Pros:** Composes with 5/5 BINDING precedent. Minimal surface — two agent files. Composes with the existing seven-validation-questions skill's fixed-list grammar without adding a new Q.
- **Cons:** Adds intake ceremony for every Architect / Researcher dispatch. Mitigated because the enumeration is one-sentence-per-category.
- **Status:** **Chosen.**

### Option C — Rust RFC 2333 style — separate "Prior Art" section from "Alternatives Considered" in every design-doc surface

The strongest enterprise pattern (Rust RFC 2333 explicitly separates Prior Art from Rationale-and-Alternatives because "scattering category-level context across the doc loses coherence"). Apply at every architecture doc the framework produces.

- **Pros:** Most rigorous version of Q2.2's BINDING finding.
- **Cons:** Heavier than Option B at the doc level. The architecture-doc template (`agents/architect.md` operating levels) already has a "Cross-cutting concepts" section per arc42 §8 which serves a similar role.
- **Status:** **Composed with Option B** — the new step in Option B writes its output into a named subsection (Spectrum/Categories) that lives next to (not interleaved with) the Considered Options section in any ADR or architecture doc. This is the Rust RFC 2333 shape applied at the framework level.

### Option D — Add 5 new validation questions (Q8 spectrum, Q9 deferral, Q10 scale-readiness, Q11 phase-completeness, Q8-alt competitor-coverage) to the seven-validation-questions skill

Make the count drift explicit: rename to "twelve-validation-questions" or "validation-questions" (no number).

- **Pros:** Each gap surfaces in a single fixed-list grammar.
- **Cons:** Skill is named "seven" for a reason — Anthropic + SP precedent values fixed-count discipline. Renaming is high-churn. Researcher Q1.2 noted that enterprise design-doc templates often have a *fixed* small set of sections, not an open list. The framework's seven is its INVEST-style anchor.
- **Status:** Neglected as the universal answer. The architect's compromise: keep the core list at 7; add an "extended Qs" opt-in for specific cycle types. This is consistent with how Anthropic's Building-Effective-Agents pattern uses fixed-base + optional-extension shapes.

---

## Decision Outcome

**Chosen:** **Option B (named Spectrum/Categories step on both agents) + Option C (Rust-RFC-2333-style subsection separation in any ADR/architecture doc the agents produce) + a reconciled count-drift resolution.**

### Spectrum/Categories step (Option B)

Both `agents/architect.md` and `agents/researcher.md` gain a named first-action step at intake:

For the Architect:
1. Enumerate the categories of approach the dispatched question implies (one sentence per category). Categories are the spectrum; specific options come later.
2. State Goals and Non-Goals of the recommendation in one sentence each. Non-Goals is the Squarespace/KEP/Google-DD scope-challenge mechanism.
3. If the dispatched question collapses the spectrum (binary X-vs-Y framing), return NEEDS_CONTEXT with a proposed re-framing using the "Yes, if" structure: "Yes, I can recommend X vs Y, IF the underlying category-level decision is already made; otherwise the categories first."

For the Researcher (Items 1, 6 composing with ADR-015):
1. Enumerate the dispatched question's Goals and Non-Goals (one sentence each).
2. Frame-check against the project's competitor-roster (ADR-015 artifact `docs/COMPETITORS.md`) — does the dispatched comparable set include the named direct competitors, or is the framing implicitly excluding them?
3. Pattern-vs-library declaration (Q1.3) — does the dispatched question target pattern-level or library-level analysis? If conflated, return NEEDS_CONTEXT.

### Rust RFC 2333 subsection separation (Option C)

Any ADR or architecture doc produced by the Architect that contains "Considered Options" MUST also contain a preceding "Spectrum / Categories" subsection (or equivalent — "Prior Art," "Problem-Space Framing," "Categories of Approach"). The subsection enumerates the categories; the "Considered Options" lists the specific options within (or sometimes across) those categories. MADR's "Decision Drivers" section can carry the Spectrum subsection if the ADR uses MADR; Y-statement ADRs note the Spectrum inline in the "facing" clause.

### Validation-question count-drift resolution

The seven-validation-questions skill stays named "seven" and stays at seven core questions. The new questions Items 1, 5, 7, 9, 12 propose are added as **"extended Qs"** — opt-in for specific cycle types. Concretely:

- **Cycle types that opt-in to extended Qs:** refactor (touches multiple skills), security-audit, scale-readiness, migration. For these, the cycle's CTO dispatch lists which extended Qs apply, and the seven-validation-questions skill consumes the extended set in addition to its core seven.
- **Cycle types that stay at seven:** simple build, debug, simple bugfix.

This is enterprise consensus: fixed-base + optional-extension is the pattern in INVEST (six core attributes), Y-statement (six clauses), MADR (minimal vs full template). The framework's seven matches the INVEST-style anchor.

---

## Consequences

### Positive

- 5/5 BINDING precedent honored: spectrum enumeration becomes a structurally-required step, not implicit.
- Items 5 and 6 share one fix surface — minimal cost.
- The Goals/Non-Goals + "Yes, if" pushback discipline (Squarespace precedent) gives the Researcher a non-confrontational mechanism for prompt-framing pushback.
- The seven-validation-questions skill stays at seven (no rename, no churn).
- The pattern-vs-library declaration (Q1.3) composes with `skills/enterprise-research-first/SKILL.md` Step 1 — the dispatch envelope gains one extra field.
- ADRs and architecture docs become more readable per Rust RFC 2333 precedent (problem-space and solution-space don't bleed into each other).

### Negative

- Intake ceremony rises slightly for every Architect / Researcher dispatch. Mitigated because enumeration is one-sentence-per-category.
- Cycle-type-specific extended-Q opt-in adds one decision-point at CTO dispatch time. Mitigated because the cycle-selection skill already classifies cycle types.
- The Architect's NEEDS_CONTEXT trigger (when dispatched question is over-binary) creates a feedback loop — the orchestrator may need to re-dispatch. This is the intended behavior but does add round-trips.

### Consequence path (what the ADR will eventually drive — NOT implemented here)

The downstream Build cycle implements:

- `agents/architect.md` — add the Spectrum/Categories step + Goals/Non-Goals enumeration step + NEEDS_CONTEXT trigger on over-binary framing.
- `agents/researcher.md` — add the frame-check step (Goals/Non-Goals + competitor-roster coverage + pattern-vs-library declaration).
- `skills/enterprise-research-first/SKILL.md` — Step 1 gains the `pattern-level | library-level` field in the dispatch envelope.
- `skills/seven-validation-questions/SKILL.md` — add the "extended Qs" opt-in mechanism with per-cycle-type extension lists.
- `skills/cycle-selection/SKILL.md` — add the extended-Qs opt-in to the cycle dispatch grammar.
- Architecture doc templates (any new ADR template the framework ships): add the Spectrum/Categories subsection as a required slot when "Considered Options" is present.

No source code is written by this ADR.

---

## Citations (verbatim, with re-verification flag)

All Researcher citations are tagged `(via WebSearch synthesis of canonical URL)` per Lane R-1 §"Methodology disclosure." Re-verification before Build-cycle code change is required.

1. **Rust RFC 2333 — explicit separation of Prior Art from Alternatives (the primary precedent for the chosen pattern).** "Information about prior art could be provided in each section (motivation, guide-level explanation, etc.), but this is likely to reduce the coherence and readability of RFCs. This RFC argues that it is better that prior art be discussed in one coherent section." — https://rust-lang.github.io/rfcs/2333-prior-art.html (Researcher Lane R-1 §Q2.2, verified 2026-05-12 via WebSearch synthesis).

2. **Rust RFC Prior Art scope (problem-space enumeration discipline).** "Discuss prior art, both the good and the bad, in relation to their proposal." — https://rust-lang.github.io/rfcs/2333-prior-art.html (Researcher Lane R-1 §Q2.2, verified 2026-05-12 via WebSearch synthesis).

3. **Kubernetes KEP — Alternatives as named section.** "The alternatives considered section elucidates why a particular design path was taken, whether it's selecting a sidecar model over an operator pattern or choosing CRDs over API extensions" — https://github.com/kubernetes/enhancements/blob/master/keps/NNNN-kep-template/README.md (Researcher Lane R-1 §Q2.2, verified 2026-05-12 via WebSearch synthesis).

4. **Google Design Doc — Alternatives Considered as one of the most important sections.** "This section is one of the most important ones as it shows very explicitly why the selected solution is the best given the project goals and how other solutions, that the reader may be wondering about, introduce trade-offs that are less desirable given the goals." — https://www.industrialempathy.com/posts/design-docs-at-google/ (Researcher Lane R-1 §Q2.2, verified 2026-05-12 via WebSearch synthesis).

5. **Y-statement (Zimmermann) — explicit "neglected alternatives" slot.** "context: functional requirement (story, use case) or arch. component, facing: non-functional requirement, for instance a desired quality, we decided: decision outcome (arguably the most important part), and neglected alternatives not chosen (not to be forgotten!), to achieve: benefits, the full or partial satisfaction of requirement(s), accepting that: drawbacks and other consequences." — https://medium.com/olzzio/y-statements-10eb07b5a177 (Researcher Lane R-1 §Q2.2, verified 2026-05-12 via WebSearch synthesis).

6. **Squarespace "Yes, if" — structural rejection-forbidden framing (the strongest Goals/Non-Goals discipline).** "The most common response during RFC review is 'Yes, if you make sure that…'" "RFCs can never have a 'rejected' status, only a 'not yet'" — https://engineering.squarespace.com/blog/2019/the-power-of-yes-if (Researcher Lane R-1 §Q1.2, verified 2026-05-12 via WebSearch synthesis).

7. **Squarespace Goals + Non-Goals — explicit structural requirement.** "What problems are you trying to solve? What problems are you not trying to solve?" — https://engineering.squarespace.com/s/Squarespace-RFC-Template.pdf (Researcher Lane R-1 §Q1.2, verified 2026-05-12 via WebSearch synthesis).

8. **Amazon PR/FAQ — internal FAQ as the pushback mechanism.** "The next section is the internal FAQs, which anticipates the most important questions that senior leaders and stakeholders in the company will ask after reading the PR." — https://workingbackwards.com/concepts/working-backwards-pr-faq-process/ (Researcher Lane R-1 §Q1.2, verified 2026-05-12 via WebSearch synthesis).

9. **ThoughtWorks Tech Radar — pattern-vs-library structural distinction (Techniques vs Tools quadrants).** "Techniques: These include elements of a software development process, such as experience design; and ways of structuring software, such as microservices." "Tools: These can be components, such as databases, software development tools, such as versions' control systems." — https://www.thoughtworks.com/radar (Researcher Lane R-1 §Q1.3, verified 2026-05-12 via WebSearch synthesis).

10. **Gartner Hype Cycle vs Magic Quadrant — pattern-vs-library structural distinction.** "Use a Gartner Hype Cycle report to gauge emerging trends; a Gartner Magic Quadrant tool to compare vendors." — https://www.gartner.com/en/research/methodologies/gartner-hype-cycle and https://www.gartner.com/en/research/methodologies/magic-quadrants-research (Researcher Lane R-1 §Q1.3, verified 2026-05-12 via WebSearch synthesis).

11. **MADR — Considered Options requirement (specific-options-with-pros-and-cons).** "The considered options with their pros and cons are crucial to understand the reasons for choosing a particular design… It's valuable to explicitly list all the serious alternatives that were considered, together with their pros and cons." — https://adr.github.io/madr/ (Researcher Lane R-1 §Q2.2 cross-citation, verified 2026-05-12 via WebSearch synthesis).

---

## Re-verification disclosure

Per Researcher Lane R-1 §"Methodology disclosure": WebFetch was permission-denied throughout. Every quote is via WebSearch synthesis of canonical URL. The Build cycle MUST re-fetch each URL before committing the spectrum-step + frame-check code change.

---

## More Information

- Architecture doc: `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (C1 + C2 clusters), §4 (Q1.2, Q1.3, Q2.2), §9 concerns (validation-question count drift).
- Researcher output: `docs/research/research-methodology-framing-2026-05-12.md` §Q1.2, §Q1.3, §Q2.2, §Citations.
- Companion ADRs: `docs/adr/015-competitor-roster.md` (the competitor-roster artifact the Researcher's frame-check consumes), `docs/adr/017-dependency-inventory.md` (the Architect's pre-recommendation inventory step composes with the Spectrum/Categories step).
- Framework-internal precedent: `skills/enterprise-research-first/SKILL.md` (Step 1 dispatch envelope target), `skills/seven-validation-questions/SKILL.md` (extended-Qs opt-in target), `skills/cycle-selection/SKILL.md` (cycle-type classification feeds extended-Qs decision).
