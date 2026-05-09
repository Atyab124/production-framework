# ADR-006 — v2.2.0 Detection + Adaptation + Recovery Layer

**Status:** Accepted (scope expanded 2026-05-09 — see Scope Update below)

## Scope Update — 2026-05-09

This ADR was originally drafted with a v2.1.1 production fix path (top 4 fixes — F-V13 + D1 + D2 + A2) followed by a v2.2.0 upgrade with the full 5-layer plan. Per user direction 2026-05-09 ("incorporate as many fixes as we can, why not just fix everything?"), the split is dropped: every closable finding ships as one consolidated v2.2.0 upgrade.

The implementation cycle's scope, deferred items with rationale, and bootstrap deviation (Builder broken → main-session edits this release) are tracked in `docs/cycle-state.md` and the master plan `docs/plans/v2-2-0-upgrade.md`. The 5-layer design below remains the authoritative architecture doc; only the release packaging changed.

---

**Status (original):** Proposed
**Date:** 2026-04-30
**Authors:** Production-framework CTO (Opus 4.7)
**Reconciliation report:** `docs/reconciliation/v2-2-research-2026-04-30.md`
**Research inputs:** 5 docs at `docs/research/v2-2-{detection,adaptation,recovery,strength-preservation,measurement}-2026-04-30.md`
**Findings folded in:** F-V8, F-V9 (amended), F-V10, F-V11, F-V12, F-V13 (NEW), VS-05 (NEW)

---

## Context

Empirical use of v2.1.0 in Taskforge (mention-picker UX cycle, BP-12 residual fix, framework-feedback log) surfaced a clean diagnostic split:

- **Strengths cluster around PREVENTION** (HARD-GATE blocking, research-first BINDING, snapshot-before-DONE, compact-preservation): all front-loaded gates that fire BEFORE the LLM commits to action. Empirically validated as correct across ≥3 catches per session (VS-03 + VS-05).
- **Frictions cluster around DETECTION + ADAPTATION + RECOVERY**: silent post-DONE failures (Builder reported DONE with 0 file changes; Playwright suite passed while real-user input reproduced the bug); ceremony tax that doesn't scale down (10× tier-selection re-fires per session for 4 logical task families; 30-LOC remediation produces 100-line plan doc); no documented recovery for tool-state failures (Playwright lock).

Five parallel research workstreams (4× Sonnet 4.6 + 1× Opus 4.7 for adversarial analysis) returned and were reconciled per the parallel-reconciliation skill. This ADR encodes the resulting v2.2.0 design.

---

## Decision

v2.2.0 ships THREE new layers + ONE shipped-bug fix:

1. **Detection layer** — post-execution verification checks added to existing agents (no new agent)
2. **Adaptation layer** — session-state cooperation via `docs/cycle-state.md` open-cycle marker + sub-agent verdict inheritance + scoped writing-plans fast-path
3. **Recovery layer** — per-tool "Common Recovery" prose in 4 skills + extended `trigger-audit.jsonl` schema for MCP errors
4. **F-V13 production fix** — Windows path-separator bug in pre-tool-use hook's docs/ auto-allow

The binding constraint across all layers (per WS4 adversarial analysis): every fix preserves the *blocking semantic* of the HARD-GATE. Fixes target the firing-rate / UX / scope-declaration layer; the gate-fire logic at `pre-tool-use` lines 232-240 stays untouched. VS-03 + VS-05 prove blocking is what produces correctness — non-blocking warnings would erode the discipline that catches BC-9-vs-BC-2 misroutes.

---

## Layer 1: Detection — five post-execution amendments

Five mechanisms, all amendments to existing agent prompts and skill bodies. No new agent.

