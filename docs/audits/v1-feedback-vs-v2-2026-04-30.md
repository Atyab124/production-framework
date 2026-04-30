# v1 Feedback Audit vs v2 Already-Shipped

**Date:** 2026-04-30
**Source:** User-provided 33+ item feedback log from PF v1 in production use (TaskIt — Next.js 16 + Supabase + shadcn; sessions 2026-04-28 to 2026-04-30; truncated at Item 33).
**Auditor:** v2 designer, post-shipping of (12 agents + STACK-PATTERNS template + 3 foundational skills) and BEFORE writing the remaining 6 Phase D skills.
**Methodology:** Two-pass per the agreed approach. **This is Pass 1: audit each item against already-shipped v2 — does the research-grounded redesign accidentally solve the v1 friction?** Pass 2 (next): bake unresolved gaps into the remaining work.

**Verdict legend:**

- **STRENGTH** — user-identified working primitive in v1; verify it survived in v2.
- **CONVERGENT** — v2 independently solves the friction. Cite the artifact + line.
- **PARTIAL** — v2 covers part; gap remains.
- **GAP** — v2 does not address; needs bake-in.
- **META** — pattern across multiple items; architectural decision required.
- **OUT-OF-SCOPE** — v1 hook/structural concern; not relevant to v2's skill+agent shape.

---

## Convergence Summary

| Verdict | Count | Items |
|---|---|---|
| STRENGTH (preserve) | 4 | #4, #6, #7, #33 (truncated) |
| CONVERGENT | 5 | #6, #8 (precedence), #14 (corrected), #18 (foundational primitive in CTO mode), #25 (plan dir cite by ref) |
| PARTIAL | 8 | #1, #3, #4 (elevation), #9, #11, #12, #28, #32 |
| GAP | 13 | #5, #10, #11 (React state-setter), #15, #16, #19–24 (most), #26, #27, #28, #29, #30, #31 |
| META | 3 | #17, #18, #28 |
| OUT-OF-SCOPE | 2 | #2 (v1 structural-check), #25 (v1 plan dir rule) |

**Headline numbers:**

- **5 of 33 items already CONVERGENT** — v2's research-first redesign hit ~15% of v1's friction points without seeing the feedback. Modest but real validation; the design isn't a drop-in fix.
- **8 PARTIAL + 13 GAP = 21 items needing v2 work.** Roughly 2/3 of v1 friction survives into v2 unless we bake in.
- **The biggest single architectural decision surfaced** is META: the bypass-prone discipline class (Items 14, 15, 17–27, 26, 27). v2 inherits SP's discipline-based enforcement; the user proposes a sweep of `PreToolUse` hook gates. This is a v2.0-vs-v2.1 decision that should be made explicitly, not by default.
- **3 entirely new skills are surfaced** that aren't on the Phase D list: `browser-driven-verification` (Playwright), `parallel-reconciliation`, `incident-response` (live, distinct from post-mortem). Each is independently load-bearing per the user's traces.

---

## Item-by-Item Audit

### Item 1 — Schema verification gap in `writing-arch-doc` [HIGH friction]

- **v1 symptom:** arch-doc proposed `teams` table that didn't exist in TaskIt schema (actual table: `departments`).
- **v2 status:** **GAP.** `agents/architect.md` requires Multi-tenant isolation table, Quality-attribute matrix, Container/Component diagram, Data Contracts section — but **no schema-existence probe**. Grep for `schema|information_schema|verify.*table|probe.*entity` in architect.md returns 2 hits, both about isolation model rows, not table-existence.
- **Action:** Extend architect.md (or the SP-inherited `writing-arch-doc` skill) with a "verify entity model exists" step requiring evidence (probe output OR file:line citation in source) that each referenced table exists.
- **Bake-in:** v2 architect.md amendment (NOT a new skill). Cheap fix.

### Item 2 — `structural-check` wave-seam noise [MEDIUM friction]

- **v1 symptom:** false positive `recordRecentlyOpened exported but never imported` between waves.
- **v2 status:** **OUT-OF-SCOPE.** v2 inherits SP's hook system (no `structural-check.sh`). The wave-seam concept doesn't exist in v2 — Phase 1 only has SessionStart + agent-return-parse hooks. If multi-wave cycles return to v2 via cycle-state.md, the same friction could re-emerge.
- **Action:** None for v2.0. Note for future hook design: any wave-aware structural check must read cycle-state.md to determine phase boundary.

### Item 3 — Debugger anchoring on prompt's first hypothesis [HIGH friction]

- **v1 symptom:** Faisal notification bug — Debugger took prompt's first hypothesis (create paths) and missed UPDATE path (`assignUser`). User said "added him" (mutation), not "created with him."
- **v2 status:** **PARTIAL.** `agents/debugger.md` line 50 says `**Symptom** — what the user reported, verbatim`. Acknowledges user-report-as-evidence. Has SP's "5-step backward call-stack tracing." But **no explicit rule "the user's language is ground truth — the prompt's first hypothesis may be wrong; widen before narrowing."** No `enumerate every code path that COULD produce the symptom, then narrow` step.
- **Action:** Extend debugger.md with: (a) "User-language-as-ground-truth" rule citing the user's verb ("added", "after I changed", "when I clicked") as a constraint on the search frontier; (b) "Widen before narrow" step — enumerate all paths matching the symptom verb before picking one.
- **Bake-in:** v2 debugger.md amendment.

