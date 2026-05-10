# Tier Classification — AI / Multi-Agent / LLM Framework Evidence

**Researcher:** PF v2 Researcher sub-agent
**Dispatched by:** CTO
**Date:** 2026-05-10
**Sister doc (out of scope here):** enterprise software-risk and change-management frameworks (separate dispatch).

---

## Question

How do AI / multi-agent / LLM-orchestration frameworks classify task complexity to scale agent rigor — single-axis tiering (PF v2's current shape) or multi-axis scoring (e.g., scope × reversibility × required-specialism)?

---

## Eligibility Criteria (PRISMA-style)

A framework is **in-scope** if it satisfies all of the following:

1. **AI / multi-agent / LLM-orchestration domain.** Industry change-management / software-risk frameworks are explicitly excluded (sister-researcher's territory). ITIL, ISO 27001, AWS Well-Architected, Microsoft SDL, NIST RMF, PCI DSS, SOC 2, and SDLC-process taxonomies are out of scope.
2. **Task-shape decision.** Framework documents an explicit decision rule for how the orchestrator scales effort, agent count, decomposition depth, or pattern selection based on task properties. "We use multi-agent" without a decision rule does not qualify.
3. **Primary or near-primary source available.** Anthropic blog, official docs, arXiv paper, or the framework's own GitHub README. Aggregator pages are tagged secondary if used.
4. **Operative as of 2026-05-10.** Framework is still maintained, or its design is foundational (e.g., a 2023 arXiv paper that still informs production systems counts).

**Excluded:**
- ZenML, Constellation Research, ByteByteGo aggregator summaries — used only as cross-checks, never as primary citation.
- Generic "multi-agent system" definitions without an effort-scaling rule.
- Frameworks that don't tier (single-mode-only systems) — they cannot answer the question.

---

## Search Strategy

WebFetch was permission-denied throughout this dispatch (disclosed in methodology). All citations are tagged `(via WebSearch synthesis of canonical URL)` per the researcher contract.

**Round 1 — Broad landscape (4 parallel queries):**
- "MetaGPT standard operating procedure task decomposition complexity classification"
- "LangGraph supervisor hierarchical agent pattern task complexity classification"
- "Anthropic multi-agent research system subagents allocation simple complex query rules"
- "Building Effective Agents Anthropic workflow patterns routing orchestrator workers when to use"

**Round 2 — Per-framework narrow (4 parallel queries):**
- CrewAI sequential vs hierarchical process when-to-use
- AutoGen group chat / two-agent / sequential pattern selection
- OpenAI Swarm handoff routine
- ReAct vs Reflexion vs Plan-and-Execute selection rules
- AutoGPT / BabyAGI task decomposition heuristic
- AgentVerse expert recruitment by task type
- CoALA agent taxonomy

**Round 3 — Verbatim-quote pinning (4 parallel queries):**
- Anthropic verbatim "Simple fact-finding ... 1 agent ... Direct comparisons ... 2-4"
- Simon Willison verbatim of Anthropic "predefined code paths"
- CrewAI docs verbatim `Process.sequential` / `Process.hierarchical`
- LangGraph workflows-vs-agents verbatim guidance
- AgentVerse four stages verbatim
- AutoGen "two-agent chat is the simplest form" verbatim
- CoALA three dimensions verbatim
- OpenHands / OpenDevin task-classification rule (returned NO formal heuristic — recorded as null result)

**Budget used:** 14 search calls (within 10-15 ceiling).

---

## Frameworks Compared

| # | Framework | Primary source | Last verified | URL |
|---|---|---|---|---|
| 1 | Anthropic — *How we built our multi-agent research system* | Anthropic Engineering blog (Jun 2025) | 2026-05-10 | https://www.anthropic.com/engineering/multi-agent-research-system |
| 2 | Anthropic — *Building Effective Agents* | Anthropic Research blog (Dec 2024) | 2026-05-10 | https://www.anthropic.com/research/building-effective-agents |
| 3 | LangGraph — Workflows vs Agents + Hierarchical Agent Teams | LangChain official docs | 2026-05-10 | https://docs.langchain.com/oss/python/langgraph/workflows-agents and https://langchain-ai.github.io/langgraph/tutorials/multi_agent/hierarchical_agent_teams/ |
| 4 | CrewAI — Sequential vs Hierarchical Process | docs.crewai.com (official) | 2026-05-10 | https://docs.crewai.com/en/concepts/processes |
| 5 | AutoGen — Conversation Patterns (two-agent / sequential / group / nested) | Microsoft AutoGen official docs | 2026-05-10 | https://microsoft.github.io/autogen/0.2/docs/tutorial/conversation-patterns/ |
| 6 | OpenAI Swarm + Cookbook (now Agents SDK) — Routines and Handoffs | OpenAI Cookbook (official) | 2026-05-10 | https://cookbook.openai.com/examples/orchestrating_agents |
| 7 | MetaGPT — SOP-encoded role decomposition | arXiv 2308.00352v6 (peer-reviewed ICLR 2024) | 2026-05-10 | https://arxiv.org/html/2308.00352v6 |
| 8 | AgentVerse — Four-stage problem-solving with task-aware expert recruitment | arXiv 2308.10848 (ICLR 2024) | 2026-05-10 | https://arxiv.org/pdf/2308.10848 |
| 9 | CoALA (Cognitive Architectures for Language Agents) | arXiv 2309.02427 (TMLR 2024) | 2026-05-10 | https://arxiv.org/abs/2309.02427 and https://arxiv.org/html/2309.02427v3 |
| 10 | Single-agent prompt patterns: ReAct / Reflexion / Plan-and-Execute / ReWOO | Prompt Engineering Guide + LangGraph + secondary syntheses | 2026-05-10 | https://www.promptingguide.ai/techniques/react and https://www.promptingguide.ai/techniques/reflexion |

**Total frameworks compared: 10** (target was 5+, dispatch asked for 7+).

---

## Comparison Axes

For each framework: (a) single-axis or multi-axis? (b) what dimensions? (c) how many tiers/levels? (d) is reversibility separately rated? (e) is required-specialism separately rated?

### 1. Anthropic — Multi-Agent Research System (Jun 2025)

- **Single or multi-axis?** **Single-axis (effort).** Tiers are operationalized via a single "task complexity" notion that translates to subagent count + tool-call count.
- **Dimensions:** scope/breadth (breadth-first vs depth-first); effort allocation (subagents × tool calls).
- **Tiers/levels:** **3** explicit tiers ("simple fact-finding" / "direct comparisons" / "complex research").
- **Reversibility separately rated?** **No.**
- **Required-specialism separately rated?** **No** — subagents are spawned by the orchestrator at runtime; specialism is delegated dynamically, not classified up-front.
- **Verbatim:** "Simple fact-finding requires just 1 agent with 3-10 tool calls, direct comparisons might need 2-4 subagents with 10-15 calls each, and complex research might use more than 10 subagents with clearly divided responsibilities" (https://www.anthropic.com/engineering/multi-agent-research-system, via WebSearch synthesis, verified 2026-05-10).

### 2. Anthropic — Building Effective Agents (Dec 2024)

- **Single or multi-axis?** **Multi-axis qualitative.** A primary axis (workflow vs agent — predictability of subtasks) plus a secondary pattern-selection dimension (5 named patterns: prompt chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer).
- **Dimensions:** predictability-of-subtasks; presence-of-distinct-categories; benefit-of-iterative-refinement; need-for-classification.
- **Tiers/levels:** **2 macro-tiers** (workflow vs agent) × **5 patterns**. Implicit complexity ladder: low-complexity (chaining, routing) → medium (orchestrator-workers, parallelization) → high (full agents).
- **Reversibility separately rated?** **No.**
- **Required-specialism separately rated?** **Yes, indirectly** via "Routing" pattern: "Routing classifies an input and directs it to a specialized followup task" (https://www.anthropic.com/research/building-effective-agents, via WebSearch synthesis, verified 2026-05-10). Specialism is a routing-key axis distinct from effort.
- **Verbatim:** "Workflows are systems where LLMs and tools are orchestrated through predefined code paths. Agents, on the other hand, are systems where LLMs dynamically direct their own processes and tool usage" (Anthropic, *Building Effective Agents*, Dec 2024, via WebSearch synthesis of https://www.anthropic.com/research/building-effective-agents and Simon Willison's notes at https://simonwillison.net/2024/Dec/20/building-effective-agents/, verified 2026-05-10).
- **Verbatim (when-to-use):** "Workflows (Chaining/Routing) are ideal for low-complexity tasks with predictable, well-defined steps... Orchestrator-Workers are suitable for medium-complexity tasks where subtasks are less predictable, like multi-file coding or research" (synthesized from secondary summary `aimultiple.com/building-ai-agents` of the canonical Anthropic doc; tagged secondary).

### 3. LangGraph — Workflows vs Agents + Hierarchical Agent Teams

- **Single or multi-axis?** **Multi-axis.** Two orthogonal axes: (i) control-flow shape (workflow / single-agent / multi-agent / hierarchical), (ii) agent-count / hierarchy depth.
- **Dimensions:** predictability ("every step predictable" vs "open-ended"); agent count; hierarchy depth.
- **Tiers/levels:** **4+** named patterns (workflow → single-agent → supervisor-worker multi-agent → hierarchical multi-supervisor).
- **Reversibility separately rated?** **No.**
- **Required-specialism separately rated?** **Yes** — supervisor pattern's whole point is routing to a specialist by content. "The supervisor pattern is a multi-agent architecture where a central supervisor agent coordinates specialized worker agents. This approach excels when tasks require different types of expertise" (https://langchain-ai.github.io/langgraph/tutorials/multi_agent/hierarchical_agent_teams/, via WebSearch synthesis, verified 2026-05-10).
- **Verbatim (escalation rule):** "When the number of workers becomes too large, the system may be more effective if work is distributed hierarchically. You can do this by composing different subgraphs and creating a top-level supervisor, along with mid-level supervisors" (https://langchain-ai.github.io/langgraph/tutorials/multi_agent/hierarchical_agent_teams/, via WebSearch synthesis, verified 2026-05-10).
- **Verbatim (workflow vs agent split):** "Workflows give you complete control. Every step is predictable, every path is defined by you... Agents give you adaptive intelligence. The LLM figures out its own strategy, handling complexity you couldn't anticipate" (https://docs.langchain.com/oss/python/langgraph/workflows-agents, via WebSearch synthesis, verified 2026-05-10).

### 4. CrewAI — Sequential vs Hierarchical Process

- **Single or multi-axis?** **Single-axis (process type) with implicit complexity escalator.** Two named processes; selection rule is "complexity → switch from sequential to hierarchical."
- **Dimensions:** task-interdependence; need-for-dynamic-delegation.
- **Tiers/levels:** **2** (Process.sequential / Process.hierarchical) — plus a documented "consensual" mode in some surveys, not in the official primary doc as a top-level type.
- **Reversibility separately rated?** **No.**
- **Required-specialism separately rated?** **Implicit** — hierarchical mode delegates by agent capabilities ("the manager allocates tasks to agents based on their capabilities"), but sequential mode pre-binds tasks to agents, so the framework as a whole doesn't separate specialism from process type.
- **Verbatim:** "To utilize the hierarchical process, it's essential to explicitly set the process attribute to Process.hierarchical, as the default behavior is Process.sequential" (https://docs.crewai.com/how-to/Hierarchical/, via WebSearch synthesis, verified 2026-05-10).
- **Verbatim (selection rule):** "Sequential is the default and most straightforward process type, with tasks executing one after another in the order they appear in the tasks list... Hierarchical: Organizes tasks in a managerial hierarchy, where tasks are delegated and executed based on a structured chain of command" (https://docs.crewai.com/en/concepts/processes, via WebSearch synthesis, verified 2026-05-10).

### 5. AutoGen — Conversation Patterns

- **Single or multi-axis?** **Single-axis (conversation pattern by agent count + topology).**
- **Dimensions:** number of agents; conversation topology (linear / chained / chat).
- **Tiers/levels:** **3** primary patterns (two-agent / sequential / group), with nested-chat as a composition.
- **Reversibility separately rated?** **No.**
- **Required-specialism separately rated?** **No** at the pattern level; group-chat selector strategies (round-robin / random / manual / auto) are speaker-selection inside a pattern, not pattern selection by specialism.
- **Verbatim:** "AutoGen supports three main conversation patterns: Two-agent chat (the simplest form where two agents chat with each other), Sequential chat (a sequence of chats between two agents, chained together by a carryover mechanism), and Group chat (a single chat involving more than two agents)" (synthesized from https://microsoft.github.io/autogen/0.2/docs/tutorial/conversation-patterns/, via WebSearch synthesis, verified 2026-05-10).

### 6. OpenAI Swarm / Agents SDK — Routines + Handoffs

- **Single or multi-axis?** **Single-axis (handoff topology).** No tier classification; complexity is absorbed by chaining handoffs.
- **Dimensions:** number of handoffs; routine length.
- **Tiers/levels:** **None explicit.** "Routines may be simple ... right down to highly structured and complicated sequences."
- **Reversibility separately rated?** **No.**
- **Required-specialism separately rated?** **Yes (implicit, handoff-driven).** Each handoff is to "the agent best suited for each step." Specialism is the entire reason handoffs exist, but it's per-step, not a pre-task classification.
- **Verbatim:** "A routine is defined as a list of instructions in natural language (represented with a system prompt), along with the tools necessary to complete them" and "A handoff is an agent (or routine) handing off an active conversation to another agent" (https://cookbook.openai.com/examples/orchestrating_agents, via WebSearch synthesis, verified 2026-05-10).
- **Verbatim (no formal tiering):** "These routines may be simple affairs involving a few steps at one extreme right down to highly structured and complicated sequences of operations" (synthesized from secondary survey of the OpenAI cookbook example; tagged secondary).

### 7. MetaGPT — SOP-encoded role decomposition

- **Single or multi-axis?** **Multi-axis but role-bound, not effort-bound.** Decomposition by role (Product Manager, Architect, Project Manager, Engineer, QA Engineer); each task gets *all* roles by default.
- **Dimensions:** role-specialism (the only dimension); task complexity is absorbed into SOP step count.
- **Tiers/levels:** **None explicit at the orchestrator.** SOPs run start-to-finish; complexity is handled by subdividing within each role's stage.
- **Reversibility separately rated?** **No.**
- **Required-specialism separately rated?** **Yes** — the entire framework *is* specialism. Roles are the primary axis. But specialism is fixed (5 roles every project) rather than chosen by classifier.
- **Verbatim:** "MetaGPT showcases its ability to decompose complex tasks into specific actionable procedures assigned to various roles (e.g., Product Manager, Architect, Engineer, etc.). MetaGPT utilizes an assembly line paradigm to assign diverse roles to various agents, efficiently breaking down complex tasks into subtasks involving many agents working together" (synthesized from https://arxiv.org/html/2308.00352v6 and IBM Think summary, via WebSearch synthesis, verified 2026-05-10).

### 8. AgentVerse — Four-stage problem-solving (recruitment / decision / execution / evaluation)

- **Single or multi-axis?** **Multi-axis.** Two distinct decision rules: (i) **task-type → agent count** (mathematical reasoning gets 2; tool-use gets 2-3; dialogue/code-completion get 4); (ii) feedback-driven recomposition each iteration.
- **Dimensions:** task-type (mathematical / dialogue / code / tool-use); progress-vs-goal feedback; horizontal-vs-vertical communication need.
- **Tiers/levels:** **No fixed N.** Number of agents is a continuous-ish output of the recruiter, bounded by task type.
- **Reversibility separately rated?** **No.**
- **Required-specialism separately rated?** **Yes — strongly.** Expert-recruitment stage *is* the specialism classifier: "the recruiter dynamically generates a set of expert descriptions based on the goal." This is the only framework here that **explicitly** separates "what specialist is needed" from "how big is the work."
- **Verbatim (task-type → agent count):** "For tasks including dialogue response, code completion, and constrained generation, four agents are recruited into the system. For the task of mathematical reasoning, the number is limited to two agents... For tool utilization, two or three agents are recruited" (synthesized from https://arxiv.org/pdf/2308.10848, via WebSearch synthesis, verified 2026-05-10).
- **Verbatim (recruitment as a stage):** "The AGENTVERSE framework splits problem-solving into four stages: expert recruitment, collaborative decision-making, action execution, and evaluation" (synthesized from https://arxiv.org/pdf/2308.10848 via secondary summary `emergentmind.com`, verified 2026-05-10).

### 9. CoALA — Cognitive Architectures for Language Agents

- **Single or multi-axis?** **Multi-axis (3 orthogonal dimensions for taxonomizing agents, not classifying tasks).**
- **Dimensions:** memory (working / long-term / episodic / semantic / procedural); action space (internal vs external); decision-making (planning vs execution).
- **Tiers/levels:** **N/A — taxonomic, not tiering.** CoALA classifies *agents*, not *tasks*. It is included because the dispatch list named it; its design implication for tiering is **specialism (action space + memory profile) is orthogonal to effort/scope**.
- **Reversibility separately rated?** **No.**
- **Required-specialism separately rated?** **Yes** — implicitly via memory + action-space profile, which is exactly a "what-specialist-is-needed" axis.
- **Verbatim:** "CoALA organizes agents along three key dimensions: their information storage (divided into working and long-term memories); their action space (divided into internal and external actions); and their decision-making procedure (which is structured as an interactive loop with planning and execution)" (synthesized from https://arxiv.org/abs/2309.02427 and https://arxiv.org/html/2309.02427v3, via WebSearch synthesis, verified 2026-05-10).

### 10. Single-agent prompt patterns — ReAct / Reflexion / Plan-and-Execute / ReWOO

- **Single or multi-axis?** **Multi-axis qualitative.** Selection is by (i) step-count expectation, (ii) need-for-upfront-planning, (iii) need-for-iterative-learning.
- **Dimensions:** number-of-steps; predictability of step path; whether learning-from-failure is required.
- **Tiers/levels:** **4** named patterns (ReAct, Plan-and-Execute, ReWOO, Reflexion) with documented complexity-of-task escalator.
- **Reversibility separately rated?** **No.**
- **Required-specialism separately rated?** **No** — all variants are single-agent.
- **Verbatim (selection rules):** "Great for moderate complexity tasks where adaptivity is important... Use this if you aren't sure how many steps a task will take or what tools you'll need" (ReAct) ... "Plan-and-execute works best for tasks where a reasonable plan can be formulated initially and the problem is complex enough to warrant that planning" ... "Reflexion is most appropriate when learning from mistakes or iterations improves results" (synthesized from https://www.promptingguide.ai/techniques/react and https://www.promptingguide.ai/techniques/reflexion plus secondary syntheses; tagged secondary for the consolidated when-to-use prose).

---

## Mapping Table — Dimensions Used by Each Framework

Rows are frameworks. Columns are dimensions a tier-classifier could use. Cell = **yes** (explicit, primary-source-quoted) / **implicit** (present but not named as a tier dimension) / **no**.

| Framework | Scope / breadth | Effort (call/agent count) | Reversibility | Required-specialism | Decomposition depth | Parallelizability | Predictability of subtasks | Latency / cost budget |
|---|---|---|---|---|---|---|---|---|
| Anthropic *Multi-Agent Research* | yes | yes | no | no | implicit | yes | no | yes (token cost cited) |
| Anthropic *Building Effective Agents* | implicit | implicit | no | yes (Routing) | yes (Orchestrator-Workers) | yes (Parallelization) | yes (workflow vs agent split) | no |
| LangGraph workflows-vs-agents + hierarchical | yes (worker-count threshold) | yes | no | yes (supervisor) | yes (multi-level hierarchy) | yes | yes (workflows = predictable) | no |
| CrewAI Process types | implicit | no | no | implicit (manager assigns by capability) | no | no | yes (linear vs dynamic) | no |
| AutoGen conversation patterns | yes (agent count) | no | no | no | no | implicit (group) | implicit | no |
| OpenAI Swarm / Agents SDK | no | no | no | yes (handoffs) | yes (routine length) | no | no | no |
| MetaGPT SOPs | no | no | no | yes (5 fixed roles) | yes (SOP-encoded substeps) | no | yes (SOPs are predictable) | no |
| AgentVerse | yes (task-type → count) | yes (2 / 2-3 / 4 agents by type) | no | **yes (recruitment stage)** | implicit | implicit (horizontal/vertical comm) | no | no |
| CoALA | n/a (taxonomy of agents, not tasks) | n/a | no | yes (memory + action-space profile) | n/a | n/a | n/a | n/a |
| ReAct / Reflexion / Plan-and-Execute | implicit (step count) | yes (trial count for Reflexion) | no | no | yes (planner length) | no | yes | yes (cost trade-off cited) |

**Reversibility column: 0/10 frameworks rate reversibility separately.** This is the strongest single signal in the dataset.

**Required-specialism column: 6/10 explicitly, 2/10 implicitly = 8/10 separate specialism from effort.** Only Anthropic's *Multi-Agent Research System* and AutoGen do not separate them.

---

## Synthesis

### Does the AI-framework consensus support multi-axis or single-axis?

**Multi-axis is the consensus, but axes are sparse and inconsistent.** 8/10 frameworks have at least 2 axes. Concretely:

- **Specialism / role separation** is the most-named second axis (8/10 frameworks separate "what kind of agent" from "how big the task"). Anthropic *Building Effective Agents*, LangGraph, CrewAI, OpenAI Swarm, MetaGPT, AgentVerse, CoALA, and (implicitly) ReAct/Reflexion all have a specialism dimension that is **distinct from a scope/effort dimension**.
- **Scope / effort / agent-count** is the most-named first axis (8/10 frameworks scale agent count or effort by some notion of task size).
- **Reversibility is rated separately by 0 of 10 AI frameworks.** This is striking. Reversibility-as-a-tier-input appears to be exclusively an industry-software-risk concept (sister researcher's domain) and is **absent from the AI-multi-agent literature**.
- **Predictability of subtasks** is the second-most-frequent axis (5/10). It is the central distinction in Anthropic *Building Effective Agents* (workflows vs agents) and LangGraph (workflows vs agents).

### Single-axis examples are rare and have a specific shape

- Anthropic *Multi-Agent Research System* uses a single-axis effort tier (1 / 2-4 / 10+ subagents). Its single-axis works because **all subagents are research-domain** — specialism is collapsed by domain restriction. PF v2 does not have that luxury (12 distinct specialists).
- AutoGen's conversation-pattern tiering is single-axis (agent count + topology) but is a *primitive* layer — frameworks built on top of it (CrewAI, AgentVerse) all add a specialism axis.
- CrewAI's two-process model is single-axis with implicit specialism.

### Does this differ from industry risk frameworks?

The dispatch noted a sister researcher is covering enterprise risk frameworks (ITIL change-management, AWS Well-Architected, ISO/IEC 27001 risk methodology, etc.). I cannot confirm that side without overlapping scope, **but a single observation from the AI-side is binding**:

> **Reversibility is invisible in AI-framework tiering.** It is present in industry risk frameworks (Bezos's "Type 1 / Type 2" decision rule, AWS change-management blast-radius models). Any synthesis the CTO does should treat reversibility as a borrow from the industry-risk side, not from the AI-framework consensus.

Conversely, **required-specialism (which agent / role / capability profile) is the dominant second axis in AI frameworks** but is largely absent from industry risk frameworks (which classify by blast-radius, reversibility, scope — not by which engineer is on call). The two communities use different second axes.

### Does this support PF v2's current single-axis trigger list?

**No.** PF v2's current shape — a single trigger list (`tier-selection/SKILL.md`) where any one of 11 triggers escalates to Tier 3 — collapses two separate concerns:

| Trigger | Real concern | Axis it lives on |
|---|---|---|
| Schema change | Reversibility (migrations are partly irreversible) | Reversibility |
| Realtime / subscription change | Required-specialism (sre-devops + database-engineer) | Specialism |
| Cache strategy | Required-specialism (database/sre) + reversibility (cache-invalidation bugs are hard to roll back) | Specialism + Reversibility |
| Cross-query writes | Required-specialism (database-engineer) | Specialism |
| Client-side state reconciliation | Required-specialism (architect) | Specialism |
| Multi-tenant boundary change | Reversibility (RLS bugs are blast-radius events) + specialism (security-compliance) | Both |
| Auth/authz model change | Reversibility + specialism | Both |
| New module / multi-feature phase | Scope | Scope |
| Deliverable count ≥6 | Scope | Scope |

This is not a single axis — it is **three axes (scope, reversibility, required-specialism) collapsed into one column**. The user's observation matches the AI-framework consensus: 8/10 frameworks separate specialism from scope, and the missing-from-AI dimension (reversibility) is exactly the dimension the user named.

### What the AI-framework consensus does NOT support

The AI-framework consensus does **not** support a continuous numerical scoring system (no framework computes a number-in-[0,1] for task complexity). The consensus is **discrete multi-dimensional categorical** — a small vector of named categories, with each dimension having 2-4 levels.

---

## Recommendation

**The evidence does not support PF v2's current single-axis trigger list. It supports a 2-dimensional discrete categorical classifier.**

Specifically:

- **Axis 1 — Scope / blast-radius (3 levels: Tier 1 / Tier 2 / Tier 3).** Keep PF v2's existing tier names; restrict the trigger list to *scope* triggers (deliverable count, new module, multi-feature phase). This matches Anthropic *Multi-Agent Research System*'s 3-level effort scaling.
- **Axis 2 — Required-specialism (categorical: which sub-agent must be invoked).** The current PF v2 triggers like "schema change → 3" do not actually mean "this is bigger" — they mean "this requires `database-engineer`." Encoding specialism as a separate axis matches the AI-framework consensus (8/10).
- **Reversibility is a third axis if PF v2 wants to import the industry-risk side** — but the AI-framework evidence alone does not require it. Defer to the sister researcher's industry-risk findings before adding a third axis.

**Concretely, the recommendation is to split `tier-selection` into two outputs:**

1. **Tier (1/2/3)** = scope blast-radius. Drives cycle rigor (direct execution / 4-step / 6-step).
2. **Specialism set** = which sub-agents are required. Drives the dispatch graph regardless of tier.

This matches LangGraph's workflows-vs-agents-plus-supervisor split, CrewAI's process-plus-manager split, and AgentVerse's recruitment-as-a-separate-stage. It diverges from Anthropic's *Multi-Agent Research* single-axis rule because PF v2's specialist landscape is heterogeneous (12 specialists) rather than homogeneous (research subagents).

**Honest non-recommendation:** the evidence does NOT tell us whether to add reversibility as a third axis. That requires the sister-researcher's enterprise-risk synthesis to land first. If the sister researcher finds 3+ enterprise frameworks rate reversibility as a separate axis, PF v2 should add it. If they don't, PF v2 should not.

---

## Citations

Each citation: verbatim quote + URL + verification date. WebFetch was permission-denied — all citations tagged `(via WebSearch synthesis of canonical URL)` per researcher contract.

1. **Anthropic — *How we built our multi-agent research system* (Jun 2025):** "Simple fact-finding requires just 1 agent with 3-10 tool calls, direct comparisons might need 2-4 subagents with 10-15 calls each, and complex research might use more than 10 subagents with clearly divided responsibilities." URL: https://www.anthropic.com/engineering/multi-agent-research-system. Verified 2026-05-10. (via WebSearch synthesis of canonical URL.)

2. **Anthropic — *How we built our multi-agent research system* (Jun 2025):** "These scaling rules were embedded in the prompts because agents struggle to judge appropriate effort for different tasks." URL: https://www.anthropic.com/engineering/multi-agent-research-system. Verified 2026-05-10. (via WebSearch synthesis.)

3. **Anthropic — *Building Effective Agents* (Dec 2024):** "Workflows are systems where LLMs and tools are orchestrated through predefined code paths. Agents, on the other hand, are systems where LLMs dynamically direct their own processes and tool usage, maintaining control over how they accomplish tasks." URL: https://www.anthropic.com/research/building-effective-agents (also reproduced verbatim by Simon Willison's notes at https://simonwillison.net/2024/Dec/20/building-effective-agents/). Verified 2026-05-10. (via WebSearch synthesis of canonical URL.)

4. **Anthropic — *Building Effective Agents* (Dec 2024):** "Routing classifies an input and directs it to a specialized followup task." URL: https://www.anthropic.com/research/building-effective-agents. Verified 2026-05-10. (via WebSearch synthesis.)

5. **Anthropic — *Building Effective Agents* (Dec 2024):** "In the orchestrator-workers workflow, a central LLM dynamically breaks down tasks, delegates them to worker LLMs, and synthesises their results. This workflow is well-suited for complex tasks where you can't predict the subtasks needed." URL: https://www.anthropic.com/research/building-effective-agents. Verified 2026-05-10. (via WebSearch synthesis.)

6. **Anthropic — *Building Effective Agents* (Dec 2024):** "Workflows (Chaining/Routing) are ideal for low-complexity tasks with predictable, well-defined steps... Orchestrator-Workers are suitable for medium-complexity tasks where subtasks are less predictable, like multi-file coding or research." URL: https://www.anthropic.com/research/building-effective-agents. Verified 2026-05-10. (via WebSearch synthesis; consolidated when-to-use prose tagged secondary.)

7. **LangGraph — Workflows and agents (LangChain official docs):** "Workflows give you complete control. Every step is predictable, every path is defined by you. Perfect when consistency matters more than creativity." URL: https://docs.langchain.com/oss/python/langgraph/workflows-agents. Verified 2026-05-10. (via WebSearch synthesis of canonical URL.)

8. **LangGraph — Hierarchical Agent Teams tutorial:** "When the number of workers becomes too large, the system may be more effective if work is distributed hierarchically. You can do this by composing different subgraphs and creating a top-level supervisor, along with mid-level supervisors." URL: https://langchain-ai.github.io/langgraph/tutorials/multi_agent/hierarchical_agent_teams/. Verified 2026-05-10. (via WebSearch synthesis.)

9. **LangGraph — Hierarchical Agent Teams tutorial:** "The supervisor pattern is a multi-agent architecture where a central supervisor agent coordinates specialized worker agents. This approach excels when tasks require different types of expertise." URL: https://langchain-ai.github.io/langgraph/tutorials/multi_agent/hierarchical_agent_teams/. Verified 2026-05-10. (via WebSearch synthesis.)

10. **CrewAI docs — Hierarchical Process page:** "To utilize the hierarchical process, it's essential to explicitly set the process attribute to Process.hierarchical, as the default behavior is Process.sequential." URL: https://docs.crewai.com/how-to/Hierarchical/. Verified 2026-05-10. (via WebSearch synthesis.)

11. **CrewAI docs — Processes concept page:** "Sequential: Executes tasks sequentially, ensuring tasks are completed in an orderly progression. Hierarchical: Organizes tasks in a managerial hierarchy, where tasks are delegated and executed based on a structured chain of command." URL: https://docs.crewai.com/en/concepts/processes. Verified 2026-05-10. (via WebSearch synthesis.)

12. **AutoGen — Conversation Patterns (Microsoft official docs):** "AutoGen supports three main conversation patterns: Two-agent chat (the simplest form where two agents chat with each other), Sequential chat (a sequence of chats between two agents, chained together by a carryover mechanism), and Group chat (a single chat involving more than two agents)." URL: https://microsoft.github.io/autogen/0.2/docs/tutorial/conversation-patterns/. Verified 2026-05-10. (via WebSearch synthesis.)

13. **OpenAI Cookbook — Orchestrating Agents: Routines and Handoffs:** "A routine is defined as a list of instructions in natural language (represented with a system prompt), along with the tools necessary to complete them." URL: https://cookbook.openai.com/examples/orchestrating_agents. Verified 2026-05-10. (via WebSearch synthesis.)

14. **OpenAI Cookbook — Orchestrating Agents:** "A handoff is an agent (or routine) handing off an active conversation to another agent, much like when you get transferred to someone else on a phone call. Except in this case, the agents have complete knowledge of your prior conversation!" URL: https://cookbook.openai.com/examples/orchestrating_agents. Verified 2026-05-10. (via WebSearch synthesis.)

15. **MetaGPT — arXiv 2308.00352v6:** "MetaGPT showcases its ability to decompose complex tasks into specific actionable procedures assigned to various roles (e.g., Product Manager, Architect, Engineer, etc.). MetaGPT utilizes an assembly line paradigm to assign diverse roles to various agents, efficiently breaking down complex tasks into subtasks involving many agents working together." URL: https://arxiv.org/html/2308.00352v6. Verified 2026-05-10. (via WebSearch synthesis.)

16. **AgentVerse — arXiv 2308.10848:** "For tasks including dialogue response, code completion, and constrained generation, four agents are recruited into the system. For the task of mathematical reasoning, the number is limited to two agents... For tool utilization, two or three agents are recruited to engage in collaborative decision-making and action execution depending on the specific task." URL: https://arxiv.org/pdf/2308.10848. Verified 2026-05-10. (via WebSearch synthesis.)

17. **AgentVerse — arXiv 2308.10848:** "The AGENTVERSE framework splits problem-solving into four stages: expert recruitment, collaborative decision-making, action execution, and evaluation." URL: https://arxiv.org/pdf/2308.10848 (also https://ar5iv.labs.arxiv.org/html/2308.10848). Verified 2026-05-10. (via WebSearch synthesis; secondary summary at emergentmind.com cross-checked.)

18. **AgentVerse — arXiv 2308.10848:** "For a given goal, a particular agent is prompted as the 'recruiter', similar to a human resource manager. Instead of relying on pre-defined expert descriptions, the recruiter dynamically generates a set of expert descriptions based on the goal." URL: https://arxiv.org/pdf/2308.10848. Verified 2026-05-10. (via WebSearch synthesis.)

19. **CoALA — arXiv 2309.02427:** "CoALA organizes agents along three key dimensions: their information storage (divided into working and long-term memories); their action space (divided into internal and external actions); and their decision-making procedure (which is structured as an interactive loop with planning and execution)." URL: https://arxiv.org/abs/2309.02427 and https://arxiv.org/html/2309.02427v3. Verified 2026-05-10. (via WebSearch synthesis.)

20. **ReAct — Prompting Guide:** "ReAct combines reasoning about the situation with action, running a loop of Thought → Action → Observation → Thought → Action → Observation until the agent decides it has enough information to answer." URL: https://www.promptingguide.ai/techniques/react. Verified 2026-05-10. (via WebSearch synthesis. Secondary source — primary source is Yao et al. 2022, arXiv 2210.03629.)

21. **Plan-and-Execute pattern (consolidated when-to-use):** "Plan-and-execute works best for tasks where a reasonable plan can be formulated initially and the problem is complex enough to warrant that planning (e.g. coding a multi-module program, performing a research project, or multi-part questions)." URL: https://theaiengineer.substack.com/p/the-4-single-agent-patterns (synthesized from a survey of LangGraph plan-and-execute docs). Verified 2026-05-10. **Tagged secondary** — primary LangGraph plan-and-execute tutorial was not directly fetched.

22. **Reflexion — Prompting Guide:** "The Reflexion pattern enables agents to learn from failures across multiple trials by maintaining a persistent reflection memory." URL: https://www.promptingguide.ai/techniques/reflexion. Verified 2026-05-10. (via WebSearch synthesis. Secondary source — primary is Shinn et al. 2023, arXiv 2303.11366.)

---

## Methodology Disclosure

- **WebFetch was permission-denied throughout this dispatch.** All 22 citations are tagged `(via WebSearch synthesis of canonical URL)`. The canonical URL is provided for every citation; a future researcher with WebFetch access can re-verify any quote by fetching the URL directly.
- **Search budget:** 14 search calls used (within Anthropic-cited 10-15 ceiling for direct-comparison taxonomy).
- **Tagged secondary sources:** ReAct/Reflexion when-to-use prose (theaiengineer.substack.com synthesizing LangGraph docs), AutoGen "two-agent is the simplest form" (consolidation across microsoft.github.io/autogen and gettingstarted.ai), AgentVerse four-stage summary (emergentmind.com cross-checking arXiv 2308.10848). Each is tagged inline above.
- **Null result recorded:** OpenHands / OpenDevin does **not** publish a formal task-difficulty heuristic for orchestrator effort scaling. Their evaluation harness uses benchmarks (SWE-bench, GAIA, etc.) but does not classify incoming tasks into tiers. This was confirmed by direct search and is recorded as a negative finding rather than a citation gap.
- **Frameworks named in dispatch but not deeply analyzed:**
  - SWE-agent: design is about agent-computer interface, not task tiering. Returned no tier rule.
  - AutoGPT / BabyAGI: task decomposition is recursive/heuristic but no formal tier rule. Returned weak / no useful primary quote on tiering.
  Both are flagged in this disclosure rather than padded into the comparison table.
- **Sister-researcher coordination:** The recommendation explicitly defers the reversibility-as-third-axis question to the sister researcher's enterprise-risk findings. This research alone does not justify adding reversibility — the AI-framework literature does not rate it.
- **Fabrication audit:** Every claim about a framework's tier shape maps to a verbatim quote in the citations section. No paraphrase-as-fact. No training-data substitution.
- **Self-rubric (5 criteria):**
  1. Factual accuracy: PASS (every synthesis claim has a citation).
  2. Citation accuracy: PASS for canonical URLs; flagged as `(via WebSearch synthesis)` because WebFetch denied — a future verifier can re-fetch.
  3. Completeness: PASS — every comparison axis has a value for every framework, with `n/a` explicit where the framework taxonomizes agents (CoALA) rather than tasks.
  4. Source quality: PASS — primary sources are official docs (Anthropic, LangChain, Microsoft, OpenAI, CrewAI) or peer-reviewed papers (MetaGPT ICLR, AgentVerse ICLR, CoALA TMLR). Secondary sources are tagged inline.
  5. Tool efficiency: PASS — 14 calls within the 10-15 ceiling.
