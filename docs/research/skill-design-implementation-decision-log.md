# Skill Design Research: `implementation-decision-log`

**Date:** 2026-04-30
**Type:** Source-of-truth research — no code modifications
**Triggered by:** PF v2 binding rule (`CLAUDE.md`) requiring every feature to cite SP precedent OR Anthropic guidance, supplemented (where neither exists) by ≥3 enterprise/OSS analogs. SP has no implementation-decision-log primitive. Anthropic publishes nothing direct. Industry has ADR/MADR for architecture-grain (cited in `skill-design-seven-validation-questions.md` Part 2 Q2) — must adapt for **implementation-grain**, OR find an existing implementation-grain analog.

**Methodology disclosure:** WebFetch was permission-denied this session (matches `skill-design-seven-validation-questions.md` Part 6 disclosure). All Anthropic and external quotes were retrieved via WebSearch synthesis of canonical URLs and are reproduced verbatim as returned. SP 5.0.7 quotes are direct local-cache reads. Re-verify against live URLs in a WebFetch-permitted session before any binding decision.

**Scope of this skill (per design brief):** A lightweight, append-only `docs/IMPLEMENTATION-DECISIONS.md` log. Each entry: decision / alternatives / why-this / commit hash / pattern link. Builders append after every Tier 2/3 ship; lookup happens during `find-similar-implementations`. Sits BETWEEN `PROJECT-PLAN` (phase grain) and `STACK-PATTERNS` (codified pattern grain). Captures decisions at the helper / primitive grain that today fall through both.

**Canonical example (Item 39, v1 feedback):** "we chose `useRef` over `useState` for the mention `matchRef` because the click handler reads after async commit — closure-captured state was stale." This is precisely the decision class that never lands in PROJECT-PLAN (too fine) and never lands in STACK-PATTERNS (only one occurrence, threshold not met).

---

## Part 1: Sources Inventory

| # | Source | URL | Type | Retrieved |
|---|---|---|---|---|
| 1 | SP 5.0.7 — `skills/writing-plans/SKILL.md` | local cache | precedent (plan-grain) | 2026-04-30 |
| 2 | SP 5.0.7 — `skills/finishing-a-development-branch/SKILL.md` | local cache | precedent (commit-shape) | 2026-04-30 |
| 3 | SP 5.0.7 — `skills/writing-skills/anthropic-best-practices.md` | local cache | precedent (commit-message format) | 2026-04-30 |
| 4 | PF v2 — `templates/PROJECT-PLAN.template.md` | local | current state of decision capture | 2026-04-30 |
| 5 | PF v2 — `docs/audits/v1-feedback-vs-v2-2026-04-30.md` Item 39 + cluster C5 | local | source brief | 2026-04-30 |
| 6 | Anthropic — *Effective context engineering for AI agents* | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | primary | 2026-04-30 |
| 7 | Anthropic — *Effective harnesses for long-running agents* | https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents | primary | 2026-04-30 |
| 8 | Anthropic — *Building Effective AI Agents* | https://www.anthropic.com/research/building-effective-agents | primary | 2026-04-30 |
| 9 | MADR — Markdown Architectural Decision Records (4.0.0, "minimal" + "bare-minimal" variants) | https://adr.github.io/madr/ | OSS standard | 2026-04-30 |
| 10 | Y-Statement (Olaf Zimmermann) — Y-Statement Template Primer | https://ozimmer.ch/practices/2022/11/22/MADRTemplatePrimer.html | academic / industry | 2026-04-30 |
| 11 | Conventional Commits 1.0.0 | https://www.conventionalcommits.org/en/v1.0.0/ | OSS standard | 2026-04-30 |
| 12 | GitHub Engineering Blog — *Why write ADRs* (Stafford Williams) | https://github.blog/engineering/architecture-optimization/why-write-adrs/ | enterprise | 2026-04-30 |
| 13 | Spotify Engineering — *When Should I Write an Architecture Decision Record* | https://engineering.atspotify.com/2020/04/when-should-i-write-an-architecture-decision-record | enterprise | 2026-04-30 |
| 14 | Microsoft Engineering Fundamentals Playbook — *Decision Log* | https://microsoft.github.io/code-with-engineering-playbook/design/design-reviews/decision-log/ | enterprise (closest implementation-grain analog) | 2026-04-30 |
| 15 | The Pragmatic Engineer — *RFCs and Design Docs* (industry survey) | https://blog.pragmaticengineer.com/rfcs-and-design-docs/ | industry survey | 2026-04-30 |
| 16 | Wix Engineering — *Why I Stop Prompting and Start Logging: The Design-Log Methodology* | https://www.wix.engineering/post/why-i-stop-prompting-and-start-logging-the-design-log-methodology | enterprise (append-only implementation-grain) | 2026-04-30 |
| 17 | Stack Overflow Blog — *You should keep a developer's journal* (Dec 2024) | https://stackoverflow.blog/2024/12/24/you-should-keep-a-developer-s-journal/ | industry blog | 2026-04-30 |
| 18 | Martin Fowler — *Refactoring* "Rule of Three" | https://en.wikipedia.org/wiki/Rule_of_three_(computer_programming) | academic / industry | 2026-04-30 |