### Item 4 — `enterprise-research-first` Step 6 is the highest-leverage check [HIGH STRENGTH]

- **v1 strength:** Step 6 (use-case-fit check) saved 4+ sessions from cargo-culting BINDING patterns.
- **v2 status:** **CONVERGENT (preserved) + PARTIAL (elevation).** Step 6 carried forward verbatim with the 7/7 OAuth incident in `skills/enterprise-research-first/SKILL.md` lines 96–116. **Not yet "elevated to top-level"** — i.e., not pulled out as a standalone skill that other skills (`writing-arch-doc`, `writing-plan`, `seven-validation-questions`) reference explicitly.
- **Action:** Either (a) keep as Step 6 and explicitly cross-reference from `writing-arch-doc` + `seven-validation-questions Q2` (which already cites ER1 — partial elevation), OR (b) extract as standalone `use-case-fit-check` skill. Recommend (a) for v2.0 — extraction is a v2.1 refactor.

### Item 5 — Per-wave handover overhead [LOW friction]

- **v1 symptom:** plan §14 produces W1+W2+W3+phase-end handovers when QA is phase-end-only. Per-wave handovers write-once-read-never.
- **v2 status:** **GAP.** `writing-handover` is on the Phase D list, not yet written. The v2 cto-mode skill currently makes no statement about per-wave vs phase-end cadence.
- **Action:** Bake into the upcoming `writing-handover` skill — make handover cadence conditional on a "QA-cadence" plan flag. Default to ONE rolling handover updated per wave, finalized at phase end. Per-wave separate docs only if the plan declares per-wave QA.

### Item 6 — `parsing-agent-returns` `DONE_WITH_CONCERNS` is load-bearing [HIGH STRENGTH]

- **v1 strength:** `DONE_WITH_CONCERNS` kept R3↔R5 cross-surface tension visible.
- **v2 status:** **CONVERGENT.** Four-token grammar preserved verbatim. `seven-validation-questions/SKILL.md` line 188 enumerates all four; `gate-3-production-check/SKILL.md` enforces D2/D8/D10/D14 as BLOCKED-only (not DONE_WITH_CONCERNS) — strengthens the token's discrimination.
- **Action:** Document the v2 status of DONE_WITH_CONCERNS as "intentionally distinct, load-bearing" in the agent-return-parse hook commentary so future contributors don't collapse it.

### Item 7 — Triage skill prevented over-tiering [MEDIUM STRENGTH]

- **v1 strength:** four UI bugs collapsed to three root causes via triage; correctly Tier-1 instead of Tier-2.
- **v2 status:** **PARTIAL.** v2 inherits SP's `systematic-debugging` skill. v2 has no `triage` skill explicitly; the closest is `tier-selection`. The "collapse symptoms to root causes BEFORE tiering" discipline isn't named.
- **Action:** Either (a) add a step to `tier-selection` SKILL.md: "If multiple symptoms, dispatch debugger first to collapse to root causes, THEN tier the root-cause set, not the symptom set" — OR (b) add a `triage` skill on the Phase D list. Recommend (a) — cheaper, sits in the right place.

### Item 8 — Memory-vs-skill drift, no precedence rule [MEDIUM friction]

- **v1 symptom:** `feedback_token_identity_vs_consent.md` overlaps with ER1 Step 6; no precedence rule.
- **v2 status:** **CONVERGENT.** `skills/using-production-framework/SKILL.md` lines 80–82 has the explicit precedence: User instructions > Production-framework skills (universal rules) > Project memories. "If a memory conflicts with a framework skill on universal-rule territory, the skill wins."
- **Action:** None. v2 already solved this.

### Item 9 — Arch-doc invariants don't validate impl auth model [HIGH friction]

- **v1 symptom:** Search-G arch doc said `SECURITY INVOKER` so RLS applies, but implementation used `supabaseAdmin` (service-role) which bypasses RLS. Result: G-CRIT-1 within-tenant visibility leak.
- **v2 status:** **PARTIAL.** `agents/architect.md` requires Multi-tenant isolation table per AWS SaaS Lens silo/pool/bridge. `seven-validation-questions/SKILL.md` Q3 requires "tenant scope enforced at the data layer." Neither requires **naming the client shape that activates the auth model** (user-scoped vs service-role+manual-filter vs RPC with `p_user_id`). v2 security-compliance.md HARD-GATE on RLS-before-ship + STACK-PATTERNS multi-tenant grep #4 (`service_role` in client-reachable code) catch part of this at later stages.
- **Action:** Strengthen Q3 of `seven-validation-questions` AND architect.md: require auth-model answers to (a) name the auth model, (b) name the client shape that activates it, (c) cite the helper/import path that produces that client shape. Add a STACK-PATTERNS multi-tenant pattern row: "Service-role clients bypass RLS — never use service-role admin client for read paths gated by RLS without explicit `p_user_id` parameter and visibility check inside the RPC."
- **Bake-in:** seven-validation-questions Q3 amendment + STACK-PATTERNS extension + architect.md amendment.

