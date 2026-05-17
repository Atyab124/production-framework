---
name: parallel-reconciliation
description: "Use after 2+ agents (researchers / debuggers / builders / etc.) have returned in parallel — reconciles their outputs into a single decision. Closing primitive paired with dispatching-parallel-agents. Includes verdict-precedence ladder for conflicting findings + HARD-GATE against silent override. Auto-loaded by SubagentStop hook (v2.5.0) when ≥2 parallel returns are detected within 10 minutes; catalog C-04 blocks the next consuming dispatch until the reconciliation doc lands."
---

> **Auto-loaded by SubagentStop hook (v2.5.0, F-9 fix).** When ≥2 sub-agents complete within 10 minutes on the same cycle, `hooks/subagent-stop` writes a `.framework-state/pending-reconciliation.jsonl` marker AND injects a system-reminder into the next CTO turn pointing at this skill. Catalog C-04 (parallel-reconciliation gate, PR-11) is in block-tier and will deny the next consuming dispatch until `docs/reconciliation/<wave-id>.md` materializes. The skill no longer relies on dispatcher initiative — auto-load + block-on-absent-doc together close FEEDBACK F-9 (warn-tier silent-skip was structurally undiscoverable). Output contract: produce `docs/reconciliation/<wave-id>-<UTC>.md` per Step 4 below; the gate verifies presence before unblocking.

## Overview

PF v1 documented (audit Item 29): `dispatching-parallel-agents` opens N agents but no skill exists for closing — i.e., reconciling N outputs into a single decision when they converge OR conflict. Manual reconciliation drifts: one researcher's recommendation overrides another's silently because one was applied first.

This skill is the closing primitive paired with the opener. **Wave 1 research recommends NEW STANDALONE SKILL** (not extension of dispatching-parallel-agents) per 5 grounded reasons including SP's canonical paired-skill idiom (`using-git-worktrees` ↔ `finishing-a-development-branch`) + CLAUDE.md "Skill Changes Require Evaluation" cost.

**Enterprise grounding: 5/7 BINDING** on a named, discrete reconciliation/synthesis step — Anthropic *How we built our multi-agent research system* (lead-agent synthesis), Anthropic *Effective Context Engineering* (file-artifact reconciliation), LangGraph (summarizer node), CrewAI (`manager_agent.synthesizes`), ChatDev (phase-end convergence). Outliers: AutoGen (emergent via group-chat rounds) + MetaGPT (emergent via filtered subscription).

<HARD-GATE>
When N parallel returns disagree, the reconciler MUST surface the disagreement explicitly with verbatim point-of-conflict + the precedence-ladder step that broke the tie (or escalate to user). **Silent override of a minority finding is a discipline failure** — directly addresses Item 29's empirical drift.

A reconciler that emits "all good, here's the merged answer" without naming the conflicts and the resolution rule is the failure this skill exists to prevent.
</HARD-GATE>

## When to Use

