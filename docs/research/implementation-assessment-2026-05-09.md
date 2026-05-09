# Implementation-Readiness Assessment — production-framework v2 plan

**Date:** 2026-05-09
**Assessor:** Researcher sub-agent (Tier 3, Research cycle), invoked from CTO main session
**Scope:** Audit every OPEN finding (F-V7..F-V20 + F-01..F-15) plus the v2.2.0 ADR-006 layered design and the IN_PROGRESS Phase 8 sub-items (7/8/9 + Workstream E)
**Inputs read:** see Section 6
**Verdict format per finding:** three axes — priority / plan quality / quoted correctness

---

## Section 1 — Priority recommendation (execution order)

### Production fix tier (ship within 1 week as v2.1.1)

**Selected because each is a 1- to 2-line code change that unblocks a currently-broken path, with zero coupling to the larger v2.2.0 layer work.**

| Order | Finding | Why first |
|---|---|---|
| 1 | **F-V19 (CRITICAL)** — Builder sub-agent reports inability to use Bash/PowerShell/Write | Blocks every Build cycle, every Refactor, every Security-Audit, every Performance, every Migration. Framework's core dispatch shape doesn't work without this. **Highest urgency by blast-radius.** Verifiable in current code: 0/12 agent files declare `tools:` in frontmatter (Grep `^tools:` in `agents/` returned no matches). Builder is the only agent with `isolation: worktree` (frontmatter line 6) — the most likely interaction. |
| 2 | **F-V13 (HIGH)** — Windows path-separator bug in docs/ auto-allow | 2-line fix at `hooks/pre-tool-use:215-217`. Currently every Windows doc-only edit hits the tier-selection gate. Verifiable: case-statement pattern is `*/.framework-state/*\|*/docs/*\|*/.claude-plugin/*` (forward slashes only); Windows file paths arrive with backslashes. ADR-006 prescribes the canonical fix (`FILE_PATH_NORM="${FILE_PATH//\\\\//}"`). Same defect class — same line — fixes 3 paths simultaneously. |
| 3 | **F-V20 (HIGH)** — Sub-agent tier-selection inheritance missing | Hook already parses `SUBAGENT_TYPE` (line 147) for trigger-audit but does not use it to short-circuit the tier-selection gate (line 205-240). 4/4 BINDING citation in research doc (OpenAI Agents SDK, LangGraph, AutoGen, Anthropic multi-agent). Resolves F-V19 if root cause is gate-deny rather than tool-inheritance. Strong case to ship in same production fix as F-V19 because the diagnosis path may converge (gate-deny **is** the F-V19 mechanism — see Section 3 concern). |
| 4 | **F-V9 sub-fix only (HIGH→MEDIUM after split)** — `user-prompt-submit` hook ignores `<system-reminder>` events | Specifically the A2 portion of ADR-006: skip `last_user_prompt_at` write on `<system-reminder>` payloads. Single hook file, ~5-line change. The cycle-state.md half (A1) is bigger and ships in v2.2.0 full layer. Doing only A2 in 2.1.1 captures ~50% of the friction reduction with ~10% of the surface area. |

### Full v2.2.0 layer (ship within 5 weeks)

| Order | Finding cluster | Layer | Notes |
|---|---|---|---|
| 5 | **F-V10** Builder empty-diff gate | D1 | Highest-signal silent-failure detection per WS1. Verb+scope-conditional per WS4 reconciliation (CF2). |
| 6 | **F-V11** Real-user smoke for BC-3/P2/pointer/IME | D2 | Highest-signal verification gap. Adds the missing Anti-Pattern note that contradicts current `browser-driven-verification/SKILL.md:110-112` ("Timing-dependent bugs are reproducible — via synthetic event dispatch"). |
| 7 | **F-V9 cycle-state.md** + cooperating skills (tier-selection / triage / writing-plans / cycle-selection) | A1 | The bigger half. Composes with F-V20 inheritance. Cache-poisoning eval (12 prompts × 4 attack classes) per WS4 strength-preservation test. |
| 8 | **F-V12** writing-plans remediation fast-path with default-deny + 8-trigger test | A4 | Per WS4 CF3: thresholds become NECESSARY but not SUFFICIENT. Default-deny + CONFIG-declared file-glob allowlist. 8-trigger leakage eval before merge. |
| 9 | **F-V8** + browser-driven-verification "Common Recovery" prose | R1 | Pairs naturally with F-V11's amendment. One round of skill-body changes covers both. |
| 10 | **F-V7** Builder dispatch verb ambiguity | A3 sub-fix | Update `cto-mode` Builder-dispatch template to "EXECUTE the plan; do not re-plan or re-design." Resolves with A3 sub-agent inheritance work — same dispatch-template surface. |
| 11 | **F-V18** dispatching-parallel-agents foreground/background subsection | Skill-body amendment | Cheap doc add. Pairs with v2.1.1 if surplus capacity, else v2.2.0. |
| 12 | **F-V17** brownfield retrofit playbook | Docs add | `docs/onboarding-brownfield.md`. Cheap, no code surface. |
| 13 | **R1** Common Recovery sections in `rls-aware-migrations`, `finishing-a-development-branch`, `enterprise-research-first` | R1 | Group with F-V8/V11 work. |
| 14 | **R2** trigger-audit.jsonl schema extension for MCP errors | R2 | Foundation for measurement layer; lands once R1 prose lands. |
| 15 | **D3 / D4 / D5** Researcher post-Write / Debugger instrumentation / QA empty-diff REJECT | Detection layer | Lower-priority detection mechanisms; bundle. |
| 16 | **M1-M5** measurement infrastructure | Measurement | Ships once Layers 2 + 3 land so we can measure their impact. |

