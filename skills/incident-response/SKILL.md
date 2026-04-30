---
name: incident-response
description: "Use during a LIVE production fire — fire is currently affecting users; rollback safety > root cause; minutes-to-resolve > completeness-of-fix. Distinct from triage (unclear bug report from a user), gate-3-production-check (pre-ship gate), and post-mortem (retrospective). Composes with debugger (diagnose), writing-handover (retro doc), and hands off to post-mortem agent for retro after resolution."
---

## Overview

Live production fires have different optimization targets than dev bug fixes: rollback safety dominates root cause; communication discipline dominates code; minutes-to-resolution dominates completeness-of-fix. PF v2's existing flow (`triage` → `debugger` → fix → verify → Gate 3) is half-day or more and is the wrong shape for fire-already-burning scenarios.

**Enterprise grounding:** 6/6 sources name **Detect → Mitigate → Resolve+Handoff** as the load-bearing phase set (Google SRE Book Ch. 13 + Ch. 14, Google SRE Workbook Incident Response, PagerDuty Incident Response, Atlassian Incident Management Handbook, AWS Incident Manager, ITIL 4). Convergent **5-phase spine: Detect → Triage → Contain → Mitigate → Resolve+Handoff.**

## The 5-Phase Spine

```
Detect → Triage → Contain → Mitigate → Resolve+Handoff
```

Each phase has a distinct remediation lever (Lunney 2017 mapping). Don't skip phases; you can compress them when severity is low.

| Phase | Goal | Owner | Output |
|---|---|---|---|
| 1. Detect | confirm the fire exists | on-call, monitoring | timestamp + alert source |
| 2. Triage | classify severity + scope | on-call | SEV1–SEV5 + tenant/user blast estimate |
| 3. Contain | stop the bleed | on-call + Builder (rollback) | rollback executed OR explicit "forward-fix" decision with rationale |
| 4. Mitigate | reduce blast radius further | Builder + SRE/DevOps | follow-up patch / kill-switch / capacity bump |
| 5. Resolve+Handoff | close the incident; hand to post-mortem | CTO | live-timeline artifact + handoff message |

<HARD-GATE>
**Rollback is the first action in Contain (Phase 3), not a fallback.**

