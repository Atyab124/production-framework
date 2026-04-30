# Agent Design Research — PF v2 Researcher Sub-Agent

**Date:** 2026-04-29
**Type:** Source-of-truth research for the `agents/researcher.md` agent (the one that enforces the N≥3 enterprise/OSS citation binding rule)
**Triggered by:** Current draft is shape-correct but lacks role-specific depth on (a) Lead Researcher prompt patterns, (b) citation discipline, (c) parallel/iterative search patterns, (d) tool selection, (e) stopping criteria. PF v2's binding rule (every feature cites SP precedent OR Anthropic guidance) makes this the single most leverage-heavy agent prompt to get right.
**Methodology disclosure:** WebFetch was permission-denied for this session. All quotes below are reproduced verbatim as returned by WebSearch synthesis of the canonical URLs listed in the Sources index. Re-verify against the live URL before committing a binding decision on a single quote.

---

## Canonical sources mined

| # | Source | URL | Relevance to Researcher |
|---|---|---|---|
| 1 | *How we built our multi-agent research system* — Anthropic Engineering, Jun 2025 | https://www.anthropic.com/engineering/multi-agent-research-system | **Primary.** The closest analogue to PF v2's Researcher: Anthropic's own Subagent Researcher inside their Research feature. Specifies prompt patterns, scaling rules, search strategy, evaluation rubric. |
| 2 | *Building Effective AI Agents* — Anthropic, Dec 2024 | https://www.anthropic.com/research/building-effective-agents | Orchestrator-workers and parallelization patterns; ACI design principle. |
| 3 | *Citations* — Claude API Docs | https://docs.claude.com/en/docs/build-with-claude/citations | Anthropic's own citation discipline: chunk-level grounding, response shape, hallucination mitigation via direct quotation. |
| 4 | *Introducing Citations on the Anthropic API* — Anthropic blog, Jan 2025 | https://claude.com/blog/introducing-citations-api | Marketing/principle complement to (3): "ground its answers in source documents" framing. |
| 5 | *PRISMA 2020 statement* | https://www.prisma-statement.org/prisma-2020-checklist | Academic standard for systematic reviews — informs "compare 3-6 frameworks" reporting structure. |
| 6 | *DSPy — Multi-Hop RAG / Retrieve-then-Generate* | https://dspy.ai/tutorials/rag/ , https://dspy.ai/tutorials/rl_multihop/ | Programmatic prompt patterns for retrieve-then-generate; chain-of-thought + RAG composition. |
| 7 | *LangGraph Swarm + LangGraph Supervisor* | https://github.com/langchain-ai/langgraph-swarm-py , https://github.com/langchain-ai/langgraph-supervisor-py | Handoff and supervisor patterns for multi-agent research; reference for how OSS frameworks structure dispatch. |
| 8 | *Aider repo-map* | https://aider.chat/docs/repomap.html , https://aider.chat/2023/10/22/repomap.html | OSS coding-agent context-compression pattern (tree-sitter + PageRank + token budget) — applicable when Researcher must compress a large corpus into a comparison table. |
| 9 | *MetaGPT — SOP-encoded multi-agent framework* | https://arxiv.org/html/2308.00352v6 | Search-and-retrieval flow embedded in role-based SOPs; precedent for tying research to a structured role prompt. |

---

## Part 1 — Verbatim quotes by topic

### Topic A: Lead Researcher → Subagent prompt patterns

> "When a user submits a query, the system creates a LeadResearcher agent that enters an iterative research process and then creates specialized Subagents with specific research tasks." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "Each subagent needs an objective, an output format, guidance on the tools and sources to use, and clear task boundaries." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "The lead agent decomposes queries into subtasks and describes them to subagents." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "Each subagent independently performs web searches, evaluates tool results using interleaved thinking, and returns findings to the LeadResearcher. The LeadResearcher synthesizes these results and decides whether more research is needed." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "The lead agent uses thinking to plan its approach, assessing which tools fit the task, determining query complexity and subagent count, and defining each subagent's role." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

**Translation for PF v2 Researcher:** the dispatching CTO is the Lead Researcher; the PF Researcher *agent* is the Subagent. The CTO's dispatch prompt to Researcher must contain four explicit fields per the Anthropic spec: **objective, output format, tool/source guidance, task boundaries**. Researcher's own internal loop then mirrors the LeadResearcher's iterative pattern: search → evaluate → decide whether more research is needed → return findings.

