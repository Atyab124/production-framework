# Enterprise Multi-Agent Architecture — Reference

**Date:** 2026-04-29
**Type:** Research — no code modifications
**Triggered by:** PF v2.0.0 architectural validation against ≥5 enterprise/OSS multi-agent systems
**N≥3 binding rule:** Any architectural recommendation must be supported by ≥3 named frameworks. <3 → flag REDIRECT.

## Frameworks Compared

| Framework | Source | Last-verified | URL |
|---|---|---|---|
| MetaGPT | DeepWisdom / FoundationAgents (OSS, Python) | 2026-04-29 | https://github.com/FoundationAgents/MetaGPT · https://arxiv.org/html/2308.00352v6 |
| ChatDev | Tsinghua / OpenBMB (OSS, Python) | 2026-04-29 | https://github.com/OpenBMB/ChatDev |
| CrewAI | crewAIInc (OSS, Python) | 2026-04-29 | https://docs.crewai.com/en/concepts/processes · https://docs.crewai.com/en/concepts/memory |
| LangGraph | LangChain (OSS, Python/TS) | 2026-04-29 | https://github.com/langchain-ai/langgraph-supervisor-py · https://github.com/langchain-ai/langgraph-swarm-py |
| AutoGen + Magentic-One | Microsoft (OSS, Python) | 2026-04-29 | https://microsoft.github.io/autogen/stable/user-guide/core-user-guide/design-patterns/ · https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/magentic-one.html |
| OpenAI Swarm → Agents SDK | OpenAI (OSS, Python) | 2026-04-29 | https://github.com/openai/swarm · https://openai.github.io/openai-agents-python/ |
| Claude Code subagents | Anthropic (CC plugin runtime) | 2026-04-29 | https://code.claude.com/docs/en/sub-agents · https://platform.claude.com/docs/en/agent-sdk/subagents |

**Sample size:** N=7. Both N≥3 (consensus) and N≥5 (binding) thresholds available.

Note: OpenAI Swarm is officially superseded by the OpenAI Agents SDK ("Swarm is now replaced by the OpenAI Agents SDK, which is a production-ready evolution of Swarm" — github.com/openai/swarm README, verified 2026-04-29). Treated as one framework lineage.

## Axis 1 — Cycle / Process Selection

| Framework | Mechanism | Strength | Weakness |
|---|---|---|---|
| MetaGPT | Fixed SOP per role (waterfall: PRD → Design → Tasks → Code → QA). "Code = SOP(Team)" philosophy. | Strong domain encoding; deterministic. | One workflow shape only. |
| ChatDev | "ChatChain" — chain-shaped topology executing phased SDLC. MacNet generalisation supports broader topologies. | Phase model explicit; debuggable. | Single chain shape per run. |
| CrewAI | User picks `Process.sequential` or `Process.hierarchical`. Hierarchical requires `manager_llm` or custom `manager_agent`. | Explicit user choice; clean API. | Only two shapes. |
| LangGraph | Graph-based `StateGraph`. Pre-built libs: `langgraph-supervisor-py`, `langgraph-swarm-py`, hierarchical (supervisor of supervisors). | Most flexible; multi-level supervision. | Steeper authoring cost; no built-in cycle catalogue. |
| AutoGen | Named patterns: two-agent chat, sequential chat, group chat, nested chat, reflection, Magentic-One. Microsoft Agent Framework v1.0 adds: sequential, concurrent, handoff, group chat, Magentic-One orchestrations. | Catalogue of named shapes — closest analogue to PF v2's "8 cycle templates". | User must read several docs to map task to pattern. |
| OpenAI Agents SDK | Function-based handoffs; agent `return`s another agent. No top-level "process" enum. Handoffs/guardrails/sessions are primitives. | Minimal abstraction. | No prescribed cycle catalogue. |
| Claude Code subagents | Parent dispatches via Agent tool; each call is fresh-context delegation. Orchestration logic lives in parent prompt. | Simple primitive; isolation automatic. | No native multi-shape selection. |

### Synthesis

**Consensus on "named workflow patterns" (5/7):** AutoGen, CrewAI, LangGraph, MetaGPT, ChatDev all expose **named, distinct orchestration shapes**. **BINDING per N=5/7.**

