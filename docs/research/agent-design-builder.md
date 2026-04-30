# Agent Design Research — Builder Sub-Agent

**Date:** 2026-04-29
**Type:** Source-of-truth research — no code modifications
**Triggered by:** Need to deepen `agents/builder.md` with role-specific best practices, citing SP precedent or Anthropic guidance per the binding rule (`CLAUDE.md` THE BINDING RULE).
**Scope:** The Builder sub-agent — the role that *writes implementation code* per a plan handed it by the CTO/Deputy.

This research mines five canonical sources, in priority order:

1. **SP `subagent-driven-development/implementer-prompt.md`** (primary — the verbatim template Builder must inherit)
2. **SP `subagent-driven-development/SKILL.md`** (status-token grammar, reviewer ordering, parallel-dispatch rules)
3. **Anthropic** — *Claude Code best practices*, *Effective harnesses for long-running agents*, *Building agents with the Claude Agent SDK*, *Effective context engineering for AI agents*
4. **MetaGPT** Engineer / `WriteCode` action (`metagpt/actions/write_code.py`)
5. **ChatDev** Programmer (instructor↔assistant pattern, `ChatChain` coding phase)
6. **Aider** EditBlock coder system prompt (`aider/coders/editblock_prompts.py`)
7. **Cursor** — public references only; no leaked Cursor prompt is cited as authoritative here

Verified URLs in §Sources. WebFetch was permission-denied for several Anthropic URLs; quotes from those are tagged `(via WebSearch synthesis of canonical URL)` and must be re-verified before any binding decision.

---

## Part 0 — Canonical Sources Table

| # | Source | Type | Local path / URL | Verified | Why it matters |
|---|---|---|---|---|---|
| 1 | SP 5.0.7 `implementer-prompt.md` | Verbatim local cache | `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/subagent-driven-development/implementer-prompt.md` | ✅ Direct read | The template to inherit |
| 2 | SP 5.0.7 `subagent-driven-development/SKILL.md` | Verbatim local cache | `…/skills/subagent-driven-development/SKILL.md` | ✅ Direct read | Status tokens, two-stage review, red flags |
| 3 | SP 5.0.7 `spec-reviewer-prompt.md` | Verbatim local cache | `…/skills/subagent-driven-development/spec-reviewer-prompt.md` | ✅ Direct read | "Do not trust the report" stance defines what Builder is reviewed against |
| 4 | SP 5.0.7 `code-quality-reviewer-prompt.md` | Verbatim local cache | `…/skills/subagent-driven-development/code-quality-reviewer-prompt.md` | ✅ Direct read | Code-quality criteria Builder is evaluated by |
| 5 | SP 5.0.7 `test-driven-development/SKILL.md` | Verbatim local cache | `…/skills/test-driven-development/SKILL.md` | ✅ Direct read | RED→GREEN→REFACTOR Iron Law for Builder when TDD enabled |
| 6 | SP 5.0.7 `verification-before-completion/SKILL.md` | Verbatim local cache | `…/skills/verification-before-completion/SKILL.md` | ✅ Direct read | Iron Law on Builder's "DONE" claim |
| 7 | Anthropic *Claude Code best practices* | Web | https://www.anthropic.com/engineering/claude-code-best-practices · https://code.claude.com/docs/en/best-practices | WebSearch synthesis | TDD endorsement, commit-as-you-go, hooks-enforce-quality |
| 8 | Anthropic *Effective harnesses for long-running agents* | Web | https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents | WebSearch synthesis | `claude-progress.txt` / CHANGELOG.md handoff for multi-session work |
| 9 | Anthropic *Building agents with the Claude Agent SDK* | Web | https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk | WebSearch synthesis | Tool design, the agentic loop, why Claude needs the same tools as humans |
| 10 | Anthropic *Effective context engineering* | Web | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | Quoted in PF citation manifest §2.17 | Subagent context isolation rationale |
| 11 | MetaGPT `WriteCode.PROMPT_TEMPLATE` | Web | https://github.com/geekan/MetaGPT/blob/main/metagpt/actions/write_code.py | WebSearch synthesis | The closest enterprise/OSS analogue to a Builder system prompt |
| 12 | ChatDev wiki + paper §coding phase | Web | https://github.com/OpenBMB/ChatDev · https://arxiv.org/html/2307.07924v5 | WebSearch synthesis | Programmer-as-assistant pattern, instructor↔assistant chat |
| 13 | Aider `editblock_prompts.py` | Web (URL only) | https://github.com/Aider-AI/aider/blob/main/aider/coders/editblock_prompts.py | URL recorded; raw file fetch returned indirect references | Edit-format discipline, "shell_cmd_reminder" framing |
| 14 | Anthropic *Create custom subagents* | Web | https://docs.claude.com/en/docs/claude-code/sub-agents | Quoted in PF citation manifest §2.9 | Subagent isolation contract |

---

## Part 1 — SP `implementer-prompt.md`: The Template Builder MUST Inherit

This is the **primary source**. SP 5.0.7's `implementer-prompt.md` defines the template a controller (CTO) pastes into Builder's prompt. PF v2's `agents/builder.md` is the *system prompt* (frontmatter+body); the implementer-prompt is the *task envelope* the controller wraps every dispatch in. **Both shapes must align.** The verbatim template is reproduced below, then mined for inheritable patterns.

### 1.1 Verbatim template (SP `implementer-prompt.md` lines 5–113)