### Topic B: Citation discipline

> "The best way to help mitigate hallucination risks is to support the answer with citations that incorporate direct quotations from the underlying source documents." — Anthropic, *Citations API* (via WebSearch synthesis)

> "Anthropic launched Citations, a new API feature that lets Claude ground its answers in source documents and provide detailed references to the exact sentences and passages it uses to generate responses, leading to more verifiable, trustworthy outputs." — Anthropic, *Citations API* (via WebSearch synthesis)

> "When Citations is enabled, the API processes user-provided source documents by chunking them into sentences, which are passed to the model with the user's query, and Claude analyzes the query and generates a response that includes precise citations based on the provided chunks for any claims derived from the source material." — Anthropic, *Citations API* (via WebSearch synthesis)

> "An LLM judge evaluated each output against criteria in a rubric: factual accuracy (do claims match sources?), citation accuracy (do the cited sources match the claims?), completeness (are all requested aspects covered?), source quality (did it use primary sources over lower-quality secondary sources?), and tool efficiency (did it use the right tools a reasonable number of times?)." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "Human testers noticed that early agents consistently chose SEO-optimized content farms over authoritative sources like academic PDFs, and adding source quality heuristics to prompts helped resolve this issue." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

**Translation for PF v2 Researcher:** the binding rule is *direct quotation, not paraphrase* — this matches Anthropic's own framing precisely. Source-quality heuristics (prefer primary docs, GitHub source, official blog over SEO content farms) belong in the Researcher prompt explicitly. The five-criterion rubric (factual / citation / completeness / source-quality / tool-efficiency) is a near-perfect template for PF Researcher's self-check before declaring DONE.

### Topic C: Parallel-search and search-strategy patterns

> "The system implements parallel tool calling at two levels: the lead agent spawns 3-5 subagents simultaneously, and individual subagents execute multiple tool calls in parallel." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "Anthropic introduced two kinds of parallelization: (1) the lead agent spins up 3-5 subagents in parallel rather than serially; (2) the subagents use 3+ tools in parallel. These changes cut research time by up to 90% for complex queries." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "Subagents facilitate compression by operating in parallel with their own context windows and exploring different aspects of the question simultaneously, while also providing separation of concerns with distinct tools, prompts, and exploration trajectories." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "Multi-agent research systems excel especially for breadth-first queries that involve pursuing multiple independent directions simultaneously." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "Anthropic's prompting strategy encodes strategies like decomposing difficult questions into smaller tasks, carefully evaluating the quality of sources, adjusting search approaches based on new information, and recognizing when to focus on depth (investigating one topic in detail) vs. breadth (exploring many topics in parallel)." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "Agents often default to overly long, specific queries that return few results, which Anthropic counteracted by prompting agents to start with short, broad queries, evaluate what's available, then progressively narrow focus." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "The research loop executes an excellent OODA (observe, orient, decide, act) loop." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

**Translation for PF v2 Researcher:** when comparing N≥3 enterprise tools, run searches for them **in parallel**, not sequentially. Within a single search round, fire 3+ tool calls in parallel. Always start broad ("how do enterprise SaaS apps handle X") then narrow ("how does Linear specifically implement Y"). The Researcher's internal loop is OODA: observe what's found, orient against gap (do we have N≥3?), decide next search, act.

### Topic D: Search-tool selection and ACI

> "An agent searching the web for context that only exists in Slack is doomed from the start. With Model Context Protocol (MCP) servers providing access to external tools, this problem compounds as agents encounter unseen tools with varying description quality. The team gave agents explicit heuristics: examine all available tools first, match tool usage to user intent, search the web for broad external exploration, and prefer specialized tools over generic ones." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "One rule of thumb is to think about how much effort goes into human-computer interfaces (HCI), and plan to invest just as much effort in creating good agent-computer interfaces (ACI)." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "They even created a tool-testing agent—when given a flawed MCP tool, it attempts to use the tool and then rewrites the tool description to avoid failures." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

**Translation for PF v2 Researcher:** the dispatch prompt must enumerate available tools (WebSearch, WebFetch, Read, Grep, Glob, gh-cli for GitHub) and tell the agent to **prefer specialized tools** (gh-cli for OSS repos > WebSearch for general queries). When WebFetch is permission-denied (a recurring real condition in this environment), the prompt must specify the fallback (WebSearch with verbatim-quote tagging) so the agent doesn't burn tokens trying.