- After ≥2 agents dispatched in parallel via `dispatching-parallel-agents` have returned.
- After ≥2 researchers in a single research wave have returned (e.g., this session's Wave 1 / 1.5 / 2 / 3).
- After ≥2 debuggers worked in parallel on different layers of a multi-component bug.
- Before the orchestrator (CTO / Deputy) writes a "synthesize for user" message.

Do NOT use:
- For a single-agent return (no reconciliation needed).
- When the agents were dispatched sequentially with explicit dependency (the later agent already incorporated the earlier).

## Core Pattern

You MUST create a TodoWrite item per step.

### Step 1 — Collect verdicts + status tokens

For each returned agent:
- Status token: `DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED` (per `parsing-agent-returns`)
- Verdict (from findings doc, if applicable): `APPROVE / APPROVE_WITH_FIXES / REJECT` (QA agent only) OR specific recommendation (Researcher / Debugger / etc.)
- Cited evidence: file path + line, K/N consensus strength, etc.

### Step 2 — Identify convergences and conflicts

For each decision dimension (same architectural question, same bug class, same recommendation surface):
- **Convergence:** all agents agree on the answer. Note the K/N strength.
- **Conflict:** ≥2 agents give different answers on the same dimension.

If all agents BLOCKED: re-dispatch broader (per Anthropic *Multi-Agent Research System*: "When subagents fail, the lead agent should reformulate the query rather than retry the same prompt.").

### Step 3 — Apply verdict-precedence ladder

For each conflict, apply the ladder in order. The first rule that resolves the conflict wins:

1. **Use-case-fit (cite ER1 Step 6).** If one recommendation applies a pattern the project's use case doesn't need (cargo-cult), reject it in favor of the use-case-fit alternative.
2. **Citation strength.** Recommendation backed by N/N at N≥5 (BINDING) wins over (N-1)/N at N≥3 (STRONG); STRONG wins over SPLIT; SPLIT wins over INSUFFICIENT.
3. **Convergence majority.** If ≥⌈N/2⌉+1 agents agree on one answer, adopt it; flag the minority finding explicitly.
4. **Status token precedence.** `DONE` outranks `DONE_WITH_CONCERNS`; `DONE_WITH_CONCERNS` is NOT silently downgraded to DONE — the concerns surface.
5. **Recency.** When all prior steps tie: most-recent finding wins (newer evidence > older evidence).
6. **Escalate to user.** If no rule resolves: write the conflict to the cycle-state file and ask the user.

### Step 4 — Produce reconciliation report

Output: `docs/reconciliation/<wave-name>-<UTC>.md`. Required sections:

- **Convergent findings** — list of dimensions where all agents agreed; cite consensus strength
- **Resolved conflicts** — for each conflict: the dimension, the divergent answers, the precedence-ladder rule that resolved it, the resolution
- **Unresolved conflicts (escalated)** — conflicts that hit Step 6 (escalate); listed for user adjudication
- **Final synthesis** — one paragraph that merges the convergent + resolved into a single recommendation

### Step 5 — Hand back to orchestrator

Pass the reconciliation report path to the dispatching orchestrator (CTO / Deputy). The orchestrator's "synthesize for user" message reads from this report — no duplication.

## Anti-Patterns

### "All researchers agreed, easy synthesis"

Even apparent convergence has minority findings. Per ChatDev phase-end convergence: "Without explicit conflict surfacing, lead-agent overrides are silent." Walk every dimension; name minorities; document why they were not the consensus.

### "I already merged the findings in my head"

Defeats the audit trail. The reconciliation report is the durable artifact; future readers (future you, future post-mortem) need to see the precedence-ladder reasoning.

### "Conflict X seems minor; I'll skip it"

Item 29's empirical drift came from exactly this. Silent overrides accumulate. Surface every conflict, even small ones; resolution can be one-line.

## Red Flags

| Excuse | Reality |
|---|---|
| "Recency wins, take the newest" | Recency is Step 5 of the ladder, not Step 1. Use-case-fit + citation strength precede recency. |
| "K/N=3/5 STRONG and K/N=4/5 STRONG, both pass — call it" | Adopt the higher (4/5); document that 3/5 was the divergent minority. Don't silently treat them as equivalent. |
| "Disagreement is normal; no need to escalate" | Disagreement that falls through all 5 ladder steps IS abnormal. Step 6 escalates to user — don't bypass. |

## Quick Reference

- Closes the parallel-dispatch loop (paired with `dispatching-parallel-agents`).
- 5-step pattern: collect → identify → apply ladder → report → hand back.
- 6-step verdict-precedence ladder: use-case-fit → citation strength → majority → status token → recency → escalate.
- HARD-GATE against silent override of minority findings.
- Output: `docs/reconciliation/<wave>-<UTC>.md` with convergent / resolved / unresolved sections.

## Composability

- **Pairs with `dispatching-parallel-agents`** — opener / closer pair, mirroring SP's `using-git-worktrees` ↔ `finishing-a-development-branch` paired-skill idiom.
- **Consumes `parsing-agent-returns`** — uses the 4-token grammar for status-precedence ladder Step 4.
- **Consumes `enterprise-research-first` Step 6** — cites use-case-fit as the highest precedence-ladder rule.
- **Feeds `cto-mode` step 7** — provides the detailed procedure behind cto-mode's currently-vague "synthesize for user."
- **Composable with `seven-validation-questions`** — when a research wave's reconciliation produces a Tier 2/3 plan, 7VQ runs against the synthesized plan.

## Citations

**SP precedent:**
- `superpowers/5.0.7/skills/dispatching-parallel-agents/SKILL.md` — the opener this pairs with
- `superpowers/5.0.7/skills/using-git-worktrees/SKILL.md` ↔ `finishing-a-development-branch/SKILL.md` — canonical SP paired-skill idiom (verbatim model for opener/closer)
- `superpowers/5.0.7/skills/subagent-driven-development/SKILL.md` lines 102–118 — 4-token grammar consumed in Step 4

**Anthropic guidance:**
- *How we built our multi-agent research system* — "the lead agent integrates findings from parallel subagents"; explicit synthesis step
- *Effective Context Engineering* — "agents can save information from tool call results as artifacts" (the reconciliation doc IS one)

**Enterprise / OSS (5/7 BINDING):**
- LangGraph supervisor / summarizer node: https://reference.langchain.com/python/langgraph/supervisor/
- CrewAI processes (`manager_agent.synthesizes`): https://docs.crewai.com/en/concepts/processes
- ChatDev phase-end convergence: https://arxiv.org/html/2307.07924v5
- AutoGen (emergent via group-chat rounds — outlier): https://microsoft.github.io/autogen/
- MetaGPT (emergent via filtered subscription — outlier): https://arxiv.org/html/2308.00352v6

**Companion PF v2 research:**
- `docs/research/skill-design-parallel-reconciliation.md` (Wave 1, Opus, 272L; 5/7 BINDING; structural verdict NEW STANDALONE)
