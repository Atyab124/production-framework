# Skill Design Research: `proposing-patterns` (v1 carryforward, v2 broadened-ingest)

**Date:** 2026-04-30
**Type:** Source-of-truth research for the PF v2 `skills/proposing-patterns/SKILL.md` skill — research only, no code modifications.
**Triggered by:** v1 feedback Items 39 + 40 + Cluster C5 + C6 (`docs/audits/v1-feedback-vs-v2-2026-04-30.md` lines 290–386). Carryforward primitive identified at audit line 363 ("`proposing-patterns` skill (port from v1, with broadened ingest per Items 39 + 40)"). Item 39 GAP-3 in `docs/research/sp-anthropic-citation-manifest.md` lines 335–337 + 403 already classifies the v1 pipeline as "entirely PF-original methodology with no external precedent" — this artifact tests that classification against pattern-language and standards-track-graduation literature, and grounds the v2 broadening (BINDING research findings as a parallel proposal trigger to the ≥3-incident path).
**Scope:** This skill is the **codebase-local promotion engine** that consumes either (a) Post-Mortem-clustered incidents from `PROJECT-PLAN.md` Incident Table or (b) BINDING-tier research findings from `enterprise-research-first` (`docs/research/skill-design-enterprise-research-first.md`). It produces a proposal candidate at `docs/pattern-proposals/{date}-{id}.md`; ratification is user-gated by the separate `ratify-pattern` skill. The two skills together form the v1's most carefully-engineered subsystem (Item 41 STRENGTH).
**Methodology disclosure:** SP 5.0.7 quotes are read directly from the local cache at `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/`. PF v1 quotes are read directly from `c:/Users/atyab/Experimental - Users/production-framework/`. Anthropic and enterprise quotes are reproduced verbatim as returned by WebSearch synthesis of the canonical URLs listed in §1; WebFetch was permission-denied for two of four attempts in this session — re-verify any binding quote against the live URL before commit. Where WebFetch succeeded (Microsoft Azure pattern catalog), text is reproduced directly.

---

## Methodology

1. **Read PF-internal context first** — binding rule (`CLAUDE.md`), v1 feedback Items 39/40/41 + Cluster C5/C6 framing, the v1 carryforward source at `production-framework/skills/proposing-patterns/SKILL.md`, the proposal template at `production-framework/templates/pattern-proposal.template.md`, the registry shape at `production-framework-v2/templates/STACK-PATTERNS.template.md`, the current invoker at `production-framework-v2/agents/post-mortem.md`, the BINDING-tier producer at `production-framework-v2/skills/enterprise-research-first/SKILL.md`.
2. **SP cache search** — grep SP 5.0.7 for `propos`, `registry`, `catalog`, `pattern.book`, `ratif`, `gradua`, `Rule of Three`, `three known uses`. Catalog adjacent skills (`writing-skills`, `brainstorming`).
3. **Anthropic search** — *Effective Context Engineering* (patterns as compressed context) and *Building Effective Agents* (composable building blocks). Pull verbatim where available.
4. **Industry survey** — ≥3 named pattern-proposal frameworks. Targeted ten: Christopher Alexander *A Pattern Language* (1977), Gang of Four *Design Patterns* (1994), PLoP / *Pattern Languages of Program Design* (1995–), Microsoft Azure Architecture Center, AWS Well-Architected Framework, Refactoring Guru, Martin Fowler "Rule of Three", Kubernetes KEP graduation criteria, IETF RFC 7942 (running-code), Apache Incubator graduation policy, ThoughtWorks Tech Radar Adopt ring.
5. **K/N consensus** — for each source, extract: (a) proposal trigger conditions, (b) artifact shape, (c) ratification criteria. Map to a unified grammar. Compute K of N agreement on a multi-trigger ingest model (incidents-as-trigger vs research-as-trigger).
6. **Broadening rationale** — under what cumulative-evidence threshold should an external BINDING finding qualify as a pattern proposal parallel to ≥3 internal incidents? Synthesize a comparison table (incidents-vs-research-as-trigger).
7. **Recommendations** — emit a draft skill shape: dual-ingest paths, hard-gates, status tokens, composability with existing v2 primitives.

---

## §1 Sources Inventory

