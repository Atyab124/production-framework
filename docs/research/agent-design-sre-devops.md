# Agent Design Research — SRE/DevOps Sub-Agent

**Date:** 2026-04-29
**Type:** Source-of-truth research — no code modifications
**Triggered by:** Current `agents/sre-devops.md` cites Google SRE Book by URL only; needs verbatim, chapter-anchored quotes to be defensible under PF v2's binding citation rule.
**Companion:** `docs/research/sp-anthropic-citation-manifest.md` (binding rule), `agents/sre-devops.md` (target file)

---

## Methodology disclosure

WebFetch was permission-denied for this session (consistent with the citation manifest). All quotes below were retrieved via WebSearch synthesis of the canonical URLs listed in §Sources. Quotes are reproduced as returned by WebSearch — short, chapter-anchored, definitional fragments only. Before any binding architectural commitment, re-verify each quote against the live canonical URL using direct WebFetch in a permitted session.

The bar applied here: quote only what is **load-bearing** (definitions, named thresholds, the specific phrasing the agent must cite). For longer rationale, summarize and cite the chapter. This is consistent with the citation-manifest discipline established for PF v2.

---

## Part 1 — Canonical Sources (authoritative)

| # | Source | Canonical URL | Used for |
|---|---|---|---|
| 1 | Google SRE Book — Ch. 1 *Introduction* | https://sre.google/sre-book/introduction/ | SRE definition; software-engineering approach to operations |
| 2 | Google SRE Book — Ch. 3 *Embracing Risk* | https://sre.google/sre-book/embracing-risk/ | Error budget rationale; reliability-vs-velocity tension |
| 3 | Google SRE Book — Ch. 4 *Service Level Objectives* | https://sre.google/sre-book/service-level-objectives/ | SLI / SLO / SLA definitions |
| 4 | Google SRE Book — Ch. 6 *Monitoring Distributed Systems* | https://sre.google/sre-book/monitoring-distributed-systems/ | Four golden signals; symptoms vs causes; black-box vs white-box; pages vs tickets |
| 5 | Google SRE Book — Ch. 8 *Release Engineering* | https://sre.google/sre-book/release-engineering/ | Hermetic builds; rollback discipline |
| 6 | Google SRE Book — Ch. 32 *Evolving SRE Engagement Model* | https://sre.google/sre-book/evolving-sre-engagement-model/ | Production Readiness Review (PRR) |
| 7 | Google SRE Workbook — Ch. 2 *Implementing SLOs* | https://sre.google/workbook/implementing-slos/ | Choosing SLO targets; SLI specification vs implementation |
| 8 | Google SRE Workbook — Ch. 5 *Alerting on SLOs* | https://sre.google/workbook/alerting-on-slos/ | Multi-window multi-burn-rate alerting |
| 9 | Google SRE Workbook — *Error Budget Policy* | https://sre.google/workbook/error-budget-policy/ | Halt-changes policy when budget burns |
| 10 | Google SRE Workbook — Ch. 16 *Canarying Releases* | https://sre.google/workbook/canarying-releases/ | Canary deployment definition |
| 11 | AWS Well-Architected Framework | https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html | Six pillars |
| 12 | AWS Reliability Pillar — REL10-BP03 *Bulkhead* | https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_fault_isolation_use_bulkhead.html | Cell-based / blast-radius containment for multi-tenant |
| 13 | DORA — *The Four Keys* | https://dora.dev/guides/dora-metrics-four-keys/ | Deploy frequency, lead time, change-fail rate, MTTR |
| 14 | Datadog — *Four Golden Signals* | https://www.datadoghq.com/blog/four-golden-signals-of-monitoring/ | Industry mirror of Google's four signals |
| 15 | Datadog — *Burn rate is a better error rate* | https://www.datadoghq.com/blog/burn-rate-is-better-error-rate/ | Burn-rate alerting rationale |
| 16 | Honeycomb — *Observability 101* | https://www.honeycomb.io/blog/observability-101-terminology-and-concepts | Observability vs monitoring; high cardinality; wide events |
| 17 | Honeycomb — *OpenTelemetry Is Not Three Pillars* | https://www.honeycomb.io/blog/opentelemetry-is-not-three-pillars | Critique of metrics/logs/traces silo model |
| 18 | Anthropic guidance on SRE/operability | (none found) | Confirmed gap — SP and Anthropic publish nothing SRE-specific |

