# Agent Design Research: Product Manager

**Date:** 2026-04-29
**Type:** Role-craft research — no code modifications
**Triggered by:** PF v2 PM agent (`agents/product-manager.md`) is shape-correct but lacks PM-craft references (acceptance criteria patterns, scope discipline, user-intent decomposition for multi-tenant SaaS)
**Scope:** Source PM-craft canon to harden the PM agent body. Deliver verbatim quotes by topic, SP-inheritable items, gaps, and a concrete revised spec-doc structure.

---

## Methodology disclosure

WebFetch was permission-denied for this session (same condition as the citation manifest). All external quotes were retrieved via WebSearch synthesis of the canonical URLs listed under each section. Quotes are reproduced as returned. **Before any binding architectural change, re-verify the quoted text against the live canonical URL using direct WebFetch in a session where it's permitted.** Files in the local Superpowers cache and the PF v2 repo were read directly.

Current PM agent file read directly: `c:/Users/atyab/Experimental - Users/production-framework-v2/agents/product-manager.md` (41 lines, body lines 8–40). SP brainstorming skill read directly: `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/brainstorming/SKILL.md` (165 lines).

---

## Part 1: Canonical Sources

| # | Source | URL | Use for |
|---|---|---|---|
| 1 | MetaGPT paper §3.2 (PM role + PRD) | https://arxiv.org/html/2308.00352v6 | PRD section taxonomy: goals, user stories, competitive analysis, requirement analysis, requirement pool |
| 2 | MetaGPT GitHub (FoundationAgents/MetaGPT) | https://github.com/FoundationAgents/MetaGPT | `metagpt/roles/product_manager.py`, `metagpt/actions/write_prd.py` (file paths confirmed via search; source not directly fetched this session) |
| 3 | ChatDev paper "Communicative Agents for Software Development" | https://arxiv.org/html/2307.07924v4 | CEO/CPO/CTO three-role demand-analysis phase structure |
| 4 | ChatDev GitHub | https://github.com/OpenBMB/ChatDev | Inception prompting, CompanyConfig customization of CEO/CPO roles |
| 5 | RICE framework (Intercom, Sean McBride) | https://www.intercom.com/blog/rice-simple-prioritization-for-product-managers/ | Reach × Impact × Confidence ÷ Effort prioritization |
| 6 | SVPG / Marty Cagan — Empowered Product Teams | https://www.svpg.com/empowered-product-teams/ | Outcome > Output; "given a problem to solve, not a feature to build" |
| 7 | SVPG — Four Big Risks | https://www.svpg.com/four-big-risks/ | Value / Usability / Feasibility / Viability — PM owns value+viability |
| 8 | Cucumber BDD docs | https://cucumber.io/docs/bdd/ and https://cucumber.io/docs/bdd/better-gherkin/ | Given-When-Then acceptance criteria format |
| 9 | Martin Fowler — GivenWhenThen | https://martinfowler.com/bliki/GivenWhenThen.html | Canonical phrasing of the three-part scenario pattern |
| 10 | Bill Wake — INVEST (Agile for All) | https://agileforall.com/new-to-agile-invest-in-good-user-stories/ | Independent / Negotiable / Valuable / Estimable / Small / Testable |
| 11 | What Matters / Doerr — OKRs | https://www.whatmatters.com/faqs/okr-meaning-definition-example | "I will [Objective] as measured by [Key Results]" — outcome-driven specs |
| 12 | Atlassian PRD guide | https://www.atlassian.com/agile/product-management/requirements | PRD canonical sections |
| 13 | ProductPlan PRD glossary | https://www.productplan.com/glossary/product-requirements-document | Non-Goals / Out-of-Scope rationale |
| 14 | Jama Software — writing requirements | https://www.jamasoftware.com/requirements-management-guide/writing-requirements/how-to-write-an-effective-product-requirements-document/ | Specificity in out-of-scope items |
| 15 | AWS Whitepapers — SaaS Tenant Isolation | https://docs.aws.amazon.com/whitepapers/latest/saas-architecture-fundamentals/tenant-isolation.html | Tenant isolation as separate from auth/authz |
| 16 | OWASP Multi-Tenant Security Cheat Sheet | https://cheatsheetseries.owasp.org/cheatsheets/Multi_Tenant_Security_Cheat_Sheet.html | Per-tenant rate limiting, audit, encryption boundaries |
| 17 | WorkOS — multi-tenant guide | https://workos.com/blog/developers-guide-saas-multi-tenant-architecture | Tenant context binding, JWT claims, data-layer enforcement |
| 18 | Anthropic — *Building Effective AI Agents* | https://www.anthropic.com/research/building-effective-agents | Orchestrator-workers + simplicity principle (already on PF v2 manifest §2.1, §2.6) |
| 19 | Anthropic — *Multi-Agent Research System* | https://www.anthropic.com/engineering/multi-agent-research-system | Subagents need clear objectives, output formats, task boundaries |