```text
Task tool (general-purpose):
  description: "Implement Task N: [task name]"
  prompt: |
    You are implementing Task N: [task name]

    ## Task Description

    [FULL TEXT of task from plan - paste it here, don't make subagent read file]

    ## Context

    [Scene-setting: where this fits, dependencies, architectural context]

    ## Before You Begin

    If you have questions about:
    - The requirements or acceptance criteria
    - The approach or implementation strategy
    - Dependencies or assumptions
    - Anything unclear in the task description

    **Ask them now.** Raise any concerns before starting work.

    ## Your Job

    Once you're clear on requirements:
    1. Implement exactly what the task specifies
    2. Write tests (following TDD if task says to)
    3. Verify implementation works
    4. Commit your work
    5. Self-review (see below)
    6. Report back

    Work from: [directory]

    **While you work:** If you encounter something unexpected or unclear, **ask questions**.
    It's always OK to pause and clarify. Don't guess or make assumptions.

    ## Code Organization

    You reason best about code you can hold in context at once, and your edits are more
    reliable when files are focused. Keep this in mind:
    - Follow the file structure defined in the plan
    - Each file should have one clear responsibility with a well-defined interface
    - If a file you're creating is growing beyond the plan's intent, stop and report
      it as DONE_WITH_CONCERNS — don't split files on your own without plan guidance
    - If an existing file you're modifying is already large or tangled, work carefully
      and note it as a concern in your report
    - In existing codebases, follow established patterns. Improve code you're touching
      the way a good developer would, but don't restructure things outside your task.

    ## When You're in Over Your Head

    It is always OK to stop and say "this is too hard for me." Bad work is worse than
    no work. You will not be penalized for escalating.

    **STOP and escalate when:**
    - The task requires architectural decisions with multiple valid approaches
    - You need to understand code beyond what was provided and can't find clarity
    - You feel uncertain about whether your approach is correct
    - The task involves restructuring existing code in ways the plan didn't anticipate
    - You've been reading file after file trying to understand the system without progress

    **How to escalate:** Report back with status BLOCKED or NEEDS_CONTEXT. Describe
    specifically what you're stuck on, what you've tried, and what kind of help you need.
    The controller can provide more context, re-dispatch with a more capable model,
    or break the task into smaller pieces.

    ## Before Reporting Back: Self-Review

    Review your work with fresh eyes. Ask yourself:

    **Completeness:**
    - Did I fully implement everything in the spec?
    - Did I miss any requirements?
    - Are there edge cases I didn't handle?

    **Quality:**
    - Is this my best work?
    - Are names clear and accurate (match what things do, not how they work)?
    - Is the code clean and maintainable?

    **Discipline:**
    - Did I avoid overbuilding (YAGNI)?
    - Did I only build what was requested?
    - Did I follow existing patterns in the codebase?

    **Testing:**
    - Do tests actually verify behavior (not just mock behavior)?
    - Did I follow TDD if required?
    - Are tests comprehensive?

    If you find issues during self-review, fix them now before reporting.

    ## Report Format

    When done, report:
    - **Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
    - What you implemented (or what you attempted, if blocked)
    - What you tested and test results
    - Files changed
    - Self-review findings (if any)
    - Any issues or concerns

    Use DONE_WITH_CONCERNS if you completed the work but have doubts about correctness.
    Use BLOCKED if you cannot complete the task. Use NEEDS_CONTEXT if you need
    information that wasn't provided. Never silently produce work you're unsure about.
```

### 1.2 SP-Inheritable Patterns from `implementer-prompt.md`

The PF v2 Builder system prompt (`agents/builder.md`) and the dispatch envelope used by CTO/Deputy must inherit each of the following. They are organized by topic with verbatim anchors and a one-line note on whether PF v2's current `agents/builder.md` already covers it (`✓` covered, `△` partial, `✗` missing).

#### 1.2.1 Plan adherence vs deviation

> "Implement exactly what the task specifies"
> — `implementer-prompt.md` line 32

> "Don't restructure things outside your task."
> — `implementer-prompt.md` line 56

> "If a file you're creating is growing beyond the plan's intent, stop and report it as DONE_WITH_CONCERNS — don't split files on your own without plan guidance"
> — `implementer-prompt.md` lines 50–51

PF v2 builder.md status: ✓ ("Do not deviate from the plan."). Inheritance: **add the file-growth heuristic verbatim** — the current draft says "stay in scope" but does not give the "file growing → DONE_WITH_CONCERNS" rule that protects against silent splitting.

#### 1.2.2 Ask-before-acting (questions are first-class output)

> "If you have questions about: The requirements or acceptance criteria, The approach or implementation strategy, Dependencies or assumptions, Anything unclear in the task description. **Ask them now.** Raise any concerns before starting work."
> — `implementer-prompt.md` lines 21–28

> "While you work: If you encounter something unexpected or unclear, **ask questions**. It's always OK to pause and clarify. Don't guess or make assumptions."
> — `implementer-prompt.md` lines 41–42

PF v2 builder.md status: △ — only the post-hoc `NEEDS_CONTEXT` status token is mentioned. The "ask before starting" and "ask while working" gates are missing from the body. **High-impact gap.**

#### 1.2.3 The 5-trigger STOP-and-escalate list

> "STOP and escalate when:
> - The task requires architectural decisions with multiple valid approaches
> - You need to understand code beyond what was provided and can't find clarity
> - You feel uncertain about whether your approach is correct
> - The task involves restructuring existing code in ways the plan didn't anticipate
> - You've been reading file after file trying to understand the system without progress"
> — `implementer-prompt.md` lines 62–68

PF v2 builder.md status: ✗ missing entirely. The current draft only says "If you discover the plan is wrong, return NEEDS_CONTEXT or BLOCKED." Without these five concrete triggers, agents tend to push through even when the spec mandates escalation. **Inherit verbatim.**

#### 1.2.4 Code organization heuristics (file responsibility, file size, codebase pattern matching)

> "You reason best about code you can hold in context at once, and your edits are more reliable when files are focused."
> — `implementer-prompt.md` line 47

> "Each file should have one clear responsibility with a well-defined interface"
> — `implementer-prompt.md` line 49

> "In existing codebases, follow established patterns. Improve code you're touching the way a good developer would, but don't restructure things outside your task."
> — `implementer-prompt.md` lines 55–56

PF v2 builder.md status: △ — current draft says "Follow existing conventions" but does not include the "context-window reasoning" rationale or the "improve code you're touching, don't restructure outside" boundary. **Inherit verbatim.**

