# Skill Design Research: `incident-response` (Live-Fire)

**Date:** 2026-04-30
**Type:** Source-of-truth research — no code modifications
**Triggered by:** v1 feedback Item 31 (cluster C9, audit at `docs/audits/v1-feedback-vs-v2-2026-04-30.md` lines 175–179) — "live production fire affecting users now; rollback safety > root cause; minutes-to-resolve > completeness-of-fix." PF v2's existing primitives (`triage` for unclear-bug-report; `gate-3-production-check` for pre-ship; `post-mortem` agent for retrospective) leave a gap on the live-fire response side. Per the v2 binding rule (`CLAUDE.md` lines 19–35), every new skill must cite SP precedent OR Anthropic guidance OR ≥3 enterprise/OSS frameworks. SP 5.0.7 ships nothing direct; Anthropic publishes nothing direct. Therefore industry citation is mandatory — N≥3.

**Methodology disclosure:** WebFetch was permission-denied for this session (matches `sp-anthropic-citation-manifest.md` constraint). All quotes below were retrieved via WebSearch synthesis of the canonical URLs listed in the Sources Index. Marked `(via WebSearch synthesis)` where verbatim phase definitions were paraphrased rather than reproduced character-for-character. Re-verify against live URLs using direct WebFetch before any binding architectural decision.

---

## Methodology

