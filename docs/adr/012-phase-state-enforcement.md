# ADR-012 — Phase-State Enforcement (Skill-Layer Orchestrator + Durable `cycle-state.md` Substrate)

**Status:** Proposed
**Date:** 2026-05-12 (Pass-3 finalization after Lane R-5 Researcher return)
**Authors:** Production-framework Architect sub-agent (Opus 4.7), Pass 3 finalization
**Supersedes:** Pass-2 placeholder of this ADR (Disposition A through C deferral table) — Lane R-5 has now returned and the disposition is closed in favor of (A).

---

## Context and Problem Statement

The framework's eight execution cycles (build, debug, research, refactor, security-audit, performance, migration, post-mortem) define an ordered agent graph (Architect → Researcher → DB Engineer → Security/Compliance → Builder → QA → SRE/DevOps), but ordering is encoded only as **recipe in skill prompts** — there is no mechanical refusal-to-dispatch when a prior phase has not produced its output artifact. The Deputy/CTO can drift past required phases without flagging the skip, and the skip is not recorded as a logged event.

The trade-off the Pass-1 Architect flagged (`framework-feedback-response-2026-05-12.md` §9): extending `hooks/pre-tool-use` to gate "dispatch of Phase N+1 on Phase N is DONE" is a **hook-contract change → MAJOR semver bump (v3.0.0)**. Achieving the same enforcement at skill-only layer (`cto-mode` refuses to dispatch internally, reading `docs/cycle-state.md`) is a MINOR bump (v2.4.0). The decision turns on enterprise consensus: where does industry place the phase-ordering enforcement boundary?

Lane R-5 (Researcher, `docs/research/cycle-phase-enforcement-2026-05-12.md`, 2026-05-12) returned with 11/11 declarative-graph + named-substrate consensus across surveyed frameworks. The disposition is now closeable.

---

## Decision Drivers

1. **Enterprise-research-first binding rule** (CLAUDE.md): a non-obvious architectural choice must cite ≥3 enterprise/OSS implementations. Lane R-5 returned 11 surveyed frameworks across two adjacent layers (workflow engines + AI multi-agent frameworks) and 5 SDLC/change-management frameworks.
2. **Semver discipline** (CLAUDE.md versioning matrix): hook-contract change is MAJOR; skill body change is MINOR. The enforcement surface chosen determines plugin-version impact.
3. **SP precedent reuse:** PF v2's `cycle-selection` skill already enforces a "do not dispatch until artifact exists" HARD-GATE at lines 15-17 — the design needs to extend this shape, not invent a new one.
4. **Skip semantics must be auditable** (Item 12 source): a skipped phase must be recorded with a justification, not silent. ITIL Emergency Change + SAFe Inspect-and-Adapt + CAB-in-DevOps each instantiate this in enterprise SDLC practice.

---

## Considered Options

### Option 1 — Hook-layer enforcement (extend `pre-tool-use`)

`hooks/pre-tool-use` gates dispatches by reading `docs/cycle-state.md` and refusing the Task tool when prior phase status is not `DONE` or `SKIPPED+justification`.

- **Pros:** Mechanical refusal regardless of which skill is active.
- **Cons:** Hook-contract change → **MAJOR** v3.0.0 bump per CLAUDE.md. Couples phase semantics to tool semantics (hook sees tool calls, not phase boundaries). No enterprise precedent in the surveyed frameworks places the enforcement at the runtime-hook layer — all 11 surveyed frameworks place it at the orchestrator/coordinator layer.

### Option 2 — Skill-layer enforcement at `cto-mode` (chosen)

`cto-mode` skill body adds a HARD-GATE block: refuse to dispatch Phase N+1 until `docs/cycle-state.md` records Phase N as `DONE` OR `SKIPPED + <one-line justification>`. Reuses the existing `docs/cycle-state.md` substrate (introduced at v2.3.0 by `cycle-selection`). Phase-skip grammar (`user-intent-already-clear` / `no-schema-touched` / `existing-coverage` plus free-form for review) is enumerable. End-of-cycle visible diff vs the canonical cycle definition surfaces the skipped phases as input to the Open Findings list.

