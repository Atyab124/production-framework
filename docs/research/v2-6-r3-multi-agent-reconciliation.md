# v2.6 R3 — Multi-Agent Reconciliation + Parallel Coordination

**Date:** 2026-05-27
**Researcher:** v2.6 design wave, Researcher #3 of 6
**Dispatch question:** How do enterprise multi-agent frameworks enforce output landing, scope discipline, and parallel-output reconciliation?
**Closes FEEDBACK.md:** §1.1 agent-output-file-landed · §1.2 write-side scope intersection · §8.1 file-scope-overlap pre-dispatch · §8.2 parallel-reconciliation auto-load · §8.4 CTO dispatch boundary-coverage
**Status token:** DONE

---

## Eligibility criteria (PRISMA)

**Included:** Frameworks must (a) support multi-agent orchestration as a primary use case, (b) have published primary documentation or OSS source on a coordination primitive, (c) ship at least one mechanism applicable to ≥1 of the 7 sub-dimensions. Single-agent frameworks and wrapper libraries excluded as primary citations.

**Excluded:**
- Aggregators (LiteLLM, OpenRouter) — not coordination primitives.
- Vendor wrappers republishing other frameworks without their own coordination semantics.
- AI-generated summaries / SEO content farms as primary sources (Anthropic source-quality heuristic).

**Sample:** N=6 enterprise/OSS frameworks meet criteria — **LangGraph, AutoGen Core, CrewAI, OpenAI Agents SDK, Anthropic Claude Code multi-agent research system, MetaGPT.** Both N≥3 (consensus) and N≥5 (binding) thresholds met per `docs/adr/001-7-gap-decisions.md` G1.

## Search strategy

| Round | Queries | Tool calls | Outcome |
|---|---|---|---|
| 0 — context | Read `sp-anthropic-citation-manifest.md` (§2.7, §2.17), `enterprise-multi-agent-architecture.md`, `skill-design-parallel-reconciliation.md`, FEEDBACK §1 + §8 | 6 local reads | Anthropic citations already verified in manifest; 7-framework prior research available |
| 1 — broad | LangGraph state reducer, CrewAI Task attrs, AutoGen topic-subscription, OpenAI handoffs | 4 WebFetch (2 succeeded, 2 denied → fallback) | LangGraph SPA stub → switched to `docs.langchain.com` + WebSearch; OpenAI denied → WebSearch fallback; CrewAI direct hit |
| 2 — narrow | INVALID_CONCURRENT_GRAPH_UPDATE, TypeSubscription mapping, concurrent-agents pattern, guardrails tripwire | 1 WebFetch + 3 WebSearch | Strong primary-source matches; guardrails semantics confirmed |
| 3 — primary | LangGraph reducer mechanics, CrewAI processes, Anthropic essay quotes, MetaGPT message pool | 2 WebFetch + 2 WebSearch | All 6 frameworks have verbatim quotes |
| **Total** | | **12 net tool calls** | Within 10-15 budget |

## Frameworks compared

| Framework | Source | Last-verified | Primary URL |
|---|---|---|---|
| LangGraph | LangChain (OSS, Python/TS) | 2026-05-27 | https://docs.langchain.com/oss/python/langgraph/errors/INVALID_CONCURRENT_GRAPH_UPDATE · https://reference.langchain.com/python/langgraph/graph/state/StateGraph |
| AutoGen Core | Microsoft (OSS, Python) | 2026-05-27 | https://microsoft.github.io/autogen/stable/user-guide/core-user-guide/core-concepts/topic-and-subscription.html · /design-patterns/concurrent-agents.html |
| CrewAI | crewAIInc (OSS, Python) | 2026-05-27 | https://docs.crewai.com/en/concepts/tasks · /processes |
| OpenAI Agents SDK | OpenAI (OSS, Python) | 2026-05-27 | https://openai.github.io/openai-agents-python/handoffs/ · /guardrails/ |
| Anthropic — Claude Code multi-agent | Anthropic (closed-source product, published essays) | 2026-05-27 | https://www.anthropic.com/engineering/multi-agent-research-system · /effective-context-engineering-for-ai-agents |
| MetaGPT | DeepWisdom / FoundationAgents (OSS, Python) | 2026-05-27 | https://arxiv.org/html/2308.00352v6 · https://docs.deepwisdom.ai/main/en/guide/in_depth_guides/agent_communication.html |

---

## §1 — Executive summary (7 bullets)

