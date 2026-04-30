# ADR-001 — Decisions on the 7 Citation-Manifest Gaps

**Status:** Accepted
**Date:** 2026-04-29
**Decided by:** PF v2 CTO (entry session)
**Cites:** `docs/research/sp-anthropic-citation-manifest.md`, `docs/research/enterprise-multi-agent-architecture.md`

## Context

The PF v2 binding rule requires every feature to cite either SP precedent OR Anthropic-published guidance. The citation manifest surfaced 7 gaps — features without either source. Each must be: (a) cited via newly-found primary source, (b) redesigned to align with existing citation, or (c) removed.

This ADR records the decisions taken on each gap, the rationale, and the trigger that would cause re-evaluation.

## Decisions

### G1 — `enterprise-research-first` skill (N≥3 binding rule)

**Decision:** Keep as BINDING. Tag as PF-internal opinion, not Anthropic-derived. Cite the architecture doc's empirical N=5/7 framework consensus (`docs/research/enterprise-multi-agent-architecture.md`) as evidence the rule is sound. Cite Anthropic §2.6 ("add complexity only when it demonstrably improves outcomes") as supporting principle, not authority.

**Why:** This rule is the user's stated vision: "Each feature if implemented needs to have proof of implementation within other enterprise softwares." Empirically, 5/7 enterprise multi-agent frameworks (CrewAI, LangGraph, AutoGen, MetaGPT, ChatDev) employ a comparable "compare to enterprise reference" pattern when picking architectural shapes. The N=3 threshold is PF's quantification — Anthropic does not prescribe a count.

**Re-evaluation trigger:** Anthropic publishes contradicting guidance, OR PF observes ≥3 incidents where N=3 was followed and produced a wrong recommendation.

### G2 — `gate-3-production-check` skill (7-category gate)

**Decision:** Keep in core. Cite **Google SRE Book** (Chapter 32 — Evolving SRE Engagement Model, including the Production Readiness Review) and **AWS Well-Architected Framework** (Five Pillars) as external industry references, not Anthropic. Tag as "industry-derived production-readiness pattern, not Anthropic-derived."

**Why:** Production-readiness checklists exist in well-established industry frameworks. PF v2's enterprise multi-tenant scope demands a production gate. Moving this to per-project stack-patterns would amputate the framework's enterprise SaaS claim.

**Re-evaluation trigger:** ≥3 PF v2 projects ship without invoking gate-3 and report no incidents in 6 months → consider downgrade to opt-in.

### G3 — `proposing-patterns` and `ratify-pattern` skills

**Decision (original, 2026-04-29):** **Defer to v2.1.** Not core enough to ship in v2.0. Postmortem cycle still works without formal pattern proposal flow — the post-mortem agent can emit `docs/post-mortem/<incident>.md` with classification + blast radius without the hash-cluster-threshold-bloat-cap-ratify pipeline.

**Why (original):** Entirely PF-original methodology with no SP or Anthropic precedent. Honest provenance demands it ship as labeled PF-IP, but v2.0 has higher-priority foundations to land first. Pattern proposal pipeline is a quality-of-life enhancement, not a blocker for the CTO+12-specialists vision.

---

**Amendment (2026-04-30): UN-DEFERRED to v2.0.x. See ADR-003.**

**Why amended:**

1. **Item 41 STRENGTH evidence (audit 2026-04-30):** PF v1's Rule #43 incident-loop is "the most carefully engineered subsystem in v1" — triple-enforced via `MACHINE(script:structural-check.sh:check_incident_logged) + RULE(agent:deputy) + RULE(agent:post-mortem)`. Empirical evidence that the methodology works in production over multiple cycles.
2. **Components are enterprise-cited 9/11** (per Wave 2 `skill-design-proposing-patterns.md`): only the *composition* is PF-original. The original framing as "entirely PF-original methodology with no SP or Anthropic precedent" is overstated. RFC 7942, Microsoft Engineering Playbook, AWS WAF, Refactoring Guru, KEP graduation, Apache PMC, ThoughtWorks Tech Radar all support multi-trigger pattern ingest.
3. **PF v1 hash normalization grammar is enterprise-consensus, not bespoke** (per Wave 2 `skill-design-fix-time-hash-check.md`): Rollbar + Datadog independently corroborate the 7-rule normalization verbatim.
4. **Wave 3 produced a live Path-B test case** (Pattern 2 — React state-setter closure-flag, 7/7 BINDING enterprise via react-mentions + text-expander-element). Deferring means shipping v2.0 with a known-applicable BINDING finding that has no path to pattern promotion.

