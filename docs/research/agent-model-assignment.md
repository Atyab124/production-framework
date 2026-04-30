# Agent Model Assignment — PF v2 Specialist Sub-Agents

**Date:** 2026-04-29
**Type:** Research — no code modifications
**Triggered by:** CTO proposed 9-Opus / 3-Sonnet split; user challenged "Do we really need Opus on all those?" Requires evidence-grounded, cost-justified per-agent model assignment.

---

## Part 1: Anthropic Guidance

### Pricing (verified 2026-04-29 via search)

| Model | Input ($/M tokens) | Output ($/M tokens) | Ratio vs Opus |
|---|---|---|---|
| Claude Opus 4.7 | $15.00 | $75.00 | 1× |
| Claude Sonnet 4.6 | $3.00 | $15.00 | 0.2× (5× cheaper) |
| Claude Haiku 4.5 | $1.00 | $5.00 | 0.067× (15× cheaper) |

Source: Anthropic pricing page — https://docs.anthropic.com/en/docs/about-claude/pricing

### Model capability matrix (Anthropic published guidance)

**Claude Opus 4.7:**
> "Handles complex, long-running tasks with rigor and consistency, pays precise attention to instructions, and devises ways to verify its own outputs before reporting back."
> "Particularly meaningful for complex, long-running coding workflows."
(Source: https://www.anthropic.com/news/claude-opus-4-7)

**Claude Sonnet 4.6:**
Frontier coding model. "Can break down a complex problem into multi-step plans, then orchestrate a team of multiple Haiku 4.5s to complete subtasks in parallel."
(Source: https://www.anthropic.com/news/claude-sonnet-4-5 / search results)

**Claude Haiku 4.5:**
> "Handles complex workflows reliably, self-corrects in real-time, maintains momentum without latency overhead."
Use cases: "Real-time, low-latency tasks like chat assistants, customer service agents, or pair programming."
(Source: https://www.anthropic.com/news/claude-haiku-4-5)

### Anthropic multi-agent architecture — THE binding citation

From *How we built our multi-agent research system* (https://www.anthropic.com/engineering/multi-agent-research-system):

> "A multi-agent system with Claude Opus 4 as the lead agent and Claude Sonnet 4 subagents outperformed single-agent Claude Opus 4 by 90.2% on Anthropic's internal research eval."

Evolution (updated finding):
> "Pairing Claude Opus 4.5 with lightweight Claude Haiku 4.5 subagents yielded a 12.2% improvement over Claude Opus 4.5 alone (87.0% vs. 74.8%). Claude Opus 4.5 achieved 85.4% with Claude Sonnet 4.5 subagents compared to 66.5% with Claude Sonnet 4.5 as orchestrator."

**Critical inference:** Anthropic's own production multi-agent system assigns the **orchestrator** (lead agent) Opus, and **worker subagents** Sonnet or Haiku. In PF v2, the CTO entry session is the orchestrator. The 12 specialist agents are workers. The direct analogy is: PF v2 workers = Sonnet/Haiku, not Opus.

**HOWEVER:** Anthropic's research system uses uniform model assignment across workers. PF v2 workers are heterogeneous in task profile — some perform design/review (closer to orchestrator cognitive load) and some perform template-driven production (true worker load). This heterogeneity is where SP's model selection guidance governs.

### Claude Code subagent model field (Anthropic docs)

From https://docs.anthropic.com/en/docs/claude-code/sub-agents:
> "The `model` field in subagent configuration accepts values of `'sonnet'`, `'opus'`, or `'haiku'`, with `'inherit'` allowing a subagent to use the parent agent's model."

Current state: all 12 PF v2 agents have `model: inherit` — which means they inherit whatever model the user's CTO entry session runs. This gives users control but provides no cost-optimized default.

---

## Part 2: SP Precedent

From `skills/subagent-driven-development/SKILL.md`, lines 87–101 (SP 5.0.7):

```
## Model Selection
Use the least powerful model that can handle each role to conserve cost and increase speed.
Mechanical implementation tasks (isolated functions, clear specs, 1-2 files): use a fast, cheap model.
Integration and judgment tasks (multi-file coordination, pattern matching, debugging): use a standard model.
Architecture, design, and review tasks: use the most capable available model.
Task complexity signals:
- Touches 1-2 files with a complete spec → cheap model
- Touches multiple files with integration concerns → standard model
- Requires design judgment or broad codebase understanding → most capable model
```

**Mapping to Claude model family:**
- "fast, cheap model" = Haiku 4.5
- "standard model" = Sonnet 4.6
- "most capable available model" = Opus 4.7

SP also confirms (SKILL.md line 89): "Use the **least powerful model that can handle each role**" — this is the overriding principle. Bias toward cheaper unless the task profile genuinely requires the upgrade.

---

## Part 3: Per-Agent Task Profile Analysis

### SP tier classification criteria applied to each agent

**Tier 1 — "most capable" (Opus 4.7):** Design judgment, novel architecture, codebase-wide review, high-stakes correctness where errors are not detectable without the model's own reasoning
**Tier 2 — "standard model" (Sonnet 4.6):** Multi-file coordination, integration judgment, debugging, structured synthesis with lateral reasoning
**Tier 3 — "fast, cheap model" (Haiku 4.5):** Template-driven single-concern document production, mechanical implementation with complete spec

---

### Agent-by-agent analysis

#### 1. Architect
**Task profile:** Novel system design, module decomposition, multi-tenant isolation strategy, ADRs, edge case discovery in schema design.
**SP tier:** "Architecture, design, and review tasks: use the most capable available model." (line 95)
**Anthropic analogy:** Orchestrator-level reasoning over the codebase.
**Verdict:** **Opus 4.7**
**Confidence:** HIGH — SP line 95 is direct.

#### 2. Researcher
**Task profile:** N≥3 citation enforcement, cross-source synthesis, consensus-strength evaluation, identifying gaps between project and enterprise patterns. Requires broad lateral reasoning across multiple external sources and project internals simultaneously.
**SP tier:** Design judgment + synthesis = "architecture, design" category by cognitive load.
**Anthropic analogy:** Research lead agent role — Anthropic used Opus for the lead in their own research system.
**Note from agent-design-researcher.md:** Cited sources include Anthropic's own multi-agent research system (Opus as lead agent for synthesis/coordination).
**Verdict:** **Opus 4.7**
**Confidence:** HIGH — synthesis + citation reasoning is the hardest cognitive task in the framework.

#### 3. Builder
**Task profile:** Implements a pre-specified plan in bounded file scope. When the arch doc and plan are well-formed, execution is mechanical file-by-file production.
**SP tier:** "Touches multiple files with integration concerns → standard model." Builder regularly touches 3–10 files per task, requiring integration reasoning even with a complete spec. Pure mechanical tasks (1–2 files) = Haiku; but multi-file integration with ordering constraints = Sonnet.
**Anthropic analogy:** Worker subagent in research system (Sonnet/Haiku).
**Note from agent-design-builder.md:** Builder holds the arch doc + plan + schema — the design work is done. Builder's residual judgment: file ordering, import chains, integration edge cases.
**Verdict:** **Sonnet 4.6**
**Confidence:** HIGH — SP is explicit. "Standard model" for integration tasks.
**CTO's proposal:** Also Sonnet — no change.

#### 4. QA
**Task profile:** Two-stage review: (a) spec compliance against arch doc — line-by-line verification; (b) code quality — pattern adherence, edge case detection, security smell detection across the full changeset.
**SP tier:** SP line 95 explicit: "Architecture, design, and **review tasks**: use the most capable available model."
**Anthropic analogy:** Review is equivalent to design in cognitive demand — requires understanding what *should* be there, not just what *is* there.
**Note from agent-design-qa.md:** Explicitly cites SP line 95 as applying to QA reviews.
**Verdict:** **Opus 4.7**
**Confidence:** HIGH — SP direct cite. QA errors that Sonnet misses ship to production.
**CTO's proposal:** Sonnet — this is a CHANGE. QA review is design-tier cognitive work.

#### 5. Database Engineer
**Task profile:** Schema design, RLS policy authoring, migration sequencing, multi-tenant isolation table structure. Novel design decisions with high correctness stakes (a wrong migration is irreversible in production).
**SP tier:** "Architecture, design" category — schema design is design, not implementation.
**Verdict:** **Opus 4.7**
**Confidence:** HIGH — irreversibility of schema errors makes this Opus-justified independent of SP tier.
**CTO's proposal:** Opus — no change.

#### 6. Security/Compliance
**Task profile:** Audits auth flows, RLS policies, audit trail coverage, multi-tenant boundary enforcement, regulatory compliance checks. High-stakes: missed security gap = breach.
**SP tier:** "Architecture, design, and review tasks" — security audit is the most consequential review in the framework. False negatives cannot be tolerated.
**Verdict:** **Opus 4.7**
**Confidence:** HIGH — risk asymmetry alone justifies Opus. SP review-tier confirms.
**CTO's proposal:** Opus — no change.

#### 7. SRE/DevOps
**Task profile:** Deploy runbook production, SLO/SLI definition, observability checklist, rollback procedure. Follows Google SRE Book patterns (structured templates). Not novel design — applies established templates to project-specific context.
**SP tier:** "Touches multiple files with integration concerns" but the reasoning is template application, not novel design. Standard model.
**Anthropic analogy:** Worker subagent — structured document production.
**Note from agent-design-sre-devops.md:** Agent primarily applies SRE Book Ch. 6/7 patterns to project context. No novel architecture decisions.
**Verdict:** **Sonnet 4.6**
**Confidence:** MEDIUM-HIGH — task is structured/templated but requires integration judgment for environment-specific adaptation.
**CTO's proposal:** Also Sonnet — no change.

#### 8. Code Reviewer
**Task profile:** Plan alignment check + code quality review across the full changeset. Reviews for: pattern adherence, performance anti-patterns, security smells, test coverage gaps, architectural drift.
**SP tier:** SP line 95 explicit: "review tasks: use the most capable available model."
**SP precedent (agent file):** SP's own `code-reviewer.md` has `model: inherit` but SP's SKILL.md says review = most capable.
**Verdict:** **Opus 4.7**
**Confidence:** HIGH — SP direct cite for review tasks. Code Reviewer is the last line of defense before Gate 3.
**CTO's proposal:** Opus — no change.

#### 9. Debugger
**Task profile:** Root cause identification via instrument-first discipline. Reads across multiple files to form hypotheses, traces call paths, analyzes logs. Requires broad codebase understanding but the work is investigative/diagnostic, not design.
**SP tier:** "Integration and judgment tasks (multi-file coordination, pattern matching, debugging): use a standard model." SP line 93 **names debugging explicitly** as standard-model tier.
**Anthropic analogy:** Worker subagent performing multi-file investigation.
**Note from agent-design-debugger.md:** Debugger's cognitive work is hypothesis formation + evidence collection. Not novel architecture. Complex intermittent bugs still fit Sonnet — the instrument-first discipline compensates for model capability with structured process.
**Verdict:** **Sonnet 4.6**
**Confidence:** HIGH — SP line 93 names debugging as standard-model work.
**CTO's proposal:** Opus — this is a CHANGE. Debugger moves Opus→Sonnet. SP explicitly names debugging as Tier 2.

#### 10. Post-Mortem
**Task profile:** Structured blameless post-mortem document production following SRE Book Ch. 15 patterns. Five-whys, timeline reconstruction, action items. Template-driven. Runs after a fix has already shipped.
**SP tier:** The document structure is established (SRE Book). Content is drawn from the incident context. This is "touches 1-2 files with a complete spec" territory — the spec is the incident record and the template.
**Anthropic analogy:** Worker subagent for structured document production.
**Note from agent-design-post-mortem.md:** Agent produces a bounded document with well-defined sections. Does not make novel architecture decisions.
**Verdict:** **Sonnet 4.6**
**Confidence:** HIGH — template-driven document production. No SP evidence for most-capable model here.
**CTO's proposal:** Opus — this is a CHANGE. Post-Mortem moves Opus→Sonnet. Document production from template = standard-model task.

#### 11. UX/Design
**Task profile:** Produces design doc with state matrices, multi-tenant boundary states, IA, user journey maps. Structured document production from a feature spec, drawing on established UX patterns.
**SP tier:** Document production from spec = integration/judgment work (multi-tenant state matrices require reasoning across component boundaries). Standard model.
**Note from agent-design-ux-design.md:** Agent primarily applies WCAG, Nielsen heuristics, and multi-tenant UX patterns to produce structured documentation. Novel design judgment is minimal — mostly application of established patterns.
**Verdict:** **Sonnet 4.6**
**Confidence:** MEDIUM-HIGH — structured UX doc production with established patterns. The multi-tenant boundary state reasoning adds some judgment complexity but does not cross into Opus territory.
**CTO's proposal:** Also Sonnet — no change.

#### 12. Product Manager
**Task profile:** Translates user intent into structured spec (Given-When-Then ACs, six-axis multi-tenant scope, feature vs. bug classification). Requires scoping judgment but operates within a structured template.
**SP tier:** "Integration and judgment tasks" — translating user intent involves judgment, but the output structure is fixed (ACs template, scope axes). Standard model.
**Note from agent-design-product-manager.md:** Agent's value is structured decomposition, not novel design. The six-axis multi-tenant scope is a template PF provides. PM applies it.
**Verdict:** **Sonnet 4.6**
**Confidence:** MEDIUM-HIGH — scoping judgment is real but template-bounded.
**CTO's proposal:** Opus — this is a CHANGE. Product Manager moves Opus→Sonnet. Structured spec production with template = standard-model work.

---

## Part 4: Comparison Table

| Agent | CTO Proposed | Evidence-Based | Change | SP Tier | Key Justification |
|---|---|---|---|---|---|
| Architect | Opus | **Opus 4.7** | — | Design | SP line 95 direct |
| Researcher | Opus | **Opus 4.7** | — | Design/synthesis | Lead agent analogy; N≥3 synthesis |
| Builder | Sonnet | **Sonnet 4.6** | — | Integration | SP line 93 direct |
| QA | Sonnet | **Opus 4.7** | ↑ Sonnet→Opus | Review | SP line 95: review = most capable |
| Database Engineer | Opus | **Opus 4.7** | — | Design | Irreversibility + SP design tier |
| Security/Compliance | Opus | **Opus 4.7** | — | Review | Risk asymmetry + SP review tier |
| SRE/DevOps | Sonnet | **Sonnet 4.6** | — | Integration | Template-driven; SP standard model |
| Code Reviewer | Opus | **Opus 4.7** | — | Review | SP line 95 direct |
| Debugger | Opus | **Sonnet 4.6** | ↓ Opus→Sonnet | Debugging | SP line 93 names debugging explicitly |
| Post-Mortem | Opus | **Sonnet 4.6** | ↓ Opus→Sonnet | Template doc | SRE Book template; no novel design |
| UX/Design | Sonnet | **Sonnet 4.6** | — | Integration | Established pattern application |
| Product Manager | Opus | **Sonnet 4.6** | ↓ Opus→Sonnet | Structured spec | Template-bounded scoping |

**Net split:**
- CTO proposed: 9 Opus / 3 Sonnet / 0 Haiku
- Evidence-based: **7 Opus / 5 Sonnet / 0 Haiku**
- Net change: 2 agents move Opus→Sonnet (Debugger, Post-Mortem, Product Manager = 3), 1 agent moves Sonnet→Opus (QA = 1). Net: −2 Opus.

---

## Part 5: Cost Delta Per Cycle

### Assumptions for one typical Tier 2 cycle:
- Average tokens per agent invocation: ~8,000 input + ~3,000 output = ~11,000 tokens total
- Each agent fires once per cycle
- 12 agents total

### CTO proposed (9 Opus / 3 Sonnet):
- Opus cost per invocation: (8,000 × $15 + 3,000 × $75) / 1,000,000 = ($0.12 + $0.225) = **$0.345**
- Sonnet cost per invocation: (8,000 × $3 + 3,000 × $15) / 1,000,000 = ($0.024 + $0.045) = **$0.069**
- Total: (9 × $0.345) + (3 × $0.069) = $3.105 + $0.207 = **$3.312 per cycle**

### Evidence-based (7 Opus / 5 Sonnet):
- Total: (7 × $0.345) + (5 × $0.069) = $2.415 + $0.345 = **$2.760 per cycle**

### Savings: $3.312 − $2.760 = **$0.552 per cycle (~17% reduction)**

At 10 cycles/day: $5.52/day savings. At 300 cycles/month: $165.60/month savings.

**The QA upgrade (Sonnet→Opus) costs an additional $0.276/cycle but is mandatory per SP line 95 — review tasks require most capable model. The three downgrades (Debugger + Post-Mortem + PM: 3 × $0.276 saved) = $0.828 saved, minus QA upgrade $0.276 = net $0.552 savings.**

---

## Part 6: Haiku Rationale (Why 0 Agents)

Haiku is appropriate for "mechanical implementation tasks (isolated functions, clear specs, 1-2 files)" per SP. No PF v2 agent is purely mechanical from start to finish:
- Builder is the closest candidate but regularly handles multi-file integration with ordering constraints (Sonnet tier per SP).
- Post-Mortem is template-driven but the timeline reconstruction and five-whys reasoning across an incident context is not mechanical.
- Haiku's "real-time, low-latency" use case (Anthropic docs) does not map to any PF v2 specialist agent role.

**Haiku is appropriate for sub-tasks within agents** (e.g., a Builder sub-dispatch for a simple utility file). Not recommended at the agent level.

---

## Part 7: Recommendations

### Immediate changes to agent frontmatter

Replace `model: inherit` with explicit assignments in each agent file:

| File | New value |
|---|---|
| `agents/architect.md` | `model: opus` |
| `agents/researcher.md` | `model: opus` |
| `agents/builder.md` | `model: sonnet` |
| `agents/qa.md` | `model: opus` |
| `agents/database-engineer.md` | `model: opus` |
| `agents/security-compliance.md` | `model: opus` |
| `agents/sre-devops.md` | `model: sonnet` |
| `agents/code-reviewer.md` | `model: opus` |
| `agents/debugger.md` | `model: sonnet` |
| `agents/post-mortem.md` | `model: sonnet` |
| `agents/ux-design.md` | `model: sonnet` |
| `agents/product-manager.md` | `model: sonnet` |

### Citation manifest update required

Per CLAUDE.md binding rule: this model assignment must map to a row in `docs/research/sp-anthropic-citation-manifest.md` citing:
1. SP `skills/subagent-driven-development/SKILL.md` lines 87–101 (tier classification)
2. Anthropic multi-agent research system article (Opus orchestrator / Sonnet workers pattern)

### Override guidance for `model: inherit`

The current `model: inherit` behavior is not wrong — it gives users control. The recommended path is:
- Set explicit defaults in frontmatter (table above)
- Document that users can override per-agent in their project's `AGENTS.md` or agent config
- The `inherit` value remains available for users who want all agents to track the session model (useful for users who are already on a specific tier)

---

## Sources

1. SP `skills/subagent-driven-development/SKILL.md` lines 87–101 — model selection tiers (file read, verified)
2. SP `agents/code-reviewer.md` — `model: inherit` (file read, verified)
3. All 12 `docs/research/agent-design-*.md` files — task profile per agent (file reads, verified)
4. All 12 `agents/*.md` files — current `model: inherit` state (file reads, verified)
5. Anthropic pricing: https://docs.anthropic.com/en/docs/about-claude/pricing — Opus $15/$75, Sonnet $3/$15, Haiku $1/$5 per million tokens
6. Anthropic multi-agent research system: https://www.anthropic.com/engineering/multi-agent-research-system — "Opus 4 lead agent, Sonnet 4 subagents outperformed single-agent Opus 4 by 90.2%"
7. Anthropic Haiku 4.5 announcement: https://www.anthropic.com/news/claude-haiku-4-5 — "real-time, low-latency tasks" use case
8. Anthropic Opus 4.7 announcement: https://www.anthropic.com/news/claude-opus-4-7 — "complex, long-running tasks with rigor and consistency"
9. Claude Code subagents docs: https://docs.anthropic.com/en/docs/claude-code/sub-agents — model field accepts "opus"/"sonnet"/"haiku"/"inherit"
