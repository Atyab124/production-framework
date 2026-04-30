---
name: find-similar-implementations
description: "Use BEFORE writing-plans for any change introducing a new helper / component / hook / primitive. Outputs a 5-line table of existing-codebase candidates with REUSE / ADAPT / NEW judgment per row. Closes the reuse-lookup gap (audit Item 39): registries (patterns.md, STACK-PATTERNS.md) say WHAT to reuse — this skill says HOW to find it."
---

## Overview

PF v1 documented (audit Item 39): the framework knows the WHAT of reuse — `core/patterns.md`, `STACK-PATTERNS.md`, U-PP-10 ("adopt, never invent") — but lacks the HOW. Builders + orchestrators apply ad-hoc heuristics; outputs vary; the `matchRef` synchronous-mutation pattern that worked for one feature gets re-implemented (and re-broken) for the next picker.

This skill is the codebase-local cousin of `enterprise-research-first` (which compares against industry tools). It runs structured 4-step similarity search across the project's own codebase before any plan introduces a new primitive.

**Enterprise grounding: 11/11 BINDING** on structured methodology beyond name-grep — Sourcegraph, GitHub Copilot, Aider, Cursor, ast-grep, Semgrep, comby.dev, SonarQube, Code Climate, Bellon academic taxonomy, Fowler "Rule of Three". **Most-adopted pairing: name/literal entry → AST/structural confirmation (5/11 explicit; 8/11 AST-confirmation BINDING).**

<HARD-GATE>
Do NOT proceed to `writing-plans` for any new helper / component / hook / primitive until the 4-step methodology has produced a 5-line candidate table with explicit REUSE / ADAPT / NEW judgment per row. Skipping the search is the failure mode that produces re-implemented-and-re-broken patterns (audit Item 39).
</HARD-GATE>

## When to Use

- Any change introducing a **new helper function** that isn't a one-line wrapper.
- Any new **component** at the design-system grain (button, picker, table, modal).
- Any new **hook** (React) / **store** / **service** / **utility module**.
- Any new **primitive** at the data layer (RPC, query builder, cache key).
- Before `writing-plans` for any of the above.

Do NOT use:
- For one-line config changes, typo fixes, comment edits — the 4-step search costs more than the change.
- For changes inside an existing primitive's internal implementation — you're already in the boundary.

## Core Pattern

You MUST create a TodoWrite item per step. Output: 5-line candidate table, ranked by similarity strength.

### Step 1 — Name-similarity grep

Search the codebase for identifiers similar to the proposed name:
- Exact name (case-insensitive): `rg -i "newHelper" src/`
- Partial name: `rg -i "Helper" src/lib/` (if proposing `newHelper`)
- Synonyms: if proposing `picker`, also `selector`, `chooser`, `combobox`, `autocomplete`

Per Sourcegraph "Code search at scale": "Most code reuse opportunities are findable by literal name search before semantic search."

