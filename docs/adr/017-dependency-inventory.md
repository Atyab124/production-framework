# ADR-017 — Dependency Inventory Pre-Recommendation Step

**Status:** Proposed (Pass 3 of Pattern A; awaits Build cycle)
**Date:** 2026-05-12
**Authors:** Production-framework Architect sub-agent (Opus 4.7), Pass 3 consolidation
**Producer-Consumer pass:** Researcher Pass 2 → Architect Pass 3 (this doc)
**Researcher inputs:**
- `docs/research/architecture-pre-recommendation-discipline-2026-05-12.md` (Lane R-2, Q2.1 — pre-recommendation dependency/component inventory)

**Source feedback items addressed:** Item 3 (Architect lacks dependency-inventory step before recommending a new library).

**Architecture doc reference:** `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (Cluster C2), §4 (Q2.1), §8 (cross-reference to F-09 RESOLVED — `find-similar-implementations` for code-level reuse; this ADR is the package-level sibling).

---

## Context and Problem Statement

The TaskIt 2026-05-11 feedback log (Item 3) observed that the Architect recommends libraries / dependencies without first inventorying what the project already has. The existing `find-similar-implementations` skill (F-09 RESOLVED) handles the *code-level* reuse-lookup gap — it asks "what helpers/hooks already exist in the codebase that this new feature could reuse?" — but it does not handle the *package-level* sibling: "what libraries / dependencies are already installed that overlap with the proposed new one?" The result: the Architect recommends adding library X to a project that already has library Y (which does most of what X does), or recommends library X without checking whether the project has an explicit "do not add" list.

The framework needs a pre-recommendation dependency-inventory step that fires before any "add new library / service" recommendation. The step must compose with the existing `find-similar-implementations` skill (which is the code-level sibling), with ADR-011's scale-readiness gate (which is the scale-targets sibling), and with ADR-014's spectrum-vs-binary discipline (which is the problem-space-framing sibling).

---

## Decision Drivers

1. **5/5 BINDING precedent (Researcher Q2.1).** TOGAF Gap Analysis, arc42 §5 Building Block View, C4 System Context, MADR Considered Options, ThoughtWorks Tech Radar — all five enterprise architecture frameworks make existing-state inventory a documented pre-condition of an add-new-component decision. The strength varies (TOGAF and arc42 are BINDING at named ADM phase / section; C4 makes it structurally mandatory; MADR is advisory but explicit; ThoughtWorks treats the radar as the inventory + Assess-before-Adopt as the discipline). No outlier; every surveyed framework treats "what do we already have" as a prerequisite question.
2. **TOGAF Baseline Architecture is the strongest named artifact.** The Baseline / Target Matrix with explicit "New" and "Eliminated" rows is the canonical enterprise pattern. PF v2 cannot adopt TOGAF wholesale (over-heavy) but can adopt the Baseline/Target gap-matrix shape narrowed to the dependency axis.
3. **arc42 §5 BBV table is the closest fit for PF v2's existing architecture-doc tradition.** PF v2 architecture docs already cite arc42 §5 + §6 + §8 per the citation manifest; extending to the dependency-inventory axis is a natural composition.
4. **ThoughtWorks Hold-ring is the project-level "do not add" precedent.** The Hold ring's "don't start anything new with this technology" rule is the precedent for project-level "do not add" lists.
5. **Composes with the existing `find-similar-implementations` skill.** The skill handles code-level reuse-lookup; this ADR's step handles package-level inventory. Together they form the complete reuse-lookup discipline.

---

## Considered Options

### Option A — Leave the framework as-is; trust Architect judgment

Status quo.

- **Pros:** Zero new template surface.
- **Cons:** Reproduces Item 3 exactly. 5/5 BINDING precedent forbids; departing from unanimous enterprise consensus violates the framework's own enterprise-research-first rule.
- **Status:** Neglected.

### Option B — Require a `docs/dependencies.md` artifact at the project level

Modelled on TOGAF Baseline Architecture. The project ships an explicit dependency manifest separate from `package.json` / `Gemfile` / `pyproject.toml`.

- **Pros:** Most rigorous version of Q2.1's BINDING finding.
- **Cons:** The package-manager files ARE the dependency manifest. A separate `docs/dependencies.md` either duplicates them (drift risk) or paraphrases them (information loss). The artifact should be the package-manager file itself, with the *inventory step* being how the Architect consumes it.
- **Status:** Neglected as the literal Option B; the spirit is preserved in Option C.

### Option C — Add an "Inventory existing components" pre-recommendation step to `agents/architect.md`

When the Architect is asked "should we add library X?", the agent's first action is:

1. Read the project's package-manager file (e.g., `package.json`, `pyproject.toml`).
2. List dependencies / libraries / services already in the project that overlap the proposed new component's purpose.
3. Output a table with `name | already-installed | overlap-with-new | reuse-feasibility`.
4. If a "do not add" list exists (project-level Hold-ring artifact), check it.

This is structurally a TOGAF Baseline / Target gap matrix narrowed to the dependency axis, applied per-question rather than as a standing artifact.

- **Pros:** Composes with `find-similar-implementations` (code-level reuse) — both are agent-prompt-level intake steps. Composes with ADR-014 (Spectrum/Categories step) — same intake-shape. No new project-level artifact required (the package-manager file is the inventory).
- **Cons:** Per-question execution means the inventory work happens each time. Mitigated because the package-manager file is small and machine-readable.
- **Status:** **Chosen as the core mechanism.**

### Option D — Optional project-level Hold-ring artifact for "do not add" lists

Modelled on ThoughtWorks Tech Radar Hold ring. The project optionally ships `docs/tech-hold.md` (or includes a `hold:` slot in `PROJECT-PLAN.md`) listing technologies the project has decided NOT to add. The Architect's pre-recommendation step checks it.

- **Pros:** Captures the project's "do not add" decisions as a persistent artifact; matches ThoughtWorks Hold-ring precedent. Optional — projects without strong opinions skip it.
- **Cons:** Adds an optional artifact. Mitigated because it's optional.
- **Status:** **Composed with Option C** — Option C is the core agent-step; Option D is the optional project-level Hold-ring artifact that Option C consumes if present.

---

## Decision Outcome

**Chosen:** **Option C (agent-step) + Option D (optional Hold-ring artifact)**.

### Agent step (Option C)

`agents/architect.md` gains a "Dependency Inventory" pre-recommendation step. When the Architect is dispatched on a question that proposes adding a new library / dependency / service, the agent's first action is:

1. **Read the project's package-manager file(s).** `package.json` for Node, `pyproject.toml` for Python, `Gemfile` for Ruby, etc.
2. **List overlap candidates.** Produce a table:
   | Name | Already-installed | Overlap-with-new | Reuse-feasibility |
   |---|---|---|---|
3. **Check the Hold-ring artifact** (if present at `docs/tech-hold.md` or as `hold:` slot in `PROJECT-PLAN.md`).
4. **Recommendation incorporates the inventory.** If the inventory surfaces a viable existing candidate, the Architect's recommendation must address why the candidate is or is not sufficient (MADR-style "Considered Options" — see ADR-014). If the Hold-ring lists the proposed library, the Architect must surface this and return NEEDS_CONTEXT for the orchestrator's decision.

### Optional Hold-ring artifact (Option D)

`PROJECT-PLAN.template.md` gains an optional `hold:` slot — list of technologies the project has decided NOT to add, with one-line rationale per entry. Modelled on ThoughtWorks Tech Radar Hold ring's "don't start anything new with this technology" rule.

### Composition with `find-similar-implementations`

The existing skill (F-09 RESOLVED) and this ADR's step are siblings:

- `find-similar-implementations` — code-level reuse-lookup (what helpers/hooks/components in the existing codebase could we reuse?).
- ADR-017 step — package-level reuse-lookup (what installed libraries could we reuse?).

Both run as pre-recommendation intake steps. Together they form the complete reuse-lookup discipline that Items 3 and the prior Item 4 (F-09 RESOLVED) collectively name.

### Composition with ADR-011 (scale-readiness gate) and ADR-014 (spectrum step)

The Architect's intake checklist (after the dispatches of ADRs 011, 014, and 017) becomes:

1. Spectrum / Categories enumeration (ADR-014) — what category of approach is the question asking about?
2. Goals / Non-Goals (ADR-014) — what's in scope and what's not?
3. Dependency inventory (this ADR) — what do we already have?
4. Scale-readiness gate (ADR-011) — does the proposed work address stated `scale_targets:`?
5. Recommend (with MADR-style Considered Options that cite at least the closest inventory entries — Q2.1 recommendation #4).

This is a four-step intake; ceremony cost is mitigated because each step is a one-table-or-one-sentence output.

---

## Consequences

### Positive

- 5/5 BINDING enterprise precedent honored. The framework moves from "trust Architect judgment" to "structurally require inventory."
- Composes cleanly with `find-similar-implementations` (code-level sibling) — together they cover the complete reuse-lookup space.
- Composes with ADR-011 (scale-readiness) and ADR-014 (spectrum step) — same intake-shape across three siblings.
- Hold-ring artifact captures project-level "do not add" decisions as persistent context — matches ThoughtWorks precedent.
- The ADR's recommendation that the new component's MADR cite at least the closest inventory entries (not generic alternatives) tightens the MADR Considered Options discipline.

### Negative

- Intake ceremony rises by one step per "add new library" question. Mitigated because the step is a table-output from a single package-manager file read.
- Hold-ring artifact is optional — projects that should have one but don't are not caught by this ADR alone. Future cycles may promote the Hold ring to required for scale-readiness-tagged projects.
- The package-manager file format varies across stacks. The Build cycle should not bake the format into `skills/` or `agents/` core (per CLAUDE.md rejection criterion #3). The format-specific reader lives in `templates/STACK-PATTERNS.md` instances or in a project-local helper.

### Consequence path (what the ADR will eventually drive — NOT implemented here)

The downstream Build cycle implements:

- `agents/architect.md` — add the Dependency-Inventory pre-recommendation step to the intake checklist (composes with ADR-011 + ADR-014).
- `templates/PROJECT-PLAN.template.md` — add the optional `hold:` slot.
- `skills/find-similar-implementations/SKILL.md` — add a cross-reference note: "this skill is the code-level sibling of the dependency-inventory step in `agents/architect.md` — they compose."
- `skills/enterprise-research-first/SKILL.md` — Step 1 dispatch envelope may gain a "current-state-inventoried: yes/no" field for research questions that touch dependency choice.

No source code is written by this ADR.

---

## Citations (verbatim, with re-verification flag)

All Researcher citations are tagged `(via WebSearch synthesis of canonical URL)` per Lane R-2 §"Methodology Disclosure" (5 of 6 WebFetch denied; the AWS WAF Reliability page loaded directly). Re-verification before Build-cycle implementation is required.

1. **TOGAF Gap Analysis matrix — the canonical Baseline / Target inventory pattern.** "The matrix includes all the ABBs (Architecture Building Blocks) of the Baseline Architecture on the vertical axis, and all the ABBs of the Target Architecture on the horizontal axis, with a final row labeled 'New' added to the Baseline Architecture axis, and a final column labeled 'Eliminated' added to the Target Architecture axis." — https://pubs.opengroup.org/architecture/togaf91-doc/arch/chap27.html (Researcher Lane R-2 §Q2.1, verified 2026-05-12 via WebSearch synthesis).

2. **TOGAF — the three gap categories.** "'Included': Where a function is available in both the current and target architectures, this is recorded with 'Included' at the intersecting cell. 'Eliminated': This column captures building blocks from the baseline that are not in the target architecture. 'New': This row captures gaps — anything under 'New' should either be explained as correctly eliminated, or marked as to be addressed by reinstating or developing/procuring the building block." — https://pubs.opengroup.org/architecture/togaf91-doc/arch/chap27.html (Researcher Lane R-2 §Q2.1, verified 2026-05-12 via WebSearch synthesis).

3. **arc42 §5 Building Block View — static decomposition with dependencies.** "The building block view shows the static decomposition of the system into building blocks (modules, components, subsystems, classes, interfaces, packages, libraries, frameworks, layers, partitions, tiers, functions, macros, operations, data structures, …) as well as their dependencies (relationships, associations, …)." — https://docs.arc42.org/section-5/ (Researcher Lane R-2 §Q2.1, verified 2026-05-12 via WebSearch synthesis).

4. **arc42 — BBV table requirement.** "A short and pragmatic overview of all contained building blocks and their interfaces can be provided through a table, or a list of black box descriptions of the building blocks. Dependencies and relationships of the listed building blocks should be explained." — https://docs.arc42.org/section-5/ (Researcher Lane R-2 §Q2.1, verified 2026-05-12 via WebSearch synthesis).

5. **C4 Level-1 System Context — external dependencies.** "People (e.g. users, actors, roles, or personas) and software systems (external dependencies) that are directly connected to the software system in scope. Typically these other software systems sit outside the scope or boundary of your own software system, and you don't have responsibility or ownership of them." — https://c4model.com/diagrams/system-context (Researcher Lane R-2 §Q2.1, verified 2026-05-12 via WebSearch synthesis).

6. **C4 — dependency-decision support.** "This supports architectural decision-making by making it easier to identify dependencies, assess the scope of changes and explore alternative designs." — https://c4model.com (Researcher Lane R-2 §Q2.1, verified 2026-05-12 via WebSearch synthesis).

7. **MADR — Considered Options requirement (the inventory feeds the MADR).** "The considered options with their pros and cons are crucial to understand the reasons for choosing a particular design, and the MADR project includes such tradeoff analysis information. It's valuable to explicitly list all the serious alternatives that were considered, together with their pros and cons." — https://adr.github.io/madr/ (Researcher Lane R-2 §Q2.1, verified 2026-05-12 via WebSearch synthesis).

8. **ThoughtWorks Tech Radar — rings as the inventory primitive.** "The radar is split into four quadrants: Techniques, Tools, Platforms, and Languages & Frameworks. The radar has four rings, from outer to inner: hold, assess, trial, and adopt." — https://www.thoughtworks.com/en-us/radar/faq (Researcher Lane R-2 §Q2.1, verified 2026-05-12 via WebSearch synthesis).

9. **ThoughtWorks Hold ring — the project-level "do not add" precedent (Option D).** "The hold ring has evolved into our way of saying 'don't start anything new with this technology'. There's no harm in using it on existing projects, but you should think twice about using this technology for new development." — https://www.thoughtworks.com/radar/faq (Researcher Lane R-2 §Q2.1, verified 2026-05-12 via WebSearch synthesis).

10. **ThoughtWorks Assess ring — the pre-adoption inventory state.** "Typically, blips in the Assess ring are things that we think are interesting and worth keeping an eye on." — https://www.thoughtworks.com/radar/faq (Researcher Lane R-2 §Q2.1, verified 2026-05-12 via WebSearch synthesis).

11. **TOGAF Phase scope — applies to Business / Information Systems / Technology Architecture (the framework spans all three).** "Gap analysis is applied during Phase B (Business Architecture), Phase C (Information Systems Architectures), and Phase D (Technology Architecture) of the ADM. The purpose of gap analysis in these phases is to identify the differences between the current state (baseline architecture) and the desired future state (target architecture)." — Visual-Paradigm TOGAF guide aggregator citing Open Group primary, tagged secondary (Researcher Lane R-2 §Q2.1, verified 2026-05-12 via WebSearch synthesis).

---

## Re-verification disclosure

Per Researcher Lane R-2 §9 "Methodology disclosure": 5 of 6 WebFetch attempts denied; one URL (AWS WAF Reliability welcome page) loaded directly but is cited only in ADR-011. All citations in this ADR are via WebSearch synthesis. The Build cycle MUST re-fetch the TOGAF, arc42, C4, MADR, and ThoughtWorks pages before committing the agents/architect.md and templates/PROJECT-PLAN.template.md changes. The TOGAF phase-applicability quote is tagged secondary (aggregator pointing at Open Group primary) — re-verify against the primary URL.

---

## More Information

- Architecture doc: `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (C2 cluster), §4 (Q2.1), §7 (Lane R-2 dispatch), §8 (cross-reference to F-09 RESOLVED).
- Researcher output: `docs/research/architecture-pre-recommendation-discipline-2026-05-12.md` §Q2.1, §Citations.
- Companion ADRs: `docs/adr/011-scale-readiness-commitment.md` (pre-recommendation gate for scale-readiness; same intake-shape), `docs/adr/014-spectrum-vs-binary-discipline.md` (Spectrum/Categories step; same intake-shape), `docs/adr/015-competitor-roster.md` (the project-level "competitive landscape" sister artifact).
- Framework-internal precedent: `skills/find-similar-implementations/SKILL.md` (code-level reuse-lookup sibling; F-09 RESOLVED); `templates/PROJECT-PLAN.template.md` (target file for the optional `hold:` slot); `agents/architect.md` (target file for the agent-step).
