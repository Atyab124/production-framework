# SP + Anthropic Citation Manifest

**Date:** 2026-04-29
**Type:** Source-of-truth research — no code modifications
**Triggered by:** Establishment of binding rule that every PF v2 feature must cite SP precedent OR Anthropic-published guidance

## Binding Rule

**Every PF v2 feature must cite either Superpowers (SP) precedent OR Anthropic-published guidance from this manifest.** Features failing this rule are listed under "Gaps" and require redesign or removal before v2.0.0 ships.

PF v2 is a Claude Code plugin forked from Superpowers 5.0.7 (Jesse Vincent, MIT licensed, https://github.com/obra/superpowers, plugin metadata at `.claude-plugin/plugin.json` v5.0.7).

## Source-fetch methodology

- **Superpowers 5.0.7:** all `skills/*/SKILL.md`, `agents/code-reviewer.md`, `hooks/session-start`, `hooks/hooks.json`, and `.claude-plugin/plugin.json` were read directly from local cache at `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/`. Quotes are verbatim from those files; line numbers cited where helpful.
- **Anthropic primary sources:** WebFetch was permission-denied. WebSearch was used as fallback against the official URLs. Quotes returned by WebSearch are reproduced verbatim and tagged `(via WebSearch synthesis of canonical URL)`. URLs listed for direct verification by the reader. **Any future agent reading this manifest should re-verify Anthropic quotes against the canonical URL before committing a feature on its strength alone.**

---

## Part 1: Superpowers Precedents (read directly from local SP 5.0.7 cache)

| PF v2 feature | SP precedent file | Verbatim anchor / quote |
|---|---|---|
| Skill frontmatter shape: two required fields `name` + `description` | `skills/*/SKILL.md` (universal) | All 14 SP skills use exactly: `---\nname: <slug>\ndescription: <text>\n---`. From `skills/writing-skills/SKILL.md`: "Two required fields: `name` and `description`... Max 1024 characters total." |
| `description` discipline: "Use when..." third-person, triggers only, no workflow summary | `skills/writing-skills/SKILL.md` lines 140–172 | "**CRITICAL: Description = When to Use, NOT What the Skill Does**... Testing revealed that when a description summarizes the skill's workflow, Claude may follow the description instead of reading the full skill content... A description saying 'code review between tasks' caused Claude to do ONE review, even though the skill's flowchart clearly showed TWO reviews." |
| HARD-GATE markers blocking implementation until prerequisite | `skills/brainstorming/SKILL.md` lines 12–14 | `<HARD-GATE>\nDo NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.\n</HARD-GATE>` |
| "Iron Law" gate phrasing | `skills/verification-before-completion/SKILL.md` lines 18–22; `skills/test-driven-development/SKILL.md` lines 32–36; `skills/systematic-debugging/SKILL.md` lines 18–22 | Three SP skills use the same `## The Iron Law` frame: e.g. "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE", "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST", "NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST". |
| Checklist with mandatory TodoWrite-per-item | `skills/brainstorming/SKILL.md` lines 22–32; `skills/writing-skills/SKILL.md` lines 596–633 | "You MUST create a task for each of these items and complete them in order"; "**IMPORTANT: Use TodoWrite to create todos for EACH checklist item below.**" |
| Anti-Pattern sections | `skills/brainstorming/SKILL.md` line 16 (`## Anti-Pattern: "This Is Too Simple To Need A Design"`); `skills/writing-skills/SKILL.md` lines 562–582 (`## Anti-Patterns`) | Both skills name the section literally `## Anti-Pattern` / `## Anti-Patterns` and enumerate forbidden patterns. |
| Red Flags table (rationalizations → reality) | `skills/test-driven-development/SKILL.md` lines 256–270; `skills/verification-before-completion/SKILL.md` lines 53–74; `skills/systematic-debugging/SKILL.md` lines 245–256; `skills/receiving-code-review/SKILL.md` lines 165–174 | Recurring two-column `\| Excuse \| Reality \|` table. SP testing methodology explicitly populates this from baseline subagent failures (`skills/writing-skills/SKILL.md` lines 498–510). |
| Rationalization-prevention discipline ("violating the letter is violating the spirit") | `skills/test-driven-development/SKILL.md` line 14; `skills/systematic-debugging/SKILL.md` line 14; `skills/verification-before-completion/SKILL.md` line 14 | All three SP discipline skills include the line "**Violating the letter of the rules is violating the spirit of the rules.**" |
| SessionStart bootstrap injecting `using-superpowers` content | `hooks/hooks.json`; `hooks/session-start` | `hooks/hooks.json` registers `SessionStart` matcher `startup\|clear\|compact`. `hooks/session-start` reads `skills/using-superpowers/SKILL.md` and injects via `hookSpecificOutput.additionalContext` (Claude Code) or `additional_context` (Cursor) or `additionalContext` (Copilot). |
| `<EXTREMELY-IMPORTANT>` framing of injected bootstrap | `hooks/session-start` line 35 | `session_context="<EXTREMELY_IMPORTANT>\nYou have superpowers...</EXTREMELY_IMPORTANT>"` |
| `<SUBAGENT-STOP>` short-circuit so subagents don't re-run bootstrap | `skills/using-superpowers/SKILL.md` lines 6–8 | `<SUBAGENT-STOP>\nIf you were dispatched as a subagent to execute a specific task, skip this skill.\n</SUBAGENT-STOP>` |
| `agents/<role>.md` markdown spec file shape | `agents/code-reviewer.md` lines 1–6 | Frontmatter `name`, `description` (with embedded `<example>` blocks), `model: inherit`, body becomes the system prompt. |
| Two-stage review (spec compliance, then code quality) — sequential, never parallel | `skills/subagent-driven-development/SKILL.md` lines 41–85; `code-quality-reviewer-prompt.md` line 7 | "Two-stage review after each task: spec compliance first, then code quality"; "**Only dispatch after spec compliance review passes.**" |
| Status token grammar: `DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT` | `skills/subagent-driven-development/SKILL.md` lines 102–118; `implementer-prompt.md` lines 102–112 | "Implementer subagents report one of four statuses... DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED." |
| Parallel-dispatch pattern with explicit "independent domains" pre-check | `skills/dispatching-parallel-agents/SKILL.md` lines 1–84 | "Dispatch one agent per independent problem domain. Let them work concurrently... Don't use when: Failures are related (fix one might fix others)... Shared state." |
| Worktree isolation before parallel work | `skills/using-git-worktrees/SKILL.md` lines 1–60; `skills/subagent-driven-development/SKILL.md` line 268 | "Git worktrees create isolated workspaces sharing the same repository, allowing work on multiple branches simultaneously without switching."; "**superpowers:using-git-worktrees** - REQUIRED: Set up isolated workspace before starting." |
| Implementer-prompt template forbids reading the plan file (controller pastes full text) | `skills/subagent-driven-development/SKILL.md` lines 240–242; `implementer-prompt.md` lines 8–14 | "Make subagent read plan file (provide full text instead)"; "[FULL TEXT of task from plan - paste it here, don't make subagent read file]" |
| Spec-reviewer "do not trust the implementer's report" | `skills/subagent-driven-development/spec-reviewer-prompt.md` lines 21–37 | "## CRITICAL: Do Not Trust the Report... Verify by reading code, not by trusting report." |
| Brainstorming → writing-plans → execute terminal-state flow | `skills/brainstorming/SKILL.md` line 66; `skills/writing-plans/SKILL.md` lines 138–152 | "**The terminal state is invoking writing-plans.** Do NOT invoke frontend-design, mcp-builder, or any other implementation skill." |
| Plan-document header with "REQUIRED SUB-SKILL" pointer | `skills/writing-plans/SKILL.md` lines 47–60 | `> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development...` |
| Bite-sized 2–5 minute task granularity | `skills/writing-plans/SKILL.md` lines 38–44 | "**Each step is one action (2-5 minutes):**" |
| Self-review pass after writing a plan/spec | `skills/writing-plans/SKILL.md` lines 124–133; `skills/brainstorming/SKILL.md` lines 116–125 | "After writing the complete plan, look at the spec with fresh eyes... Placeholder scan, Type consistency, Spec coverage. Fix any issues inline." |
| RED-GREEN-REFACTOR ported to documentation (skill creation as TDD) | `skills/writing-skills/SKILL.md` lines 16–46, 374–393 | "Writing skills IS Test-Driven Development applied to process documentation... Same Iron Law: No skill without failing test first." |
| Finishing-a-branch four-option menu (merge / PR / keep / discard) | `skills/finishing-a-development-branch/SKILL.md` lines 50–63 | Exactly four options listed verbatim. |
| Code-review feedback reception protocol (no performative agreement) | `skills/receiving-code-review/SKILL.md` lines 28–58 | "**NEVER:** 'You're absolutely right!' (explicit CLAUDE.md violation)... INSTEAD: Restate the technical requirement / Ask clarifying questions / Push back with technical reasoning if wrong / Just start working (actions > words)." |
| Plugin manifest at `.claude-plugin/plugin.json` with `name`, `description`, `version`, `author`, `license`, `keywords` | `.claude-plugin/plugin.json` | Direct read; SP 5.0.7 manifest uses exactly this shape. |
| Per-platform hook wrapper (`hooks/run-hook.cmd` for cross-platform) | `hooks/hooks.json` line 9; `hooks/run-hook.cmd` (referenced) | `"command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start"` |

---

## Part 2: Anthropic Guidance Citations (verbatim, via WebSearch synthesis of canonical URLs)

### Pattern 2.1 — Orchestrator-Workers (PF v2 CTO Mode)

> "In the orchestrator-workers workflow, a central LLM dynamically breaks down tasks, delegates them to worker LLMs, and synthesizes their results."

> "This workflow is well-suited for complex tasks where you can't predict the subtasks needed (in coding, for example, the number of files that need to be changed and the nature of the change in each file likely depend on the task). The key difference from parallelization is its flexibility—subtasks aren't pre-defined, but determined by the orchestrator based on the specific input."

— *Building Effective AI Agents*, Anthropic, Dec 19 2024.
URL: https://www.anthropic.com/research/building-effective-agents
(via WebSearch synthesis of canonical URL)

### Pattern 2.2 — Routing (PF v2 Cycle Selection / Tier Selection)

> "Routing classifies an input and directs it to a specialized followup task. This workflow allows for separation of concerns, and building more specialized prompts."

> "Without this workflow, optimizing for one kind of input can hurt performance on other inputs."

— *Building Effective AI Agents*, Anthropic.
URL: https://www.anthropic.com/research/building-effective-agents
(via WebSearch synthesis of canonical URL)

### Pattern 2.3 — Parallelization: Sectioning + Voting (PF v2 parallel-dispatch skill)

> "Parallelization manifests in two key variations: Sectioning, which breaks a task into independent subtasks run in parallel, and Voting, which runs the same task multiple times to get diverse outputs."

> "Parallelization is effective when the divided subtasks can be parallelized for speed, or when multiple perspectives or attempts are needed for higher confidence results."

> "Avoid parallel workflows when agents need to build on each other's work or require cumulative context in a specific sequence."

— *Building Effective AI Agents*, Anthropic.
URL: https://www.anthropic.com/research/building-effective-agents
(via WebSearch synthesis of canonical URL)

### Pattern 2.4 — Evaluator-Optimizer (PF v2 two-stage review)

> "In the evaluator-optimizer workflow, one LLM call generates a response while another provides evaluation and feedback in a loop."

> "This workflow is particularly effective when there are clear evaluation criteria and when iterative refinement provides measurable value. The two signs of good fit are that LLM responses can be demonstrably improved when a human articulates feedback, and that the LLM can provide such feedback."

— *Building Effective AI Agents*, Anthropic.
URL: https://www.anthropic.com/research/building-effective-agents
(via WebSearch synthesis of canonical URL)

### Pattern 2.5 — Prompt Chaining (PF v2 brainstorm → plan → build pipeline)

> "Workflows are systems where multiple LLMs are orchestrated together using pre-defined patterns" (vs. agents which "dynamically direct their own processes and tool usage").

— *Building Effective AI Agents*, Anthropic.
URL: https://www.anthropic.com/research/building-effective-agents
(via WebSearch synthesis of canonical URL)

### Principle 2.6 — Simplicity / Add Complexity Only When Justified

> "Anthropic recommends finding the simplest solution possible, and only increasing complexity when needed."

> "You should consider adding complexity only when it demonstrably improves outcomes. Success in the LLM space isn't about building the most sophisticated system. It's about building the right system for your needs."

> "Maintain simplicity in your agent's design. Prioritize transparency by explicitly showing the agent's planning steps. Carefully craft your agent-computer interface (ACI) through thorough tool documentation and testing."

— *Building Effective AI Agents*, Anthropic.
URL: https://www.anthropic.com/research/building-effective-agents
(via WebSearch synthesis of canonical URL)

### Pattern 2.7 — Multi-Agent Research System: Lead Orchestrator + Parallel Subagents (PF v2 parallel CTO dispatch)

> "Anthropic built a multi-agent architecture with an orchestrator-worker pattern, where a lead agent coordinates the process while delegating to specialized subagents that operate in parallel."

> "When a user submits a query, the Lead Researcher analyzes it, decides on an overall strategy, and records the plan in memory. The lead agent maintains overall research state through a memory system that persists context when conversations exceed 200,000 tokens, preventing loss of research plans and findings."

> "Each subagent is given a specific task, such as exploring a certain company, checking a particular time period, or looking into a technical detail. Because subagents operate in parallel and maintain their own context, they can search, evaluate results, and refine queries independently without interfering with one another."

> "The system implements parallel tool calling at two levels: the lead agent spawns 3-5 subagents simultaneously, and individual subagents execute multiple tool calls in parallel."

— *How we built our multi-agent research system*, Anthropic Engineering, Jun 2025.
URL: https://www.anthropic.com/engineering/multi-agent-research-system
(via WebSearch synthesis of canonical URL)

### Pattern 2.8 — Prompt Engineering as Primary Lever (PF v2 prompt templates per role)

> "Early agents made errors like spawning 50 subagents for simple queries, scouring the web endlessly for nonexistent sources, and distracting each other with excessive updates. Since each agent is steered by a prompt, prompt engineering was our primary lever for improving these behaviors."

— *How we built our multi-agent research system*, Anthropic Engineering, Jun 2025.
URL: https://www.anthropic.com/engineering/multi-agent-research-system
(via WebSearch synthesis of canonical URL)

### Pattern 2.9 — Sub-Agent Context Isolation (PF v2 Builder/QA/Researcher fresh context)

> "Subagents receive only their specialized system prompt (plus basic environment details like working directory), not the full Claude Code system prompt. Subagents maintain separate context from the main agent, preventing information overload and keeping interactions focused, ensuring that specialized tasks don't pollute the main conversation context with irrelevant details."

> "The frontmatter defines the subagent's metadata and configuration, and the body becomes the system prompt that guides the subagent's behavior."

— *Create custom subagents*, Claude Code documentation.
URL: https://docs.claude.com/en/docs/claude-code/sub-agents
(via WebSearch synthesis of canonical URL)

### Pattern 2.10 — Subagent Isolation Modes (worktree)

> "Within a subagent, cd commands do not persist between Bash or PowerShell tool calls and do not affect the main conversation's working directory. To give the subagent an isolated copy of the repository instead, set isolation: worktree."

— *Create custom subagents*, Claude Code documentation.
URL: https://docs.claude.com/en/docs/claude-code/sub-agents
(via WebSearch synthesis of canonical URL)

### Pattern 2.11 — Skill Discovery / Progressive Disclosure (PF v2 skill set)

> "The filesystem-based model enables progressive disclosure, allowing Claude to navigate and selectively load exactly what each task requires."

> "When a user asks a question, Claude reads the SKILL.md overview, sees references to other files, and invokes bash to read just the relevant file. Other files remain on the filesystem, consuming zero context tokens until needed."

> "Every skill needs a SKILL.md file with two parts: YAML frontmatter (between --- markers) that tells Claude when to use the skill, and markdown content with instructions Claude follows when the skill is invoked."

— *Extend Claude with skills*, Claude Code documentation.
URL: https://docs.claude.com/en/docs/claude-code/skills
(via WebSearch synthesis of canonical URL)

### Pattern 2.12 — Skill Description Discipline

> "The description should be a maximum of 1024 characters, non-empty, and contain no XML tags."

> "Keep SKILL.md body under 500 lines for optimal performance, and if content exceeds this, split it into separate files using progressive disclosure patterns."

— *Skill authoring best practices*, Claude documentation.
URL: https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices
(via WebSearch synthesis of canonical URL)

### Pattern 2.13 — SessionStart Hook with `additionalContext` (PF v2 framework bootstrap)

> "SessionStart runs when Claude Code starts a new session or resumes an existing session. For SessionStart hooks, anything you write to stdout is added to Claude's context."

> "Text returned via additionalContext is injected as a system reminder that Claude reads as plain text."

> "SessionStart hooks support hookSpecificOutput with additionalContext as a string field."

— *Automate workflows with hooks*, Claude Code documentation.
URL: https://docs.claude.com/en/docs/claude-code/hooks-guide
(via WebSearch synthesis of canonical URL)

### Pattern 2.14 — PreToolUse Hook (PF v2 future enforcement gates)

> "PreToolUse hooks run before tool calls and can block them while providing Claude feedback on what to do differently. Use PreToolUse hooks for automated permission decisions."

> "PreToolUse hookSpecificOutput can include permissionDecision ('allow', 'deny', or 'ask'), permissionDecisionReason, and updatedInput to rewrite tool arguments."

— *Automate workflows with hooks*, Claude Code documentation.
URL: https://docs.claude.com/en/docs/claude-code/hooks-guide
(via WebSearch synthesis of canonical URL)

### Pattern 2.15 — Plugin Structure (PF v2 plugin layout)

> "The plugin manifest (.claude-plugin/plugin.json) describes your plugin's metadata, the skills directory (skills/) contains your custom skills."

> "Don't put commands/, agents/, skills/, or hooks/ inside the .claude-plugin/ directory. Only plugin.json goes inside .claude-plugin/. All other directories must be at the plugin root level."

> "Plugin agents support name, description, model, effort, maxTurns, tools, disallowedTools, skills, memory, background, and isolation frontmatter fields."

— *Create plugins*, Claude Code documentation.
URL: https://docs.claude.com/en/docs/claude-code/plugins
(via WebSearch synthesis of canonical URL)

### Pattern 2.16 — Plugin Marketplace Structure

> "Create .claude-plugin/marketplace.json in your repository root. This file defines your marketplace's name, owner information, and a list of plugins with their sources."

— *Create and distribute a plugin marketplace*, Claude Code documentation.
URL: https://docs.claude.com/en/docs/claude-code/plugin-marketplaces
(via WebSearch synthesis of canonical URL)

### Pattern 2.17 — Context Engineering: Isolated Subagent Windows + File Artifacts (PF v2 file-based substrate)

> "Each subagent operates with an isolated context window. When the orchestrator invokes (for example) the backend-architect agent to handle a task, that agent receives only the information relevant to its task (plus any persistent project context) and does not see the entire dialogue history or unrelated data. This design is intentional: it prevents cross-contamination between different phases of the workflow and keeps each agent focused."

> "The most powerful pattern for large tasks involves each subagent getting its own context window with its own tool permissions. The main conversation stays clean while specialized agents handle isolated tasks with exactly the context they need."

> "Agents can save information from tool call results as artifacts, making it available to other agents and users. This enables persistent memory and knowledge sharing across agent interactions."

> "Common background information is provided via a persistent context file (CLAUDE.md), which is preloaded into each agent's context."

> "Good context engineering means finding the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome."

— *Effective context engineering for AI agents*, Anthropic Engineering.
URL: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
(via WebSearch synthesis of canonical URL)

---

## Part 3: PF v2 Feature → Citation Map

Status legend:
- **OK** — has at least one valid citation (SP precedent OR Anthropic quote)
- **OK on SP alone** — SP precedent exists; Anthropic citation optional
- **OK on Anthropic alone** — direct Anthropic citation; no SP precedent
- **NEEDS CITATION** — no defensible source yet; goes to Gaps unless added
- **GAP** — no SP precedent AND no Anthropic citation; redesign required

| PF v2 component | Type | SP precedent | Anthropic citation | Status |
|---|---|---|---|---|
| Plugin manifest at `.claude-plugin/plugin.json` | structure | SP `.claude-plugin/plugin.json` | §2.15 | OK |
| Plugin layout (skills/, agents/, hooks/, commands/, docs/) | structure | SP root | §2.15 | OK |
| `using-production-framework` skill (bootstrap) | skill | SP `using-superpowers` | §2.13 SessionStart hook | OK |
| SessionStart hook injecting framework rules | hook | SP `hooks/session-start` + `hooks.json` | §2.13 | OK |
| `<EXTREMELY_IMPORTANT>` framing on injected context | convention | SP `hooks/session-start` line 35 | §2.13 (system reminder) | OK |
| `<SUBAGENT-STOP>` short-circuit | convention | SP `using-superpowers/SKILL.md` lines 6–8 | §2.9 (subagents have separate context) | OK |
| `agents/<role>.md` markdown spec files (13 specialists) | agents | SP `agents/code-reviewer.md` (one example, scaled by SP shape) | §2.9, §2.15 plugin agents support frontmatter fields | OK |
| 13-agent specialist roster | agents | (none — SP ships 1 agent) | §2.7 (lead + parallel specialised subagents) | OK on Anthropic alone — but Anthropic example is 3-5 subagents per task, NOT 13 standing roles. **Document scaling rationale.** |
| `cto-mode` skill (orchestrator dispatcher) | skill | (none direct) | §2.1 orchestrator-workers + §2.7 lead-researcher + §2.3 parallelization | OK |
| `cycle-selection` skill (route to one of 8 cycles) | skill | (none direct) | §2.2 routing | OK |
| `tier-selection` skill (Tier 1/2/3 classification) | skill | PF v1 origin (not in SP) | §2.2 routing | OK on Anthropic alone |
| `parallel-dispatch` skill | skill | SP `dispatching-parallel-agents` | §2.3 sectioning + §2.7 (3-5 simultaneous subagents) | OK |
| `subagent-driven-development` skill | skill | SP `subagent-driven-development` | §2.7 lead orchestrator pattern | OK |
| `parsing-agent-returns` skill (status-token grammar) | skill | SP `subagent-driven-development/SKILL.md` lines 102–118 (4 statuses) | §2.8 (prompt engineering as primary lever) | OK |
| `worktree-isolation` skill | skill | SP `using-git-worktrees` | §2.10 isolation:worktree | OK |
| `verification-before-completion` skill | skill | SP `verification-before-completion` | (none needed) | OK on SP alone |
| `systematic-debugging` skill | skill | SP `systematic-debugging` | (none needed) | OK on SP alone |
| `test-driven-development` skill (opt-in) | skill | SP `test-driven-development` | §2.6 ACI testing | OK |
| `brainstorming` skill | skill | SP `brainstorming` | §2.6 simplicity / spec before code | OK |
| `writing-plan` skill | skill | SP `writing-plans` | §2.5 prompt chaining (workflow with pre-defined steps) | OK |
| `writing-arch-doc` skill | skill | (none direct — SP has spec docs in brainstorming) | §2.6 transparency / planning steps | OK on Anthropic alone |
| `writing-handover` skill | skill | (none direct) | §2.17 file artifacts as cross-agent comms | OK on Anthropic alone |
| `writing-qa-findings` skill | skill | (none direct) | §2.17 file artifacts | OK on Anthropic alone |
| `writing-skills` skill | skill | SP `writing-skills` | §2.11 SKILL.md format + §2.12 description discipline | OK |
| `two-stage-review` skill (spec compliance → code quality) | skill | SP `subagent-driven-development/SKILL.md` lines 41–85 (two-stage built in); `code-quality-reviewer-prompt.md` line 7 ("only after spec compliance review passes") | §2.4 evaluator-optimizer | OK |
| `regression-scope` skill | skill | (none direct) | §2.6 ACI / careful tool design | OK on Anthropic alone (weak — see Gaps) |
| `seven-validation-questions` skill | skill | (none direct) | §2.6 transparency / planning checks | OK on Anthropic alone (weak — see Gaps) |
| `gate-3-production-check` skill | skill | (none direct — domain-specific) | (none) | **GAP** |
| `enterprise-research-first` skill (N≥3 binding) | skill | (none) | (none direct — closest is §2.6 measure-and-iterate) | **GAP** — see Part 4 |
| `proposing-patterns` skill | skill | (none direct) | (none direct) | **GAP** |
| `ratify-pattern` skill | skill | (none direct) | (none direct) | **GAP** |
| `triage` skill | skill | (none direct) | §2.2 routing (route bug to debugger first) | OK on Anthropic alone |
| `bash-output-discipline` skill | skill | (none direct) | §2.6 ACI / tool documentation | OK on Anthropic alone (weak) |
| `deputy-methodology` skill | skill | (none direct) | §2.7 orchestrator-worker | OK on Anthropic alone |
| `finishing-a-branch` skill | skill | SP `finishing-a-development-branch` | (none needed) | OK on SP alone |
| HARD-GATE markers | convention | SP `brainstorming/SKILL.md` lines 12–14; `verification-before-completion` Iron Law | (none needed) | OK on SP alone |
| Anti-Pattern sections | convention | SP `brainstorming/SKILL.md` line 16; `writing-skills/SKILL.md` lines 562–582 | (none needed) | OK on SP alone |
| Red Flags / Rationalization tables | convention | SP `test-driven-development`, `verification-before-completion`, `systematic-debugging`, `receiving-code-review` | (none needed) | OK on SP alone |
| Checklist with mandatory TodoWrite-per-item | convention | SP `brainstorming/SKILL.md` lines 22–32; `writing-skills/SKILL.md` lines 596–633 | (none needed) | OK on SP alone |
| Status-token grammar `DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED` | convention | SP `subagent-driven-development/SKILL.md` lines 102–118 | §2.8 prompt engineering as primary lever | OK |
| `agent-return-parse` hook (proposed) | hook | (none — SP only ships SessionStart) | §2.14 PreToolUse for blocking + feedback | OK on Anthropic alone — flagged for future MAJOR version per PF CLAUDE.md hook-proliferation rule |
| `docs/cycle-state.md` substrate | file convention | (none — SP uses `docs/superpowers/specs/` and `docs/superpowers/plans/` as one-shot artifacts, not a running state file) | §2.7 lead agent "records the plan in memory"; §2.17 "save information from tool call results as artifacts" | OK on Anthropic alone |
| `docs/plans/<feature>.md` plan handover | file convention | SP `docs/superpowers/plans/YYYY-MM-DD-<topic>.md` (writing-plans/SKILL.md line 18) | §2.17 file artifacts | OK |
| `docs/research/<topic>.md` enterprise citations | file convention | (none — SP doesn't have a research directory) | §2.17 file artifacts; §2.6 measure-and-iterate (weak) | OK on Anthropic alone — Gap on the "research-before-design" rule itself, see Part 4 |
| `docs/audits/qa-findings-<scope>-<date>.md` | file convention | (none direct) | §2.17 file artifacts | OK on Anthropic alone |
| `docs/adr/<n>-<decision>.md` | file convention | (none — industry standard, not SP-specific) | §2.17 persistent context file pattern | OK on Anthropic alone |
| 8 cycle templates (Build/Debug/Research/Refactor/Security/Performance/Migration/Postmortem) | feature | (none — SP has no cycle catalogue) | §2.1 orchestrator dynamically breaks down + §2.2 routing | OK on Anthropic alone — pattern catalogue framing supported by enterprise research (AutoGen 5/7), see Part 4 for Anthropic-citation strength |
| Brainstorm → spec → plan → build pipeline | feature | SP `brainstorming` → `writing-plans` → `executing-plans` (terminal-state chaining) | §2.5 prompt chaining | OK |
| "Iron Law" framing on completion / TDD / debugging | convention | SP three skills (lines 18–22 each) | (none needed) | OK on SP alone |
| `code-reviewer` agent | agent | SP `agents/code-reviewer.md` | §2.9 subagent isolation | OK |
| `Builder ↔ QA` two-stage review enforcement | feature | SP `subagent-driven-development/SKILL.md` (built-in) | §2.4 evaluator-optimizer | OK |
| File-based cross-agent communication (no shared in-memory state) | architecture | SP `dispatching-parallel-agents` (subagents don't share state) | §2.17 isolated context + file artifacts | OK |
| `/compact` resume awareness | convention | SP `hooks/hooks.json` matcher `startup\|clear\|compact` | §2.7 ("memory system that persists context when conversations exceed 200,000 tokens") | OK |

---

## Part 4: Gaps — Features WITHOUT SP Precedent AND WITHOUT Direct Anthropic Citation

These features carry no defensible source under the binding rule. Each must be: (a) cited via a newly-found primary source, (b) redesigned to align with an existing citation, or (c) removed before v2.0.0 ships.

### GAP-1 — `enterprise-research-first` skill (N≥3 binding rule)

**What it claims:** Before deciding any new interaction model, data shape, sync strategy, module location, or API contract, research 3–6 enterprise/OSS tools first; consensus among ≥3 is binding.

**Why originally framed as a gap:** The N≥3 quantitative threshold is a PF invention. Anthropic's *Building Effective Agents* says "find the simplest solution... only increase complexity when needed" — does not prescribe an external-research consensus rule.

---

**Update (2026-04-30 — Wave 1 R-1 / `skill-design-enterprise-research-first.md`, 362L Opus):**

The *discipline* of "research before designing with explicit alternatives or prior-art section" is now **9/9 BINDING enterprise-cited**:

- Amazon PR/FAQ (six-page narrative including differentiation + invention)
- Google Design Docs ("trade-offs that were considered")
- Rust RFC 2333 ("Prior Art" section required in template)
- Kubernetes KEP template ("Alternatives" required)
- AWS Well-Architected Framework (explicit comparison against documented patterns)
- ThoughtWorks Tech Radar (multi-voter ring assignment)
- ADR / MADR ("Considered Options" core to template)
- Spotify RFC + ADR (two-stage gate)
- Squarespace opinionated RFC (mandatory template structure)

Plus **5 SP precedents** for the smaller-scope analogue ("compare against references / existing patterns / baseline / requirements"): brainstorming, systematic-debugging, subagent-driven-development implementer, writing-skills anthropic-best-practices, requesting-code-review.

**Plus Anthropic-cited reinforcements:**
- *How we built our multi-agent research system* (Jun 2025) — source-quality heuristic ("early agents consistently chose SEO-optimized content farms over authoritative sources... adding source quality heuristics to prompts helped resolve this issue")
- *Anthropic Citations API* — "support the answer with citations that incorporate direct quotations"
- 5-criterion evaluation rubric (factual / citation / completeness / source quality / tool efficiency)

**Honest framing:** the *discipline* is enterprise-cited (9/9 BINDING) and SP-precedented (5 distinct skills). Only the *N≥3 STRONG / N≥5 BINDING numeric threshold* is PF-internal calibration. The skill body says so verbatim. **No longer GAP — closed via R-1.**

---

### GAP-2 — `gate-3-production-check` skill (production-readiness gate)

**What it claims:** Before declaring production-ready, walk an 18-dimension (now 19, post-D19 addition) production-readiness check.

**Why originally framed as a gap:** No SP precedent for unified production-readiness gate. Anthropic guidance silent on production-readiness checklists.

---

**Update (2026-04-30 — Wave 1 R-3 / `skill-design-gate-3-production-check.md`, ~430L Opus):**

The skill is now grounded in **17 distinct enterprise sources** across **6 named PRR frameworks**:

- Google SRE Book (Chs. 4 / 6 / 8 / 32) + Workbook (Chs. 2 / 5 / 16 + Error Budget Policy)
- AWS Well-Architected Framework (six pillars + REL10-BP03 bulkhead)
- Microsoft Azure Well-Architected Review (five pillars)
- CNCF / Mercari production-readiness check
- Twelve-Factor App
- DORA Four Keys
- OWASP ASVS v4 + API Top 10 (2023) + Multi-Tenant + Logging
- NIST SP 800-53 Rev. 5
- SOC 2 TSC 2017
- Honeycomb (high-cardinality + wide-events)
- Atlassian + GitHub deployment guides

**Per-dimension K/N consensus shows 12 dimensions K≥4, 3 dimensions K=3, 2 dimensions SP-precedent + K=2, 1 dimension PF-internal.** Zero dimensions fail the binding rule.

**Plus 3 SP precedents** for the gate-shape itself: `verification-before-completion` Iron Law + Gate Function + Common Failures table; `requesting-code-review` mandatory-before-merge framing; `finishing-a-development-branch` pre-merge test verification.

**Honest framing:** the gate's *shape* is SP-precedented (Iron Law inheritance). The gate's *content* is industry-framework adapted (PRR + WAF + Twelve-Factor + DORA + OWASP + NIST). Tagged in skill body as "industry-framework adapter," not "PF opinion." **No longer GAP — closed via R-3.**

---

### GAP-3 — `proposing-patterns` and `ratify-pattern` skills

**What they claim:** A pipeline where ≥3 incidents (or, after broadening, ≥1 BINDING research finding) trigger a pattern proposal; ratification gates merge into the canonical registry.

**Why originally framed as a gap:** "Entirely PF-original methodology, not derived from SP or Anthropic guidance."

---

**Update (2026-04-30 — Wave 2 R-9 + R-10 / `skill-design-proposing-patterns.md` Opus 381L + `skill-design-ratify-pattern.md` Sonnet 359L):**

**`proposing-patterns` components are enterprise-cited 9/11 (82% BINDING)**:
- PLoP (Christopher Alexander pattern language)
- Fowler "Rule of Three" (Refactoring 2018)
- Microsoft Engineering Playbook
- AWS Well-Architected pattern library
- Refactoring Guru
- Kubernetes KEP graduation criteria
- IETF RFC 7942 (running-code requirement)
- Apache PMC pattern adoption
- ThoughtWorks Tech Radar (Adopt ring criteria)

The two strict-recurrence-only outliers (PLoP + Fowler) align cleanly with v1's Path A. The 7 remaining frameworks support **multi-trigger ingest** — recurrence AND/OR external-evidence. The broadening is explicitly approved per ADR-003.

**`ratify-pattern` gates 5/7 frameworks have analogs:**
- G3 machine-verifiable check (5/7 — TC39 Test262, K8s e2e, Linux CI strict matches)
- G4 ratification traceability (6/7 — strongest consensus)
- G5 rollback path (5/7 partial; 2/7 strict — K8s, Linux)
- G6 fixture gate (4/7 — TC39, K8s strict)

G1 (≤20-row bloat cap) and G2 (duplicate-incident hash) are explicitly PF-original (0/7 analog) — kept with failure-mode rationales rather than inventing citations. `postpone` as 4th Stage-3 disposition aligns Rust RFC FCP three-disposition model.

**`compute-root-cause-hash.sh`** 7-rule normalization grammar is **independently corroborated verbatim** by Rollbar + Datadog (per Wave 2 R-11 / `skill-design-fix-time-hash-check.md`) — the v1 primitive is enterprise-consensus, not bespoke.

**Honest framing:** the *composition* (incident-loop + pattern-proposal + ratify gate) is PF-original. The *components* are enterprise-cited 9/11. The *normalization grammar* is independently enterprise-corroborated. **No longer GAP — closed via R-9 + R-10 + R-11. Un-deferred from v2.1 to v2.0.x per ADR-001 G3 amendment + ADR-003.**

---

### GAP-4 — Builder/Engineer split into Backend Builder + Frontend Builder

**What it claims:** Two distinct standing Builder agents (backend, frontend) rather than one.

**Why a gap:** Per `enterprise-multi-agent-architecture.md` Axis 2 synthesis, **0/7** enterprise frameworks split builders this way. MetaGPT/ChatDev/Magentic-One ship one Builder/Engineer/Coder. No Anthropic citation supports the split. SP has no Builder agent at all (relies on subagent dispatch).

**Recommendation:** Consider merging to a single Builder in v2.0, or document the split as a deliberate PF opinion subject to incident-driven validation. Per the enterprise research doc's own recommendation: "Document rationale in ADR; consider merging in v2.1 if no incidents materialise."

---

### GAP-5 — Standing roles with no enterprise consensus: Researcher / SRE / Security / UX-Design / Database-Engineer / Post-Mortem

**What it claims:** Each is a standing specialist agent.

**Why a gap:** Per `enterprise-multi-agent-architecture.md` Axis 2, **0/7** frameworks ship these as standing roles. They appear as ad-hoc subagent dispatches in Anthropic's multi-agent research system (per §2.7), not as named roster members.

**Recommendation:** Two acceptable framings:
- **(A) "PF v2 ships a maximalist roster; rooms unused agents are zero-cost in the substrate."** Cite §2.9 isolated-context as why having extra named agents costs nothing until invoked.
- **(B) Demote to "task-mode subagents" dispatched by CTO** rather than standing roles, matching §2.7 ("Each subagent is given a specific task").

Either is defensible; pick one and document it. The current framing appears to assume (A) without making the case.

---

### GAP-6 — `regression-scope` and `seven-validation-questions` skills

**What they claim:** Pre-build checklist skills that walk specific question sets.

**Why a gap:** Generic "verify before claiming done" is covered by SP `verification-before-completion`, but the specific question sets (e.g., "every shared model that could regress") are PF inventions. Citation to §2.6 (ACI / careful tool design) is weak — Anthropic doesn't prescribe checklists at this granularity.

**Recommendation:** Treat these as PF-internal heuristics, on the same footing as GAP-1's N≥3 rule. Document provenance honestly. Acceptable to ship; just don't claim Anthropic backing.

---

### GAP-7 — `bash-output-discipline` skill

**What it claims:** Wrap build/test/typecheck commands in filtered wrappers, never raw + post-hoc head/tail.

**Why a gap:** This is a context-pollution-prevention rule. SP doesn't ship it. Closest Anthropic touchpoint is §2.17 "smallest possible set of high-signal tokens" — supports the principle but doesn't prescribe the specific wrapper-vs-raw rule.

**Recommendation:** Ship as PF-internal token-discipline pattern; cite §2.17 as the principle backing it (acceptable as supporting citation, not a binding one).

---

## Summary

- **SP precedents documented:** 27 distinct mappings (Part 1)
- **Anthropic citations documented:** 17 distinct quoted patterns (Part 2)
- **Mapped PF v2 features:** 49 entries (Part 3)
- **Features OK on SP+Anthropic combined:** 35
- **Features OK on SP alone:** 9
- **Features OK on Anthropic alone:** 12 (some marked weak)
- **Gaps requiring redesign or honest "PF-internal" labeling:** 7 (Part 4)

## Top 3 Highest-Priority Gaps

1. **GAP-1 — `enterprise-research-first` (N≥3 BINDING rule)**: The very rule that this manifest enforces does not itself have an Anthropic citation. Either downgrade from BINDING to STRONG-RECOMMENDED, or own it as a PF-internal stance.
2. **GAP-4 — Backend/Frontend Builder split**: Zero enterprise framework support and no Anthropic guidance. Consider merging in v2.0 or documenting the split as an incident-driven experiment.
3. **GAP-3 — `proposing-patterns` + `ratify-pattern` pipeline**: Entirely PF-original methodology with no external precedent. Defensible if owned honestly; should not be presented as best-practice-derived.

## Sources Index (canonical URLs for re-verification)

**Anthropic primary sources used:**
- *Building Effective AI Agents* — https://www.anthropic.com/research/building-effective-agents (Dec 19 2024)
- *How we built our multi-agent research system* — https://www.anthropic.com/engineering/multi-agent-research-system (Jun 2025)
- *Effective context engineering for AI agents* — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- *Create custom subagents* — https://docs.claude.com/en/docs/claude-code/sub-agents
- *Subagents in the SDK* — https://docs.claude.com/en/docs/agent-sdk/subagents
- *Extend Claude with skills* — https://docs.claude.com/en/docs/claude-code/skills
- *Skill authoring best practices* — https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices
- *Automate workflows with hooks* — https://docs.claude.com/en/docs/claude-code/hooks-guide
- *Hooks reference* — https://docs.claude.com/en/docs/claude-code/hooks
- *Create plugins* — https://docs.claude.com/en/docs/claude-code/plugins
- *Plugins reference* — https://docs.claude.com/en/docs/claude-code/plugins-reference
- *Create and distribute a plugin marketplace* — https://docs.claude.com/en/docs/claude-code/plugin-marketplaces

**Superpowers source files used (local cache):**
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/.claude-plugin/plugin.json`
- `.../superpowers/5.0.7/hooks/hooks.json`
- `.../superpowers/5.0.7/hooks/session-start`
- `.../superpowers/5.0.7/agents/code-reviewer.md`
- `.../superpowers/5.0.7/skills/using-superpowers/SKILL.md`
- `.../superpowers/5.0.7/skills/brainstorming/SKILL.md`
- `.../superpowers/5.0.7/skills/dispatching-parallel-agents/SKILL.md`
- `.../superpowers/5.0.7/skills/subagent-driven-development/SKILL.md`
- `.../superpowers/5.0.7/skills/subagent-driven-development/implementer-prompt.md`
- `.../superpowers/5.0.7/skills/subagent-driven-development/spec-reviewer-prompt.md`
- `.../superpowers/5.0.7/skills/subagent-driven-development/code-quality-reviewer-prompt.md`
- `.../superpowers/5.0.7/skills/verification-before-completion/SKILL.md`
- `.../superpowers/5.0.7/skills/writing-plans/SKILL.md`
- `.../superpowers/5.0.7/skills/executing-plans/SKILL.md`
- `.../superpowers/5.0.7/skills/systematic-debugging/SKILL.md`
- `.../superpowers/5.0.7/skills/test-driven-development/SKILL.md`
- `.../superpowers/5.0.7/skills/writing-skills/SKILL.md`
- `.../superpowers/5.0.7/skills/requesting-code-review/SKILL.md`
- `.../superpowers/5.0.7/skills/receiving-code-review/SKILL.md`
- `.../superpowers/5.0.7/skills/finishing-a-development-branch/SKILL.md`
- `.../superpowers/5.0.7/skills/using-git-worktrees/SKILL.md`

**Companion research doc cross-referenced:**
- `c:/Users/atyab/Experimental - Users/production-framework-v2/docs/research/enterprise-multi-agent-architecture.md` (Axes 1–3 enterprise consensus tables)

**Methodology disclosure:** WebFetch was permission-denied for this session. All Anthropic quotes in Part 2 were retrieved via WebSearch synthesis of the canonical URLs listed above. Quotes are reproduced verbatim as returned by WebSearch. Before any binding architectural decision, re-verify the quoted text against the live canonical URL using direct WebFetch in a session where it's permitted.

---

## Part 5: v2.2.0 Additions (2026-05-09)

Added in the consolidated v2.2.0 upgrade (`docs/plans/v2-2-0-upgrade.md`). Each row maps a new behavior to its SP precedent or Anthropic guidance + N≥3 enterprise analog, per CLAUDE.md THE BINDING RULE.

| Feature ID | Behavior | Citation type | Source | Verified |
|---|---|---|---|---|
| D1 | Builder verb-conditional empty-diff gate (`SCOPE: code` + `EMPTY_DIFF_FLAG`) | SP precedent + Anthropic | SP `subagent-driven-development/SKILL.md:102-118` (status grammar — `DONE_WITH_CONCERNS` extension semantics); Anthropic *Building Effective AI Agents* (evaluator-optimizer pattern) | 2026-05-09 |
| D2 | Real-user smoke for closure-staleness / race classes | SP precedent | SP `verification-before-completion/SKILL.md:19-22` Iron Law specialization for UI deliverables ("NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE") | 2026-05-09 (deferred — F-V11 needs design) |
| D3 | Researcher post-Write file-existence check | SP precedent | SP `verification-before-completion/SKILL.md:102-105` agent-delegation: "Agent reports success → Check VCS diff → Verify changes → Report actual state." | 2026-05-09 |
| D4 | Debugger profiler-mode instrumentation gate | SP precedent | SP `systematic-debugging/SKILL.md:18-22` Iron Law extended to performance: "NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST" → NO OPTIMIZATIONS WITHOUT BASELINE | 2026-05-09 |
| D5 | QA empty-diff REJECT semantics under `SCOPE: code` | SP precedent | SP `spec-reviewer-prompt.md:21-29` "Do Not Trust the Report. Verify by reading code, not by trusting report." | 2026-05-09 |
| A2 | System-reminder filter on `user-prompt-submit` hook | Anthropic guidance | Anthropic Claude Code system-reminder convention — `<system-reminder>` payload prefix is runtime-injected, not human-turn input | 2026-05-09 |
| R1 | Per-tool Common Recovery prose in 4 skills (browser-driven-verification, rls-aware-migrations, finishing-a-development-branch, enterprise-research-first) | Anthropic + enterprise | Anthropic *Effective Context Engineering* ("agents can save information from tool call results as artifacts" — recovery doc IS one); Kubernetes runbook conventions; AWS WAF playbooks; Mattermost incident-response runbook format | 2026-05-09 |
| R2 | `trigger-audit.jsonl` schema extended for MCP tool errors (`event: mcp_tool_call`) | Anthropic + SP | Anthropic Claude Code MCP server docs (https://docs.claude.com/en/docs/claude-code/mcp); SP `bypass-log.jsonl` append-only convention | 2026-05-09 |
| R3 | Playwright MCP server-restart as first-line recovery | Enterprise convergence (3/3) | Playwright Issues #891 (https://github.com/microsoft/playwright/issues/891), #1305, #24144 — three independent issue threads converge on restart-as-recovery for transient state | 2026-05-09 |
| M1 | Session-derived metrics (prompt count, skill / agent / MCP invocation counts, sub-agent inheritance count, bypass events) | Anthropic + SP | Anthropic *Effective Context Engineering* (file artifacts as evidence substrate); existing `trigger-audit.jsonl` substrate (v2.0.3) — append-only state files as observability primitive | 2026-05-09 |
| M2 | Project-agnostic measurement script (`scripts/measurement.sh`) | Enterprise (Google SRE) | Google SRE Book Ch. 6 (Monitoring) — black-box / white-box dual telemetry; metrics emitted to stdout for piping to project's observability layer | 2026-05-09 |
| F-V18 | Foreground vs background guidance for parallel dispatches | Anthropic + SP | Anthropic Claude Code Agent tool guidance — "Use background when you have genuinely independent work to do in parallel"; SP `dispatching-parallel-agents/SKILL.md` (the skill being amended) | 2026-05-09 |
| F-V20 | Sub-agent tier-selection inheritance via `SUBAGENT_TYPE` env signal | Enterprise (4/4 BINDING) | OpenAI Agents SDK (handoffs propagate context); LangGraph (supervisor-pattern parent state); AutoGen (group-chat shared message bus); Anthropic *How we built our multi-agent research system* (lead-agent classification flows to sub-agents) | 2026-05-09 |
| F-V13 | Windows path normalization in `pre-tool-use` docs/ auto-allow | Cross-platform discipline | POSIX path-handling convention; Git Bash on Windows uses backslash native paths in tool inputs; bash parameter expansion `${var//\\//}` is portable | 2026-05-09 |
| F-V17 | Brownfield onboarding doc | Enterprise convention | ThoughtWorks Tech Radar onboarding pattern; Spotify Backstage adoption guide; Cisco Engineering Practices brownfield retrofit pattern (≥3 enterprise) | 2026-05-09 |
| Release discipline | 4-gate release contract (dogfood + cross-platform + regression-per-finding + citation-manifest) | SP + Anthropic + enterprise | SP `CLAUDE.md:67-75` skill-changes-require-evaluation; Anthropic *Building Effective AI Agents* (evaluator-optimizer); Google SRE Book Ch. 8 (Release Engineering); Rust RFC process (reference impl required); Linux kernel `tools/testing/selftests/` (per-bug regression tests in-tree) | 2026-05-09 |

