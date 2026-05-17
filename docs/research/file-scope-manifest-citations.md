# File-Scope Manifest Citations — production-framework v2.5.0 PR-9

**Date:** 2026-05-17
**Pattern:** Agent dispatch declares `scope_write[]` + `scope_read[]` arrays at the agent prompt / dispatch contract level.
**Purpose:** Enable a pre-dispatch hook to detect file-scope intersection between a new agent's required-read list and any in-flight agent's write list, blocking the dispatch until producer completes. Closes FEEDBACK F-4 (transient inconsistency when producer-edit and consumer-read overlap on shared substrate docs).

## Context

The project's `CLAUDE.md` binding rule requires every framework feature to cite either a Superpowers (SP) precedent OR an Anthropic citation. The `enterprise-research-first` rule additionally requires N≥3 enterprise/OSS citations. This document gathers both: one BINDING Anthropic source for the principle (isolated context windows + file artifacts as cross-agent communication substrate) and three enterprise sources for the implementation analogs (CrewAI = literal filesystem substrate, LangGraph = structural typed-state declaration, AutoGen = principle-level topic routing).

Research methodology disclosure: Anthropic source inherited from local manifest `sp-anthropic-citation-manifest.md` §2.17 (anthropic.com on Claude Code's built-in WebFetch blocklist; 2 prior subagent dispatches verified). Enterprise sources WebFetched directly. CrewAI is the strongest literal fit; LangGraph and AutoGen validate the declared-dependency principle across different substrates (graph-state vs filesystem; topic-bus vs filesystem).

---

## Citation 1 — Anthropic *Effective context engineering for AI agents* (BINDING)

- **URL:** https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- **Pattern bound:** Isolated subagent context windows + file artifacts as the cross-agent communication substrate
- **Verbatim passages:**

> "Each subagent operates with an isolated context window. When the orchestrator invokes (for example) the backend-architect agent to handle a task, that agent receives only the information relevant to its task (plus any persistent project context) and does not see the entire dialogue history or unrelated data. This design is intentional: it prevents cross-contamination between different phases of the workflow and keeps each agent focused."

> "The most powerful pattern for large tasks involves each subagent getting its own context window with its own tool permissions. The main conversation stays clean while specialized agents handle isolated tasks with exactly the context they need."

> "Agents can save information from tool call results as artifacts, making it available to other agents and users. This enables persistent memory and knowledge sharing across agent interactions."

> "Common background information is provided via a persistent context file (CLAUDE.md), which is preloaded into each agent's context."

> "Good context engineering means finding the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."

- **Semantic fit:** PRINCIPLE — validates the isolation principle + file-artifact-as-substrate at the orchestration level. The framework's `scope_write[]`/`scope_read[]` arrays are a runtime expression of "smallest possible set of high-signal tokens" applied at dispatch time.
- **Binding strength:** BINDING
- **last_verified:** 2026-04-29 (inherited from local manifest; anthropic.com on Claude Code's built-in WebFetch blocklist — `skipWebFetchPreflight` setting would bypass but not enabled this round; within the project's 90-day staleness threshold per `researcher-citation-freshness` gate)
- **verification_method:** Local manifest read (`sp-anthropic-citation-manifest.md` §2.17, lines 222-236)

---

## Citation 2 — CrewAI *Task.context + Task.output_file* (LITERAL fit, STRONG)

- **URL:** https://docs.crewai.com/en/concepts/tasks
- **Pattern bound:** Task declares its input dependencies (`context=[other_tasks]`) and its output file artifact (`output_file="path"`) at task-definition time — the orchestrator can statically detect producer/consumer relationships without runtime inference.
- **Verbatim passages:**

> "**Context** *(optional)* | `context` | `Optional[List[\"Task\"]]` | Other tasks whose outputs will be used as context for this task."

> "**Output File** *(optional)* | `output_file` | `Optional[str]` | File path for storing the task output."

> "Tasks can depend on the output of other tasks using the `context` attribute."

Code example combining both:

```python
write_blog_task = Task(
    description="Write a full blog post about the importance of AI and its latest news",
    expected_output="Full blog post that is 4 paragraphs long",
    agent=writer_agent,
    context=[research_ai_task, research_ops_task]
)
```

```yaml
reporting_task:
  agent: reporting_analyst
  markdown: true
  output_file: report.md
```

- **Semantic fit:** LITERAL — filesystem substrate (`output_file` is a path), declarative producer/consumer at definition time (`context` lists tasks whose outputs this task reads). This is a near-1:1 analog of the v2.5.0 `scope_write[]`/`scope_read[]` contract — the only difference is that CrewAI binds at task-graph definition time while PF v2.5.0 binds at dispatch time (the hook reads the declaration just before dispatch).
- **Binding strength:** STRONG
- **last_verified:** 2026-05-17
- **verification_method:** WebFetch

---

## Citation 3 — LangGraph *StateGraph + TypedDict state schema* (STRUCTURAL fit, WEAK)

- **URL:** https://raw.githubusercontent.com/langchain-ai/langgraph/main/libs/langgraph/README.md
- **Pattern bound:** Each node in a `StateGraph` operates on a typed `State` TypedDict; the schema declares which keys nodes read/write. Channel reducers (`Annotated[type, reducer]`) declare merge semantics for concurrent writes.
- **Verbatim passages:**

> ```python
> class State(TypedDict):
>     text: str
> ```

> ```python
> graph = StateGraph(State)
> ```

- **Semantic fit:** STRUCTURAL — declares producer/consumer dependencies via typed state schema rather than filesystem paths. Different substrate (in-graph channels, not file artifacts) but the same declared-dependency principle: every node knows in advance which state slots it will read/write.
- **Binding strength:** WEAK — the README is intentionally a high-level intro; the canonical concepts/low_level page is rendered as a JS SPA and unreachable via WebFetch. The TypedDict + StateGraph pattern is documented; the per-node read/write scoping is implied but not explicitly captured in the README passages above.
- **last_verified:** 2026-05-17
- **verification_method:** WebFetch (raw GitHub markdown — `langchain-ai.github.io` SPA stub blocked direct fetch)
- **Honest gap-flag:** This citation is the weakest of the four. The structural pattern (TypedDict-based state contract per node) is real and load-bearing in LangGraph's API, but the verbatim passages from the README don't explicitly show node-level scope declaration. A reader following the citation would need to navigate to LangGraph's `concepts/low_level` reference to see the full `Annotated[type, reducer]` channel-reducer API. For PR-9 commit-body purposes, this satisfies the N≥3 enterprise rule at the principle level — but the load-bearing literal-fit citation is CrewAI, not this.

---

## Citation 4 — AutoGen *RoutedAgent + type_subscription* (PRINCIPLE fit, WEAK)

- **URL:** https://microsoft.github.io/autogen/stable/user-guide/core-user-guide/framework/message-and-communication.html
- **Pattern bound:** Agents subclass `RoutedAgent` and use the `@message_handler` decorator to declare which message types they handle; the `@type_subscription` class decorator declares which topic types the agent subscribes to. The runtime routes messages based on these declarations.
- **Verbatim passages:**

> "The `RoutedAgent` base class provides a mechanism for associating message types with message handlers with the `message_handler()` decorator"

> "To make an agent that subclasses `RoutedAgent` subscribe to a topic of a given topic type, you can use the `type_subscription()` class decorator."

Code example:

```python
@type_subscription(topic_type="default")
class ReceivingAgent(RoutedAgent):
    @message_handler
    async def on_my_message(self, message: Message, ctx: MessageContext) -> None:
        print(f"Received a message: {message.content}")
```

> "Subscriptions are registered with the agent runtime, either as part of agent type's registration or through a separate API method" — e.g., `TypeSubscription(topic_type="default", agent_type="broadcasting_agent")`

- **Semantic fit:** PRINCIPLE — declarative scoping of what each agent participates in. Substrate is an in-memory message bus routed by topic type, NOT filesystem artifacts. The declared-dependency principle holds (agent declares its read scope as "messages of topic X"), but the substrate is fundamentally different from v2.5.0's filesystem-substrate pattern.
- **Binding strength:** WEAK
- **last_verified:** 2026-05-17
- **verification_method:** WebFetch
- **Honest gap-flag:** AutoGen's topic-routing is principle-analog only. The contribution to N≥3 enterprise rule is real but the literal pattern fit is least-strong of the three enterprise citations. Documenting this honestly per the project's anti-fabrication rule.

---

## Semantic-fit summary

| Citation | Semantic fit | Binding strength | Substrate |
|---|---|---|---|
| Anthropic §2.17 | PRINCIPLE | **BINDING** | Filesystem (CLAUDE.md, file artifacts) |
| CrewAI | **LITERAL** | STRONG | Filesystem (`output_file`) |
| LangGraph | STRUCTURAL | WEAK | In-graph typed state (TypedDict + channels) |
| AutoGen | PRINCIPLE | WEAK | In-memory message bus (topic types) |

## Coverage verdict

- **CLAUDE.md binding rule** (Anthropic OR SP precedent): ✅ **Satisfied** by Anthropic §2.17.
- **enterprise-research-first N≥3 rule:** ✅ **Satisfied** by CrewAI + LangGraph + AutoGen.
- **Honest framing for PR-9 commit body:** "PF v2.5.0 PR-9 elevates Anthropic's file-artifact pattern + CrewAI's `Task.context`/`Task.output_file` API to a runtime pre-dispatch gate (`scope_write[]`/`scope_read[]`). LangGraph's TypedDict-based state contract (STRUCTURAL) and AutoGen's `TypeSubscription` declaration (PRINCIPLE) validate the declared-dependency idea across non-filesystem substrates. CrewAI is the load-bearing literal-fit enterprise citation; LangGraph and AutoGen carry the principle at the N≥3 rule level."

## Pattern-alignment concerns (forward to CTO)

1. **CrewAI is the load-bearing enterprise citation.** If a code-review challenges the LangGraph or AutoGen citations as too-loose-fit, the response is "CrewAI is the literal-fit citation; the other two satisfy the N≥3 enterprise rule at the principle level — same declared-dependency idea, different substrates."
2. **LangGraph capture is thin.** Future v2.5.x or v2.6.0 work that revisits this citation should re-fetch from the rendered `concepts/low_level` page (which requires either the SPA-rendering hack or Context7 MCP access — both denied this round).
3. **No SP precedent claimed.** The pattern is new to PF v2.5.0. The Anthropic citation satisfies the binding rule on its own; no SP fallback needed.
4. **Citation freshness:** Anthropic is 18 days old (within 90-day threshold). CrewAI/LangGraph/AutoGen are today.
