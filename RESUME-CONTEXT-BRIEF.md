# PRODUCTION-FRAMEWORK v2 — Resume Context Brief

## ONE-LINE PITCH
A Claude Code plugin that turns a single Claude session into a CTO orchestrating 12 specialist sub-agents through 8 named execution cycles to autonomously build enterprise multi-tenant SaaS. Solo-built by Atyab Rehman; MIT-licensed fork of Superpowers 5.0.7; currently in production use at TaskIt.

## QUANTITATIVE SCALE

| Metric | Value |
|---|---|
| Total files | 328 |
| Code + doc lines | 61,822 |
| Markdown files | 103 (~38,051 lines) |
| Bash/shell scripts | 35 (~5,217 lines) |
| Skills | 37 (24 original + 13 inherited from Superpowers) |
| Specialist sub-agents | 12 + CTO orchestrator role |
| Hooks | 4 registered events (~1,060 lines of bash) |
| Architecture Decision Records | 12 |
| Research documents | 55 (~15,000 lines) |
| Behavioral eval sets | 2 (35 test cases total) |
| Release versions shipped | 18 (v5.0.0–v5.0.7 inherited, v2.0.0–v2.5.0 original) |
| Active enforcement gates | 27 (9 universal floor + 18 configurable) |
| Citation mappings | 51 Superpowers precedents + 9 Anthropic patterns |
| Runtime dependencies | 0 |
| Platforms supported | macOS, Linux, Windows (Git Bash via polyglot CMD wrapper) |

## TARGET DOMAIN
Enterprise multi-tenant SaaS development. Target user: anyone wanting Claude Code to operate at the rigor of an enterprise engineering org — with PM, Architect, Builder, QA, SRE, Security, Database Engineer, UX, Researcher, Post-Mortem, Debugger, Code Reviewer specialists, plus multi-tenant primitives (RLS, audit trails, tenant isolation, SLO/SLI contracts).

## THE 12 SPECIALIST SUB-AGENTS
Architect, Builder, Code Reviewer, Database Engineer, Debugger, Post-Mortem, Product Manager, QA, Researcher, Security/Compliance, SRE/DevOps, UX/Design.
The CTO is not a sub-agent — the entry session itself adopts the CTO role via the `cto-mode` skill, classifies the task, picks a cycle, dispatches specialists in parallel, and synthesizes results.

## THE 8 EXECUTION CYCLES
Build · Debug · Research · Refactor · Security-Audit · Performance · Migration · Postmortem.
Each cycle has a defined agent graph (e.g., Build at Tier 3 = PM → UX‖Researcher → Architect‖Researcher → DB‖Security → plan → Builder‖Builder → QA‖Reviewer → SRE → gate-3).

## THE 3-TIER SCALING MODEL
- **Tier 1** (trivial): CTO executes directly, no sub-agent dispatch
- **Tier 2** (moderate): Minimal cycle (PM + Architect + Builder + QA)
- **Tier 3** (high blast radius): Full agent graph with reviews + production gate

Tier selection is HARD-GATE enforced by hooks — Tier 3 work cannot reach Edit/Write without passing cycle + tier selection.

## THE BINDING CITATION RULE
Every feature in the codebase must cite either (a) a Superpowers precedent with exact file path, line numbers, and verbatim quote, OR (b) an Anthropic guidance quote with URL and verification date. Features without citations are rejected at PR merge time. New architectural choices additionally require N≥3 enterprise/OSS framework consensus. The canonical source-of-truth is a 60-mapping citation manifest (51 Superpowers + 9 Anthropic patterns).

## ENTERPRISE FRAMEWORK VALIDATION
Architectural decisions validated against N=7 enterprise/OSS multi-agent frameworks: **MetaGPT** (DeepWisdom), **ChatDev** (Tsinghua/OpenBMB), **CrewAI**, **LangGraph** (LangChain), **AutoGen + Magentic-One** (Microsoft), **OpenAI Agents SDK**, **Claude Code subagents** (Anthropic native). All comparisons documented with verbatim quotes and verification dates.

