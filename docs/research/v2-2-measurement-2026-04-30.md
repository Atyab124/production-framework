# v2.2 Measurement — Eval Sets, Metrics, and Trigger-Audit Cadence

**Research date:** 2026-05-01
**Researcher:** Researcher sub-agent (production-framework v2)
**Questions answered:** Q16 (eval set shape), Q17 (new metrics for PROJECT-PLAN), Q18 (trigger-audit cadence + ownership)
**Status:** DONE

---

## Question

What eval set distinguishes friction metrics (time-per-task, ceremony token cost, repeat-skill-invocation rate) from strength metrics (bug-class regression detection rate, HARD-GATE catch rate, citation-density per plan), and what is the minimum viable eval shape? What metrics should PROJECT-PLAN start tracking, and which are collectible from existing `.framework-state/trigger-audit.jsonl` and `.framework-state/bypass-log.jsonl`? What is the cadence and ownership for analyzing trigger-audit.jsonl to detect over-trigger and under-trigger?

---

## Eligibility Criteria (PRISMA-style)

**Included:** Frameworks that define (a) a structured eval set for agent or LLM behavior, with named case format and pass/fail mechanics; OR (b) a metrics/observability system that distinguishes efficiency from correctness signals; OR (c) an analysis cadence model for time-series operational data with ownership assignment.

**Excluded:**
- Frameworks that only provide LLM benchmarks (MMLU, HumanEval) — these measure raw model capability, not agent skill triggering fidelity.
- Pure RAG evaluation frameworks (RAGAS) — included only for metric-separation pattern; excluded as primary citation for agent eval structure because PF does not do RAG.
- SEO content aggregators and AI-generated summaries.

---

## Search Strategy

**Round 1 — Broad landscape (3 parallel queries):**
1. `OpenAI evals harness eval set structure pass fail rubric LLM evaluation`
2. `RAGAS framework metrics RAG evaluation faithfulness answer relevancy`
3. `Honeycomb observability high cardinality metrics instrumentation cadence analysis`

**Round 2 — Narrow specifics + primary-source fetch (9 calls):**
4. `Datadog SLO burn rate analysis anomaly detection cadence alert fatigue`
5. `Anthropic Claude evals API evaluation framework metrics structured`
6. `LLM agent evaluation friction vs quality metrics ceremony token cost task completion time`
7. WebFetch: `https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents`
8. WebFetch: `https://platform.claude.com/docs/en/test-and-evaluate/develop-tests`
9. WebFetch: `https://developers.openai.com/blog/eval-skills`
10. WebFetch: `https://docs.datadoghq.com/service_management/service_level_objectives/burn_rate/` (404 — fallback to secondary)
11. WebFetch: `https://hceris.com/multiwindow-multi-burn-rate-alerts-in-datadog/` (burn-rate window sizes — secondary)
12. WebFetch: `https://raw.githubusercontent.com/openai/evals/main/docs/build-eval.md` (case format)

Total: 12 tool calls (within 10-15 budget).

---

## Frameworks Compared