### Deferred (no signal yet — do not invest)

| Finding | Why deferred |
|---|---|
| **F-V14** Validation sample size below N≥3 | Resolves itself with v2.1.1 + v2.2.0 onboarding to two more projects (tutoring-platform, ECA-portal per FD-02). Empirical, not engineerable. |
| **F-V15** Team-mode (multi-developer concurrent) | Explicit deferred-research per the finding row. No empirical signal yet. |
| **F-V16** No CI/deploy enforcement | Explicit deferred per finding row. Cross-references FD-02. |
| **F-01..F-15** (audit-derived) | Marked CRITICAL/HIGH at audit time, but the v2.2.0 ADR + Phase 7 implementation already shipped fixes for the load-bearing items (F-01 → D-A bundle; F-02 → ER1 bug-class extension; F-03 → D-B eval pending; F-09 → find-similar-implementations + implementation-decision-log + proposing-patterns; F-10 → fix-time-hash-check + ratify-pattern + proposing-patterns; F-11 → browser-driven-verification + D19; F-12 → incident-response; F-13 → parallel-reconciliation; F-14 → writing-handover; F-15 → triage). These rows are kept in PROJECT-PLAN as audit history, not active engineering targets. **Net new work for v2.2.0 cycle:** F-V7..F-V20 only. |

### Phase 8 sub-items (still IN_PROGRESS)

| Item | Verdict |
|---|---|
| **(7) skill body lint via scripts/structural-check.sh** | Ship as part of v2.1.1 patch (cheap; verifies skill-body invariants the new fixes will introduce). |
| **(8) full Tier 3 cycle smoke** | Run AFTER F-V19 + F-V20 ship. Smoke today proves nothing — Builder dispatch is broken. |
| **(9) description-trigger-overlap audit per Option 1** | v2.2.0 work; pairs with M2 trigger-fidelity eval. |
| **Workstream E (D-B eval)** | Independent. Not blocked by other work. Run when scheduling permits. |

---

## Section 2 — Per-finding assessment table

