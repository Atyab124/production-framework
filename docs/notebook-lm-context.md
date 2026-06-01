# Plugin Authorship via production-framework — A Context Pack for NotebookLM

> **Audience:** A junior dev who wants to read this once, paste it into NotebookLM, and walk out a master at authoring Claude Code plugins and skills. The production-framework plugin is used as the worked example throughout — every concept is anchored to a real file at a real path so you can verify it.
>
> **Scope:** Everything you need to (a) read production-framework's code without getting lost, (b) build your own plugin from scratch, (c) understand WHY this plugin is shaped the way it is — not just WHAT it does.
>
> **Reading order:** Top-to-bottom on first read. After that, jump by topic via the table of contents.

---

## Table of contents

1. The 30-second mental model
2. What a Claude Code plugin actually is
3. Repository anatomy (file tree map)
4. The five primitives:
   - 4.1 Plugin packaging (`.claude-plugin/`)
   - 4.2 Skills (`skills/*/SKILL.md`)
   - 4.3 Agents (`agents/*.md`)
   - 4.4 Hooks (`hooks/hooks.json` + scripts + polyglot wrapper)
   - 4.5 State (`.framework-state/`, JSONL convention)
5. Composition patterns — how the primitives interact
6. The CTO orchestrator pattern (this plugin's special sauce)
7. The binding citation rule
8. Cycle definitions (the 8 named workflows)
9. The configurable gate system (42-gate catalog, three tiers)
10. Multi-platform support (Codex, Cursor, OpenCode, Gemini)
11. Building your own plugin — minimum viable to full orchestrator
12. Common gotchas (lessons from FEEDBACK.md)
13. Reference map — where to look in the repo

---

## 1. The 30-second mental model

A **Claude Code plugin** is a directory with a `.claude-plugin/plugin.json` manifest. When installed, Claude Code loads its skills, agents, and hooks into the session.

**production-framework** is one such plugin. It does something specific: it turns a normal Claude session into a "CTO" that orchestrates 12 specialist sub-agents through 8 named workflows. The orchestrator is just a skill (`cto-mode`) that fires when you describe non-trivial work; the specialists are sub-agents you dispatch via the `Agent` tool; the workflows are templates the orchestrator reads from another skill (`cycle-selection`); and the rules that catch violations are bash scripts under `hooks/`.

That's it. Five primitives — plugin manifest, skills, agents, hooks, state files — composed in specific ways. Every line of production-framework is one of those five things or something that orchestrates them.

---

## 2. What a Claude Code plugin actually is

A plugin is a Git-cloneable directory installed via:

```
/plugin marketplace add https://github.com/<owner>/<repo>
/plugin install <plugin-name>@<marketplace-name>
```

After install, Claude Code reads the plugin's `.claude-plugin/plugin.json` and:

- **Discovers skills** — every `skills/<name>/SKILL.md` becomes a skill the model can invoke via the `Skill` tool.
- **Discovers agents** — every `agents/<name>.md` becomes a subagent dispatchable via `Agent` tool with `subagent_type: <plugin-name>:<agent-name>`.
- **Registers hooks** — every entry in `hooks/hooks.json` becomes a script that fires on the named event (SessionStart, PreToolUse, etc.).
- **Optionally registers commands** — every `commands/<name>.md` becomes a `/slash-command`.

The plugin runs **in-process** within the Claude Code session. There's no separate runtime, no daemon, no network service. Zero dependencies. Just text files + bash scripts.

This is the entire surface area. If you understand this, you can read any plugin and you can build any plugin.

---

## 3. Repository anatomy (file tree map)

```
production-framework/
├── .claude-plugin/
│   ├── plugin.json              # ← required: tells Claude Code this is a plugin
│   └── marketplace.json         # ← optional: registers as a marketplace
├── .codex-plugin/               # multi-platform: Codex variant
├── .cursor-plugin/              # multi-platform: Cursor variant
├── .opencode/                   # multi-platform: OpenCode variant
├── agents/                      # 12 specialist sub-agents
│   ├── architect.md
│   ├── builder.md
│   ├── code-reviewer.md
│   ├── database-engineer.md
│   ├── debugger.md
│   ├── post-mortem.md
│   ├── product-manager.md
│   ├── qa.md
│   ├── researcher.md
│   ├── security-compliance.md
│   ├── sre-devops.md
│   └── ux-design.md
├── skills/                      # 37 skills (orchestrator-grade behavior)
│   ├── cto-mode/SKILL.md        # ← the CTO orchestrator entry point
│   ├── cycle-selection/SKILL.md # ← picks 1 of 8 workflows
│   ├── tier-selection/SKILL.md  # ← scales rigor (Tier 1/2/3)
│   ├── configure-project-gates/SKILL.md  # ← per-project gate bootstrap
│   ├── gate-3-production-check/SKILL.md  # ← 18-dimension ship gate
│   ├── using-production-framework/SKILL.md  # ← SessionStart bootstrap
│   ├── using-superpowers/SKILL.md           # ← SP cascade bootstrap
│   └── … (30 more, all the disciplines)
├── hooks/
│   ├── hooks.json               # ← required: registers hooks by event
│   ├── run-hook.cmd             # ← polyglot wrapper (Windows .cmd + Unix bash)
│   ├── session-start            # bash script
│   ├── user-prompt-submit       # bash script
│   ├── pre-tool-use             # bash script — the enforcement teeth
│   └── subagent-stop            # bash script
├── commands/                    # slash commands
│   ├── brainstorm.md            # /brainstorm
│   ├── execute-plan.md          # /execute-plan
│   └── write-plan.md            # /write-plan
├── templates/                   # blank shapes projects copy
│   ├── CONFIG.yaml.template
│   ├── PROJECT-PLAN.template.md
│   └── STACK-PATTERNS.template.md
├── docs/                        # the framework's own docs
│   ├── catalog/hard-gates.md    # the 42-gate catalog
│   ├── catalog/hard-gates.json  # machine-readable version
│   ├── adr/                     # Architecture Decision Records
│   ├── research/                # binding-citation backing
│   ├── plans/                   # historical implementation plans
│   ├── PROJECT-PLAN.md          # framework's own project state
│   ├── FEEDBACK.md              # design surface for v2.6+
│   └── framework-overview.md
├── .framework-state/            # ← runtime state (created/maintained by hooks)
│   ├── active-gates.yaml        # per-project gate activation
│   ├── decision-log.jsonl       # append-only deny/allow audit
│   ├── bypass-log.jsonl         # bypass usage telemetry
│   ├── active-agents.jsonl      # in-flight subagent scope declarations
│   └── session.json             # session-start branch/SHA capture
├── CLAUDE.md                    # contributor guard for THIS repo
├── README.md                    # user-facing install + smoke test
├── RELEASE-NOTES.md             # version history with rationales
├── LICENSE                      # MIT, attribution preserved from Superpowers
└── .gitignore
```

Every directory is purposeful. Nothing is decorative.

---

## 4. The five primitives

### 4.1 Plugin packaging (`.claude-plugin/`)

**`plugin.json`** — required, minimal:

```json
{
  "name": "production-framework",
  "description": "Enterprise multi-tenant production framework — built on Superpowers...",
  "version": "2.5.0",
  "author": { "name": "Atyab Rehman", "email": "..." },
  "license": "MIT",
  "keywords": ["skills", "tdd", "..."],
  "credits": {
    "based_on": {
      "name": "superpowers",
      "version": "5.0.7",
      "author": "Jesse Vincent <jesse@fsck.com>",
      "homepage": "https://github.com/obra/superpowers",
      "license": "MIT"
    }
  }
}
```

That's the entire required surface. Everything else (skills, agents, hooks) is discovered by directory convention.

**`marketplace.json`** — optional. A "marketplace" is a directory that registers multiple plugins. PF's marketplace.json registers itself as a single-plugin marketplace so `/plugin marketplace add <repo>` works as the install entry point. Schema mirrors `plugin.json` but wraps an array of plugins.

**Versioning convention** (from CLAUDE.md):
- **Patch** (2.0.x) — docs, citations, formatting
- **Minor** (2.x.0) — new skill / agent / template section
- **Major** (3.0.0) — hook contract change, agent dispatch shape change, shared-context substrate breaking change

---

### 4.2 Skills (`skills/*/SKILL.md`)

A skill is one Markdown file at `skills/<kebab-case-name>/SKILL.md`. Skills are **lazy-loaded**: only the frontmatter `description:` field is read into context at session start; the body loads only when the model invokes `Skill(skill: "<name>")`.

This is the single most important design fact about skills. **The description is what Claude reads to decide whether the skill applies.** Write descriptions that pattern-match the situations where the skill should fire.

**Anatomy (using `skills/cto-mode/SKILL.md`):**

```markdown
---
name: cto-mode
description: "You MUST use this when the user describes any non-trivial enterprise SaaS work — building features, fixing bugs, designing systems, refactoring modules, debugging incidents, or auditing for security/performance/compliance. Switches the entry-point session into CTO mode: classifies the task into a cycle, dispatches the right specialist agents in the right order, maintains shared cycle state, and synthesizes results."
---

# CTO Mode — You Are the CTO of an Enterprise SaaS Team

[body — loaded only on Skill tool invocation]

<HARD-GATE>
Do NOT write production code, run migrations, or take implementation action yourself.
...
</HARD-GATE>

## Anti-Pattern: "I'll Just Build It Myself"
[rationalization-list patterns the agent might use to skip the skill]

## Checklist
1. **Classify the task** — invoke `cycle-selection` skill...
2. **Read project state** — read PROJECT-PLAN.md + cycle-state.md...
[etc.]
```

**Frontmatter discipline:**
- `name` — kebab-case slug matching the directory
- `description` — action-oriented imperative. Pattern-match phrases the user/model would generate. Specific verbs and surface names beat vague topic-labels. "Use when X" or "You MUST use this when Y" — never "About X."

**Body conventions (Superpowers cascade):**
- `<HARD-GATE>` tags — non-negotiable rules. The model treats these as binding even when it's tempted not to.
- **Anti-pattern sections** — rationalization-list. The skill names the excuses the model might use to skip itself ("I'll just build it myself"). This is empirically the highest-leverage discipline-shaping pattern; it survives across model versions because it inoculates against specific failure modes.
- **Red Flags table** — paired thought + reality. ("'This is just a simple question' | Questions are tasks. Check for skills.")
- **Checklist** — numbered steps the skill walks. Concrete, mechanical.
- **Citations** — explicit references to source material (Anthropic guidance, Superpowers precedent, enterprise framework analogs).

**Why skills work:** Claude doesn't have access to all skill bodies at once — it reads descriptions and decides which to invoke. Well-written skills compose: `cto-mode` invokes `cycle-selection`, which invokes `tier-selection`, which invokes a specific cycle template. Each step lazily loads only what's needed. **Context is not free; lazy loading is the discipline.**

**Skill discoverability rule:** Every skill needs to be invocable by the model from the description alone. If the description doesn't pattern-match the situation, the skill is dead code.

---

### 4.3 Agents (`agents/*.md`)

An agent is one Markdown file at `agents/<name>.md`. Agents are **dispatched** via the `Agent` tool: `Agent(subagent_type: "production-framework:builder", prompt: "...")`. Each dispatch spawns the agent in its own isolated context window.

**Anatomy (using `agents/builder.md`):**

```markdown
---
name: builder
description: |
  Use this agent when the CTO has an implementation plan and architecture doc ready,
  and needs code written. Dispatched by the CTO at Phase 6 of Build cycle...
  Examples: <example>Context: Build cycle ready... user: "Implement comments per
  docs/plans/comments.md..." assistant: "I'll dispatch two parallel Builder instances
  — one scoped to src/server/comments/, one to src/web/comments/." <commentary>Two
  Builder instances run in parallel because file scopes don't overlap.</commentary>
  </example>
model: sonnet
isolation: worktree
---

You are the **Builder** sub-agent of the production-framework v2 team.
You execute one bounded scope of implementation work...

[body — system prompt for the subagent]
```

**Frontmatter fields:**
- `name` — kebab-case slug matching the filename
- `description` — when to dispatch this agent. Includes 1-2 `<example>` blocks with the assistant's narration of why they chose this agent. The CTO reads the description and the examples to route correctly.
- `model` — `sonnet` (default), `opus`, or `haiku`. Higher-stakes / heavier-reasoning agents get `opus`; mechanical agents get `sonnet`.
- `isolation` — `worktree` triggers automatic git worktree spawn for that dispatch. The worktree is created from the session's parent-branch tip, the agent operates inside it, and the result is returned. (See §12 for the worktree HEAD-parity caveat.)
- `tools` — optional list to restrict tool access. Default inherits parent tools.

**Body conventions:**
- Opens with role + scope ("You are the Builder. You execute bounded scope.")
- Cites Anthropic / Superpowers / enterprise precedent for the role shape.
- Names hard rules (`<HARD-GATE>`-equivalent prose, e.g., "Do not deviate from the plan.")
- Specifies **status tokens** — the agent returns one of `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED`. The CTO reads the token to know what to do next.
- Specifies what the agent reads (paths) and what it writes (paths).
- Names empty-diff / no-op self-attestation rules where applicable.

**Sub-agent dispatch model (the key mental model):**

When you dispatch via `Agent(subagent_type: "X")`:
1. A new context window is spawned.
2. The agent's system prompt (from the `.md` body) loads.
3. Your dispatch text (the `prompt:` parameter) is the user message.
4. The agent runs, calls tools, writes files.
5. On completion, it returns a final message (the "handover").
6. **Your context only receives the handover, not the transcript.** This is the isolation.

This isolation is intentional. It prevents cross-contamination and keeps the parent context lean. But it means **subagents communicate only through files written to disk** (or the brief handover message). The substrate is the filesystem — `docs/specs/`, `docs/architecture/`, `docs/cycle-state.md`. Files survive the subagent boundary; in-memory state does not.

---

### 4.4 Hooks (`hooks/hooks.json` + scripts + polyglot wrapper)

Hooks are bash scripts that fire on Claude Code events. They are the **enforcement layer** — the only mechanism that can block a tool call before it runs.

**Registration (`hooks/hooks.json`):**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start",
            "async": false
          }
        ]
      }
    ],
    "UserPromptSubmit": [...],
    "PreToolUse": [
      {
        "matcher": "Edit|Write|Bash|Skill|Agent",
        "hooks": [...]
      }
    ],
    "SubagentStop": [...]
  }
}
```

**Events you can hook:**
- `SessionStart` — fires once when Claude Code session starts (or after `/clear` or `/compact`). Used to inject baseline context. Receives subevent (`startup` / `clear` / `compact`) so you can vary behavior.
- `UserPromptSubmit` — fires on every user message. Used to track timestamps, filter noise (system reminders, task notifications).
- `PreToolUse` — fires BEFORE a tool call. The teeth: can `block`, `warn`, or modify input. `matcher` is a regex on tool name(s).
- `PostToolUse` — fires AFTER a tool call. Used for telemetry, audit logging.
- `SubagentStop` — fires when a dispatched subagent returns. Used to verify the subagent's claims (e.g., did the file actually land?).

**The polyglot wrapper (`hooks/run-hook.cmd`)** is a single file that's BOTH a Windows `.cmd` batch script AND a Unix bash script. On Windows, `cmd.exe` interprets it; on Unix, bash interprets the `: << 'CMDBLOCK'` heredoc trick to skip the batch section. This is why PF runs on both platforms with zero installation steps. The wrapper finds bash (Git Bash on Windows, system bash on Unix) and execs the actual hook script.

Hook scripts themselves are **extensionless** (`session-start`, not `session-start.sh`) because Claude Code's Windows auto-detection prepends `bash` to any path with `.sh`, which would double-invoke.

**Hook script contract:**
- Receives event JSON via stdin
- Returns JSON via stdout
- Exit code: 0 (continue), 1+ (treat as block)

**Decision shapes (PreToolUse):**
- `{"decision": "block", "reason": "<text shown to user + model>"}` — hard block
- `{"decision": "warn", "reason": "..."}` — soft warning, tool still runs
- `{"decision": "approve"}` or no output — allow
- `{"hookSpecificOutput": {"additionalContext": "<text>"}}` — inject text into model's next turn (used by SessionStart to load skill bootstraps)
- `{"updatedInput": {...}}` — modify tool inputs before execution

**Example hook script structure (pseudocode):**

```bash
#!/usr/bin/env bash
set -euo pipefail

