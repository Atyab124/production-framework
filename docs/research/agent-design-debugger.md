# Agent Design Research: Debugger

**Date:** 2026-04-29
**Type:** Research — no code modifications
**Triggered by:** Need verbatim depth + external reference citations for `agents/debugger.md` beyond the SP `systematic-debugging` Iron Law
**Scope:** Role-specific best practices for the production-framework v2 Debugger sub-agent
**Sibling docs:** `docs/research/sp-anthropic-citation-manifest.md` (Part 3 maps `systematic-debugging` skill → SP precedent at row "OK on SP alone")

---

## Part 1: Canonical Sources

| # | Source | Status | Use |
|---|---|---|---|
| 1 | SP `skills/systematic-debugging/SKILL.md` 5.0.7 (local cache) | Read direct | Primary inheritance source — Iron Law, Four Phases, Red Flags table |
| 2 | SP `skills/systematic-debugging/root-cause-tracing.md` (local) | Read direct | Backward-tracing technique |
| 3 | SP `skills/systematic-debugging/defense-in-depth.md` (local) | Read direct | Multi-layer validation post-fix (NOT for the Debugger — for the Builder; included so Debugger understands the hand-off contract) |
| 4 | SP `skills/systematic-debugging/condition-based-waiting.md` (local) | Read direct | Intermittent / timing-bug protocol |
| 5 | David J. Agans, *Debugging: The 9 Indispensable Rules* (2002, Amacom; ISBN 0-8144-7457-8) | Searched (book content) | The 9 rules — primary external reference |
| 6 | Brian W. Kernighan + Rob Pike, *The Practice of Programming* (1999, Addison-Wesley), Ch. 5 "Debugging" | Searched (Princeton excerpt + book content) | Industry-canonical principles |
| 7 | Google SRE Book Ch. 12 "Effective Troubleshooting" (Murphy, Beyer, Jones, Petoff, eds.) | Searched | Troubleshooting model: report → triage → examine → diagnose → test → cure |
| 8 | Microsoft Time-Travel Debugging Overview (learn.microsoft.com) | WebFetch direct | Record-then-investigate paradigm |
| 9 | Anthropic *Claude Code Best Practices* + *How Anthropic Teams Use Claude Code* | Searched | Agent-specific debugging pragmatics (stack traces directly into Claude, runbooks as context) |

**Methodology disclosure:** WebFetch was permission-denied for non-Microsoft URLs in this session. SP files were read directly from local plugin cache. Anthropic and book quotes were retrieved via WebSearch and are reproduced verbatim as returned. Where the source is paraphrased rather than directly quoted by the search tool, it is marked **(paraphrase, verify against canonical URL before using as binding citation)**.

---

## Part 2: Verbatim Quotes by Topic

### 2.1 Root cause vs symptom

**SP `systematic-debugging/SKILL.md` lines 11–22 (verbatim):**
> Random fixes waste time and create new bugs. Quick patches mask underlying issues.
>
> **Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.
>
> **Violating the letter of this process is violating the spirit of debugging.**
>
> ## The Iron Law
>
> ```
> NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
> ```
>
> If you haven't completed Phase 1, you cannot propose fixes.

**SP `root-cause-tracing.md` lines 5–8 (verbatim):**
> Bugs often manifest deep in the call stack ... Your instinct is to fix where the error appears, but that's treating a symptom.
>
> **Core principle:** Trace backward through the call chain until you find the original trigger, then fix at the source.

**SP `root-cause-tracing.md` line 154 (verbatim):**
> **NEVER fix just where the error appears.** Trace back to find the original trigger.

**Agans Rule 9, "If You Didn't Fix It, It Ain't Fixed" (paraphrased from Embedded Artistry & Wheeler reviews — verify against book Ch. 9 before binding):**
> If the bug came back, you didn't fix the cause; you patched a symptom. The bug will happen again.

**Kernighan & Pike, Ch. 5 (paraphrased from Princeton excerpt and search results, verify against canonical URL):**
> Examine the evidence in the erroneous output and try to infer how it could have been produced.

**Google SRE Ch. 12 "Effective Troubleshooting" (paraphrased from search results, verify against canonical URL):**
> The troubleshooting process can be understood as an application of the hypothetico-deductive method: given a set of observations about a system and a theoretical basis for understanding system behavior, troubleshooters iteratively hypothesize potential causes for the failure and try to test those hypotheses.
>
> Ineffective troubleshooting sessions are plagued by problems at the Triage, Examine, and Diagnose steps, often because of a lack of deep system understanding.

**Sources:**
- https://embeddedartistry.com/blog/2017/09/06/debugging-9-indispensable-rules/
- https://dwheeler.com/essays/debugging-agans.html
- https://www.cs.princeton.edu/~bwk/tpop.webpage/debugging.html
- https://sre.google/sre-book/effective-troubleshooting/

---

### 2.2 Instrument-before-fix

