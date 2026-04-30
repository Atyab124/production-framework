---
name: regression-scope
description: "Use during QA review (Stage 2) when the change touches a shared module / utility / hook / cache key / API contract — produces a regression-scope catalog: what other features could break, what tests cover them, what manual smoke is needed. Closes the gap where shared-module changes ship with insufficient regression coverage."
---

## Overview

When a change touches a shared module, the blast radius extends to every consumer. PF v2 ships this skill as the bounded-blast-radius primitive QA invokes during Stage 2 review (per `agents/qa.md` lines 65-66). It produces `docs/PROJECT-PLAN.md` Regression Scope Catalog rows that future cycles read.

**SP precedent:** SP `requesting-code-review/SKILL.md` enforces review-as-regression-detection (mandatory before merge). PF v2 specializes for cross-module impact analysis — what tests cover the consumers, what manual smoke is needed, what should be in the rolling handover doc's "Regression scope" subsection.

**Industry support:** Google Engineering Practices "How to do a code review" (https://google.github.io/eng-practices/review/reviewer/) prescribes consumer-impact analysis as part of every review. Microsoft Engineering Playbook "Risk-Based Testing" frames the bounded-blast-radius discipline. ISTQB Foundation Level §4.2 boundary-value analysis.

## When to Use

- During QA Stage 2 review (per `agents/qa.md`) when the change touches:
  - A shared utility / hook / context provider used by ≥3 modules
  - A cache key or query-key shape (any storage with consumers across modules)
  - An API contract (RPC signature, response shape, error envelope)
  - An auth / multi-tenant / RLS primitive (touches everything downstream)
  - A migration that adds / drops / renames a column on a multi-consumer table
- During `writing-plans` when the plan introduces a cross-cutting refactor.

Do NOT use:
- For changes scoped to a single module / file with no cross-imports.
- For Tier 1 changes (typo, comment, single-line config).

## Core Pattern

You MUST create a TodoWrite item per step.

### Step 1 — Inventory consumers

For every shared module / hook / cache key / API contract the change touches:

```bash
# Find direct importers (name-grep)
rg "import.*<exported-name>" src/ tests/

# Find indirect consumers (transitive — module imports the importer)
# Aider's PageRank model: rank by import-graph in-degree
```

Output: list of consumers with file:line.

### Step 2 — Map consumers to feature areas

Group consumers by feature / module / route. Each group is a regression candidate.

### Step 3 — Map regression candidates to existing tests

For each candidate group:
- Does an existing test cover the integration?
- Is the test in the regression suite (CI runs it)?
- Has it been updated for the change (or does it still pass on the old behavior)?

If gap: flag as "needs new test" OR "needs manual smoke."

### Step 4 — Manual smoke runbook (when test coverage absent)

For consumers without existing test coverage, produce a manual runbook:

```markdown
### Regression smoke: <feature>
- **What to test:** <user-flow>
- **How:** <steps; cite Playwright invocation if applicable per `browser-driven-verification`>
- **Expected:** <outcome>
- **Failure signal:** <what to look for>
```

### Step 5 — Append to PROJECT-PLAN Regression Scope Catalog

Append rows to `docs/PROJECT-PLAN.md` "Regression Scope Catalog":

```markdown
| Feature / Module | Depends on | Depended on by |
|---|---|---|
| <consumer feature> | <touched module> | (downstream) |
```

Cross-link in the rolling handover doc's "Regression scope" subsection (per `writing-handover` skill).

## Anti-Patterns

### "Tests will catch any regressions"

Tests catch what they cover. Regression-scope is the explicit list of consumers that MIGHT regress — required so tests can be written to cover each, OR manual smoke can fill the gap.

### "It's a small change; no regression scope needed"

If the change touches a shared module, "small" doesn't apply at the consumer level. A 1-line cache-key rename breaks every consumer of the cache.

## Quick Reference

- Triggered when change touches shared module / hook / cache key / API / auth / migration.
- 5-step: inventory → group → map to tests → smoke runbook for gaps → append to PROJECT-PLAN.
- Output: regression-scope rows in PROJECT-PLAN + cross-link from rolling handover.
- Manual smoke runbook required when no test covers a consumer.

## Composability

- **Invoked from `agents/qa.md`** Stage 2 — per existing checklist line "Invoke `production-framework:regression-scope` if the change touches a shared module."
- **Composable with `browser-driven-verification`** — manual smoke runbook cites Playwright invocations for UI consumers.
- **Composable with `writing-handover`** — regression scope rows cross-link from the rolling doc's "Regression scope" subsection.
- **Composable with `gate-3-production-check` D16** (regression scope re-tested) — gate-3 reads the PROJECT-PLAN Regression Scope Catalog as its evidence input.

## Citations

**SP precedent:**
- `superpowers/5.0.7/skills/requesting-code-review/SKILL.md` — review-as-regression-detection
- `superpowers/5.0.7/skills/subagent-driven-development/code-quality-reviewer-prompt.md` — quality review checklist

**Anthropic guidance:**
- *Building Effective AI Agents* — ACI / careful tool design (consumers as a tool's caller-set)

**Enterprise / OSS (≥3 satisfied):**
- Google Engineering Practices — "How to do a code review": https://google.github.io/eng-practices/review/reviewer/
- Microsoft Engineering Playbook — Risk-Based Testing
- ISTQB Foundation Level §4.2 — boundary-value analysis
- Aider — PageRank-based codebase navigation (consumer ranking)

**Companion PF v2 research:**
- `docs/research/agent-design-qa.md` — QA agent already invokes this skill (existing checklist)
- `templates/PROJECT-PLAN.template.md` — Regression Scope Catalog table
