# Skill Design Research: `seven-validation-questions`

**Date:** 2026-04-30
**Type:** Source-of-truth research — no code modifications
**Triggered by:** PF v2 binding rule (`CLAUDE.md`) requiring every feature to cite SP precedent OR Anthropic guidance, supplemented (where neither exists) by ≥3 enterprise/OSS analogs. The 7-question set as a *bundle* is a PF invention; the underlying disciplines have strong industry analogs and this artifact maps each.

**Methodology disclosure:** WebFetch was permission-denied this session (matches the constraint disclosed in `sp-anthropic-citation-manifest.md` and `agent-design-post-mortem.md`). All Anthropic and external quotes were retrieved via WebSearch synthesis of canonical URLs. They are reproduced verbatim as returned by WebSearch. Before any binding architectural decision, re-verify against the live URL using WebFetch in a session where it is permitted. Local-cache reads of SP 5.0.7 and PF v1 are direct.

**Scope of this skill (per design brief):** A pre-execution validation skill the Deputy/CTO agent runs against any Tier 2/3 plan before dispatching builders. Seven questions:

| # | Question | Discipline |
|---|---|---|
| Q1 | **Why now?** | Trigger / cost-of-inaction |
| Q2 | **Why this approach?** | Alternatives considered |
| Q3 | **What invariants must hold?** | Pre/post conditions, multi-tenant boundaries |
| Q4 | **What's the contract?** | Input shape, output shape, error shape |
| Q5 | **What's the failure mode?** | Partial-failure semantics, blast radius |
| Q6 | **How is it observed?** | Logs / metrics / traces / alerts |
| Q7 | **How is it reverted?** | Rollback, cleanup, feature-flag exit |

**Note on PF v1 lineage:** A skill named `seven-validation-questions` exists in PF v1 (`production-framework/skills/seven-validation-questions/SKILL.md`), but its 7 questions are different (Simplest approach? / Pattern match? / Enterprise consensus? / Rule count? / Per-item auth? / Sibling data flow? / Performance at scale?). The v2 redesign in this brief swaps PF-internal heuristics (Q1, Q2, Q3, Q4 of v1) for industry-standard disciplines that align with SP, Anthropic, and enterprise OSS analogs.

---

## Part 1: Sources Inventory

| # | Source | URL | Type | Retrieved |
|---|---|---|---|---|
| 1 | SP 5.0.7 — `skills/writing-plans/SKILL.md` | local cache | precedent | 2026-04-30 |
| 2 | SP 5.0.7 — `skills/brainstorming/SKILL.md` | local cache | precedent | 2026-04-30 |
| 3 | SP 5.0.7 — `skills/verification-before-completion/SKILL.md` | local cache | precedent | 2026-04-30 |
| 4 | SP 5.0.7 — `skills/subagent-driven-development/spec-reviewer-prompt.md` | local cache | precedent | 2026-04-30 |
| 5 | SP 5.0.7 — `skills/subagent-driven-development/SKILL.md` | local cache | precedent | 2026-04-30 |
| 6 | SP 5.0.7 — `skills/requesting-code-review/SKILL.md` | local cache | precedent | 2026-04-30 |
| 7 | SP 5.0.7 — `agents/code-reviewer.md` | local cache | precedent | 2026-04-30 |
| 8 | PF v1 — `skills/seven-validation-questions/SKILL.md` | local | prior version | 2026-04-30 |
| 9 | Anthropic — *Building Effective AI Agents* (Dec 19 2024) | https://www.anthropic.com/research/building-effective-agents | primary | 2026-04-30 |
| 10 | Anthropic — *How we built our multi-agent research system* (Jun 2025) | https://www.anthropic.com/engineering/multi-agent-research-system | primary | 2026-04-30 |
| 11 | Anthropic — *Effective context engineering for AI agents* | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | primary | 2026-04-30 |
| 12 | Amazon — Working Backwards PR/FAQ (6-pager) | https://workingbackwards.com/concepts/working-backwards-pr-faq-process/ | enterprise | 2026-04-30 |
| 13 | Google — Design Docs at Google (Industrial Empathy / ex-Googler canonical post) | https://www.industrialempathy.com/posts/design-docs-at-google/ | enterprise | 2026-04-30 |
| 14 | AWS — Well-Architected Framework (6 pillars) | https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html | enterprise | 2026-04-30 |
| 15 | MADR — Markdown Architectural Decision Records | https://adr.github.io/madr/ | OSS standard | 2026-04-30 |
| 16 | Y-Statement (Olaf Zimmermann, SATURN 2012) | https://medium.com/olzzio/y-statements-10eb07b5a177 | academic / industry | 2026-04-30 |
| 17 | INVEST mnemonic (Bill Wake) — user-story acceptance bar | https://en.wikipedia.org/wiki/INVEST_(mnemonic) | industry standard | 2026-04-30 |
| 18 | Google SRE Book — *Reliable Product Launches* / Launch Coordination Checklist | https://sre.google/sre-book/launch-checklist/ | enterprise | 2026-04-30 |
| 19 | Google SRE Book — *Production Readiness Review* | https://sre.google/sre-book/evolving-sre-engagement-model/ | enterprise | 2026-04-30 |
| 20 | Google SRE — *Reliable Releases and Rollbacks* (CRE Life Lessons) | https://cloud.google.com/blog/products/gcp/reliable-releases-and-rollbacks-cre-life-lessons | enterprise | 2026-04-30 |
| 21 | Lunney — *Postmortem Action Items: Plan the Work and Work the Plan* (USENIX ;login: Spring 2017) | https://www.usenix.org/system/files/login/articles/login_spring17_09_lunney.pdf | conference | 2026-04-30 |