### Topic E: When to stop / search budget / scaling rules

> "Simple fact-finding requires one agent with 3-10 tool calls, direct comparisons need 2-4 subagents with 10-15 calls each, while complex research might use over 10 subagents with clearly divided responsibilities." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "These explicit guidelines help the lead agent allocate resources efficiently and prevent overinvestment in simple queries, which was a common failure mode in early versions." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "Early agents made errors like spawning 50 subagents for simple queries, scouring the web endlessly for nonexistent sources, and distracting each other with excessive updates. Since each agent is steered by a prompt, prompt engineering was our primary lever for improving these behaviors." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "It's common to include stopping conditions (such as a maximum number of iterations) to maintain control." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "The essence of search is compression: distilling insights from a vast corpus." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

**Translation for PF v2 Researcher:** the prompt MUST set a search budget. PF's Researcher is a "direct comparison" task per Anthropic's taxonomy → **10-15 tool calls** is the budget per dispatch. The N≥3 rule is the stopping condition for citation count; the 15-call ceiling is the stopping condition for time. Both must be in the agent prompt, or the agent will either over-search ("scouring the web endlessly") or under-search (giving up at 2 citations).

### Topic F: End-state evaluation (how to verify the Researcher succeeded)

> "Anthropic found success focusing on end-state evaluation rather than turn-by-turn analysis. Instead of judging whether the agent followed a specific process, they evaluated whether it achieved the correct final state." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

> "Anthropic experimented with multiple judges to evaluate each component, but found that a single LLM call with a single prompt outputting scores from 0.0-1.0 and a pass-fail grade was the most consistent and aligned with human judgements." — Anthropic, *Multi-Agent Research System*, Jun 2025 (via WebSearch)

**Translation for PF v2 Researcher:** the PF agent should produce its output to a file (`docs/research/<topic>.md`) and the CTO (Lead) should evaluate the *file*, not the in-conversation summary. This already aligns with PF v2's file-based substrate. What needs to be added: an explicit "self-rubric" pass before declaring DONE — the agent grades its own draft on the 5-criterion rubric and only reports DONE when all 5 pass.

### Topic G: PRISMA — academic systematic-review structure

> "PRISMA 2020 checklist requires specifying the inclusion and exclusion criteria for the review and how studies were grouped for the syntheses." — PRISMA 2020 checklist (via WebSearch)

> "The checklist requires specifying all databases, registers, websites, organisations, reference lists and other sources searched or consulted to identify studies, and specifying the date when each source was last searched or consulted." — PRISMA 2020 (via WebSearch)

> "The PRISMA 2020 checklist requires presenting the full search strategies for all databases, registers and websites, including any filters and limits used." — PRISMA 2020 (via WebSearch)

**Translation for PF v2 Researcher:** PRISMA's discipline maps directly to the Researcher's deliverable structure: (a) **eligibility criteria** ("what counts as an enterprise/OSS comparable for question Q?"), (b) **information sources** (table of frameworks compared with `last-verified` dates — already in current draft), (c) **search strategy** (which queries were tried, in what order). Adding an "Eligibility criteria" subsection upgrades the Researcher's output from "selection of links" to "defensible systematic review."

### Topic H: Aider repo-map — context compression for code-bound research

> "The repo map system uses tree-sitter parsers to extract code definitions and references from source files." — Aider, *Repo Map* (via WebSearch)

> "The core innovation of Aider's repository understanding is using PageRank to rank code relevance based on the graph of definitions and references." — Aider (via WebSearch)

> "Not all symbols are equally important — a function called by 20 other functions is more valuable context than a private helper called once." — Aider (via WebSearch)

> "The repo map must fit within the LLM's context window. The system dynamically calculates token budgets and formats output to stay within limits." — Aider (via WebSearch)

**Translation for PF v2 Researcher:** when the research question is "how does OSS framework X implement pattern Y", the agent should not paste large files into context. Instead, it should follow Aider's discipline: (a) identify the 3-5 most-referenced symbols, (b) cite them with file:line, (c) include only verbatim snippets of the relevant lines. PF v2's existing token-discipline pattern (`bash-output-discipline` skill) is the same idea applied to bash; the Researcher prompt should articulate the equivalent for code reading.