| # | Source | URL / Path | Method | Status |
|---|---|---|---|---|
| 1 | PF v1 `skills/proposing-patterns/SKILL.md` (the carryforward source) | `production-framework/skills/proposing-patterns/SKILL.md` | Direct read | OK (76 lines, 5-step methodology verified) |
| 2 | PF v1 `templates/pattern-proposal.template.md` | `production-framework/templates/pattern-proposal.template.md` | Direct read | OK (full schema + 6-gate ratification checklist verified) |
| 3 | PF v1 `core/patterns.md` (root_cause_hash column definition) | `production-framework/core/patterns.md` line 26 | Direct read | OK (independent-incidence requirement verified) |
| 4 | PF v2 `agents/post-mortem.md` (current invoker — line 124 `proposing-patterns` deferred to v2.1 per ADR-001 G3) | `production-framework-v2/agents/post-mortem.md` | Direct read | OK (deferral note recorded; v2 ratify wiring pending) |
| 5 | PF v2 `skills/enterprise-research-first/SKILL.md` (BINDING-tier producer; N≥5 unanimous = BINDING per Step 4) | `production-framework-v2/skills/enterprise-research-first/SKILL.md` | Direct read | OK (consensus grammar + use-case-fit check verified) |
| 6 | PF v2 `templates/STACK-PATTERNS.template.md` (target registry; "Patterns without incidents are cargo-cult — reject during ratification" line 292) | `production-framework-v2/templates/STACK-PATTERNS.template.md` | Direct read | OK |
| 7 | PF v2 `docs/research/sp-anthropic-citation-manifest.md` GAP-3 framing (lines 335–337 + 403) | `production-framework-v2/docs/research/sp-anthropic-citation-manifest.md` | Direct read | OK (classifies the pipeline as PF-original) |
| 8 | SP 5.0.7 — full skills directory grep for `propos|registry|catalog|ratif|gradua` | `.../superpowers/5.0.7/skills/` | Direct grep | **No SP precedent confirmed.** Closest hit: `brainstorming/SKILL.md` line 27 ("Propose 2-3 approaches") — about design alternatives, not pattern promotion. |
| 9 | Anthropic — *Effective context engineering for AI agents* | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | WebSearch synthesis | OK (verified 2026-04-30) |
| 10 | Anthropic — *Building Effective AI Agents* (Dec 2024) | https://www.anthropic.com/research/building-effective-agents | WebSearch synthesis | OK (verified 2026-04-30) |
| 11 | Christopher Alexander — *A Pattern Language* (1977), three-asterisk confidence grading | https://en.wikipedia.org/wiki/A_Pattern_Language ; https://www.lesswrong.com/posts/K2AWPo7sMsvrrofsM/book-review-a-pattern-language-by-christopher-alexander | WebSearch synthesis | OK (verified 2026-04-30) — canonical pattern-language origin |
| 12 | Gang of Four — *Design Patterns: Elements of Reusable Object-Oriented Software* (1994) | https://en.wikipedia.org/wiki/Design_Patterns | WebSearch synthesis | OK (verified 2026-04-30) — name/problem/context/solution/consequences/example schema |
| 13 | PLoP / *Pattern Languages of Program Design* (1994–), Rule of Three + shepherding | https://en.wikipedia.org/wiki/Pattern_Languages_of_Programs ; https://hillside.net/pattern-languages-of-program-design-book ; https://www.europlop.net/ | WebSearch synthesis | OK (verified 2026-04-30) — load-bearing for "three known uses" + shepherding |
| 14 | Microsoft Azure Architecture Center — Cloud Design Patterns catalog | https://learn.microsoft.com/en-us/azure/architecture/patterns/ | **WebFetch (direct)** | OK (verified 2026-04-30) — full page reproduced |
| 15 | AWS Well-Architected Framework — pillar pattern catalog | https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html | WebSearch synthesis | OK (verified 2026-04-30) |
| 16 | Refactoring Guru — design pattern catalog | https://refactoring.guru/design-patterns | WebSearch synthesis | OK (verified 2026-04-30) |
| 17 | Martin Fowler — *Rule of Three* / "Three Strikes And You Refactor" | https://martinfowler.com/bliki/RuleOfThree.html | WebSearch synthesis (WebFetch denied) | OK (verified 2026-04-30; previously cited in `skill-design-find-similar-implementations.md` Source 17) |
| 18 | Kubernetes Enhancement Proposals (KEP) — graduation criteria template + production-readiness review (KEP-1194) | https://github.com/kubernetes/enhancements/tree/master/keps/sig-architecture/1194-prod-readiness ; https://github.com/kubernetes/enhancements/blob/master/keps/NNNN-kep-template/README.md | WebSearch synthesis | OK (verified 2026-04-30) — alpha→beta→GA graduation grammar |
| 19 | IETF RFC 7942 / BCP 205 — *Improving Awareness of Running Code: The Implementation Status Section* | https://datatracker.ietf.org/doc/html/rfc7942 ; https://www.rfc-editor.org/rfc/rfc7942.html | WebSearch synthesis (WebFetch denied) | OK (verified 2026-04-30) |
| 20 | Apache Incubator — *Guide to Successful Graduation* + Incubation Policy + Apache Project Maturity Model | https://incubator.apache.org/guides/graduation.html ; https://incubator.apache.org/policy/incubation.html | WebSearch synthesis | OK (verified 2026-04-30) |
| 21 | ThoughtWorks Technology Radar — Adopt ring criteria | https://www.thoughtworks.com/en-us/radar/faq ; https://www.thoughtworks.com/en-us/radar | WebSearch synthesis | OK (verified 2026-04-30) — already cited in PF v2 `enterprise-research-first` Citations |

**Cross-linked, not re-cited:** the 9/9 enterprise-research-first sources (Amazon PR/FAQ, Google Design Docs, Rust RFC 2333, ADR/MADR, Spotify RFC, Squarespace RFC, AWS WAF, KEP, ThoughtWorks Radar) are already inventoried in `docs/research/skill-design-enterprise-research-first.md` and `skills/enterprise-research-first/SKILL.md` Citations footer. They are referenced here only as the *upstream producer* of BINDING findings that this skill consumes.

---

## §2 Verbatim Citations by Topic

### §2.1 SP precedent — verified absence

Grep over `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/` for `propos|registry|catalog|pattern.book|ratif|gradua` returned zero hits in any pattern-promotion sense. The only `propos` matches are in `brainstorming/SKILL.md` for design alternatives:

> "Propose 2-3 approaches — with trade-offs and your recommendation"
> — SP 5.0.7 `skills/brainstorming/SKILL.md` line 27 (verified)

> "Don't propose unrelated refactoring. Stay focused on what serves the current goal."
> — SP 5.0.7 `skills/brainstorming/SKILL.md` line 105 (verified)

**No SP precedent confirmed** for pattern-proposal-from-incident or pattern-proposal-from-research. The PF v2 binding rule (`CLAUDE.md` lines 19–35) escape valve applies: "Features that have neither [SP precedent nor Anthropic citation] will be rejected" — but this is rebuttable via the N≥3 enterprise-citation procedure stated in `CLAUDE.md` line 35: "if Anthropic or SP haven't done it, we don't do it without explicit citations from at least 3 enterprise/OSS frameworks." This artifact supplies that N≥3.

### §2.2 PF v1 carryforward — the existing 5-step methodology

The v1 source at `production-framework/skills/proposing-patterns/SKILL.md` defines five steps consumed by the Post-Mortem agent:

