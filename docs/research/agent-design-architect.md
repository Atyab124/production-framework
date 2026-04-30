# Agent Design Research — Architect

**Date:** 2026-04-29
**Type:** Source-of-truth research — no code modifications
**Triggered by:** `agents/architect.md` was written for shape-correctness; needs role-specific depth derived from canonical software-architect literature and multi-agent-system precedent.
**Methodology disclosure:** WebFetch was permission-denied this session. All external quotes were retrieved via WebSearch synthesis of the canonical URLs listed in §Citations and are tagged `(via WebSearch synthesis of canonical URL)`. Re-verify against canonical URLs before any binding architectural decision per the SP+Anthropic citation manifest's Part 2 rule.

---

## Canonical sources mined

| Source | URL | Last-verified | What it teaches |
|---|---|---|---|
| C4 Model (Simon Brown) | https://c4model.com/ | 2026-04-29 | Four-level hierarchical decomposition: Context → Container → Component → Code. Audience-tiered storytelling. |
| MADR (adr.github.io) | https://adr.github.io/madr/ | 2026-04-29 | Markdown ADR template — Context, Decision Drivers, Considered Options, Decision Outcome, Consequences. |
| Y-Statement (Zimmermann, SATURN 2012) | https://medium.com/olzzio/y-statements-10eb07b5a177 ; https://ozimmer.ch/practices/2020/04/27/ArchitectureDecisionMaking.html | 2026-04-29 | One-sentence WH(Y) template encoding context/concern/decision/neglected/benefits/drawbacks. |
| MetaGPT (Hong et al., ICLR 2024) | https://arxiv.org/html/2308.00352v6 | 2026-04-29 | Architect role generates File Lists + Data Structures + Interface Definitions + sequence flow diagram as structured documents (not dialogue). |
| ChatDev (Qian et al., ACL 2024) | https://arxiv.org/html/2307.07924v5 ; https://github.com/OpenBMB/ChatDev | 2026-04-29 | CTO role chooses tech stack and procedure during design phase via paired-agent ChatChain dialogues. |
| Building Effective AI Agents (Anthropic) | https://www.anthropic.com/research/building-effective-agents | 2026-04-29 | Orchestrator-workers, prompt-chaining, simplicity, "subagent needs an objective, output format, tool guidance, task boundaries." |
| How we built our multi-agent research system (Anthropic Engineering, Jun 2025) | https://www.anthropic.com/engineering/multi-agent-research-system | 2026-04-29 | Detailed delegation, effort scaling (3-10 / 10-15 / 10+ tool calls per subagent), prompt engineering as primary lever. |
| AWS Well-Architected — six pillars | https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html | 2026-04-29 | Operational Excellence, Security, Reliability, Performance Efficiency, Cost Optimization, Sustainability. |
| AWS Well-Architected SaaS Lens | https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/silo-pool-and-bridge-models.html | 2026-04-29 | Silo / Pool / Bridge tenant-isolation models with mixed-mode reality. |
| arc42 | https://arc42.org/overview ; https://docs.arc42.org/section-5/ ; https://docs.arc42.org/section-6/ ; https://docs.arc42.org/section-8/ | 2026-04-29 | 12-section, method-and-tool-agnostic template — building blocks (5), runtime (6), deployment (7), cross-cutting concepts (8), decisions (9), quality (10), risks (11). |

---

## Verbatim quotes by topic

### Module boundaries / decomposition

> "The C4 model consists of a set of hierarchical abstractions — software systems, containers, components, and code. It includes a set of hierarchical diagrams — system context, containers, components, and code."
> — C4 model home page, https://c4model.com/, verified 2026-04-29 (via WebSearch synthesis of canonical URL)

> "A container is something that needs to be running in order for the overall software system to work (e.g. a Server-side web application, a Microservice, a Serverless function, a File system)."
> — C4 model home page, https://c4model.com/, verified 2026-04-29 (via WebSearch synthesis of canonical URL)