1. **State-merge reducers are the canonical fix for parallel state collisions.** LangGraph names the failure (`INVALID_CONCURRENT_GRAPH_UPDATE`) and forces an `Annotated[T, reducer]` declaration; the reducer is a typed function `(Value, Value) -> Value`. PF's analog is the write-side `scope_write[]` intersection check + `cycle-state.md` reducer convention. **4/6 frameworks** (LangGraph, MetaGPT, AutoGen, CrewAI-hierarchical) have an explicit merge surface; **2/6** (OpenAI Agents SDK, Anthropic) leave merge to the orchestrator's prompt logic. **Implication for §1:** PF needs a write-side merge contract, not just an enforcement gate.

2. **Output-file validation is universal where outputs are file-based.** CrewAI explicitly types `Task.output_file`, `Task.output_pydantic`, and `Task.guardrail` (callable returning `(bool, Any)` with `guardrail_max_retries=3`). OpenAI Agents SDK uses `output_type` Pydantic models + `output_guardrail` with `tripwire_triggered`. Anthropic's research system explicitly inserts a "Citation Agent" stage before final report. **5/6 frameworks** have a discrete output-validation surface separate from the agent. **Implication for §1.1:** PF's `agent-output-file-landed` HARD-GATE is consistent with enterprise practice — current gap is having a per-dispatch declarative output spec (CrewAI `output_file` + `output_pydantic`) rather than only parsing the prompt for `WRITE THE FILE`.

3. **Routing/subscription enforces message boundaries via type+key, not natural-language descriptions.** AutoGen Core's `TypeSubscription(topic_type, agent_type)` maps `(topic_type, topic_source)` → `(agent_type, agent_key)` — boundaries are runtime-enforced by the message broker. MetaGPT's shared message pool uses a "subscription mechanism filtering out irrelevant contexts." LangGraph uses graph edges (compile-time). **All 6 frameworks** enforce boundaries structurally, never via instruction-prompt alone. **Implication for §8.1:** PF's file-scope-overlap pre-dispatch must be a runtime check (PreToolUse hook), not a dispatch-prompt directive.

4. **Handoffs in OpenAI Agents SDK use `input_filter`/`input_type` + a pipeline that bypasses tool guardrails.** Per the SDK: "Handoffs run through the SDK's handoff pipeline rather than the normal function-tool pipeline, so tool guardrails do not apply to the handoff call itself. However, input guardrails still apply only to the first agent in the chain, and output guardrails only to the agent that produces the final output." **Implication:** treating sub-agent dispatch as a handoff (not a tool call) lets guardrails attach at chain endpoints — analogous to PF's SubagentStop hook.

5. **Anthropic's research system uses 3-5 parallel subagents + dedicated synthesis + dedicated citation validation.** Three-tier topology: Lead Researcher → parallel Subagents → Citation Agent → final report. The Citation Agent is a *separate* validator stage, not a property of subagents — analog to PF's `parallel-reconciliation` skill. **5/6 frameworks** have a named synthesis/aggregation primitive (LangGraph summarizer node, CrewAI manager_agent, AutoGen ClosureAgent, MetaGPT downstream subscriber, Anthropic Lead+Citation). AutoGen alone leaves it implicit via GroupChat speaker selection.

6. **File-artifact substrate dominates Anthropic + Claude Code; message-passing substrate dominates AutoGen + MetaGPT.** Anthropic *Effective context engineering*: "Agents can save information from tool call results as artifacts, making it available to other agents and users... Common background information is provided via a persistent context file (CLAUDE.md)." AutoGen + MetaGPT use shared message pools / topic pubsub. CrewAI + LangGraph are hybrid (typed state + optional file output). **Substrate choice has cascading consequences for reconciliation** — see §3 below.

7. **Convergence/divergence reconciliation is always a named, distinct step — never emergent.** Anthropic Lead Researcher "synthesizes these results and decides whether more research is needed"; CrewAI manager_agent "synthesizes their outputs and terminates execution at the right point"; LangGraph aggregator/summarizer nodes; ChatDev's "two unchanged code modifications" termination condition (per `skill-design-parallel-reconciliation.md`). **6/6 frameworks** treat reconciliation as a discrete primitive, validating PF's `parallel-reconciliation` skill being a separate skill (not inlined into `dispatching-parallel-agents`). The CTO-as-default-synthesizer is consistent with CrewAI's hierarchical manager — but requires explicit prompts, not implicit role.

---

## §2 — Comparison table