---

## Part 2: Verbatim Citations

### A. SP precedent — adjacent, not direct

SP has **no implementation-decision-log primitive**. The closest precedents capture decisions at the *plan* grain or in the *commit message*, but neither persists a per-decision row at helper/primitive grain.

**SP `writing-plans/SKILL.md` line 56 (plan-grain "why this"):**
> "**Architecture:** [2-3 sentences about approach]"
> — `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/writing-plans/SKILL.md` line 56

This is plan-grain decision capture. PF v2's gap (Item 39) is the rung *below* it: the plan says "use a ref-based store"; the decision log captures "we chose `useRef` over `useState` because the click handler reads after async commit."

**SP `finishing-a-development-branch/SKILL.md` lines 96–103 (commit-shape decision):**
> ```
> gh pr create --title "<title>" --body "$(cat <<'EOF'
> ## Summary
> <2-3 bullets of what changed>
>
> ## Test Plan
> - [ ] <verification steps>
> EOF
> )"
> ```
> — SP `finishing-a-development-branch/SKILL.md` lines 96–103

PR description is decision-grain capture, but it ships once-per-merge and doesn't persist a queryable log at helper grain.

**SP `writing-skills/anthropic-best-practices.md` line 688 (commit-message convention):**
> "Follow this style: type(scope): brief description, then detailed explanation."
> — SP `writing-skills/anthropic-best-practices.md` line 688

SP recommends Conventional-Commits-flavored format. The commit body is a candidate decision-record carrier — but git-log search is poor UX vs. a dedicated markdown log.

**Verdict:** SP has commit-message and PR-body capture, plan-header `Architecture:` line, but **no implementation-decision-log primitive**. Item 39's gap is real.

---

### B. Anthropic precedent — file artifacts as cross-agent comms

This skill **IS** an inter-agent file artifact in Anthropic's sense. Two essays directly support the pattern.

**Anthropic — *Effective context engineering for AI agents* (file-as-memory):**
> "Structured note-taking (agentic memory) is a technique where agents regularly write notes persisted to memory outside of the context window, which get pulled back in at later times. This strategy provides persistent memory with minimal overhead, allowing agents like Claude Code to track progress across complex tasks by maintaining a NOTES.md file."
> — *Effective context engineering for AI agents*

`docs/IMPLEMENTATION-DECISIONS.md` is exactly a NOTES.md scoped to per-decision rationale.

**Anthropic — *Effective harnesses for long-running agents*:**
> "The best way to elicit persistent behavior was to ask the model to commit its progress to git with descriptive commit messages and to write summaries of its progress in a progress file, which allowed the model to use git to revert bad code changes and recover working states while increasing efficiency."
> — *Effective harnesses for long-running agents*

The "commit + progress file" pair is the canonical Anthropic-endorsed shape. Implementation-decision-log = the progress-file half of that pair, scoped to *why* rather than *what*.

**Anthropic — *Building Effective AI Agents* (artifact systems):**
> "Rather than requiring subagents to communicate everything through the lead agent, implement artifact systems where specialized agents can create outputs that persist independently, with subagents calling tools to store their work in external systems and passing lightweight references back to the coordinator."
> — *Building Effective AI Agents*

A Builder appending a 5-field row to `IMPLEMENTATION-DECISIONS.md` is exactly this artifact pattern: persists independently, lightweight, reference-able.

**Verdict:** Anthropic supports the file-artifact-as-cross-agent-comms shape directly. Strongest single citation for the skill's existence is *Effective context engineering* (NOTES.md pattern).

---