### Topic I: DSPy — programmatic retrieve-then-generate

> "DSPy modules encapsulate prompting techniques, such as chain of thought or retrieval-augmented generation (RAG), and can be invoked as callable classes and combined into larger pipelines." — DSPy docs (via WebSearch)

> "Signatures abstract the input/output behavior of a module, describing what transformation is needed without detailing how to prompt the LM." — DSPy docs (via WebSearch)

> "A chain-of-thought and retrieval-augmented generation (CoT RAG) program can self-bootstrap in DSPy to increase answer EM substantially." — DSPy (via WebSearch)

**Translation for PF v2 Researcher:** DSPy's *signature* concept (declared input/output contract per stage) is what the Researcher's "Question / Frameworks compared / Comparison axes / Synthesis / Recommendation / Citations" sections already approximate. The improvement is being explicit in the agent prompt about each section's signature: "Question: 1 sentence", "Frameworks compared: ≥3 rows with `name | source | last-verified | url`", etc. This is *typed prompting* — and matches Anthropic's "output format" requirement from Topic A.

### Topic J: LangGraph swarm/supervisor — multi-agent handoff patterns

> "LangGraph Supervisor is a Python library for creating hierarchical multi-agent systems using LangGraph, where specialized agents are coordinated by a central supervisor agent that controls all communication flow and task delegation, making decisions about which agent to invoke based on the current context and task requirements." — LangGraph docs (via WebSearch)

> "The supervisor can be equipped with a tool to directly forward the last message received from a worker agent straight to the final output, which is useful when the supervisor determines that the worker's response is sufficient and saves tokens while avoiding potential misrepresentation." — LangGraph supervisor docs (via WebSearch)

**Translation for PF v2 Researcher:** the LangGraph Supervisor's "forward-last-message" pattern is a defensive token-saver that PF v2 already implicitly uses: the CTO doesn't paraphrase the Researcher's findings, it cites the file. This pattern *should* be explicit in the Researcher's contract: "your output is the file at `docs/research/<topic>.md` — the CTO will read that file directly, not your in-conversation summary."

### Topic K: MetaGPT — SOP-encoded research-and-retrieval flow

> "MetaGPT encodes Standardized Operating Procedures (SOPs) into prompt sequences for more streamlined workflows, thus allowing agents with human-like domain expertise to verify intermediate results and reduce errors." — MetaGPT, arxiv 2308.00352 (via WebSearch)

> "When an agent identifies that the user is asking a question, it formulates a search query, fetches an answer from a RAG system, and continues the SOP flow from where it branched." — MetaGPT (via WebSearch)

**Translation for PF v2 Researcher:** MetaGPT confirms the SOP-as-prompt pattern PF v2 already uses (every agent.md is an SOP). The Researcher's SOP should explicitly include the question-detection and search-formulation step: "if your dispatch prompt's question is ambiguous, return NEEDS_CONTEXT before searching" — preventing the failure mode of running 15 searches against a poorly-defined question.

---

## Part 2 — SP precedents inheritable by the Researcher

(From `sp-anthropic-citation-manifest.md` Part 1, plus direct re-reads.)

| SP precedent | Direct relevance to Researcher | Inheritance verdict |
|---|---|---|
| `agents/code-reviewer.md` shape (frontmatter + body becomes system prompt) | Defines the agent.md file shape. | **Direct inherit** (already used in current draft). |
| `subagent-driven-development/SKILL.md` lines 102–118 — 4 status tokens (`DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED`) | Researcher already uses these. | **Direct inherit** (already used). |
| `dispatching-parallel-agents/SKILL.md` lines 1–84 — "Dispatch one agent per independent problem domain" | Maps to Anthropic Topic C (parallel subagents). | **Direct inherit** in CTO dispatch logic, not in Researcher prompt itself. |
| `verification-before-completion/SKILL.md` Iron Law: "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE" | Maps to Anthropic Topic F (end-state evaluation) and Topic B (citation rubric). | **Direct inherit** — Researcher's pre-DONE self-rubric is the SP Iron Law applied to research. |
| `writing-skills/SKILL.md` Red Flags / Excuse-Reality table | The most empirically-tuned anti-rationalization device in SP. | **Adapt** — Researcher needs its own Red Flags table for the citation gap (e.g., "Excuse: I only found 2, but they agree → Reality: 2 is not 3, return NEEDS_CONTEXT"). |
| `brainstorming/SKILL.md` `## Anti-Pattern: "This Is Too Simple To Need A Design"` | Anti-pattern framing convention. | **Adapt** — Researcher's equivalent: `## Anti-Pattern: "I Already Know How Slack Does It"`. |
| `writing-skills/SKILL.md` "violating the letter is violating the spirit" | Rationalization-prevention discipline. | **Adapt** — applies to the N≥3 rule, citation verbatim rule, and date-verify rule. |

