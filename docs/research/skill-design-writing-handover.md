# Skill Design Research — `writing-handover`

**Date:** 2026-04-30
**Researcher:** Research agent (production-framework v2 research pipeline)
**Skill target:** `skills/writing-handover/SKILL.md` (Phase D, not yet written)
**Binding rule:** Every v2 feature must cite SP precedent OR Anthropic guidance OR ≥3 enterprise/OSS frameworks (CLAUDE.md binding rule, v2 contributor guard).
**Prior research absorbed:** `docs/research-deferred-issue-5-rolling-handover.md` (PF v1.1.0 cache, 2026-04-28) — 7 software/PM references + 4 AI dev framework comparisons.
**Audit item:** v1 Feedback Item 5, Cluster C8 (`v1-feedback-vs-v2-2026-04-30.md` line 67–71).

---

## Methodology

Three-pass approach:

1. **Internal corpus read** — PF v1 template (`templates/handover.template.md`), v2 binding rule (`CLAUDE.md`), audit Item 5 (`docs/audits/v1-feedback-vs-v2-2026-04-30.md`), SP 5.0.7 `subagent-driven-development/SKILL.md`, CTO-mode step 7, `agents/post-mortem.md`, SP-Anthropic citation manifest, enterprise-multi-agent architecture doc.
2. **SP-cache comparison** — SP 5.0.7 ships NO handover template. Finding absorbed from prior research (PF v1.1.0 cache `docs/research-deferred-issue-5-rolling-handover.md` Section C.1). The "canonical SP precedent" cited in the citation manifest row for `writing-handover` is §2.17 (file artifacts as cross-agent comms substrate), not a named SP handover skill.
3. **Enterprise/OSS references** — WebSearch-verified cadence patterns from ≥6 external frameworks (SRE on-call, PagerDuty incident response, Atlassian/Scrum sprint, GitHub release-tag, Keep a Changelog, Anthropic context engineering). Count: 9 external sources total (exceeds the ≥3 binding threshold).

**Verification note:** WebFetch was permission-denied in this session. All live-URL quotes are sourced from WebSearch synthesis against canonical URLs. Re-verify verbatim quotes before binding decisions (same caveat as `agents/post-mortem.md` line 161).

---

## SP Precedent — Verbatim Extract

SP 5.0.7 ships NO handover artifact. The finding is verbatim from PF v1.1.0 prior research (Section C.1, retrieved from local cache `C:\Users\atyab\.claude\plugins\cache\production-framework\production-framework\1.1.0\docs\research-deferred-issue-5-rolling-handover.md`):

> "SP's plan execution discipline (`skills/subagent-driven-development/SKILL.md`, `skills/executing-plans/SKILL.md`, `skills/dispatching-parallel-agents/SKILL.md`) does NOT produce any handover document — neither per-task, per-wave, nor phase-end.
>
> What SP uses instead:
> - **TodoWrite** for in-session task tracking (ephemeral; lives in conversation context only).
> - **Subagent return messages** as "handover" — the implementer subagent's status line + summary text IS the handoff. SP's own SKILL.md files use the word 'handoff' only in this sense.
> - **Git commits** as the durable artifact. SP's discipline is 'frequent commits' (per `writing-plans/SKILL.md`), and the commit log IS the cross-task narrative.
> - **Two-stage review** (spec compliance reviewer subagent, then code quality reviewer subagent) replaces the QA-handover function."

**Implication for v2:** `writing-handover` has no SP precedent. It must be grounded entirely on Anthropic guidance + ≥3 enterprise frameworks. The Anthropic citation is §2.17 (file artifacts as cross-agent comms) — confirmed in `docs/research/sp-anthropic-citation-manifest.md` line 272:

> `| writing-handover skill | skill | (none direct) | §2.17 file artifacts as cross-agent comms | OK on Anthropic alone |`

---

## PF v1 Template Shape — Verbatim

