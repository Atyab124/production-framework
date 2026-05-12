# Production Framework v2.0.0 — Project Plan

**Project:** PF v2 — Claude Code plugin forked from Superpowers 5.0.7. Turns a regular Claude session into a CTO running 12 specialist sub-agents in parallel cycles to build enterprise multi-tenant SaaS.

**Started:** 2026-04-26 (foundation phase). **Plan written:** 2026-04-30. **Maintainer:** v2 designer.

**Binding rule:** every feature cites SP precedent OR Anthropic guidance + ≥3 enterprise/OSS analogs (per `CLAUDE.md` THE BINDING RULE).

---

## Phase Status

| Phase | Status | Gate | Notes |
|---|---|---|---|
| Phase 1 — Foundation (citation manifest + enterprise multi-agent architecture research + ADR-001) | COMPLETE | — | `docs/research/sp-anthropic-citation-manifest.md`, `enterprise-multi-agent-architecture.md`, `docs/adr/001-7-gap-decisions.md` |
| Phase 2 — 12 specialist agents (researched + written + cost-justified model matrix) | COMPLETE | — | 12 agents in `agents/`; per-role research in `docs/research/agent-design-*.md` (12 docs); model matrix 6/6 Opus/Sonnet per `agent-model-assignment.md` |
| Phase 3 — STACK-PATTERNS template | COMPLETE | — | `templates/STACK-PATTERNS.template.md` (330 lines, 11 sections, all sections cited) |
| Phase 4 — Foundational skills (3 skills) | COMPLETE | — | `enterprise-research-first` (207L), `seven-validation-questions` (224L), `gate-3-production-check` (343L). Each grounded in research at `docs/research/skill-design-*.md`. |
| Phase 5 — v1 feedback audit | COMPLETE | — | `docs/audits/v1-feedback-vs-v2-2026-04-30.md` — 36 items audited, 11 clusters, 6 architectural decisions surfaced (D-A through D-F) |
| Phase 6 — Pass 2 research (4 waves: 1 + 1.5 + 2 + 3) | COMPLETE | — | 14 research artifacts; ~3500 lines of cited research |
| Phase 7 — Pass 2 implementation | COMPLETE | — | 9 workstreams shipped: A 9 amendments + B 6 new skills + C hook bundle + D 6 carryforwards + E eval scaffold + F 5 stack patterns + G ADR-002+003+manifest + H 2 wave-3 skills + I 5 originally-planned. Total ~47 files created/edited. |
| Phase 9 — v2.2.0 consolidated upgrade | COMPLETE | gate-3 | Plan: `docs/plans/v2-2-0-upgrade.md`. ADR: `docs/adr/006-v2-2-detection-adaptation-recovery-layer.md`. Closes 9 empirical findings (F-V7, F-V8, F-V9 A2, F-V10, F-V13, F-V17, F-V18, F-V20, F-V22) plus ADR-006 layers D1, D3, D4, D5, A2, R1, R2, R3, M1, M2. Bootstrap deviation declared (Builder broken; main-session implementation). Cross-platform smoke single-platform with Linux/macOS asterisk. Released 2026-05-09 as tag v2.2.0. |
| Phase 10 — v2.4.0 candidate from TaskIt 2026-05-11 feedback (12 framework gaps + new feedback-authoring skill) | PLANNING | — | Architecture: `docs/architecture/framework-feedback-response-2026-05-12.md`. 7 Researcher artifacts at `docs/research/*-2026-05-12.md`. 10 ADRs at `docs/adr/008-017`. Implementation decomposed by surface affinity into 9 Build cycles (B1-B9, see Phase 10 Detail below). HARD BLOCKER: live-URL re-verification of every Researcher citation (web-fetch denied across every Researcher lane on 2026-05-12; all 37+ citations tagged "via WebSearch synthesis of canonical URL"; CLAUDE.md binding rule forbids implementation against un-verified citations). |
| Phase 8 — E5 verification + smoke-test | IN_PROGRESS (6/9 verified) | — | Plan at `docs/plans/phase-e5-verification-2026-04-30.md`. Verified at v2.0.2: (1) plugin loads + SessionStart fires ✅ (Taskforge); (2) framework-state-init resets state on /clear ✅; (3+4) tier-selection gate end-to-end (deny on Write; auto-recovery via Skill production-framework:tier-selection; subsequent Write allowed) ✅ (Taskforge); (5) bypass grammar — PF_BYPASS=tier-selection per-rule ✅, PF_BYPASS_ALL=1+REASON ✅, PF_BYPASS_ALL=1 without REASON denies ✅, PF_GATES_DISABLED filesystem kill switch ✅, bypass-log.jsonl JSONL append-only audit ✅ (5/5 paths verified 2026-04-30 via direct hook invocation); (6) destructive-ops gate (rm -rf, git reset --hard) + PF_BYPASS=destructive ✅, dep-add gate (npm install) + PF_BYPASS=dep-add ✅. Pending: (7) skill body lint via scripts/structural-check.sh; (8) full Tier 3 cycle smoke; (9) description-trigger-overlap audit per Option 1; plus D-B eval (3 corpora 15 cases). **Operational note:** plugin updates mid-session do not refresh CC's in-memory hook registry; live hook firing requires a fresh CC session post-update. Step 5+6 verified via direct hook invocation using exact CC JSON contract — equivalent functional coverage. |

**Status tokens:** PENDING | IN_PROGRESS | COMPLETE | COMPLETE_AWAITING_QA | BLOCKED

---

## Phase 10 Detail — Cycle Decomposition (v2.4.0 candidate)

**Source:** TaskIt project's `Taskforge/taskforge/docs/framework-plugin-feedback.md` — 12 items, all dated 2026-05-11, all OPEN at intake. Plus user-requested new feedback-authoring skill (2026-05-12 conversation).

**Design pass complete (2026-05-12):**
- Architect first pass: clustered the 12 items into 7 themes; drafted 22 research questions. Output at `docs/architecture/framework-feedback-response-2026-05-12.md`.
- 5 parallel Researcher lanes + 1 follow-on lane: 7 research artifacts at `docs/research/*-2026-05-12.md`; 37+ citations across 22 questions; all met the at-least-three citations threshold.
- Architect second + third pass: 10 finalized ADRs at `docs/adr/008` through `adr/017`. ADRs 008 and 009 self-cited at the Architect's first pass; ADRs 010 through 017 grounded in Researcher citations.

