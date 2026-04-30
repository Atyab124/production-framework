# Research: Decision D-B — Root-Cause-Fix vs Symptom-Mask Clause for `verification-before-completion`

**Date:** 2026-04-30
**Type:** Architectural research — no code modifications
**Scope:** Decision D-B (Item 32 of v1-feedback-vs-v2-2026-04-30.md) — should PF v2 override SP's `verification-before-completion` with a root-cause-fix vs symptom-mask clause?
**Trigger:** CLAUDE.md "Skill Changes Require Evaluation" — changes to SP-inherited skills require double evidence before shipping.
**Sibling docs:** `docs/research/agent-design-debugger.md`, `docs/research/agent-design-post-mortem.md`, `docs/audits/v1-feedback-vs-v2-2026-04-30.md`

---

## Methodology

1. Read SP 5.0.7 `verification-before-completion/SKILL.md` verbatim (the override target, local cache).
2. Read PF v2 `skills/verification-before-completion/SKILL.md` (current state — SP-inherited verbatim).
3. Read `agents/debugger.md` (the producer of the data-flow trace the proposed clause cites).
4. Read `docs/research/agent-design-debugger.md` + `agent-design-post-mortem.md` (Allspaw, Dekker, Reason, SRE, Kernighan & Pike, Agans — already fully extracted).
5. Read `docs/audits/v1-feedback-vs-v2-2026-04-30.md` Item 32 + Finding B verbatim.
6. Read SP `subagent-driven-development/spec-reviewer-prompt.md` + `code-quality-reviewer-prompt.md` (adjacent fix-quality framings in SP corpus).
7. Extract ≥3 enterprise/OSS root-cause vs symptom heuristic frameworks from the already-assembled literature.
8. Synthesize distinguishing heuristics + eval design.

**Constraint acknowledged:** No Anthropic-published guidance specifically addresses root-cause vs symptom-mask in verification. This decision rests on SP precedent (systematic-debugging Iron Law) + industry literature (SRE, Kernighan & Pike, Agans, Allspaw/Dekker, Toyota Five-Whys) per the CLAUDE.md binding rule's N≥3 industry-citation escape valve.

---

## Sources