| # | Mechanism | Target | Triggers DONE_WITH_CONCERNS when |
|---|---|---|---|
| **D1** | Builder empty-diff gate (verb-conditional + scope-declared) | `agents/builder.md` | Dispatch declared `scope: code` AND verb in {implement, build, fix, refactor, migrate} AND `git diff --name-only -- <declared_scope>` empty |
| **D2** | Real-user smoke step for BC-3/P2 / pointer-capture / IME / drag-drop classes | `skills/browser-driven-verification/SKILL.md` body amendment + `agents/qa.md` Stage 2 rule | Plan touches state-setter with closure-read OR drag/IME/pointer-capture surface; require either (a) human manual smoke OR (b) architecture-level race-immunity proof |
| **D3** | Researcher post-Write file-existence confirmation | `agents/researcher.md` checklist | After every Write tool call, confirm file exists via Read or Glob before claiming DONE |
| **D4** | Debugger instrumentation gate | `agents/debugger.md` checklist | Before DONE: confirm at least ONE of (console output captured from reproduction, failing test saved to disk, code path instrumented with probe logs). All-reading-no-instrument diagnosis tagged DONE_WITH_CONCERNS |
| **D5** | QA empty-diff auto-REJECT | `agents/qa.md` Stage 1 rule | `git diff $BASE_SHA..$HEAD_SHA` empty AND spec requires implementation changes → verdict MUST be REJECT (missing requirements), not no-op DONE |

**STACK-PATTERNS amendment:** add `playwright-detectable: yes/partial/no` column. Existing patterns mapped: P1 (no — static analysis), P2 (partial — synthetic insufficient for race), P3 (yes — console capture works), P4 (no — data layer), P5 (no — file system).

**Citations:** WS1 §Q1-Q4 — Playwright Actionability docs, Issue #38370 (drag/pointer), Issue #5777 (IME), DEV.to outcome-based-verification, Anthropic evaluator-optimizer.

---

## Layer 2: Adaptation — session-state model + sub-agent inheritance + fast-path

### A1 — `docs/cycle-state.md` open-cycle marker

When `cycle-selection` opens a cycle, write a marker to `docs/cycle-state.md` containing: `{cycle_name, tier, matched_trigger, opened_at, status: open}`. The `tier-selection` skill reads this marker on invocation: if an open cycle exists with matching tier, return a 5-line summary (verdict + matched trigger + cycle_id) instead of re-printing the 80-line skill body. Cycle closes via explicit user signal ("done", "ship it", "next task") OR task-shape verb in NEW human turn that doesn't fit current cycle scope.

**Cooperating skills:** `tier-selection`, `triage`, `writing-plans`, `cycle-selection`. Each reads `cycle-state.md` to decide whether to fire OR return a same-cycle summary.

### A2 — `user-prompt-submit` hook: ignore system-reminder events; task-shape verb gate

Modify `hooks/user-prompt-submit`:
- Detect `<system-reminder>` events (TodoWrite reminder, deferred-tool announcements, etc.) → SKIP `last_user_prompt_at` write entirely.
- Detect human-turn content with task-shape verb regex (`fix|build|add|refactor|implement|debug|investigate|design|create`) → write timestamp.
- Otherwise (continuation/clarification turns) → SKIP write.

Both checks are deterministic regex; neither is LLM-self-attested (per WS4 FM-12 anti-pattern guard).

### A3 — Sub-agent tier verdict inheritance

Modify the dispatch-prompt template across `cto-mode` Step 3 + `subagent-driven-development` + `dispatching-parallel-agents`:

```
Tier: {N} (matched trigger: {trigger_text}; cycle_id: {cycle_state_id})
Scope: code | verdict | analysis | docs
```

Sub-agents (Builder, Researcher, Debugger, QA) receive these fields as explicit input. Their preamble checklist is amended:
- REMOVE: "invoke tier-selection skill"
- ADD: "Confirm dispatch tier matches your reading of the task; if inconsistent, return NEEDS_CONTEXT before touching files"

Citations: 4/4 BINDING (OpenAI Agents SDK, LangGraph, AutoGen, Anthropic multi-agent). All four orchestrator-vs-worker frameworks classify once; workers receive classification, do not re-derive.

### A4 — `writing-plans` remediation fast-path (default-deny)

New section in `skills/writing-plans/SKILL.md`:

```markdown
## Remediation Fast-Path (default DENY; explicit allow required)

A plan doc is required UNLESS ALL of the following are explicitly true:
- LOC < 30
- File count < 3
- Root cause documented in an existing handover (cite path)
- ALL 8 Tier 3 triggers explicitly answered FALSE (no schema, no realtime, no cache strategy, no cross-query writes, no state reconciliation, no multi-tenant boundary, no auth/authz, no new module)
- File paths match a CONFIG.yaml-declared `fast_path_allowlist` glob

If ANY of these is "unsure" or "I think no" — fast-path is REFUSED. Default-deny.

When fast-path triggers: CTO writes a ≤25-line brief directly to Builder. Plan doc is implicit in the original handover + the brief.

Escalation: if any Tier 3 trigger flips to TRUE mid-execution, immediately abort fast-path and produce a full plan doc. Builder reports NEEDS_CONTEXT in this case.
```

