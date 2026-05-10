# Production Framework v2 — Full Context Document

**Audience:** This document is written for ingestion into a tool like NotebookLM. It is self-contained and assumes the reader has no prior context. Every Claude-specific feature is defined the first time it's used. Every framework primitive is explained with its purpose, mechanism, and design rationale.

**Released version at time of writing:** v2.2.0 (2026-05-09)
**Repository:** https://github.com/Atyab124/production-framework
**License:** MIT (preserves attribution to Superpowers 5.0.7 by Jesse Vincent)
**Working environment:** Maintained from a Windows machine with Git Bash; runs on macOS / Linux / Windows-via-Git-Bash.

---

## 1. What this framework is

Production Framework v2 (PF v2) is a Claude Code plugin. It turns a regular Claude Code session into the role of a CTO orchestrating a team of 13 specialist sub-agents (the CTO is the entry point session itself; the 12 specialists are dispatched as sub-agents). The framework is opinionated toward enterprise multi-tenant SaaS work, but most of its primitives are domain-agnostic and apply to any non-trivial software work.

The user starts a Claude Code session in a project that has the plugin installed. The framework's bootstrap fires automatically. From that point, every non-trivial task runs through a structured cycle: classify the task into one of eight execution shapes, scale the rigor by one of three tiers, dispatch the appropriate specialist sub-agents in the correct order, mediate their outputs through shared documents on disk, run a production-readiness gate before declaring the work done, and update the project plan.