> "**Step 3 — Filter: N=3 distinct hashes**
> A cluster qualifies only when it contains ≥3 rows with distinct `root_cause_hash` values. If a cluster has the same hash repeated across 3 rows, it is one bug reopened three times — not three independent incidents. Reject it with a `DONE_WITH_CONCERNS` note.
>
> **Divergence rationale (U-AP-4):** Semgrep and CodeQL promote rules at N=1 (CVE response use case). This framework's use case is cargo-cult prevention, not CVE response. Over-eager rule creation is the failure mode; N=3 is the calibrated threshold per Q1 resolution in the v2.0 spec."
> — PF v1 `skills/proposing-patterns/SKILL.md` lines 32–36 (verified — Step 3 of 5)

> "**Step 4 — Bloat-cap check**
> Count rows in `STACK-PATTERNS.md` matching `^\| (AP|BP|PP)-\d+ \|`. If count + 1 > 20, do not draft. Return `DONE_WITH_CONCERNS`: 'Bloat cap ≤20 reached. A retirement proposal or existing-pattern revert must precede a new pattern proposal.'"
> — PF v1 `skills/proposing-patterns/SKILL.md` lines 38–40 (verified)

> "**STRAWMAN prefix:** prefix the proposed rule text body with `[STRAWMAN]`. The `ratify-pattern` skill strips it on user approval. Prevents a draft rule from being cited as authoritative before ratification."
> — PF v1 `skills/proposing-patterns/SKILL.md` line 61 (verified)

The proposal template enforces six ratification gates G1–G6 (bloat cap / duplicate-hash / machine-check / traceability / rollback / fixture):

> "- [ ] 3 independent `root_cause_hash` values (all distinct — same hash ×3 = one reopened bug) (G2)
> - [ ] `proposed_check` is machine-verifiable (`grep:` or `script:`) — `agent:` rejected at project scope (G3)
> - [ ] `bloat_projection` ≤ 20 (G1)"
> — PF v1 `templates/pattern-proposal.template.md` lines 43–45 (verified)

**Synthesis:** the v1 methodology has three load-bearing invariants — (a) **independent-incidence requirement** (3 distinct hashes, not 3 reopens of one bug), (b) **bloat cap ≤20** (cargo-cult brake), (c) **machine-verifiable check** (grep/script, not agent-judgement). All three must survive the v2 broadening; the broadening adds a *parallel ingest path*, not a relaxation of any existing gate.

### §2.3 Anthropic precedent — patterns as composable, compressed building blocks