**Updated scope:** ship `proposing-patterns` (with broadened Path A + Path B ingest per ADR-003) and `ratify-pattern` (6 mechanical gates + `postpone` disposition) in v2.0.x. Carryforward scripts (`compute-root-cause-hash.sh` + `structural-check.sh:check_incident_logged`) port verbatim from v1.

**Re-evaluation trigger (updated):** None — Item 41 evidence and Wave 2/3 research close the original concern. Future re-evaluation only if Path-B promotion produces ≥3 cargo-cult patterns rejected at ratification (would suggest the use-case-fit check is failing).

### G4 — Builder split: Backend Builder + Frontend Builder

**Decision:** **MERGE.** Single `builder` agent. Roster: 14 → **13 total** (CTO entry session + 12 specialists).

**Why:** 0/7 enterprise frameworks split builders by tech stack. MetaGPT, ChatDev, Magentic-One ship a single Engineer/Programmer/Coder. PF v1 also had a single Builder. The split was a v2 design proposal that cleared no consensus bar. CTO can dispatch two parallel `builder` instances when a build cycle has both backend and frontend deliverables (matching Anthropic's "lead agent spawns 3-5 subagents simultaneously" pattern). File-scope, not stack-scope, drives parallelism.

**Re-evaluation trigger:** ≥3 incidents where a single Builder produced cross-stack confusion (e.g., wrong layer, wrong convention). Then introduce specialized stack Builders.

### G5 — Standing roles with no enterprise consensus (Researcher / SRE / Security / UX-Design / Database-Engineer / Post-Mortem)

**Decision:** **Keep maximalist roster** (option A from the citation manifest). Cite Anthropic §2.9 — subagents have isolated context windows and zero cost until invoked.

**Why:** This matches the user's stated vision: "agents for all functions a team would require that builds enterprise SaaS from scratch." The cost of a never-invoked agent is the bytes of its `agents/<name>.md` file on disk — negligible. Tasks that need a Database Engineer get one; tasks that don't, ignore the file. Per Anthropic: "Each subagent operates with an isolated context window... preventing cross-contamination... and keeps each agent focused."

**Re-evaluation trigger:** 6 months of incident logs in PROJECT-PLAN.md show ≥0 incidents that an SRE/Security/Researcher/etc. agent uniquely caught → consolidate that role into another agent's scope.

### G6 — `regression-scope` and `seven-validation-questions` skills

**Decision:** Keep, tag PF-internal heuristics. Cite Anthropic §2.6 (ACI / careful tool design) as supporting principle.

**Why:** Generic "verify before claiming done" is covered by SP `verification-before-completion`, but the specific question sets (every shared model that could regress, the 7 plan-validation questions) are PF inventions that have demonstrably caught real PF v1 regressions. Acceptable to ship as PF-internal, with honest provenance.

**Re-evaluation trigger:** None — these are stable PF-internal heuristics.

### G7 — `bash-output-discipline` skill

**Decision:** Keep, cite Anthropic §2.17 ("smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome") as the principle backing PF's specific wrapper rule.

**Why:** This is a context-pollution-prevention rule — tightly aligned with §2.17. The specific implementation (filtered wrappers vs raw + post-hoc head/tail) is PF-internal but the principle is Anthropic-derived.

**Re-evaluation trigger:** Anthropic publishes guidance contradicting wrapper-first execution → review.

## Net Effect on v2.0.0 Scope

**Roster change:** 14 agents → 13 (CTO + 12 specialists). Frontend Builder removed; merged into single Builder.

**Skills shipping in v2.0:** All except `proposing-patterns` and `ratify-pattern` (deferred to v2.1).

**Provenance labels added:**
- `enterprise-research-first` — labeled PF-internal
- `gate-3-production-check` — labeled industry-derived (SRE + AWS Well-Architected)
- `regression-scope` — labeled PF-internal
- `seven-validation-questions` — labeled PF-internal
- `bash-output-discipline` — labeled PF-internal-with-§2.17-principle-backing

## Citations

- `docs/research/sp-anthropic-citation-manifest.md` — Part 4 Gaps
- `docs/research/enterprise-multi-agent-architecture.md` — Axes 1-3 enterprise consensus
- *Building Effective AI Agents* — https://www.anthropic.com/research/building-effective-agents
- *How we built our multi-agent research system* — https://www.anthropic.com/engineering/multi-agent-research-system
- *Effective context engineering for AI agents* — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Google SRE Book — https://sre.google/sre-book/table-of-contents/
- AWS Well-Architected Framework — https://aws.amazon.com/architecture/well-architected/