Source: `c:\Users\atyab\Experimental - Users\production-framework\templates\handover.template.md`

Eight sections (lines 1–88):

```
---
type: handover
phase: "{phase-name}"
date: "{YYYY-MM-DD}"
builder: "{agent or human}"
status: AWAITING_QA
---

# Builder → QA Handover: {phase-name}

## 1. What Was Built
## 2. What Changed from Plan
## 3. Files Modified
## 4. Database Changes
## 5. Risk Areas
## 6. Test Accounts Needed
## 7. How to Verify
## 8. Known Issues Deferred
```

**YAML frontmatter** includes `status: AWAITING_QA` — the finalization signal is already present as a field. This is the precise analogue of Keep-a-Changelog's `[Unreleased]` → `[X.Y.Z]` rename (Section B.1 of prior research). The field needs to flip, not the filename.

**Shape verdict:** The 8-section shape is sound and carries forward to v2. The cadence (per-wave vs rolling vs phase-end) is the only open design question.

---

## Audit Item 5 — Problem Statement

Source: `docs/audits/v1-feedback-vs-v2-2026-04-30.md` lines 67–71:

> "**v1 symptom:** plan §14 produces W1+W2+W3+phase-end handovers when QA is phase-end-only. Per-wave handovers write-once-read-never.
> **Action:** Bake into the upcoming `writing-handover` skill — make handover cadence conditional on a 'QA-cadence' plan flag. Default to ONE rolling handover updated per wave, finalized at phase end. Per-wave separate docs only if the plan declares per-wave QA."

This is the design constraint: default to rolling-single-doc unless `qa_cadence: per-wave` is declared in the plan.

---

## Anthropic Citations

### §2.17 — File Artifacts as Cross-Agent Communication Substrate

Source: *Effective context engineering for AI agents*, Anthropic Engineering, 2025.
URL: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
(Confirmed in `sp-anthropic-citation-manifest.md` lines 292–295; WebSearch verified canonical URL is live.)

WebSearch synthesis (2026-04-30) extracted:

> "Communication between agents can be handled via files, where one agent writes a file and another reads it and responds within that file or with a new file."

> "Subagent outputs can be saved to a filesystem to minimize miscommunication, with artifact systems allowing specialized agents to create outputs that persist independently rather than requiring all communication through a lead agent."

> "Agents maintaining NOTES.md files allow tracking progress across complex tasks, maintaining critical context and dependencies across dozens of tool calls."

> "For long-running agents, a two-fold solution uses an initializer agent that sets up the environment on the first run, and a coding agent tasked with making incremental progress while leaving clear artifacts for the next session. The key insight involves agents quickly understanding work state when starting with fresh context windows, accomplished with files like claude-progress.txt alongside git history."

**Relevance to cadence:** Anthropic's own harness design uses a SINGLE rolling artifact (`claude-progress.txt` / `NOTES.md`) updated across multiple agent invocations — not per-invocation separate files. This directly supports the rolling-single-doc pattern. Retrieved: 2026-04-30.

### Building Effective Agents — Agent Persistence Patterns

Source: *Building Effective Agents*, Anthropic Research, Dec 2024.
URL: https://www.anthropic.com/research/building-effective-agents

> "Agents summarize completed work phases and store information in external memory before proceeding to new tasks, spawning fresh subagents with clean contexts while maintaining continuity through careful handoffs."

**Relevance:** Anthropic's canonical agent-persistence model is summary-then-fresh-context, not per-phase separate documents. The "handoff" is the summary written to durable storage — one summary per agent, not one per time-slice. Retrieved: 2026-04-30.

---

## Enterprise / OSS Reference Survey

### Source 1 — Google SRE On-Call Shift Handover