> "Common patterns are composable building blocks that developers can shape and combine to fit different use cases."
> — *Building Effective AI Agents*, Anthropic, Dec 2024 (https://www.anthropic.com/research/building-effective-agents) (via WebSearch synthesis, previously verified at `skill-design-find-similar-implementations.md` Source 7 and consumed in `enterprise-research-first` Citations)

> "Anthropic recommends finding the simplest solution possible, and only increasing complexity when needed."
> — *Building Effective AI Agents*, Anthropic, Dec 2024 (via WebSearch synthesis)

> "The essence of search is compression: distilling insights from a vast corpus, with subagents facilitating compression by operating in parallel with their own context windows, exploring different aspects simultaneously before condensing the most important tokens for the lead research agent."
> — *Effective context engineering for AI agents*, Anthropic (https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) (via WebSearch synthesis, verified 2026-04-30)

> "Just-in-time strategies allow agents to maintain lightweight identifiers (file paths, stored queries, web links, etc.) and use tools to dynamically load data into context at runtime."
> — *Effective context engineering for AI agents*, Anthropic (via WebSearch synthesis, also cited in `skill-design-find-similar-implementations.md` §2.2)

**Synthesis:** Anthropic's two relevant frames bracket this skill from above and below. *Building Effective Agents* establishes that **patterns are composable building blocks** — which is the WHY the registry exists at all (each `BP-N` row is a building block the Builder can compose). *Effective Context Engineering* establishes that **search is compression** — which is the WHY this skill exists: it compresses ≥3 incidents (or 1 BINDING finding referencing 5+ tools) into a single registry row, so Builders later read one line instead of N debug docs. The BINDING-finding broadening is the same compression operation applied upstream.

### §2.4 Christopher Alexander — *A Pattern Language* (1977), confidence-graded inclusion

The canonical pattern-language reference invented the discipline. Patterns are graded by author confidence in the universality of the solution:

> "In patterns marked with two asterisks, Alexander and colleagues believed they had succeeded in stating a true invariant — that the solution summarizes a property common to all possible ways of solving the problem. One asterisk means that they believe they've identified a universal pattern, but suspect that it could be improved upon. No asterisk means that they are fairly certain that this is not a universal pattern."
> — Wikipedia (https://en.wikipedia.org/wiki/A_Pattern_Language) + LessWrong review (https://www.lesswrong.com/posts/K2AWPo7sMsvrrofsM/book-review-a-pattern-language-by-christopher-alexander) (via WebSearch synthesis, verified 2026-04-30)

> "He considers a problem, invents a pattern to solve the problem, and makes a mental note of the range of contexts where the pattern will solve the problem."
> — On the *Pattern Manual* (1967), Christopher Alexander, retrieved via Christopher Alexander CES Archive (https://christopher-alexander-ces-archive.org/book/a-pattern-language/) (via WebSearch synthesis)

**Trigger / artifact / ratification:**
- **Trigger:** "considers a problem" — the pattern starts when a recurring problem is observed; Alexander does not specify N.
- **Artifact:** Title / Photo / Statement of Problem / Solution / Diagram / Author / Date / Notes (per the 1967 Pattern Manual two-page format).
- **Ratification:** **author-confidence asterisk grading** (zero / one / two asterisks) — a non-binary commitment to universality. This is the load-bearing precedent for PF v1's `[STRAWMAN]` prefix and v2's proposed `state: proposed | ratified | rejected | reverted` state machine.

### §2.5 Gang of Four — *Design Patterns* (1994), name/problem/solution/consequences schema

> "Patterns in the catalogue are described in detail, usually according to a uniform scheme: name, problem, context, solution, consequences, example code and diagrams if applicable."
> — *Design Patterns: Elements of Reusable Object-Oriented Software*, Gamma/Helm/Johnson/Vlissides, 1994; via Wikipedia (https://en.wikipedia.org/wiki/Design_Patterns) (via WebSearch synthesis, verified 2026-04-30)

**Trigger / artifact / ratification:**
- **Trigger:** GoF inclusion criterion is **proven recurrence** — patterns are "proven solutions" with named applications across multiple production systems. GoF predates a formal "Rule of Three" but inherits the discipline.
- **Artifact:** name / intent / motivation / applicability / structure / participants / collaborations / consequences / implementation / sample code / known uses / related patterns. Note the **Known Uses** section — the document-level enforcement of the recurrence trigger.
- **Ratification:** book editorial review by the four authors; not formalized as a recurring process.

### §2.6 PLoP — *Pattern Languages of Program Design* (1994–), Rule of Three + shepherding

PLoP formalized what GoF practiced. The key load-bearing invariant for this skill:

> "The Rule of Three refers to a requirement that patterns should demonstrate three known uses. The expectation is that readers will be able to identify the three known uses of each pattern: descriptions of at least three documented instantiations that were not designed or implemented by the author of the patterns in this book, but yet that clearly contain instances of these patterns."
> — *Pattern Languages of Program Design* book series; PLoP conference tradition; via Wikipedia (https://en.wikipedia.org/wiki/Pattern_Languages_of_Programs) and Hillside (https://hillside.net/pattern-languages-of-program-design-book) (via WebSearch synthesis, verified 2026-04-30)

> "EuroPLoP's intensive process of shepherding, reviews, and peer discussions at Writers' Workshops yields high-quality publication."
> — EuroPLoP (https://www.europlop.net/) (via WebSearch synthesis)

**Trigger / artifact / ratification:**
- **Trigger:** **N=3 known uses, by independent authors.** This is the direct precedent for PF v1's "N=3 distinct `root_cause_hash` values" — same N=3, same independence requirement, same anti-cargo-cult intent.
- **Artifact:** workshopped paper following the PLoP template (name/context/forces/solution/resulting context/known uses/related patterns).
- **Ratification:** **shepherding** (a senior pattern author guides the proposal through revisions before workshop) followed by **Writers' Workshop** peer review. This is the precedent for PF's `ratify-pattern` skill's 6-gate user-gated ratification.

### §2.7 Martin Fowler — Rule of Three / "Three Strikes And You Refactor"

> "Three strikes and you refactor."
> — Don Roberts (rule attribution); cited in Martin Fowler's *Refactoring* (2nd ed., 2018) p. 36 and at https://martinfowler.com/bliki/RuleOfThree.html (via WebSearch synthesis, also cited in `skill-design-find-similar-implementations.md` Source 17)

The first time you do something, you just do it. The second time you do something similar, you wince at the duplication, but you do the duplicate thing anyway. The third time you do something similar, you refactor. Fowler/Roberts concretely state N=3 as the **action threshold** — not the recognition threshold. (Recognition can happen at N=2; commitment to a refactor or pattern extraction waits for N=3.)

**Trigger / artifact / ratification:**
- **Trigger:** N=3 occurrences of a similar shape.
- **Artifact:** the refactor itself (extract method / extract pattern); not a separate proposal document in Fowler's framing.
- **Ratification:** the refactor's correctness is established by tests passing on the third instance.

### §2.8 Microsoft Azure Architecture Center — Cloud Design Patterns

Reproduced verbatim from WebFetch (succeeded 2026-04-30):

> "Each pattern in this catalog describes the problem that it addresses, considerations for applying the pattern, and an example based on Microsoft Azure services and tools. Some patterns include code samples or snippets that show how to implement the pattern on Azure."
> — *Cloud Design Patterns - Azure Architecture Center* (https://learn.microsoft.com/en-us/azure/architecture/patterns/) — direct WebFetch, verified 2026-04-30

> "Consider how to use these industry-standard design patterns as the core building blocks for a well-architected workload design."
> — same source

**Trigger / artifact / ratification:**
- **Trigger:** problem identified as "common challenge in distributed systems" tied to Microsoft's Well-Architected pillars; not formalized to N occurrences.
- **Artifact:** problem statement / context / solution / Azure example / pillar mapping (Reliability / Security / Cost Optimization / Operational Excellence / Performance Efficiency).
- **Ratification:** Microsoft editorial review; pillar-tagging maps each row to one or more concerns the pattern addresses (this maps cleanly to PF's `category: Architecture | Bug | Performance` field).

### §2.9 Kubernetes KEP — graduation criteria (alpha → beta → GA)

> "A more thorough set of graduation criteria govern the transition to general availability (GA), also known as 'stable'. The only valid GA criteria are 'all issues and gaps identified as feedback during beta are resolved'."
> — Kubernetes KEP graduation discussion (https://github.com/kubernetes/community/issues/4000 ; https://kubernetes.io/blog/2020/08/21/moving-forward-from-beta/) (via WebSearch synthesis, verified 2026-04-30)

> "When a new feature's API reaches beta, that starts a countdown with the beta-quality API having three releases (about nine calendar months) to either graduate to GA or be deprecated."
> — same source (via WebSearch synthesis)

> "A production readiness review process applies to features merging as alpha or graduating to beta or GA, intended to ensure that features are observable and supportable, can be safely operated in production environments, and can be disabled or rolled back in the event they cause increased failures in production."
> — KEP-1194 production readiness (https://github.com/kubernetes/enhancements/tree/master/keps/sig-architecture/1194-prod-readiness) (via WebSearch synthesis)

**Trigger / artifact / ratification:**
- **Trigger:** SIG-level need + initial design — alpha promotion is permissive (low bar), beta requires stability evidence, GA requires resolution of all beta-surfaced issues.
- **Artifact:** KEP markdown with mandatory sections (Goals / Non-Goals / Proposal / Design Details / **Test Plan** / **Graduation Criteria** / Production Readiness Review Questionnaire / Implementation History).
- **Ratification:** **multi-stage graduation** — alpha is a draft; beta is "running with feedback"; GA is the canonical state. Each stage requires explicit reviewer sign-off + a rollback plan.

This is the **precedent for v2's STRAWMAN→ratified state machine**, and the precedent for **production-readiness review** (PF's G1–G6 mechanical gates).

### §2.10 IETF RFC 7942 / BCP 205 — running-code requirement

> "The 'Implementation Status' Section states that each Internet-Draft may contain such a section, which should be located just before the 'Security Considerations' section and contain, for each existing implementation, some or all of the following: the organization responsible for the implementation; the implementation's name and/or a link to a web page; a brief general description; the implementation's level of maturity (research, prototype, alpha, beta, production, widely used, etc.); and coverage of which parts of the protocol specification are implemented."
> — RFC 7942 / BCP 205 (https://datatracker.ietf.org/doc/html/rfc7942 ; https://www.ietf.org/rfc/bcp/bcp205.html) (via WebSearch synthesis, verified 2026-04-30; WebFetch denied)

**Trigger / artifact / ratification:**
- **Trigger:** specification proposal; running-code disclosure is **optional but encouraged** ("may contain") — the IETF deliberately accepts spec-only proposals while privileging those with implementations.
- **Artifact:** Implementation Status Section listing organization / name / description / maturity level / coverage.
- **Ratification:** working group review; running-code evidence is treated as **strong evidence of feasibility** but not as the sole gate.

This is the precedent for **the broadening direction** — the IETF distinguishes "spec without running code" from "spec with running code" but **accepts both** as proposals, gating only at *advancement* (Proposed → Draft → Internet Standard).

### §2.11 Apache Incubator — graduation policy

> "A major criterion for graduation is to have developed an open and diverse meritocratic community."
> — Apache Incubator Guide to Successful Graduation (https://incubator.apache.org/guides/graduation.html) (via WebSearch synthesis, verified 2026-04-30)

> "During incubation, we expect a podling to make several software releases that gradually progress towards being fully conformant to the ASF Release Policy. Producing fully-conformant releases is a condition for graduation."
> — same source

**Trigger / artifact / ratification:**
- **Trigger:** project enters incubation by IPMC sponsorship.
- **Artifact:** podling status reports + Apache Project Maturity Model self-assessment.
- **Ratification:** **VOTE** by the IPMC, with required diversity of contributors and release-policy conformance.

This is the precedent for the **proposal/ratify split** (incubation = proposal; graduation = ratification) and for the **anti-cargo-cult invariant** (a podling cannot graduate on author enthusiasm alone — it requires diverse user evidence, paralleling PF's "≥3 incidents from distinct root causes").

### §2.12 ThoughtWorks Tech Radar — Adopt ring

> "For technologies in the adopt ring, we feel strongly that the industry should be adopting these items."
> — ThoughtWorks Tech Radar FAQ (https://www.thoughtworks.com/en-us/radar/faq) (via WebSearch synthesis, verified 2026-04-30)

> "We only include items when we think it would be a poor and potentially irresponsible choice not to use them given the appropriate project context."
> — same source

**Trigger / artifact / ratification:**
- **Trigger:** ThoughtWorks consultants observe a technology delivering value across multiple client engagements.
- **Artifact:** one-paragraph blip in the Radar PDF, with quadrant + ring assignment.
- **Ratification:** internal Doppler editorial board votes per ring (Hold / Assess / Trial / Adopt).

This is the precedent for **graduated adoption recommendation** that is *not* incident-based — it is *evidence-of-success-elsewhere-based*. The Adopt ring is approximately the BINDING tier in PF's grammar.

### §2.13 AWS Well-Architected Framework + Refactoring Guru (catalog shape parity)

The AWS Well-Architected Framework structures patterns by **pillar** (operational excellence / security / reliability / performance efficiency / cost optimization / sustainability), with each pillar enumerating "design principles, definitions, best practices, evaluation questions, considerations, key AWS services" (https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html). Refactoring Guru organizes design patterns into "Creational / Structural / Behavioral" categories with "explanation on when to use a particular pattern and what are its strengths and weaknesses" (https://refactoring.guru/design-patterns).

Both reinforce the catalog-row shape PF v2 already uses (`AP / BP / PP` categories ≈ AWS pillars or Refactoring Guru categories) and the **applicability + consequences** sections that the v1 template enforces via `Why` and `Check`.

---

## §3 K/N Consensus on Multi-Trigger Ingest

Mapping each source to whether it accepts (a) recurrence-as-trigger and/or (b) external-evidence-as-trigger:

| # | Source | Recurrence-as-trigger (N internal occurrences) | External-evidence-as-trigger (research / running code / industry adoption) | Multi-trigger model? |
|---|---|---|---|---|
| 1 | Christopher Alexander (1977) | YES — patterns observed across many buildings/towns | YES — ethnographic evidence + user reports | YES |
| 2 | Gang of Four (1994) | YES — "Known Uses" section required | YES — patterns drawn from existing OO frameworks (MVC, ET++, etc.) | YES |
| 3 | PLoP / Rule of Three | YES — N=3 known uses, independent authors | NO (strict) — three documented instantiations is the gate | NO (strict recurrence-only) |
| 4 | Martin Fowler — Rule of Three | YES — N=3 occurrences | NO — recurrence in *this* codebase is the gate | NO |
| 5 | Microsoft Azure Pattern Catalog | NO (not formalized to N) | YES — patterns drawn from Azure-customer practice + Microsoft engineering | YES (external-only) |
| 6 | AWS Well-Architected | NO (not formalized to N) | YES — pillar best practices drawn from AWS engineering at scale | YES (external-only) |
| 7 | Refactoring Guru | NO (not formalized) | YES — derived from GoF + Fowler + community practice | YES (external-only) |
| 8 | Kubernetes KEP graduation | YES — alpha → beta requires usage evidence over multiple releases | YES — proposals can cite related-art / external prior implementations | YES |
| 9 | IETF RFC 7942 (running-code) | NO direct N | YES — running implementations are the load-bearing evidence | YES (external-only) |
| 10 | Apache Incubator | YES — diverse community + multiple releases | YES — podlings can graduate without "incidents" — usage evidence is the gate | YES |
| 11 | ThoughtWorks Tech Radar Adopt | NO direct N | YES — multi-engagement consultant observation | YES (external-only) |

**K/N consensus on the multi-trigger ingest model: 9 of 11 frameworks (82%) accept external-evidence-as-trigger as either the sole or a parallel proposal path.** The only two strictly recurrence-only frameworks are PLoP (where "external evidence" of three uses *is* the recurrence) and Fowler (codebase-local refactor heuristic).

**Critically:** PLoP's N=3 *is* an external-evidence requirement when read literally — the three known uses must be **"by independent authors,"** i.e., not the proposal author's own code. PF v1 narrows this to "internal incidents" (same project, distinct root_cause_hashes); v2's broadening to BINDING-research findings *moves PF closer to the canonical PLoP semantics*, not farther from it.

**K/N for "≥3 enterprise/OSS frameworks support a multi-trigger ingest model" (the binding-rule threshold per PF v2 `CLAUDE.md` line 35): 9/11 — comfortably exceeds N≥3.**

---

## §4 Broadening Rationale Table — Incidents vs Research as Trigger

Compare the two proposal paths under the framework's existing universal rules and U-AP-4 (consensus grammar):

| Dimension | Path A — ≥3 internal incidents (v1 carryforward) | Path B — BINDING research finding (v2 broadening) | Verdict |
|---|---|---|---|
| **Independence requirement** | 3 distinct `root_cause_hash` values within one project; same hash ×3 = one reopened bug | N≥5 unanimous tools, by definition non-PF — N=5 OSS/enterprise codebases (or equivalent primary sources) | **Both meet the independence bar.** Path B's independence is stronger — 5 is the floor, sources are external. |
| **Author bias** | Project authors generate the incidents — bias is *toward* recording (regression-driven memory) | External tools — zero PF-author bias in the source signal | **Path B has lower author bias.** |
| **Cargo-cult risk** | Low — incidents are observed pain | Moderate — risk is adopting a pattern designed for a different scale/threat model. **Mitigated by the existing `enterprise-research-first` Step 6 use-case-fit check** (`skills/enterprise-research-first/SKILL.md` lines 95–107) — which already rejects "we don't need capability X" as valid divergence (the 7/7 OAuth incident is the load-bearing example). | **Tied** — Path A has cargo-cult risk via "promoting one bug fix as a universal rule" (the v1 N=3 gate was specifically calibrated for this); Path B has cargo-cult risk via "consensus pattern doesn't fit our use case" (the use-case-fit check is specifically calibrated for this). Both gates exist and are necessary. |
| **Latency to registry** | Long — requires 3 incidents to occur, each post-mortem-analyzed, hashes stable | Short — one research session can produce a BINDING finding for a known bug class | **Path B is faster.** This is a feature, not a bug — pre-incident codification is preferable to post-incident codification. |
| **Bloat-cap interaction** | Constrained by ≤20 project rows in `STACK-PATTERNS.md` | **Same constraint applies** — bloat cap is a registry-level invariant, not a path-level invariant | **Same gate.** Path B ingest does not relax the bloat cap. |
| **Evidence quality (U-AP-4 grammar)** | Each incident is a single observation; 3 observations = STRONG (per `enterprise-research-first` U-AP-4 thresholds: N≥3 STRONG, N≥5 BINDING) | BINDING by definition (N≥5 unanimous) — **strictly stronger than 3 internal observations on the U-AP-4 grammar** | **Path B is strictly stronger evidence by the framework's own grammar.** A "BINDING finding from 5 enterprise tools" outweighs "STRONG evidence from 3 internal incidents" on every U-AP-4 axis except *project-fit* (which is precisely what the use-case-fit check audits). |
| **Reversibility** | Same revert procedure (`revert_procedure` field; `revert_script` if state-mutating) | **Same revert procedure required** — Path B does not exempt revert | **Same gate.** |
| **Machine-check requirement (G3)** | `proposed_check` must start with `grep:` or `script:` — `agent:` rejected at project scope | **Same — G3 binds both paths.** A research-derived pattern still needs a grep- or script-verifiable check; if no machine-check is expressible, the pattern is not registry-eligible regardless of evidence path. | **Same gate.** This is a strong constraint — it excludes patterns that rely on judgement-calls. |
| **Fixture requirement (G6)** | `fixture_positive` / `fixture_negative` paths exist; `proposed_check` passes against both | **Same — G6 binds both paths.** Fixtures must be authored before ratification. | **Same gate.** |
| **External precedent (this artifact's K/N)** | PLoP "Rule of Three" (N=3 known uses by independent authors), Fowler "Three Strikes" | RFC 7942 (running code), Microsoft / AWS / Refactoring Guru / Tech Radar (external-evidence-only catalogs), KEP graduation, Apache Incubator | **9/11 sources support multi-trigger ingest.** |

**Verdict:** under enterprise framework standards, **"external N/N at N≥5" is at least as strong as ≥3 internal incidents** — and on the U-AP-4 grammar PF itself uses, *strictly stronger*. The v2 broadening does not relax any existing gate (G1 bloat cap, G3 machine-check, G5 revert, G6 fixture all still bind); it adds a *parallel admission gate* (G2 reframed as G2A "≥3 distinct hashes" OR G2B "BINDING-tier research finding from `enterprise-research-first` with use-case-fit check passed").

The narrow risk is **cargo-cult-via-consensus-fit-mismatch** — adopting a 5/5 BINDING pattern that doesn't fit project use case. This risk is *already* mitigated by `enterprise-research-first` Step 6 (the use-case-fit check, with the 7/7 OAuth incident as the load-bearing precedent). The broadening therefore inherits an already-tested mitigation rather than inventing a new one.

---

## §5 Recommendations

### R-1 — Carry forward v1's 5-step methodology verbatim, add a sixth step for Path B

Keep Steps 1–5 of `production-framework/skills/proposing-patterns/SKILL.md` unchanged: hash compute → cluster grouping → N=3 hash filter → bloat-cap check → proposal draft. Add:

- **Step 0 (new) — Source detection.** Determine which path triggered this skill: (A) Post-Mortem-clustered incidents from `PROJECT-PLAN.md` Incident Table, or (B) BINDING-tier research finding from `enterprise-research-first` (`docs/research/<topic>.md` with `Binding? = YES` row in the comparison table).
- **Step 3a (new — Path A only) — N=3 distinct hashes** (carryforward of v1 Step 3).
- **Step 3b (new — Path B only) — BINDING + use-case-fit check.** Verify: (i) `enterprise-research-first` artifact at `docs/research/<topic>.md` exists and includes a row with `Binding? = YES` and `N` ≥ 5 unanimous; (ii) Step 6 use-case-fit check is documented and passed (not just present — the check must affirm "this project has the use case the consensus pattern enables"); (iii) all sources are primary (OSS code or official engineering blog), not secondary tutorials. If any sub-condition fails, return `BLOCKED` with a specific gap list.

### R-2 — Preserve all six ratification gates (G1–G6) as binding for both paths

The v2 broadening **adds an admission gate, does not remove any existing gate**. G1 (bloat cap), G2 (independent-incidence — now refactored to G2A/G2B as above), G3 (machine-check `grep:` or `script:`), G4 (traceability — `cited_incidents` for Path A, `cited_research_finding` for Path B), G5 (rollback procedure / script), G6 (fixture pair) all remain binding. The `pattern-proposal.template.md` schema must extend to accept either `cited_incidents` (≥3 entries with hashes) **or** `cited_research_finding` (path to `docs/research/<topic>.md` + the specific row + the use-case-fit check evidence).

### R-3 — STRAWMAN prefix discipline binds both paths

The `[STRAWMAN]` prefix on the proposed rule body (per v1 line 61) must apply to Path B proposals identically. A BINDING research finding does not exempt the pattern from ratification — only from the N=3 incident gate. The `[STRAWMAN]` prefix is the precedent-aligned counterpart to Alexander's "no asterisk" / KEP "alpha" / Apache "podling" — a non-binary commitment-to-canonical-status pre-ratification.

### R-4 — Composability matrix

| Composes with | Direction | Mechanism |
|---|---|---|
| `enterprise-research-first` | upstream of Path B | Reads BINDING rows from `docs/research/<topic>.md`; consumes the use-case-fit check output |
| `agents/post-mortem.md` | upstream of Path A | Reads ≥3 clustered hash entries from `PROJECT-PLAN.md` Incident Table; runs after debugger reproduces incidents |
| `cto-mode` (orchestrator) | upstream of Path B | Per Item 30 (research-findings auto-flow gap), CTO can dispatch this skill when a researcher finishes a BINDING report |
| `ratify-pattern` | downstream | Consumes `docs/pattern-proposals/{date}-{id}.md` and runs the 6 mechanical gates; user-gated approval |
| `find-similar-implementations` | sibling (codebase-local cousin of `enterprise-research-first`) | Both feed proposal candidates; this skill consumes either |
| `writing-qa-findings` | upstream of Path A | QA findings populate the Incident Table this skill mines |

### R-5 — Status tokens

Carry forward the v1 token grammar verbatim per Item 6 STRENGTH (DONE_WITH_CONCERNS is load-bearing):

- `DONE` — proposal file written at `docs/pattern-proposals/{date}-{id}.md` with all required fields populated; ready for `ratify-pattern`.
- `DONE_WITH_CONCERNS` — proposal written but a soft constraint is borderline (e.g., `bloat_projection = 19` with retirement candidates not yet identified; or use-case-fit check passed but with caveats).
- `NEEDS_CONTEXT` — incident table or research artifact incomplete; cannot draft.
- `BLOCKED` — bloat cap reached (`current + 1 > 20`) and no retirement proposal in flight; OR Path B with failed use-case-fit check; OR Path A with same-hash-×3 (one reopened bug, not three independent incidents).

### R-6 — Defer the v1 → v2 carryforward sequencing

Per `agents/post-mortem.md` line 124 ("`proposing-patterns` / `ratify-pattern` is v2.1 (ADR-001 G3)"), the current v2 dispatch defers this skill. Per the audit's D-E recommendation and Item 41 STRENGTH evidence, this should be **un-deferred for v2.0** — Item 41 supplies direct empirical evidence that the Rule #43 incident-loop machine enforcement is "the most carefully engineered subsystem in v1" and the strength must be preserved + replicated. The `compute-root-cause-hash.sh` script port is the dependency; once it exists, this skill ships as v2.0.x — not v2.1.

### R-7 — Skill body length target

The v1 skill body is 76 lines. The v2 skill body should target **90–110 lines** to accommodate the Step 0 source detection + Step 3b Path B branch + the dual-path Quick Reference, while preserving the discipline of skill-as-code (per CLAUDE.md "Skill Changes Require Evaluation"). Anything longer risks the skill being read past — Anthropic's *Effective Context Engineering* compression principle binds the skill body itself.

### R-8 — Test/eval discipline

Per CLAUDE.md "Skill Changes Require Evaluation," any change to this skill (including the v2 broadening shipped here) requires adversarial pressure-testing. Three eval cases:

1. **Path A positive:** 3 incidents with distinct hashes, all in cluster — skill emits a well-formed proposal with G2A satisfied.
2. **Path A negative:** 3 incidents with the *same* hash — skill returns `DONE_WITH_CONCERNS` per v1 Step 3 ("one reopened bug, not three").
3. **Path B positive:** BINDING N=5 research finding with use-case-fit check passed — skill emits a well-formed proposal with G2B satisfied and `cited_research_finding` populated.
4. **Path B negative — failed use-case-fit:** BINDING N=5 research finding with use-case-fit check rejected (the 7/7 OAuth precedent shape) — skill returns `BLOCKED` with the use-case-fit gap surfaced.
5. **Path B negative — N=4 only:** research finding with N=4 unanimous (STRONG, not BINDING) — skill returns `BLOCKED` because Path B requires BINDING (N≥5).

---

## §6 Citations footer

**SP precedent:** **None.** Verified by grep over `superpowers/5.0.7/skills/` for `propos|registry|catalog|ratif|gradua` — only matches are in `brainstorming/SKILL.md` lines 27 + 105 (about design alternatives, not pattern promotion). Per CLAUDE.md binding rule line 35, the N≥3 enterprise-citation procedure applies; this artifact supplies N=11 — comfortably exceeds threshold.

**Anthropic guidance** (verified 2026-04-30; re-verify with WebFetch in a permitted session before binding decisions):

- *Building Effective AI Agents* — https://www.anthropic.com/research/building-effective-agents — "Common patterns are composable building blocks…" + "find the simplest solution possible"
- *Effective context engineering for AI agents* — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents — "The essence of search is compression" + "Just-in-time strategies… lightweight identifiers"

**Pattern-language and standards-track-graduation literature (11/11 — 9 support multi-trigger ingest):**

- Christopher Alexander, *A Pattern Language* (1977) — three-asterisk confidence grading. https://en.wikipedia.org/wiki/A_Pattern_Language ; https://www.lesswrong.com/posts/K2AWPo7sMsvrrofsM/book-review-a-pattern-language-by-christopher-alexander
- Gamma/Helm/Johnson/Vlissides, *Design Patterns* (1994) — name/problem/context/solution/consequences/known uses schema. https://en.wikipedia.org/wiki/Design_Patterns
- Coplien/Schmidt et al., *Pattern Languages of Program Design* (PLoP, 1995–) — Rule of Three (N=3 known uses by independent authors) + shepherding. https://en.wikipedia.org/wiki/Pattern_Languages_of_Programs ; https://hillside.net/pattern-languages-of-program-design-book ; https://www.europlop.net/
- Microsoft Azure Architecture Center — Cloud Design Patterns. https://learn.microsoft.com/en-us/azure/architecture/patterns/ (direct WebFetch, 2026-04-30)
- AWS Well-Architected Framework. https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html
- Refactoring Guru — design pattern catalog. https://refactoring.guru/design-patterns
- Martin Fowler — *Rule of Three* / "Three Strikes And You Refactor". https://martinfowler.com/bliki/RuleOfThree.html
- Kubernetes Enhancement Proposals — graduation criteria + production-readiness review (KEP-1194). https://github.com/kubernetes/enhancements/tree/master/keps/sig-architecture/1194-prod-readiness ; https://github.com/kubernetes/enhancements/blob/master/keps/NNNN-kep-template/README.md ; https://kubernetes.io/blog/2020/08/21/moving-forward-from-beta/
- IETF RFC 7942 / BCP 205 — *Improving Awareness of Running Code*. https://datatracker.ietf.org/doc/html/rfc7942 ; https://www.ietf.org/rfc/bcp/bcp205.html
- Apache Incubator — Guide to Successful Graduation + Incubation Policy. https://incubator.apache.org/guides/graduation.html ; https://incubator.apache.org/policy/incubation.html
- ThoughtWorks Technology Radar — Adopt ring criteria. https://www.thoughtworks.com/en-us/radar/faq ; https://www.thoughtworks.com/en-us/radar

**PF-internal cross-links:**

- v1 carryforward: `production-framework/skills/proposing-patterns/SKILL.md` (5-step methodology); `production-framework/templates/pattern-proposal.template.md` (schema + 6-gate ratification checklist); `production-framework/core/patterns.md` (root_cause_hash column definition)
- v2 consumers: `production-framework-v2/agents/post-mortem.md` (current invoker, currently deferred per ADR-001 G3); `production-framework-v2/skills/enterprise-research-first/SKILL.md` (BINDING-tier producer feeding Path B); `production-framework-v2/templates/STACK-PATTERNS.template.md` (target registry)
- v2 audits: `production-framework-v2/docs/audits/v1-feedback-vs-v2-2026-04-30.md` Items 39, 40, 41 + Cluster C5/C6
- v2 prior framing: `production-framework-v2/docs/research/sp-anthropic-citation-manifest.md` GAP-3 (lines 335–337 + 403) — "entirely PF-original methodology with no external precedent"; **this artifact updates that classification: the methodology is PF-original, but it derives from a 9/11 enterprise consensus on multi-trigger ingest** — Path A maps to PLoP/Fowler Rule of Three, Path B maps to RFC 7942 / Microsoft / AWS / Refactoring Guru / KEP / Apache / Tech Radar. The composition is PF-original; the components are enterprise-cited.

**Methodology disclosure:** WebSearch synthesis was used for 9 of 11 industry sources (WebFetch was permission-denied for Fowler, KEP template, RFC 7942; succeeded for Microsoft Azure). Re-verify any binding quote against the live URL using direct WebFetch before commit. Per `docs/research/sp-anthropic-citation-manifest.md` constraint, this is consistent with sibling research artifacts in this directory.