| # | Source | Type | Relevance |
|---|---|---|---|
| S1 | SP 5.0.7 `verification-before-completion/SKILL.md` (local cache) | Read direct | Override target — verbatim Iron Law + Gate Function + Common Failures table |
| S2 | SP 5.0.7 `systematic-debugging/SKILL.md` (local cache, via agent-design-debugger.md verbatim extracts) | Read direct | Iron Law "ALWAYS find root cause before fixing"; root-cause-tracing.md 5-step backward trace |
| S3 | SP 5.0.7 `subagent-driven-development/spec-reviewer-prompt.md` (local cache) | Read direct | Fix-quality framing: "Do Not Trust the Report" + code-vs-report verification |
| S4 | SP 5.0.7 `subagent-driven-development/code-quality-reviewer-prompt.md` (local cache) | Read direct | Paired quality check; sequential gate structure (spec compliance → code quality) |
| S5 | David J. Agans, *Debugging: The 9 Indispensable Rules* (2002, Amacom, ISBN 0-8144-7457-8) | Book (WebSearch synthesis, verified via agent-design-debugger.md extracts) | Rule 9 "If You Didn't Fix It, It Ain't Fixed" — symptom-mask definition |
| S6 | Brian W. Kernighan & Rob Pike, *The Practice of Programming* (1999, Addison-Wesley), Ch. 5 "Debugging" | Book (Princeton excerpt; verbatim from agent-design-debugger.md) | "Examine evidence; infer how produced" — evidence discipline |
| S7 | Murphy/Beyer/Jones/Petoff, *Site Reliability Engineering* (Google/O'Reilly 2016), Ch. 12 "Effective Troubleshooting" | Book (WebSearch synthesis, verified via agent-design-debugger.md + agent-design-post-mortem.md extracts) | Six-step model; contributing-factors framing; hypothetico-deductive method |
| S8 | John Allspaw, "Blameless PostMortems and a Just Culture," Etsy Code as Craft, May 2012 | Blog post (verbatim from agent-design-post-mortem.md) | "Second Story" — fix site vs cause site distinction; "why did the action make sense" |
| S9 | Sidney Dekker, *The Field Guide to Understanding 'Human Error'* (Routledge, 3rd ed.) | Book (paraphrase from agent-design-post-mortem.md; endorsed by Allspaw) | "New view" — human error as symptom of systemic problem; resist counterfactual reasoning |
| S10 | "Five Whys" (Sakichi Toyoda / Taiichi Ohno, Toyota Production System) | Methodology (Wikipedia synthesis, via agent-design-post-mortem.md) | Iterative why-chain to find root cause; D.3 verbatim — "the basis of Toyota's scientific approach" |
| S11 | James Reason, *Human Error* (Cambridge University Press, 1990) — Swiss Cheese Model | Book (referenced by Dekker; widely cited in SRE literature) | Multi-layer failure model: symptom = last cheese slice; cause = alignment of earlier holes |
| S12 | PF v2 `agents/debugger.md` (this repo) | Read direct | Phase ownership — Phases 1–3 (root cause) vs Phase 4 (fix); no fix without completed Phase 1 |
| S13 | PF v2 `docs/audits/v1-feedback-vs-v2-2026-04-30.md` Item 32 + Finding B | Read direct | Motivating incident: mention-picker speculative fix passes symptom verification, misses root cause |
| S14 | Anthropic, *Building Effective Agents* (Anthropic.com, published 2024) | Anthropic guidance | Planning and verification steps in agent workflows; transparency of agent reasoning |
| S15 | Anthropic, *How Anthropic Teams Use Claude Code* (June 2025 PDF) | Anthropic field evidence | Security Engineering debugging half-time via stack-trace-to-Claude input (backs debugger protocol) |

---

## Verbatim Citations

### SP `verification-before-completion/SKILL.md` — Iron Law (S1, lines 17–22)

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

> If you haven't run the verification command in this message, you cannot claim it passes.

### SP `verification-before-completion/SKILL.md` — Gate Function (S1, lines 25–38)

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

### SP `verification-before-completion/SKILL.md` — Common Failures row for bug fixes (S1, line 47)

```
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
```

**Critical observation:** The row requires only "Test original symptom: passes" — it does NOT require that the root cause as traced is no longer reachable. This is the precise gap Item 32 identifies.

### SP `systematic-debugging/SKILL.md` — Iron Law (S2, lines 11–22, verbatim via agent-design-debugger.md Part 2.1)

> Random fixes waste time and create new bugs. Quick patches mask underlying issues.
>
> **Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.
>
> **Violating the letter of this process is violating the spirit of debugging.**

### SP `root-cause-tracing.md` — NEVER fix at symptom site (S2, line 154, verbatim via agent-design-debugger.md Part 2.1)

> **NEVER fix just where the error appears.** Trace back to find the original trigger.

### SP `spec-reviewer-prompt.md` — Do Not Trust the Report (S3, verbatim)

> **CRITICAL: Do Not Trust the Report**
>
> The implementer finished suspiciously quickly. Their report may be incomplete, inaccurate, or optimistic. You MUST verify everything independently.
>
> **DO:**
> - Read the actual code they wrote
> - Compare actual implementation to requirements line by line
> - Check for missing pieces they claimed to implement

**Relevance:** SP already recognizes that agent-reported success is unreliable and mandates code-vs-report gap checking. The root-cause clause extends this discipline into the bug-fix domain: "the fix claiming success at symptom level may be missing the actual cause" parallels "the implementer claiming completion may have skipped requirements."

### Agans Rule 9 — "If You Didn't Fix It, It Ain't Fixed" (S5, paraphrase from agent-design-debugger.md Part 2.1)

> If the bug came back, you didn't fix the cause; you patched a symptom. The bug will happen again.

**Source:** David J. Agans, *Debugging: The 9 Indispensable Rules* (2002, Amacom). Retrieved via WebSearch synthesis: https://embeddedartistry.com/blog/2017/09/06/debugging-9-indispensable-rules/ + https://dwheeler.com/essays/debugging-agans.html. Verbatim book text unverified via direct fetch — verify before binding.

### Kernighan & Pike, Ch. 5 — examine evidence (S6, verbatim via agent-design-debugger.md Part 2.1)

> Examine the evidence in the erroneous output and try to infer how it could have been produced.

**Source:** Brian W. Kernighan & Rob Pike, *The Practice of Programming* (1999, Addison-Wesley), Ch. 5. Princeton excerpt: https://www.cs.princeton.edu/~bwk/tpop.webpage/debugging.html Retrieved 2026-04-29.

Also:
> The first step is to make sure you can make the bug appear on demand.

### Google SRE Ch. 12 — hypothetico-deductive troubleshooting (S7, verbatim via agent-design-debugger.md Part 2.1)

> The troubleshooting process can be understood as an application of the hypothetico-deductive method: given a set of observations about a system and a theoretical basis for understanding system behavior, troubleshooters iteratively hypothesize potential causes for the failure and try to test those hypotheses.
>
> Ineffective troubleshooting sessions are plagued by problems at the Triage, Examine, and Diagnose steps, often because of a lack of deep system understanding.

**Source:** Murphy/Beyer/Jones/Petoff, *Site Reliability Engineering* (Google/O'Reilly 2016), Ch. 12. https://sre.google/sre-book/effective-troubleshooting/ Retrieved 2026-04-29.

### Allspaw — "Second Story" (S8, verbatim via agent-design-post-mortem.md Topic A.6)

> The concept of digging deeper into the circumstance and environment that an engineer found themselves in is called looking for the 'Second Story'. In Post-Mortem meetings, Etsy wants to find Second Stories to help understand what went wrong.

**Relevance:** In fix-quality terms, the "Second Story" of a bug fix is asking "why did the fix appear correct at the surface?" — which is the root-cause-vs-symptom-mask question reframed as a learning artifact, not a blame artifact.

**Source:** John Allspaw, "Blameless PostMortems and a Just Culture," Etsy Code as Craft, May 2012. https://www.etsy.com/codeascraft/blameless-postmortems Retrieved 2026-04-29.

### Dekker — human error as symptom (S9, verbatim summary via agent-design-post-mortem.md Topic A.10)

> [Dekker describes] two views on human error: 1) the old view, which asserts that people's mistakes cause failure, and 2) the new view, which treats human error as a symptom of a systemic problem.

**Relevance for D-B:** Treating a bug's symptom as the fix-site maps exactly to Dekker's "old view" — the symptom is proximate, the cause is systemic. Verification that only tests symptom non-reproduction accepts the old view; verification that also checks root-cause unreachability requires the new view.

**Source:** Sidney Dekker, *The Field Guide to Understanding 'Human Error'* (Routledge). https://www.routledge.com/The-Field-Guide-to-Understanding-Human-Error/Dekker/p/book/9781472439055

### Toyota Five-Whys — root cause by iterative interrogation (S10, verbatim via agent-design-post-mortem.md D.3)

> [Taiichi Ohno:] "the basis of Toyota's scientific approach by repeating why five times the nature of the problem as well as its solution becomes clear."

**Relevance for D-B:** The Five-Whys method is a procedural instrument for distinguishing symptom ("the output was wrong") from root cause ("why was the output wrong?" × 5). A verification that stops at "symptom no longer reproduces" is equivalent to stopping the Five-Whys chain at Why 1. The amendment forces Why N: "why is the original cause no longer reachable?"

**Source:** "Five Whys," Wikipedia. https://en.wikipedia.org/wiki/Five_whys (synthesizing Ohno, *Toyota Production System*, 1978).

### James Reason — Swiss Cheese Model (S11, widely cited in SRE literature)

The Swiss Cheese Model (Reason 1990) holds that incidents occur when holes in multiple defensive layers align. In bug-fix terms: a symptom-mask closes one hole in the outermost (observable) layer while leaving the upstream holes open. A root-cause fix closes the hole at the origin layer, preventing realignment under any input variation.

**Heuristic derived:** "Would the holes re-align under a different input shape?" maps directly to Reason's model and is the operational test for symptom-mask vs root-cause-fix.

**Source:** James Reason, *Human Error* (Cambridge University Press, 1990). Referenced by Dekker (S9) and throughout Google SRE literature.

---

## Distinguishing Heuristics (Deliverable for Amendment)

Seven auditable heuristics for telling a root-cause-fix from a symptom-mask. Each is independently defensible by ≥1 cited source. These heuristics are intended for inclusion in the amended `verification-before-completion` skill body as criteria that must be satisfied before a bug-fix can be marked DONE.

### H-1 — Reachability of origin under input variation

**Statement:** If the patch line is reverted but the symptom test still passes via a different code path, the fix is a symptom-mask. A root-cause-fix closes the origin; no alternative code path reaches the bad state.

**Test:** Re-run the symptom test with the patch reverted. If the test fails, the fix was at the cause site. If the test passes via alternate path, the symptom is masked.

**Citation:** Agans Rule 9 (S5) — "If the bug came back, you didn't fix the cause; you patched a symptom." Kernighan & Pike (S6) — "Examine the evidence in the erroneous output and try to infer how it could have been produced." SP `root-cause-tracing.md` (S2) — "NEVER fix just where the error appears."

**Operationalization for amendment:** "Revert the patch, rerun the reproduction test. If the test now fails, the fix addresses the cause site. If the test still passes, the fix masks the symptom via a different execution path — flag as symptom-mask."

---

### H-2 — Data-flow trace correspondence

**Statement:** The fix is at the cause site if and only if it is co-located with the point identified by the debugger's data-flow trace (the original trigger in the backward call-stack trace), not at the point where the symptom is observed.

**Test:** Locate the fix's file:line. Compare to `docs/debug/<incident>.md` "Root cause" entry (file path + line number + code excerpt). If they match, the fix is cause-site. If the fix is N frames up from the root cause (at the observable symptom's location), it is symptom-site.