# Read event from stdin
event=$(cat)

# Extract fields
tool_name=$(echo "$event" | jq -r '.tool_name')
prompt=$(echo "$event" | jq -r '.tool_input.prompt // empty')

# Decision logic
if [[ "$tool_name" == "Agent" && "$prompt" == *"EXECUTE"* ]]; then
    # Check builder dispatch invariants
    if ! grep -q "BASE_SHA:" <<< "$prompt"; then
        echo '{"decision": "block", "reason": "Builder dispatch missing BASE_SHA"}'
        exit 0
    fi
fi

# Allow
echo '{"decision": "approve"}'
```

**Why hooks matter:** they are the only enforcement layer that operates **regardless of model prompts**. A skill body can say "you MUST do X" and the model can rationalize around it. A hook that blocks the offending tool call is mechanical. This is the difference between PROMPT and HOOK fixes (see §12 for FEEDBACK.md's mechanical-floor rule).

---

### 4.5 State (`.framework-state/`, JSONL convention)

Plugins persist state in a `.framework-state/` directory at the repo root. Convention:

- **JSONL files** for append-only logs (`decision-log.jsonl`, `bypass-log.jsonl`, `active-agents.jsonl`, `dispatch-economics.jsonl`)
- **YAML** for human-editable configuration (`active-gates.yaml`)
- **JSON** for single-document state (`session.json`, `warn-counts.json`)

Why JSONL for logs? Atomic appends without locking. Multiple hook scripts can append concurrently without overwriting each other. Parsing is cheap (`jq` line-by-line).

**`.framework-state/active-gates.yaml`** is the per-project gate activation file written by `configure-project-gates` and read by `pre-tool-use`. See §9.

**`.framework-state/active-agents.jsonl`** tracks in-flight subagent `scope_write` / `scope_read` declarations. The `pre-tool-use` hook reads this to detect file-scope intersection (see §5.4).

**`.framework-state/session.json`** captures session-start branch + SHA so the `worktree-preflight` HEAD-parity gate can detect staleness later.

**Don't put `.framework-state/` in version control.** Add it to `.gitignore`. It's session-local runtime state, not part of the repo.

---

## 5. Composition patterns — how the primitives interact

### 5.1 Lazy skill loading via description-string matching

When the session starts, Claude Code injects a list of available skill names + descriptions into the system prompt. The model never sees skill bodies until it invokes one via the `Skill` tool. This means:

1. **Skill descriptions are your only chance to be discovered.** Pattern-match the user phrases or model thoughts that should trigger the skill.
2. **Composition emerges from descriptions.** A skill body saying "now invoke `tier-selection`" only works if `tier-selection`'s description matches the moment the invocation arrives.
3. **Avoid skill-name collisions.** Two skills with overlapping descriptions = model picks one ambiguously.

The `using-superpowers` and `using-production-framework` skills both have `description:` starting with "Use when starting any conversation" — they fire at session start by design (see §5.2).

### 5.2 SessionStart bootstrap (how the framework "loads")

When you ask Claude to do X, how does the framework know to be the CTO instead of a generic assistant?

The chain:
1. Claude Code session starts.
2. `hooks/hooks.json` SessionStart hook fires.
3. `hooks/session-start` script runs, returns `additionalContext` with the framework's bootstrap text — "You are the CTO of an enterprise SaaS team... read `using-superpowers` and `using-production-framework` skills for the full contract."
4. The model reads the bootstrap, sees the skill names, and on its first turn invokes them via `Skill`.
5. Skills are loaded into context. The CTO discipline is now active.

This is the mechanism by which a plugin "switches the agent's mode." Not a magic config flag — just a hook that injects bootstrap text + skills that the model reliably picks up.

### 5.3 Sub-agent dispatch via Agent tool

```
Agent(
    subagent_type: "production-framework:architect",
    description: "Architect dispatch — comments feature",
    prompt: """
        ACTIVE GATES THIS PROJECT (from CLAUDE.md ## Active Gates):
          - tenant-isolation (block — declare silo/pool/bridge model)
          - architect-evidence-coverage (block — every UI surface needs ≥1 visual evidence file in scope_read)

        Design the comments feature. Read:
          - docs/specs/comments.md
          - docs/research/comments-realtime.md (Researcher Pass 1 output)

        Produce: docs/architecture/comments.md with C4 Container + Component diagrams,
        ADRs for sync strategy, multi-tenant isolation table.

        scope_write: docs/architecture/comments.md
        scope_read: docs/specs/comments.md, docs/research/comments-realtime.md
    """
)
```

What happens:
1. Claude Code spawns a new context window.
2. The agent's `.md` body loads as the system prompt.
3. The `prompt:` parameter loads as the user message.
4. The agent runs (calls Read / Write / Bash / etc.).
5. On completion, the final assistant message returns to the parent.

The **`ACTIVE GATES THIS PROJECT:` block** is prepended by the CTO before every dispatch. Sub-agents do NOT inherit the parent's session context; they only see what the dispatch prompt carries. So the CTO has to teach each sub-agent the project's active gates per-dispatch.

The **`scope_write` / `scope_read` declarations** are read by the `pre-tool-use` hook (via `.framework-state/active-agents.jsonl`) to detect file-scope intersection across parallel dispatches.

### 5.4 File-based shared context across subagent isolation

Because sub-agents have isolated context, **the filesystem is the only durable cross-agent channel.** Production-framework formalizes this:

| File | Written by | Read by | Purpose |
|---|---|---|---|
| `docs/specs/<feature>.md` | Product Manager | Everyone downstream | What we're building + acceptance criteria |
| `docs/design/<feature>.md` | UX Design | Architect, Builder | UI flows + IA |
| `docs/architecture/<feature>.md` | Architect | DB Engineer, Security, Builder | System design + ADRs |
| `docs/research/<topic>.md` | Researcher | Architect, DB Engineer | ≥3 enterprise citations |
| `docs/database/<feature>.md` | Database Engineer | Builder | Schema + migrations |
| `docs/security/<feature>.md` | Security/Compliance | Builder | Control map + RLS audit |
| `docs/plans/<feature>.md` | Plan author | Builder | Implementation plan (what code to write) |
| `docs/audits/qa-findings-<feature>.md` | QA | CTO | Verdict + concerns |
| `docs/audits/review-<feature>.md` | Code Reviewer | CTO | Quality findings |
| `docs/runbook/<feature>.md` | SRE/DevOps | Operators | Deploy + observability |
| `docs/cycle-state.md` | All agents | All agents | Session shared brain (append-only) |
| `docs/PROJECT-PLAN.md` | CTO | All agents | Long-lived project state |
| `docs/adr/<n>-<decision>.md` | Architect | Future agents | Architecture Decision Records |

**Pattern:** Each subagent reads its inputs by path, writes its output to a known path, returns a status token. The CTO mediates handovers (reads both files, confirms fit) before dispatching the next agent.

**Anthropic precedent** (cited in cto-mode skill): *"Each subagent operates with an isolated context window... This design is intentional: it prevents cross-contamination between different phases of the workflow and keeps each agent focused."* — *Effective context engineering for AI agents*.

### 5.5 Hook enforcement vs prompt discipline — the mechanical-floor rule

The framework's FEEDBACK.md surfaced a critical lesson:

> v1 of CLAUDE.md's measurement protocol shipped but was never executed because the discipline-dependent `Rule born:` annotations didn't propagate. Author-discipline-dependent measurement does not self-sustain.

The general pattern: **discipline-dependent fixes don't work; mechanical floors do.**

When designing a fix, ask:
- **HOOK** — mechanical check catches the violation by itself; no prompt change required. Highest reliability.
- **HYBRID** — hook floor catches violation + prompt teaches actor how to comply. The hook is load-bearing; the prompt makes compliance easier.
- **PROMPT** — only an agent/skill/CLAUDE.md text edit. Lowest reliability — works only when the actor is disciplined.

Half of any framework's intended discipline can be expressed as prompts. The other half MUST be hooks if you want it enforced. Without hooks, prompts drift and don't propagate.

---

## 6. The CTO orchestrator pattern (this plugin's special sauce)

The reason production-framework is more than a collection of skills: the **CTO orchestrator pattern** turns a normal Claude session into a coordinator that runs an entire team.

**The chain:**

```
User: "build me a multi-tenant comments feature"
│
▼
SessionStart hook injects bootstrap → Claude is now CTO
│
▼
cto-mode skill fires (description matched "build" + "multi-tenant")
│
▼
cycle-selection skill → "Build cycle, Tier 3"
│
▼
tier-selection skill → confirms Tier 3 (full cycle)
│
▼
CTO dispatches in graph order:
  Phase 1: Product Manager → docs/specs/comments.md
  Phase 2: UX/Design ∥ Researcher (parallel)
  Phase 3: Architect ∥ Researcher (Pattern A pass 1+2)
  Phase 4: Database Engineer ∥ Security/Compliance (parallel)
  Phase 5: writing-plan skill → docs/plans/comments.md
  Phase 6: Two parallel Builders (backend + frontend, disjoint scopes)
  Phase 7: QA ∥ Code Reviewer (parallel)
  Phase 8: SRE/DevOps → docs/runbook/comments.md
  Phase 9: gate-3-production-check → final 18D gate
  Phase 10: PROJECT-PLAN update + ≤30-line synthesis to user