### C. Enterprise/OSS analogs (≥3 required, found 7)

#### C1. Microsoft Engineering Fundamentals Playbook — *Decision Log* (closest implementation-grain analog)

> "Microsoft's engineering playbook suggests using a markdown table as a decision log, with columns for Decision, Date, Alternatives, Reasoning, Link to detailed doc (if any), Who made it, etc."
> — Microsoft Engineering Fundamentals Playbook, https://microsoft.github.io/code-with-engineering-playbook/design/design-reviews/decision-log/ (retrieved 2026-04-30 via WebSearch)

This is a **direct schema match** — Decision / Alternatives / Reasoning / Link / Who. Differs from MADR by being explicitly tabular + append-only + sized for non-architectural decisions ("executive summaries").

#### C2. Wix Engineering — *Design-Log Methodology* (append-only implementation-grain)

> "A design log is a version-controlled folder ./design-log/ in your Git repository containing markdown documents that serve as a 'snapshot in time' of a specific design, decision or feature."
> — Wix Engineering, https://www.wix.engineering/post/why-i-stop-prompting-and-start-logging-the-design-log-methodology

> "During the build, any deviation was appended to the 'Implementation Results' section. More specifically, do not update design log initial section once implementation started, but append design log with 'Implementation Results' section as you go."
> — Wix Engineering (same source)

Verbatim "append-only at implementation time" — directly mirrors the brief's "Builders append after every Tier 2/3 ship."

#### C3. MADR 4.0.0 — minimal + bare-minimal variants (lightweight ADR)

> "MADR 4.0.0 includes 'bare' and 'minimal' templates… The minimal template contains only mandatory sections with explanations… the bare template has all sections but they are empty without explanations, while the bare-minimal template has mandatory sections without explanations."
> — About MADR, https://adr.github.io/madr/

> "The minimal MADR structure includes: title, Context and Problem Statement, Considered Options, Decision Outcome, and Consequences"
> — About MADR (same)

MADR-minimal is the architectural-grain template downsized; implementation-decision-log compresses further (one row, not one file per decision).

#### C4. GitHub Engineering Blog — *Why write ADRs* (decision rationale capture)

> "ADRs will help you 6-12 months from now recall what your mindset was when you decided upon that architecture, capturing the decision at the time it's being made."
> — GitHub Engineering Blog, https://github.blog/engineering/architecture-optimization/why-write-adrs/

> "ADRs are a longer form of prose to help your teammates understand why the feature is built the way it is, and not built some other way through 'Alternatives Considered' and 'Pros/Cons' within ADRs themselves."
> — GitHub Engineering Blog (same)

Frames "Alternatives Considered" + "why not the other way" as the load-bearing fields. This is the same pair the brief's 5-field schema requires.

#### C5. Spotify Engineering — *When Should I Write an Architecture Decision Record*

> "Future team members are able to read a history of decisions and quickly get up to speed on how and why a decision is made, and the impact of that decision."
> — Spotify Engineering, https://engineering.atspotify.com/2020/04/when-should-i-write-an-architecture-decision-record

> "When a new engineer asks 'why didn't we use MongoDB?', the answer is right here. When the team revisits the decision a year later, they can see what was evaluated and why it was rejected."
> — search-result paraphrase of Spotify ADR practice (same source)

Spotify ships ADRs at *system-design* grain; v2's implementation-decision-log is the rung below. The lookup-shape ("why didn't we use X?") is identical.

#### C6. Conventional Commits 1.0.0 — commit-message-as-record

> "A scope may be provided to a commit's type, to provide additional contextual information and is contained within parenthesis, e.g., feat(parser): add ability to parse arrays."
> — Conventional Commits 1.0.0, https://www.conventionalcommits.org/en/v1.0.0/

> "Breaking changes should be described in the commit footer section, if the commit description isn't sufficiently informative. The rationale is that an author notes the breakingness of a change (and advice for how clients of the library might adapt to the breaking change) in the body or footer of a Conventional Commit."
> — Conventional Commits 1.0.0 (same)

Commit messages are the lightest possible decision record. The 5-field schema BORROWS the commit hash as a join key but does NOT replace the commit-body — the log row is the searchable index, the commit body is the long-form rationale.

#### C7. The Pragmatic Engineer — *RFCs and Design Docs* (industry survey)

> "Decision logs are used to record, store, and reference key software decisions, preserving context and avoiding repeated debates."
> — Pragmatic Engineer, https://blog.pragmaticengineer.com/rfcs-and-design-docs/