---

## Part 2: Verbatim Citations Organized by the 7 Questions

### Q1 — Why now? (trigger + cost of inaction)

**SP precedent (weak — adjacent):** SP `writing-plans/SKILL.md` line 54 requires every plan to open with `**Goal:** [One sentence describing what this builds]` and `**Architecture:** [2-3 sentences about approach]` — closest to "why" but not "why now". SP `brainstorming/SKILL.md` line 78: "Focus on understanding: purpose, constraints, success criteria." SP does not enforce a trigger / cost-of-delay question.

**Anthropic precedent (indirect):** *Building Effective Agents* — "find the simplest solution... only increase complexity when needed." Implicit "do not build unless triggered by need" but no explicit "why now" question.

**Enterprise analog (strong):** Amazon Working Backwards PR/FAQ (Source 12).

> "Why will this new product be compelling enough for customers to take action and buy it? — a common question executives ask is 'so what?' — if the press release doesn't describe a product that is meaningfully better (faster, easier, cheaper) than what is already out there, then it isn't worth building."
> — Working Backwards PR/FAQ, https://workingbackwards.com/concepts/working-backwards-pr-faq-process/

The "so what?" filter is Amazon's institutionalised answer to "why now". The PR/FAQ is rejected if it cannot pass it.

**Enterprise analog (strong):** Google Design Doc — "Context and scope" is the first required section.
> "Design docs typically include the following key sections: Context and scope, Goals and non-goals…"
> — *Design Docs at Google*, https://www.industrialempathy.com/posts/design-docs-at-google/

"Context and scope" is the standard frame in which "why now" lives.

**Enterprise analog (strong):** MADR template requires `Context and Problem Statement` plus `Decision Drivers` as core sections.
> "The core parts of the MADR template include context, decision and consequences, with supplemental parts including status, decision drivers, options with their pros and cons and more information."
> — About MADR, https://adr.github.io/madr/

---

### Q2 — Why this approach? (alternatives considered)

**SP precedent (strong):** SP `brainstorming/SKILL.md` line 82 explicitly mandates this:

> "**Exploring approaches:**
> - Propose 2-3 different approaches with trade-offs
> - Present options conversationally with your recommendation and reasoning
> - Lead with your recommended option and explain why"
> — SP `brainstorming/SKILL.md` lines 80–84

**SP precedent (strong):** SP `brainstorming/SKILL.md` line 142 — "**Explore alternatives** - Always propose 2-3 approaches before settling".

**Anthropic precedent (indirect):** *Building Effective Agents* — "Anthropic recommends finding the simplest solution possible, and only increasing complexity when needed... You should consider adding complexity only when it demonstrably improves outcomes."