```

**Anthropic citation** (binding rule): *"In the orchestrator-workers workflow, a central LLM dynamically breaks down tasks, delegates them to worker LLMs, and synthesizes their results."* — *Building Effective AI Agents*, Anthropic, Dec 2024.

**Tier scaling:**
- **Tier 1** — CTO executes directly (a typo, a comment, a one-line config). The cycle is skipped. Saves ceremony cost.
- **Tier 2** — Minimal cycle. Run only the agents whose output the implementation needs.
- **Tier 3** — Full cycle. All agents per the template.

The CTO picks tier based on blast radius: how many systems does this change touch, how reversible is it, what's the production impact?

**The CTO never writes production code.** That is the load-bearing discipline. Implementation is always delegated to a Builder. The CTO classifies, dispatches, mediates handovers, synthesizes. Exception: Tier 1 trivial work.

---

## 7. The binding citation rule

Every implementation plan in production-framework must cite **≥3 named enterprise/OSS implementations of the same pattern.** The Researcher agent enforces. Plans without citations are rejected at QA.

**Why:** prevents inventing patterns without precedent. The framework's premise is that 30 years of enterprise SaaS has already solved most multi-tenant problems; the team's job is to apply those solutions, not invent new ones.

**Citation forms accepted:**
- OSS: `file:line` + commit hash from the source repo
- Closed: URL + verbatim quote + verification date

**Citation strengths:**
- **THIN** — 1 source, prose claim only
- **WEAK** — 2-3 sources, partial agreement
- **STRONG** — 4+ sources, broad agreement
- **BINDING** — N≥5 sources, unanimous consensus. Cannot be overridden by team disagreement.

**The framework's OWN development follows this rule.** Every feature in `skills/`, `agents/`, `hooks/` cites either:
1. A Superpowers (SP) precedent — path + snippet from SP 5.0.7, OR
2. A quoted Anthropic doc — exact quote + URL + verification date

`docs/research/sp-anthropic-citation-manifest.md` is the source of truth. The contributor guard in `CLAUDE.md` rejects PRs that add features without this citation.

This is **how a research-backed framework stays honest**: every line traces back to a named source.

---

## 8. Cycle definitions (the 8 named workflows)

Defined in `skills/cycle-selection/SKILL.md`. The CTO walks the trigger list top-down; first match wins.

| Cycle | Trigger | Tier 3 graph |
|---|---|---|
| **debug** | Broken/unexpected, root cause unknown | debugger → re-classify root cause → fix cycle → QA → optional post-mortem |
| **postmortem** | Incident already happened | post-mortem agent (after debugger reproduces) |
| **research** | Decision support, no code change | Researcher → optional Architect recommendation |
| **build** | Add/build/implement/create with new behavior | PM → UX ∥ Researcher → Architect ∥ Researcher (Pattern A 3-pass) → DB ∥ Security → plan → Builder (parallel per scope) → QA ∥ Reviewer → SRE → gate-3 |
| **refactor** | Restructure, no new behavior | Architect ∥ Researcher → regression-scope → Builder → QA → Reviewer |
| **security-audit** | Audit / harden / pen-test | Security ∥ Researcher → Architect → Builder (severity order) → QA → gate-3 |
| **performance** | Speed up / optimize, measurable target | Debugger (profiler) → Researcher → Architect → DB ∥ Builder → QA (delta vs baseline) |
| **migration** | Schema migration / data backfill | Architect ∥ Researcher → DB → Security → regression-scope → Builder → QA → SRE → gate-3 |

**Pattern A (3-pass producer-consumer):** Producer (pass 1, draft + open questions) → Consumer (audit + answers) → Producer (pass 2, finalize with citations). Used in Tier 3 where the producer's output is the ratified artifact.

**Pattern B (2-pass):** Producer → Consumer (sequential, no producer revision). Used in Tier 2 where downstream agent already synthesizes both views.

---

## 9. The configurable gate system (42-gate catalog, three tiers)

`docs/catalog/hard-gates.md` lists 42 gates the framework can enforce. They split into three tiers:

**1. Universal floor (9 gates, always-active, hardcoded):**
- evidence-before-completion
- no-fix-without-root-cause
- enterprise-citation-rule (N≥3)
- active-gates-fresh (session-start reminder if CLAUDE.md missing `## Active Gates`)
- heavy-read-dispatch
- gate-3-production-check
- builder-empty-diff
- no-PII-in-logs
- data-loss-disclosure