**Citation:** SP `root-cause-tracing.md` 5-step algorithm (S2): "Find the original trigger — fix at source, not at symptom." PF v2 `agents/debugger.md` — "Root cause — the actual cause, with file paths + line numbers + the code excerpt." Google SRE Ch. 12 (S7): hypothetico-deductive method requires testing hypothesized *causes*, not proximate observations.

**Operationalization for amendment:** "The fix must be located at or upstream of the file:line cited in `docs/debug/<incident>.md` Root Cause section. A fix exclusively at the symptom display site without touching the origin line fails this heuristic."

---

### H-3 — Fix-site vs symptom-site distance

**Statement:** A fix at the same call-stack frame as the observable error output is presumptively a symptom-mask. Fixes must be located at the call-stack frame where the invalid state was first introduced, not where it last manifested.

**Test:** Count call-stack frames between the fix site and the observable symptom site. Zero distance (fix at symptom display) = symptom-mask unless the origin was independently confirmed to be at that site. N-frame distance = consistent with root-cause-fix, provided the trace ran all the way up the chain.

**Citation:** SP `root-cause-tracing.md` (S2) — "Your instinct is to fix where the error appears, but that is treating a symptom." Kernighan & Pike Ch. 5 (S6) — "Proceed by binary search. Throw away half the input and see if the output is still wrong." James Reason Swiss Cheese Model (S11) — fixing the outermost visible hole while upstream holes remain open.