> "A component is a grouping of related code that lives behind a well-defined interface."
> — C4 model home page, https://c4model.com/ (via WebSearch synthesis of canonical URL)

> "The C4 model is a simple way to communicate software architecture at different levels of abstraction, so that you can tell different stories to different audiences."
> — C4 model home page (via WebSearch synthesis of canonical URL)

> "The building block view shows the static decomposition of the system into building blocks (modules, components, subsystems, classes, interfaces, packages, libraries, frameworks, layers, partitions, tiers, functions, macros, operations, data structures, …) as well as their dependencies (relationships, associations, …). The building block view is a hierarchical collection of black boxes and white boxes and their descriptions."
> — arc42 §5 Building Block View, https://docs.arc42.org/section-5/ (via WebSearch synthesis of canonical URL)

> "The runtime view describes concrete behavior and interactions of the system's building blocks in form of scenarios from the following areas: important use cases or features… interactions at critical external interfaces… operation and administration: launch, start-up, stop; error and exception scenarios."
> — arc42 §6 Runtime View, https://docs.arc42.org/section-6/ (via WebSearch synthesis of canonical URL)

> "Some topics within systems often concern multiple building blocks, hardware elements or development processes. It might be easier to communicate or document such cross-cutting topics at a central location, instead of repeating them. Cross-cutting concepts include different topics like domain models, architecture patterns and styles, rules for using specific technology and implementation rules."
> — arc42 §8 Concepts, https://docs.arc42.org/section-8/ (via WebSearch synthesis of canonical URL)

### ADR / decision records

> "The MADR template includes the following core sections: Context and Problem Statement… Decision Drivers… Considered Options… Decision Outcome… Consequences… More Information."
> — MADR template, https://adr.github.io/madr/decisions/adr-template.html (via WebSearch synthesis of canonical URL)

> "As of version 3.0.0, the sections 'Positive Consequences' and 'Negative Consequences' were merged into 'Consequences' to enable similar grammar as in 'Pros and Cons of the Options'."
> — MADR release notes (via WebSearch synthesis)

> Y-Statement form: "In the context of [use case/user story], facing [concern], we decided for [option], and neglected [other options], to achieve [system qualities/desired consequences], accepting [downside/undesired consequences]."
> — Zimmermann Y-statements, https://medium.com/olzzio/y-statements-10eb07b5a177 (via WebSearch synthesis of canonical URL)

> "Architectural Decisions answer 'why?' questions about design and justify why an option is chosen."
> — Zimmermann, https://ozimmer.ch/practices/2020/04/27/ArchitectureDecisionMaking.html (via WebSearch synthesis)

### Multi-tenant SaaS architectural patterns

> "SaaS applications can use three types of isolation: silo, pool, and bridge."
> — AWS Well-Architected SaaS Lens, https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/silo-pool-and-bridge-models.html (via WebSearch synthesis)

> "The silo model refers to an architecture where tenants are provided dedicated resources, where each tenant of your system has a fully independent infrastructure stack or separate database."
> — AWS SaaS Lens, silo-isolation page (via WebSearch synthesis)

> "The pool model refers to a scenario where tenants share resources… the more classic notion of multi-tenancy where tenants rely on shared, scalable infrastructure to achieve economies of scale, manageability, agility, and so on."
> — AWS SaaS Lens, pool-isolation page (via WebSearch synthesis)

> "Bridge acknowledges the reality that SaaS businesses aren't always exclusively silo or pool, instead many systems have a mixed mode where some of the system is implemented in a silo model and some is in a pooled model."
> — AWS SaaS Lens, bridge-model page (via WebSearch synthesis)

> "Services should be decomposed based on multi-tenant load and isolation profile, where some services might pool data while others need to silo data based on compliance or noisy neighbor considerations."
> — AWS SaaS Lens (via WebSearch synthesis)

> AWS Well-Architected six pillars: "operational excellence, security, reliability, performance efficiency, cost optimization, and sustainability."
> — AWS Well-Architected, https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html (via WebSearch synthesis)

