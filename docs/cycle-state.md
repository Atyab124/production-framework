# Cycle State — v2.2.0 consolidated upgrade

**Cycle:** build · **Tier:** 3 · **Matched trigger:** new behavior + multi-feature phase + ≥6 deliverables

Replaces the prior v2.1.1 production fix / v2.2.0 upgrade split. Ships every closable finding as one consolidated v2.2.0 upgrade per release-discipline contract.

## Closing this cycle (in scope)

- F-V7 — Builder dispatch verb ambiguity
- F-V8 — `browser-driven-verification` + 3 other skills get per-tool Common Recovery prose (also covers ADR R1, R3)
- F-V9 sub-fix A2 only — `user-prompt-submit` ignores `<system-reminder>` events (also covers ADR A2)
- F-V10 — Builder silent-DONE empty-diff gate + dispatch-time `scope` declaration (also covers ADR D1)
- F-V13 — Windows path-separator normalization in `pre-tool-use`
- F-V17 — Brownfield onboarding doc
- F-V18 — `dispatching-parallel-agents` foreground / background subsection
- F-V20 — `pre-tool-use` sub-agent tier-selection inheritance
- F-V22 — Resolved by clarifying F-V11's deferred status
- ADR-006 D3 — Researcher post-Write file-existence check
- ADR-006 D4 — Debugger instrumentation gate (profiler mode)
- ADR-006 D5 — QA empty-diff REJECT
- ADR-006 R2 — `trigger-audit.jsonl` schema extended for MCP tool errors
- ADR-006 M1 + M2 — session-derived metrics + project-agnostic measurement script
- Citation manifest — new rows for D1-D5, A2, R1-R3, M1-M2
- Regression test per closed finding (`evals/regression/<finding-id>.json`)
- Version bump — 2.1.0 → 2.2.0 in `plugin.json` + `marketplace.json`
- RELEASE-NOTES.md — v2.2.0 entry

## Deferred this cycle (with reasons)

- F-V9 sub-fix A1 (cycle-state.md cooperating across skills) — WS4 FM-12 cache-poisoning concern unresolved. Needs design before implementation.
- F-V11 (real-input regression in `browser-driven-verification`) — overrides existing skill body lines 110-112, not just adds. Needs decision on what replaces them.
- F-V12 (Tier-2 ceremony fast-path threshold) — needs WS4-aware default-deny + 8-trigger-test specification.
- ADR-006 D2 (real-user smoke for closure-staleness / race classes) — depends on F-V11 design.
- F-V14, F-V15, F-V16 — not implementable as code; need second/third project onboarding (F-V14), team-mode research cycle (F-V15), CI/deploy research cycle (F-V16).
- F-V19 — Builder permission failure reproduction not attempted; depends on F-V20 fix to disambiguate root cause from gate-deny vs tool inheritance.
- F-V21 — Agent-dispatch worktree cwd resolution; likely Claude Code-side issue, not framework-side.
- FD-03 — Reply-shape discipline; design parked explicitly per user.
- ADR-006 M3-M5 — depends on F-V14 cross-project signal.

## Bootstrap deviation (declared)

The Builder sub-agent is in scope of this very release (F-V10, F-V20, F-V21 all touch Builder behavior). Implementation therefore happens in main CTO session via direct Edit/Write — not via Builder dispatch. The first release that ships dogfood-via-Builder-dispatch is v2.2.1+ once the Builder-related fixes have landed and stabilized.

## Dispatch Order

1. CTO main session → docs/cycle-state.md (this file)
2. CTO main session → docs/adr/006-...md (amend scope statement)
3. **writing-plans** skill → docs/plans/v2-2-0-upgrade.md (master plan)
4. CTO main session → implementation across hooks/, agents/, skills/, evals/, docs/
5. **qa** sub-agent → docs/audits/qa-findings-v2-2-0.md (Stage 1 + Stage 2)
6. **code-reviewer** sub-agent (parallel with qa) → docs/audits/code-review-v2-2-0.md
7. **gate-3-production-check** skill → final readiness verdict
8. CTO main session → RELEASE-NOTES.md, version bump, commit + push
9. CTO main session → docs/handovers/v2-2-0.md (release handover)

## Open Handover

[Updated by each step on completion]

- 2026-05-09 — cycle-state.md written; entering ADR amendment + writing-plans