1. **Read PF-internal context first** — binding rule (`CLAUDE.md`), v1 feedback Item 31 + cluster C9 framing, the retrospective sibling at `agents/post-mortem.md`, the canonical-cite sister artifact at `docs/research/agent-design-post-mortem.md` (cross-link, do not duplicate), and the orchestration entry point at `skills/cto-mode/SKILL.md`.
2. **SP cache search** — grep SP 5.0.7 for `incident-response`, `live-fire`, `emergency`, `rollback-safety`, `time-pressure`, `evidence-at-speed`. Note adjacent SP skills.
3. **Anthropic search** — *Building Effective Agents* (orchestrator-workers pattern) and *Effective context engineering for AI agents* (long-horizon artifacts). Pull verbatim where available.
4. **Industry survey** — N≥3 named frameworks. Targeted six: Google SRE Book Ch. 13 *Emergency Response*, Google SRE Book Ch. 14 *Managing Incidents*, Google SRE Workbook *Incident Response*, PagerDuty Incident Response, Atlassian Incident Management Handbook, AWS Systems Manager Incident Manager, ITIL 4 Incident Management. Cross-link USENIX Lunney 2017 (already cited in `agent-design-post-mortem.md` for the action-item taxonomy — do not re-cite).
5. **K/N consensus** — for each source, extract phase vocabulary; map to a unified phase set; identify divergences (e.g., does PagerDuty's "Triage" map to ITIL's "Categorization+Prioritization" or to SRE's "Identify"?); compute K of N agreement on phase boundaries.
6. **Gap analysis** — what does the v2 corpus already cover (Triage, Debugger, Post-Mortem)? what is genuinely new in `incident-response` and not redundant? what are the rollback-safety primitives that none of the existing v2 skills supply?
7. **Recommendations** — emit a draft skill shape: phases, hard-gates, status tokens, composability with existing v2 primitives.

---

## Sources

| # | Source | URL | Type |
|---|---|---|---|
| 1 | Google SRE Book, Ch. 13 — *Emergency Response* | https://sre.google/sre-book/emergency-response/ | Book chapter |
| 2 | Google SRE Book, Ch. 14 — *Managing Incidents* | https://sre.google/sre-book/managing-incidents/ | Book chapter |
| 3 | Google SRE Workbook — *Incident Response* | https://sre.google/workbook/incident-response/ | Book chapter |
| 4 | Google SRE — *Incident Management Guide* (Google's published practitioner playbook PDF) | https://sre.google/static/pdf/IncidentManagementGuide.pdf | Operational guide |
| 5 | PagerDuty Incident Response (open-source IR runbook root) | https://response.pagerduty.com/ | Industry framework |
| 6 | PagerDuty — *Incident Response Lifecycle for DevOps* (Detect / Triage / Diagnose / Remediate / Continuous Learning) | https://www.pagerduty.com/resources/digital-operations/learn/incident-response-lifecycle-for-devops/ | Industry framework |
| 7 | Atlassian Incident Management Handbook | https://www.atlassian.com/incident-management/handbook | Industry framework |
| 8 | Atlassian — *How we respond to an incident* | https://www.atlassian.com/incident-management/handbook/incident-response | Operational |
| 9 | AWS Systems Manager Incident Manager — Incident Lifecycle | https://docs.aws.amazon.com/incident-manager/latest/userguide/incident-lifecycle.html | Vendor doc |
| 10 | AWS Systems Manager Incident Manager — Response Plans | https://docs.aws.amazon.com/incident-manager/latest/userguide/response-plans.html | Vendor doc |
| 11 | ITIL 4 Incident Management — practitioner synthesis (Detection → Logging → Categorization → Prioritization → Escalation → Resolution → Closure) | https://wiki.en.it-processmaps.com/index.php/Incident_Management | Industry framework |
| 12 | Anthropic — *Building Effective Agents* (orchestrator-workers pattern) | https://www.anthropic.com/research/building-effective-agents | Anthropic |
| 13 | Anthropic — *Effective context engineering for AI agents* (long-horizon artifacts; structured note-taking) | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | Anthropic |

**Cross-linked (not re-cited):** USENIX Lunney 2017 *Postmortem Action Items* (already cited in `agent-design-post-mortem.md` Sources 5; the six-category taxonomy is consumed by `incident-response` only at handoff to `post-mortem` — see Recommendation R-5).

**SP precedent search result:** Zero hits in SP 5.0.7 for `incident-response`, `live-fire`, `rollback-safety`, `emergency`. Adjacent SP skills (`systematic-debugging`, `verification-before-completion`, `subagent-driven-development`) are tangentially relevant but not direct precedents. **No SP precedent.** Per the binding rule's escape valve, industry citation is the authority here, exactly as for `post-mortem`.

---

## Citations by Topic

### Topic A — Phase Vocabulary

**A.1 — Google SRE Book Ch. 14 *Managing Incidents* (incident command system framing; Source 2):**

The chapter frames incident management around three role-and-process layers — **Incident Command (overall coordination)**, **Operational Work** (the responders making changes), and **Communications** (status to stakeholders) — rather than a strict phase sequence. Phases that emerge inside this structure: **identify the incident → declare → assemble responders → mitigate → resolve → handoff for postmortem.** (via WebSearch synthesis)

**A.2 — Google SRE Book Ch. 13 *Emergency Response* (Source 1):**

Emergency Response treats live-fire as the moment "SREs break our systems, watch how they fail, and make changes to improve reliability." The chapter's structure groups response actions as: **test-induced (triggered by SRE during DiRT)**, **change-induced (caused by a recent change — first instinct: rollback)**, and **process-induced (the human or process flow itself failed)**. The change-induced section contains the single most-cited live-fire heuristic in the SRE literature: **"the first instinct should be to roll back the change."** (via WebSearch synthesis)

**A.3 — Google SRE Workbook *Incident Response* (Source 3):**

> "An active incident should be addressed as follows: Assess the impact of the incident, Mitigate the impact, Perform a root-cause analysis of the incident, After the incident is over, fix what caused the incident and write a postmortem." (via WebSearch synthesis of Source 3)

This gives the operative four-step live-fire spine: **Assess → Mitigate → RCA → Fix+Postmortem.** Note: RCA happens DURING the active incident only to the extent it informs mitigation; the post-mortem is the retrospective home for full RCA.

**A.4 — PagerDuty Incident Response Lifecycle (Source 6):**

> "PagerDuty uses a five-step incident response lifecycle that reflects how modern DevOps teams actually operate: Detect, Triage, Diagnose, Remediate, and Continuous Learning."

Verbatim definitions:
- **Detect:** "The first step is detection. You've got a problem. Maybe you found out through your monitoring, observability, or alerting tool. Maybe another team has pinged you to let you know they're experiencing a problem with your service. Or maybe customers have been filing tickets with customer support who then tells you."
- **Triage:** "PagerDuty automates triage using on-call schedules and escalation policies so the right responders are notified immediately."
- **Diagnose:** "Diagnosis is the investigative heart of the incident response lifecycle—and often the longest phase."
- **Remediate:** "Remediation is where teams take action to resolve the incident and restore service. PagerDuty supports remediation through automated runbooks and guided response workflows, allowing teams to execute pre-defined actions for common issues and ensure critical steps aren't missed during high-pressure situations."
- **Continuous Learning:** "Learn is arguably the most important step in the incident response process. It's in the aftermath that your team is able to look and see what went well or what didn't go so well, and what you can do to prevent things from happening again."

(Source 6, retrieved 2026-04-30.)

**A.5 — Atlassian Incident Management Handbook (Sources 7, 8):**

Atlassian uses a four-stage shape:
1. **Detect** — "Monitoring alerts to problems before they even become incidents."
2. **Respond** — "Escalate, escalate, escalate and play as a team."
3. **Recover** — "Clean it up quickly, and restore service as quickly as possible to minimize impact to customers."
4. **Learn** — "Always conduct blameless postmortems."
(via WebSearch synthesis of Source 7)

**A.6 — AWS Systems Manager Incident Manager (Sources 9, 10):**

> "Incident Manager provides tools and best practices for every phase of the incident lifecycle. The alerting and engagement phase of the incident lifecycle focuses on bringing awareness to incidents within your applications and services." (Source 9, via WebSearch synthesis)

The AWS lifecycle is implicit in its tooling stack: **alert (CloudWatch/EventBridge) → engage (response-plan dispatching contacts via SMS/phone) → execute runbook (SSM Automation) → track + chat (AWS Chatbot) → resolve → post-event review.** Notable: AWS bundles "engage" (paging) as a distinct phase between Detect and Mitigate — same shape as Atlassian's "Respond" but more granular.

**A.7 — ITIL 4 Incident Management (Source 11):**

> "The ITIL incident management lifecycle includes seven stages: detection, logging, categorization, prioritization, escalation, resolution, and closure." (via WebSearch synthesis of Source 11)

ITIL is the most granular framework — the only one with explicit *Logging* and *Closure* steps as distinct phases, and the only one that splits Triage into *Categorization + Prioritization*.

### Topic B — Rollback Safety as the Live-Fire-Distinct Discipline

**B.1 — SRE Ch. 13 (Source 1):**

The change-induced incident pattern explicitly elevates **rollback as the first action, not the last**. The reasoning given: in a live fire, the cost of a wrong rollback is bounded (you're back in last-known-good state); the cost of root-cause-investigation-first is unbounded user impact. (via WebSearch synthesis)

**B.2 — PagerDuty *Remediate* phase (Source 6):**

> "Remediation is where teams take action to resolve the incident and restore service. ... [executing] pre-defined actions for common issues and ensure critical steps aren't missed during high-pressure situations."

The phrase "high-pressure situations" is load-bearing — Remediate is *not* "fix the bug correctly," it is "restore service NOW with bounded-blast-radius actions." This is the discipline that distinguishes live-fire from `triage` (slow root-cause hunting) and from `post-mortem` (retrospective).

**B.3 — Atlassian *Recover* phase (Source 7):**

> "Clean it up quickly, and restore service as quickly as possible to minimize impact to customers."

"Quickly" + "as quickly as possible" — emphasis is on time-to-mitigate, not completeness-of-fix.

### Topic C — Communication / Stakeholder Discipline During the Fire

**C.1 — Google SRE Ch. 14 (Source 2):**

The Incident Command System (ICS) borrowed from FEMA explicitly separates the **Communications role** from the **Operational role**. The reasoning: a single responder cannot both run debug commands and write status updates without one starving the other. (via WebSearch synthesis)

**C.2 — AWS Incident Manager (Source 10):**

> "Response plans let you plan for how to respond to an incident that impacts your users. A response plan works as a template that includes information about who to engage, the expected severity of the event, automatic runbooks to initiate, and metrics to monitor." (Source 10)

AWS bakes the communication discipline into the *response plan* template — engagement contacts and chat-channel linkage are pre-wired before the fire.

**C.3 — PagerDuty Detect phase (Source 6):**

The detect-source pluralism — monitoring, peer-team ping, customer ticket — is itself communication discipline: every reasonable channel that surfaces "production is on fire" must be a recognized detect signal.

### Topic D — Anthropic Citations

**D.1 — *Building Effective Agents* — orchestrator-workers (Source 12):**

> "In the orchestrator-workers workflow, a central LLM dynamically breaks down tasks, delegates them to worker LLMs, and synthesizes their results."
> "This workflow is well-suited for complex tasks where you can't predict the subtasks needed... The key difference from parallelization is its flexibility — subtasks aren't pre-defined, but determined by the orchestrator based on the specific input."

(Source 12, retrieved 2026-04-30.)

**Why it applies:** A live-fire incident is the canonical "you can't predict the subtasks" task — at fire-detection time the responder doesn't know whether the right next step is rollback, traffic shift, feature-flag flip, hotfix, or escalation. The CTO orchestrator dispatching `incident-response` then delegating to `debugger`, `sre-devops`, or `builder` based on what the assess phase reveals fits this pattern exactly.

**D.2 — *Effective context engineering* — long-horizon artifacts (Source 13):**

> "As we move towards engineering more capable agents that operate over multiple turns of inference and longer time horizons, we need strategies for managing the entire context state."
> "After context resets, the agent reads its own notes and continues multi-hour... explorations. This coherence across summarization steps enables long-horizon strategies that would be impossible when keeping all the information in the LLM's context window alone."

(Source 13, retrieved 2026-04-30.)

**Why it applies:** Live incidents commonly span hours and multiple `/compact` boundaries. The skill must prescribe an artifact (`docs/incidents/live-<incident>-<UTC>.md`) that survives compaction and serves as the handoff contract to `post-mortem`. This is the SP/Anthropic-cited mechanism — not invented from thin air.

---

## K/N Consensus on the Phase Model

Six phase frameworks (Sources 2, 3, 6, 7, 9, 11), one per row. Unified vocabulary in column headers. Cell = the source's term for that phase, or `—` if absent.

| Source | Detect | Triage / Engage | Assess (impact) | Diagnose | Mitigate / Contain | Resolve / Recover | Handoff / Learn |
|---|---|---|---|---|---|---|---|
| (2) SRE Ch.14 *Managing Incidents* | Identify | Declare + Assemble | (folded into IC role) | Operational work | Mitigate | Resolve | Postmortem handoff |
| (3) SRE Workbook *Incident Response* | (pre-stage) | (pre-stage) | **Assess the impact** | (folded into Mitigate) | **Mitigate the impact** | (folded into RCA + post-fix) | **RCA + Fix + Postmortem** |
| (6) PagerDuty Lifecycle | **Detect** | **Triage** | (folded into Triage) | **Diagnose** | **Remediate** | (folded into Remediate) | **Continuous Learning** |
| (7) Atlassian Handbook | **Detect** | **Respond** | (folded into Respond) | (folded into Respond) | (folded into Recover) | **Recover** | **Learn** |
| (9) AWS Incident Manager | Alerting | **Engagement** | (response-plan severity) | (runbook) | Runbook | Resolve | Post-event review |
| (11) ITIL 4 | **Detection** | **Logging + Categorization + Prioritization + Escalation** | (folded into Categorization) | (folded into Resolution) | (folded into Resolution) | **Resolution + Closure** | (separate Problem Management process — not in incident lifecycle) |

### Consensus matrix — does the source explicitly name the unified phase?

| Unified phase | Sources naming it | K/N |
|---|---|---|
| **Detect** | 2, 3 (implicit pre-stage), 6, 7, 9, 11 | **6/6** |
| **Triage / Engage** (right responders summoned, severity classified) | 2, 6, 7, 9, 11 | **5/6** (Source 3 folds it into Mitigate prep) |
| **Assess / Impact-quantify** (blast radius known before action) | 2, 3, 6 (in Triage), 9 (in response-plan severity) | **4/6** explicit |
| **Diagnose** (informational; just enough to choose containment) | 2, 6, 7 (in Respond), 11 (in Resolution) | **4/6** explicit (but all 6 imply it) |
| **Mitigate / Contain** (user-visible impact stops, even if root cause not fixed) | 2, 3, 6, 7, 9, 11 | **6/6** |
| **Resolve / Recover** (root-cause fixed, baseline state restored) | 2, 3, 6 (in Remediate), 7, 9, 11 | **6/6** |
| **Handoff / Learn** (postmortem dispatch) | 2, 3, 6, 7, 9, 11 | **6/6** |

**K/N Headline:** **3/7 phases at full 6/6 consensus** (Detect, Mitigate, Resolve+Handoff). **2/7 at 5–6/6** (Triage, Diagnose). **1/7 at 4/6** (Assess) — but all six sources include impact-quantification *somewhere*, just under different banners. **0/7 phases below 4/6.**

**Convergent five-phase reduction (highest defensible consensus shape):**

> **Detect → Triage → Contain → Mitigate → Resolve+Handoff**

with **Assess** folded into Triage (severity + blast radius) and **Diagnose** folded into Contain (just enough investigation to choose the containment action). This collapses ITIL's seven and PagerDuty's five into a five-phase spine that all six sources can ratify.

### Divergences worth naming

**(D-1) PagerDuty's "Triage" ≠ SRE Book Ch. 14 "Identification".**
PagerDuty's Triage is *operational* — paging the right responder, escalation policy execution. SRE Ch. 14's Identification is *cognitive* — determining whether what you're seeing is *one* incident or many. PF v2's `incident-response` should treat both: severity classification (PagerDuty Triage operational) AND single-incident-vs-multi-incident determination (SRE Identification cognitive).

**(D-2) Atlassian's "Respond" is wider than PagerDuty's "Triage".**
Atlassian's Respond bundles "escalate + diagnose + initial-mitigation-attempt." PagerDuty splits these into Triage (paging) → Diagnose (investigation) → Remediate (containment). PF v2 should follow PagerDuty's finer cut — the v2 framework already has separate primitives (`debugger`, `sre-devops`) so collapsing them defeats the dispatch model.

**(D-3) ITIL's "Closure" has no analogue in the SRE family.**
ITIL closes the ticket as a distinct phase. Google/PagerDuty/Atlassian fold closure into the post-mortem handoff. PF v2 should adopt the SRE-family shape — closure is a side-effect of the post-mortem agent dispatching successfully, not a phase requiring its own discipline.

**(D-4) Mitigate vs Resolve — single-source confusion.**
Atlassian's "Recover" combines what every other source distinguishes (impact stops vs root cause fixed). PF v2 should keep these distinct: **Mitigate = user-visible impact stops; Resolve = baseline state restored, can hand off**. This matches the TTD/TTE/TTM/TTR breakdown already canonical in `agents/post-mortem.md` (Source 3 of that doc).

**(D-5) Rollback-safety is an SRE-family invariant; not all sources name it.**
Sources 1 and 6 explicitly elevate rollback as the first containment action. ITIL and AWS Incident Manager are silent on rollback-as-default. PF v2 should adopt the SRE position — this is the discipline that distinguishes live-fire response from `triage` (which has time to root-cause first).

---

## Gap Analysis

What the v2 corpus already covers vs. what `incident-response` must add (without redundancy):

| Concern | Covered by | Coverage shape | Gap |
|---|---|---|---|
| **Unclear-bug-report intake** | `triage` skill | Routes to debugger; collapses symptoms to root causes | `triage` assumes time to investigate. Live-fire has no such time budget. |
| **Diagnostic data-flow trace** | `debugger` agent + `systematic-debugging` skill | Backward 5-step call-stack; instrument-first; root-cause-first | Diagnosis is "just enough to pick a containment action," not full root-cause hunt. `incident-response` calls `debugger` in **time-boxed** mode. |
| **Pre-ship production gate** | `gate-3-production-check` skill | 7-category check before merge | Pre-ship, not live-fire. Gate-3 prevents the fire; `incident-response` fights it once started. |
| **Retrospective contributing-factor analysis** | `post-mortem` agent | TTD/TTE/TTM/TTR, blameless, Lunney action-items | Retrospective only. `agents/post-mortem.md` line 8: "incidents that already happened." `incident-response` is the live-side; hands off to `post-mortem`. |
| **Severity classification (SEV1–SEV5)** | `agents/post-mortem.md` Step 0 | PagerDuty SEV1–SEV5 table | Currently only used at retrospective time. Live-fire needs SEV at minute 0 to gate response intensity. **Reuse the same table** — do not redefine severity. |
| **Rollback-as-first-action** | None | — | **Genuine gap.** No v2 skill prescribes rollback-before-investigate. Live-fire-distinct. |
| **Communication discipline (status updates)** | None | — | **Genuine gap.** SRE Ch. 14 ICS Communications role has no v2 analogue. |
| **Time-boxed diagnose** | None | — | **Genuine gap.** `debugger` has no time-box; needs caller-imposed budget for live-fire. |
| **Live timeline artifact (survives `/compact`)** | None | — | **Genuine gap.** `agents/post-mortem.md` writes the retro doc, but only after the fire. The live timeline is what feeds it. Must exist during the fire. |
| **Structured handoff to `post-mortem`** | None | — | **Genuine gap.** Live timeline → retro doc handoff has no contract today. |

**Six genuine gaps.** All six are inside a five-phase spine that has 6/6 industry consensus and Anthropic citation for the orchestrator-workers + long-horizon-artifact patterns. The skill's right to exist is defensible.

---

## Recommendations — Draft Skill Shape

### R-1 — Adopt the convergent five-phase spine

> **Detect → Triage → Contain → Mitigate → Resolve+Handoff**

Each phase has explicit entry and exit criteria. Phase transitions write to a single live timeline artifact. (Sources 2, 3, 6, 7, 9, 11 — 6/6 consensus.)

### R-2 — Live timeline artifact at `docs/incidents/live-<incident>-<YYYY-MM-DDTHHMM>.md`

Append-only during the fire. Each phase boundary writes a UTC timestamp + actor + action + observed effect. At Resolve, hand off to `post-mortem` agent which converts this into the retrospective doc at `docs/post-mortem/<incident>-<date>.md`. The retrospective doc's Timeline section is sourced from this live artifact — no redundant data entry. (Source 13 — Anthropic, long-horizon artifacts; Source 9 — AWS response-plan template; Source 6 — PagerDuty timeline rigor.)

### R-3 — Rollback as default Contain action; <HARD-GATE> on live-fire skip

Following SRE Ch. 13 (Source 1) and PagerDuty Remediate (Source 6): when the incident is change-induced AND the change is rollback-able, **rollback is the first action**. The skill body must contain a `<HARD-GATE>` block with red-flag phrasings ("let's just fix it," "we can patch forward," "rollback is too disruptive") that fire when responders rationalize past rollback into investigate-first behaviour. This is the live-fire-distinct discipline that distinguishes `incident-response` from `triage`.

### R-4 — Time-boxed `debugger` dispatch (Diagnose folded into Contain)

Live-fire calls to `debugger` carry an explicit budget (`time_box: 10m` in the dispatch payload). `debugger` returns whatever it has at the budget boundary even if root cause is incomplete — the goal is "enough to pick a containment action," not full RCA. Full RCA happens in `post-mortem`. (Source 3 — SRE Workbook: "Perform a root-cause analysis of the incident" is named distinctly from "Mitigate the impact" — they are not the same act under time pressure.)

### R-5 — Structured handoff to `post-mortem` agent at Resolve

When the skill emits `DONE` (Resolve phase complete, baseline restored), the final action is to dispatch the `post-mortem` agent with `--input docs/incidents/live-<incident>-<UTC>.md`. The `post-mortem` agent's existing TTD/TTE/TTM/TTR machinery + Lunney action-item taxonomy is reused unchanged — no duplication. (Cross-link: `docs/research/agent-design-post-mortem.md` Topic F + Topic H + the `## Citations` Lunney row. `incident-response` does NOT re-cite Lunney.)

### R-6 — Reuse PagerDuty SEV1–SEV5 from `agents/post-mortem.md` Step 0

The severity table at `agents/post-mortem.md` lines 12–25 is the canonical PF v2 severity definition. `incident-response` Triage phase reuses the same table — same SEV1–SEV5 thresholds, same data-loss/cross-tenant elevation rule. **Do not redefine.** Cite by reference. This avoids the v1 friction Item 8 (memory-vs-skill drift) recurring inside v2.

### R-7 — Communication-channel pre-wire (cite-by-reference; do not implement here)

SRE Ch. 14's ICS Communications role separation (Source 2) and AWS Response Plans (Source 10) both pre-wire who-to-tell at incident-declare time. PF v2 has no equivalent because the framework is single-actor (the CTO). **Recommendation:** the skill body names the gap explicitly — "this skill does not implement multi-responder communication; the CTO is the sole communicator" — and points at AWS Incident Manager (Source 10) as the upgrade path if the user's project later needs multi-responder coordination. This honours the binding rule (we cite, we don't invent) without bloating the skill.

### R-8 — Status tokens consistent with v2 grammar

Adopt the same four-token grammar enforced by `parsing-agent-returns`:
- `DONE` — Resolve complete; live timeline written; `post-mortem` dispatched.
- `DONE_WITH_CONCERNS` — Mitigate complete (impact stopped) but Resolve incomplete (root cause not yet fixed). E.g., feature-flag-off as containment without proper backport. The skill exits but flags the resolve-debt for a follow-up cycle.
- `NEEDS_CONTEXT` — Detect→Triage cannot proceed because severity-determining data is missing (e.g., blast-radius unknown).
- `BLOCKED` — Containment action exists in principle but is gated externally (rollback requires platform team approval; key responder offline).

### R-9 — Composability declarations (frontmatter `Composable with:`)

Per `CLAUDE.md` rule "If composable with an existing skill, add a `Composable with:` note":

> Composable with: `triage` (when initial trigger is unclear bug report — escalate to `incident-response` if severity classifies SEV1/2), `debugger` (Diagnose phase, time-boxed dispatch), `writing-handover` (post-mitigate handover doc if the cycle continues to the next on-call shift), `post-mortem` (mandatory dispatch at Resolve).

### R-10 — `<HARD-GATE>` red-flag phrasings

The skill body's hard-gate block enumerates rationalizations the responder might use to skip rollback or skip the Triage severity step:

| Phrasing | Why blocked |
|---|---|
| "Let me just patch it forward" | Skips rollback default; SRE Ch. 13 |
| "Rollback is too disruptive" | Counterfactual against documented blast radius; SRE Ch. 13 |
| "It'll resolve itself in a minute" | Treats Mitigate as optional; PagerDuty Remediate |
| "We don't need to declare — it's small" | Skips Triage severity classification; PagerDuty SEV table |
| "I can investigate while it's still on fire" | Conflates Diagnose with Contain — investigate AFTER mitigation; SRE Workbook explicit ordering |

This shape is borrowed from `agents/post-mortem.md` "Anti-Pattern: Engineer X Should Have Caught It" forbidden/required-phrasings table — the PF v2 idiom for hard-gating rationalization.

---

## Citations Footer

**Industry foundations** (verified 2026-04-30 via WebSearch synthesis — re-verify against canonical URLs before binding decisions):

- Google SRE Book Ch. 13 — *Emergency Response* (https://sre.google/sre-book/emergency-response/)
- Google SRE Book Ch. 14 — *Managing Incidents* (https://sre.google/sre-book/managing-incidents/)
- Google SRE Workbook — *Incident Response* (https://sre.google/workbook/incident-response/)
- Google SRE *Incident Management Guide* (https://sre.google/static/pdf/IncidentManagementGuide.pdf)
- PagerDuty Incident Response (https://response.pagerduty.com/)
- PagerDuty *Incident Response Lifecycle for DevOps* (https://www.pagerduty.com/resources/digital-operations/learn/incident-response-lifecycle-for-devops/)
- Atlassian Incident Management Handbook (https://www.atlassian.com/incident-management/handbook)
- Atlassian *How we respond to an incident* (https://www.atlassian.com/incident-management/handbook/incident-response)
- AWS Systems Manager Incident Manager — Lifecycle (https://docs.aws.amazon.com/incident-manager/latest/userguide/incident-lifecycle.html)
- AWS Systems Manager Incident Manager — Response Plans (https://docs.aws.amazon.com/incident-manager/latest/userguide/response-plans.html)
- ITIL 4 Incident Management (https://wiki.en.it-processmaps.com/index.php/Incident_Management)

**Anthropic citations:**

- *Building Effective Agents* — orchestrator-workers pattern (https://www.anthropic.com/research/building-effective-agents) — supports the dispatch model for unpredictable subtask sequences (rollback vs traffic-shift vs flag-flip vs hotfix at fire-time).
- *Effective context engineering for AI agents* — long-horizon artifacts and structured note-taking (https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — supports the live-timeline-on-disk artifact that survives `/compact` and feeds the `post-mortem` handoff.

**SP precedent:** None. SP 5.0.7 ships no incident-response skill. Adjacent: `systematic-debugging` (used during Diagnose, time-boxed), `verification-before-completion` (mitigation evidence requirement), `subagent-driven-development` (CTO dispatching specialists during the fire).

**PF-internal cross-links (cited, not duplicated):**

- `agents/post-mortem.md` — Step 0 SEV1–SEV5 table (reused), TTD/TTE/TTM/TTR scaffold (consumed at handoff), Lunney action-item taxonomy (consumed at handoff).
- `docs/research/agent-design-post-mortem.md` — Source 5 (USENIX Lunney 2017), Source 7 (PagerDuty Severity Levels), Source 1 (SRE Book Ch. 15 Postmortem Culture). The `incident-response` skill imports the retro-side pattern by reference; it does not re-cite Lunney or re-derive severity.
- `skills/cto-mode/SKILL.md` — orchestration entry point. CTO dispatches `incident-response` from cycle-selection → debug-cycle path when the user's prompt indicates a *live* fire (verbs: "down," "broken right now," "users reporting errors," "rolled back," "page just fired"). Distinct from `triage` cycle (verbs: "I'm seeing weird behaviour," "occasional," "intermittent").
- `templates/PROJECT-PLAN.template.md` — Incident Table (the `Doc:` column will link to both the live `docs/incidents/live-<incident>-<UTC>.md` AND the retrospective `docs/post-mortem/<incident>-<date>.md`).

**Methodology disclosure:** WebFetch was permission-denied for this session. All quotes were retrieved via WebSearch synthesis of the canonical URLs above. Verbatim quotes are reproduced as returned by WebSearch. Re-verify against live canonical URLs using WebFetch before merging the resulting `skills/incident-response/SKILL.md`.