| ID | Sev (today) | Priority verdict | Plan-quality verdict | Quoted-correctness verdict |
|---|---|---|---|---|
| **F-V7** | LOW | Matches reality. Single-incident signal; verbose prompt language is cheap to fix. | Plan is well-aimed (concrete: "EXECUTE the plan; do not re-plan or re-design"); names target file (cto-mode + dispatching-parallel-agents + subagent-driven-development). Falsifiable. | Bug exists in current code: `agents/builder.md:25-33` says "If you have questions... Ask them now" without disambiguating "execute" vs "re-plan." Fix is well-aimed. Does not break strength preservation. |
| **F-V8** | LOW | Matches reality. Single-incident lock-fail signal; Playwright MCP infra reality is the lock-fail mode is real and frequent. | **Upgraded after full recovery-doc read.** F-V8 alone is well-aimed (names paths a + b). The broader R1 work (recovery doc lines 380-387) extends to 4 named skills (`browser-driven-verification`, `rls-aware-migrations`, `finishing-a-development-branch`, `enterprise-research-first`) with explicit table format `Symptom \| Error class \| Recovery path \| Escalation if recovery fails`. R3 (recovery doc lines 396-397) adds MCP server restart as first-line recovery for Playwright (3/3 issue convergence: #891, #1305, #24144). Plan-quality is **higher** than original verdict suggested. | Bug exists by absence: `browser-driven-verification/SKILL.md` has NO "Common Recovery" section in its 168 lines. Fix is documentation-only addition; no strength-preservation risk. R1 + R3 add 3 more skill bodies and reorder Playwright recovery — still no strength-preservation risk (additive prose). |
| **F-V9** | HIGH | **Matches reality but should split.** A2 portion (system-reminder filter at user-prompt-submit) is a HIGH-priority PRODUCTION FIX (1 day work, 5 LOC). A1 portion (cycle-state.md cooperating across 4 skills) is HIGH-priority but full v2.2.0 layer (3-5 days, 4 skill-body changes). Recommend splitting. | Plan A2 is well-aimed and cite-grounded. Plan A1 is well-aimed in shape (named cooperating skills + cycle-close conditions) but cycle-state.md schema is referenced, not specified — the actual schema fields are `{cycle_name, tier, matched_trigger, opened_at, status: open}` per ADR §A1, but the cycle-close mechanics ("explicit user signal OR task-shape verb in NEW human turn") are LLM-self-attested. WS4 FM-12 explicitly warns against this. **Concern flagged in Section 3.** | Bug exists in current code: `hooks/user-prompt-submit:41-46` writes `last_user_prompt_at` for every UserPromptSubmit event with no payload-shape filter. ADR-006 A2 fix is well-aimed (regex on `<system-reminder>` prefix; deterministic). A1 fix is **partially well-aimed** — the cycle-close detection is qualitatively-judged. **Strength preservation: A2 preserves blocking; A1 risks FM-12 cache-poisoning.** |
| **F-V10** | HIGH | Matches reality (single-incident-but-high-impact: silent failure undetectable without empirical confirmation). | Plan is well-aimed per WS4 reconciliation (CF2). Verb+scope-conditional gate. Adds dispatch-time `scope: code/verdict/analysis/docs` declaration. Falsifiable via 4 false-positive variants + 1 true-positive replay. Builder-only carve-out is now subsumed under F-V20 (general inheritance primitive). | Bug exists: `agents/builder.md:170-194` Output Format requires `Files Changed` section but no enforcement; QA Stage 1 (`agents/builder.md:142-150`) does not check empty diff. Fix is well-aimed. Does NOT break strength preservation IF dispatched-time scope declaration carries the gate (per WS4 mitigation). Without that, falls into FM-13 false-positive trust erosion class. |
| **F-V11** | HIGH | Matches reality. Empirical: shipped bug undetected by green Playwright suite (BP-12 leftover-tail). | Plan is well-aimed (real-user manual smoke OR architectural race-immunity proof). Cited (Playwright Issue #38370 + #5777, DEV.to outcome-based-verification, BC-1/BC-3 taxonomy). Falsifiable. | Bug exists in current code: `browser-driven-verification/SKILL.md:110-112` actually says "Timing-dependent bugs are reproducible — via synthetic event dispatch" — DIRECTLY CONTRADICTS the F-V11 fix. The fix is not just additive, it OVERRIDES an existing claim. **Plan must explicitly remove or qualify lines 110-112.** Currently the proposed fix only adds a "Real-input regression" subsection; without removing the contradicting Anti-Pattern, the skill body is internally inconsistent. **Concern flagged in Section 3.** |
| **F-V12** | MEDIUM | Matches reality. Single-incident, but the failure mode (Tier 2 ceremony for tiny remediations) recurs as friction tax. | Plan is well-aimed per WS4 reconciliation (CF3). Default-deny + ALL 8 Tier 3 triggers tested + CONFIG-declared allowlist. Falsifiable via 8-trigger leakage eval (must escalate 8/8). | Bug exists by absence: `skills/writing-plans/SKILL.md` does not have a fast-path subsection. Fix is well-aimed. Default-deny preserves strength (per WS4 FM-14). RISK: the 8-trigger test is itself LLM-self-attested unless the file-glob allowlist is binding. **Mitigation in plan is correct (file-glob allowlist as primary gate, 8-trigger as secondary).** No strength-preservation break. |
| **F-V13** | HIGH | Matches reality. Active shipped defect on Windows; every doc-only edit denied. | Plan is well-aimed: 2-line normalization fix at `hooks/pre-tool-use`. The ADR-006 cites line 191 but actual location is **line 215-217** (case statement). The line number is off but the fix surface is correct. | Bug exists: case statement pattern `*/.framework-state/*\|*/docs/*\|*/.claude-plugin/*` at line 216 uses forward slashes only. Windows file paths arrive backslash-formatted. Fix is well-aimed. Zero strength-preservation risk (allow-broadening for already-allowed paths). |
| **F-V14** | MEDIUM | **Refined after full measurement-doc read.** Project-count gap (Taskforge-only) still self-resolves via onboarding more projects — but the measurement research doc (lines 91-95, 244-249) shows M1 (friction eval) and M2 (trigger fidelity) are **session-derived**, not cross-project, so multi-project replication is needed only for ADR M3 FM-15 (5 sessions of normal use), not for the bulk of v2.2.0 measurement infrastructure. Verdict shifts from "blanket dependency" to "isolated dependency on M3 only." | Plan is direction-only, not specification — names candidate projects (tutoring-platform, ECA-portal) per FD-02. Acceptable for a research-readiness gap. M1/M2 can ship and produce signal on Taskforge alone. | N/A — this finding is a discipline issue, not a code bug. |
| **F-V15** | MEDIUM | Matches reality. Genuinely deferred until empirical signal. | Plan correctly flags as out-of-scope; names the research need (≥3 enterprise multi-developer-AI-tooling analogs). | N/A. |
| **F-V16** | MEDIUM | Matches reality. Genuinely deferred. | Plan correctly flags as out-of-scope; names candidate shapes (gate-3-production-check.json manifest, GitHub Action). Cross-references FD-02 (GitHub MCP). | N/A. |
| **F-V17** | LOW | Matches reality. Cheap docs add; pairs with v2.1.1. | Plan is well-aimed; concrete sub-headings ((a) CONFIG slots, (b) alias existing patterns doc, (c) ADR convention, (d) when to skip vs port). | N/A — docs only. |
| **F-V18** | LOW | Matches reality. Cheap skill-body amendment. | Plan is well-aimed: names 4 sub-elements (what the choice controls / why background isn't default / rule of thumb / 2-row decision table). Cites parent CC guidance. | Bug exists by absence: `skills/dispatching-parallel-agents/SKILL.md` (182 lines) says NOTHING about foreground vs background. Fix is well-aimed. No strength-preservation risk. |
| **F-V19** | CRITICAL | **Matches reality. Highest urgency by blast radius.** | Plan is well-aimed in DIAGNOSTIC METHOD (4-step debug path: reproduce → test explicit `tools:` → generalize across agents → document contract). Plan does NOT prescribe a fix yet — it's an investigation plan. Acceptable for CRITICAL of unknown root cause. **Concern: F-V19 and F-V20 may be the same bug — see Section 3.** | Bug exists in current code: 0/12 agent files have `tools:` declared (verified via Grep). Builder is the only agent with `isolation: worktree` (verified at line 6). Fix-direction is correct. No strength-preservation risk for adding explicit `tools:` lines. |
| **F-V20** | HIGH | **Should be HIGH (matches) but consider promoting to CRITICAL pending F-V19 root-cause confirmation.** If F-V19 root cause turns out to be gate-deny (not tool-inheritance), F-V20's fix resolves both. | Plan is well-aimed: hook already parses SUBAGENT_TYPE (line 147), needs only the gate-skip logic. 4/4 BINDING citations. WS4 strength-preservation explicit (gate at parent layer untouched; only redundant re-fire suppressed). | Bug exists: `hooks/pre-tool-use:147` parses SUBAGENT_TYPE but lines 205-240 do not consult it. Fix is well-aimed. Strength preservation correct (parent gate stays). |
| F-01..F-13 (audit) | Mixed | All resolved by Phase 7 implementation per PROJECT-PLAN Phase Status. Kept as audit-history rows; no new engineering. | Resolved by shipped artifacts. | Confirmed against shipped artifacts (heavy-read-dispatch, browser-driven-verification, parallel-reconciliation, incident-response, etc., all exist in `skills/`). |
| F-14 | MEDIUM | Resolved by `writing-handover` skill ship (Wave 3). | Plan-quality and correctness both confirmed against the Wave 3 research doc and skill-design artifact. | N/A. |
| F-15 | MEDIUM | Resolved by triage skill (Wave 3). Item 33 truncated still pending — see Remnant Watchlist. | Concrete. | N/A. |
| **Phase 8 (7)** | MEDIUM | Ship in v2.1.1 patch (cheap, verifies skill-body lint). | Concrete: `scripts/structural-check.sh`. | Script exists and runs per Phase 8 verification trail. |
| **Phase 8 (8)** | HIGH | **Blocked on F-V19 + F-V20.** Smoke today proves nothing because Builder dispatch is broken. Run AFTER 1+2+3 ship. | N/A — verification step. | N/A. |
| **Phase 8 (9)** | LOW | Pairs with M2 trigger-fidelity eval. v2.2.0 cycle. | Direction-only (Option 1 reference). | N/A. |
| **Workstream E (D-B eval)** | MEDIUM | Independent. Run when scheduling permits. | Eval design specified in `decision-d-b-root-cause-vs-symptom-2026-04-30.md` (3 corpora 15 cases). Concrete and falsifiable. | N/A — eval design, not code. |

---

## Section 3 — Concerns flagged

### Concern 1 — F-V19 and F-V20 may be the same bug; the proposed fixes are not coordinated

The PROJECT-PLAN F-V20 row explicitly says: "Resolves: F-V19 if the diagnosis is gate-deny rather than tool inheritance" (line 66). But the F-V19 fix path (PROJECT-PLAN line 67, "(2) test with `tools:` explicitly listed in Builder frontmatter") does not gate on the F-V20 diagnostic test running first.

**Quote from current state (PROJECT-PLAN F-V19, line 67):**
> "(1) reproduce the failure with a minimal Builder dispatch in a controlled project, capture the exact tool-denied message; (2) test with `tools:` explicitly listed in Builder frontmatter (Bash, PowerShell, Write, Read, Edit, Glob, Grep) to determine whether the implicit-inheritance path is broken"

**Quote from current state (F-V20, line 66):**
> "the hook already parses SUBAGENT_TYPE for the trigger-audit work (post-v2.0.3), so it has the dispatch-context signal it needs"

**Risk:** if F-V19's empirical fix lists `tools:` explicitly, AND F-V20's hook fix also ships, the `tools:` declaration may be load-bearing for nothing — the inheritance was always working, the tier-selection gate was the deny path.

**Mitigation:** dispatch the F-V19 reproduction step FIRST (single tool call: parent dispatches Builder with a minimal "echo hello" task). The exact tool-denied message determines which fix is load-bearing:
- If "tool not allowed" → F-V19 fix (explicit `tools:` declaration) is load-bearing.
- If "tier-selection has not been invoked..." → F-V20 fix (hook inheritance) is load-bearing; F-V19's `tools:` declaration is cosmetic.

The two findings as written do NOT explicitly resolve this overlap. They should.

### Concern 2 — F-V11 fix is additive but the existing skill body contradicts it

`browser-driven-verification/SKILL.md:110-112` (current state, verified in this session):
> "**'The bug isn't reproducing — must be intermittent'** — Timing-dependent bugs are reproducible — via synthetic event dispatch faster than React commit. If `page.click()` → `page.waitForText()` doesn't reproduce, drop to `page.evaluate(() => dispatchEvent(...))` for synchronous back-to-back dispatch."

The F-V11 proposed fix (PROJECT-PLAN line 59):
> "Skill body must state explicitly: 'Synthetic event dispatch is necessary but NOT sufficient for timing-dependent UI bugs.'"

These two are in **direct contradiction.** Adding the F-V11 line without removing or qualifying lines 110-112 leaves the skill internally inconsistent. The Anti-Pattern at lines 110-112 says synthetic dispatch IS the deterministic way to reproduce; F-V11's empirical evidence says synthetic dispatch CAN PASS while real input fails. Both can be true (synthetic reproduces SOME timing bugs; misses others) but the body must say so.

**Mitigation:** the F-V11 fix must EXPLICITLY rewrite the lines 110-112 Anti-Pattern, not just add a new section. Recommended replacement language: "Synthetic event dispatch reproduces timing bugs that depend on JS event-loop ordering, but MISSES bugs that depend on OS-level hardware-event interleaving (mention-picker leftover-tail class, F-V11). For BC-3 / pointer-capture / IME / drag-drop classes: synthetic is necessary but not sufficient — require either real-user manual smoke OR architectural race-immunity proof."

### Concern 3 — F-V9 cycle-state.md cycle-close detection is LLM-self-attested

ADR-006 §A1 (line 58):
> "Cycle closes via explicit user signal ('done', 'ship it', 'next task') OR task-shape verb in NEW human turn that doesn't fit current cycle scope."

WS4 strength-preservation FM-12 explicitly warns:
> "All three proposed fixes share one anti-pattern — they convert qualitative judgment into LLM-self-attested quantitative gates" (research doc Q12).

Detecting "task-shape verb in NEW human turn that doesn't fit current cycle scope" is precisely a qualitative judgment. The ADR is internally inconsistent: §A1's mechanism is the failure pattern §WS4 forbids.

**Quote from ADR-006 (lines 32):**
> "every fix preserves the *blocking semantic* of the HARD-GATE. Fixes target the firing-rate / UX / scope-declaration layer; the gate-fire logic at `pre-tool-use` lines 232-240 stays untouched."

But §A1 says "if an open cycle exists with matching tier, return a 5-line summary (verdict + matched trigger + cycle_id) instead of re-printing the 80-line skill body." That's a display change, not a gate change — IF the gate still fires per-prompt and the cycle-state.md just shortens what's printed.

**Two readings of the ADR collide:**
- Reading A (display-only, WS4-compliant): cycle-state.md only shortens the printout. The hook gate fires every prompt boundary as today.
- Reading B (gate-skip, WS4-violation): cycle-state.md actually skips the gate firing for matching-tier in-cycle invocations.

The ADR text (line 58) reads more like B ("instead of re-printing"). WS4 wants A. Plan must explicitly disambiguate. Without that, the implementer will guess, and FM-12 cache-poisoning becomes possible.

**Mitigation:** ADR §A1 must explicitly state: "the hook gate at `pre-tool-use:232-240` still fires every prompt boundary; cycle-state.md is read by the SKILL BODY (after the gate allows the Skill invocation) to decide whether to print the full 80-line body or a 5-line summary. The gate-fire frequency is unchanged from v2.1.0."

### Concern 4 — F-V13 ADR line number is off

ADR-006 §Layer 4 (line 159):
> "`hooks/pre-tool-use` line 191 case-statement currently:"

Actual code state (verified this session):
> Line 215-217 — `case "${FILE_PATH}" in */.framework-state/*|*/docs/*|*/.claude-plugin/*) allow ;;`

Line 191 is the dep-add gate, not the docs-allow case. **The fix surface is correct (the case statement is the bug), but the line number cited in the ADR is wrong.** Implementer may waste 5 minutes hunting; not load-bearing but should be corrected.

### Concern 5 — Phase 8 sub-item (8) full Tier 3 cycle smoke is currently un-runnable

If F-V19 is real (Builder cannot use Bash/PowerShell/Write), then "full Tier 3 cycle smoke" cannot succeed by definition — the cycle ends with Builder writing code. PROJECT-PLAN status says (8) is PENDING but doesn't link the dependency on F-V19.

**Mitigation:** explicitly mark (8) as BLOCKED ON F-V19 in PROJECT-PLAN Phase Status. Run only after the F-V19 fix lands and is verified.

### Concern 6 — F-V14 (sample size) interacts with v2.2.0 measurement layer (NARROWED after full measurement-doc read)

ADR-006 §M3 (lines 196-198):
> "FM-15 VS-03 replication — 5 sessions of normal use; track block-count ≥2, verdict-correctness 100%, bypass-rate ≤1"

The framework only has Taskforge as a real project (per F-V14). Five sessions of "normal use" all on Taskforge does not satisfy the framework's own N≥3 different-project rule. The strength-preservation eval may pass on Taskforge yet not generalize.

**Scope clarification after full measurement-doc read:** The measurement research doc (lines 91-95) explicitly designs M1 as session-derived from `trigger-audit.jsonl` — single-project + multi-session is sufficient for M1. M2 trigger-fidelity (lines 244-247) uses 30-case golden datasets that are also project-agnostic. **Only M3 FM-15 has the cross-project gap.** This narrows the concern from "M1-M5 affected" to "M3 FM-15 only."

**Mitigation:** ADR-006 §M3 FM-15 (specifically, not the full measurement layer) should explicitly require 5 sessions across ≥2 projects. If only Taskforge data is available for FM-15, tag that single eval DONE_WITH_CONCERNS. M1, M2, M4, M5 can ship and produce defensible signal on Taskforge alone per the measurement research doc's deterministic-rubric design.

### Concern 7 — F-V12 fast-path "in-handover-scope" precondition is undefined

ADR-006 §A4 (line 95):
> "Root cause documented in an existing handover (cite path)"

There is no specification of what counts as "existing handover" — is it any handover? The most recent handover for the same module? The handover from the immediately-prior cycle? The fast-path will be applied based on LLM judgment of "is this in scope of the prior handover" — that's qualitative.

**Mitigation:** spec must define "in-handover-scope" deterministically — e.g., "the handover whose `## Files Modified` section contains the file being remediated." Otherwise FM-14 leakage class re-emerges via "I think this is in scope of last week's handover."

---

## Section 4 — Dependency graph

```
                      F-V19 (CRITICAL: Builder broken)
                         |
                         v
                      F-V20 (HIGH: hook inheritance — likely root cause)
                         |
                         v
                      Phase 8 (8) full Tier 3 smoke
                         |
                         v
              Workstream E (D-B eval)
                         |
                         v
              v2.2.0 measurement layer M3 (FM-15 replication)


      F-V13 (Windows path-separator)        F-V9 sub-fix A2 (system-reminder filter)
              |                                          |
              +------------+-----------------------------+
                           |
                           v  (these three are the v2.1.1 production fix bundle)
              hooks/pre-tool-use + hooks/user-prompt-submit
                                  |
                                  v
                     Reduces friction enough to onboard projects 2 & 3 (closes F-V14)


      F-V11 (real-input regression)
              |
              v
      browser-driven-verification skill body (rewrite Anti-Pattern + add Real-User Smoke)
              |
              v
      F-V8 (recovery section pairs naturally) → R1 broader (4 skills)


      F-V9 cycle-state.md (A1) ----+
      F-V10 Builder empty-diff (D1) -- coupled by dispatch-time scope:code declaration
      F-V12 fast-path (A4)      ----+
              |
              v
      WS4 strength-preservation eval (cache-poisoning + 8-trigger leakage + counterfactual)
              |
              v
      Ship as bundle in v2.2.0; do not split (eval inputs share the dispatch-metadata schema)


      F-V18, F-V17, F-V7 — independent, can ship anywhere.
```

**Critical path:** F-V19 / F-V20 (production fix) → Phase 8 (8) verification → Workstream E eval → v2.2.0 measurement.

**Why critical:** every other v2.2.0 layer depends on Builder dispatch working. Any layer that ships without Builder verification is shipping unverified.

---

## Section 5 — Recommended sequencing (final)

### v2.1.1 production fix patch (within 1 week)

| # | Finding | Files touched | LOC est | Risk |
|---|---|---|---|---|
| 1 | F-V13 Windows path-separator | `hooks/pre-tool-use` lines 215-217 | 2 | Zero |
| 2 | F-V20 sub-agent inheritance | `hooks/pre-tool-use` lines 205-240 | 6-8 | Low (gate at parent untouched per WS4) |
| 3 | F-V19 reproduction + fix | Reproduce first; then either `agents/*.md` frontmatter (12 files, +1 line each) OR confirms F-V20 resolves | 12 lines OR 0 | Medium until reproduced |
| 4 | F-V9 sub-fix A2 system-reminder filter | `hooks/user-prompt-submit` lines 41-46 | 5 | Low |
| 5 | F-V18 dispatching-parallel-agents subsection | skill-body amendment | 30 lines doc | Zero |
| 6 | F-V17 brownfield onboarding doc | `docs/onboarding-brownfield.md` (new) | 80 lines doc | Zero |
| 7 | Phase 8 sub-item (7) skill body lint | run script | 0 | Zero |

**Pre-ship verification:**
- F-V19 reproduction must produce exact error message in writing before deciding fix shape.
- F-V13: test on Windows + macOS + Linux file_path test cases (per ADR strength preservation §F-V13 row).
- F-V20 + Phase 8 (8) full cycle smoke must run AFTER F-V19 confirms.

### v2.2.0 full layer (within 5 weeks)

| Layer | Findings | Files | Eval gate before merge |
|---|---|---|---|
| Detection (D1-D5) | F-V10 + F-V11 + (D3, D4, D5) | builder.md, qa.md, researcher.md, debugger.md, browser-driven-verification skill | 4-FP + 1-TP eval; 8-trigger leakage; real-input replication |
| Adaptation (A1-A4) | F-V9 (full) + F-V12 + F-V7 (dispatch verb) | tier-selection, triage, writing-plans, cycle-selection, cto-mode, dispatching-parallel-agents, subagent-driven-development, builder, researcher, qa, architect, debugger | Cache-poisoning eval (12 prompts × 4 attacks); 8-trigger fast-path leakage; F-V10 counterfactual replay |
| Recovery (R1-R2) | F-V8 + R1 broader (4 skills) | browser-driven-verification, rls-aware-migrations, finishing-a-development-branch, enterprise-research-first, hooks/pre-tool-use (R2 schema) | None new; per-tool prose is documentation. R2 schema additive (non-breaking). |
| Measurement (M1-M5) | All v2.2.0 fixes | evals/friction/, evals/triggering/ | M1 zero-infra; M2-M5 incremental. |

**Pre-ship verification:**
- WS4 strength-preservation tests all pass before merge.
- Builder counterfactual replay on F-V10 case must show TP detected AND 4 FPs not flagged.
- Cache-poisoning eval 12/12.
- 8-trigger leakage eval 8/8 escalate.

### Deferred (no engineering this cycle)

- F-V14, F-V15, F-V16: explicit deferred, no signal yet
- F-01..F-15 audit-history rows: shipped, kept as record
- Phase 8 (9) description-trigger-overlap: pairs with M2 (v2.2.0 measurement)

---

## Section 6 — Methodology + sources read

### Files read in full

| Path | One-line summary |
|---|---|
| `docs/PROJECT-PLAN.md` (lines 1-220, 220-422) | Phase status + 6 architectural decisions + 22 Open Findings + 4 Validated Discipline rows + 2 Future Decisions + Research-Performed log + Architecture Documents index. Read both halves. |
| `docs/adr/006-v2-2-detection-adaptation-recovery-layer.md` | The v2.2.0 layered design doc (313 lines) — Context, Decision, 5 Layers, Strength preservation tests, Implementation order, Consequences, Self-Review. |
| `docs/reconciliation/v2-2-research-2026-04-30.md` | parallel-reconciliation report on the 5 WS research docs — Verdicts, Convergent findings (C1-C5), Conflicts CF1-CF4 with precedence-ladder steps, Final synthesis paragraph. |
| `docs/research/v2-2-strength-preservation-2026-04-30.md` | WS4 adversarial analysis (Opus). FM-12 cache-poisoning, FM-13 false-positive trust, FM-14 fast-path leakage, FM-15 gate weakening — each with eligibility criteria, citations, strength-preservation test design. **The most load-bearing doc for this assessment.** |
| `hooks/pre-tool-use` (244 lines) | The 5-gate hook bundle — line 147 SUBAGENT_TYPE parse; line 215-217 docs/ auto-allow case statement (F-V13 surface); line 232-240 tier-selection gate logic. |
| `hooks/user-prompt-submit` (63 lines) | UserPromptSubmit handler — lines 41-46 unconditional `last_user_prompt_at` write (F-V9 A2 surface). |
| `agents/builder.md` (214 lines) | Builder agent prompt. Line 5 `model: sonnet`. Line 6 `isolation: worktree`. NO `tools:` line in frontmatter. F-V19 surface confirmed. |
| `skills/dispatching-parallel-agents/SKILL.md` (182 lines) | Parallel dispatch skill body. NO mention of foreground vs background. F-V18 surface confirmed. |
| `skills/browser-driven-verification/SKILL.md` (168 lines) | Browser-driven verification skill. Lines 110-112 contain Anti-Pattern that contradicts F-V11's proposed fix. NO "Common Recovery" section. F-V8 + F-V11 surfaces confirmed. |
| `skills/tier-selection/SKILL.md` (73 lines) | Tier-selection skill body — HARD-GATE at lines 15-17, 5-step checklist at lines 27-35. The F-V9 friction surface (re-prints this body on every invocation). |
| `skills/heavy-read-dispatch/SKILL.md` (62 lines) | Confirms F-V6 RESOLVED — skill exists, has HARD-GATE at lines 32-34, cited per ADR-006 implicit precedent. |

### Files read in part (header / overview / specific sections)

| Path | Sections read | Why partial |
|---|---|---|
| `docs/research/v2-2-detection-2026-04-30.md` | Lines 1-120 (Q1 + citations); lines 280-414 (Detection-Layer Synthesis + Citations + Methodology + Self-Rubric) | Q1 establishes the synthetic-event gap (F-V11 grounding); design synthesis names D1-D5. Q2/Q3 covered by reconciliation doc. |
| `docs/research/v2-2-adaptation-2026-04-30.md` | Lines 1-120 (questions, eligibility, search strategy, Q5 framework comparison) | Q5/Q8 framework comparison + verbatim citations are load-bearing for F-V20 inheritance citation count. |

### Files NOT read this session (acknowledged limitation)

| Path | Why skipped | Risk |
|---|---|---|
| Adaptation Q6/Q7/Q8 detail | Reconciliation report + ADR-006 capture the load-bearing prescriptions. | Low — verbatim citations were spot-checked via Q5 read. |

### Amendment pass — 2026-05-09 (post-initial assessment)

A follow-up amendment pass read `docs/research/v2-2-recovery-2026-04-30.md` (441L) and `docs/research/v2-2-measurement-2026-04-30.md` (394L) in full. Both were initially marked "skipped, low risk" — the full reads confirmed the original verdicts were directionally correct but produced two narrow refinements:

| Doc read in full | What changed | Impact |
|---|---|---|
| `v2-2-recovery-2026-04-30.md` | F-V8 row plan-quality verdict upgraded — recovery doc lines 380-387 specify R1 in 4 named skills with explicit `Symptom \| Error class \| Recovery path \| Escalation` table format; lines 396-397 add R3 (MCP server restart as first-line for Playwright) backed by 3/3 issue convergence (#891, #1305, #24144). Original "well-aimed" verdict held; doc revealed plan is **more rigorous** than the F-V8 row alone communicates. | Confirms Section 1 row 9 + row 13 + row 14 sequencing. No re-priority. |
| `v2-2-measurement-2026-04-30.md` | F-V14 row priority refined — measurement research doc lines 91-95 + 244-249 design M1 (friction eval) as session-derived single-project, and M2 (trigger fidelity) uses 30-case golden datasets that are project-agnostic. Concern 6 narrowed from "M1-M5 affected by Taskforge-only data" to "ADR M3 FM-15 only." M1, M2, M4, M5 can ship + produce defensible signal on Taskforge alone. | Reduces apparent blocker scope of F-V14 against v2.2.0 measurement layer. |

Findings whose verdicts were UNCHANGED after full reads (explicit list to defeat the "I might have missed something" worry):
- F-V7, F-V9, F-V10, F-V11, F-V12, F-V13, F-V15, F-V16, F-V17, F-V18, F-V19, F-V20 — none of these are scoped within the recovery or measurement docs; their verdicts derive from the detection/adaptation/strength-preservation/code-state reads which were complete in the original pass.
- Phase 8 sub-items (7), (8), (9) and Workstream E — verdicts unchanged.
- Concerns 1, 2, 3, 4, 5, 7 — unchanged. Only Concern 6 was narrowed.

### Verification operations performed

| Operation | Result |
|---|---|
| `Grep "^tools:" agents/` | 0 matches across 12 files. F-V19 diagnostic state confirmed. |
| `Grep "^isolation:" agents/` | 1 match: `agents/builder.md:6 isolation: worktree`. Unique to Builder. |
| `wc -l` across all named code surfaces | All file sizes match plan claims. |
| Tier-selection invocation in this context | Successful; confirms gate currently fires for sub-agent contexts (per F-V20). Required to unblock final Write per dispatch instructions. |

### Methodology disclosure

- WebFetch + WebSearch not used in this session — all evidence is internal-source verification of the plan against current code, not external citation gathering. The plan itself cites enterprise/OSS sources; this assessment evaluates whether those citations are correctly applied.
- Strength-preservation rule per WS4 was the binding constraint for "correctness" verdicts. Any plan that converts a HARD-GATE's blocking semantic into LLM-self-attestation was flagged in Section 3 Concerns regardless of intent.
- F-V19 cause has not been empirically reproduced in this session — Builder dispatch from this researcher context would itself fail per F-V19. The verdict for F-V19's "quoted correctness" is based on the static state of the agent files (no `tools:` declared), which is necessary-but-not-sufficient for the runtime failure.
- Tool budget: 1 tier-selection invocation (gate-required) + 14 reads + 2 grep + 2 wc = 19 calls. Outside the 10-15 ceiling for a Researcher direct comparison; justified because this is a multi-finding deep audit, not a 2-3 framework comparison. Audit is single-deliverable (this file), so context discipline served by reading what was needed.

### Self-rubric (Anthropic 5-criterion)

1. **Factual accuracy** — every claim about current code state cites the file + line number; verified inline.
2. **Citation accuracy** — internal citations only this session; line numbers cross-checked against Read output.
3. **Completeness** — every OPEN finding F-V7..F-V20 has a 3-axis verdict; F-01..F-15 audit-history rows covered en bloc with rationale; Phase 8 sub-items (7/8/9) and Workstream E covered.
4. **Source quality** — all citations are PF-internal primary (file paths + line numbers); no secondary sources required for this assessment shape.
5. **Tool efficiency** — exceeded 15-call ceiling (19 calls) for a single deliverable; flagged in methodology disclosure with justification (multi-finding audit ≠ direct comparison; bigger budget warranted).

All five pass.