**SP `systematic-debugging/SKILL.md` lines 73–88 (verbatim):**
> **WHEN system has multiple components (CI → build → signing, API → service → database):**
>
> **BEFORE proposing fixes, add diagnostic instrumentation:**
> ```
> For EACH component boundary:
>   - Log what data enters component
>   - Log what data exits component
>   - Verify environment/config propagation
>   - Check state at each layer
>
> Run once to gather evidence showing WHERE it breaks
> THEN analyze evidence to identify failing component
> THEN investigate that specific component
> ```

**SP `systematic-debugging/SKILL.md` line 108 (verbatim):**
> **This reveals:** Which layer fails (secrets → workflow ✓, workflow → build ✗)

**Agans Rule 3 "Quit Thinking and Look" (paraphrased from search & Embedded Artistry — verify against book Ch. 3):**
> Too many try to "fix" things based on a guess instead of gathering and observing data to prove or disprove a hypothesis.
>
> Sub-rules: See the failure. See the details. Build instrumentation in. Add instrumentation on. Don't be afraid to dive in. Watch out for Heisenberg. Guess only to focus the search.

**Kernighan & Pike, Ch. 5 (verbatim per Princeton excerpt):**
> If you don't understand what the program is doing, adding statements to display more information can be the easiest, most cost-effective way to find out.

**SP `root-cause-tracing.md` lines 66–90 (verbatim, abridged):**
> When you can't trace manually, add instrumentation:
> ```typescript
> async function gitInit(directory: string) {
>   const stack = new Error().stack;
>   console.error('DEBUG git init:', { directory, cwd: process.cwd(), nodeEnv: process.env.NODE_ENV, stack });
>   await execFileAsync('git', ['init'], { cwd: directory });
> }
> ```
> **Critical:** Use `console.error()` in tests (not logger - may not show)

---

### 2.3 Intermittent / timing / multi-path bug protocols

**SP `systematic-debugging/SKILL.md` lines 218–232 (verbatim):**
> **ALL of these mean: STOP. Return to Phase 1.**
>
> **If 3+ fixes failed:** Question the architecture (see Phase 4.5)
>
> Pattern indicating architectural problem:
> - Each fix reveals new shared state/coupling/problem in different place
> - Fixes require "massive refactoring" to implement
> - Each fix creates new symptoms elsewhere

**SP `condition-based-waiting.md` lines 4–8 (verbatim):**
> Flaky tests often guess at timing with arbitrary delays. This creates race conditions where tests pass on fast machines but fail under load or in CI.
>
> **Core principle:** Wait for the actual condition you care about, not a guess about how long it takes.

**Agans Rule 2 "Make It Fail" (paraphrased from search results — verify against Ch. 2):**
> Do it again. Start at the beginning. Stimulate the failure. Don't simulate the failure. Find the uncontrolled condition that makes it intermittent. Record everything and find the signature of intermittent bugs. Don't trust statistics too much. Know that "that" can happen. Never throw away a debugging tool.

**Microsoft Time-Travel Debugging Overview (verbatim, WebFetch):**
> TTD helps you debug issues by letting you "rewind" your debugger session, instead of having to reproduce the issue until you find the bug.
>
> TTD allows you to go back in time to better understand the conditions that lead up to the bug and replay it multiple times to learn how best to fix the problem.
>
> TTD has advantages over crash dump files, which often miss the state and execution path that led to the ultimate failure.

**Microsoft TTD comparison table (verbatim, WebFetch):**
> Live debugging — Cons: ... may require effort to reproduce the issue repeatedly ... With repro difficult to work back from point of failure to determine cause.
>
> Time Travel Debugging (TTD) — Pros: Great at complex bugs, no coding upfront, offline repeatable debugging, analysis friendly, captures everything.

**Source:** https://learn.microsoft.com/en-us/windows-hardware/drivers/debuggercmds/time-travel-debugging-overview

---

### 2.4 Reproduction discipline

**SP `systematic-debugging/SKILL.md` lines 60–65 (verbatim):**
> 2. **Reproduce Consistently**
>    - Can you trigger it reliably?
>    - What are the exact steps?
>    - Does it happen every time?
>    - If not reproducible → gather more data, don't guess

**Kernighan & Pike, Ch. 5 (verbatim per Princeton excerpt):**
> The first step is to make sure you can make the bug appear on demand.
>
> Narrow down the possibilities by creating the smallest input where the bug still shows up.
>
> Proceed by binary search. Throw away half the input and see if the output is still wrong; if not, go back to the previous state and discard the other half of the input.

**Agans Rule 2 "Make It Fail" (per book table of contents widely cited):**
> Make it fail every time. Make it fail faster. Find the uncontrolled condition that makes it intermittent.

**Google SRE Ch. 12 (paraphrased from search):**
> Idealized troubleshooting model: report → triage → examine → diagnose → test → cure.

**Source:** https://www.oreilly.com/library/view/site-reliability-engineering/9781491929117/ch12.html