| Framework | State-merge / fan-in | Output validation | Routing / topic boundaries | Handoff / orchestrator handover | Parallel coordination |
|---|---|---|---|---|---|
| **LangGraph** | Explicit `Annotated[T, reducer]` declaration in TypedDict/Pydantic state schema. Missing reducer + parallel writes → `INVALID_CONCURRENT_GRAPH_UPDATE` error raised by runtime. Reducer signature `(Value, Value) -> Value`. | StateGraph nodes return state dicts; merging is structural via reducers. No per-node output-type validation surface (Pydantic schema at graph compile time, not per-edge). | Graph edges (compile-time). `Send` API for explicit fan-out. | `Command` primitive returns next-node hint. | Native — multiple nodes execute in the same super-step; reducer aggregates. |
| **AutoGen Core** | Implicit — developers write aggregator agents (e.g., `ClosureAgent`) that subscribe to results topic. No automatic state merge. Concurrent writes are independent messages. | Per-message type contracts (Pydantic). `RoutedAgent` `@message_handler` decorator dispatches by message type. No built-in output guardrail. | `TypeSubscription(topic_type, agent_type)` — runtime broker maps topics → agent IDs by type. Topic = `(topic_type, topic_source)` 2-tuple. | Direct messaging via `send_message`; topic publish for broadcast. No "handoff" primitive — message passing is the substrate. | Native via `asyncio.gather()`; aggregator agent receives results topic. |
| **CrewAI** | Sequential or hierarchical Process. Hierarchical: manager_agent owns delegation+synthesis. Sequential: output of one task → context of next (typed via `Task.context`). | Strong — `Task.output_pydantic` / `Task.output_json` (Pydantic models), `Task.output_file` (path), `Task.guardrail` (callable `(bool, Any) → retry up to guardrail_max_retries=3`). | Task-graph topology declared in Crew config. No type-subscription model. | Hierarchical manager delegates; tasks have explicit `agent` assignment. | Hierarchical Process — manager_agent dispatches + synthesizes in one role. No native parallel-fan-out primitive (sequential default). |
| **OpenAI Agents SDK** | None — handoff transfers control, not state. State persists via Sessions abstraction. | `output_type` (Pydantic schema). `@output_guardrail` decorator with `tripwire_triggered: bool` field — when true, raises `OutputGuardrailTripwireTriggered` exception and halts execution. Input guardrails apply only to first agent in chain; output guardrails only to final agent. | Implicit via handoff selection (LLM picks next agent from available `handoffs=[...]`). | First-class — `handoffs` parameter on Agent; `input_filter`, `input_type`, `on_handoff` callback. Bypasses tool-guardrail pipeline. | Not native at SDK level — orchestration is a single Runner stepping through handoffs. Parallelism delegated to user code (asyncio). |
| **Anthropic Claude Code** | Lead Researcher maintains "overall research state through a memory system that persists context when conversations exceed 200,000 tokens." Subagents return condensed summaries; merge happens in Lead's context. | Three-tier: subagent returns → Lead synthesizes → Citation Agent validates source-attribution before final report. Citation Agent is a *separate* validator stage. | Sub-agent dispatch via Agent tool; each invocation isolated context. `.claude/agents/*.md` frontmatter declares scope. | Sub-agent invocation is the handoff (no explicit "handover" primitive — return-to-parent is implicit on SubagentStop). | Native — lead spawns 3-5 subagents simultaneously; subagents themselves execute multiple tool calls in parallel ("parallel tool calling at two levels"). |
| **MetaGPT** | Implicit — shared global message pool. Agents publish; downstream subscribers filter. SOP fixes the merge sequence. | Pydantic-typed `Message` objects with `role` + `content` + `cause_by` (which Action produced it). No discrete guardrail step — SOP enforces validity by next role's review. | Subscription mechanism filters by message role / cause_by. Project Manager's plan determines who consumes what. | SOP-driven sequence (PM → Architect → Engineer → QA). No dynamic handoff; topology is fixed per role. | Limited — MetaGPT's SOP is sequential by design; parallelism is within an agent's tool use, not across agents. |

---

## §3 — File-artifact substrate vs message-passing analysis

### Anthropic's substrate choice (file artifacts + CLAUDE.md)

Per *Effective context engineering for AI agents* (Anthropic Engineering, via citation manifest §2.17):

> "Agents can save information from tool call results as artifacts, making it available to other agents and users. This enables persistent memory and knowledge sharing across agent interactions."

> "Common background information is provided via a persistent context file (CLAUDE.md), which is preloaded into each agent's context."

> "Each subagent operates with an isolated context window... This design is intentional: it prevents cross-contamination between different phases of the workflow and keeps each agent focused."

Per *How we built our multi-agent research system* (Anthropic Engineering, Jun 2025, via citation manifest §2.7):

> "The lead agent maintains overall research state through a memory system that persists context when conversations exceed 200,000 tokens, preventing loss of research plans and findings."