### Architect-as-subagent prompt patterns (MetaGPT, ChatDev)

> "The Architect translates requirements into system design components, such as File Lists, Data Structures, and Interface Definitions."
> — MetaGPT (Hong et al.), https://arxiv.org/html/2308.00352v6, §3 (via WebSearch synthesis)

> "The Architect agent generates two outputs: the system interface design and a sequence flow diagram, which contain system module design and interaction sequences that serve as important deliverables for Engineers."
> — MetaGPT §3 (via WebSearch synthesis)

> "The structured PRD is then passed to the Architect, who translates the requirements into system design components, such as File Lists, Data Structures, and Interface Definitions. Once captured in the system design, the information is directed towards the Project Manager for task distribution."
> — MetaGPT §3.2-3.3 (via WebSearch synthesis)

> "Unlike ChatDev, agents in MetaGPT communicate through documents and diagrams (structured outputs) rather than dialogue."
> — MetaGPT (via WebSearch synthesis)

> "MetaGPT encodes Standardized Operating Procedures (SOPs) into prompt sequences for more streamlined workflows, thus allowing agents with human-like domain expertise to verify intermediate results and reduce errors."
> — MetaGPT (via WebSearch synthesis)

> "ChatDev divides software development into 5 subtasks within 3 phases, assigning specific roles like CEO, CTO, programmer, reviewer, and tester. The CTO is assigned tasks by the CEO and assigns to developers."
> — ChatDev (Qian et al.), https://arxiv.org/html/2307.07924v5 (via WebSearch synthesis)

> "During the design phase, ChatDev follows a process where agents first decide the overall method procedure process for the application, followed by language selection — deciding what programming language to use to build and run the software."
> — ChatDev (via WebSearch synthesis)

> "Atomic chats extract, summarize, and refine architectural blueprints during the design phase, where the CTO plays an active role."
> — ChatDev (via WebSearch synthesis)

### Anthropic guidance on architectural-design subagents

> "In the orchestrator-workers workflow, a central LLM dynamically breaks down tasks, delegates them to worker LLMs, and synthesizes their results."
> — Anthropic, *Building Effective AI Agents*, Dec 19 2024, https://www.anthropic.com/research/building-effective-agents (via WebSearch synthesis)

> "Prompt chaining decomposes a task into a sequence of steps, where each LLM call processes the output of the previous one. This workflow is ideal for situations where the task can be easily and cleanly decomposed into fixed subtasks, with the main goal of trading off latency for higher accuracy."
> — Anthropic, *Building Effective AI Agents* (via WebSearch synthesis)

> "Each subagent needs an objective, an output format, guidance on the tools and sources to use, and clear task boundaries."
> — Anthropic, *Building Effective AI Agents* / *Multi-agent research system* (via WebSearch synthesis of canonical URLs)

> "Without detailed task descriptions, agents would duplicate work or leave critical information gaps."
> — Anthropic, *How we built our multi-agent research system*, Jun 2025, https://www.anthropic.com/engineering/multi-agent-research-system (via WebSearch synthesis)

> "The prompts evolved from simple instructions like 'research the semiconductor shortage' to detailed mandates that specify search strategies, source types, and coordination protocols. Designing good prompts turned out to be the single most important way to guide how the agents behaved, as small changes in phrasing could make the difference between efficient research and wasted effort."
> — Anthropic, *Multi-agent research system* (via WebSearch synthesis)

> "Effective agents come from design choices. When implementing agents, focus on keeping the architecture simple, starting small, building modularly, and introducing complexity when it clearly improves performance or flexibility."
> — Anthropic, *Building Effective AI Agents* (via WebSearch synthesis)

> "Simple fact-finding requires one agent with 3-10 tool calls, direct comparisons need 2-4 subagents with 10-15 calls each, while complex research might use over 10 subagents."
> — Anthropic, *Multi-agent research system* (via WebSearch synthesis)

---

## SP-inheritable patterns

**None direct.** Superpowers 5.0.7 ships zero standing architecture-design agent. SP's nearest analogues are:

- `skills/brainstorming/SKILL.md` — "design before code" hard-gate (cited verbatim in citation manifest Part 1, row 3); applies to *any* implementation, not architectural-design specifically.
- `skills/writing-plans/SKILL.md` — produces a build plan, not a system-design document. Plans presume the design is settled.
- `agents/code-reviewer.md` — frontmatter+body shape inherited; no content overlap.

**Conclusion:** Architect is a PF v2 net-new role. SP's only contribution is the *file-shape* of an `agents/<role>.md` (already followed) and the principle of "design first" (covered by brainstorming). All role-specific behavior must be sourced from MetaGPT / ChatDev / Anthropic guidance / C4 / arc42 / MADR / AWS-WAF — i.e. from this document.

This is consistent with the citation manifest's Part 3 row "13-agent specialist roster — OK on Anthropic alone — but Anthropic example is 3-5 subagents per task, NOT 13 standing roles. Document scaling rationale." Architect is one such role; its content depth must come from the canonical software-architect literature mined here.

---

## Gaps in current `agents/architect.md`

The current draft (62 lines) gets the SHAPE right but is thin on architect-specific tradecraft. Concrete gaps:

### Gap A — Module-decomposition discipline is unnamed

**Current:** "Module boundaries — what new modules / files; what existing modules they touch" (one bullet, line 31).

**Gap:** No reference to a hierarchical decomposition model. Without one, "module boundaries" can be answered at any level (one giant file vs. classes vs. micro-functions). MetaGPT's Architect produces **File Lists + Data Structures + Interface Definitions** as discrete artefacts, not one prose section.

**Justification quote:** "The Architect translates requirements into system design components, such as File Lists, Data Structures, and Interface Definitions." — MetaGPT §3 (above).

**Recommended fix:** Adopt C4 abstraction levels for the Architect's output:
- **Container level (mandatory):** what services / processes / deployable units exist after this change.
- **Component level (mandatory):** what components-with-well-defined-interfaces live in each container.
- **Code level (optional, only when novel):** class/function shape if the pattern is unprecedented in the codebase.
The Context level is the user-spec / PM responsibility, not the Architect's.

### Gap B — Architect output is one prose doc, not structured artefacts

**Current:** Single `docs/architecture/<feature>.md` with eight bullet sections.

**Gap:** MetaGPT, arc42, and C4 all argue for *structured-by-aspect* outputs. Engineers downstream (Builder, QA) parse different sections for different purposes. A single prose doc forces all readers through all sections.

**Justification quote:** "MetaGPT requires agents to generate structured outputs, such as high-quality requirements documents, design artifacts, flowcharts, and interface specifications." — MetaGPT (above). Plus: "Each subagent needs an objective, an output format…" — Anthropic.

**Recommended fix:** Keep one file (filesystem hygiene), but mandate three named sub-sections corresponding to MetaGPT's deliverables, mapped to PF v2 vocabulary:
1. **File List** — every new/modified file with one-line purpose.
2. **Data Contracts** — tables, columns, RPC signatures, message shapes (the "Data Structures" + "Interface Definitions" merge).
3. **Sequence View** — request paths under happy + degraded + concurrent conditions.

These replace the current "Data flow / Integration contracts" bullets with stricter shape.

### Gap C — No ADR mechanism for non-obvious choices

**Current:** "Cite enterprise precedent for any non-obvious choice" (line 45) + "Open questions for Researcher" (line 38).

**Gap:** Architectural decisions made *during* design (not deferred to Researcher) have no capture mechanism. The PF v2 file layout already includes `docs/adr/<n>-<decision>.md` (per `cto-mode/SKILL.md` line 78 and CLAUDE.md `docs/adr/`), but `architect.md` never tells the Architect to write one.

**Justification quote:** "Architectural Decisions answer 'why?' questions about design and justify why an option is chosen. Answers to 'why?' questions are as important as anything else in designs." — Zimmermann (above). MADR's "Decision Drivers / Considered Options / Decision Outcome / Consequences" is the canonical capture format.