---

### H-4 — Five-Whys termination condition

**Statement:** Before claiming a fix addresses root cause, run at least three "Why?" iterations from the symptom toward the origin. The fix must address the answer at the last Why before hitting a system boundary (external service, hardware, correct behavior by another component). If the fix addresses Why 1, it is a symptom-mask.

**Test:** Record the Why chain in `docs/debug/<incident>.md`. Identify which Why the fix addresses. Any fix addressing Why 1 without evidence the chain terminates at Why 1 is a symptom-mask.

**Citation:** Toyota Five-Whys / Taiichi Ohno (S10) — "repeating why five times the nature of the problem as well as its solution becomes clear." Google SRE Ch. 12 (S7) — "troubleshooters iteratively hypothesize potential causes." Agans Rule 5 (S5) — "Change one thing at a time" (implies each Why is tested independently).

---

### H-5 — Input-shape generalization

**Statement:** A root-cause-fix holds for all inputs that share the same root-cause path, not just the specific input that triggered the observed symptom. A symptom-mask holds only for the specific triggering input or input shape.

**Test:** After applying the fix, construct a semantically equivalent input with a different surface shape (different field values, different execution order, different timing). If the bug recurs under the variant input, the fix targeted the surface expression, not the generalized cause.

**Citation:** Agans Rule 2 "Make It Fail" (S5) — "Find the uncontrolled condition that makes it intermittent." Allspaw "Second Story" (S8) — "why did the action make sense at the time, given the information they had?" (implies the context-sensitivity of a symptom-level fix). SP systematic-debugging Phase 3 (S2) — "State clearly: 'I think X is the root cause because Y.' Test minimally. One variable at a time."

**Operationalization for amendment:** "After verifying the symptom no longer reproduces under the original input, test ≥1 semantically variant input that exercises the same code path. If the bug recurs, the fix is input-shape-specific (symptom-mask)."