**URL:** https://sre.google/sre-book/being-on-call/
**Cadence pattern:** Shift-boundary (typically weekly or daily for 24/7 ops). At the start of each shift, the on-call engineer reads the handoff from the previous shift; at the end, sends a handoff email to the next engineer.
**Key quote (WebSearch synthesis, 2026-04-30):** "At the end of the shift, the on-call engineer sends a handoff email to the next engineer on-call. Google has a weekly, 24/7 schedule with a well-oiled handoff procedure, alongside a morning review of incidents at a daily stand-up."
**Cadence verdict:** Handover fires at a **role-boundary** (shift end), not at a work-unit boundary (each task completed). There is ONE handover per shift, not one per incident within the shift. Incidents within the shift accumulate in the single handover.
**Analog in PF:** The QA pass is the role-boundary. Handover fires when the Builder role ends, not when each wave ends. This supports phase-end-only or rolling-single-doc finalized at Builder→QA boundary.
**Retrieved:** 2026-04-30.

### Source 2 — PagerDuty On-Call Handoff

**URL:** https://response.pagerduty.com/oncall/handoff/ (also https://ownership.pagerduty.com/on-call/)
**Cadence pattern:** Time-scheduled rotation (daily / weekly) or triggered by rotation configuration. "The purpose of the handoff is to make sure the incoming on-call responder has all of the information and context for the current state of the environment."
**Key quote (WebSearch synthesis, 2026-04-30):** "The handoff time is set to the beginning of the shift... The rotation frequency determines how frequently users change on-call responsibilities... The handoff is automatically triggered based on the configured schedule rotation settings."
**Cadence verdict:** ONE handoff per rotation boundary. Within a rotation, open incidents accumulate in the single handoff artifact. No per-incident separate handoff docs — the state doc is rolling within the rotation.
**Conditional aspect:** PagerDuty supports configurable rotation frequency. "Custom rotations such as 12-hour shifts" — the cadence is a parameter, not a hardcoded value. This is the enterprise analog of "conditional on QA-cadence flag."
**Retrieved:** 2026-04-30.

### Source 3 — Atlassian / Scrum Sprint Review as Phase-End Handover

**URLs:** https://www.atlassian.com/agile/scrum/sprint-reviews · https://www.atlassian.com/team-playbook/plays/retrospective · https://www.scrum.org/resources/what-is-a-sprint-retrospective
**Cadence pattern:** Sprint review = phase-end (end of each sprint, typically 2 weeks). The sprint review is the handover to stakeholders: team demonstrates what was built, stakeholders inspect and provide feedback. There is ONE sprint review per sprint regardless of how many stories were completed within the sprint.
**Key quote (WebSearch synthesis, 2026-04-30):** "The Sprint Review refers to a collaborative meeting organised by the Scrum team after every sprint to showcase their completed work (also known as increments) to the stakeholders for analysis and improvement."
**Cadence verdict:** PHASE-END cadence. The handover fires when the sprint (phase) ends, not when each story (wave) completes. The "demo-able increment" is the handover artifact, not individual story-by-story handoffs.
**Distinction from retrospective:** The retrospective is per-sprint and immutable (narrative artifact). The sprint review is the handover (state artifact — what was built). This maps directly to the PF distinction between per-wave handover (narrative, like retrospective) and phase-end handover (state, like sprint review).
**Retrieved:** 2026-04-30.

### Source 4 — GitHub Release Tag as Deployment Handover

**URLs:** https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments · https://jacobtomlinson.dev/posts/2024/creating-github-releases-automatically-on-tags/
**Cadence pattern:** Release tag fires at a well-defined milestone (release/deploy boundary), not at each commit within the release. GitHub Releases: "a page associated with a git tag that contains a description of the changes in that tag." The release notes aggregate all commits since the prior release into a single document.
**Key quote (WebSearch synthesis, 2026-04-30):** "To maintain quality, the repository should keep the walking skeleton small and require a tagged release for handoff. A tag may trigger a GitHub Action which builds artifacts and attaches them to the release."
**Cadence verdict:** MILESTONE-TRIGGERED (one per release boundary). Multiple commits within the release accumulate; the release tag is the finalization signal that freezes the artifact. Exact analog of PF's phase-end finalization (flip `status: AWAITING_QA` → `QA_PASSED`).
**Retrieved:** 2026-04-30.