**2. Stack-conditional (8 gates, auto-activated by STACK-PATTERNS):**
When `templates/STACK-PATTERNS.md` declares the trigger (e.g., multi-tenant + Postgres + RLS), specific gates auto-activate (e.g., RLS query coverage, tenant-scoped index lints).

**3. Configurable (25 gates, project-selectable):**
`configure-project-gates` skill reads the project's `FEEDBACK.md` pain signals + STACK-PATTERNS + user-stated priorities, then writes the activation list to:
- `.framework-state/active-gates.yaml` (machine-readable; the hook reads this)
- Project's `CLAUDE.md ## Active Gates` section (human-readable; the CTO reads this and injects per dispatch)

**Three enforcement modes per gate:**
- `block` — pre-tool-use hook denies the tool call. Operator can use `PF_BYPASS=<gate-id>` to override (audited in `.framework-state/bypass-log.jsonl`).
- `warn` — hook lets the tool proceed but logs a warning. Counter-based (e.g., `max_per_session: 3` flips to block on the 4th).
- `audit` — logged only; no user-facing message. Used for telemetry / future-tuning data.

**Severity tiers per gate:**
- `critical` — always block. No max-per-session.
- `standard` — warn-or-block configurable per project.
- `friction` — warn-only.

**The bypass model:**

