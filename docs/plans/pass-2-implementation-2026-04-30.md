# Pass 2 Implementation Plan — Production-Framework v2.0.0

**Date:** 2026-04-30
**Goal:** Land everything from the v1-feedback audit (Phase 5) and the Phase 6 research waves (Wave 1 + 1.5 + 2 + 3) into shipped v2 artifacts. End-state = v2.0.0 ready for Phase E5 verification.
**Scope:** ~15 skill writes + ~9 existing-artifact amendments + 1 hook bundle + 4 v1-carryforward primitive ports + 1 STACK-PATTERNS extension + manifest/ADR updates + 1 eval run.
**Architecture:** Decision-independent work first (Workstreams A + G — ship continuously), then decision-gated work in dependency order (B → D → C → E), with Workstream F slotting in as Wave 3 lands.

---

## Workstream Summary

| Workstream | Goal | Decision dependency | Wave-3 dependency | Effort |
|---|---|---|---|---|
| **A. Foundation amendments** | 9 small targeted edits to shipped artifacts (debugger.md, architect.md, ER1, 7VQ Q3, gate-3 console-errors dim, post-mortem.md ADR-001 reference, ADR-001 G3 update, manifest GAP updates) | None | None | ~3-4h |
| **B. Wave-1-derived NEW skill writes** | 6 new skills shipped: browser-driven-verification, incident-response, parallel-reconciliation, find-similar-implementations, implementation-decision-log, fix-time-hash-check (advisory) | D-D (mostly autodecided by audit) | None | ~6-8h |
| **C. D-A hook bundle** | 1 ADR (002-hook-gating.md) + `hooks/pre-tool-use.sh` + `.framework-state/` scaffolding + 5 hook gates (tier-selection, destructive-ops, phase-break, critical-blocks-next-phase, dep-add) | **D-A user decision** | None | ~6-10h |
| **D. v1 carryforward port** | 4 primitives ported: `compute-root-cause-hash.sh`, `structural-check.sh:check_incident_logged`, `proposing-patterns` skill, `ratify-pattern` skill + UN-DEFER from v2.1 → v2.0.x | **D-E user decision** (research strongly recommends UN-DEFER) | None | ~5-7h |
| **E. D-B verification override eval** | Run R-F's 3-corpora 15-test-case eval; write override clause to `verification-before-completion`; document eval results | **D-B user decision** + eval-pass gate | None | ~4-6h |
| **F. STACK-PATTERNS extensions** | Apply Wave-3 stack stubs (Next.js / React / Postgres / Supabase / env-separation) into `templates/STACK-PATTERNS.template.md` Code-Reviewer pre-flight greps | None | **Wave 3 stack-patterns research** | ~2-3h |
| **G. Manifest + ADR updates** | `sp-anthropic-citation-manifest.md` GAP-1/2/3 updates + `docs/adr/001-7-gap-decisions.md` G3 un-defer + new `docs/adr/003-broadened-pattern-ingest.md` (proposing-patterns dual-path) | None | None | ~2-3h |
| **H. Wave-3-derived skills** | `writing-handover` skill + triage v2 (port-vs-extend decision, then write/edit) | None | **Wave 3 writing-handover + triage research** | ~4-6h |
| **I. Originally-planned wave-2 skills** | 5 skills written from existing research: `regression-scope`, `rls-aware-migrations`, `tenant-isolation`, `audit-trail`, `slo-sli-contracts` | None | None | ~6-8h |

**Total estimated effort:** ~38-55 person-hours (a few days of focused work).

---

## Workstream A — Foundation amendments (decision-independent; ship first)

### Goal

Land the small, low-risk edits to already-shipped v2 artifacts using already-cited research. No new architectural decisions; no new research. These can happen continuously alongside other workstreams.

### Deliverables

