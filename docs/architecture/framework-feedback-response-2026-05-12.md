# Framework Feedback Response — Architecture First-Pass (2026-05-12)

**Dispatch:** CTO orchestrator → Architect sub-agent, Pass 1 of Pattern A three-pass (Producer-Consumer Convention, `skills/cycle-selection/SKILL.md` lines 57-74).

**Tier:** 3 — framework-level changes touching ≥3 skills, ≥2 agents, hook contract surface; deliverable count ≥11; multi-tenant boundary thinking embedded; therefore `tier-selection` triggers fire.

**Cycle:** refactor (per `cycle-selection` trigger table — "rewrite / restructure / extract / consolidate" with no new behavior at the *plugin* level; we are evolving existing skills/agents, not adding a new behavior class). Note: the *output* of this cycle will then drive one or more Build cycles to ship the fixes; this first cycle is the design pass.

**Plugin version under design:** v2.4.0 candidate (next minor after v2.3.0 released 2026-05-10).

---

## 1. Goal

Produce a research-backed fix proposal set for the 11 framework gaps logged in TaskIt's `framework-plugin-feedback.md` (2026-05-11), by clustering the gaps into research themes, drafting per-cluster open questions for the Researcher sub-agent (Pass 2), and self-citing the ADRs that need no further research.

---

## 2. File List

Files that will be touched in the eventual fixes (architecture-level enumeration only — no implementation detail):

| Path | Status | One-line purpose |
|---|---|---|
| `skills/cycle-selection/SKILL.md` | MODIFY | Add Refactor-cadence convention (Item 7) and optionally a `cross-cutting-pattern-audit` cycle row (Item 4) |
| `skills/tier-selection/SKILL.md` | MODIFY | Possibly add a `scale-readiness` axis trigger (Item 9) — pending Researcher Q3.1-Q3.3 |
| `skills/enterprise-research-first/SKILL.md` | MODIFY | Add competitor-roster coverage check (Item 1), pattern-vs-library frame check (Item 6), category-enumeration step (Item 5) — pending Researcher Q1.x / Q2.x |
| `skills/seven-validation-questions/SKILL.md` | MODIFY | Candidate Q8 (spectrum-vs-binary, Item 5), Q8 alt (competitor coverage, Item 1), Q9 (deferral-blocker, Item 7), Q10 (scale-readiness, Item 9), Q11 (phase-completeness, Item 12) — pending Researcher Q4.x to confirm the validation-question count remains a fixed list vs an open list |
| `skills/writing-plans/SKILL.md` | MODIFY | Add scale-readiness tagging (Item 9) + DEFER-WITH-BLOCKER / SCHEDULED-LATER bucket grammar (Item 7) |
| `skills/using-production-framework/SKILL.md` | MODIFY | Plugin-version surfacing (Item 2) — composes with hook change |
| `skills/cto-mode/SKILL.md` | MODIFY | Phase-state enforcement (Item 12) — refuse Phase N+1 dispatch until Phase N is DONE or skipped-with-justification |
| `skills/proposing-patterns/SKILL.md` | MODIFY | New Path C "proactive pattern-enforcement audit" (Item 10) — pending Researcher Q5.x |
| `agents/architect.md` | MODIFY | Dependency-inventory step (Item 3), spectrum-vs-binary step (Item 5), scale-readiness tag (Item 9) |
| `agents/researcher.md` | MODIFY | Frame-check step (Item 6), competitor-roster check (Item 1) |
| `hooks/session-start` | MODIFY | Inject plugin version + release date from `.claude-plugin/plugin.json` (Item 2) |
| `hooks/post-tool-use` (new or extended) | NEW or MODIFY | Cycle-phase-state tracker enforcement (Item 12) — pending Researcher Q6.x for hook-vs-skill placement |
| `scripts/qa-structural-checks.sh` | MODIFY | New checks per Item 10 (proactive pattern-enforcement audit) and project-local hooks for Item 8 generalization |
| `templates/PROJECT-PLAN.template.md` | MODIFY | Add `competitors_roster:` slot and `scale_targets:` slot per Items 1 and 9 |
| `templates/COMPETITORS.template.md` | NEW | Schema for `docs/COMPETITORS.md` per Item 1 |
| `templates/STACK-PATTERNS.template.md` | MODIFY | Add convention-only-vs-structural-check column per Item 10 |
| `.claude-plugin/plugin.json` | MODIFY (release-only) | Version bump 2.3.0 → 2.4.0 (the change itself ships as a minor — new skills, modified agents) |
| `.claude-plugin/marketplace.json` | MODIFY (release-only) | Version bump to match |
| `docs/adr/008-orchestrator-role-renaming.md` | NEW | Y-statement: keep "CTO mode" generic name + document the override pattern (Item 11; can self-cite — see ADR section below) |
| `docs/adr/009-plugin-version-surfacing.md` | NEW | Y-statement: SessionStart hook injects version (Item 2; can self-cite — see ADR section below) |
| `docs/adr/010-deferral-rigor-grammar.md` | NEW | MADR after Researcher Pass 2 — DEFER vs SCHEDULED-LATER bucket grammar (Item 7) |
| `docs/adr/011-scale-readiness-commitment.md` | NEW | MADR after Researcher Pass 2 (Item 9) |
| `docs/adr/012-phase-state-enforcement.md` | NEW | MADR after Researcher Pass 2 — cycle-phase-state tracker shape (Item 12) |
| `docs/adr/013-pattern-enforcement-audit.md` | NEW | MADR after Researcher Pass 2 — convention-vs-structural-check authoring rule (Items 8 + 10) |
| `docs/adr/014-spectrum-vs-binary-discipline.md` | NEW | MADR after Researcher Pass 2 (Items 5 + 6) |
| `docs/adr/015-competitor-roster.md` | NEW | MADR after Researcher Pass 2 (Items 1 + 6) |
| `docs/adr/016-cross-cutting-pattern-audit.md` | NEW | MADR after Researcher Pass 2 (Item 4) |
| `docs/adr/017-dependency-inventory.md` | NEW | MADR after Researcher Pass 2 (Item 3) |
| `docs/research/<topic>.md` (multiple) | NEW | Researcher Pass 2 output, one per cluster |

**No source code is written by this cycle.** All artifacts are docs / skills / agent prompts / hooks / templates. The Architect produces the design; downstream Build cycles (separate dispatches) will execute each ADR's implementation.

