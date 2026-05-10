---
name: tier-selection
description: "You MUST use this immediately after cycle-selection has chosen a cycle, and before dispatching any sub-agent. Classifies the task's blast radius as Tier 1, 2, or 3 to scale how rigorously the chosen cycle runs. Tier 1 → CTO executes directly (cycle skipped); Tier 2 → cycle runs minimal agent graph; Tier 3 → cycle runs full agent graph."
---

# Tier Selection — Scale Cycle Rigor to Blast Radius

> Anthropic-cited foundation: "Routing classifies an input and directs it to a specialized followup task." Tier selection routes the chosen cycle to a fast/slim/full execution shape.
> — *Building Effective AI Agents*, Anthropic, Dec 2024 (https://www.anthropic.com/research/building-effective-agents)

Tier selection is a trigger scan, not an estimate. Read the trigger list top-down, first match wins, output the tier. The only subjective rule: **when in doubt, step up.**

A typo run through a full Tier 3 cycle wastes the team. A realtime change run as a direct edit causes incidents. The three tiers exist because these two failure modes are equally damaging.

<HARD-GATE>
Do NOT dispatch any sub-agent until both cycle and tier are output. The cto-mode skill will block dispatch otherwise.
</HARD-GATE>

## Anti-Pattern: "I Already Know What This Is"

Skipping tier selection because the task feels obviously small is the leading cause of Tier 2 work silently requiring Tier 3. A one-line symptom ("button label wrong") can have a root cause that touches state reconciliation. Triage first, then re-run tier selection on the root cause.

## Anti-Pattern: "It's Just a Bug Fix"

Bug fixes inherit the tier of their root cause, not the symptom. A fix that touches schema, realtime, cache strategy, or cross-query writes is Tier 3 — even if the user-visible bug is one wrong number on a screen.

## Checklist

You MUST create a task for each of these and complete them in order:

1. **Identify task scope** — restate the task in one sentence, including the likely root cause (not just the symptom).
2. **Walk the trigger list top-down** — first match wins.
3. **Apply tie-breakers** — no match + <6 deliverables → Tier 2; no logic change → Tier 1; in doubt → step up.
4. **Output the tier and the matched trigger** — in plain text, in your reply.
5. **Invoke the matching workflow** — Tier 1 direct execution; Tier 2 → `writing-plans` (4-step); Tier 3 → architecture doc first, then `writing-plans` (6-step).

## The Three Tiers

**Tier 1 — Trivial.** Typo, style tweak, config value, one-line copy change, comment. No logic change. Cycle: direct execution. No plan, no doc update.

**Tier 2 — Small.** Isolated bug OR single feature that does not touch any Tier 3 trigger. Fewer than 6 deliverables. Cycle: 4-step — audit → plan → implement → production-readiness check.

**Tier 3 — Module / Phase.** Any Tier 3 trigger fires, OR ≥6 deliverables, OR multi-feature phase. Cycle: 6-step — architecture doc → research → plan → implement → QA → production-readiness check + handover.

## Trigger List

Scan top-down. First match wins:

| Condition | Tier |
|---|---|
| No logic change (typo / style / comment / config value) | 1 |
| Schema change (migration, column, constraint, index) | 3 |
| Realtime / subscription / event-stream change | 3 |
| Cache strategy change (invalidation, TTL, tag scope) | 3 |
| Cross-query writes (2+ queries on same data, same request) | 3 |
| Client-side state reconciliation (optimistic + rollback; polling + diff) | 3 |
| Multi-tenant boundary change (RLS policy, tenant filter, isolation primitive) | 3 |
| Authentication / authorization model change | 3 |
| New module or multi-feature phase | 3 |
| Deliverable count ≥6 | 3 |
| Project-specific trigger (per project's PROJECT-PLAN.md) | 3 |
| Isolated bug or single feature, <6 deliverables, no trigger above | 2 |
| In doubt | step up |

## What axis the triggers actually rate

Per `docs/research/tier-classification-risk-frameworks-2026-05-10.md` (industry risk) and `docs/research/tier-classification-ai-frameworks-2026-05-10.md` (AI multi-agent frameworks), 17 of 22 surveyed frameworks classify task rigor on multiple axes — most commonly Likelihood × Impact (industry, N=5 binding) and Scope × Required-Specialism (AI, N=8 binding). PF v2's trigger list collapses these into a single output, but each row in the trigger list above is best read as a **blast-radius indicator** (likelihood × impact-if-wrong), not a skill-domain flag.

**Skill-domain (which specialists to dispatch) is `cycle-selection`'s territory, not tier-selection's.** A "schema change" trigger fires Tier 3 because the blast radius of getting RLS wrong is large — not because a Database Engineer happens to be needed. Don't reason from "we need an X agent → step up tier"; reason from "if this is wrong the harm is Y → step up tier."

The trigger list is a fast-path lookup over the underlying axis (matching ITIL 4's Standard-Change pre-approval pattern). For tasks not covered by a trigger row, fall back to the 2-axis judgment (likelihood × impact) and step up in doubt.

## Common Mistakes

**Sizing from symptom, not root cause.** Triage first; tier-select on the root cause.

**Skipping the Tier 3 architecture doc for a "simple" feature.** If any trigger fires — realtime, cache, cross-query, RLS — the architecture doc is mandatory regardless of how small the feature feels. The doc is where blast radius is computed.

**Running Tier 1 for a task that silently triggers state reconciliation.** Optimistic UI changes look like frontend-only edits but they encode rollback logic. Any change to optimistic state is Tier 3.

**Assuming bug fixes are always Tier 1 or 2.** A bug whose root cause sits behind a Tier 3 trigger is Tier 3 work. Re-run tier selection after triage.