| # | File | Change | Research source |
|---|---|---|---|
| A1 | `agents/debugger.md` | Add 3 rules: (a) user-language-as-ground-truth (user's verb constrains the search frontier, not the prompt's first hypothesis); (b) widen-before-narrow (enumerate paths in Phase 1 before narrowing to a hypothesis in Phase 3); (c) Phase 4.5 bug-class enterprise check (name the bug-class; if BC has ≥3 enterprise solutions, dispatch ER1 in parallel) | `bug-class-taxonomy-2026-04-30.md` R-2 + R-3 |
| A2 | `agents/architect.md` | Add 2 sections: (a) Schema-existence probe step (every named entity verified against `information_schema.tables` or equivalent — output evidence); (b) Client-shape naming requirement (per row of Multi-tenant isolation table — name auth model + name client shape that activates it: user-scoped JWT vs service-role+manual-filter vs RPC-with-explicit-p_user_id) | Audit Items 1 + 9; existing AWS SaaS Lens + OWASP citations |
| A3 | `skills/enterprise-research-first/SKILL.md` | Extend "When to Use" with bug-class triggers per BC-1–BC-10 from R-E (closure-staleness / cache-invalidation / race / hydration / optimistic-rollback / IDOR-BOLA / N+1 / deadlock / spec-divergence / state-machine) | `bug-class-taxonomy-2026-04-30.md` R-1 |
| A4 | `skills/seven-validation-questions/SKILL.md` | Strengthen Q3 (Invariants) — add explicit requirement: "for tenant-scoped resources, name the auth model AND name the client shape that activates it; cite STACK-PATTERNS multi-tenant grep #4" | Audit Item 9 |
| A5 | `skills/gate-3-production-check/SKILL.md` | Add D-X dimension: console-errors clean on routes touched by ship (Playwright `browser_console_messages` empty) | `skill-design-browser-driven-verification.md` R-5 + Audit Item 12 |
| A6 | `agents/post-mortem.md` | Remove the "deferred to v2.1" note for proposing-patterns/ratify-pattern carryforward (line 124); reference the un-defer rationale | `skill-design-proposing-patterns.md` R-3 |
| A7 | `docs/adr/001-7-gap-decisions.md` | Update G3 row from DEFER-to-v2.1 to UN-DEFERRED-as-of-2026-04-30 with rationale citing Item 41 evidence + R-3 | Same |
| A8 | `docs/research/sp-anthropic-citation-manifest.md` | Three updates: GAP-1 add 9/9 enterprise consensus; GAP-2 add 17 enterprise sources + 18 dimensions K/N; GAP-3 add 9/11 enterprise grounding for proposing-patterns components | `skill-design-{enterprise-research-first, gate-3-production-check, proposing-patterns}.md` |
| A9 | `agents/qa.md` | Add stack-conditional reasoning hooks (e.g., "for React state-setter `setX(prev => …)` callbacks, check whether code on subsequent lines reads variables mutated inside the updater — flag as defect") | Audit Item 11; canonical react.dev cites (Wave 3 will harden these) |

### Sequencing

A1, A2, A3, A4 can run in parallel (independent files). A5, A6, A7, A8 serially (manifest updates touch overlapping content). A9 last (depends on Wave 3 React citations for full grounding).

### Acceptance criteria

- All shipped v2 artifacts pass `post-write-md-lint.sh` hook (4 required body sections present where applicable).
- No `RULE(prompt)` rule promoted without grounded amendment text.
- Manifest GAP entries each cite the specific research artifact that closed them.

---

## Workstream B — Wave-1-derived NEW skill writes (D-D bundle)

### Goal

Ship the 6 new skills surfaced by the v1-feedback audit, each grounded in its Wave-1 research artifact.

### Deliverables

For each skill: directory `skills/<name>/` + `SKILL.md` + (where applicable) supporting files (e.g., template files, helper docs).

