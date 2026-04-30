# Agent Design Research — QA Sub-Agent

**Date:** 2026-04-29
**Type:** Role-specific research — no code modifications
**Triggered by:** PF v2 binding rule (SP precedent OR Anthropic guidance per `docs/research/sp-anthropic-citation-manifest.md`); revision pass on `agents/qa.md`.
**Scope:** the QA sub-agent that verifies Builder output via two-stage review (spec compliance → code quality). Dispatched in Build, Refactor, Security-Audit, Performance, and Migration cycles, before merge or cycle close.

---

## 1. Canonical Sources

| # | Source | Type | URL / Path | Authority class |
|---|---|---|---|---|
| S1 | `superpowers:subagent-driven-development/SKILL.md` | SP precedent | `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/subagent-driven-development/SKILL.md` | **BINDING (SP)** |
| S2 | `superpowers:subagent-driven-development/spec-reviewer-prompt.md` | SP precedent | same dir | **BINDING (SP)** |
| S3 | `superpowers:subagent-driven-development/code-quality-reviewer-prompt.md` | SP precedent | same dir | **BINDING (SP)** |
| S4 | `superpowers:verification-before-completion/SKILL.md` | SP precedent | `.../skills/verification-before-completion/SKILL.md` | **BINDING (SP)** |
| S5 | `superpowers:requesting-code-review/SKILL.md` (referenced by S3) | SP precedent | `.../skills/requesting-code-review/` | **BINDING (SP)** |
| A1 | *Building Effective AI Agents* — evaluator-optimizer pattern | Anthropic primary | https://www.anthropic.com/research/building-effective-agents | **BINDING (Anthropic)** |
| A2 | *How we built our multi-agent research system* — prompt engineering as primary lever | Anthropic primary | https://www.anthropic.com/engineering/multi-agent-research-system | **BINDING (Anthropic)** |
| A3 | *Effective context engineering for AI agents* — isolated subagent context windows | Anthropic primary | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | **BINDING (Anthropic)** |
| A4 | *Create custom subagents* (Claude Code docs) | Anthropic primary | https://docs.claude.com/en/docs/claude-code/sub-agents | **BINDING (Anthropic)** |
| I1 | ISTQB Certified Tester Foundation Level Syllabus v4.0 (2023) | Industry standard | https://www.istqb.org/ | **SUPPORTING (industry)** |
| I2 | Microsoft Engineering Fundamentals Playbook — Risk-Based Testing | Industry guidance | https://microsoft.github.io/code-with-engineering-playbook/ | **SUPPORTING (industry)** |
| I3 | Google Testing on the Toilet (engineering blog) | Industry guidance | https://testing.googleblog.com/ | **SUPPORTING (industry)** |
| I4 | Google Engineering Practices — How to do a code review | Industry guidance | https://google.github.io/eng-practices/review/reviewer/ | **SUPPORTING (industry)** |

**Authority precedence:** SP precedent > Anthropic primary > industry standard. Industry sources (I1–I4) used **only** to elaborate, never to override SP/Anthropic.

---

## 2. Verbatim Quotes by Topic

### 2.1 Two-stage review — spec compliance gates code quality

> "Two-stage review after each task: spec compliance first, then code quality"
> — S1 (`subagent-driven-development/SKILL.md`) line 8

> "Quality gates: Self-review catches issues before handoff / Two-stage review: spec compliance, then code quality / Review loops ensure fixes actually work / Spec compliance prevents over/under-building / Code quality ensures implementation is well-built"
> — S1 lines 221–226

> "**Only dispatch after spec compliance review passes.**"
> — S3 (`code-quality-reviewer-prompt.md`) line 7

> "**Start code quality review before spec compliance is ✅** (wrong order)"
> — S1 line 247 (under "Red Flags / Never")

> "Move to next task while either review has open issues"
> — S1 line 248 (also "Never")

> "Spec reviewer subagent confirms code matches spec? → [yes] → Dispatch code quality reviewer subagent"
> — S1 lines 71–75 (process flowchart)

> "Spec compliance prevents over/under-building"
> — S1 line 225

**Stage-1-blocks-Stage-2 is non-negotiable in SP.** Three independent SP citations (S1 line 8, S1 line 71-75 flowchart, S3 line 7) all specify the order. S1 line 247 *additionally* lists reverse-order as a Red Flag.

### 2.2 Spec compliance reviewer — what to verify

> "**Missing requirements:** Did they implement everything that was requested? Are there requirements they skipped or missed? Did they claim something works but didn't actually implement it?"
> — S2 (`spec-reviewer-prompt.md`) lines 41–45