**Recommended fix:** Add a hard rule: every non-obvious choice the Architect makes (i.e. one with a defensible alternative) gets an ADR file at `docs/adr/<n>-<slug>.md` using **MADR template** (Context, Decision Drivers, Considered Options, Decision Outcome, Consequences) OR a **Y-statement** for compact decisions. Link the ADR from the architecture doc; do not inline.

### Gap D — Multi-tenant section is single-bullet; no tradeoff guidance

**Current:** "Multi-tenant contract — RLS posture, tenant scope, cross-tenant safeguards (always present, even if 'single-tenant — no RLS')" (line 34) + "Multi-tenant section is mandatory" (line 47).

**Gap:** No vocabulary for the *isolation model*. PF v2 targets enterprise multi-tenant SaaS (CLAUDE.md line 9). The canonical taxonomy is silo / pool / bridge per AWS SaaS Lens; current draft never names it.

**Justification quote:** "SaaS applications can use three types of isolation: silo, pool, and bridge." — AWS SaaS Lens (above). Plus: "Services should be decomposed based on multi-tenant load and isolation profile."

**Recommended fix:** Replace single bullet with a required mini-table per feature:
| Resource | Isolation model (silo/pool/bridge) | Mechanism (RLS, separate DB, schema, prefix, etc.) | Rationale |

The Architect MUST classify every shared resource into silo/pool/bridge and justify. Single-tenant projects say "pool — only one tenant exists" and move on; the slot is still filled.

### Gap E — No quality-attribute / failure-mode framework

**Current:** "Failure modes — what breaks under partial failure, retry, partition" (line 36) + "Observability — what gets instrumented, where alerts fire" (line 37).

**Gap:** Two bullets, no taxonomy. AWS Well-Architected's six pillars and arc42 §10 (Quality) provide canonical taxonomies. Without one, the Architect can credibly write "fails under partition" and stop.

**Justification quote:** AWS WAF six pillars: "operational excellence, security, reliability, performance efficiency, cost optimization, and sustainability." Plus: arc42 §10 "Quality" requires explicit quality attributes.

**Recommended fix:** Replace the two bullets with one **quality-attribute matrix** per feature: required pillars × the design's posture on each. At minimum: Reliability (what fails, how it recovers), Security (auth/authz/data-handling — composes with Security/Compliance agent), Performance (target latency / throughput, measured how), Operational Excellence (observability hooks, alerting). Cost and Sustainability are optional unless flagged in the spec.

### Gap F — No effort-scaling guidance for the Architect itself

**Current:** No mention of how deep the architect should go.

**Gap:** Anthropic's tier-aware effort scaling ("Simple fact-finding requires one agent with 3-10 tool calls; direct comparisons need 2-4 subagents with 10-15 calls each…") is precedent for stack-depth guidance the Architect lacks. Tier 2 Build cycles and Tier 3 Build cycles need different architecture-doc depth.

**Justification quote:** "Simple fact-finding requires one agent with 3-10 tool calls, direct comparisons need 2-4 subagents…" — Anthropic *Multi-agent research system*. Plus: "find the simplest solution… only increase complexity when needed" — *Building Effective Agents* (cited in citation manifest §2.6).

**Recommended fix:** Add a "Depth-by-tier" rule:
- **Tier 2:** File List + Data Contracts + Multi-tenant table + one ADR (if any non-obvious choice). No Sequence View unless concurrency or partial-failure is in scope.
- **Tier 3:** All sections. Sequence View for at least one happy and one degraded path. ADRs for every non-obvious choice. Quality-attribute matrix mandatory.
- **Tier 1:** Architect is not dispatched (per `cto-mode/SKILL.md` HARD-GATE exception line 14). Should be stated as a non-trigger.

### Gap G — "Don't write code" is correct but unsupported by canonical citation

**Current:** "Do not write source code. Implementation is the Builder's job." (line 44).