---

## Part 3 — Gaps in current `agents/researcher.md` (vs. mined sources)

The current draft is shape-correct but missing role-specific depth. Concrete gaps follow.

### Gap 1 — No explicit search budget

**Current state:** No mention of tool-call count or iteration ceiling.

**What Anthropic says:** "Direct comparisons need 2-4 subagents with 10-15 calls each" (Topic E). "Spawning 50 subagents for simple queries" was a cited failure mode.

**Recommended addition:** A `## Search budget` section: "PF Researcher tasks are 'direct comparisons' per Anthropic's taxonomy. Budget: 10-15 search/fetch calls per dispatch. If you've used 15 and still have <3 citations, return NEEDS_CONTEXT — don't keep searching."

### Gap 2 — No "start broad, narrow down" guidance

**Current state:** Lists "internet" as a source but doesn't prescribe query strategy.

**What Anthropic says:** "Start with short, broad queries, evaluate what's available, then progressively narrow focus" (Topic C).

**Recommended addition:** A `## Search strategy` section: "Round 1 — 1 broad query per framework ('how does Linear handle X'). Round 2 — narrow to specifics ('Linear `presence` table schema'). Round 3 — primary-source fetch (GitHub, official docs, engineering blog). Do NOT start with the narrowest query."

### Gap 3 — No tool-preference order

**Current state:** Mentions WebFetch fallback to WebSearch but doesn't rank tools.

**What Anthropic says:** "Prefer specialized tools over generic ones" (Topic D).

**Recommended addition:** A `## Tool selection` section with explicit precedence: `gh CLI for OSS GitHub repos` > `WebFetch for primary URLs` > `WebSearch for synthesis when WebFetch denied`. Plus the source-quality heuristic: "primary sources (official docs, GitHub source, engineering blog) over secondary (Medium articles, ZenML summaries) over content farms (SEO sites)."

### Gap 4 — No self-rubric before DONE

**Current state:** Lists hard rules, but no pre-DONE check.

**What Anthropic says:** End-state evaluation via 5-criterion rubric: factual / citation / completeness / source-quality / tool-efficiency (Topic B, F).

**Recommended addition:** A `## Pre-DONE self-rubric` section: "Before declaring DONE, grade your draft on: (1) factual accuracy — every claim has a verbatim quote? (2) citation accuracy — quote actually appears at the cited URL? (3) completeness — all axes filled? (4) source quality — primary > secondary? (5) tool efficiency — within budget? If any fails, fix before reporting."

### Gap 5 — No PRISMA-style "eligibility criteria"

**Current state:** "Frameworks compared" table requires N≥3 but doesn't define what counts as comparable.

**What PRISMA says:** "Specify the inclusion and exclusion criteria for the review" (Topic G).

**Recommended addition:** Add a row to the output template: `## Eligibility criteria` — "What counts as a comparable framework for question Q? E.g., 'enterprise SaaS with realtime presence + multi-tenant'. Frameworks not meeting these criteria are excluded with a one-line reason."

### Gap 6 — No Red Flags / Excuse-Reality table

**Current state:** Hard rules listed prose-style.

**What SP says:** Most-tested anti-rationalization device is the two-column table (`writing-skills` / `tdd` / `verification-before-completion`).

**Recommended addition:** A `## Red Flags` section adapting SP's pattern:

```
| Excuse | Reality |
|---|---|
| "I only found 2, but they're authoritative" | 2 is not 3. Return NEEDS_CONTEXT. |
| "The third tool would just confirm the first two" | You don't know that without checking. |
| "I summarized the source instead of quoting because the doc is paywalled" | Cite the URL + tag (paywalled, accessed via secondary). Don't fabricate the quote. |
| "WebFetch is denied so I'll rely on training data" | Tag (via WebSearch synthesis) and cite the URL. Never silently substitute training data. |
| "The user's question implies they want X — I'll back-fill citations for X" | Opinion-first research is forbidden. Surface the gap. |
| "I found it on Medium so it's a citation" | Medium is secondary at best. Find the primary source or tag it secondary. |
```