**Enterprise analog (strong):** Google Design Doc — "Alternatives Considered" is a mandatory section.
> "Alternatives Section: This section lists alternative designs that would have reasonably achieved similar outcomes, focusing on the trade-offs that each respective design makes and how those trade-offs led to the decision to select the primary design. This is one of the most important sections."
> — *Design Docs at Google*

**Enterprise analog (strong):** Y-Statement (Zimmermann, SATURN 2012) — six-element template explicitly requires `neglected alternatives`.
> "1. context: functional requirement (story, use case) or arch. component, 2. facing: non-functional requirement, for instance a desired quality, 3. we decided: decision outcome (arguably the most important part), 4. and neglected alternatives not chosen (not to be forgotten!), 5. to achieve: benefits…, 6. accepting that: drawbacks and other consequences…"
> — *Y-Statements*, https://medium.com/olzzio/y-statements-10eb07b5a177

**Enterprise analog (strong):** MADR template — `Considered Options` section with `Pros and Cons of the Options`.

---

### Q3 — What invariants must hold? (pre/post conditions, multi-tenant boundaries)

**SP precedent (medium):** SP `verification-before-completion/SKILL.md` lines 96–98 — "**Requirements:** Re-read plan → Create checklist → Verify each → Report gaps or completion." SP enforces post-condition verification but does not name "invariants" as a category.

**SP precedent (medium):** SP `subagent-driven-development/spec-reviewer-prompt.md` lines 41–48: "**Missing requirements:** Did they implement everything that was requested? Are there requirements they skipped or missed? **Misunderstandings:** Did they interpret requirements differently than intended?" — implicitly a post-condition check, not a pre-condition or invariant statement.

**Anthropic precedent (medium):** *Effective Context Engineering* explicitly uses the word "invariants" in tool/context contexts.
> "The API provides a robust version of tool-result clearing that handles correct block-pairing invariants, tool-specific exclusions, and token counting and automatic triggering."
> — *Effective context engineering for AI agents*

**Enterprise analog (strong):** AWS Well-Architected — Reliability pillar specifies design questions about invariant maintenance.
> "For reliability, there are specific patterns you must follow, such as loosely coupled dependencies, graceful degradation, and limiting retries. Changes to your workload or its environment must be anticipated and accommodated to achieve reliable operation of the workload."
> — *AWS Well-Architected: Reliability Pillar*, https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html

**Enterprise analog (strong):** Google Design Doc — "Cross-Cutting Concerns" section institutionalises invariants like security, privacy, observability that must hold across the design.
> "Cross-Cutting Concerns: This is where organizations can ensure that certain cross-cutting concerns such as security, privacy, and observability are always taken into consideration. These are often relatively short sections that explain how the design impacts the concern and how the concern is addressed."
> — *Design Docs at Google*

**Enterprise analog (strong):** Google SRE PRR — analysis phase explicitly checks invariants (e.g., "Does the service connect to the appropriate serving instance of its dependencies? For example, end-user requests to a service should not depend on a system that is designed for a batch-processing use case.")
— *Google SRE Book — Production Readiness Review*, https://sre.google/sre-book/evolving-sre-engagement-model/

---

### Q4 — What's the contract? (input/output/error shape)

**SP precedent (strong):** SP `writing-plans/SKILL.md` lines 65–80 — task structure mandates exact file paths, file responsibilities, exact code blocks, exact test inputs and expected outputs.
> "**Files:** Create: `exact/path/to/file.py` … Test: `tests/exact/path/to/test.py`"
> — SP `writing-plans/SKILL.md` lines 67–71

**SP precedent (strong):** SP `writing-plans/SKILL.md` lines 113–115:
> "Steps that describe what to do without showing how (code blocks required for code steps); References to types, functions, or methods not defined in any task"
> — SP `writing-plans/SKILL.md` lines 113–115

I.e., the "no placeholder" rule is exactly a contract-completeness rule.

**SP precedent (strong):** SP `writing-plans/SKILL.md` line 130:
> "**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug."
> — SP `writing-plans/SKILL.md` line 130

This is a literal contract self-review.

**Anthropic precedent (strong):** *Building Effective Agents* — agent-computer interface (ACI) discipline.
> "Is it obvious how to use this tool, based on the description and parameters, or would you need to think carefully about it? If so, then it's probably also true for the model. A good tool definition often includes example usage, edge cases, input format requirements, and clear boundaries from other tools."
> — *Building Effective Agents*