- **Pros:** **MINOR** v2.4.0 bump (no hook-contract change). Matches 11/11 enterprise consensus on coordinator-layer enforcement. Extends the existing `cycle-selection` HARD-GATE shape (one layer deeper). Reuses `docs/cycle-state.md` durable substrate — Magentic-One Task-and-Progress Ledger analog.
- **Cons:** Enforcement only fires when `cto-mode` is loaded; a session that bypasses `cto-mode` would not be gated (acceptable — `using-production-framework` SessionStart-loads `cto-mode` for any non-trivial task).

### Option 3 — Recipe-only (defer enforcement entirely)

Keep the cycle ordering as prose in skill bodies; rely on agent discretion.

- **Pros:** No code change.
- **Cons:** Reproduces the exact failure mode Item 12 describes. Zero enterprise precedent for purely-implicit phase ordering on multi-agent dispatch graphs (Lane R-5 found 0/11 frameworks doing this).

---

## Decision Outcome

**Chosen: Option 2 — Skill-layer enforcement at `cto-mode` with `docs/cycle-state.md` as the durable phase-state-tracker substrate.**

Specifically:

1. **State substrate.** `docs/cycle-state.md` (introduced at v2.3.0 by `cycle-selection`) becomes the canonical phase-state-tracker artifact. Schema extends with one row per phase: `{phase: <name>, status: PENDING | IN-PROGRESS | DONE | SKIPPED, agent_dispatched_at, output_doc, gate_passed: bool, skip_justification?: string}`. Append-only; each agent updates its own row on completion.

2. **Enforcement surface.** Modify `skills/cto-mode/SKILL.md` (skill-only edit, no hook change) to add a HARD-GATE block: refuse Phase N+1 dispatch until `docs/cycle-state.md` records Phase N as `DONE` OR `SKIPPED + <justification>`. The HARD-GATE follows the same shape as `cycle-selection` lines 15-17.

3. **Skip grammar.** Enumerable categories — `user-intent-already-clear`, `no-schema-touched`, `existing-coverage` — plus free-form justifications which are flagged for review at cycle end. The skip MUST be logged before the next phase dispatches (ITIL Emergency Change precedent: paperwork can be post-implementation, but the audit trail is mandatory).

4. **Visible diff at cycle end.** `cto-mode` surfaces "skipped phases" as a visible diff in `docs/cycle-state.md` vs the canonical cycle definition. The skip log feeds the project's Open Findings list (SAFe Inspect-and-Adapt precedent: skip becomes input to the improvement backlog).

5. **Gate-3 D-row addition (separate Build-cycle scope).** A new `gate-3-production-check` dimension (`D-cycle-state-hygiene`) enforces that all phases have terminal status (`DONE` or `SKIPPED+justification`) at gate-3 time — no `PENDING`/`IN-PROGRESS` survives. Reuses the existing "skipped dimension is a gate failure" mechanic from `gate-3-production-check` lines 30-31. This row is recorded in this ADR but implemented in a sibling ADR/Build (not bundled).

6. **Do NOT extend `hooks/pre-tool-use`.** Lane R-5 found 0/11 frameworks using the runtime-hook layer for phase enforcement; extending it would couple phase to tool semantics and impose an unnecessary MAJOR bump.

**Plugin-version implication.** Per CLAUDE.md versioning matrix:
- Skill body change (`cto-mode`) + extended `cycle-state.md` schema = **MINOR (v2.3.0 → v2.4.0)**.
- No hook contract change → **NOT MAJOR**.

---

## Consequences

**Positive:**
- Enforcement matches 11/11 surveyed-framework consensus on coordinator-layer placement.
- Plugin remains on the minor track; v2.4.0 ships the enforcement alongside the other ADRs in the same cycle.
- Skip is auditable (justification logged before next phase dispatches; visible diff at cycle end).
- Substrate reuse: no new file, just an extended schema for `docs/cycle-state.md`.

**Negative / accepted trade-offs:**
- Enforcement is bounded to sessions where `cto-mode` is loaded. SessionStart-loading of `cto-mode` via `using-production-framework` makes this effectively-always for any non-trivial task, but a hypothetical bypass would not be gated.
- The phase-state schema lives in a markdown file, not a structured DB — concurrent agent updates rely on append-only discipline rather than transactional safety. Acceptable for single-orchestrator single-session use.