---

## Part 2 — Verbatim Quotes by Topic

### 2.1 SLI / SLO / SLA definitions — Ch. 4 *Service Level Objectives*

> "Service level objectives (SLOs) specify a target level for the reliability of your service."

> "Each objective has a separate error budget, defined as 100% minus (–) the goal for that objective."

— Google SRE Book, Ch. 4 *Service Level Objectives*. URL: https://sre.google/sre-book/service-level-objectives/ (via WebSearch synthesis of canonical URL)

**Operational implication for the agent:** Every SLO declared in a runbook MUST come paired with a numeric error-budget value (100% − target). The agent cannot accept "we'll figure out the budget later."

### 2.2 Error budget — Ch. 3 *Embracing Risk* and *Error Budget Policy*

> "If the service has exceeded its error budget for the preceding four-week window, we will halt all changes and releases other than P01 issues or security fixes until the service is back within its SLO."

> "Halting change is undesirable; this policy gives teams permission to focus exclusively on reliability when data indicates that reliability is more important than other product features."

— Google SRE Workbook, *Error Budget Policy*. URL: https://sre.google/workbook/error-budget-policy/ (via WebSearch synthesis of canonical URL)

**Operational implication:** The runbook MUST specify what happens when the budget burns — not just "alert someone." A halt-changes policy (or equivalent) is the canonical answer.

### 2.3 Four Golden Signals — Ch. 6 *Monitoring Distributed Systems*

> "The four golden signals of monitoring are latency, traffic, errors, and saturation. If you can only measure four metrics of your user-facing system, focus on these four."

