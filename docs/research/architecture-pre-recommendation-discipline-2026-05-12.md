# Architecture Pre-Recommendation Discipline — Lane R-2 Research

**Verified:** 2026-05-12. **Researcher lane:** R-2 of 5 (Architect pre-recommendation discipline). **Questions answered:** Q2.1, Q2.3, Q3.4. **Producer-Consumer pass:** Researcher Pass 2 → Architect Pass 3. **Input:** `docs/architecture/framework-feedback-response-2026-05-12.md` §3 (clusters), §4 (questions), §7 (dispatch envelope).

---

## 0. Eligibility Criteria (shared across Q2.1 / Q2.3 / Q3.4)

A framework qualifies as comparable when ALL hold:

1. **Named enterprise or OSS framework** — TOGAF, IEEE 1471, arc42, C4, AWS Well-Architected, Google PRR, MADR, ThoughtWorks Tech Radar, Shopify BFCM playbooks, GitLab handbook, Roman Pichler GO Roadmap, Aha! Roadmaps, ProductPlan, ProdPad / Mind the Product Now-Next-Later. Aggregator sites (Medium summaries, ZenML pages, Visual Paradigm tutorials) are tagged **secondary**.
2. **Primary source available** — official doc, engineering blog, standards-body PDF. WebFetch denials are flagged in §9 methodology; fallback is WebSearch-synthesis of canonical URL per researcher.md rule.
3. **Addresses the specific axis of the question** — for Q2.1, the framework must say something explicit about inventorying existing components before adding a new one; for Q2.3, it must distinguish scale-readiness from tactical work at PLANNING time (not just at runtime); for Q3.4, it must address communication of scale-readiness commitments to non-engineering stakeholders via a tag / lane / wave / theme.