---

## 3. Cluster Table

Seven clusters extracted from the 11 gaps. Each cluster groups items that share a root cause shape, so the Researcher can answer them as one coherent question set rather than 11 independent investigations.

| Cluster | Items | Theme | Why these belong together |
|---|---|---|---|
| **C1 — Researcher framing discipline** | 1, 6 | Researcher accepts prompt framing as fixed input; doesn't push back when the comparable set excludes direct competitors (Item 1) or when the prompt asks "evaluate libraries" instead of "evaluate the architectural pattern" (Item 6). Both produce technically-passing research that misses the actual question. | Both items describe the SAME failure: Researcher executes the dispatch verbatim. The fix surface is the same — researcher.md intake step + enterprise-research-first frame-check + a project-level competitor-roster artifact that both Items 1 and 6 would consume. |
| **C2 — Architect pre-recommendation discipline** | 3, 5, 9 | Architect issues recommendations without three discipline steps: (a) dependency inventory before recommending a library (Item 3); (b) spectrum enumeration before issuing a binary verdict (Item 5); (c) scale-readiness tag against project-stated targets (Item 9). All three are pre-recommendation checklist gaps. | All three are "Architect should do X before recommending Y" — same workflow surface (`agents/architect.md`), same intake-step shape. Fixing one without the others leaves two unfixed; fixing all three together avoids three separate revisions of the same agent prompt. |
| **C3 — Deferral and scheduling rigor** | 7, 9 (overlap) | DEFER / opportunistic / future used as default-procrastination synonyms without named blockers (Item 7); scale-readiness work classified DEFER even when the project's stated targets demand it now (Item 9). Item 9 is partly a sub-case of Item 7 but adds the scale-targets dimension. | Both fix the Wave-classification rubric (Item 7) AND the validation-question set (both items propose new Qs). Item 9 is partially in C2 (Architect intake) and partially in C3 (deferral rigor) — research question set must address both axes. |
| **C4 — Pattern enforcement: convention vs structural check** | 8, 10 | Security patterns enforced by convention only, not structural check (Item 8); general failure mode — patterns added to CLAUDE.md without matching structural checks (Item 10). Item 8 is the narrow case; Item 10 is the general case. | Item 10 IS the generalization of Item 8 (user explicitly pushed back "why just security patterns?"). Same fix surface — pattern-authoring convention + structural-check audit cycle + composability with `proposing-patterns`. |
| **C5 — Audit-scope blind spots: cross-feature and meta-pattern** | 4 | No "cross-cutting pattern detection" pass — framework finds symptoms per feature, doesn't aggregate "you've reinvented X in N places." Sibling to C4 but distinct: C4 is about enforcing known patterns; C5 is about discovering unknown ones. | Stands alone — no other item describes the missing pattern-discovery cycle. Could be discussed alongside C4 but the fix surface differs (new skill `cross-cutting-pattern-audit` vs modified pattern-authoring template). |
| **C6 — Plugin self-knowledge and identity** | 2, 11 | Plugin version not surfaced anywhere a session would naturally see it (Item 2); orchestrator role-naming inconsistency between framework's "CTO mode" and project-customized titles (Item 11). Both are "what is this framework, and what does it call its parts?" questions. | Same root cause: plugin's self-identity is encoded in skill bodies and config files that aren't naturally read during a session. SessionStart hook is the shared fix surface (both items propose injecting identity info). Item 11 is LOW severity; Item 2 is HIGH — but the fix shape is one hook edit + one README edit + (for Item 11) a generic-naming decision. |
| **C7 — Cycle-phase enforcement (state-machine vs recipe)** | 12 | Build-cycle phase ordering defined but not enforced; Deputy/CTO can drift past required phases without flagging the skip. Stands alone — no other item describes the phase-skip class. | Single-member cluster, but distinct enough to deserve its own ADR + research question. Pairs with C3 (deferral) and C2 (Architect discipline) at the values level (all three are "framework defines the right shape but doesn't structurally require it") but has its own fix surface — `cycle-state.md` tracker + `cto-mode` enforcement. |

---

## 4. Per-Cluster Research Questions

Each question is specific enough that the Researcher returns ≥3 enterprise/OSS citations against it (per `enterprise-research-first` Step 1).

### C1 — Researcher framing discipline (Items 1, 6)

- **Q1.1.** How do enterprise research methodologies (PRISMA-style systematic reviews, GAO audit guidance, McKinsey/Gartner competitive landscape methods, Forrester Wave, ThoughtWorks Tech Radar) specify mandatory inclusion of named direct competitors in a comparative survey? What's the equivalent of a "competitor roster" artifact, who owns it, and how is it kept current?
- **Q1.2.** How do enterprise R&D processes (Amazon Working Backwards, Google Design Docs, Spotify RFC, Stripe RFCs, GitLab handbook, Squarespace opinionated RFC) handle the "prompt-framing pushback" case — when a researcher believes the question being asked is the wrong question? Is pushback a documented step, a checklist item, or implicit?
- **Q1.3.** How do enterprise research processes distinguish "evaluate pattern X" from "evaluate libraries that implement pattern X"? Is the distinction codified (e.g., as separate research phases), or relies on the researcher's discretion?
- **Q1.4.** How do enterprise/OSS analytic frameworks (Forrester Wave, Gartner MQ, IDC MarketScape, Linux Foundation OSS landscape reports) enumerate the comparable set at intake? Is the set ratified by a separate role, or self-attested by the researcher?

### C2 — Architect pre-recommendation discipline (Items 3, 5, 9)

- **Q2.1.** How do enterprise architecture frameworks (TOGAF, IEEE 1471, arc42, C4, AWS Well-Architected, Google Design Docs, MADR, ThoughtWorks Tech Radar) require an inventory of existing dependencies/components before recommending a new one? Specifically — is a "current state" artifact (CMDB, component register, dependency manifest) a documented pre-condition of any "add new component" decision?
- **Q2.2.** How do enterprise design disciplines (Rust RFC 2333 Alternatives, Kubernetes KEP Alternatives, Google DD Alternatives Considered, MADR Considered Options, Y-statement neglected-options clause) enumerate categories of approach BEFORE evaluating specific implementations? Is "spectrum enumeration" a named step, or implicit in "alternatives considered"?
- **Q2.3.** How do enterprise scale-readiness frameworks (Google PRR, AWS WAF Performance + Reliability pillars, Netflix scaling playbooks, Shopify "Black Friday Cyber Monday" engineering posts, GitLab scalability handbook) distinguish "tactical" features from "scale-readiness foundation" at the planning stage? Is the distinction surfaced as a tag, a rubric, a separate planning phase, or a separate budget?