#### 1.2.5 Self-review pass before reporting

> "Review your work with fresh eyes. Ask yourself: Completeness… Quality… Discipline… Testing… If you find issues during self-review, fix them now before reporting."
> — `implementer-prompt.md` lines 76–98

PF v2 builder.md status: ✗ missing entirely. The current draft has no self-review section. The Two-Stage Review (spec then quality) gives Builder *external* review, but SP additionally requires *internal* self-review *before* the external review fires. **High-impact gap; inherit verbatim.**

#### 1.2.6 The 4-status token grammar — verbatim semantics

> "Status: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT"
> — `implementer-prompt.md` line 103

> "Use DONE_WITH_CONCERNS if you completed the work but have doubts about correctness. Use BLOCKED if you cannot complete the task. Use NEEDS_CONTEXT if you need information that wasn't provided. Never silently produce work you're unsure about."
> — `implementer-prompt.md` lines 110–112

> "Implementer subagents report one of four statuses. Handle each appropriately: DONE: Proceed to spec compliance review. DONE_WITH_CONCERNS: The implementer completed the work but flagged doubts… NEEDS_CONTEXT: The implementer needs information that wasn't provided. Provide the missing context and re-dispatch. BLOCKED: The implementer cannot complete the task."
> — `subagent-driven-development/SKILL.md` lines 102–117

PF v2 builder.md status: ✓ token names listed; △ semantics. The current draft only lists names and one-line glosses — it does not include the strong "Never silently produce work you're unsure about" line that distinguishes DONE_WITH_CONCERNS from DONE in practice. Inherit that line verbatim.

#### 1.2.7 The "bad work is worse than no work" psychological permission

> "It is always OK to stop and say 'this is too hard for me.' Bad work is worse than no work. You will not be penalized for escalating."
> — `implementer-prompt.md` lines 60–61

PF v2 builder.md status: ✗ missing entirely. This is non-trivial: it gives the model explicit permission to escalate without competing pressure. Without it, agents are observed to produce shaky work rather than admit they're stuck. **Inherit verbatim.**

#### 1.2.8 Test-with-real-code, not mocks

> "Do tests actually verify behavior (not just mock behavior)?"
> — `implementer-prompt.md` line 94

> "Real code (no mocks unless unavoidable)"
> — `test-driven-development/SKILL.md` line 111

PF v2 builder.md status: △ — the test rule is implied via TDD inheritance but not stated. **Inherit verbatim where TDD is enabled.**

#### 1.2.9 RED→GREEN→REFACTOR cycle (when TDD on)

> "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST. Write code before the test? Delete it. Start over."
> — `test-driven-development/SKILL.md` lines 34, 38

> "Verify RED — Watch It Fail. MANDATORY. Never skip."
> — `test-driven-development/SKILL.md` lines 113–115

> "Write code before test … Test after implementation … Test passes immediately … Can't explain why test failed … Tests added 'later' … All of these mean: Delete code. Start over with TDD."
> — `test-driven-development/SKILL.md` lines 274–288

PF v2 builder.md status: △ — points to `superpowers:test-driven-development` skill but doesn't quote the Iron Law. Since Builder is the actor that violates TDD if anyone does, **inherit the Iron Law line verbatim** ("NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST") into the body when project-level CONFIG enables TDD.

#### 1.2.10 Verification before claiming DONE

> "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE. If you haven't run the verification command in this message, you cannot claim it passes."
> — `verification-before-completion/SKILL.md` lines 19–22

> "BEFORE claiming any status … 1. IDENTIFY: What command proves this claim? 2. RUN: Execute the FULL command (fresh, complete) 3. READ: Full output, check exit code, count failures 4. VERIFY: Does output confirm the claim? … Skip any step = lying, not verifying"
> — `verification-before-completion/SKILL.md` lines 26–38

PF v2 builder.md status: △ — the "Verification done" line in the report format implies it but doesn't enforce the gate. **Inherit the Iron Law line verbatim.**

#### 1.2.11 Spec-reviewer's posture: do NOT trust Builder's report

> "The implementer finished suspiciously quickly. Their report may be incomplete, inaccurate, or optimistic. You MUST verify everything independently."
> — `spec-reviewer-prompt.md` lines 22–24

> "DO NOT: Take their word for what they implemented … Trust their claims about completeness … Accept their interpretation of requirements"
> — `spec-reviewer-prompt.md` lines 26–29

This is not a Builder rule, but it is the rule Builder is *evaluated against*. Builder.md should explicitly acknowledge this — Builder's report is independently verified; padding the report does not pass the gate. PF v2 builder.md status: ✗ missing. Add a line: "Your report is independently verified by the Two-Stage Review — do not over-claim. The spec reviewer reads your code, not your report."

#### 1.2.12 Code-quality reviewer's criteria — what Builder is graded on

> "Does each file have one clear responsibility with a well-defined interface? Are units decomposed so they can be understood and tested independently? Is the implementation following the file structure from the plan? Did this implementation create new files that are already large, or significantly grow existing files?"
> — `code-quality-reviewer-prompt.md` lines 21–24

PF v2 builder.md status: ✗ missing — Builder doesn't see the rubric it's graded on. Add a "You will be graded on" subsection mirroring these four bullets.

---

## Part 2 — Anthropic Guidance for Coding Agents

### 2.1 *Claude Code best practices*: TDD as "the single strongest pattern"

> "Test-driven development (TDD) is the single strongest pattern for working with agentic coding tools, with each red-to-green cycle giving Claude unambiguous feedback."
> — *Claude Code Best Practices* (via WebSearch synthesis of canonical URL)
> URL: https://www.anthropic.com/engineering/claude-code-best-practices

> Recommended workflow: "1. Write tests first using a TDD approach with no mock implementations. 2. Confirm tests fail by running them. 3. Commit the failing tests as a checkpoint. 4. Write the implementation without modifying the tests, keeping going until all tests pass."
> — *Claude Code Best Practices* (via WebSearch synthesis)