---

### 2.5 Evidence-based debugging (vs. theorizing)

**Agans Rule 3 sub-rule (verbatim per multiple book reviews):**
> See the failure. See the details.

**Kernighan & Pike, Ch. 5 (verbatim per Princeton excerpt):**
> Another effective technique is to explain your code to someone else. This will often cause you to explain the bug to yourself.

**SP `systematic-debugging/SKILL.md` lines 108, 152–168 (verbatim):**
> **This reveals:** Which layer fails ...
>
> ### Phase 3: Hypothesis and Testing
>
> **Scientific method:**
>
> 1. **Form Single Hypothesis**
>    - State clearly: "I think X is the root cause because Y"
>    - Write it down
>    - Be specific, not vague
>
> 2. **Test Minimally**
>    - Make the SMALLEST possible change to test hypothesis
>    - One variable at a time
>    - Don't fix multiple things at once

**Google SRE antipatterns (paraphrased from search):**
> Common antipatterns: misinterpreting system metrics; improper hypothesis testing (changing the system unsafely); flawed reasoning (wildly improbable theories, latching onto causes of past problems, hunting spurious correlations).

---

### 2.6 When to stop investigating

**SP `systematic-debugging/SKILL.md` lines 192–212 (verbatim):**
> 4. **If Fix Doesn't Work**
>    - STOP
>    - Count: How many fixes have you tried?
>    - If < 3: Return to Phase 1, re-analyze with new information
>    - **If ≥ 3: STOP and question the architecture (step 5 below)**
>    - DON'T attempt Fix #4 without architectural discussion
>
> 5. **If 3+ Fixes Failed: Question Architecture**
>
>    **STOP and question fundamentals:**
>    - Is this pattern fundamentally sound?
>    - Are we "sticking with it through sheer inertia"?
>    - Should we refactor architecture vs. continue fixing symptoms?

**SP `systematic-debugging/SKILL.md` lines 267–276 (verbatim):**
> ## When Process Reveals "No Root Cause"
>
> If systematic investigation reveals issue is truly environmental, timing-dependent, or external:
>
> 1. You've completed the process
> 2. Document what you investigated
> 3. Implement appropriate handling (retry, timeout, error message)
> 4. Add monitoring/logging for future investigation
>
> **But:** 95% of "no root cause" cases are incomplete investigation.

**Agans Rule 8 "Get a Fresh View" (per search results — paraphrase, verify against Ch. 8):**
> Ask for fresh insights. Don't be too proud to ask. Report symptoms, not theories. Realize that you needn't be sure.

---

### 2.7 Hand-off discipline (this is PF v2-specific extension over SP)

**SP `systematic-debugging/SKILL.md` line 287 (verbatim):**
> **Related skills:**
> - **superpowers:test-driven-development** - For creating failing test case (Phase 4, Step 1)
> - **superpowers:verification-before-completion** - Verify fix worked before claiming success