WS4 FM-14 binding constraint: the 8-trigger test is the gate, not the LOC count. LOC is necessary but not sufficient.

---

## Layer 3: Recovery — per-tool prose + audit-log schema extension

### R1 — Per-tool "Common Recovery" sections in 4 skill bodies

Add `## Common Recovery` section to:

| Skill | MCP server | Failure modes documented |
|---|---|---|
| `browser-driven-verification` | Playwright | Lock (PID kill + delete lockfile + `--isolated` + MCP restart as first-line); corrupted install (MCP restart only); container `--isolated` namespace error |
| `rls-aware-migrations` | Supabase | Auth/scope mismatch (disconnect + re-authorize); migration conflict (lock_timeout + serialize); advisor staleness (re-call before acting) |
| `finishing-a-development-branch` | GitHub | Token expiry (pre-emptive refresh; long-lived PAT interim); scope mismatch (GitHub App permissions UI fix); rate limit (jitter + honor X-RateLimit-Reset) |
| `enterprise-research-first` | Context7 | Rate limit (backoff + WebSearch fallback); tool-resolution -32602 (call list_tools first); connection drop -32000 (`/mcp reload`; WebFetch fallback) |

Format per skill: table with columns `Symptom | Error class | Recovery path | Escalation if recovery fails`.

### R2 — `trigger-audit.jsonl` schema extension

Extend `hooks/pre-tool-use` `log_invocation` function to also write MCP tool errors. New event type `mcp_tool_error`:

```jsonl
{
  "timestamp": "ISO-8601 UTC",
  "event": "mcp_tool_error",
  "mcp_server": "playwright | supabase | github | context7 | vercel | notion",
  "tool_name": "browser_navigate | apply_migration | ...",
  "error_class": "transport | auth | lock | rate_limit | tool_resolution | unknown",
  "error_message": "verbatim error string",
  "is_error_flag": true,
  "retry_count": 0,
  "recovered": false,
  "recovery_action": "mcp_restart | token_refresh | backoff_retry | manual | none",
  "session_id": "from session.json session_started_at",
  "skill_context": "browser-driven-verification | rls-aware-migrations | ..."
}
```

Existing narrow `{timestamp, event, name}` entries coexist with the extended error entries (different `event` values).

Post-Mortem agent prompt amended: "scan trigger-audit.jsonl for `event = mcp_tool_error`; group by `mcp_server + error_class`; flag any triple appearing ≥3 times across sessions for promotion to STACK-PATTERNS."

### R3 — Deferred (FD-02 dependency)

PostSessionStart MCP-ping hook deferred until `CONFIG.yaml mcp_plugins` slot is resolved (FD-02). Per-tool prose covers 10/12 failure modes; ping covers only the remaining 2 (transport class). ROI for the slot+hook is low until project survey is done.

---

## Layer 4: F-V13 production fix — Windows path-separator bug

`hooks/pre-tool-use` line 191 case-statement currently:

```bash
case "${FILE_PATH}" in
  */.framework-state/*|*/docs/*|*/.claude-plugin/*) allow ;;
esac
```

This never matches Windows backslash paths (`c:\...\docs\...`). The intended docs/ auto-allow has been silently broken on Windows since v2.0.0.

Fix: normalize file_path before case match:

```bash
FILE_PATH_NORM="${FILE_PATH//\\//}"
case "${FILE_PATH_NORM}" in
  */.framework-state/*|*/docs/*|*/.claude-plugin/*) allow ;;
esac
```

This is a 2-line shipped-bug fix. Ships in v2.2.0 alongside the bigger layer changes; could also ship as 2.1.1 patch independently if v2.2.0 work stretches.

---

## Layer 5: Measurement — eval set + metrics + cadence

### M1 — Friction eval (derived from live trigger-audit.jsonl)

Add `evals/friction/repeat-invoke.jsonl`. No golden dataset; derived from session log. Group skill events per prompt boundary; pass = `invocation_count == 1` for ≥95% of cycles. Tracks F-V9 fix effectiveness.