**Consensus on "user picks shape per task" (3/7):** CrewAI, LangGraph, AutoGen. MetaGPT and ChatDev hard-code one shape; Agents SDK and Claude Code leave shape implicit. **CONSENSUS (3/7).**

**PF v2's 8-cycle template approach** sits closest to **AutoGen's pattern catalogue**. PF v2's naming (Build / Debug / Research / Refactor / Security / Performance / Migration / Postmortem) is **task-domain-flavoured** (close to MetaGPT's SOP framing) whereas AutoGen's names are **interaction-shape-flavoured** (sequential, concurrent, handoff). Both framings exist in the wild — neither is wrong.

**Outliers (2/7):** OpenAI Agents SDK and Claude Code treat workflow as emergent from primitives. They shift the burden to the orchestrator's prompt logic — which is exactly what PF v2's CTO does atop Claude Code subagents.

## Axis 2 — Agent Roster Shape

| Framework | Agent count | Role categories | Rigid vs flexible |
|---|---|---|---|
| MetaGPT | **5 fixed** (Product Manager, Architect, Project Manager, Engineer, QA Engineer) | Product, design, PM, build, test | Rigid SOP. |
| ChatDev | **6 fixed** (CEO, CTO, Programmer, Designer, Reviewer, Tester) | Exec, build, design, review, test | Rigid SDLC waterfall. |
| CrewAI | **N flexible** (`Agent(role=, goal=, backstory=)`) | User-defined | Fully flexible. |
| LangGraph | **N flexible** (user defines nodes) | User-defined | Fully flexible. |
| AutoGen | **N flexible**; Magentic-One reference team: Orchestrator, WebSurfer, FileSurfer, Coder, ComputerTerminal (5) | Orchestrator + capability specialists | Flexible API. |
| OpenAI Agents SDK | **N flexible**; minimal `Agent(instructions=, tools=)` | User-defined | Fully flexible. |
| Claude Code subagents | **N flexible**; markdown spec files in `.claude/agents/` | User-defined | Fully flexible. |

### Synthesis

**Consensus on "flexible roster" (5/7):** CrewAI, LangGraph, AutoGen, Agents SDK, Claude Code. Only MetaGPT and ChatDev hard-code roles. **STRONG (5/7).**

**Consensus on "single orchestrator at top" (5/7):**
- MetaGPT: Project Manager closest.
- ChatDev: CEO + CTO leadership.
- CrewAI hierarchical: `manager_agent`.
- LangGraph: explicit Supervisor node.
- AutoGen Magentic-One: Orchestrator with Task + Progress Ledgers.

PF v2's **CTO role** has direct analogues in 5/7 frameworks — **STRONG (5/7).** The function (single orchestrator with planning + delegation) is consistently present.

**Roster-count comparison:**
- Hard-coded rosters: 5–6 (MetaGPT 5, ChatDev 6, Magentic-One 5).
- PF v2: **14 specialists** — **2.3–2.8× larger than any documented hard-coded roster.**
- Frameworks supporting >10 fixed roles: 0/7. PF v2 is an outlier on count, but 5/7 frameworks support arbitrary N, so the count itself is not architecturally invalid — it's a product opinion. **No REDIRECT** — but document as deliberate; validate empirically via incident logging.

**PF v2 roles vs framework consensus:**
- **Orchestrator (CTO)** — 5/7 STRONG. Keep.
- **Engineer/Builder** — MetaGPT (Engineer), ChatDev (Programmer), Magentic-One (Coder). 3/7 CONSENSUS. PF's split into Backend Builder + Frontend Builder is **0/7** — novel.
- **QA / Tester** — MetaGPT (QA Engineer), ChatDev (Tester). 2/7 SPLIT.
- **Product Manager** — MetaGPT, ChatDev (CEO covers requirements). 2/7 SPLIT.
- **Architect** — MetaGPT (Architect), ChatDev (CTO closest). 2/7 SPLIT.
- **Code Reviewer** — ChatDev (Reviewer). 1/7 — no consensus, PF unique.
- **Debugger** — 0/7. PF unique.
- **Researcher / SRE / Security / UX-Design / Database-Engineer / Post-Mortem** — 0/7 each. PF unique.

