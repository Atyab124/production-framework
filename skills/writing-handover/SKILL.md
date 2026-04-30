---
name: writing-handover
description: "Use when handing off work between agents, between waves of a phase, or at phase end. Default cadence: rolling-single-doc finalized at phase end (5/9 BINDING). Per-wave-immutable cadence is supported only when the plan declares qa_cadence: per-wave."
---

## Overview

PF v1 documented (audit Item 5): per-wave handovers are write-once-read-never when QA cadence is phase-end-only. Wave 3 research found **5/9 BINDING enterprise consensus on rolling-single-doc with milestone finalization**, **0/9 support per-wave-immutable** as default.

This skill prescribes the rolling-default cadence. SP ships zero handover artifact; binding citation falls back to Anthropic *Effective Context Engineering* §2.17 (file artifacts as cross-agent comms substrate).

**Microsoft Engineering Playbook + Wix Engineering + Atlassian + GitHub deployment + Google SRE on-call shift handoff + PagerDuty incident handoff** all support the rolling-doc default; per-wave handovers are kept as a conditional override for QA-per-wave plans.

## When to Use

- Handing off work from one agent to another (Builder → QA, Researcher → Architect, etc.).
- Closing a wave within a phase (multi-wave plan).
- Closing a phase (always finalizes the rolling doc).

Do NOT use:
- Within a single agent's work (use cycle-state.md append-line for that).
- For Tier 1 tasks (handover overhead exceeds work blast radius).

## Core Pattern

You MUST create a TodoWrite item per step.

### Step 1 — Locate or open the rolling handover

Convention: `docs/handovers/<phase-or-feature>.md`. Single rolling doc per phase. Open if it exists; create if not.

Frontmatter:
```yaml
---
feature: <name>
phase: <phase-id>
status: AWAITING_QA   # AWAITING_QA | QA_PASSED | BLOCKED
qa_cadence: phase-end  # phase-end (default) | per-wave (override)
---
```

### Step 2 — Append wave entry (NOT immutable)

For each wave / agent dispatch / cycle iteration, append a section:

```markdown
## Wave N — <YYYY-MM-DD UTC> — <agent name> — <status token>

### What was done
<concrete deliverables>

### Files touched
<list with one-line purpose>

### Decisions
<decision-grain — see implementation-decision-log skill>

### Open issues / handoff items
<what the next agent needs>

### Status
DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
```

### Step 3 — Update Phase History table at bottom (Wave 3 R-3 — append-only audit trail)

```markdown
## Phase History

| Date | Wave | Agent | Status | Key additions |
|---|---|---|---|---|
| 2026-04-30 | 1 | builder | DONE | Added X helper, removed Y constant |
| 2026-04-30 | 2 | qa | APPROVE_WITH_FIXES | Stage 1 ✅, Stage 2 has 2 MEDIUM findings |
| 2026-04-30 | 3 | builder | DONE | Fixed both findings; QA re-dispatch pending |
```

The Phase History table provides wave provenance without per-wave separate files. Replaces the audit-trail function that PF v1 per-wave separate docs served.

### Step 4 — Conditional per-wave file (override only)

If the plan declares `qa_cadence: per-wave` in frontmatter (PagerDuty configurable-rotation precedent — explicit override), produce separate per-wave files alongside the rolling doc:
- Rolling: `docs/handovers/<feature>.md`
- Per-wave: `docs/handovers/<feature>-wave-N.md`

This preserves PF v1 behavior for projects that need per-wave QA pass/fail traceability.

### Step 5 — Phase-end finalization

When the phase closes (all waves done; CTO marks phase COMPLETE in PROJECT-PLAN.md):
1. Flip frontmatter `status: AWAITING_QA → QA_PASSED` (or `BLOCKED` if open issues).
2. Append a final "Phase Close" section with: phase outcome, total waves, total decisions logged, link to QA findings doc.
3. The doc is now closed (Keep-a-Changelog finalization analog). Subsequent phase opens a new rolling doc.

Per Wix Engineering append-only discipline:

> "Do not update design log initial section once implementation started."

Translation: once a wave entry is appended, it is immutable. Revisions get new entries (e.g., "Wave 4 — REVISED Wave 2 entry's decision X").

## Anti-Patterns

### "Per-wave files for everything — they're more granular"

Item 5's empirical data: per-wave files are write-once-read-never when QA is phase-end-only. The granularity has cost (write friction) without proportional benefit (no read). Use the rolling default unless `qa_cadence: per-wave` is explicitly declared.

### "I'll edit the prior wave's entry to clarify"

Append-only. If clarification is needed, append a new entry referencing the prior. Editing breaks the audit trail.

### "Frontmatter status doesn't matter"

The status flip (`AWAITING_QA → QA_PASSED`) is the phase-close signal. Other agents (post-mortem, gate-3) read the frontmatter to know whether the phase is open or finalized. Don't skip.

## Quick Reference

- Default: rolling-single-doc per phase, finalized at phase end (5/9 BINDING).
- Conditional: `qa_cadence: per-wave` in frontmatter triggers per-wave files alongside rolling.
- Append-only per Wix discipline; revisions reference + supersede prior entries.
- Phase History table at bottom is the wave-provenance audit trail.
- Frontmatter status: `AWAITING_QA → QA_PASSED → (next phase)` OR `BLOCKED`.
- Zero SP precedent — falls back to Anthropic ECE §2.17 file-artifact substrate.

## Composability

- **Composable with `implementation-decision-log`** — decisions captured in the rolling doc's "Decisions" section reference the standalone decision log.
- **Composable with QA agent** — QA reads the rolling doc + finds the wave's `STATUS` in its findings doc.
- **Composable with `incident-response`** — at Phase 5 Resolve+Handoff, hand off to the post-mortem agent via the rolling doc + the live-timeline.
- **Composable with `parallel-reconciliation`** — when a wave dispatches N parallel agents, the reconciliation report gets linked from the rolling doc's wave entry.

## Citations

**SP precedent:** None — confirmed.

**Anthropic guidance:**
- *Effective Context Engineering* §2.17 — "agents can save information from tool call results as artifacts" (the rolling doc IS one)
- *Building Effective Agents* — agent persistence patterns

**Enterprise / OSS (5/9 BINDING on rolling-default):**
- Microsoft Engineering Playbook handover/decision-log patterns
- Wix Engineering Design-Log Methodology — append-only discipline
- Atlassian deployment-handoff docs: https://www.atlassian.com/incident-management
- GitHub deployment handoff (release-tag-as-handover)
- Google SRE shift-handover pattern: https://sre.google/sre-book/being-on-call/
- PagerDuty configurable-rotation: https://response.pagerduty.com/
- Keep-a-Changelog (finalization-on-close pattern)
- Agile sprint review + retrospective handoff
- Spotify squad handoff practices

**Companion PF v2 research:**
- `docs/research/skill-design-writing-handover.md` (Wave 3, Sonnet, 332L; 5/9 BINDING)
- v1 carryforward: `production-framework/templates/handover.template.md`