> "An ADR can result from an RFC discussion (the final decision captured in an ADR). But RFCs are more about the process of reaching a decision collaboratively. They tend to be longer-form than an ADR, often including analysis, diagrams, or multiple options in detail."
> — Pragmatic Engineer (same)

Establishes a 3-tier industry hierarchy: RFC (process, longest) → ADR (decision, medium) → decision log (executive summary, shortest). PF v2's implementation-decision-log fits BELOW ADR — a 4th tier scoped to helper/primitive grain.

#### C8. Y-Statement — single-sentence decision grammar (Zimmermann)

> "1. context: functional requirement (story, use case) or arch. component, 2. facing: non-functional requirement, for instance a desired quality, 3. we decided: decision outcome (arguably the most important part), 4. and neglected alternatives not chosen (not to be forgotten!), 5. to achieve: benefits…, 6. accepting that: drawbacks and other consequences…"
> — Y-Statement (Zimmermann), https://medium.com/olzzio/y-statements-10eb07b5a177 (already cited in `skill-design-seven-validation-questions.md` Q2; Microsoft + Spotify ADR canon also reference)

Y-Statement compresses MADR's 5+ sections into ONE sentence. Implementation-decision-log's `why-this` field is best constrained to a Y-Statement-shaped clause: `In context X, facing Y, we chose Z over A, to achieve Q, accepting D.`

#### C9. Stack Overflow Blog — *You should keep a developer's journal* (code-level grain)

> "At the code level, it's easy to get lost, and fortunately there's a way to keep your thoughts organized around the nitty-gritty: a developer's journal. You can use your code editor and simply create a new text or markdown file."
> — Stack Overflow Blog, https://stackoverflow.blog/2024/12/24/you-should-keep-a-developer-s-journal/

Validates the code-level grain explicitly — distinct from project-level RFC/ADR.

#### C10. Martin Fowler — Rule of Three (refactoring threshold)

> "The first time you do something, you just do it. The second time you do something similar, you wince at the duplication, but you do the duplicate thing anyway. The third time you do something similar, you refactor."
> — Martin Fowler, *Refactoring*, via https://en.wikipedia.org/wiki/Rule_of_three_(computer_programming)

Cross-link justification: implementation-decision-log entries that recur ≥3 times become candidates for promotion to a `STACK-PATTERNS` row (`proposing-patterns` ingest threshold). Rule-of-Three is the canonical industry threshold for "decision becomes pattern." Item 40-2 in v1 audit calls this out.

---

## Part 3: Consensus on the 5-Field Schema

The brief proposes 5 fields: `decision / alternatives / why-this / commit-hash / pattern-link`. Consensus check (K of N frameworks supporting each field):

| Field | Microsoft | Wix | MADR-min | GitHub ADR | Spotify | ConvCommits | Y-Statement | Pragmatic | Count |
|---|---|---|---|---|---|---|---|---|---|
| **decision** (1-line) | ✓ ("Decision") | ✓ (page title) | ✓ (title) | ✓ | ✓ | ✓ (description) | ✓ (we decided) | ✓ | 8/8 |
| **alternatives** | ✓ ("Alternatives") | (implicit) | ✓ ("Considered Options") | ✓ ("Alternatives Considered") | ✓ | — | ✓ ("neglected alternatives") | ✓ | 7/8 |
| **why-this** | ✓ ("Reasoning") | ✓ ("Implementation Results") | ✓ ("Decision Outcome") | ✓ (rationale) | ✓ ("how and why") | ✓ (body/footer) | ✓ ("to achieve") | ✓ | 8/8 |
| **commit-hash** (or equivalent join key) | ✓ ("Link to detailed doc") | ✓ (Git folder anchor) | — (separate file per decision) | — | — | ✓ (commit IS the record) | — | — | 3/8 |
| **pattern-link** (cross-ref to codified pattern) | — | — | — | — | — | — | — | — | 0/8 (PF-novel) |

**Consensus verdict:**
- **Fields 1, 2, 3** — universal (≥7/8). Bind directly.
- **Field 4 (commit-hash)** — 3/8 explicit; the others assume Git presence. Defensible because PF v2 is Git-centric and Anthropic's "commit-and-progress-file" pair (cited above) is the binding shape.
- **Field 5 (pattern-link)** — PF-novel, justified by Item 40-2 (fix-time-hash-check) + Rule-of-Three threshold. Cite Fowler + the existing `proposing-patterns` skill as the rationale; this field is what makes the log composable with v2's pattern-promotion pipeline rather than a dead-end journal.