### Gap 7 — No "context compression" guidance for code reading

**Current state:** Silent on how to read OSS source code without context-pollution.

**What Aider says:** Symbol-importance ranking; only include high-PageRank definitions; token-budget output (Topic H).

**Recommended addition:** A `## Reading OSS source` section: "When citing code from a GitHub repo, do NOT paste full files. Cite `path/to/file.py:lineN-lineM` with verbatim snippet of the 5-15 relevant lines. Use grep/Glob to find symbols; use Read with `offset`/`limit` to extract just the snippet."

### Gap 8 — No explicit input-contract enforcement

**Current state:** Says "What you read" but doesn't enforce "reject ambiguous dispatch."

**What MetaGPT says:** Question-formulation step is part of the SOP (Topic K).

**Recommended addition:** A first-checklist-item: "If the dispatch prompt's question is ambiguous (multi-part, no clear axis to compare on), return NEEDS_CONTEXT *before searching*. Saving 15 wasted tool calls is more valuable than a low-quality answer."

### Gap 9 — No OODA-style internal loop description

**Current state:** Implicit linear flow.

**What Anthropic says:** OODA loop — observe gathered info, orient toward gap, decide tool/query, act (Topic C).

**Recommended addition:** A `## Your internal loop` section explicitly stating the OODA frame so the agent knows it's expected to iterate — not just run one batch of searches and stop.

### Gap 10 — No "your output is the file" emphasis

**Current state:** Says "you write a doc at docs/research/<topic>.md" but doesn't emphasize that the conversation summary is *not* the deliverable.

**What LangGraph/Anthropic says:** Forward-last-message + file-artifact substrate (Topic J + §2.17 of citation manifest).

**Recommended addition:** A `## Output discipline` section: "Your deliverable is the file. Your in-conversation summary is ≤10 lines: status token + top finding + file path + open gaps. The CTO reads the file, not your summary."

---

## Part 4 — Suggested revisions to `agents/researcher.md`

Below is a concrete edit plan. Numbered items map to Gap # above.

**Add new sections (in this order, after `## Hard rules`):**

1. **`## Search budget`** (Gap 1) — 10-15 tool calls; NEEDS_CONTEXT if ceiling hit before N≥3.
2. **`## Search strategy`** (Gap 2) — broad → narrow → primary-source-fetch.
3. **`## Tool selection`** (Gap 3) — precedence list + source-quality heuristic.
4. **`## Your internal loop`** (Gap 9) — OODA with one-sentence-per-step.
5. **`## Reading OSS source`** (Gap 7) — file:line + verbatim snippet, no full files.
6. **`## Pre-DONE self-rubric`** (Gap 4) — 5 criteria from Anthropic's evaluator.
7. **`## Red Flags`** (Gap 6) — table above.
8. **`## Output discipline`** (Gap 10) — file is deliverable, summary ≤10 lines.

**Modify existing sections:**

9. **Output template** — add `## Eligibility criteria` row (Gap 5) before `## Frameworks compared`.
10. **Checklist (top of body)** — first item becomes "Verify dispatch question is unambiguous; if not, return NEEDS_CONTEXT before searching" (Gap 8).

**Update `## Citations` at end:**

- Add citation for the Lead-Researcher pattern (already there).
- Add citation for citation-discipline (Anthropic Citations API).
- Add citation for search-budget (multi-agent research system "scaling rules").
- Add citation for PRISMA (eligibility criteria).
- Add citation for Aider (context-compression for code).

**Suggested inline anti-pattern blocks (SP convention):**