**SP `defense-in-depth.md` lines 87–95 (verbatim — note: this is for the Builder phase that follows the Debugger's hand-off):**
> When you find a bug:
>
> 1. **Trace the data flow** - Where does bad value originate? Where used?
> 2. **Map all checkpoints** - List every point data passes through
> 3. **Add validation at each layer** - Entry, business, environment, debug
> 4. **Test each layer** - Try to bypass layer 1, verify layer 2 catches it

**Anthropic Claude Code field guidance (paraphrase from search of *How Anthropic teams use Claude Code*, June 2025 — verify against canonical URL):**
> Security Engineering cut infrastructure debugging time in half — from 10–15 minutes down to 5 minutes — by feeding stack traces directly into Claude Code instead of manually scanning through logs.
>
> [Anthropic teams] ingest multiple documentation sources to create markdown runbooks and troubleshooting guides that become context for debugging real production issues.

**Source:** https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf — *How Anthropic Teams Use Claude Code* PDF

---

### 2.8 Confidence threshold / don't guess

**SP `systematic-debugging/SKILL.md` lines 162–168 (verbatim):**
> 4. **When You Don't Know**
>    - Say "I don't understand X"
>    - Don't pretend to know
>    - Ask for help
>    - Research more

**SP `systematic-debugging/SKILL.md` lines 235–243 (verbatim):**
> ## your human partner's Signals You're Doing It Wrong
>
> **Watch for these redirections:**
> - "Is that not happening?" - You assumed without verifying
> - "Will it show us...?" - You should have added evidence gathering
> - "Stop guessing" - You're proposing fixes without understanding
> - "Ultrathink this" - Question fundamentals, not just symptoms
> - "We're stuck?" (frustrated) - Your approach isn't working
>
> **When you see these:** STOP. Return to Phase 1.

---

## Part 3: SP-Inheritable Patterns DEEP from systematic-debugging.md

The current `agents/debugger.md` cites SP at a high level. The following patterns should be inherited verbatim or near-verbatim into the agent body — not just referenced.

### Pattern A — The Iron Law (already cited; promote to top-of-prompt)

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
If you haven't completed Phase 1, you cannot propose fixes.
Violating the letter of this process is violating the spirit of debugging.
```

**Status in current `agents/debugger.md`:** present but as a quote-block at line 10–11, not as a HARD-GATE. **Promote to `<HARD-GATE>` block** per SP `brainstorming/SKILL.md` lines 12–14 precedent.

### Pattern B — Four-Phase Discipline (currently absent)

```
Phase 1: Root Cause Investigation     → MUST complete before Phase 2
Phase 2: Pattern Analysis              → Find working examples; identify diff
Phase 3: Hypothesis and Testing        → Single hypothesis, minimal test
Phase 4: Implementation                → (this phase is the Builder's, NOT the Debugger's)
```

**Status in current `agents/debugger.md`:** Phases 1–3 collapsed into a 4-bullet "Your job" list. **Inherit the 4-phase frame verbatim, but redraw the boundary:** Debugger owns Phases 1–3 + sub-step 1 of Phase 4 ("Create Failing Test Case") as the deliverable for hand-off; Builder owns Phase 4 sub-steps 2–4.

### Pattern C — Red Flags table (currently absent)

SP lines 217–229 list 11 red-flag thoughts that must trigger "STOP and return to Phase 1." This is a behaviorally-tested list — per SP `writing-skills/SKILL.md` lines 498–510, Red Flags tables are populated from baseline subagent failures and are load-bearing.

**Status in current `agents/debugger.md`:** absent. **Inherit verbatim** under a `## Red Flags — STOP` heading. Per PF v2 CLAUDE.md "Skill Changes Require Evaluation" rule: do NOT modify entries; PF inherits the SP-tuned list.

### Pattern D — Common Rationalizations table (currently absent)

SP lines 247–256: 8 rationalizations + reality-check rebuttals. Same provenance discipline as Pattern C.

**Status in current `agents/debugger.md`:** absent. **Inherit verbatim.**

### Pattern E — Multi-component evidence-gathering protocol

SP lines 73–108 specify the boundary-instrumentation protocol with a worked 4-layer example. The current Debugger says "instrument first" but does not give the protocol.

**Status:** absent. **Inherit verbatim.** This is the operational core of the Debugger's investigation phase.

### Pattern F — Backward call-stack tracing (`root-cause-tracing.md`)

The `root-cause-tracing.md` companion file is referenced by the SP SKILL.md but is a separate file. Its 5-step trace process (Observe → Immediate Cause → What Called This → Keep Tracing → Find Original Trigger) is the Debugger's primary investigation algorithm.

**Status in current `agents/debugger.md`:** referenced as "instrument, read code paths" in one bullet. **Inherit the 5-step frame** as the Debugger's Phase 1 algorithm.

### Pattern G — Condition-based waiting for intermittent bugs

`condition-based-waiting.md` provides a specific protocol for timing/race-condition bugs — replace `setTimeout(50)` with `waitFor(condition, timeoutMs)`. This is exactly the case the current Debugger flags as "instrument first" but doesn't operationalize.

**Status:** absent. **Inherit as a sub-protocol** for intermittent/timing bugs.

### Pattern H — "When Process Reveals No Root Cause" (95% rule)

SP lines 267–276: documenting what you investigated, implementing appropriate handling, adding monitoring — is the legitimate "DONE_WITH_CONCERNS" path. Crucially: "**95% of 'no root cause' cases are incomplete investigation.**"

**Status in current `agents/debugger.md`:** Status token `DONE_WITH_CONCERNS` exists but no protocol. **Inherit the 4-step protocol** as the gate before emitting `DONE_WITH_CONCERNS`.

### Pattern I — your-human-partner redirection signals

SP lines 235–243: 5 specific redirection phrases that mean "you're doing it wrong, return to Phase 1." This is behaviorally tuned content and should not be paraphrased.

**Status:** absent. **Inherit verbatim.**

### Pattern J — 3-fixes-then-question-architecture

SP lines 192–213: after 3 failed fixes, the problem is architectural, not a bug. Stop and discuss. This is the Debugger's escalation rule.

**Status in current `agents/debugger.md`:** absent. **Inherit** — for the Debugger this manifests as: after 3 failed hypotheses, return `BLOCKED` with an architectural-question framing rather than a 4th hypothesis.

---

## Part 4: External-Reference Patterns (NEW, beyond SP)

These come from canonical sources outside SP. Each is a candidate for citation in `agents/debugger.md`.

### Pattern K — Agans 9 rules taxonomy (frame for the agent's mental model)

Cite as foundational reference for the discipline. The 9 rules:

1. Understand the system
2. Make it fail
3. Quit thinking and look
4. Divide and conquer
5. Change one thing at a time
6. Keep an audit trail
7. Check the plug
8. Get a fresh view
9. If you didn't fix it, it ain't fixed

**Suggested treatment:** add a "Foundational reference" line in the agent frontmatter description: cite Agans rules 2, 3, 6, 9 as the four most-relevant to the Debugger role.

### Pattern L — Kernighan & Pike: "make the bug appear on demand"

This is the canonical pre-SP statement of reproduction discipline. Cite alongside SP Phase 1 step 2.

### Pattern M — Google SRE 6-step troubleshooting model: report → triage → examine → diagnose → test → cure

The "examine before diagnose" step is what SP calls "instrument first." The "test" step matches SP Phase 3. Citing SRE gives the Debugger a recognized industry frame and helps justify the no-fixes-from-Debugger boundary (the Debugger does report → triage → examine → diagnose → test; the Builder does cure).

**Suggested treatment:** add a 1-line citation note that explains the role boundary in SRE terms — the Debugger owns the first 5 steps, the Builder owns "cure."

### Pattern N — Google SRE antipatterns

Three antipatterns (paraphrased from search, verify Ch. 12 before binding):
1. Misinterpreting system metrics (looking at irrelevant symptoms)
2. Improper hypothesis testing (changing the system unsafely)
3. Flawed reasoning (improbable theories, past-incident anchoring, spurious correlations)

These complement SP's Red Flags by offering a *systems-level* view. Cite as supporting reference, not primary.

### Pattern O — Microsoft TTD: record-then-investigate paradigm

The TTD paradigm — record execution, investigate the recording — is exactly what SP's instrument-first discipline asks for at the language level (logging boundaries) but at the execution-trace level. For PF v2 Debugger, the relevant inheritance is: **when a bug is intermittent, the bias should be toward recording rather than reproducing-then-investigating-live.**

**Suggested treatment:** add a 1-line note in the intermittent-bug protocol citing TTD as the "industry record-and-replay paradigm" backing the instrument-first discipline.

**Verbatim hook (Microsoft):** "TTD has advantages over crash dump files, which often miss the state and execution path that led to the ultimate failure."

### Pattern P — Anthropic field-evidence: stack traces as primary input

Per *How Anthropic Teams Use Claude Code* PDF: feeding stack traces directly into Claude (rather than manual log scanning) cut Security Engineering's infra debugging time from 10–15min → 5min. This is **direct evidence** that the agent-driven debugging model works in production, and supports the Debugger's mandate to consume raw stack traces and structured error output as its input contract.

**Suggested treatment:** cite as Anthropic-published evidence in the Debugger's "Your job" → step 1 ("Reproduce") footnote, and as justification for the agent's input-format contract (accept raw stack traces directly rather than requiring pre-summarized reports).

---

## Part 5: Comparison Table — Current Agent vs. Canonical Sources

| Pattern | SP `systematic-debugging` | Agans 9 Rules | Kernighan & Pike | Google SRE | MSFT TTD | Anthropic | Current `agents/debugger.md` | Consensus |
|---|---|---|---|---|---|---|---|---|
| Root cause not symptom | YES (Iron Law, lines 18–22) | YES (Rule 9) | YES (Ch. 5) | YES (Ch. 12 hypothetico-deductive) | (implicit) | (implicit) | YES (cited line 10) | **5/5 binding** |
| Reproduce before fixing | YES (Phase 1 step 2) | YES (Rule 2) | YES ("appear on demand") | YES (Triage step) | YES (record paradigm) | (implicit) | YES (Hard rule line 38) | **5/5 binding** |
| Instrument before fix | YES (lines 73–108) | YES (Rule 3 "Quit thinking and look") | YES ("display more information") | YES (Examine step) | YES (the entire paradigm) | YES (stack-trace example) | PARTIAL (mentioned, not protocol) | **6/6 binding — gap in current agent** |
| Backward stack-trace | YES (`root-cause-tracing.md`) | (implicit Rule 4 divide-and-conquer) | YES (Ch. 5 binary search) | (implicit) | YES (rewind paradigm) | — | NO | **4/4 binding — major gap** |
| Single hypothesis at a time | YES (Phase 3 step 1) | YES (Rule 5) | YES (binary-search variants) | YES (test step) | — | — | NO | **4/4 binding — gap** |
| Question architecture after 3 fixes | YES (lines 199–213) | (implicit Rule 8 fresh view) | — | — | — | — | NO | **SP-only, but binding via SP** |
| 95%-incomplete-investigation rule | YES (line 276) | — | — | — | — | — | NO (no `DONE_WITH_CONCERNS` gate) | **SP-only, but binding via SP** |
| Red Flags table | YES (lines 217–229) | (Rules 3, 5 imply) | — | YES (antipatterns) | — | — | NO | **STRONG — gap** |
| Common Rationalizations table | YES (lines 247–256) | — | — | YES (antipatterns) | — | — | NO | **STRONG — gap** |
| Don't pretend to know | YES (Phase 3 step 4) | YES (Rule 8) | — | YES ("lack of deep system understanding") | — | (implicit) | NO | **4/4 binding — gap** |
| Audit trail / log every step | (implicit in instrument-first) | YES (Rule 6, explicit) | — | YES (negative results) | YES (the trace IS the audit trail) | (implicit) | NO | **4/4 binding — gap** |
| Hand-off contract (Debugger ≠ Builder) | (implicit via "Phase 4 Implementation" framing) | (implicit Rule 9) | — | YES (cure step is separate) | — | — | YES (no-fixes line 39) | **4/4 — current agent ahead, validate framing** |

**Consensus reading:** the current `agents/debugger.md` correctly inherits the Iron Law and the no-fixes hand-off boundary, but **8 of 12 binding patterns are gaps**: instrument protocol, backward-stack-trace, single-hypothesis discipline, 3-fixes-then-architecture, 95%-rule, Red Flags, Rationalizations, audit trail, "don't pretend to know."

---

## Part 6: Gaps in Current `agents/debugger.md`

GAP-D-1 | **HIGH** | 5/5 binding | Iron Law is quoted but not formatted as `<HARD-GATE>` per SP brainstorming precedent
GAP-D-2 | **HIGH** | 6/6 binding | Instrument-first protocol absent — only mentioned, not operationalized (lines 73–108 of SP SKILL not inherited)
GAP-D-3 | **HIGH** | 4/4 binding | Backward call-stack tracing 5-step process from `root-cause-tracing.md` not inherited
GAP-D-4 | **HIGH** | SP+SRE | Four-phase frame absent; Debugger owns Phases 1–3, Builder owns Phase 4 — not made explicit
GAP-D-5 | **HIGH** | SP-only binding | Red Flags + Common Rationalizations tables not inherited (these are tuned content per SP `writing-skills` lines 498–510)
GAP-D-6 | MED | 4/4 binding | Single-hypothesis discipline (one variable at a time) not stated
GAP-D-7 | MED | SP-only binding | 3-fixes-then-question-architecture escalation rule absent
GAP-D-8 | MED | SP-only binding | "When Process Reveals No Root Cause" 4-step gate before `DONE_WITH_CONCERNS` absent — current agent allows the token without the protocol
GAP-D-9 | MED | 4/4 binding | "Don't pretend to know" → return `NEEDS_CONTEXT` discipline not stated
GAP-D-10 | MED | Agans + SRE | Audit-trail discipline (Rule 6) not stated — Debugger should write timeline as it investigates, not at the end
GAP-D-11 | LOW | external | No reference to Agans 9 rules, Kernighan & Pike, SRE Ch. 12, or TTD — current agent cites SP only
GAP-D-12 | LOW | Anthropic | No citation of Anthropic field evidence (stack traces as primary input, *How Anthropic Teams Use Claude Code* PDF)
GAP-D-13 | LOW | timing-bugs | Condition-based-waiting protocol from SP companion file not inherited; intermittent bugs only get a 1-line "instrument first" mention

---

## Part 7: Suggested Revisions to `agents/debugger.md`

Prioritized by simplicity ladder (eliminate > reuse > one primitive > build new). All revisions REUSE existing SP content — none invent new methodology.

### Revision R1 (HIGH, GAP-D-1, GAP-D-4) — Reframe top-of-prompt with HARD-GATE + four-phase frame

Replace lines 10–11 of current agent with:

```markdown
<HARD-GATE>
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.
If you have not completed Phase 1 (Root Cause Investigation), you may not propose fixes —
not even a one-line fix. Violating the letter of this process is violating the spirit of debugging.
— inherits superpowers:systematic-debugging Iron Law (lines 18–22)
</HARD-GATE>

You own SP Phases 1–3 of the four-phase debugging discipline:
- Phase 1: Root Cause Investigation  (yours)
- Phase 2: Pattern Analysis           (yours)
- Phase 3: Hypothesis and Testing     (yours)
- Phase 4: Implementation             (the Builder's — NOT yours)

You hand off to the CTO at the end of Phase 3 with a failing-test-case-or-reproduction artifact
that the Builder uses as Phase 4 input.
```

**Citation:** SP `systematic-debugging/SKILL.md` lines 18–22, 47–58, 122–145, 170–180; SP `brainstorming/SKILL.md` lines 12–14 (HARD-GATE format precedent).

### Revision R2 (HIGH, GAP-D-2) — Inherit the multi-component instrument protocol verbatim

Add a new section `## Investigation protocol — multi-component systems` containing SP lines 73–108 of `systematic-debugging/SKILL.md` verbatim. This is operational content, not prose; SP CLAUDE.md "skills are code" rule applies — inherit, don't paraphrase.

### Revision R3 (HIGH, GAP-D-3) — Inherit backward-tracing 5-step algorithm

Add `## Investigation protocol — backward call-stack tracing` with the 5-step algorithm from `root-cause-tracing.md`:

```
1. Observe the symptom (the actual error)
2. Find the immediate cause (what code directly produces it)
3. Ask: what called this with this value/state?
4. Keep tracing up the call chain
5. Find the original trigger — fix at source, not at symptom
```

**Citation:** SP `root-cause-tracing.md` lines 32–65.

### Revision R4 (HIGH, GAP-D-5) — Inherit Red Flags + Rationalizations tables verbatim

Add two sections at the end of the agent body:

```markdown
## Red Flags — STOP and return to Phase 1

[verbatim copy of SP systematic-debugging/SKILL.md lines 217–229]

## Common Rationalizations

[verbatim copy of SP systematic-debugging/SKILL.md lines 247–256]
```

**Citation rule:** Per PF v2 CLAUDE.md "carefully-tuned content" rejection criterion (#5), these tables MUST be inherited verbatim — modifying entries requires before/after eval evidence.

### Revision R5 (MED, GAP-D-6, GAP-D-9) — Add hypothesis discipline + don't-pretend-to-know

Add to "Hard rules" section:

- **One hypothesis at a time.** State your hypothesis explicitly as "I think X is the root cause because Y." Test the smallest possible thing. If the test refutes the hypothesis, form a new one — never bundle multiple speculative changes into one investigation step.
- **When you don't know, say so.** Return `NEEDS_CONTEXT` with the specific gap you can't fill, rather than guessing. Do not pretend to know.

**Citation:** SP `systematic-debugging/SKILL.md` lines 152–168.

### Revision R6 (MED, GAP-D-7, GAP-D-8) — Add 3-fixes rule + 95% rule

Add to "Hard rules" section:

- **Three failed hypotheses → return `BLOCKED`, not Hypothesis #4.** If three hypotheses have been disproved by evidence, the problem is likely architectural, not a single bug. Return `BLOCKED` with an architectural framing for the CTO to triage, rather than continuing to generate hypotheses.
- **Before emitting `DONE_WITH_CONCERNS` ("no root cause"), complete the 4-step gate:** (1) document everything investigated, (2) verify why it's environmental/timing/external rather than incomplete investigation, (3) propose appropriate handling (retry/timeout/error message) for the Builder, (4) propose monitoring/logging additions. *95% of "no root cause" claims are incomplete investigation* (SP `systematic-debugging/SKILL.md` line 276).

**Citation:** SP `systematic-debugging/SKILL.md` lines 192–213, 267–276.

### Revision R7 (MED, GAP-D-10) — Add audit-trail-as-you-go discipline

Add to "Your job" section:

- **Write the investigation timeline as you go, not after.** Each instrumentation pass, each ruled-out hypothesis, each piece of evidence — record it in `docs/debug/<incident>.md` immediately. Per Agans Rule 6 ("Keep an Audit Trail"): record everything.

**Citation:** SP `systematic-debugging/SKILL.md` lines 270–273; David Agans, *Debugging: The 9 Indispensable Rules*, Rule 6.

### Revision R8 (LOW, GAP-D-11, GAP-D-12) — Add external citation block

Replace current `## Citations` section with:

```markdown
## Citations

**Primary inheritance — SP `superpowers:systematic-debugging`:**
- Iron Law (SKILL.md lines 18–22)
- Four-phase frame (lines 47–215)
- Multi-component instrument protocol (lines 73–108)
- Red Flags + Rationalizations (lines 217–256)
- "When Process Reveals No Root Cause" 95%-rule (lines 267–276)
- `root-cause-tracing.md` companion: 5-step backward trace
- `condition-based-waiting.md` companion: intermittent / timing protocol

**External references (foundational, cited in body):**
- David J. Agans, *Debugging: The 9 Indispensable Rules for Finding Even the Most Elusive
  Software and Hardware Problems* (2002, Amacom). Especially Rules 2 (Make It Fail),
  3 (Quit Thinking and Look), 6 (Keep an Audit Trail), 9 (If You Didn't Fix It, It Ain't Fixed).
- Brian W. Kernighan & Rob Pike, *The Practice of Programming* (1999, Addison-Wesley),
  Chapter 5 "Debugging." Excerpt: https://www.cs.princeton.edu/~bwk/tpop.webpage/debugging.html
- Murphy/Beyer/Jones/Petoff (eds.), *Site Reliability Engineering* (Google, O'Reilly 2016),
  Chapter 12 "Effective Troubleshooting": https://sre.google/sre-book/effective-troubleshooting/
  Six-step model: report → triage → examine → diagnose → test → cure. Debugger owns the
  first 5 steps; Builder owns "cure."
- Microsoft, *Time Travel Debugging Overview*: https://learn.microsoft.com/en-us/windows-hardware/drivers/debuggercmds/time-travel-debugging-overview
  Backs the record-then-investigate paradigm for intermittent bugs.

**Anthropic field evidence:**
- *How Anthropic Teams Use Claude Code* (June 2025 PDF):
  https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf
  Security Engineering cut infra debugging time 10–15min → 5min by feeding stack traces
  directly into Claude. Backs this agent's input contract (accept raw stack traces
  directly, not pre-summarized reports).
- *Subagent isolation* — Claude Code documentation:
  https://docs.claude.com/en/docs/claude-code/sub-agents
  Backs the Debugger-as-isolated-subagent topology.
```

### Revision R9 (LOW, GAP-D-13) — Add intermittent-bug sub-protocol

Add a new section `## Intermittent / timing-dependent bugs` containing condensed reference to `condition-based-waiting.md`:

```markdown
For tests that pass sometimes and fail under load, or for production bugs with no
deterministic repro: replace arbitrary `setTimeout`/`sleep` guesses with condition-based
waiting (`waitFor(condition, timeoutMs)`). Per SP `condition-based-waiting.md`: "Wait for
the actual condition you care about, not a guess about how long it takes." Per Microsoft
TTD: prefer recording-and-replaying over reproducing-then-investigating-live for
non-deterministic bugs.
```

**Citation:** SP `condition-based-waiting.md` (full file); Microsoft TTD overview.

---

## Part 8: Recommendations Summary (prioritized)

1. **R1, R4** — HIGH-priority, ELIMINATE risk by inheriting verbatim SP content (Iron Law as HARD-GATE + Red Flags + Rationalizations tables). Effort: 30 min. Files: `agents/debugger.md` only.
2. **R2, R3** — HIGH-priority, REUSE SP companion-file content (instrument protocol + backward-trace algorithm). Effort: 20 min. Files: `agents/debugger.md` only.
3. **R5, R6, R7** — MED-priority, add hard-rules entries (one-hypothesis, 3-fixes, 95%-rule, audit-trail). Effort: 20 min. Files: `agents/debugger.md` only.
4. **R8, R9** — LOW-priority, add external citations block + intermittent-bug sub-protocol. Effort: 15 min. Files: `agents/debugger.md` only.

**Total effort estimate:** ~85 minutes for full revision. All revisions REUSE existing SP/Anthropic/external content — zero new methodology invented. This satisfies PF v2 CLAUDE.md binding rule (every feature cites SP precedent OR Anthropic guidance).

**Citation manifest update needed:** the row in `docs/research/sp-anthropic-citation-manifest.md` Part 3 for `systematic-debugging` skill currently reads "OK on SP alone" — after R8 it remains OK on SP alone for the *skill itself*, but the Debugger *agent* gains additional external references that should be added as a separate row in Part 3 ("`agents/debugger.md` — agent — SP precedent: `systematic-debugging` SKILL.md + companion files; Anthropic: §2.9 subagent isolation, *How Anthropic teams use Claude Code* — Status: OK").

---

## Sources

**SP files (read direct from local cache):**
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/systematic-debugging/SKILL.md`
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/systematic-debugging/root-cause-tracing.md`
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/systematic-debugging/condition-based-waiting.md`
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/systematic-debugging/defense-in-depth.md`

**Microsoft TTD (WebFetch direct, 2025-11-05 doc revision date per metadata):**
- https://learn.microsoft.com/en-us/windows-hardware/drivers/debuggercmds/time-travel-debugging-overview

**External references (WebSearch synthesis — verify before binding):**
- https://embeddedartistry.com/blog/2017/09/06/debugging-9-indispensable-rules/ (Agans 9 rules summary)
- https://dwheeler.com/essays/debugging-agans.html (David Wheeler review of Agans)
- https://www.amazon.com/Debugging-Indispensable-Software-Hardware-Problems/dp/0814474570 (Agans book)
- https://www.cs.princeton.edu/~bwk/tpop.webpage/debugging.html (Kernighan & Pike Ch. 5 excerpt)
- https://www.oreilly.com/library/view/the-practice-of/9780133133448/ (Kernighan & Pike book)
- https://sre.google/sre-book/effective-troubleshooting/ (SRE Ch. 12)
- https://www.oreilly.com/library/view/site-reliability-engineering/9781491929117/ch12.html (SRE Ch. 12 alternate)
- https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf (How Anthropic Teams Use Claude Code, June 2025)
- https://code.claude.com/docs/en/best-practices (Claude Code Best Practices)
- https://docs.claude.com/en/docs/claude-code/sub-agents (Subagent isolation reference, used in companion citation manifest)

**Companion PF v2 docs cross-referenced:**
- `c:/Users/atyab/Experimental - Users/production-framework-v2/docs/research/sp-anthropic-citation-manifest.md`
- `c:/Users/atyab/Experimental - Users/production-framework-v2/agents/debugger.md`

**Methodology disclosure:** WebFetch was permission-denied for non-Microsoft URLs in this session. Anthropic and book quotes were retrieved via WebSearch synthesis of canonical URLs and are reproduced verbatim as returned by WebSearch where the search tool returned them as direct quotes. Where the search tool paraphrased rather than quoted, the passage is marked **(paraphrase, verify against canonical URL before binding)**. SP file content was read directly from local plugin cache and is verbatim.