### Item 10 — Builder client/server boundary violation [HIGH friction, recurrent]

- **v1 symptom:** Builder added `getNotificationHref()` to `notifications.ts` (already imports server-only modules) → Turbopack pulled server-only deps into client bundle → prod build failed. Identical incident already in user-memory `feedback_url_codec_server_import.md` ("3x prior Builder failure"). Builder didn't pull that memory.
- **v2 status:** **GAP.** v2 STACK-PATTERNS has `Builder Stack-Specific Hard Rules` section but no client/server boundary rule. v2 builder.md inherits SP precedent but doesn't gate on transitive server-only imports. v2 has no structural check.
- **Action:** Three-part fix per user's proposal:
  1. Add stack-specific anti-pattern row to STACK-PATTERNS Next.js extension example: "Files exporting helpers that may be imported from client components MUST NOT transitively import `server-only`, `next/cache`, `next/server`, supabase admin client, or Sentry server SDK."
  2. (Optional v2.x hook) Structural check scanning `.ts`/`.tsx` for transitive server-only imports + named exports + missing `import "server-only"` declaration.
  3. Builder agent amendment: "Before adding any export to an existing module, verify it does not import `server-only` (directly or transitively); if it does, propose a client-safe sibling file."

### Item 11 — QA missed React state-setter timing bug [MEDIUM friction]

- **v1 symptom:** Closure-flag pattern in `task-table-v2.tsx` — `let inserted = false; setX(prev => { ... inserted = true; ...}); if (inserted) ...`. React state-setter updater is async; `if (inserted)` always read `false`. QA rated PASS based on visual inspection.
- **v2 status:** **GAP.** v2 qa.md is universal — no React-specific reasoning step. STACK-PATTERNS has no React state-setter rule. Stack-specific by definition; belongs in the project's STACK-PATTERNS.md.
- **Action:** Add to STACK-PATTERNS React/Next.js extension example as a stack-specific anti-pattern: "Never read a flag mutated inside a `setState(prev => ...)` updater on the line after the setter — the updater runs later. Compute the decision SYNCHRONOUSLY via a ref to current state, OR move the dependent state into the same updater." Add corresponding grep pattern: `let \w+ = false; set\w+\(prev =>` for Code-Reviewer pre-flight.

### Item 12 — Pre-existing recoverable hydration error registry [LOW friction]

- **v1 symptom:** React #418/#419 visible across multiple ship cycles, never caught because each cycle audits only its own changes.
- **v2 status:** **PARTIAL.** v2 gate-3-production-check has D15 (build/test/lint clean — no debug artifacts) and D9 (performance budget) but no console-errors-clean dimension. The 18 dimensions don't include "production console clean of pre-existing recoverable React errors."
- **Action:** Add a sub-criterion under D15 OR a new D19: "On every route touched by this ship, browser console messages contain no React errors — including pre-existing #418/#419/recoverable-hydration. Pre-existing errors are filed as separate findings, not absorbed silently." Cheap to enforce via Playwright (Item 16 dependency).

### Item 13 — Compact-self-bypass (CORRECTED by Item 14) [HIGH friction]

- **v1 corrected:** SessionStart hook DOES fire on `/compact` (verified by user). Actual failure was self-bypass of tier-selection.
- **v2 status:** **CONVERGENT (corrected interpretation).** v2 inherits SP's session-start hook + bootstrap. Same bootstrap behavior. The actual failure surface is the same as Item 14/15.
- **Action:** None on v2's bootstrap loading. See Item 15 for the real fix.

### Item 14 — Self-bypass of tier-selection [HIGH friction]

- **v1 symptom:** Bootstrap loaded; assistant read directive `Invoke production-framework:tier-selection`; skipped it; jumped to `systematic-debugging` for mention-picker bug. Tier-selection would have flagged it as Tier 3 → arch-doc → ER1 → 7/7 BINDING fix.
- **v2 status:** **PARTIAL → META gap.** v2 has tier-selection skill (SP-inherited). v2 cto-mode skill has explicit "Step 1 — Classify the task — invoke `cycle-selection` skill." But cto-mode is read-once-at-bootstrap; nothing prevents the assistant from skipping the invocation.
- **Action:** Per Item 15. This becomes the canonical instance for the META decision.

### Item 15 — `PreToolUse` hook gating Edit/Write on tier-selection invocation [HIGH proposal, ARCHITECTURAL]

- **v1 proposal:** Hook reads session-state file (`.claude/framework-state.json`); blocks `Edit|Write` if `tier_selection_invoked_at` missing OR older than the latest user-prompt timestamp. Bypass via `FRAMEWORK_ALLOW_TIER_BYPASS=1`.
- **v2 status:** **GAP — META decision required.** v2 has zero `PreToolUse` hooks (verified — `hooks/hooks.json` only registers SessionStart + agent-return-parse). Per CLAUDE.md rejection criterion #5: "Add a new hook without MAJOR version bump + architecture doc justifying it" → blocked. New hooks require v3.0 OR an explicit ADR for v2.0.
- **Action:** Decide: (A) defer to v2.1/v3.0 with ADR; (B) bake into v2.0 with full ADR + binding rule citation; (C) reject and rely on discipline. Per the user's data ("self-bypass IS the recurring failure mode"), (A) or (B) is correct; (C) reproduces the bug. **User decision required.**