**Re-verification requirement (Pass-2 disclosure carries forward):**
- Lane R-5's WebFetch was permission-denied for several primary sources (Airflow, Temporal, Astronomer, Argo Workflows documentation). Citations marked `via WebSearch synthesis of canonical URL` must be re-verified against live URLs before the Build cycle commits the `cto-mode` skill edit. If WebFetch is unavailable in the Build session, manual user-browser verification is acceptable per CLAUDE.md citation discipline.

---

## Citations (verbatim from Lane R-5 Researcher output, with URLs + verification dates)

The full evidence base lives at `docs/research/cycle-phase-enforcement-2026-05-12.md`. Six citations are reproduced verbatim below; all six are the load-bearing precedents for the decision. Three or more of the workflow-engine, AI-multi-agent, and SDLC families are represented.

### Workflow-engine precedent (declarative + named-substrate consensus, 5/5)

**[Q7.1-1]** AWS Step Functions (primary, via successful WebFetch):

> "Step Functions is based on *state machines* and *tasks*. In Step Functions, state machines are called *workflows*, which are a series of event-driven steps. Each step in a workflow is called a *state*."
> "Standard workflows ... have exactly-once workflow execution and can run for up to one year. This means that each step in a Standard workflow will execute exactly once."

URL: https://docs.aws.amazon.com/step-functions/latest/dg/welcome.html — verified 2026-05-12.

**[Q7.1-2]** Apache Airflow (via WebSearch synthesis of canonical URL — WebFetch denied; re-verify before Build):

> "The default value for trigger_rule is all_success and can be defined as 'trigger this task when all directly upstream tasks have succeeded'."
> "An important aspect of the all_success trigger rule is how it handles skipped tasks: The join task will show up as skipped because its trigger_rule is set to all_success by default and skipped tasks will cascade through all_success."

URL: https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html + https://www.astronomer.io/docs/learn/airflow-trigger-rules — verified 2026-05-12 (via WebSearch synthesis of canonical URL; re-verification needed).

**[Q7.1-3]** Temporal (via WebSearch synthesis of canonical URL — WebFetch denied; re-verify before Build):

> "When the Workflow's code replays, the Commands that are emitted are compared with the existing Event History. If a corresponding Event already exists within the Event History that matches that command, then the Execution progresses."
> "When violations occur, if a generated Command doesn't match what it needs to in the existing Event History, then the Workflow Execution returns a non-deterministic error."

URL: https://docs.temporal.io/workflows + https://docs.temporal.io/workflow-execution/event — verified 2026-05-12 (via WebSearch synthesis of canonical URL; re-verification needed).

### AI-multi-agent-framework precedent (named state-tracker artifact, 4/6)

**[Q7.2-5]** Magentic-One (via WebSearch synthesis — the most-explicit Task-Ledger + Progress-Ledger instance):

> "The Orchestrator begins by creating a plan to tackle the task, gathering needed facts and educated guesses in a Task Ledger that is maintained."
> "At each step of its plan, the Orchestrator creates a Progress Ledger where it self-reflects on task progress and checks whether the task is completed."
> "The outer loop manages the task ledger (containing facts, guesses, and plan) and the inner loop manages the progress ledger (containing current progress, task assignment to agents)."

URL: https://www.microsoft.com/en-us/research/articles/magentic-one-a-generalist-multi-agent-system-for-solving-complex-tasks/ + https://microsoft.github.io/autogen/dev/user-guide/agentchat-user-guide/magentic-one.html — verified 2026-05-12 (via WebSearch synthesis of canonical URL).

### SDLC skip-with-justification precedent (3/5 explicit logging)

**[Q7.3-1]** ITIL 4 Change Enablement Emergency Change (via WebSearch synthesis of practitioner sources; ITIL is paywalled):

> "Emergency changes are time-sensitive, urgent changes to prevent major incidents and are still expedited and typically require a post-implementation review."
> "For emergency changes specifically, the paperwork and approvals can be done post implementation so that there is an auditable trail that it happened."