The framework's value is not in any single skill or agent. It is in the combination of:
- **Discipline that survives across sessions.** Project state lives on disk in a known set of paths, so a fresh session after `/compact` (Claude Code's context-compression command) can pick up exactly where the prior session left off.
- **Citation discipline.** Every implementation plan must cite at least three named enterprise or open-source implementations of the same pattern. This single rule prevents the most common AI failure mode of inventing architecture from thin air.
- **HARD-GATE blocking semantics.** Critical rules are enforced at the tool-call layer via Claude Code hooks, not by hoping the LLM remembers. A change that should not ship without a test will be blocked at write time, not caught during code review.
- **Two-stage review of every implementation.** Spec compliance first, code quality only if spec compliance passes. The reviewer is forbidden from trusting the implementer's report; verification is by reading the actual diff.

## 2. Origin and philosophy

PF v2 is a fork of Superpowers 5.0.7 by Jesse Vincent. Superpowers is a Claude Code plugin that ships an empirically-validated cascade of skills (brainstorming, writing-plans, test-driven-development, debugging, verification-before-completion, and more). PF v2 inherits that cascade verbatim, layering on top:

- 12 specialist sub-agents for domains Superpowers does not address (architect, researcher, builder, QA, debugger, post-mortem, code-reviewer, database engineer, security/compliance, SRE/DevOps, product manager, UX/design)
- A cycle-selection layer that picks the right execution shape (8 cycles) for the task
- A tier-selection layer that scales rigor (3 tiers) within the chosen cycle
- An enterprise-research-first discipline that enforces the three-citation rule
- A production-readiness gate (gate-3-production-check) covering 18 dimensions including multi-tenant isolation, RLS, audit trail, SLO/SLI, observability, error budget, and rollback
- Hooks that enforce these disciplines at the tool-call layer

PF v1 was a separate plugin (no longer in active use) that used a custom 7-agent topology. It empirically failed because its agents did not reliably fire skills — the failure mode Anthropic has named the "telephone game" anti-pattern, where each layer of indirection between user and skill loses fidelity. PF v2 abandoned that shape and rebuilt atop Superpowers' empirically-firing skill cascade. The Superpowers attribution and license are preserved in every shipped artifact.

The binding rule of PF v2 development is: **every feature must cite either a Superpowers precedent or an Anthropic guidance source, plus three enterprise or open-source analogs**. Features without citations are rejected. The citation manifest at `docs/research/sp-anthropic-citation-manifest.md` is the source of truth and must be updated with every release.

## 3. Claude Code features the framework uses

Claude Code is Anthropic's command-line tool for AI-assisted software development. It is an interactive agent that supports multi-turn conversations, tool use, sub-agent dispatch, hooks, plugins, and MCP server integration. The framework uses every major Claude Code primitive. This section explains each.

### 3.1. Plugins

Claude Code supports installable plugins. A plugin is a directory that follows a specific layout and is installed via Claude Code's marketplace mechanism. The framework ships as a plugin.

A plugin's manifest lives in `.claude-plugin/plugin.json`. This file declares the plugin's name, version, description, author, license, and the credit attribution to upstream sources (Superpowers 5.0.7 in PF v2's case). The marketplace registration lives in `.claude-plugin/marketplace.json` — this declares the plugin's name, version, source path, and metadata for the marketplace listing.

When Claude Code starts a session in a project, it checks which plugins are installed and loads each plugin's `.claude-plugin/` content along with its skills, agents, hooks, commands, and MCP servers.

### 3.2. Skills (the Skill tool)

Skills are reusable knowledge artifacts that Claude Code agents can invoke. They live in a plugin's `skills/` directory, one folder per skill, with a `SKILL.md` file inside each folder. The folder name is the skill's name; the file's content is the skill's body.

Each skill starts with YAML frontmatter that declares two required fields: `name` (the skill's identifier) and `description` (the trigger text that Claude reads to decide when to invoke the skill). The body is markdown that the agent reads when the skill is invoked.

Claude Code makes skills available via a built-in `Skill` tool. When the agent invokes the tool with a skill name, the skill's body is loaded into the agent's context, and any TodoWrite-per-step convention or HARD-GATE marker in the body becomes part of the agent's working instructions for the rest of that turn.

The `description` field is the load-bearing primitive of skill discovery. Claude Code shows the agent a list of available skills with their descriptions; the agent picks which to invoke based on whether the description matches the current task. A vague description (`"Use when working with code"`) produces poor invocation. A precise description (`"Use before any creative work — features, components, modifying behavior. Explores user intent before implementation."`) produces reliable invocation.

The framework uses a **HARD-GATE** convention for non-negotiable skill rules. A `<HARD-GATE>...</HARD-GATE>` block in the skill body is read by the agent as a blocking constraint, not advice. Combined with hooks (next section), HARD-GATEs become real enforcement, not just preached discipline.

The framework also uses a **TodoWrite-per-step** convention. Skills with multi-step procedures instruct the agent to write a TodoWrite item per step and complete them in order. This combats the agent's tendency to skip steps mid-execution. TodoWrite is a Claude Code tool that maintains a session-scoped todo list visible to both the agent and the user.

The framework ships approximately 36 skills layered atop Superpowers' inherited skills. The most important framework-owned skills:

- **using-production-framework** — the SessionStart bootstrap skill (auto-injected on session start)
- **cto-mode** — the orchestrator behavior the entry session adopts
- **cycle-selection** — picks 1 of 8 execution cycles
- **tier-selection** — scales rigor by tier (1, 2, or 3)
- **enterprise-research-first** — enforces the three-citation rule before any design decision
- **gate-3-production-check** — the 18-dimension production-readiness gate
- **seven-validation-questions** — runs against any Tier 2/3 plan before builder dispatch
- **parallel-reconciliation** — the closing primitive paired with parallel-dispatch
- **dispatching-parallel-agents** — the opening primitive (inherited from Superpowers, amended with foreground/background guidance in v2.2.0)
- **heavy-read-dispatch** — HARD-GATE preventing the main session from burning context on background reads
- **browser-driven-verification** — Playwright-based UI verification primitive
- **rls-aware-migrations** — RLS-aware database migration discipline
- **slo-sli-contracts** — SLO/SLI definition discipline
- **tenant-isolation** — silo / pool / bridge tenancy classification per AWS SaaS Lens
- **audit-trail** — append-only audit-log schema discipline
- **proposing-patterns** — the dual-path pattern proposal mechanism (Path A: ≥3 incidents clustered; Path B: ≥3 enterprise binding research findings)
- **ratify-pattern** — six mechanical gates for promoting a proposal to a binding pattern
- **regression-scope** — what other features could regress when a shared module changes
- **find-similar-implementations** — REUSE / ADAPT / NEW judgment for new helpers, components, hooks
- **fix-time-hash-check** — bug-deduplication primitive (cluster fix-time bugs against prior incidents)
- **implementation-decision-log** — append-only log of every Tier 2/3 implementation decision
- **incident-response** — live-fire production incident discipline (rollback safety > root cause)
- **triage** — routes user-reported bugs to direct-fix vs systematic-debugging vs incident-response
- **writing-handover** — handover discipline between agents and across phases
- **release-discipline** (new in v2.2.0) — the four-gate release contract

### 3.3. Sub-agents (the Agent tool)

Claude Code supports sub-agents. A sub-agent is a separate context window with its own system prompt, optionally its own tool permissions, and optionally its own working directory (via worktree isolation). Sub-agents are dispatched via the `Agent` tool, which the parent session invokes with a `subagent_type` parameter naming the sub-agent and a `prompt` parameter passing the task.

Sub-agents are defined in a plugin's `agents/` directory, one markdown file per agent. The frontmatter declares:
- `name` — the agent's identifier (matched against `subagent_type`)
- `description` — when to dispatch the agent (similar to skill descriptions)
- `model` — which Claude model the agent runs (e.g. `sonnet`, `opus`)
- `tools` (optional) — explicit tool allowlist; if omitted, the sub-agent inherits all tools from the parent
- `isolation` (optional) — set to `worktree` to run the agent in a temporary git worktree

The body of the agent file is its system prompt. When the parent dispatches the agent, Claude Code starts a fresh context window with that body as the system prompt, runs the agent until it returns a message, and delivers that message to the parent as the tool result.

Sub-agent dispatch can run in foreground (the parent session blocks on the result) or background (the parent keeps working; the result arrives as a notification). The framework uses foreground by default; background only when the parent has independent productive work to fill the wait. The reasoning is documented in the `dispatching-parallel-agents` skill body amendment shipped in v2.2.0.

The framework defines 12 specialist sub-agents:

- **architect** — produces the architecture doc (system-level design, module boundaries, data flow, integration contracts) before any builder writes code. Model: opus.
- **researcher** — enforces the three-citation rule (≥3 named enterprise/OSS implementations of any pattern). Searches the web; quotes verbatim; produces a comparison table; recommends one option. Model: opus.
- **builder** — implements one bounded scope of code (backend, frontend, migration). Multiple builder instances can dispatch in parallel when file scopes don't overlap. Model: sonnet. Worktree-isolated.
- **qa** — two-stage review of every builder output: spec compliance first, code quality only if spec compliance passes. Model: opus.
- **code-reviewer** — code-quality-only review (separate from QA). Model: opus.
- **debugger** — reproduces bugs, identifies root causes, produces evidence. Does not write fixes (the fix is dispatched as a separate cycle). Model: sonnet.
- **post-mortem** — incident retrospective; pattern proposal when an incident shape repeats. Model: opus.
- **database-engineer** — schema design + migrations + RLS policies for multi-tenant data. Model: opus.
- **security-compliance** — auth model, RLS audit, audit trail coverage, SOC2 control mapping. Model: opus.
- **sre-devops** — deploy pipeline, observability, SLO/SLI definition, runbook authoring. Model: sonnet.
- **product-manager** — translates user intent into a structured spec at the start of a build cycle. Model: sonnet.
- **ux-design** — UI flows, mockup descriptions, interaction states (Tier 3 build cycles only). Model: sonnet.

The CTO is not a sub-agent. The CTO is the entry-point session itself, behaving according to the `cto-mode` skill.

The framework's model assignment matrix is opinionated: design and critical-judgment work runs on Opus; execution work runs on Sonnet. This balances cost against capability per Superpowers' "least-powerful-model" rule.

### 3.4. Hooks

Claude Code supports hooks: shell commands that run in response to specific session events. Hook configuration lives in `hooks/hooks.json` inside a plugin (or in `~/.claude/settings.json` for user-scope hooks). Each hook entry declares:
- The event type (`SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, etc.)
- A matcher (which tool calls or events trigger the hook; supports regex)
- The command to run

Hooks read JSON event payloads from stdin and emit JSON responses on stdout. For `PreToolUse`, the response can include a `permissionDecision` of `"allow"` or `"deny"`. A `"deny"` response with a `permissionDecisionReason` blocks the tool call and surfaces the reason to the agent.

The framework ships three hooks, all written in portable Bash with a `.cmd` polyglot wrapper for Git Bash on Windows:

- **session-start** — runs at the start of every session. Initializes `.framework-state/` and seeds `session.json` with empty timestamp fields. Inherits from Superpowers.
- **user-prompt-submit** — runs on every user prompt. Updates `last_user_prompt_at` in `session.json`. Logs a `prompt_received` event to `trigger-audit.jsonl`. As of v2.2.0, filters out `<system-reminder>` payloads (system reminders are runtime-injected events, not human turns; without the filter they would re-arm the tier-selection gate on every notification).
- **pre-tool-use** — the largest hook. Runs before every Edit, Write, Bash, Skill, or Agent tool call. Implements five gates per ADR-002:
  - **Gate 1 — tier-selection.** Edit/Write/Bash blocked unless tier-selection has been invoked since the latest user prompt.
  - **Gate 2 — destructive-ops.** Bash commands matching `rm -rf | reset --hard | push --force | DROP TABLE | TRUNCATE | --no-verify` blocked unless `PF_BYPASS=destructive`.
  - **Gate 3 — phase-break.** (reserved; not yet active in v2.2.0)
  - **Gate 4 — critical-finding-blocks-next-phase.** (reserved)
  - **Gate 5 — dep-add.** Bash commands matching `npm/pnpm/yarn/bun add|install` blocked unless preceded by a Tool Selection Chain or `PF_BYPASS=dep-add`.
  
  As of v2.2.0, the hook also performs:
  - **Path normalization.** Windows backslashes in file paths are normalized to forward slashes before the docs/.framework-state/.claude-plugin auto-allow check. (Closes F-V13.)
  - **Sub-agent inheritance.** When `SUBAGENT_TYPE` is set in the tool input AND the parent session passed tier-selection AND the timestamp is at-or-after the last user prompt, the sub-agent inherits the parent's verdict and the gate doesn't re-fire. (Closes F-V20.)
  - **MCP tool logging.** Tool calls whose names match `mcp__*` are logged to `trigger-audit.jsonl` as `event: mcp_tool_call` for downstream failure-pattern mining. (ADR-006 R2.)

The hooks use no third-party dependencies. JSON parsing and emission is done with grep + sed + bash parameter substitution. This honors PF v2's zero-runtime-dependency posture.

### 3.5. SessionStart bootstrap

Claude Code's SessionStart hook can emit `additionalContext` that is automatically injected into the session at startup. The framework uses this to inject the `using-production-framework` skill body. The injection is what establishes that the session is a CTO; without it the session would be a generic Claude Code session.

The injected content includes:
- A statement that the session is the CTO
- A routing table mapping common request shapes to the appropriate first action (`cto-mode` for any non-trivial task, direct execution for typos, etc.)
- The list of available skills (loaded lazily; not enumerated)
- The list of 12 specialist sub-agents
- The shared-context substrate (what files agents read and write)
- The path indirection rule (`docs/PROJECT-PLAN.md` is the convention path; CONFIG can override it for brownfield projects)
- The compaction-preservation list (what survives `/compact`)

### 3.6. Slash commands

Plugins can ship slash commands in a `commands/` directory. Each command is a markdown file that the user can invoke by typing `/<command-name>`. The framework inherits Superpowers' commands (`init`, `review`, `security-review`) without modification.

### 3.7. MCP servers (Model Context Protocol)

MCP is Anthropic's protocol for connecting AI agents to external tools and services. An MCP server runs as a separate process; the agent talks to it over a structured protocol. Claude Code lets users configure MCP servers in settings; once configured, the server's tools are available to the agent.

The framework integrates with several MCP servers without depending on any of them:

- **Playwright MCP** — browser automation for `browser-driven-verification`. Used for UI verification, ARIA snapshots, console-error capture, synthetic event dispatch.
- **Supabase MCP** — multi-tenant DB ops, RLS migrations, schema introspection. Used by `database-engineer` and `rls-aware-migrations`.
- **Vercel MCP** — deploy state, runtime logs, deployment build logs. Used by `sre-devops`.
- **Context7 MCP** — current library docs. Used by `researcher` for retrieving up-to-date library documentation that may have changed since the model's training cutoff.
- **GitHub MCP** — PR/issue/CI access. Used by `qa` and `finishing-a-development-branch`.
- **Notion / ClickUp MCP** — work-item tracking. Used by `product-manager` for spec sync.

The framework documents this integration as a Future Decision (FD-02) in PROJECT-PLAN, with the open question of whether to formalize MCP plugin compatibility per project via a CONFIG slot. Today the integration is implicit: skills reference MCP capabilities by name, and if the MCP server isn't connected, the skill degrades to manual instructions.

### 3.8. Compact (/compact)

Claude Code lets users compress an active session's context with the `/compact` command. The framework's design assumes compaction will happen and that nothing in active session memory is durable. Everything load-bearing must live on disk. The framework's `using-production-framework` skill includes explicit Compact Instructions that name the artifacts that must be preserved verbatim:

- The open `docs/cycle-state.md` content (current cycle, dispatch log, open handovers)
- `docs/PROJECT-PLAN.md` Open Findings table, Incident table, Remnant Watchlist
- Active `docs/plans/<feature>.md` paths and their associated cycle name
- Any pending agent dispatches

OK to compress: completed agent transcripts (their outputs are on disk), tool-call noise, intermediate research notes already saved to docs/research/.

This gives the framework the property "Validated Strength VS-04 — Compact-preservation discipline survived /compact intact" — empirically observed across multiple Taskforge sessions.

### 3.9. CLAUDE.md (project memory and contributor guard)

Claude Code reads a `CLAUDE.md` file at the project root automatically. The framework uses CLAUDE.md as a contributor guard for the framework's own repository — declaring the binding rule, the PR checklist, the rejection criteria, the versioning policy, and the dependency list.

Critically, the framework distinguishes two roles for CLAUDE.md:
- The framework repo's own CLAUDE.md applies to people contributing to the framework itself.
- Each downstream project using the framework has its own CLAUDE.md, which is authoritative for that project. The framework's bootstrap is not allowed to inline framework rules into a project's CLAUDE.md; the framework flows via the SessionStart skill injection only.

This separation prevents the framework from polluting the project's project-specific guidance.

### 3.10. Settings (~/.claude/settings.json and project .claude/settings.json)

Claude Code supports user-scope settings (`~/.claude/settings.json`) and project-scope settings (`<project>/.claude/settings.json`). Settings declare permission allowlists, hook configurations, and environment variables. The framework does not require any specific settings — it works out of the box — but it documents how settings interact with its hooks (e.g., the `PF_BYPASS_ALL` env var overrides all gates session-wide).

### 3.11. Memory system

Claude Code supports a per-project memory system at `~/.claude/projects/<project-id>/memory/`. The directory contains a `MEMORY.md` index file and individual memory files. Memories persist across conversations and are loaded into context when relevant.

The framework defines four memory types:
- **user** — facts about the user's role, preferences, knowledge
- **feedback** — guidance the user has given about how to approach work; corrections and validated approaches
- **project** — ongoing work, goals, deadlines (decay quickly; need to be kept fresh)
- **reference** — pointers to where information lives in external systems (Linear, Slack, Grafana)

The framework uses memory to capture the user's communication preferences (terse bullets, plain English, no internal codes in user-facing replies) so future sessions inherit the calibration without the user having to repeat themselves.

### 3.12. Tool inheritance

By default, sub-agents inherit all tools from the parent session. This is convenient but has empirical failure modes (per F-V19 / F-V21 in PROJECT-PLAN). The framework documents this as a known caveat and uses explicit `tools:` declarations sparingly — only when a sub-agent should have a strictly smaller tool surface than the parent.

### 3.13. ToolSearch / deferred tools

Claude Code can defer tool schemas (not load them at session start) to keep the initial system prompt lean. Deferred tools are surfaced by name only; their schemas are loaded on demand via a `ToolSearch` mechanism. The framework benefits from this but doesn't directly use it.

### 3.14. Worktree isolation

Sub-agents with `isolation: worktree` in their frontmatter run in a temporary git worktree — a separate working directory cloned from the project's git state. This prevents parallel sub-agents from stepping on each other's file changes.

The Builder sub-agent is worktree-isolated. This has produced one empirical failure (F-V21) when the dispatch context isn't a git repository or when the Agent tool resolves cwd differently than the host session does.

### 3.15. The standard Claude Code tools

Used throughout the framework:
- **Read, Glob, Grep** — file inspection
- **Edit, Write** — file modification
- **Bash** — shell commands (PowerShell on Windows; the framework's hooks include polyglot wrappers)
- **TodoWrite** — session-scoped todo list
- **WebFetch, WebSearch** — web access (for the researcher's three-citation rule)

## 4. Anthropic-published patterns the framework implements

The framework's binding rule requires every feature to cite either a Superpowers precedent or an Anthropic guidance source. Most features map to one of the following Anthropic-published patterns:

- **Orchestrator-Workers** — *Building Effective AI Agents* (Dec 2024). The CTO is the orchestrator; the 12 specialist sub-agents are workers.
- **Routing** — same source. Cycle-selection routes the task into one of 8 execution shapes; tier-selection routes the chosen cycle to a fast/slim/full execution shape.
- **Parallelization (Sectioning + Voting)** — same source. The `dispatching-parallel-agents` skill implements sectioning (multiple agents on independent sub-tasks); the `parallel-reconciliation` skill implements voting (synthesizing N parallel returns into a single decision).
- **Evaluator-Optimizer** — same source. The two-stage QA review (spec compliance first, code quality only if spec compliance passes) is an evaluator-optimizer loop.
- **Prompt Chaining** — same source. The brainstorm → plan → build pipeline is a prompt chain.
- **Multi-Agent Research System: Lead Orchestrator + Parallel Subagents** — *How we built our multi-agent research system*, Anthropic Engineering, Jun 2025. The CTO's parallel sub-agent dispatch directly implements this pattern.
- **Sub-Agent Context Isolation** — *Effective context engineering for AI agents*, Anthropic Engineering. Builder/QA/Researcher run in fresh, isolated context windows so the parent's context stays lean.
- **SessionStart hook with additionalContext** — Claude Code documentation. The `using-production-framework` injection is a textbook use of this primitive.
- **Subagent Isolation Modes (worktree)** — Claude Code documentation §2.10. The Builder's `isolation: worktree` declaration follows this pattern.

## 5. The framework's own architecture

### 5.1. The core loop

When the user types a non-trivial request, the CTO session walks this sequence:

1. **`using-production-framework` was already loaded at session start** via SessionStart bootstrap.
2. **Invoke `cto-mode`** to switch into orchestrator behavior. This skill establishes the dispatch discipline: classify, dispatch, mediate, synthesize.
3. **Invoke `cycle-selection`** to pick one of 8 cycles (build, debug, research, refactor, security-audit, performance, migration, postmortem). The skill walks a top-down trigger list; first match wins.
4. **Invoke `tier-selection`** to scale the cycle's rigor (Tier 1 = direct execution, Tier 2 = slim cycle graph, Tier 3 = full cycle graph). The skill walks a top-down trigger list; first match wins.
5. **Optionally invoke `heavy-read-dispatch`** if the next step requires reading more than three files of source material (audit, doc generation, codebase survey). This dispatches a researcher sub-agent so the main session's context stays clean.
6. **Dispatch the cycle's agent graph.** Each cycle has a defined dispatch order with parallelism markers. The CTO follows the order.
7. **Mediate handovers.** When agent A's output is agent B's input, the CTO reads both files and confirms fit before dispatching B.
8. **Run `gate-3-production-check`** (or skip for non-production cycles like research).
9. **Update PROJECT-PLAN.md** — phases, findings, validated discipline, incidents, remnants.
10. **Synthesize for the user** in 30 lines or fewer: cycle name, agents dispatched, shipped artifacts, open findings, next steps.

### 5.2. The 8 cycles

Each cycle has a defined agent graph. Cycle definitions live in the `cycle-selection` skill body.

- **Build** — new behavior. Graph: PM → UX (parallel with Architect+Researcher) → DB-engineer (parallel with Security) → writing-plans → builder(s) → QA + code-reviewer → SRE/DevOps → gate-3.
- **Debug** — broken / unexpected / failing with unknown root cause. Graph: debugger → re-tier on root cause → builder (or escalate to fix cycle) → QA confirms fix + adds regression test → post-mortem if pattern repeats.
- **Research** — decision support without code change. Graph: researcher → architect (optional recommendation) → CTO synthesizes for user.
- **Refactor** — restructure with no new behavior. Graph: architect → researcher → regression-scope → builder → QA confirms behavior unchanged → code-reviewer.
- **Security-Audit** — audit / harden / pen-test / compliance. Graph: security-compliance → researcher → architect → builder fixes (in severity order) → QA → gate-3 re-run.
- **Performance** — speed up / reduce cost / optimize with measurable target. Graph: debugger in profiler mode → researcher → architect → DB-engineer parallel with builder → QA measures delta vs baseline.
- **Migration** — schema migration / data backfill / service move. Graph: architect → researcher → DB-engineer → security-compliance → regression-scope → builder → QA confirms rollback + no data loss → SRE/DevOps runbook → gate-3 with multi-tenant focus.
- **Postmortem** — incident already happened. Graph: debugger reproduces → post-mortem classifies + writes incident row → CTO updates PROJECT-PLAN incident table → optional ratify-pattern if proposal exists.

### 5.3. The 3 tiers

Tier scales rigor inside the chosen cycle:

- **Tier 1 — Trivial.** Typo, style, comment, single-line config. No logic change. The CTO executes directly; the cycle is skipped.
- **Tier 2 — Small.** Isolated bug or single feature, fewer than 6 deliverables, no Tier 3 trigger. The cycle runs minimal — for build, that's audit → plan → implement → production-readiness check.
- **Tier 3 — Module / Phase.** Any Tier 3 trigger fires (schema change, realtime change, cache strategy change, cross-query writes, state reconciliation, multi-tenant boundary change, auth change, new module, ≥6 deliverables, project-specific trigger). The cycle runs full — for build, that's architecture doc → research → plan → implement → QA → production-readiness check + handover.

When in doubt: step up. A Tier 1 typo through a Tier 3 cycle wastes the team. A Tier 3 change executed as Tier 1 causes incidents. The framework prioritizes the second failure mode and biases up.

### 5.4. State substrate (.framework-state/)

The framework maintains state on disk at `<project>/.framework-state/`. The directory is `.gitignore`-d so runtime artifacts don't ship.

- **session.json** — current session timestamps. Fields: `session_started_at`, `tier_selection_invoked_at`, `triage_invoked_at`, `last_user_prompt_at`. Read by pre-tool-use to apply the tier-selection gate.
- **bypass-log.jsonl** — append-only audit trail of every bypass invocation (`PF_BYPASS=<rule>`, `PF_BYPASS_ALL=1`, `PF_GATES_DISABLED` filesystem kill switch). The post-mortem agent mines this for repeat-bypass patterns.
- **trigger-audit.jsonl** — append-only audit trail of every Skill/Agent/UserPromptSubmit/MCP-tool event. Cross-correlates with prompt history. Powers the measurement script (`scripts/measurement.sh`) added in v2.2.0.
- **PF_GATES_DISABLED** — filesystem kill switch. If this file exists, all hook gates pass.

### 5.5. Bypass grammar (three tiers)

The framework supports three layers of bypass:

- **Per-rule bypass** — `PF_BYPASS=<rule-id>`. Bypasses one specific gate for one tool call. Logged.
- **Session-wide bypass** — `PF_BYPASS_ALL=1` plus a required `PF_BYPASS_REASON`. Bypasses all gates for the rest of the session. Logged. Without `PF_BYPASS_REASON`, the session-wide bypass denies (forcing the user to explain why).
- **Project-level kill switch** — `.framework-state/PF_GATES_DISABLED` file. Bypasses all gates for the project until the file is deleted. Logged on every invocation.

All bypasses are append-only logged to `bypass-log.jsonl`. The post-mortem agent reviews repeat bypasses for pattern signal.

### 5.6. Documentation discipline

The framework reserves a known set of paths for shared-context artifacts. These paths are CONFIG-overridable for brownfield projects, but the convention paths are:

- `docs/cycle-state.md` — session shared brain (current cycle, dispatch log, open handovers)
- `docs/specs/<feature>.md` — Product Manager output
- `docs/architecture/<feature>.md` — Architect output
- `docs/research/<topic>.md` — Researcher output (≥3 citations)
- `docs/database/<feature>.md` — Database Engineer output
- `docs/security/<feature>.md` — Security/Compliance output
- `docs/plans/<feature>.md` — implementation plan
- `docs/audits/qa-findings-<feature>.md` — QA output
- `docs/audits/code-review-<feature>.md` — code-reviewer output
- `docs/audits/gate-3-<feature>.md` — production-readiness audit
- `docs/handovers/<feature>.md` — handover doc at phase end
- `docs/PROJECT-PLAN.md` — long-lived project state
- `docs/adr/<n>-<decision>.md` — Architecture Decision Records
- `docs/onboarding-brownfield.md` — onboarding guide for projects with existing patterns docs (added v2.2.0)
- `docs/release-discipline.md` — release contract (added v2.2.0)
- `docs/research/sp-anthropic-citation-manifest.md` — the binding-rule source of truth

When dispatching a sub-agent, the CTO always passes absolute paths the sub-agent should read and write. File contents are never inlined into prompts.

### 5.7. The binding rule

Every feature in the repo must cite either:
1. A Superpowers precedent (exact path + relevant snippet from SP 5.0.7), OR
2. A quoted reference from an Anthropic manual (exact quote + URL + verification date)

Plus, by extension, every architectural decision must cite at least three named enterprise or open-source implementations of the same pattern (the framework's enterprise-research-first rule, applied recursively to the framework itself).

The citation manifest at `docs/research/sp-anthropic-citation-manifest.md` is the source of truth. Every skill, agent, hook, or convention must map to a row in that manifest.

Features without citations are rejected. The choices are: find a citation, redesign to align with one that exists, or drop the feature. There is no fourth option.

### 5.8. Release discipline (added in v2.2.0)

The framework's own releases must clear four gates before shipping:

- **Gate 1 — Dogfood.** The maintainer runs the framework on real or synthetic work. At least one Tier 1, one Tier 2, and one Tier 3 cycle. Each agent type dispatched at least once. Hook gate behavior verified end-to-end. Findings logged in PROJECT-PLAN before declaring the release ready. CRITICAL/HIGH findings resolved or explicitly deferred-with-rationale before ship.
- **Gate 2 — Cross-platform smoke.** A fixed checklist runs on Linux, macOS, and Windows-via-Git-Bash. Plugin loads; framework-state-init populates; pre-tool-use behaves correctly; bypass grammar works; Builder dispatches successfully (from a git-backed project).
- **Gate 3 — Regression test per closed finding.** Every finding closed since the previous release ships with a test in `evals/regression/<finding-id>.json` that fails if the bug returns.
- **Gate 4 — Citation manifest current.** Every new skill, agent, hook, or convention since the previous release maps to a row in the citation manifest.

The framework's value to its users is durability. A release that breaks a user's project once destroys more user trust than a feature gain creates. Slow + correct beats fast + reactive.

## 6. The 18-dimension production-readiness gate (gate-3-production-check)

Run before declaring any feature production-ready. The 18 dimensions:

1. **Tenant isolation** — silo / pool / bridge model declared and respected
2. **RLS policies** — `FORCE ROW LEVEL SECURITY` enabled where applicable; policies tested
3. **Auth model** — service-role vs user-role usage correct
4. **SLO contract** — numeric SLO target defined (not derived from current performance)
5. **SLI definitions** — 4 golden signals as the floor
6. **Audit trail** — append-only log with mandatory fields (actor_id, tenant_id, action, target, timestamp), no PII, integrity-protected
7. **Security review** — auth model, RLS posture, audit trail coverage, SOC2 control mapping
8. **Performance budget** — meets numeric target measured fresh
9. **Migration phase** — expand → backfill → cutover → contract; client-shape-aware
10. **Rollback** — explicit rollback plan documented
11. **PII handling** — explicit declaration of what's stored, where, with what encryption
12. **Audit-trail integrity** — tamper-evident or hash-chained
13. **Observability** — dashboards + alert rules wired to dashboards
14. **Build / test passes** — fresh evidence, not Builder's claim
15. **Regression scope** — what other features could regress; what tests cover them; what manual smoke is needed
16. **12-factor compliance** (where applicable)
17. **Feature flag / rollback** — feature behind a flag; flag flip rolls back
18. **PROJECT-PLAN updated** — phase status, findings, incidents, remnants reflect the new feature
19. **Console-errors-clean** (when UI deliverable; via browser-driven-verification)

## 7. Empirical findings cycle

The framework is self-empirical. Every real-world use produces findings, which are logged in PROJECT-PLAN.md with:

- **ID** — F-V<n> for findings surfaced by v2 use; F-<n> for findings carried from the v1 audit
- **Severity** — CRITICAL / HIGH / MEDIUM / LOW
- **Area** — which surface (skill / agent / hook / template / plan / docs)
- **Description** — the symptom + the proposed fix shape + dependencies on other findings
- **Source** — which session / project / event surfaced it

Findings move through states: OPEN → PARTIALLY RESOLVED → RESOLVED. Resolution requires a regression test per the release-discipline contract.

The framework also tracks empirical strengths in a Validated Discipline table. Strengths are confirmed patterns to keep doing. Examples:

- **VS-01 — `enterprise-research-first`** — the three-citation rule produced binding-justified ARIA wiring on a Taskforge cycle; one mismatch (textarea vs contenteditable) was caught and deferred with rationale rather than silently shipping.
- **VS-02 — `browser-driven-verification` + Playwright MCP composability** — ARIA snapshot + console capture form a 2-tool verification cycle producing clean, diffable, durable evidence.
- **VS-03 — D-A HARD-GATE prevented "just-edit-this-real-quick" shortcuts** — empirically blocked attempts to bypass tier-selection. The blocking nature is what produces the discipline.
- **VS-04 — Compact-preservation discipline** — survived `/compact` intact across multiple sessions.
- **VS-05 — Gating ROI is net-positive** — the friction tax is justified by the catches; the gating itself caught a real misroute risk in one session that justified the gating cost many times over.

## 8. Versioning policy

- **Patch (2.x.y)** — production fixes, docs, formatting, citation-manifest additions, typos
- **Upgrade (2.x.0)** — new skills, new agents, new template sections, new structural checks
- **Major (3.0.0)** — hook contract changes, agent dispatch shape changes, breaking changes to the shared-context substrate

The version is bumped in both `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` together. The two values are kept in sync.

## 9. v2 release history

- **v2.0.0** (2026-04-26) — Foundation. 12 specialist agents, 6 architectural decisions resolved, 36-item v1 feedback audit, 14 research artifacts, citation manifest, enterprise-multi-agent-architecture comparison.
- **v2.0.2** (2026-04-30) — Phase E5 verification. D-A hook gate (tier-selection / destructive-ops / dep-add). Three-tier bypass grammar.
- **v2.0.3** (2026-04-30) — Trigger-audit instrumentation. Passive logging of every Skill/Agent/UserPromptSubmit event for trigger-fidelity analysis.
- **v2.1.0** (2026-04-30) — `heavy-read-dispatch` skill (HARD-GATE preventing main-session context burn). CONFIG path indirection for brownfield projects (closes F-V5). First public push to GitHub.
- **v2.2.0** (2026-05-09) — Consolidated upgrade closing 9 empirical findings (F-V7, F-V8, F-V10, F-V13, F-V17, F-V18, F-V20, F-V22, plus F-V9 sub-fix A2) plus ADR-006 layers D1, D3, D4, D5, A2, R1, R2, R3, M1, M2. New release-discipline contract. New brownfield onboarding doc. Measurement script. Eight regression test manifests.

## 10. Open work as of v2.2.0

The framework has known unfinished work, all logged in PROJECT-PLAN.md:

- **F-V9 A1** — cycle-state.md cooperation across skills. The cycle-close detection problem is unresolved (LLM-self-attestation is the failure mode the strength-preservation research warned against).
- **F-V11** — `browser-driven-verification` skill body has lines (110–112) that contradict the proposed real-input regression fix. Needs design decision on what replaces them.
- **F-V12** — Tier-2 ceremony fast-path threshold. Needs the WS4-aware default-deny + 8-trigger-test specification.
- **F-V14** — Validation sample size. Only one project (Taskforge) has used the framework end-to-end. The framework's own three-validation rule isn't met.
- **F-V15** — Team-mode (multi-developer on same repo). Undesigned.
- **F-V16** — CI/deploy enforcement. The production-readiness gate runs in chat, not at PR time. Needs research.
- **F-V19** — Builder permission failure. Depends on F-V20 fix actually unblocking it (verified by dispatching from a real git-backed project).
- **F-V21** — Agent-dispatch worktree cwd resolution. Likely a Claude Code-side issue, not framework-side.
- **FD-03** — Reply-shape discipline (theater suppression). Design parked explicitly.

## 11. Three core failure modes the framework prevents

Most of the framework's design exists to prevent three specific failure modes empirically observed in PF v1 and elsewhere:

### 11.1. The telephone game

PF v1 used a 7-agent custom topology where each layer was meant to translate the user's intent into the next agent's input. In practice, each translation lost fidelity, and skills that should have fired didn't. v2 was forked to escape this — by rebuilding atop Superpowers' empirically-firing skill cascade, the agent layer is one stop closer to the user, and the discovery happens via skill descriptions rather than agent-to-agent handoff.

### 11.2. Cargo-cult architecture

The pattern of "I've seen something like this before, let me copy it" without understanding why or whether it fits the current use case. The enterprise-research-first rule is the structural defense: every architectural decision must be backed by three named enterprise implementations, and the use-case-fit check is the highest precedence-ladder rule (more important than citation-strength or recency). A pattern that doesn't fit the use case is rejected even if it has unanimous enterprise consensus.

### 11.3. Silent success

The Builder reporting DONE while no code was changed (F-V10). The QA passing a build that ships a bug (F-V11). The hook quietly allowing a write that should have been blocked (F-V13). v2.2.0's empty-diff gate, dispatch-time scope declaration, browser-driven-verification specialization, and Windows path normalization are all responses to silent-success class failures. The post-mortem discipline is the audit trail that catches them: every silent success becomes a finding, every finding becomes a regression test, every regression test catches the same failure if it returns.

## 12. How to use the framework

Install via the Claude Code plugin marketplace. The framework's marketplace entry is at https://github.com/Atyab124/production-framework. Once installed, the framework boots automatically when a Claude Code session starts in a project that has it enabled.

For brownfield projects with existing artifacts (a project plan at a non-convention path, an ADR folder elsewhere, etc.), drop a `CONFIG.yaml` at the project root with `file_paths.*` entries pointing at the project's actual paths. The framework reads CONFIG before falling back to convention paths.

The user types a request. The framework dispatches the appropriate cycle. The user reviews the synthesized result. Each cycle produces durable artifacts on disk that survive `/compact` and that the next session picks up automatically.

The framework's hooks block tool calls that violate discipline. The bypass grammar exists for legitimate exceptions (a one-off destructive command after a real human decision; a known-safe environment for batch deployment). All bypasses are logged.

The framework is most valuable when the work is non-trivial — multi-file features, schema migrations, security-relevant changes. For typo fixes and one-line config edits, the framework allows direct execution; the cycle ceremony is skipped.

## 13. Bootstrap deviation note (v2.2.0)

The Builder sub-agent is in scope of several v2.2.0 fixes (F-V10 empty-diff gate, F-V20 sub-agent inheritance, F-V21 worktree-cwd issue). This means v2.2.0 was implemented via the CTO main session, not by dispatching the Builder. The release-discipline doc declares this deviation explicitly. Future releases run dogfood-via-Builder once the Builder fixes prove reliable in a real git-backed project (Taskforge or similar).

This deviation is not hidden. It is documented in `docs/cycle-state.md`, `docs/audits/gate-3-v2-2-0.md`, `docs/handovers/v2-2-0.md`, `docs/plans/v2-2-0-upgrade.md`, the ADR's scope-update note, and the RELEASE-NOTES v2.2.0 entry.

## 14. Glossary of abbreviations

- **PF v2** — production-framework v2 (this framework)
- **SP** — Superpowers (the upstream plugin PF v2 forks from)
- **ADR** — Architecture Decision Record
- **WS** — Workstream (used to label parallel research workstreams in v2.2.0 design)
- **FM** — Failure Mode (used to label adversarial-research findings)
- **F-V<n>** — Finding from v2 use
- **F-<n>** — Finding from v1 audit (carried forward)
- **VS-<n>** — Validated Strength
- **FD-<n>** — Future Decision
- **D-A / D-B / etc.** — Decision letter from the v1-feedback audit (e.g., D-A is the hook-gate decision)
- **D1 / D2 / etc.** — Detection-layer item in ADR-006
- **A1 / A2 / etc.** — Adaptation-layer item in ADR-006
- **R1 / R2 / R3** — Recovery-layer item in ADR-006
- **M1–M5** — Measurement-layer item in ADR-006
- **BC-1 ... BC-10** — Bug class taxonomy (closure-staleness, cache-invalidation, race condition, hydration mismatch, optimistic-rollback, IDOR/BOLA, N+1 query, deadlock, spec-divergence, state-machine)
- **HARD-GATE** — non-negotiable rule marker in skill bodies; enforced via hooks where possible
- **MCP** — Model Context Protocol (Anthropic's protocol for AI ↔ tool integration)
- **RLS** — Row-Level Security (Postgres feature for multi-tenant isolation)
- **SLO / SLI** — Service Level Objective / Indicator
- **BASE_SHA / HEAD_SHA** — git commit range bounding a QA review's diff scope
- **PRISMA** — Preferred Reporting Items for Systematic Reviews and Meta-Analyses (research-discipline framework cited by the researcher agent for eligibility-criteria + search-strategy reporting)
- **CTO** — the role the entry-point Claude Code session adopts; not a sub-agent
- **CONFIG** — the optional `CONFIG.yaml` at project root that overrides convention paths and declares project-specific values

## 15. Source of truth files (for verifying any claim in this document)

- `docs/PROJECT-PLAN.md` — current state of all open / resolved findings, validated discipline, future decisions, phase status
- `docs/release-discipline.md` — release contract
- `docs/onboarding-brownfield.md` — brownfield onboarding guide
- `docs/cycle-state.md` — current cycle's dispatch log
- `docs/research/sp-anthropic-citation-manifest.md` — citation source of truth (every feature → SP precedent or Anthropic citation + ≥3 enterprise analogs)
- `docs/research/enterprise-multi-agent-architecture.md` — N=7 framework comparison
- `docs/adr/006-v2-2-detection-adaptation-recovery-layer.md` — v2.2.0 architecture
- `docs/plans/v2-2-0-upgrade.md` — v2.2.0 implementation plan
- `docs/audits/qa-findings-v2-2-0.md` — QA verdict for v2.2.0
- `docs/audits/code-review-v2-2-0.md` — code-review verdict for v2.2.0
- `docs/audits/gate-3-v2-2-0.md` — production-readiness gate-3 verdict for v2.2.0
- `docs/handovers/v2-2-0.md` — release handover for v2.2.0
- `RELEASE-NOTES.md` — chronological release notes
- `CLAUDE.md` — contributor guard for this repository
- `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json` — plugin manifests
- `hooks/pre-tool-use`, `hooks/user-prompt-submit`, `hooks/session-start` — the three hooks
- `agents/<n>.md` — the 12 specialist agent definitions
- `skills/<name>/SKILL.md` — every skill body
- `evals/regression/<finding-id>.json` — regression-test manifests for closed findings
- `scripts/measurement.sh` — session-derived metrics emitter
- `scripts/structural-check.sh` — markdown-lint and structural correctness checker (runs in pre-commit hook on contributor side)
- `templates/STACK-PATTERNS.template.md` — the template projects fork to start a stack-patterns doc

## 16. Closing

The framework's working theory is that AI-assisted software work fails for a small number of recurring reasons (telephone game, cargo-cult, silent success), and that those reasons can be defended against with structured discipline that is enforced at the tool-call layer rather than preached. Every primitive in the framework — cycles, tiers, hooks, the citation rule, the production gate, the regression-test-per-finding contract — exists to defend against one of those failure modes.

The framework is opinionated and slow by design. It is not the right tool for one-off scripts or quick prototypes. It is the right tool for work that has to actually ship and stay shipped, where the cost of breaking a user's project once exceeds the cost of a slower release cadence.

Every claim in this document is auditable. Every primitive maps to a source-of-truth file listed in section 15. Every architectural decision maps to an ADR. Every behavior maps to a row in the citation manifest. Every closed finding maps to a regression-test manifest. The framework's own discipline applies to itself; this document is itself an artifact of that discipline.