### Items 17 / 18 — META: bypass-prone discipline is widespread [HIGH META]

- **v1 finding:** 8 `RULE(prompt)` in v1 `core/rules.md` + an unspecified subset of 11 `RULE(skill:*)` whose invocation is discretionary. Pattern, not single defect.
- **v2 status:** **GAP — META.** v2 doesn't have `core/rules.md` (skills replace rules); but the same bypass surface exists. Skills like `tier-selection`, `brainstorming`, `enterprise-research-first`, `triage`, `seven-validation-questions` are summoned by assistant initiative; nothing gates them.
- **Action:** Treat as a hook-gate audit project for v2 (per Items 19–27 below). Decide on the architectural envelope FIRST (v2.0 ADR + ≥1 hook OR defer all to v2.1).

### Items 19–27 — Specific bypass-prone instances

- **#19 Tool Selection Chain (MEDIUM):** v2 GAP. SP/v2 has no rule equivalent. Could be added if the v2 hook-gate decision lands. Lower priority.
- **#20 Env separation (LOW):** v2 GAP. Stack-specific; belongs in STACK-PATTERNS as a Code-Reviewer pre-flight grep, not a hook.
- **#21 Destructive ops (HIGH):** v2 GAP. Claude Code's existing destructive-action heuristics handle some cases; v2 hook would add project-aware version. Worth shipping in v2.0 if the META decision lands.
- **#22 Phase-break before code (MEDIUM):** v2 GAP. Maps to PROJECT-PLAN.md "current phase" marker — v2 PROJECT-PLAN template has Phase Status table. Hook-able.
- **#23 Update plan after phase (MEDIUM):** v2 GAP. Maps to PROJECT-PLAN structure. Hook-able.
- **#24 Don't start next phase until gated (HIGH):** v2 GAP. PROJECT-PLAN Open Findings table has Severity column; hook can read.
- **#25 Save plans to configured directory (LOW):** v2 PARTIAL. v2 has no CONFIG.yaml; SP convention is `docs/plans/`. Could enforce trivially.
- **#26 Skip triage on bug-shaped prompts (HIGH):** v2 GAP. Plus v2 doesn't have a `triage` skill yet (Item 7 partial fix). Pre-condition: ship triage discipline first.
- **#27 Skip brainstorming HARD-GATE on creative prompts (HIGH):** v2 GAP. v2 inherits SP brainstorming HARD-GATE which fires once skill runs but can't fire if skill never invoked. Same shape as Item 15.

### Item 28 — Bug-fix path missing enterprise verification of the FIX [HIGH friction, META]

- **v1 finding:** `enterprise-research-first` is scoped to pre-design ("before deciding new interaction model, data shape, ..."). Never invoked from bug-fix path. `triage` and `systematic-debugging` and `verification-before-completion` and `gate-3-production-check` all have zero "compare fix to enterprise pattern" check. Mention-picker race + notification badge-vs-list both required user redirection to reach the consensus answer.
- **v2 status:** **PARTIAL — meaningful gap.** Verified by grep: `skills/enterprise-research-first/SKILL.md` "When to Use" lists interaction model / data shape / sync strategy / module location / API contract — **does NOT include "before fixing a bug class with documented enterprise solutions."** The narrative in line 8 mentions "edge-case bugs" once but no trigger. v2 debugger.md doesn't reference ER1.
- **Action:** Two amendments:
  1. Extend ER1's "When to Use" with: "Before applying a fix to a bug class with ≥3 documented enterprise solutions (closure-staleness, cache-invalidation, optimistic-rollback, hydration-mismatch, race conditions, etc.). Name the bug class; if N≥3 mature OSS / enterprise solutions exist, pull this skill before the fix."
  2. Add a step to debugger.md: "Step 4.5 — Bug-class enterprise check. Before applying the fix: name the bug class; if a class with documented enterprise solutions, dispatch ER1 in parallel; compare proposed local fix to consensus pattern."

### Item 29 — No `parallel-reconciliation` paired with `parallel-dispatch` [MEDIUM gap]

- **v1 finding:** `parallel-dispatch` opens N agents; no closing skill for reconciling N outputs. Manual reconciliation drifts.
- **v2 status:** **GAP.** Verified — `dispatching-parallel-agents/SKILL.md` exists but contains no `reconcil`/`synthes`/`consolidat`/`aggregat` content. v2 cto-mode says "synthesize for user" at step 7 but doesn't prescribe how to reconcile conflicting researcher findings.
- **Action:** Either (a) extend `dispatching-parallel-agents` with a closing `## Reconciling Outputs` section, OR (b) add a new `parallel-reconciliation` skill. Recommend (a) — same skill, paired open/close, single mental model.

### Item 30 — Research findings don't auto-flow to backlog [HIGH gap]

