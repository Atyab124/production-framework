# production-framework v2

> **The CTO of an enterprise multi-tenant SaaS team — packaged as a Claude Code plugin.**

production-framework v2 turns a regular Claude Code session into a CTO running 12 specialist sub-agents through 8 named execution cycles, with file-based shared context, the binding rule that every implementation cite ≥3 enterprise/OSS references, and Superpowers-grade skill cascade reliability underneath.

It is a fork of [Superpowers 5.0.7](https://github.com/obra/superpowers) (MIT, © 2025 Jesse Vincent) — full attribution preserved in `LICENSE`. Superpowers carries the skill cascade plumbing; production-framework adds the multi-tenant SaaS team on top.

---

## What you get

- **CTO mode** — your Claude session adopts orchestrator behavior: classifies the task, picks a cycle, dispatches the right specialists, mediates handovers, synthesizes results.
- **12 specialist sub-agents** — Product Manager, UX/Design, Architect, Researcher, Database Engineer, Security/Compliance, Builder, SRE/DevOps, QA, Code Reviewer, Debugger, Post-Mortem.
- **8 execution cycles** — Build, Debug, Research, Refactor, Security-Audit, Performance, Migration, Postmortem. Each is a graph of agents with parallelism rules.
- **Tier scaling** — Tier 1 (CTO executes directly), Tier 2 (minimal cycle), Tier 3 (full cycle). Routes the chosen cycle to the right rigor for the blast radius.
- **File-based shared context** — `docs/cycle-state.md` (session brain), `docs/specs/`, `docs/architecture/`, `docs/research/`, `docs/plans/`, `docs/audits/`, `docs/runbook/`, `docs/PROJECT-PLAN.md`, `docs/adr/`. Survives sub-agent boundaries.
- **Binding citation rule** — every implementation plan cites ≥3 named enterprise/OSS implementations. Researcher agent enforces. Plans without citations are rejected at QA.
- **Multi-tenant primitives** — RLS-aware migrations, tenant isolation, audit-trail discipline, SLO/SLI contracts as first-class skills.

---

## How it works

```
You: "build me a multi-tenant comments feature"

│
▼
SessionStart hook injects the bootstrap → Claude is now in CTO mode
│
▼
cto-mode skill fires
│
▼
cycle-selection → "Build cycle, Tier 3" (matched: new module + multi-tenant boundary)
│
▼
CTO dispatches in graph order:
  Phase 1: Product Manager → docs/specs/comments.md
  Phase 2: UX/Design ∥ Researcher (parallel) → docs/design/, docs/research/
  Phase 3: Architect ∥ Researcher → docs/architecture/comments.md
  Phase 4: Database Engineer ∥ Security/Compliance → docs/database/, docs/security/
  Phase 5: writing-plan skill → docs/plans/comments.md
  Phase 6: Two parallel Builder instances (backend scope + frontend scope)
  Phase 7: QA ∥ Code Reviewer → docs/audits/
  Phase 8: SRE/DevOps → docs/runbook/comments.md
  Phase 9: gate-3-production-check skill → final gate
  Phase 10: PROJECT-PLAN update + synthesis to user
```

Each sub-agent reads from disk (paths the CTO supplies), writes its output to disk, returns a status token (`DONE` / `DONE_WITH_CONCERNS` / `NEEDS_CONTEXT` / `BLOCKED`). The CTO mediates handovers. The user sees one synthesis at the end.

---

## Installation

```bash
/plugin marketplace add <YOUR_FORK_URL>
/plugin install production-framework@production-framework
```

Replace `<YOUR_FORK_URL>` with the marketplace location.

---

## Cycles at a glance

| Cycle | Trigger | Primary agents (Tier 3) |
|---|---|---|
| **Build** | New behavior | PM → UX∥Researcher → Architect∥Researcher → DB∥Security → plan → Builder ∥ Builder → QA∥Reviewer → SRE → gate-3 |
| **Debug** | Broken / unexpected, root cause unknown | Debugger → re-tier → fix cycle → QA → optional Post-Mortem |
| **Research** | Decision support, no code | Researcher → optional Architect → CTO synthesis |
| **Refactor** | Restructure, no new behavior | Architect → Researcher → regression-scope → Builder → QA → Reviewer |
| **Security-Audit** | Audit / harden / compliance | Security ∥ Researcher → Architect → Builder → QA → gate-3 |
| **Performance** | Speed up / optimize, measurable target | Debugger (profiler) → Researcher → Architect → DB ∥ Builder → QA |
| **Migration** | Schema / data move | Architect → Researcher → DB → Security → regression-scope → Builder → QA → SRE → gate-3 |
| **Postmortem** | Incident already happened | Debugger → Post-Mortem → CTO writes incident row |

---

## Foundational design references

PF v2's architecture is grounded in published research:

- **Anthropic *Building Effective AI Agents*** (Dec 2024) — orchestrator-workers, routing, parallelization, evaluator-optimizer patterns
- **Anthropic *How we built our multi-agent research system*** (Jun 2025) — lead orchestrator + parallel subagents, prompt engineering as primary lever
- **Anthropic *Effective context engineering for AI agents*** — isolated subagent windows + file artifacts as cross-agent comms
- **Claude Code subagent docs** — frontmatter shape, isolation modes, dispatch model
- **Superpowers 5.0.7** — empirically-firing skill cascade, two-stage review, status-token grammar, hook architecture

Validation against enterprise frameworks lives in `docs/research/enterprise-multi-agent-architecture.md` (N=7 comparison: MetaGPT, ChatDev, CrewAI, LangGraph, AutoGen, OpenAI Agents SDK, Claude Code). Every PF v2 feature cites SP precedent or Anthropic guidance per `docs/research/sp-anthropic-citation-manifest.md`.

---

## Philosophy

- **Delegate; do not implement.** The CTO orchestrates 12 specialists. It does not write code itself.
- **Cycles, not pipelines.** Different task classes (build vs debug vs migration) need different agent graphs. Cycle selection picks the right one.
- **Tier scaling.** Tier 1 trivial work bypasses the cycle. Tier 3 work runs the full team. Wasted ceremony causes friction; missing ceremony causes incidents.
- **Enterprise proof, always.** ≥3 named enterprise/OSS citations on every plan. The team does not invent patterns.
- **File-based shared context.** Sub-agents have isolated context windows; the only durable cross-agent channel is the filesystem. Embraced, not worked around.
- **Multi-tenant by default.** Every spec, design, schema, security audit, and runbook addresses the tenant boundary — even when single-tenant.
- **Honest provenance.** Every skill cites where it came from. PF-internal heuristics are labeled as such, not dressed up as Anthropic guidance.

---

## Attribution

Forked from **Superpowers 5.0.7** by Jesse Vincent (jesse@fsck.com), https://github.com/obra/superpowers, MIT licensed. The skill cascade, hook architecture, two-stage review pattern, status-token grammar, and ~14 inherited skills are SP work. PF v2 layers CTO mode, cycle selection, the 12-specialist roster, multi-tenant primitives, and the binding citation rule on top.

LICENSE preserved. Jesse's original copyright notice retained.

---

## Versioning

- **Patch (2.0.x)** — docs, formatting, citation manifest additions
- **Minor (2.x.0)** — new skill, new agent, new template section
- **Major (3.0.0)** — hook contract change, agent dispatch shape change, breaking change to shared-context substrate

See `CLAUDE.md` for contributor guard, binding rule, and rejection criteria.

---

## License

MIT License — see `LICENSE` file. Original SP copyright retained; PF v2 additions also MIT.