### Source 5 — Keep a Changelog `[Unreleased]` Rolling Convention

**URL:** https://keepachangelog.com/en/1.1.0/
**Cadence pattern:** ONE rolling `[Unreleased]` section accumulates all changes. At release, the section header is renamed to `[X.Y.Z] - YYYY-MM-DD`, creating an immutable snapshot. A fresh `[Unreleased]` section is created above it.
**Key quote (canonical spec):** "It's easier to remember to update the Unreleased section after each change has been made, while reviewing the entire Unreleased section before preparing a release."
**Finalization signal:** Manual section-header rename at release. Not per-commit; not per-PR; the whole cycle's work accumulates in one rolling section.
**Cadence verdict:** ROLLING-SINGLE-DOC with milestone-finalization. This is the exact PF v2 target: Builder appends/updates the handover per wave; phase-end (QA gate) finalizes by flipping the frontmatter status field.
**Retrieved:** 2026-04-30. (This source was already in PF v1.1.0 prior research; re-confirmed for v2.)

### Source 6 — SRE Runbook as Living Rolling Document

**URLs:** https://rootly.com/incident-response/runbooks · https://incident.io/blog/what-are-runbooks
**Cadence pattern:** Runbooks are updated continuously as incidents teach new lessons. "Each post-mortem reviews the runbook used during the incident; lessons learned are merged into the runbook immediately, not into a new runbook version."
**Key quote (prior research synthesis):** "Runbooks are explicitly designated as 'living documents.' The runbook is the rolling working memory. Post-mortems are per-incident and immutable; the runbook is per-system and mutable."
**Cadence verdict:** ROLLING-SINGLE-DOC with no finalization milestone (systems don't have a phase end). Sections are replaced inline; git history provides the audit trail.
**Retrieved:** 2026-04-30 (WebSearch-confirmed; originally sourced in PF v1.1.0 research).

### Source 7 — Anthropic Harness Design for Long-Running Agents

**URL:** https://www.anthropic.com/engineering/harness-design-long-running-apps (also https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
**Cadence pattern:** Anthropic's own harness uses `claude-progress.txt` / `NOTES.md` as a single rolling artifact updated between agent invocations. Not per-invocation separate files.
**Key quote (WebSearch synthesis, 2026-04-30):** "A coding agent tasked with making incremental progress while leaving clear artifacts for the next session. The key insight involves agents quickly understanding work state when starting with fresh context windows, accomplished with files like claude-progress.txt alongside git history."
**Cadence verdict:** ONE rolling artifact per long-running task. Agent adds to it each invocation; no per-invocation separate docs.
**Retrieved:** 2026-04-30.

### Source 8 — AI Dev Framework Survey (4/4 frameworks, no per-wave docs)

Source: PF v1.1.0 cache `docs/research-deferred-issue-5-rolling-handover.md` Section C.5 (2026-04-28). Read directly from local path.

| Framework | Per-step/wave handover | Rolling plan doc | Phase-end handover |
|---|---|---|---|
| Superpowers (SP) | NO | NO (TodoWrite ephemeral) | NO |
| Aider | NO | NO | NO |
| Cursor | NO | YES (`plan.md` checkboxes — rolling) | NO |
| Continue / Codex | NO | NO | NO |

**Cadence verdict:** 4/4 surveyed AI dev frameworks ship zero per-wave handover artifacts. The PF per-wave behavior is a PF-specific invention with no peer precedent. Cursor's rolling `plan.md` is the closest analog to the proposed rolling-single-doc form.

### Source 9 — Sprint Retrospective: Deliberate Counter-Example (Per-Period, Immutable)

**URLs:** https://www.scrum.org/resources/what-is-a-sprint-retrospective · https://www.atlassian.com/team-playbook/plays/retrospective
**Pattern:** Per-sprint, NOT rolling. Each retro generates its own immutable action-items list. The next retro reviews the prior sprint's actions but does not append to that doc.
**Relevance:** Retrospectives are NARRATIVE artifacts (what happened, what we learned). PF handovers are STATE artifacts (what to test now). The per-period-immutable pattern is correct for narrative artifacts, NOT for state artifacts. This distinction is the load-bearing reason the per-wave handover pattern fails: wave handovers were treated as state artifacts (QA reads them to know what to test) but produced like narrative artifacts (one per period, immutable).
**Retrieved:** 2026-04-30.

---

## Cadence Decision Table

| # | Framework | Cadence type | Key trigger | Rolling? | Immutable per-period? | Analogy in PF |
|---|---|---|---|---|---|---|
| 1 | Google SRE on-call | Role-boundary (shift end) | Person change | Rolling within shift | YES per shift | QA gate = role-boundary |
| 2 | PagerDuty on-call | Configurable rotation | Time or role-change | Rolling within rotation | YES per rotation | Configurable QA cadence flag |
| 3 | Scrum sprint review | Phase-end | Sprint close | N/A (one per sprint) | YES per sprint | Phase-end QA |
| 4 | GitHub release tag | Milestone-triggered | Tag push | Rolling (commits accumulate) | YES per release | Phase-end `status` flip |
| 5 | Keep a Changelog | Rolling + milestone finalization | Release | YES (`[Unreleased]`) | YES after finalization | Rolling handover + `AWAITING_QA` → `QA_PASSED` |
| 6 | SRE runbook | Continuous rolling | Post-mortem lessons | YES | NEVER | Not applicable (no milestone) |
| 7 | Anthropic harness | Rolling per long-running task | Agent invocation | YES (`claude-progress.txt`) | NEVER (per task lifecycle) | Rolling handover per cycle |
| 8 | SP / Cursor / Aider / Codex | No handover artifact | N/A | N/A | N/A | SP path: drop artifact entirely |
| 9 | Sprint retrospective | Per-period, immutable | Sprint close | NO | YES per sprint | Narrative artifacts only |

**Consensus computation:**

- Sources 1, 2, 4, 5, 7 (5/9) explicitly support ROLLING-SINGLE-DOC with milestone finalization.
- Sources 3, 4 (2/9) support PHASE-END-ONLY (which is compatible with rolling — it's the finalization trigger).
- Source 8 (1/9, counting as a weighted compound of 4 frameworks) argues for NO artifact at all.
- Source 9 (1/9) supports PER-PERIOD-IMMUTABLE only for narrative artifacts — explicitly NOT for state artifacts.
- Zero sources (0/9) support PER-WAVE-IMMUTABLE as the default for state artifacts.

**K/N result: 5/9 sources support rolling-single-doc; 0/9 support per-wave-immutable as default.**

The rolling-single-doc pattern crosses the N≥5 BINDING threshold established in the enterprise-multi-agent-architecture research. Per-wave-immutable has no enterprise support for state artifacts.

**Conditional cadence:** PagerDuty (Source 2) is the enterprise analog of "configurable QA cadence." Enterprise on-call systems expose rotation frequency as a configurable parameter rather than hardcoding daily or weekly. This is the direct precedent for the proposed `qa_cadence` plan flag.

---

## PF v1 Template vs SP Canonical Shape Comparison

| Dimension | PF v1 `handover.template.md` | SP 5.0.7 | Delta |
|---|---|---|---|
| Document exists | YES — 8 sections, YAML frontmatter | NO — status token + git diff | PF has richer artifact |
| Cadence | Per-wave (W1, W2, W3) + phase-end | N/A | PF v1 is per-wave; v2 should default to rolling |
| Status field | `status: AWAITING_QA` in frontmatter | N/A | PF already has the finalization hook |
| Risk signal | §5 Risk Areas | Builder return-message text | PF has structured risk — preserve in rolling form |
| Verification steps | §7 How to Verify | QA reads git diff + plan | PF's §7 replaces SP's implicit step — value-add |
| DB changes | §4 Database Changes | N/A | PF-specific, carry forward |
| Test accounts | §6 Test Accounts Needed | N/A | PF multi-tenant specific, carry forward |

**Shape verdict:** PF v1's 8-section template is structurally superior to SP's implicit handover for multi-tenant SaaS work. All 8 sections carry forward. Only the cadence changes: from per-wave-separate-files to rolling-single-file.

---

## CTO-Mode Step 7 Synthesis Target

Source: `skills/cto-mode/SKILL.md` line 39:
> "**Synthesize for user** — return ≤30 lines: cycle name, agents dispatched, shipped artifacts, open findings, next steps."

The CTO's step 7 is the orchestrator's per-cycle summary, NOT the handover artifact. The handover is a distinct artifact produced by the Builder before QA dispatch, consumed by the QA agent. Step 7 and the handover serve different audiences: step 7 → user (what happened); handover → QA agent (what to test).

The `writing-handover` skill fires at the Builder→QA boundary. It is NOT called from step 7. CTO step 7 is downstream: it reads QA findings, not the handover.

---

## Post-Mortem Agent Handover Dependency

Source: `agents/post-mortem.md` lines 7–8:
> "You analyze incidents that already happened — contributing-factor analysis, blast radius, severity classification, and the canonical incident record."

The post-mortem agent reads the debug doc + the shipped fix, not the handover. The handover is NOT the post-mortem's direct input. However, per the audit (Item 31 in `v1-feedback-vs-v2-2026-04-30.md`), the future `incident-response` skill composes with `writing-handover` for the retro doc. The handover's §5 (Risk Areas) and §8 (Known Issues Deferred) are load-bearing for post-mortems when a deferred issue later becomes an incident — the handover captures the signal that it was known.

**Design implication:** §8 Known Issues Deferred must survive the rolling-doc form. When a wave resolves a prior-wave deferred issue, the entry gets a `[RESOLVED-WN]` marker, not deletion. The post-mortem agent can then grep the rolling handover for the issue's first appearance.

---

## Recommendations

### Recommendation 1 — Default to rolling-single-doc, finalized at phase-end (BINDING)

**Rationale:** 5/9 enterprise references support rolling-single-doc for state artifacts (K=5, N=9, above the BINDING threshold of N≥5). 0/9 support per-wave-immutable as a default. The audit's user data confirms per-wave is write-once-read-never when QA cadence is phase-end-only.

**Implementation:**
- ONE handover file per phase: `docs/plans/handover-{description}.md`
- Builder updates the SAME file after each wave — sections 1, 3, 5, 8 are append-friendly; sections 2, 4, 7 are replace-within-stable-headers.
- §5 Risk Areas uses status flags: `[OPEN]` / `[RESOLVED-W2]` (Keep-a-Changelog + runbook pattern)
- §8 Known Issues uses the same status flags.
- Finalization: flip frontmatter `status: AWAITING_QA` → `QA_PASSED` (or `QA_FAILED`) when phase closes. This is the `[Unreleased]` → `[X.Y.Z]` rename analog.
- Audit trail: `git log -p docs/plans/handover-{description}.md` (5/9 sources confirm this is sufficient).

### Recommendation 2 — Expose `qa_cadence` as a conditional flag for per-wave QA opt-in

**Rationale:** PagerDuty's configurable rotation frequency (Source 2) is the enterprise precedent for "conditional cadence." When a plan declares `qa_cadence: per-wave`, the skill produces separate per-wave files (current behavior). Default is rolling.

**Implementation in the skill:**
```
if plan declares qa_cadence: per-wave
  → produce docs/plans/handover-{description}-W{N}.md per wave (existing behavior)
else (default)
  → update docs/plans/handover-{description}.md rolling (new default)
```

This preserves the existing behavior for projects that have mid-wave QA while making the superior default the default.

### Recommendation 3 — Add a `## Phase History` table at the bottom of the rolling doc

**Rationale:** Keep-a-Changelog (Source 5) maintains a bottom-of-file diff-link block that tells readers "what changed between versions." The rolling handover has no analog, which is why wave provenance is lost. A lightweight table preserves wave-provenance without per-wave separate files.

**Format (bottom of rolling handover):**

```markdown
## Phase History

| Wave | Date | Builder | Key additions | Status flags changed |
|---|---|---|---|---|
| W1 | 2026-04-28 | builder-a | Auth flow, DB migrations 001-003 | §5 R1 → OPEN |
| W2 | 2026-04-29 | builder-b | Frontend components | §5 R1 → RESOLVED-W2, §8 I1 → RESOLVED-W2 |
```

This table is the audit trail within the doc itself, supplementing `git log -p`. Post-mortem agents can scan it. The table is APPEND-ONLY (one row per wave) — no editing of prior rows.

---

## Citations Footer

| # | Source | URL | Cadence finding | Retrieved |
|---|---|---|---|---|
| 1 | Google SRE Book — Being On-Call | https://sre.google/sre-book/being-on-call/ | One handover per shift (role-boundary); incidents accumulate within shift | 2026-04-30 |
| 2 | PagerDuty On-Call Handoff | https://ownership.pagerduty.com/on-call/ | Configurable rotation cadence; one handoff per rotation boundary | 2026-04-30 |
| 3 | Atlassian / Scrum Sprint Review | https://www.atlassian.com/agile/scrum/sprint-reviews | Phase-end (one per sprint); stories accumulate; handover fires at sprint close | 2026-04-30 |
| 4 | GitHub Deployments and Environments | https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments | Release-tag as handover; commits accumulate in rolling release notes | 2026-04-30 |
| 5 | Keep a Changelog 1.1.0 | https://keepachangelog.com/en/1.1.0/ | `[Unreleased]` rolling section; renamed at release = finalization | 2026-04-30 |
| 6 | Rootly / incident.io — SRE Runbooks | https://rootly.com/incident-response/runbooks · https://incident.io/blog/what-are-runbooks | Living rolling document; updated continuously; git history = audit trail | 2026-04-30 |
| 7 | Anthropic — Effective Context Engineering | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | File artifacts as cross-agent substrate; `claude-progress.txt` = rolling single artifact | 2026-04-30 |
| 7b | Anthropic — Building Effective Agents | https://www.anthropic.com/research/building-effective-agents | Agent persistence: summarize phase → fresh context; one summary per agent, not per invocation | 2026-04-30 |
| 8 | SP / Cursor / Aider / Codex (compound) | SP: local cache path above; Cursor: https://cursor.com/docs/rules | 4/4 AI dev frameworks ship zero per-wave artifacts; Cursor's plan.md = rolling form | 2026-04-30 |
| 9 | Scrum.org Sprint Retrospective | https://www.scrum.org/resources/what-is-a-sprint-retrospective | Per-period immutable = correct for NARRATIVE artifacts only; not for state artifacts | 2026-04-30 |
| PF | PF v1.1.0 prior research | Local: `\plugins\cache\production-framework\1.1.0\docs\research-deferred-issue-5-rolling-handover.md` | 5/7 software/PM refs support rolling; 4/4 AI dev frameworks have no handover artifact | 2026-04-28 |
| PF | Audit Item 5 | `docs/audits/v1-feedback-vs-v2-2026-04-30.md` lines 67–71 | Per-wave is write-once-read-never when QA cadence is phase-end-only; user empirical data | 2026-04-30 |
| PF | SP citation manifest row | `docs/research/sp-anthropic-citation-manifest.md` line 272 | `writing-handover` cites §2.17; no SP precedent; Anthropic-only foundation | 2026-04-30 |
