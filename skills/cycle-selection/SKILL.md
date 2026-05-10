---
name: cycle-selection
description: "You MUST use this immediately after entering CTO mode and before dispatching any agent. Classifies the user's task into one of 8 execution cycles (build / debug / research / refactor / security-audit / performance / migration / postmortem) and outputs the agent graph the CTO will dispatch. Composable with tier-selection (which scales rigor inside the chosen cycle)."
---

# Cycle Selection — Pick the Execution Playbook

The cycle is *which* playbook the CTO runs. The tier is *how rigorously* it runs. Both must be set before any agent is dispatched.

> Anthropic-cited foundation: "Routing classifies an input and directs it to a specialized followup task. This workflow allows for separation of concerns, and building more specialized prompts. Without this workflow, optimizing for one kind of input can hurt performance on other inputs."
> — *Building Effective AI Agents*, Anthropic, Dec 19 2024 (https://www.anthropic.com/research/building-effective-agents)

A bug routed through the build cycle wastes the team. A new feature routed through the debug cycle skips spec and design. Cycles exist because each task class has a different right-shape graph of agents.

<HARD-GATE>
Do NOT dispatch any sub-agent until both cycle and tier are output. The CTO mode skill will block dispatch otherwise.
</HARD-GATE>

## Anti-Pattern: "It's a Mix of Build and Debug"

If the task feels like a mix, the user has bundled work that should be split. Pick the dominant cycle, complete it, then run the second cycle as a follow-up. Mixed cycles produce mixed agent graphs and lose the discipline of either.

## Anti-Pattern: "Skip Cycle, Just Pick the Tier"

Skipping cycle selection because tier feels enough is the failure mode of PF v1. Tier alone tells you the rigor; it does not tell you which agents to run. A Tier 3 build and a Tier 3 migration involve different teams.

## Checklist

You MUST create a task for each of these and complete them in order:

1. **Read the task statement** — restate it in one sentence including the user-visible outcome.
2. **Walk the cycle trigger list** — top-down, first match wins.
3. **Output cycle name + matched trigger** — one line.
4. **Run `tier-selection` skill** — get tier (1/2/3) for the matched cycle.
5. **Read the cycle's agent graph below** — write the dispatch order to `docs/cycle-state.md` so handovers can reference it.

## Cycle Trigger List

Scan top-down. First match wins:

| Condition | Cycle |
|---|---|
| User reports something broken / unexpected / failing / slow + root cause unknown | **debug** |
| User reports incident / outage / data corruption already happened | **postmortem** |
| User asks for comparison, decision support, or "how should we approach X" without code change | **research** |
| Task touches schema migration, data backfill, or service-to-service data move | **migration** |
| Task is "audit / harden / pen-test / review for compliance" with no new feature | **security-audit** |
| Task is "speed up / reduce cost / optimize" with measurable target | **performance** |
| Task is "rewrite / restructure / extract / consolidate" with NO new behavior | **refactor** |
| Task is "add / build / implement / create" feature, module, or endpoint with new behavior | **build** |
| Ambiguous | default to **build** with discovery sub-cycle, ask user to confirm scope before dispatch |

## The 8 Cycles

Each cycle defines: required agents, parallelism, artifacts. Tier scales which optional agents run.

### Producer-Consumer Convention (Pattern A / Pattern B)

When a phase pairs two agents where one's output feeds the other (producer → consumer), pick the dispatch shape by tier:

- **Pattern A — three-pass (Tier 3 default).** Producer (pass 1, draft + open questions) → Consumer (reads, answers, audits) → Producer (pass 2, finalizes with consumer's input). Use when the producer's output is the cycle's ratified artifact AND no downstream agent synthesizes both sides.
- **Pattern B — sequential, no revision (Tier 2 default).** Producer → Consumer (sequential). Use when a downstream agent already synthesizes both. Consumer findings that require producer changes escalate the cycle to Tier 3, where Pattern A applies.

Per-phase mapping:

| Phase | Producer | Consumer | Why Pattern A applies at Tier 3 |
|---|---|---|---|
| Build phase 3 | Architect | Researcher | Architecture doc is the ratified artifact (F-V23) |
| Build phase 4 | Database Engineer | Security and Compliance | Database design + RLS migration is the ratified artifact |
| Refactor phase 1-2 | Architect | Researcher | Same as Build phase 3 |
| Migration phase 1-2 | Architect | Researcher | Same as Build phase 3 |
| Security-Audit phase 1-2 | Security and Compliance | Researcher | Findings + remediation cite the ratified controls |

Citations: MetaGPT iterative-refinement loop (https://arxiv.org/html/2308.00352v6 §3.2-3.3), ChatDev review-revise loop (https://arxiv.org/html/2307.07924v5), Anthropic OODA loop (*How we built our multi-agent research system*, Jun 2025). The pattern resolves F-V23 (parallel-without-feedback idiosyncrasy).

### Build Cycle
**Trigger:** new behavior. **Graph:**
1. **product-manager** → spec
2. **ux-design** (parallel with research) → flows
3. **architect (pass 1) → researcher → architect (pass 2, finalize)** (three-pass; resolves F-V23) → (a) Architect drafts design + ADRs they can self-cite + Open Questions for Researcher; (b) Researcher answers those open questions with ≥3 enterprise citations each; (c) Architect finalizes ADRs with citations and locks the plan. Tier 2 may collapse (c) into CTO reconciliation.
4. **database-engineer + security-compliance** (Pattern A at Tier 3, Pattern B at Tier 2) → schema + RLS + auth model. Tier 3: Database Engineer (pass 1) → Security and Compliance audits → Database Engineer (pass 2, fixes any RLS gaps). Tier 2: sequential, no Database Engineer revision; blocking Security findings escalate the cycle to Tier 3.
5. **writing-plan** skill → implementation plan referencing spec/architecture/database/security
6. **builder** instances (one per file scope — typically one backend, one frontend; parallel where files don't overlap; use `worktree-isolation` if they do)
7. **qa** + **code-reviewer** (parallel) → audit
8. **sre-devops** → deploy pipeline + observability
9. **gate-3-production-check** skill → final gate

**Tier scaling:** Tier 1 = direct execution (skip cycle entirely — handled by CTO). Tier 2 = skip pm/ux/sre, run minimal graph. Tier 3 = full graph.

### Debug Cycle
**Trigger:** broken / unexpected / failing, root cause unknown. **Graph:**
1. **debugger** → root-cause doc with reproduction
2. Re-run `tier-selection` on the root cause (not the symptom)
3. If root cause is Tier 3 → invoke build/refactor/migration cycle for the fix
4. If root cause is Tier 1/2 → **builder** (scoped to the file owning the bug)
5. **qa** → confirms fix + adds regression test
6. **post-mortem** (parallel with QA, only if incident shape repeats) → pattern proposal

### Research Cycle
**Trigger:** decision support, no code change. **Graph:**
1. **researcher** → ≥3 enterprise citations + comparison table
2. **architect** (optional) → recommendation doc if user wants a decision
3. CTO synthesizes for user

### Refactor Cycle
**Trigger:** restructure with no new behavior. **Graph:**
1. **architect (pass 1)** → before/after structure draft + Open Questions for Researcher
2. **researcher → architect (pass 2, finalize)** (three-pass; resolves F-V23) → Researcher answers Open Questions with ≥3 enterprise citations of the target pattern; Architect then revises the structure doc to incorporate citations and lock the plan. Tier 2 may collapse the Architect revision into CTO reconciliation.
3. **regression-scope** skill → enumerate every feature that could regress
4. **builder** → implementation
5. **qa** → confirms behavior unchanged + regression suite passes
6. **code-reviewer** → quality check

### Security-Audit Cycle
**Trigger:** audit / harden / pen-test / compliance. **Graph:**
1. **security-compliance (pass 1)** → audit findings doc with severities + Open Questions for Researcher
2. **researcher → security-compliance (pass 2, refines remediation citations)** (Pattern A at Tier 3, Pattern B at Tier 2) → Researcher cites ≥3 enterprise references for each control named in Security's findings; at Tier 3 Security and Compliance then refines the remediation language with citations. Tier 2: sequential, no Security revision pass — downstream Architect (phase 3) synthesizes both.
3. **architect** → remediation plan
4. **builder** → fixes (in severity order)
5. **qa** → confirms remediation
6. **gate-3-production-check** → re-run

### Performance Cycle
**Trigger:** speed up / reduce cost / optimize with measurable target. **Graph:**
1. **debugger** (in profiler mode) → baseline measurement + bottleneck doc
2. **researcher** → ≥3 enterprise citations of the target optimization
3. **architect** → optimization plan
4. **database-engineer** (parallel with builder if DB is the bottleneck)
5. **builder** → implementation
6. **qa** → measures delta vs baseline, confirms target met

### Migration Cycle
**Trigger:** schema migration, data backfill, service move. **Graph:**
1. **architect (pass 1)** → migration plan + rollback strategy draft + Open Questions for Researcher
2. **researcher → architect (pass 2, finalize)** (three-pass; resolves F-V23) → Researcher answers Open Questions with ≥3 enterprise citations of the migration pattern; Architect then finalizes the plan with citations. Tier 2 may collapse the Architect revision into CTO reconciliation.
3. **database-engineer** → migration files + RLS-aware test
4. **security-compliance** → confirms RLS + audit trail intact post-migration
5. **regression-scope** skill → enumerate everything that touches the moved data
6. **backend-builder** → migration runner + monitoring
7. **qa** → confirms rollback works + no data loss
8. **sre-devops** → runbook + observability
9. **gate-3-production-check** with multi-tenant focus

### Postmortem Cycle
**Trigger:** incident already happened. **Graph:**
1. **debugger** → reproduces incident, produces timeline
2. **post-mortem** → root-cause classification, blast radius, fix verification
3. **post-mortem** drafts pattern proposal if root cause shape ≥3 in PROJECT-PLAN incident table
4. CTO writes incident row to `docs/PROJECT-PLAN.md` incident table
5. User ratifies pattern via `ratify-pattern` skill (if proposal exists)

## Output Format

After running this skill, write to `docs/cycle-state.md`:

```markdown
# Cycle State — <task one-liner>

**Cycle:** <name> · **Tier:** <1|2|3> · **Matched trigger:** <trigger>

## Dispatch Order
1. <agent> → <output file>
2. <agent> → <output file>
...

## Open Handover
[Updated by each agent on completion]
```

## Common Mistakes

**Picking build for what's actually debug.** "Add a fix for X" where X is broken is a debug cycle, not build. The fix is the artifact, but the path to it goes through reproduction first.

**Skipping the cycle when the user is prescriptive.** A user saying "just add a column called publishedAt" still gets a build cycle (or migration cycle if it's an existing-data table) — the prescriptive prompt does not exempt the team from running.

**Running build cycle for a refactor.** Build cycle adds new behavior. Refactor changes shape with no new behavior. Running build for refactor produces unnecessary spec/design churn and misses the regression-scope step.

**Forgetting research cycle.** Decision-support questions that don't need code ("how should we structure tenancy") are research cycle, not build. The output is a citation table + recommendation, not source code.
