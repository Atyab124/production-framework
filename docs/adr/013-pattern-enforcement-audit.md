# ADR-013 — Pattern Enforcement Audit (Convention vs Structural Check vs Runtime)

**Status:** Proposed (Pass 3 of Pattern A; awaits Build cycle)
**Date:** 2026-05-12
**Authors:** Production-framework Architect sub-agent (Opus 4.7), Pass 3 consolidation
**Producer-Consumer pass:** Researcher Pass 2 → Architect Pass 3 (this doc)
**Researcher inputs:**
- `docs/research/pattern-enforcement-2026-05-12.md` (Lane R-4a, Q4.1 + Q4.2 + Q4.3 + Q4.4)
- `docs/research/research-methodology-framing-2026-05-12.md` (Lane R-1, Q5.3 — DRY + Rule of Three + NIH citation stack)

**Source feedback items addressed:** Item 8 (security patterns enforced by convention only) and Item 10 (general failure: patterns added to CLAUDE.md without matching structural checks). Item 8 is the narrow case; Item 10 is its generalization.

**Architecture doc reference:** `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (Cluster C4), §4 (Q4.1–Q4.4), §7 (Lane R-4a dispatch).

---

## Context and Problem Statement

The TaskIt 2026-05-11 feedback log surfaced two patterns of the same shape:

- **Item 8 (specific).** Security patterns documented in STACK-PATTERNS.md or project-level CLAUDE.md are enforced by code-review convention only. Example: "Server Action input schema must not contain `userId`" exists as prose; no Semgrep rule, no ESLint plugin, no pre-commit check exists to fail a build if a developer violates it.
- **Item 10 (general).** The pattern-authoring workflow does not require the author to declare whether the pattern is enforced by convention, by structural check, or by runtime gate. A pattern reaches CLAUDE.md / STACK-PATTERNS.md without ever asking the rule-to-check coupling question.

User feedback explicitly pushed back: "why is this just about security patterns?" The general failure mode is rule-without-check. The framework needs a mandatory declaration column for every pattern, plus a structural-check audit cycle that verifies declared `structural-check` patterns actually have an artifact backing them.

---

## Decision Drivers

1. **Authoring-time enforcement is enterprise consensus (3/3 BINDING).** Researcher Q4.1 returned Tricorder + Sorbet + CODEOWNERS — all three couple the rule to the check at authoring time, not via later audit. Disclosure-only-with-audit-later is not the enterprise pattern.
2. **Declared-enforcement-mode is enterprise consensus (4/4 BINDING).** Researcher Q4.2 returned OWASP ASVS + NIST 800-53B + Semgrep + Sorbet — every rule carries first-class metadata about its enforcement mode. The variability is whether the declaration *is* the enforcement (Sorbet) or feeds into a separate policy decision (Semgrep).
3. **Major enterprise pattern catalogs DO NOT carry an enforcement column (3/3 by absence).** Researcher Q4.3 found Microsoft Cloud Design Patterns + AWS Well-Architected + Refactoring Guru all stop at categorization / tradeoff axes / applicability fields. PF v2's proposed `enforcement:` column is therefore **PF v2-specific innovation** — well-supported by Q4.1/Q4.2 deeper precedent (codebase-governance and security-tooling frameworks) but not mirrored in the pattern-catalog tradition.
4. **The canonical structural-check tool for the narrow case (Q4.4) is Semgrep AST/taint mode**, with defense-in-depth via runtime middleware (next-safe-action) and database-layer RLS (Supabase). All three layers compose; no single layer is sufficient alone.
5. **The N≥3 promotion threshold the framework already uses (`proposing-patterns` Path A) is Rule-of-Three-aligned.** Researcher Q5.3 confirmed: "the N≥3 threshold in PF's existing `proposing-patterns` Path A skill (≥3 incidents) is already aligned with the Rule of Three — no new design needed." Use DRY + Rule of Three + NIH-as-pathology as the citation stack rather than coining a new term.

---

## Considered Options

### Option A — Continue current model: pattern body in STACK-PATTERNS.md as prose; enforcement is implicit / code-review-only

Status quo. Patterns are descriptive; enforcement is human discipline.

- **Pros:** Zero new template surface; aligned with the descriptive tradition of MS/AWS/Refactoring Guru pattern catalogs (3/3 by absence).
- **Cons:** Reproduces Items 8 and 10 exactly — patterns ship without checks. The framework's own `enterprise-research-first` skill exists to counter this rationalization pattern at the research layer; the same discipline should apply at the pattern-authoring layer.
- **Status:** Neglected.

### Option B — Add an `enforcement:` column to STACK-PATTERNS rows (Sorbet sigil precedent)

Every pattern row declares `enforcement: convention | structural-check | runtime`. Where `structural-check` is declared, the row MUST cite a mechanical-check artifact path (script, Semgrep rule, ESLint rule, hook). Where `runtime` is declared, the row MUST cite the runtime-gate artifact (middleware, RLS policy, etc.).

- **Pros:** Declaration-as-enforcement aligned with Sorbet sigil precedent (Q4.1 + Q4.2 cross-citation). Mechanically auditable: a structural check can verify that every `structural-check` row's cited artifact exists.
- **Cons:** Adds a column to STACK-PATTERNS.md schema. Mitigated because the column is one enum + one artifact path.
- **Status:** **Chosen as the core mechanism.**

### Option C — Generate Semgrep rules from STACK-PATTERNS rows automatically

Treat STACK-PATTERNS.md as the source-of-truth; auto-generate Semgrep rule files from declared patterns.

- **Pros:** Strongest possible coupling — the rule and the check are literally the same artifact.
- **Cons:** Stack-specific (Semgrep is the chosen tool for the TaskIt-class stack; not all PF-using stacks ship Semgrep). Per CLAUDE.md rejection criterion #3 ("Add a stack reference to `core/` — language, framework, or service names. Extract to `templates/`"), the rule-generation tool belongs in a downstream stack template, not in the framework core.
- **Status:** Neglected at the framework core layer; recommended at the project-template layer (TaskIt-class STACK-PATTERNS instance).

### Option D — Path C "proactive pattern-enforcement audit" added to `proposing-patterns` skill

Beyond the existing Path A (≥3 incidents) and Path B (enterprise-research binding), add a Path C: cadenced audit of existing STACK-PATTERNS rows asking "which `convention`-tagged rows should become `structural-check`?"

- **Pros:** Composes with the existing `proposing-patterns` skill; doesn't introduce a new skill.
- **Cons:** Path C is not the core fix — it's a discovery mechanism. The core fix is Option B (the column itself).
- **Status:** **Composed with Option B** — Option B introduces the column; Option D adds the audit cycle that pressures rows toward higher enforcement modes.

---

## Decision Outcome

**Chosen:** **Option B (enforcement column) + Option D (Path C audit) + Q4.4 defense-in-depth stack for the TaskIt-class STACK-PATTERNS instance.**

### Core mechanism (Option B)

Every STACK-PATTERNS row carries a mandatory `enforcement:` column with one of three values:

| Value | Meaning | Required additional field |
|---|---|---|
| `convention` | Rule documented; enforced by code-review and discipline. No mechanical check exists. | None. But: the audit cycle (Path C) periodically pressures these to higher-enforcement modes. |
| `structural-check` | Rule has a mechanical check artifact that runs at authoring or CI time. | `check_artifact:` field — path to the script / Semgrep rule / ESLint rule / hook / pre-commit. The structural check itself fails if the cited artifact does not exist (declaration-as-enforcement, Sorbet sigil precedent). |
| `runtime` | Rule is enforced by runtime gate (middleware, RLS policy, framework-level closure encryption). | `runtime_gate:` field — file path or library reference for the gate. |

### Audit cycle (Option D — `proposing-patterns` Path C)

The `proposing-patterns` skill gains a third ingest path (Path C — proactive pattern-enforcement audit), invoked on a cadence (architecture doc §2 suggests "every 3 build cycles"). Path C input: existing `convention`-tagged rows. Path C output: a proposal file at `docs/pattern-proposals/{date}-{id}.md` for each row that should be promoted to `structural-check`. Promotion criteria modeled on DRY + Rule of Three + NIH-as-pathology citation stack (Q5.3):

- **DRY trigger:** the rule appears in ≥2 distinct contexts (project-level prose + framework-level prose) — the duplication signal.
- **Rule-of-Three trigger:** the rule has been violated and code-review-caught ≥3 times across cycles — the timing signal.
- **NIH-as-pathology trigger:** the rule could be enforced by a 3rd-party tool (Semgrep, ESLint plugin, off-the-shelf hook) but is being enforced by hand — the organizational-pathology signal.

A promotion proposal cites at least two of the three triggers, plus an `enforcement_artifact_proposed:` field naming the specific check.

### Q4.4 defense-in-depth stack (TaskIt-class STACK-PATTERNS instance)

For the narrow case Item 8 ("Server Action input must not contain `userId`"), the STACK-PATTERNS row gains:

- `enforcement: structural-check` with `check_artifact:` pointing at a Semgrep rule (taint-mode or pattern-based) flagging Zod schemas in `'use server'` files that include identity-field names. Configurable list: `userId`, `accountId`, `tenantId`, `orgId`.
- Companion `enforcement: runtime` row with `runtime_gate:` pointing at the `next-safe-action` `authActionClient` middleware that injects `userId` into `ctx`.
- Companion `enforcement: runtime` row for the database-layer floor, `runtime_gate:` pointing at the RLS policy template using `auth.uid()`.

The three layers compose; the structural check catches the source-code antipattern, the middleware catches the symptom at request time, the RLS catches the data-layer breach.

### Disclosure: PF v2 is more structured than the enterprise pattern-catalog baseline

Per Researcher Q4.3 §"Recommendation" — "Document this as PF v2-specific innovation in ADR-013, not as enterprise-standard." The enforcement column is **not** mirrored in Microsoft Cloud Design Patterns, AWS Well-Architected, or Refactoring Guru. The framework is deliberately more structured than the enterprise pattern-catalog baseline on this axis, justified by the deeper-layer evidence: Q4.1 (codebase governance) and Q4.2 (security tooling) both BIND on declared-enforcement-mode as a meta-requirement.

---

## Consequences

### Positive

- Every pattern declares its enforcement mode at authoring time — replaces "we'll enforce by code review" with controlled metadata (Sorbet sigil precedent).
- Structural checks that cite a non-existent artifact fail their own audit — declaration-as-enforcement.
- Path C audit cycle creates ongoing pressure toward higher-enforcement modes, citing DRY + Rule of Three + NIH-as-pathology rather than coining a new term.
- The Q4.4 defense-in-depth stack composes static + runtime + data-layer for the narrow Item 8 case.
- Composes with ADR-016 (cross-cutting-pattern-audit) — Path C runs the "should X become structural?" pressure; ADR-016 runs the "are we reinventing X?" detection.

### Negative

- One new mandatory column in STACK-PATTERNS.md schema. Mitigated by trivial diff size.
- The enforcement column is a PF v2 innovation absent from the major pattern catalogs. The framework discloses this honestly rather than implying enterprise consensus exists.
- Path C audit cycle adds a third ingest path to `proposing-patterns` — increases the skill's surface area.
- TaskIt-class Semgrep tooling is stack-specific. The Build cycle MUST extract the Semgrep rule artifact to `templates/STACK-PATTERNS.template.md` example or to a project-local file, NOT into `skills/` or `agents/` (per CLAUDE.md rejection criterion #3).

### Consequence path (what the ADR will eventually drive — NOT implemented here)

The downstream Build cycle implements:

- `templates/STACK-PATTERNS.template.md` — add the `enforcement:` column + `check_artifact:` + `runtime_gate:` fields.
- `skills/proposing-patterns/SKILL.md` — add Path C "proactive pattern-enforcement audit" ingest path with DRY + Rule-of-Three + NIH-as-pathology trigger logic.
- `scripts/qa-structural-checks.sh` — add a check that verifies every `enforcement: structural-check` row's `check_artifact:` path exists on disk.
- `templates/STACK-PATTERNS.template.md` example rows (TaskIt-class): Semgrep rule for `userId` in Server Action schemas; `next-safe-action` middleware; Supabase RLS template.
- Project-local files at the TaskIt-class instance (NOT framework core): the actual Semgrep rule YAML and the actual RLS policy SQL.

No source code is written by this ADR.

---

## Citations (verbatim, with re-verification flag)

All Researcher citations are tagged `(via WebSearch synthesis of canonical URL)` per Lane R-4a §10 (WebFetch was permission-denied throughout). Re-verification before Build-cycle code change is required.

1. **Google Tricorder — 10% false-positive contract (Sadowski et al., ICSE 2015 / Google SWE book Ch. 20).** "Analysis results shown during code review are allowed to include up to 10% effective false positives, with the expectation that feedback is not always perfect and that authors evaluate proposed changes before applying them." "The Tricorder team tracks not-useful clicks, computing the ratio of 'Please fix' vs. 'Not useful' clicks, and if the ratio for an analyzer goes above 10%, the Tricorder team disables the analyzer until the author(s) improve it." — https://abseil.io/resources/swe-book/html/ch20.html (Researcher Lane R-4a §9 [C-Q4.1-a], verified 2026-05-12 via WebSearch synthesis).

2. **Sorbet — file-sigil declares enforcement level (declaration-as-enforcement, the chosen pattern).** "A # typed: sigil is a comment placed at the top of a Ruby file, indicating to Sorbet which errors to report and which to silence. The available strictness levels are (from most permissive to most strict): ignore, false, true, strict, and strong." — https://sorbet.org/docs/static (Researcher Lane R-4a §9 [C-Q4.1-b], verified 2026-05-12 via WebSearch synthesis).

3. **Shopify — Sorbet enforced in CI (rule-to-check coupling at authoring time).** "On Shopify's main monolith, they require all files to be at least typed: false and Sorbet is run on their continuous integration platform for every PR, failing builds if type checking errors are found. As of the time of reporting, 80% of their files (including tests) are typed: true or higher." — https://shopify.engineering/the-state-of-ruby-static-typing-at-shopify (Researcher Lane R-4a §9 [C-Q4.1-c], verified 2026-05-12 via WebSearch synthesis).

4. **GitHub CODEOWNERS + branch protection (rule-to-check coupling at merge time).** "If you enable code owner reviews, any pull request that affects code with a code owner must be approved by that code owner before the pull request can be merged into the protected branch." — https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners (Researcher Lane R-4a §9 [C-Q4.1-d], verified 2026-05-12 via WebSearch synthesis).

5. **OWASP ASVS — cumulative levels with per-requirement IDs (declared-enforcement-mode precedent).** "ASVS levels are cumulative, meaning Level 2 includes all Level 1 requirements, and Level 3 includes everything from Levels 1 and 2." "Each requirement has an identifier in the format <chapter>.<section>.<requirement>." — https://owasp.org/www-project-application-security-verification-standard/ (Researcher Lane R-4a §9 [C-Q4.2-a], verified 2026-05-12 via WebSearch synthesis).

6. **NIST 800-53B — cumulative baselines (declared-enforcement-mode precedent).** "NIST SP 800-53B defines three security control baselines (one for each system impact level — low-impact, moderate-impact, and high-impact)." "The Low baseline has the least amount of controls (149 controls)... The Moderate baseline contains 287 controls... The High baseline prescribes the most controls and control enhancements, with a total of 370." — https://csrc.nist.gov/pubs/sp/800/53/b/upd1/final (Researcher Lane R-4a §9 [C-Q4.2-b], verified 2026-05-12 via WebSearch synthesis).

7. **Semgrep — severity as per-rule mandatory metadata.** "Semgrep supports three main severity levels: INFO, WARNING, and ERROR." — https://semgrep.dev/docs/kb/rules/understand-severities (Researcher Lane R-4a §9 [C-Q4.2-c], verified 2026-05-12 via WebSearch synthesis).

8. **Microsoft Cloud Design Patterns — pattern template structure (no enforcement column).** "Each pattern is provided in a common format that describes the context and problem, the solution, issues and considerations for applying the pattern, and an example based on Microsoft Azure." — https://learn.microsoft.com/en-us/azure/architecture/patterns/ (Researcher Lane R-4a §9 [C-Q4.3-a], verified 2026-05-12 via WebSearch synthesis).

9. **AWS Well-Architected — tradeoff documentation (no enforcement column).** "AWS discusses trade-offs to consider when implementing resilience patterns, including: 1) design complexity, 2) cost to implement, 3) operational effort, 4) effort to secure, and 5) environmental impact." — https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html (Researcher Lane R-4a §9 [C-Q4.3-b], verified 2026-05-12 via WebSearch synthesis).

10. **Refactoring Guru — applicability field but no enforcement column.** "Some pattern catalogs list other useful details, such as applicability of the pattern, implementation steps and relations with other patterns. The site also emphasizes trade-offs in pattern usage." — https://refactoring.guru/design-patterns (Researcher Lane R-4a §9 [C-Q4.3-c], verified 2026-05-12 via WebSearch synthesis).

11. **Next.js / Vercel security guidance — Server Action DAL + closure-encryption (Q4.4 application-layer convention).** "A Data Access Layer can be applied to both reading and mutations, which keeps authentication, authorization, and database logic in a dedicated server-only module, while 'use server' actions stay thin." "In Next.js 14, the closed over variables are encrypted with the action ID before sent to the client." — https://nextjs.org/blog/security-nextjs-server-components-actions (Researcher Lane R-4a §9 [C-Q4.4-a], verified 2026-05-12 via WebSearch synthesis).

12. **next-safe-action — middleware-injected `userId` context (Q4.4 runtime gate).** "Context is a special object that holds information about the current execution state. This object is passed to middleware functions and server code functions when defining actions." "You can define authorization middleware using `.use()` that retrieves session information from cookies, validates it, and returns the next middleware with a `userId` value in the context." — https://next-safe-action.dev/docs/define-actions/middleware (Researcher Lane R-4a §9 [C-Q4.4-b], verified 2026-05-12 via WebSearch synthesis).

13. **Semgrep taint mode — AST-level structural check (Q4.4 chosen primary).** "To create a taint tracking rule, include mode: taint in the rule's YAML definition file. This enables operators that act as pattern-either operators, taking a list of patterns that specify what is considered a source, a propagator, a sanitizer, or a sink." — https://semgrep.dev/docs/writing-rules/data-flow/taint-mode/overview (Researcher Lane R-4a §9 [C-Q4.4-c], verified 2026-05-12 via WebSearch synthesis).

14. **Supabase RLS — database-layer enforcement using `auth.uid()` (Q4.4 data-layer floor).** "RLS policies function as WHERE clauses that PostgreSQL appends to every query automatically — USING (user_id = auth.uid()) becomes WHERE user_id = auth.uid() on every SELECT." "RLS is default-deny — when you enable RLS on a table and add no policies, zero rows are returned, ensuring secure defaults." — https://supabase.com/docs/guides/database/postgres/row-level-security (Researcher Lane R-4a §9 [C-Q4.4-d], verified 2026-05-12 via WebSearch synthesis).

15. **DRY + Rule of Three + NIH-as-pathology citation stack (Path C trigger rationale, from Q5.3).** "Don't Repeat Yourself: 'Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.'" — Hunt & Thomas (1999), via https://en.wikipedia.org/wiki/Don't_repeat_yourself . "Rule of Three: two instances of similar code do not require refactoring, but when similar code is used three times, it should be extracted into a new procedure." — Fowler, via https://en.wikipedia.org/wiki/Rule_of_three_(computer_programming) . "Not Invented Here syndrome: a 1982 study by Ralph Katz and Thomas J. Allen provides empirical evidence for the 'not invented here' syndrome, showing that the performance of R&D project groups declines after about five years." — https://en.wikipedia.org/wiki/Not_invented_here (Researcher Lane R-1 §Q5.3, verified 2026-05-12 via WebSearch synthesis).

---

## Re-verification disclosure

Per Researcher Lane R-4a §10 and Lane R-1 methodology disclosure: WebFetch was permission-denied throughout. Every quote is via WebSearch synthesis. The Build cycle MUST re-fetch each canonical URL before committing the `enforcement:` column code change. The Tricorder 10%-threshold quote and the Next.js closure-encryption quote are specifically flagged in Lane R-4a §11 for re-verification before ratification.

---

## More Information

- Architecture doc: `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (C4 cluster), §4 (Q4.1–Q4.4), §7 (Lane R-4a dispatch), §8 cross-reference to F-V20 RESOLVED (sub-agent tier-selection inheritance check).
- Researcher outputs: `docs/research/pattern-enforcement-2026-05-12.md` §Q4.1–§Q4.4, §Citations, §11 Concerns; `docs/research/research-methodology-framing-2026-05-12.md` §Q5.3.
- Companion ADRs: `docs/adr/014-spectrum-vs-binary-discipline.md` (the validation-question-count drift implication is reconciled there), `docs/adr/016-cross-cutting-pattern-audit.md` (the detection-of-unknown-patterns sibling).
- Framework-internal precedent: `skills/proposing-patterns/SKILL.md` Path A (≥3 incidents — Rule-of-Three aligned per Q5.3) and Path B (research-backed binding); `scripts/qa-structural-checks.sh` (target file for the new enforcement-artifact-exists check).
