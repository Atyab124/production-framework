---
name: slo-sli-contracts
description: "Use when designing the observability + reliability contract for a new feature or service — prescribes SLI definitions (4 golden signals as the floor), SLO targets (numeric, NOT derived from current performance), error-budget computation, and burn-rate alert wiring. Composes with sre-devops agent and gate-3 D4 + D5."
---

## Overview

SLO/SLI contracts are how a service's reliability promise is made explicit. Per Google SRE Book Ch. 4 + Workbook Ch. 2:

> "Service level objectives (SLOs) specify a target level for the reliability of your service."
> "Each objective has a separate error budget, defined as 100% minus (–) the goal for that objective."

Without an SLO catalog, "reliability" is a feeling. With one, it's a measurable contract that drives alerting, deployment cadence, and incident response.

**Enterprise grounding:** Google SRE Book Ch. 4 (SLOs) + Ch. 6 (four golden signals) + Workbook Ch. 2 (don't pick from current perf) + Ch. 5 (multi-window multi-burn-rate alerting); AWS Well-Architected Reliability Pillar; DORA Four Keys; Honeycomb high-cardinality / wide-events.

## When to Use

- Designing observability + reliability for a new service or feature.
- Auditing an existing service's SLO catalog for completeness.
- Filling `agents/sre-devops.md` SLO catalog for a feature.
- Filling `agents/architect.md` Quality-Attribute Matrix (Reliability + Performance Efficiency rows).

Do NOT use:
- For internal-only tools with no SLO commitment.
- For experimental features explicitly tagged as alpha (no production traffic).

## Core Pattern

You MUST create a TodoWrite item per step.

### Step 1 — Define SLIs (start with the 4 golden signals)

Per Google SRE Book Ch. 6:

> "The four golden signals of monitoring are latency, traffic, errors, and saturation. If you can only measure four metrics of your user-facing system, focus on these four."

For every user-visible surface, define:

- **Latency** — request latency P50 / P95 / P99 (user-perceived; not server-internal)
- **Traffic** — requests per second
- **Errors** — error rate (4xx + 5xx for HTTP; failed RPCs for gRPC)
- **Saturation** — system load relative to capacity (CPU / memory / connection pool / queue depth)

Multi-tenant systems extend with `tenant_id` as a high-cardinality field on every event (Honeycomb / wide-events). Per `gate-3-production-check` D7.

### Step 2 — Set SLO targets (numeric, NOT from current performance)

Per Workbook Ch. 2:

> "Don't pick SLOs from current performance. Pick them from what users need. Picking from current means you're shipping the current performance level as the contract — and the contract was never negotiated."

For each SLI, set a numeric SLO target that meets user need:

- Latency: "P95 < 500ms" (NOT "P95 < whatever-it-is-now")
- Errors: "< 0.1% errors over 28 days"
- Saturation: "< 80% CPU utilization at peak"

Document the target in the runbook + STACK-PATTERNS.md `slo-error-budget-policy` slot.

### Step 3 — Compute error budget (100% − target)

Per Google SRE Book Ch. 4:

> "Each objective has a separate error budget, defined as 100% minus (–) the goal for that objective."

If SLO is 99.9% availability: error budget is 0.1% (~43 minutes/month). The error budget is the unit of operational tolerance — releases consume it; outages consume it; deployment cadence is gated by remaining headroom.

### Step 4 — Wire multi-window multi-burn-rate alerts

Per Workbook Ch. 5:

> "In most cases, [Google believes] that the multiwindow, multi-burn-rate alerting technique is the most appropriate approach to defending your application's SLOs."

For every SLO, configure two windows:
- **Fast burn** — 2% of error budget consumed in 1 hour → page (urgent)
- **Slow burn** — 5% consumed in 6 hours → page (sustained issue)

Both must fire to page (avoids flapping; per Datadog burn-rate post). Single-window threshold alerts are an Anti-Pattern.

### Step 5 — Error Budget Policy enforcement

Per Workbook Error Budget Policy:

> "If the service has exceeded its error budget for the preceding four-week window, we will halt all changes and releases other than P01 issues or security fixes until the service is back within its SLO."

Document the policy in the runbook. When budget is exhausted: deploys halt; only P01 / security fixes ship. This is the policy gate-3 D13 reads.

### Step 6 — Multi-tenant tenant_id field on every event

Per Honeycomb high-cardinality:

> "Every observability event must include `tenant_id` as a high-cardinality field. Pre-aggregated metrics that drop the tenant dimension are rejected."

Wire `tenant_id` into:
- Log lines (structured events)
- Trace spans
- Metrics labels (cardinality budget per metric — typical: tenant_id × route × outcome)

Per `gate-3-production-check` D7: pre-aggregated tenant-blind metrics are rejected.

### Step 7 — Output runbook section

Append to the feature's runbook (`docs/runbook/<feature>.md`):

```markdown
## SLO catalog

| SLI | SLO target | Error budget | Burn-rate alerts |
|---|---|---|---|
| latency P95 | < 500ms | (computed) | fast: 2% in 1h; slow: 5% in 6h |
| error rate | < 0.1% | 99.9% over 28d | fast / slow per above |
| ... |

## Error Budget Policy
When budget exhausted: deploys halted. Only P01 / security fixes ship. Owner: <SRE on-call>.

## Multi-tenant observability
Every log/trace/metric carries `tenant_id`. Cardinality budget: tenant_id × route × outcome.
```

## Anti-Patterns

### "We'll set the SLO to current performance"

Workbook Ch. 2 explicitly forbids this. Current performance is the de-facto contract; "set SLO to current" makes that explicit but doesn't negotiate. Set SLOs from user need; if current performance is below need, the gap is a project, not a target.

### "Single-threshold alert on error rate is fine"

Single-threshold alerts produce flapping (constant pages on transient spikes) AND blind spots (slow burn under threshold ships an outage in slow motion). Multi-window multi-burn-rate is 5/5 BINDING per `gate-3-production-check` D5.

### "Pre-aggregated metrics are cheaper to store"

Pre-aggregated metrics that drop `tenant_id` are tenant-blind. The first cross-tenant incident becomes uninvestigatable. Per Honeycomb: wide events > pre-aggregated metrics for high-cardinality fields.

### "Error Budget Policy is theoretical; we never halt deploys"

If the policy doesn't fire, the SLO target is wrong. Either tighten the target, or accept that releases drove the budget consumption (this is the data Workbook EBP exists to surface).

## Quick Reference

- 4 golden signals as the SLI floor: latency / traffic / errors / saturation.
- SLO targets numeric + from user need (not current perf).
- Error budget = 100% − target.
- Multi-window multi-burn-rate alerts (fast 2%/1h + slow 5%/6h).
- Error Budget Policy: when exhausted, halt non-P01 deploys.
- Multi-tenant: `tenant_id` on every log / trace / metric per Honeycomb.

## Composability

- **Invoked by `agents/sre-devops.md`** for every new service/feature SLO catalog.
- **Reads from `templates/STACK-PATTERNS.md`** `slo-error-budget-policy` + `runbook-template-path` slots.
- **Pairs with `tenant-isolation`** — log layer carries tenant_id.
- **Pairs with `audit-trail`** — audit logs are observability events too.
- **Feeds `gate-3-production-check`** D4 (SLO/SLI catalog), D5 (burn-rate alerts), D6 (runbook), D7 (tenant-scoped observability), D13 (error budget headroom) evidence inputs.

## Citations

**SP precedent:** None — domain-specific.

**Anthropic guidance:** None direct — Anthropic doesn't publish SRE-specific guidance.

**Enterprise / OSS (≥3 satisfied):**
- Google SRE Book Ch. 4 (SLOs): https://sre.google/sre-book/service-level-objectives/
- Google SRE Book Ch. 6 (Monitoring Distributed Systems / four golden signals): https://sre.google/sre-book/monitoring-distributed-systems/
- Google SRE Workbook Ch. 2 (don't pick from current perf): https://sre.google/workbook/implementing-slos/
- Google SRE Workbook Ch. 5 (Alerting on SLOs / multi-window multi-burn-rate): https://sre.google/workbook/alerting-on-slos/
- Google SRE Workbook Error Budget Policy: https://sre.google/workbook/error-budget-policy/
- AWS Well-Architected Reliability Pillar: https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/
- DORA Four Keys: https://dora.dev/guides/dora-metrics-four-keys/
- Honeycomb high-cardinality / wide-events: https://www.honeycomb.io/blog/observability-101-terminology-and-concepts
- Datadog burn-rate alerting: https://www.datadoghq.com/blog/burn-rate-is-better-error-rate/

**Companion PF v2 research:**
- `docs/research/agent-design-sre-devops.md` (Google SRE + AWS WAF + DORA + Honeycomb verbatim quotes)
- `skills/gate-3-production-check/SKILL.md` D4 / D5 / D6 / D7 / D13 — read this skill's outputs