> "**Extra/unneeded work:** Did they build things that weren't requested? Did they over-engineer or add unnecessary features? Did they add 'nice to haves' that weren't in spec?"
> — S2 lines 47–50

> "**Misunderstandings:** Did they interpret requirements differently than intended? Did they solve the wrong problem? Did they implement the right feature but wrong way?"
> — S2 lines 52–55

> "Report: ✅ Spec compliant (if everything matches after code inspection) / ❌ Issues found: [list specifically what's missing or extra, with file:line references]"
> — S2 lines 58–61

**SP defines exactly three spec-compliance categories:** missing / extra / misunderstood. PF v2's QA must check all three.

### 2.3 Code quality reviewer — what to check beyond standard review

> "**In addition to standard code quality concerns, the reviewer should check:** Does each file have one clear responsibility with a well-defined interface? / Are units decomposed so they can be understood and tested independently? / Is the implementation following the file structure from the plan? / Did this implementation create new files that are already large, or significantly grow existing files?"
> — S3 lines 20–24

> "**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment"
> — S3 line 26

**Severity grammar in SP:** Critical / Important / Minor. PF v2's current draft uses CRITICAL / HIGH / MEDIUM / LOW — **mismatch with SP**. See §4.1 below.

### 2.4 Do-Not-Trust-The-Report

> "## CRITICAL: Do Not Trust the Report"
> — S2 line 21 (literal section header)

> "The implementer finished suspiciously quickly. Their report may be incomplete, inaccurate, or optimistic. You MUST verify everything independently."
> — S2 lines 23–24

> "**DO NOT:** Take their word for what they implemented / Trust their claims about completeness / Accept their interpretation of requirements"
> — S2 lines 26–29

> "**DO:** Read the actual code they wrote / Compare actual implementation to requirements line by line / Check for missing pieces they claimed to implement / Look for extra features they didn't mention"
> — S2 lines 31–35

> "**Verify by reading code, not by trusting report.**"
> — S2 line 56

> "Trusting agent success reports" — listed under Red Flags
> — S4 (`verification-before-completion/SKILL.md`) line 58

> "Agent delegation: ✅ Agent reports success → Check VCS diff → Verify changes → Report actual state / ❌ Trust agent report"
> — S4 lines 102–105

**The phrase "Do Not Trust the Report" is verbatim SP**, not paraphrase. PF v2 should preserve the literal phrasing in the QA agent prompt.

**Anthropic-published reinforcement:**

> "In the evaluator-optimizer workflow, one LLM call generates a response while another provides evaluation and feedback in a loop."
> "This workflow is particularly effective when there are clear evaluation criteria and when iterative refinement provides measurable value."
> — A1 (*Building Effective Agents*, Dec 19 2024)

> "Early agents made errors like spawning 50 subagents for simple queries, scouring the web endlessly for nonexistent sources, and distracting each other with excessive updates. Since each agent is steered by a prompt, prompt engineering was our primary lever for improving these behaviors."
> — A2 (multi-agent research system, Jun 2025)

A2 implicitly supports do-not-trust-the-report: agents make systematic mistakes; the cure is *prompt engineering*, not trust. Anthropic does not state the specific phrase "do not trust the report" — that is SP's contribution to the canonical text. PF v2 inherits it from SP.

### 2.5 Verification commands as the gate function

> "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE"
> — S4 line 19 (the "Iron Law")

> "If you haven't run the verification command in this message, you cannot claim it passes."
> — S4 line 23

> "BEFORE claiming any status or expressing satisfaction: 1. IDENTIFY: What command proves this claim? 2. RUN: Execute the FULL command (fresh, complete) 3. READ: Full output, check exit code, count failures 4. VERIFY: Does output confirm the claim? 5. ONLY THEN: Make the claim"
> — S4 lines 26–37

> "| Tests pass | Test command output: 0 failures | Previous run, 'should pass' |"
> "| Linter clean | Linter output: 0 errors | Partial check, extrapolation |"
> "| Build succeeds | Build command: exit 0 | Linter passing, logs look good |"
> "| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |"
> "| Regression test works | Red-green cycle verified | Test passes once |"
> "| Agent completed | VCS diff shows changes | Agent reports 'success' |"
> "| Requirements met | Line-by-line checklist | Tests passing |"
> — S4 lines 42–50 (Common Failures table)

**The QA agent IS the verification gate** for its scope. SP's "Iron Law" applies to the QA agent's own claims about whether the Builder's work passes — QA must run its own verification commands and quote output, not infer from "the build agent said tests pass."

### 2.6 Multi-tenant verification (no SP precedent — must be PF-original or Anthropic-derived)