### M2 — Trigger fidelity eval (10-50 cases per skill)

Format already in `evals/triggering/tier-selection.json`: `{id, should_trigger, prompt}`. Extend to per-skill files for `cycle-selection`, `triage`, `cto-mode` (which the WS4 cache-poisoning analysis specifically calls out as test surface).

### M3 — Strength preservation eval (per WS4)

Four eval sets, one per identified failure mode:
- **FM-12 cache poisoning** — 12 prompts × 4 attack classes; verify gate fires correctly under all
- **FM-13 false-positive trust** — 4 false-positive variants of empty-diff; longitudinal <10% FP rate
- **FM-14 fast-path leakage** — 8 prompts (1 per Tier 3 trigger phrased as small-LOC fix); ALL 8 must escalate to full plan
- **FM-15 VS-03 replication** — 5 sessions of normal use; track block-count ≥2, verdict-correctness 100%, bypass-rate ≤1

### M4 — PROJECT-PLAN metrics tracking (incremental)

Best-effort collectible from existing trigger-audit.jsonl + bypass-log.jsonl + git log:
- `repeat_skill_invocation_rate`
- `skills_per_prompt_p50_p95`
- `bypass_rate_per_rule`
- `bypass_all_rate`
- `LOC_per_plan` (git log)

Need minor additions (1-line each):
- `hard_gate_deny_count` (pre-tool-use)
- `time_per_task_minutes` (task_start/done events)
- `citation_density_per_plan` (frontmatter field in plan template)

### M5 — Analysis cadence

Post-Mortem agent owner. Two-window pattern (Datadog burn-rate analogue):
- **Short window (per-session):** if `skills_per_prompt > 3` → flag acute over-trigger
- **Long window (weekly):** if any metric trends >20% over 4 weeks → flag drift

Collection fully automated via v2.0.3 hooks. Zero new infrastructure for M5.

---

## Strength preservation tests

For every layer change above, the WS4 adversarial test must pass:

| Layer | Test | Pass criterion |
|---|---|---|
| A1 cycle-state.md | Cache-poisoning eval (12 prompts × 4 attack classes) | Gate fires correctly under all attacks; no scenario reduces deny-count below VS-03 baseline |
| A2 user-prompt-submit | Task-shape verb regex eval (50 prompts: 25 task-shape, 25 conversational) | ≥95% precision + ≥95% recall on the regex |
| A3 sub-agent inheritance | Builder receives `Tier: 2 (...)` line; F-V10 counterfactual replay | Builder NEEDS_CONTEXT-rate stays under 5% on dispatches with valid inheritance |
| A4 writing-plans fast-path | 8-trigger leakage eval | ALL 8 Tier 3-disguised-as-small-fix prompts escalate to full plan |
| D1 Builder empty-diff | 4 false-positive variants (analysis verdict, docs-only, no-change-needed, scope-met-by-prior-commit) | <10% false-positive rate longitudinal |
| F-V13 path normalization | Windows + macOS + Linux file_path test cases | docs/ auto-allow fires on all 3 platforms |

Skill changes that override SP-precedent skills require **double evidence** per CLAUDE.md (adversarial pressure tests showing PF version performs ≥ SP version on same prompts).

---

## Implementation order

Priority by ROI × inverse-risk:

1. **F-V13 path-normalization fix** (1 hour, 2-line change). Zero risk. Unblocks Windows-user friction loop immediately.
2. **D1 Builder empty-diff gate** (1 day). Highest empirical signal (F-V10 silent failure mode).
3. **D2 Real-user smoke for BC-3/P2 in browser-driven-verification + QA Stage 2** (1 day). Highest empirical signal (F-V11 shipped-bug-with-green-suite).
4. **A2 user-prompt-submit hook fix** (1 day, 2-line change). Closes F-V9 friction; immediately reduces ceremony tax.
5. **A1 cycle-state.md marker + 4 skill cooperation reads** (3-5 days). Larger surface; requires skill-body changes across 4 skills.
6. **A3 sub-agent tier inheritance + Builder preamble strip** (2-3 days). Touches 4 agent prompts.
7. **A4 writing-plans fast-path with 8-trigger test** (2 days). Includes the adversarial leakage eval.
8. **R1 Common Recovery sections in 4 skills** (1-2 days). Lower urgency than detection layer.
9. **D3, D4, D5** (2-3 days collectively). Researcher / Debugger / QA preamble additions.
10. **R2 trigger-audit.jsonl schema extension + Post-Mortem mining** (3-5 days). Foundation for measurement layer.
11. **M1-M5 measurement infrastructure** (1 week). Ships once Layer 2 + Layer 3 land so we can measure their impact.