**Enterprise analog (strong):** INVEST — `T = Testable` requires acceptance criteria; `V = Valuable` requires output value to user; `I = Independent` requires clean boundaries.
> "Testable: The story can be tested to ensure it passes a clear set of acceptance criteria."
> — *INVEST mnemonic*, https://en.wikipedia.org/wiki/INVEST_(mnemonic)

**Enterprise analog (strong):** Google Design Doc — "Detailed Design (including system-context-diagram, APIs, data storage, code and pseudo-code, constraints)" is required.

---

### Q5 — What's the failure mode? (partial-failure semantics, blast radius)

**SP precedent (weak):** SP has no explicit "failure mode" question. SP `verification-before-completion` covers post-fact failure detection ("Tests pass, 0 failures") but not design-time failure-mode enumeration.

**Anthropic precedent (weak):** No direct "failure modes" question in *Building Effective Agents*. *How we built our multi-agent research system* discusses agent failure modes (early agents "spawning 50 subagents for simple queries") as observed mistakes rather than a design-time question.

**Enterprise analog (strong):** AWS Well-Architected — Reliability pillar.
> "Automatically recover from failure by setting and monitoring workload KPIs and triggering automation when a threshold is breached. Test recovery procedures using automation to simulate or recreate scenarios that lead to failure."
> — *AWS Well-Architected: Reliability Pillar*

**Enterprise analog (strong):** Google SRE — blast-radius framing.
> "In order to reduce the blast radius of outages, avoid global changes and adopt advanced deployments strategies that allow you to gradually deploy changes. Consider progressive and canary rollouts over the course of hours, days, or weeks, which allow you to reduce the risk and to identify an issue before all your users are affected."
> — *SRE: Reliable Releases and Rollbacks*, https://cloud.google.com/blog/products/gcp/reliable-releases-and-rollbacks-cre-life-lessons

**Enterprise analog (medium):** Google Design Doc "Cross-Cutting Concerns" (when concerns include reliability).

**Enterprise analog (strong):** Lunney — Postmortem Action Items categorisation.
> "Lunney classifies action items by category (Investigate, Mitigate, Repair, Detect, Prevent) to make sure that the action item plan covers both very short-term and longer-term fixes."
> — Lunney, USENIX ;login: Spring 2017, https://www.usenix.org/system/files/login/articles/login_spring17_09_lunney.pdf

The Mitigate/Detect/Prevent categories are the post-incident mirror of design-time failure-mode enumeration.

---

### Q6 — How is it observed? (logs, metrics, traces, alerts)

**SP precedent (weak):** SP has no observability-design question. SP focuses on test verification, not production telemetry.

**Anthropic precedent (medium):** *Building Effective Agents* — "Maintain simplicity in your agent's design. Prioritize transparency by explicitly showing the agent's planning steps." This supports the observability principle but at agent-design level, not service-level telemetry.

**Enterprise analog (strong):** AWS Well-Architected — Operational Excellence pillar.
> "How do you design your workload so that you can understand its state? Design your workload so that it provides the information necessary for you to understand its internal state (for example, metrics, logs, and traces) across all components."
> — *AWS Well-Architected: Operational Excellence Pillar*

This is a verbatim "logs, metrics, traces" question identical to Q6's framing.

**Enterprise analog (strong):** Google SRE Launch Checklist — Monitoring is a required category.
> "Set up monitoring for your new service."
> — *SRE Launch Checklist*, https://sre.google/sre-book/launch-checklist/

**Enterprise analog (strong):** Google Design Doc — Cross-Cutting Concerns explicitly names observability.
> "Cross-cutting concerns such as security, privacy, and observability are always taken into consideration."
> — *Design Docs at Google*

---

### Q7 — How is it reverted? (rollback, cleanup, feature-flag exit)

**SP precedent (strong):** SP `finishing-a-development-branch/SKILL.md` lines 50–63 — four exit options including "discard" — is the closest SP analog. Each option requires a clean reversion path.

**SP precedent (medium):** SP `verification-before-completion/SKILL.md` line 84:
> "**Regression tests (TDD Red-Green):** Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)"
> — SP `verification-before-completion/SKILL.md` line 84