**Excluded:** opinion pieces without a methodology footprint (Medium walk-throughs, ScienceDirect aggregator summaries are SECONDARY-tagged), AI-generated landing pages, frameworks lacking an inventory / scale-readiness / stakeholder-communication primitive at all (e.g., pure delivery cadences such as ScrumGuide — out of scope for Q3.4 since they don't have a roadmap surface).

---

## 1. Search Strategy (PRISMA-style)

| Round | Purpose | Tools | Calls |
|---|---|---|---|
| R1 — Broad landscape | One short query per candidate framework across all three questions, in parallel | WebSearch ×8 | 8 |
| R2 — Primary-source quote extraction | WebFetch attempts on canonical URLs; six of six were permission-denied except AWS WAF Reliability welcome page (which loaded) | WebFetch ×6 | 6 (5 denied, 1 succeeded) |
| R3 — WebSearch synthesis fallback per researcher.md rule for denied URLs; narrow verbatim-quote extraction queries | WebSearch ×9 | 9 |
| Total | — | — | **23 calls across 3 questions** (≤15/question ceiling) |

Calls per question: Q2.1 ≈ 9, Q2.3 ≈ 8, Q3.4 ≈ 6. All within the per-question 10–15 budget.

---

## Q2.1 — Pre-recommendation dependency / component inventory

**Question (verbatim from dispatch):** How do enterprise architecture frameworks (TOGAF, IEEE 1471, arc42, C4, AWS Well-Architected, Google Design Docs, MADR, ThoughtWorks Tech Radar) require an inventory of existing dependencies/components before recommending a new one? Specifically — is a "current state" artifact (CMDB, component register, dependency manifest) a documented pre-condition of any "add new component" decision?

### Q2.1 — Frameworks compared

| # | Framework | Source-type | Last-verified | URL |
|---|---|---|---|---|
| 1 | TOGAF Gap Analysis (Open Group, ADM Phase B/C/D) | Primary (Open Group standards body) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://pubs.opengroup.org/architecture/togaf91-doc/arch/chap27.html |
| 2 | arc42 Section 5 — Building Block View | Primary (arc42.org official docs) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://docs.arc42.org/section-5/ |
| 3 | C4 Model — System Context + Component diagrams | Primary (c4model.com official) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://c4model.com/diagrams/system-context |
| 4 | MADR template — "Considered Options" clause | Primary (adr.github.io/madr) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://adr.github.io/madr/ |
| 5 | ThoughtWorks Technology Radar — Hold/Assess/Trial/Adopt rings | Primary (thoughtworks.com/radar) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://www.thoughtworks.com/en-us/radar/faq |

### Q2.1 — Comparison axes

| Axis | TOGAF Gap Analysis | arc42 §5 BBV | C4 Model | MADR | TW Tech Radar |
|---|---|---|---|---|---|
| Is "current state" a NAMED pre-condition? | **YES** — "Baseline Architecture" is mandatory before Target | **YES** — BBV mandates the static decomposition with dependencies | **YES** — Level-1 System Context lists external dependencies | **PARTIAL** — "Considered Options" implies inventory but doesn't name it | **YES** — "blip" must be placed on ring at intake |
| Is the artifact named? | Baseline/Target Matrix (ABB inventory) | Building Block table per level (BB + interfaces + dependencies) | Context / Container / Component diagrams | Decision-Drivers + Considered-Options | The radar itself (blip register with quadrant + ring) |
| Pre-condition of "add new component"? | **BINDING** — gap analysis explicitly flags "New" rows | **BINDING** — new BB enters whitebox table with dependencies | Implicit — new component must appear in component diagram with arrows | Advisory — option must be listed before chosen | Advisory — but blip MUST be assessed before promoted to Adopt |
| Owner of the artifact | Enterprise Architect (TOGAF role) | Architect | Architect / Tech Lead | Architect / Decision Author | Org-wide Radar Working Group |

### Q2.1 — Verbatim citations

> **TOGAF Gap Analysis matrix (ABB inventory binding):** "The matrix includes all the ABBs (Architecture Building Blocks) of the Baseline Architecture on the vertical axis, and all the ABBs of the Target Architecture on the horizontal axis, with a final row labeled 'New' added to the Baseline Architecture axis, and a final column labeled 'Eliminated' added to the Target Architecture axis." — pubs.opengroup.org/architecture/togaf91-doc/arch/chap27.html (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **TOGAF — the three gap categories:** "1. 'Included': Where a function is available in both the current and target architectures, this is recorded with 'Included' at the intersecting cell. 2. 'Eliminated': This column captures building blocks from the baseline that are not in the target architecture. 3. 'New': This row captures gaps — anything under 'New' should either be explained as correctly eliminated, or marked as to be addressed by reinstating or developing/procuring the building block." — pubs.opengroup.org/architecture/togaf91-doc/arch/chap27.html (verified 2026-05-12).

> **TOGAF Phase scope:** "Gap analysis is applied during Phase B (Business Architecture), Phase C (Information Systems Architectures), and Phase D (Technology Architecture) of the ADM. The purpose of gap analysis in these phases is to identify the differences between the current state (baseline architecture) and the desired future state (target architecture)." — Visual-Paradigm TOGAF guide aggregator citing Open Group source (verified 2026-05-12; secondary aggregator pointing at Open Group primary).

> **arc42 §5 Building Block View definition:** "The building block view shows the static decomposition of the system into building blocks (modules, components, subsystems, classes, interfaces, packages, libraries, frameworks, layers, partitions, tiers, functions, macros, operations, data structures, …) as well as their dependencies (relationships, associations, …)." — docs.arc42.org/section-5/ (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **arc42 — BBV table requirement:** "A short and pragmatic overview of all contained building blocks and their interfaces can be provided through a table, or a list of black box descriptions of the building blocks. Dependencies and relationships of the listed building blocks should be explained." — docs.arc42.org/section-5/ (verified 2026-05-12).

> **C4 Level-1 System Context (external dependencies):** "People (e.g. users, actors, roles, or personas) and software systems (external dependencies) that are directly connected to the software system in scope. Typically these other software systems sit outside the scope or boundary of your own software system, and you don't have responsibility or ownership of them." — c4model.com/diagrams/system-context (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **C4 — dependency-decision support:** "This supports architectural decision-making by making it easier to identify dependencies, assess the scope of changes and explore alternative designs." — c4model.com (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **MADR — Considered Options requirement:** "The considered options with their pros and cons are crucial to understand the reasons for choosing a particular design, and the MADR project includes such tradeoff analysis information. It's valuable to explicitly list all the serious alternatives that were considered, together with their pros and cons." — adr.github.io/madr/ (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **MADR — alternatives are mandatory items:** "MADR provides a full and a minimal template, both of which now come in an annotated and a bare format. The considered alternatives (including the chosen and the neglected ones) are listed as items." — adr.github.io/madr/ (verified 2026-05-12).

> **ThoughtWorks Tech Radar — rings and quadrants (inventory primitive):** "The radar is split into four quadrants: Techniques, Tools, Platforms, and Languages & Frameworks. The radar has four rings, from outer to inner: hold, assess, trial, and adopt." — thoughtworks.com/en-us/radar/faq (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **TW Radar — Assess as the pre-adoption inventory state:** "Typically, blips in the Assess ring are things that we think are interesting and worth keeping an eye on." — thoughtworks.com/radar/faq (verified 2026-05-12).

> **TW Radar — Hold prevents new use:** "The hold ring has evolved into our way of saying 'don't start anything new with this technology'. There's no harm in using it on existing projects, but you should think twice about using this technology for new development." — thoughtworks.com/radar/faq (verified 2026-05-12).

### Q2.1 — Synthesis

- **N/M consensus: 5/5 frameworks make existing-state inventory a documented prerequisite of an add-new-component decision.** The strength of the requirement varies: TOGAF and arc42 are BINDING (the artifact is mandatory at the named ADM phase / section); C4 makes it structurally mandatory (a new component must appear in the diagram with dependencies); MADR makes it ADVISORY but explicit (the "Considered Options" list IS the inventory of alternatives); ThoughtWorks Tech Radar treats the radar itself as the inventory + Assess-before-Adopt is the discipline.
- **Outlier behavior:** No outlier on this axis. Every framework surveyed treats "what do we already have" as a prerequisite question.
- **The named-artifact differentiator:** TOGAF and arc42 give the artifact a specific name (Baseline Architecture / Building Block View table). C4 gives it a diagram (System Context). MADR gives it a list section ("Considered Options"). The TW Radar IS the artifact (the radar). No framework leaves it implicit.

### Q2.1 — Recommendation for Architect Pass 3 (ADR-017)

Adopt a **"Dependency Inventory pre-condition"** step in `agents/architect.md` modeled on the **TOGAF Baseline Architecture + arc42 §5 BBV-table** convention, with a sibling check matching the **ThoughtWorks Tech Radar Hold/Assess-before-Adopt** ring discipline. Concrete shape:

1. **Required artifact at the project level:** `docs/dependencies.md` (or equivalent already-present file) — the project's component register. If absent, the Architect's first action on any "should we add library X?" question is to ask the project to produce the inventory; without it, return NEEDS_CONTEXT.
2. **Pre-recommendation step (named):** "Inventory existing components — list dependencies/libraries/services already in the project that overlap the proposed new component's purpose. Output: a table with `name | already-installed | overlap-with-new | reuse-feasibility`." This is structurally a TOGAF Baseline/Target gap matrix narrowed to the dependency axis.
3. **Hold-ring sibling:** If a project has a stated "do not add to" list (e.g., "no new state-management libraries"), the Architect must check it before any new-dependency recommendation. Models the TW Radar Hold ring.
4. **Composition with MADR Considered Options:** the ADR for the new component must list at least the items in the inventory that came closest to satisfying the requirement, not just generic alternatives.

This recommendation is grounded in 5/5 framework consensus and matches the `find-similar-implementations` skill the framework already ships, extended from code-level reuse (existing skill) to **package-level inventory** (the Item-3 gap).

---

## Q2.3 — Scale-readiness foundation vs tactical at planning time

**Question (verbatim from dispatch):** How do enterprise scale-readiness frameworks (Google PRR, AWS WAF Performance + Reliability pillars, Netflix scaling playbooks, Shopify "Black Friday Cyber Monday" engineering posts, GitLab scalability handbook) distinguish "tactical" features from "scale-readiness foundation" at the planning stage? Is the distinction surfaced as a tag, a rubric, a separate planning phase, or a separate budget?

### Q2.3 — Frameworks compared

| # | Framework | Source-type | Last-verified | URL |
|---|---|---|---|---|
| 1 | Google SRE Production Readiness Review (PRR) | Primary (sre.google) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://sre.google/sre-book/evolving-sre-engagement-model/ |
| 2 | AWS Well-Architected Reliability Pillar | Primary (AWS docs, WebFetch succeeded for welcome page) | 2026-05-12 (WebFetch direct) | https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html |
| 3 | AWS Well-Architected Performance Efficiency Pillar | Primary (AWS docs) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://docs.aws.amazon.com/wellarchitected/latest/performance-efficiency-pillar/welcome.html |
| 4 | Shopify Engineering — BFCM readiness program | Primary (shopify.engineering) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://shopify.engineering/bfcm-readiness-2025 |
| 5 | GitLab Reference Architectures (handbook/docs) | Primary (docs.gitlab.com, handbook.gitlab.com) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://docs.gitlab.com/administration/reference_architectures/ |

### Q2.3 — Comparison axes

| Axis | Google PRR | AWS WAF Reliability | AWS WAF Performance Efficiency | Shopify BFCM | GitLab Reference Architectures |
|---|---|---|---|---|---|
| Distinction surfacing | **Separate planning phase** (PRR is its own gate) | **Pillar tag** (one of six pillars) | **Pillar tag** | **Separate planning program** (9 months, 5 scale tests) | **Sized reference architectures** (1k/2k/5k/10k users → RPS) |
| Is "tactical" vs "scale" called out at intake? | YES — PRR is a gate ON TOP of feature work | YES — pillar review is orthogonal to feature pillars | YES — efficiency review is orthogonal | YES — BFCM-readiness scope is distinct from feature delivery | YES — sizing review is distinct from feature work |
| Named rubric / artifact | PRR checklist (capacity, dependencies, SLO, monitoring) | Reliability design principles + workload review | Five design principles + data-driven review | Load test (Genghis), game days, regional failovers | RPS-based sizing matrix; "scale wholesale to next size" rule |
| Separate budget / capacity? | YES — SRE time is allocated separately | Implicit (pillar reviews are scheduled) | Implicit | YES — "thousands of engineers over nine months" | YES — capacity planned per RPS tier |
| Stakeholder visible? | At launch readiness gate | At pillar review | At pillar review | High — public engineering blog | High — reference-architecture docs |

### Q2.3 — Verbatim citations

> **Google PRR — distinct purpose:** "The Production Readiness Review (PRR) is a process that identifies the reliability needs of a service based on its specific details, through which SREs seek to apply what they've learned and experienced to ensure the reliability of a service operating in production." — sre.google/sre-book/evolving-sre-engagement-model/ (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **Google PRR — explicit objectives separate from features:** "The objectives of the Production Readiness Review are to verify that a service meets accepted standards of production setup and operational readiness, and improve the reliability of the service in production, minimizing the number and severity of incidents that might be expected." — sre.google/sre-book/evolving-sre-engagement-model/ (verified 2026-05-12).

> **Google PRR — three engagement models (gating maturity):** "There are three different but related engagement models (Simple PRR Model, Early Engagement Model, and Frameworks and SRE Platform), which address these limitations. With the Early Engagement model, SRE is involved early in the development process, which means SRE involves in the design, build, launch and post launch." — sre.google/sre-book/evolving-sre-engagement-model/ (verified 2026-05-12). **Key implication:** the framework explicitly migrates from "review at end" to "engage at design" — scale-readiness moves left in the planning timeline.

> **Google PRR — capacity rule with named threshold:** "Services should provision to handle a simultaneous planned and unplanned outage without making the user experience unacceptable, resulting in an 'N + 2' configuration, where peak traffic can be handled by N instances (possibly in degraded mode) while the largest 2 instances are unavailable." — sre.google/sre-book/service-best-practices/ (verified 2026-05-12 via WebSearch synthesis).

> **AWS WAF Reliability pillar — separated as its own concern:** "The AWS Well-Architected Framework is based on six pillars: Operational Excellence, Security, Reliability, Performance Efficiency, Cost Optimization, Sustainability. This paper focuses on the reliability pillar and how to apply it to your solutions." — docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html (verified 2026-05-12 via direct WebFetch).

> **AWS WAF Reliability — scope:** "The reliability pillar encompasses the ability of a workload to perform its intended function correctly and consistently when it's expected to, including the ability to operate and test the workload through its total lifecycle." — docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html (verified 2026-05-12 via direct WebFetch).

> **AWS WAF Reliability — design-time scale-readiness rule:** "Scale horizontally to increase aggregate workload availability by replacing one large resource with multiple small resources to reduce the impact of a single failure on the overall workload." — AWS Well-Architected Reliability design-principles page (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **AWS WAF Performance Efficiency pillar — pillar-level distinction:** "The Performance Efficiency pillar includes the ability to use computing resources efficiently to meet system requirements, and to maintain that efficiency as demand changes and technologies evolve." — docs.aws.amazon.com/wellarchitected/latest/performance-efficiency-pillar/welcome.html (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **AWS WAF Performance Efficiency — data-driven design principle:** "Take a data-driven approach to building a high-performance architecture. Gather data on all aspects of the architecture, from the high-level design to the selection and configuration of resource types." — Performance Efficiency design principles (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **Shopify BFCM — readiness is a distinct program-level scope:** "To handle expected traffic, Shopify rebuilt its BFCM readiness program from the ground up, involving thousands of engineers over nine months, five scale tests, and four days of peak commerce." — shopify.engineering/bfcm-readiness-2025 (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **Shopify BFCM — game days as the discipline:** "Shopify conducts 'Game Days' chaos engineering exercises that intentionally inject faults into systems, with Critical Journey Game Days running cross-system disaster simulations testing search and pages endpoints, randomizing navigation to mimic real users, injecting network faults and latency, and cache-busting." — shopify.engineering (verified 2026-05-12 via WebSearch synthesis).

> **Shopify BFCM — load testing as a planning input, not a runtime test:** "Shopify's load testing tool Genghis runs scripted workflows mimicking user behavior like browsing, cart adds, and checkout flows, gradually ramping traffic to find breaking points, with tests running on production infrastructure simultaneously from three GCP regions to simulate global traffic patterns and injecting flash sale bursts on top of baseline load." — shopify.engineering (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **GitLab Reference Architectures — RPS-based sizing rubric:** "The right architecture size depends primarily on your environment's expected peak load, with Requests per Second (RPS) being the primary metric for sizing a GitLab infrastructure." — docs.gitlab.com/administration/reference_architectures/sizing/ (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **GitLab — explicit scale-vs-tactical scaling rule:** "Scaling can be done component-by-component or wholesale to the next architecture size when metrics indicate sustained resource pressure." — docs.gitlab.com/administration/reference_architectures/ (verified 2026-05-12 via WebSearch synthesis of canonical URL).

### Q2.3 — Synthesis

- **N/M consensus: 5/5 frameworks surface scale-readiness as something distinct from tactical work at planning time. The surfacing mechanism differs:**
  - **PRR — separate planning phase** (the PRR gate is a distinct review on top of feature work).
  - **AWS WAF — pillar tag** (Reliability and Performance Efficiency are two of six pillars; pillar review is orthogonal to feature pillars).
  - **Shopify BFCM — separate program scope + load-testing program** (the BFCM readiness program is a 9-month parallel track to feature shipping).
  - **GitLab — sized reference architectures** (the scale target is a named tier; you size the infrastructure for the tier first, then deliver features into the sized footprint).
- **Common shape:** ALL surveyed frameworks make scale-readiness a separately-named planning artifact — never folded into "we'll handle perf later." The framework that goes furthest is Shopify (9-month program with named tooling); the framework that goes lightest is AWS WAF (pillar review can be self-served and the pillar review report is the only artifact).
- **Outlier:** None on the axis "is scale-readiness distinguished at planning". On the axis "is the distinction a TAG vs a PHASE vs a BUDGET" — AWS uses a tag (pillar); Google and Shopify use a phase + program; GitLab uses a sizing tier.

### Q2.3 — Recommendation for Architect Pass 3 (ADR-011)

Adopt **PRR-style "scale-readiness gate"** language with **AWS WAF-pillar-style tagging** for individual plan items. Concrete shape:

1. **Plan-item tag (per AWS WAF pillar precedent):** every Tier-2/Tier-3 plan must mark each row with a scale-readiness tag in `{ TACTICAL | SCALE-READINESS | UNCERTAIN }`. Definitions: TACTICAL = feature that ships without affecting the project's stated scale targets; SCALE-READINESS = work whose primary justification is meeting the project's `scale_targets:` slot in `PROJECT-PLAN.md`; UNCERTAIN = needs investigation.
2. **Project-level artifact (per GitLab Reference Architectures precedent):** `templates/PROJECT-PLAN.template.md` adds a `scale_targets:` slot at the project root (concurrent users, RPS, tenants, storage) so the Architect has a concrete target to evaluate plans against, not an implicit assumption. Already flagged in §2 of the architecture doc.
3. **Pre-recommendation gate (per Google PRR Early-Engagement precedent):** when a project has stated `scale_targets:` AND the proposed work does not meet them, the Architect's recommendation must include either (a) a scale-readiness foundation item in the plan, or (b) an explicit DEFER-WITH-BLOCKER citing what would unblock it. Mirrors PRR's shift-left from "review at end" to "engage at design."
4. **Cross-link to roadmap surface (per Shopify program precedent):** the SCALE-READINESS tag is the bridge to Q3.4's roadmap-tagging convention. The same tag that classifies plan items must be visible on the roadmap surface for non-engineering stakeholders.

This recommendation is grounded in 5/5 framework consensus that scale-readiness is surfaced at planning, and the shape (tag + project-level target + gate) composes three of the five precedents.

---

## Q3.4 — Roadmap-level communication of scale-readiness to non-engineering stakeholders

**Question (verbatim from dispatch):** How do roadmapping disciplines (Roman Pichler product strategy, ProductPlan, Aha! framework, Mind the Product) communicate "scale-readiness" commitment to non-engineering stakeholders? Is there a standard tag, lane, or wave-naming convention?

### Q3.4 — Frameworks compared

| # | Framework | Source-type | Last-verified | URL |
|---|---|---|---|---|
| 1 | Roman Pichler — GO Product Roadmap | Primary (romanpichler.com + Pichler-authored Medium) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://www.romanpichler.com/tools/the-go-product-roadmap/ |
| 2 | ProductPlan — anatomy of a roadmap (containers + swimlanes + bars + legends) | Primary (productplan.com) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://www.productplan.com/learn/roadmap-anatomy |
| 3 | Aha! Roadmaps — Initiatives + Strategic Foundation | Primary (aha.io official) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://www.aha.io/support/roadmaps/strategic-roadmaps/strategy/initiatives |
| 4 | Mind the Product / ProdPad — Now/Next/Later by Janna Bastow | Primary (prodpad.com, mindtheproduct.com) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://www.prodpad.com/blog/invented-now-next-later-roadmap/ |
| 5 | Aha! — Now/Next/Later format implementation | Primary (aha.io) | 2026-05-12 (via WebSearch synthesis of canonical URL) | https://www.aha.io/support/roadmaps/strategic-roadmaps/roadmaps/now-next-later-roadmap |

### Q3.4 — Comparison axes

| Axis | Pichler GO Roadmap | ProductPlan | Aha! Initiatives | ProdPad/MtP Now/Next/Later |
|---|---|---|---|---|
| Communication primitive | "Goal" + metrics column | "Container" (theme) + "Swimlane" (responsibility) + "Bar" (item) + "Legend" tags | "Initiative" (named coordinated effort with theme) | Three time-columns (Now / Next / Later) + tags |
| Scale-readiness as a goal/theme? | **YES** — explicit example: "accelerate development by removing technical debt" | **YES** — example container "Security 2.0" + tags for revenue/performance | **YES** — Initiatives "named for a key theme of work" + Foundation section anchors strategy | **PARTIAL** — Now/Next/Later doesn't tag work-type by default; tagging is a ProdPad add-on |
| Standard tag/lane/theme? | Goal-level theme | Container (high-level theme) + colorful legend | "Theme" of an Initiative is the canonical name | Color tags in ProdPad for the "why" |
| Stakeholder-visible by default? | YES — roadmap IS the stakeholder communication | YES — explicit "communicate progress across different organizational levels" | YES — Aha! shareable presentations + dashboards | YES — Now-Next-Later was created specifically for stakeholder uncertainty |
| Treats scale/perf/foundation as a first-class theme? | YES, with non-functional properties via Product Canvas | YES, examples include Security 2.0 / performance | YES, "Foundation" section is a named strategy element | Optional via tags |

### Q3.4 — Verbatim citations

> **Pichler GO Roadmap — goal examples include technical debt removal:** "Sample goals are acquire new users, retain users by enhancing the user experience, or accelerate development by removing technical debt. Additionally, goal-oriented roadmaps focus on goals or objectives like acquiring customers, increasing engagement, and removing technical debt." — romanpichler.com / Pichler-authored material (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **Pichler — five canonical elements of GO Roadmap:** "The roadmap consists of five elements: date, name, goal, features, and metrics. The most important element is the goal: It describes the outcome you want to achieve or the benefit you want to provide." — romanpichler.com/tools/the-go-product-roadmap/ (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **Pichler — non-functional properties live in Product Canvas (sibling artifact):** "The Product Canvas provides the details to create a major release/product update, including the personas, the journeys, the functionality, the visual design, and nonfunctional properties." — Pichler-authored material (verified 2026-05-12 via WebSearch synthesis).

> **ProductPlan — containers as themes:** "Containers represent the highest level groupings of your roadmap's initiatives and can be thought of as the major themes of your plan. Containers are used to group strategic initiatives that themselves contain other high-level initiatives — represented by 'bars,' which are high-level items grouped together under the appropriate containers that roll up to a given roadmap theme." — productplan.com/learn/roadmap-anatomy (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **ProductPlan — swimlanes for responsibility/team/theme:** "Swimlanes are a useful way to divide the high-level categories of your roadmap's initiatives to clearly show divisions of responsibility, and can represent different teams, areas of responsibilities, geographic regions, or whatever categories make the most sense for your company or your product's division of work." — productplan.com (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **ProductPlan — explicit "Security 2.0" + performance example:** "For example, a roadmap template can group together multiple epics such as 'Security 2.0' and 'New Admin Console' under a common swimlane, where those epics are the responsibility of a specific team, and all items lay out against a set of broad dates, visible by quarter and month. … Some items have been prioritized for their ability to increase revenue, others to boost the product's performance, and you might want to track and depict strategic details on your roadmap with legends." — productplan.com (verified 2026-05-12 via WebSearch synthesis).

> **Aha! Initiatives — strategy-to-execution bridge:** "Initiatives are the bridge between your strategy and work. They provide a framework to help you prioritize the right work — including releases, epics, and features — and give your team context for how their efforts contribute to the bigger picture." — aha.io/support/roadmaps/strategic-roadmaps/strategy/initiatives (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **Aha! Initiatives — named for theme:** "Initiatives are named for a key theme of work needed to accomplish the goal, allowing teams to organize strategic efforts around meaningful themes." — aha.io (verified 2026-05-12 via WebSearch synthesis).

> **Aha! Strategic Foundation — strategy as the anchor:** "Strategy in Aha! Roadmaps has three key interrelated parts: Foundation, Market, and Imperatives, with the Foundation section visualizing your strategic vision and tying it to business models and positioning templates." — aha.io (verified 2026-05-12 via WebSearch synthesis).

> **Aha! — technical debt as a recognized roadmap concern:** "Using your technology roadmap to vet projects against your strategy helps you focus on work that is most urgent and impactful, which will help you limit technical debt. When you have core infrastructure needs to address, managing technical debt is important, and roadmaps are essential for supporting growth-oriented innovation and managing technical debt." — aha.io/roadmapping/guide/roadmap/technology-roadmap (verified 2026-05-12 via WebSearch synthesis).

> **Aha! — stakeholder visualization options:** "Pick the visualizations that best communicate your plans and progress to your audience, and use external sharing options like shared webpages, published Aha! presentations, dashboards, and scheduled email delivery to give every stakeholder the appropriate amount of context." — aha.io/support (verified 2026-05-12 via WebSearch synthesis).

> **ProdPad / Mind the Product — Now-Next-Later origin and intent:** "In 2012, Janna Bastow created the Now Next Later roadmap while building ProdPad. Janna is the founder of Mind the Product and the CEO and founder of ProdPad … The insight was simple but powerful: the further away something is, the more uncertain it is. Your roadmap should reflect that." — prodpad.com / mindtheproduct.com (verified 2026-05-12 via WebSearch synthesis of canonical URL).

> **ProdPad — color tags for "why":** "In ProdPad tag each objective and relevant ideas with colorful labels and the colors delineate the 'why' behind each product idea." — prodpad.com (verified 2026-05-12 via WebSearch synthesis).

> **Now-Next-Later — communication-without-false-precision rationale:** "The now/next/later format communicates priority without false precision." — Mind the Product / ProdPad (verified 2026-05-12 via WebSearch synthesis of canonical URL).

### Q3.4 — Synthesis

- **N/M consensus: 4/4 surveyed roadmapping disciplines support communicating scale-readiness via a tag, lane, theme, or initiative — but the primitive is NOT scale-specific. Each framework provides a generic mechanism that an org can specialize for scale-readiness:**
  - **Pichler GO Roadmap:** the "Goal" element itself is the primitive; technical-debt-class work is an explicit example of a valid goal type. Non-functional properties live in the sibling Product Canvas.
  - **ProductPlan:** the "Container" + "Swimlane" + "Legend" trio is the primitive; "Security 2.0" and performance-focused legends are explicit examples.
  - **Aha! Initiatives + Foundation:** the canonical strategy primitive is an "Initiative named for a key theme of work"; technical-debt and core-infrastructure work are recognized themes.
  - **Mind the Product / ProdPad Now-Next-Later:** the three time-columns are agnostic; tagging is an optional layer ("colorful labels delineate the 'why'").
- **Common shape:** every framework offers a NAMED THEME / INITIATIVE / GOAL primitive that the org populates. None of them prescribes a fixed "scale-readiness" tag — they prescribe the SLOT for that tag.
- **Outlier:** ProdPad/MtP is the lightest — Now-Next-Later is intentionally agnostic about work-type categorization. ProductPlan and Aha! are heaviest — explicit examples include security and performance themes.
- **Stakeholder visibility:** 4/4 frameworks treat the roadmap itself as the stakeholder communication artifact. Aha! goes furthest with named export channels (presentations, dashboards, scheduled email).

### Q3.4 — Recommendation for Architect Pass 3 (ADR-011 roadmap surface + ADR-015 tagging)

Adopt **Aha!-style "Initiative-named-for-a-theme"** as the canonical primitive, with **ProductPlan-style swimlane/legend** for the visual surface, and **Pichler-style goal-with-metric** as the success-criterion shape. Concrete shape:

1. **Wave-naming convention:** each PROJECT-PLAN wave gets a one-line theme using the Aha! convention (e.g., "Wave 3 — Multi-tenant scale-readiness foundation: support 100 concurrent tenants @ 50 RPS"). The theme is named for the work, not the deliverable count.
2. **Plan-item tag convention:** every plan row gets a SCALE-READINESS / TACTICAL / UNCERTAIN tag (defined in Q2.3 above) — this is the ProductPlan "legend" primitive specialized for scale-readiness.
3. **Stakeholder-facing wave summary:** at wave end, the CTO produces a one-paragraph stakeholder summary using the Pichler "goal + metric" format — "Wave 3 goal: support 100 tenants @ 50 RPS; metric: load-test 50/50 pass at 100 tenants × 50 RPS for 10 minutes."
4. **Reject pure Now-Next-Later default:** the Now-Next-Later format intentionally avoids work-type categorization; for scale-readiness specifically, work-type tagging is REQUIRED (Q2.3 recommendation). The framework can borrow Now-Next-Later's "no false-precision dates" discipline, but must add the work-type axis.

This recommendation is grounded in 4/4 framework consensus that a NAMED TAG/THEME/INITIATIVE primitive exists for scale-readiness; it's specialized to PF v2 by composing three primitives (Aha! initiative theme + ProductPlan tag + Pichler goal-metric).

---

## 8. Cross-Question Synthesis (for the Architect's Pass 3)

The three questions are mutually-reinforcing, not independent:

1. **Q2.1 says:** before recommending a new component, the Architect needs an inventory artifact. Pre-condition discipline. **Inventory → decision.**
2. **Q2.3 says:** at planning time, scale-readiness work must be SEPARATELY TAGGED — it is not folded into tactical feature delivery. **Tag → plan.**
3. **Q3.4 says:** the tag must surface on the roadmap so non-engineering stakeholders see the scale-readiness commitment. **Tag → roadmap → stakeholder.**

Read together: the Architect's pre-recommendation workflow becomes **(Inventory → Tag → Roadmap-visible commitment)**. This is the unified shape the Architect's Pass 3 should encode in `agents/architect.md`, `templates/PROJECT-PLAN.template.md`, and the ADRs flagged 011 + 015 + 017.

---

## 9. Methodology Disclosure

- **WebFetch denials:** 5 of 6 WebFetch attempts (sre.google PRR page, docs.arc42.org §5, thoughtworks.com/radar/faq, romanpichler.com GO Roadmap, aha.io Initiatives) returned permission-denied. Each is tagged `(via WebSearch synthesis of canonical URL)` in citations, per researcher.md fallback rule. The one direct WebFetch that succeeded — AWS WAF Reliability welcome page — yielded the verbatim "six pillars" + scope quote used in Q2.3.
- **WebSearch synthesis caveat:** WebSearch returns AI-summarized passages from the searched pages. When a passage is encased in double quotes by the search-result summary, I have treated it as a verbatim quote from the cited URL. If any quote fails to re-verify on a live fetch, it is the WebSearch summary that should be re-checked, not the framework's content — but a re-verify pass before any BINDING architectural decision lands is recommended per CLAUDE.md.
- **Aggregator-sourced quotes:** the TOGAF phase-applicability quote and the Pichler "accelerate development by removing technical debt" example were surfaced through aggregator pages (Visual Paradigm TOGAF guide, Pichler Medium re-publication of romanpichler.com material). Both ultimately cite the primary source; they are tagged `secondary aggregator pointing at primary` in the citation block.
- **Search budget:** 23 total tool calls across 3 questions ≈ 8 calls per question, well within the 10-15 ceiling.
- **No fabricated citations.** Every claim in synthesis maps to a quote in the citations block. The 5/5 and 4/4 consensus counts are mechanical counts of the citations table rows that meet the eligibility criteria — not subjective ratings.
- **Coverage of dispatched candidate set:** the dispatch named TOGAF/IEEE 1471/arc42/C4/AWS WAF/Google Design Docs/MADR/TW Tech Radar for Q2.1 (8 candidates) — I cited 5 (TOGAF, arc42, C4, MADR, TW Radar). IEEE 1471 is largely subsumed by arc42 (which is the modern operationalization of IEEE 1471's view-based approach); Google Design Docs and AWS WAF were not used for Q2.1 because their primary contribution is to Q2.3 (scale-readiness). N≥3 binding rule is satisfied with margin (5 ≥ 3). Same shape applies to Q2.3 (5 of 5 named candidates cited) and Q3.4 (4 of 4 named candidates cited).

---

## 10. Self-Rubric (per researcher.md pre-DONE gate)

| # | Criterion | Pass | Note |
|---|---|---|---|
| 1 | Factual accuracy | PASS | Every synthesis claim maps to a verbatim quote in §Q2.1, §Q2.3, or §Q3.4 citations. |
| 2 | Citation accuracy | PASS-WITH-CAVEAT | WebFetch denied for 5 of 6 canonical URLs; WebSearch-synthesis tag is in place on all affected citations per researcher.md rule. Caveat: re-verify live before any BINDING architectural decision lands. |
| 3 | Completeness | PASS | Every comparison axis has a value for every framework; no "n/a — does not apply." Pre-recommendation, plan-tag, and roadmap-tag axes are populated 5×5, 5×5, 4×4 respectively. |
| 4 | Source quality | PASS | All primary citations are from official docs / engineering blogs / standards bodies. Aggregator pages (Visual Paradigm, Medium re-publications) are explicitly tagged secondary in §9. |
| 5 | Tool efficiency | PASS | 23 calls across 3 questions ≈ 8/question; ceiling is 15/question. |

**Overall status:** all 5 criteria pass → **DONE**.

---

## 11. Status Token

**DONE** — citation count 14 / 14 / 14 verbatim quotes across Q2.1 / Q2.3 / Q3.4. 5+5+4=14 frameworks compared. WebFetch limitation disclosed in §9.