```
## Anti-Pattern: "I Already Know How Slack Does It"

Training data is not a citation. Even if you "remember" Slack uses table X with column Y,
verify against a current primary source. Slack's data model evolves; your training cutoff
does not. If the primary source is inaccessible (paywalled, behind login), tag the citation
explicitly — never silently substitute training data for a verified quote.

## Anti-Pattern: "Two Strong Citations Beat Three Weak Ones"

The N≥3 binding rule is a count rule, not a quality rule. Two enterprise citations + one
OSS citation that all confirm the same pattern is stronger evidence than two enterprise
citations alone, even if the OSS citation is from a smaller project. The point of N≥3 is
to defeat single-source bias — and 2 is not 3.

## Anti-Pattern: "I'll Just Recommend What I Think Is Right"

Opinion-first research is the failure mode this agent exists to prevent. Research the
landscape, build the comparison table, and let the synthesis fall out of the evidence —
not the other way around. If your recommendation surprises you, that's the sign the
research worked. If it didn't, you may have back-filled the citations.
```

---

## Part 5 — What NOT to change

Some elements of the current draft are already well-cited and should NOT be modified:

- **Frontmatter `description`** with two `<example>` blocks — matches SP `agents/code-reviewer.md` shape exactly.
- **`> Anthropic-cited foundation:` header quote** — exactly the right citation for the parallel-subagent pattern.
- **N≥3 binding rule with NEEDS_CONTEXT escape hatch** — already correct; the binding-rule provenance is honestly tagged as "PF-internal heuristic" per `sp-anthropic-citation-manifest.md` GAP-1, which is the right framing.
- **Status token grammar** — direct SP inherit, do not modify.
- **`Verify dates` rule** (URLs older than 90 days re-verify) — PF-internal but defensible; keep.
- **`Flag WebFetch failures` fallback rule** — environment-specific to Claude Code; keep.

---

## Part 6 — Effort estimate and files affected

**Files to edit:**

1. `agents/researcher.md` — 8 new sections + checklist update + 3 anti-pattern blocks. ~150 net lines added.
2. `docs/research/sp-anthropic-citation-manifest.md` — add a new row in Part 3 mapping `agents/researcher.md` rev 2 to its citations (Topics A–K above). ~10 lines added.

**No new skill files.** All revisions are content additions to the existing agent.md.

**Effort:** 1–2 hours for one Builder. Single PR. Citation manifest update is part of the same PR per CLAUDE.md.

**Risk:** Low. The agent.md is a system prompt, not code; pressure-testing per CLAUDE.md "skill changes require evaluation" rule means the revised agent should be dispatched against ≥3 real research questions and graded against the 5-criterion rubric before merge. Specifically, run the existing `sp-anthropic-citation-manifest.md` task as a regression test — the revised researcher should produce a doc *at least as good* on the same prompt.

---

## Sources index (canonical URLs for re-verification)

**Anthropic primary sources used:**
- *How we built our multi-agent research system* — https://www.anthropic.com/engineering/multi-agent-research-system (Jun 2025)
- *Building Effective AI Agents* — https://www.anthropic.com/research/building-effective-agents (Dec 19 2024)
- *Citations* (API docs) — https://docs.claude.com/en/docs/build-with-claude/citations
- *Introducing Citations on the Anthropic API* — https://claude.com/blog/introducing-citations-api (Jan 24 2025)

**Academic / OSS sources used:**
- *PRISMA 2020 statement* — https://www.prisma-statement.org/prisma-2020-checklist
- *PRISMA 2020 — full guideline (PMC)* — https://pmc.ncbi.nlm.nih.gov/articles/PMC8007028/
- *DSPy — RAG tutorial* — https://dspy.ai/tutorials/rag/
- *DSPy — RL Multi-Hop tutorial* — https://dspy.ai/tutorials/rl_multihop/
- *DSPy paper* — https://arxiv.org/pdf/2310.03714
- *LangGraph Swarm* — https://github.com/langchain-ai/langgraph-swarm-py
- *LangGraph Supervisor* — https://github.com/langchain-ai/langgraph-supervisor-py
- *Aider Repo Map docs* — https://aider.chat/docs/repomap.html
- *Aider Repo Map blog post* — https://aider.chat/2023/10/22/repomap.html
- *Aider Repo Map (DeepWiki extract)* — https://deepwiki.com/Aider-AI/aider/4.1-repository-mapping
- *MetaGPT paper* — https://arxiv.org/html/2308.00352v6

**Methodology disclosure:** WebFetch was permission-denied for this session. All quotes are reproduced verbatim as returned by WebSearch synthesis of the canonical URLs above. Re-verify against the live URL via direct WebFetch in a session where permission is granted before committing a binding decision on a single quote.