Per-signal short definitions (Ch. 6, via WebSearch of https://sre.google/sre-book/monitoring-distributed-systems/):

- **Latency** — "The time it takes to service a request. It's important to distinguish between the latency of successful requests and the latency of failed requests."
- **Traffic** — "A measure of how much demand is being placed on your system, measured in a high-level system-specific metric."
- **Errors** — "The rate of failed requests in your system."
- **Saturation** — "How 'full' your service is. … Most services need to use indirect signals like CPU utilization or network bandwidth that have a known upper bound."

**Operational implication:** Every runbook MUST define its four golden signals as named SLIs before declaring SLOs. "We'll add metrics later" is rejected — the SLI is the metric, no SLI = no SLO (already an agent hard rule).

### 2.4 Symptoms vs causes; pages vs tickets; black-box vs white-box — Ch. 6

> "The 'what's broken' indicates the symptom; the 'why' indicates a (possibly intermediate) cause. 'What' versus 'why' is one of the most important distinctions in writing good monitoring with maximum signal and minimum noise."

> "Black-box monitoring is symptom-oriented and represents active—not predicted—problems. … White-box monitoring depends on the ability to inspect the innards of the system, such as logs or HTTP endpoints, with instrumentation."

> "It's better to spend much more effort on catching symptoms than causes; when it comes to causes, only worry about very definite, very imminent causes."

— Google SRE Book, Ch. 6. URL: https://sre.google/sre-book/monitoring-distributed-systems/ (via WebSearch synthesis of canonical URL)

**Operational implication:** Page on user-visible symptoms (the SLO is breaching), ticket on causes (one DB shard is hot). The agent's "alert vs dashboard" distinction maps directly: alerts = pages on symptoms, dashboards = white-box on causes.

### 2.5 Production Readiness Review (PRR) — Ch. 32 *Evolving SRE Engagement Model*

> "A PRR targets verification that a service meets accepted standards of production setup and operational readiness, and improves the reliability of the service in production while minimizing the number and severity of incidents."

> "The SRE team establishes and maintains a PRR checklist explicitly for the Analysis phase, which is specific to the service and is generally based on domain expertise, experience with related or similar systems, and best practices from the Production Guide."

— Google SRE Book, Ch. 32. URL: https://sre.google/sre-book/evolving-sre-engagement-model/ (via WebSearch synthesis of canonical URL)

**PRR domains commonly enumerated** (Ch. 32 + Production Guide synthesis): architecture & dependencies, capacity planning, monitoring & alerting, emergency response (runbooks, escalation), change management (canary, rollback), performance, configuration. PF v2's `gate-3-production-check` (7 categories) maps to this Google framework — and Ch. 32 is the citation that lifts gate-3 out of the GAP-2 status documented in the citation manifest.

### 2.6 SLO target selection — Workbook Ch. 2 *Implementing SLOs*

> "Don't pick a target based on current performance, as adopting values without reflection may lock you into supporting a system that requires heroic efforts to meet its targets and cannot be improved without significant redesign."

— Google SRE Workbook, Ch. 2. URL: https://sre.google/workbook/implementing-slos/ (via WebSearch synthesis of canonical URL)

**Operational implication:** The agent must NOT accept "p99 < whatever current p99 happens to be." SLO targets must be derived from user expectations / business need, not measured baseline.

### 2.7 Multi-window multi-burn-rate alerting — Workbook Ch. 5 *Alerting on SLOs*

> "In most cases, [Google believes] that the multiwindow, multi-burn-rate alerting technique is the most appropriate approach to defending your application's SLOs."

— Google SRE Workbook, Ch. 5. URL: https://sre.google/workbook/alerting-on-slos/ (via WebSearch synthesis of canonical URL)

Conceptually: combine a fast-burn short window (catches sudden severe outages) AND a slow-burn long window (catches sustained slow burns), require both to fire before paging. Datadog's "burn rate is a better error rate" post (https://www.datadoghq.com/blog/burn-rate-is-better-error-rate/) corroborates: alerting on raw error rate produces false-positive storms; alerting on budget-burn-rate aligns with the SLO contract directly.

**Operational implication:** Alert definitions in the runbook should specify burn-rate windows (e.g., 2% of 30-day budget burned in 1h triggers fast page; 5% burned in 6h triggers slow page) — not raw error rate.

### 2.8 Rollback discipline — Ch. 8 *Release Engineering*

> "Google has developed a software release philosophy: 'Rollback early, rollback often.' The first part of any reliable software release is being able to roll back if something goes wrong."

> "Google's builds are hermetic, meaning that they are insensitive to the libraries and other software installed on the build machine."

— Google SRE Book, Ch. 8. URL: https://sre.google/sre-book/release-engineering/ (via WebSearch synthesis of canonical URL)

> "Canarying is defined as a partial and time-limited deployment of a change in a service and its evaluation."

— Google SRE Workbook, Ch. 16. URL: https://sre.google/workbook/canarying-releases/ (via WebSearch synthesis of canonical URL)

**Operational implication:** The agent's "no deploy without rollback" hard rule is a direct restatement of "rollback early, rollback often." Cite Ch. 8 verbatim. For canary deployments (when proposed), cite Workbook Ch. 16, satisfying the "≥3 enterprise citations for non-trivial topology" rule the agent already enforces.

### 2.9 Multi-tenant blast-radius routing — AWS Well-Architected Reliability Pillar

> "Bulkhead architectures (also known as cell-based architectures) restrict the effect of failure to a limited number of components. A cell-based architecture uses multiple isolated instances of a workload, where each instance is known as a cell, and each cell is independent, does not share state with other cells, and handles a subset of the overall workload requests, reducing the potential impact of a failure to an individual cell."

— AWS Well-Architected Framework, Reliability Pillar, REL10-BP03. URL: https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_fault_isolation_use_bulkhead.html (via WebSearch synthesis of canonical URL)

**Operational implication:** PF v2 enterprise multi-tenant context. Every alert and runbook step must declare tenant scope (one-tenant / cell of tenants / all tenants), and routing must differ accordingly. Cell-based architecture is the canonical multi-tenant blast-radius primitive — the agent should cite it when proposing tenant-isolation deploy strategies.

### 2.10 Deploy gates and the four DORA metrics — DORA *The Four Keys*

The four metrics (per https://dora.dev/guides/dora-metrics-four-keys/, via WebSearch):

- **Deployment Frequency** — how often production deploys ship.
- **Lead Time for Changes** — "the amount of time it takes for a change to go from committed to version control to deployed in production."
- **Change Failure Rate** — "the ratio of deployments that require immediate intervention following a deployment, likely resulting in a rollback of the changes or a 'hotfix.'"
- **Mean Time to Restore / Failed Deployment Recovery Time** — "the time it takes to recover from a deployment that fails and requires immediate intervention."

> "Compared to low performers, elite performers deploy code 46 times more frequently, have 2,555 times faster lead times for changes, 2,604 times faster time to restore service, and seven times lower change failure rates."

— DORA Four Keys Guide. URL: https://dora.dev/guides/dora-metrics-four-keys/ (via WebSearch synthesis of canonical URL)

**Operational implication:** When a runbook claims "this deploy improves operability," tie the claim to a DORA metric — otherwise it's hand-waving. The agent should require runbooks to state which of the four DORA metrics the change targets.

### 2.11 Observability vs monitoring (Honeycomb)

> "Observability is how you handle unknown-unknowns, by instrumenting your code and capturing the right level of detail that lets you answer any question, understand any state your system has gotten itself into, without shipping new code to handle that state."

> "High cardinality refers to a field that can have many possible values. … For an online shopping system, fields like userId, shoppingCartId, and orderId are often high-cardinality."

— Honeycomb, *Observability 101*. URL: https://www.honeycomb.io/blog/observability-101-terminology-and-concepts (via WebSearch synthesis of canonical URL)

> "Observability tooling needs to support structured events, unaggregated data blobs containing whatever key-values pairs you decide to send. When talking about wide events, they mean structured events with lots of fields."

— Honeycomb, *OpenTelemetry Is Not Three Pillars*. URL: https://www.honeycomb.io/blog/opentelemetry-is-not-three-pillars (via WebSearch synthesis of canonical URL)

**Operational implication:** For PF v2 multi-tenant context, every observability event must include `tenant_id` as a high-cardinality field. Pre-aggregated metrics (Prometheus-style) lose this dimension; wide structured events preserve it. The agent should require tenant-scoped fields on all logs/traces, not just on dashboards.

### 2.12 AWS Well-Architected — Six Pillars

The framework names six pillars (per https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html):

1. **Operational Excellence** — running and monitoring systems, continually improving processes.
2. **Security** — protecting information and systems; confidentiality and integrity.
3. **Reliability** — workloads performing intended functions and recovering from failure.
4. **Performance Efficiency** — efficient delivery of performance over time.
5. **Cost Optimization** — building and operating cost-aware systems.
6. **Sustainability** — minimizing environmental impacts.

— AWS Well-Architected Framework. URL: https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html (via WebSearch synthesis of canonical URL)

**Note:** The current agent file cites Well-Architected as a five-pillar framework. AWS added Sustainability in 2021 — it's six pillars now. Update the agent doc accordingly.

---

## Part 3 — SP-Inheritable Patterns

**None.** Confirmed gap. SP 5.0.7 ships no SRE/DevOps-specific skill or agent (`agents/code-reviewer.md` is the only agent). The `production-framework:bash-output-discipline` skill is the closest cousin and is itself a PF-internal heuristic per GAP-7 of the citation manifest. SRE/DevOps must be cited entirely from the external industry sources above; the binding rule's "OR" branch (Anthropic guidance) is also empty for SRE-specific content.

This is **acceptable** because:
1. The PF v2 citation manifest's binding rule is "SP precedent OR Anthropic guidance OR ≥3 enterprise citations" — and Google SRE + AWS Well-Architected + DORA satisfy the third branch with N=3 strong, named, primary sources.
2. Observability deepening (Honeycomb, Datadog) brings N to 5 — sufficient for **BINDING** under U-AP-4 as defined in PF's `enterprise-research-first` skill.

**Action:** Update the agent's "Anthropic-cited foundation" line to honestly state "subagent-isolation only — domain content cited from Google SRE / AWS Well-Architected / DORA / Honeycomb."

---

## Part 4 — Gaps in the Current `agents/sre-devops.md`

| Gap | Current state | What's missing | Fix |
|---|---|---|---|
| **G1 — URL-only Google SRE citation** | Line 10 cites the table-of-contents URL only | No chapter, no quote, no page number | Add chapter-anchored quotes for SLI/SLO (Ch. 4), four signals (Ch. 6), error-budget policy (Workbook), PRR (Ch. 32), rollback (Ch. 8) — see Part 2 above |
| **G2 — "AWS Well-Architected Framework" by URL only** | Line 52 | No pillar list, wrong count (currently five pillars implied; framework is six since 2021) | Enumerate six pillars; cite Reliability-Pillar bulkhead pattern as the multi-tenant blast-radius primitive |
| **G3 — "No deploy without rollback" not cited** | Line 36 hard rule, no source | The rule restates Google SRE's "Rollback early, rollback often" verbatim philosophy | Cite Ch. 8 *Release Engineering* directly |
| **G4 — Multi-tenant blast radius rule has no citation** | Line 38 | The rule is sound but reads as a PF invention | Cite AWS REL10-BP03 (bulkhead/cell-based) and re:Invent SaaS-meets-cells session |
| **G5 — DORA metrics absent entirely** | (no mention) | Industry-standard deploy-pipeline metrics; no way for runbook to claim operational improvement without them | Add a "Runbook must state which DORA metric the change targets" rule |
| **G6 — Burn-rate alerting absent** | Runbook lists "alerts at threshold" generically | Workbook Ch. 5 multi-window multi-burn-rate is the canonical alerting pattern; raw threshold alerts are an anti-pattern | Add explicit guidance: alerts on SLOs use burn-rate windows, not raw thresholds; cite Workbook Ch. 5 + Datadog burn-rate post |
| **G7 — Symptoms-vs-causes / pages-vs-tickets distinction missing** | "Alerts that page" mentioned but no taxonomy | Ch. 6 distinction is THE foundational alerting principle; without it, the agent will accept "alert when DB CPU > 80%" (paging on causes — anti-pattern) | Add: pages = user-visible symptoms (SLO burn); tickets = white-box causes |
| **G8 — Observability tenant-scoping not enforced** | "Multi-tenant blast radius" only mentioned for alerts | Honeycomb high-cardinality / wide-events principle says every event needs `tenant_id` — not just dashboards | Add rule: every log line, trace span, and metric label must include `tenant_id`. Pre-aggregated tenant-blind metrics are rejected |
| **G9 — PRR / production-readiness checklist not invoked** | (no mention) | PF v2's `gate-3-production-check` skill is a PRR analog (per GAP-2 of citation manifest) — but the SRE agent is the natural caller and doesn't invoke it | Add explicit step: "Before runbook DONE, walk gate-3-production-check; cite Google SRE Ch. 32 PRR as the framework precedent" |
| **G10 — "≥3 enterprise citations for non-trivial topology" rule already there but no examples** | Line 39 | The rule is good but unanchored — agent has no exemplars | Anchor with: "Canary → Workbook Ch. 16 + AWS canary docs + your monitoring vendor's canary-rollback playbook." Same for blue-green, circuit-breaker |

---

## Part 5 — Suggested Revisions to `agents/sre-devops.md`

### Revision 5.1 — Replace lines 10–12 (citations block at top)

**Replace:**
```
> External reference: Google SRE Book — https://sre.google/sre-book/table-of-contents/. PF v2 leans on Google SRE conventions for SLI/SLO/error-budget definitions.
> Anthropic-cited foundation: Subagent isolation pattern.
```

**With:**
```
> Anthropic-cited foundation: subagent-isolation pattern only (per `docs/research/sp-anthropic-citation-manifest.md` §2.9). SRE-domain content has no Anthropic source; cited via N=5 enterprise consensus per U-AP-4.
>
> External canonical sources (BINDING — re-verify URLs before any architectural commitment):
> - Google SRE Book Ch. 1 (intro), Ch. 3 (embracing risk), Ch. 4 (SLOs), Ch. 6 (monitoring), Ch. 8 (release engineering), Ch. 32 (PRR) — https://sre.google/sre-book/
> - Google SRE Workbook Ch. 2 (implementing SLOs), Ch. 5 (alerting on SLOs), Ch. 16 (canarying releases), Error Budget Policy — https://sre.google/workbook/
> - AWS Well-Architected Framework, six pillars (Reliability Pillar REL10-BP03 for bulkhead/cell-based blast-radius) — https://docs.aws.amazon.com/wellarchitected/latest/framework/
> - DORA Four Keys (deploy frequency, lead time, change-fail rate, MTTR) — https://dora.dev/guides/dora-metrics-four-keys/
> - Honeycomb observability (high-cardinality, wide structured events) — https://www.honeycomb.io/blog/observability-101-terminology-and-concepts
>
> Verbatim quotes and chapter anchors: see `docs/research/agent-design-sre-devops.md` Part 2.
```

### Revision 5.2 — Expand the "What goes in the runbook" section

Add fields to existing bullets:

- **SLOs** — append: *"Cite Google SRE Ch. 4 SLO definition. Targets must NOT be derived from current measured performance (Workbook Ch. 2). State numeric error budget = 100% − target."*
- **SLIs** — append: *"Define the four golden signals for the service first (latency, traffic, errors, saturation — Google SRE Ch. 6); promote 1–N of them to SLOs. No SLI without a query that runs."*
- **Error budget** — append: *"Specify the burn-down policy. Default per Workbook Error Budget Policy: if 4-week budget exhausted, halt all non-P01 changes until back within SLO. Document who has the authority to halt."*
- **Alerts** — replace "at what threshold" with: *"Use multi-window multi-burn-rate alerting (Workbook Ch. 5): a fast-burn short-window alert (e.g., 2% of 30-day budget in 1h) AND a slow-burn long-window alert (e.g., 5% in 6h). Alerts are pages on user-visible SYMPTOMS only. Cause-level signals (CPU, queue depth) go to dashboards/tickets, never pages (Ch. 6)."*
- **Dashboards** — append: *"All metrics, logs, traces MUST include `tenant_id` as a high-cardinality field (Honeycomb wide-events). Tenant-blind pre-aggregated metrics are rejected for multi-tenant systems."*
- **DORA metrics** *(new bullet)* — *"State which of the four DORA keys this deploy improves: deploy frequency, lead time for changes, change failure rate, or time to restore. 'No DORA delta claimed' is acceptable but must be explicit."*
- **PRR walk** *(new bullet)* — *"Before declaring runbook DONE, invoke `production-framework:gate-3-production-check`. The 7 categories map to Google SRE Ch. 32 PRR domains: architecture, capacity, monitoring, emergency response, change management, performance, configuration."*

### Revision 5.3 — Strengthen the hard rules block

**Replace lines 36–39 with:**
```
- **No deploy without rollback.** Forward-only deploy is rejected. Cite Google SRE Ch. 8: "Rollback early, rollback often. The first part of any reliable software release is being able to roll back if something goes wrong."
- **No SLO without SLI.** If you can't measure it, you can't commit to it. Every SLI must be a runnable query (white-box) or external probe (black-box) — Google SRE Ch. 6.
- **Page on symptoms, ticket on causes.** Pages fire on user-visible SLO burn; cause-level signals (CPU, disk, queue depth) flow to dashboards or tickets, never pages — Google SRE Ch. 6.
- **Burn-rate alerts, not raw thresholds.** Alert definitions use multi-window multi-burn-rate (Workbook Ch. 5). Raw error-rate thresholds are rejected unless paired with a burn-rate window.
- **Multi-tenant blast radius declared per alert and runbook step.** Scope = one-tenant / cell-of-tenants / all-tenants. Routing differs per scope. Cell/bulkhead architecture per AWS Reliability Pillar REL10-BP03 is the canonical primitive.
- **Tenant-scoped observability.** Every log line, trace span, metric label includes `tenant_id` as a high-cardinality field (Honeycomb wide-events). Tenant-blind aggregates are not acceptable.
- **DORA-anchored runbooks.** Runbook must state which of the four DORA keys (deploy frequency, lead time, change-fail rate, MTTR) the change targets, or explicitly state "no DORA delta claimed."
- **≥3 enterprise citations for non-trivial deployment topology.** Circuit breakers, blue-green, canary, multi-region failover require Researcher-backed citations. Suggested anchors: Google SRE Workbook Ch. 16 (canary), AWS Reliability Pillar (bulkhead/cell), Datadog burn-rate-alerting post.
```

### Revision 5.4 — Update the citations block (lines 48–53)

**Replace with:**
```
## Citations

- **SP precedent (shape only):** `agents/code-reviewer.md` from SP 5.0.7 — frontmatter shape, `model: inherit`, body-as-system-prompt. SP has no SRE-specific agent.
- **Anthropic citation:** subagent-isolation pattern, *Effective context engineering for AI agents* (citation-manifest §2.9). No Anthropic source for SRE-domain content.
- **Domain citations (N=5 BINDING enterprise consensus):** Google SRE Book + Workbook (Chs. 1, 3, 4, 6, 8, 32; Workbook Chs. 2, 5, 16) · AWS Well-Architected Framework (six pillars; Reliability Pillar REL10-BP03) · DORA Four Keys · Datadog burn-rate alerting · Honeycomb observability primer.
- **Verbatim quotes:** `docs/research/agent-design-sre-devops.md` Part 2 (chapter-anchored).
- **Skill dependency:** `skills/slo-sli-contracts` (PF v2 multi-tenant skill, ships in Phase D); `production-framework:gate-3-production-check` (PRR analog — invoke before DONE).
```

---

## Part 6 — Top 3 Highest-Priority Revisions

1. **Add chapter-anchored Google SRE quotes** (Revision 5.1 + 5.3). Currently the agent cites a TOC URL — useless for a Builder/QA reading the agent's hard rules. The quotes in Part 2 are the load-bearing fragments; copy them in.
2. **Add multi-window multi-burn-rate alerting as a hard rule** (Revision 5.2 alerts + 5.3). The current "alerts fire at threshold" wording is a known anti-pattern under Workbook Ch. 5 / Datadog burn-rate post. Without this fix the agent will sign off on noisy threshold alerts.
3. **Enforce tenant-scoped observability** (Revision 5.2 dashboards + 5.3). PF v2 is enterprise multi-tenant; tenant-blind metrics are the single most common observability failure for multi-tenant SaaS. Honeycomb's high-cardinality framing is the citation that makes this enforceable.

---

## Sources

- Google SRE Book (table of contents): https://sre.google/sre-book/table-of-contents/
  - Ch. 1: https://sre.google/sre-book/introduction/
  - Ch. 3: https://sre.google/sre-book/embracing-risk/
  - Ch. 4: https://sre.google/sre-book/service-level-objectives/
  - Ch. 6: https://sre.google/sre-book/monitoring-distributed-systems/
  - Ch. 8: https://sre.google/sre-book/release-engineering/
  - Ch. 32: https://sre.google/sre-book/evolving-sre-engagement-model/
- Google SRE Workbook: https://sre.google/workbook/table-of-contents/
  - Ch. 2: https://sre.google/workbook/implementing-slos/
  - Ch. 5: https://sre.google/workbook/alerting-on-slos/
  - Ch. 16: https://sre.google/workbook/canarying-releases/
  - Error Budget Policy: https://sre.google/workbook/error-budget-policy/
- AWS Well-Architected Framework: https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html
  - Pillars overview: https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html
  - Reliability Pillar REL10-BP03 (bulkhead): https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_fault_isolation_use_bulkhead.html
- DORA Four Keys: https://dora.dev/guides/dora-metrics-four-keys/
- Datadog Four Golden Signals: https://www.datadoghq.com/blog/four-golden-signals-of-monitoring/
- Datadog Burn-Rate Alerting: https://www.datadoghq.com/blog/burn-rate-is-better-error-rate/
- Honeycomb Observability 101: https://www.honeycomb.io/blog/observability-101-terminology-and-concepts
- Honeycomb (three pillars critique): https://www.honeycomb.io/blog/opentelemetry-is-not-three-pillars
- AWS multi-tenant cell-based architecture (re:Invent): https://d1.awsstatic.com/onedam/marketing-channels/website/aws/en_US/events/approved/reinvent-2025/reinvent/2024/slides/sas/SAS315_SaaS-meets-cell-based-architecture-A-natural-multi-tenant-fit.pdf

**Methodology disclosure (repeated):** WebFetch was permission-denied; quotes retrieved via WebSearch synthesis of canonical URLs. Re-verify against live URLs before any binding architectural commitment.