## HOOK-BASED ENFORCEMENT (4 EVENTS, 27 GATES)
Discovered empirically that prose-based HARD-GATEs had ~14% compliance vs. ~97% for hook-enforced gates. Moved enforcement to the hook layer:
- **SessionStart**: bootstrap framework context into entry session
- **UserPromptSubmit**: filter system-reminders, cache tier-verdicts on continuation prompts
- **PreToolUse**: 8 active block-tier HARD-GATEs (tier-selection, worktree-preflight, HEAD-parity, file-scope intersection, phase-state enforcement, EXECUTE-verb scoping, researcher citation freshness, cycle-selection-before-dispatch)
- **SubagentStop** (NEW v2.5.0): auto-detects ≥2 parallel returns, auto-loads parallel-reconciliation skill, blocks next dispatch until resolved

## NOVEL TECHNICAL INNOVATIONS

1. **File-scope intersection check** (v2.5.0): Production-grade parallel-dispatch safety. Tracks each agent's `scope_read`/`scope_write` declarations; blocks dispatch when a new agent's read scope intersects an in-flight agent's write scope. Cited from 4 sources: Anthropic (BINDING), CrewAI Task.context (LITERAL), LangGraph StateGraph (STRUCTURAL), AutoGen RoutedAgent (PRINCIPLE).
2. **Heavy-read-dispatch pattern**: Solves main-session context burn by dispatching researcher sub-agents (fresh context windows) whenever a step requires reading ≥3 source files.
3. **Parallel reconciliation with auto-load**: Precedence ladder (unanimous → 2-of-3 → 3-way-split → research-quality tiebreaker) for resolving conflicts between parallel agent outputs; auto-triggered by SubagentStop hook.
4. **Display-only verdict caching** (v2.2.0): 20–30% context savings on continuation prompts without creating a gate-bypass surface; forensically pressure-tested against TOCTOU attacks in `v2-2-strength-preservation-2026-04-30.md`.
5. **Two-stage review contract**: Code Reviewer Stage 1 = spec compliance, Stage 2 = code quality only if Stage 1 passes. Reviewer forbidden from trusting implementer self-report; must read actual diff.
6. **Dual-path pattern ingest**: New patterns admitted via Path A (≥3 clustered incidents) OR Path B (≥5 enterprise framework BINDING consensus + use-case fit).
7. **Solving the "telephone game" anti-pattern**: PF v1's custom 7-agent topology had ~5% skill-invoke rate. v2 abandoned that shape and rebuilt atop Superpowers' empirically-firing skill cascade (~98% invoke rate), then layered enterprise primitives on top.

## MULTI-TENANT SAAS PRIMITIVES (UNIQUE TO PF v2)
Zero of the 7 surveyed frameworks treat multi-tenancy as a first-class concern. PF v2 adds:
- `tenant-isolation` skill — AWS SaaS Lens silo/pool/bridge classification
- `rls-aware-migrations` skill — 4-phase Postgres RLS migration (expand → backfill → cutover → contract) with irreversible-data-loss disclosure
- `audit-trail` skill — append-only schema (actor_id, tenant_id, action, target, timestamp), no-PII enforcement
- `slo-sli-contracts` skill — 4 golden signals floor + SLO targets + error budget + burn-rate wiring
- `gate-3-production-check` skill — 18-dimension production readiness gate (tenant isolation, RLS, rollback, runbook, observability, security, PII, audit, etc.)
- Security/Compliance sub-agent — OWASP/NIST/SOC2 control ID audits