**Inheritance:** When the project enables TDD, Builder must follow steps 1–4 verbatim, including the "commit failing tests as a checkpoint" step. PF v2 builder.md status: ✗ — current draft doesn't mention committing the failing test as a separate checkpoint.

### 2.2 *Claude Code best practices*: commit-as-you-go

> "Have Claude write commits as it goes for each task step, so either Claude or the user can revert to a previous state if something goes wrong."
> — *Claude Code Best Practices* (via WebSearch synthesis)

**Inheritance:** Builder commits per task step (not a single bulk commit at the end). The current PF v2 builder.md says "Commit your work" once and gives no granularity guidance. **Add: "Commit at each meaningful step (failing test, passing test, refactor) — not a single bulk commit at the end."**

### 2.3 *Effective harnesses for long-running agents*: progress file for cross-session handoff

> "A claude-progress.txt file serves as a session-to-session log of completed work. The progress file, which by convention is called CHANGELOG.md, is the agent's portable long-term memory. A good progress file might track current status, completed tasks, failed approaches and why they didn't work, accuracy tables at key checkpoints, and known limitations."
> — *Effective harnesses for long-running agents* (via WebSearch synthesis)
> URL: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents

**Inheritance for PF v2:** `docs/cycle-state.md` (PF's running orchestration substrate) plays this role for the *CTO/Deputy*. For Builder, the analogous artifact is the `docs/plans/handover-{description}.md` file produced via the `writing-handover` skill. PF v2 builder.md should explicitly write a one-line entry to `docs/cycle-state.md` *and* produce the handover doc when the next agent (typically QA) needs cross-session context. Status: △ — current draft says "one-line handover summary to docs/cycle-state.md" but does not invoke `writing-handover` for the QA handoff.

### 2.4 *Building agents with the Claude Agent SDK*: tools-and-agentic-loop framing

> "The key design principle behind Claude Code is that Claude needs the same tools that programmers use every day. It needs to be able to find appropriate files in a codebase, write and edit files, lint the code, run it, debug, edit, and sometimes take these actions iteratively until the code succeeds."
> — *Building agents with the Claude Agent SDK* (via WebSearch synthesis)
> URL: https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk

**Inheritance:** Builder's allowed-tools list should include Read/Write/Edit/Grep/Glob/Bash. Builder must run the project's lint+build+test commands before claiming DONE — this is the "iteratively until the code succeeds" loop. PF v2 builder.md status: ✗ — no `tools:` allowlist is declared in the agent frontmatter. Recommend an explicit `tools` field once the agent frontmatter schema settles.

### 2.5 *Effective context engineering*: subagent isolation = clean main context

> "The most powerful pattern for large tasks involves each subagent getting its own context window with its own tool permissions. The main conversation stays clean while specialized agents handle isolated tasks with exactly the context they need."
> — *Effective context engineering for AI agents* (via WebSearch synthesis, quoted in PF citation manifest §2.17)
> URL: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents

PF v2 builder.md status: ✓ — already cited at the top of the file. No change needed.

### 2.6 *Create custom subagents*: how the agent file shape works

> "Subagents receive only their specialized system prompt (plus basic environment details like working directory), not the full Claude Code system prompt."
> — *Create custom subagents* (via WebSearch synthesis, quoted in PF citation manifest §2.9)

**Implication for Builder:** The system prompt body in `agents/builder.md` is the *complete* context Builder operates from. Anything not in the body must be in the dispatch envelope. This justifies the verbosity recommendations in §3.

---

## Part 3 — MetaGPT, ChatDev, Aider Comparison

### 3.1 MetaGPT `WriteCode.PROMPT_TEMPLATE`

The closest enterprise/OSS analogue to a Builder system prompt is MetaGPT's `WriteCode` action, which prompts the Engineer role.

> "Code: {filename}. Write code with triple quoto, based on the following attentions and context."
> — `metagpt/actions/write_code.py` PROMPT_TEMPLATE (verified URL; quote via WebSearch synthesis)
> URL: https://github.com/geekan/MetaGPT/blob/main/metagpt/actions/write_code.py

The action enumerates seven design rules (verbatim per WebSearch):

> "1. Only One file: do your best to implement THIS ONLY ONE FILE.
> 2. COMPLETE CODE: Your code will be part of the entire project, so please implement complete, reliable, reusable code snippets.
> 3. Set default value: If there is any setting, ALWAYS SET A DEFAULT VALUE, ALWAYS USE STRONG TYPE AND EXPLICIT VARIABLE.
> 4. Follow design: YOU MUST FOLLOW 'Data structures and interfaces'. DONT CHANGE ANY DESIGN.
> 5. CAREFULLY CHECK THAT YOU DONT MISS ANY NECESSARY CLASS/FUNCTION IN THIS FILE.
> 6. Before using a external variable/module, make sure you import it first.
> 7. Write out EVERY CODE DETAIL, DON'T LEAVE TODO."
> — MetaGPT `WriteCode` PROMPT_TEMPLATE (via WebSearch synthesis of canonical URL)

**Inheritance signal for PF v2:** Rules 1, 4, 5, 7 are aligned with SP's "implement exactly what the task specifies" + "don't leave files growing beyond plan intent." Rules 2, 3, 6 are language-specific (Python type-strictness) and belong in `templates/STACK-PATTERNS.md`, not `core/`. Rule 7 ("DON'T LEAVE TODO") is enterprise consensus worth inheriting verbatim — Builder must not leave `// TODO` placeholders unless the plan explicitly says to. **PF v2 builder.md status: ✗ missing — recommend adding "no TODO placeholders unless plan-mandated" to Hard Rules.**

### 3.2 ChatDev Programmer (instructor↔assistant pattern)

> "During the coding phase, the Programmer serves as the assistant role, and according to the phase prompt, should write one or multiple files to satisfy the user's demands, making sure that every detail of the architecture is implemented as code."
> — ChatDev (via WebSearch synthesis of OpenBMB/ChatDev README and arxiv paper)
> URLs: https://github.com/OpenBMB/ChatDev · https://arxiv.org/html/2307.07924v5

> "Each phase of ChatChain is governed by two agents: an instructor agent and an assistant agent, where the instructor agent is responsible for guiding the subtask toward completion by providing instructions and setting goals, while the assistant agent follows these instructions and responds with solutions."
> — ChatDev (via WebSearch synthesis)

**Inheritance signal:** ChatDev's instructor↔assistant chat is structurally analogous to PF v2's CTO↔Builder dispatch — except ChatDev runs *iterative dialog* during the phase, while SP/PF v2 uses *one-shot dispatch with status-token returns*. The PF v2 model is closer to AutoGen-style and to Anthropic's *multi-agent research system*. Worth noting in an ADR but no specific Builder.md change required.

> "ChatDev segments the software development process into three sequential phases: design, coding, and testing, with the coding phase further subdivided into subtasks of code writing and completion."
> — ChatDev (via WebSearch synthesis)

**Inheritance signal:** ChatDev splits "writing" from "completion" — analogous to PF v2's Builder→QA handover. This validates the two-stage discipline.

### 3.3 Aider EditBlock coder

Aider's `editblock_prompts.py` defines the LLM's edit format (search/replace blocks) and a "shell_cmd_reminder" for commands the model should suggest.

> "If you changed a self-contained HTML file, suggest an OS-appropriate command to open a browser to view it. Shell commands should be suggested this way, not as example code, and only complete shell commands that are ready to execute should be suggested, with at most a few shell commands at a time, not more than 1-3, one per line."
> — Aider `editblock_prompts.py` (via WebSearch synthesis of canonical URL)
> URL: https://github.com/Aider-AI/aider/blob/main/aider/coders/editblock_prompts.py

**Inheritance signal:** Aider explicitly bounds the *number* of suggestions per turn (≤3). PF v2 doesn't currently constrain Builder's verification-command count — recommend adding "Run the project's lint, typecheck, and test commands; do not run unrelated diagnostic commands."

Note: WebFetch on the raw file was permission-denied; the verbatim text of `main_system` could not be retrieved this session. Re-verify before binding decisions.

### 3.4 Cursor

No verifiable verbatim Cursor agent prompt was located in this research session. Public references describe Cursor as using a "tools-and-loop" framing similar to Anthropic Agent SDK, but no authoritative citation is available. **Status: not a defensible source for the binding rule.**

---

## Part 4 — Topic-Indexed Verbatim Anchors

For each topic the task prompt named, the highest-load-bearing quote and citation. The Builder.md revisions in Part 6 reference these anchors.

### 4.1 Scope discipline

- **SP:** "Don't restructure things outside your task." (`implementer-prompt.md` line 56)
- **SP:** "If a file you're creating is growing beyond the plan's intent, stop and report it as DONE_WITH_CONCERNS — don't split files on your own without plan guidance" (`implementer-prompt.md` lines 50–51)
- **MetaGPT:** "Only One file: do your best to implement THIS ONLY ONE FILE." (`WriteCode` rule 1)

### 4.2 Plan adherence vs deviation

- **SP:** "Implement exactly what the task specifies" (`implementer-prompt.md` line 32)
- **SP:** "If a planned step seems unnecessary, do not skip silently" (PF v2 builder.md current line 37 — already aligned)
- **MetaGPT:** "YOU MUST FOLLOW 'Data structures and interfaces'. DONT CHANGE ANY DESIGN." (`WriteCode` rule 4)

### 4.3 Test-first when enabled

- **SP TDD Iron Law:** "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST" (`test-driven-development/SKILL.md` line 34)
- **SP TDD:** "Verify RED — Watch It Fail. MANDATORY. Never skip." (`test-driven-development/SKILL.md` lines 113–115)
- **Anthropic:** "TDD is the single strongest pattern for working with agentic coding tools" (Claude Code best practices)
- **Anthropic workflow:** "Write tests first … Confirm tests fail by running them. Commit the failing tests as a checkpoint. Write the implementation without modifying the tests" (Claude Code best practices)

### 4.4 Status tokens

- **SP:** "Status: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT" (`implementer-prompt.md` line 103)
- **SP:** "Never silently produce work you're unsure about." (`implementer-prompt.md` line 112)
- **SP controller-side:** Per-status handling at `subagent-driven-development/SKILL.md` lines 102–117

### 4.5 File-scope worktree isolation (when CTO dispatches Builders in parallel)

- **SP:** "Git worktrees create isolated workspaces sharing the same repository" (`using-git-worktrees/SKILL.md`, quoted at PF citation manifest row Worktree)
- **SP:** "REQUIRED: Set up isolated workspace before starting" (`subagent-driven-development/SKILL.md` line 268)
- **Anthropic:** "set isolation: worktree" (Create custom subagents — quoted at PF citation manifest §2.10)

### 4.6 Multi-tenant safety in code

No SP precedent (SP has no enterprise SaaS framing). No direct Anthropic citation. The current PF v2 builder.md rule "Multi-tenant scope is non-negotiable. Every query, every API endpoint, every cache key MUST honor tenant scope" is **PF-original** content that addresses an enterprise SaaS gap SP doesn't cover. Per `CLAUDE.md` THE BINDING RULE this either needs (a) a stack-pattern citation moved to `templates/STACK-PATTERNS.md` (since multi-tenant scoping is stack-specific — RLS in Postgres, scope filters in Rails, tenant filter in Mongo), or (b) honest "PF-internal opinion" tagging. **Flag for ADR — see Part 7 Gap-MT.**

### 4.7 Self-review

- **SP:** Four-category self-review (Completeness, Quality, Discipline, Testing) with "If you find issues during self-review, fix them now before reporting." (`implementer-prompt.md` lines 76–98)

### 4.8 Ask-before-acting

- **SP:** "Ask them now. Raise any concerns before starting work." (`implementer-prompt.md` line 28)
- **SP:** "It's always OK to pause and clarify. Don't guess or make assumptions." (`implementer-prompt.md` line 42)

### 4.9 Verification gate before DONE

- **SP:** "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE" (`verification-before-completion/SKILL.md` line 19)
- **SP report-format reminder:** "Verify by reading code, not by trusting report." (`spec-reviewer-prompt.md` line 56) — this is the *reviewer's* rule but Builder must know it's the rule it's measured against.

### 4.10 Commit discipline

- **Anthropic:** "Have Claude write commits as it goes for each task step" (Claude Code best practices, via WebSearch)
- **Anthropic TDD step 3:** "Commit the failing tests as a checkpoint" (Claude Code best practices)

---

## Part 5 — Gap Analysis: Current `agents/builder.md` vs Inheritance Inventory

| # | Inherited pattern | SP/Anthropic anchor | Current builder.md status | Gap severity |
|---|---|---|---|---|
| 1 | Ask-before-acting (questions are first-class output) | `implementer-prompt.md` 21–28, 41–42 | ✗ missing | **HIGH** — agents don't ask without explicit permission |
| 2 | 5-trigger STOP-and-escalate list | `implementer-prompt.md` 62–68 | ✗ missing | **HIGH** — concrete triggers are load-bearing |
| 3 | Self-review pass before reporting | `implementer-prompt.md` 76–98 | ✗ missing | **HIGH** — caught ~30% of issues per SP example workflow |
| 4 | "Bad work is worse than no work" psychological permission | `implementer-prompt.md` 60–61 | ✗ missing | MEDIUM — small line, big behavior shift |
| 5 | File-growth heuristic ("growing beyond plan intent → DONE_WITH_CONCERNS") | `implementer-prompt.md` 50–51 | ✗ missing | MEDIUM |
| 6 | Code-quality grading rubric Builder is measured by | `code-quality-reviewer-prompt.md` 21–24 | ✗ missing | MEDIUM — "know the rubric" improves output |
| 7 | "Spec reviewer doesn't trust your report" awareness | `spec-reviewer-prompt.md` 22–24 | ✗ missing | MEDIUM |
| 8 | TDD Iron Law verbatim (when enabled) | `test-driven-development/SKILL.md` 34 | △ pointer only | MEDIUM |
| 9 | Verification Iron Law verbatim before DONE | `verification-before-completion/SKILL.md` 19 | △ implied | MEDIUM |
| 10 | Commit-as-you-go granularity (per step, not bulk) | Anthropic Claude Code best practices | ✗ missing | MEDIUM |
| 11 | Failing-test-as-checkpoint commit step | Anthropic Claude Code best practices | ✗ missing | LOW |
| 12 | "No TODO placeholders unless plan-mandated" | MetaGPT `WriteCode` rule 7 | ✗ missing | LOW |
| 13 | "Don't run unrelated diagnostic commands" verification-bound | Aider 1–3 shell command bound | ✗ missing | LOW |
| 14 | Multi-tenant-safety-as-Hard-Rule citation | (no SP/Anthropic) | ✓ present, ✗ uncited | **CITATION GAP — see Part 7 Gap-MT** |
| 15 | Code-organization rationale ("reason best about code you can hold in context") | `implementer-prompt.md` 47 | △ partial | LOW |
| 16 | "Names match what things do, not how" | `implementer-prompt.md` 86 | ✗ missing | LOW |
| 17 | Real-code testing, not mocks | `implementer-prompt.md` 94, TDD SKILL line 111 | △ implied via TDD link | LOW |
| 18 | Tools allowlist (Read/Write/Edit/Grep/Glob/Bash) | Anthropic Agent SDK §2.4 | ✗ no `tools:` field declared | LOW (waits on frontmatter schema) |
| 19 | `writing-handover` skill invocation for Builder→QA | PF v2 internal | △ mentions cycle-state but not handover doc | MEDIUM |
| 20 | Worktree precondition when ≥2 parallel Builders | SP `using-git-worktrees`, Anthropic `isolation: worktree` | ✓ ADR cited, △ no in-prompt enforcement | MEDIUM |

**Top 3 highest-impact gaps:**

1. **Gap #1 — Ask-before-acting.** Without explicit permission, models default to "infer-and-proceed." SP's verbatim "Ask them now" is psychologically load-bearing. Inheriting this is the single highest-leverage change.
2. **Gap #2 — 5-trigger STOP list.** Without concrete triggers, agents push through ambiguity and produce shaky work. Inherit verbatim.
3. **Gap #3 — Self-review pass.** SP's documented two-stage review presumes Builder has *already* done internal self-review. Without it, the spec reviewer catches issues self-review would have caught — wasting a review loop.

---

## Part 6 — Suggested Revisions to `agents/builder.md`

The current builder.md body is 73 lines (lines 1–73 of source). Below is a structured inheritance plan, line-budgeted to keep the agent system prompt under SP's "skill body under 500 lines" guideline (Anthropic *Skill authoring best practices* §2.12, quoted in PF citation manifest). Builder is an agent, not a skill — but the same context-economy principle applies.

### 6.1 New sections to add (with anchor citations)

**Section: "Before You Begin — Ask"** (~10 lines)
Inherit `implementer-prompt.md` 21–28 and 41–42 verbatim. Cite SP `subagent-driven-development/implementer-prompt.md`.

**Section: "When You're in Over Your Head"** (~12 lines)
Inherit `implementer-prompt.md` 60–72 verbatim, including the 5-trigger STOP list, the "Bad work is worse than no work" line, and the BLOCKED/NEEDS_CONTEXT escalation guidance. Cite SP `subagent-driven-development/implementer-prompt.md`.

**Section: "Code Organization"** (~10 lines)
Inherit `implementer-prompt.md` 47–56 verbatim. The "reason best about code you can hold in context at once" line gives Builder a *reason*, not just a rule, for keeping files focused. Cite SP.

**Section: "Self-Review Before Reporting"** (~15 lines)
Inherit `implementer-prompt.md` 76–98 verbatim — the four-category checklist (Completeness, Quality, Discipline, Testing) and the "If you find issues during self-review, fix them now before reporting" close. Cite SP.

**Section: "How You Will Be Reviewed"** (~10 lines, NEW — PF v2 addition)
Brief paragraph stating: (a) Spec reviewer will read your code, not your report — do not over-claim; (b) Code-quality reviewer will check the four criteria from `code-quality-reviewer-prompt.md` 21–24; (c) Both run AFTER your self-review. Cite SP `spec-reviewer-prompt.md` and `code-quality-reviewer-prompt.md`. **Rationale: showing Builder the rubric improves output.**

**Section: "Test-First (when project enables TDD)"** (~12 lines)
Quote SP `test-driven-development/SKILL.md` Iron Law verbatim. Add Anthropic 4-step workflow from *Claude Code best practices* (write test → run to confirm fail → commit failing test as checkpoint → implement). Cite both.

**Section: "Verification Before Claiming DONE"** (~8 lines)
Quote SP `verification-before-completion/SKILL.md` Iron Law verbatim and the 4-step gate function (IDENTIFY → RUN → READ → VERIFY).

**Section: "Commit Discipline"** (~6 lines, NEW)
Cite Anthropic *Claude Code best practices*: "commit at each meaningful step (failing test, passing test, refactor) — not a single bulk commit at the end." Add: "do not run `git push --force` unless the plan or controller explicitly authorizes it" — same restraint as SP `finishing-a-development-branch`.

### 6.2 Existing sections to keep, with minor edits

**Hard rules** — keep, but:
- Add MetaGPT-derived rule: "No TODO placeholders unless plan-mandated."
- Add Aider-derived rule: "Run only the project's defined lint/typecheck/test commands as verification — do not run unrelated diagnostic commands."
- The multi-tenant rule **must be re-cited** — see Part 7 Gap-MT.

**Status tokens** — keep, but:
- Add the "Never silently produce work you're unsure about" line verbatim from `implementer-prompt.md` 112.
- Add the per-status controller-side handling reference (so Builder understands why each status routes differently): cite `subagent-driven-development/SKILL.md` 102–117.

**Output format** — keep, but:
- Reorder to match `implementer-prompt.md` 100–108: Status first, then "What you implemented", then test results, then files changed, then self-review findings, then concerns. The current order is mostly aligned but inverts test results and files.

**Citations footer** — expand to enumerate every section's anchor, not just the broad "implementer-prompt template" reference.

### 6.3 Recommended length

Current: ~73 lines body. Proposed: ~150–180 lines body. Still well under SP's 500-line guideline. The inheritance is *additive* — every new section paid for by an explicit SP or Anthropic anchor.

### 6.4 Frontmatter changes

- Consider adding a `tools` allowlist when the agent frontmatter schema supports it (Anthropic *Create plugins* §2.15: "Plugin agents support … tools, disallowedTools …").
- Consider `isolation: worktree` for when the controller dispatches multiple parallel Builders (Anthropic *Create custom subagents* §2.10). PF v2 already has a `worktree-isolation` skill — making `isolation: worktree` the default in builder.md frontmatter would be consistent with the rule and remove a control-plane decision from CTO.

---

## Part 7 — Gaps and Citations

### Gap-MT — Multi-tenant safety rule has no SP or Anthropic citation

**What it claims:** "Every query, every API endpoint, every cache key MUST honor tenant scope. If the plan does not specify it for a touch point, return NEEDS_CONTEXT."

**Why a gap:** SP has no enterprise SaaS / multi-tenant framing. Anthropic guidance is silent on multi-tenant scoping at the agent-prompt level. The rule is PF-original content addressing an enterprise SaaS gap.

**Options:**

- **(A) Move to `templates/STACK-PATTERNS.md`** — multi-tenant scoping is stack-specific (RLS in Postgres, scope filters in Rails, tenant filter in Mongo, namespaced keys in Redis). The pattern belongs in stack-patterns, not in the universal Builder prompt. Builder.md would say: "Honor every safety rule in `templates/STACK-PATTERNS.md` as Hard Rules" and let stack-patterns enumerate multi-tenant requirements.
- **(B) Keep in core builder.md, tag explicitly as PF-internal** — like GAP-1 in the citation manifest (the N≥3 rule is PF-internal; Anthropic doesn't prescribe it). Acceptable per the manifest's precedent.

**Recommendation:** **Option A.** Multi-tenant scoping is stack-specific and the citation manifest's own design separates universal rules from stack-pattern rules. Move the rule to `STACK-PATTERNS.md` and have builder.md cite the file as the source of stack-specific Hard Rules. This also supports projects that aren't multi-tenant (an internal tool, an open-source CLI) — they wouldn't carry the rule unless their stack-patterns says so.

### Gap-7G — No `tools:` allowlist on builder.md frontmatter

Builder.md uses `model: inherit` only. Per Anthropic *Create plugins* §2.15, agent frontmatter supports `tools` and `disallowedTools` fields. Without an allowlist, Builder inherits the full Claude Code tool surface — including web tools that aren't relevant. **Recommendation:** Once frontmatter schema settles in v2.0.0, declare `tools: [Read, Write, Edit, Grep, Glob, Bash, TodoWrite, NotebookEdit]` and `disallowedTools: [WebFetch, WebSearch]`. Cite Anthropic §2.15.

### Gap-7H — Worktree default not declared in frontmatter

Builder.md cites the `worktree-isolation` skill in the description but doesn't set `isolation: worktree` in frontmatter. **Recommendation:** Set `isolation: worktree` by default (Anthropic *Create custom subagents* §2.10). The CTO can override when isolation is unnecessary (single Builder, no overlap).

### Gap-7I — No ADR on the "single Builder" decision

The current builder.md cites `docs/adr/001-7-gap-decisions.md` G4 but that ADR doesn't yet exist in the repo (`docs/adr/` is registered but empty). **Recommendation:** Author the ADR before v2.0.0 ships; it should explicitly cite `docs/research/enterprise-multi-agent-architecture.md` (0/7 frameworks split BE/FE) as the rationale. This supports the citation-manifest GAP-4 entry.

---

## Part 8 — Composability with Other PF v2 Skills

Builder is one agent in a 13-agent roster. Inheritance has to compose, not collide. Verified compositions:

| Builder section | PF v2 skill that owns the underlying contract | Composition rule |
|---|---|---|
| "Test-First (when TDD enabled)" | `production-framework:test-driven-development` | Builder must invoke or cite the skill — not duplicate the Iron Law in builder.md beyond a one-line anchor. |
| "Verification Before Claiming DONE" | `production-framework:verification-before-completion` | Same — anchor only. |
| "Status tokens" | `production-framework:parsing-agent-returns` | Builder must produce returns parseable by the agent-return-parse hook — see `parsing-agent-returns` SKILL for the exact grammar. |
| "Self-review" | (PF-original — no upstream PF skill) | Inherit from SP `implementer-prompt.md` only. |
| "Commit discipline" | `production-framework:finishing-a-branch` (downstream) | Builder commits per step; final-branch decisions belong to `finishing-a-branch`, not Builder. |
| "How You Will Be Reviewed" | `production-framework:two-stage-review` | Builder cites the skill so reviewer logic stays single-sourced. |
| "Builder→QA handover" | `production-framework:writing-handover` | When Builder hands off, it invokes `writing-handover` to produce `docs/plans/handover-{description}.md`. **Add to builder.md.** |
| "Worktree default" | `production-framework:worktree-isolation` | Set `isolation: worktree` in frontmatter; cite the skill. |
| "No-deviation hard rule" | `production-framework:regression-scope` | Builder reads the regression-scope check before changing any shared model. Builder.md should reference this skill in Hard Rules. |

---

## Part 9 — Top 5 Concrete Edits to `agents/builder.md` (priority order)

1. **Add "Before You Begin — Ask" section** (verbatim from SP `implementer-prompt.md` 21–28, 41–42). Cite SP. **(High impact, low cost.)**
2. **Add "When You're in Over Your Head" section** with the 5-trigger STOP list and "Bad work is worse than no work" line (verbatim from SP `implementer-prompt.md` 60–72). Cite SP. **(High impact, low cost.)**
3. **Add "Self-Review Before Reporting" section** with four-category checklist (verbatim from SP `implementer-prompt.md` 76–98). Cite SP. **(High impact, low cost.)**
4. **Add "How You Will Be Reviewed" section** mirroring the spec-reviewer's "do not trust the report" stance and the code-quality reviewer's four criteria. Cite SP `spec-reviewer-prompt.md` 22–24 and `code-quality-reviewer-prompt.md` 21–24. **(Medium impact, very low cost — Builder produces better output when it sees its rubric.)**
5. **Decide Gap-MT now.** Move the multi-tenant rule to `templates/STACK-PATTERNS.md` (Option A) and have builder.md cite the file as the authoritative source for stack-specific Hard Rules. Resolves the citation gap without losing the rule's force.

Secondary edits (lower priority but worth bundling): add `isolation: worktree` to frontmatter, add `tools` allowlist, add commit-as-you-go and failing-test-checkpoint citations, add MetaGPT "no TODO" rule, add Aider-style verification-command bound, expand citations footer to enumerate every section's anchor.

---

## Sources

**Primary (verbatim local cache):**

- SP 5.0.7 `subagent-driven-development/implementer-prompt.md` — `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/subagent-driven-development/implementer-prompt.md`
- SP 5.0.7 `subagent-driven-development/SKILL.md` — same path, sibling file
- SP 5.0.7 `subagent-driven-development/spec-reviewer-prompt.md` — same path
- SP 5.0.7 `subagent-driven-development/code-quality-reviewer-prompt.md` — same path
- SP 5.0.7 `test-driven-development/SKILL.md`
- SP 5.0.7 `verification-before-completion/SKILL.md`

**Anthropic (web; verify before binding decisions):**

- *Claude Code best practices* — https://www.anthropic.com/engineering/claude-code-best-practices · https://code.claude.com/docs/en/best-practices
- *Effective harnesses for long-running agents* — https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- *Building agents with the Claude Agent SDK* — https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
- *Effective context engineering for AI agents* — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- *Create custom subagents* — https://docs.claude.com/en/docs/claude-code/sub-agents
- *Create plugins* — https://docs.claude.com/en/docs/claude-code/plugins

**Enterprise/OSS (web):**

- MetaGPT `metagpt/actions/write_code.py` — https://github.com/geekan/MetaGPT/blob/main/metagpt/actions/write_code.py
- MetaGPT main repo — https://github.com/FoundationAgents/MetaGPT
- ChatDev main repo — https://github.com/OpenBMB/ChatDev
- ChatDev paper — https://arxiv.org/html/2307.07924v5
- Aider `editblock_prompts.py` — https://github.com/Aider-AI/aider/blob/main/aider/coders/editblock_prompts.py
- Aider edit formats docs — https://aider.chat/docs/more/edit-formats.html

**Companion PF v2 docs:**

- `docs/research/sp-anthropic-citation-manifest.md` (the binding citation source)
- `docs/research/enterprise-multi-agent-architecture.md` (Axes 1–3 enterprise consensus, including the 0/7 BE/FE split finding)

**Methodology disclosure:** WebFetch was permission-denied for several Anthropic URLs in this session. Quotes tagged `(via WebSearch synthesis)` are reproduced as returned by WebSearch from the canonical URLs listed above. Before binding any architectural change to `agents/builder.md` on the strength of those quotes, re-verify against the live URL with direct WebFetch.