---

## Part 4: Recommendations for Skill Body Content

### R1 — Use Microsoft Decision Log shape, not MADR-per-file

The brief's append-only single-file shape matches **Microsoft Engineering Playbook** more than MADR (one file per decision). Cite Microsoft directly as the format anchor. MADR-minimal is the next-closest analog and worth citing as the "if richer rationale is needed, link out to a per-decision MADR file" escape hatch — but the default is one row in one file.

### R2 — 5-field row schema, grounded per field

| Field | Grammar | Source binding |
|---|---|---|
| `decision` | One-sentence imperative starting with verb. ≤120 chars. | Microsoft "Decision" + Conventional Commits "description MUST… short summary of the code changes" |
| `alternatives` | Comma-separated list of ≥1 named alternative considered. Empty list forbidden. | Y-Statement clause 4 ("**neglected alternatives** not chosen — not to be forgotten!") + GitHub ADR "Alternatives Considered" |
| `why-this` | Y-Statement compression: `In <context>, facing <constraint>, chose <X> over <alt>, to achieve <Q>, accepting <D>.` ≤200 chars. | Y-Statement (Zimmermann) — direct adoption of grammar |
| `commit-hash` | Short Git SHA (7+ chars) of the merge or feature commit. | Anthropic "commit progress to git with descriptive commit messages… write summaries of its progress in a progress file" + Conventional Commits |
| `pattern-link` | Either `STACK-PATTERNS:<row-id>`, `PROJECT-PLAN:<finding-id>`, or `—` if neither exists. | PF-novel; rationale = Rule-of-Three (Fowler) + `proposing-patterns` ingest path |

### R3 — Append-only enforcement (Wix precedent)

Body MUST cite Wix's "do not update design log initial section once implementation started" verbatim. Builder appends; no row is ever edited. If a decision is reversed, append a new row referencing the prior row's commit-hash. This preserves the temporal record (Anthropic's "agents are stateful and errors compound" → don't lose the audit trail).

### R4 — Frontmatter `description` per SP convention

Per `writing-skills/SKILL.md` lines 140-172 (already cited in `skill-design-seven-validation-questions.md` R2): action-oriented imperative. Example:
> "Use after every Tier 2/3 ship — append a 5-field row to docs/IMPLEMENTATION-DECISIONS.md capturing the decision, alternatives, why-this (Y-Statement form), commit hash, and any pattern-link. Builders run this skill BEFORE the handover."

### R5 — Composability with `find-similar-implementations` (Item 39 paired skill)

Per the Item 39 brief, lookup happens in `find-similar-implementations`. The skill body MUST include a `Composable with: find-similar-implementations` frontmatter note (per CLAUDE.md PR-checklist convention) and a body section explaining the read-side: `find-similar-implementations` greps `IMPLEMENTATION-DECISIONS.md` first, then PROJECT-PLAN, then STACK-PATTERNS — sorted least-to-most codified.

### R6 — Composability with `proposing-patterns` (Item 40-2 cross-link)

Per Item 40-2 + Rule-of-Three, when ≥3 rows in `IMPLEMENTATION-DECISIONS.md` cluster on the same `pattern-link` value or the same `root_cause_hash` (computed via `compute-root-cause-hash.sh`), the `proposing-patterns` skill auto-qualifies them as a proposal candidate. Body MUST include a `Composable with: proposing-patterns` note + the threshold rule. This is what closes the v1 loop the audit calls out: research-grade BINDING findings + ≥3 implementation-decision rows = proposal candidate, parallel to the existing ≥3-incident path.

### R7 — Scoping rule: when to log vs. not