**Missing in PF v2:** Magentic-One's **tool-affordance specialists** (WebSurfer, FileSurfer, ComputerTerminal) split capability by *tool* not *job-title*. PF splits exclusively by job-title. Defensible difference; could add tool-affordance specialists in v2.1 if domain demands.

## Axis 3 — Shared Context Substrate

| Framework | Substrate | Persistence | Scope |
|---|---|---|---|
| MetaGPT | **Global shared message pool with publish-subscribe**. Agents publish structured messages; others subscribe to filtered streams. | In-memory per run + workspace files (PRD, design docs). | Crew-wide. |
| ChatDev | Chain-shaped message passing along ChatChain phases. | In-memory + workspace files. | Chain-wide. |
| CrewAI | **Three memory stores** unified by Contextual Memory: Short-term (ChromaDB + RAG), Long-term (SQLite3 across sessions), Entity (RAG). | ChromaDB + SQLite3 — **persistent across sessions**. | Crew + cross-session. |
| LangGraph | **Shared state object** (TypedDict) flowing through nodes. **Checkpointer** (`InMemorySaver`/`SqliteSaver`/`PostgresSaver`) persists state. **Store** for cross-thread memory. Swarm tracks `active_agent` marker. | In-memory or SQL via checkpointer. | Graph-wide + cross-thread via store. |
| AutoGen / Magentic-One | Group-chat broadcast. Magentic-One adds **Task Ledger** + **Progress Ledger**. Microsoft Agent Framework adds runtime message bus. | In-memory; ledgers persist for run. | Team-wide. |
| OpenAI Agents SDK | **`context` object** dependency-injected into every agent + tool + handoff. **Sessions** as persistent memory layer. Handoff transfers full message history. | Sessions persist; context per-run. | Run-wide; sessions persistent. |
| Claude Code subagents | **Each subagent has fresh 200K context window**. Parent communicates only via Agent tool prompt + final return text. **No shared state object** between parent/subagent. Filesystem is only durable cross-agent substrate. | Filesystem (durable) + parent's own context. | Subagent-isolated; durable shared state must be on disk. |

### Synthesis

**Consensus on "structured shared-state object" (5/7):** MetaGPT (message pool), CrewAI (memory stores), LangGraph (state + checkpointer), AutoGen (ledgers + group chat), Agents SDK (context object). **STRONG (5/7).**

**Consensus on "persistent shared state across runs" (4/7):** CrewAI, LangGraph, Agents SDK, AutoGen via Microsoft Agent Framework. **CONSENSUS (4/7).**

**Outliers (2/7):** ChatDev (chain-only message passing) and Claude Code (filesystem-only between subagents) lack a structured in-memory shared-state object.

### Where PF v2 sits

PF v2's substrate is **file-based** (`docs/cycle-state.md`, `docs/plans/<feature>.md`, `docs/research/<topic>.md`, `docs/PROJECT-PLAN.md`, `docs/adr/<n>-<decision>.md`).

**This is the Claude Code subagent reality:** subagents have isolated context windows; the only durable cross-agent channel is the filesystem. PF v2's choice is **forced by the runtime** — and matches Claude Code's documented model exactly.

**N≥3 support for file-based substrate as the *primary* mechanism: 1/7 (Claude Code only).** Every other framework has a structured in-memory shared-state object. **REDIRECT NOT APPLICABLE** because PF v2 is a Claude Code plugin — it cannot use a non-Claude-Code substrate. The right framing: PF v2 is solving the cross-subagent persistence problem the same way every Claude Code workflow must — markdown files on disk. `docs/cycle-state.md` is essentially a hand-rolled equivalent of CrewAI's contextual memory or LangGraph's state object.

**Gap to flag for v2.1:** the 4/7 frameworks with persistent cross-run memory all use a **structured store with retrieval semantics** (vector DB or SQL), not free-form markdown. Markdown is human-readable and Builder/QA-friendly, but doesn't support semantic retrieval. **For v2.1+:** consider adding a vector-indexed retrieval layer over `docs/research/` if the corpus grows beyond ~50 docs (linear-scan loading becomes context-window-heavy at that scale).

## Architectural Recommendations for PF v2

### KEEP AS-IS (≥3 framework support)