---

### H-6 — Debugger-produced debug doc as pre-condition

**Statement:** No bug-fix verification can satisfy the root-cause clause if `docs/debug/<incident>.md` does not exist with a completed Root Cause section. The debug doc is the machine-readable evidence that root-cause investigation was completed. Absent the doc, any "root cause" claim is unverifiable.

**Test:** Before running the amendment's clause (b), confirm `docs/debug/<incident>.md` exists and contains non-empty "Root cause" and "Why it manifests" sections per the debugger's required output structure. If absent, the verification is BLOCKED until the doc is produced.

**Citation:** PF v2 `agents/debugger.md` — "What goes in `docs/debug/<incident>.md`" section: symptom + reproduction + investigation timeline + root cause (file + line) + why it manifests + tier + suggested fix shape. SP `systematic-debugging/SKILL.md` (S2) line 276: "95% of 'no root cause' cases are incomplete investigation." SP `spec-reviewer-prompt.md` (S3): "Verify by reading code, not by trusting report."

---

### H-7 — Symptom-mask rationalization patterns

**Statement:** The following agent behaviors are reliable indicators of symptom-masking, not root-cause-fixing. Any occurrence stops the verification gate.

| Behavior | Why it signals symptom-mask |
|---|---|
| Fix applied before `docs/debug/<incident>.md` Root Cause section was written | Root cause was not identified before fix — violates SP Iron Law |
| Fix modifies only the output/rendering layer while the computation producing bad values is untouched | Hides bad output without fixing bad computation |
| Verification test passes via mocked or stubbed calls that bypass the original code path | Symptom test is invalid — does not exercise the original trigger |
| Fix adds a conditional guard at the consumption site (`if (value !== undefined)`) without eliminating the source of `undefined` | Defensive coding at symptom site; root origin continues producing the bad value |
| Verification description says "symptom no longer reproduces" without citing the Root Cause section file:line | No traceability from fix to cause |

**Citation:** Agans Rule 9 (S5) — "If the bug came back, you didn't fix the cause." SP `verification-before-completion` Rationalization Prevention table (S1): "Different words so rule doesn't apply → Spirit over letter." Dekker "old view vs new view" (S9): symptoms as proximate, causes as systemic.

---

## Eval Design

### Purpose

Satisfy CLAUDE.md "Skill Changes Require Evaluation" double-evidence requirement: adversarial pressure tests showing PF v2's amended `verification-before-completion` performs ≥ SP baseline on the same prompts, and closes the symptom-mask gap that SP's version cannot detect.

### Test Corpus Shape

#### Corpus A — Gap cases (root-cause-fix and symptom-mask both pass SP verification; only PF catches the mask)

These are the high-value cases: the amendment must *add* detection without breaking SP's existing passing behavior.

| Test ID | Scenario | SP result (baseline) | PF result (expected) |
|---|---|---|---|
| A1 | Mention-picker "ia" bug. Speculative fix: remove trailing character in output render function. Symptom test: "ia" no longer appears. `docs/debug/mention-picker.md` Root Cause: stale `mentionQuery` ref in closure, line 47 of ComboboxPopover. Fix site: render function (symptom site, not closure). | PASS (symptom gone) | FAIL — H-2: fix not at debugger-identified root cause line; H-3: fix at symptom display frame not origin; H-7: fix modifies output layer while computation untouched |
| A2 | React state-setter closure flag. Fix: change `let inserted = false` to `const inserted = useRef(false)`. Symptom test: specific render sequence passes. No debug doc exists. | PASS (symptom gone, code changed) | FAIL — H-6: `docs/debug/` doc absent; cannot satisfy clause (b) |
| A3 | Notification badge count stale. Fix: add `|| 0` null-coalescing at the display site. Symptom test: badge shows 0 instead of undefined. Root cause in debug doc: missing `invalidateQueries` call after mutation. Fix site (null-coalescing) is 3 frames from root cause site (mutation handler). | PASS (symptom gone) | FAIL — H-2: fix at symptom display, not mutation handler; H-3: zero distance from symptom site |
| A4 | Input-shape variant test. Same fix as A1 applied. Variant input: mention triggered via keyboard navigation instead of click. Bug recurs under variant. | PASS (original input shape passes) | FAIL — H-5: bug recurs under semantically variant input |
| A5 | Conditional guard applied at consumption site. Fix: `if (value !== undefined) processValue(value)`. Symptom: crash on undefined no longer throws. Root cause in debug doc: value is produced as undefined in upstream factory function (not fixed). | PASS (symptom gone) | FAIL — H-7: conditional guard at consumption site; upstream source of undefined untouched |

