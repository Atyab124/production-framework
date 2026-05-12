# ADR-016 — Cross-Cutting Pattern Audit (Two-Pass Sweep for Unknown Pattern Discovery)

**Status:** Proposed (Pass 3 of Pattern A; awaits Build cycle)
**Date:** 2026-05-12
**Author:** Atyab Rehman
**Producer-Consumer pass:** Researcher Pass 2 → Architect Pass 3 (this doc)
**Researcher inputs:**
- `docs/research/research-methodology-framing-2026-05-12.md` (Lane R-1, Q5.1 — codebase audit tools, Q5.2 — architecture review boards, Q5.3 — anti-NIH canonical naming)

**Source feedback items addressed:** Item 4 (no duplicate-implementation detection pass — framework finds symptoms per feature, doesn't aggregate "you've reinvented X in N places").

**Architecture doc reference:** `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (Cluster C5), §4 (Q5.1, Q5.2, Q5.3), §7 (Lane R-1 dispatch).

---

## Context and Problem Statement

The TaskIt 2026-05-11 feedback log (Item 4) observed that the framework's existing `find-similar-implementations` skill operates per-feature — it asks "what existing helpers should this new feature reuse?" but does not aggregate across the project to ask "are we expressing the same architectural intent in N different places?" The result: a project ships N variants of the same primitive (e.g., "tenant scoping," "audit logging," "soft-delete sentinel") because each variant is justified in isolation. The framework finds symptoms per feature but doesn't surface the meta-pattern.

The framework needs a project-wide sweep cycle that (a) detects code-block duplication via off-the-shelf tooling (the named-feature layer), and (b) surfaces architectural-pattern duplication that no off-the-shelf tool detects (the gap layer that pattern catalogs and audit tools both leave open).

---

## Decision Drivers

1. **4/5 BINDING precedent (Researcher Q5.1) on named code-block duplication as a first-class audit-tool feature.** SonarQube, CodeClimate, jscpd, CodeQL all treat cross-file duplication as a built-in named feature. The fifth tool (CodeClimate Cognitive Complexity) operates per-function and is included for contrast.
2. **Named gap (Researcher Q5.1) — none of the surveyed tools surface architectural-pattern-level duplication automatically.** The named-feature class finds *code-block* duplication, not *pattern* duplication. The architectural-pattern level remains emergent. This is the actual gap Item 4 names.
3. **4/4 BINDING precedent (Researcher Q5.2) on ARB anti-duplication mandate.** Google Readability + AWS ARB + LeanIX ARB + modern ARB (InfoWorld + Conexiam) all include "preventing duplication of primitives" as a named board function. The modern-ARB shift toward guilds + template libraries + reference architectures is the closest enterprise analog to PF v2's STACK-PATTERNS.md template-library approach.
4. **No canonical name (Researcher Q5.3) — use the citation stack instead.** DRY + Rule of Three + NIH-as-pathology collectively cover the territory; no single Fowler-catalog name unifies them. PF v2 cites the stack rather than coining a new term.
5. **N≥3 promotion threshold already aligned with Rule of Three.** The framework's existing `proposing-patterns` Path A (≥3 incidents) matches Fowler's Rule of Three precisely. No new threshold needed — the existing one carries forward.

---

## Considered Options

### Option A — Rely on off-the-shelf tools (SonarQube, jscpd) and call it done

Wire SonarQube or jscpd into CI; the duplication report is the audit.

- **Pros:** Zero new framework surface; off-the-shelf tool ownership.
- **Cons:** Researcher Q5.1 explicitly named the gap: code-block duplication is not architectural-pattern duplication. Two implementations of "tenant scoping" using different variable names, different function shapes, but identical semantic intent will not show up in a Rabin-Karp scan (jscpd) or an AST clone-detector (SonarQube). The gap layer is the actual fix.
- **Status:** Neglected as the universal answer. Composed-with-Option-B as the first layer.

### Option B — New skill `cross-cutting-pattern-audit` running a two-pass sweep on a cadence

Pass 1: automated code-block duplication via jscpd / SonarQube / CodeQL (whichever the project ships). Pass 2: human/Architect/Code-Reviewer-driven architectural-pattern audit asking "are these N occurrences expressing the same architectural intent?" Cadence: every M build cycles (architecture doc §2 File List suggests M=3, aligning with Rule of Three).

- **Pros:** Composes the named-feature layer (Pass 1) with the gap layer (Pass 2). Aligns with modern-ARB shift (guilds + template libraries + reference architectures per Researcher Q5.2). Composes with `proposing-patterns` Path A (which the audit feeds — when ≥3 cross-cutting occurrences are found, the audit produces a Path A proposal).
- **Cons:** Adds a new skill. Mitigated because the skill body is short — it's a runbook for "run the tool, then run the question" rather than a deep grammar.
- **Status:** **Chosen.**

### Option C — Extend `proposing-patterns` with Path C (detection-cadence)

Don't introduce a new skill; instead extend the existing `proposing-patterns` skill with a third ingest path (the same Path C that ADR-013 introduces for enforcement-mode promotion).

- **Pros:** Single-skill home for cross-cutting pattern work.
- **Cons:** ADR-013's Path C is for "convention → structural-check" promotion of *known* patterns. ADR-016's purpose is the discovery of *unknown* patterns. Different goal, different inputs (existing pattern rows vs codebase scan). Conflating them in one Path C overloads the skill.
- **Status:** **Composed with Option B** — the new `cross-cutting-pattern-audit` skill outputs proposals that feed `proposing-patterns` Path A (≥3 incidents threshold). ADR-013's Path C and ADR-016's audit run in parallel, not interleaved.

### Option D — Architect-only sweep, no skill

The Architect runs the sweep as part of every refactor-cycle dispatch.

- **Pros:** No new skill body.
- **Cons:** The sweep is not cycle-shaped; it is cadenced (every M cycles). Forcing it into the Architect's per-cycle workflow either fires too often or never fires.
- **Status:** Neglected.

---

## Decision Outcome

**Chosen:** **Option B (new skill `cross-cutting-pattern-audit`)** + **Option C's composition rule (audit output feeds `proposing-patterns` Path A)**.

### Skill shape

`skills/cross-cutting-pattern-audit/SKILL.md` (new). Body is a runbook with two passes:

**Pass 1 — automated code-block duplication.** Choose the off-the-shelf tool per project stack: SonarQube (cross-project since 2.11), CodeClimate, jscpd, or CodeQL custom query. Run against the project's source tree. Output: a duplication report.

**Pass 2 — architectural-pattern audit.** The Architect (or Code-Reviewer agent) reviews the Pass 1 report and asks for each cluster: "are these N occurrences expressing the same architectural intent, even if the code-block signatures differ?" Output: a list of candidate pattern-promotion proposals.

For each candidate where N≥3 (Rule of Three trigger), the skill outputs a `docs/pattern-proposals/{date}-{id}.md` file using the `proposing-patterns` Path A schema. The proposal cites the DRY + Rule of Three + NIH-as-pathology citation stack (Q5.3) plus the specific code locations.

### Cadence

The skill runs every M build cycles (recommend M=3, matching the Rule of Three). Cadence is enforced by the framework's existing cycle-state tracker (architecture doc §2 File List — `docs/cycle-state.md` already tracks cycle count). If M cycles pass without `cross-cutting-pattern-audit` having fired, the next CTO dispatch surfaces a recommendation to run the audit.

### Composition with `proposing-patterns`

- `proposing-patterns` Path A — ≥3 incidents → audit-output proposal (this ADR's output feeds Path A).
- `proposing-patterns` Path B — enterprise-research-first BINDING → unchanged.
- `proposing-patterns` Path C — proactive enforcement-mode promotion (ADR-013) → unchanged, runs independently.

### Naming discipline (citation stack rather than new term)

Per Researcher Q5.3 finding "there is no single canonical name," the skill cites three principles in its frontmatter description, never coining a new term:

- **DRY** (Hunt & Thomas 1999) — what the audit enforces (one authoritative representation per piece of knowledge).
- **Rule of Three** (Fowler / Roberts) — when the audit fires a proposal (N≥3 occurrences).
- **Anti-NIH posture** (Katz & Allen 1982) — why the audit is structurally required (organizational pathology counter-measure).

### Disclosure: PF v2 fills a gap that no surveyed audit tool fills

Per Researcher Q5.1 finding — "none of the tools surveyed surface the *meta-pattern*" — the architectural-pattern level (Pass 2) is novel relative to the off-the-shelf tooling space. The framework discloses this honestly rather than implying enterprise consensus exists for an "architectural-pattern duplication detector."

---

## Consequences

### Positive

- Detects pattern duplication that no off-the-shelf tool finds; the gap layer is the actual fix.
- Composes with the existing `proposing-patterns` Path A — audit output is a Path A input.
- Cadenced (every M=3 cycles), not per-cycle — avoids the ceremony-cost failure mode.
- Cites DRY + Rule of Three + NIH-as-pathology rather than coining a new term — aligned with the framework's existing CLAUDE.md citation discipline.
- Aligned with modern-ARB shift (guilds + template libraries + reference architectures per Q5.2) — PF v2's STACK-PATTERNS.md template library plays the modern-ARB role.

### Negative

- One new skill body. Mitigated because the skill is a short runbook.
- Cadence-enforcement requires the existing `docs/cycle-state.md` tracker to surface the "M cycles elapsed" signal. The mechanism exists; this ADR just adds one consumer.
- Pass 1 tool choice is stack-specific. The skill body lists tool options; project-level decision lives in `docs/STACK-PATTERNS.md` (or equivalent project file), not in `skills/` (per CLAUDE.md rejection criterion #3).
- The audit's Pass 2 architectural review is Architect / Code-Reviewer judgment — not mechanically checkable. This is the right design (the gap is precisely that no tool checks it) but it does mean the audit is human-effort-shaped.

### Consequence path (what the ADR will eventually drive — NOT implemented here)

The downstream Build cycle implements:

- `skills/cross-cutting-pattern-audit/SKILL.md` — new skill body with the two-pass runbook and DRY + Rule-of-Three + NIH-as-pathology citation stack.
- `skills/cycle-selection/SKILL.md` — add a `cross-cutting-pattern-audit` cycle row (per architecture doc §2 File List).
- `skills/cto-mode/SKILL.md` — add the M-cycles-elapsed surfacing rule.
- `skills/proposing-patterns/SKILL.md` — no body change required; the existing Path A consumes the audit output as-is.
- `docs/cycle-state.md` (existing tracker) — add a `last-cross-cutting-audit:` field.
- Project-level STACK-PATTERNS instance: list of off-the-shelf tools for Pass 1 (Semgrep, jscpd, SonarQube, CodeClimate, CodeQL) per stack.

No source code is written by this ADR.

---

## Citations (verbatim, with re-verification flag)

All Researcher citations are tagged `(via WebSearch synthesis of canonical URL)` per Lane R-1 §"Methodology disclosure." Re-verification before Build-cycle implementation is required.

1. **SonarQube — cross-project duplication detection (Pass 1 tool option).** "Sonar 2.11 introduced cross-project duplication detection for Java, significantly expanding the ability to identify shared clones across an entire codebase portfolio." — https://www.sonarsource.com/blog/manage-duplicated-code-with-sonar (Researcher Lane R-1 §Q5.1, verified 2026-05-12 via WebSearch synthesis).

2. **CodeClimate — AST-based identical-code + similar-code detection (Pass 1 tool option).** "Code Climate has two maintainability checks for duplication: identical-code and similar-code. Code is identical when all operations & values are identical. Code is similar when the overall structure is the same, but the particular operations & values under consideration might be different." — https://docs.codeclimate.com/docs/duplication-concept (Researcher Lane R-1 §Q5.1, verified 2026-05-12 via WebSearch synthesis).

3. **jscpd — Rabin-Karp + 150+ language support (Pass 1 tool option, purpose-built).** "The jscpd tool implements Rabin-Karp algorithm for searching duplications." "Supports 150+ programming languages." — https://github.com/kucherenko/jscpd (Researcher Lane R-1 §Q5.1, verified 2026-05-12 via WebSearch synthesis).

4. **CodeQL — semantic queryable-code engine (Pass 1 tool option, user-authored queries).** "CodeQL is a semantic code analysis engine that treats code as queryable data." "Custom queries extend CodeQL's built-in security analysis to detect vulnerabilities, coding standards, and patterns specific to your codebase." — https://codeql.github.com/ + https://docs.github.com/en/code-security/concepts/code-scanning/codeql/custom-codeql-queries (Researcher Lane R-1 §Q5.1, verified 2026-05-12 via WebSearch synthesis).

5. **Google Readability reviewer — anti-duplication via "recommended patterns and libraries" (Q5.2 ARB precedent).** "With tens of thousands of developers committing code, an additional reviewer ensures that everyone is committing code that matches the lengthy language standards and is using the recommended patterns and libraries." — https://google.github.io/eng-practices/review/reviewer/standard.html (Researcher Lane R-1 §Q5.2, verified 2026-05-12 via WebSearch synthesis).

6. **AWS Architecture Review Board — anti-debt mandate.** "The ARB helps identify and mitigate technical debt early in the design phase. By enforcing architectural standards and promoting best practices, the board helps ensure that decisions are made with long-term sustainability in mind." — https://aws.amazon.com/blogs/architecture/build-and-operate-an-effective-architecture-review-board/ (Researcher Lane R-1 §Q5.2, verified 2026-05-12 via WebSearch synthesis).

7. **Modern ARB transformation — guilds prevent duplication (the closest analog to PF v2's STACK-PATTERNS).** "Guilds and communities of practice create horizontal knowledge sharing. Teams working on similar problems share insights and align on common approaches. This prevents the duplication and inconsistency that traditional ARBs were designed to address." — https://www.infoworld.com/article/3607426/how-to-transform-your-architecture-review-board.html (Researcher Lane R-1 §Q5.2, verified 2026-05-12 via WebSearch synthesis).

8. **Modern ARB — template libraries accelerate reuse.** "Template libraries and reference architectures accelerate good practices. Instead of reinventing solutions for common problems, teams can start with proven patterns and adapt them to their specific needs." — https://www.infoworld.com/article/3607426/how-to-transform-your-architecture-review-board.html (Researcher Lane R-1 §Q5.2, verified 2026-05-12 via WebSearch synthesis).

9. **DRY (Hunt & Thomas 1999) — canonical statement (citation-stack member 1).** "Every piece of knowledge must have a single, unambiguous, authoritative representation within a system." — Hunt & Thomas, *The Pragmatic Programmer* (1999), as cited at https://en.wikipedia.org/wiki/Don't_repeat_yourself (Researcher Lane R-1 §Q5.3, verified 2026-05-12 via WebSearch synthesis).

10. **Rule of Three (Fowler / Roberts) — timing trigger (citation-stack member 2).** "Two instances of similar code do not require refactoring, but when similar code is used three times, it should be extracted into a new procedure." "The rule was popularised by Martin Fowler in Refactoring and attributed to Don Roberts." — https://en.wikipedia.org/wiki/Rule_of_three_(computer_programming) (Researcher Lane R-1 §Q5.3, verified 2026-05-12 via WebSearch synthesis).

11. **NIH syndrome (Katz & Allen 1982) — organizational-pathology name (citation-stack member 3).** "A 1982 study by Ralph Katz and Thomas J. Allen provides empirical evidence for the 'not invented here' syndrome, showing that the performance of R&D project groups declines after about five years, which they attribute to the groups becoming increasingly insular and communicating less with key information sources outside the group." — https://en.wikipedia.org/wiki/Not_invented_here (Researcher Lane R-1 §Q5.3, verified 2026-05-12 via WebSearch synthesis).

12. **Roberts & Johnson "Three Examples" pattern (Rule-of-Three predecessor; reinforces N≥3).** "Roberts and Johnson's 'Three Examples' pattern advises to build an application, build a second application that is slightly different from the first, and finally build a third application that is even more different than the first two, where provided that all of the applications fall within the problem domain, common abstractions will become apparent." — https://en.wikipedia.org/wiki/Rule_of_three_(computer_programming) (Researcher Lane R-1 §Q5.3, verified 2026-05-12 via WebSearch synthesis).

---

## Re-verification disclosure

Per Researcher Lane R-1 §"Methodology disclosure": WebFetch was permission-denied throughout. Every quote is via WebSearch synthesis. The Wikipedia citations for DRY / Rule of Three / NIH point at canonical first-source publications via tertiary-aggregator surface; the Build cycle SHOULD re-verify against the live Wikipedia pages and ideally against the originals (Hunt & Thomas 1999; Fowler *Refactoring*; Katz & Allen 1982 study) before committing the skill body.

---

## More Information

- Architecture doc: `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (C5 cluster), §4 (Q5.1, Q5.2, Q5.3), §7 (Lane R-1 dispatch).
- Researcher output: `docs/research/research-methodology-framing-2026-05-12.md` §Q5.1, §Q5.2, §Q5.3, §Citations.
- Companion ADRs: `docs/adr/013-pattern-enforcement-audit.md` (sibling — Path C handles known-pattern enforcement-mode promotion; this ADR handles unknown-pattern discovery).
- Framework-internal precedent: `skills/find-similar-implementations/SKILL.md` (per-feature reuse-lookup; this ADR's project-wide sweep is the sibling); `skills/proposing-patterns/SKILL.md` Path A (≥3 incidents threshold consumes this audit's output); `docs/cycle-state.md` (cadence tracker).