- **v1 finding:** BINDING ER1 findings sit in TodoWrite "pending" with no process check that they should enter PROJECT-PLAN, be tiered, OR proposed as patterns. Composer-parity 6/6, comment-rich-text 7/7, emoji autocomplete 6/6 all unactioned.
- **v2 status:** **GAP.** ER1 has no post-condition for "build-or-defer" or "pattern-proposal-candidate" output.
- **Action:** Add a post-condition to ER1's body: "Before exiting, the researcher MUST propose either (a) a build-or-defer entry with concrete file targets and effort estimate to be appended to docs/PROJECT-PLAN.md, OR (b) a pattern-proposal candidate to be ratified later. The orchestrator records the proposal."

### Item 31 — No incident-response skill distinct from bug-fix [MEDIUM gap]

- **v1 finding:** triage = unclear-root-cause-bug-reports; gate-3 = pre-ship; post-mortem = retrospective. None scoped to live production fire (rollback safety > root cause; minutes-to-resolve > completeness-of-fix).
- **v2 status:** **GAP.** Verified — `agents/post-mortem.md` line 8 explicitly: "incidents that already happened — contributing-factor analysis, blast radius, severity classification, and the canonical incident record." Retrospective-only.
- **Action:** Add a new skill `incident-response` (or `live-incident-response`) to v2 skills list. Body: SRE phases (detect → contain → mitigate → resolve → retro). Composes with `debugger` for diagnose; `writing-handover` for retro doc; hands off to `post-mortem` agent for the retro. Distinct trigger from `triage`: "live production fire affecting users now."

### Item 32 — `verification-before-completion` accepts symptom-mask, not root-cause-fix [HIGH friction]

- **v1 finding:** mention-picker first-pass speculative fix would have PASSED verification because the surface symptom no longer reproduced. Fix targeted symptom, not root cause.
- **v2 status:** **GAP.** Verified — `skills/verification-before-completion/SKILL.md` (SP-inherited) has zero matches for "root cause" / "symptom mask" / "surface fix."
- **Action:** Extend verification-before-completion (PF v2 override of SP, with double-evidence per CLAUDE.md "Skill Changes Require Evaluation" rule): "For bug fixes, the fresh evidence MUST demonstrate (a) symptom no longer reproduces AND (b) the root cause as identified by `systematic-debugging` data-flow trace is no longer reachable. If only (a) is satisfied, the fix is a symptom-mask and must be flagged as such." Per the framework's own rule on overriding SP skills (CLAUDE.md "Skill Changes Require Evaluation"), this needs adversarial pressure tests showing the PF version performs ≥ SP version on the same prompts. **User decision required for v2.0 inclusion.**

### Item 33+ (truncated) — STRENGTH preservation

- **Known:** Item 33 starts "STRENGTH: `stop-debug-scan` hook caught two d..." — truncated.
- **v2 status:** v2 hooks do not yet include `stop-debug-scan` per inspection. v2 inherits SP hooks; SP has no debug-scan hook of this shape. **Likely GAP if the user's strength preservation depends on this.**
- **Action:** Request the truncated portion (Items 33+) so the strengths are auditable.

### Item 16 — No Playwright/browser-driven verification primitive [HIGH gap, NEW SKILL]

- **v1 finding:** Three sessions where Playwright was the load-bearing tool (Hier-2 panel-open false alarm; mention-picker race synthetic-event reproduction; notification store popover verification). Framework prescribed none.
- **v2 status:** **GAP.** Verified by grep — `skills/` contains zero `playwright|browser_` references. Mentions exist only in research docs and tests.
- **Action:** Add a NEW skill `browser-driven-verification` to v2 skills list. Body: when to use (UI/UX deliverables; timing-dependent bugs; static-reasoning-resistant cases); what to capture (snapshot vs screenshot vs evaluate); how to suppress flaky waits (`wait_for` with text not arbitrary `setTimeout`). Cross-link from `verification-before-completion`, `systematic-debugging` Step 4, and `gate-3-production-check` (new dimension or D9 sub-criterion).

---

## Cross-Cutting Findings

### Finding A — Bypass-prone discipline is the largest architectural decision

Items 14, 15, 17, 18, 21, 22, 24, 26, 27 all instance the same pattern: skill X is summoned by assistant choice; assistant rationalizes past it; downstream tool calls fire without the discipline. v2 inherits this from SP's design philosophy. **Three options:**

- **(A) Defer all hook-gating to v2.1.** Cleaner v2.0; reproduces v1's failure mode for early adopters.
- **(B) Ship v2.0 with ≥1 architectural ADR + ≥1 hook gate (most likely tier-selection or triage on Edit/Write).** Materially changes v2.0 scope; needs binding-rule citation per CLAUDE.md.
- **(C) Discipline-only (status quo).** Fast to ship; the user has empirical data this fails.

Recommendation: **(B)** with the tier-selection gate (Item 15) as the canonical instance. The user already has a fully-specified proposal; the framework has the hook plumbing; the binding rule citation is "this is exactly the failure mode that PF v1 traced repeatedly in production." This is the highest-leverage single change to v2.

### Finding B — Bug-fix path needs enterprise-research-first integration

Items 28, 32 together: v2's bug-fix path (triage → debugger → fix → verify) doesn't compare the FIX against enterprise solutions OR validate that the fix targets root cause vs symptom. The user has two empirical incidents (mention-picker race; notification-store) where this gap shipped wrong fixes that user-redirection caught.