## FILE-BASED SHARED CONTEXT SUBSTRATE
Claude Code subagents have isolated context windows — no in-memory state crosses agent boundaries. PF v2 builds a durable cross-agent substrate entirely from structured Markdown files on disk: `docs/cycle-state.md` (session brain), `docs/specs/`, `docs/architecture/`, `docs/plans/`, `docs/research/`, `docs/audits/`, `docs/runbook/`, `PROJECT-PLAN.md`, `docs/adr/`. State survives sub-agent boundaries, session breaks, and `/compact` events.

## ENGINEERING DISCIPLINE SIGNALS
- **Eval-driven skill development**: 2 behavioral eval sets (20-case tier-selection + 15-case writing-plans-preemit) verify gate-firing accuracy
- **Zero runtime dependencies**: bash-only hooks, no `jq`, polyglot CMD wrapper for Windows
- **Strict release contract**: version bumped in 6 manifest locations + RELEASE-NOTES entry + citation manifest update + clean working tree
- **Per-project gate configuration**: `.framework-state/active-gates.yaml` lets projects opt-in/out of gates based on `STACK-PATTERNS.template.md`
- **Bypass grammar with audit trail**: `PF_BYPASS=<gate-id>`, `PF_BYPASS_ALL=1`, kill switch — all bypasses logged to `.framework-state/decision-log.jsonl`
- **Blameless post-mortem discipline**: forbidden blame phrases denied by hook; systemic framing required
- **12 ADRs documenting every major architectural choice** with research backing

## VERSION TRAJECTORY
- **v2.0.0** (Apr 2026): Fork off Superpowers 5.0.7; rebuilt PF v1's failed 7-agent topology atop SP skill cascade
- **v2.1.0**: Cycle model formalized; 8 execution cycles defined
- **v2.2.0**: Detection + Adaptation + Recovery layer; tier-verdict caching; two-stage review formalization; forensic safety analysis of 8 properties
- **v2.3.0**: Greenfield/brownfield onboarding; measurement script
- **v2.4.0** (May 2026): Pivot release — 42-row HARD-GATE catalog, `configure-project-gates` meta-skill, per-project active-gates.yaml, decision-log audit trail
- **v2.5.0** (in development): Closes 9 of 10 framework-fixable items from TaskIt feedback; adds file-scope intersection check + SubagentStop hook + writing-plans pre-emit eval

## PRODUCTION VALIDATION
Live in production at TaskIt (SaaS project management tool) since 2026-05-11. Feedback loop: TaskIt sessions surface friction → tagged FEEDBACK items (F-2…F-11) → addressed in framework releases with cited problem statements. v2.5.0 explicitly closes 9 of 10 identified items.

## LICENSING & LINEAGE
MIT-licensed fork of Superpowers 5.0.7 by Jesse Vincent (jesse@fsck.com), with attribution + LICENSE preserved. Inherits 13 skills (brainstorming, dispatching-parallel-agents, systematic-debugging, test-driven-development, etc.); adds 24 original skills + 12 specialist agents + 4 hooks + multi-tenant primitives + binding citation rule + hook-based enforcement layer.

## RESUME-FRAMING ANGLES (FOR THE NEXT LLM)
- **Systems architect**: designed and shipped 61K-line multi-agent orchestration platform solo
- **AI/ML engineering depth**: validated architecture against 7 enterprise multi-agent frameworks; codified 9 Anthropic agent patterns; cited 51 Superpowers precedents
- **Multi-tenant SaaS expertise**: codified AWS SaaS Lens, Postgres RLS phase migrations, SLO/SLI contracts, OWASP/NIST/SOC2 audit discipline into runnable skills
- **Production rigor**: hook-based enforcement, 2 behavioral eval suites, forensic safety analysis pressure-testing 8 properties against TOCTOU/authorization/sandboxing attacks
- **Engineering discipline**: zero-dependency design, polyglot cross-platform support, binding citation rule preventing speculative work
- **Real-world deployment**: framework in production use at TaskIt; closed-loop feedback integration drove 2 successive release pivots (v2.4.0, v2.5.0)
- **Open source**: MIT-licensed, public repo, preserves upstream attribution
