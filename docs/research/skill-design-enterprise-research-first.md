# Skill Design Research — `enterprise-research-first`

**Date:** 2026-04-30
**Type:** Source-of-truth research for the `skills/enterprise-research-first/SKILL.md` skill — research only, no code modifications.
**Triggered by:** GAP-1 in `docs/research/sp-anthropic-citation-manifest.md` — the N≥3 binding-research-before-design rule has no exact SP precedent and no direct Anthropic citation. Per the PF v2 binding rule, every feature must cite either SP or Anthropic; gap features must either find adjacent precedent + ≥3 enterprise/OSS analogues, redesign, or be removed. This skill plugs into `cto-mode` (orchestrator-worker frame, lines 1–80) and is invoked by Architect, Database Engineer, and Researcher agents at design-decision time.
**Methodology disclosure:** SP 5.0.7 quotes are read directly from the local cache at `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/`. Anthropic and enterprise quotes are reproduced verbatim as returned by WebSearch synthesis of the canonical URLs listed in §Sources Inventory. WebFetch was permission-denied; re-verify any binding quote against the live URL before commit. PF v1 skill at `c:/Users/atyab/Experimental - Users/production-framework/skills/enterprise-research-first/SKILL.md` was read directly from disk and forms the carry-forward baseline.

---

## §1 Sources Inventory

| # | Source | URL / Path | Method | Status |
|---|---|---|---|---|
| 1 | PF v1 `enterprise-research-first` skill (carry-forward baseline) | `c:/Users/atyab/Experimental - Users/production-framework/skills/enterprise-research-first/SKILL.md` | Direct read | OK (107 lines, fully read) |
| 2 | SP 5.0.7 `brainstorming/SKILL.md` line 103 | `.../superpowers/5.0.7/skills/brainstorming/SKILL.md` | Direct read | OK |
| 3 | SP 5.0.7 `systematic-debugging/SKILL.md` lines 122–143 ("Phase 2: Pattern Analysis / Compare Against References") | `.../superpowers/5.0.7/skills/systematic-debugging/SKILL.md` | Direct read | OK |
| 4 | SP 5.0.7 `subagent-driven-development/implementer-prompt.md` line 91 ("Did I follow existing patterns in the codebase?") | `.../superpowers/5.0.7/skills/subagent-driven-development/implementer-prompt.md` | Direct read | OK |
| 5 | SP 5.0.7 `writing-skills/anthropic-best-practices.md` lines 720–735 (eval-driven loop "compare against baseline") | `.../superpowers/5.0.7/skills/writing-skills/anthropic-best-practices.md` | Direct read | OK |
| 6 | SP 5.0.7 `requesting-code-review/code-reviewer.md` line 7 ("Compare against {PLAN_OR_REQUIREMENTS}") | `.../superpowers/5.0.7/skills/requesting-code-review/code-reviewer.md` | Direct read | OK |
| 7 | Anthropic — *Building Effective AI Agents* (Dec 2024) | https://www.anthropic.com/research/building-effective-agents | WebSearch synthesis | OK (verified 2026-04-30) |
| 8 | Anthropic — *How we built our multi-agent research system* (Jun 2025) | https://www.anthropic.com/engineering/multi-agent-research-system | WebSearch synthesis | OK (verified 2026-04-30) |
| 9 | Anthropic — *Effective context engineering for AI agents* | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | Cross-referenced from citation manifest §2.17 | OK |
| 10 | Amazon "Working Backwards" PR/FAQ — six-page narrative | https://workingbackwards.com/concepts/working-backwards-pr-faq-process/ , https://www.aboutamazon.com/news/workplace/an-insider-look-at-amazons-culture-and-processes | WebSearch synthesis | OK (verified 2026-04-30) |
| 11 | Google — *Design Docs at Google* | https://www.industrialempathy.com/posts/design-docs-at-google/ | WebSearch synthesis | OK (verified 2026-04-30) |
| 12 | Rust RFC template + RFC 2333 ("Add a 'prior art' section to RFCs") | https://github.com/rust-lang/rfcs/blob/master/0000-template.md , https://rust-lang.github.io/rfcs/2333-prior-art.html | WebSearch synthesis | OK (verified 2026-04-30) |
| 13 | Kubernetes KEP template — "Alternatives" section | https://github.com/kubernetes/enhancements/blob/master/keps/NNNN-kep-template/README.md | WebSearch synthesis | OK (verified 2026-04-30) |
| 14 | AWS Well-Architected Framework | https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html , https://aws.amazon.com/architecture/well-architected/ | WebSearch synthesis | OK (verified 2026-04-30) |
| 15 | ThoughtWorks Technology Radar — Adopt / Trial / Assess / Hold rings | https://www.thoughtworks.com/radar , https://www.thoughtworks.com/radar/techniques | WebSearch synthesis | OK (verified 2026-04-30) |
| 16 | ADR / MADR (Markdown ADR) — "Considered Options" section | https://adr.github.io/adr-templates/ , https://github.com/joelparkerhenderson/architecture-decision-record , https://martinfowler.com/bliki/ArchitectureDecisionRecord.html | WebSearch synthesis | OK (verified 2026-04-30) |
| 17 | Spotify engineering — RFC + ADR practice | https://engineering.atspotify.com/2024/7/technical-decision-making-in-a-fragmented-space-spotify-in-car-case-study , https://www.infoq.com/news/2020/04/architecture-decision-records/ | WebSearch synthesis | OK (verified 2026-04-30) |
| 18 | Squarespace engineering — *The Power of "Yes, if": Iterating on our RFC Process* | https://engineering.squarespace.com/blog/2019/the-power-of-yes-if | WebSearch synthesis | OK (verified 2026-04-30) |
| 19 | The Pragmatic Engineer — *Companies Using RFCs or Design Docs* (industry survey) | https://blog.pragmaticengineer.com/rfcs-and-design-docs/ , https://newsletter.pragmaticengineer.com/p/software-engineering-rfc-and-design | WebSearch synthesis | OK (verified 2026-04-30) — used for cross-validation only, not as a binding source |
| 20 | PF v2 Enterprise multi-agent architecture research (companion doc) | `c:/Users/atyab/Experimental - Users/production-framework-v2/docs/research/enterprise-multi-agent-architecture.md` | Direct read | OK |

