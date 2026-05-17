---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Dispatch model — agent type selection (F-5, 2026-05-17)

When the CTO dispatches this skill via the Agent tool, the agent type matters: this skill instructs the producer to write a plan file to disk, which means the producer needs Write tool access.

**Prefer:**
- `production-framework:architect` — has Write enabled by contract; native fit for plan-authoring.
- `general-purpose` — has Write enabled; valid fallback when an architect dispatch isn't appropriate.

**Do NOT use:**
- The built-in `Plan` agent type — it is read-only by contract (no Edit/Write/NotebookEdit per the Claude Code agent tool list). A `Plan` dispatch will produce the full plan content in its response BUT will return DONE_WITH_CONCERNS noting it could not Write — costing 15+ minutes of agent-time on content that the parent then has to re-materialize via a different agent. The `Plan` agent's description was historically ambiguous about this; FEEDBACK F-5 (2026-05-17) documents the empirical failure mode.

If a parent agent has already dispatched the `Plan` type by mistake and gotten back content-without-file, the parent persists the inline content via Write directly — no need to re-dispatch.

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Pre-emit existence checks (F-7, 2026-05-17)

Before writing any task that imports a library, calls an RPC, asserts a schema table, or invokes a test runner, **verify the target exists in the actual codebase**. Verification is EXISTENCE only — does the symbol/file/dep exist? — never shape (function bodies, call signatures, type shapes remain Builder's responsibility per the mechanical-vs-design distinction).

### What to check before emitting a task

| Target in task | Verify by |
|---|---|
| Library import (`@scope/package`, `package-name`) | `git show HEAD:package.json \| grep <package>` (or `requirements.txt`, `Cargo.toml`, `go.mod` per project) |
| RPC call (e.g. Supabase `.rpc("foo")`, internal RPC catalog) | grep `CREATE FUNCTION foo` in `supabase/migrations/*.sql` or equivalent DB-function catalog |
| Schema table (e.g. `from('work_items')`, `db.work_items`) | grep `CREATE TABLE work_items` in migrations OR `information_schema.tables` |
| Test runner (`vitest`, `pytest`, `node --test`) | grep the runner name in test config or `package.json` scripts |
| Type import from internal module | grep the type name at its declared source path |

If the target is absent, **escalate to Open Questions** — do NOT silently emit a task that depends on a missing dependency, hoping the Builder will install it. Builder discipline (FEEDBACK STRENGTH-2 + STRENGTH-3, 2026-05-17) correctly returns NEEDS_CONTEXT on plan-vs-code mismatches; an under-disciplined producer that "auto-fixes" by silently installing libraries un-masks the Builder safety net.

### Adoption-plan handshake (F-7, 2026-05-17)

If a dependency is absent from the codebase BUT exists in an in-flight adoption plan (search `docs/plans/*` + `docs/audits/*` for the dep name), do NOT silently assume the dep will be present at Builder dispatch time. The presence of an adoption plan means the codebase has decided HOW that dep will be wired — silently `pnpm add` from within an unrelated plan preempts that decision and creates duplication debt.

Surface as a CTO decision: "this plan would require adding library X; an adoption plan exists at `docs/plans/<adoption-plan>.md`. Options: (a) merge this plan's dep usage into the adoption plan's wiring, (b) defer the dep-using tasks until the adoption plan ships, (c) accept the duplication with a documented commit-body rationale."

### Why existence-only, not shape

The framework's Builder discipline catches shape bugs at execution time — Builder runs named test commands, captures failure output, identifies mechanical defects (wrong RPC argument shape, missing `onConflict`, regex collision, Luhn checksum), and either corrects them inline (mechanical) or escalates via NEEDS_CONTEXT (design). FEEDBACK STRENGTH-2 documents 9 mechanical-bug catches across one session; STRENGTH-3 documents 3 zero-false-positive NEEDS_CONTEXT escalations.

If `writing-plans` were to claim shape verification ("I verified `users.email` has type `text`"), the Builder's catch rate collapses: Builder would treat the plan's claim as authoritative and stop probing. Existence checks close the F-7 bug class (TanStack Query imported without `package.json` entry) at plan time; shape verification would erode the Builder safety net for the other 8 STRENGTH-2 bug shapes.

⚠️  **Anti-pattern:** *"I'll verify the function signature too while I'm checking existence."* Don't. Existence ≠ shape. Builder's job is to catch shape bugs; yours is to verify the symbol exists. The bright-line keeps the two disciplines composing.

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Remember
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