URL: https://itsm.tools/change-enablement/ + https://blog.invgate.com/emergency-change-control-process — verified 2026-05-12 (SECONDARY; ITIL primary paywalled).

**[Q7.3-2]** SAFe ART Inspect-and-Adapt (via WebSearch synthesis):

> "The Inspect and Adapt (I&A) is a significant event held at the end of each PI, where the current state of the Solution is demonstrated and evaluated, and teams then reflect and identify improvement backlog items via a structured problem-solving workshop."
> "The result is a set of improvement backlog items that go into the ART Backlog for consideration in the next PI Planning event."

URL: https://framework.scaledagile.com/inspect-and-adapt + https://framework.scaledagile.com/pi-planning + https://framework.scaledagile.com/agile-release-train — verified 2026-05-12 (via WebSearch synthesis of canonical URL).

### Internal SP precedent (one-layer-deeper extension of existing HARD-GATE)

**[Q7.4-3]** PF v2 `cycle-selection` (local file):

> Lines 15-17: "Do NOT dispatch any sub-agent until both cycle and tier are output. The CTO mode skill will block dispatch otherwise."

Path: `skills/cycle-selection/SKILL.md` lines 15-17 — verified 2026-05-12. This is the exact "do not dispatch agent X until artifact Y exists at path Z" pattern the new HARD-GATE extends, one layer deeper (Phase-N+1 dispatch gated on Phase-N status in `cycle-state.md`).

### Anthropic-side framing

**[Q7.4-7]** Anthropic — *Building Effective AI Agents* (orchestrator-worker pattern):

> "In the orchestrator-workers workflow, a central LLM dynamically breaks down tasks, delegates them to worker LLMs, and synthesizes their results."
> "In Anthropic's framework, workflows are systems where LLMs and tools are orchestrated through predefined code paths, while agents are systems where LLMs dynamically direct their own processes and tool usage."

URL: https://www.anthropic.com/research/building-effective-agents — verified 2026-05-12 (via WebSearch synthesis of canonical URL).

---

## More Information

- **Full Researcher evidence base:** `docs/research/cycle-phase-enforcement-2026-05-12.md` (Lane R-5, 14 search-class tool calls; 11/11 declarative-graph consensus + 3/5 explicit skip-with-justification + SP-precedent grounding).
- **Pass-1 Architecture doc context:** `docs/architecture/framework-feedback-response-2026-05-12.md` §3 row 7 (C7 cluster), §4 (Q7.1–Q7.4 verbatim), §9 (semver-vs-enforcement-layer trade-off).
- **Composes with:**
  - ADR-002 (hook-gating tier-selection) — phase-state enforcement explicitly does NOT extend the `pre-tool-use` hook; it sits beside ADR-002 at the skill layer.
  - ADR-003 (broadened pattern ingest) — phase-skip log feeds Path A pattern-ingest if N≥3 cycles show the same skip pattern.
  - ADR-006 (v2.2 detection-adaptation-recovery layer) — the visible-diff-at-cycle-end mechanism feeds the recovery surface.
- **Implementation surface (deferred to Build cycle):**
  - `skills/cto-mode/SKILL.md` — add HARD-GATE block for phase-state enforcement; extend the `docs/cycle-state.md` write contract.
  - `skills/cycle-selection/SKILL.md` — extend the `cycle-state.md` schema to include the per-phase row.
  - `templates/PROJECT-PLAN.template.md` (already MODIFY in §2 File List for other reasons) — extend the cycle-history section to surface skipped-phase rows for Open Findings ingestion.
  - `skills/gate-3-production-check/SKILL.md` — add D-cycle-state-hygiene row (scope of a sibling ADR/Build; recorded here for cross-reference).
- **Re-verification before Build:** All WebSearch-synthesis citations above must be re-verified against live URLs before the Build cycle commits `cto-mode` changes per CLAUDE.md citation discipline. The AWS Step Functions citation is primary (WebFetch succeeded); the others are WebSearch-synthesized.

---

## Status token

**PROPOSED.** Ready for orchestrator ratification and Build-cycle dispatch. Plugin-version impact: MINOR (v2.3.0 → v2.4.0). No hook-contract change; no major bump.