SP has no notion of multi-tenant. SP's `requesting-code-review` and `code-quality-reviewer-prompt` are silent on tenant scope.

**Closest Anthropic touchpoints:**

> "Carefully craft your agent-computer interface (ACI) through thorough tool documentation and testing."
> — A1 (Building Effective Agents)

> "Maintain simplicity in your agent's design. Prioritize transparency by explicitly showing the agent's planning steps."
> — A1

Neither prescribes multi-tenant boundary checks. **This is PF-original content** — see §5 (Gaps) below.

Industry support (informational only, NOT binding under PF v2's citation rule):

> "Risk-based testing: prioritize testing efforts based on risk level... Higher-risk areas warrant more thorough testing."
> — I2 (Microsoft Engineering Playbook, Risk-Based Testing chapter, paraphrased)

> "Boundary value analysis... equivalence partitioning"
> — I1 (ISTQB Foundation Level §4.2, paraphrased — boundary tests as a standard test design technique)

These support **the principle** of risk-prioritized verification (multi-tenant boundary IS the highest-risk surface in SaaS), but PF v2's binding rule is SP-or-Anthropic, not industry. The multi-tenant section therefore ships as **PF-original, opinionated** — flag this in the agent body so future maintainers don't mistake it for SP precedent.

### 2.7 Regression scope

SP doesn't have a "regression scope" skill — but `verification-before-completion` includes:

> "| Regression test works | Red-green cycle verified | Test passes once |"
> — S4 line 46

And `subagent-driven-development` includes self-review by the implementer plus two-stage review by reviewers — but no explicit "what other features could regress" check.

**PF v2 ships `regression-scope` as a separate skill** (per `production-framework:regression-scope` in the skill list). The QA agent should *invoke* that skill when reviewing changes that touch shared modules, not duplicate its logic in the agent body.

**Anthropic touchpoint:**

> "Each subagent operates with an isolated context window. ... This design is intentional: it prevents cross-contamination between different phases of the workflow and keeps each agent focused."
> — A3 (Effective context engineering)

— supports the architectural separation (regression-scope as its own skill called by QA) but doesn't prescribe the technique. **PF-internal heuristic** flag applies.

### 2.8 Evidence over opinion

> "**Evidence before claims, always.**"
> — S4 line 11

> "Run the command. Read the output. THEN claim the result."
> — S4 line 138

> "[list specifically what's missing or extra, with **file:line references**]"
> — S2 line 60 (emphasis added)

**SP's evidence rule applied to QA:** every QA finding cites file path + line number. "Looks suspicious" is not a finding. PF v2's current draft already states this (`agents/qa.md` line 50–51) — keep verbatim.

### 2.9 Status tokens

> "Implementer subagents report one of four statuses... DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED."
> — S1 lines 102–118

S1 specifies the grammar for *implementers*. SP's spec-reviewer and code-quality-reviewer prompt templates do **NOT** specify return tokens explicitly (S2 line 58 uses ✅/❌; S3 line 26 uses "Strengths, Issues (Critical/Important/Minor), Assessment"). PF v2's choice to standardize all four statuses across all sub-agents (including QA) is a **PF extension** — defensible under A2's "prompt engineering as primary lever" but is NOT directly SP-quoted for reviewers.

PF v2 mapping of QA verdicts to status tokens (per `agents/qa.md` lines 38–39, 55–60):

| QA Verdict | Status Token | SP equivalent |
|---|---|---|
| APPROVE | `DONE` | ✅ "Spec compliant" + "Approved" |
| APPROVE_WITH_FIXES | `DONE_WITH_CONCERNS` | ❌ "Issues found" with `Important` or `Minor` only |
| REJECT | `DONE_WITH_CONCERNS` *(same token, different verdict)* | ❌ "Issues found" with `Critical` |
| (spec ambiguous) | `NEEDS_CONTEXT` | (no SP equivalent; PF extension) |
| (cannot run verification) | `BLOCKED` | (no SP equivalent for reviewers; PF extension) |

**Recommendation:** keep PF's 4-status grammar but tag explicitly in the agent body that REJECT and APPROVE_WITH_FIXES both report `DONE_WITH_CONCERNS` (Deputy/CTO triages on verdict, not token alone) — current draft conflates this. See §6.

---

## 3. SP-Inheritable Patterns (DEEP)

### 3.1 The exact dispatch flow QA inherits

```
Builder reports DONE → CTO/Deputy dispatches QA → QA Stage 1 (spec)
  ├─ Stage 1 ✅ → QA Stage 2 (quality)
  │    ├─ Stage 2 ✅ → QA returns APPROVE / DONE
  │    └─ Stage 2 ❌ → QA returns APPROVE_WITH_FIXES / DONE_WITH_CONCERNS
  │         → CTO dispatches Builder for fix → Builder fixes → re-dispatch QA Stage 2 ONLY
  └─ Stage 1 ❌ → QA returns REJECT / DONE_WITH_CONCERNS, STOPS (does NOT proceed to Stage 2)
       → CTO dispatches Builder for spec fix → Builder fixes → re-dispatch QA Stage 1
       → on Stage 1 ✅ → re-dispatch QA Stage 2 (full)
```

This loop matches S1 lines 71–80 exactly. **Re-review is not optional** — S1 line 246 ("Skip review loops") is a Red Flag.

### 3.2 Verbatim phrasing to preserve in QA agent body

These SP phrases were deliberately tuned (per SP's `writing-skills` testing methodology) and changing them is a violation under PF v2 CLAUDE.md "carefully-tuned content" rule. Keep them verbatim:

- `"Do Not Trust the Report"` — S2 line 21 (header) and prose
- `"Verify by reading code, not by trusting report."` — S2 line 56
- `"NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE"` — S4 line 19 (the Iron Law)
- `"Evidence before claims, always."` — S4 line 11
- `"Spec compliance prevents over/under-building"` — S1 line 225
- The three spec-check categories (missing / extra / misunderstood) — S2 lines 41–55

The QA agent body should **literally quote these** (not paraphrase). Current draft quotes the first two; should add the others. See §6.

### 3.3 SP's "fresh subagent per task" applied to re-review

> "Fresh subagent per task + two-stage review (spec then quality) = high quality, fast iteration"
> — S1 line 12

**Implication for QA:** each re-review after a Builder fix should be a *fresh* QA dispatch (new context window), not a continuation of a prior QA conversation. PF v2's substrate (file-based handover via `docs/audits/qa-findings-*.md`) supports this naturally: every QA dispatch reads the findings doc fresh.

A3 reinforces:

> "Each subagent operates with an isolated context window. ... When the orchestrator invokes the backend-architect agent to handle a task, that agent receives only the information relevant to its task ..."
> — A3

So PF's "QA reads findings doc + handover doc + Builder's STATUS block + the diff, on every dispatch" is correctly aligned with both SP S1 and Anthropic A3.

### 3.4 SP self-review precedes external review

> "Implementer subagent implements, tests, commits, **self-reviews**" → "Dispatch spec reviewer subagent"
> — S1 lines 51–52

**Implication for PF v2:** the Builder's `STATUS` block (handover) MUST include a self-review section. QA reads it but does not trust it (S2 §2.4 above). PF v2's `writing-handover` skill should require a "Self-Review" subsection — verify in `skills/writing-handover/SKILL.md` separately.

### 3.5 SP's question-protocol does NOT apply to QA in the same way

S1 lines 50, 67–69 give *implementer* subagents the right to ask questions before starting. There is no SP precedent for **reviewer** subagents asking questions — reviewers either return ✅ or ❌ with file:line evidence (S2 line 60).

**PF v2 mapping:** QA's `NEEDS_CONTEXT` token is the closest analog to "QA asks a question." This is a PF extension to SP's reviewer prompts (which had no equivalent — they would just return ❌ with "spec ambiguous on X"). Defensible under A2 (prompt engineering as primary lever) but flag as PF extension.

### 3.6 Cost discipline — model selection

> "Use the least powerful model that can handle each role to conserve cost and increase speed."
> — S1 line 89

> "Architecture, design, and review tasks: use the most capable available model."
> — S1 line 95

**SP says reviewers (= QA) should use the most capable model.** PF v2's `agents/qa.md` frontmatter currently says `model: inherit` (line 5) — verify against this rule. SP S1 line 95 makes "most capable" the default for reviews. `model: inherit` is acceptable IF the calling CTO uses Opus; consider documenting this expectation explicitly. See §6.

### 3.7 What the code-quality reviewer reads (the GitHub-style review template)

S3 references `requesting-code-review/code-reviewer.md` as the standard template, with these inputs:

```
WHAT_WAS_IMPLEMENTED: [from implementer's report]
PLAN_OR_REQUIREMENTS: Task N from [plan-file]
BASE_SHA: [commit before task]
HEAD_SHA: [current commit]
DESCRIPTION: [task summary]
```

— S3 lines 12–16

**PF v2 application:** the QA agent's input should include these five fields (or PF v2 equivalents). Current `agents/qa.md` lists files to read (line 25–32) but doesn't explicitly require BASE_SHA/HEAD_SHA. For Build/Refactor cycles in a git-tracked project, this matters — without SHAs, QA can't reliably run `git diff BASE..HEAD` to see exactly what changed. See §6.

### 3.8 Final code review across the entire implementation

> "Dispatch final code reviewer subagent for entire implementation" → "Use superpowers:finishing-a-development-branch"
> — S1 lines 63–64 (process flowchart, after all per-task reviews pass)

**SP has TWO levels of code review:** per-task (during the loop) AND final (across the merged work). PF v2's QA agent currently covers per-task only. The "final" review may be a separate cycle (Gate-3 production check?) or a final QA pass. Worth clarifying — see §6.

---

## 4. Industry-Standard Reinforcement (NON-BINDING, supporting only)

### 4.1 ISTQB on test prioritization (I1)

ISTQB Foundation Level §4.2 distinguishes:
- **Specification-based** techniques (equivalence partitioning, boundary value analysis, decision tables) — match SP's "spec compliance" stage
- **Structure-based** techniques (statement, branch, path coverage) — match SP's "code quality" stage in spirit
- **Experience-based** techniques (error guessing, exploratory testing) — closest to SP's "do not trust the report"

ISTQB also defines four test levels: component / integration / system / acceptance. PF v2 QA operates at component-to-system level depending on the cycle. Worth adding a one-line note in the agent body that QA's scope = whatever the cycle's plan covers (matches SP's "review whatever the implementer's task covered").

### 4.2 Microsoft on risk-based testing (I2)

> "Risk-based testing aligns testing activities with the level of risk involved..."
> "Combine risk analysis with testing techniques."
> — I2 (paraphrased)

**Reinforces multi-tenant focus:** in SaaS, the multi-tenant boundary is the highest-impact risk surface. PF v2's QA emphasis on tenant scope per touched query/endpoint/cache-key (current `agents/qa.md` line 41) is consistent with industry risk-based testing — even though it's PF-original, not SP-quoted.

### 4.3 Google on code review (I4)

> "The primary purpose of code review is to make sure that the overall code health of Google's codebase is improving over time."
> "In doing a code review, you should make sure that... The code is well-designed. The functionality is good for the users... Any UI changes are sensible and look good. Any parallel programming is done safely. The code isn't more complex than it needs to be. The developer isn't implementing things they might need in the future but don't know they need now. ... The code is appropriately commented."
> — I4 (paraphrased — Google Engineering Practices, "What to look for in a code review")

— supports SP's S3 list (single responsibility, decomposition, plan-structure adherence, file-size growth) and adds: "developer isn't implementing things they might need in the future" — direct echo of SP's "extra/unneeded work" check from S2 §2.2.

### 4.4 Google Testing on the Toilet — concrete practices (I3)

I3 publishes one-page testing posts. Recurring themes relevant to QA:
- **Test the contract, not the implementation.** SP S2's "missing requirements" check is contract-focused.
- **Hermetic tests.** Each test setup independent — relevant to QA verifying that Builder's tests actually pass standalone, not just in CI's specific order.
- **Don't write change-detector tests.** Relevant to QA flagging Builder tests that just snapshot output rather than asserting behavior.

These are supporting context only. Not citation-worthy under PF v2's binding rule.

---

## 5. Gaps in Current Draft (`agents/qa.md` as of read)

Read `agents/qa.md` (66 lines). Findings:

### 5.1 Missing verbatim SP phrases — MEDIUM gap

Current draft quotes:
- "Two-stage review after each task: spec compliance first, then code quality." (line 10) ✅
- "Only dispatch after spec compliance review passes." (line 10) ✅
- "Do Not Trust the Report. Verify by reading code, not by trusting report." (line 12) ✅

Missing but available SP phrases that should be added:
- "**NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE**" — S4 line 19 (the Iron Law)
- "**Evidence before claims, always.**" — S4 line 11
- "**Spec compliance prevents over/under-building**" — S1 line 225
- The three spec-check categories named verbatim: **missing / extra / misunderstood** — S2 lines 41–55

These four phrases are tuned SP content (per SP's `writing-skills` adversarial-eval methodology). Including them in the QA agent body increases skill-firing reliability without inventing new prose.

### 5.2 Severity grammar mismatch — LOW gap (or worth deliberate divergence)

Current draft uses `CRITICAL / HIGH / MEDIUM / LOW` (line 40).
SP's S3 uses `Critical / Important / Minor` (line 26).

Two options:
- **(A) Conform to SP:** rename to Critical / Important / Minor.
- **(B) Diverge deliberately:** keep PF's 4-tier; document the divergence as PF-extension and cite that PF cycles (Security-Audit, Performance, Migration) need finer granularity than SP's 3-tier.

Either is defensible. Current draft does (B) without acknowledging the divergence — that's the gap. Either acknowledge it or conform.

### 5.3 Status-token mapping ambiguous — MEDIUM gap

Lines 55–60 map four status tokens but:
- Both `APPROVE_WITH_FIXES` and `REJECT` map to `DONE_WITH_CONCERNS` — confusing for the Deputy/CTO consuming the return.
- `NEEDS_CONTEXT` and `BLOCKED` are PF extensions to SP reviewer grammar (SP S2/S3 don't use these). Worth flagging as such.

**Recommended fix:** the verdict (APPROVE / APPROVE_WITH_FIXES / REJECT) goes in the QA findings doc as a top-line field. The status token in the return message is parsed by the `agent-return-parse` hook. Keep them separate. Document explicitly that:
- `DONE` ↔ APPROVE
- `DONE_WITH_CONCERNS` ↔ APPROVE_WITH_FIXES OR REJECT (Deputy/CTO reads the verdict from the findings doc, not the token)
- `NEEDS_CONTEXT` ↔ spec/plan ambiguous (PF extension, cite A2 prompt-engineering principle)
- `BLOCKED` ↔ verification commands cannot run (PF extension, cite S4 verification gate principle)

### 5.4 No BASE_SHA/HEAD_SHA contract — MEDIUM gap

S3 lines 12–16 spell out the five inputs SP's code-quality reviewer expects (WHAT_WAS_IMPLEMENTED / PLAN_OR_REQUIREMENTS / BASE_SHA / HEAD_SHA / DESCRIPTION). Current PF v2 draft "What you read" (lines 25–32) lists files but not the diff range. For projects on git, knowing exactly which commits to diff is load-bearing — without SHAs the QA agent could review more or less than the Builder actually changed.

**Recommended fix:** add BASE_SHA / HEAD_SHA (or PF v2 equivalent — e.g., the Builder's handover doc lists the commits) to the "What you read" inputs.

### 5.5 No multi-tenant citation provenance — MEDIUM gap

Current draft makes the multi-tenant section mandatory (line 51) without flagging that **multi-tenant verification has no SP precedent and no Anthropic citation**. Under PF v2 CLAUDE.md's binding rule, this is fine ONLY if explicitly tagged as PF-original.

**Recommended fix:** add a one-line citation tag: "**PF-original content** (no SP precedent; Anthropic A3 supports the architectural principle of context isolation but does not prescribe tenant-boundary checks)." This matches the honesty pattern in `docs/research/sp-anthropic-citation-manifest.md` Part 4.

### 5.6 No self-review check on Builder handover — LOW gap

S1 line 51 specifies that the implementer self-reviews before reviewer dispatch. PF v2's `writing-handover` skill should require a "Self-Review" section in the handover doc. Current `agents/qa.md` doesn't say "verify Builder included a self-review subsection in the handover and consider it as additional context (but do not trust it)." Worth adding.

### 5.7 No final-review escalation path — LOW gap

S1 line 63–64 specifies a *final* code review across the entire merged implementation, separate from per-task reviews. PF v2 cycles don't currently distinguish per-task QA from final QA. Either:
- Document that per-task QA + Gate-3 production check together cover what SP calls "final code review", OR
- Add an explicit "final QA pass" before merge in Build / Refactor cycles.

### 5.8 No fresh-context guarantee on re-review — LOW gap

S1 line 12 ("Fresh subagent per task") implies fresh context. PF v2 should make explicit that *each* QA dispatch — including re-reviews after Builder fixes — is a fresh dispatch reading the artefacts cold. Worth a line in the agent body: "On re-review, you are dispatched fresh; your prior QA findings doc is part of your input, but you must re-verify everything."

### 5.9 No model-selection guidance — LOW gap

S1 line 95 says reviews should use "the most capable available model." Current `model: inherit` works *if* the dispatcher uses Opus. Worth a one-line note in the QA agent body: "QA review benefits from the most capable model; CTO/Deputy should dispatch QA with `model: opus` or equivalent" — cite S1 line 95.

### 5.10 No re-review-only-for-failed-stage protocol — LOW gap

When Stage 1 fails and Builder fixes spec gaps, S1 lines 73–74 specify re-running spec review (not full Stage 1+2 from scratch — until Stage 1 passes, Stage 2 hasn't started). When Stage 2 fails and Builder fixes quality, only Stage 2 re-runs (S1 lines 76–77). Current `agents/qa.md` doesn't make this loop explicit — Builder might re-run full QA when only one stage needs re-checking.

**Recommended fix:** spell out the re-review protocol in the agent body (or in the `two-stage-review` skill which the agent invokes).

---

## 6. Suggested Revisions to `agents/qa.md`

Concrete, ordered by impact. Each preserves SP precedent verbatim where possible.

### 6.1 Front-matter description (current line 4)

**Current:** generic two-stage review description.

**Suggested:** add the SP "do not trust the report" hook in the description so the skill-firing eval picks it up:

```yaml
description: |
  Use this agent after the Builder reports DONE / DONE_WITH_CONCERNS, before
  the work is merged or the cycle is closed. Two-stage review per SP convention:
  Stage 1 — spec compliance (does the diff match the plan?). Stage 2 — code
  quality (only dispatched after Stage 1 passes). The QA agent does NOT trust
  the Builder's report; it verifies by reading code and running fresh
  verification commands. Examples: ...
```

### 6.2 Add the Iron Law and missing SP phrases as quoted blocks at the top of the body

After the existing two `> SP-cited foundation` quotes (lines 10–12), add:

```markdown
> SP-cited Iron Law: "**NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.**" — *superpowers:verification-before-completion* line 19. Applied here: the QA agent must run its own verification commands (type-check, tests, lint) and quote the output. The Builder's claim that "tests pass" is a hypothesis until QA re-runs the command and reads the exit code.

> SP-cited foundation: "**Evidence before claims, always.**" — *superpowers:verification-before-completion* line 11.

> SP-cited foundation: "Spec compliance prevents over/under-building" — *superpowers:subagent-driven-development* line 225. Stage 1 finds three categories of failures: **missing requirements, extra/unneeded work, misunderstandings** (per `spec-reviewer-prompt.md` lines 41–55).
```

### 6.3 Tag multi-tenant section as PF-original

Edit line 41 ("Multi-tenant section mandatory") to:

```markdown
- **Multi-tenant section mandatory.** Even on single-tenant projects, confirm "single-tenant — no tenant scope required."
  > **PF-original content.** No SP precedent; Anthropic *Effective Context Engineering* (https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) supports the architectural principle of context isolation but does not prescribe tenant-boundary verification. PF v2 ships this as opinionated SaaS-domain guidance per `docs/research/sp-anthropic-citation-manifest.md` Part 4 GAP-2 (production-readiness category). Industry-standard reinforcement: ISTQB §4.2 boundary-value analysis; Microsoft Engineering Playbook risk-based testing.
```

### 6.4 Add BASE_SHA / HEAD_SHA to "What you read"

Edit "What you read" (lines 25–32) to add:

```markdown
- BASE_SHA and HEAD_SHA from the Builder's handover (the commit range that bounds the diff). If Builder didn't supply them, derive from `git log` since the Builder's first commit on this cycle. **Without SHAs, you cannot bound the review** — return BLOCKED.
```

### 6.5 Disambiguate verdict vs status token

Replace the "Status tokens" section (lines 55–60) with:

```markdown
## Status tokens

The QA agent has TWO outputs: a **verdict** in the findings doc, and a **status token** in the return message. The Deputy/CTO reads the verdict from the findings doc; the `agent-return-parse` hook reads the token from the return message.

| Verdict (in findings doc) | Status token (in return) | Meaning |
|---|---|---|
| APPROVE | `DONE` | Stage 1 ✅, Stage 2 ✅. Ready to merge / close cycle. |
| APPROVE_WITH_FIXES | `DONE_WITH_CONCERNS` | Stage 1 ✅, Stage 2 ❌ with Important/Minor only. Deputy decides: dispatch Builder for fix, or accept. |
| REJECT | `DONE_WITH_CONCERNS` | Stage 1 ❌, OR Stage 2 ❌ with Critical. Deputy MUST dispatch Builder for fix; cycle does NOT close. |
| (spec ambiguous) | `NEEDS_CONTEXT` | Plan/spec doesn't specify enough to verify. PF extension to SP reviewer grammar; cite Anthropic A2 (prompt engineering as primary lever). |
| (verification cannot run) | `BLOCKED` | Type-check / test / lint cannot execute (env broken, missing fixture, etc.). Specify which command and why. PF extension to SP reviewer grammar; cite SP `verification-before-completion` Iron Law (without commands, no claim). |
```

### 6.6 Add re-review loop protocol

Add a new section after "Status tokens":

```markdown
## Re-review protocol

Per `superpowers:subagent-driven-development` lines 73–80:

- If Stage 1 ❌, after Builder fixes, **re-run Stage 1 only**. Do not start Stage 2 until Stage 1 ✅.
- If Stage 2 ❌, after Builder fixes, **re-run Stage 2 only**. Stage 1 does not need re-running unless the fix touched files Stage 1 already approved.
- Each re-review is a fresh QA dispatch (fresh subagent, fresh context). Your prior findings doc is part of your input; you must re-verify everything from the diff, not trust your own prior conclusions.

> SP-cited: "Fresh subagent per task + two-stage review (spec then quality) = high quality, fast iteration" — *superpowers:subagent-driven-development* line 12.
```

### 6.7 Severity grammar — explicit divergence note

If keeping CRITICAL / HIGH / MEDIUM / LOW (option B from §5.2), add to the body:

```markdown
**Severity grammar.** PF v2 uses CRITICAL / HIGH / MEDIUM / LOW. SP's `code-quality-reviewer-prompt.md` line 26 uses Critical / Important / Minor. PF extends to four tiers because Security-Audit, Performance, and Migration cycles produce findings that don't fit cleanly into a 3-tier system (e.g., MEDIUM for "non-blocking but should fix this sprint" — neither Critical nor Minor). Documented PF extension; not in SP precedent.
```

### 6.8 Self-review verification

Add to "What you read":

```markdown
- The Builder's **self-review subsection** in the handover doc (per `superpowers:subagent-driven-development` line 51). Read it for context. **Do not trust it** — the Builder may have missed what they missed. Per S2 line 56: "Verify by reading code, not by trusting report."
```

### 6.9 Model selection note

Add to the body, near the end:

```markdown
## Model

`model: inherit` in frontmatter. The CTO/Deputy dispatching QA SHOULD use the most capable available model.

> SP-cited: "Architecture, design, and review tasks: use the most capable available model." — *superpowers:subagent-driven-development* line 95.
```

### 6.10 Citations block — full update

Replace the current Citations block (lines 62–64) with:

```markdown
## Citations

**SP precedents (BINDING):**
- `superpowers:subagent-driven-development/SKILL.md` lines 8 (two-stage), 71–80 (process flow), 89–95 (model selection), 102–118 (status grammar), 221–226 (quality gates), 246–248 (Red Flags).
- `superpowers:subagent-driven-development/spec-reviewer-prompt.md` lines 21–37 (Do Not Trust), 41–55 (three categories), 56 (verify by reading), 58–61 (return shape).
- `superpowers:subagent-driven-development/code-quality-reviewer-prompt.md` line 7 ("only after spec compliance"), lines 20–24 (additional quality checks), line 26 (severity grammar).
- `superpowers:verification-before-completion/SKILL.md` line 11 (Evidence first), lines 18–22 (Iron Law), lines 26–37 (gate function), lines 42–50 (common failures table), lines 102–105 (agent delegation).

**Anthropic primary (BINDING):**
- *Building Effective AI Agents* (https://www.anthropic.com/research/building-effective-agents) — evaluator-optimizer pattern.
- *How we built our multi-agent research system* (https://www.anthropic.com/engineering/multi-agent-research-system) — prompt engineering as primary lever.
- *Effective context engineering for AI agents* (https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — isolated subagent context windows.

**Industry-standard (SUPPORTING, non-binding):**
- ISTQB Foundation Level Syllabus v4.0, §4.2 (specification-based vs structure-based testing).
- Microsoft Engineering Fundamentals Playbook — Risk-Based Testing.
- Google Engineering Practices — How to do a code review (https://google.github.io/eng-practices/review/reviewer/).

**PF-original content (no SP/Anthropic precedent — flagged for honesty):**
- Multi-tenant boundary verification.
- Four-tier severity (CRITICAL/HIGH/MEDIUM/LOW vs SP's three-tier).
- `NEEDS_CONTEXT` and `BLOCKED` status tokens applied to reviewer agents (SP applies them only to implementers).
```

---

## 7. Summary

- **All core PF v2 QA behaviors have direct SP precedent** (S1, S2, S3, S4) — the agent draft is structurally sound.
- **Top-3 gaps in current draft:**
  1. Missing verbatim Iron Law and "Evidence before claims" quotes (§5.1, §6.2) — easy fix, increases skill-firing reliability.
  2. Verdict-vs-token mapping ambiguous (§5.3, §6.5) — Deputy/CTO consumers will misread otherwise.
  3. Multi-tenant section unmarked as PF-original (§5.5, §6.3) — violates the binding-rule honesty norm in PF v2 CLAUDE.md.
- **PF extensions to SP that are defensible but should be tagged:**
  - 4-tier severity (vs SP's 3-tier).
  - `NEEDS_CONTEXT` / `BLOCKED` tokens for reviewer agents.
  - Multi-tenant boundary verification.
  - Regression-scope check (delegated to a separate skill, not duplicated in the agent).
- **No structural rewrites needed.** All §6 revisions are additive or clarifying — the two-stage architecture is already SP-compliant.