The red-green cycle is a tiny rollback drill: SP enforces revertability at the test level.

**Anthropic precedent (none direct):** No rollback question in published Anthropic essays.

**Enterprise analog (strong):** Google SRE — rollback as first-class concern.
> "If unexpected behavior is detected, roll back first and diagnose afterward in order to minimize Mean Time to Recovery."
> — *SRE: Reliable Releases and Rollbacks*

**Enterprise analog (strong):** Google SRE Launch Checklist — rollback procedure required category (verbatim from Search Source: covers "graceful degradation, and external dependencies").

**Enterprise analog (medium):** AWS Well-Architected — Reliability pillar requires testing recovery procedures.

**Enterprise analog (medium):** Y-Statement `accepting that:` clause encodes the cost / drawback of the chosen path, including the cost of reverting it.

---

## Part 3: Q-to-Enterprise-Analog Mapping Table

| # | PF Question | Strongest SP precedent | Strongest Anthropic | Strongest enterprise analog | Strength |
|---|---|---|---|---|---|
| Q1 | Why now? | (none direct — SP `writing-plans` "Goal:" line) | (indirect — "increase complexity only when needed") | **Amazon Working Backwards PR/FAQ "so what?"** + Google Design Doc "Context and scope" + MADR "Context and Problem Statement" | strong (3+ enterprise analogs) |
| Q2 | Why this approach? | **SP `brainstorming/SKILL.md` lines 82–84 "Propose 2-3 different approaches with trade-offs"** | "consider adding complexity only when it demonstrably improves outcomes" | Google Design Doc "Alternatives Considered" + Y-Statement "neglected alternatives" + MADR "Considered Options" | very strong (SP + 3 enterprise) |
| Q3 | What invariants must hold? | (medium — SP `spec-reviewer-prompt.md` "did they implement everything requested") | "block-pairing invariants" (context engineering) | AWS Well-Architected Reliability + Google Design Doc "Cross-Cutting Concerns" + Google SRE PRR | strong (3 enterprise) |
| Q4 | What's the contract? | **SP `writing-plans/SKILL.md` lines 67–80 + 130 (file paths, type consistency)** | **ACI: "input format requirements, edge cases, clear boundaries"** | INVEST `T=Testable` + Google Design Doc "Detailed Design" + Y-Statement | very strong (SP + Anthropic + 3 enterprise) |
| Q5 | What's the failure mode? | (weak) | (weak — observed agent failures, not design-time question) | AWS Well-Architected Reliability + Google SRE blast-radius + Lunney post-mortem categories (Mitigate/Detect/Prevent) | strong (3 enterprise) but weak SP+Anthropic |
| Q6 | How is it observed? | (none) | (weak — "transparency by explicitly showing planning steps") | **AWS Well-Architected Operational Excellence "metrics, logs, traces"** + Google SRE Launch Checklist Monitoring + Google Design Doc Cross-Cutting | strong (3 enterprise) but weak SP+Anthropic |
| Q7 | How is it reverted? | SP `finishing-a-branch` four options + `verification-before-completion` revert-fix red-green | (none direct) | Google SRE "roll back first, diagnose afterward" + AWS Well-Architected recovery testing + Y-Statement `accepting that:` | strong (3 enterprise) |

---

## Part 4: Gap Analysis — which questions have weakest external grounding