**Output:** list of files with name-matching identifiers. If empty, proceed to Step 2 (don't conclude "novel" yet).

### Step 2 — Function-signature / shape grep

Search for similar function signatures:
- Same return type + similar arity (`rg "function \w+\(.*\): Promise<Result"`)
- Same prop interface (`rg "interface \w+Props \{[^}]*onSelect"`)
- Same hook return shape (`rg "return \{ ... data, error, isLoading"`)

Per ast-grep + Semgrep: structural-AST search catches reuse opportunities that name-grep misses (different name, same shape).

**Output:** signature-matching candidates added to the table.

### Step 3 — Import-graph trace

For each candidate from Steps 1-2, trace what imports it:
- `rg "import.*<candidate>" src/` — who depends on it
- If a candidate has ≥3 importers, it's already a reuse hub — strong signal to use it

Per Aider's PageRank-based codebase navigation: "Reuse hubs are the modules with the highest in-degree."

**Output:** importer count per candidate.

### Step 4 — AST / token-fingerprint match (when Steps 1-3 inconclusive)

If Steps 1-3 produced no clear candidates BUT the proposed primitive feels structurally similar to something:
- Run `rg -P "pattern with structural anchors"` for shape match (token fingerprint fallback)
- If `ast-grep` is installed: `ast-grep --pattern "function $NAME($_) { return $_; }"`
- If `semgrep` is installed: `semgrep --config 'auto' src/` for inline duplicate detection

**Output:** AST/fingerprint matches added to table.

### Step 5 — Produce the 5-line candidate table

Format:

```
| # | Candidate (path:line) | Similarity score | Importers | Judgment | Rationale |
|---|---|---|---|---|---|
| 1 | src/lib/picker.tsx:42 | name+signature match | 4 | REUSE | Same shape + already a reuse hub. Adapt props, reuse internals. |
| 2 | src/lib/combobox.tsx:18 | name match only | 1 | ADAPT | Different return shape; copy + adapt as `newPicker` if reuse blocked. |
| 3 | (no AST match in src/) | — | — | NEW | Novel primitive. Proceed to writing-plans. Per Fowler "Rule of Three": flag for `proposing-patterns` review if this is the 3rd similar one. |
```

Judgment grammar (per Code Climate identical/similar tiers):
- **REUSE** — exact shape match; integrate directly
- **ADAPT** — partial match; copy + modify (rule-of-three trigger: if this is the 3rd ADAPT in the same shape, propose extracting via `proposing-patterns`)
- **NEW** — no candidate; truly novel; proceed to plan

## Anti-Patterns

### "I already know there's nothing similar"

Training-data recall isn't a citation here — same as in `enterprise-research-first`. Run the grep. The codebase has 18+ months of changes since you last looked.

### "Name didn't match, so it's novel"

Name-grep is Step 1. Step 2-4 catch shape matches that name-grep misses. Skipping Step 2 is the failure mode that produces re-implemented-and-re-broken primitives (audit Item 39: `matchRef` would have been findable by signature).

### "It matched something but I want to write fresh anyway"

Acceptable IF you document why in the plan's Decision Record (per `seven-validation-questions` Q2 + ADR Y-statement). "Different enough to fork" is a reasonable rationale; "I prefer my version" is not.

## Red Flags

| Excuse | Reality |
|---|---|
| "I'll just do a quick grep, no need for structured search" | Quick greps miss shape matches. Audit Item 39's `matchRef` was a quick-grep miss. |
| "AST tooling isn't installed" | `rg -P` token fingerprint is a graceful fallback per CLAUDE.md zero-runtime-dep posture. |
| "The candidate has only 1 importer; not a real reuse hub" | 1 importer is still 1 reuse opportunity. Don't dismiss; mark as ADAPT instead of REUSE. |
| "I'll skip Step 5 — the table is overhead" | The table is the durable artifact. Future Builders read it; without it, the search isn't reproducible. |

## Quick Reference

- HARD-GATE before `writing-plans` for new helper/component/hook/primitive.
- 4-step methodology: name → signature → import-graph → AST/fingerprint.
- Output: 5-line candidate table (path:line, similarity, importers, REUSE/ADAPT/NEW, rationale).
- Most-adopted pairing: name + AST (5/11 explicit; 11/11 BINDING on structured-beyond-name-grep).
- Rule of Three: 3rd ADAPT in same shape → trigger `proposing-patterns`.

## Composability

- **HARD-GATE precedes `writing-plans`** for new primitive/helper/component/hook.
- **Composable with `enterprise-research-first`** — codebase-first (this skill), industry-second (ER1). Order matters: in-house reuse beats invention; invention beats cargo-cult.
- **Feeds `implementation-decision-log`** — the REUSE/ADAPT/NEW judgment is one of the decision-log entries.
- **Triggers `proposing-patterns`** when 3rd ADAPT in same shape (Path A — recurrence-driven).
- **Distinct from `enterprise-research-first`** — that skill compares against industry tools; this one against the project's own codebase.

## Citations

**SP precedent (5 SP skills enforce smaller-scope analogue, already cited in `skill-design-enterprise-research-first.md`):**
- `superpowers/5.0.7/skills/subagent-driven-development/implementer-prompt.md` line 91 — "Did I follow existing patterns in the codebase?"
- `superpowers/5.0.7/skills/brainstorming/SKILL.md` line 103 — "Explore the current structure before proposing changes."
- `superpowers/5.0.7/skills/systematic-debugging/SKILL.md` Phase 2 lines 122–143 — "Find Working Examples / Compare Against References"

**Anthropic guidance:**
- *Effective Context Engineering* — codebase navigation, just-in-time retrieval, lightweight identifiers + selective load
- *Building Effective AI Agents* — "find the simplest solution... only increase complexity when needed"

**Enterprise / OSS (≥3 satisfied 11/11 BINDING):**
- Sourcegraph "Code search at scale": https://about.sourcegraph.com/blog/
- GitHub Copilot — pattern matching
- Aider — codebase-aware editing + git-aware retrieval (PageRank navigation)
- Cursor — embedding-based similarity
- ast-grep — structural code search: https://ast-grep.github.io/
- Semgrep — pattern rules: https://semgrep.dev/
- comby.dev — structural diff matching
- SonarQube / Code Climate — duplication detection
- Bellon et al., academic taxonomy of clone detection
- Fowler "Rule of Three" — *Refactoring* (2018)

**Companion PF v2 research:**
- `docs/research/skill-design-find-similar-implementations.md` (Wave 1, Opus, 352L; 11/11 BINDING)