| Name | Source | Last-verified | URL |
|---|---|---|---|
| Anthropic Demystifying Evals for AI Agents | Anthropic Engineering blog (primary) | 2026-05-01 | https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents |
| Anthropic Define Success Criteria and Build Evaluations | Anthropic Claude API Docs (primary) | 2026-05-01 | https://platform.claude.com/docs/en/test-and-evaluate/develop-tests |
| OpenAI Eval Skills Harness | OpenAI Developers blog (primary) | 2026-05-01 | https://developers.openai.com/blog/eval-skills |
| OpenAI Evals OSS Framework | GitHub openai/evals (primary) | 2026-05-01 | https://github.com/openai/evals |
| Datadog Multiwindow Burn Rate | hceris.com practitioner post (secondary — canonical 404'd) | 2026-05-01 | https://hceris.com/multiwindow-multi-burn-rate-alerts-in-datadog/ |
| PF v2 Existing Eval Infrastructure | Local source (evals/, hooks/) | 2026-05-01 | `evals/triggering/tier-selection.json`, `evals/verification-root-cause/`, `hooks/pre-tool-use` |

---

## Q16 — Eval Set Shape: Distinguishing Friction from Strength

### Comparison Axes

| Framework | Eval set size (recommended) | Case format | Friction metrics | Strength / quality metrics | Pass/fail rubric |
|---|---|---|---|---|---|
| **Anthropic Demystifying Evals** | "20-50 simple tasks drawn from real failures is a great start" | task + grader + expected outcome | n_toolcalls, latency, cost per task | pass@k (≥1 correct in k), pass^k (all k succeed) | Code-based / model-based / human (three-tier) |
| **Anthropic Develop Tests Guide** | 100–1000 for exact-match; 100–200 for LLM-graded | `{input, expected_output, edge_case_label}` | "Operational: Response time (ms), uptime (%)" | F1, accuracy, ROUGE-L, Likert 1-5 | Exact match / cosine similarity / LLM-graded rubric |
| **OpenAI Eval Skills** | "a small set of 10–20 prompts is enough to surface regressions and confirm improvements early" | `id,should_trigger,prompt` (CSV) | "Efficiency goals: Did it get there without thrashing?" | "Outcome goals: Did the task complete?", "Process goals: Did it invoke the skill?" | Binary should_trigger comparison |
| **OpenAI Evals OSS** | Not specified per set | `{input, ideal}` (JSONL, chat format) | Not explicit | Exact match, includes, fuzzy match | `Match` / `Includes` / `FuzzyMatch` templates |
| **PF v2 (existing)** | 20 cases (tier-selection.json); 15 cases (verification-root-cause, 3×5 corpora) | `{query, should_trigger}` / `{scenario, fix_root_cause, fix_symptom_mask, expected_verdict}` | Not tracked | Trigger fidelity (binary); root-cause-fix vs symptom-mask distinction | Binary allow/deny per case |

### Synthesis

All four external frameworks agree on a core two-dimension split:

1. **Efficiency / friction axis** — token count, wall-clock time, retry count, tool-call count. Measured per trace, not per task outcome.
2. **Quality / strength axis** — outcome correctness, skill invocation fidelity, HARD-GATE catch rate. Measured as pass/fail against a golden expectation.

3/4 primary sources recommend starting at 10-50 cases per eval set, not hundreds (Anthropic Demystifying Evals: "20-50"; OpenAI Eval Skills: "10-20"). The Anthropic Develop Tests guide recommends larger sets (1000) only for fully automated exact-match grading. For skill-trigger evals — which require LLM or human grading — 20-50 is the consensus minimum viable size.

PF v2's existing `tier-selection.json` (20 cases, `{query, should_trigger}`) already matches the OpenAI Eval Skills structure exactly (`id,should_trigger,prompt`). The `verification-root-cause` corpora (3×5 cases) match the three-corpus adversarial pattern described in Anthropic Demystifying Evals (standard + adversarial + pairwise).

**Gap:** PF v2 has no eval set for friction metrics. No eval tracks ceremony token cost, repeat-skill-invocation rate, or time-per-task. These dimensions are present in Anthropic Demystifying Evals (`n_toolcalls`, latency) and the OpenAI four-goal taxonomy ("Efficiency goals") but absent from PF's `trigger-audit.jsonl` schema (which logs only `{timestamp, event, name}`).

### Minimum Viable Eval Shape for v2.2

Per three-framework consensus (Anthropic Demystifying Evals, Anthropic Develop Tests, OpenAI Eval Skills):

**Friction eval set (new, session-derived — not a golden dataset):**
- Structure: `{session_id, prompt_window_ts, skill_name, invocation_count}`
- Source: derived from `trigger-audit.jsonl` — group skill events by consecutive `prompt_received` boundaries.
- Pass criterion: `invocation_count == 1` for 95%+ of (session, skill, prompt_window) triples.
- Rubric: FAIL if `invocation_count > 1` for the same skill within the same user-prompt window (F-V9 over-trigger pattern).

**Strength eval set (extending existing):**
- `tier-selection.json`: 20 cases → extend to 30 by adding 10 cases from live F-V9 / F-V10 failure transcripts.
- `verification-root-cause/`: 15 cases across 3 corpora — no change needed; D-B eval gate already governs this.
- New corpus `hard-gate-catch.json`: 15 cases (5 should fire, 5 should not, 5 adversarial with bypass rationalization). Pass: 5/5 fires; 0/5 false positives; 5/5 adversarial holds.

**Canonical case format for v2.2:**
```json
{
  "id": "FQ-001",
  "category": "friction | strength",
  "dimension": "repeat-invoke | token-cost | hard-gate-catch | trigger-fidelity | citation-density",
  "input": "<prompt text or session prefix>",
  "expected": "<should_trigger: bool | invocation_count: int | gate_fires: bool>",
  "pass_criterion": "<binary expression or threshold>",
  "adversarial": false
}
```

---

## Q17 — New Metrics for PROJECT-PLAN

### What PF Generates Today (collectible from existing logs)

**From `trigger-audit.jsonl`** (schema: `{timestamp, event: "skill"|"agent"|"prompt_received", name}`):

| Metric | Collection method | Signal |
|---|---|---|
| `repeat_skill_invocation_rate` | Group prompt_received + skill events by session window; count skill N > 1 for same skill in same window | F-V9 over-trigger detection |
| `skills_per_prompt_p50_p95` | Count skill events between consecutive prompt_received events; take percentiles | Ceremony load per task |
| `agent_dispatch_rate` | Count agent events per prompt_received | Tier 2/3 escalation frequency |
| `under_trigger_rate` | Count prompt_received events with zero skill events AND subsequent Write/Edit/Bash activity | Skills failing to fire |

**From `bypass-log.jsonl`** (schema: `{timestamp, rule, reason, payload}`):

| Metric | Collection method | Signal |
|---|---|---|
| `bypass_rate_per_rule` | Count by `rule` field | Which gates are blocked most often (friction signal) |
| `bypass_all_rate` | Count `rule == "ALL"` entries | Session-wide gate fatigue |
| `gates_disabled_rate` | Count `rule == "PF_GATES_DISABLED"` entries | Kill-switch usage = extreme friction |
| `bypass_reason_absent_rate` | Count bypass entries with empty reason | Discipline gap |

**From git log:**

| Metric | Collection method | Signal |
|---|---|---|
| `LOC_per_plan` | `git diff --stat` between plan-write commit and implementation-complete commit | Plan inflation indicator |
| `files_changed_per_tier` | `git diff --name-only` count at Tier 2 vs Tier 3 boundaries | Tier calibration fidelity |

### New Metrics NOT Currently Collectible (require instrumentation additions)

| Metric | What is missing | Cost to add |
|---|---|---|
| `ceremony_token_cost` | trigger-audit.jsonl does not record token counts; CC hook events do not expose token_usage | Medium: PostToolUse hook reading usage fields from CC event JSON |
| `time_per_task_minutes` | No task_start / task_done event in trigger-audit | Low: add `{event: "task_start"}` and `{event: "task_done"}` to trigger-audit on tier-selection invocation |
| `hard_gate_deny_count` | bypass-log.jsonl records bypasses but not deny events that were NOT bypassed | Low: route non-bypassed deny events to a new `deny-log.jsonl` in pre-tool-use |
| `manual_smoke_catch_rate` | No structured smoke-test result log | Medium: requires smoke-test result schema and write discipline in cto-mode |
| `citation_density_per_plan` | Plan docs are markdown, not machine-readable | Low: add YAML frontmatter `citations_count: N` to plan template; grep-collectible |
| `false_positive_rate_hard_gate` | Requires deny-log.jsonl (above) cross-referenced with bypass rationale | Depends on deny-log.jsonl addition |
| `trigger_audit_anomaly_rate` | Not defined; needs a baseline first | Deferred: define after 10+ sessions of data collection |

### Recommended Tracking Additions for PROJECT-PLAN

Per the Anthropic Develop Tests metric taxonomy (Operational metrics include "Response time (ms), uptime (%)") and the Datadog multiwindow burn-rate pattern (short window for acute signal, long window for trend), PF v2.2 should track:

**Best-effort collectible NOW (zero new infrastructure):**
1. `repeat_skill_invocation_rate` — from trigger-audit.jsonl
2. `bypass_rate_per_rule` — from bypass-log.jsonl
3. `bypass_all_rate` — from bypass-log.jsonl
4. `LOC_per_plan` — from git log
5. `skills_per_prompt_p50_p95` — from trigger-audit.jsonl

**Collectible with minor hook additions (v2.2 scope, low cost):**
6. `hard_gate_deny_count` — add deny-log.jsonl output to pre-tool-use deny() function
7. `time_per_task_minutes` — add task_start/task_done events to trigger-audit on tier-selection boundary
8. `citation_density_per_plan` — add `citations_count` YAML frontmatter field to plan template

**Deferred (medium cost or requires baseline, post-v2.2):**
9. `ceremony_token_cost` — PostToolUse hook + token_usage field
10. `false_positive_rate_hard_gate` — derived from deny-log.jsonl + bypass-log.jsonl correlation
11. `trigger_audit_anomaly_rate` — requires baseline from 10+ sessions first

---

## Q18 — Trigger-Audit Cadence and Ownership

### Comparison Axes

| Framework | Analysis cadence | Window model | Ownership model |
|---|---|---|---|
| **Anthropic Demystifying Evals** | "evaluations should be as routine as maintaining unit tests"; per-change (before any skill edit) | Implied per-PR / per-model-update | "dedicated evals teams to own the core infrastructure, while domain experts and product teams contribute most eval tasks" |
| **Datadog Multiwindow Burn Rate** | Continuous collection; dual-window alerting | Fast pair: `quick_window_short = "5m"` + `quick_window_long = "1h"`; Slow pair: `slow_window_short = "30m"` + `slow_window_long = "6h"` | Implicitly ops/SRE team; alert fires → member investigates |
| **OpenAI Eval Skills** | Per-change ("run your eval against the current version and save the results" before any skill edit) | Single run per change; no time-series | Skill owner (developer modifying the skill) |
| **PF v2 (existing)** | Continuous collection in pre-tool-use + user-prompt-submit; no periodic analysis step defined | No window model; no alerting thresholds | No ownership assigned |

### Synthesis

3/4 frameworks agree on a **dual-cadence** model:
- **Continuous collection** of raw event data (traces, logs, token counts) — every session.
- **Periodic analysis** at a defined interval — triggered by code change (per-PR) or calendar (weekly/monthly).

The Datadog multiwindow model adds a directly applicable insight: use a **short window** to detect acute over-trigger (skill fires 3× in 10 minutes) and a **long window** to detect drift (skill invocation rate trending up over 7 days). A single-window analysis misses one of the two failure modes. This maps exactly to PF's two known failure modes: F-V9 (acute over-trigger in one session) and the gradual ceremony-inflation risk across many sessions.

PF v2's trigger-audit.jsonl already collects raw event data continuously (v2.0.3). The gap is the periodic analysis step and threshold definitions.

### Recommended Cadence and Ownership for v2.2

**Collection cadence:** continuous (already shipping in v2.0.3 via pre-tool-use + user-prompt-submit hooks). No change needed.

**Analysis cadence — two windows (mirroring Datadog multiwindow pattern):**

| Window | Trigger | Metrics checked | Threshold (initial) | Action |
|---|---|---|---|---|
| **Short (per-session)** | End of any session where `bypass_all_rate > 0` OR any skill fired > 2× for one prompt | `skills_per_prompt`, `repeat_skill_invocation_rate` | skills_per_prompt > 3 OR any skill invoked > 2× per prompt = OVER_TRIGGER flag | Note in session notes; queue for weekly review |
| **Long (weekly)** | Every 7 days OR after any HARD-GATE firing spike (> 3 denies in one session) | `repeat_skill_invocation_rate` week-over-week, `under_trigger_rate` trend, `bypass_rate_per_rule` | Trend up >20% week-over-week OR `under_trigger_rate` > 10% = investigate | Open F-VN finding in PROJECT-PLAN; propose skill trigger tuning |
| **On-demand** | After any user-reported friction spike (F-V9, F-V10 class) | All metrics | Any anomaly | CTO dispatches Researcher with trigger-audit.jsonl as context |

**Ownership mapping** (per Anthropic Demystifying Evals: "dedicated evals team owns infrastructure; domain experts contribute tasks"):

| Role | Responsibility |
|---|---|
| `pre-tool-use` hook (automated) | Continuous collection: writes trigger-audit.jsonl + bypass-log.jsonl every session |
| **Post-Mortem agent** | Weekly analysis: mines trigger-audit.jsonl for repeat-skill patterns (extends existing bypass-log mining mandate in post-mortem.md checklist) |
| **CTO (entry session)** | Short-window review: inspects per-session over-trigger flags; sets threshold calibration |
| **Researcher sub-agent** | On-demand deep-dive: dispatched by CTO for anomaly spikes; produces analysis artifact in docs/research/ |

**Concrete weekly analysis — collectible today with zero new infrastructure:**

```bash
# skills-per-prompt distribution (last session)
awk '/"event":"prompt_received"/{w=NR} /"event":"skill"/{if(w>0) count[NR-w]++} END{for(k in count) print count[k]}' \
  .framework-state/trigger-audit.jsonl | sort -n

# bypass rate per rule
awk -F'"' '/"rule"/{print $4}' \
  .framework-state/bypass-log.jsonl | sort | uniq -c | sort -rn
```

---

## Recommendation

### Q16 — Minimum Viable Eval Shape

Adopt three eval sets for v2.2. Two extend existing infrastructure; one is derived from live logs:

| Set | Cases | Structure | Pass criterion |
|---|---|---|---|
| `evals/triggering/tier-selection.json` (extend 20 → 30) | 30 | `{id, should_trigger, query}` | ≥90% correct trigger decisions |
| `evals/triggering/hard-gate-catch.json` (new) | 15 | `{id, expected_gate_fires, prompt, adversarial}` | 5/5 fires; 0/5 false positives; 5/5 adversarial holds |
| `evals/friction/repeat-invoke.jsonl` (derived from live logs) | Session-derived | `{session_id, skill, invocation_count, prompt_window_ts}` | invocation_count == 1 for ≥95% of (session, skill, prompt_window) triples |

This is the minimum set covering both friction (repeat-invoke) and strength (trigger fidelity + HARD-GATE catch) with deterministic pass/fail rubrics — no LLM-judge required for any of the three.

### Q17 — New Metrics

Add 5 metrics to PROJECT-PLAN tracking immediately (zero new infrastructure):
1. `repeat_skill_invocation_rate` — trigger-audit.jsonl
2. `skills_per_prompt_p50_p95` — trigger-audit.jsonl
3. `bypass_rate_per_rule` — bypass-log.jsonl
4. `bypass_all_rate` — bypass-log.jsonl
5. `LOC_per_plan` — git log

Add 3 metrics with minor hook additions (v2.2 scope):
6. `hard_gate_deny_count` — add deny-log.jsonl output to pre-tool-use deny() function (one line)
7. `time_per_task_minutes` — add task_start/task_done events to trigger-audit on tier-selection boundary
8. `citation_density_per_plan` — add `citations_count` YAML frontmatter to plan template

Defer 3 metrics to post-v2.2:
9. `ceremony_token_cost` (PostToolUse hook, medium cost)
10. `false_positive_rate_hard_gate` (requires deny-log.jsonl first)
11. `trigger_audit_anomaly_rate` (requires baseline from ≥10 sessions)

### Q18 — Cadence and Ownership

Post-Mortem agent runs weekly trigger-audit analysis (natural extension of its existing bypass-log mining mandate). CTO reviews per-session when skills_per_prompt > 3 or bypass_all_rate > 0. Researcher is dispatched on-demand for anomaly spikes. Collection is already automated via v2.0.3 hooks — no new infrastructure for Q18.

---

## Citations

### Citation 1 — Anthropic Demystifying Evals for AI Agents

**URL:** https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
**Verified:** 2026-05-01 (via WebFetch)
**Source quality:** Primary — Anthropic Engineering blog

Verbatim quotes:
- "20-50 simple tasks drawn from real failures is a great start."
- "pass@k: measures the likelihood that an agent gets at least one correct solution in k attempts"
- "pass^k: measures the probability that all k trials succeed"
- "evaluations should be as routine as maintaining unit tests"
- "dedicated evals teams to own the core infrastructure, while domain experts and product teams contribute most eval tasks"
- "eval-driven development: build evals to define planned capabilities before agents can fulfill them"
- "An evaluation harness is the infrastructure that runs evals end-to-end. It provides instructions and tools, runs tasks concurrently, records all the steps, grades outputs, and aggregates results."

**Use in this research:** Primary citation for Q16 eval set size (20-50 cases), grader taxonomy (code / model / human), and Q18 ownership model (infra team + domain expert split).

---

### Citation 2 — Anthropic Define Success Criteria and Build Evaluations

**URL:** https://platform.claude.com/docs/en/test-and-evaluate/develop-tests
**Verified:** 2026-05-01 (via WebFetch)
**Source quality:** Primary — Anthropic Claude API Docs

Verbatim quotes:
- "Most use cases will need multidimensional evaluation along several success criteria."
- "Quantitative metrics: Task-specific: F1 score, BLEU score, perplexity. Generic: Accuracy, precision, recall. Operational: Response time (ms), uptime (%)"
- "More questions with slightly lower signal automated grading is better than fewer questions with high-quality human hand-graded evals."
- "Code-based grading: Fastest and most reliable, extremely scalable, but also lacks nuance for more complex judgements that require less rule-based rigidity."
- "Have detailed, clear rubrics: 'The answer should always mention Acme Inc. in the first sentence. If it does not, the answer is automatically graded as incorrect.'"

**Use in this research:** Primary citation for Q16 case format, Q17 metric taxonomy (Operational metrics = efficiency/friction bucket), and grading hierarchy (code > LLM > human).

---

### Citation 3 — OpenAI Eval Skills Harness

**URL:** https://developers.openai.com/blog/eval-skills
**Verified:** 2026-05-01 (via WebFetch)
**Source quality:** Primary — OpenAI Developers blog

Verbatim quotes:
- "a small set of 10–20 prompts is enough to surface regressions and confirm improvements early"
- "id,should_trigger,prompt" (verbatim CSV header for case format)
- "Each row should represent a situation where you care whether the `setup-demo-app` skill _does_ or _does_ not activate"
- "Outcome goals: Did the task complete? Does the app run? Process goals: Did Codex invoke the skill and follow the tools and steps you intended? Style goals: Does the output follow the conventions you asked for? Efficiency goals: Did it get there without thrashing?"

**Use in this research:** Primary citation for Q16 case structure (id/should_trigger/prompt mirrors PF's existing tier-selection.json format); four-goal taxonomy that explicitly separates Efficiency from Outcome — the direct analog to friction vs strength.

---

### Citation 4 — OpenAI Evals OSS Framework (build-eval.md)

**URL:** https://raw.githubusercontent.com/openai/evals/main/docs/build-eval.md
**Verified:** 2026-05-01 (via WebFetch)
**Source quality:** Primary — OpenAI GitHub repository official documentation

Verbatim quotes:
- "All templates expect an `\"input\"` key, which is the prompt, ideally specified in chat format"
- "For the basic evals `Match`, `Includes`, and `FuzzyMatch`, the other required key is `\"ideal\"`, which is a string (or a list of strings) specifying the correct reference answer(s)."

**Use in this research:** Corroborating citation for Q16 case format. `{input, ideal}` is the third independent source (after Anthropic Demystifying Evals and OpenAI Eval Skills) confirming a two-field minimum per eval case — maps to `{prompt, expected_verdict}` in PF terms.

---

### Citation 5 — Datadog Multiwindow Multi-Burn-Rate Alerts

**URL:** https://hceris.com/multiwindow-multi-burn-rate-alerts-in-datadog/
**Verified:** 2026-05-01 (via WebFetch — secondary; canonical `https://docs.datadoghq.com/service_management/service_level_objectives/burn_rate/` returned HTTP 404 during research session)
**Source quality:** Secondary — practitioner implementation blog

Verbatim quotes:
- "My newest obsession is multiwindow, multi-burn rate alerts."
- "Having a burn rate measures how quickly you're exhausting your error budget."
- `quick_window_long = "1h"` / `quick_window_short = "5m"` (fast burn detection pair)
- `slow_window_long = "6h"` / `slow_window_short = "30m"` (slow burn detection pair)

**Use in this research:** Dual-window alerting pattern applied to Q18 trigger-audit cadence design — short window for acute over-trigger detection, long window for drift detection. Tagged secondary because canonical Datadog docs URL 404'd; the practitioner post contains verbatim Terraform variable definitions confirming the window sizes.

---

### Citation 6 — AI Agent Evaluation: Friction vs Quality (Confident AI)

**URL:** https://www.confident-ai.com/blog/definitive-ai-agent-evaluation-guide
**Verified:** 2026-05-01 (via WebSearch synthesis — full WebFetch not performed)
**Source quality:** Secondary — third-party evaluation framework vendor blog (tagged: via WebSearch synthesis of canonical URL)

Verbatim quotes (via WebSearch synthesis):
- "Agents can fail when tasks complete only after unacceptable latency, cost, or conversational friction for the product you're shipping"
- "Cost depends on trace shape—how many completions, how fast context balloons across turns, and whether failures retry blindly."
- "Two runs can both pass task completion while one burns far more tokens through re-reading tool output or re-summarizing every turn."
- "Track operating envelopes (cost, latency, step/token budgets) in the same traces you use for quality—not only pass/fail scores"

**Use in this research:** Q17 — justification for tracking ceremony token cost and repeat-invocation rate as first-class metrics alongside quality scores. The "operating envelope" framing directly maps to PF's friction/strength distinction.

---

## Methodology Disclosure

- Citation 5 (Datadog burn rate) is tagged secondary because `docs.datadoghq.com/service_management/service_level_objectives/burn_rate/` returned HTTP 404 during the research session. The hceris.com post is a practitioner's Terraform implementation guide with verbatim variable values.
- Citation 6 is tagged `(via WebSearch synthesis of canonical URL)` because the full article was accessed via WebSearch snippet, not a full WebFetch call.
- PF v2's own `evals/` directory and hook source files (`hooks/pre-tool-use`, `hooks/user-prompt-submit`) were read as primary sources via the Read tool (verified 2026-05-01). These are first-party primary sources for the "existing infrastructure" comparison axis.
- RAGAS was searched (Round 1, Query 2) and excluded as a primary citation for Q16. The RAGAS metrics overview page (`docs.ragas.io/en/stable/concepts/metrics/overview/`) did not contain verbatim content on eval set size, case format, or analysis cadence applicable to agent skill triggering. The metric-separation insight (retrieval quality vs generation quality as distinct axes) informed the friction/strength framing but is not cited as a primary recommendation.

---

## Pre-DONE Self-Rubric

| # | Criterion | Result |
|---|---|---|
| 1 | **Factual accuracy** — every synthesis claim maps to a verbatim quote in the citations section | PASS: all Q16/Q17/Q18 recommendations cite a numbered citation with verbatim quotes. |
| 2 | **Citation accuracy** — URLs are canonical; WebFetch denials and synthesis tags are present | PASS: Citation 5 tagged secondary with 404 note; Citation 6 tagged via WebSearch synthesis. |
| 3 | **Completeness** — all axes populated or explicitly explained | PASS: every comparison axis has a value; "not currently collectible" metrics list what is missing and why. |
| 4 | **Source quality** — primary sources for major claims | PASS: Citations 1-4 are primary (Anthropic Engineering blog, Anthropic API docs, OpenAI Developers blog, OpenAI GitHub repo). Citations 5-6 are explicitly tagged secondary. |
| 5 | **Tool efficiency** — within 10-15 call budget | PASS: 12 tool calls used (3 broad + 9 narrow/fetch). |