**Gap:** Currently sourced from PF-internal CTO/Builder split. Strongest external citation is MetaGPT's role separation: "Once captured in the system design, the information is directed towards the Project Manager for task distribution… Given the provided file structure and function definitions, an Engineer agent requires only fundamental development skills to complete the development tasks."

**Recommended fix:** Add the MetaGPT quote as the cited foundation for the rule. Same shape as the existing Anthropic-citation banner at the top of the file.

### Gap H — Missing "structured documents, not dialogue" principle

**Current:** Implicit (Architect writes one doc; subsequent agents read it).

**Gap:** MetaGPT's load-bearing finding was that document-passing beats dialogue-passing. PF v2's `cto-mode/SKILL.md` line 79 already enforces this for the CTO ("Do NOT inline file contents into the prompt — agents read from disk"), but `architect.md` never names it as the Architect's communication protocol.

**Justification quote:** "Unlike ChatDev, agents in MetaGPT communicate through documents and diagrams (structured outputs) rather than dialogue." — MetaGPT.

**Recommended fix:** Add a one-line principle near the top: "You communicate to downstream agents through the architecture document and ADRs — never through messages relayed via the CTO." This anchors the file-substrate model already used by `cto-mode`.

---

## Suggested prompt revisions

Below: paragraphs to add or edit. Each cites the quote that justifies it.

### Revision 1 — Add a second cited-foundation banner (after line 11)

> Cited foundation: "The Architect translates requirements into system design components, such as File Lists, Data Structures, and Interface Definitions. Once captured in the system design, the information is directed towards the Project Manager for task distribution." — *MetaGPT: Meta Programming for a Multi-Agent Collaborative Framework* (Hong et al., ICLR 2024), https://arxiv.org/html/2308.00352v6, §3.2-3.3 (via WebSearch synthesis of canonical URL, verified 2026-04-29).

> "MetaGPT requires agents to generate structured outputs, such as high-quality requirements documents, design artifacts, flowcharts, and interface specifications." — MetaGPT (same source).

**Justification:** Gap G + Gap B. Anchors the role's literature provenance and the structured-output principle.

### Revision 2 — Replace "What you write" section (current lines 28-40) with C4-aligned, tiered structure

Add this paragraph before the bullet list:

> Your output is structured along the C4 model levels (Brown, https://c4model.com/, verified 2026-04-29): you operate at Container (services/deployable units) and Component (well-defined-interface modules) levels. The Code level is for the Builder; the Context level is for the Product Manager. Cite: "A component is a grouping of related code that lives behind a well-defined interface." — c4model.com.

Then replace the eight bullets with these (keeping `architecture/<feature>.md` as the file path):

1. **Goal** — one sentence restating the user-visible outcome.
2. **File List** — every new/modified file with one-line purpose. (MetaGPT precedent.)
3. **Container/Component diagram** — text or mermaid; what services exist, which components live in each, which are new vs. modified. (C4 levels 2-3.)
4. **Data Contracts** — tables, columns, RPC signatures, message/event shapes. (MetaGPT "Data Structures + Interface Definitions".)
5. **Sequence View** — request paths under happy + at least one degraded path (Tier 3 mandatory; Tier 2 only when concurrency/partial-failure is in scope). (arc42 §6 Runtime View.)
6. **Multi-tenant isolation table** — one row per shared resource × silo/pool/bridge × mechanism × rationale. (AWS SaaS Lens vocabulary.)
7. **Quality-attribute matrix** — Reliability / Security / Performance / Operational Excellence postures. Cost & Sustainability optional. (AWS Well-Architected six pillars; arc42 §10.)
8. **Cross-cutting concepts** — domain models, shared rules, conventions reused across components. (arc42 §8.)
9. **ADR links** — one bullet per `docs/adr/<n>-<slug>.md` ratified during this design.
10. **Out-of-scope** — explicit list of what this design does NOT cover, with the reason.
11. **Open questions for Researcher** — any decision needing ≥3 enterprise/OSS citation per the binding rule.

**Justification:** Gaps A, B, D, E.

### Revision 3 — Add ADR-writing duty (insert after current "What you write" section)

> ## When to write an ADR
>
> Every non-obvious choice you make — i.e. any decision with a defensible alternative the next architect might revisit — gets an ADR file at `docs/adr/<n>-<slug>.md`. Use the **MADR template** (Context and Problem Statement, Decision Drivers, Considered Options, Decision Outcome, Consequences) per https://adr.github.io/madr/ (verified 2026-04-29). For compact decisions, use a Y-statement: "In the context of X, facing Y, we decided for Z, and neglected W, to achieve A, accepting B." (Zimmermann, https://medium.com/olzzio/y-statements-10eb07b5a177.)
>
> Cited foundation: "Architectural Decisions answer 'why?' questions about design and justify why an option is chosen. Answers to 'why?' questions are as important as anything else in designs." — Zimmermann, https://ozimmer.ch/practices/2020/04/27/ArchitectureDecisionMaking.html (via WebSearch synthesis, verified 2026-04-29).
>
> Link every ADR from the architecture doc's "ADR links" section. Do NOT inline ADR content; the file is the ratified artifact.

**Justification:** Gap C.

### Revision 4 — Replace single multi-tenant bullet with mandatory table (in Hard Rules section, near current line 47)

> **Multi-tenant isolation table is mandatory.** Per AWS Well-Architected SaaS Lens (https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/silo-pool-and-bridge-models.html, verified 2026-04-29), every shared resource in your design must be classified silo / pool / bridge with mechanism + rationale. Cite: "SaaS applications can use three types of isolation: silo, pool, and bridge." For single-tenant projects, the table contains one row reading "pool — only one tenant exists"; the slot still gets filled.

**Justification:** Gap D.

### Revision 5 — Add Depth-by-tier section (insert before Status tokens)

> ## Depth by tier
>
> The CTO tells you the cycle's tier (per `tier-selection` skill). Scale your output:
>
> - **Tier 2:** File List + Data Contracts + Multi-tenant table + ADRs for any non-obvious choice. Sequence View only when concurrency or partial-failure is in scope.
> - **Tier 3:** All sections including Sequence View (≥1 happy + ≥1 degraded path), Quality-attribute matrix, and ADRs for every non-obvious choice.
> - **Tier 1:** You are not dispatched on Tier 1. If the CTO routes a Tier 1 task to you, return `BLOCKED` with reason "Tier 1 — direct execution per cto-mode HARD-GATE exception."
>
> Cited foundation: "Simple fact-finding requires one agent with 3-10 tool calls, direct comparisons need 2-4 subagents with 10-15 calls each, while complex research might use over 10 subagents." — Anthropic, *How we built our multi-agent research system* (Jun 2025). Effort-scaling-by-task-complexity is the precedent for tier-aware architect depth. Plus: "find the simplest solution… only increase complexity when needed" — Anthropic, *Building Effective AI Agents*.

**Justification:** Gap F.

### Revision 6 — Add "Communicate via documents, not dialogue" principle (insert as second paragraph after the introduction)

> You communicate with downstream agents (Researcher, Database Engineer, Security/Compliance, Builder, QA) through the architecture document and the ADRs you write — never through messages relayed via the CTO. Subsequent agents read your files from disk; the CTO does not paraphrase them.
>
> Cited foundation: "Unlike ChatDev, agents in MetaGPT communicate through documents and diagrams (structured outputs) rather than dialogue." — MetaGPT, https://arxiv.org/html/2308.00352v6, §3 (via WebSearch synthesis, verified 2026-04-29). This matches `cto-mode/SKILL.md` line 79 ("Do NOT inline file contents into the prompt — agents read from disk") and SP's `dispatching-parallel-agents` substrate principle.

**Justification:** Gap H.

### Revision 7 — Optional: Reframe "Hard rules" → "Hard rules" + cite per rule

For each existing hard rule, append a citation. Example for "Do not write source code":

> - **Do not write source code.** Implementation is the Builder's job. If the CTO dispatched you, design first; code never. Cited foundation: MetaGPT separates roles such that "the structured PRD is then passed to the Architect, who translates the requirements into system design components… Given the provided file structure and function definitions, an Engineer agent requires only fundamental development skills to complete the development tasks." — MetaGPT §3.

**Justification:** Gap G; brings every rule under the binding citation rule (PF v2 CLAUDE.md).

---

## Citations

**Primary architecture-method sources:**
- C4 Model — https://c4model.com/ (verified 2026-04-29 via WebSearch synthesis)
- C4 Model FAQ — https://c4model.com/faq (verified 2026-04-29)
- arc42 overview — https://arc42.org/overview (verified 2026-04-29)
- arc42 §5 Building Block View — https://docs.arc42.org/section-5/ (verified 2026-04-29)
- arc42 §6 Runtime View — https://docs.arc42.org/section-6/ (verified 2026-04-29)
- arc42 §8 Cross-cutting Concepts — https://docs.arc42.org/section-8/ (verified 2026-04-29)
- MADR — https://adr.github.io/madr/ (verified 2026-04-29)
- MADR template — https://adr.github.io/madr/decisions/adr-template.html (verified 2026-04-29)
- ADR home — https://adr.github.io/ (verified 2026-04-29)
- Y-Statement (Zimmermann) — https://medium.com/olzzio/y-statements-10eb07b5a177 (verified 2026-04-29)
- Architectural Decisions — The Making Of (Zimmermann) — https://ozimmer.ch/practices/2020/04/27/ArchitectureDecisionMaking.html (verified 2026-04-29)

**Multi-tenant SaaS sources:**
- AWS Well-Architected pillars — https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html (verified 2026-04-29)
- AWS Well-Architected — https://aws.amazon.com/architecture/well-architected/ (verified 2026-04-29)
- AWS SaaS Lens silo/pool/bridge — https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/silo-pool-and-bridge-models.html (verified 2026-04-29)
- AWS SaaS Lens silo isolation — https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/silo-isolation.html (verified 2026-04-29)
- AWS SaaS Lens pool isolation — https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/pool-isolation.html (verified 2026-04-29)
- AWS SaaS Lens bridge model — https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/bridge-model.html (verified 2026-04-29)

**Multi-agent precedent (Architect role):**
- MetaGPT (HTML) — https://arxiv.org/html/2308.00352v6 (verified 2026-04-29)
- MetaGPT (PDF) — https://arxiv.org/pdf/2308.00352 (verified 2026-04-29)
- MetaGPT GitHub — https://github.com/FoundationAgents/MetaGPT (referenced; not re-fetched)
- ChatDev (HTML) — https://arxiv.org/html/2307.07924v5 (verified 2026-04-29)
- ChatDev GitHub — https://github.com/OpenBMB/ChatDev (referenced)

**Anthropic guidance:**
- *Building Effective AI Agents* — https://www.anthropic.com/research/building-effective-agents (Dec 19 2024; verified 2026-04-29)
- *How we built our multi-agent research system* — https://www.anthropic.com/engineering/multi-agent-research-system (Jun 2025; verified 2026-04-29)

**Cross-references inside this repo:**
- `docs/research/sp-anthropic-citation-manifest.md` (binding citation source)
- `docs/research/enterprise-multi-agent-architecture.md` (N=7 framework validation, referenced in citation manifest)
- `agents/architect.md` (the file these revisions target)
- `skills/cto-mode/SKILL.md` (dispatch context — Architect listed in 12-agent roster, line 49)
- `CLAUDE.md` (binding rule + file layout incl. `docs/adr/`)

**Methodology disclosure (repeated for emphasis):** WebFetch was permission-denied for this session. All external quotes were retrieved via WebSearch synthesis of the canonical URLs listed above. Quotes are reproduced as returned by WebSearch. Before any binding architectural decision based on these revisions, re-verify the quoted text against the live canonical URL using direct WebFetch in a session where it is permitted.