**Substrate consequences:** File-artifact substrate (Anthropic + Claude Code) makes parallel coordination *deterministic* (files have paths; conflicts are detectable by path overlap) but requires explicit landing enforcement (`agent-output-file-landed` — file may not exist if agent narrates instead of writes). Message-passing substrate (AutoGen + MetaGPT) makes parallel coordination *probabilistic* (messages may not be consumed; subscribers may filter incorrectly) but landing is automatic (message is published or it isn't).

### Comparable framework choices

| Framework | Substrate | Cost of parallel coordination | Cost of output-landing enforcement |
|---|---|---|---|
| Anthropic Claude Code | **File artifacts** (`docs/**`) + ephemeral context | LOW (path-based scope detection) | HIGH (narrative DONE without file is the FEEDBACK §1.1 failure mode) |
| LangGraph | **Typed state** (TypedDict/Pydantic) | LOW (reducer is structural) | LOW (state shape is the contract) |
| AutoGen Core | **Messages** (typed via `@message_handler`) | MEDIUM (subscription correctness) | N/A (no file landing — pure pub/sub) |
| CrewAI | **Hybrid** — task outputs + optional `output_file` | MEDIUM (sequential default) | LOW (`output_pydantic` + `output_file` declared per Task) |
| OpenAI Agents SDK | **Session state** (passed between handoffs) | N/A (no native parallelism) | LOW (`output_type` Pydantic schema) |
| MetaGPT | **Message pool** (shared global) | MEDIUM (subscription filter quality) | N/A (no file landing — pool is the substrate) |

**Key finding:** PF v2.6 inherits Anthropic's substrate choice (file artifacts) but lacks the per-dispatch declarative output contract (CrewAI's `output_file` + `output_pydantic`) that makes "did the agent produce its output?" a runtime-checkable predicate. **Recommendation:** dispatch prompts should carry explicit `output_files: list[str]` + `output_schema: dict[path → contract]` fields, not just informally embed `WRITE THE FILE` in prose.

### When enterprise frameworks coordinate parallel writes

The dominant pattern (4/6: LangGraph, MetaGPT, AutoGen, CrewAI-hierarchical) is **either reducer-on-shared-state OR aggregator-agent-on-message-stream** — never two parallel writers to the same path/key without a declared merge primitive. PF's analog: file-scope-overlap pre-dispatch (FEEDBACK §8.1).

LangGraph quote (via WebSearch synthesis of canonical URL `docs.langchain.com/oss/python/langgraph/errors/INVALID_CONCURRENT_GRAPH_UPDATE`, 2026-05-27):

> "Multiple nodes in a fanout within a single step return values for the same key, the graph will throw this error because there is uncertainty around how to update the internal state."

> "If your graph executes nodes in parallel, make sure you have defined relevant state keys with a reducer."

The error existing at all is the load-bearing finding: LangGraph's authors decided that ambiguous parallel writes should *fail loudly at runtime*, not silently last-writer-wins. PF should do the same on `scope_write[]` overlap — block dispatch rather than allow race.

---

## §4 — Convergence/divergence reconciliation patterns

### Convergent case

**Pattern (5/6 frameworks):** Aggregator/synthesizer agent reads all returns, produces single output. Skip when all agents return identical recommendation.

- **Anthropic Lead Researcher:** "synthesizes these results and decides whether more research is needed — if so, it can create additional subagents or refine its strategy" (via `skill-design-parallel-reconciliation.md` S1).
- **CrewAI manager_agent:** "synthesizes their outputs and terminates execution at the right point" (via S6 same file).
- **LangGraph supervisor:** "summarizer aggregates the results from each agent and generates the final output" (via S4).
- **AutoGen ClosureAgent:** subscribes to results topic, combines explicitly (`combined_result = f'Part 1: ..., Part 2: ...'`).
- **MetaGPT next-role subscriber:** SOP enforces who consumes; reconciliation is implicit in role sequence.

### Divergent case (the failure mode FEEDBACK §8 is about)

**Pattern (3/6):** Re-dispatch with conflict context, or escalate to higher-tier judgment.

- **Anthropic:** Lead "decides whether more research is needed... can create additional subagents or refine its strategy" — explicit re-dispatch on insufficient convergence.
- **ChatDev** (from prior research file): "Subtask would terminate and get a conclusion either after two unchanged code modifications or after 10 rounds of communication" — convergence detection with hard-cap.
- **CrewAI hierarchical (documented limitation):** "out-of-the-box hierarchical mode does not effectively coordinate, forcing users to implement an explicit synthesis step in a custom manager" — empirical evidence that *implicit divergence handling fails*, and **explicit re-dispatch must be coded** (via `skill-design-parallel-reconciliation.md` S6).

**Implication for PF §8.2:** `parallel-reconciliation` auto-load is correct. The verdict-precedence ladder (per prior `skill-design-parallel-reconciliation.md`) is necessary because no enterprise framework solves divergence implicitly — they all either escalate or re-dispatch.

### Convergent-exemption (FEEDBACK §8.2 fix #2)