| # | Skill | Length target | Source | Status implication |
|---|---|---|---|---|
| B1 | `skills/browser-driven-verification/SKILL.md` | ~250-300L | `skill-design-browser-driven-verification.md` (327L research) | Closes C7; new Gate-3 dim already in A5 |
| B2 | `skills/incident-response/SKILL.md` | ~250-300L | `skill-design-incident-response.md` (320L) | Closes C9; 5-phase spine + rollback-as-first-Contain HARD-GATE + live-timeline artifact |
| B3 | `skills/parallel-reconciliation/SKILL.md` | ~200-280L | `skill-design-parallel-reconciliation.md` (272L) | Closes C8; **NEW STANDALONE** per research verdict; verdict-precedence ladder + HARD-GATE |
| B4 | `skills/find-similar-implementations/SKILL.md` | ~250-300L | `skill-design-find-similar-implementations.md` (352L) | Closes C5; HARD-GATE before `writing-plans` for new helpers; 4-step methodology |
| B5 | `skills/implementation-decision-log/SKILL.md` | ~180-250L | `skill-design-implementation-decision-log.md` (~290L) | Closes C5; explicitly NON-HARD-GATE; Microsoft Engineering Playbook 1:1 schema |
| B6 | `skills/fix-time-hash-check/SKILL.md` | ~50-80L | `skill-design-fix-time-hash-check.md` (278L) | **Advisory** (DONE/NEEDS_CONTEXT, never blocking); pairs with D-A PostToolUse hook in Workstream C |

### Sequencing

Independent files; run in parallel. None depend on D-A / D-B / D-E (all are D-D members which the audit recommends ship). B6 depends on D-E port (Workstream D — needs `compute-root-cause-hash.sh` available) but the skill body can be written in advance with the script-call placeholder.

### Acceptance criteria

- Each skill body cites ≥1 SP precedent + ≥1 Anthropic guidance + ≥3 enterprise/OSS sources from the research artifact.
- HARD-GATE markers present where research recommends (B1 / B2 / B3 / B4); explicitly NON-HARD-GATE where research recommends (B5 / B6).
- Composability footers list cross-links per the research recommendations.
- `post-write-md-lint.sh` passes (4 required body sections).

---

## Workstream C — D-A hook bundle (architectural)

### Goal

Per R-A's Option C recommendation: ship 5 PreToolUse hook gates in v2.0 with full ADR. Resolves Cluster C1 (13 audit items + 1 from C5 sub-fix).

### Decision dependency

**D-A user decision required.** Research strongly recommends Option C. CLAUDE.md rejection-criterion #5 satisfied by R-A's grounding (5/5 enterprise consensus on multiple heuristics + SP precedent in `polyglot-hooks.md` + Anthropic `permissionDecision: "deny"` semantics).

### Deliverables

| # | File | Content |
|---|---|---|
| C1 | `docs/adr/002-hook-gating.md` | Formal ADR from R-A draft. MADR shape. Records: scoped 5-gate v2.0 ship; 3 deferred to v2.1; 2 discipline-only. Per-rule rationale per row. |
| C2 | `hooks/pre-tool-use.sh` | Bash hook script. Reads `.framework-state/session.json` for last-tier-selection-invocation-time. Emits `permissionDecision: "deny"` JSON if (matcher matches) AND (rule prerequisite missing) AND (not bypassed). |
| C3 | `hooks/run-hook.cmd` | Polyglot wrapper update if needed (check existing) |
| C4 | `hooks/hooks.json` | Add new entry: `{"matcher": "Edit\|Write\|Bash", "type": "pre-tool-use", "command": "hooks/pre-tool-use.sh"}` |
| C5 | `.framework-state/.gitkeep` + `.framework-state/.gitignore` | Scaffolding for session-state files (session.json + bypass-log.jsonl + destructive-allowlist all .gitignored) |
| C6 | `scripts/framework-state-init.sh` | Helper script that creates fresh `.framework-state/session.json` on SessionStart (called from existing `hooks/session-start.sh`) |
| C7 | `hooks/session-start.sh` (amend) | Add line invoking C6 on every session start |
| C8 | `.claude-plugin/plugin.json` | Bump version to 2.0.0; document the new hook contract per CLAUDE.md "MAJOR version bump for new hook" rule |
| C9 | `tests/hooks/pre-tool-use/` | At minimum 5 test fixtures — one per gate — verifying block-on-missing-prereq + bypass-on-env-var-set |
| C10 | `RELEASE-NOTES.md` | New section documenting the hook contract, the 5 gates, the bypass grammar, and the post-mortem-mining of `bypass-log.jsonl` |