**Resolution:**
- ER1 trigger expansion (Item 28 fix) — extends "When to Use" to include bug-class research.
- debugger agent gets Step 4.5 for bug-class enterprise check.
- verification-before-completion gets root-cause-vs-symptom clause (Item 32 fix).

This is a coordinated three-artifact change. Should be bundled.

### Finding C — Three new skills surfaced beyond Phase D list

- **`browser-driven-verification`** (Playwright) — Item 16
- **`parallel-reconciliation`** (or `dispatching-parallel-agents` extension) — Item 29
- **`incident-response`** (live, distinct from post-mortem) — Item 31

Each is independently load-bearing per user's traces. Adding them grows Phase D from 9 skills to 12.

### Finding D — STACK-PATTERNS extensions identified

The user's data surfaces specific stack-conditional rows that should land in STACK-PATTERNS:

- Next.js client/server boundary (Item 10) — file-level `import "server-only"` + transitive scan
- React state-setter async semantics (Item 11) — closure-flag anti-pattern + grep
- Postgres service-role / RLS bypass (Item 9) — already partially in STACK-PATTERNS multi-tenant grep #4; extend with arch-doc-time client-shape-naming
- Console errors clean on touched routes (Item 12) — gate-3 D-X new dimension OR Playwright skill prescription

---

## Recommended Bake-In for Remaining Phase D Skills