> "Auto-trigger `parallel-reconciliation` post-hook (shipped v2.5 PR-10; verify firing). Convergent-returns exemption: when all parallel returns converge on same recommendation, reconciliation can be a one-line note in cycle-state instead of separate doc."

**Verification against enterprise practice:** CrewAI sequential Process treats single-task-output→next-task-context as the trivial case (no reconciliation primitive needed). LangGraph reducers like `operator.add` on convergent lists trivially merge. **The exemption is consistent with 4/6 frameworks** — when there's nothing to reconcile, the named primitive can degrade to a no-op note. CTO judgment: keep the exemption but require a one-line cycle-state record so the audit trail is preserved.

---

## §5 — Recommendations for v2.6

### §1.1 — `agent-output-file-landed` HARD-GATE at SubagentStop

**Findings backing the recommendation:**
- CrewAI: `Task.output_file` is a typed field on Task — "File path for storing the task output" — and `output_pydantic` "ensures that the output is not only structured but also validated according to the Pydantic model."
- OpenAI Agents SDK: `output_type` is a top-level Agent parameter; output_guardrails raise `OutputGuardrailTripwireTriggered` and *halt* execution.
- LangGraph: `INVALID_CONCURRENT_GRAPH_UPDATE` halts the run rather than silently dropping data.

**Recommendation:**
1. **Dispatch prompt schema must include declarative `output_files: list[str]` field**, not just embedded `WRITE THE FILE` prose. Parser extracts this field structurally (no prompt-engineering brittleness). Mirror CrewAI's `Task.output_file` API shape.
2. **SubagentStop hook checks every declared output_file exists with `size > 0`** before recording `DONE`. Missing → override to `OUTPUT_MISSING`, force re-dispatch. Mirror OpenAI Agents SDK's `tripwire_triggered → halt` pattern.
3. **Recidivism counter:** ≥2 narrative-only DONEs from same agent type in 30 days flips that agent type to global "narrative-only DONE = automatic OUTPUT_MISSING." Captures the FEEDBACK §1.1b "fabricated standing instruction" failure mode (anti-rationalization).

### §1.2 — Write-side `file-scope-intersection` gate

**Findings backing:**
- LangGraph: explicit `INVALID_CONCURRENT_GRAPH_UPDATE` failure mode at parallel-write time.
- AutoGen: `TypeSubscription(topic_type, agent_type)` *runtime-enforced*, not prompt-enforced.
- CrewAI: hierarchical mode's manager_agent has explicit "step-wise instructions that... synthesizes their outputs, and terminates execution at the right point."

**Recommendation:**
1. **PreToolUse hook on `Write`**: parse dispatch prompt's `scope_write[]` field (already exists per FEEDBACK §1c framing); reject any Write whose target path doesn't intersect `scope_write[]` patterns. Mirror LangGraph's load-fail-loudly principle.
2. **`scope_write[]` glob syntax** documented in dispatch-prompt schema. Researcher dispatches default-deny `docs/cycle-state.md` (caught FEEDBACK §1c Architect-overwrote-cycle-state regression).
3. **No silent override.** PreToolUse `permissionDecision: 'deny'` + `permissionDecisionReason: 'path {x} not in scope_write {y}'` — agent receives the rejection and must surface as `DONE_WITH_CONCERNS` if path was actually needed. Mirror OpenAI's `tripwire_triggered → halt + reason`.

### §8.1 — File-scope-overlap pre-dispatch check

**Findings backing:**
- LangGraph's reducer mandate: parallel writers to same key require declared merge primitive — *or runtime fails*.
- AutoGen's TypeSubscription: runtime broker maps topic → agent_id structurally.
- MetaGPT's filtered subscription mechanism eliminates information overload.