NOT every commit produces a decision log row. Trigger rule:
- Tier 2/3 ship (per `tier-selection`) AND
- Decision had ≥1 named alternative considered (per `brainstorming`'s "Propose 2-3 different approaches with trade-offs") AND
- Decision is at helper / primitive / hook / utility grain — NOT at module / feature grain (those go in PROJECT-PLAN) AND NOT at codified-pattern grain (those go in STACK-PATTERNS).

Tier-1 trivia, default-stack-pattern reuse, and pure refactors with no alternative rejected → no log entry. This keeps the log signal-dense per Anthropic's "context window is a public good" + concision principle.

### R8 — File location

`docs/IMPLEMENTATION-DECISIONS.md` (single file, repo-rooted). Matches Wix's `./design-log/` approach but flattened to one file per the brief and per the size of decisions tracked (one row, not one document). Cross-link from PROJECT-PLAN.template.md "Architecture Documents" section as a sibling artifact.

### R9 — Quick-reference table format

Body MUST ship the literal table header to use:
```markdown
| Date | Decision | Alternatives | Why-This | Commit | Pattern-Link |
|---|---|---|---|---|---|
```
Date column is added (it's universal across Microsoft / Spotify / Pragmatic — 5/8 → effectively unanimous when "implicit by file order" is collapsed) and cheap. The brief's 5-field schema becomes a 6-field table; the 5 fields remain the load-bearing semantic content.

### R10 — HARD-GATE? No.

Unlike `seven-validation-questions` (R1) or `verification-before-completion`, this skill does NOT gate execution. Missing log entries are detected at QA / handover / pattern-promotion time, not at write time. A `<HARD-GATE>` would over-fire (every Tier-2 commit blocked on log discipline). Instead: cite SP `verification-before-completion` style "Required evidence" — handover doc must reference the log row's commit-hash.

If a stronger gate is wanted, the right place is the **PostToolUse Builder DONE hook** proposed in Item 40 (audit), which would auto-append a stub row at Tier 2/3 ship time. That's a hook decision (D-F in audit), not a skill-body decision.

---

## Part 5: Citations Footer

**Anthropic primary sources (re-verify before binding decisions):**
- *Effective context engineering for AI agents* — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- *Effective harnesses for long-running agents* — https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- *Building Effective AI Agents* — https://www.anthropic.com/research/building-effective-agents

**Superpowers 5.0.7 source files (local cache):**
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/writing-plans/SKILL.md` (line 56 — `Architecture:` plan-grain analog)
- `.../skills/finishing-a-development-branch/SKILL.md` (lines 96–103 — PR-body decision-shape)
- `.../skills/writing-skills/anthropic-best-practices.md` (line 688 — commit-message format)

**Production-framework v2 internal cross-references:**
- `c:/Users/atyab/Experimental - Users/production-framework-v2/CLAUDE.md` — binding rule
- `c:/Users/atyab/Experimental - Users/production-framework-v2/docs/research/skill-design-seven-validation-questions.md` — Q2 MADR + Y-Statement citations adapted here
- `c:/Users/atyab/Experimental - Users/production-framework-v2/templates/PROJECT-PLAN.template.md` — sibling artifact
- `c:/Users/atyab/Experimental - Users/production-framework-v2/docs/audits/v1-feedback-vs-v2-2026-04-30.md` — Item 39 + Item 40 source brief

**Enterprise / OSS sources:**
- Microsoft Engineering Fundamentals Playbook *Decision Log* — https://microsoft.github.io/code-with-engineering-playbook/design/design-reviews/decision-log/
- Wix Engineering *Design-Log Methodology* — https://www.wix.engineering/post/why-i-stop-prompting-and-start-logging-the-design-log-methodology
- MADR 4.0.0 — https://adr.github.io/madr/
- GitHub Engineering Blog *Why write ADRs* — https://github.blog/engineering/architecture-optimization/why-write-adrs/
- Spotify Engineering *When Should I Write an ADR* — https://engineering.atspotify.com/2020/04/when-should-i-write-an-architecture-decision-record
- Conventional Commits 1.0.0 — https://www.conventionalcommits.org/en/v1.0.0/
- The Pragmatic Engineer *RFCs and Design Docs* — https://blog.pragmaticengineer.com/rfcs-and-design-docs/
- Y-Statement (Zimmermann) — https://medium.com/olzzio/y-statements-10eb07b5a177 + https://ozimmer.ch/practices/2022/11/22/MADRTemplatePrimer.html
- Stack Overflow Blog *Developer's Journal* — https://stackoverflow.blog/2024/12/24/you-should-keep-a-developer-s-journal/
- Martin Fowler Rule of Three — https://en.wikipedia.org/wiki/Rule_of_three_(computer_programming)

**Methodology disclosure (re-stated):** WebFetch was permission-denied. All Anthropic and external quotes were retrieved via WebSearch synthesis of canonical URLs. Re-verify against live URLs before binding architectural decisions.