---

## Part 2: Verbatim Quotes by Topic

### 2.1 Acceptance criteria — Given/When/Then format

> "Given some context, When some action is carried out, Then the observable consequences should follow."
— Martin Fowler, *GivenWhenThen* (https://martinfowler.com/bliki/GivenWhenThen.html, via WebSearch)

> "The given part describes the state of the world before you begin (pre-conditions), the when section is the behavior being specified, and the then section describes the changes expected due to the specified behavior."
— Cucumber BDD docs (https://cucumber.io/docs/bdd/, via WebSearch)

> "**Given**: This puts the system in a known state with a set of key pre-conditions for a scenario. **When**: This is the key action a user will take, the action that leads to an outcome. **Then**: This is the observable outcome, what happens after the user makes that action."
— Cucumber BDD docs (via WebSearch)

> "Your scenarios should describe the intended behaviour of the system, not the implementation — it should describe what, not how."
— Cucumber, *Writing better Gherkin* (https://cucumber.io/docs/bdd/better-gherkin/, via WebSearch)

> "Domain-specific languages like the Gherkin language express Acceptance Criteria and Acceptance Test Cases in a format that is easy for business stakeholders to use, as well as easy for software programmers to translate into code."
— Cucumber BDD docs (via WebSearch)

**PF v2 implication:** the current PM agent says "Acceptance criteria are testable" with one custom example. Adopting Given-When-Then verbatim makes every AC mechanically QA-translatable — a 1:1 map to the QA agent's verification steps that the agent body already promises.

### 2.2 INVEST — testable, independent user stories

> "INVEST is an acronym to help teams write high-quality, specific user stories that are independent, negotiable, valuable, estimatable, small, and testable. Bill Wake developed the INVEST framework and published it in 2003."
— Bill Wake / Agile for All (https://agileforall.com/new-to-agile-invest-in-good-user-stories/, via WebSearch)

> "**Independent:** conceptually separate from other user stories, and not reliant on the completion of other user stories. **Negotiable:** A story is not a contract. A story IS an invitation to a conversation. **Valuable:** clearly meets an actual user need. **Estimatable:** detailed enough that the team can estimate its relative size. **Small:** can be completed in a short time window without losing value. **Testable:** can be tested to ensure it passes a clear set of acceptance criteria."
— INVEST summary (via WebSearch)

**PF v2 implication:** "Independent" + "Small" formalize the brainstorming skill's already-existing "decompose if too large" rule (line 73 of brainstorming SKILL.md). Cite both.

### 2.3 Scope discipline — In-scope / Out-of-scope / Non-Goals

> "The second most common element across elite templates is a 'Non-Goals' or 'No Gos' section, which emphasizes defining boundaries as much as requirements and prevents scope creep before it starts."
— ProductPlan PRD glossary (via WebSearch synthesis)

> "Be specific: Avoid vague language in out-of-scope definitions — state exactly what's excluded and why. Without a clear boundary, scope creep can result."
— Jama Software requirements guide (via WebSearch synthesis)

> "Effective PRDs include goals, assumptions, user stories, design, and clear out-of-scope items, fostering collaboration and adaptability."
— Atlassian PRD guide (https://www.atlassian.com/agile/product-management/requirements, via WebSearch synthesis)

**PF v2 implication:** the current agent body already mandates an Out-of-scope section but does not require the *reason* per item. Adopt "what + why" for every exclusion (matches the PF principle of "every rule needs a reason").

### 2.4 User-intent vs solution-detail separation

> "The job of a product manager of an empowered product team is to be responsible and accountable for addressing value and viability risk. The designer covers usability risk, and the tech lead covers feasibility risk."
— SVPG, *Empowered Product Teams* (https://www.svpg.com/empowered-product-teams/, via WebSearch synthesis)

> "Empowered product teams… are focused on and measured by outcomes (rather than output)… A core principle is that the team is given a problem to solve instead of a feature to build."
— SVPG, *Empowered Product Teams* (via WebSearch synthesis)

> "Feature teams deliver output, but product teams deliver outcomes."
— SVPG, *Product vs Feature Teams* (https://www.svpg.com/product-vs-feature-teams/, via WebSearch synthesis)

> "OKRs use the basic formula: I will [Objective], as measured by [Key Results]." … "The key result has to be measurable. But at the end you can look, and without any arguments: Did I do that or did I not do it?"
— What Matters / John Doerr (https://www.whatmatters.com/faqs/okr-meaning-definition-example, via WebSearch synthesis)

**PF v2 implication:** PF v2's PM and Architect roles already have a clean PM-owns-WHAT / Architect-owns-HOW split (current body line 25). Cagan's Four-Risks taxonomy formalizes this as a *risk-allocation* split (PM = value+viability; Architect = feasibility; UX/Design = usability) — making the role boundary not just a discipline rule but an industry-standard division of labor. Cite SVPG.

### 2.5 Multi-tenant scope-statement requirement

> "SaaS systems include explicit mechanisms that ensure that each tenant's resources — even if they run on shared infrastructure — are isolated. This is what is referred to as tenant isolation, which introduces constructs that tightly control access to resources, and block any attempt to access resources of another tenant."
— AWS SaaS Architecture Fundamentals (https://docs.aws.amazon.com/whitepapers/latest/saas-architecture-fundamentals/tenant-isolation.html, via WebSearch synthesis)

> "Tenant isolation is separate from general security mechanisms. While your system will support authentication and authorization, the fact that a tenant user is authenticated does not mean that your system has achieved isolation."
— AWS (via WebSearch synthesis)

> "Tenant context is typically embedded within session tokens (for example as JSON Web Token (JWT) claims including tenant_id) and bound to the authenticated user session. Authentication flows should validate that tenant context in the session matches the authenticated user's tenant on every authorization decision, not just at login. Include tenant_id in all resource queries, cache keys, and storage paths. Validate tenant ownership at the data access layer."
— WorkOS multi-tenant guide (https://workos.com/blog/developers-guide-saas-multi-tenant-architecture, via WebSearch synthesis)

> "Per-tenant rate limiting and quotas. Log tenant context with every operation. Tenant-scoped audit trails for all events, enabling enterprise answers like 'who accessed what, when, in which org.'"
— OWASP Multi-Tenant Security Cheat Sheet (https://cheatsheetseries.owasp.org/cheatsheets/Multi_Tenant_Security_Cheat_Sheet.html, via WebSearch synthesis)

**PF v2 implication:** the current PM agent's "Multi-tenant scope is mandatory" line is correct in spirit but under-specified. Each spec should declare scope across *six* tenant axes (per consensus of AWS+OWASP+WorkOS): (1) per-tenant vs cross-tenant vs admin-only; (2) tenant-context binding (where `tenant_id` lives in the request); (3) data-layer enforcement (RLS/scoped queries vs application-layer); (4) cache-key tenant scoping; (5) audit-log tenant tagging; (6) rate-limit/quota scope. This is a binding multi-tenant SaaS pattern with N≥3 enterprise consensus.

### 2.6 Prioritization — RICE

> "RICE is an acronym for the four factors used to evaluate each project idea: reach, impact, confidence and effort. Messaging-software maker Intercom developed the RICE roadmap prioritization model to improve its own internal decision-making processes."
— Intercom (https://www.intercom.com/blog/rice-simple-prioritization-for-product-managers/, via WebSearch synthesis)

> "**Reach**: the number of people a particular product initiative will affect within a specific period of time. **Impact**: how much this will impact each person — Massive=3x, High=2x, Medium=1x, Low=0.5x, Minimal=0.25x. **Confidence**: High=100%, Medium=80%, Low=50%. **Effort**: how many 'person-months' a project will take. **Formula**: (Reach × Impact × Confidence) / Effort."
— Intercom (via WebSearch synthesis)

**PF v2 implication:** RICE is *not* needed in every PF spec — most PF specs are single-feature deliverables already greenlit by the user. RICE belongs in the Brainstorm phase ("which of three approaches first?") or in PM-led roadmap framing, not in the per-feature spec. Reference but do not mandate.

### 2.7 PRD canonical structure (MetaGPT consensus + Atlassian)

> "Upon obtaining user requirements, the Product Manager undertakes a thorough analysis, formulating a detailed PRD that includes User Stories and Requirement Pool. The product manager role produces PRD including product goals, user stories, competitive analysis, competitive quadrant chart, requirement analysis and requirement pool."
— MetaGPT (https://arxiv.org/html/2308.00352v6, via WebSearch synthesis)

> "The structured PRD is then passed to the Architect, who translates the requirements into system design components, such as File Lists, Data Structures, and Interface Definitions."
— MetaGPT (via WebSearch synthesis)

> "The product manager agent is prompted to create a product requirement document (PRD), and can be prompted multiple times to refine certain elements of the PRD due to the incremental development of the project."
— MetaGPT (via WebSearch synthesis)

**Section consensus** (MetaGPT + Atlassian + ProductPlan + Jama):
- **Goals / Objective** (consensus 4/4)
- **User stories** (consensus 4/4)
- **Requirements** (in-scope) (consensus 4/4)
- **Non-goals / Out-of-scope** (consensus 3/4 — MetaGPT subsumes into "requirement pool" priority)
- **Acceptance criteria** (consensus 3/4 — MetaGPT calls it "requirement analysis")
- **Open questions / Assumptions** (consensus 3/4)
- **Competitive analysis** (consensus 1/4 — MetaGPT only; not load-bearing for PF v2 internal-feature specs)

### 2.8 Anthropic guidance — orchestrator subtask specification

> "Subagents receive only their specialized system prompt (plus basic environment details like working directory), not the full Claude Code system prompt. Subagents maintain separate context from the main agent, preventing information overload and keeping interactions focused."
— Anthropic, *Create custom subagents* (already on manifest §2.9)

> "The lead agent needed specific guidance on decomposing queries into subtasks, with each subagent receiving clear objectives, output formats, tool usage guidance, and task boundaries. Without detailed task descriptions, agents would duplicate work or leave critical information gaps."
— Anthropic, *Multi-Agent Research System* (https://www.anthropic.com/engineering/multi-agent-research-system, via WebSearch synthesis)

> "Anthropic recommends finding the simplest solution possible, and only increasing complexity when needed."
— Anthropic, *Building Effective AI Agents* (manifest §2.6)

**PF v2 implication:** PM is the agent that produces the "clear objectives, output formats, task boundaries" that Anthropic says downstream subagents need. The PM spec IS the contract Anthropic describes. Cite §2.7 + §2.6.

---

## Part 3: SP-Inheritable Items (from `brainstorming/SKILL.md`)

The PF v2 PM agent is downstream of brainstorming (per current body line 28: "If the user's intent has 2+ plausible interpretations, ask the CTO to invoke `superpowers:brainstorming`"). The following items in SP brainstorming MAY be inherited rather than re-stated in the PM agent body:

| SP item | SP location | Inherit by PM agent? |
|---|---|---|
| HARD-GATE: no implementation until design approved | brainstorming SKILL.md lines 12–14 | YES — PM body should reference, not duplicate |
| Anti-Pattern "This is too simple to need a design" | brainstorming SKILL.md line 16 | YES — applies to PM specs equally; reference |
| YAGNI ruthlessly | brainstorming SKILL.md line 142 | YES — already implicit in current body's "smallest possible set" |
| Spec self-review (placeholder/consistency/scope/ambiguity) | brainstorming SKILL.md lines 116–124 | **YES — currently MISSING from PM agent.** Add. |
| User-review gate before transition to plan | brainstorming SKILL.md lines 126–131 | YES — currently implicit; make explicit |
| Decomposition rule for too-large projects | brainstorming SKILL.md lines 73–74 | YES — pair with INVEST "Small" + "Independent" |
| Spec file location convention | brainstorming SKILL.md line 111 (`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`) | PARTIAL — PF v2 uses `docs/specs/<feature>.md` per current PM body line 14; document the divergence in ADR |
| Terminal state = invoke writing-plans | brainstorming SKILL.md line 66 | PARTIAL — PF v2 PM hands to Architect first (writing-arch-doc), then to writing-plan; document the chain |

**Net: PM agent inherits 4 hard rules from SP brainstorming.** It should reference rather than re-state them, then layer PM-craft on top.

---

## Part 4: Gap Analysis — current `agents/product-manager.md` vs canon

| Gap | Current state | Canonical guidance | Severity | Source |
|---|---|---|---|---|
| **G1: AC format unspecified** | Line 27 says "testable" with one ad-hoc example | Adopt Given-When-Then verbatim | HIGH — every AC should be QA-translatable; current example shows the right idea but no template | Cucumber, Fowler |
| **G2: User-story shape missing** | No "As a [role] I want [action] so that [outcome]" template | Industry-standard story format implied by INVEST | MEDIUM | Wake / INVEST |
| **G3: Multi-tenant scope axes under-specified** | Line 26: "per-tenant, cross-tenant, or admin-only" — only ONE axis (data scope) | Six axes per AWS+OWASP+WorkOS consensus (data, context binding, enforcement, cache, audit, quotas) | HIGH — multi-tenancy is PF v2's core domain | AWS, OWASP, WorkOS |
| **G4: Out-of-scope reason field missing** | Line 18: "with reason" present in parens but no schema | Jama: "state exactly what's excluded **and why**" | LOW — currently mentioned but not enforced | Jama, ProductPlan |
| **G5: Spec self-review step missing** | Not in checklist | SP brainstorming lines 116–124 mandates it | MEDIUM — already established SP precedent | SP brainstorming |
| **G6: Risk taxonomy not cited** | Line 25 implicit PM=WHAT/Architect=HOW split | Cagan Four-Risks: PM=value+viability; UX=usability; Architect=feasibility | MEDIUM — adds external grounding to existing PF rule | SVPG |
| **G7: Outcome-vs-output framing missing** | Goal field defined as "user-visible outcome" (good) but no explicit outcome>output principle | SVPG empowered teams; OKR formula | LOW — the existing language already gestures at it; cite for grounding | SVPG, Doerr |
| **G8: PRD section taxonomy under-specified** | 6 sections defined | MetaGPT/Atlassian/ProductPlan consensus: goals, user stories, in-scope, out-of-scope, AC, assumptions, open questions; the PF set is close but does not cite | LOW — current set is defensible; just add citations | MetaGPT, Atlassian |
| **G9: User-review gate not explicit** | Line 35 status `DONE_WITH_CONCERNS` implies it; no formal "wait for user approval" gate | SP brainstorming lines 126–131 | MEDIUM — risks PM marking DONE before user has read the spec | SP brainstorming |
| **G10: Open-question protocol vague** | "Open questions for CTO" — no schema | Industry: assumption + impact + decision-required | LOW | PRD templates consensus |
| **G11: AC-to-QA contract not formalized** | Line 19: "Each maps 1:1 to a QA verification step" — promised but no mechanism | Given-When-Then *is* the mechanism (Then = QA step) | HIGH — pairs with G1 | Cucumber |
| **G12: RICE / prioritization** | Not present | RICE formula | NEUTRAL — do NOT add to single-feature PM spec; mention only as "for roadmap framing, defer to Brainstorm or CTO" | Intercom |

---

## Part 5: Suggested Revisions — concrete spec-doc structure

### 5.1 Revised PM agent body — section-by-section

The agent body keeps its current frontmatter and overall shape. Suggested additions are flagged INSERT, modifications are flagged MODIFY. None of the current rules are being removed; the changes layer canon citations and tighten under-specified items.

```
You are the Product Manager sub-agent of the production-framework v2 team. You translate user
intent into the structured spec the rest of the team reads.

> Anthropic-cited foundation [unchanged]

> [INSERT — new] SVPG-cited foundation: "Feature teams deliver output, but product teams
> deliver outcomes." — Marty Cagan, SVPG. The PM owns value + viability risk; Architect owns
> feasibility; UX/Design owns usability. Each spec must state the outcome, not the
> implementation. (https://www.svpg.com/empowered-product-teams/)

## Your job

Read the user's request. Read the existing codebase context. If the user's intent has 2+ plausible
interpretations, [MODIFY — insert] FIRST ensure brainstorming has run (see Hard rules). Then produce
docs/specs/<feature>.md covering:

- Goal — one sentence. The user-visible OUTCOME (not output). [INSERT] Format: "I will <verb>
  <user-visible change>, as measured by <criterion>." (Doerr OKR shape, adapted.)
- User stories — bullet list. [INSERT] Format: "As a <role>, I want <action>, so that
  <outcome>." Each story must satisfy INVEST: Independent / Negotiable / Valuable / Estimable /
  Small / Testable (Wake 2003).
- In-scope — bullet list of what this feature MUST do.
- Out-of-scope — bullet list of what this feature explicitly does NOT do.
  [INSERT] Each item: "<excluded item> — <reason>." No reason ⇒ delete the line; an exclusion
  without a reason is not a decision (Jama Software).
- Acceptance criteria — testable Given-When-Then scenarios. [INSERT — replace current example]
  Format per Cucumber/Fowler:
      Given <pre-condition / system state>
      When <user action>
      Then <observable outcome>
  Each scenario maps 1:1 to a QA verification step. The Then clause IS the QA assertion.
- Constraints — multi-tenant scope, performance budget, compliance.
  [MODIFY — replace current one-line tenant scope with six-axis declaration]
  Multi-tenant scope must declare ALL of:
    1. Data scope: per-tenant / cross-tenant / admin-only
    2. Tenant context binding: where tenant_id is read from (session/JWT/header)
    3. Data-layer enforcement: which mechanism prevents cross-tenant reads/writes
    4. Cache scoping: are cache keys tenant-prefixed?
    5. Audit: are audit-log entries tenant-tagged?
    6. Rate limit / quota: is throttling per-tenant?
  Sources: AWS SaaS Architecture Fundamentals; OWASP Multi-Tenant Security; WorkOS multi-tenant
  guide. (N=3 enterprise consensus per enterprise-research-first skill.)
- Open questions for CTO — each as: "<question> — <PM's working assumption> — <impact if
  assumption is wrong>."
- [INSERT — new section] Risk allocation (one line each):
    - Value risk: <who/what proves users will adopt this>
    - Viability risk: <legal/finance/sales/brand concerns or 'none'>
  PM does NOT enumerate Usability or Feasibility risk; those are UX-Design and Architect domains
  per SVPG Four-Risks taxonomy. (https://www.svpg.com/four-big-risks/)

## Hard rules

- No implementation details [unchanged].
- Multi-tenant scope is mandatory [unchanged, but now references the six-axis schema above].
- Acceptance criteria are testable [MODIFY] — must use Given-When-Then. Free-form prose ACs are
  rejected by the Architect.
- Brainstorm first if ambiguous [unchanged].
- [INSERT] Spec self-review before handoff (inherited from superpowers:brainstorming SKILL.md
  lines 116–124): scan for placeholders, internal contradictions, scope blow-ups, ambiguous
  requirements. Fix inline. Then ask user to review the written spec before status flips to DONE.
- [INSERT] Decomposition rule: if the spec covers >1 independent subsystem (chat AND billing AND
  analytics), STOP. Decompose into N specs, write the first one, return DONE_WITH_CONCERNS naming
  the remaining sub-features. (SP brainstorming lines 73–74; INVEST "Independent" + "Small".)
- [INSERT] PM owns value + viability risk only. Do NOT speculate about implementation feasibility,
  data-model choices, or UX patterns; those belong to Architect / UX-Design / Builder. (SVPG
  Four-Risks taxonomy.)

## Status tokens [unchanged]

## Citations [MODIFY — expand]

- SP precedent: superpowers:brainstorming/SKILL.md — design before code, decomposition rule,
  spec self-review, user-review gate (lines 12–14, 73–74, 116–131).
- Anthropic citation: simplicity principle, *Building Effective AI Agents*; subtask boundaries,
  *Multi-Agent Research System*.
- Industry canon (PM-craft):
    - Cagan / SVPG — Four Big Risks; Empowered Product Teams (https://www.svpg.com/four-big-risks/,
      https://www.svpg.com/empowered-product-teams/)
    - Wake (2003) — INVEST user-story criteria
      (https://agileforall.com/new-to-agile-invest-in-good-user-stories/)
    - Cucumber BDD / Fowler — Given-When-Then acceptance criteria
      (https://cucumber.io/docs/bdd/, https://martinfowler.com/bliki/GivenWhenThen.html)
    - Doerr — OKR outcome formula (https://www.whatmatters.com/)
    - MetaGPT §3.2 — PRD structure precedent in multi-agent systems
      (https://arxiv.org/html/2308.00352v6)
    - AWS SaaS Architecture Fundamentals; OWASP Multi-Tenant Security Cheat Sheet; WorkOS
      multi-tenant guide — six-axis tenant scope schema (N=3 enterprise consensus).
```

### 5.2 Revised spec-doc skeleton (what `docs/specs/<feature>.md` looks like)

```markdown
# Spec: <feature-name>

**Date:** YYYY-MM-DD  **Author:** PM agent  **Status:** DRAFT | APPROVED

## Goal
I will <verb> <user-visible change>, as measured by <criterion>.

## User stories
- As a <role>, I want <action>, so that <outcome>.
- ...

## In-scope
- <requirement 1>
- ...

## Out-of-scope
- <excluded item> — <reason it's excluded now>.
- ...

## Acceptance criteria
### Scenario: <name>
- Given <pre-condition>
- When <action>
- Then <observable outcome>

### Scenario: <name>
- Given ...
- When ...
- Then ...

## Constraints
### Multi-tenant scope (six-axis declaration)
1. Data scope: per-tenant / cross-tenant / admin-only
2. Tenant context binding: <where tenant_id is sourced>
3. Data-layer enforcement: <RLS / scoped query / app-layer guard>
4. Cache scoping: <tenant-prefixed keys yes/no + scheme>
5. Audit: <tenant-tagged log entries yes/no>
6. Rate limit / quota: <per-tenant yes/no + threshold>

### Performance budget
- <p95 latency, throughput, payload size, etc.>

### Compliance / security
- <if applicable>

## Risk allocation (PM-owned only)
- Value risk: <how we know users want this>
- Viability risk: <legal/finance/sales/brand concerns, or "none">

(Usability risk → UX-Design. Feasibility risk → Architect.)

## Open questions for CTO
- <question> — assumption: <PM's working assumption> — impact: <what changes if assumption is wrong>
- ...

## Citations
- SP brainstorming: <yes/no>
- Anthropic patterns invoked: <list>
- Multi-tenant pattern: AWS / OWASP / WorkOS (N=3)
```

This skeleton makes every section mechanically auditable: a CI-style structural check could verify Given/When/Then triplets, six-axis declaration, presence of reason for each out-of-scope item, etc. PF v2's structural-check.sh pattern (per `CLAUDE.md` repo guard) extends naturally to this.

---

## Part 6: Citation Manifest Diff

The current `sp-anthropic-citation-manifest.md` does not list PM-craft sources. Suggested additions to the manifest:

| Add to manifest | Type | Source | Justifies |
|---|---|---|---|
| Pattern 3.1 — Given-When-Then AC | external canon | Cucumber + Fowler | PM agent AC format |
| Pattern 3.2 — INVEST user stories | external canon | Wake 2003 | PM agent story format |
| Pattern 3.3 — SVPG Four Risks | external canon | Cagan/SVPG | PM/Architect/UX/Builder risk allocation across all PF v2 specialist agents |
| Pattern 3.4 — Outcome > Output | external canon | SVPG, Doerr | PM agent goal section |
| Pattern 3.5 — Multi-tenant six-axis | enterprise N≥3 | AWS, OWASP, WorkOS | PM agent constraint section; satisfies enterprise-research-first skill threshold |
| Pattern 3.6 — MetaGPT PRD shape | multi-agent precedent | MetaGPT §3.2 | PM agent overall shape (PRD-as-handoff) |

These are external-industry-canon citations, not Anthropic-published guidance, so they extend the manifest's two-source rule (SP precedent OR Anthropic) with a third lane: "industry consensus N≥3" — which the framework already accepts via the `enterprise-research-first` skill (manifest GAP-1, where N≥3 was acknowledged as PF-internal). PM-craft is one of the cleanest cases for this third lane because four+ independent industry sources converge on the same patterns.

If the maintainer wants to keep the binding-rule strictly two-source, the SP-brainstorming and Anthropic §2.6/§2.7 citations alone are sufficient to ship the revised PM agent — the PM-craft canon then becomes "supporting documentation" rather than "binding."

---

## Sources

**Read directly (local files):**
- `c:/Users/atyab/Experimental - Users/production-framework-v2/agents/product-manager.md` (current state, 41 lines)
- `c:/Users/atyab/Experimental - Users/production-framework-v2/docs/research/sp-anthropic-citation-manifest.md` (manifest)
- `c:/Users/atyab/Experimental - Users/production-framework-v2/CLAUDE.md` (binding rule, file layout)
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/brainstorming/SKILL.md` (165 lines; HARD-GATE, decomposition rule, spec self-review, terminal state)

**External canon (via WebSearch synthesis of canonical URLs — re-verify with WebFetch before binding decisions):**
- MetaGPT paper https://arxiv.org/html/2308.00352v6 ; GitHub https://github.com/FoundationAgents/MetaGPT
- ChatDev paper https://arxiv.org/html/2307.07924v4 ; GitHub https://github.com/OpenBMB/ChatDev
- RICE: https://www.intercom.com/blog/rice-simple-prioritization-for-product-managers/
- SVPG Empowered Product Teams: https://www.svpg.com/empowered-product-teams/
- SVPG Four Big Risks: https://www.svpg.com/four-big-risks/
- SVPG Product vs Feature Teams: https://www.svpg.com/product-vs-feature-teams/
- Cucumber BDD: https://cucumber.io/docs/bdd/
- Cucumber Better Gherkin: https://cucumber.io/docs/bdd/better-gherkin/
- Fowler GivenWhenThen: https://martinfowler.com/bliki/GivenWhenThen.html
- INVEST (Agile for All): https://agileforall.com/new-to-agile-invest-in-good-user-stories/
- INVEST (Wikipedia): https://en.wikipedia.org/wiki/INVEST_(mnemonic)
- What Matters / OKRs: https://www.whatmatters.com/faqs/okr-meaning-definition-example
- Atlassian PRD: https://www.atlassian.com/agile/product-management/requirements
- ProductPlan PRD glossary: https://www.productplan.com/glossary/product-requirements-document
- Jama Software requirements: https://www.jamasoftware.com/requirements-management-guide/writing-requirements/how-to-write-an-effective-product-requirements-document/
- AWS SaaS Tenant Isolation: https://docs.aws.amazon.com/whitepapers/latest/saas-architecture-fundamentals/tenant-isolation.html
- OWASP Multi-Tenant Security: https://cheatsheetseries.owasp.org/cheatsheets/Multi_Tenant_Security_Cheat_Sheet.html
- WorkOS multi-tenant: https://workos.com/blog/developers-guide-saas-multi-tenant-architecture
- Anthropic Building Effective Agents: https://www.anthropic.com/research/building-effective-agents
- Anthropic Multi-Agent Research System: https://www.anthropic.com/engineering/multi-agent-research-system