### Three-tier bypass grammar (per R-A)

```
PF_BYPASS=<rule-id>           # per-rule; one tool call only
PF_BYPASS_ALL=1               # session-wide; requires PF_BYPASS_REASON
.framework-state/PF_GATES_DISABLED  # project-wide kill switch (file)
```

All bypasses logged append-only to `.framework-state/bypass-log.jsonl` with: timestamp, rule-id, reason (if PF_BYPASS_ALL), the tool call payload. Post-Mortem agent mines this log for repeat-bypass patterns.

### Sequencing

C1 first (ADR is the spec for everything else). C2 + C5 + C6 can parallelize. C4 + C7 + C8 serially after the script + scaffolding land. C9 last (tests against the working hook). C10 last (release notes are the wrap-up).

### Acceptance criteria

- ADR-002 reviewed and approved by user.
- 5/5 hook gates functional in test fixtures.
- Each bypass tier produces a `bypass-log.jsonl` row with all required fields.
- `pre-tool-use.sh` returns `permissionDecision: "deny"` JSON (not exit-code-2 — per R-A research on CC bugs #13744/#36071/#40580).
- No regression: existing `Bash` `pre-commit-structural.sh` hook still fires; existing `stop-debug-scan.sh` still fires.
- Phase 8 verification: launch a fresh CC session, attempt `Edit` without `tier-selection` invocation, verify block.

---

## Workstream D — v1 carryforward port (D-E)

### Goal

Per `skill-design-proposing-patterns.md` R-3 + Item 41 STRENGTH evidence: UN-DEFER from v2.1 to v2.0.x. Port 4 primitives.

### Decision dependency

**D-E user decision required.** Research strongly recommends UN-DEFER (overrides ADR-001 G3's earlier defer; rationale documented in R-3 of proposing-patterns research).

### Deliverables

| # | File | Content |
|---|---|---|
| D1 | `scripts/compute-root-cause-hash.sh` | Verbatim port from PF v1; preserve HASH_VERSION=1; 7-rule normalization grammar (verified verbatim against Rollbar + Datadog by R-11). Surface version line in output (Sentry/Bugsnag versioning precedent). |
| D2 | `scripts/structural-check.sh` (partial) | Port `check_incident_logged` function only — the Rule #43 MACHINE enforcement. Other PF v1 structural checks NOT ported (out of scope for v2.0). |
| D3 | `skills/proposing-patterns/SKILL.md` | New skill body, ~250-350L. Carry v1 5-step methodology verbatim. **Add Step 0 (source detection)** + **Step 3a/3b dual-path branch** (Path A = ≥3 distinct hashes (v1); Path B = BINDING research + use-case-fit check passed). G2 refactors to G2A (incidents) OR G2B (research). STRAWMAN prefix discipline binds both paths. |
| D4 | `skills/ratify-pattern/SKILL.md` | New skill body, ~250-300L. Port v1's 6 mechanical gates. Add explicitly-PF-original failure-mode rationales for G1 (≤20-row bloat cap; parameterize cap in Stack Config) + G2 (duplicate-incident hash). Strengthen G5 with idempotency + clean-branch test (K8s graduation alignment). **Add `postpone` as 4th Stage-3 disposition** (Rust RFC FCP-aligned). |
| D5 | `templates/pattern-proposal.template.md` | Port from PF v1. Add Path-B (BINDING research) section to the template per R-1's dual-path branch. |
| D6 | `templates/revert-pattern.template.sh` | Port from PF v1. Add idempotency + clean-branch test requirements per R-2. |
| D7 | `docs/adr/003-broadened-pattern-ingest.md` | New ADR formalizing the dual-path ingest (incidents OR BINDING research). MADR shape. References R-1, R-3 of proposing-patterns research. |
| D8 | `agents/post-mortem.md` (amend) | Update invocation triggers: now invokes proposing-patterns on (≥3 incidents) OR (orchestrator hands off a BINDING research finding). |

### Sequencing

D1 + D2 first (scripts; foundational). D3 + D4 in parallel (depend on D1 for hash references). D5 + D6 in parallel after D3/D4. D7 + D8 last (ADR + agent reference updates).

### Acceptance criteria

- `compute-root-cause-hash.sh` determinism test passes (port v1's test).
- Both paths (A: incidents, B: BINDING research) tested with fixtures.
- All 6 ratification gates fire as expected with `postpone` available as Stage-3 disposition.
- Phase 8 smoke-test: dispatch a synthetic post-mortem cycle producing 3 incidents → triggers proposing-patterns Path A → user-gated ratify-pattern → pattern lands in STACK-PATTERNS.

---

## Workstream E — D-B verification override eval

### Goal

Run R-F's 3-corpora 15-test-case eval. If it passes, ship the override clause to `skills/verification-before-completion/SKILL.md`. If not, document why and defer.

### Decision dependency

**D-B user decision required.** Per CLAUDE.md "Skill Changes Require Evaluation" — overriding SP-inherited skill needs double-evidence eval first.

### Deliverables

| # | File | Content |
|---|---|---|
| E1 | `evals/verification-root-cause/corpus-A.json` | 5 cases where root-cause-fix and symptom-mask both pass SP — only PF should catch the mask |
| E2 | `evals/verification-root-cause/corpus-B.json` | 5 regression-guard cases — both SP and PF must pass (no false positives from PF override) |
| E3 | `evals/verification-root-cause/corpus-C.json` | 5 adversarial cases — direct SP-vs-PF comparison; PF tighter on 1-2, equal on rest |
| E4 | `evals/verification-root-cause/run.sh` | Test harness: run prompts twice — once with SP body, once with PF override body. Compare verdicts. Adversarial session adds rationalization-encouragement priming. |
| E5 | `evals/verification-root-cause/results-2026-XX-XX.md` | Test results: PF must catch all Corpus A; no Corpus B regressions; Corpus C tighter-or-equal. Pass/fail verdict. |
| E6 (conditional on E5 pass) | `skills/verification-before-completion/SKILL.md` (PF override) | New body with the H-1/H-2/H-6 distinguishing heuristics + root-cause-fix clause: "For bug fixes, fresh evidence MUST demonstrate (a) symptom no longer reproduces AND (b) the root cause as identified by `systematic-debugging` data-flow trace is no longer reachable" |

### Sequencing

E1-E4 in parallel (test corpus build). E5 after corpus runs. E6 conditional on E5 pass.

### Acceptance criteria

- E5 pass criteria: Corpus A all 5 caught by PF (not by SP); Corpus B 0 false positives; Corpus C ≥1 PF-tighter case.
- Eval doc explicitly cites CLAUDE.md double-evidence rule + R-F's design.
- If pass: E6 lands. If fail: defer D-B; document why.

---

## Workstream F — STACK-PATTERNS extensions (Wave-3 dependent)

### Goal

Land Wave-3 stack stubs into `templates/STACK-PATTERNS.template.md` example-stub sections. Resolves Cluster C4.

### Wave-3 dependency

`skill-design-stack-patterns-extensions-2026-04-30.md` (Sonnet, in-flight) provides the 5 patterns + grep + canonical fix + ≥3 enterprise citations each.

### Deliverables

| # | File | Content |
|---|---|---|
| F1 | `templates/STACK-PATTERNS.template.md` (amend) | Replace `<!-- EXAMPLE -->` stubs in: Postgres+RLS subsection (add service-role bypass row); Code-Review Pre-Flight Greps (add 5 stack-specific patterns); Stack-specific anti-patterns table; per-stack security primitives section |
| F2 | `agents/qa.md` (amend, depends on Wave 3 React grep patterns) | Workstream A's A9 amendment — landed once Wave 3 hardens the React state-setter cite list |

### Acceptance criteria

- Each pattern in F1 has ≥3 citations from research.
- Item 10 (Next.js client/server boundary) cite list explicitly references the 3rd-recurrence framing.
- Code-Reviewer pre-flight grep table grew from 7 rows (current) to 12 rows (5 new).

---

## Workstream G — Manifest + ADR updates

(Already covered in Workstream A items A6/A7/A8 + Workstream D item D7. Tracked here for explicit visibility.)

| File | Update |
|---|---|
| `docs/research/sp-anthropic-citation-manifest.md` | A8 — three GAP updates |
| `docs/adr/001-7-gap-decisions.md` | A7 — G3 un-defer |
| `docs/adr/002-hook-gating.md` | C1 — new ADR |
| `docs/adr/003-broadened-pattern-ingest.md` | D7 — new ADR |
| `RELEASE-NOTES.md` | C10 — hook contract changes; D-E un-defer; eval results from E5 |

---

## Workstream H — Wave-3-derived skills

### Wave-3 dependency

- `skill-design-writing-handover.md` (Sonnet, in-flight) — cadence decision
- `skill-design-triage-v2-shape.md` (Sonnet, in-flight) — port-vs-extend-vs-new structural verdict

### Deliverables

| # | File | Content |
|---|---|---|
| H1 | `skills/writing-handover/SKILL.md` | Body grounded in research; cadence per recommended pattern (likely single-rolling-doc with phase-end finalization, conditional-on-flag override). ~200-300L. |
| H2 | depends on triage research verdict | If verdict = port: `skills/triage/SKILL.md` (port from v1 + integration with incident-response + bug-class-taxonomy). If verdict = extend: amend `skills/tier-selection/SKILL.md`. If verdict = new: write fresh skill. ~200-300L. |

### Acceptance criteria

- H1 cadence matches Wave-3 K/N consensus verdict.
- H2 structural decision documented in ADR (new ADR-004) if it changes the skill inventory.

---

## Workstream I — Originally-planned wave-2 skills (compile from existing research)

### Goal

Land 5 skills the audit didn't surface (already in original Phase D wave 2 plan), all writable from existing agent-design / skill-design research without new dispatch.

### Deliverables

| # | Skill | Length | Sources |
|---|---|---|---|
| I1 | `skills/regression-scope/SKILL.md` | ~200-280L | SP `requesting-code-review/SKILL.md` (review-as-regression-detection); `agent-design-qa.md`; Microsoft Test Selection + Google build dependency analysis |
| I2 | `skills/rls-aware-migrations/SKILL.md` | ~250-350L | `agent-design-database-engineer.md` Topics A–D (Postgres §5.9, Supabase RLS guide, gh-ost/pgRoll/pt-osc) — already 99.94% / 94.97% / 99.78% / 99.993% measured fixes |
| I3 | `skills/tenant-isolation/SKILL.md` | ~250-350L | AWS SaaS Lens silo/pool/bridge (DBE research); `agent-design-security-compliance.md` control IDs; STACK-PATTERNS multi-tenant section |
| I4 | `skills/audit-trail/SKILL.md` | ~200-300L | `agent-design-security-compliance.md` NIST AU-2/3/9 + ASVS V7.1.3 + V7.2.1 + V7.2.2 + SOC 2 CC7.2 |
| I5 | `skills/slo-sli-contracts/SKILL.md` | ~250-350L | `agent-design-sre-devops.md` Google SRE Ch. 4 + Workbook Ch. 5 + Honeycomb high-cardinality + DORA Four Keys |

### Acceptance criteria

- Each cites ≥3 enterprise/OSS sources from the existing agent-design research (no new research dispatch needed).
- HARD-GATE markers where the research already specified them in the agent body.

---

## Sequencing — recommended execution order

### Day 1 — Decision-independent + Wave-3 wait

- **Workstream A** (foundation amendments) starts.
- Wave 3 researchers continue running (background).
- **Workstream B** (Wave-1-derived skills) starts in parallel.
- **Workstream G** starts (manifest updates as evidence lands from B).

### Day 2 — Decision-gated work begins

- **D-A user decision lands** → Workstream C (hook bundle) starts.
- **D-E user decision lands** → Workstream D (carryforward port) starts.
- Wave 3 lands → Workstream F (STACK-PATTERNS extension) + Workstream H (writing-handover, triage) start.

### Day 3 — Convergence

- **Workstream E** (D-B eval) runs.
- **Workstream I** (originally-planned skills) starts (compile from existing).
- Workstream A finishes; Workstream B finishes; Workstream C reaches test stage; Workstream D reaches script stage.

### Day 4 — Phase E5 verification

- Phase 8 smoke-test on shipped v2 plugin.
- Final RELEASE-NOTES.md update.

---

## Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| D-A hook breaks existing Edit/Write workflows during gate-test | MEDIUM | HIGH | Land C9 (test fixtures) before C8 (plugin.json bump). Three-tier bypass grammar lets users escape safely. |
| D-B eval Corpus A doesn't cleanly distinguish PF override from SP | MEDIUM | MEDIUM | Defer D-B; document why; reconsider in v2.1 with stronger eval design. Don't ship symptom-mask catch unless eval proves it. |
| Wave 3 STACK-PATTERNS research surfaces more patterns than 5 (scope creep) | LOW | LOW | Prioritize the 5 cited; defer extras to v2.x. |
| `compute-root-cause-hash.sh` hash drift breaks Path A | LOW | HIGH | HASH_VERSION=1 surface in skill output; never auto-update (Sentry/Bugsnag precedent). Migration path documented. |
| D-A `permissionDecision` JSON returns unsupported in CC version users have | LOW | HIGH | R-A research surfaced CC bugs #13744/#36071/#40580; document version-min in plugin.json + RELEASE-NOTES.md. |
| Workstream cycles (B + C + D) take longer than 3-4 days | MEDIUM | LOW | Workstreams are independent; re-prioritize if needed. Workstream A + G ship continuously regardless. |

---

## Success criteria

- All 36 audit items either RESOLVED (with link to resolving artifact) or explicitly DEFERRED (with rationale row) in PROJECT-PLAN.md Open Findings.
- All Phase 6 research artifacts have `Status: IMPLEMENTED in <path>` updates.
- Phase 8 verification passes:
  - SessionStart hook fires (existing).
  - PreToolUse hook fires correctly per D-A bundle (new).
  - cto-mode auto-routes (existing).
  - smoke-test cycle on a fresh non-trivial task ships without manual intervention.
  - bypass-log.jsonl records test bypass attempts during smoke-test.
- v2.0.0 marketplace release.

---

## Citations

- Research artifacts: `docs/research/skill-design-*.md` (11 from Wave 1+1.5+2; 3 in-flight from Wave 3).
- Audit: `docs/audits/v1-feedback-vs-v2-2026-04-30.md`.
- Decisions: `docs/adr/001-7-gap-decisions.md` + (forthcoming) 002-hook-gating.md + 003-broadened-pattern-ingest.md.
- PROJECT-PLAN: `docs/PROJECT-PLAN.md`.
- Binding rule: `CLAUDE.md` THE BINDING RULE + rejection-criterion #5 (no new hook without major version + ADR — satisfied by C1).