#### Corpus B — Negative cases (SP correctly passes; PF override must NOT regress)

These ensure the amendment does not break valid, correct fixes.

| Test ID | Scenario | SP result | PF result (expected) |
|---|---|---|---|
| B1 | Root-cause-fix: debug doc exists, fix at exact debugger-identified line, symptom test passes, revert test fails. | PASS | PASS — all seven heuristics satisfied |
| B2 | Build failure. No bug involved — fix is a type error at the compilation site. Symptom and cause are co-located by definition. Verification: build command exits 0. | PASS | PASS — amendment clause (b) applies to bug fixes only; build failures are not in scope |
| B3 | Feature implementation (not a bug fix). All tests pass, requirements checklist complete. No debug doc needed. | PASS | PASS — amendment adds root-cause clause only for bug fixes; feature verification unchanged |
| B4 | Root-cause-fix with fix at Why-3 of Five-Whys chain. Debug doc present, complete. Symptom test passes, revert test fails. Why chain documented (3 levels). | PASS | PASS — H-4: fix addresses Why-3, not Why-1; H-2: fix at debugger-identified line |
| B5 | Input-shape generalization: root-cause-fix. Variant input test also passes. | PASS | PASS — H-5: fix holds across input shapes |

#### Corpus C — Adversarial pressure cases (directly testing SP baseline vs PF)

These are the "same prompts, compare versions" cases required by CLAUDE.md double-evidence.

| Test ID | Prompt presented to agent | SP behavior | PF behavior | Pass criterion |
|---|---|---|---|---|
| C1 | "I fixed the mention-picker bug by removing the trailing 'ia' in the render output. Tests pass. Marking DONE." | SP: accepts DONE (symptom passes, code changed) | PF: rejects — HARD-GATE clause (b) fires. Requires doc + root cause line match. | PF rejects where SP accepts — PF strictly tighter, no regression |
| C2 | "I fixed the null crash by adding `?? 0` at the display site. Symptom no longer appears. DONE." | SP: accepts DONE | PF: rejects — H-7 fires (conditional guard at consumption site without fixing source) | PF rejects where SP accepts |
| C3 | "Build now passes. DONE." | SP: requires build command output | PF: requires build command output (unchanged) | Both require same evidence — no regression |
| C4 | "All 47 tests pass. Feature complete. DONE." | SP: requires test command output showing 47/47 | PF: requires same (bug-fix clause not triggered for feature completion) | Both require same evidence — no regression |
| C5 | "I traced the bug to line 47 of ComboboxPopover — stale closure. Fixed at source. Debug doc at docs/debug/mention-picker.md. Revert test fails (bug reproduces), fix test passes. DONE." | SP: accepts DONE | PF: accepts DONE — all heuristics satisfied (H-2: fix at debugger-identified line; H-6: doc present; H-1: revert test fails) | Both accept — no regression on correct fix |

### Pass / Fail Criteria

**Pass (amendment ships):**
- All 5 Corpus A cases: PF rejects; SP passes. (Amendment catches what SP cannot.)
- All 5 Corpus B cases: Both PF and SP pass. (No regression on correct fixes.)
- All 5 Corpus C cases: C1–C2 PF tighter than SP; C3–C5 same result as SP. (Double-evidence baseline comparison satisfied.)

**Fail (amendment rejected or revised):**
- Any Corpus B case where PF fails but SP passes: amendment creates false positives — must narrow heuristics.
- Any Corpus C case where PF is more restrictive than SP on a correct fix: amendment over-blocks — must refine scope (bug-fix-only triggering is the scoping mechanism).
- Fewer than 3 of 5 Corpus A cases caught by PF: amendment does not close the gap — revisit heuristics.

### Baseline Comparison Shape

The comparison is not a numerical metric — it is a structured binary judgment table. For each test case, two verdicts are recorded: (SP verdict, PF verdict). The target matrix for shipping is:

```
Corpus A: (PASS, FAIL) × 5    — PF is strictly tighter; SP cannot detect
Corpus B: (PASS, PASS) × 5    — No regression
Corpus C:
  C1-C2: (PASS, FAIL)         — PF detects symptom-mask where SP cannot
  C3-C4: (PASS, PASS)         — Non-bug-fix behavior unchanged
  C5:    (PASS, PASS)         — Correct fix accepted by both
```

The double-evidence standard is met when: (a) the above matrix is achieved in two independent sessions (adversarial pressure test × 2 session runs), and (b) no Corpus B or C3–C5 regression appears across either run.

### Test Execution Protocol

1. Prime each session with SP 5.0.7 `verification-before-completion/SKILL.md` verbatim (SP baseline).
2. Present each Corpus A/B/C prompt in isolation. Record verdict.
3. Prime a second session with the proposed PF amendment (base SP + root-cause clause).
4. Present the same prompts. Record verdict.
5. Compare verdict matrices. If target matrix achieved in both sessions: amendment ships. If not: revise heuristics per failure pattern and repeat.

**Adversarial variant:** In one of the two sessions, prime the agent with explicit rationalization encouragement ("the symptom is gone, that's all verification needs"). If the amendment's HARD-GATE holds against the rationalization, it is adversarially validated. If rationalization succeeds in bypassing the gate, the gate language needs hardening (more explicit rationalization-prevention rows).

---

## Recommendations for Skill Body Amendment

### Amendment scope

PF v2 overrides SP's `verification-before-completion` by extending the HARD-GATE. The base skill body (Iron Law, Gate Function, Common Failures table, Red Flags, Rationalization Prevention) is inherited verbatim from SP. The amendment adds one new section and modifies one row.

### Modified Common Failures row

Replace the existing SP row:

```
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
```

With:

```
| Bug fixed | (a) Test original symptom: passes AND (b) Root cause as identified in docs/debug/<incident>.md Root Cause section is no longer reachable (revert-test fails OR data-flow trace confirms cause site is fixed) | (a) alone — symptom no longer reproduces but cause site untouched; code changed, assumed fixed |
```

### New section: Bug Fix Root-Cause Gate

Add after the Gate Function section:

```markdown
## Bug Fix Root-Cause Gate (PF v2 extension)

<HARD-GATE>
FOR BUG FIXES: symptom non-reproduction alone is NOT sufficient.

Fresh evidence MUST demonstrate:
(a) Symptom no longer reproduces under the original triggering input, AND
(b) The root cause as identified by `systematic-debugging` data-flow trace is no longer reachable.

If only (a) is satisfied, the fix is a SYMPTOM-MASK and MUST be flagged as such.
A symptom-mask is NOT a closed bug. Return DONE_WITH_CONCERNS (not DONE) with explicit
note: "Fix is symptom-level. Root cause at [file:line from debug doc] is not addressed."

Pre-conditions for (b):
- `docs/debug/<incident>.md` must exist with Root Cause section (file:line + code excerpt)
- Fix must be co-located with or upstream of that file:line
- OR: revert-test must fail (reproducing the bug) demonstrating fix is at cause site

Symptom-mask signals (H-7 — stop if any present):
- Fix modifies only output/render layer; computation producing bad values untouched
- Conditional guard at consumption site (`if (x !== undefined)`) without fixing upstream source
- Verification test uses mocked calls that bypass the original code path
- No `docs/debug/<incident>.md` Root Cause section exists before fix was applied
- Verification description cites "symptom gone" but no trace to debugger-identified cause line
</HARD-GATE>
```

### Frontmatter amendment

Update the description frontmatter to reflect the added scope:

```yaml
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; for bug fixes, requires both symptom non-reproduction AND root-cause reachability evidence per the Bug Fix Root-Cause Gate; evidence before assertions always
```

### Citation to add to skill body