1. **Named cycle templates as user-selectable workflow shapes** — supported by AutoGen, CrewAI, LangGraph, MetaGPT, ChatDev. **5/7 BINDING.**
2. **Single-orchestrator (CTO) at the top** — supported by ChatDev, CrewAI, LangGraph, AutoGen Magentic-One, MetaGPT. **5/7 STRONG.**
3. **Flexible roster size (N=14)** — supported by CrewAI, LangGraph, AutoGen, Agents SDK, Claude Code. **5/7 STRONG.**
4. **Builder/Engineer + QA/Tester roles** — Builder/Engineer 3/7 CONSENSUS (MetaGPT, ChatDev, Magentic-One).
5. **File-based cross-agent substrate (within Claude Code)** — runtime-forced; matches Claude Code's documented model.
6. **Parent dispatches subagents with isolated contexts** — exact Claude Code subagent model.

### REDIRECT (<3 framework support)

1. **None of PF v2's high-level architectural choices fall below the N=3 bar** for the three axes researched.
2. **Soft REDIRECT — Backend/Frontend Builder split** — 0/7 frameworks split builders this way. Document rationale in ADR; consider merging in v2.1 if no incidents materialise from a unified Builder.
3. **Soft REDIRECT — Researcher / SRE / Security / UX-Design / Database-Engineer / Post-Mortem as standing roles** — 0/7. Treat each as candidate for incident-driven validation: if 6-month incident log shows the role consistently catches issues no other role catches, keep; otherwise consolidate. Track in PROJECT-PLAN.md.

### ADD FOR FUTURE (≥3 framework support, not in v2.0)

1. **Persistent cross-run structured memory store (vector DB or SQL)** — CrewAI (ChromaDB + SQLite), LangGraph (checkpointer/store), Agents SDK (sessions), AutoGen runtime. **4/7 CONSENSUS — eligible for v2.1.** Trigger: when `docs/research/` exceeds ~50 docs OR CTO frequently hits "we already researched this last cycle, but it's not loaded" incidents.
2. **Swarm-style autonomous handoff** (no central supervisor) — LangGraph swarm, Agents SDK handoffs, AutoGen group-chat. **3/7 CONSENSUS.** PF v2 is supervisor-only. Adding a swarm cycle (e.g., collaborative refactor where Builder ↔ Reviewer iterate without CTO mediation) eligible for v2.1.
3. **Reflection pattern as a named cycle** — AutoGen explicitly; Magentic-One Progress Ledger; LangGraph permits it. **3/7 CONSENSUS.** PF v2's Postmortem is post-hoc; an in-cycle reflection pass (Builder reflects before handing to QA) is a documented pattern PF could adopt.
4. **Tool-affordance specialists (WebSurfer-style)** — Magentic-One only. **1/7 — does not clear N≥3.** Re-evaluate only if domain incidents demand it.
5. **Task Ledger + Progress Ledger pattern** — Magentic-One only. **1/7 — does not clear N≥3.** Skip.

## Citations (all verified 2026-04-29)

**MetaGPT:** https://github.com/FoundationAgents/MetaGPT · https://arxiv.org/html/2308.00352v6 · https://www.ibm.com/think/topics/metagpt

**ChatDev:** https://github.com/OpenBMB/ChatDev

**CrewAI:** https://docs.crewai.com/en/concepts/processes · https://docs.crewai.com/how-to/hierarchical-process · https://docs.crewai.com/en/concepts/memory

**LangGraph:** https://github.com/langchain-ai/langgraph-supervisor-py · https://github.com/langchain-ai/langgraph-swarm-py · https://reference.langchain.com/python/langgraph-supervisor

**AutoGen / Magentic-One:** https://microsoft.github.io/autogen/stable/user-guide/core-user-guide/design-patterns/intro.html · https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/magentic-one.html · https://learn.microsoft.com/en-us/agent-framework/user-guide/workflows/orchestrations/magentic

**OpenAI Swarm → Agents SDK:** https://github.com/openai/swarm · https://openai.github.io/openai-agents-python/ · https://openai.github.io/openai-agents-python/handoffs/

**Claude Code subagents:** https://code.claude.com/docs/en/sub-agents · https://platform.claude.com/docs/en/agent-sdk/subagents · https://claude.com/blog/subagents-in-claude-code