Per Google SRE Ch. 8 ("Rollback early, rollback often") and PagerDuty Remediate ("high-pressure situations require fast, reversible actions"): in Phase 3, the FIRST action is to evaluate rollback. If rollback restores service, take it; investigate root cause in retro. Forward-fix is the exception, not the default — it requires explicit rationale (rollback would lose data, rollback was already taken and didn't fix, etc.).

A "forward-fix because the rollback would be slow" decision without explicit reasoning is a discipline failure. Document the decision in the live timeline.
</HARD-GATE>

## When to Use

- **A real production incident is happening NOW** — users are affected, paging fired, error rate spiked, etc.
- **A rollback decision must be made within minutes**, not hours.
- **The scope of impact (tenants, users, services) is uncertain.**

Do NOT use for:
- A user-reported bug with no live impact → use `triage` instead.
- A pre-ship gate failure → use `gate-3-production-check` recovery path.
- A retrospective on an incident that already resolved → use `post-mortem` agent directly.

## Core Pattern

You MUST create a TodoWrite per phase. Compress aggressively when SEV is low; don't skip.

### Phase 1 — Detect

- **Confirm the fire is real** (not a flapping alert). Cross-reference: alert text + dashboard + manual reproduction.
- **Note the start timestamp (UTC).** This becomes `t₀` in the post-mortem timeline.
- **Open the live-timeline artifact** at `docs/incidents/live-<incident-slug>-<UTC>.md`. Append timestamps + observations as the response unfolds. Hand-off to `post-mortem` reuses this verbatim — no duplicate data entry.

### Phase 2 — Triage (live-fire variant)

This is NOT the `triage` skill (which routes user-reported bugs). Live-fire triage classifies severity:

- **SEV1** — production down OR data loss/corruption OR cross-tenant data exposure
- **SEV2** — meaningful degradation for majority of users
- **SEV3** — partial degradation, minority of users (data-loss/cross-tenant variant only)
- **SEV4–5** — minor regression, scheduled fix → exit this skill, route to normal bug-fix flow

(Severity table imported by reference from `agents/post-mortem.md` Step 0 — do NOT duplicate.)

### Phase 3 — Contain (rollback-first HARD-GATE)

Per HARD-GATE above. Order:

1. **Rollback evaluation FIRST.** Identify the deploy / migration / config change that correlates with the start timestamp. Can it be reverted?
2. **If rollback restores service:** take it. Document in live-timeline. Investigation continues, but service is restored.
3. **If rollback isn't viable** (data loss, already taken, etc.): document WHY in live-timeline, then proceed to forward-fix path.
4. **Forward-fix path:** dispatch `debugger` agent for time-boxed root-cause investigation (2-hour budget for SEV1/2). After 2 hours without RC, escalate to architectural review per `debugger` 3-fixes-question-architecture rule.

### Phase 4 — Mitigate

- Apply containment patches (kill-switch, capacity bump, traffic shift) to reduce blast radius further.
- Communicate to affected users (status page, email).
- Continue investigation in parallel.

### Phase 5 — Resolve+Handoff

- **Mark service restored** when error rate / SLO is back within budget.
- **Update the live-timeline** with `t₅` (resolution time).
- **Hand off to `post-mortem` agent** with the live-timeline as input. The post-mortem agent reads it as its Timeline source — no duplicate data entry.
- **Lunney action items:** the post-mortem agent (not this skill) generates ≥1 Prevent + ≥1 Detect action items per its existing checklist.

## Anti-Patterns

### "Forward-fix because rollback is slow"

Without explicit reasoning, this is a discipline failure. Rollback's slowness is a known cost. Document why forward-fix is faster OR safer than rollback in this specific incident, in the live-timeline. "Rollback would take 10 minutes; forward-fix in 5" is acceptable rationale; "rollback feels slow" is not.

### "We can skip the live-timeline; we're too busy fighting the fire"

The live-timeline is the post-mortem's input. Without it, the retro starts from blank. Two-line entries during the fire (timestamp + observation) cost ~5 seconds each and save the post-mortem agent from reconstructing from memory.

### "SEV3, no need for live-fire response"

SEV3 with data-exposure variant IS live-fire (see severity table). Cross-tenant exposure at any scope triggers full response.

### "We resolved it; no post-mortem needed"

SEV1/SEV2 incidents REQUIRE full post-mortem (per `agents/post-mortem.md` Step 0). The live-timeline's hand-off to post-mortem is mandatory; do not skip.

## Red Flags

| Excuse | Reality |
|---|---|
| "Rollback would lose 10 minutes of writes" | Document this in live-timeline. Forward-fix is now the explicit path. |
| "It's just affecting tenant X" | Cross-tenant SEV1 is rare; single-tenant data-loss is still SEV1. Don't downgrade. |
| "We don't have a status page" | Communication discipline is part of mitigation; if no status page, an internal Slack message + email to affected users counts. |
| "Debugger is taking too long; let me just guess" | After 3 failed hypotheses, escalate to architectural review per `debugger` skill. Don't compound the incident with bad fixes. |
| "Post-mortem can wait until tomorrow" | The hand-off message goes immediately; the post-mortem doc itself can be drafted in the next 24-48h. |

## Quick Reference

- 5-phase spine: Detect → Triage → Contain → Mitigate → Resolve+Handoff.
- Rollback FIRST in Contain (HARD-GATE). Forward-fix requires explicit rationale.
- Live-timeline at `docs/incidents/live-<slug>-<UTC>.md` is mandatory.
- Severity table imported by reference from `post-mortem.md` Step 0 — no duplication.
- SEV3 data-loss/cross-tenant variant → full live-fire response. SEV4-5 → exit skill.
- Hand off to `post-mortem` agent at Phase 5 — live-timeline is its input.

## Composability

- **Composable with `triage`** — DIFFERENT skills. `triage` is for user-reported bugs with no live impact; `incident-response` is for live fires.
- **Composable with `debugger`** — dispatched for time-boxed root-cause investigation in Phase 3 forward-fix path.
- **Composable with `writing-handover`** — produces the retro doc shape after Phase 5.
- **Hands off to `post-mortem` agent** at Phase 5 — live-timeline is the post-mortem's Timeline source.
- **Distinct from `gate-3-production-check`** — gate-3 is pre-ship; incident-response is post-ship live fire.

## Citations

**SP precedent:** None — SP has no incident-response skill. Adjacent: `verification-before-completion` for "evidence at speed."

**Anthropic guidance:**
- *Building Effective Agents* — orchestration patterns; agent dispatch under time pressure
- *Effective Context Engineering* — file artifacts (live-timeline) surviving `/compact`

**Enterprise / OSS (≥3, satisfied 6):**
- Google SRE Book Ch. 13 *Emergency Response* + Ch. 14 *Managing Incidents*: https://sre.google/sre-book/managing-incidents/
- Google SRE Workbook *Incident Response*: https://sre.google/workbook/incident-response/
- PagerDuty Incident Response (open-source IR runbook): https://response.pagerduty.com/
- Atlassian Incident Management Handbook: https://www.atlassian.com/incident-management
- AWS Incident Manager
- ITIL 4 Service Operation triage workflow

**Cross-references (do NOT duplicate content):**
- `agents/post-mortem.md` Step 0 (severity table) — IMPORT BY REFERENCE
- Lunney USENIX 2017 (cited in post-mortem research) — action-item taxonomy used at hand-off, not in this skill
- `agents/debugger.md` (dispatched in Phase 3 forward-fix path)

**Companion PF v2 research:**
- `docs/research/skill-design-incident-response.md` (Wave 1, Opus, 320L)