Total estimate: ~5 weeks for full v2.2.0 layer. F-V13 + D1 + D2 + A2 (top 4) ship in 1 week as a **v2.1.1 production fix patch** since they address active empirical friction.

---

## Consequences

### Positive

- Detection layer closes the silent-DONE failure class across all 5 agents.
- Adaptation layer reduces ceremony tax by ~70% on continuation turns (F-V9 measured at ~$0.01 + 20-40s/session waste; cycle-state.md marker eliminates the redundant invocations).
- Recovery layer makes MCP failures self-documented + minable.
- F-V13 production fix unblocks Windows users immediately.
- Strength preservation tests give us before/after evidence per CLAUDE.md "Skill Changes Require Evaluation" rule.

### Negative

- 5 weeks of plugin work without new feature shipping. Internal-tooling investment.
- `cycle-state.md` introduces shared mutable state — needs careful schema definition + migration story for existing projects.
- Sub-agent inheritance changes the dispatch contract — old sub-agent invocations from in-flight sessions may not have the new fields. Needs backward-compat fallback (re-invoke tier-selection if dispatch metadata missing).
- Eval infrastructure (M1-M5) is new framework territory; first iteration likely has rough edges.

### Mitigations

- v2.1.1 production fix path (top 4 fixes) ships in 1 week so users see immediate benefit before the larger layer lands.
- `cycle-state.md` schema published in this ADR; migration is "create file, write {status: idle} as default."
- Sub-agent backward-compat: new dispatch metadata is OPTIONAL in v2.2.0; missing → fall back to in-agent tier-selection (current behavior). v2.3.0 makes it mandatory after one version of soak.
- Eval infrastructure: ship M1 (friction eval from live data) first since it's zero-infrastructure; M2-M5 ship incrementally.

---

## Future Decisions deferred (carried forward)

- **FD-01** (Automatic Playwright invocation on UI cycles) — still parked. v2.2.0 D2 amendment partially addresses by requiring real-user smoke for BC-3/P2 class; FD-01 broader auto-invocation still pending Taskforge UI cycle data.
- **FD-02** (MCP plugin compatibility surface) — still parked. R3 deferred PostSessionStart ping until this resolves.

---

## References

- Reconciliation report: `docs/reconciliation/v2-2-research-2026-04-30.md`
- Research inputs: `docs/research/v2-2-{detection,adaptation,recovery,strength-preservation,measurement}-2026-04-30.md`
- Findings: `docs/PROJECT-PLAN.md` Open Findings F-V8 → F-V13 + Validated Discipline VS-01 → VS-05
- Future decisions: `docs/PROJECT-PLAN.md` FD-01 + FD-02
- ADR-002 (D-A hook gating) — the prevention layer this ADR adds detection/adaptation/recovery on top of
- ADR-003 (Broadened pattern ingest) — the citation discipline that produced the WS-1..5 research

---

## Self-Review

- **Citation present:** every layer change cites either SP precedent (none new), Anthropic guidance (Anthropic evaluator-optimizer for D1-D5; Anthropic multi-agent for A3), or N≥3 enterprise/OSS (4/4 for A3; 3/3 K8s analogues for R1; 5/6 BINDING for D2 real-input gap).
- **No third-party runtime dependencies:** all changes are skill-body / agent-prompt / hook-script edits in bash + markdown.
- **HARD-GATE markers explicit:** A4 fast-path uses default-deny; D1 empty-diff is verb+scope-conditional; preserved on all paths.
- **No bulk PRs:** layer changes split per file at implementation time. Implementation order section gives the sequencing.
- **Frontmatter discipline:** new skill-body amendments will follow action-oriented imperative form.
- **No speculative fixes:** every change traces to either an empirical F-V finding or a strength-preservation test from WS4.
- **Adversarial framing preserved:** WS4's binding constraint (don't convert qualitative judgment into LLM-self-attested gates) is enforced across all four layers.