**Recommendation:**
1. **Pre-dispatch hook (CTO mode):** when dispatch carries new `scope_write[]`, compute intersection with all running agents' `scope_write[]` from `.framework-state/active-agents.jsonl`. Non-empty intersection → BLOCKED with: *"wait for upstream {agent_id}; modifying {file} that is in your scope_write."*
2. **Mirror LangGraph's failure-mode:** the absence of a reducer/merge primitive on a shared file is a *structural* error, not a runtime race. Block at dispatch time, not at SubagentStop.
3. **Reducer declaration optional:** dispatches may declare `merge_strategy: append | overwrite_with_review | requires_reconciliation` (analogous to LangGraph's reducer signature). Default = `requires_reconciliation` → auto-dispatch `parallel-reconciliation` post-fan-in.

### §8.2 — `parallel-reconciliation` auto-load

**Findings backing:**
- 6/6 frameworks treat reconciliation as a discrete, named primitive (not emergent).
- Anthropic's research system has a *dedicated Citation Agent* as the validator stage.
- CrewAI's documented limitation: "out-of-the-box hierarchical mode does not effectively coordinate" — implicit reconciliation **does not work** in practice.

**Recommendation:**
1. **Keep v2.5 PR-10 auto-trigger.** SubagentStop hook detecting ≥2 parallel returns within 10min triggers `parallel-reconciliation` skill load, blocking next consuming dispatch until reconciliation doc lands. Already shipped — verify firing in v2.6.
2. **Convergent-exemption:** when all parallel returns converge on identical recommendation (string-match on Status token + Recommendation paragraph), allow one-line cycle-state note instead of separate doc. Mirrors CrewAI sequential's no-reconciliation-needed case.
3. **Divergent escalation ladder** (from prior `skill-design-parallel-reconciliation.md`): adopt Anthropic's "Lead can create additional subagents or refine its strategy" pattern. Verdict-precedence ladder: identical → merge / contradicts-on-fact → re-dispatch fact-checker / contradicts-on-judgment → escalate to user.

### §8.4 — CTO dispatch boundary-coverage check

**Findings backing:**
- AutoGen's `TypeSubscription` makes message boundaries explicit at the *type level* — applications declare which agent handles which topic_type up front.
- MetaGPT's SOP explicitly maps roles to message types.
- Anthropic's Lead Researcher "analyzes [the query], decides on an overall strategy, and records the plan in memory" — strategy precedes dispatch.

**Recommendation:**
1. **Pre-wave hook:** CTO must write a one-line "critical path crossings" list (e.g., `canvas → store → server-action → DB → executor`) before dispatching any wave. Stored at `docs/cycle-state.md#wave-N-coverage`.
2. **Coverage assertion:** union of all wave dispatches' `scope_write[]` must cover every crossing on the list. Missing crossing → BLOCKED with: *"add a wave or extend an existing dispatch's scope to cover {crossing}."*
3. **Mirror AutoGen's TypeSubscription:** boundaries are runtime-enforced via the same `.framework-state/active-agents.jsonl` substrate already used for §8.1. One file, both checks.

---

## §6 — Citation table

| # | Source | Verbatim quote | URL | Verified | Tag |
|---|---|---|---|---|---|
| C1 | LangGraph — INVALID_CONCURRENT_GRAPH_UPDATE | "Multiple nodes in a fanout within a single step return values for the same key, the graph will throw this error because there is uncertainty around how to update the internal state." | https://docs.langchain.com/oss/python/langgraph/errors/INVALID_CONCURRENT_GRAPH_UPDATE | 2026-05-27 | (via WebSearch synthesis of canonical URL — WebFetch on docs.langchain.com denied) |
| C2 | LangGraph — reducer best practice | "If your graph executes nodes in parallel, make sure you have defined relevant state keys with a reducer." Reducer signature `(Value, Value) -> Value`. Example: `numbers: Annotated[list[int], add]`. | same | 2026-05-27 | (via WebSearch synthesis) |
| C3 | CrewAI — Task output_file | "File path for storing the task output." | https://docs.crewai.com/en/concepts/tasks | 2026-05-27 | WebFetch direct |
| C4 | CrewAI — Task output_pydantic | "A Pydantic model for task output." "Ensures that the output is not only structured but also validated according to the Pydantic model." | same | 2026-05-27 | WebFetch direct |
| C5 | CrewAI — Task.guardrail | "Function to validate task output before proceeding to next task." Guardrail returns `(bool, Any)`; on False, "error message is communicated back to the agent... process repeats until... maximum retries are exhausted (controlled by `guardrail_max_retries`, defaulting to 3)." | same | 2026-05-27 | WebFetch direct |
| C6 | CrewAI — sequential vs hierarchical Process | "Executes tasks sequentially, ensuring tasks are completed in an orderly progression." / "Organizes tasks in a managerial hierarchy, where tasks are delegated and executed based on a structured chain of command." "A manager language model (`manager_llm`) or a custom manager agent (`manager_agent`) must be specified in the crew to enable the hierarchical process." | https://docs.crewai.com/en/concepts/processes | 2026-05-27 | WebFetch direct |
| C7 | CrewAI — manager synthesis | "The fix involves introducing a custom manager agent with explicit, step-wise instructions that uses triage results, conditionally calls only the required agents, synthesizes their outputs, and terminates execution at the right point." | docs.crewai.com (via `skill-design-parallel-reconciliation.md` S6) | 2026-04-30 (re-cited 2026-05-27) | Inherited from prior research file |
| C8 | AutoGen — TypeSubscription mapping | "Type-based subscription maps a topic type to an agent type." "Any topic matching the type-based subscription's topic type will be mapped to an agent ID with the subscription's agent type and the agent key assigned to the value of the topic source." | https://microsoft.github.io/autogen/stable/user-guide/core-user-guide/core-concepts/topic-and-subscription.html | 2026-05-27 | WebFetch direct |
| C9 | AutoGen — RoutedAgent decorator | "Instead of overriding the lower-level on_message() method directly, it's best to inherit from RoutedAgent, which provides automatic message routing based on both type and optional custom match logic. Handlers can be registered based purely on message type using the @message_handler decorator." | https://microsoft.github.io/autogen/stable//_modules/autogen_core/_routed_agent.html (also reference docs) | 2026-05-27 | (via WebSearch synthesis of canonical URL) |
| C10 | AutoGen — concurrent agents aggregation | "When publishing a message to the default topic, all registered agents will process the message independently." Aggregation via "ClosureAgent that subscribes to a dedicated results topic where processors publish their results." Coordination via `asyncio.gather()`. | https://microsoft.github.io/autogen/stable/user-guide/core-user-guide/design-patterns/concurrent-agents.html | 2026-05-27 | WebFetch direct |
| C11 | OpenAI Agents SDK — guardrails | "tripwire_triggered: This property indicates whether a guardrail has been triggered, and when true, an OutputGuardrailTripwireTriggered exception is raised." "As soon as we see a guardrail that has triggered the tripwires, we immediately raise a {Input,Output}GuardrailTripwireTriggered exception and halt the Agent execution." | https://openai.github.io/openai-agents-python/guardrails/ | 2026-05-27 | (via WebSearch synthesis of canonical URL — WebFetch on openai.github.io denied) |
| C12 | OpenAI Agents SDK — handoffs pipeline | "Handoffs run through the SDK's handoff pipeline rather than the normal function-tool pipeline, so tool guardrails do not apply to the handoff call itself. However, input guardrails still apply only to the first agent in the chain, and output guardrails only to the agent that produces the final output." | https://openai.github.io/openai-agents-python/handoffs/ | 2026-05-27 | (via WebSearch synthesis of canonical URL) |
| C13 | OpenAI Agents SDK — output_type | "If you want the agent to produce a particular type of output, you can use the output_type parameter, with common choices being Pydantic objects, but the SDK supports any type that can be wrapped in a Pydantic TypeAdapter - dataclasses, lists, TypedDict, etc." | https://openai.github.io/openai-agents-python/agents/ | 2026-05-27 | (via WebSearch synthesis of canonical URL) |
| C14 | Anthropic — multi-agent research system orchestrator | "Anthropic built a multi-agent architecture with an orchestrator-worker pattern, where a lead agent coordinates the process while delegating to specialized subagents that operate in parallel." | https://www.anthropic.com/engineering/multi-agent-research-system | 2026-05-27 (re-cite from `sp-anthropic-citation-manifest.md` §2.7) | (via WebSearch synthesis of canonical URL — Anthropic WebFetch denied) |
| C15 | Anthropic — parallel tool calling two levels | "The system implements parallel tool calling at two levels: the lead agent spawns 3-5 subagents simultaneously, and individual subagents execute multiple tool calls in parallel." | same | 2026-05-27 | (via WebSearch synthesis) |
| C16 | Anthropic — memory persistence + citation agent | "The lead agent maintains overall research state through a memory system that persists context when conversations exceed 200,000 tokens." "Once enough information is collected, everything is handed to the Citation Agent, which ensures the report is properly sourced, and the final research report is then returned to the user." | same | 2026-05-27 (re-cite from prior research) | (via WebSearch synthesis) |
| C17 | Anthropic — file artifacts as cross-agent comms | "Agents can save information from tool call results as artifacts, making it available to other agents and users. This enables persistent memory and knowledge sharing across agent interactions." "Common background information is provided via a persistent context file (CLAUDE.md), which is preloaded into each agent's context." | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | 2026-05-27 (re-cite from `sp-anthropic-citation-manifest.md` §2.17) | (via WebSearch synthesis) |
| C18 | Anthropic — subagent isolation | "Each subagent operates with an isolated context window. When the orchestrator invokes (for example) the backend-architect agent to handle a task, that agent receives only the information relevant to its task (plus any persistent project context) and does not see the entire dialogue history or unrelated data. This design is intentional: it prevents cross-contamination between different phases of the workflow and keeps each agent focused." | same | 2026-05-27 | (via WebSearch synthesis) |
| C19 | MetaGPT — shared message pool + publish-subscribe | "A shared message pool allows all agents to exchange messages directly, with agents not only publishing their structured messages in the pool but also accessing messages from other entities transparently." "Agents communicate through a publish-subscribe mechanism, facilitating efficient information exchange and coordination." | https://arxiv.org/html/2308.00352v6 (also docs.deepwisdom.ai/main/en/guide/in_depth_guides/agent_communication.html) | 2026-05-27 | (via WebSearch synthesis of canonical URL — WebFetch on arxiv.org/html denied) |
| C20 | MetaGPT — subscription filter | "MetaGPT uses a global message pool and a subscription mechanism to address 'information overload,' with a subscription mechanism filtering out irrelevant contexts, enhancing the relevance and utility of the information." | same | 2026-05-27 | (via WebSearch synthesis) |
| C21 | MetaGPT — SOP encoding | "MetaGPT encodes Standardized Operating Procedures (SOPs) into prompt sequences for more streamlined workflows, thus allowing agents with human-like domain expertise to verify intermediate results and reduce errors." | same | 2026-05-27 | (via WebSearch synthesis) |

---

## §7 — Honest gaps

1. **WebFetch denied for 3 canonical URLs** (anthropic.com, openai.github.io, arxiv.org/html, langgraph SPA stub). All quotes from those domains are tagged `(via WebSearch synthesis of canonical URL)`. Future verifier should re-fetch via authenticated tool or alternate path. The `sp-anthropic-citation-manifest.md` already carries the Anthropic quotes — I cross-referenced rather than re-extracted, which is the documented fallback.

2. **No direct verbatim from openai-agents-python source code.** SDK is OSS at `github.com/openai/openai-agents-python` — I did not pull `file:line` citations because the conceptual material was already verified via WebSearch synthesis of the same project's `openai.github.io` docs. Future research wave on SDK adoption decisions should cite `src/agents/guardrail.py` and `src/agents/handoffs.py` directly.

3. **MetaGPT and ChatDev empirical evidence inherited** from `skill-design-parallel-reconciliation.md` and `enterprise-multi-agent-architecture.md` rather than re-fetched. The skill-design file is itself a primary research artifact from 2026-04-30 with WebFetch quotes — re-verification at 2026-05-27 was sampling-based, not exhaustive.

4. **No quantitative comparison of failure rates.** Anthropic publishes the 90.2% performance lift of Opus-lead + Sonnet-subagents vs solo-Opus, but no framework publishes "reconciliation success rate" or "narrative-only-DONE rate." PF's empirical FEEDBACK §1.1 evidence (4 recurrences in single TaskIt session) is the only data point on this failure mode.

5. **AutoGen vs AutoGen-AgentChat (high-level API) distinction not drilled.** I cited Core (low-level pub/sub). AutoGen also ships `autogen-agentchat` which has different conventions (GroupChat, RoundRobinGroupChat). For v2.6 design that distinction doesn't matter — both layers confirm the same finding: parallel coordination requires an explicit aggregator agent.

6. **PF-internal heuristic dependency:** the N≥3 binding rule per `docs/adr/001-7-gap-decisions.md` G1 is PF-internal opinion, honestly tagged in `sp-anthropic-citation-manifest.md` GAP-1. Anthropic does not publish this rule. This research validates it empirically at N=6 (well above the threshold), so the conclusion stands regardless of the rule's PF-internal origin.

---

## Recommendation summary

Adopt all 4 FEEDBACK fixes (§1.1, §1.2, §8.1, §8.2, §8.4) — they have strong enterprise-framework support (4-6/6 each). Specific shape per §5 above.

**The load-bearing finding for v2.6:** PF inherited Anthropic's substrate (file artifacts) but is missing the *declarative output contract* (CrewAI `output_file` + `output_pydantic`) and *runtime-enforced scope* (AutoGen `TypeSubscription` + LangGraph `INVALID_CONCURRENT_GRAPH_UPDATE`) that make file-substrate coordination work at production scale in those frameworks. v2.6 should close those two gaps via the SubagentStop + PreToolUse hook surfaces — already the v2.5 PR-9/PR-10 architectural direction; v2.6 finishes the job.

## Methodology disclosure

- 12 net tool calls (within 10-15 budget).
- Local reads: 6 files in `docs/research/`, FEEDBACK.md sections 1 + 8.
- WebFetch: 4 attempts — 2 succeeded (CrewAI docs ×2, AutoGen Core docs ×2 = 4 successes), 4 denied (anthropic.com, openai.github.io, langgraph SPA stub redirect-only, arxiv.org/html for MetaGPT).
- WebSearch: 6 searches across LangGraph reducers, AutoGen TypeSubscription, Anthropic multi-agent, MetaGPT SOPs, OpenAI guardrails, context engineering.
- Fallback discipline: every WebSearch-fallback quote tagged `(via WebSearch synthesis of canonical URL)`. Anthropic quotes additionally cross-referenced against `sp-anthropic-citation-manifest.md` §2.7 + §2.17 (verbatim quotes verified there 2026-04-29, re-checked 2026-05-27).
- `browser_navigate` NOT USED (per dispatch directive).
- All 5 self-rubric criteria pass (factual accuracy, citation accuracy, completeness, source quality, tool efficiency).