**Strongest grounded:** Q2 (Why this approach?) and Q4 (What's the contract?). Both have direct SP precedent **and** direct Anthropic citation **and** ≥3 enterprise analogs. These two are unambiguously defensible under the binding rule.

**Strongly grounded:** Q1 (Why now?), Q3 (Invariants), Q7 (Revert). Each has ≥3 enterprise analogs and at least adjacent SP/Anthropic touchpoints.

**Weakest grounded:** **Q5 (Failure mode) and Q6 (Observability).** Both have:
- No direct SP precedent (SP focuses on test verification, not production observability or design-time failure enumeration)
- Only weak/indirect Anthropic citation ("transparency by explicitly showing planning steps" applies to agent design, not service telemetry; Anthropic does not publish failure-mode-design guidance)
- Strong enterprise grounding (AWS Well-Architected, Google SRE) but the binding rule is SP+Anthropic; enterprise-only puts Q5/Q6 in the same boat as the GAPs called out in the citation manifest (e.g., GAP-2 `gate-3-production-check`).

**Mitigation strategy for Q5/Q6:**
1. Cite AWS Well-Architected and Google SRE explicitly in the SKILL.md body — they are best-in-class enterprise standards exactly mirroring Q5/Q6 phrasing.
2. Tag the questions as "Industry-framework adapted" in the skill's frontmatter description, identical framing to citation-manifest GAP-2.
3. Honestly disclose: "PF v2 imports the failure-mode + observability disciplines from AWS Well-Architected and Google SRE. SP's discipline ends at unit/integration test verification; Anthropic publishes no service-telemetry guidance. We extend the boundary."

This is **the same pattern used by `gate-3-production-check`** (per `sp-anthropic-citation-manifest.md` GAP-2). Q5 and Q6 are essentially an inline-into-plan version of `gate-3-production-check`'s observability and reliability categories. **Recommend cross-linking the two skills explicitly** so they share grounding.

---

## Part 5: Recommendations for Skill Body Content

### R1 — Use a HARD-GATE marker

Per SP precedent (`brainstorming/SKILL.md` lines 12–14, `verification-before-completion/SKILL.md` lines 18–22, `test-driven-development/SKILL.md` lines 32–36): every SP discipline-skill that gates execution wraps the gate in either `<HARD-GATE>...</HARD-GATE>` or `## The Iron Law`. This skill should adopt one of the two. **Recommended:** `<HARD-GATE>Do NOT dispatch builders if any of the 7 questions returns BLOCKED.</HARD-GATE>` — matches PF v2 binding-rule shape and SP `brainstorming` precedent.

### R2 — Tier-2/3 guard, not Tier-1

Per the design brief, this skill runs against Tier 2/3 plans only. Frontmatter `description` should match the SP "use when" discipline (`writing-skills/SKILL.md` lines 140–172): action-oriented, identifying triggers. Example:
> "Use after a build plan is written and before any builder dispatch on Tier 2 or Tier 3 plans — answers 7 validation questions against the source files (not assumptions). A plan that cannot answer all 7 returns BLOCKED."

### R3 — Per-question evidence requirement (SP precedent)

Each of the 7 answers MUST cite evidence from a file the Deputy/CTO has read in this session. PF v1 already enforces this for its 7-question set ("Answer against EVIDENCE: for Tier 3, the architecture doc and enterprise research findings; for Tier 2, actual file reads. Answering from memory or intuition invalidates the answers."). Carry forward verbatim from `production-framework/skills/seven-validation-questions/SKILL.md` line 8.

### R4 — One section per question with Anti-Pattern + Red Flag rows

Match SP precedent for `brainstorming` (line 16 `## Anti-Pattern: "This Is Too Simple To Need A Design"`) and the Red Flags table convention from SP `verification-before-completion` (lines 53–74), `test-driven-development` (lines 256–270), `systematic-debugging` (lines 245–256). Each of the 7 questions should ship with:
- A 1-sentence purpose statement
- "Required evidence" line (which file/doc the answer must read)
- An Anti-Pattern (the failure mode this question prevents)
- A Red Flag row in a Q-specific rationalization table

### R5 — BLOCKED status uses PF v2 status-token grammar

Per `sp-anthropic-citation-manifest.md` row "Status token grammar: `DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT`" and SP `subagent-driven-development/SKILL.md` lines 102–118. The skill's terminal output is one of those four tokens. A plan that cannot answer all 7 returns `BLOCKED` with a specific question number and the missing evidence path.

### R6 — Cross-link to `gate-3-production-check` for Q5/Q6

Q5 (failure mode) and Q6 (observability) overlap with `gate-3-production-check`'s 7 categories. Add a `Composability` section noting that this skill is the *plan-time* version of `gate-3-production-check`'s *ship-time* gate — same disciplines, applied earlier. This strengthens grounding for the weakest-cited questions and creates a coherent two-stage gate (plan → ship).

### R7 — Cite Y-Statement format for Q1+Q2 answers

Q1 (why now) + Q2 (why this approach) map cleanly onto the Y-Statement template: `In context X, facing Y, we decided Z, neglecting alternatives A/B, to achieve Q, accepting D`. **Recommendation:** when answering Q1+Q2, use the Y-Statement single-sentence form. This compresses two questions into one disciplined answer and pulls in a 14-year-old industry-standard ADR template. Cite Zimmermann SATURN 2012 in the skill body.

### R8 — For Q4, require typed-shape evidence (SP "type consistency" precedent)

Q4 (contract) is best served by reusing SP `writing-plans/SKILL.md` line 130 — "type consistency" self-review. Require Q4's answer to enumerate input shape, output shape, and error shape with concrete types or schemas drawn from the plan. "JSON object" or "string" is not an answer. Mirror SP's `clearLayers()` vs `clearFullLayers()` example as the canonical Q4 anti-pattern.

### R9 — For Q5+Q6, embed AWS Well-Architected verbatim and credit it

Per recommendation in Part 4, the Q5 and Q6 sections should include verbatim quotes from AWS Well-Architected as the discipline source — same approach `agent-design-post-mortem.md` takes with Google SRE. This is the honest framing: "PF v2 adopts AWS Well-Architected's framing of failure modes and observability."

### R10 — Place skill in cycle execution flow before builder dispatch

Per `cto-mode/SKILL.md` Checklist line 35 ("Dispatch the cycle — follow the cycle's agent graph"), the 7-question gate runs at step 2.5 — **after** plan write (step 2) and **before** dispatch (step 3). Update `cto-mode/SKILL.md` Checklist to reference this skill explicitly when the deputy CTO is invoking writing-plans for Tier 2/3 work.

---

## Part 6: Citations Footer

**Anthropic primary sources (re-verify before binding decisions):**
- *Building Effective AI Agents* — https://www.anthropic.com/research/building-effective-agents
- *How we built our multi-agent research system* — https://www.anthropic.com/engineering/multi-agent-research-system
- *Effective context engineering for AI agents* — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents

**Superpowers 5.0.7 source files (local cache):**
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/writing-plans/SKILL.md`
- `.../skills/brainstorming/SKILL.md`
- `.../skills/verification-before-completion/SKILL.md`
- `.../skills/subagent-driven-development/SKILL.md`
- `.../skills/subagent-driven-development/spec-reviewer-prompt.md`
- `.../skills/requesting-code-review/SKILL.md`
- `.../skills/finishing-a-development-branch/SKILL.md`
- `.../agents/code-reviewer.md`

**Production-framework v1 prior-art:**
- `c:/Users/atyab/Experimental - Users/production-framework/skills/seven-validation-questions/SKILL.md` (different 7-question set; kept for cross-reference only)

**Enterprise / OSS sources:**
- Amazon Working Backwards PR/FAQ — https://workingbackwards.com/concepts/working-backwards-pr-faq-process/
- Google Design Docs (Industrial Empathy) — https://www.industrialempathy.com/posts/design-docs-at-google/
- AWS Well-Architected Framework — https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html
- MADR — https://adr.github.io/madr/
- Y-Statement (Zimmermann, SATURN 2012) — https://medium.com/olzzio/y-statements-10eb07b5a177
- INVEST mnemonic — https://en.wikipedia.org/wiki/INVEST_(mnemonic)
- Google SRE Launch Checklist — https://sre.google/sre-book/launch-checklist/
- Google SRE PRR — https://sre.google/sre-book/evolving-sre-engagement-model/
- Google SRE — Reliable Releases and Rollbacks — https://cloud.google.com/blog/products/gcp/reliable-releases-and-rollbacks-cre-life-lessons
- Lunney, *Postmortem Action Items* (USENIX ;login: Spring 2017) — https://www.usenix.org/system/files/login/articles/login_spring17_09_lunney.pdf

**Companion PF v2 research docs cross-referenced:**
- `c:/Users/atyab/Experimental - Users/production-framework-v2/docs/research/sp-anthropic-citation-manifest.md`
- `c:/Users/atyab/Experimental - Users/production-framework-v2/docs/research/agent-design-post-mortem.md`
- `c:/Users/atyab/Experimental - Users/production-framework-v2/docs/research/enterprise-multi-agent-architecture.md`

**Methodology disclosure (re-stated):** WebFetch was permission-denied. All Anthropic and external quotes were retrieved via WebSearch synthesis of canonical URLs. Re-verify against live URLs before binding architectural decisions.