```bash
PF_BYPASS=tier-selection git commit -m "..."
# OR
PF_BYPASS_ALL=1 PF_BYPASS_REASON="end-of-session cleanup" rm -rf temp/
```

Every bypass is logged. The framework's own dev cycle re-mines the bypass log to identify gates that get bypassed routinely (= gate is wrong, retune).

---

## 10. Multi-platform support (Codex, Cursor, OpenCode, Gemini)

Production-framework runs on multiple Claude / agent platforms:

- **Claude Code** (primary) — `.claude-plugin/plugin.json`
- **Codex** — `.codex/INSTALL.md` + `.codex-plugin/plugin.json`
- **Cursor** — `.cursor-plugin/plugin.json`
- **OpenCode** — `.opencode/INSTALL.md` + `.opencode/plugins/superpowers.js`
- **Gemini CLI** — `GEMINI.md` (loaded at session start with platform-tool mapping)

Each platform discovers different conventions:
- Claude Code reads `.claude-plugin/plugin.json`
- Codex reads `.codex-plugin/plugin.json`
- Cursor reads `.cursor-plugin/plugin.json`

The skills + agents + hooks themselves stay platform-neutral. The platform-specific files are install manifests + small adapters (e.g., `.opencode/plugins/superpowers.js` translates CC skill semantics to OpenCode's plugin API).

When a non-Claude-Code platform doesn't natively support a feature (e.g., `Skill` tool), the framework documents the equivalent via `references/copilot-tools.md` / `references/codex-tools.md`. Gemini's `GEMINI.md` loads the tool mapping automatically.

This is how a plugin reaches multiple ecosystems: keep the core (skills/agents/hooks) neutral, ship per-platform adapter files.

---

## 11. Building your own plugin — minimum viable to full orchestrator

### 11.1 Minimum viable plugin (1 skill, no hooks)

```
my-plugin/
└── .claude-plugin/
    └── plugin.json
└── skills/
    └── my-skill/
        └── SKILL.md
```

`plugin.json`:

```json
{
  "name": "my-plugin",
  "description": "My first plugin",
  "version": "0.1.0",
  "author": { "name": "Me" },
  "license": "MIT"
}
```

`skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: Use when the user asks to do X — fires the my-skill behavior.
---

# My Skill

Walk through these steps:

1. Read the file at X.
2. Apply transformation Y.
3. Write the result to Z.
```

That's it. Push to GitHub. Install via `/plugin marketplace add <repo-url>` + `/plugin install my-plugin`. The skill is now available when the user matches its description.

### 11.2 Adding a hook (for enforcement)

```
my-plugin/
├── .claude-plugin/plugin.json
├── skills/my-skill/SKILL.md
└── hooks/
    ├── hooks.json
    ├── run-hook.cmd        ← copy from production-framework
    └── pre-tool-use        ← your bash script
```

`hooks/hooks.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" pre-tool-use",
            "async": false
          }
        ]
      }
    ]
  }
}
```

`hooks/pre-tool-use`:

```bash
#!/usr/bin/env bash
set -euo pipefail

event=$(cat)
tool=$(echo "$event" | jq -r '.tool_name')
cmd=$(echo "$event" | jq -r '.tool_input.command // empty')

if [[ "$tool" == "Bash" && "$cmd" == *"rm -rf /"* ]]; then
    echo '{"decision": "block", "reason": "rm -rf / is forbidden"}'
    exit 0
fi

echo '{"decision": "approve"}'
```

The hook now fires on every Bash call and blocks `rm -rf /`.

### 11.3 Adding an agent (for delegated work)

```
my-plugin/
├── .claude-plugin/plugin.json
├── skills/my-skill/SKILL.md
├── hooks/...
└── agents/
    └── my-worker.md
```

`agents/my-worker.md`:

```markdown
---
name: my-worker
description: |
  Use this agent when there's bounded scoped work to do that doesn't need
  the main session's full context. Examples: <example>Context: User asks
  for a code-style audit. user: "audit all src/ files for unused imports."
  assistant: "I'll dispatch my-worker to walk src/ and produce a report."
  <commentary>The audit is bounded + the output is a doc — perfect for a
  dedicated worker.</commentary></example>
model: sonnet
isolation: worktree
---

You are a worker agent. Read the files specified in the dispatch prompt,
produce the requested output, write it to the named path. Return DONE,
DONE_WITH_CONCERNS, NEEDS_CONTEXT, or BLOCKED.

[detailed instructions]
```

Dispatch from main session: `Agent(subagent_type: "my-plugin:my-worker", prompt: "...")`.

### 11.4 Adding a slash command

```
my-plugin/commands/my-command.md
```

```markdown
---
description: Run my custom workflow
---

When the user types `/my-command`, run these steps:

1. Step A
2. Step B
3. Step C
```

The user invokes `/my-command` and the command body is loaded as a prompt.

### 11.5 Full orchestrator (production-framework shape)

Composing all of the above:

- **One entry-point skill** (the "mode" — e.g., `cto-mode`) with a description that matches the user's task class.
- **A router skill** the entry-point invokes (`cycle-selection`) to pick a workflow.
- **A scaling skill** (`tier-selection`) to choose rigor level.
- **N specialist agents** the entry-point dispatches per workflow.
- **Shared context files** the agents read/write under `docs/`.
- **SessionStart hook** that bootstraps the mode at session start.
- **PreToolUse hook** that enforces invariants the mode depends on.
- **SubagentStop hook** that verifies sub-agents' claims (did the file land?).
- **State files** under `.framework-state/` to track in-flight work.

That's production-framework. Six surfaces, composed.

---

## 12. Common gotchas (lessons from FEEDBACK.md)

These are surfaced in the framework's own dev cycle. Every plugin author hits them.

**1. Sub-agents return DONE without writing files.** A doc-authoring agent embeds the artifact in its summary message but never calls Write. The framework's fix shape (v2.6): SubagentStop hook checks the file actually landed; missing + DONE → override to OUTPUT_MISSING.

**2. Agents fabricate standing instructions to skip per-dispatch directives.** A sub-agent invents "the project standing instruction says don't write this file" — citing a rule that doesn't exist. Fix: anti-fabrication clause in every agent's system prompt: *"NEVER claim a project standing instruction overrides a per-dispatch directive without citing the verbatim line + file path."*

**3. Worktree HEAD-parity.** Builder's `isolation: worktree` spawns from session-start parent-branch state, not current HEAD. If you `git switch` mid-session and commit, subsequent Builder dispatches see stale state. Fix: `worktree-preflight` HEAD-parity gate (v2.5).

**4. WebFetch permission denials force researcher fallbacks.** Researchers hit `anthropic.com` blocks; ad-hoc fallback to WebSearch synthesis was undocumented. Fix v2.5: `skipWebFetchPreflight: true` in `~/.claude/settings.json` + codified `[CITATION-DEGRADED]` tag protocol.

**5. Tier-selection over-fires on system notifications.** Every task-notification / subagent-completion message looks like a "new prompt" to the hook. Fix v2.5+: source filter on input origin; cycle-cache via `.framework-state/current-cycle.json`.

**6. CLAUDE.md bloat degrades model attention.** Empirical: stock template → 355 lines → demonstrable performance regression. Fix v2.6+: `claude-md-design` skill + line-count drift hook (no annotation discipline required).

**7. Architect extrapolates UX from adjacent surfaces.** Designs 3 panes when `scope_read` only includes 1 capture. Fix v2.6+: `architect-evidence-coverage` HARD-GATE — every UI surface needs ≥1 visual evidence file in scope_read.

**8. Builder copies surface patterns without verifying preconditions.** "Mirroring V2's disabled Publish" — but V2 had an inner Save fallback, V4 didn't. Fix: Builder system prompt requires verifying prior-version preconditions hold.

**9. Mock tests green, live tests red.** Postgres 42702 ambiguity, JWT propagation through SECURITY DEFINER RPCs — none caught by mocked Supabase client tests. Fix v2.6+: F-46 live-test mandate (any RPC-touching code ships with a real-client integration test).

**10. Discipline-dependent fixes don't self-sustain.** v1 of the CLAUDE.md measurement protocol shipped with `Rule born:` annotations the author had to write — they never propagated. Always prefer mechanical (hook) over prompt enforcement.

The general lesson: **plumbing leaks where prompts ask actors to be careful. Plug the plumbing first; ask actors to be careful only where you can't plug.**

---

## 13. Reference map — where to look in the repo

**When you want to see how X is done, read Y:**

| To learn about… | Read… |
|---|---|
| Plugin manifest shape | `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json` |
| A clean skill body | `skills/cto-mode/SKILL.md`, `skills/cycle-selection/SKILL.md` |
| A clean agent body | `agents/builder.md`, `agents/researcher.md` |
| The bootstrap entry skill | `skills/using-production-framework/SKILL.md` |
| Hook registration | `hooks/hooks.json` |
| The polyglot wrapper | `hooks/run-hook.cmd` |
| A real hook script | `hooks/pre-tool-use`, `hooks/session-start` |
| State file conventions | `.framework-state/` (gitignored — run the plugin to populate) |
| Cycle definitions | `skills/cycle-selection/SKILL.md` |
| Tier scaling | `skills/tier-selection/SKILL.md` |
| The 42-gate catalog | `docs/catalog/hard-gates.md`, `docs/catalog/hard-gates.json` |
| Per-project gate selection | `skills/configure-project-gates/SKILL.md` |
| Citation manifest | `docs/research/sp-anthropic-citation-manifest.md` |
| Enterprise framework comparison | `docs/research/enterprise-multi-agent-architecture.md` |
| Contributor rules (binding rule) | `CLAUDE.md` |
| Lessons learned (gotchas) | `docs/FEEDBACK.md` |
| Project state | `docs/PROJECT-PLAN.md` |
| Architecture decisions | `docs/adr/*.md` |
| Multi-platform install | `.codex/INSTALL.md`, `.opencode/INSTALL.md`, `GEMINI.md` |
| Version history + rationales | `RELEASE-NOTES.md` |

**Reading order if you have 2 hours:**

1. `README.md` (5 min) — what is this
2. `.claude-plugin/plugin.json` (1 min) — entry point
3. `CLAUDE.md` (10 min) — contributor guard + binding rule
4. `skills/cto-mode/SKILL.md` (15 min) — the orchestrator
5. `skills/cycle-selection/SKILL.md` (15 min) — the workflows
6. `agents/builder.md` (15 min) — a specialist
7. `agents/researcher.md` (10 min) — the citation enforcer
8. `hooks/hooks.json` + `hooks/run-hook.cmd` + one hook script (15 min) — enforcement layer
9. `docs/catalog/hard-gates.md` (10 min, skim) — what gets enforced
10. `docs/FEEDBACK.md` (20 min) — what's broken, what's next

After 2 hours you can read any other file with full context.

---

## 14. Closing thoughts — what makes a great plugin

The framework's own design principles, distilled:

**1. Delegate; do not implement.** Skills tell the model HOW to think; they don't replace its thinking. Hooks tell the model what NOT to do; they don't replace its judgment.

**2. Lazy load.** Context is not free. Skill descriptions are read; bodies aren't, until invoked. Design descriptions that pattern-match the right moments.

**3. File-based shared context.** Sub-agents have isolated context. The only durable channel is disk. Embrace it; design schemas for the shared files (specs, architecture, plans).

**4. Mechanical enforcement over prompt discipline.** Anything you can hook, hook. Anything you can only prompt, accept will sometimes drift.

**5. Cite your sources.** Every design choice should trace back to a named precedent — Anthropic guidance, an OSS implementation, an enterprise post-mortem. Inventing from thin air is the failure mode citation rules prevent.

**6. Eat your own dogfood.** A `claude-md-design` skill that says "keep CLAUDE.md ≤300 lines" should itself live in a skill body ≤300 lines. A FEEDBACK.md that says "research-back every design decision" should itself be backed by parallel researcher dispatches.

**7. Surface the disagreement.** When sub-agents return contradictory output, don't paper over it. Use `parallel-reconciliation` skill. The user should see the conflict and decide.

**8. Be honest about gaps.** Researcher's "Honest gap" section is the most valuable section. If the evidence isn't there, say so. If a measurement protocol you shipped never actually runs, flag it (FEEDBACK §1.4 self-flag) and replace it with a mechanical alternative.

A great plugin shapes the agent's behavior toward better outcomes. A bad plugin clogs context with ceremony. The difference is which of the lessons above the author understood.

---

**End of context pack.** Paste into NotebookLM. Source files at `c:\Users\atyab\Experimental - Users\Production Framework\` — every reference in this doc has a real path you can open.