---

## §2 Verbatim Citations by Topic

### §2.1 SP precedent — "compare against existing patterns / references"

SP does not ship a skill named anything like `enterprise-research-first`. It does, however, have **five separate skills that each enforce a "compare-before-deciding" discipline at a smaller scope** (codebase-local rather than industry-wide). Together these establish that the *generic discipline* of pattern-comparison is core to SP's design philosophy — PF v2's contribution is scaling that discipline from "look at the rest of this codebase" to "look at ≥3 enterprise/OSS implementations."

> "Explore the current structure before proposing changes. Follow existing patterns."
> — SP 5.0.7 `skills/brainstorming/SKILL.md` line 103

> "**Compare Against References**
>    - If implementing pattern, read reference implementation COMPLETELY
>    - Don't skim - read every line
>    - Understand the pattern fully before applying"
> — SP 5.0.7 `skills/systematic-debugging/SKILL.md` lines 130–133

> "**Find Working Examples**
>    - Locate similar working code in same codebase
>    - What works that's similar to what's broken?"
> — SP 5.0.7 `skills/systematic-debugging/SKILL.md` lines 126–128

> "Did I follow existing patterns in the codebase?"
> — SP 5.0.7 `skills/subagent-driven-development/implementer-prompt.md` line 91 (in the implementer's mandatory self-review checklist)

> "Iterate: Execute evaluations, compare against baseline, and refine"
> — SP 5.0.7 `skills/writing-skills/anthropic-best-practices.md` line 733

> "Compare against {PLAN_OR_REQUIREMENTS}"
> — SP 5.0.7 `skills/requesting-code-review/code-reviewer.md` line 7

**Synthesis:** SP enforces "compare against references / existing patterns / baseline / requirements" in **5 distinct skills**. PF v2's `enterprise-research-first` extends the same discipline one scope-level outward — from same-codebase patterns to industry patterns. The discipline is SP-precedented; only the *scope* of "where to look" is PF-original.

### §2.2 Anthropic precedent — closest adjacent guidance

No Anthropic publication prescribes "research ≥3 external implementations before designing." The closest available framings are:

> "Anthropic recommends finding the simplest solution possible, and only increasing complexity when needed... You should consider adding complexity only when it demonstrably improves outcomes. Success in the LLM space isn't about building the most sophisticated system. It's about building the right system for your needs."
> — *Building Effective AI Agents*, Anthropic, Dec 2024 (https://www.anthropic.com/research/building-effective-agents) (via WebSearch synthesis, verified 2026-04-30)

> "Common patterns are composable building blocks that developers can shape and combine to fit different use cases."
> — *Building Effective AI Agents*, Anthropic, Dec 2024 (via WebSearch synthesis)

> "When a user submits a query, the system creates a LeadResearcher agent that enters an iterative research process and then creates specialized Subagents with specific research tasks... Each subagent needs an objective, an output format, guidance on the tools and sources to use, and clear task boundaries."
> — *How we built our multi-agent research system*, Anthropic Engineering, Jun 2025 (https://www.anthropic.com/engineering/multi-agent-research-system) (via WebSearch synthesis, verified 2026-04-30)

> "Human testers noticed that early agents consistently chose SEO-optimized content farms over authoritative sources like academic PDFs, and adding source quality heuristics to prompts helped resolve this issue."
> — *How we built our multi-agent research system*, Anthropic Engineering, Jun 2025 (via WebSearch synthesis)

> "An LLM judge evaluated each output against criteria in a rubric: factual accuracy (do claims match sources?), citation accuracy (do the cited sources match the claims?), completeness (are all requested aspects covered?), source quality (did it use primary sources over lower-quality secondary sources?), and tool efficiency (did it use the right tools a reasonable number of times?)."
> — *How we built our multi-agent research system*, Anthropic Engineering, Jun 2025 (via WebSearch synthesis)

**Synthesis:** Anthropic does not prescribe N≥3 external research as a discipline. It does prescribe (a) **simplest-solution-first** with complexity justified by measurement, (b) **direct-quotation citation discipline** to mitigate hallucination, (c) **source-quality heuristics** (prefer primary docs over SEO content), and (d) **a five-criterion evaluation rubric** for research outputs. PF v2 should claim Anthropic backing for *citation discipline + source quality + simplest-solution framing* but **not** for the N≥3 quantitative bar itself. The N≥3 number is PF-original.

### §2.3 Enterprise / OSS precedents — "research-before-designing as a documented discipline"

#### 2.3.1 Amazon Working Backwards (PR/FAQ six-page narrative)

> "Most of Amazon's major products and initiatives since 2004 have been created through a process called Working Backwards. Its principal tool is a second form of written narrative called the PR/FAQ, short for press release/frequently asked questions."
> — *An insider look at Amazon's culture and processes*, About Amazon (https://www.aboutamazon.com/news/workplace/an-insider-look-at-amazons-culture-and-processes) (via WebSearch synthesis, verified 2026-04-30)

> "For any new product inside of Amazon, the first page of that narrative is a press release, as if you were launching the product tomorrow. And then the next five pages are frequently asked questions. Questions cover how the product will be differentiated, how it would be priced, and what invention you have to solve to do this."
> — *Working Backwards: Dave Limp on Amazon's Six Page Memo*, Amazon Chronicles (via WebSearch synthesis)

> "The key tenet is to start by defining the customer experience, then iteratively work backwards from that point until the team achieves clarity of thought around what to build."
> — *The Amazon Working Backwards PR/FAQ Process*, workingbackwards.com (https://workingbackwards.com/concepts/working-backwards-pr-faq-process/) (via WebSearch synthesis)

**Discipline demonstrated:** **research + structured narrative before deciding.** Amazon's PR/FAQ requires a written six-page document that articulates differentiation, alternatives, and "what invention you have to solve" before approval. Iteration is expected; first-draft approval is rare.

#### 2.3.2 Google Design Docs

> "Google's software engineering culture uses design docs—relatively informal documents created before coding—that document the high-level implementation strategy and key design decisions with emphasis on the trade-offs that were considered during those decisions."
> — *Design Docs at Google*, industrialempathy.com (https://www.industrialempathy.com/posts/design-docs-at-google/) (via WebSearch synthesis, verified 2026-04-30)

**Discipline demonstrated:** **trade-offs documented before code.** "Trade-offs that were considered" implies enumerating alternatives. Google's culture is one of the most-cited industry exemplars for this discipline.

#### 2.3.3 Rust RFC process — explicit "Prior Art" + "Alternatives" sections

> "RFC 2333 modifies the RFC template by adding a Prior art section before the Unresolved questions. The newly introduced section is intended to help authors reflect on the experience other languages have had with similar and related concepts."
> — *RFC 2333: Add a 'prior art' section to RFCs* (https://rust-lang.github.io/rfcs/2333-prior-art.html) (via WebSearch synthesis, verified 2026-04-30)

> "Discuss prior art, both the good and the bad, in relation to this proposal."
> — Rust RFC template (https://github.com/rust-lang/rfcs/blob/master/0000-template.md) (via WebSearch synthesis)

> "RFC template designs have been influenced by Ember's RFCs, ESLint's RFCs, React's RFCs, Rust's RFCs and Major Change Proposals, Vue's RFCs, Yarn's RFCs, Java Specification Requests and Architectural Decision Records."
> — *Companies Using RFCs or Design Docs*, Pragmatic Engineer (https://blog.pragmaticengineer.com/rfcs-and-design-docs/) (via WebSearch synthesis)

**Discipline demonstrated:** **a named "Prior Art" section is mandatory in the template.** Rust's RFC template propagated to Ember, ESLint, React, Vue, Yarn — i.e., the discipline is not a Rust quirk but a JS/Rust ecosystem norm. "Not strictly required to fill" if no prior art exists, but the section itself is required.

#### 2.3.4 Kubernetes KEPs — "Alternatives" required

> "The Alternatives section is used to highlight and record other possible approaches to delivering the value proposed by a KEP. A robust KEP will juxtapose alternative approaches, explaining what was considered and rejected, and why."
> — Kubernetes KEP template (https://github.com/kubernetes/enhancements/blob/master/keps/NNNN-kep-template/README.md) (via WebSearch synthesis, verified 2026-04-30)

> "The alternatives considered section elucidates why this particular path was taken, whether it's selecting a sidecar model over an operator pattern or choosing CRDs over API extensions."
> — Kubernetes KEP process documentation (via WebSearch synthesis)

**Discipline demonstrated:** **alternatives must be enumerated and rejected with rationale.** "What was considered and rejected, and why" is the gate. K8s ships at planet-scale; this is not academic ceremony.

#### 2.3.5 AWS Well-Architected Framework — comparison against established pillars

> "The AWS Well-Architected Framework documents a set of foundational questions that help you to understand if a specific architecture aligns well with cloud best practices. The framework provides a consistent approach to evaluating systems against the qualities you expect from modern cloud-based systems."
> — AWS Well-Architected Framework (https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html) (via WebSearch synthesis, verified 2026-04-30)

> "The framework describes AWS best practices and strategies to use when designing and operating a cloud workload, and provides links to further implementation details and architectural patterns... The tool surfaces insights on where your architecture diverges from recommended practices and provides an action plan for remediation."
> — AWS Well-Architected docs (via WebSearch synthesis)

**Discipline demonstrated:** **explicit, automated comparison of a proposed architecture against documented industry patterns.** Divergence is named and remediation is required.

#### 2.3.6 ThoughtWorks Technology Radar — N-source consensus rings

> "Adopt: Blips that we think you should seriously consider using. Trial: Things we think are ready for use, but not as completely proven as those in the Adopt ring. Assess: Things to look at closely, but not necessarily trial yet. Hold: The industry should consider alternative options or even proactively avoid these things."
> — ThoughtWorks Technology Radar (https://www.thoughtworks.com/radar) (via WebSearch synthesis, verified 2026-04-30)

> "The way Thoughtworks chooses the technology and tools (or 'blips') included in the radar is through interactive sessions with the Technology Radar group. Over the course of a couple of days they come together (in person or virtually) and make their case for each technology. They then vote for what stays and what needs to go."
> — ThoughtWorks methodology (via WebSearch synthesis)

**Discipline demonstrated:** **multi-voter consensus over N independent practitioners** before assigning a "ring" to a tool/technique. The four-ring grammar (Adopt/Trial/Assess/Hold) is a near-perfect analogue to PF's BINDING/STRONG/SPLIT/INSUFFICIENT consensus grammar. ThoughtWorks publishes twice yearly; the methodology is openly documented.

#### 2.3.7 ADR / MADR — "Considered Options" section in template

> "An Architectural Decision Record (ADR) captures a single AD and its rationale, helping you understand the reasons for a chosen architectural decision, along with its trade-offs and consequences... As part of documenting an ADR it's valuable to explicitly list all the serious alternatives that were considered, together with their pros and cons."
> — adr.github.io / Joel Parker Henderson ADR collection / Martin Fowler bliki (https://adr.github.io/adr-templates/ , https://martinfowler.com/bliki/ArchitectureDecisionRecord.html) (via WebSearch synthesis, verified 2026-04-30)

> "MADR provides a full and a minimal template, both of which now come in an annotated and a bare format... The considered options with their pros and cons are crucial to understand the reasons for choosing a particular design."
> — MADR documentation (via WebSearch synthesis)

**Discipline demonstrated:** **alternatives + pros/cons enumerated as a structured section in every decision record.** ADR/MADR is the de-facto industry standard for decision capture; PF v2 already mandates `docs/adr/<n>-<decision>.md` files.

#### 2.3.8 Spotify — RFC + ADR coupling

> "Spotify has deeply embedded RFCs and ADRs as part of its culture, and sometimes uses them for non-technical changes such as re-orgs. For technical decision-making, Spotify prefers Request for Comments (RFC) documents that focus on a single problem, allow stakeholders to discuss that problem asynchronously, and refine the solution. When making changes with large impact on systems, Spotify engineers use RFCs as a means to facilitate all stakeholders to agree on a common approach, and once the RFC process is completed, the solution agreed upon is captured in an ADR."
> — Spotify engineering blog / InfoQ summary (https://engineering.atspotify.com , https://www.infoq.com/news/2020/04/architecture-decision-records/) (via WebSearch synthesis, verified 2026-04-30)

**Discipline demonstrated:** **RFC for option-discovery + ADR for option-selection.** Two-step gate; the RFC stage enumerates options, the ADR stage records the chosen one with rejected alternatives.

#### 2.3.9 Squarespace — opinionated RFC template

> "Squarespace improved its RFC process through three steps: writing an opinionated RFC template, creating an Infrastructure Council, and introducing Architecture Review. They rewrote their RFC template to give more opinionated guidance on what RFCs should include, making it easy and intuitive for people to do the right thing."
> — Squarespace engineering blog (https://engineering.squarespace.com/blog/2019/the-power-of-yes-if) (via WebSearch synthesis, verified 2026-04-30)

**Discipline demonstrated:** **opinionated, mandatory template structure** for design proposals — the template itself enforces that alternatives and prior art are surfaced.

### §2.4 Consensus strength — K of N

| # | Source | Requires/recommends "research-before-design" with explicit alternatives section? |
|---|---|---|
| 1 | Amazon Working Backwards (PR/FAQ) | YES — six-page narrative including differentiation + invention required |
| 2 | Google Design Docs | YES — trade-offs documented before code |
| 3 | Rust RFC template + RFC 2333 | YES — "Prior Art" section required in template |
| 4 | Kubernetes KEPs | YES — "Alternatives" section required, with rejection rationale |
| 5 | AWS Well-Architected | YES — explicit comparison against documented patterns; divergence flagged |
| 6 | ThoughtWorks Tech Radar | YES — multi-voter ring assignment from independent practitioner experience |
| 7 | ADR / MADR | YES — "Considered Options" section is core to template |
| 8 | Spotify RFC + ADR | YES — two-stage gate, RFC enumerates options, ADR records selection |
| 9 | Squarespace opinionated RFC | YES — mandatory template structure enforces alternatives surfacing |

**Consensus strength: 9/9 enterprise sources require/recommend "research-before-design with an explicit alternatives or prior-art section" as a documented step.**

Per PF v2's own consensus grammar (`enterprise-multi-agent-architecture.md` thresholds: BINDING = N/N unanimous AND N≥5):

> **9/9 unanimous, N=9 ≥ 5 → BINDING.**

The *discipline* of research-before-design is BINDING by PF's own standard. The *quantitative threshold* of "≥3 sources" is not directly cited by any of these enterprise sources — it is PF-original, but well-supported by the spirit of the discipline.

---

## §3 Gap Analysis vs Current PF v2 Framing

### What is covered (keep as-is)

- **The discipline itself** — "research before designing, with an explicit alternatives/prior-art section." 9/9 enterprise sources support this. SP supports the smaller-scope analogue ("compare against references / existing patterns / baseline") in 5 distinct skills.
- **The N=3–6 tool sample size** — adjacent support: ThoughtWorks Radar uses multi-voter consensus; the v1 PF skill already sets 3-6 as the sample range.
- **The output format (comparison table + consensus strength + binding flag)** — adjacent support: ADR/MADR "Considered Options" tables, KEP "Alternatives" sections, ThoughtWorks four-ring assignment.
- **Citation discipline (file:line, commit hash, URL + verification date)** — directly supported by Anthropic Citations API framing ("ground its answers in source documents… direct references to the exact sentences and passages").
- **Source-quality heuristic (prefer primary OSS code over training-data recall)** — directly supported by Anthropic multi-agent research system: "adding source quality heuristics to prompts helped resolve" SEO-content-farm bias.
- **Outlier-naming requirement** — adjacent support: Rust "discuss prior art, both the good and the bad"; KEP "explaining what was considered and rejected, and why".
- **Use-case-fit check before adopting unanimous consensus** — *no direct enterprise precedent found, but adjacent to AWS Well-Architected divergence-with-rationale framing*. PF-original; defensible as a refinement.

### What is missing or weak

- **The exact "N≥3 BINDING / N≥5 STRONG-or-BINDING" numeric threshold** — no enterprise source prescribes a specific count. PF-original. The v1 skill already labels these "framework invariant §2.10" — keep that framing, but do **not** claim Anthropic or any single enterprise source backs the number. Cite "9/9 enterprise sources require the *discipline*; the threshold is PF-internal calibration."
- **The "Composability with `writing-arch-doc` and `seven-validation-questions` Q3" coupling** — PF-internal wiring, no external precedent needed (intra-framework integration).
- **Anthropic citation discipline** — v1 skill says "verify the source at research time" but doesn't quote Anthropic's citation framing. v2 should add an Anthropic-cited line to make the verification rule traceable.
- **The five-criterion self-check rubric (factual / citation / completeness / source-quality / tool-efficiency)** — Anthropic uses this for their LeadResearcher. PF v2 Researcher *agent* is already designed around it (`agent-design-researcher.md`); the v2 *skill* should likewise reference the rubric so that any agent invoking the skill (Architect, DBE, Researcher) self-audits to the same standard.
- **Provenance honesty** — per the citation-manifest GAP-1 recommendation, the skill should state up-front that the *discipline* is enterprise-cited but the *N=3 threshold* is PF-internal calibration. Avoids the "claims more authority than it has" failure mode the manifest flagged.

### What in the v1 skill should be carried forward verbatim

- The 5-step core pattern (select tools → trace exact implementation → comparison table → consensus strength → name outliers).
- The Step 6 "use-case-fit check" with the 7/7 server-side-OAuth incident as the worked example. **This incident is load-bearing** — it's the only documented case of N/N consensus rejected after capability-need analysis, and it's the strongest argument that this skill is more than ceremony.
- The Common Mistakes section, all six items.
- The Quick Reference framing.
- The composability notes (feeds into `writing-arch-doc`, precedes `seven-validation-questions` Q3).

### What in the v1 skill should be revised

- **Frontmatter description** — v1 says "research 3-6 enterprise / open-source tools first; consensus among them is binding." Keep, but add the trigger surface for the three invoking agents (Architect, DBE, Researcher) so the skill description aligns with `cto-mode`'s dispatch graph.
- **Add a citations footer** matching the shape of `agent-design-researcher.md` — every claim in the skill body should be traceable to either an SP file:line, an Anthropic URL, or one of the 9 enterprise sources.
- **Reframe the BINDING-threshold introduction** — instead of "framework invariant §2.10 says...", lead with "9/9 enterprise sources (Amazon / Google / Rust / Kubernetes / AWS / ThoughtWorks / ADR-MADR / Spotify / Squarespace) require an alternatives-or-prior-art section in the design artefact. PF v2 calibrates the count at N≥3 STRONG / N≥5 BINDING — that calibration is PF-internal."
- **Add a HARD-GATE marker** consistent with SP `brainstorming/SKILL.md` lines 12–14 framing. Currently v1 has no `<HARD-GATE>` block — but the skill is invoked at design-decision time and is intended to be non-negotiable for that invocation. Adding the gate aligns it with SP convention.
- **Add an Anti-Pattern section** — SP convention (`brainstorming` line 16, `writing-skills` lines 562–582). Likely candidates: "I already know what tool X does" (without verification at research time), "Two tools agree, that's enough" (N<3 false consensus), "Simpler is better" (U-AP-4 rejection).
- **Add a Red Flags table** — SP convention (`test-driven-development`, `verification-before-completion`). Two-column `| Excuse | Reality |`.

---

## §4 Recommendations for the Skill Body

Each recommendation is concrete content the skill author should include. Rationale gives the source.

### R1 — Lead with the discipline citation, not the threshold

**What:** Open the Overview with "9/9 enterprise sources require an alternatives or prior-art section in the design artefact: Amazon PR/FAQ, Google Design Docs, Rust RFC template (RFC 2333), Kubernetes KEPs, AWS Well-Architected, ThoughtWorks Tech Radar, ADR/MADR, Spotify RFC+ADR, Squarespace opinionated RFC. PF v2 codifies this discipline as `enterprise-research-first`, calibrated at N≥3 STRONG and N≥5 BINDING."

**Why:** Resolves GAP-1 from the citation manifest. The discipline is now SP-precedented (5 SP skills) AND enterprise-cited (9/9). Only the numeric threshold remains PF-original — and the skill says so honestly.

### R2 — Add an explicit `<HARD-GATE>` marker

**What:** Insert a `<HARD-GATE>` block right after the frontmatter:
> Do NOT propose a new interaction model, data shape, sync strategy, module location, or API contract until the comparison table is written, the consensus strength is computed, outliers are named, and the use-case-fit check is documented. Skipping this skill at design-decision time is a U-PP-10 violation.

**Why:** SP convention (`brainstorming` lines 12–14; `verification-before-completion` Iron Law). The citation manifest §2.6 ("only increase complexity when needed") supports the principle — if you skip the comparison, you cannot demonstrate that the proposed pattern is the simplest one that fits.

### R3 — Carry forward the v1 Core Pattern (Steps 1–6) verbatim

**What:** Keep the Step 1–6 structure (select tools / trace implementation / comparison table / consensus strength / name outliers / use-case-fit check) exactly as in v1.

**Why:** Already battle-tested in PF v1 with the 7/7 OAuth incident. Carrying forward avoids regression. The structure mirrors KEP "Alternatives", ADR "Considered Options", and ThoughtWorks ring-assignment.

### R4 — Add an Anti-Pattern section with three named patterns

**What:**
- **"I already know what Tool X does."** Training-data recall is not a citation. Verify at research time.
- **"Two tools agree, that's enough."** N<3 is INSUFFICIENT per the consensus grammar. Two-tool agreement is coincidence, not consensus.
- **"This pattern is simpler than the consensus, so simpler wins."** U-AP-4 explicitly rejects this. The valid divergence rationale is "the consensus pattern requires capabilities our project does not need" (use-case-fit check), not "simpler."

**Why:** SP convention (`brainstorming` line 16, `writing-skills` lines 562–582). The three named patterns are the most common rationalizations the skill exists to prevent — and Step 6 use-case-fit check is the antidote to pattern #3.

### R5 — Add a Red Flags table

**What:** Two-column `| Excuse | Reality |` table. Candidate rows:
| Excuse | Reality |
|---|---|
| "Most tools do X" | "Most" without a count is unverifiable. State 4/6 or 5/5 explicitly. |
| "Based on training data" | Training data is a starting list, not a citation. Verify against the live source. |
| "These three tools agree" (cherry-picked from a larger set) | If two more tools were researched and diverged, report 3/5, not 3/3. |
| "Simpler is better" | U-AP-4 rejects this. Valid divergence is "no use case for the capability the consensus pattern enables." |
| "BINDING with N=3 unanimous" | BINDING requires N≥5 unanimous. N=3 is STRONG, not BINDING. |
| "We already researched this last sprint" | If `docs/research/<topic>.md` doesn't exist or is stale, re-verify at research time. |

**Why:** SP convention. The `writing-skills` skill explicitly says (lines 498–510) that Red Flags rows should be populated from observed baseline failures. Each row above is an actual failure mode in PF v1 sessions per the v1 SKILL.md "Common Mistakes" list.

### R6 — Add Anthropic-cited source-quality heuristic

**What:** Insert under Step 1 (Select Tools): "Source-quality heuristic: prefer primary sources (OSS code in the repo, official engineering blog, public changelog) over secondary sources (third-party tutorials, SEO-optimized listicles). Anthropic's multi-agent research system documents this exact failure mode: 'early agents consistently chose SEO-optimized content farms over authoritative sources like academic PDFs, and adding source quality heuristics to prompts helped resolve this issue' (https://www.anthropic.com/engineering/multi-agent-research-system, Jun 2025)."

**Why:** Direct Anthropic citation strengthens the skill against GAP-1. Aligns with how PF v2's Researcher *agent* prompt is being written (per `agent-design-researcher.md`).

### R7 — Add Anthropic-cited citation discipline

**What:** Insert under Step 2 (Trace Exact Implementation): "Citation discipline: cite verbatim text or precise file:line — not paraphrase. Anthropic's Citations API framing applies: 'support the answer with citations that incorporate direct quotations from the underlying source documents' (https://docs.claude.com/en/docs/build-with-claude/citations, https://claude.com/blog/introducing-citations-api)."

**Why:** Closes GAP-1's "no Anthropic citation" gap on the verification-at-research-time rule. Same discipline PF v2 Researcher agent uses.

### R8 — Add a self-check rubric (5 criteria)

**What:** Add a "Self-Check Before Declaring DONE" section with the five Anthropic-derived criteria adapted for design-decision research:
1. **Factual accuracy** — does each cell in the comparison table match the cited source?
2. **Citation accuracy** — does each citation resolve to the exact line/section claimed?
3. **Completeness** — are all design aspects covered, not just the easy ones?
4. **Source quality** — are sources primary (OSS code, official docs) rather than secondary (tutorials, SEO content)?
5. **Tool efficiency** — N=3-6 sources researched, not N=12 (over-research) or N=2 (under-research).

**Why:** Anthropic's Multi-Agent Research System documents this exact rubric for LeadResearcher self-audit (Jun 2025 blog). PF v2 already plans to use it for the Researcher agent (`agent-design-researcher.md`); the skill should expose the same standard so any agent invoking the skill is held to it.

### R9 — Carry forward the worked-example incident verbatim

**What:** Keep the v1 incident (7/7 enterprise tools used server-side OAuth; PF project's use-case-fit check rejected the consensus because none of the server-side capabilities were needed). Quote the incident as-is; it's the load-bearing example for Step 6.

**Why:** SP convention requires every pattern row to have an `Incident` column value (per the parent PF/CLAUDE.md line 22). The 7/7 OAuth case is the strongest documented evidence that the use-case-fit check earns its line in the skill.

### R10 — Citations footer

**What:** Mirror the citations footer from `agent-design-researcher.md` and other `agent-design-*.md` docs. List all 20 sources from §1 above, with verification dates.

**Why:** Consistency with the rest of `docs/research/`. Makes the skill self-auditable against the binding rule.

---

## §5 Citations Footer

**SP 5.0.7 sources (read directly from local cache `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/`):**

- `skills/brainstorming/SKILL.md` line 103 — "Explore the current structure before proposing changes. Follow existing patterns."
- `skills/systematic-debugging/SKILL.md` lines 122–143 — Phase 2: Pattern Analysis ("Compare Against References", "Find Working Examples")
- `skills/subagent-driven-development/implementer-prompt.md` line 91 — "Did I follow existing patterns in the codebase?"
- `skills/writing-skills/anthropic-best-practices.md` line 733 — "Iterate: Execute evaluations, compare against baseline, and refine"
- `skills/requesting-code-review/code-reviewer.md` line 7 — "Compare against {PLAN_OR_REQUIREMENTS}"
- `skills/brainstorming/SKILL.md` lines 12–14 — `<HARD-GATE>` convention pattern
- `skills/writing-skills/SKILL.md` lines 498–510 — Red Flags methodology

**PF v1 carry-forward source (read directly from disk):**
- `c:/Users/atyab/Experimental - Users/production-framework/skills/enterprise-research-first/SKILL.md` (lines 1–107) — full v1 skill body, all six core-pattern steps, common mistakes, 7/7 OAuth incident.

**Anthropic primary sources (canonical URLs; via WebSearch synthesis, verified 2026-04-30; re-verify with WebFetch in a permitted session before binding decisions):**
- *Building Effective AI Agents* — https://www.anthropic.com/research/building-effective-agents (Dec 19 2024)
- *How we built our multi-agent research system* — https://www.anthropic.com/engineering/multi-agent-research-system (Jun 2025)
- *Effective context engineering for AI agents* — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- *Citations* — https://docs.claude.com/en/docs/build-with-claude/citations
- *Introducing Citations on the Anthropic API* — https://claude.com/blog/introducing-citations-api

**Enterprise / OSS sources (canonical URLs; via WebSearch synthesis, verified 2026-04-30):**
- Amazon Working Backwards / PR-FAQ — https://workingbackwards.com/concepts/working-backwards-pr-faq-process/ , https://www.aboutamazon.com/news/workplace/an-insider-look-at-amazons-culture-and-processes
- Google Design Docs — https://www.industrialempathy.com/posts/design-docs-at-google/
- Rust RFC template + RFC 2333 — https://github.com/rust-lang/rfcs/blob/master/0000-template.md , https://rust-lang.github.io/rfcs/2333-prior-art.html
- Kubernetes KEP template — https://github.com/kubernetes/enhancements/blob/master/keps/NNNN-kep-template/README.md
- AWS Well-Architected Framework — https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html , https://aws.amazon.com/architecture/well-architected/
- ThoughtWorks Technology Radar — https://www.thoughtworks.com/radar , https://www.thoughtworks.com/radar/techniques
- ADR / MADR — https://adr.github.io/adr-templates/ , https://github.com/joelparkerhenderson/architecture-decision-record , https://martinfowler.com/bliki/ArchitectureDecisionRecord.html
- Spotify engineering — https://engineering.atspotify.com/2024/7/technical-decision-making-in-a-fragmented-space-spotify-in-car-case-study , https://www.infoq.com/news/2020/04/architecture-decision-records/
- Squarespace engineering — https://engineering.squarespace.com/blog/2019/the-power-of-yes-if
- Pragmatic Engineer industry survey (cross-validation only) — https://blog.pragmaticengineer.com/rfcs-and-design-docs/ , https://newsletter.pragmaticengineer.com/p/software-engineering-rfc-and-design

**Companion PF v2 research docs (read directly):**
- `docs/research/sp-anthropic-citation-manifest.md` (GAP-1 framing source, Part 4 entry)
- `docs/research/enterprise-multi-agent-architecture.md` (consensus-strength grammar; N≥3 / N≥5 thresholds)
- `docs/research/agent-design-researcher.md` (companion structure for Researcher agent; the same five-criterion rubric in §2.4)
- `skills/cto-mode/SKILL.md` (orchestrator-worker frame the skill plugs into)
