---
name: heavy-read-dispatch
description: "Use when the next step requires reading >3 files of source material to produce a single deliverable (audit, doc generation, codebase survey, pattern catalog, STACK-PATTERNS bootstrap). Dispatches a researcher sub-agent so the main session never burns context on background reads."
---

# Heavy-Read Dispatch

The orchestrator-vs-worker rule for context. `tier-selection` scales execution rigor; `heavy-read-dispatch` scales context. They run orthogonally: a Tier 1 doc-generation task that requires reading 10+ source files goes through a sub-agent regardless of execution simplicity, because the cost is context, not complexity.

## When to Use

Trigger BEFORE the first read if any of these match:

- Deliverable is a single doc (architecture, audit, STACK-PATTERNS, research summary, pattern catalog) AND producing it requires reading ≥3 source files.
- User asks to "audit," "survey," "catalog," "summarize," or "generate a doc from" an area of the codebase.
- First-session bootstrap step "generate STACK-PATTERNS.md from the template" — Rule 29.
- About to read ≥3 files in a row before writing a single output.

Do NOT use:

- Implementation work — the Builder agent already isolates context.
- Targeted reads — one specific file you need to edit.
- User explicitly asks for direct execution AND the read scope is small (≤3 files).

## Core Pattern

1. **Stop before reading.** As soon as the trigger matches, do not read in main context.
2. **Dispatch a researcher sub-agent.** Use the Agent tool with `subagent_type: production-framework:researcher`. For fast targeted lookups (≤3 queries) prefer `Explore` instead.
3. **Brief the sub-agent.** Pass absolute paths to read, the template path to follow, and the output file path. Tell it to return ≤30 lines listing what it wrote — never to paste the doc inline.
4. **Receive the summary.** Read the produced file on disk only if you need to verify or follow up. Never reflate context with the sub-agent's full reading material.

<HARD-GATE>
Main session does not read >3 files of source material to produce a single deliverable. If the trigger matches, dispatch first. This is the v1-vs-v2 architectural difference; ignoring it returns the framework to the failure mode v2 was forked to escape.
</HARD-GATE>

## Quick Reference

| Task shape | Action |
|---|---|
| First-session STACK-PATTERNS.md generation (Rule 29) | Dispatch researcher with template path + project sources + audit memory; return ≤30-line summary |
| Architecture doc for a new module | Dispatch researcher first; the architect agent reads the research doc, not the raw source |
| "Survey all Server Actions" / "audit X area" | Dispatch researcher; main session reads the summary |
| Pattern catalog from incident memory | Dispatch researcher; main session ratifies via `ratify-pattern` skill |
| Edit one file you've already located | Direct read; trigger does not match |
| Tier 3 architecture step | Dispatch researcher BEFORE the architect — research output gates the architect's read scope |

## Composability

- Composes with `tier-selection` — orthogonal axes (execution rigor vs. context discipline).
- Composes with `enterprise-research-first` — the researcher invoked here applies ER1 citation discipline by default.
- Composes with `cto-mode` Checklist Step 1 — heavy-read-dispatch fires before cycle dispatch on audit-shaped tasks.

## Citations

- **Anthropic Claude Code documentation** — the Agent tool exists to keep main context clean. Built-in trigger language: "for broad codebase exploration that'll take more than 3 queries, spawn Agent."
- **Anthropic *Effective context engineering for AI agents*** — "Each subagent operates with an isolated context window... prevents cross-contamination between phases of the workflow and keeps each agent focused." (https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- **v2's own forking rationale** — PF v1 used a CTO-does-everything-in-main-context shape that empirically failed (telephone-game anti-pattern); v2 was rebuilt on SP's skill cascade specifically to enforce dispatch discipline. (`production-framework-v2/CLAUDE.md`, "Why fork.")
- **N≥3 enterprise consensus**:
  - **LangGraph** — separates planner / researcher / critic nodes; planner never reads source directly.
  - **AutoGen** — orchestrator + worker pools; orchestrator dispatches reads to workers.
  - **CrewAI** — manager + worker crews; manager only reads summaries.
- **Framework's existing output discipline** — "Researcher returns ≤30 lines" is the corollary of this skill's input discipline ("main session reads ≤3 files before dispatching"). They are two halves of the same context-isolation principle, codified in `production-framework-v2/CLAUDE.md` Output Discipline section.