**Cycle decomposition (Architect's surface-affinity recommendation, 2026-05-12). Each Build cycle has been pre-tier-classified:**

| Build cycle | Surfaces touched | ADRs implemented | Cycle / Tier | Depends on |
|---|---|---|---|---|
| B1 — Citation re-verification | `docs/research/*-2026-05-12.md` | covers all | Refactor cycle, Tier 1 (mechanical URL re-fetches; no logic change). Direct execution. | none — must run first |
| B2 — Plugin version surfacing + README override docs | `hooks/session-start`, `README.md`, `.claude-plugin/plugin.json` | 008 (orchestrator naming), 009 (version surfacing) | Build cycle, Tier 1 (single hook line addition + README paragraph + version-template). Direct execution. | B1 |
| B3 — Architect intake additions | `agents/architect.md` | 014 (spectrum-vs-binary), 017 (dependency inventory), part of 011 (scale-readiness tag) | Build cycle, Tier 2 (agent-prompt amendment, single file, <6 deliverables). 4-step: audit → plan → implement → production-readiness check. | B1 |
| B4 — Researcher intake additions | `agents/researcher.md`, `skills/enterprise-research-first/SKILL.md` | 014 (frame-check), 015 (competitor-roster check) | Build cycle, Tier 2 (agent + skill amendment, 2 files). 4-step. | B1 |
| B5 — Deferral grammar + scale-readiness in plans | `skills/writing-plans/SKILL.md` | 010 (deferral grammar), 011 (scale-readiness commitment) | Build cycle, Tier 2 (single skill amendment with new grammar; touches plan-doc schema). 4-step. | B1, B3 (Architect must surface the tag before plans consume it) |
| B6 — Pattern-enforcement audit + cross-cutting pattern audit | `skills/proposing-patterns/SKILL.md`, `scripts/qa-structural-checks.sh`, `templates/STACK-PATTERNS.template.md`, new `skills/cross-cutting-pattern-audit/SKILL.md` | 013 (pattern-enforcement audit), 016 (cross-cutting pattern audit) | Build cycle, Tier 3 (new module / multi-feature phase; ≥6 deliverables across skill body + structural-check script + template + new skill). 6-step: architecture doc → research (already done) → plan → implement → QA → production-readiness check. | B1 |
| B7 — Cycle-phase enforcement at orchestrator | `skills/cto-mode/SKILL.md`, `skills/cycle-selection/SKILL.md`, `docs/cycle-state.md` schema (extended), `templates/cycle-state.template.md` (new) | 012 (phase-state enforcement) | Build cycle, Tier 2 (skill-layer enforcement only; ADR 012 explicitly avoids hook-contract change; <6 deliverables). 4-step. | B1 |
| B8 — Project bootstrap: COMPETITORS.md + feedback-file CONFIG slot | `templates/PROJECT-PLAN.template.md`, `templates/COMPETITORS.template.md` (new), `using-production-framework` skill (CONFIG slot list), `docs/onboarding-brownfield.md` + `docs/onboarding-greenfield.md` (CONFIG slot row additions) | part of 015 (competitor roster), new `file_paths.framework_feedback_log` slot | Build cycle, Tier 1 (new template + CONFIG slot addition; no logic change; mostly docs). Direct execution. | B1 |
| B9 — Feedback-authoring skill (new) | new `skills/writing-framework-feedback/SKILL.md` (or similar name) + evals directory | not an ADR; sibling work item from 2026-05-12 conversation | Build cycle, Tier 2 (single new skill, well-scoped, evals-required per skill-creator workflow). Use `skill-creator:skill-creator` per memory rule. 4-step plus skill-creator's own loop. | none — parallel to B1-B8 |

**Open Findings promotion plan:** at the start of each Build cycle, promote the relevant TaskIt feedback items (items 1-12) to F-V27 through F-V37 in the Open Findings table. Each finding row points at the in-progress Build cycle. Close each finding when the Build cycle ships and the structural check (where applicable) passes.

**Sequencing recommendation:** B1 must run first (citation re-verification). B2, B8, B9 can run in parallel (independent surfaces). B3 must precede B5 (Architect tag before plan consumes it). B4, B6, B7 are otherwise independent. B6 is the only Tier 3 cycle and will dominate calendar time.

**Release shape:** all of B1 through B8 land in v2.4.0 (minor bump per `CLAUDE.md` versioning — new conventions, new skill, new templates, no hook contract change). B9 (feedback-authoring skill) ships in v2.4.0 if ready in time or v2.5.0 if not.

**Sample-size disclosure (open finding F-V14):** every fix in B2-B8 generalizes from a single project (TaskIt). The Researcher citations partially substitute for cross-project signal but do not replace it. v2.4.0 release notes must disclose this honestly. B9 (feedback-authoring skill) does not have this caveat because its design is grounded in 14 enterprise sources covering bug-report, post-mortem, and framework-retrospective literature.

**Empirical pressure-test recommendation (skill-creator advice):** before B3-B8 close, the QA stage should walk each Architect's three deferred items from the 2026-05-11 TaskIt session backward through the new defer-with-blocker grammar and scale-readiness tag. If the new grammar would have correctly classified those items at intake (not at user-pushback time), the fix is validated. If not, the fix is incomplete and the cycle reopens.

---

## Architectural Decisions Pending

These gate Phase 7. Each maps to a cluster in the audit.

| ID | Title | Cluster | Status | Research |
|---|---|---|---|---|
| D-A | Hook-gate `tier-selection` / destructive-ops / phase-break / critical-finding / dep-add on `Edit`/`Write`/`Bash` | C1 (13 items: 14, 15, 17–27, plus 39 sub-fix) | **SHIPPED v2.0.2** + tier-selection gate VERIFIED end-to-end on 2026-04-30 (Taskforge test project) | Wave 1.5 R-A; Option C (5 gates v2.0; 3 defer v2.1; 2 discipline-only). Hook bundle = `hooks/{session-start, user-prompt-submit, pre-tool-use}` + `hooks/run-hook.cmd` polyglot wrapper + `scripts/framework-state-init.sh`. State substrate = `.framework-state/{session.json, bypass-log.jsonl}` |
| D-B | Override SP `verification-before-completion` with root-cause-fix vs symptom-mask clause | C2 (Item 32) | **EVAL READY; OVERRIDE CONDITIONAL** | Wave 1.5 R-F; eval at `evals/verification-root-cause/`; ship clause IF eval passes per CLAUDE.md double-evidence rule |
| D-C | Extend `enterprise-research-first` "When to Use" to bug-fix path | C2 (Items 28, 30) | **SHIPPED v2.0** (ER1 amended; bug-class triggers added) | Wave 1.5 R-E; bug-class taxonomy BC-1..BC-10 grounds trigger list |
| D-D | Add 6 new skills (browser-driven-verification, incident-response, parallel-reconciliation, find-similar-implementations, implementation-decision-log, fix-time-hash-check) | C5 / C7 / C8 / C9 / C6 | **SHIPPED v2.0** | Wave 1 5/5 + Wave 2 fix-time-hash |
| D-E | Port v1 incident-loop primitives — `compute-root-cause-hash.sh` + `structural-check.sh:check_incident_logged` + `proposing-patterns` skill + `ratify-pattern` skill | C6 (Items 40, 41 preservation side) | **SHIPPED v2.0** (UN-DEFER per ADR-001 G3 amendment + ADR-003) | Wave 2 R-9 + R-10 + R-11; broadened-pattern-ingest dual-path |
| D-F | Fix-time-hash-check skill + PostToolUse Builder hook for single-pass incident recording | C6 (Items 40-1, 40-2, 40-6) | **SHIPPED v2.0** (skill advisory; PostToolUse hook deferred to D-A v2.1 expansion) | Wave 2 R-11 — skill split rationale |

---

## Open Findings

[Per audit. Each row is an active incident until resolved. Preserved verbatim across `/compact`.]

| ID | Severity | Area | Description | Source |
|---|---|---|---|---|
| F-V9 | PARTIALLY RESOLVED (HIGH) | Tier-selection re-fires every prompt boundary (cumulative friction) — **A2 sub-fix shipped 2026-05-09 in v2.2.0** (system-reminder filter on user-prompt-submit; system-reminder events no longer re-arm the gate). **A1 portion DEFERRED:** cycle-state.md cooperation across skills — WS4 FM-12 cache-poisoning concern unresolved (cycle-close detection is LLM-self-attested). Remains OPEN until A1 design lands. | User feedback #42 — D-A bundle PreToolUse hook resets `tier_selection_invoked_at` on every user prompt boundary; system reminders (`<system-reminder>` for TodoWrite, deferred-tools, etc.) also reset it. In one Taskforge session the skill was invoked 10+ times for what was logically 4 distinct task families. Each invocation prints the full ~80-line skill body into context — most identical across calls. **Proposed fix (refined per wrap-up feedback item 2):** introduce a `docs/cycle-state.md` open-cycle marker that several skills (tier-selection, triage, writing-plans) cooperate around, instead of each defending its boundary independently. While a cycle is open, the gate suppresses re-firing for the cycle's classified tier. Closing the cycle (or task-shape keywords in a NEW human turn) clears the marker and rearms the gate. Sub-fixes: (a) `using-production-framework` SessionStart bootstrap reminder gets a "session warm" mode (skip preamble if any framework skill invoked in last N turns — see VS-04 cousin); (b) on first invocation of `tier-selection` per cycle, full body prints; subsequent same-cycle invocations return a 5-line summary; (c) WS2 Q5 mechanism: `user-prompt-submit` hook ignores `<system-reminder>` events for `last_user_prompt_at`, only resets on human-turn task-shape verbs. WS4 FM-15 caveat: gate logic at `pre-tool-use` MUST stay untouched; the fix is at the timestamp-write layer, not the gate-fire layer. Pairs with F-V10 (Builder redundant tier-selection inheritance) and F-V13 (docs/ auto-allow broken on Windows). | User feedback #42 + wrap-up items 1-3, 2026-04-30 |
| F-V11 | OPEN (HIGH) | Synthetic events ≠ real human input (verification blind spot) | User feedback #44 — all 7 Playwright scenarios for PRIMARY-1 reported PASS using `dispatchEvent(mousedown)` after `press_key`. User then reproduced "@Faisal Zia\|al Zia" leftover-tail on first manual test. Root cause: synthetic event dispatch runs in JS sequentially with full state commit between each event; real keyboard+mouse hardware events interleave through OS event loop in ways synthetic tests don't replicate. **Proposed fix:** add a "Real-input regression" subsection to `browser-driven-verification` skill. For BC-1 (closure-staleness) and BC-3 (race conditions), require **either** (a) a real-user manual smoke step in addition to synthetic Playwright, or (b) an architectural fix that proves race-immunity (read live DOM at click time vs React state). Skill body must state explicitly: "Synthetic event dispatch is necessary but NOT sufficient for timing-dependent UI bugs." HIGH severity: shipped bug undetected by green Playwright suite. | User feedback #44, 2026-04-30 |
| F-V12 | OPEN (MEDIUM) | Tier 2 ceremony cost-floor missing for tiny remediations | User feedback #45 — 30-LOC bug fix on already-shipped code (BP-12 residual) went through full `writing-plans` ceremony (100+ line plan doc) + Builder dispatch + handover doc. Plan and handover both proportionally larger than the fix. `parallel-dispatch` Rule 4 (cost-floor) addresses splitting one task into multiple Builders, not the orthogonal "Tier 2 ceremony for tiny remediations." **Proposed fix:** add a sibling rule (Rule 4b) to `parallel-dispatch` OR a "remediation fast path" subsection to `writing-plans`: "If <30 LOC, <3 files, root cause in scope of an existing handover, AND no schema/RLS/realtime change → skip plan doc; CTO brief Builder direct in ≤25 lines." Plan doc is then implicit in the original handover + the CTO brief. | User feedback #45, 2026-04-30 |
| F-V14 | OPEN (HIGH) | Validation sample size below the framework's own N≥3 rule | Honest readiness review, 2026-05-08 — only one real project (Taskforge) has used the framework end-to-end. Every "what works" / "what's broken" claim in PROJECT-PLAN.md (VS-01..VS-05, F-V7..F-V13) generalizes from a single-project signal. The framework's own binding rule requires N≥3 enterprise/OSS validations before promoting a pattern; the framework itself has not cleared its own bar. **Implication:** strengths and gaps are provisional until two more projects exercise the cycles. **Proposed fix:** identify two candidate projects (likely tutoring-platform + ECA-portal per FD-02 inventory) and onboard them on v2.1.1 production fix or v2.2.0; gather a second-project + third-project signal pass before declaring any v2 pattern stable. Pairs with FD-02 (MCP plugin compatibility surface) — same cross-project signal need. | Readiness review, 2026-05-08 |
| F-V15 | OPEN (MEDIUM) | Team-mode (multi-developer on same repo) undesigned and untested | Honest readiness review, 2026-05-08 — every cycle assumes a single CTO session driving one project. What happens when two developers each run cto-mode against the same repo concurrently is undefined: `docs/cycle-state.md` (proposed in F-V9 fix) is per-checkout; `.framework-state/` is per-machine; `docs/PROJECT-PLAN.md` Open Findings would conflict on parallel writes; agent dispatch happens in each developer's session independently. **Proposed fix (deferred research):** spec the team-mode question — single-writer-PROJECT-PLAN convention vs per-developer cycle-state files vs locking via git branch. Likely needs a Research-cycle dispatch (≥3 enterprise multi-developer-AI-tooling analogs) before a design decision. **Out of scope for v2.1.1 + v2.2.0;** flag as the next strategic question after sample-size gap closes. | Readiness review, 2026-05-08 |
| F-V16 | OPEN (MEDIUM) | No CI/deploy enforcement — gates live only in the chat session | Honest readiness review, 2026-05-08 — `gate-3-production-check` runs as a discipline checklist invoked inside a CC session. Once the developer leaves the session (commit, PR, deploy), nothing in the framework reasserts the 18 dimensions. A PR could ship that violates D5 (no SLO) or D11 (no audit log) and the framework would not block — only chat-time discipline catches it. **Proposed fix (deferred):** explore a CI shape — `gate-3-production-check.json` machine-readable manifest written during the chat-time invocation; a CI step that fails the build if the manifest is missing or stale; OR a GitHub Action that enforces the checklist at PR time. Cross-references FD-02 (GitHub MCP candidate). **Out of scope for v2.1.1 + v2.2.0;** captures the difference between "framework discipline" and "deployment enforcement" — today only the former exists. | Readiness review, 2026-05-08 |
| F-V19 | OPEN (CRITICAL) | Builder sub-agent reports inability to use Bash / PowerShell / Write at runtime | Field feedback, 2026-05-09 — a CTO session dispatched `production-framework:builder` for a Build cycle and the Builder returned reporting it cannot use Bash, PowerShell, or Write in its environment. Net effect: delegation to Builder is currently impossible — the agent literally cannot write code or run shell commands, which is its sole purpose. **Diagnostic state:** the Builder agent file at `agents/builder.md` does NOT declare a `tools:` line in its frontmatter. Per Claude Code's sub-agent contract, omitting `tools:` means the sub-agent inherits all tools available to the parent. So the agent profile itself is not the cause — inheritance is being broken somewhere downstream. **Likely causes to investigate:** (a) project-level `.claude/settings.json` permission allowlist that doesn't grant Bash/Write to dispatched sub-agents; (b) sandbox mode or `dangerouslyDisableSandbox` being false at the dispatch layer; (c) `isolation: worktree` (declared in Builder frontmatter line 6) interacting badly with tool inheritance — worktree-isolated sub-agents may run with a different permission context than the parent; (d) Anthropic-side change to how unspecified-tools-list resolves for sub-agents. **Proposed fix path:** (1) reproduce the failure with a minimal Builder dispatch in a controlled project, capture the exact tool-denied message; (2) test with `tools:` explicitly listed in Builder frontmatter (Bash, PowerShell, Write, Read, Edit, Glob, Grep) to determine whether the implicit-inheritance path is broken; (3) if explicit allowlist works, do the same for every sub-agent that needs shell or write access (architect needs Write, qa needs Bash, etc.); (4) document the result as the contract — either "PF v2 sub-agents declare tools explicitly" or "tool inheritance works, here's the gotcha." **CRITICAL:** this blocks the entire Build cycle Phase 6, Refactor cycle Phase 4, Security-Audit Phase 5, Performance Phase 5, Migration Phase 6 — every cycle that ends with "Builder writes code" is currently broken on dispatch. Workaround per field report: replace `production-framework:builder` with the local generic `Builder` subagent_type, which works. That's a real escape hatch but defeats the framework's point. | Field feedback, 2026-05-09 |
| F-V21 | OPEN (HIGH) | Agent-dispatch worktree creation fails despite the dev directory BEING a git repo | Surfaced 2026-05-09 attempting a Builder reproduction dispatch. Error: "Cannot create agent worktree: not in a git repository and no WorktreeCreate hooks are configured." Original logged hypothesis was that the dev dir wasn't a git repo and a `git init` would fix it. **Actual state:** the dev dir IS a git repo, on `main`, synced with `origin/main` at commit 9dc6686 (verified 2026-05-09 via `git status` + `git remote -v`). The Agent dispatch tool sees a non-git context anyway. **Revised root cause hypothesis:** the worktree-creation tool resolves cwd differently than `git status` does — possibly looks at a default plugin-sandbox path, or runs a subprocess in a different working directory than the host session reports. **Effect on release-discipline Gate 1:** the dogfood gate is runnable for Researcher / Architect / other non-worktree agents, but Builder dispatch from inside this repo will continue to fail. **Three options unchanged:** (a) make Agent dispatch see the same cwd as the host session — likely a CC-side issue, not a framework-side fix; (b) make `isolation: worktree` conditional in agent profiles — fallback to alternative isolation when worktree tool fails; (c) document that Builder dogfood must run from a git-backed user project, not from the framework's dev dir. HIGH (downgraded from CRITICAL): partial dogfood is still possible; only Builder is blocked. **Blocks:** Gate 1 Builder coverage; F-V19 empirical reproduction. | Direct empirical evidence, 2026-05-09; revised after `git status` 2026-05-09 |
| F-V26 | OPEN (MEDIUM) | structural-check produces wave-seam noise on multi-wave plans — false-positive "exported but never imported" findings between waves | Surfaced 2026-04-28 in v1 feedback log Item 2 (Search-G W2+W3 dispatch). The structural-check has no awareness of multi-wave plan dispatch state — it treats every Builder return as if it were a phase boundary, so the W2 Builder returning with `recordRecentlyOpened` exported-but-not-yet-imported (because W3 hadn't run) trips a false positive every wave. Builder correctly called it "wave-seam, not a defect," but having to repeat the dismissal trains future readers to discount the check. Was logged in the v1 feedback file but never made it into v2's findings table during the v2.0 audit (genuine oversight; not deliberately deferred). **Proposed fix:** (a) make the check wave-aware — skip "exported-unused" findings when an active multi-wave plan exists, detected via `docs/plans/<feature>.md` presence; OR (b) downgrade these specific findings to INFO during plan execution, escalate to ERROR only at phase end (when the plan's status flips to COMPLETE). Pairs with F-V12 (Tier 2 ceremony cost-floor) — both are about reducing per-wave friction without losing the underlying audit trail. MEDIUM severity: false positives don't ship bugs but accumulate dismissal-fatigue. | v1 feedback Item 2, 2026-04-28; reclassified as v2 oversight 2026-05-10 |

---

## Resolved Findings (archive)

[Findings that have been resolved. Preserved here in the same row format for historical audit; cleared from Open Findings for actionability. F-V series sorted by ID ascending. F-NN series mapped to the architectural decision (D-A through D-F) or resolution mechanism that closed each one.]

| ID | Final status | Area | Description (incl. resolution mechanism) | Source |
|---|---|---|---|---|
| F-V1 | RESOLVED (was MEDIUM) | Phase E5 hook plumbing | v2.0.0 shipped with `.sh` extensions on `pre-tool-use` and `user-prompt-submit` — broke `run-hook.cmd` extensionless convention (lines 7–9). Fixed in v2.0.1 (renamed extensionless + added "hook script not found" diagnostic to wrapper). | Phase E5 verification, 2026-04-30 |
| F-V2 | RESOLVED (was HIGH) | Phase E5 gate logic | v2.0.1 `pre-tool-use` had inverted early-exit: "if either timestamp is empty, allow" matched the deny case (`tier_selection_invoked_at` empty + `last_user_prompt_at` populated). Fixed in v2.0.2 (early-exit checks ONLY `last_user_prompt_at`). Verified end-to-end in Taskforge test project at v2.0.2. | Phase E5 verification, 2026-04-30 |
| F-V3 | RESOLVED | Author/email metadata | plugin.json + marketplace.json shipped with placeholder author "Fortes" + email "fortes.claudeai@fortes.co". Updated to "Atyab Rehman" + "atyabtosif@gmail.com" in v2.0.x. | Owner correction, 2026-04-30 |
| F-V4 | RESOLVED | v1 plugin coexistence | v1 was installed locally to "Vendor Email Scraping" project + had stale references in ~/.claude/settings.json and known_marketplaces.json. Cleaned (cache deleted; settings + manifests purged) on 2026-04-30 to make way for v2 user-scope install. | Pre-v2 install cleanup, 2026-04-30 |
| F-V5 | RESOLVED (was LOW) | CONFIG path indirection | Taskforge first-use bootstrap redirected `file_paths.project_plan` to `docs/TASKIT-PLAN.md`. Risk was: hardcoded `docs/PROJECT-PLAN.md` references operating on the wrong file. Fixed in v2.1.0: `scripts/structural-check.sh` now reads CONFIG first; `using-production-framework` declares the indirection rule globally; `cto-mode` Checklist Steps 2+6 use the CONFIG path. | Resolved v2.1.0, 2026-04-30 |
| F-V6 | RESOLVED (was MEDIUM) | Dispatch discipline gap | Framework prescribed sub-agent dispatch for heavy reads but had no specific application rule for "audit + doc generation" tasks. Fixed in v2.1.0: new skill `heavy-read-dispatch` with HARD-GATE marker; orthogonal to tier-selection. | Resolved v2.1.0, 2026-04-30 |
| F-V7 | RESOLVED (was LOW) | Builder dispatch verb ambiguity | Resolved 2026-05-09 in v2.2.0 — `cto-mode` Builder-dispatch template now requires unambiguous `EXECUTE` verb + `scope:` declaration. | Taskforge PRIMARY-1 dispatch, 2026-04-30 |
| F-V8 | RESOLVED (was LOW) | browser-driven-verification recovery docs | Resolved 2026-05-09 in v2.2.0 — 4 skills got Common Recovery sections covering Playwright MCP lock-fail mode, dev-server orphan, etc. | Taskforge mention-picker QA, 2026-04-30 |
| F-V10 | RESOLVED (was HIGH) | Builder agent silent failure mode | Resolved 2026-05-09 in v2.2.0 — Builder dispatch contract now requires `scope: code` declaration + `EMPTY_DIFF_FLAG: true` self-attestation + QA Stage 1 REJECT on zero-file diff. | User feedback #43, 2026-04-30 |
| F-V13 | RESOLVED (was HIGH) | docs/ auto-allow broken on Windows (path-separator mismatch) | Resolved 2026-05-09 in v2.2.0 — `FILE_PATH_NORM` normalization in pre-tool-use converts backslash paths to forward-slash before the case-statement match. | User feedback wrap-up #3, 2026-04-30 |
| F-V17 | RESOLVED (was LOW) | No brownfield retrofit playbook | Resolved 2026-05-09 in v2.2.0 — `docs/onboarding-brownfield.md` ships with CONFIG slot table + step-by-step retrofit. | Readiness review, 2026-05-08 |
| F-V18 | RESOLVED (was LOW) | `dispatching-parallel-agents` skill silent on foreground vs background runtime choice | Resolved 2026-05-09 in v2.2.0 — subsection added with two-row decision table. | Field feedback, 2026-05-09 |
| F-V20 | RESOLVED (was HIGH) | Hook-side sub-agent tier-selection inheritance missing | Resolved 2026-05-09 in v2.2.0 — `pre-tool-use` hook checks SUBAGENT_TYPE + parent's recent tier-selection invocation; sub-agents inherit parent verdict, skip the gate. | Field feedback consolidation, 2026-05-09 |
| F-V22 | RESOLVED (was MEDIUM) | F-V11 fix overrides existing skill text, not just adds to it | Resolved 2026-05-09 in v2.2.0 by clarifying F-V11's deferred status — the override-not-add concern stays as a binding constraint on F-V11's eventual fix design. | Researcher assessment, 2026-05-09 |
| F-V23 | RESOLVED 2026-05-10 (was HIGH) | Architect/Researcher dispatch ordering — three internal sources prescribed three different orderings | Resolved 2026-05-10 by adopting three-pass shape (architect → researcher → architect) in Build / Refactor / Migration cycles + heavy-read-dispatch row. | Conversation, 2026-05-10 |
| F-V24 | RESOLVED 2026-05-10 | tier-selection axis was framed as skill-domain but research says skill-domain has zero precedent as a tier axis | Resolved 2026-05-10 by adding "What axis the triggers actually rate" section to `tier-selection` — reframes trigger list as blast-radius indicators; skill-domain reassigned to `cycle-selection`'s territory. Research: `docs/research/tier-classification-{risk,ai}-frameworks-2026-05-10.md`. | Conversation, 2026-05-10 |
| F-V25 | RESOLVED 2026-05-10 | Two more parallel-without-feedback idiosyncrasies — Build phase 4 + Security-Audit phase 1 | Resolved 2026-05-10 by introducing Pattern A / Pattern B convention in `cycle-selection`. Pattern A (three-pass with revision) at Tier 3; Pattern B (sequential) at Tier 2. | Conversation, 2026-05-10 |
| F-01 | RESOLVED via D-A | C1 — bypass | Self-bypass of tier-selection on bug-shaped prompts post-`/compact`. Closed by D-A bundle SHIPPED v2.0.2 (pre-tool-use hook gates Edit/Write/Bash on tier-selection invocation). | Audit Item 14 (PF v1 mention-picker, 2026-04-30) |
| F-02 | RESOLVED via D-C | C2 — bug-fix | Bug-fix path missing enterprise verification of FIX. Closed by D-C SHIPPED v2.0 — `enterprise-research-first` "When to Use" extended to bug-fix path; bug-class taxonomy BC-1..BC-10 grounds trigger list. | Audit Item 28 |
| F-03 | CONDITIONAL via D-B (eval-pending) | C2 — bug-fix | `verification-before-completion` accepts symptom-mask, not root-cause-fix. D-B EVAL READY — override clause ships if eval at `evals/verification-root-cause/` passes per CLAUDE.md double-evidence rule. | Audit Item 32 |
| F-04 | RESOLVED via Wave 3 client-shape grammar | C3 — design-time | Arch-doc invariants don't validate vs implementation auth-model. Closed by `agents/architect.md:88+` client-shape grammar requirement — every row that cites RLS/RBAC must name the import path that activates the mechanism. | Audit Item 9 |
| F-05 | RESOLVED via Wave 2 entity-existence verification | C3 — design-time | Schema verification gap in arch-doc. Closed by `agents/architect.md:68` "Entity existence verification" section — every named table/collection/queue requires evidence (information_schema query, file:line migration ref, or external-service URL). | Audit Item 1 |
| F-06 | RESOLVED via debugger agent updates | C2 — debugger | Debugger anchors on prompt's first hypothesis. Closed by `agents/debugger.md` updates — Debugger required to enumerate code paths matching the user's actual language, then narrow. | Audit Item 3 |
| F-07 | RESOLVED via STACK-PATTERNS BPs | C4 — stack-specific | Builder client/server boundary violation. Closed at framework level by STACK-PATTERNS template carrying server-only BP rows; project-level enforcement is each project's responsibility. | Audit Item 10 (3rd recurrence) |
| F-08 | RESOLVED via STACK-PATTERNS BPs | C4 — stack-specific | QA missed React state-setter async closure-flag pattern. Closed at framework level by STACK-PATTERNS template carrying React state-setter BP row; QA agent reads patterns from project's STACK-PATTERNS.md. | Audit Item 11 |
| F-09 | RESOLVED via D-D | C5 — reuse | No reuse-lookup methodology. Closed by D-D SHIPPED v2.0 — new skills `find-similar-implementations`, `implementation-decision-log`, and `fix-time-hash-check` cover reuse discovery + post-ship decision tracking + fix-time deduplication. | Audit Item 39 |
| F-10 | RESOLVED via D-E + D-F | C6 — incident-loop | 6 incident-loop sub-gaps. Closed by D-E SHIPPED v2.0 (compute-root-cause-hash, structural-check incident-logged check, proposing-patterns, ratify-pattern) + D-F SHIPPED v2.0 (fix-time-hash-check skill + advisory mode). | Audit Item 40 |
| F-11 | RESOLVED via D-D new skill `browser-driven-verification` | C7 — verification | No browser-driven verification primitive. Closed by D-D SHIPPED v2.0 — `browser-driven-verification` skill prescribes ARIA snapshot, console-clean check, lock-fail recovery. | Audit Items 16 + 12 |
| F-12 | RESOLVED via D-D new skill `incident-response` | C9 — incident-response | No live-fire incident response distinct from triage / gate-3 / post-mortem. Closed by D-D SHIPPED v2.0 — `incident-response` skill covers minutes-to-resolve > completeness-of-fix workflow. | Audit Item 31 |
| F-13 | RESOLVED via D-D new skill `parallel-reconciliation` | C8 — orchestration | No parallel-reconciliation closing primitive. Closed by D-D SHIPPED v2.0 — `parallel-reconciliation` skill reconciles 2+ parallel agent returns with verdict-precedence ladder. | Audit Item 29 |
| F-14 | RESOLVED via `writing-handover` default cadence | C8 — orchestration | Per-wave handover overhead when QA cadence is phase-end-only. Closed by `writing-handover` skill default cadence = rolling-single-doc finalized at phase end (5/9 BINDING). Per-wave-immutable cadence requires explicit `qa_cadence: per-wave` declaration. | Audit Item 5 |
| F-15 | RESOLVED via Workstream D carryforwards | C10 — strength-port | v1 strengths needing action. Closed by Workstream D carryforwards SHIPPED v2.0 — `triage` skill ported; `enterprise-research-first` Step 6 elevated; `stop-debug-scan` discipline carried. | Audit Items 4, 7, 33 |

---

## Remnant Watchlist

[Things to remove or confirm before ship.]

| Item | Where | Resolve by |
| Item 33 truncated in feedback log — likely `stop-debug-scan` strength | feedback log | Phase 7 — request truncated portion from user; confirm `stop-debug-scan` port status |
| TodoWrite list session-scoped — duplicate critical state into this PROJECT-PLAN.md as Phase Status | this file | Continuous |
| Wave 1.5 + Wave 2 research artifacts in flight — append findings to "Research Performed" below as they land | this file | Continuous |

---

## Future Decisions (Discussion Backlog)

[Design questions parked for later — not bugs. Each item lists the question, options identified so far, and signal needed before deciding.]

### FD-01 — Automatic Playwright invocation on UI cycles

**Question:** should the framework auto-invoke `browser-driven-verification` (and the Playwright MCP it relies on) whenever a Builder cycle modifies UI files, instead of waiting for the user to ask?

**Origin:** Taskforge PRIMARY-1 (mention-picker UX, 2026-04-30) — user had to explicitly say "use playwrites to test." LLM only invoked Playwright after that prompt.

**Options identified:**
- **(1) Skill-body discipline.** Tighten `gate-3-production-check` D19 + `cto-mode` Step 5: "if cycle touched UI files (`*.tsx`/`*.jsx`/`*.css`), invoke `browser-driven-verification` automatically before declaring DONE." LLM still issues the call; discipline says "you must." Cheap, reversible, no infrastructure.
- **(2) Hook reminder.** PostToolUse hook on Builder Agent inspects file diff; if UI files changed, inject system reminder. Fires regardless of skill state. Requires MAJOR version bump (hook contract change) per CLAUDE.md.
- **(3) Full auto-runner.** `scripts/verify-ui.sh` starts dev server + runs Playwright. Most automated, most fragile (lock issues per F-V8).

**Tentative recommendation:** option 1. Playwright MCP infra not yet stable enough for hard automation (F-V8 lock issue would surface in every cycle); discipline-first lets LLM skip when MCP is broken without blocking.

**Signal needed before deciding:** ≥3 more Taskforge UI cycles to see whether discipline-only (current state) reliably triggers browser-driven-verification or whether the LLM consistently skips it.

---

### Validated Discipline (Strengths — keep doing this)

[Empirically-validated framework patterns from real Taskforge use. "Don't touch" list — promote to defaults where applicable.]

- **VS-01 — `enterprise-research-first` produced BINDING-justified ARIA wiring** (user feedback #46, HIGH-value strength). N/N consensus + capability-fit precondition caught one mismatch (textarea camp vs contenteditable for chip atomicity → DEFERRED with rationale). All 3 deliverables (plan, handover, STACK-PATTERNS BP row) cite source research with line-anchored claims; no "I think we need this" decisions. **Promote candidate:** research-doc-with-comparison-table as default expectation for any **Tier 2 UX-shaped feature**, not just Tier 3.

- **VS-02 — `browser-driven-verification` + Playwright MCP composability** (user feedback #47, HIGH). `browser_evaluate` for ARIA snapshot + `browser_console_messages level=error all=true` for console capture form a 2-tool verification cycle that produces clean, diffable, durable evidence. Caught Next.js Router HMR error AND confirmed it was unrelated. **Promote candidate:** one-line Gate 3 default — "UI ship → ARIA snapshot evidence + console-clean check on every route touched."

- **VS-03 — D-A HARD-GATE prevented "just-edit-this-real-quick" shortcuts** (user feedback #48, MEDIUM-strength MEDIUM-friction). Empirically blocked ≥3 attempts per session to bypass tier-selection on Edit/Bash. Each block forced explicit tier reasoning; each verdict was the right call. The *blocking* nature is what produces the discipline — non-blocking warning would be ignored. **Don't touch the blocking behavior;** tune frequency per F-V9 (cache verdict per logical task).

- **VS-04 — Compact-preservation discipline survived /compact intact** (user feedback #49, MEDIUM). MEMORY.md pointers (31 entries), BP/AP/PP patterns in CLAUDE.md, agent-memory researcher notes — all preserved across `/compact`. Resumed session continued the deputy/CTO role correctly. **Don't touch the named-preservation list;** could be promoted to project-template default (every project's `CLAUDE.md` gets a Compact Instructions section).

- **VS-05 — Gating ROI is net-positive: friction tax justified by catches** (user feedback wrap-up item 4, HIGH). Quote: "the framework caught one real misroute risk this session (Bug 4 BC-9 vs BC-2) and that justified the gating cost many times over." Empirical signal that the F-V9/F-V13 friction surface, while taxing, is buying real correctness. **Implication for v2.2.0 design:** preserve the *blocking semantic* of the gate; tune only the *firing rate* (per F-V9 refined fix shape). Do NOT swap the HARD-GATE for a non-blocking warning — VS-03 + VS-05 together prove blocking is what produces the catch.

---

### FD-03 — Reply-shape discipline (theater suppression)

**Question:** should the framework enforce a reply-shape contract on the CTO session — bounding length, structure, vocabulary, and ceremony of user-facing output — and on what axes?

**Origin:** Empirical signal, observed in this session and prior — the CTO session repeatedly produces verbose, padded, multi-section replies for tasks where one-line acknowledgments would suffice. The user's stated preference (saved as memory `feedback_communication_style.md`) is plain-English crisp bullets, no codes, no readiness percentages, but the framework currently has no mechanism to enforce that. Memory is read-only context; it doesn't gate output. The preached "match responses to the task" line in CC's system prompt is honored intermittently, not reliably.

**Candidate axes (not yet a design — all open):**

- Output length scale (token / line cap per response, scaled by task)
- Reply-shape contract (allowed sections; forbidden sections; bullets-vs-prose default)
- Readback discipline when synthesizing parallel-agent returns (no re-narrating each agent's path; only the verdict)
- Vocabulary discipline (no internal IDs, version codes, percentages in user-facing text)
- Status-update cadence (when DOES the user need a sentence; when does silence-until-done apply)

**What's NOT decided:** which axes matter most; whether discipline lives in skill bodies (preached) or hooks (enforced); whether the contract is dynamic per task or fixed per session; how to evaluate it.

**Signal needed before designing:** characterize the failure mode precisely — what tasks reliably trigger theater, what triggers crispiness, which channels (text reply vs handover doc vs PROJECT-PLAN row) need different shapes. One project's worth of empirical sessions is below the framework's own N≥3 rule for confident design.

**Relation to existing items:** orthogonal to F-V9 / F-V12 (those are about ceremony cost in agent-internal work; this is about user-facing output). Adjacent to VS-04 compact-preservation (preservation handled; output shape is the next layer).

**Status:** parked — explicitly **future work**, not next-cycle. v2.2.0 has shipped (Phase 9 COMPLETE 2026-05-09), so the original parked-until trigger has fired, but user direction 2026-05-10 is to keep this queued rather than promote: pulling FD-03 into a cycle today still violates the framework's own N≥3 rule (only Taskforge has exercised the framework end-to-end — see F-V14). When the second and third project signals arrive (per F-V14 candidates: tutoring-platform, ECA-portal), revisit FD-03 with empirical failure-mode characterization first, then split the five candidate axes into separate ADRs (length cap + reply-shape + readback + vocabulary + cadence are independent concerns, not one feature).

---

### FD-02 — MCP plugin compatibility surface

**Question:** which Claude Code MCP plugins should production-framework explicitly support / cite / depend on, and how is that compatibility expressed?

**Context:** today the framework references several MCP plugins by capability (browser-driven-verification → Playwright MCP; database-engineer → Supabase MCP; etc.) but doesn't enumerate the supported set or document version compatibility.

**Candidates to consider:**
- **Playwright MCP** — UI verification (`browser-driven-verification` skill).
- **Supabase MCP** — multi-tenant DB ops, RLS migrations, advisors (`database-engineer` agent + `rls-aware-migrations` skill).
- **Vercel MCP** — deploy, runtime logs, deployment build logs (`sre-devops` agent).
- **Context7 MCP** — current library docs (`researcher` agent + `enterprise-research-first` skill — could replace stale-training-data lookups).
- **GitHub MCP** — PR/issue/CI access (`qa` agent + `finishing-a-development-branch` skill).
- **Notion / ClickUp MCP** — work-item tracking (`product-manager` agent for spec sync).

**Open sub-questions:**
- Should `using-production-framework` SessionStart bootstrap detect which MCP plugins are connected and adapt skill recommendations accordingly (e.g., "Supabase MCP detected — database-engineer will use it for RLS audits")?
- Should `CONFIG.yaml` grow an `mcp_plugins` slot enumerating which are required vs optional vs unsupported per project?
- How should the framework handle missing MCP plugins gracefully — degrade to manual instructions, or block the cycle?

**Signal needed before deciding:** which MCP plugins are actually used across ≥3 representative projects (Taskforge, future tutoring-platform work, future ECA-portal work). Inventory the calls; codify the binding ones.

---

## Architecture Documents

| Module | Doc | Last-verified |
|---|---|---|
| Citation manifest (binding-rule source of truth) | `docs/research/sp-anthropic-citation-manifest.md` | 2026-04-28 |
| Enterprise multi-agent architecture (N=7 framework comparison) | `docs/research/enterprise-multi-agent-architecture.md` | 2026-04-28 |
| 7-gap ADR | `docs/adr/001-7-gap-decisions.md` | 2026-04-28 |
| 12 agent design docs | `docs/research/agent-design-{architect, researcher, builder, qa, database-engineer, security-compliance, sre-devops, code-reviewer, debugger, post-mortem, product-manager, ux-design}.md` | 2026-04-28 / 2026-04-29 |
| Model assignment (6/6 Opus/Sonnet matrix) | `docs/research/agent-model-assignment.md` | 2026-04-28 |
| 3 foundational skill design docs | `docs/research/skill-design-{enterprise-research-first, seven-validation-questions, gate-3-production-check}.md` | 2026-04-30 |
| v1 feedback audit (36 items, 11 clusters, 6 architectural decisions) | `docs/audits/v1-feedback-vs-v2-2026-04-30.md` | 2026-04-30 |
| STACK-PATTERNS template | `templates/STACK-PATTERNS.template.md` | 2026-04-30 |
| PROJECT-PLAN template | `templates/PROJECT-PLAN.template.md` | (template, not used as instance) |

---

## Research Performed

[Per phase. Append-only. Each entry leads with **Prompted by:** so the trigger for the cycle is auditable. If implemented in a shipped artifact, **Status: IMPLEMENTED** + path; else **Status: PENDING-IMPLEMENTATION** and the row stays here until Phase 7.]

### Phase 1 — Foundation

**Citation manifest** (`docs/research/sp-anthropic-citation-manifest.md`)
- **Prompted by:** v2 design start — establish the binding rule (every feature cites SP precedent OR Anthropic guidance + ≥3 enterprise/OSS analogs) before any artifact is written.
- **Findings:** 27 SP precedents + 17 Anthropic citations + 7 gaps documented.
- **Status:** IMPLEMENTED in `CLAUDE.md` binding rule + every shipped artifact.

**Enterprise multi-agent architecture** (`docs/research/enterprise-multi-agent-architecture.md`)
- **Prompted by:** PF v1 "telephone game" failure — needed N=≥3 framework comparison to ground v2's dispatch shape.
- **Findings:** N=7 framework comparison (MetaGPT, ChatDev, CrewAI, LangGraph, AutoGen, Agents SDK, Claude Code).
- **Status:** IMPLEMENTED in agent dispatch shape + `cto-mode` skill.

### Phase 2 — 12 Agents

**12 role-specific researchers (Opus, parallel)** → `docs/research/agent-design-*.md`
- **Prompted by:** User pushback "are you hillbillying the prompts?" — shape-correct shallow agent prompts rejected; needed deep per-role research before writing each agent.
- **Findings:** 12 role-anchored research artifacts (architect, researcher, builder, qa, db-engineer, security-compliance, sre-devops, code-reviewer, debugger, post-mortem, product-manager, ux-design); each with verbatim canonical citations (Google SRE, AWS WAF, OWASP, NIST, MADR, Y-Statement, Cucumber BDD, INVEST, etc.).
- **Status:** IMPLEMENTED in 12 agent prompts.

**Model assignment researcher (Sonnet)** → `docs/research/agent-model-assignment.md`
- **Prompted by:** User pushback "do we really need opus on all those?" — initial 9-Opus / 3-Sonnet proposal questioned on cost.
- **Findings:** 6/6 Opus/Sonnet matrix per SP "least-powerful-model" rule (`subagent-driven-development/SKILL.md` lines 87-101); ~17% cost saving per cycle.
- **Status:** IMPLEMENTED in agent frontmatter (every agent declares its model).

### Phase 4 — Foundational Skills

**`skill-design-enterprise-research-first.md`** (Opus, 362 lines)
- **Prompted by:** Phase D start — first of 3 foundational skills; citation manifest GAP-1 (no SP precedent for the N≥3 binding rule).
- **Findings:** 9/9 BINDING enterprise consensus on the *discipline* (Amazon PR/FAQ, Google Design Docs, Rust RFC 2333, Kubernetes KEPs, AWS WAF, ThoughtWorks Radar, ADR/MADR, Spotify, Squarespace); N=3 threshold honestly labeled PF-internal.
- **Status:** IMPLEMENTED in `skills/enterprise-research-first/SKILL.md` (207L).

**`skill-design-seven-validation-questions.md`** (Opus, ~270 lines)
- **Prompted by:** Phase D start — second foundational skill; gates Tier 2/3 plans before builder dispatch.
- **Findings:** Y-Statement (Zimmermann) + 7 industry analogs; Q5/Q6 honestly tagged "Industry-framework adapted" (no SP precedent).
- **Status:** IMPLEMENTED in `skills/seven-validation-questions/SKILL.md` (224L).

**`skill-design-gate-3-production-check.md`** (Opus, ~430 lines)
- **Prompted by:** Phase D start — third foundational skill; citation manifest GAP-2 (no SP precedent for unified production gate).
- **Findings:** 17 distinct enterprise sources, 18 dimensions with K/N consensus per dim; D2/D8/D10/D14 BLOCKED-only (not DONE_WITH_CONCERNS).
- **Status:** IMPLEMENTED in `skills/gate-3-production-check/SKILL.md` (343L).

### Phase 5 — Audit

**v1 feedback vs v2 audit** (`docs/audits/v1-feedback-vs-v2-2026-04-30.md`)
- **Prompted by:** User delivering 36-item v1 feedback log from production use (TaskIt sessions 2026-04-28 to 2026-04-30); two-pass methodology agreed (audit shipped v2 first, then bake gaps).
- **Findings:** 5 CONVERGENT / 9 PARTIAL / 15 GAP / 3 META across 36 items; 11 clusters (C1–C11); 6 architectural decisions surfaced (D-A through D-F).
- **Status:** AUDIT-COMPLETE. Implementation pending Phase 7.

### Phase 6 — Pass 2 Research

#### Wave 1 (5/5 complete, all Opus, 2026-04-30)

**`skill-design-browser-driven-verification.md`** (327L)
- **Prompted by:** Audit Item 16 + Cluster C7 — no Playwright/browser-driven verification primitive in v2; 3 PF v1 sessions empirically depended on Playwright.
- **Findings:** 5/5 BINDING on wait-for-condition; 6/6 directional on user-visible-behavior + semantic locators + isolation. Top-3 recs: (R2) bind `wait_for(<text|role|alias>)` over `setTimeout`; (R5) console-error capture non-optional for routes-touched (closes Item 12); (R4) ARIA-snapshot-as-evidence.
- **Status:** PENDING-IMPLEMENTATION.

**`skill-design-incident-response.md`** (320L)
- **Prompted by:** Audit Item 31 + Cluster C9 — no live-fire incident-response skill distinct from triage / gate-3 / post-mortem.
- **Findings:** 6/6 sources name Detect/Mitigate/Resolve+Handoff. 5-phase spine: Detect → Triage → Contain → Mitigate → Resolve+Handoff. Top-3 recs: rollback-as-first-Contain-action HARD-GATE; live timeline `docs/incidents/live-<incident>-<UTC>.md` handing off to post-mortem; reuse-by-reference (severity from post-mortem.md).
- **Status:** PENDING-IMPLEMENTATION.

**`skill-design-parallel-reconciliation.md`** (272L)
- **Prompted by:** Audit Item 29 + Cluster C8 — no closing primitive paired with `dispatching-parallel-agents`; 4-researcher dispatches in this very session needed manual reconciliation.
- **Findings:** 5/7 BINDING on named reconciliation primitive. **Structural verdict: NEW STANDALONE SKILL** (not extension) — 5 grounded reasons (SP's paired-skill idiom; CLAUDE.md override-cost). Top-3: verdict-precedence ladder; HARD-GATE against silent override; convergence/divergence decision tree.
- **Status:** PENDING-IMPLEMENTATION.

**`skill-design-find-similar-implementations.md`** (352L)
- **Prompted by:** Audit Item 39 + Cluster C5 — registries exist (patterns.md, STACK-PATTERNS.md), lookup methodology missing; Builder + orchestrator apply ad-hoc heuristics.
- **Findings:** **11/11 BINDING** on structured methodology beyond name-grep. 4-step: name-similarity → fn-signature → import-graph → AST/fingerprint. HARD-GATE before `writing-plans` for new helper/component/hook. Composability with ER1, writing-plans, implementation-decision-log, proposing-patterns.
- **Status:** PENDING-IMPLEMENTATION.

**`skill-design-implementation-decision-log.md`** (~290L)
- **Prompted by:** Audit Item 39 + Cluster C5 — gap between PROJECT-PLAN (phase grain) and STACK-PATTERNS (codified pattern grain); helper/primitive-grain decisions never captured.
- **Findings:** Microsoft Engineering Playbook Decision Log is direct 1:1 analog. Wix Engineering supplies append-only discipline. Field-level consensus 8/8 on decision/why-this. 5-field schema. Explicitly NON-HARD-GATE.
- **Status:** PENDING-IMPLEMENTATION.

#### Wave 1.5 (3/3 complete, 1 Opus + 2 Sonnet, 2026-04-30)

**`decision-d-a-hook-gating-architecture-2026-04-30.md`** (Opus, 403L)
- **Prompted by:** Cluster C1 (13 audit items: 14, 15, 17–27 + 39 sub-fix) — bypass-prone discipline pattern; user follow-up "are there non-skill items that need research?"; D-A architectural decision.
- **Findings:** K/N consensus across 7 hook-design heuristics — 5/5 unanimous on gate=non-zero/structured-deny, bypass-as-feature, file/env-var state, reason surfaced, single-hook-multi-matchers; 4/5 on granular bypass + severity-classed. **Verdict: ship Option C — scoped 5-gate v2.0** with full ADR draft. Use `permissionDecision: "deny"` not exit-2 (Claude Code bugs #13744 / #36071 / #40580). Three-tier bypass grammar (`PF_BYPASS=<id>` per-rule + `PF_BYPASS_ALL=1` session + `.framework-state/PF_GATES_DISABLED` project) + append-only `bypass-log.jsonl` for Post-Mortem mining. Per-rule scope: gate-in-v2.0 (5: tier-selection / destructive-ops / phase-break / critical-blocks-next-phase / dep-add); defer-to-v2.1 (3: triage / brainstorming / plan-update); discipline-only (2: tool-selection-chain / plan-dir).
- **Status:** PENDING-IMPLEMENTATION (D-A decision pending; ADR draft ready).

**`bug-class-taxonomy-2026-04-30.md`** (Sonnet, 313L)
- **Prompted by:** Audit Items 3 + 28 + Cluster C2 — bug-fix path under-engineered; needed enterprise-cited taxonomy to ground ER1 "When to Use" extension + debugger amendment.
- **Findings:** 10 bug classes (BC-1 closure-staleness, BC-2 cache-invalidation, BC-3 race condition, BC-4 hydration mismatch, BC-5 optimistic-rollback, BC-6 IDOR/BOLA, BC-7 N+1, BC-8 deadlock, BC-9 spec-divergence, BC-10 state-machine). BC-3 race condition BINDING (7/10); 5 classes STRONG (5/10); 3 classes STRONG (4/10); BC-4 hydration STRONG (3/10, lowest). 7 PF v1 incidents backward-traced to specific classes. Top-3 recs: extend ER1 "When to Use"; add user-language-as-ground-truth + widen-before-narrow Hard rules to debugger.md; add debugger Phase 4.5 bug-class enterprise check.
- **Status:** PENDING-IMPLEMENTATION (D-C extension target).

**`decision-d-b-root-cause-vs-symptom-2026-04-30.md`** (Sonnet, 436L)
- **Prompted by:** Audit Item 32 + Cluster C2 — `verification-before-completion` accepts symptom-mask not root-cause-fix; PF v1 mention-picker first-pass fix would have PASSED; D-B architectural decision.
- **Findings:** 15 sources (Agans, Kernighan-Pike, Google SRE Ch. 12, Allspaw, Dekker, Reason, Toyota 5-Whys, Anthropic). Top-3 distinguishing heuristics: (H-2) data-flow trace correspondence — fix must touch the file:line in `docs/debug/<incident>.md` Root Cause; (H-1) reachability of origin under input variation — revert patch; if test still passes via alternate path, fix closed symptom site only; (H-6) debugger debug doc as machine-checkable pre-condition. **Eval design:** 3 corpora 15 test cases — Corpus A (5 cases where root-cause-fix and symptom-mask both pass SP, only PF catches mask), Corpus B (5 regression-guard cases), Corpus C (5 adversarial). Pass criterion: A all caught; B no regressions; C tighter-or-equal. Double-evidence via two independent sessions including adversarial rationalization-encouragement priming.
- **Status:** PENDING-IMPLEMENTATION (D-B decision pending; eval ready to run).

#### Wave 2 (3 in flight, 2026-04-30)

**`skill-design-proposing-patterns.md`** (Opus, 381L)
- **Prompted by:** Audit Items 39 + 40 + Cluster C5/C6 + D-E architectural decision — v1 carryforward needing ingest broadening (incidents OR BINDING research findings).
- **Findings:** 21 sources (1 PF v1 carryforward + 6 PF v2 internal cross-links + 1 SP-cache verified-absence + 2 Anthropic + 11 industry pattern-proposal frameworks: PLoP, Fowler Rule-of-Three, GoF/POSA, Microsoft Azure Architecture Center, AWS Well-Architected pattern library, Refactoring Guru, Kubernetes KEP graduation, IETF RFC 7942, Apache PMC, ThoughtWorks Tech Radar, RFC 2026). **K/N: 9/11 (82%) BINDING** support multi-trigger ingest (recurrence AND/OR external-evidence). The two strict-recurrence-only frameworks (PLoP, Fowler) still align with v1 Path A. **Broadening verdict: APPROVE** — external N/N at N≥5 is at least as strong as ≥3 internal incidents on every U-AP-4 grammar axis; cargo-cult-via-consensus-fit risk is already mitigated by ER1 Step 6 use-case-fit (load-bearing 7/7 OAuth precedent — broadening *inherits* the mitigation, doesn't invent). **Top-3 recs:** (R1) carry forward v1's 5-step methodology verbatim; add Step 0 (source detection) + Step 3a/3b dual-path branch — Path A = ≥3 distinct hashes (v1 carryforward), Path B = BINDING research + use-case-fit check passed; (R2) preserve all 6 ratification gates G1–G6 as binding for both paths — broadening adds an admission gate, removes none; G2 refactors to G2A (incidents) OR G2B (BINDING research); STRAWMAN prefix discipline binds both paths identically; (R3) **UN-DEFER the v1→v2 carryforward** — currently deferred to v2.1 per `docs/adr/001-7-gap-decisions.md` G3 + `agents/post-mortem.md` line 124. Item 41 STRENGTH evidence ("most carefully engineered subsystem in v1") justifies shipping in v2.0.x not v2.1.
- **Status:** PENDING-IMPLEMENTATION (D-E target). **Decision-shaping consequence:** updates `sp-anthropic-citation-manifest.md` GAP-3 framing — composition is PF-original; components are enterprise-cited 9/11. Manifest update is itself an implementation task.

**`skill-design-ratify-pattern.md`** (Sonnet, 359L)
- **Prompted by:** Audit Item 41 + Cluster C6 + D-E — v1 carryforward; user-gated 6 mechanical gates need enterprise-cited grounding (Apache PMC, Kubernetes KEP graduation, IETF RFC, W3C Recommendation, TC39 Stage 0–4, Rust FCP, Linux Signed-off-by).
- **Findings:** 11 sources (3 v1 carryforward + 1 SP adjacent: brainstorming HARD-GATE lines 12–14 + 1 Anthropic + 7 enterprise governance). SP has zero ratify-pattern precedent — confirmed. **Gate-to-analog mapping:** G1 bloat cap (0/7 — PF-original); G2 duplicate-incident hash (0/7 — PF-original); G3 machine-verifiable check (5/7 — TC39 Test262, K8s e2e, Linux CI strict matches); G4 ratification traceability (6/7 — strongest consensus); G5 rollback path (5/7 partial, 2/7 strict — K8s, Linux); G6 fixture gate (4/7 — TC39, K8s strict). **Top-3 recs:** (R1) carry G1 + G2 as explicitly PF-original with failure-mode rationales; parameterize G1 bloat cap in Stack Config; (R2) strengthen G5 with idempotency + clean-branch test requirements aligning K8s graduation criteria; (R3) add `postpone` as 4th Stage-3 disposition alongside approve/reject/edit (aligns Rust RFC FCP three-disposition model — prevents premature rejection of proposals needing more time).
- **Status:** PENDING-IMPLEMENTATION (D-E port target).

**`skill-design-fix-time-hash-check.md`** (Opus, 278L)
- **Prompted by:** Audit Items 40-1, 40-2, 40-6 + Cluster C6 + D-F — NEW skill closing fix-time dedup gap; needed to ground in error-fingerprinting / duplicate-detection literature.
- **Findings:** 18 sources (7 PF/SP internal + 2 Anthropic + 9 enterprise: Sentry, Bugsnag, Rollbar, Honeybadger, Datadog, Linear, GitHub bots, Stack Overflow DupPredictor, SRE Book). N=8 fix-time-applicable error-fingerprinting frameworks researched (exceeds ER1 N≥5 BINDING). SP precedent: zero — confirmed. **Algorithm consensus: 8/8 BINDING** on fingerprint-and-surface-prior-matches discipline; 5/8 deterministic-hash; 5/8 strip {line numbers, IDs, dates, version strings} — **Rollbar + Datadog corroborate PF v1's 7-rule normalization grammar VERBATIM** (independent validation that v1 is not bespoke); 5/8 fix-time invocation, 6/8 proposal-time, 3/8 both. **Top-3 recs:** (R1) ship as **advisory** v2.0 skill (~30–50L) — DONE/NEEDS_CONTEXT only, **never blocking**; trigger before any fix; input = Debugger root-cause sentence; procedure = compute hash → grep PROJECT-PLAN Incident Table + STACK-PATTERNS → emit 5-line surface; composable with `systematic-debugging` Step 4.5 + ER1; (R2) port `compute-root-cause-hash.sh` verbatim, preserve HASH_VERSION=1, surface version line in skill output (Sentry/Bugsnag versioning precedent — never auto-update); (R3) defer to v2.x: embedding/similarity tier (Linear/GitHub fuzzy match), PreToolUse blocking hook (separate D-F workstream), single-pass auto-recording (Item 40-1), cluster-scan (Item 40-3).
- **Status:** PENDING-IMPLEMENTATION (D-F target; advisory shape clarifies D-F scope — hashing skill ships separately from the PostToolUse Builder hook).

#### Phase 6 — Post-Research Findings Digest (2026-04-30)

[Consolidation written after all research in Phase 6 returned. Maps each artifact to the audit cluster/items it solves + the load-bearing finding. This is the executive view; the per-artifact entries above are the durable detailed record.]

| # | Research → Solves | One-liner finding |
|---|---|---|
| 1 | `browser-driven-verification` → Items 16, 12 / **Cluster C7** | 5/5 BINDING on wait-for-condition; bind `wait_for(<text\|role\|alias>)` over `setTimeout`; capture console-errors per route; ARIA-snapshot-as-evidence (closes Item 12). |
| 2 | `incident-response` → Item 31 / **Cluster C9** | 6/6 sources name Detect/Mitigate/Resolve+Handoff; ship 5-phase spine with rollback-as-first-Contain HARD-GATE + live-timeline artifact handing off to post-mortem. |
| 3 | `parallel-reconciliation` → Item 29 / **Cluster C8** | 5/7 BINDING on named reconciliation; verdict = **NEW STANDALONE skill** (not extension); verdict-precedence ladder + HARD-GATE against silent override + convergence/divergence decision tree. |
| 4 | `find-similar-implementations` → Item 39 / **Cluster C5** | **11/11 BINDING** on structured methodology beyond name-grep; 4-step (name-similarity → fn-signature → import-graph → AST/fingerprint); HARD-GATE before `writing-plans` for new helper/component/hook. |
| 5 | `implementation-decision-log` → Item 39 / **Cluster C5** | Microsoft Engineering Playbook Decision Log is **direct 1:1 analog**; field-level consensus 8/8 on decision/why-this; 5-field schema; explicitly **NON-HARD-GATE**; append-only enforcement per Wix Engineering. |
| 6 | `decision-d-a-hook-gating` → 13 items in **Cluster C1** / **D-A** | 5/5 unanimous on multiple hook heuristics; **ship Option C — 5 hook-gates in v2.0** (tier-selection + destructive-ops + phase-break + critical-blocks-next-phase + dep-add); use `permissionDecision: "deny"` JSON not exit-code-2 (CC bugs #13744/#36071/#40580); 3 defer to v2.1; 2 discipline-only. |
| 7 | `bug-class-taxonomy` → Items 3 + 28 / **Cluster C2** | 10 bug classes; BC-3 race-condition BINDING (7/10); **7 PF v1 incidents backward-traced** to specific classes (incident-grounded, not vibe-list); extend ER1 "When to Use" + add user-language-as-ground-truth + widen-before-narrow + Phase 4.5 to debugger.md. |
| 8 | `decision-d-b-root-cause-vs-symptom` → Item 32 / **Cluster C2** / **D-B** | 3 distinguishing heuristics (H-1 reachability under input variation; H-2 data-flow-trace correspondence; H-6 debug-doc as machine-checkable pre-condition); **3-corpora 15-test-case eval design** satisfies CLAUDE.md double-evidence requirement for SP override. |
| 9 | `proposing-patterns` (broadened) → Items 39 + 40 / **Cluster C5/C6** / **D-E** | 9/11 (82%) BINDING on multi-trigger ingest; **broadening verdict: APPROVE**; carry v1's 5-step + add Step 0 (source detection) + Step 3a/3b dual-path; **UN-DEFER from v2.1 → v2.0.x** per Item 41 evidence; cargo-cult risk inherits ER1 Step 6 mitigation. |
| 10 | `ratify-pattern` → Item 41 / **Cluster C6** / **D-E** | 6/7 frameworks have analog for G4 traceability (strongest); G1 (≤20-row bloat cap) + G2 (duplicate-incident hash) are **PF-original** — keep with failure-mode rationales; add `postpone` as 4th Stage-3 disposition (Rust RFC FCP-aligned, prevents premature rejection). |
| 11 | `fix-time-hash-check` → Items 40-1, 40-2, 40-6 / **Cluster C6** / **D-F** | 8/8 BINDING on fingerprint-and-surface-priors; **PF v1's 7-rule normalization grammar VERBATIM corroborated by Rollbar + Datadog** (independent validation — v1 primitive is enterprise-consensus, not bespoke); ship **advisory** v2.0 (DONE/NEEDS_CONTEXT, never blocking); **D-F splits** — skill ships now, PostToolUse Builder hook joins D-A bundle. |

##### Cluster coverage map (Phase 6 research)

- **C1** (bypass-prone discipline, 13 items) → fully addressed by R-A → **D-A decision actionable**
- **C2** (bug-fix path under-engineered, 3 items) → bug-class taxonomy (R-E) + root-cause-vs-symptom (R-F) → **D-B + D-C decisions actionable**
- **C3** (design-time validation, 2 items) → not directly researched in these waves; covered by audit recommendations only — **audit-only, no Phase 6 research**
- **C4** (stack-conditional anti-patterns, 5 items) → not researched; STACK-PATTERNS extension stubs deferred to Pass 2 — **deferred**
- **C5** (reuse + decision-log, 1 multi-faceted item) → 3 artifacts (find-similar-implementations + implementation-decision-log + proposing-patterns broadening) → **fully covered**
- **C6** (incident-loop hardening, 3 items) → 3 artifacts (proposing-patterns + ratify-pattern + fix-time-hash-check) + D-A bundle gets PostToolUse Builder hook → **fully covered**
- **C7** (UI/browser verification, 2 items) → browser-driven-verification → **fully covered**
- **C8** (orchestration closing primitives, 2 items) → parallel-reconciliation; per-wave handover overhead (Item 5) deferred to upcoming `writing-handover` skill — **partially covered**
- **C9** (live-fire incident response, 1 item) → incident-response → **fully covered**
- **C10** (strengths needing action, 3 items) → triage skill / ER1 Step 6 elevation / Item 33 → **audit-only, Phase 7 implementation tasks**
- **C11** (strengths cleanly preserved, 3 items) → C11 already shipped (v2 carries DONE_WITH_CONCERNS, memory-vs-skill precedence); Item 41 carryforward port covered by C6 research — **handled**

##### Headline cross-cutting findings

1. **D-A ADR is fully grounded** — Option C scoped 5-gate ship in v2.0 has 5/5 enterprise consensus across multiple hook-design heuristics + working ADR draft inside R-A. Single highest-leverage decision; resolves 13 audit items in one architectural move.
2. **D-E un-defer recommended** — proposing-patterns research surfaces direct Item 41 STRENGTH evidence ("most carefully engineered subsystem in v1") to ship the v1 incident-loop carryforward in **v2.0.x not v2.1**, contradicting ADR-001 G3's earlier defer.
3. **D-F splits cleanly** — fix-time-hash-check skill ships advisory in v2.0 (low risk; never blocking); the PostToolUse Builder hook joins the D-A architectural bundle as one more PreToolUse-or-PostToolUse hook. D-F is no longer one decision; it's a skill (now) + a hook (with D-A).
4. **R-F (D-B) eval is ready to run** — 3 corpora, 15 test cases, double-evidence design including adversarial rationalization-encouragement priming. The eval IS the gate to D-B; running it is mechanical from here.
5. **Three findings update prior assumptions** that should propagate back into citation manifests / ADRs:
   - **PF v1's hash normalization grammar is enterprise-consensus**, not bespoke — Rollbar + Datadog independently corroborate verbatim. Update `compute-root-cause-hash.sh` README + `sp-anthropic-citation-manifest.md` accordingly.
   - **Microsoft Engineering Playbook is a direct 1:1 analog** for `implementation-decision-log` (was previously assumed PF-original).
   - **`sp-anthropic-citation-manifest.md` GAP-3 framing needs update** — proposing-patterns *composition* is PF-original; *components* are enterprise-cited 9/11.

#### Wave 3 (3 Sonnet, in-flight, 2026-04-30 afternoon)

**`skill-design-triage-v2-shape.md`** (Sonnet, 413L)
- **Prompted by:** Audit Items 7 + 26 + Cluster C10 — v1 has triage skill (preserved as STRENGTH); v2 has none. Plus Item 26 bypass-prone (skip-triage-on-bug-shape-prompts). Structural decision needed: port v1 / extend tier-selection / write new.
- **Findings:** 9 sources (1 Anthropic — Building Effective Agents routing pattern verbatim; 6 enterprise/OSS — Google SRE Ch. 12, PagerDuty ×2, ITIL 4, Atlassian, Kubernetes, Linear; 2 SP-internal — systematic-debugging Phase 1 + 2). WebFetch denied; external quotes WebSearch synthesis. **Structural verdict: Option C — write NEW triage skill, distinct from v1 port.** All six enterprise frameworks treat triage as standalone routing classifier preceding sizing (not part of sizing); extending tier-selection (Option B) would collapse two concerns every framework separates; porting v1 (Option A) produces binding-rule violation (v1 has no Anthropic citation, no incident-response branch, uses "Deputy" role language) — correcting all three is functionally a new write. **Top-3 recs:** (R1) Anthropic routing pattern is the binding citation — "Routing classifies an input and directs it to a specialized followup task" — same escape-valve as incident-response + post-mortem; (R2) new skill integrates 3 v2 artifacts v1 never had: SEV1/2 live-fire branch to `incident-response` as Step 2 + BC-1–BC-10 bug-class categorization from R-E as Step 3 + HARD-GATE blocking `tier-selection` invocation before Step 4 confidence-threshold (makes triage the clean PreToolUse hook anchor for Item 26 in the D-A bundle); (R3) `tier-selection` already has correct cross-reference ("Triage first; tier-select on the root cause") — new triage Step 5 makes this bidirectional, no amendment to tier-selection needed.
- **Status:** PENDING-IMPLEMENTATION (Workstream H of Pass 2 plan; structural verdict resolves the open question in H2). Decision-shaping consequence: D-A bundle should add `production-framework:triage` to the per-rule list as the bug-shape-prompt anchor (currently in R-A's "defer-to-v2.1" bucket per Item 26 pre-condition; new triage skill closes that pre-condition).

**`skill-design-writing-handover.md`** (Sonnet, 332L)
- **Prompted by:** Audit Item 5 + Cluster C8 + originally-planned Phase D wave 2 skill — per-wave handovers are write-once-read-never when QA cadence is phase-end-only.
- **Findings:** 13 distinct URL citations (9 external + 3 internal PF + 1 compound AI-dev-framework survey: SP, Cursor, Aider, Codex). **SP precedent: zero — confirmed.** SP 5.0.7 ships no handover artifact; binding citation is Anthropic *Effective Context Engineering* §2.17 (file artifacts as cross-agent comms substrate). **K/N cadence consensus: 5/9 support rolling-single-doc with milestone finalization** (BINDING per N≥5); **0/9 support per-wave-immutable** as default state-artifact pattern — directly contradicts PF v1 default. **Top-3 recs:** (R1) **default to rolling-single-doc finalized at phase-end** — one file per phase; Builder updates per wave; frontmatter `status: AWAITING_QA` flips to `QA_PASSED` at phase close (Keep-a-Changelog finalization analog); (R2) expose `qa_cadence: per-wave` as conditional flag — when plan declares it, produce separate per-wave files (current PF v1 behavior preserved); default is rolling (PagerDuty configurable-rotation precedent); (R3) append-only `## Phase History` table at bottom of rolling doc — one row per wave (date, builder, key additions, status-flag changes); provides wave provenance without per-wave separate files; replaces audit-trail function of per-wave separate docs.
- **Status:** PENDING-IMPLEMENTATION (Workstream H1 of Pass 2 plan; cadence verdict resolves Item 5).

**`skill-design-stack-patterns-extensions-2026-04-30.md`** (Sonnet, 609L)
- **Prompted by:** Cluster C4 (Items 9-partial, 10, 11, 12, 20-partial) — 5 stack-conditional patterns from PF v1 production data; Item 10 is 3rd recurrence.
- **Findings:** 30 source-table entries across 5 patterns (P1: 7, P2: 7, P3: 5, P4: 6, P5: 5; all ≥3 per pattern); 23 direct + 7 WebSearch synthesis (tagged for re-verification). **SP no-precedent: confirmed** (zero hits in `skills/**/*.md` for any C4 pattern). **Top recurrent finding:** **Pattern 1 (Next.js client/server boundary) is the only pattern meeting the auto-ratifiable BP threshold at 3x recurrence** — grep NR-1 (`server-only` import + named export + no declaration) is the Code-Reviewer pre-flight stop-the-review condition. **Pattern 2 (React state-setter closure-flag)** is 1x internal but **7/7 BINDING enterprise** (react-mentions + text-expander-element) — qualifies as proposal-candidate under the **BINDING N/N≥5 Path B ingest** from `skill-design-proposing-patterns.md` (first independent test of Path B broadening). **Pattern 3 (console-errors-clean)** has no deterministic grep — Playwright execution is sole enforcement; **D19 (console-errors-clean) + `browser-driven-verification` skill ship as a pair**. **Pattern 4 (service-role/RLS bypass)** extends existing template row #4 with arch-doc-time depth at 7VQ Q3 (no new grep — arch-doc-time gate). **Top-3 implementer recs:** (R1) ship NR-1 + Builder HR-1 first — only 3x-recurrence pattern; highest leverage in C4; (R2) Add Gate-3 D19 wired to `browser-driven-verification` skill — pair; (R3) extend 7VQ Q3 with Pattern 4's client-shape-naming requirement ("name the client shape that activates the auth model + the import path that produces it") — closes G-CRIT-1 arch-doc/impl gap from PF v1.
- **Status:** PENDING-IMPLEMENTATION (Workstream F of Pass 2 plan; D19 + browser-driven-verification dependency now explicit; first auto-test of Path B ingest in Pattern 2).

#### Phase 6 — Post-Research Findings Digest Addendum (Wave 3, 2026-04-30)

[Wave 3 closure — appended to the prior Wave 1+1.5+2 digest. Updates cluster-coverage map and headline findings; does not edit prior entries.]

| # | Research → Solves | One-liner finding |
|---|---|---|
| 12 | `triage-v2-shape` → Items 7 + 26 / **Cluster C10** | 9 sources; **Verdict: Option C — write NEW triage skill** (not port v1, not extend tier-selection); routes via Anthropic Building-Effective-Agents routing pattern; 3 v2-only integrations: SEV1/2 → incident-response Step 2; BC-1–BC-10 → Step 3; HARD-GATE blocking tier-selection invocation → Step 4 (D-A anchor for Item 26). |
| 13 | `writing-handover` → Item 5 / **Cluster C8** | 13 distinct citations; **5/9 BINDING on rolling-single-doc with milestone finalization**; **0/9 support per-wave-immutable** as default (directly contradicts PF v1); rolling-doc default + `qa_cadence: per-wave` conditional flag + append-only `## Phase History` table for wave provenance. SP ships zero handover artifact — falls back to Anthropic ECE §2.17 file-artifact precedent. |
| 14 | `stack-patterns-extensions` → 5 items in **Cluster C4** | 30 source-table entries across 5 patterns; **Pattern 1 (Next.js boundary) is auto-ratifiable BP at 3x recurrence**; **Pattern 2 (React state-setter) qualifies for Path B ingest** (7/7 BINDING enterprise — first independent test of proposing-patterns broadening); D19 (console-errors) + browser-driven-verification ship paired; Pattern 4 client-shape-naming extends 7VQ Q3 (no new grep — arch-doc-time gate). |

##### Updated cluster coverage map (Wave 3 deltas)

- **C4** (5 stack-conditional items) → was "deferred"; **now fully covered** by `stack-patterns-extensions` research; ready for Workstream F of Pass 2 plan.
- **C8** (orchestration closing primitives + handover cadence) → was "partially covered"; **now fully covered** — Item 5 cadence verdict resolves the open question (`writing-handover` ships rolling-default).
- **C10 Items 7, 26** (triage strength + skip-triage-on-bug-shape bypass) → was "audit-only / partial"; **now fully covered** — Option C verdict locks in NEW triage skill; D-A bundle now adds `production-framework:triage` as the bug-shape-prompt anchor (was Item 26's deferred-to-v2.1 entry per R-A).

##### Headline cross-cutting findings (Wave 3 closure)

1. **First independent test of `proposing-patterns` Path B is built into Wave 3.** Pattern 2 (React state-setter closure-flag) has 1 internal incident + 7/7 BINDING enterprise grounding — qualifies under Path B (BINDING research) but NOT Path A (incidents). Pattern 1 (Next.js boundary) has 3 internal incidents — qualifies under Path A. **Wave 3 produced one Path-A and one Path-B candidate simultaneously** — the broadening's value proposition is empirically demonstrated.
2. **D-A bundle scope expands: add `triage` to gated rules.** R-A originally placed `triage` (Item 26) in the "defer-to-v2.1" bucket because v2 had no triage skill. The triage research's Option C verdict eliminates that pre-condition — the bug-shape-prompt anchor moves from defer-to-v2.1 → gate-in-v2.0. Update the per-rule recommendation table in the ADR-002 draft.
3. **Workstream F + Workstream B6 are now coupled.** D19 (console-errors-clean Gate-3 dimension) and `browser-driven-verification` skill ship as a pair per Pattern 3's verdict — neither works without the other (no deterministic grep exists for hydration-class console errors; Playwright execution is the only enforcement). Update Workstream A item A5 to depend on Workstream B item B1 ordering.
4. **PF v1 default cadence is enterprise-contradicted.** 0/9 enterprise frameworks support per-wave-immutable handovers as default; PF v1's per-wave default produces the write-once-read-never docs Item 5 flagged. The rolling-default pattern moves PF closer to Atlassian / GitHub / Google SRE shift-handover / PagerDuty conventions. Document in ADR-001 G3 update.
5. **Wave 3 closes the audit's research-warranted set.** All clusters that benefited from research are now researched. Remaining audit items either (a) have grounded recommendations (Workstream A amendments) or (b) are blocked on D-A through D-E user decisions. Pass 2 implementation is fully unblocked on the research side.

#### Wave 2 (3 in flight, 2026-04-30)
- **`skill-design-proposing-patterns.md`** (Opus). v1 carryforward + broadened ingest (incidents OR BINDING research). For D-E. Awaiting return.
- **`skill-design-ratify-pattern.md`** (Sonnet). v1 carryforward; user-gated 6 mechanical gates. For D-E. Awaiting return.
- **`skill-design-fix-time-hash-check.md`** (Opus). NEW skill closing incident-loop fix-time gap. For D-F. Awaiting return.

---

## Incident Table

[Append-only. Each remediation/post-mortem adds a row. `root_cause_hash` computed via `compute-root-cause-hash.sh` (PF v1 — port pending per D-E).]

| Principle | Incident | Impact | root_cause_hash |
|---|---|---|---|
| ER1 Step 6 use-case-fit check | 7/7 OAuth incident (PF v1, earlier session) — would have cargo-culted server-side OAuth pattern; use-case-fit check rejected the consensus | Multi-day Tier 3 phase avoided | (port pending) |
| Bypass-prone discipline | Mention-picker bug (PF v1, 2026-04-30) — assistant skipped tier-selection post-`/compact`; did local-patching instead of enterprise research | Wrong fix shipped; user redirection required | (port pending) |
| Bug-fix path symptom-mask | Mention-picker first-pass speculative fix (PF v1, 2026-04-30) — would have PASSED `verification-before-completion`; user caught it post-deploy | Near-miss; framework would have signed off | (port pending) |
| QA missed React state-setter timing | task-table-v2.tsx `onItemCreated` closure-flag pattern (PF v1, 2026-04-29) — QA rated PASS; bug shipped to prod | Pagination footer drift to "Showing N of N-1" on every realtime INSERT | (port pending) |
| Builder client/server boundary | `getNotificationHref()` added to `notifications.ts` (PF v1, 2026-04-28) — Turbopack pulled server-only into client bundle | Hotfix commit required; **3rd recurrence** per user-memory `feedback_url_codec_server_import.md` | (port pending) |
| Arch-doc auth-model not validated | Search-G G-CRIT-1 (PF v1, 2026-04-28) — arch doc said `SECURITY INVOKER` but impl used `supabaseAdmin` (RLS bypass) | Within-tenant visibility leak; caught at QA | (port pending) |
| Hydration error class accumulates | React #418/#419 (PF v1, ongoing) — visible across many ship cycles; never caught because each cycle audits only its own changes | Silent SSR-perf regression accumulating | (port pending) |

---

## Regression Scope Catalog

[Reusable across phases — what touches what. Add a row when a module-crossing dependency is discovered.]

| Feature / Module | Depends on | Depended on by |
|---|---|---|
| `enterprise-research-first` skill | citation manifest | `seven-validation-questions` Q2, `writing-arch-doc` interaction-model check, `find-similar-implementations` (Wave 1) |
| `seven-validation-questions` skill | `enterprise-research-first`, `gate-3-production-check` (sibling) | `cto-mode` step 2.5 |
| `gate-3-production-check` skill | STACK-PATTERNS slot vocabulary, `verification-before-completion` | `cto-mode` step 5, `finishing-a-development-branch` |
| 12 agents | per-role research docs, STACK-PATTERNS, model matrix | `cto-mode` dispatch graph |
| STACK-PATTERNS template | citation manifest, agent research | every agent that cites stack-conditional rules; gate-3 D9/D15/D17 dimensions |
| PROJECT-PLAN.md (this file) | audit, research artifacts | Phase 7 implementation; Phase 8 verification; future contributors |

---

## Maintenance protocol

- **Update Phase Status** after each major phase transition.
- **Append to "Research performed"** every time a researcher returns. Each entry leads with `**Prompted by:**` (the trigger — phase need / audit item / architectural decision). If implemented in a shipped artifact, link the artifact and mark `Status: IMPLEMENTED`. If not yet implemented, mark `Status: PENDING-IMPLEMENTATION` and the row stays here until it lands.
- **Write a Post-Research Findings Digest** at the end of every phase that completed a research wave (or set of waves). The digest contains:
  1. **One-liner findings table** — rows = artifacts, columns = `Research → Solves` (cluster + audit items) and `One-liner finding` (the load-bearing recommendation, K/N consensus, structural verdict).
  2. **Cluster coverage map** — for each audit cluster touched in the phase, mark `fully covered / partially covered / audit-only / deferred`.
  3. **Headline cross-cutting findings** — 3–7 findings that span multiple artifacts, surface architectural-decision-shaping evidence, or update prior assumptions in citation manifests / ADRs.
  This is the executive view of the phase. The per-artifact entries above the digest are the durable detailed record; the digest is the consolidation that makes the next phase's decisions actionable.
- **Append to Incident Table** after every remediation cycle (Phase 7 will trigger this for the v1 carryforward incidents).
- **Update Open Findings** as findings close — never delete a row; add a `Status: RESOLVED` column note + link to the resolving artifact.
- **Do not edit prior entries.** Append-only log. If a finding turns out wrong, add a new entry referencing the prior one.