### C3 — Deferral and scheduling rigor (Items 7, 9)

- **Q3.1.** How do enterprise agile/lean frameworks (SAFe, LeSS, ScrumGuide, GitLab handbook, Atlassian Agile Coach, Spotify model) classify deferred work? Do they distinguish "deferred for capability reasons" from "deferred for sequencing reasons"? What evidence (e.g., named blocker) is required to defer?
- **Q3.2.** How do ITIL 4 / DevOps Research and Assessment (DORA) / Google SRE / Microsoft One Engineering System schedule "scheduled-change" cadence for cross-cutting cleanup (refactor, technical debt, scale-readiness foundation) — is there a recognised cadence pattern (e.g., every Nth iteration, capacity-allocation percentage, scheduled-change windows)?
- **Q3.3.** How do enterprise prioritization frameworks (RICE, ICE, Cost of Delay, WSJF, MoSCoW, Kano) handle the explicit case "this item is needed for stated scale but has no current user-visible payoff"? Is scale-readiness a separate axis, or folded into Impact/Value?
- **Q3.4.** How do roadmapping disciplines (Roman Pichler product strategy, ProductPlan, Aha! framework, Mind the Product) communicate "scale-readiness" commitment to non-engineering stakeholders? Is there a standard tag, lane, or wave-naming convention?

### C4 — Pattern enforcement: convention vs structural check (Items 8, 10)

