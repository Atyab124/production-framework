---
name: implementation-decision-log
description: "Use after every Tier 2/3 ship — append a 5-field entry to docs/IMPLEMENTATION-DECISIONS.md capturing the decision, alternatives considered, why-this, commit hash, and pattern link (if any). Closes the gap between PROJECT-PLAN (phase grain) and STACK-PATTERNS (codified pattern grain). Explicitly NON-HARD-GATE — append-only convention, not a blocker."
---

## Overview

PF v1 documented (audit Item 39): the gap between PROJECT-PLAN (phase-grain decisions) and STACK-PATTERNS (codified-pattern-grain rules) is where helper / primitive / hook decisions fall through. "We chose useRef over useState for the mention `matchRef` because the click handler reads after async commit — closure-captured state was stale" is exactly the kind of decision that never lands in either doc; future Builders rediscover it.

This skill is the lightweight, append-only log primitive that captures these decisions at the helper / primitive grain. **Microsoft Engineering Playbook Decision Log is the direct 1:1 analog** — Wave 1 research found verbatim columns mapping (Decision / Date / Alternatives / Reasoning / Link / Who).

**Field-level consensus 8/8 on decision + why-this; 7/8 on alternatives.** Pattern-link field is PF-novel (justified by Fowler's Rule of Three + composability with `proposing-patterns`).

**Explicitly NON-HARD-GATE per Wave 1 R-10.** This is a low-friction convention, not a blocker. Skipping doesn't fail a gate; it weakens future reuse-lookup.

## When to Use

- **Recommended** after every Tier 2/3 ship — append 1 entry per non-trivial decision.
- **Recommended** when `find-similar-implementations` returns NEW (novel primitive) — capture the why.
- **Recommended** when the Builder's self-review surfaces a non-obvious choice between ≥2 alternatives.

Do NOT use:
- For Tier 1 changes — overhead exceeds benefit.
- For mechanical decisions where the answer is fully determined by the spec (e.g., "use the type the spec says to use").

## Core Pattern

Append-only. Never edit a prior entry — if a decision is later overturned, add a new entry referencing the prior one.

### File location

`docs/IMPLEMENTATION-DECISIONS.md` — single rolling doc per project, append-only.

### 5-field schema (per Microsoft Engineering Playbook + Wave 1 R-2)

```markdown
## YYYY-MM-DD — <one-line decision summary>

- **Decision:** <what was chosen — concrete; name the file:line and the construct>
- **Alternatives considered:** <≥1 alternative — concrete; not "I considered X" but "X with shape Y, rejected because Z">
- **Why this:** <Y-Statement form — In context X, facing Y, chose Z over A, to achieve Q, accepting D>
- **Commit hash:** <full SHA, even if uncommitted at write time — fill in post-commit>
- **Pattern link (optional):** <BP-N / AP-N / PP-N from STACK-PATTERNS.md if related; link to `find-similar-implementations` table if NEW judgment>
```

### Append discipline (per Wix Engineering)

> "Do not update design log initial section once implementation started."

Translation: once a decision entry is written, it is immutable. New decisions get new entries. If a prior decision is overturned:

```markdown
## YYYY-MM-DD — REVISED: <new decision> (supersedes 2026-01-15 entry "<original summary>")

- **Decision:** <new>
- **Alternatives considered:** <including the previous decision as a rejected alternative>
- **Why this:** <Y-Statement; explain why prior context changed>
- **Commit hash:** <new commit>
- **Pattern link:** <if applicable>
```

### Y-Statement format for "Why this" (per `seven-validation-questions` Q2 grounding)

> "In context **{X}**, facing **{Y}**, we decided **{Z}**, neglecting alternatives **{A, B}**, to achieve **{Q}**, accepting that **{D}**."

This compresses 4 of the 5 fields into one disciplined sentence; only Decision + Commit-hash + Pattern-link sit outside the Y-Statement.

## Composability

- **Composable with `find-similar-implementations`** — when the 4-step search returns NEW judgment, append the why-NEW reasoning here. The judgment becomes traceable.
- **Composable with `proposing-patterns`** — if 3 implementation-decision-log entries describe the same NEW shape, that's Path A trigger (per Fowler Rule of Three; ADR-003 dual-path).
- **Composable with `seven-validation-questions`** — Q2 (Why this approach?) consumes implementation-decision-log entries from the relevant module as evidence.
- **Cross-references** `docs/PROJECT-PLAN.md` Phase Status (phase-grain) and `STACK-PATTERNS.md` (pattern-grain) — sits explicitly between them.

## Anti-Patterns

### "I'll write it after the commit lands"

Acceptable if you actually do — but the practical failure mode is "write later" never happens. Write the entry as the commit message is being drafted; fill in the hash post-commit. The 30-second time cost is the entire benefit.

### "It's a small decision, no need to log"

Small decisions accumulate. The `matchRef` decision was small. Six months later, the next picker needed it; the next Builder rediscovered it. The Y-Statement is one sentence — the friction is bounded.

### "I'll log a vague summary"

"I chose useRef because state was stale" is a vague summary. "In context React state-setter async-commit, facing closure-captured stale value, chose useRef over useState, neglecting useImperativeHandle and a manual subscription, to achieve synchronous-read-of-current-value, accepting that re-renders no longer trigger on writes." That's actionable.

## Quick Reference

- 5-field schema: Decision / Alternatives / Why-this (Y-Statement) / Commit hash / Pattern link.
- Microsoft Engineering Playbook 1:1 analog (verified column mapping per Wave 1 R-1).
- Append-only (Wix discipline). Revised entries reference + supersede prior.
- NON-HARD-GATE — convention, not blocker.
- Pairs with find-similar-implementations (NEW judgment writes here) + proposing-patterns (3rd entry triggers Path A).

## Citations

**SP precedent:** Adjacent only — SP has no implementation-decision-log primitive.
- `superpowers/5.0.7/skills/writing-plans/SKILL.md` line 56 (`Architecture:` line — plan-grain)
- `superpowers/5.0.7/skills/finishing-a-development-branch/SKILL.md` lines 96–103 (PR body — once-per-merge)
- `superpowers/5.0.7/skills/writing-skills/anthropic-best-practices.md` line 688 (commit-message format)

**Anthropic guidance:**
- *Effective Context Engineering* — NOTES.md pattern; file artifacts as cross-agent comms
- *Effective harnesses for long-running agents* — commit-plus-progress-file pair
- *Building Effective Agents* — "artifact systems… persist independently… lightweight references"

**Enterprise / OSS (≥3 satisfied 8 sources, field-level 8/8 consensus on decision + why-this):**
- Microsoft Engineering Playbook Decision Log — direct 1:1 analog (verbatim column mapping)
- Wix Engineering Design-Log Methodology — append-only discipline
- ADR / MADR — https://adr.github.io/madr/ — architecture-grain analog
- Y-Statement (Zimmermann SATURN 2012) — https://medium.com/olzzio/y-statements-10eb07b5a177
- Conventional Commits — https://www.conventionalcommits.org/
- Pragmatic Engineer industry survey — https://blog.pragmaticengineer.com/rfcs-and-design-docs/
- Martin Fowler "Rule of Three" — *Refactoring* (2018)
- Spotify ADR practice

**Companion PF v2 research:**
- `docs/research/skill-design-implementation-decision-log.md` (Wave 1, Opus, ~290L; field-level 8/8 BINDING)