| Phase D skill (still to write) | What v1 feedback adds |
|---|---|
| `regression-scope` | Item 16 (Playwright capture per route in regression scope) |
| `rls-aware-migrations` | Item 9 partial (client-shape-aware migration step) |
| `tenant-isolation` | Item 9 (client-shape that activates auth model — explicit naming) |
| `audit-trail` | (v1 feedback didn't surface specific audit gaps) |
| `slo-sli-contracts` | Item 12 (console-error SLO as a frontend SLI) |
| `writing-handover` | Item 5 (one rolling handover, finalized at phase end; per-wave only if QA-cadence flag set) |

## Recommended NEW Skills (beyond Phase D)

1. **`browser-driven-verification`** — Item 16. Playwright as the verification primitive for UI deliverables and timing-dependent bugs.
2. **`incident-response`** — Item 31. Live-fire response, distinct from post-mortem retrospective.
3. **(Optional)** **`parallel-reconciliation`** OR extend `dispatching-parallel-agents` — Item 29. Closing skill paired with the opening.

## Recommended NEW v2.0 Architectural Decisions (require user input)

- **D-A (Item 15 / Finding A): Hook-gate `tier-selection` on Edit/Write?** Y/N + ADR.
- **D-B (Item 32 / Finding B): Override SP `verification-before-completion` with PF v2 root-cause-fix clause?** Per CLAUDE.md, requires double-evidence eval. Y/N + eval plan.
- **D-C (Item 28 / Finding B): Extend ER1 to bug-fix path?** Y (low cost). Bake-in target: ER1 amendment.
- **D-D: Add 3 new skills (Items 16, 29, 31)?** Y (each load-bearing). Bake-in target: 3 new skill bodies.

---

## Items Out of Scope for Pass 2

- Item 2 (v1 structural-check wave-seam noise) — v2 has no equivalent hook; not a v2 problem.
- Item 25 (save plans to configured directory) — v2 has no CONFIG.yaml; SP convention is `docs/plans/`. Trivially enforceable but low priority.
- Items 19–24 if Finding A choice is (A) or (C) — defer to v2.1.

---

## Next Step (Pass 2)

Pass 2 is the bake-in. The user's decisions on D-A, D-B, D-C, D-D determine its shape. **Recommended order:**

1. **Decisions D-C and D-D first** (low-architectural-risk, high-leverage): extend ER1 to bug-fix path; add 3 new skills.
2. **Bake into the remaining 6 Phase D skills** with the per-skill amendments listed above.
3. **Decisions D-A and D-B last** (architectural): hook-gate ADR + verification override eval. May ship in v2.1 if scope creep risks v2.0.
4. **STACK-PATTERNS extensions** (Items 10, 11, 12) shipped alongside the next Phase D wave.

This ordering keeps v2.0 momentum while surfacing the architectural questions for explicit user decision rather than default-by-omission.

---

# Addendum — Items 39–41 (received 2026-04-30, second feedback batch)

Captured per user direction: "just go through it, we will discuss how to implement later." This addendum extends but does not edit the prior audit (append-only). Three items: 1 STRENGTH that materially reinforces Finding A's recommendation; 2 GAPs that surface 3 additional NEW skill candidates + 1 broadening of an existing skill + 4 hook/script-level proposals.

## Item 39 — Reuse + implementation-log: registries exist, lookup + decision-log primitives missing [HIGH friction]

- **v1 finding:** framework provides the WHAT of reuse (`patterns.md`, `STACK-PATTERNS.md`, Rules #4/#5/#42, U-BP-7, U-PP-10) but lacks the HOW. No `find-similar-implementations` skill; no automatic similarity gate before `Write`; no implementation-decision log between `PROJECT-PLAN` (phases) and `STACK-PATTERNS` (codified patterns). Rules #5/#42 fire only on Builder dispatch — orchestrator-direct writes bypass. `proposing-patterns` is gated to ≥3 internal incidents, so BINDING N/N research findings (e.g., `matchRef` 7/7 from text-expander-element + react-mentions) never promote to a `BP-X` row.
- **v2 status:** **GAP — multiple sub-gaps.**
  - No reuse-lookup skill verified by grep over `production-framework-v2/skills/`: zero hits for `reuse|invent|simil|existi|catalog`.
  - No implementation-decision-log primitive in v2 templates. PROJECT-PLAN.template.md tracks Phase Status / Open Findings / Remnant Watchlist / Architecture Documents / Incident Table / Regression Scope — none capture "we chose X over Y because Z" at the helper/primitive grain.
  - v2 inherits SP convention: Rules don't exist as a numbered list; closest analogues are skills. The user's #5/#42 promotion proposal maps to: hardening `find-similar-implementations` from agent-only invocation to a hook-gated discipline.
  - Pattern promotion: v2 has not yet written `proposing-patterns` for v2 — currently inherits SP/v1 framing. The "BINDING research finding qualifies as proposal candidate" broadening is a fresh design point for v2.
- **Action:** Surfaces TWO additional new skills for the v2 list:
  - **`find-similar-implementations`** — invoked before `writing-plans` for any change introducing a new helper/component/hook. Methodology: grep similar fn signatures + similar prop interfaces + similar hook return shapes + name-similarity scan. Output: 5-line table of candidates with reuse-vs-adapt-vs-new judgment per row.
  - **`implementation-decision-log`** — lightweight append-only `docs/IMPLEMENTATION-DECISIONS.md`. Each entry: decision / alternatives / why / commit hash / related pattern row. Builders append after every Tier 2/3 ship; lookup happens during `find-similar-implementations`.
  - Plus an extension to the (future) v2 `proposing-patterns` skill: BINDING research findings (N/N at N≥5) auto-qualify as proposal candidates, parallel to the ≥3-incident path.

## Item 40 — Incident loop gaps: single-pass fixes don't enter table; no fix-time hash check; no cluster scan [HIGH friction]

- **v1 finding (corrected from Items 17/30):** Rule #43 IS machine-enforced (Item 41 STRENGTH). The actual gaps are 6 specific dimensions of the loop:
  - **Gap 40-1:** single-pass fixes (remediation loop = 1) never enter the incident table → clusters never form.
  - **Gap 40-2:** no fix-time hash check. Hash exists for proposal-time dedup; no skill prompts "compute hash, grep PROJECT-PLAN + STACK-PATTERNS, surface prior occurrences" before applying a fix. The closure-stale `mentionQuery` fix has a hash; checking it would have surfaced the React state-setter incident from Item 11 (2026-04-29) — same root-cause class, never reconciled.
  - **Gap 40-3:** Post-Mortem invocation is reactive (loop >1, post-mortem trigger, user request) — no proactive cluster scan that emits "Hash X has 2 occurrences; one more triggers proposal."
  - **Gap 40-4:** No automated stale-pattern retirement scan. `patterns.md` schema declares "Empty incident = candidate for retirement (cargo-cult signal)" — no script implements it.
  - **Gap 40-5:** Research findings bypass the loop. External BINDING (N/N ≥ 5) is at least as strong as 3 internal incidents but doesn't qualify for `proposing-patterns` ingest. (Same broadening as Item 39 fix #3 — two angles, one fix.)
  - **Gap 40-6:** Cross-session incident look-back is manual. Fresh agents don't auto-mine PROJECT-PLAN before fix-proposal.
- **v2 status:** **GAP — most aspects.**
  - v2 hasn't written `proposing-patterns` yet, nor a fix-time hash skill, nor a cluster-scan script. The hashing infrastructure (compute-root-cause-hash.sh) is v1; v2 inherits if Phase D includes it.
  - v2 PROJECT-PLAN.template.md has Incident Table with `root_cause_hash` column (verified line 53–55 from earlier read).
  - Post-Mortem agent in v2 is retrospective-only (verified earlier — line 8 of agents/post-mortem.md).
- **Action:** Surfaces ONE additional new skill + 3 script/hook-level proposals + 1 existing-skill broadening:
  - **`fix-time-hash-check`** (new skill) — invoked before applying any fix: compute root_cause_hash, grep PROJECT-PLAN.md + STACK-PATTERNS.md for matches, surface prior occurrences. ~30-line skill. Composable with `systematic-debugging` Step 4.5 (the bug-class-enterprise-research step from Item 28).
  - **PostToolUse Builder DONE hook** — auto-append a `pending_cluster: true` row even on single-pass remediation. Lets Post-Mortem see the data; doesn't trigger proposal until N=3.
  - **Scheduled cluster-scan script** — groups by `root_cause_hash`, emits proximity warnings; runs as PreCommit or daily.
  - **Stale-pattern retirement scan script** — implements the schema's already-declared rule.
  - **Broaden `proposing-patterns` ingest** to accept BINDING research findings (deduped with Item 39's recommendation).

## Item 41 — STRENGTH: Rule #43 incident-loop machine enforcement is the canonical "harden discipline → machine" example [HIGH-positive]

- **v1 strength:** Rule #43 is **triple-enforced**: `MACHINE(script:structural-check.sh:check_incident_logged) + RULE(agent:deputy) + RULE(agent:post-mortem)`. Compute-root-cause-hash.sh is determinism-tested on every SessionStart. Post-Mortem `Hard invariants` section locks down what it can and can't write. ratify-pattern is user-gated with 6 mechanical gates. End-to-end the most carefully engineered subsystem in v1.
- **v2 status:** **MIXED — strength must be preserved + replicated.**
  - **Preservation:** v2 has the schema (PROJECT-PLAN.template.md Incident Table with root_cause_hash). It has the agent (post-mortem.md). It does NOT yet have the structural-check script for `check_incident_logged`, nor the inherited compute-root-cause-hash.sh, nor a v2 ratify-pattern skill. **These are GAPs in v2** — the strength of v1 won't survive into v2 unless we explicitly port them.
  - **Replication:** Item 41 is the empirical evidence that Finding A (META: bypass-prone discipline) is correctly resolved by hardening to machine gates. The user's argument is direct: "Rule #43 is the proof that the cost is bearable and the payoff is large." This **strongly reinforces** the recommendation to ship D-A (hook-gate tier-selection) in v2.0 with an ADR, rather than defer to v2.1.
- **Action:** Two distinct workstreams surface from this strength:
  - **Port the existing primitives:** add `compute-root-cause-hash.sh`, `structural-check.sh:check_incident_logged`, `proposing-patterns` skill, `ratify-pattern` skill into v2. These are v1 carryforward, well-tested.
  - **Replicate the pattern:** every other architectural decision (Items 14/15/17/18, 21/24/26/27, 32) should look at Rule #43 as the reference shape — what does triple-enforcement (MACHINE + RULE-agent-A + RULE-agent-B) look like for tier-selection / triage / brainstorming / verification-root-cause?

## Updated Convergence + Architecture Picture

### Updated counts (with Items 39–41)

| Verdict | Count (was → now) |
|---|---|
| STRENGTH (preserve) | 4 → **5** (added Item 41) |
| CONVERGENT | 5 → 5 |
| PARTIAL | 8 → **9** (added Item 41 — partial preservation in v2) |
| GAP | 13 → **15** (added Items 39, 40) |
| META | 3 → 3 |
| OUT-OF-SCOPE | 2 → 2 |

### Updated NEW skills surfaced (was 3 → now 6)

1. `browser-driven-verification` — Item 16 (Playwright)
2. `incident-response` — Item 31 (live-fire, distinct from post-mortem)
3. `parallel-reconciliation` (or extend `dispatching-parallel-agents`) — Item 29
4. **`find-similar-implementations`** — Item 39 (NEW)
5. **`implementation-decision-log`** — Item 39 (NEW)
6. **`fix-time-hash-check`** — Item 40 (NEW)

### Updated NEW v1-carryforward primitives required for v2

1. `compute-root-cause-hash.sh` script (port from v1)
2. `structural-check.sh:check_incident_logged` function (port from v1)
3. `proposing-patterns` skill (port from v1, with broadened ingest per Items 39 + 40)
4. `ratify-pattern` skill (port from v1, user-gated)

### Updated architectural picture

**Finding A is materially strengthened.** Item 41 supplies direct empirical evidence that machine-enforcement of bypass-prone discipline is (a) achievable, (b) cost-bearable, (c) load-bearing. This **shifts D-A from a coin-flip-maybe-defer toward ship-with-ADR** because Rule #43 is the existing proof-of-concept inside the user's own production data.

**A second architectural decision class surfaces:** **incident-loop hardening.** Items 39 + 40 + 41 collectively argue for a workstream beyond just "harden the bypass-prone disciplines." The incident loop itself has 6+ specific gaps (single-pass non-recording, fix-time hash check, cluster scan, stale-pattern retirement, research-finding ingest, cross-session look-back). This is a coherent project, distinct from D-A's pre-tool-use hook-gating.

### Two new architectural decisions for the discussion

- **D-E — Port v1's incident-loop primitives + write the v2 proposing-patterns + ratify-pattern skills?** High value (Item 41 evidence), moderate scope (4 carryforward items).
- **D-F — Add a fix-time-hash-check skill + PostToolUse Builder DONE hook for single-pass incident recording?** Closes Items 40-1 + 40-2 + 40-6. Could ship in v2.0 if D-A's hook-gating ADR lands.

D-A through D-F is the now full set of architectural decisions surfaced by both feedback batches. Recommendation reordering for Pass 2:

1. **D-C, D-D** (low-architectural-risk, immediate): extend ER1 to bug-fix path; add 6 new skills (now including 3 from Items 39-40).
2. **D-E** (high-value v1-carryforward): port the 4 incident-loop primitives to v2.
3. **STACK-PATTERNS extensions** (Items 10, 11, 12) shipped alongside.
4. **D-A, D-F** (architectural hook decisions): tier-selection PreToolUse + Builder PostToolUse for incident recording. Now strongly recommended-ship-in-v2.0 per Item 41 evidence.
5. **D-B** (override SP verification-before-completion): still requires double-evidence eval; ship in v2.0 only if eval is fast.

This ordering still keeps the immediate-low-risk work first, but D-A is no longer a coin-flip — it's the smaller-scope half of the workstream that includes D-F.