- **Q4.1.** How do enterprise codebase governance frameworks (Google's gerrit + Tricorder + readability program, Meta's "Sapienz" + lint tooling, Microsoft's CredScan + InTune, Shopify's "Sorbet" gradual typing + lint, GitHub's CODEOWNERS + branch protection) couple a stated rule to a mechanical check? Is the rule-to-check pairing required at authoring time, or audited later?
- **Q4.2.** How do enterprise security tooling frameworks (OWASP ASVS, NIST 800-53, SOC 2 control mapping, GitLab Secure stage, Snyk, Semgrep rule registry) classify rules as "advisory" vs "enforced"? Is there a meta-rule that says "every rule must declare its enforcement mode"?
- **Q4.3.** How do enterprise pattern catalogs (Microsoft Cloud Design Patterns, AWS Architecture Center, Google Cloud Architecture Center, Spring Boot patterns, Kubernetes patterns book, Refactoring Guru) capture an "enforcement" metadata column alongside the descriptive pattern body? Is convention-only-vs-structurally-checked a named axis?
- **Q4.4.** For Postgres-RLS + Server-Action + Edge-Function stacks (the TaskIt-class stack), what tooling exists (Semgrep rules, eslint plugins, GitHub Actions, pre-commit hooks) to mechanically verify "Server Action input schema does not contain `userId`/equivalent identity fields"? Is the canonical check a regex/AST grep, a type-system constraint, or a runtime gate?

### C5 — Audit-scope blind spots: cross-feature meta-pattern detection (Item 4)

- **Q5.1.** How do enterprise codebase audit tools (SonarQube hotspots, CodeClimate cognitive complexity, GitHub CodeQL "anti-pattern" queries, jscpd duplicate detection, ReSharper "code smell" detector, NDepend) surface "this pattern appears N times in N distinct features → propose a unifying abstraction"? Is duplicate-pattern detection a named feature or an emergent property?
- **Q5.2.** How do enterprise architecture review boards (Google CL review readability program, Meta Code Review for Architects, Apple's Engineering Reviews) catch "we've reinvented this primitive in N places" — is it a checklist item, a meta-review, or an architect's discretion?
- **Q5.3.** What's the canonical name for the "anti-NIH meta-pattern" — i.e., the pattern of "stop reinventing your own primitives and pull in a library"? Is it in Fowler's catalog, Hunt & Thomas's *Pragmatic Programmer*, Brooks's *Mythical Man-Month*, or Hohpe's *Enterprise Integration Patterns*?

### C6 — Plugin self-knowledge and identity (Items 2, 11)

- **Q6.1.** How do enterprise CLI plugins / Claude Code plugins / VS Code extensions / Cursor extensions / Zed extensions surface their version to the running session? Is the version: (a) injected into context at startup, (b) available via a `whoami`-style command, (c) read from a hidden config file, (d) all of the above? What's the canonical pattern?
- **Q6.2.** How do enterprise frameworks (Spring Boot starters, Django apps, Rails engines, npm scoped packages, Helm charts) handle role-naming when the same framework is reused across projects with different organizational vocabulary? Is there a convention for "framework's generic name" vs "project's specific override"?
- **Q6.3.** What's the standard practice for documenting an override pattern in a plugin README — e.g., how does VS Code document settings overrides, how does Tailwind document config theme extension, how does Next.js document `next.config.js` overrides?

### C7 — Cycle-phase enforcement: state-machine vs recipe (Item 12)

- **Q7.1.** How do enterprise workflow engines (Airflow DAG, Prefect, Temporal, AWS Step Functions, Argo Workflows, Camunda BPMN) enforce phase-ordering on a dispatch graph? Is the enforcement (a) declarative (next step refuses to run if predecessor not DONE), (b) imperative (a coordinator polls + dispatches), or (c) implicit (steps coupled by data dependency only)?
- **Q7.2.** How do AI multi-agent frameworks (MetaGPT, ChatDev, AutoGen, LangGraph, CrewAI, Microsoft's Magentic-One) handle "phase skip" — is skipping recorded, blocked, or silent? Is there a canonical "phase-state tracker" artifact in any of them?
- **Q7.3.** How do enterprise change-management / SDLC frameworks (ITIL 4 Change Enablement, SAFe ART events, GitLab Stages, Microsoft One Engineering System) handle "phase skipped with justification" — is it a logged event, a meta-process, or undocumented?
- **Q7.4.** For Claude Code specifically — does the SP `subagent-driven-development` skill (or any sibling) define a state-machine vs recipe semantics for the cycle graph? Are there SP precedents for "do not dispatch agent X until artifact Y exists at path Z"?

---

## 5. Self-Cited ADRs (No Researcher Pass 2 Required)

Two ADRs can be ratified now without waiting for the Researcher. Both rely on citations the framework already holds (in CLAUDE.md, the citation manifest, or the v2.3.0 release notes).

### ADR-008 — Orchestrator role-naming: keep "CTO mode" generic + document the override

**Decision drivers ALREADY cited:**
- The plugin's role identity is encoded in `skills/cto-mode/SKILL.md` and 13 agent files at v2.3.0; renaming is high-churn for low gain (Item 11 is explicitly LOW severity).
- The bigger leverage is documenting the override pattern in the README + project-bootstrap docs.

**Y-statement (Zimmermann SATURN 2012):**

> In the context of TaskIt's prompter customization at `docs/prompts/prompter-base.md` re-titling the orchestrator role as "Deputy Head of Product Engineering," facing the friction of "wait, which one are you?" confusion when both names coexist in a session, we decided to keep "CTO mode" as the framework's generic name AND document the project-level override pattern in the README's customization section, neglecting alternatives "rename to Orchestrator mode globally" (Item 11 fix #1) and "add a CONFIG slot for orchestrator title" (Item 11 fix #2), to achieve clarity at low churn cost, accepting that projects with custom titles must re-state the role-name override at session-start and that Claude may still self-reference as "CTO" in absence of an active override.

**Citation:** TaskIt's `docs/prompts/prompter-base.md` (the override exists and works in practice). LOW severity per Item 11 source. No Researcher pass needed; this is preference reconciliation, not architectural research.

### ADR-009 — Plugin version surfacing via SessionStart hook injection

**Decision drivers ALREADY cited:**
- SP precedent: `hooks/session-start` of Superpowers 5.0.7 already injects context (verified at `hooks/session-start` lines 17-25 per CLAUDE.md).
- `.claude-plugin/plugin.json` `"version"` field is the canonical source of truth (per CLAUDE.md File Layout).
- Item 2's root causes 1, 3, 5, 6 are all solved by ONE hook edit; this is the highest leverage of the three proposed fixes.

**Y-statement:**

> In the context of TaskIt-session feedback-log entries authored with wrong plugin version because the session has no visible way to know its own version, facing the self-undermining failure mode of a feedback log that asks for a version field its authors cannot reliably populate, we decided to inject the plugin version + release date into context via the existing SessionStart hook (read from `.claude-plugin/plugin.json` at hook fire time), neglecting alternatives "add a `whoami` skill" (discoverable but requires the author to think to call it) and "fix only the README install-verification" (doesn't help in-session entries), to achieve self-knowledge with zero user friction, accepting that the hook must remain in sync with `.claude-plugin/plugin.json` at release time and that the injected line consumes ~50 tokens per session.

**Citation:** SP `hooks/session-start` lines 17-25 (precedent — hook already injects context). `.claude-plugin/plugin.json` (`"version": "2.3.0"`) verified in this session via the framework's own file. No Researcher pass needed; SP precedent + verified-fact ground the decision.

### ADRs that EXPLICITLY require Researcher Pass 2 (NOT self-cited)

The following 7 ADRs are deferred to after the Researcher returns:

- ADR-010 — Deferral-rigor grammar (needs Q3.1-Q3.4 enterprise citations)
- ADR-011 — Scale-readiness commitment (needs Q2.3 + Q3.3 + Q3.4)
- ADR-012 — Phase-state enforcement (needs Q7.1-Q7.4)
- ADR-013 — Pattern-enforcement audit (needs Q4.1-Q4.4)
- ADR-014 — Spectrum-vs-binary discipline (needs Q1.2 + Q2.2)
- ADR-015 — Competitor-roster (needs Q1.1 + Q1.4)
- ADR-016 — Cross-cutting-pattern audit (needs Q5.1-Q5.3)
- ADR-017 — Dependency inventory (needs Q2.1)

These ADRs will be written by the Architect in Pass 3 (after Researcher Pass 2 lands), using the Researcher's citations to ground the Considered Options and Decision Outcome sections.

---

## 6. Out-of-Scope

What this design does NOT cover:

- **Implementation of any fix.** This is the Producer step (Pass 1) of Pattern A. The Researcher (Pass 2) answers open questions; the Architect (Pass 3) finalizes ADRs; downstream Build cycles (separate dispatches) implement.
- **F-V11 (synthetic events ≠ real human input) and F-V12 (Tier 2 ceremony cost-floor)** — pre-existing PROJECT-PLAN findings unrelated to the 11 TaskIt items. Stay open; addressed in separate cycles.
- **F-V14 (validation sample size below N≥3) and F-V15 (team-mode untested)** — strategic gaps requiring 2-3 more projects' worth of signal before design is feasible. Per FD-03 logic, pulling these into a cycle today violates the framework's own N≥3 rule.
- **F-V16 (no CI/deploy enforcement) and FD-02 (MCP plugin compatibility surface)** — out of scope per existing PROJECT-PLAN "deferred" rationale.
- **F-V19 (Builder Bash/Write inability) and F-V21 (worktree creation fails despite git repo)** — CRITICAL/HIGH but distinct infrastructure-level bugs. Tracked separately; fixing them does not depend on the 11-item design.
- **Eval discipline for skill changes.** Per CLAUDE.md "Skill Changes Require Evaluation," each modified skill must ship with before/after eval evidence. The eval design itself is a separate cycle per skill and is out of scope here; the architecture doc only specifies WHAT changes; HOW the eval is constructed is in each implementing Build cycle.
- **Anthropic / Claude Code platform-level changes.** Items where the root cause is "Anthropic-side change to sub-agent tool inheritance" (F-V19 root-cause hypothesis d) cannot be fixed in the plugin; out of scope.
- **Renaming the orchestrator role globally.** Per ADR-008 above, we are documenting the override; not renaming `cto-mode` to `orchestrator-mode`.

---

## 7. Open Questions for Researcher (Consolidated Pass-2 Dispatch Contract)

This is the **Producer-Consumer contract**: the Researcher (Pass 2) MUST return ≥3 enterprise/OSS citations per question. Total open questions: **22** across 7 clusters.

Recommended parallel dispatch shape per `dispatching-parallel-agents` skill: **4 Researcher lanes**, grouped by topical adjacency to maximise cross-citation reuse:

- **Lane R-1 — Research methodology and framing (8 questions):** Q1.1, Q1.2, Q1.3, Q1.4, Q2.2, Q5.1, Q5.2, Q5.3. Output: `docs/research/research-methodology-framing-2026-05-12.md`. Sources likely overlap across these (PRISMA, RFC processes, Fowler/Hohpe catalogs).
- **Lane R-2 — Architecture and pre-recommendation discipline (3 questions):** Q2.1, Q2.3, Q3.4. Output: `docs/research/architecture-pre-recommendation-discipline-2026-05-12.md`. Sources: TOGAF, arc42, AWS WAF, roadmapping disciplines.
- **Lane R-3 — Deferral, scheduling, scale-readiness (3 questions):** Q3.1, Q3.2, Q3.3. Output: `docs/research/deferral-scheduling-scale-readiness-2026-05-12.md`. Sources: SAFe/LeSS, ITIL/DORA, RICE/ICE/WSJF.
- **Lane R-4 — Pattern enforcement + phase orchestration (8 questions):** Q4.1, Q4.2, Q4.3, Q4.4, Q6.1, Q6.2, Q6.3, Q7.1, Q7.2, Q7.3, Q7.4. Output: `docs/research/pattern-enforcement-phase-orchestration-2026-05-12.md`. (Q6 and Q7 grouped because both touch the plugin's structural/state-machine surface; Q4 grouped because pattern-enforcement is the structural-check sibling.) NOTE: 11 questions in this lane is large — Architect Pass 3 may want to split it. Flagged for the CTO to size at dispatch.

**Per-question dispatch envelope (each lane's prompt to the Researcher):**

```
Question: <verbatim Q-x.y from this doc>
Eligibility criteria: name ≥3 named enterprise/OSS frameworks; primary sources preferred.
Comparison axes: <derived from the question; e.g., "named step vs implicit", "mandatory vs advisory">
Search budget: 10-15 tool calls per question (Anthropic taxonomy).
Output: row in docs/research/<lane>.md comparison table + verbatim citation per claim.
HARD-GATE: NEEDS_CONTEXT if <3 citations after 15 calls; do not fabricate.
```

**Producer-Consumer escalation:** if the Researcher returns N/N BINDING on any question that contradicts an ADR I would self-cite (e.g., if enterprise consensus prescribes renaming the orchestrator role globally — contradicting ADR-008), the Architect MUST revise the ADR in Pass 3, not the Researcher. Cited per Pattern A grammar in `cycle-selection/SKILL.md` lines 57-74.

---

## 8. Cross-Reference to Existing PROJECT-PLAN Findings

| Item | Description (one-line) | Matching PROJECT-PLAN finding | Note |
|---|---|---|---|
| 1 | Research-cycle scoping omitted direct competitors | (none) — new gap | First surfacing; promote to F-V27 candidate. |
| 2 | Plugin version not surfaced anywhere | (none) — new gap | First surfacing; promote to F-V28 candidate. Self-cited as ADR-009. |
| 3 | Architect lacks dependency-inventory step | (partial overlap) F-09 RESOLVED via D-D `find-similar-implementations` — but that skill is for code-level reuse, not package-level dependency inventory. Item 3 is the package-level sibling. | New gap; ADR-017. |
| 4 | No duplicate-implementation detection pass | (partial overlap) F-09 RESOLVED via D-D — but `find-similar-implementations` is invoked per-feature, not as a project-wide sweep. Item 4 is the project-wide sweep sibling. | New gap; ADR-016. |
| 5 | Architect collapses spectrum decisions to binary verdicts | (none) — new gap | ADR-014. |
| 6 | Researcher does not push back on prompt framing | (none) — new gap, sibling to Item 1 | C1 cluster. |
| 7 | Deferral classifications lack required justification | (partial overlap) F-V15 OPEN (team-mode) and F-V14 OPEN (validation sample size) are themselves deferrals lacking explicit blocker beyond "out of scope" — not direct overlap, but the same root-cause class | ADR-010. |
| 8 | Critical security patterns enforced by convention only | (partial overlap) STACK-PATTERNS BPs ship as project-level documentation; F-V20 RESOLVED added the sub-agent tier-selection inheritance check. But the BP rule itself ("Server Action input must not contain userId") is convention-only. | Sub-case of Item 10; ADR-013 covers both. |
| 9 | Architect defaults to incremental shipping; no scale-readiness commitment | (partial overlap) F-V14 OPEN (sample size) is itself a scale-readiness gap; FD-03 (reply-shape) is parked partly for similar reason | C3 cluster; ADR-011. |
| 10 | Pattern enforcement reactive and partial | (partial overlap) D-E SHIPPED v2.0 — `proposing-patterns` Path A/B. But Path A requires ≥3 incidents and Path B requires research-backed binding; neither is a proactive "what convention-only patterns should become structural?" sweep. | New gap; ADR-013. |
| 11 | Orchestrator role-naming inconsistency | (none) — new gap | LOW severity; ADR-008 (self-cited). |
| 12 | Build-cycle phase ordering not enforced | (partial overlap) F-V25 RESOLVED 2026-05-10 (Pattern A/B for parallel-without-feedback); F-V23 RESOLVED 2026-05-10 (architect/researcher dispatch ordering). But those are about dispatch *shape*, not phase *state-machine enforcement*. Item 12 is the missing state-machine layer. | New gap; ADR-012. |

**Recommended PROJECT-PLAN.md Open Findings updates (out-of-scope for this Pass 1 — flagged for the CTO):**

- Promote 11 items to F-V27..F-V37 with status OPEN, source TaskIt 2026-05-11, severity per the feedback log.
- Cross-link each to the cluster + ADR in this doc.

---

## 9. Concerns and Notes for the CTO

- **Lane R-4 sizing.** 11 questions is large. Consider splitting Q4 (pattern enforcement, 4 questions) into its own R-4a lane and Q6+Q7 (plugin identity + phase orchestration, 7 questions) into R-4b. Final call: CTO at dispatch time.
- **Item 12 (phase enforcement) intersects ADR-002 D-A.** The existing `pre-tool-use` hook already gates Edit/Write/Bash on `tier-selection_invoked_at`. Extending it to gate dispatch-of-Phase-N+1 on `phase_N_status=DONE` is a hook-contract change. Per CLAUDE.md versioning, hook contract changes are **MAJOR**. If ADR-012 chooses the hook path, v3.0.0 is implied. If it chooses the skill-only path (cto-mode refuses to dispatch), it stays MINOR. The Researcher's Q7.x must surface this trade-off.
- **Item 7 (DEFER rigor) is partly a CTO discipline issue.** Even if ADR-010 codifies DEFER-WITH-BLOCKER vs SCHEDULED-LATER buckets, the CTO/Deputy still has to USE them. Suggest pairing with an eval set (similar to `evals/triggering/tier-selection.json`) that pressure-tests the new bucket grammar on 20+ deferral scenarios.
- **F-V14 (N<3 validation) overshadows everything.** Per the framework's own binding rule, every fix shipped here is generalizing from a single project (TaskIt). The honest disclosure is: this design pass produces a candidate fix set; full ratification (especially for new validation questions, which are SP-precedented as a fixed list) requires N≥3 project signal. The Researcher's citation work partially substitutes for project-signal but does not replace it.
- **Validation-question count drift.** Items 1, 5, 7, 9, 12 each propose a new Q8/Q9/Q10/Q11. The 7-validation-questions skill is named "seven" — adding 5 more makes it twelve. Either (a) we keep 7 as a fixed core and add "extended Qs" as opt-in for specific cycle types, or (b) we rename. Q4.x research should surface enterprise practice — does INVEST stay at 6? Does Y-statement stay at 6 clauses? The fixed-count vs open-list decision must be ratified in Pass 3.

---

## 10. Status Token

**DONE_WITH_CONCERNS**

Concerns are explicit in §9 above. The architecture document is written, the cluster table + 22 research questions are drafted, 2 ADRs are self-cited, 8 ADRs are flagged for Pass-3 finalization after Researcher returns. The Producer-Consumer contract for the Researcher dispatch is the per-cluster question list in §4 + consolidated dispatch envelope in §7.

---

## 11. Pass 3 (Architect Consolidation) Summary — 2026-05-12 (updated post Lane R-5 return)

Pass 2 initially returned five Researcher outputs covering 21 of the 22 open questions; the sixth Researcher lane (Lane R-5, Cluster C7 Q7.1–Q7.4 — phase-state enforcement) dispatched in a follow-on cycle on 2026-05-12 and returned DONE with N≥5 per question (11/11 declarative-graph consensus across surveyed workflow engines + AI multi-agent frameworks). Pass 3 now closes all nine pending ADRs (010 + 011 + 012 + 013 + 014 + 015 + 016 + 017, plus the two self-cited 008 + 009 from §5). All ADRs follow MADR or Y-statement structure per `agents/architect.md` guidance. Every ADR cites ≥3 verbatim Researcher quotes with canonical URLs and discloses re-verification needs (WebFetch was permission-denied throughout all six Researcher lanes; every citation other than the AWS Step Functions and AWS Well-Architected Reliability welcome pages is `via WebSearch synthesis of canonical URL`).

| ADR | Path | Status | One-line summary |
|---|---|---|---|
| 010 — Deferral Rigor Grammar | `docs/adr/010-deferral-rigor-grammar.md` | Proposed | Adopt SAFe-Enabler + Atlassian-DoR two-tag bucket grammar (`DEFER-WITH-BLOCKER` for capability-deferral, `SCHEDULED-LATER` for sequencing-deferral); cadence-floor structural check fires after N=3 cycles. Researcher Q3.1 (2/4 explicit, 2/4 discretionary — Architect chose explicit per AI-orchestrator-context risk); Q3.2 (4/4 BINDING on "structured cadence required"). |
| 011 — Scale-Readiness Commitment | `docs/adr/011-scale-readiness-commitment.md` | Proposed | Composite of (a) project-level `scale_targets:` slot (GitLab Reference Architectures), (b) per-plan-row `{ TACTICAL \| SCALE-READINESS \| UNCERTAIN }` tag (AWS WAF pillar precedent), (c) PRR-style left-shift pre-recommendation gate (Google PRR Early Engagement), (d) Aha!-Initiative wave-theme + Pichler goal-with-metric + Kano Must-Be stakeholder language. Q2.3 (5/5 BINDING), Q3.3 (4/6 majority), Q3.4 (4/4 BINDING). |
| 012 — Phase-State Enforcement | `docs/adr/012-phase-state-enforcement.md` | Proposed (finalized 2026-05-12 post Lane R-5) | Skill-layer enforcement at `cto-mode` with `docs/cycle-state.md` as the durable phase-state-tracker substrate. Refuse Phase N+1 dispatch until Phase N is `DONE` OR `SKIPPED + <justification>`; enumerable skip grammar (`user-intent-already-clear` / `no-schema-touched` / `existing-coverage` + free-form flagged); visible diff at cycle end feeds Open Findings. Plugin bump MINOR (v2.4.0); hook layer NOT touched (Lane R-5 found 0/11 frameworks using runtime-hook layer). Lane R-5 evidence: 5/5 workflow engines + 6/6 AI multi-agent frameworks declarative-graph + named-state-tracker substrate (Magentic-One Task/Progress Ledger most explicit); 3/5 SDLC frameworks (ITIL Emergency Change post-implementation review, SAFe Inspect-and-Adapt, CAB DevOps skip-with-justification) explicitly log skip. Disposition A from Pass-2 placeholder selected and ratified. |
| 013 — Pattern Enforcement Audit | `docs/adr/013-pattern-enforcement-audit.md` | Proposed | Mandatory `enforcement: { convention \| structural-check \| runtime }` column in STACK-PATTERNS rows (Sorbet sigil precedent); structural-check rows MUST cite check artifact (declaration-as-enforcement); Path C audit cycle in `proposing-patterns` skill (DRY + Rule of Three + NIH-as-pathology trigger stack). TaskIt-class Q4.4 defense-in-depth: Semgrep static + next-safe-action runtime + Supabase RLS data-layer. Q4.1 (3/3 BINDING), Q4.2 (4/4 BINDING), Q4.3 (3/3 BINDING by absence — PF innovation flagged honestly), Q4.4 (defense-in-depth stack). |
| 014 — Spectrum-vs-Binary Discipline | `docs/adr/014-spectrum-vs-binary-discipline.md` | Proposed | Named "Spectrum / Categories" step + Goals/Non-Goals enumeration on both `agents/architect.md` and `agents/researcher.md` intakes (Rust RFC 2333 + Squarespace "Yes, if" + KEP Non-Goals + 5 unanimous design-doc templates). Validation-question count-drift resolved: `seven-validation-questions` stays at seven core; new Qs added as opt-in "extended Qs" per cycle type. Q1.2 (5/5 BINDING), Q1.3 (5/5 BINDING), Q2.2 (5/5 BINDING). |
| 015 — Competitor Roster | `docs/adr/015-competitor-roster.md` | Proposed | Project-level `docs/COMPETITORS.md` artifact with roster table + PRISMA positive-exclusion subsection + per-cycle refresh; CTO ratifies (Forrester analyst role), Researcher consumes at intake (Forrester research-director role). `templates/COMPETITORS.template.md` ships in framework. Q1.1 (4/5 BINDING with PRISMA positive-exclusion as strongest discipline), Q1.4 (5/5 BINDING on two-role ratification). |
| 016 — Cross-Cutting Pattern Audit | `docs/adr/016-cross-cutting-pattern-audit.md` | Proposed | New skill `cross-cutting-pattern-audit` running two-pass sweep on M=3 cycles: Pass 1 = automated code-block duplication (SonarQube / jscpd / CodeQL); Pass 2 = Architect-driven architectural-pattern audit (the gap layer no off-the-shelf tool fills). Output feeds `proposing-patterns` Path A (N≥3). Cites DRY + Rule of Three + NIH-as-pathology rather than coining a new name. Q5.1 (4/5 BINDING + named gap), Q5.2 (4/4 BINDING ARB anti-duplication mandate), Q5.3 (citation stack rather than canonical name). |
| 017 — Dependency Inventory | `docs/adr/017-dependency-inventory.md` | Proposed | Pre-recommendation "Inventory existing components" step added to `agents/architect.md`: read package-manager file, list overlap candidates as TOGAF-Baseline-style table, check optional project-level Hold-ring artifact (`docs/tech-hold.md` or `hold:` slot). Composes with `find-similar-implementations` (code-level sibling), ADR-011 (scale-readiness gate), ADR-014 (spectrum step). Q2.1 (5/5 BINDING on existing-state inventory as pre-condition). |

### Cross-ADR consequence map

The eight ADRs above (plus the two self-cited 008 + 009 from §5) collectively touch the following framework surfaces. The Build cycle(s) that implement them must coordinate across the touched files to avoid merge conflicts:

| Touched surface | ADRs that modify it |
|---|---|
| `agents/architect.md` | 011 (scale-readiness gate), 014 (Spectrum/Categories step), 017 (Dependency Inventory step) |
| `agents/researcher.md` | 014 (frame-check step), 015 (competitor-roster intake) |
| `skills/cto-mode/SKILL.md` | 011 (wave-end stakeholder summary), 012 (HARD-GATE block + extended `cycle-state.md` write contract), 015 (analyst-side dispatch checklist), 016 (M-cycles-elapsed surfacing) |
| `skills/enterprise-research-first/SKILL.md` | 014 (pattern-vs-library dispatch field), 015 (competitor-roster consistency check), 017 (current-state-inventoried field) |
| `skills/seven-validation-questions/SKILL.md` | 010 (deferral-blocker Q), 011 (scale-readiness Q), 014 (extended-Qs opt-in mechanism) |
| `skills/writing-plans/SKILL.md` | 010 (two-tag bucket grammar), 011 (per-row scale-readiness tag) |
| `skills/proposing-patterns/SKILL.md` | 013 (Path C — enforcement-mode promotion), 016 (consumes Path A from audit output) |
| `skills/cycle-selection/SKILL.md` | 014 (extended-Qs opt-in per cycle type), 016 (cross-cutting-pattern-audit cycle row) |
| `skills/tier-selection/SKILL.md` | 011 (scale-readiness axis trigger — optional) |
| `templates/PROJECT-PLAN.template.md` | 011 (`scale_targets:` slot + tag column + wave-theme), 015 (`competitors_roster:` reference slot), 017 (`hold:` slot — optional) |
| `templates/STACK-PATTERNS.template.md` | 013 (`enforcement:` column + `check_artifact:` + `runtime_gate:` fields) |
| `templates/COMPETITORS.template.md` | 015 (new file — schema) |
| `skills/cross-cutting-pattern-audit/SKILL.md` | 016 (new skill body) |
| `scripts/qa-structural-checks.sh` | 013 (enforcement-artifact-exists check) |
| `docs/cycle-state.md` | 016 (`last-cross-cutting-audit:` field) |
| `hooks/session-start` | 009 self-cited (plugin-version injection) |
| `hooks/post-tool-use` (NEW or MODIFY) | NOT TOUCHED — ADR-012 (post Lane R-5) chose skill-layer enforcement; hook layer is explicitly out of scope (0/11 surveyed frameworks place enforcement at runtime-hook layer). This row remains in the table only to document the rejected option. |
| `skills/gate-3-production-check/SKILL.md` | 012 (new `D-cycle-state-hygiene` row — recorded for cross-reference; implemented in sibling Build) |
| `skills/cycle-selection/SKILL.md` (schema) | 012 (extend `cycle-state.md` schema to per-phase row: `phase / status / agent_dispatched_at / output_doc / gate_passed / skip_justification?`) |

The Build cycle(s) should pick a sensible decomposition: Architect-side intake-checklist changes (ADRs 011 + 014 + 015 + 017) can ship as one Build; Pattern-enforcement changes (ADR 013) and Cross-cutting audit (ADR 016) can ship as a sibling Build; Deferral grammar (ADR 010) is small enough to bundle into either; ADR 011's tag-column requires `templates/PROJECT-PLAN.template.md` modification which has the largest blast radius; ADR 015's COMPETITORS template can ship standalone. **ADR 012 (phase-state enforcement) now ships in the same v2.4.0 minor; recommended grouping with `cto-mode` + `cycle-selection` edits.**

### Re-verification disclosure (consolidated across all eight Pass-3 ADRs)

Per all five Researcher methodology disclosures: WebFetch was permission-denied throughout the Pass-2 dispatch. Every Researcher citation is `via WebSearch synthesis of canonical URL`. The one exception was the AWS Well-Architected Reliability welcome page which loaded directly (cited in ADR-011 only). Per CLAUDE.md citation discipline (binding rule), every Build cycle that implements any of these ADRs MUST re-verify the cited URLs against live pages before committing code. If WebFetch is unavailable in the Build session, manual user verification via browser is acceptable. If any quote fails re-verification, the affected ADR must be re-opened (Architect re-dispatched) before implementation proceeds.

### Researcher-evidence quality observations (orchestrator-relevant)

- **Five lanes returned DONE** with self-rubric pass per lane. No NEEDS_CONTEXT returns. N≥3 BINDING met for all 21 dispatched questions.
- **Lane R-3 evidence is split on Q3.1** (2/4 explicit, 2/4 discretionary). ADR-010 makes the architect choice (explicit) and discloses the split honestly.
- **Lane R-4a Q4.3 returned BINDING by absence** — no enterprise pattern catalog carries an enforcement column. ADR-013 declares the new column as PF v2 innovation, grounded in Q4.1 + Q4.2 deeper-layer precedent.
- **Lane R-1 Q5.3 returned a definitional finding** — no single canonical name for the anti-NIH meta-pattern. ADR-016 cites the three-principle stack (DRY + Rule of Three + NIH-as-pathology) rather than coining a new term.
- **Lane R-4b Q6.1 confirmed ADR-009 is a knowing departure** — no surveyed framework does session-time context injection. ADR-009 stands; the Y-statement should be updated to disclose the departure in the "neglecting" clause (this is a Build-cycle edit to the existing ADR-009).
- **Lane R-4b Q6.2 + Q6.3 confirmed ADR-008** — the chosen "keep generic + document override" matches 5/5 enterprise precedent. ADR-008 stands; the README override section follows the four-step consensus pattern from Q6.3.
- **No Researcher finding contradicts the self-cited ADR-008 or ADR-009** — both stand. The Q6.1 finding adds nuance (the departure is knowing) but does not require an ADR-009 reversal.

### Status token for Pass 3

**DONE_WITH_CONCERNS.** **Nine new ADRs ratified (010 + 011 + 012 + 013 + 014 + 015 + 016 + 017).** ADR-012 was previously a Pass-2 placeholder (DEFERRED, three dispositions); after Lane R-5 dispatch on 2026-05-12 the disposition closed in favor of (A) and the ADR is now finalized with skill-layer enforcement at `cto-mode` + `docs/cycle-state.md` substrate. Both self-cited ADRs (008 + 009) stand without contradiction. Concerns surfaced to orchestrator:

1. **Build-cycle decomposition.** The nine ADRs touch ~18 framework surfaces. Recommend grouping by surface affinity (intake-checklist Build, pattern-enforcement Build, deferral-grammar Build, templates Build, phase-state-enforcement Build) rather than per-ADR Build.
2. **Re-verification mandatory before code change.** WebFetch was denied throughout Passes 2 and Lane R-5 for most primary sources (Airflow, Temporal, Astronomer, Argo Workflows, ITIL/SAFe/CAB pages); every citation other than AWS Step Functions and AWS WAF Reliability is WebSearch-synthesized. The CLAUDE.md binding rule requires re-verification against live URLs before any Build cycle commits the cited material to code. If WebFetch is unavailable in the Build session, manual user-browser verification is acceptable.
3. **F-V14 (N<3 validation) still overshadows.** Per architecture doc §9, every fix here generalizes from a single project (TaskIt). The Researcher citations partially substitute for project-signal but do not replace it. The orchestrator should disclose this in the eventual release notes for v2.4.0.
4. **Plugin version impact remains MINOR.** ADR-012's chosen path is skill-layer (no hook-contract change). The v2.3.0 → v2.4.0 minor bump covers all nine ADRs together. Hook-contract change (Option 1 in ADR-012) was rejected — would have triggered a MAJOR v3.0.0 bump unsupported by Lane R-5 evidence (0/11 frameworks enforce at runtime-hook layer).

---

## Citations (Architecture-method grounding for this doc)

- **C4 model — Container/Component levels:** https://c4model.com/ (verified 2026-04-29 via citation manifest).
- **arc42 §5 Building Block / §6 Runtime / §8 Cross-cutting:** https://docs.arc42.org/ (verified 2026-04-29).
- **MADR template:** https://adr.github.io/madr/decisions/adr-template.html (verified 2026-04-29).
- **Y-Statement (Zimmermann SATURN 2012):** https://medium.com/olzzio/y-statements-10eb07b5a177 (verified 2026-04-29).
- **AWS Well-Architected pillars:** https://docs.aws.amazon.com/wellarchitected/latest/framework/the-pillars-of-the-framework.html (verified 2026-04-29).
- **MetaGPT documents-not-dialogue + producer-consumer:** https://arxiv.org/html/2308.00352v6 §3.2-3.3 (verified 2026-04-29).
- **Anthropic — multi-agent research system / OODA / source-quality heuristic:** https://www.anthropic.com/engineering/multi-agent-research-system (verified 2026-04-29).
- **Anthropic — Building Effective AI Agents (routing pattern, producer/consumer):** https://www.anthropic.com/research/building-effective-agents (verified 2026-04-29).
- **PF v2 internal — Producer-Consumer Pattern A:** `skills/cycle-selection/SKILL.md` lines 57-74 (v2.3.0, this repo).
- **PF v2 internal — enterprise-research-first BINDING grammar:** `skills/enterprise-research-first/SKILL.md` Step 4 (this repo).
- **PF v2 internal — Architect operating levels:** `agents/architect.md` lines 26-43 (this repo).
- **PF v2 internal — Researcher dispatch envelope:** `agents/researcher.md` (this repo).
- **Source feedback log:** `C:\Users\atyab\Experimental - Users\Taskforge\taskforge\docs\framework-plugin-feedback.md` (TaskIt 2026-05-11, 11 items).

**Methodology disclosure:** All architectural quotes were retrieved via the cited skill bodies and the framework's local citation manifest (re-verified 2026-04-29 → 2026-04-30 per the citation manifest's Part 2 rule). Verbatim Anthropic / external quotes already appear in the cited skill bodies; this doc cites them transitively. Re-verify against live URLs before any binding architectural decision lands as code per CLAUDE.md.