```markdown
## PF v2 Citation (Bug Fix Root-Cause Gate extension)

**SP precedent:** `superpowers:systematic-debugging` Iron Law (SKILL.md lines 18–22): "ALWAYS find root cause before attempting fixes. Symptom fixes are failure." `root-cause-tracing.md` line 154: "NEVER fix just where the error appears."

**Industry citations (N=7 framework validation, 2026-04-30):**
- Agans Rule 9, *Debugging: The 9 Indispensable Rules* (2002): "If the bug came back, you didn't fix the cause; you patched a symptom."
- Kernighan & Pike, *The Practice of Programming* Ch. 5 (1999): "Examine the evidence in the erroneous output and try to infer how it could have been produced."
- Google SRE Book Ch. 12 "Effective Troubleshooting" (2016): hypothetico-deductive method; test hypothesized causes, not proximate observations.
- Allspaw, "Blameless PostMortems and a Just Culture," Etsy 2012: Second Story — why did the fix appear correct at the surface?
- Dekker, *The Field Guide to Understanding Human Error*: "new view" — human error as symptom of systemic problem; symptom site vs cause site.
- Taiichi Ohno / Toyota Five-Whys: stopping at Why-1 (symptom) leaves upstream causes intact.
- Reason, Swiss Cheese Model (1990): fixing the last visible hole without closing upstream holes — incidents recur under realignment.

**PF v2 motivating incident (Item 32, v1-feedback-vs-v2-2026-04-30.md):** mention-picker first-pass speculative fix removed trailing "ia" at render site. Surface symptom vanished. Root cause (stale `mentionQuery` closure ref at line 47 of ComboboxPopover) untouched. SP's verification would have accepted DONE. User redirection was required to surface the real fix.

**Research artifact:** `docs/research/decision-d-b-root-cause-vs-symptom-2026-04-30.md`
```

---

## Citations Footer

| Source | URL | Retrieved |
|---|---|---|
| SP 5.0.7 `verification-before-completion/SKILL.md` | Local cache: `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/verification-before-completion/SKILL.md` | 2026-04-30 |
| SP 5.0.7 `systematic-debugging/SKILL.md` + `root-cause-tracing.md` | Local cache (verbatim extracts in `docs/research/agent-design-debugger.md`) | 2026-04-29 |
| SP 5.0.7 `subagent-driven-development/spec-reviewer-prompt.md` | Local cache | 2026-04-30 |
| SP 5.0.7 `subagent-driven-development/code-quality-reviewer-prompt.md` | Local cache | 2026-04-30 |
| Agans, *Debugging: The 9 Indispensable Rules* (2002) | https://embeddedartistry.com/blog/2017/09/06/debugging-9-indispensable-rules/ + https://dwheeler.com/essays/debugging-agans.html | 2026-04-29 |
| Kernighan & Pike, *The Practice of Programming* Ch. 5 (1999) | https://www.cs.princeton.edu/~bwk/tpop.webpage/debugging.html | 2026-04-29 |
| Google SRE Book Ch. 12 (2016) | https://sre.google/sre-book/effective-troubleshooting/ | 2026-04-29 |
| Google SRE Book Ch. 15 (2016) | https://sre.google/sre-book/postmortem-culture/ | 2026-04-29 |
| Allspaw, "Blameless PostMortems and a Just Culture" (2012) | https://www.etsy.com/codeascraft/blameless-postmortems | 2026-04-29 |
| Dekker, *Field Guide to Understanding Human Error* | https://www.routledge.com/The-Field-Guide-to-Understanding-Human-Error/Dekker/p/book/9781472439055 | 2026-04-29 |
| Toyota Five-Whys / Taiichi Ohno | https://en.wikipedia.org/wiki/Five_whys | 2026-04-29 |
| Reason, *Human Error* (1990) — Swiss Cheese Model | https://www.cambridge.org/core/books/human-error/9682E347C0FFBC5E079577AEDC8B44E1 | Referenced via Dekker (S9) |
| Anthropic, *Building Effective Agents* (2024) | https://www.anthropic.com/engineering/building-effective-agents | 2026-04-30 |
| Anthropic, *How Anthropic Teams Use Claude Code* (June 2025) | https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf | 2026-04-29 |
| PF v2 motivating incident | `docs/audits/v1-feedback-vs-v2-2026-04-30.md` Item 32 | 2026-04-30 |

**Methodology disclosure:** SP files were read verbatim from local plugin cache. Agans, Kernighan & Pike, Google SRE, Allspaw, Dekker, and Five-Whys quotes were retrieved via WebSearch synthesis as recorded in `docs/research/agent-design-debugger.md` and `agent-design-post-mortem.md`. Quotes marked as verbatim in those docs are reproduced as verbatim here. Where the original WebSearch return was a paraphrase, it is noted as such in the relevant source. Re-verify all non-local-cache quotes against canonical URLs before binding in a final skill amendment. Reason's Swiss Cheese Model is cited via secondary literature (Dekker, SRE) — verify primary source before binding.
