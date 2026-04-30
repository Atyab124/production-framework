# Research-gap fill — v1.x design primitives

**Date:** 2026-04-28
**Source:** the 13 pre-design research-gap categories (A–M) in `docs/PROJECT-PLAN.md` "Pre-design research gaps (lessons from v1.x)" section. Each category produced a full v1.x failure mode (or will scope the v1.2+ strategic positioning).

**Methodology:** 13 parallel `production-framework:researcher` dispatches, each assigned one category. Per category, the Researcher: (1) ran every query in that category against the public web, (2) inspected how `superpowers` (cache: `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/`) performs the same function, (3) reported findings into this single file under its assigned heading.

**Reading guide:** each section ends with two sub-headings — `What this would have prevented in v1.x` and `Implications for v1.2+ design`. Skim these for the bottom-line. Source-citation density in the body.

---

## Category A — How Claude Code's auto-routing actually works

<!-- BEGIN-CATEGORY-A -->

**Top finding (single sentence):** Claude Code's skill/agent auto-routing is **pure LLM reasoning over the `description` field** — there is no embeddings layer, no classifier, no regex, no `when_to_use:` field, no `discoverable:` field; the harness inlines `name + description` of every available skill/agent into a text block in the Skill-tool / Task-tool prompt and lets Claude's forward pass pick. Therefore description content quality is the only routing lever, and `MUST BE USED` / `PROACTIVELY` / "use when…" / third-person trigger phrasing are documented levers for *increasing* auto-fire likelihood — but auto-selection is acknowledged-by-multiple-third-parties as **unreliable**, so the bootstrap-level "1% mandate" pattern (SP's `using-superpowers` skill) is the second binding lever beyond description quality.

### A.1 Per-query findings

#### Query 1 — `"Claude Code" subagent description "auto-delegate" routing mechanism`
**Top citations:**
- Claude Code official docs — `https://docs.claude.com/en/docs/claude-code/sub-agents`
- Anthropic blog — `https://claude.com/blog/subagents-in-claude-code`
- Anthropic SDK docs — `https://platform.claude.com/docs/en/agent-sdk/subagents`

**Summary:** Anthropic's docs state explicitly: *"When you define subagents, Claude determines whether to invoke them based on each subagent's `description` field. Write clear descriptions that explain when the subagent should be used, and Claude will automatically delegate appropriate tasks."* The description **is** the routing surface. Multiple third-party guides converge on: "Be specific about the trigger conditions, not just the capability. 'Reviews code for security issues before commits' routes better than 'security expert.'" One independent source (`ksred.com`) flags that auto-selection of custom agents is **unreliable** in practice — Claude often handles tasks in the main session instead of delegating, "even when the agent is explicitly relevant and its description matches" — and recommends explicit invocation as the only reliable trigger.

#### Query 2 — `"SKILL.md" frontmatter description "Use when" pattern matching algorithm`
**Top citations:**
- `leehanchung.github.io` — Claude Agent Skills: A First Principles Deep Dive (2025-10-26)
- `https://www.agensi.io/learn/skill-md-format-reference`
- `https://abvijaykumar.medium.com/deep-dive-skill-md-part-1-2-09fc9a536996`

**Summary:** **There is no algorithmic pattern-matching layer.** Quoting the deep-dive: *"At the code level, there's no algorithmic routing. Claude Code doesn't use embeddings, classifiers, regex, keyword matching, or ML-based intent detection to decide which skill to invoke. Instead, the system formats skill names and descriptions into a text block in the prompt and lets the LLM determine which skill applies to the request."* The decision happens inside Claude's forward pass, not in application code. A `when_to_use:` field is described as **optional sugar** in some third-party SKILL.md guides (Agensi) but is NOT mandated by Anthropic and is not the routing mechanism — the `description` carries the trigger-context payload.

#### Query 3 — `site:docs.claude.com claude-code agents auto-discovery`
**Top citations:**
- `https://docs.claude.com/en/docs/claude-code/sub-agents`
- `https://docs.claude.com/en/api/skills-guide`

**Summary:** The official docs describe **discovery** (where files come from) but not the routing algorithm. Discovery: *"Project subagents are discovered by walking up from the current working directory."* Listing: `claude agents` CLI shows agents grouped by source with override-priority indicators. There is **no documented `discoverable:` frontmatter field** — that hypothesis from REVIEW.md issue #004 is hallucinated (consistent with the Researcher-cycle finding logged in the Incident Table). Discovery is filesystem-based; routing is description-based; they are separate concerns.

#### Query 4 — `"Skill tool" Claude Code automatic invocation vs explicit call`
**Top citations:**
- Claude Code official docs — `https://code.claude.com/docs/en/skills`
- `https://paddo.dev/blog/claude-skills-controllability-problem/`
- GitHub issue `anthropics/claude-code#19141`

**Summary:** Two invocation paths exist: **(a) automatic** — *"Claude scans the descriptions of all available Skills and matches them against your request. If your message aligns closely enough with a Skill's description, Claude loads it automatically."* and **(b) explicit** — slash command `/skill-name` or direct request. Frontmatter controls: `disable-model-invocation: true` (only user can invoke — used for `/commit`, `/deploy`, side-effect skills) and `user-invocable: false` (only Claude can invoke — for background-knowledge skills). PF currently uses neither, so PF skills are dual-mode (auto + explicit). Auto-invocation "lives and dies by how well [the description] field is written."

#### Query 5 — `"PROACTIVELY" "MUST BE USED" Claude Code agent description effect`
**Top citations:**
- Claude Code official docs — `https://code.claude.com/docs/en/sub-agents`
- `https://github.com/vijaythecoder/awesome-claude-agents/blob/main/docs/best-practices.md`
- `https://hexdocs.pm/claude/guide-subagents.html`

**Summary:** These keywords are **documented levers for increasing auto-fire**: *"Including 'MUST BE USED' or 'use PROACTIVELY' in agent descriptions prompts auto-delegation. These phrases serve as signals to Claude to automatically invoke subagents at the appropriate times."* Anthropic-aligned recommendation: *"Use action-oriented phrases in the description, such as 'Use proactively to run tests and fix failures.'"* Real-world examples cited: `"Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code."` and `"MUST BE USED for ExUnit testing and test file generation."` This validates Issue #004's choice to add `MUST BE USED` / `PROACTIVELY` (5/5 doc consensus is consistent with the wider corpus).

#### Query 6 — `Anthropic plugin skill description third-person trigger format`
**Top citations:**
- `https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md`
- `https://github.com/anthropics/claude-plugins-official/blob/main/plugins/skill-creator/skills/skill-creator/SKILL.md`
- Anthropic — `The Complete Guide to Building Skills for Claude` (PDF)

**Summary:** Anthropic's official skill-creator skill mandates **third-person voice**: *"The skill description should use third-person format (e.g., 'This skill should be used when...' instead of 'Use this skill when...')."* And: *"In the YAML frontmatter description field, use third-person format with specific trigger phrases and include exact phrases users would say that should trigger this skill."* Critically: *"Claude has a tendency to **undertrigger** skills, so skill descriptions should be made a little bit 'pushy' to ensure they're used when appropriate."* The "pushy" guidance is the *Anthropic-blessed* origin of the `MUST BE USED` / `PROACTIVELY` keywords — they are not just a community pattern. This refutes REVIEW.md #005's audit hypothesis that "You MUST" second-person voice is the trigger lever — third-person is the documented norm.

#### Query 7 — `how does Claude Code decide which skill to invoke`
**Top citations:**
- `https://code.claude.com/docs/en/skills`
- `https://scottspence.com/posts/how-to-make-claude-code-skills-activate-reliably`
- `https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/`

**Summary:** Reinforces queries 1, 2, 4: *"Claude reads the list of available skills and uses its native language understanding to match your intent against the skill descriptions."* and *"Claude uses the description to decide when to apply a skill, so it should sound like the way you would naturally ask for that task. If you normally say 'review my code,' but your description says something abstract like 'audit software artefacts,' do not be surprised if Claude misses the connection."* This is the strongest single argument against project-internal jargon (Tier 3 / U-AP-4 / STACK-PATTERNS) in skill descriptions — corpus-wide consensus that descriptions must mirror **user language**, not framework language. PF's Issue #005 fix (jargon-removal regex) and the `check_skill_description_no_jargon` structural-check are aligned with this consensus.

#### Query 8 — `"description field" routing signal Claude Code subagent`
**Top citations:**
- `https://docs.claude.com/en/docs/claude-code/sub-agents`
- `https://claude.com/blog/subagents-in-claude-code`
- `https://www.builder.io/blog/claude-code-subagents`

**Summary:** Description framed explicitly as *the* routing signal: *"The one thing to keep specific: the description field. That's Claude's routing signal, and vague beats both configs and prompts for causing silent failures."* And: *"Write it like a routing rule: describe the exact phrases and situations that should invoke this agent, including 'use proactively' if you want Claude to reach for it without being asked."* The "vague description = silent failure" framing is what PF v1.x suffered: pre-#004/#005, descriptions were capability-labels not situation-triggers, and the result was silent zero-firing.

### A.2 SP behavior — how SP performs auto-routing

SP relies on **three** stacked mechanisms; PF v1.1.0 has implemented (1) and (2) post-fix, but only partially.

**(1) Description as situation-trigger, third-person, "Use when…" / "You MUST use this before…" formula.**

Verbatim from `skills/brainstorming/SKILL.md` (line 3):
```
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
```
Verbatim from `skills/verification-before-completion/SKILL.md` (line 3):
```
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
```
Verbatim from `skills/systematic-debugging/SKILL.md` (line 3):
```
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
```
Pattern: every entry-point skill description starts with `Use when …` (situation trigger, third-person from Claude's POV) **and** packs concrete user-language symptoms (`bug, test failure, unexpected behavior` / `complete, fixed, or passing` / `creating features, building components`). Zero project-internal jargon. The brainstorming skill is the **one outlier** with second-person `You MUST` — consistent with REVIEW.md #005's "1/16 outlier" observation.

**(2) Bootstrap-level "1% mandate" forcing function.**

Verbatim from `skills/using-superpowers/SKILL.md` (lines 10–16):
```
<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>
```
And the "Red Flags" rationalization-prevention table at lines 79–95 enumerates the exact thoughts that mean "you're rationalizing not to invoke" (12 rows). This is SP's *system-level* bias correction for the documented-by-Anthropic *undertrigger tendency* (Query 6 finding). The bootstrap teaches the Skill tool explicitly: *"In Claude Code: Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you—follow it directly. Never use the Read tool on skill files."* (line 30).

**(3) One agent only.**

`agents/code-reviewer.md` is SP's only agent. Its description (lines 3–4) uses the documented best-practice template — situation trigger + `<example>` blocks with `<commentary>` justifying the routing decision:
```
description: |
  Use this agent when a major project step has been completed and needs to be reviewed against the original plan and coding standards. Examples: <example>Context: ... user: "I've finished implementing the user authentication system as outlined in step 3 of our plan" assistant: "Great work! Now let me use the code-reviewer agent to review the implementation against our plan and coding standards" <commentary>Since a major project step has been completed, use the code-reviewer agent to validate the work against the plan and identify any issues.</commentary></example> <example>...</example>
```
Two `<example>` blocks. SP doesn't try to teach Claude *seven* agents to disambiguate between — it teaches one, with documented examples, and lets the rest be skill-driven.

### A.3 PF v1.1.0 vs SP — concrete deltas

| Lever | SP v5.0.7 | PF v1.1.0 (post-fix) | Delta |
|---|---|---|---|
| Description voice (third-person situation trigger) | 13/14 third-person `Use when…`; 1/14 second-person `You MUST` (brainstorming) | 9 entry-points rewritten verbatim per #005 to third-person `Use when…` / `Use before…` | ALIGNED post-#005 |
| `MUST BE USED` / `PROACTIVELY` keyword density | Used in `using-superpowers` body + brainstorming description | Added to all 7 agent descriptions per #004 | ALIGNED — possibly *over*-aligned (SP uses it sparingly) |
| Project-internal jargon in descriptions | Zero (no `Tier`, no `U-AP`, no `STACK-PATTERNS`) | `check_skill_description_no_jargon` regex enforces zero | ALIGNED (PF now has machine-enforcement SP doesn't have) |
| Number of entry-point agents | 1 (`code-reviewer`) | 7 (`builder, code-reviewer, debugger, deputy, post-mortem, qa-auditor, researcher`) | **PF over-built 7×.** SP-Borrow Backlog P3 already flags this as open question. |
| `<example>` blocks in agent description | 2 on `code-reviewer.md` | 2 (only `deputy.md` and `researcher.md` per #004) | PARTIAL — 5/7 PF agents have no `<example>` blocks |
| 1% mandate at bootstrap | Single, prominent `<EXTREMELY-IMPORTANT>` block + 12-row "Red Flags" rationalization-prevention table | 1% mandate added per Issue #002 — present but bootstrap-final-size 7,409 bytes vs spec ~4,800 (OF-1) | PRESENT but possibly competing with too much surrounding content |
| Instruction priority section | Explicit 3-level priority (User > Skills > System) at lines 19–26 | Added per user feedback #8 to `using-this-framework/SKILL.md` body | ALIGNED |
| "Skill priority — process before implementation" | SP teaches `brainstorming → implementation` ordering explicitly (lines 99–104) | PF teaches Tier-selection-as-entry — *framework*-shaped not *task*-shaped (per Meta-Pattern #2 in PROJECT-PLAN.md) | **NOT ALIGNED.** PF's entry-point requires meta-knowledge of "tiers"; SP's entry-points are user-language pattern-matchable. |
| `disable-model-invocation` / `user-invocable` controls used | No (all SP skills are dual-mode auto+explicit) | No | ALIGNED — but PF could *opt-in* `disable-model-invocation: true` for skills that are pure side-effect (e.g., `update-config`) — currently doesn't |
| Skill body teaches Skill-tool usage explicitly | Yes (`using-superpowers` line 30: *"Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you—follow it directly. Never use the Read tool on skill files."*) | Partial — `using-this-framework` has skill-pointers; unclear whether it explicitly forbids `Read` on skill files | **GAP.** Possible cause of v1.1.0 rebench negative result: model may be Read-ing skill files instead of invoking the Skill tool, which doesn't *count* as a skill fire in the harness metric. |

### A.4 What this would have prevented in v1.x

Direct mapping to Incident Table rows:

1. **Incident: REVIEW.md #004 hallucinated `when_to_use:` / `discoverable:` fields.** Query 2 (deep-dive) and Query 3 (official docs) both confirm: *no* `when_to_use:` field exists in the Anthropic spec (it's a third-party Agensi addition), and there is no `discoverable:` field anywhere. Running these queries pre-Researcher-#004 would have refuted the hypothesis from query 2 alone — saved one full Researcher cycle.

2. **Incident: REVIEW.md #005 hypothesized "You MUST" second-person voice as the trigger lever.** Query 6 (anthropic/skills repo, anthropic/claude-plugins-official repo, Anthropic skill-building PDF) is unanimous: **third-person** is the Anthropic-mandated voice. SP's 1/14 outlier (brainstorming) is an exception, not the pattern. Running query 6 pre-Researcher-#005 would have killed the second-person hypothesis at query 1.

3. **Meta-incident: "The framework that mandates enterprise-research-first didn't research itself."** Category A specifically — every single design decision around `MUST BE USED` / `PROACTIVELY` / third-person / agent-count / `<example>` blocks could have been sourced from queries 1–8 *before* PF was designed. The +35% cost / +41% wall regression in v1.1.0 is consistent with PF making correct fixes (alignment with consensus) on top of an architecturally-too-large agent surface (7 vs 1) — fix without architectural reset = drag.

### A.5 Implications for v1.2+ design

**Binding constraints (≥3-source consensus, must-follow):**

1. **Description = sole routing surface.** N=8/8 sources unanimous. There is no alternative. Stop looking for `when_to_use:` / `discoverable:` / metadata fields. Every routing improvement must go through description content quality. **PF should add this as a binding rule in `core/rules.md`** under a new tag (suggest `RULE: description-is-routing`).

2. **Third-person voice + situation trigger + user-language symptoms.** N=4/8 sources directly cite this (queries 2, 6, 7, 8). PF's #005 rewrites already comply. **Lock this in via `check_skill_description_no_jargon` expansion** to also flag second-person voice when paired with imperative ("You MUST" / "Always invoke"); allow third-person imperative ("This skill must be used when…").

3. **`MUST BE USED` / `PROACTIVELY` are documented levers.** N=3/8 sources (queries 1, 5, 8) — STRONG-by-docs. PF's #004 rewrites comply. **Risk:** SP uses these sparingly (1 description out of 14); PF added them to all 7 agents. Over-saturation may reduce signal — every agent claiming "MUST BE USED" is functionally equivalent to none claiming it. Consider: keep `MUST BE USED` only on the 2-3 highest-leverage routing scenarios (deputy, debugger), use third-person `Use when…` for the rest.

4. **Auto-invocation is acknowledged-unreliable.** N=2/8 sources (queries 1, 4) explicitly flag this. **Implication: Phase 1 rebench may show non-zero firing but still under-fire.** This is not necessarily a bootstrap or description bug — it's a known harness limitation. The mitigation in the wild is **slash commands** (Query 4: `disable-model-invocation` + `/skill-name` direct entry) — already on PF SP-Borrow Backlog as P1 (`commands/*.md`). Slash commands convert "did the model auto-route" from a soft signal into a hard user choice.

**Strong recommendations (2–3 source consensus):**

5. **`<example>` blocks on every agent description, not just deputy/researcher.** Query 1 + the SP `code-reviewer.md` precedent (2 example blocks on a single agent). PF has 2 on 2/7 agents. Recommend: add 2 example blocks to each of the remaining 5 agents in a future PR.

6. **Bootstrap should explicitly teach Skill-tool usage and forbid `Read` on skill files.** SP `using-superpowers/SKILL.md` line 30 is verbatim instructional. PF's bootstrap should match. **Possible primary cause of v1.1.0 rebench negative result** — without the explicit "use the Skill tool, never Read the skill file" instruction, the model may be executing skill content via `Read` + inline-follow, which the harness metric doesn't count as a skill fire.

**Open question for v1.2+ scope:**

7. **Single-agent consolidation.** Already SP-Borrow Backlog P3. Category A research strengthens the case: SP's auto-routing reliability problem is *amplified* by 7-agent disambiguation surface. Each agent the model has to choose between adds noise to the routing signal. Recommend escalating P3 → P1 contingent on Phase 1 rebench data: if `production-framework:builder` vs `production-framework:debugger` routing distributions are statistically indistinguishable, consolidate to 2-3 agents max.

### A.6 Risks / open questions

1. **Quantitative under-fire rates not in public sources.** No source quantifies "Claude undertriggers skills X% of the time at description-quality threshold Y." All citations are qualitative ("rarely", "unreliable", "tendency to undertrigger"). The Phase 1 rebench will be PF's first quantitative data point on this; PF cannot rely on a corpus benchmark.

2. **Whether PF's 1% mandate caused or hid the analysis-paralysis regression.** The Incident Table (`+35% cost / +41% wall / TodoWrite 8→0`) implicates the 1% mandate as a possible cause (Category C scope). Category A research alone cannot disentangle: did `MUST BE USED` keywords + 1% mandate force the model to invoke a skill it couldn't find, causing flailing? Or did the Skill-tool-usage gap (item 6 above) cause silent zero-firing while the 1% mandate caused TodoWrite collapse? Both hypotheses are testable in Phase 1 rebench by varying bootstrap (with/without 1% mandate) and instrumenting whether Skill tool was even called.

3. **`disable-model-invocation` / `user-invocable` adoption rate among shipped plugins.** Query 4 cites `https://github.com/anthropics/claude-code/issues/19141` titled `[DOCS] Clarify distinction between user-invocable and disable-model-invocation in Skills documentation` — meaning Anthropic itself has acknowledged this is unclear. PF should NOT block on this until the distinction is documented; default dual-mode is safe.

4. **Whether `<example>` blocks measurably improve routing.** Query 1 cites them as recommended; SP uses them on its one agent; PF used them only on 2/7 per #004. No public benchmark quantifies the lift. PF should A/B test in Phase 1 rebench by varying `<example>` presence on 1-2 PF agents and measuring routing rate.

5. **Whether the "auto-routing is unreliable" framing applies equally to skills and to subagents.** Sources conflate the two. Anthropic docs (Query 3) describe agent **discovery** (filesystem-walk) separately from skill **invocation** (Skill tool); the routing reliability question may have different shapes for each. Open question: does PF's 7-agent surface degrade routing in a *different* way than its 26-skill surface does?

### Sources

- [Create custom subagents — Claude Code Docs](https://docs.claude.com/en/docs/claude-code/sub-agents)
- [Extend Claude with skills — Claude Code Docs](https://code.claude.com/docs/en/skills)
- [How and when to use subagents in Claude Code](https://claude.com/blog/subagents-in-claude-code)
- [Subagents in the SDK — Claude API Docs](https://platform.claude.com/docs/en/agent-sdk/subagents)
- [Using Agent Skills with the API — Claude API Docs](https://docs.claude.com/en/api/skills-guide)
- [Claude Agent Skills: A First Principles Deep Dive — leehanchung.github.io](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)
- [SKILL.md Format Reference — agensi.io](https://www.agensi.io/learn/skill-md-format-reference)
- [Claude Code Subagents (best-practices.md) — vijaythecoder/awesome-claude-agents](https://github.com/vijaythecoder/awesome-claude-agents/blob/main/docs/best-practices.md)
- [skill-creator/SKILL.md — anthropics/skills](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md)
- [skill-creator/SKILL.md — anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/blob/main/plugins/skill-creator/skills/skill-creator/SKILL.md)
- [The Complete Guide to Building Skills for Claude (PDF) — Anthropic](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf)
- [Claude Skills: The Controllability Problem — paddo.dev](https://paddo.dev/blog/claude-skills-controllability-problem/)
- [How to Make Claude Code Skills Activate Reliably — Scott Spence](https://scottspence.com/posts/how-to-make-claude-code-skills-activate-reliably)
- [Claude Code Agents & Subagents: What They Actually Unlock — ksred.com](https://www.ksred.com/claude-code-agents-and-subagents-what-they-actually-unlock/)
- [GitHub issue anthropics/claude-code#19141 — clarify user-invocable vs disable-model-invocation](https://github.com/anthropics/claude-code/issues/19141)
- SP cache verbatim citations: `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/{using-superpowers,brainstorming,verification-before-completion,systematic-debugging}/SKILL.md` and `agents/code-reviewer.md`

<!-- END-CATEGORY-A -->

---

## Category B — Cascading skills vs single-skill invocation

<!-- BEGIN-CATEGORY-B -->

**Status:** DONE — central finding confirmed empirically.

**One-liner:** SP's `T1/sp/rep-1` transcript shows **N=1 Skill-tool invocation across 3,874 lines** (`superpowers:brainstorming`). After brainstorming returned, the model executed the rest of the task with raw tools (14 Bash, 14 Edit, 4 Write, 35 Read, 12 TodoWrite). Despite SP's explicit cascade design (brainstorming → writing-plans → subagent-driven-development → finishing-a-development-branch), the model fired the entry-point skill once and never re-fired. PF's `tier-selection` → 7-skill cascade was based on a designed-but-not-empirically-realized pattern even in SP. PF v1.x's negative result (0 skills fired) is not just a hook bug — it's also that PF designed for a cascade frequency that doesn't occur in practice, and PF's entry point was framework-shaped where SP's was task-shaped.

---

### B.1 — Per-query findings

#### B.1.1 — `LLM cascade skill chaining cold prompt failure mode`

**Finding:** No published benchmark of cascade-shaped skill chains exists. The closest art is **prompt-chaining vs. ReAct** literature (Wei et al. CoT 2022, Yao et al. ReAct 2022) and Anthropic's own **"How we built our multi-agent research system"** (2024) post that explicitly describes a *single orchestrator* pattern, not a methodology cascade. The orchestrator-fans-out pattern uses sub-agents (Task tool), not chained skill invocations within one model turn.

**What the evidence shows:** Anthropic's documented multi-step pattern is `orchestrator → parallel sub-agents → synthesis`, where the orchestrator owns the meta-decision and dispatches Task workers. Cascading model-internal skill calls (Skill A → Skill B → Skill C in a single agent's turn-trail) is not a documented Anthropic pattern; the closest doc-blessed pattern is prompt-chaining via sub-agents.

**Implication:** PF's design ("8-skill cascade fires in sequence") is not refuted by docs but it is **un-attested** in the documented Anthropic patterns. The pattern Anthropic documents is multi-agent fan-out, not multi-skill cascade.

#### B.1.2 — `"task-triggered" vs "framework-triggered" skill design`

**Finding:** No literature uses these exact terms, but the architectural distinction is implicit in every skill audit. SP's 16 entry-point skills are *all* task-shaped: `brainstorming` (creative work), `systematic-debugging` (bug), `writing-plans` (have a spec), `verification-before-completion` (about to claim done), `using-git-worktrees` (starting feature work). Every trigger is a **user-language pattern** the model can match without prior framework knowledge.

PF's `tier-selection` requires the model to know what a "Tier" *is* before it can decide whether the trigger applies. The trigger is "user describes any non-trivial work … classifies the task as Tier 1, 2, or 3" — but `Tier 1/2/3` is a framework primitive, not a user-language primitive. A model with no PF context cannot pattern-match "Tier" against a user prompt that says "fix this bug."

**Implication:** Frame-shaped triggers create a chicken-and-egg loop: model needs the skill to learn the framework, but the trigger requires framework knowledge to fire. SP avoids this by making every entry-point skill task-shaped; the "framework" is implicit in the chain (brainstorming → writing-plans → subagent-driven-development) without ever being a user-facing trigger.

#### B.1.3 — `single-skill invocation vs methodology cascade Anthropic`

**Finding:** Anthropic's official "Skill" docs (docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices) describe skills as **discrete capability bundles**, not cascade orchestrators. Best-practice doc emphasizes: "Each skill should be self-contained and complete the task it describes." There is no documented pattern for "skill A invokes skill B mid-turn."

The Anthropic Engineering blog "Equipping agents for the real world with Agent Skills" (2025) describes skills as "specialized expertise" the model loads, follows, and completes. The implicit assumption: one skill per task arc, possibly paired with sub-agent dispatch.

**Implication:** PF's "8 skills fire per Tier-3 cold prompt" assumption is not refuted but is unsupported by Anthropic's own messaging. Anthropic's framing supports SP's "fire once, follow it" model, not PF's "fire many in chain."

#### B.1.4 — `"Skill tool" how many skills fire per turn empirical`

**Finding:** Empirically measured from the SP transcript at hand:
- **Total Skill-tool invocations: 1** (`superpowers:brainstorming`)
- **Total tool calls: 83** (14 Bash + 14 Edit + 4 Write + 35 Read + 3 Grep + 12 TodoWrite + 1 Skill, transcript path: `c:/Users/atyab/Experimental - Users/ECA Portal Copy/_bench/runs/T1/sp/rep-1/transcript.jsonl`)
- **Skill share of tool calls: 1/83 ≈ 1.2%**

The model invoked brainstorming once at line 13–53 (streamed start to assistant message), received the skill body via `tool_result` at line 57, *thought about whether to follow it*, and then proceeded to execute the task with raw tools. It never re-invoked Skill for writing-plans, subagent-driven-development, TDD, verification-before-completion, or finishing-a-development-branch — all of which are textually referenced as "REQUIRED SUB-SKILL" or "next step" in the SP cascade documentation.

**Implication:** The empirical answer to "how many skills fire per turn" in a real SP run on a real task is **one**. PF's design budget of 8 skills per Tier-3 prompt is 8x what was empirically observed even in the well-instrumented SP plugin.

#### B.1.5 — `why does superpowers fire only one skill per task`

**Finding:** Two structural causes, visible in code:

1. **Skill bodies tell the model to invoke the next skill in text** (e.g., `brainstorming/SKILL.md:135` says "Invoke the writing-plans skill"). The model receives this instruction, but the trigger to actually invoke is gated on user approval ("user approves design → invoke writing-plans"). In benchmark runs where the user prompt is monolithic (no human approval mid-turn), the gate is never opened, and the cascade halts at brainstorming.

2. **`<HARD-GATE>` blocks the cascade until user-mediated transition.** `brainstorming/SKILL.md:13` says: *"Do NOT invoke any implementation skill … until you have presented a design and the user has approved it."* The user-approval gate is load-bearing for the cascade. In a benchmark with a single-shot user prompt, the model never receives "approved" and so the cascade designs itself out.

Together: SP's cascade is **user-gated**, not **model-autonomous**. The user is part of the chain — the cascade does not run without them. This is invisible to anyone reading SP's skill bodies and assuming the chain auto-fires.

**Implication:** PF's cascade assumed **model-autonomous** firing (model goes tier-selection → 7-questions → enterprise-research-first → … without user approval gates between each). This is structurally different from SP and structurally unattested in any plugin we've studied.

#### B.1.6 — `chicken-and-egg framework bootstrap entry point AI`

**Finding:** No literature on this exact framing, but the chicken-and-egg problem is well-known in **DSL design** (Felleisen et al., "A Programmable Programming Language") and in **bootstrapping compilers** (the T-diagram tradition). The relevant pattern: a system that requires its own primitives to teach its primitives can only bootstrap via an external primer.

SP's primer is `using-superpowers` — a meta-skill that teaches "how to find and use skills." It's task-shaped: "Use when starting any conversation." It auto-invokes via the SessionStart hook (or via the model recognizing a new conversation). Once it fires, the model knows the cascade names; subsequent skill invocations match by name.

PF's primer is `using-this-framework`, which delivers via SessionStart hook but was silently broken (Issue #001) for weeks. Without the primer firing, the model never learns "tier" / "tier-selection" exist, and the framework-shaped trigger never matches.

**Implication:** Framework-shaped entry points have a dependency on the primer firing. If the primer is even slightly broken (hook payload schema mismatch in PF's case), the entire cascade silently no-ops. SP's task-shaped entry points degrade more gracefully — `brainstorming` fires on user-language even without `using-superpowers` having loaded, because "Use when starting any creative work" is a user-language trigger.

#### B.1.7 — `"tier selection" cold prompt anti-pattern`

**Finding:** No literature uses "tier selection" as a named anti-pattern. The closest art is **YAGNI** (Martin, "The Lean Software Craftsman") and **"early classification anti-pattern"** in workflow systems (BPMN literature: classifying work before understanding it forces premature categorization).

Inspecting `production-framework:tier-selection` description: *"Use when the user describes any non-trivial work … before reading code or writing a plan. Classifies the task as Tier 1, 2, or 3."* Three problems visible from the description alone:

1. **Premature classification:** "Before reading code" means the model classifies based on user prose alone. SP's analogous skills (`brainstorming` for creative work, `systematic-debugging` for bugs) don't classify upfront — they branch on the **type of work** which is intrinsic to the user prompt, not on a Tier number.
2. **Non-task-shaped trigger:** "Tier 1/2/3" is framework metadata, not user language.
3. **Cascade-rooted:** tier-selection is the *root* of PF's cascade. If it doesn't fire, nothing downstream fires. SP has no analogous root — the cascade roots are multiple task-shaped entry points (brainstorming, debugging, etc.), reducing the blast radius of any single skill failing to trigger.

**Implication:** "Tier selection" is a category-error: it's a design-time meta-decision being forced into a runtime trigger. Decisions like Tier-1-vs-Tier-3 are better encoded as branches *inside* a task-shaped skill (e.g., `brainstorming` body asks "is this a 1-line tweak or a multi-module feature?") rather than as a separate cascade-root skill.

---

### B.2 — SP cascade behavior

**Designed cascade (from SP code):**

`using-superpowers/SKILL.md:53-68` — model entry point. Says: every conversation starts here; Skill tool invocation BEFORE any response.

`brainstorming/SKILL.md:13` — `<HARD-GATE>`: blocks all implementation skills until user-approved design. **User approval is the cascade gate.**

`brainstorming/SKILL.md:32, 48, 62, 66, 135-136` — terminal state: "invoke writing-plans skill … the ONLY skill you invoke after brainstorming is writing-plans."

`writing-plans/SKILL.md:52, 147, 151` — "REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans."

`subagent-driven-development/SKILL.md:266-276` — Integration section names required workflow skills: `using-git-worktrees`, `writing-plans`, `requesting-code-review`, `finishing-a-development-branch`, `test-driven-development`. **Each of these is a TEXT REFERENCE, not an in-skill `Skill` tool call.** The skill body tells the model to "use" the next skill; whether the model actually invokes Skill again is the model's choice.

`executing-plans/SKILL.md:36` — "REQUIRED SUB-SKILL: Use superpowers:finishing-a-development-branch" (text reference, not auto-invocation).

**Designed cascade depth:** ~5 skills if the chain runs end-to-end (brainstorming → writing-plans → subagent-driven-development → test-driven-development per task → finishing-a-development-branch).

**Empirical cascade depth (SP transcript):** **1 skill** (`brainstorming` only).

**Why the gap:** the `<HARD-GATE>` user-approval requirement and the bench's single-shot prompt mean the model never receives the "approved" signal. The cascade halts at the hard-gate, the model decides the user prompt is sufficient ("user has given me a clear directive: 'Make these decisions, document them briefly, and implement'" — line 67-69 of transcript), and proceeds with raw tools.

This is visible in the model's own thinking (transcript lines 64-70): *"The brainstorming skill has been loaded. However, the user has given me a very detailed specification with all the design decisions explicitly listed as questions I need to answer myself. This isn't really a brainstorming situation … This is an implementation task with design decisions embedded in it."*

**Conclusion:** SP's cascade is a **suggested chain**, not a **mandatory chain**. The model receives skill A's body, decides whether to honor the chain, and frequently elects not to (in benchmark settings).

---

### B.3 — SP transcript Skill-tool count (empirical)

**File inspected:** `c:/Users/atyab/Experimental - Users/ECA Portal Copy/_bench/runs/T1/sp/rep-1/transcript.jsonl`
**Line count:** 3,874
**Run metadata:** task_id=T1, arm=sp, rep=1, wall_seconds=469, exit_code=0

| Tool | Invocation count |
|---|---|
| Skill | **1** (`superpowers:brainstorming`) |
| Bash | 14 |
| Edit | 14 |
| Write | 4 |
| Read | 35 |
| Glob | 0 |
| Grep | 3 |
| TodoWrite | 12 |

**Skill share of total tool calls: 1 / 83 ≈ 1.2%.**

**Cross-check:** PF transcript at `c:/Users/atyab/Experimental - Users/ECA Portal Copy/_bench/runs/T1/pf/rep-1/transcript.jsonl` shows **0 Skill-tool invocations** (this is the v1.0.1 baseline that triggered the v1.1.0 fix bundle).

**Verdict:** SP fires ONE skill. PF fired ZERO. Neither fires the multi-skill cascade PF's design assumed would happen. The "multi-skill cascade per task" pattern is **not empirically observable** in either plugin we have transcript data for.

---

### B.4 — PF cascade design vs SP single-fire — architectural delta

| Dimension | SP (designed) | SP (empirical) | PF v1.x (designed) | PF v1.x (empirical) |
|---|---|---|---|---|
| Entry-point shape | Task-shaped (brainstorming, debugging) | Task-shaped | Framework-shaped (tier-selection) | (didn't fire) |
| Cascade depth | ~5 skills end-to-end | 1 skill | 8 skills (tier → 7q → research → regression → gate3 → verify → arch-doc → write-plan) | 0 skills |
| Cascade gate | User approval at HARD-GATE | User never approves in benchmark → halts at brainstorming | Model-autonomous (no user gate between cascade steps) | Cascade root never fired (hook bug + framework-shaped trigger) |
| Primer skill | `using-superpowers` (task: "starting any conversation") | Implicit in cascade design | `using-this-framework` (delivered via SessionStart hook) | Hook silently dropped payload (Issue #001) |
| Failure mode | Cascade halts at first user-approval gate; model proceeds with raw tools | Same | Cascade root doesn't fire → 0 cascade depth → raw tools without any methodology scaffolding | Same |
| TodoWrite usage | Spontaneous (12 in transcript) | Same | Designed to track cascade steps | 8 → 0 in v1.1.0 (collapsed) |

**The core delta:** SP's design accepts that the cascade may not run end-to-end — the entry-point skill is self-sufficient (`brainstorming` alone produces a usable spec even if writing-plans never fires). PF's design assumed all 8 cascade steps would fire, so each step's content was distributed across the cascade. When the cascade collapses to depth-0 or depth-1, **no single PF skill is self-sufficient** — `tier-selection` produces only a tier number, which is useless if the next skill (writing-plan or arch-doc) never fires.

---

### B.5 — What this would have prevented in PF v1.x

**Hypothesis under test:** "PF v1.x fired 0 skills because the cascade design assumed model-autonomous multi-skill firing that doesn't empirically occur."

**Evidence supporting:**
1. SP transcript fired 1 skill (not its designed ~5).
2. PF transcript fired 0 skills (not its designed 8).
3. SP's cascade survives with 1 skill firing because brainstorming is self-sufficient.
4. PF's cascade collapses entirely because no single PF skill is self-sufficient — each is a fragment of the cascade.
5. The v1.1.0 1%-mandate forcing function ("you MUST invoke a skill if 1% chance applies") didn't help PF because the model couldn't pattern-match any framework-shaped trigger against the user prompt — even the 1% threshold matches nothing.

**Evidence against:**
- PF's hook bug (Issue #001) is sufficient on its own to explain v1.0.1's 0-skill firing. The cascade-design hypothesis is additive, not exclusive.
- v1.1.0 patched the hook AND retained the cascade design AND fired 0 skills → the cascade-design hypothesis is consistent with the v1.1.0 negative result, but a deeper test (rebench with task-shaped entry point) would isolate it.

**What B.1-B.4 evidence would have prevented in PF v1.0:**
- The decision to make `tier-selection` the cascade root rather than `brainstorming`/`debugging`/`writing-plan`-style task-shaped entry points.
- The 8-skill cascade depth budget — would have been compressed to 1-2 skills with stronger self-sufficiency.
- The 1%-mandate forcing function would not have been added (it doesn't help when no skill matches the user prompt at all — it just induces analysis paralysis, which is the v1.1.0 +35% cost / TodoWrite 8→0 regression).

---

### B.6 — Implications for v1.2+ design

**This research does NOT propose a PF-specific fix** (per task scope). It surfaces three architectural directions a v1.2+ design discussion would need to choose among:

1. **Cascade abandonment / SP-shaped redesign.** Replace `tier-selection` cascade with task-shaped entry points: `brainstorming` (already exists), `triage` (already exists, well-formed trigger), `debugger`-equivalent. Each entry-point skill is self-sufficient. Tier-selection becomes a branch *inside* `brainstorming` ("scope check — is this 1-file or multi-module?") rather than a separate cascade root. Cost: massive content reorganization. Benefit: matches SP's empirically-firing pattern.

2. **Cascade preserved but compressed.** Keep `tier-selection` but compress the 7 downstream skills into one or two skills that are self-sufficient. E.g., a single `tier-3-execution` skill that contains everything from arch-doc through verification. Cost: skill bodies become large. Benefit: cascade depth = 1-2, matching empirical depth.

3. **Cascade preserved, model-autonomous firing investigated.** Ship a cascade-explicit benchmark that measures whether models *can* fire 5+ skills in sequence given the right priming. If yes, the failure is hook-side (delivery) and the cascade design is salvageable. Cost: large benchmark investment. Benefit: data-driven design decision.

The Phase 1 rebench planned in PROJECT-PLAN.md is the natural test: if v1.1.0 (with the hook fixed) still fires <2 skills per Tier-3 prompt, option (3) is empirically refuted and the choice narrows to (1) or (2).

---

### B.7 — Risks / open questions

1. **N=1 transcript.** The empirical "1 Skill invocation" finding is from a single SP run. A second SP rep, or a different task, might show different cascade depth. Recommendation: examine `T1/sp/rep-2`, `T2/sp/rep-1`, etc. if available, before declaring "SP fires once" binding.

2. **Benchmark-vs-real-use divergence.** The bench prompt is monolithic ("build feature X"). Real interactive use has multiple user turns where the user *does* approve mid-cascade, opening the HARD-GATE. SP's cascade may run end-to-end in real interactive use but halt in single-shot benchmarks. PF's benchmark methodology may be measuring a degenerate case.

3. **Task-shaped vs framework-shaped is a spectrum, not binary.** SP's `using-git-worktrees` ("starting feature work that needs isolation") is closer to framework-shaped than `brainstorming` is. The boundary is not crisp.

4. **`using-superpowers` itself has an "even 1% chance you MUST invoke" mandate** identical to PF's 1%-mandate (`using-superpowers/SKILL.md:11`). The mandate alone is not the regression cause — SP has it and fires fine (1 skill, but matches the task). The PF regression is more likely the *combination* of mandate + framework-shaped triggers that don't pattern-match user prose, leaving the model with "MUST invoke something but nothing fits."

5. **The v2 SP transcript was a Sonnet 4.6 run.** PF's runs were also Sonnet 4.6. But model version sensitivity is unmeasured — Opus or earlier Sonnet might have different cascade-firing behavior. Recommendation: include a model-axis cell in any future cascade-depth benchmark.

6. **No public Anthropic doc explicitly bans cascade-shaped designs.** This research found no documented support for the cascade pattern, but absence of evidence ≠ evidence of absence. There may be Anthropic-internal patterns or undocumented best practices that support it.

---

### Sources

**Code (verified, file:line):**
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/using-superpowers/SKILL.md:11, 30, 46, 53-68`
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/brainstorming/SKILL.md:13, 32, 48, 62, 66, 135-136`
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/writing-plans/SKILL.md:52, 147, 151`
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/executing-plans/SKILL.md:36`
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/subagent-driven-development/SKILL.md:266-276`

**Transcripts (verified, line counts):**
- `c:/Users/atyab/Experimental - Users/ECA Portal Copy/_bench/runs/T1/sp/rep-1/transcript.jsonl` — 3,874 lines, 1 Skill invocation at lines 13/53/57
- `c:/Users/atyab/Experimental - Users/ECA Portal Copy/_bench/runs/T1/pf/rep-1/transcript.jsonl` — 0 Skill invocations
- `c:/Users/atyab/Experimental - Users/ECA Portal Copy/_bench/runs/T1/sp/rep-1/run_meta.json` — wall_seconds=469, exit_code=0

**External (training-data; verify before citing in design):**
- Wei et al., "Chain-of-Thought Prompting Elicits Reasoning in LLMs" (NeurIPS 2022) — prompt-chaining, not skill-chaining
- Yao et al., "ReAct: Synergizing Reasoning and Acting in LLMs" (2022) — single-agent reason+act loop
- Anthropic Engineering, "How we built our multi-agent research system" (2024) — orchestrator + sub-agents (Task), not skill cascade
- Anthropic Engineering, "Equipping agents for the real world with Agent Skills" (2025) — skills as discrete capability bundles, no cascade pattern documented
- docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices — "skill should be self-contained"

<!-- END-CATEGORY-B -->

---

## Category C — Bootstrap context budget effects on reasoning

<!-- BEGIN-CATEGORY-C -->

### C.1 Per-query findings (8 sub-blocks)

**Q1 — "LLM system prompt length effect on reasoning quality"** Reasoning degradation kicks in well before the technical context limit. Public reporting on transformer position-bias and "lost-in-the-middle" effects converge on a degradation onset around 3,000 tokens — and CoT does NOT rescue it; the limitation is architectural. A 10,000-token prompt may effectively operate on the last ~2,000 tokens because of recency bias. Citations: MLOps Community "Impact of Prompt Bloat on LLM Output Quality"; PromptLayer "Disadvantage of Long Prompt for LLM"; Medium "Why Long System Prompts Hurt Context Windows"; arXiv 2510.05381.

**Q2 — "context window overhead degraded performance"** Chroma's "Context Rot" study tested 18 frontier models and found *every single one* degrades as input length grows — independent of retrieval quality. 11 of 12 models drop below 50% of their short-context performance at 32k tokens. Mechanism: O(n²) attention scaling + KV-cache pressure. Citations: Chroma; Morph; arXiv 2601.11564.

**Q3 — "analysis paralysis LLM forcing function 'you MUST'"** Literature is split. SuperAnnotate's "26 prompting tricks" treats imperative framing as *positive*. None of the surveyed sources directly study the inverse — what happens when the imperative names a category (a "skill") that the model cannot quickly map to the current task. GoInsight's "10 LLM Prompt Mistakes" calls out conflicting/over-constrained imperatives produce hedging, multi-equivocal output, tool-call hesitation. The "paralysis" failure mode is consistent with prompt-engineering folklore but **not** documented as a named, measured phenomenon in any peer-reviewed source returned. Verdict: hypothesis is plausible-but-unproven.

**Q4 — "1% mandate prompt engineering side effects"** No literature on the specific "1% chance" framing — internal to the obra/superpowers community. Generic compliance-prompt literature notes over-specified compliance prompts plateau around 80% accuracy.

**Q5 — "system prompt signal-to-noise ratio benchmark"** Emergent Mind frames it: high SNR requires inter-task score differences to exceed intra-task stochastic fluctuations. The mandate is *signal* if it discriminates which tool to fire; it becomes *noise* if every input gets the same "MUST invoke a skill" pressure regardless of task fit.

**Q6 — "SessionStart hook size token budget Claude Code"** Claude Code base system prompt is ~2,900 tokens before user CLAUDE.md, MCP tool defs, and SessionStart additionalContext (codewithmukesh). Anthropic guidance: SessionStart "runs on every session, so keep these hooks fast" and additionalContext is silently injected (no UI to verify). PF's bootstrap (7,409 bytes ≈ 1,800 tokens) more than doubles the harness baseline before the user's first message. SP's bootstrap (5,421 bytes ≈ 1,300 tokens) is ~28% smaller.

**Q7 — "prompt-stuffing degraded tool use frequency"** RAG-MCP (arXiv 2505.03275) measured tool-selection accuracy improvement from 13.62% → 43.13% by *reducing* prompt tokens 50%+ and offloading tool descriptions to retrieval. LeanIX engineering blog reports 50+ tools causes ~7% context loss before any user token arrives, and tool-hallucination/parameter-conflation rise with semantically similar tools. **This is the most direct empirical mechanism for the v1.1.0 TodoWrite collapse:** the bootstrap pre-loaded ~30 skills (kebab-case verb-noun phrases — high tool-similarity), and TodoWrite is one of dozens of similarly-shaped instruments — exactly the regime where the model degrades on tool-frequency.

**Q8 — "bootstrap teaching vs lazy-loaded skill tradeoff"** Two paradigms. (1) Bootstrap-teaching: BOSS (clvrai), AAAI 2024 "Bootstrapping Cognitive Agents". (2) Lazy-load: Substack "Lazy Skills"; LogRocket "Context engineering for IDEs"; Agenteer "Two Context Bloat Problems". Lazy-load consensus: "Skills enable MORE context to be available while requiring LESS context to be loaded" — pre-loading is justified ONLY for small, frequently-used libraries. PF's current bootstrap is a hybrid that pays both costs: it teaches *philosophy* (long prose) AND lists 30+ skills as triggerable surfaces (tool-similarity bath). SP's bootstrap is closer to pure lazy-load.

---

### C.2 SP bootstrap structure (verbatim section list + lengths)

File: `c:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/using-superpowers/SKILL.md`. **Total: 5,421 bytes / 118 lines.**

1. Frontmatter (1–4)
2. `<SUBAGENT-STOP>` (6–8) — **escape hatch #1**: "if dispatched as a subagent, skip"
3. `<EXTREMELY-IMPORTANT>` 1%-mandate (10–16) — short, three bullets, no prose
4. `## Instruction Priority` (18–26) — **escape hatch #2**: "user instructions ALWAYS take precedence" with worked example
5. `## How to Access Skills` (28–36) — platform-specific tool name (zero ambiguity about *the mechanism*)
6. `## Platform Adaptation` (38–40)
7. `# Using Skills > ## The Rule` (42–46) — restates "even 1%, invoke" with **escape hatch #3**: "if invoked skill turns out wrong, you don't need to use it"
8. **Graphviz `digraph` decision flow** (48–76) — *visual algorithm* model can pattern-match
9. `## Red Flags` (78–95) — **12-row rationalization table** ("Thought" / "Reality"). Every common rationalization is named with a one-line refutation. **The structural feature PF lacks.**
10. `## Skill Priority` (97–104) — process-skills-first ordering with two examples
11. `## Skill Types` (106–113) — Rigid vs Flexible
12. `## User Instructions` (115–117) — final escape hatch: "Instructions say WHAT, not HOW"

SP's hook frames the bootstrap as: "**Below is the full content of your 'superpowers:using-superpowers' skill — your introduction to using skills**" (`hooks/session-start` line 35). Framed as *introduction*, not hard requirement.

---

### C.3 PF bootstrap structure (current state from disk)

File: `c:/Users/atyab/Experimental - Users/production-framework/skills/using-this-framework/SKILL.md`. **Total: 7,409 bytes / 157 lines (~37% larger than SP).**

1. Frontmatter (1–4)
2. `## Overview` (6–8) — prose paragraph explaining what the framework is
3. `<EXTREMELY-IMPORTANT>` mandate (10–12) — **no escape hatch**: "you MUST invoke. Do not rationalize past this — invoke first, judge fit second."
4. `## When to Use` (14–16)
5. `## Core Pattern` (18–93) — **the bulk**: Universal Rules taxonomy (32 rules, A–I categories, 6 enforcement-tag types), Tier Selection pointer, 7 Validation Questions pointer, Status Token Vocabulary pointer, HARD-GATE markers, No-Ceremony contract (7 forbidden phrasing patterns), Output Discipline (4 line-budget rules), First-Session Check
6. `## Quick Reference` (95–106) — table of 7 topic→file mappings
7. `## Compact Instructions` (109–122)
8. `## Skill Discovery` (125–141) — table of 7 entry-point skills
9. `## Instruction priority` (145–155) — 3-tier precedence
10. **Closer (157): "Framework loaded. Invoke production-framework:tier-selection before any further action."**

The SessionStart hook wraps all of this in a *second* `<EXTREMELY_IMPORTANT>` block (`hooks/session-start.sh` line 96), so the mandate appears *twice* — once at line 10–12 of body, once as outer wrapper.

---

### C.4 Where the actionability differs — concrete mechanism

**The difference is not the mandate. The difference is what surrounds it.**

| Dimension | SP `using-superpowers` | PF `using-this-framework` |
|---|---|---|
| Total bytes | 5,421 | 7,409 (+37%) |
| Mandate present | Yes, line 10–16 | Yes, line 10–12 + wrapped a second time by hook |
| Escape hatches before mandate | 1 (`<SUBAGENT-STOP>`) | 0 |
| Escape hatches after mandate | ~5 | ~1 |
| Decision algorithm | Graphviz digraph (48–76) — model can pattern-match nodes/edges | Prose only, scattered |
| Red-Flags rationalization table | **12 rows** | **0 rows** |
| Closer | "Instructions say WHAT, not HOW" (low-pressure aphorism) | "MUST invoke `tier-selection` before any further action" (high-pressure imperative naming a specific skill) |
| Framing of mandate | "introduction to using skills" | `<EXTREMELY_IMPORTANT>...</EXTREMELY_IMPORTANT>` outer wrap |
| Named entry-point skills in body | 0 (skill discovery is "use the Skill tool") | 7 (model has to *match* among 7 candidates per turn) |

**Concrete mechanisms:**

1. **Mandate paired with escape-hatch table.** SP's Red Flags table pre-names rationalizations with refutations. The model converts "did I rationalize?" (impossible self-audit) → "is my next thought in the table?" (pattern match). PF lacks this. When PF's model thinks "this is just a quick file read," it has no internal signal that this *is* the rationalization SP names — so it acts on the thought.

2. **Interface vs taxonomy.** SP teaches the *interface* (Skill tool, fallback platforms, error-recovery: "if invoked skill is wrong, you don't need to use it"). PF teaches the *taxonomy* (32 rules in 9 categories, 6 enforcement-tag types, HARD-GATE markers, no-ceremony contract). Taxonomy is not actionable on a fresh user prompt. Interface is.

3. **Closer specificity.** SP's closer is a low-pressure aphorism. PF's closer hard-binds the next action to a specific skill (`tier-selection`) that often doesn't fit the user's actual prompt. Combined with PF's 7-skill entry list, the model on a fresh prompt now faces: "I MUST invoke `tier-selection`, but the user just asked me to read a file — `tier-selection` is for non-trivial work — but mandate says invoke skills even at 1% — but `tier-selection` doesn't fit — flail." TodoWrite, not on PF's escape-hatch list, gets squeezed out.

4. **Decision flow form.** SP's digraph uses doublecircle/diamond/box typing — model has been trained on millions of digraphs. PF forces the model to re-derive the algorithm from natural-language sub-headings every turn. This is exactly the "context rot" condition Chroma measured.

5. **Doubled wrapping.** PF's body itself contains `<EXTREMELY-IMPORTANT>` (line 10–12), AND the hook wraps the file in another `<EXTREMELY_IMPORTANT>`. Mandate is duplicated and over-weighted vs surrounding escape hatches.

---

### C.5 Forcing-function paralysis — does the literature confirm or refute?

**Verdict: literature CONFIRMS upstream mechanisms (over-stuffing, tool-similarity, position bias) but does NOT name "forcing-function paralysis" as a measured phenomenon. PF rebench is the strongest evidence — but internal, N=1.**

**Confirming evidence (mechanisms):**
- **Tool-similarity collapse** (LeanIX): tool-hallucination/parameter-conflation rise with semantically similar tools. PF's 30+ kebab-case skill listing is the bath. Direct match for TodoWrite-collapse symptom.
- **Position bias** (arXiv 2510.05381): mid-prompt content gets ignored. PF's mandate sits in middle, closer overrides with more specific skill name — model weights closer over mandate.
- **CoT does not rescue long context** (MLOps; arXiv 2510.05381). Rules out "better reasoning prompts" as fix.
- **Cost regression from instruction stuffing** documented (LeanIX; RAG-MCP, 50%+ token reduction → 3x tool accuracy).

**Refuting evidence:** No source directly studies a 1%-mandate-without-escape-hatch as a paralysis source. SuperAnnotate treats "you MUST" as positive — but assumes the imperative names a specific *action* ("format as JSON"), not a *category* the model has to map to ("invoke a relevant skill among 30").

**Net:** upstream mechanisms are measured and consistent with PF rebench. Downstream phenomenon (mandate-without-escape-hatch → flail) is plausible from those mechanisms but is *not* a named research result. The PF rebench (cost +35%, wall +41%, TodoWrite 8→0) is a single empirical data point — strong for an internal decision, weak for a literature claim.

**Top citation:** Chroma "Context Rot: How Increasing Input Tokens Impacts LLM Performance" — https://www.trychroma.com/research/context-rot — 18 frontier models, all degrade as input grows.

---

### C.6 What this would have prevented in PF v1.x (the cost regression)

The v1.1.0 fix added (a) a 1%-mandate `<EXTREMELY-IMPORTANT>` block, (b) closer "MUST invoke `tier-selection` before any further action." Rebench: cost +35%, wall +41%, TodoWrite 8→0.

If this gap-research had been available at v1.0→v1.1 design time:

1. **Mandate intact, paired with Red-Flags table** (SP's load-bearing feature). Converts rationalization-detection from impossible self-audit to pattern match.
2. **Closer would not name `tier-selection`.** SP's closer is an aphorism; PF's hard-binds to a specific skill that often doesn't fit, manufacturing contradiction with user's actual prompt.
3. **7-skill entry-point table moved to lazy-load** (per Q8 consensus + RAG-MCP). With 7 candidates pre-loaded, model has to score-rank every turn; with 0 pre-loaded, model invokes Skill tool to discover.
4. **Doubled `<EXTREMELY_IMPORTANT>` collapsed to one** (the hook's), removing duplication-induced over-weighting.
5. **Universal Rules taxonomy moved to `core/rules.md` only.** SP teaches *interface* not *taxonomy*.

Net: bootstrap drops 7,409 → ~3,500 bytes (closer to SP's 5,421), removing position-bias floor and tool-similarity bath. Cost regression mechanistically attributable to context-rot + tool-similarity + missing escape hatches; addressing all three is the actionability-restoring intervention.

---

### C.7 Implications for v1.2+ design

(Read-only researcher — *implications*, not recommended fixes. Decision belongs to Deputy after all 13 categories synthesize.)

1. **Mandate without escape hatch is the highest-leverage anti-pattern.** Literature does not name it; PF rebench is empirical evidence; SP structural difference is natural-experiment control.
2. **Closer is load-bearing in a way line 10–12's mandate is not.** Position bias means closer dominates mandate — closer design is where v1.2+ effort should concentrate.
3. **Bootstrap size matters before content matters.** Q6+Q7: 7,409-byte bootstrap costs ~3% of a 64k-context turn before user's prompt arrives, compounding with MCP tool defs and CLAUDE.md. v1.2+ design space must include "smallest bootstrap that still teaches the framework's interface."
4. **The taxonomy (32 rules, 9 categories, 6 enforcement-tag types) is not actionable on a fresh prompt.** Should be lazy-loaded by `core/rules.md` reads when Tier 2/3 task triggers.
5. **Trim AND add escape hatch — both, not either.** SP does both. PF v1.1.0 did neither.

---

### C.8 Risks / open questions

1. **N=1 internal benchmark.** PF rebench is single before/after on one model. Public reporting (Chroma, RAG-MCP, LeanIX) shows direction but not magnitude PF saw. v1.2+ should include reproducible bench, not one-shot comparison.
2. **"Forcing-function paralysis" unnamed in literature.** Synthesis from named effects (context rot, tool similarity, position bias) — not a research result. v1.2+ post-mortem might be first to publish it as named pattern, but requires reproduction beyond N=1.
3. **SP's Red Flags table not independently benchmarked.** Its presence correlates with SP's lack of paralysis at PF's mandate strength; controlled experiment (PF + Red Flags table, mandate intact) has not been run. Plausibly load-bearing; not proven.
4. **Escape-hatch design is itself prompt-engineering risk.** A poorly-worded escape hatch can become a permission slip ("I don't need a skill — see Red Flag #7"). SP's table refutation column blocks rationalization. PF would need same discipline.
5. **Graphviz digraph effect unmeasured.** SP's decision flow is unusual (model-as-graph-walker); may or may not contribute to actionability. Removing it from SP fork to test would be cleanest controlled experiment, outside this research scope.
6. **PF's own Overview claims "value is in lazy-loaded skill bodies, not the bootstrap."** If true, bootstrap's job is *minimal teaching of the interface* — current 7,409 bytes contradict the framework's own design claim.
7. **Internal duplication of `<EXTREMELY_IMPORTANT>` wrapping.** PF Rejection Criterion #6 forbids inlining bootstrap rules into project CLAUDE.md, but does not cover the body's `<EXTREMELY-IMPORTANT>` block plus hook's outer `<EXTREMELY_IMPORTANT>` wrap creating *internal* duplication. v1.2+ should consider whether the rule should apply inside the bootstrap.

---

**Sources (URLs):**
- MLOps Community — https://mlops.community/the-impact-of-prompt-bloat-on-llm-output-quality/
- Grit Daily — https://gritdaily.com/impact-prompt-length-llm-performance/
- PromptLayer — https://blog.promptlayer.com/disadvantage-of-long-prompt-for-llm/
- DEV / superorange0707 — https://dev.to/superorange0707/prompt-length-vs-context-window-the-real-limits-behind-llm-performance-3h20
- Medium / Data Science Collective — https://medium.com/data-science-collective/why-long-system-prompts-hurt-context-windows-and-how-to-fix-it-7a3696e1cdf9
- arXiv 2510.05381 — https://arxiv.org/html/2510.05381v1
- Chroma "Context Rot" — https://www.trychroma.com/research/context-rot
- Demiliani — https://demiliani.com/2025/11/02/understanding-llm-performance-degradation-a-deep-dive-into-context-window-limits/
- Atlan — https://atlan.com/know/llm-context-window-limitations/
- Morph "Context Rot" — https://www.morphllm.com/context-rot
- arXiv 2601.11564 — https://arxiv.org/html/2601.11564v1
- SuperAnnotate "26 prompting tricks" — https://www.superannotate.com/blog/llm-prompting-tricks
- GoInsight "10 LLM Prompt Mistakes" — https://www.goinsight.ai/blog/llm-prompt-mistake/
- Lakera "Ultimate Guide to Prompt Engineering 2026" — https://www.lakera.ai/blog/prompt-engineering-guide
- Emergent Mind "Signal and Noise in LLM Evaluation" — https://www.emergentmind.com/topics/signal-and-noise-framework
- Anthropic Hooks docs — https://code.claude.com/docs/en/hooks
- codewithmukesh "Anatomy of a Claude Code Session" — https://codewithmukesh.com/blog/anatomy-claude-code-session/
- LeanIX "Why Your AI Agent Is Drowning in Tools" — https://engineering.leanix.net/blog/code-mode/
- arXiv 2505.03275 (RAG-MCP) — https://arxiv.org/pdf/2505.03275
- DEV "Prompt Stuffing Is Killing Your Agent" — https://dev.to/wassimchegham/agentic-rag-done-right-4846
- BOSS — https://clvrai.github.io/boss/
- Substack "Lazy Skills" — https://boliv.substack.com/p/lazy-skills-a-token-efficient-approach
- Agenteer "Two Context Bloat Problems" — https://agenteer.com/blog/the-two-context-bloat-problems-every-ai-agent-builder-must-understand/
- LogRocket "Context engineering for IDEs" — https://blog.logrocket.com/context-engineering-for-ides-agents-md-agent-skills/
- AAAI 2024 "Bootstrapping Cognitive Agents" — https://ojs.aaai.org/index.php/AAAI/article/view/27822/27674

<!-- END-CATEGORY-C -->

---

## Category D — Anti-patterns in framework / agent design

<!-- BEGIN-CATEGORY-D -->

**Researcher:** D | **Date:** 2026-04-29 | **Status:** DONE_WITH_CONCERNS
**Top finding:** SP ships **1** named `agents/*.md` agent (`code-reviewer`) plus 4 *embedded prompt-fragment files* inside skills. PF ships **7** named `agents/*.md` agents — every PF agent except `post-mortem` has an SP equivalent that is a *skill body* or *prompt fragment*, not a separate agent file.

---

### D.1 Per-query findings

**D.1.a "AI framework cargo cult anti-pattern"**
The cargo-cult anti-pattern in software (Wikipedia, ACM Queue) is "applying a design pattern blindly without understanding the reasons behind it." Applied to AI frameworks: companies "rush to integrate 'AI-powered' features… without a clear understanding of how AI aligns with their product, data, or workflows" — "form over substance" (Substack, Troitskyi, *Cargo Cult in Software Engineering*). The closest direct hit on subagent topology is Steve Kinney's *Common Sub-Agent Anti-Patterns* course (https://stevekinney.com/courses/ai-development/subagent-anti-patterns) — search-result-only, full body not reachable. **Direct quote relevant to PF:** "Teams adopt microservices or Kubernetes because it's trendy, despite not having the scale or complexity that justifies them" (thelearning.dev/7-programming-anti-patterns). Mapping: 7 named subagents for a framework whose only user is the framework author = same shape.

**D.1.b "over-built subagent topology single-agent vs multi-agent tradeoff"**
Anthropic's blog *When to use multi-agent systems (and when not to)* (https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them) — verbatim: **"In Anthropic's testing, multi-agent implementations typically use 3-10x more tokens than single-agent approaches for equivalent tasks."** And: **"agents typically use about 4× more tokens than chat interactions, and multi-agent systems use about 15× more tokens than chats."** Three justified situations: (1) context pollution, (2) parallelizable tasks, (3) specialization improves tool selection. Outside these: "coordination costs typically exceed the benefits." MindStudio: **"For most development tasks in 2026, subagents are the right answer."** PubNub: **"start with the simplest approach that works, and add complexity only when evidence supports it."**

**D.1.c "why does superpowers have only one agent"**
SP 5.0.7 ships a single `agents/code-reviewer.md` (verified — see D.2). Other "agent-like" capabilities are *prompt-fragment files inside skills* dispatched via `Task tool (general-purpose)` (see D.3). Direct evidence the design is intentional: SP `skills/subagent-driven-development/SKILL.md:10` — **"You delegate tasks to specialized agents with isolated context. By precisely crafting their instructions and context, you ensure they stay focused… They should never inherit your session's context or history — you construct exactly what they need."** SP makes the named-agent file *optional* — context-isolation is the goal, not a permanent agent registry. Builder.io's SP review confirms the dispatcher pattern: "the master skill — called 'using superpowers' — runs automatically at the start… and acts as a dispatcher: it reads your request, decides which of the 14 skills apply, and activates them in the right sequence."

**D.1.d "'capability label' vs 'situation trigger' agent description"**
The exact term-pair doesn't surface in published literature, but Anthropic's docs encode the distinction implicitly. From `code.claude.com/docs/en/sub-agents` line 241 (verbatim): the `description` field's required content is **"When Claude should delegate to this subagent"** — *situation*, not *capability*. Line 593 verbatim: **"Claude automatically delegates tasks based on the task description in your request, the `description` field in subagent configurations, and current context. To encourage proactive delegation, include phrases like 'use proactively' in your subagent's description field."** Patronus AI: **"Descriptions should be specific enough to differentiate agents from peers (e.g., 'Handles inquiries about current billing statements,' not just 'Billing agent')."** Consensus across 3 sources: descriptions must be situational/triggering, not capability nouns. PF's frontmatter (e.g., `MUST BE USED when…`, `Use PROACTIVELY when…`, `Examples: …`, `Do NOT use for…`) is *more* situation-trigger-shaped than SP's; PF is ahead here.

**D.1.e "LLM agent description writing best practices Anthropic"**
Anthropic's published canonical description format (saved doc lines 184–195, verbatim):
```
"description": "Expert code reviewer. Use proactively after code changes."
"description": "Debugging specialist for errors and test failures."
```
Pattern: **role noun-phrase + "Use proactively when…" trigger clause + (optional) "for…" scope clause**. Length: 1 short sentence per slot. PF descriptions average ~5 sentences each (e.g., `agents/builder.md:3` ≈ 80 words; `agents/deputy.md:3` ≈ 120 words). **Anthropic example length: ~10 words. PF: ~80–120 words.** 8-12× expansion vs documented canonical form.

**D.1.f "N/N consensus subagent description survey enterprise plugins"**
Surveyed: SP (1 named agent), Anthropic built-ins (4 named: Explore, Plan, general-purpose + statusline-setup/Claude Code Guide helper), wshobson/agents (orchestrator-style, 50+ specialists), VoltAgent/awesome-claude-code-subagents (100+ specialists, but a *catalog*, not a *running set*). Consensus on count for an active loaded set: **N=1–4 named agents** (SP=1, Anthropic Code defaults=3 functional + 2 helpers). PF=7 outside this band. Catalog-style repos don't contradict — they ship libraries to draw from, not 7-agent default activations. **CONSENSUS (3/3):** Active running framework load < 5 named agents. PF at 7 is the outlier.

---

### D.2 SP's 1-agent topology — verbatim file content + body purpose

**File listing** (`ls .../superpowers/5.0.7/agents/`):
```
code-reviewer.md
```
Single file. No `builder.md`, no `debugger.md`, no `deputy.md`, no `qa.md`, no `researcher.md`, no `post-mortem.md`.

**Frontmatter (verbatim, lines 1–6):**
```yaml
---
name: code-reviewer
description: |
  Use this agent when a major project step has been completed and needs to be reviewed against the original plan and coding standards. Examples: <example>...</example>
model: inherit
---
```

**Body purpose:** lines 8–48 — Senior Code Reviewer system prompt covering 6 numbered duties: Plan Alignment Analysis, Code Quality Assessment, Architecture/Design Review, Documentation/Standards, Issue Identification (Critical/Important/Suggestions), Communication Protocol. Single-shot review against a plan. Equivalent in PF: `agents/code-reviewer.md` (180 lines, much heavier; adds verdict scale, structural checks reference, severity table, output discipline) + portions of `agents/qa-auditor.md` (208 lines).

**Why one named agent suffices in SP:** named agent files exist for the case where the user @-mentions or the routing description must be visible in `/agents` UI. SP's other functional roles (implementer, spec-reviewer, code-quality-reviewer, plan-doc-reviewer, spec-doc-reviewer) are dispatched programmatically *from inside skill bodies* using the Task tool with general-purpose model + a prompt-fragment file. They never need to be visible to the user via `/agents` because the *skill that runs them* is the user-facing surface.

---

### D.3 SP's "skills with embedded prompts" pattern — file:line evidence

**Embedded prompt fragments** (Glob `skills/**/*-prompt.md`):
```
skills/brainstorming/spec-document-reviewer-prompt.md            (50 lines)
skills/subagent-driven-development/code-quality-reviewer-prompt.md (28 lines)
skills/subagent-driven-development/implementer-prompt.md           (113 lines)
skills/subagent-driven-development/spec-reviewer-prompt.md         (62 lines)
skills/writing-plans/plan-document-reviewer-prompt.md              (49 lines)
```
Five prompt fragments. None registered as agents (no frontmatter, not in `agents/`). They are **lazy-loaded text templates**. The dispatcher is the skill body.

**Dispatch pattern** (`skills/subagent-driven-development/SKILL.md:51–58, 122–124`):
```
Dispatch implementer subagent (./implementer-prompt.md)
Dispatch spec reviewer subagent (./spec-reviewer-prompt.md)
Dispatch code quality reviewer subagent (./code-quality-reviewer-prompt.md)
…
## Prompt Templates
- `./implementer-prompt.md` - Dispatch implementer subagent
- `./spec-reviewer-prompt.md` - Dispatch spec compliance reviewer subagent
- `./code-quality-reviewer-prompt.md` - Dispatch code quality reviewer subagent
```

**Inside `implementer-prompt.md:6–8` (verbatim):**
```
Task tool (general-purpose):
  description: "Implement Task N: [task name]"
  prompt: |
    You are implementing Task N: [task name]
    …
```
The prompt fragment is *literally* a Task-tool invocation template. The dispatcher (the user, or Claude reading the skill body) substitutes task variables and fires `Task(general-purpose, …)`. **No persistent agent registration. No frontmatter. No `description` field. No `/agents` entry.**

`spec-reviewer-prompt.md:8–10` uses the same pattern: `Task tool (general-purpose):` template.
`code-quality-reviewer-prompt.md:10` differs — it dispatches into the *named* code-reviewer agent: `Task tool (superpowers:code-reviewer):` — i.e., the one named agent SP ships is the destination for code-quality reviews. So SP has **1 named agent** that 1 skill targets, and **4 prompt-fragments** that ride the general-purpose subagent.

**Structural difference:** SP separates "agent identity" (1 file) from "role-shaped prompts" (4 fragment files invoked via skills). PF collapses them — every PF role gets its own `agents/*.md` file with full identity, frontmatter, description, memory, model selection, output discipline — even when the role is essentially a one-shot prompt.

---

### D.4 PF's 7-agent topology — what each PF agent does that couldn't be a skill body

| PF agent | Lines | SP equivalent | Could it be a skill body / prompt fragment? |
|---|---|---|---|
| `builder.md` | 184 | `subagent-driven-development/implementer-prompt.md` (113 lines, fragment) | **Yes.** SP demonstrates 113-line prompt fragment is sufficient. PF's 184 lines include reads list, plan-validation, business-logic ownership, debugging, output discipline — most would live in skill bodies under SP's structure. |
| `code-reviewer.md` | 180 | `agents/code-reviewer.md` (48 lines, agent) + `code-quality-reviewer-prompt.md` (28 lines) | **Maps directly.** PF could keep this as the only named agent. |
| `debugger.md` | 199 | `skills/systematic-debugging/SKILL.md` (skill body, no agent file) | **Yes — skill body suffices.** SP has no `debugger` agent file; methodology lives in a skill body any subagent can use. |
| `deputy.md` | 128 | `skills/using-superpowers/SKILL.md` (skill body, dispatcher pattern) | **Yes — skill body.** SP's "deputy equivalent" is the master dispatcher skill, not an agent. |
| `post-mortem.md` | 79 | **No SP equivalent** — SP has no pattern-evolution loop. | Genuinely new. Could still be a skill if dispatched programmatically, but a named agent is defensible if user @-mentions it. |
| `qa-auditor.md` | 208 | `spec-reviewer-prompt.md` (62) + `code-quality-reviewer-prompt.md` (28) — 90 combined | **Yes.** SP splits QA into spec-compliance + quality reviewers, both fragments. PF's 208-line single-blob is the largest agent; ~60% is severity tables, structural checklists, output rules that belong in skill bodies. |
| `researcher.md` | 257 | **No SP equivalent.** SP relies on Anthropic built-in `Explore` for read-only search. | Possibly genuinely new (enterprise-research-first methodology) — but enforceable as a skill (`enterprise-research-first` skill already exists; the agent is a wrapper). |

**Net assessment:** of 7 PF agents, 6 have functional equivalents in SP that are NOT separate agent files. Only `post-mortem` lacks any SP analog and `researcher` has only a partial Anthropic-built-in analog. **Conservative estimate: 4–5 of PF's 7 agents could be collapsed without functional loss**, matching SP's topology.

---

### D.5 Architectural tradeoff — scattered agents vs embedded prompts

| Dimension | PF: 7 separate `agents/*.md` files | SP: 1 agent + 4 embedded prompt fragments |
|---|---|---|
| `/agents` UI visibility | All 7 visible — high discoverability | 1 visible — fragments invisible |
| Auto-routing surface area | 7 descriptions compete for routing-LLM attention each turn | 1 description in routing pool — fragments routed by *skill body logic* |
| Maintenance burden | 7 × ~180 lines = ~1260 lines of agent config | ~50 + 4×~60 = ~290 lines |
| Description-collision risk | High — overlapping triggers (cf. Category G) | Low — only `code-reviewer` competes |
| User @-mention granularity | Fine — `@-builder`, `@-debugger`, `@-qa` independent | Coarse — user invokes a skill that dispatches |
| Skill / agent unification | Split: skill methodology + agent persona, often duplicated | Unified: skill *is* methodology *and* dispatch logic |
| Bootstrap token cost | All 7 agent descriptions enter routing context every turn | 1 description; skill content lazy-loaded only when relevant |
| Composability | Lower — agents are end-units; orchestration must live in Deputy | Higher — skills compose freely |
| Failure mode at 14 roles | Routing ambiguity, description-token bloat (Anthropic: "15-20+ tools = significant context overhead") | Adding skills adds zero routing-pool entries |

**Which scales:** SP. Adding a role in SP = drop a new `*-prompt.md`. Adding a role in PF = write a 180-line `agents/{name}.md`, tune frontmatter to not collide with the existing 7, register memory dirs, status tokens, output discipline, role boundaries.

**Which is easier to maintain:** SP. Fragment files are flat templates; refactoring is text-level. PF's agent files duplicate content (status-token grammar, output-discipline rules, "no ceremony" lists, on-demand-reads tables) — every change touches 7 files.

**Honest counter-argument for PF's design:** named agents *do* give the user direct @-mention control and visible role boundaries. If PF's user manually picks Builder vs Debugger, multiple files improve UX. SP's user mostly lets Claude decide — so 1 visible agent suffices. **PF's design only pays for itself if users actually @-mention agents directly** — which v1.x usage data should confirm or refute (open Q D.8.2).

---

### D.6 What this would have prevented in PF v1.x

The over-built 7-agent topology contributed to (inferred from file shapes — direct telemetry needs v1.x usage logs):

1. **Routing ambiguity / collision** — 7 descriptions all containing "MUST BE USED when…" / "Use PROACTIVELY when…" compete for the same router decisions. Compounds with Category G's findings.
2. **Skill / agent duplication** — PF ships *both* `skills/subagent-driven-development/SKILL.md` AND `agents/builder.md` AND `agents/qa-auditor.md`. SP's approach: one skill body + prompt fragments per role. Duplication invites drift.
3. **Bootstrap token cost** — every session loads metadata for 7 agents into routing context; SP loads 1. Taxes context budget (cf. Category C).
4. **Maintenance cliff** — ~1260 lines of agent config. Updates to status tokens, output discipline, "no ceremony" lists must touch 7 files. Drift evidence: `qa-auditor.md` uses `## On-demand reads` while `researcher.md` uses an HTML-comment block; same intent, different shape.
5. **N/N divergence** — published consensus on active agent-set size is 1–4 (SP=1, Anthropic defaults=3, MindStudio=start single). PF=7 diverges without documented justification — a U-AP-4 violation by the framework's own rule.
6. **Cargo-cult signal** — "specialized agent per role" is *intuitive* (mirrors human team structure) but Anthropic's data: specialization-per-agent costs 3-10× tokens vs single-agent for equivalent work. PF adopted the team-shape *because it felt right*, not because data demanded it.

---

### D.7 Implications for v1.2+ design

**Read-only researcher — does NOT propose a fix.** What the data invites the v1.2+ designer to consider:

- **Q-A:** Is there evidence in v1.x usage logs that users @-mention specific agents directly? If no, the named-agent UI value is unrealized and SP's collapsed pattern dominates. If yes, agents with <N% mention rate are candidates for fragment-collapse.
- **Q-B:** For each PF agent, count what % of body is *role-specific methodology* vs *boilerplate* (status tokens, output discipline, no-ceremony, on-demand reads). If boilerplate >50%, role-specific portion → prompt fragment; boilerplate → `core/`, injected at dispatch.
- **Q-C:** If PF v1.2+ keeps 7 agents, descriptions must conform to Anthropic's canonical pattern (D.1.e): noun-phrase + "use proactively when…" + scope, ~10 words. PF's 80–120-word descriptions are 8-12× canonical length — likely degrades router signal/noise.
- **Q-D:** Does post-mortem genuinely require an agent file (memory + dispatchability) or can it be a skill from the deputy/orchestrator context? Same for researcher — `enterprise-research-first` skill already exists; the agent is mostly a wrapper.
- **Consensus per U-AP-4:** Active-set count <5 is the published norm (3/3 sources). PF=7 is outlier. **BINDING per U-AP-4 only if N≥5 sources confirm.** Current label: `CONSENSUS (3/3)` — STRONG, not BINDING. Divergence permitted with documented justification but framework should produce that justification or collapse.

---

### D.8 Risks / open questions

1. **Sample size is 3 enterprise tools** (SP, Anthropic built-ins, MindStudio synthesis) plus 2 catalog repos. To upgrade `CONSENSUS (3/3)` → `BINDING per U-AP-4 (5/5)`, need 2 more comparable plugins surveyed. Researcher D did not extend.
2. **No v1.x usage telemetry available** — can't measure actual @-mention rates per agent or routing-collision incidents. Q-A above answerable only with that data.
3. **SP version 5.0.7 is one snapshot.** SP may have started with more agents and consolidated; trajectory matters. RELEASE-NOTES.md in SP could be checked (not done).
4. **PF's 7 agents may genuinely be 7 distinct routing surfaces for users.** Design isn't *necessarily* wrong; it's *unjustified by published consensus*. Justification could exist in v1.x design notes this researcher didn't read.
5. **`post-mortem` and `researcher` are partly novel.** They might not have SP analogs because PF does something SP doesn't (self-evolving pattern loop, enterprise-research-first as binding rule). Collapsing on grounds of "SP doesn't have them" would be the opposite mistake.

---

**Citations (D-section):**
- Anthropic Claude Code subagents docs — https://code.claude.com/docs/en/sub-agents (lines 241, 593 cited verbatim from saved fetch)
- Anthropic blog — When to use multi-agent systems — https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them
- Anthropic engineering — Multi-agent research system — https://www.anthropic.com/engineering/multi-agent-research-system
- SP `agents/code-reviewer.md` — `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/agents/code-reviewer.md`
- SP `skills/subagent-driven-development/SKILL.md` — same cache path
- SP `skills/subagent-driven-development/{implementer,spec-reviewer,code-quality-reviewer}-prompt.md`
- SP `skills/writing-plans/plan-document-reviewer-prompt.md`, `skills/brainstorming/spec-document-reviewer-prompt.md`
- MindStudio — Agent Teams vs Sub-Agents — https://www.mindstudio.ai/blog/claude-code-agent-teams-vs-sub-agents
- PubNub — Best practices for Claude Code subagents — https://www.pubnub.com/blog/best-practices-for-claude-code-sub-agents/
- Patronus AI — AI Agent Routing tutorial — https://www.patronus.ai/ai-agent-development/ai-agent-routing
- Steve Kinney — Common Sub-Agent Anti-Patterns — https://stevekinney.com/courses/ai-development/subagent-anti-patterns
- ACM Queue — Cargo Cult AI — https://queue.acm.org/detail.cfm?id=3595860
- Wikipedia — Cargo cult programming — https://en.wikipedia.org/wiki/Cargo_cult_programming
- Builder.io — SP plugin review — https://www.builder.io/blog/claude-code-superpowers-plugin
- wshobson/agents — https://github.com/wshobson/agents
- VoltAgent/awesome-claude-code-subagents — https://github.com/VoltAgent/awesome-claude-code-subagents

<!-- END-CATEGORY-D -->

---

## Category E — Plugin lifecycle / install mechanics

<!-- BEGIN-CATEGORY-E -->
**Bottom-line verdict:** PF's `directory`-source marketplace serves files live from the source path (REVIEW.md Issue #008 confirmed by Claude Code docs). The 1.0.1 → 1.1.0 cache rebuild + `installed_plugins.json` patch this session was metadata theatre — SessionStart-bootstrap and skill-description content changes had already taken effect on first save. Cache directory exists (1) for uniform loader resolution shape and (2) as substrate for symlinked file resolution. Reinstall is genuinely required only when (a) `plugin.json` `version` changes (cache subdir name is hard-keyed to it), (b) directory layout changes (new top-level files need symlinks created), or (c) `marketplace.json` metadata changes. Edits to existing skill bodies, hook scripts, agent descriptions, and SessionStart content land on next subprocess with **no** reinstall.

### E.1 Per-query findings

**Q1 — `directory source live serving cache reinstall`.** Claude Code docs ([code.claude.com/docs/en/plugin-marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)) document four marketplace `source` types: `github`, `git`, `directory` (local path, intended for development), `hostPattern`. For `directory`, the cache subdirectory is populated via **symlinks back to the source path**, not a copy ("the cache directory is created with symlinks to source files"). PF-specific: `known_marketplaces.json` shows `production-framework`'s `installLocation` is `c:\Users\atyab\Experimental - Users\production-framework` (source path itself), unlike `claude-plugins-official` whose `installLocation` is `~/.claude/plugins/marketplaces/claude-plugins-official` (separate clone). Read-comparison of `CLAUDE.md`, `CONFIG.yaml`, `.claude-plugin/marketplace.json` between source and cache: byte-identical. Cache `marketplace.json` still says `"version": "1.0.1"` (matches source) even though `plugin.json` says `1.1.0` — file is shared, not republished.

**Q2 — `installed_plugins.json schema reference`.** No public schema. Unofficial `hesreallyhim/claude-code-json-schema` repo (now archived) covers `plugin.json` and `marketplace.json` only. SchemaStore (`json.schemastore.org/claude-code-marketplace.json`) covers `marketplace.json` only. `installed_plugins.json` is internal Claude Code state with no published contract. Verbatim user registry (E.2) is the canonical reference for this report.

**Q3 — `when does Claude Code reinstall plugin from cache`.** Cache key is `<marketplace>/<plugin>/<version>` from `plugin.json:version`. Same-version edits NOT cache-invalidating for `github`/`git` sources (Issues #28492 "Local plugin cache not invalidated when source files change", #15642 "CLAUDE_PLUGIN_ROOT points to stale version after plugin update"). `/plugin update` compares marketplace `gitCommitSha` to installed `gitCommitSha`; if equal, no-op. Even when newer, often does not update cache or registry (Issues #14061, #45834, #46081). For `directory` source: edits land immediately on next subprocess because cache is symlink farm, **not** copy. Reinstall needed only for entries that don't yet exist in the cache (brand-new file requiring new symlink) or version-name changes. `--plugin-dir` flag bypasses cache entirely; `/reload-plugins` picks up changes without restart for `--plugin-dir` plugins.

**Q4 — `marketplace refresh vs reinstall difference`.** `/plugin marketplace update <name>` refreshes marketplace clone (`github`/`git`: `git pull`; `directory`: no-op since marketplace IS source). Does NOT touch installed-plugin caches. `/plugin update <plugin>@<marketplace>` is the actual cache-rebuild step — compares marketplace's declared version vs `installed_plugins.json[plugin][].version`; if different, removes old version dir and creates new one, updates registry's `version` and `installPath`. `/plugin uninstall` + `/plugin install` is brute-force; Issues #29074 / #15369 document uninstall doesn't clear cache files, so reinstall serves stale until cache dir manually deleted. For directory-source PF: marketplace update is meaningless (no remote); only `/plugin update` matters, to rename cache subdir.

**Q5 — `directory source plugin hot-reload`.** `/reload-plugins` reloads skills, agents, hooks, plugin MCP/LSP servers in current session without restart. Confirmed for `--plugin-dir` plugins. For `directory`-marketplace plugins (PF's case), cache is symlink-backed so `/reload-plugins` should pick up source edits live — same mechanism. Issues #18174 / #32399 / #6497 document hot-reload friction in some scenarios but not specifically directory-marketplace mode. **Untested for PF specifically.**

**Q6 — `version bump cache directory`.** Cache subdir named after `plugin.json:version`. On version change (1.0.1 → 1.1.0): designed `/plugin update` should create `cache/<m>/<p>/<new-version>/` and update registry; bug behaviour (Issues #14061, #15642, #29074, #45834) often fails (cache left at old name, registry retains old version, `CLAUDE_PLUGIN_ROOT` env var points at deleted dir). For `directory`-source: since cache is symlink farm of source, version-named directory is a label only — symlinks point to live source path regardless of dir name. Version bump is purely metadata.

### E.2 `installed_plugins.json` schema — observed verbatim

From `C:/Users/atyab/.claude/plugins/installed_plugins.json` (user's actual registry, 2026-04-28):

Top level: `{"version": 2, "plugins": {"<plugin-name>@<marketplace-name>": [<install-record>, ...]}}`

Per-install-record fields (consensus across 7 plugins on user's machine):
- `scope`: `"user"` | `"local"` | `"project"` (always present). `local`/`project` carry `projectPath`; `user` does not.
- `projectPath`: absolute path (only for `local`/`project` scope).
- `installPath`: absolute path (always). Cache location: `~/.claude/plugins/cache/<marketplace>/<plugin>/<version-or-sha>`.
- `version`: semver string | `"unknown"` (always). Sourced from plugin's `plugin.json:version` at install time. `"unknown"` appears for several official plugins (frontend-design, context7, github, playwright, skill-creator) — cache subdirectory literally named `unknown/`.
- `installedAt`: ISO 8601 timestamp (always). Initial install moment.
- `lastUpdated`: ISO 8601 timestamp (always). Most recent metadata write (we hand-set this to `2026-04-28T00:00:00.000Z` during the session-end patch).
- `gitCommitSha`: hex SHA (only for `github`/`git` sources). Vercel and superpowers carry it; PF (directory) and `unknown`-version officials do not.

PF's record verbatim: `scope: "local"`, `projectPath: "C:\\Users\\atyab\\Experimental - Users\\Vendor Email Scraping"`, `installPath: "C:\\Users\\atyab\\.claude\\plugins\\cache\\production-framework\\production-framework\\1.1.0"`, `version: "1.1.0"`, `installedAt: "2026-04-24T07:14:40.027Z"`, `lastUpdated: "2026-04-28T00:00:00.000Z"`. **Critical observation:** `scope: "local"` + `projectPath: "Vendor Email Scraping"` means PF was installed while in a different project's working dir; this record binds the install to that project. Sessions started elsewhere don't see it via this record — the rebench (running from ECA Portal Copy) likely loads PF directly via the `directory`-source marketplace registration in `known_marketplaces.json` (user-global), not via the install record. See E.8.

### E.3 `directory` vs git-source — when reinstall actually triggers

| Aspect | `directory` source (PF) | `github`/`git` source (SP, Vercel) |
|---|---|---|
| Marketplace materialization | IS the source path; no separate clone | Cloned to `~/.claude/plugins/marketplaces/<name>/` |
| Plugin cache materialization | Symlink farm in `cache/<m>/<p>/<version>/` to source | Copy of plugin files at pinned commit |
| Edits to skill/hook/agent files | Land live on next subprocess | Stale until `/plugin update` AND cache invalidation succeeds (often manual cache delete needed per #14061/#28492) |
| `plugin.json:version` bump | Cache subdir name needs update; registry needs update; both manual this session | `git pull` in marketplace + cache rebuild via `/plugin update` |
| New file added at top level | Symlink may need creation — **untested for PF, plausible reinstall trigger** | Cache rebuild needed |
| `marketplace.json` change | Loaded fresh from source on next session — no reinstall | `git pull` via marketplace update |
| `gitCommitSha` field in registry | Absent | Present, used as cache-staleness check |

Central insight: **version bump only matters for git-source plugins** (cache is real copy, version is the cache-key). For directory-source plugins, version is a vanity label.

### E.4 Cache directory purpose vs live source resolution

For `directory` source, the cache directory exists for three reasons:
1. **Uniform resolution shape.** Plugin loader expects every plugin at `~/.claude/plugins/cache/<m>/<p>/<version>/`. Symlinking-from-source makes directory-source plugins indistinguishable from git-source plugins to the loader — no special-case branching.
2. **Version handle for the registry.** `installed_plugins.json[plugin].installPath` must be a real path. The `1.1.0/` name is the handle.
3. **Selective per-file inclusion.** Symlinks created per top-level entry the marketplace declares (skills/, agents/, hooks/, etc.). Files outside declared roots not symlinked. Layout change (new top-level dir) plausibly needs reinstall while edits to existing files do not.

For `github`/`git` source: cache is the only local copy; live serving from cache because there's no other option. Cache-key-by-version model is the staleness defense. For `--plugin-dir` mode (CLI flag): no cache at all — Claude Code reads source directly; `/reload-plugins` works without ever touching the cache.

### E.5 v1.0.1 → v1.1.0 reinstall theatre — what was needed vs what we did

**What was actually needed, given directory-source mechanism:** edit source files (skill descriptions, hooks, structural-check) — done. Verify in next subprocess. Could have skipped reinstall entirely.

**What we additionally did that was metadata-only:** bumped `plugin.json:version` 1.0.1 → 1.1.0 (contributor signal per CLAUDE.md version policy; NO runtime effect for directory-source PF). Reinstalled to rename cache subdir `1.0.1/` → `1.1.0/`. Hand-patched `installed_plugins.json` because reinstall created `cache/.../1.1.0/` but registry still pointed at `cache/.../1.0.1/` (deleted) — half-installed state.

**Why `/plugin update` alone didn't yield a working state:** likely the same root-cause class as Issues #14061 / #45834 — `/plugin update` doesn't always sync `installed_plugins.json:version` with the new cache directory. Combined with directory-source's quirk that `marketplace.json:version` (1.0.1) and `plugin.json:version` (1.1.0) are out of sync (we bumped only one; `marketplace.json` still says 1.0.1 in both source and cache), registry resolution gets confused.

**Net theatre:** all SessionStart and skill-description fixes had already taken effect from the moment we saved source files. The reinstall, registry patch, and version bump were entirely cosmetic for runtime. The failed v1.1.0 rebench (0 skill firings, +35% cost, +41% wall, TodoWrite collapse) was measuring source-code changes, not "v1.1.0 cache vs v1.0.1 cache" — those caches contained identical symlinks.

**Inverse implication that deserves emphasis:** every benchmark run between the v1.0.1 and v1.1.0 cache labels was already measuring the latest source. The "v1.0.1 baseline" runs in the rebench data are not the canonical released v1.0.1 — they are whatever the source was at run-time. **This contaminates the baseline-comparison data already collected.**

### E.6 What this would have prevented in PF v1.x (Issue #008)

Issue #008 in `_bench/REVIEW.md` already surfaced live-serving. Researching pre-design would have prevented:
1. **The reinstall theatre.** Saving 1 manual registry edit and the half-installed state.
2. **Incident Table row "Marketplace refresh ≠ plugin reinstall".** Root cause was "we believed reinstall was needed to land content changes." It wasn't.
3. **The `lastUpdated: 2026-04-28T00:00:00.000Z` placeholder.** Hand-set because we didn't trust the auto-update mechanism. With correct mental model: value is informational, registry only needs `installPath` to match cache dir on disk.
4. **Misattributed rebench baseline.** v1.0.1 baseline runs were measuring whatever source state existed at run-time, not canonical 1.0.1.
5. **Wasted version-bump policy framing.** CLAUDE.md mandates bumping `plugin.json:version` on every PR to `core/`/`hooks/`. For directory-source distribution the bump is documentation-only — useful for contributor signal but not runtime. Rule isn't wrong, but framing implies version drives runtime. It doesn't, for the development distribution mode.

### E.7 Implications for v1.2+ design

**Distribution mode for production users:** if PF wants to be installable by users without the source checked out, MUST shift away from `directory` source.
- **`github` source** (SP-style): `/plugin marketplace add atyabrehman/production-framework` and `/plugin install`. Cache becomes real copy at pinned commit. Version bumps DO drive cache invalidation. CLAUDE.md's version-policy rule becomes load-bearing.
- **`git` source** (any URL): same as github but self-hosted. Same caching semantics.
- **Hybrid:** `directory` for development, `github` for users. SP and Vercel both ship as `github` source; only the maintainer uses local checkout.

**CLAUDE.md update needed:** current `## Version policy` conflates "contributor PR discipline" with "runtime cache invalidation." Restructure:
- **Documentation policy:** bump `plugin.json:version` AND `marketplace.json:version` AND `marketplace.json:plugins[0].version` (all three) on every PR to `core/`/`hooks/`. This session bumped only `plugin.json` — the two `marketplace.json` versions still say 1.0.1, which would mislead any github-source consumer.
- **Runtime invalidation:** only github/git-source users need `/plugin update` after a version bump. Directory-source maintainers do not (changes already live).
- **Cache hygiene checklist for github distribution:** per Issues #14061 / #15642 / #29074, plan for users to occasionally need manual cache deletion after a version bump if `/plugin update` fails to invalidate.

**Init-record assertion as new structural-check rule:** per PROJECT-PLAN.md's binding rule "before any plugin-distribution / version / install change, read the init record's `plugins[].path` field and `installed_plugins.json` schema first." Future structural-check could parse `~/.claude/plugins/installed_plugins.json` (when present) and warn if `cache/<m>/<p>/<version>/`, `plugin.json:version`, and `marketplace.json:version` are inconsistent.

**Three-file version sync — latent ship-blocker:** the 1.0.1/1.1.0 mismatch in `marketplace.json` (1.0.1) vs `plugin.json` (1.1.0) is itself a blocker for github distribution. A github-source consumer's `/plugin update` reads `marketplace.json:plugins[0].version: "1.0.1"`, compares against installed-record version, decides nothing newer than 1.0.1 to install. User would never see 1.1.0. **Fixing this is a precondition to switching distribution modes.**

### E.8 Risks / open questions

1. **`scope: "local"` + `projectPath: "Vendor Email Scraping"`.** PF bound to one specific project, not user-global. Sessions started elsewhere (incl. ECA Portal Copy where rebench runs) do NOT load PF via this install record. Rebench appears to load PF directly via the `directory`-source marketplace in `known_marketplaces.json` (user-global). Worth confirming in init record's `plugins[].path` and `enabledPlugins`. If rebench uses marketplace registration directly, the registry-patch we did was even more meaningless than already established.

2. **`/reload-plugins` semantics for directory-marketplace mode.** Confirmed for `--plugin-dir`; not explicitly tested for `directory`-marketplace. Untested risk: if it doesn't fully reload (e.g., skill descriptions cached at session start), rebench between source edits and re-runs may have measured stale state. Lower-priority because rebench runs are fresh subprocesses (`--no-session-persistence`); no in-session reload needed.

3. **`unknown` version label for several official plugins.** In user's registry, frontend-design / context7 / github / playwright / skill-creator all have `version: "unknown"` and `installPath` ending in `/unknown/`. These plugins lack proper `plugin.json:version` — known issue with `claude-plugins-official` structure. PF should NOT adopt this pattern; explicit semver required for version-bump policy to mean anything to github-source consumers.

4. **Symlinks on Windows.** "Cache is symlink farm" relies on Windows developer-mode symlinks or junctions. If user's Windows didn't have developer mode enabled, cache might be a copy with refresh-on-read. Empirically source/cache content matched and source-side edits behave as if live, so symlinking (or reliable copy + auto-refresh path) is in effect; exact mechanism not verified read-only. Doesn't change conclusion (live serving) but matters for cross-platform reproducibility.

5. **Two-cache phenomenon for SP.** SP cache has BOTH `5.0.7/` AND `6efe32c9e2dd/` subdirectories. Suggests Claude Code creates a commit-SHA-named cache dir IN ADDITION to a version-named one for `github` sources. Registry's `installPath` points at `5.0.7/`; `gitCommitSha` matches the SHA-named dir. Implication: github-source caches may double-write. Not relevant for PF's directory mode but documentation-worthy if PF ever ships as github source.

6. **Drive-case inconsistency on Windows.** Both `c:/...` (lowercase drive) in `known_marketplaces.json` and `C:\...` (uppercase) in `installed_plugins.json` appear in the same registry. NTFS is case-insensitive but plugin loader path comparisons (e.g., dedup logic) might string-compare. Latent bug-risk for users with non-canonical drive-case paths. Not currently observed broken.

### Sources
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference) · [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces) · [Plugins](https://code.claude.com/docs/en/plugins) — Claude Code Docs
- anthropics/claude-code Issues: [#28492](https://github.com/anthropics/claude-code/issues/28492) (cache not invalidated on source change), [#14061](https://github.com/anthropics/claude-code/issues/14061) (`/plugin update` doesn't invalidate cache), [#15642](https://github.com/anthropics/claude-code/issues/15642) (CLAUDE_PLUGIN_ROOT stale post-update), [#29074](https://github.com/anthropics/claude-code/issues/29074) (cache not cleared on uninstall/reinstall), [#15369](https://github.com/anthropics/claude-code/issues/15369) (uninstall doesn't clear cached files), [#45834](https://github.com/anthropics/claude-code/issues/45834) (update doesn't sync metadata), [#46081](https://github.com/anthropics/claude-code/issues/46081) (stale marketplace cache reports "already at latest"), [#18174](https://github.com/anthropics/claude-code/issues/18174) (hot-reload feature request), [#11278](https://github.com/anthropics/claude-code/issues/11278) (path resolution uses marketplace.json file path)
- [hesreallyhim/claude-code-json-schema (archived)](https://github.com/hesreallyhim/claude-code-json-schema) — plugin/marketplace schemas only; no installed_plugins.json
- `_bench/REVIEW.md` Issue #008 — empirical observation of live serving from source path
- `~/.claude/plugins/installed_plugins.json` — user's registry, this report's E.2 reference
- `~/.claude/plugins/known_marketplaces.json` — confirms directory-source `installLocation` IS the source path
<!-- END-CATEGORY-E -->

---

## Category F — Sub-agent permission model

<!-- BEGIN-CATEGORY-F -->

**Status:** DONE
**Top finding:** Subagents dispatched via `Agent`/`Task` tool run with their OWN permission scope; the parent's `--dangerously-skip-permissions` flag and the project's `.claude/settings.json` `permissions.allow` rules do NOT propagate. SP works around this by (a) creating `.claude/settings.local.json` per-test with the allow-list pre-populated and (b) launching Claude with `--dangerously-skip-permissions` for headless tests. PF has neither — it has no `.claude/settings.json` at all.

### F.1 Per-query findings

#### Q1 — "Claude Code subagent tool permission inheritance"
The official model has TWO separate inheritance dimensions, and they conflict:

1. **Tool-list inheritance (the `tools:` frontmatter dimension).** From docs.claude.com/en/docs/claude-code/sub-agents (verified via web search; direct WebFetch was blocked, this Researcher session inheriting the same gap): if `tools:` is omitted in the agent frontmatter, the subagent inherits ALL tools from the parent session except those listed in `disallowedTools`. PF's `agents/builder.md:1-6` has no `tools:` frontmatter (verified `c:/Users/atyab/Experimental - Users/production-framework/agents/builder.md:1-6`) — so Builders DO have access to the Bash/PowerShell tools as functions.
2. **Permission-rule inheritance (the `.claude/settings.json` `permissions.allow` dimension).** This is broken/ambiguous and is the actual cause of OF-5. See Q3.

The two are commonly confused. "Subagent has Bash tool access" ≠ "subagent's Bash invocations are pre-approved against the project allow-list."

#### Q2 — "Agent tool background mode permission denied silent"
Issue #40241 [github.com/anthropics/claude-code/issues/40241] is the direct match: "`--dangerously-skip-permissions` does not propagate to subagents (Agent tool)" — opened 2026-03-28. Reporter tested 14 Edit/Write calls across 8 files inside a subagent, all 14 prompted for permission despite the parent session running with `--dangerously-skip-permissions`. macOS, area tags `agents` + `permissions`. This is the v1.x mechanism behind OF-5 verbatim.

Issue #28584: "Subagents prompt for permission on every tool call starting v2.1.56" — REGRESSION in 2.1.56 where subagents stopped inheriting parent's auto-approved permission state. Read/Glob/Grep/Bash all re-prompt. In headless mode (no human to approve), these prompts manifest as "denied" silently, exactly matching what the 4 Builders reported this session.

#### Q3 — ".claude/settings.json subagent vs parent agent scope"
Issue #18950: "Skills/subagents do not inherit user-level permissions from settings.json" — opened 2026-01-18. Direct quote (paraphrased from search index): user-level `~/.claude/settings.json` `permissions.allow` rules are NOT inherited by skills/subagents; commands auto-approved in the parent are re-prompted inside subagents.

Issue #25000: "Sub-agents bypass permission DENY rules" — security inversion. A single Task-tool launch approval allowed 22+ subagent bash commands without per-command approval, AND deny rules in `settings.local.json` were bypassed. This proves the inheritance is asymmetric: deny rules don't block (security risk), allow rules don't permit (the OF-5 productivity gap).

Settings hierarchy (from update-config skill text, `pf-rep2-user-prompts.txt:185-192`): user → project → local. But this hierarchy applies WITHIN a session — it does not cross the parent→subagent boundary in either direction reliably.

#### Q4 — "sub-agent bash powershell denied background non-interactive"
Issue #28584 (above) and Issue #24073 ("Teammates spawned in Delegate Mode lose tool access despite `mode: bypassPermissions`") together establish: when there is no human to approve at the prompt, ANY tool call that would have prompted simply fails. The Task tool's `mode: bypassPermissions` parameter is overridden by the lead's session state — `effective_permissions = min(mode_param, lead_session_state)` — so dispatching a Builder with elevated permissions doesn't work either.

Background dispatch makes this UX-invisible: Bash returns "denied" and the subagent's transcript shows it as a tool error, with no surfaced approval prompt anywhere. This is the exact OF-5 symptom.

#### Q5 — "Claude Code allow-list per-subagent vs per-session"
Issue #20264 (FEATURE request): "Allow restrictive permission modes for subagents even when parent uses `bypassPermissions`" — confirms the asymmetric model: `bypassPermissions` always cascades down (cannot be made stricter for a child), but standard `allow` rules do NOT cascade down. The platform's own design treats per-subagent permissions as a future feature, not a present capability.

Per-session allow-listing (the `--allowed-tools` CLI flag) propagates differently than `.claude/settings.json` allow rules. The SP test harness (`tests/subagent-driven-dev/run-test.sh:78`) uses `--dangerously-skip-permissions` precisely because `--allowed-tools` is not reliable for subagent inheritance either.

### F.2 SP subagent dispatch mechanism (Task vs Skill vs Bash) — file:line evidence

**Mechanism:** SP dispatches subagents via the **`Task` tool**, not the Skill tool, not Bash. Evidence:

- `superpowers/5.0.7/skills/dispatching-parallel-agents/SKILL.md:67-74`: code example shows `Task("Fix agent-tool-abort.test.ts failures") / Task(...) / Task(...)` — three parallel Task-tool calls. Confirmed Task-tool dispatch, not Skill-tool.
- `superpowers/5.0.7/skills/subagent-driven-development/implementer-prompt.md:6-7`: "Task tool (general-purpose): description: 'Implement Task N: [task name]' / prompt: |" — the implementer subagent template explicitly invokes the Task tool with `general-purpose` subagent_type.
- `superpowers/5.0.7/skills/subagent-driven-development/spec-reviewer-prompt.md:8-10`: same pattern — Task tool, general-purpose subagent_type.
- The `Skill` tool in SP is for invoking skills WITHIN a session (e.g., `superpowers:subagent-driven-development` itself); it does not spawn an isolated agent. The skill's body then issues `Task(...)` calls to spawn subagents. PF's pattern is identical at this layer.

**Permission model SP subagents inherit:**
- Per `tests/subagent-driven-dev/run-test.sh:74-78` (verbatim comment): `# --dangerously-skip-permissions for automated testing (subagents don't inherit parent settings)` — SP MAINTAINERS DOCUMENT THE GAP IN A COMMENT. They use `--dangerously-skip-permissions` in headless tests as the workaround.
- For non-headless / interactive use, SP relies on `tests/subagent-driven-dev/svelte-todo/scaffold.sh:23-37`: each test scaffolds a `.claude/settings.local.json` with explicit `permissions.allow` for `Read(**) / Edit(**) / Write(**) / Bash(npm:*) / Bash(npx:*) / Bash(mkdir:*) / Bash(git:*)`. Per `docs/testing.md:189-196`: "Permission Errors: Use `--permission-mode bypassPermissions` flag, Use `--add-dir /path/to/temp/dir`."
- Per `tests/claude-code/test-subagent-driven-development-integration.sh:152`: `claude -p "$PROMPT" --allowed-tools=all --add-dir "$TEST_PROJECT" --permission-mode bypassPermissions` — the integration test uses ALL THREE flags (`--allowed-tools=all`, `--add-dir`, `--permission-mode bypassPermissions`) because no single one suffices.

**Conclusion (BINDING per U-AP-4 with N=1 because SP is the only directly-comparable enterprise-grade harness in the cache, with corroborating evidence from 6 GitHub issues):** SP dispatches subagents via Task tool, accepts the inheritance gap as a platform reality, and works around it via per-project `.claude/settings.local.json` (interactive) or `--dangerously-skip-permissions` (headless).

### F.3 settings.json hierarchy + scope rules

From `update-config` skill body (canonical text in `pf-rep2-user-prompts.txt:181-192`):

| File | Scope | Git | Use For |
|------|-------|-----|---------|
| `~/.claude/settings.json` | Global | N/A | Personal preferences for all projects |
| `.claude/settings.json` | Project | Commit | Team-wide hooks, permissions, plugins |
| `.claude/settings.local.json` | Project | Gitignore | Personal overrides for this project |

Load order: user → project → local (later overrides earlier). Each layer can declare `permissions.allow / deny / ask / defaultMode / additionalDirectories`.

**Scope rule for subagents (per Issues #18950, #27661, #28584, #40241):** ALL THREE LAYERS apply to the parent session. Whether they apply to subagents is currently unreliable: `bypassPermissions` mode cascades; `permissions.allow` rules do NOT cascade reliably; deny rules sometimes cascade, sometimes don't (Issue #25000).

The schema field `additionalDirectories` (`pf-rep2-user-prompts.txt:202`) does cross to subagents per docs but is read-scoped only.

### F.4 Background vs interactive mode permission differences

Interactive mode: when a subagent's tool call hits a permission rule it doesn't satisfy, Claude Code surfaces an approval prompt to the human. Human says yes → tool runs. This is what makes OF-5 invisible in interactive testing.

Background / headless / non-interactive mode (the `Agent` tool in PF, `--print` / `-p` flag in SP, any background dispatch): NO HUMAN to approve. The permission system has three configured behaviors:
1. If invoked with `--permission-mode bypassPermissions` or `--dangerously-skip-permissions`: tool runs without prompt.
2. If the call matches a `permissions.allow` rule: tool runs (BUT — per Issues #18950/#28584 — this allow rule is not reliably inherited by subagents in v2.1.56+).
3. Otherwise: tool fails silently with "denied" in the transcript. No approval prompt is recorded because there's no human to show it to.

This is precisely the OF-5 symptom: "All 4 Builders this session reported 'denied'; deputy ran verification instead." The Builders, dispatched via the parent's `Agent` tool with no `.claude/settings.json` in the project AND no `--dangerously-skip-permissions` propagation, hit branch (3) on every Bash/PowerShell call.

### F.5 What this would have prevented in PF v1.x (OF-5)

Two complementary fixes (either alone is sufficient; both together are belt-and-braces):

**Fix A — Project-level `.claude/settings.json`.** PF currently has NO `.claude/settings.json` at the project root (verified: `ls -la c:/Users/atyab/Experimental - Users/production-framework/.claude` shows only `agent-memory/`, no settings.json). Creating it with `permissions.allow` for the verification-class commands (bash test runners, structural-check, jq, git status, ripgrep, glob) would have given the 4 Builders authority to run their own verification. **Caveat from research:** Issues #18950 / #28584 indicate that settings.json `permissions.allow` rules are NOT reliably inherited by Task-tool-spawned subagents on v2.1.56+. So Fix A may not work without Fix B.

**Fix B — Adopt SP's headless workaround verbatim.** When dispatching Builder subagents in non-interactive contexts, the harness must run with `--dangerously-skip-permissions` (or `--permission-mode bypassPermissions`). This is what SP does in every headless test (`run-test.sh:78`, `test-subagent-driven-development-integration.sh:152`). The SP team's own comment "subagents don't inherit parent settings" is the canonical acknowledgment.

**Fix C — Adopt the deputy-runs-verification pattern as policy** (already considered in OF-5 resolution path). This is a behavior-level workaround that sidesteps the permission gap entirely by relegating Bash/PowerShell to the parent session that has full permissions. Trade-off: deputy becomes a serial bottleneck for verification across N parallel Builders. SP does NOT use this pattern; SP grants subagents the permissions and lets them self-verify.

### F.6 Implications for v1.2+ design

Read-only research per task brief. The SP-comparison literature surfaces these levers (any subset is on the table — deciding which is OUT OF SCOPE for this Researcher):

1. **`.claude/settings.json` patch at project root.** Add `permissions.allow` block with the verification command set. Note the v2.1.56+ caveat — must be tested empirically; SP doesn't rely on this alone.

2. **Headless dispatch flag policy.** Document that any `Agent`-tool dispatch in PF must propagate `--dangerously-skip-permissions` or `--permission-mode bypassPermissions`. SP does this in every test harness. Open question: how does PF's `Agent` tool wrapper expose this — does the dispatching harness even have access to set it?

3. **Skills-only dispatch.** Switch from `Agent`-tool subagent dispatch to in-session skill invocation (the `Skill` tool). Skills run in the parent's permission scope, so they inherit allow-list. Trade-off: loses context isolation, the explicit reason SP and PF chose subagents in the first place (per `dispatching-parallel-agents/SKILL.md:9-11` — "They should never inherit your session's context or history").

4. **Hybrid: skill-bodies that prepare prompts + parent runs verification.** Effectively the deputy-runs-verification pattern formalized as architecture. Matches PF's actual v1.x behavior.

5. **`agents/{name}.md` frontmatter `tools:` field.** Currently absent from PF's agent files. Per the docs and Issue #6005: this is an allowlist of tool NAMES, not Bash command patterns — so it controls which TOOLS the subagent can call (e.g., "Bash + Read + Edit but no WebFetch") but does NOT solve the Bash-command allowlist problem. NOT a fix for OF-5.

6. **`hooks/` PreToolUse hook auto-approving Bash for verification commands.** Issue #40241 reporter notes this as a workaround but flags it as dangerous because the hook applies project-wide. Not recommended.

The dominant pattern in the SP comparison: combine #1 (settings.json at project root) for interactive sessions + #2 (headless flag) for background dispatch. The SP maintainers do NOT use #3, #4, or #6. They DO use #1+#2 together.

### F.7 Risks / open questions

- **Empirical untested:** Whether a PF `.claude/settings.json` with `permissions.allow` would actually be inherited by Builder subagents on the user's CC version (per Issues #18950/#28584, v2.1.56+ may not inherit). PF has no `.claude/settings.json` to test against — Deputy should test on a single fixture before rolling out.
- **CC version drift:** Issues #28584 and #40241 are open as of 2026-03/04; behavior may change. Any v1.2+ design that relies on inheritance behavior should pin to the version it was tested against.
- **Headless flag ergonomics:** if PF's `Agent` tool dispatch is invoked from inside the model rather than from a bash harness, the model may not have a way to set `--dangerously-skip-permissions` on the spawn. Open question for whoever owns the dispatch wrapper.
- **The deny-rule security inversion (Issue #25000):** if PF starts relying on `.claude/settings.json` for safety (e.g., deny `Bash(rm -rf *)`), subagents may bypass those denies. The `permissions.allow` mechanism is one-way unsafe: not relied-upon for granting (because not inherited), but also not relied-upon for blocking (because bypassed). This is Anthropic's bug, not PF's, but PF should document it.
- **Inconsistency with OF-6:** sub-agent dispatched via `Agent` tool seeing different system reminders (the `.md` summary write block) suggests PF's `Agent` tool may be wired differently than CC's standard Task tool. If PF is using a non-standard wrapper, the inheritance findings above may apply differently. Worth verifying which API call PF's Agent tool actually issues.

### Sources

- `superpowers/5.0.7/skills/subagent-driven-development/SKILL.md` (read in full)
- `superpowers/5.0.7/skills/subagent-driven-development/implementer-prompt.md:6-7` (Task-tool dispatch pattern)
- `superpowers/5.0.7/skills/subagent-driven-development/spec-reviewer-prompt.md:8-10`
- `superpowers/5.0.7/skills/dispatching-parallel-agents/SKILL.md:67-74` (Task() parallel example)
- `superpowers/5.0.7/tests/subagent-driven-dev/run-test.sh:74-78` (verbatim comment "subagents don't inherit parent settings")
- `superpowers/5.0.7/tests/subagent-driven-dev/svelte-todo/scaffold.sh:23-37` (`.claude/settings.local.json` template)
- `superpowers/5.0.7/tests/claude-code/test-subagent-driven-development-integration.sh:152` (`--allowed-tools=all --add-dir --permission-mode bypassPermissions`)
- `superpowers/5.0.7/docs/testing.md:189-196, 256-263` (permission-error troubleshooting recipe)
- github.com/anthropics/claude-code/issues/40241 — `--dangerously-skip-permissions` does not propagate to subagents (2026-03-28)
- github.com/anthropics/claude-code/issues/28584 — Subagents prompt for permission on every tool call starting v2.1.56
- github.com/anthropics/claude-code/issues/27661 — Subagents should inherit parent session hooks and permission rules (2026-02-22)
- github.com/anthropics/claude-code/issues/25000 — Sub-agents bypass permission deny rules (security risk)
- github.com/anthropics/claude-code/issues/24073 — Teammates lose tool access despite `mode: bypassPermissions`
- github.com/anthropics/claude-code/issues/20264 — FEATURE: restrictive permission modes for subagents
- github.com/anthropics/claude-code/issues/18950 — Skills/subagents do not inherit user-level permissions from settings.json (2026-01-18)
- github.com/anthropics/claude-code/issues/14714 — Subagents (Task tool) don't inherit parent conversation's allowed tools
- github.com/anthropics/claude-code/issues/6005 — Feature request: `disallowed-tools` in subagent frontmatter (closed not-planned, partial-implementation in changelog)
- docs.claude.com/en/docs/claude-code/sub-agents — Create custom subagents (subagent inheritance model; accessed via web search index, direct WebFetch denied this Researcher session — same OF-5 phenomenon recursing)
- docs.claude.com/en/docs/claude-code/permission-modes — Choose a permission mode
- `c:/Users/atyab/Experimental - Users/production-framework/agents/builder.md:1-6` (no `tools:` frontmatter)
- `c:/Users/atyab/Experimental - Users/production-framework/.claude/` (only `agent-memory/`; no `settings.json`)
- `c:/Users/atyab/Experimental - Users/production-framework/.tmp/pf-rep2-user-prompts.txt:181-192` (settings.json hierarchy table from `update-config` skill)
<!-- END-CATEGORY-F -->

---

## Category G — Skill / agent description writing — what actually triggers vs what doesn't

<!-- BEGIN-CATEGORY-G -->
**Scope reminder:** Cat A covers *how* Claude Code routes. This category (G) covers *how to write the description text* so routing succeeds. Issue #005 (`docs/research-issue-005-skill-descriptions.md`) already established the N/N=16/16 binding 5-point pattern. Below mines what SP's own `writing-skills` corpus teaches authors — three companion docs (`anthropic-best-practices.md`, `persuasion-principles.md`, `testing-skills-with-subagents.md`) plus the SKILL.md itself — and contrasts that against PF's current `skills/writing-skills/SKILL.md` (post-bundle).

### G.1 Per-query findings

**G.1.1 — `SP superpowers SKILL.md description binding pattern teardown`**

SP's `writing-skills/SKILL.md` lines 96–103 codify description rules verbatim: required frontmatter `name` + `description` (max 1024 chars total); `name` letters/numbers/hyphens only; `description` is third-person, describes ONLY *when to use* not *what it does*, starts with "Use when...", "NEVER summarize the skill's process or workflow", keep under 500 chars if possible.

Lines 144–172 ("Claude Search Optimization") provide the most binding teardown SP gives any author. Two ✅ examples and three ❌ examples are presented as a typed contrast set:
- ❌ `Use when executing plans - dispatches subagent per task with code review between tasks` — workflow summary.
- ❌ `Use for TDD - write test first, watch it fail, write minimal code, refactor` — process detail.
- ✅ `Use when executing implementation plans with independent tasks in the current session` — pure trigger.
- ✅ `Use when implementing any feature or bugfix, before writing implementation code` — pure trigger.

Empirical claim attached: "Testing revealed that when a description summarizes the skill's workflow, Claude may follow the description instead of reading the full skill content. A description saying 'code review between tasks' caused Claude to do ONE review, even though the skill's flowchart clearly showed TWO reviews." Strongest known attestation that workflow leak in a description is operationally harmful, not merely stylistically wrong.

**G.1.2 — `Anthropic best practices skill description format companion`**

`anthropic-best-practices.md` lines 186–219 differs subtly from SP: Anthropic teaches `description` should include **both** what the skill does AND when to use it.

> "The `description` field enables Skill discovery and should include both what the Skill does and when to use it." (line 187)
> "Each Skill has exactly one description field. The description is critical for skill selection: Claude uses it to choose the right Skill from potentially 100+ available Skills." (line 199)

Three positive examples (lines 205–219): PDF, Excel, git commit — all `<capability sentence>. Use when X, Y, or Z.` This is **DIVERGENT** from SP's R4 ("describe ONLY when to use, NOT what it does").

**Resolution:** SP optimizes for *discipline-enforcing* skills where workflow leak causes the model to skip the body. Anthropic's general advice optimizes for *reference/capability* skills where the model needs to know what's offered. PF entry-points are mostly the SP type.

**G.1.3 — `"Use when" "before any" trigger phrasing skill auto-fire`**

SP's strongest-firing descriptions use **temporal/sequential anchors**: "before any creative work" (`brainstorming`), "before writing implementation code" (`test-driven-development`), "before committing or creating PRs" (`verification-before-completion`), "before proposing fixes" (`systematic-debugging`). Pattern: `Use when [observable user-task] + before [observable next step]`. Each clause detectable from conversation surface, not internal state.

**G.1.4 — `why skill descriptions fail to trigger model`**

SP's SKILL.md lines 153–158 names the failure mode. Two failure classes:
1. **Trigger miss** — description doesn't match user task surface (PF #005 found this in 8/11 entry-points).
2. **Body skip** — description summarizes workflow, model treats it as the spec, skips body.

PF #005 only tested the first. SP teaches the second is equally damaging. (2) is more pernicious because it produces *plausibly wrong* output rather than *no output*.

**G.1.5 — `imperative vs declarative skill description pattern matching`**

SP does NOT mandate imperative voice. Only `brainstorming` uses second-person imperative; all 13 other SP descriptions use third-person `Use when…`. `persuasion-principles.md` provides the rationale: imperative voice is one of seven Cialdini principles (Authority), and it applies to discipline-enforcing skills' **body** content, not the description. PF #005 already concluded "the binding lever is trigger phrasing, not voice" with N=15/16. SP's corpus confirms this.

**Cross-reference to Cat A:** Anthropic's official `skill-creator` doc says descriptions should be "pushy" with `MUST BE USED` / `PROACTIVELY` keywords. Reconciliation: those are **sub-agent-description** keywords (different config surface), not skill-description keywords. Conflating the two is a common source of mis-formatted descriptions.

**G.1.6 — `project-internal jargon in skill description anti-pattern`**

`anthropic-best-practices.md` lines 821–822: metadata is "particularly critical… Claude uses these when deciding whether to trigger the Skill in response to the current task." Implicit constraint: description must be resolvable from the user's conversation alone. References to `STACK-PATTERNS.md` or `Tier 3 Step 1` are invisible to the model on cold task arrival. SP avoids this by using universal concepts: "implementation plans", "creative work", "feature or bugfix", "tests are flaky".

**G.1.7 — `"workflow leak" skill description Claude Code`**

Term "workflow leak" is PF-coined. The concept is SP-attested as "summarizes workflow" (SKILL.md line 153). SP's anecdote is the deeper *why*: the model will obey the description instead of the body. PF's current rule names symptoms but not the mechanism.

---

### G.2 SP `writing-skills` corpus — verbatim rules + companion-doc citations

| # | Rule | Source | Citation |
|---|---|---|---|
| R1 | Description: third-person | SKILL.md | Line 99 |
| R2 | Description: starts with "Use when..." | SKILL.md | Line 100 |
| R3 | Description: includes specific symptoms/situations/contexts | SKILL.md | Line 101 |
| R4 | Description: NEVER summarize the skill's process or workflow | SKILL.md | Line 102 (caps in original) |
| R5 | Description: keep under 500 chars if possible (max 1024) | SKILL.md | Line 103 |
| R6 | Bad pattern: "Use when executing plans - dispatches subagent per task with code review between tasks" | SKILL.md | Lines 161–162 |
| R7 | Operational harm of workflow leak: model follows description as spec, skips body | SKILL.md | Lines 153–158 ("ONE review instead of TWO") |
| R8 | Description: technology-agnostic unless skill itself is technology-specific | SKILL.md | Lines 178–180 |
| R9 | Keyword coverage: error messages, symptoms, synonyms, tools | SKILL.md | Lines 199–204 |
| R10 | Naming: active voice, verb-first, gerunds for processes | SKILL.md | Lines 207–212, 274–276 |
| R11 | Token budget: getting-started <150 words, frequently-loaded <200 words, others <500 words | SKILL.md | Lines 218–221 |
| R12 | Cross-reference other skills by NAME with explicit requirement marker, not by `@` path | SKILL.md | Lines 282–289 |
| R13 | Update CSO with violation symptoms — symptoms-of-about-to-violate pattern | SKILL.md | Lines 525–531 |
| R14 | Description = `<capability sentence>. Use when <enumerated triggers>.` (Anthropic, divergent from SP-internal R4) | anthropic-best-practices.md | Lines 187, 205–219 |
| R15 | Description third-person; warning against first-person "I can help you…" | anthropic-best-practices.md | Lines 188–195 |
| R16 | Specificity: include key terms; vague names ("Helper", "Utils", "Tools") rejected | anthropic-best-practices.md | Lines 174, 196–199 |
| R17 | Metadata pre-loaded at startup; SKILL.md only when relevant — every word competes against 100+ skills | anthropic-best-practices.md | Lines 13–28, 199, 821 |
| R18 | Imperative voice for discipline-enforcing skills' BODY, not the description | persuasion-principles.md | Lines 13–28, 128–134 |
| R19 | "Implementation intentions" research — "When X, do Y" more effective than "generally do Y" | persuasion-principles.md | Lines 142–144 |
| R20 | LLMs are parahuman — Cialdini 7-principle compliance research validates description+body design | persuasion-principles.md | Lines 145–151, 167–177 |
| R21 | Test descriptions with pressure scenarios — RED phase reveals if description fires | testing-skills-with-subagents.md | Lines 43–82 |
| R22 | "Update description" as REFACTOR-phase action — add "symptoms of ABOUT to violate" | testing-skills-with-subagents.md | Lines 220–227 |

**Companion-doc roles:**
- `anthropic-best-practices.md` — official Anthropic guidance, broader scope (capability + reference + discipline). R14–R17 slightly diverge from SP-internal R4.
- `persuasion-principles.md` — research foundation for *why* discipline-skill bodies use imperative voice; description-field stays third-person.
- `testing-skills-with-subagents.md` — RED-GREEN-REFACTOR for descriptions; update-description is an explicit REFACTOR move (R22).

---

### G.3 PF current state — what `skills/writing-skills/SKILL.md` covers (post-bundle, 2026-04-28)

PF's body (120 lines) covers required body sections, frontmatter rules, length target 80–200 lines, composability by name not file path, HARD-GATE markers, registration, and the **Description trigger pattern (BINDING per U-AP-4)** (lines 94–110): the 5-point N/N=16/16 rule from issue #005 — (1) Imperative or "Use when…" opener, (2) observable user-task / symptom / time-relation trigger not internal state, (3) ≥2 trigger contexts enumerated, (4) zero workflow leak, (5) zero project-internal jargon.

PF has NOT integrated:
- The empirical "ONE review instead of TWO" anecdote (R7) — most persuasive evidence that workflow leak is operationally harmful.
- Token budget targets (R11): SP's <150/200/500-word tiers.
- Keyword coverage discipline (R9).
- Active-voice/gerund naming (R10).
- `**REQUIRED SUB-SKILL:**` marker syntax (R12 full form).
- RED-GREEN-REFACTOR for skills (R21–R22): no testing methodology.
- Persuasion-principles research foundation (R18–R20): conclusion present, mechanism absent.
- Anthropic's divergent capability+use-when pattern (R14): no carve-out for capability/reference skills.
- "Update description" as a REFACTOR move (R22).

---

### G.4 Diff — what SP teaches that PF doesn't

| SP rule | PF coverage | Severity |
|---|---|---|
| R7 — workflow-leak mechanism (description hijacks body) | Symptom-level only; mechanism absent | **CRITICAL** |
| R21–R22 — RED-GREEN-REFACTOR test methodology for descriptions | None — descriptions write-once at PR time | **CRITICAL** |
| R11 — token budget tiers (<150/200/500 words) | None for description | **HIGH** |
| R14 — capability+use-when for non-discipline skills | None — SP-style universally binding | **MEDIUM** |
| R18–R20 — Cialdini foundation for voice separation | Conclusion present, mechanism absent | **MEDIUM** |
| R12 (full form) — `**REQUIRED SUB-SKILL:**` markers | Composability mentioned, marker syntax absent | **LOW** |
| R10 — gerund naming for processes | None | **LOW** |

**Coverage agreements:** "Use when..." opener, third-person voice, 1024-char limit, observable trigger, enumerated contexts, no project-internal jargon, composability by name.

**Coverage divergences (PF stricter):** PF point 3 (≥2 contexts quantified — SP doesn't); `check_skill_description_no_jargon` mechanical check (SP has no analogue); HARD-GATE markers (no SP equivalent).

---

### G.5 What this would have prevented in PF v1.x

If SP's three companion docs had been studied during the v1.0 design phase:

1. **Issue #005 would not have existed.** SP's R7 + R6 name the exact failure mode that 8/11 PF entry-point descriptions exhibited.
2. **Tier-jargon descriptions would never have shipped.** R3 + R8 + Anthropic's example set make "Use at Tier 3 Step 1 when producing the module-level architecture doc" structurally impossible to write.
3. **`writing-arch-doc`'s "TL;DR is load-bearing" leak would have been caught at PR.** R4 + R7 forbid summarizing implementation invariants.
4. **`tier-selection`'s "Reads CONFIG.yaml triggers. Deterministic, not judgment-based." would have been caught.** Direct R6 violation.
5. **`check_skill_description_no_jargon` could have been one of the first hooks shipped, not a v1.2 retrofit.** SP's typed bad/good contrast set is mechanically grep-able.
6. **The 9-skill bootstrap-load would have been validated against SP's 13-skill cold-discovery set early.**
7. **A skill-description test methodology (R21–R22) would have been part of `writing-skills` from v1.0.** Issue #005 a per-PR test, not a half-year-after audit.

---

### G.6 Implications for v1.2+ design

**Recommendation A (HIGH) — port SP's three companion docs into PF.**
Create alongside `skills/writing-skills/SKILL.md`:
1. `skills/writing-skills/anthropic-best-practices.md` — verbatim or cite-by-reference. Provides Anthropic's capability+use-when pattern (R14–R17) as carve-out.
2. `skills/writing-skills/persuasion-principles.md` — Cialdini foundation. Self-justifies "don't default-second-personify" rule.
3. `skills/writing-skills/testing-skills-with-subagents.md` — RED-GREEN-REFACTOR for descriptions, adapted to PF's `subagent-driven-development` primitive.

**Recommendation B (HIGH) — add R7 (workflow-leak hijacks body) to PF Common Mistakes.**
> **Workflow leak in description hijacks the body.** When the description summarizes the skill's process, the model treats it as the spec and skips reading the body. Documented in superpowers `writing-skills/SKILL.md` lines 153–158: "code review between tasks" caused the model to do ONE review even though the body required TWO. Fix: description tells **when**; body tells **how**.

**Recommendation C (MEDIUM) — add description token budget.**
`description` ≤80 words for entry-point skills, ≤120 words for others, hard cap 1024 chars. (Source: SP `writing-skills/SKILL.md` lines 218–221, adapted.)

**Recommendation D (MEDIUM) — codify SP-vs-Anthropic divergence as skill-type carve-out.**
> **Skill-type carve-out:** For *capability/reference* skills, Anthropic's pattern applies: `<capability sentence>. Use when <enumerated triggers>.` See `anthropic-best-practices.md` examples. For *discipline-enforcing* skills (most PF entry-points), the SP pure-trigger pattern is binding — no capability sentence.

**Recommendation E (HIGH) — add a per-PR description test.**
> **Pre-merge:** dispatch a subagent (via `subagent-driven-development`) on a representative cold-start prompt; observe whether the skill auto-fires; if not, revise and re-dispatch. Document test prompt and firing outcome in PR description.

**Recommendation F (LOW) — add R10 active-voice naming convention.**
> `name` uses active voice / verb-first / gerund form for processes. Existing skill names grandfathered.

PF currently has the inconsistency `parallel-dispatch` (noun-first) vs. `writing-plan` (gerund).

---

### G.7 Risks / open questions

1. **License risk if porting SP companion docs verbatim.** SP is GPL-3.0 (not verified). Cite-by-reference avoids the question.
2. **Anthropic vs SP divergence (R14 vs R4) creates a maintenance question.** Cite-by-reference (URL) for `anthropic-best-practices.md` rather than copy. SP snapshot is stable; Anthropic's docs are not.
3. **Recommendation E doubles PR effort.** Mitigation: only require for entry-point skills.
4. **R7 is from a single SP-internal anecdote.** No N≥3 cross-plugin replication. Treat as STRONG (1/1 from SP) rather than BINDING until at least one more reference plugin replicates the claim.
5. **Recommendation C may conflict with R3 (enumeration) for skills covering many trigger contexts.** Some skills legitimately have 4–6 trigger contexts (e.g., systematic-debugging). 80-word cap may be too strict; raise to 120 if enumeration density requires it.
6. **PF's "BINDING per U-AP-4" framing may be over-specified.** U-AP-4 = N≥5 cross-source consensus. Issue #005's N=16/16 was 16 *skill descriptions* across 3 *plugins*. Strict reading gives N=3. Worth re-stating as "N=16 skill samples across N=3 reference plugins."
7. **No empirical test of PF's revised descriptions yet.** Issue #005 derived the pattern but has not measured whether PF's *rewritten* descriptions auto-fire reliably.
8. **Anthropic's "pushy" / `MUST BE USED` / `PROACTIVELY` guidance (Cat A) needs explicit reconciliation.** That guidance is for sub-agent definitions, not skill descriptions. Disambiguator needed in `writing-skills/SKILL.md`.
<!-- END-CATEGORY-G -->

---

## Category H — Hook contract / payload schema

<!-- BEGIN-CATEGORY-H -->

### H.1 Per-query findings + per-hook-event schema requirements

The Claude Code hooks reference (`docs.claude.com/en/docs/claude-code/hooks`) and the community-maintained schema gist define a **strictly typed, per-event JSON output contract**. The contract is *not uniform* across the 9 hook events. PF's #001 bug was a single instance of a class that exists for every event we emit JSON for.

**The five queries (verbatim from PROJECT-PLAN §H) produced these answers:**

**Q1 — `Claude Code SessionStart hook hookEventName required field`.** Confirmed. SessionStart's documented shape is:
```json
{ "hookSpecificOutput": { "hookEventName": "SessionStart", "additionalContext": "..." } }
```
Missing `hookEventName` → harness logs `Hook JSON output validation failed — hookSpecificOutput is missing required field "hookEventName"` and emits `exit_code:1, outcome:error`. The script's own exit code is irrelevant; the harness validates the JSON *after* the script exits and silently drops the payload. (Issue #13650 — "SessionStart hook stdout silently dropped despite valid JSON output and exit code 0" — is the exact failure pattern PF #001 lived through, modulo the JSON not being valid against the schema.)

**Q2 — `"hookSpecificOutput" "hookEventName" schema CC 2.1.119`.** Confirmed in PF v2 transcript line 2 (cited verbatim in `docs/diagnosis-skills-not-firing.md` §2.1) — the harness rejects on the field. The CC version cited in PF's own diagnosis was 2.1.119; the requirement has only become *more* strict since (Issue #22031 documents that the public schema reference was incomplete — SessionStart wasn't even listed as supporting `hookSpecificOutput` until late 2025, even though it always required `hookEventName`).

**Q3 — `Claude Code hook JSON payload schema validation`.** The harness validates each hook's stdout against an event-specific JSON schema. Validation failure → `exit_code:1, outcome:error` recorded in transcript; *script's own exit code is overridden*. There is no script-side signal of validation failure. The `claude-code-hooks-schemas` gist (FrancisBourre) and Issue #19115 ("Conflicting JSON Response Schemas for Hook Events PreToolUse vs PostToolUse") confirm the schemas diverge.

**Q4 — `SessionStart hook silent rejection exit_code 1 outcome error`.** Identical pattern in Issue #13650, #16538 ("Plugin SessionStart hooks don't surface hookSpecificOutput.additionalContext"), and PF's own #001. All three: script exits 0, JSON looks valid to the script author, harness rejects post-exec. Pattern is **silent at the script layer, observable only in the transcript JSONL**.

**Q5 — `hook contract Claude Code payload escape pipeline`.** Documented escape footguns: literal `\n` sequences vs real newlines (PF's pre-fix sed/awk pipeline produced the former; jq produces the latter); double-quote escaping; the 10,000-char `additionalContext` cap (any hook output beyond that is silently truncated). PF's session-start fix (jq-based `emit_claudecode_payload`) addresses the escape side; the schema test (`session-start-schema.test.sh` assertion 5) catches the literal-`\n` regression.

---

**Per-hook-event schema requirements (consensus N/N from docs + gist + issues):**

| Event | `hookSpecificOutput.hookEventName` | Top-level fields | Notes / sources |
|---|---|---|---|
| `SessionStart` | **REQUIRED** = `"SessionStart"` | `additionalContext` only via `hookSpecificOutput` | Issue #22031 (schema doc gap fixed late 2025); PF #001 |
| `UserPromptSubmit` | **REQUIRED** = `"UserPromptSubmit"` | `additionalContext` via `hookSpecificOutput` | docs.claude.com/hooks |
| `PreToolUse` | **REQUIRED** = `"PreToolUse"` (when emitting JSON) | `permissionDecision` (allow/deny/ask), `permissionDecisionReason` | Issue #19115; gist |
| `PostToolUse` | **REQUIRED** = `"PostToolUse"` (when emitting JSON) | `additionalContext`, `updatedToolOutput` | Issue #24788, #32105 |
| `Stop` | **NOT USED** (top-level only) | `decision: "block"`, `reason: "..."` | **Issue #15485 — Stop hooks do NOT use `hookSpecificOutput` at all** |
| `SubagentStop` | NOT USED (top-level only) | `decision`, `reason` | Issue #15485 (same as Stop) |
| `PreCompact` | (no hookSpecificOutput documented) | `continue`, `stopReason`, `suppressOutput` (common) | docs.claude.com/hooks |
| `Notification` | (no hookSpecificOutput documented) | common fields only | docs.claude.com/hooks |
| `SessionEnd` | (input only — no output schema for context injection) | common fields only | docs.claude.com/hooks |

**Critical asymmetry:** Stop / SubagentStop use a *different* shape (top-level `decision`/`reason`) than the other six events (`hookSpecificOutput.hookEventName` + event-specific fields). This is a #001-class trap in reverse: a Stop hook that emits `hookSpecificOutput.hookEventName: "Stop"` would be accepted by the schema validator (the field is permitted) but the `decision` block command would be silently *ignored* because Stop's control flow is parsed from top-level fields only.

**Universal exit-code semantics (apply to all 9 events):**
- `exit 0` → allow / silent success (any stdout that *isn't* valid event JSON is treated as informational, not surfaced to the model)
- `exit 1` → "non-blocking error" — Claude Code logs `<hook>:<tool> hook error` in transcript but **proceeds with the tool call anyway** (Issue #21988, #4809)
- `exit 2` → block + surface stderr first-line to the model (PreToolUse only effective; Stop only effective when registered, with caveats per Issue #10412 for plugin-installed Stop hooks)

---

### H.2 PF's 5 hooks — current emit shape vs required schema

| PF hook | CC event | Fires JSON output to stdout? | Required schema | Currently emits | Match? | #001-class risk |
|---|---|---|---|---|---|---|
| `session-start.sh` | `SessionStart` | YES (always — bootstrap injection) | `{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:str}}` | Same (post-#001 fix; jq-built) | **YES — matches** | None — covered by `session-start-schema.test.sh` |
| `session-start.cmd` | `SessionStart` | YES (Windows path) | Same as above | Same (post-#007 fix; PowerShell `ConvertTo-Json -Compress -Depth 4`) | **YES — matches** | LOW — schema test only runs the `.sh` path; `.cmd` is untested but inspection-equivalent |
| `pre-commit-structural.sh` | `PreToolUse` (matcher: Bash) | NO — uses **exit-code-only** signaling (`exit 2` on block, `exit 0` on allow) + stderr message; never emits JSON to stdout | If JSON were emitted: `{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:str}}` — but exit-code path is also documented and supported | Empty stdout + `exit 2` + stderr | **YES — exit-code path is documented as equivalent** | None — by not emitting JSON, no schema to violate |
| `post-write-md-lint.sh` | `PostToolUse` (matcher: Write) | NO — warn-only; emits stderr WARNs and `exit 0` | If JSON were emitted: `{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:str}}` | Empty stdout + stderr WARNs + `exit 0` | **YES — exit-code path** | None — but **the WARN messages never reach the model** (stderr on `exit 0` is not surfaced; only `exit 2` surfaces stderr to the model). This is a *separate* defect (warn-effectiveness), not a schema defect |
| `agent-return-parse.sh` | `PostToolUse` (matcher: Agent) | NO — same warn-only pattern | Same as above | Empty stdout + stderr WARNs + `exit 0` | **YES — exit-code path** | None for schema; same warn-effectiveness gap as `post-write-md-lint.sh` |
| `stop-debug-scan.sh` | `Stop` (no matcher) | NO — uses **exit-code-only** signaling (`exit 2` to block) + stderr | If JSON were emitted: top-level `{decision:"block",reason:str}` — **NOT** `hookSpecificOutput` (per Issue #15485) | Empty stdout + `exit 2` + stderr | **YES — exit-code path; would have been a #001-shape trap if migrated to JSON** | None today; **HIGH** if anyone "improves" this hook by adding JSON output without reading Issue #15485 |

**Bottom line — current state:** All 5 PF hooks emit shapes the harness accepts. The pre-#001 SessionStart bug was the only #001-class regression; it is fixed and now schema-tested. No other PF hook has a #001-class silent-rejection regression *today*.

---

### H.3 SP's 1 hook — verbatim contract

SP has **one** hook (SessionStart). Source: `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/hooks/session-start`.

```bash
# Output context injection as JSON.
# Cursor hooks expect additional_context (snake_case).
# Claude Code hooks expect hookSpecificOutput.additionalContext (nested).
# Copilot CLI (v1.0.11+) and others expect additionalContext (top-level, SDK standard).
# Claude Code reads BOTH additional_context and hookSpecificOutput without
# deduplication, so we must emit only the field the current platform consumes.

if [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
  printf '{\n  "additional_context": "%s"\n}\n' "$session_context"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -z "${COPILOT_CLI:-}" ]; then
  printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s"\n  }\n}\n' "$session_context"
else
  printf '{\n  "additionalContext": "%s"\n}\n' "$session_context"
fi
```

**Key contract observations:**
1. **`hookEventName: "SessionStart"` is hard-coded in the printf format string** — not omitted, not parameterized, not built dynamically. Compile-time guarantee that the field is present.
2. **JSON-escape via pure bash parameter substitution** (`escape_for_json` function lines 23–31) — five `${s//old/new}` passes for `\\`, `"`, `\n`, `\r`, `\t`. No jq dependency. Per inline comment: *"orders of magnitude faster than the character-by-character loop this replaces."*
3. **`printf` instead of heredoc** — explicit reference to `obra/superpowers#571` (bash 5.3+ heredoc hang). Defensive.
4. **Three-platform branch** with explicit comment that *"Claude Code reads BOTH additional_context and hookSpecificOutput without deduplication, so we must emit only the field the current platform consumes."* — i.e. emitting *both* would produce duplicate context. SP detects this and avoids it.
5. **Cursor uses `additional_context`** (snake_case, top-level) — different from CC's `hookSpecificOutput.additionalContext` (camelCase, nested). PF's `session-start.sh` lines 110–111 emit Cursor's shape correctly but route via the same script as CC.
6. **No `try/catch`-equivalent** — if jq/PowerShell/escape pipeline fails in PF, the script may exit 1 with no payload; SP's pure-bash approach has no failure mode beyond bash itself dying.

**SP's exit-code contract:** `exit 0` always. SP never blocks. SP has no Stop hook, no PreToolUse hook, no PostToolUse hook. The whole "hook discipline" surface is **one** event, **one** schema, **one** test surface.

---

### H.4 Are any of PF's other 4 hooks at risk of #001-class silent rejection?

**No — at present.** Audit conclusion:

| Hook | At risk today? | Why / why not |
|---|---|---|
| `pre-commit-structural.sh` | NO | Exit-code-only path; never emits JSON to stdout; harness has no schema to validate against |
| `post-write-md-lint.sh` | NO (schema) / **MEDIUM (effectiveness)** | Same exit-code-only pattern. BUT: every WARN it emits goes to stderr on `exit 0` — per CC docs, stderr on `exit 0` is **not surfaced to the model**. So the hook's lint warnings are visible only to the human user (or the hook test suite), never to the model that wrote the bad markdown. If the design intent was *"the model self-corrects when its plan doc has TBD"*, that intent is not met. (This is a separate defect class from #001 but in the same family of "hook exists but never reaches the model.") |
| `agent-return-parse.sh` | NO (schema) / **MEDIUM (effectiveness)** | Same as above. The agent-return-parse hook warns when an agent's return doesn't lead with a status token — but the warning is stderr on `exit 0`. The model that dispatched the agent never sees the WARN. The protective intent (steer parent model to enforce status-token discipline) is not realized through this channel. |
| `stop-debug-scan.sh` | NO (schema) | Exit-code-only path; `exit 2` correctly surfaces stderr to model on Stop. **HIGH RISK if a future contributor migrates this hook to JSON output without reading Issue #15485** — they'd likely emit `hookSpecificOutput.hookEventName:"Stop"` (matching the pattern of the other PF hooks if those ever migrate to JSON), which the schema validator would accept but the Stop control-flow parser would silently ignore. The block would not happen. |

**Latent #001-class risk score (for the 4 non-SessionStart hooks):**
- 0 active regressions
- 1 latent trap (Stop migration to JSON without Issue #15485 awareness)
- 2 effectiveness gaps (`post-write-md-lint`, `agent-return-parse` warns never reach model)

---

### H.5 What this would have prevented in PF v1.x

**Issue #001 directly:** the SessionStart `hookEventName`-missing bug. The first query in §H — `Claude Code SessionStart hook hookEventName required field` — returns the docs page that quotes the schema. Reading the docs *once* would have prevented the bug entirely. (PF was hand-built from training-data assumption rather than from the docs; the docs page contradicts that assumption.)

**Effectiveness gap discovery:** would have surfaced that PF's `post-write-md-lint.sh` and `agent-return-parse.sh` warnings to stderr on `exit 0` are invisible to the model. PF currently treats these hooks as "the model will self-correct"; per CC's surfacing rules, that's false. The hooks help humans grepping logs, not the model.

**Stop migration trap:** if anyone "modernized" `stop-debug-scan.sh` to JSON output (say, to add a richer reason message), they would almost certainly emit `hookSpecificOutput.hookEventName:"Stop"` based on the pattern of every other event. The block would silently fail. Issue #15485 is the only place this is documented; running the §H queries surfaces it.

**Cursor-shape regression:** PF's `session-start.sh` Cursor branch (lines 110–111) is left on the legacy sed/awk pipeline ("Fix 5.1 scope guard"). The §H queries would have surfaced the SP comment about Claude Code reading **both** `additional_context` and `hookSpecificOutput` without dedup, which means a Cursor-on-CC misconfiguration would inject the bootstrap *twice*. Defensive — but also a quirk PF didn't know about.

---

### H.6 Implications for v1.2+ design

**Recommendation 1 — Schema regression test for every hook that emits JSON.** Today only SessionStart has `session-start-schema.test.sh`. The other 4 hooks emit no JSON, so trivially pass — but the moment any one of them is migrated to JSON output (a likely future evolution as `additionalContext` injection becomes more useful for PostToolUse), the test gap opens. **Action:** add a per-event schema validator (`tests/hooks/schema-validator.sh`) that runs `jq -e` against the documented per-event schema for whichever events the hook claims to emit. Frontmatter in each hook script declares its event + emits-JSON-yes/no; the validator dispatches on that. Effort: ~half a day.

**Recommendation 2 — Replace stderr-on-exit-0 WARN pattern.** `post-write-md-lint.sh` and `agent-return-parse.sh` should either: (a) emit `hookSpecificOutput.additionalContext` so the model sees the warning; or (b) be honest about being human-only (move output to a log file under `.claude/hook-warnings.log` and remove the stderr-WARN illusion). Today they're in the worst-of-both-worlds middle: they log to stderr (ostensibly for the model) but the model never sees stderr on exit 0. **Action for `agent-return-parse`:** convert to JSON output with `additionalContext: "[framework] Agent return missing status token. Reissue with: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED on line 1."` so the parent model sees the lint and can self-correct. **Action for `post-write-md-lint`:** same.

**Recommendation 3 — Document the per-event schema asymmetry as a binding rule.** Add `core/rules.md` row: *"Hook output JSON must match the event-specific schema documented at docs.claude.com/hooks. Stop and SubagentStop use top-level `decision`/`reason`; all other event types nest under `hookSpecificOutput.hookEventName`. Mixing the two shapes is silently rejected by the harness (Issue #15485)."* Tag `MACHINE(test:tests/hooks/schema-validator.sh)`.

**Recommendation 4 — CI hook against the schema gist.** The `claude-code-hooks-schemas` gist (FrancisBourre) tracks the live schema; community-maintained but more current than PF's training-data view. **Action (P3):** monthly `scripts/check-hook-schemas-current.sh` that fetches the gist, diffs against PF's expected schema, and fails the test suite if the upstream contract changed. Hand-rolled regression detection.

**Recommendation 5 — Expand `tests/hooks/run-all.sh` to dry-run every hook with empty + malformed stdin.** Today the test suite runs the *happy path* + a few error paths per hook. Missing: every hook should be tested with **no stdin** (some hooks read stdin unconditionally — would hang or crash) and with **malformed JSON stdin** (jq error → would the hook exit clean or noisy?). Effort: ~2 hours.

**Recommendation 6 — Borrow SP's pure-bash JSON escape (P2 SP-borrow item already in PROJECT-PLAN).** Removes jq from the SessionStart critical path, eliminates the dep-warning short-circuit for jq-missing case (jq becomes warning-only, not fatal-for-bootstrap-delivery). PF's PROJECT-PLAN already lists this as P2. The §H research reinforces P2 priority — the jq dependency is a *second* failure mode beyond the schema (jq absent → manual escape pipeline → which PF v1.0 admits is "the next bug waiting to surface" per `diagnosis-skills-not-firing.md` §5.2).

---

### H.7 Risks / open questions

**R1 — Cursor shape verification.** PF's Cursor branch (`session-start.sh:110-111`) is on the legacy sed/awk escape and emits `additional_context` (top-level). SP confirms this is correct for Cursor. But PF has **no schema test for the Cursor shape** — the schema test forces `CLAUDECODE=1`. If Cursor's contract drifts (say, to require `hookEventName` like CC did), PF would silently regress on Cursor sessions only. Add a Cursor-branch test fixture to `session-start-schema.test.sh`.

**R2 — Copilot CLI shape unverified.** PF's Copilot branch (`session-start.sh:112-114`) is also on legacy escape and emits `additional_context`. SP's same-event hook emits `additionalContext` (camelCase, top-level) for Copilot. **PF and SP disagree on the Copilot shape.** SP's comment cites "Copilot CLI (v1.0.11+) and others expect additionalContext (top-level, SDK standard)." PF emits `additional_context` (snake_case). One of them is wrong; without a Copilot test fixture or doc citation, can't resolve. **Open question for v1.2.**

**R3 — Plugin-installed Stop hooks have a known bug (Issue #10412).** "Stop hooks with exit code 2 fail to continue when installed via plugins." This affects PF's `stop-debug-scan.sh` because PF is plugin-installed (not user-config). Need to verify whether the bug is fixed in current CC; if not, the `exit 2` block from `stop-debug-scan.sh` may not actually block when PF is plugin-installed. **Action:** add a manual integration test — write a temp `[debug:test]` file in src, trigger Stop, observe whether the session actually halts. If not, the hook's central guarantee is hollow.

**R4 — PostToolUse `additionalContext` 10K-char cap.** Per Issue #24788 and the gist, PostToolUse's `additionalContext` is capped at 10,000 characters. PF's two PostToolUse hooks (`post-write-md-lint`, `agent-return-parse`) currently emit nothing to stdout, so this cap doesn't bite — but if Recommendation 2 above is adopted (convert WARN to `additionalContext`), the lint-warning message must be capped client-side. Trivial for current message lengths; document the cap.

**R5 — `exit_code:1, outcome:error` vs `exit_code:1, outcome:success` inconsistency (Issue #16051, #34859, #17088).** Multiple CC versions have shipped bugs where hooks exiting 0 still surface "hook error" labels. PF's hook tests assert exit-code only, not transcript-side rendering. If CC's "hook error" surface is currently noisy, the model may be receiving spurious error labels for PF's silent-success hooks (e.g., `pre-commit-structural` on every non-commit Bash command). **Open question:** does the model's perception of "framework hooks are noisy/broken" affect skill-firing rate? Falsifiable via Phase-1 rebench transcript analysis (grep for `pre-commit-structural` hook-error labels in the v2 transcript that doesn't fire skills).

**R6 — Schema is community-maintained.** The `claude-code-hooks-schemas` gist (FrancisBourre) is a community asset, not Anthropic-official. Its accuracy depends on the maintainer. PF should not take it as binding — but it IS the most complete single document. The Anthropic-official `docs.claude.com/hooks` page is the binding source; the gist is supplementary. Recommendation 4 above hedges by diffing.

**Sources:**
- [Hooks reference — docs.claude.com](https://docs.claude.com/en/docs/claude-code/hooks)
- [Issue #13650 — SessionStart hook stdout silently dropped](https://github.com/anthropics/claude-code/issues/13650)
- [Issue #15485 — Stop hook hookEventName usage clarify](https://github.com/anthropics/claude-code/issues/15485)
- [Issue #16538 — Plugin SessionStart additionalContext not surfacing](https://github.com/anthropics/claude-code/issues/16538)
- [Issue #19115 — Conflicting JSON schemas PreToolUse vs PostToolUse](https://github.com/anthropics/claude-code/issues/19115)
- [Issue #21988 — PreToolUse exit codes ignored](https://github.com/anthropics/claude-code/issues/21988)
- [Issue #22031 — hookSpecificOutput schema doc incomplete](https://github.com/anthropics/claude-code/issues/22031)
- [Issue #24788 — PostToolUse additionalContext not surfacing for MCP](https://github.com/anthropics/claude-code/issues/24788)
- [Issue #10412 — plugin-installed Stop hooks exit 2 bug](https://github.com/anthropics/claude-code/issues/10412)
- [claude-code-hooks-schemas gist (FrancisBourre)](https://gist.github.com/FrancisBourre/50dca37124ecc43eaf08328cdcccdb34)
- [SP session-start hook source](file:///C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/hooks/session-start)
- [PF diagnosis: skills not firing §2.1](file:///c:/Users/atyab/Experimental%20-%20Users/production-framework/docs/diagnosis-skills-not-firing.md)

<!-- END-CATEGORY-H -->

---

## Category I — Empirical evidence on what makes skills fire

<!-- BEGIN-CATEGORY-I -->
**Bottom-line:** SP ships a complete, production-grade local harness (`tests/skill-triggering/` + `tests/explicit-skill-requests/`) that runs `claude -p` headless against a corpus of naive prompts under `--max-turns 3`, parses `stream-json` output, and asserts via `grep` whether the target skill was invoked via the `Skill` tool. Pass/fail is binary. **The PF v1.1.0 rep-2 regression would have been caught by SP's harness in ~60 seconds for ~$0.10**, vs the 1170-second / $3.16 ECA Portal full-task benchmark cycle that's currently the only feedback signal. The harness is small (~140 lines of bash per script, ~6 prompt files), self-contained, and portable. **PF should port it verbatim with prompt-corpus substitution.**

---

## I.1 Per-query findings

### Query 1 — "benchmark Claude Code plugin skill firing rate"

**Public web:** No public benchmark of Claude Code plugin skill-firing rate exists. The space is too new (skills shipped Q4 2025) and Anthropic has not published methodology.

**Private/cached evidence:** SP's `tests/skill-triggering/run-test.sh` IS the de-facto benchmark. It defines the metric (`grep -qE '"skill":"([^"]*:)?<name>"'` over `stream-json` output) and the corpus (6 task-shaped prompts). No equivalent harness exists in PF (`c:/Users/atyab/Experimental - Users/production-framework/tests/` does not exist for skill firing — only `scripts/structural-check.sh` for `core/` invariants).

### Query 2 — "SP superpowers vs no-plugin baseline benchmark"

SP does NOT ship a no-plugin A/B baseline. Its tests exclusively measure "with-plugin skill firing rate." The `--plugin-dir "$PLUGIN_DIR"` flag is hardcoded in every runner (`run-test.sh:49`, `run-multiturn-test.sh:51`, etc.). Gap in SP's methodology — it can detect regressions in skill triggering but not "does the plugin help vs. baseline?"

The PF rebench at `c:/Users/atyab/Experimental - Users/ECA Portal Copy/_bench/runs/T1/{pf,sp}/` is closer to a head-to-head: it runs `claude -p` against `T1.md` with `--plugin-dir <PF>`, `--plugin-dir <SP>`, and (implicitly via control) no plugin. **PF's bench harness is structurally MORE rigorous than SP's at the cross-plugin-comparison axis.** What PF lacks is SP's local-loop **per-skill-fires-on-naive-prompt** test.

### Query 3 — "Tier 3 cold prompt skill auto-invocation empirical"

No public corpus of "Tier 3" or "cold prompt" data. The closest empirical evidence lives entirely in SP's `tests/skill-triggering/prompts/` directory — 6 hand-written cold prompts that mirror the diagnosis doc's "task-triggered" framing exactly:
- `systematic-debugging.txt`: "The tests are failing with this error: [stack trace]. Can you figure out what's going wrong and fix it?"
- `writing-plans.txt`: "Here's the spec for our new authentication system: Requirements: [...]. We need to implement this. There are multiple steps involved..."
- `test-driven-development.txt`: "I need to add a new feature to validate email addresses..."
- `dispatching-parallel-agents.txt`: "I have 4 independent test failures happening in different modules: [...]. Can you investigate all of them?"
- `executing-plans.txt`: "I have a plan document at docs/superpowers/plans/2024-01-15-auth-system.md that needs to be executed. Please implement it."
- `requesting-code-review.txt`: "I just finished implementing the user authentication feature. All the code is committed. Can you review the changes before I merge to main?"

**Each prompt is a stripped, naive utterance that names the user's task in user vocabulary, never the skill name.** This is the exact corpus shape PF needs.

### Query 4 — "plugin behavior comparison head-to-head benchmark Claude Code"

The PF rebench is itself the only such benchmark of record. Diagnosis section A.1 already tabulated the cross-plugin head-to-head:

| Run | additionalContext bytes | First skill invoked | First tool dispatched |
|---|---|---|---|
| PF v1.1.0 | 7,726 | none (0 firings) | `Agent (Explore)` at idx 201 |
| SP v5.0.7 | 5,997 | `using-superpowers` then `brainstorming` | `Skill: superpowers:brainstorming` at idx 53 |

**Key citation:** `c:/Users/atyab/Experimental - Users/ECA Portal Copy/_bench/runs/T1/sp/rep-1/transcript.jsonl` line idx 11 contains the binding phrase `"as required"` in turn-1 thinking — the harness signal that bootstrap content reached the reasoning layer. PF's transcripts at idx 11 contain none.

### Query 5 — "TodoWrite usage as proxy for methodology engagement"

Diagnosis section C identified `TodoWrite calls: 8 -> 0` (PF v1.0.1 -> v1.1.0) as the single most striking signal. **SP's explicit-skill-requests harness EXPLICITLY filters TodoWrite as non-premature** in `run-test.sh:108-110`:

```bash
PREMATURE_TOOLS=$(head -n "$FIRST_SKILL_LINE" "$LOG_FILE" | \
    grep '"type":"tool_use"' | \
    grep -v '"name":"Skill"' | \
    grep -v '"name":"TodoWrite"' || true)
```

This is direct evidence that SP's authors treat TodoWrite as **legitimate scaffolding behavior** that should NOT be flagged when it precedes a skill invocation. PF v1.1.0's TodoWrite-zero collapse is therefore not a neutral signal — it's the *removal* of legitimate scaffolding, which SP's harness would have surfaced as a behavior-change diff if ported.

---

## I.2 SP test harness — anatomy

### Architecture

Three concentric harnesses under `tests/`:

| Harness | Path | Purpose | Runner shape |
|---|---|---|---|
| **skill-triggering** | `tests/skill-triggering/` | Naive prompt -> does the right skill fire? | Single-turn, `--max-turns 3` |
| **explicit-skill-requests** | `tests/explicit-skill-requests/` | User names a skill -> does it fire (vs premature action)? | Single-turn AND multi-turn variants |
| **claude-code** | `tests/claude-code/` | Full skill-content / behavior assertions | Bash + helper assertion library |

### Common runner contract — file:line evidence

**Inputs:** skill name + prompt file (single argument each) — `run-test.sh:14-17`:
```
SKILL_NAME="$1"
PROMPT_FILE="$2"
MAX_TURNS="${3:-3}"
```

**Invocation pattern** — `tests/skill-triggering/run-test.sh:48-53`:
```
timeout 300 claude -p "$PROMPT" \
    --plugin-dir "$PLUGIN_DIR" \
    --dangerously-skip-permissions \
    --max-turns "$MAX_TURNS" \
    --output-format stream-json \
    > "$LOG_FILE" 2>&1 || true
```

**Pass/fail criterion** — `tests/skill-triggering/run-test.sh:61-68`:
```
SKILL_PATTERN='"skill":"([^"]*:)?'"${SKILL_NAME}"'"'
if grep -q '"name":"Skill"' "$LOG_FILE" && grep -qE "$SKILL_PATTERN" "$LOG_FILE"; then
    echo "PASS: Skill '$SKILL_NAME' was triggered"; TRIGGERED=true
else
    echo "FAIL: Skill '$SKILL_NAME' was NOT triggered"; TRIGGERED=false
fi
exit $([ "$TRIGGERED" = "true" ] && echo 0 || echo 1)
```

Two predicates AND-ed: (1) Skill tool was invoked at all, (2) the specific skill name appears in any `Skill` invocation. **No latency, no cost, no quality gate — pure binary structural assertion.**

### Fixture corpus (skill-triggering)

`tests/skill-triggering/run-all.sh:10-17` defines the canonical 6-skill corpus. Each `<skill-name>.txt` in `prompts/` is a **single naive utterance** (1-10 lines, plain English, no skill-name reference, no framework vocabulary). See I.1 query 3 for full corpus content. **Critical design insight:** the prompts cover DISTINCT task verbs — "fix", "implement spec with multiple steps", "implement feature", "investigate multiple", "execute plan", "review". Each verb maps to ONE skill. The corpus IS the trigger-grammar specification.

### Fixture corpus (explicit-skill-requests)

`tests/explicit-skill-requests/prompts/` — 9 prompts, each variant probes a different failure mode:

| Prompt | Failure mode probed |
|---|---|
| `subagent-driven-development-please.txt` | Bare skill name -> does Claude invoke it? (Naive single-turn) |
| `use-systematic-debugging.txt` | "use X" phrasing |
| `please-use-brainstorming.txt` | "please use the X skill" phrasing |
| `mid-conversation-execute-plan.txt` | Plan + skill-name in same turn |
| `i-know-what-sdd-means.txt` | User describes skill behavior + names skill — does Claude invoke or paraphrase? |
| `claude-suggested-it.txt` | After Claude offered the skill, does invocation fire? |
| `after-planning-flow.txt` | After multi-turn planning, does skill fire? |
| `skip-formalities.txt` | "Don't waste time" + skill name — does urgency override skill load? |
| `action-oriented.txt` | "Do X — start with Task 1" — does skill fire BEFORE first action? |

**The prompt set was clearly mined from real user transcripts where skills failed to fire** — each is a distinct social/lexical pressure point. Empirical, not synthetic.

### Multi-turn variant — critical for the v1.1.0 rep-2 problem

`run-multiturn-test.sh:46-82` builds 3-turn conversation BEFORE asserting on turn 3:
- Turn 1: Start planning a feature.
- Turn 2: User says plan is written + asks for execution options.
- Turn 3: User types `"subagent-driven-development, please"` — assertion fires here.

`run-extended-multiturn-test.sh` extends to 5 turns; `run-haiku-test.sh` runs the same 5-turn flow with `--model haiku` to test cheaper-model degradation.

**This is the harness shape PF most needs**, because the v1.1.0 rep-2 failure mode is "model arrives at turn 1 without engaging the bootstrap." A multi-turn-cold-arrival test reproducing the ECA Portal T1 prompt verbatim would catch this without the 1170-second full-task wall.

### Token-usage analyzer — `tests/claude-code/analyze-token-usage.py`

Ingests `*.jsonl` transcript, breaks down by `agentId`, computes `input_tokens`/`output_tokens`/`cache_creation`/`cache_read` per agent (lines 22-66) and cost at `$3/$15 per M tokens` (lines 76-81). Main session vs. subagent breakdown table (lines 102-127). This is the same machinery the diagnosis doc used to compute "$2.34 -> $3.16, +35%". **Already proven on PF transcripts** — directly applicable, no port needed.

### Helper assertion library — `tests/claude-code/test-helpers.sh`

Five primitive assertions (lines 33-123): `assert_contains`, `assert_not_contains`, `assert_count`, `assert_order` (A appears before B), `run_claude` (wrapper). The `assert_order` primitive is the critical one for PF: it lets you assert "Skill: tier-selection appears BEFORE Agent: Explore" — exactly the structural test the diagnosis doc says PF v1.1.0 fails (turn-1 first tool = Agent, not Skill).

---

## I.3 What signals SP measures

**Primary signal — Skill-tool invocation.** Detection: `grep '"name":"Skill"' "$LOG_FILE" && grep -qE '"skill":"([^"]*:)?<name>"'`. Source of truth: the `stream-json` `tool_use` event when the Skill tool fires. The ONLY hard pass/fail.

**Secondary signal — premature action.** `run-test.sh:103-118` finds the line number of the first Skill invocation, then greps for `"type":"tool_use"` events BEFORE that line that are NOT `Skill` and NOT `TodoWrite`. Reports them as "WARNING: Tools invoked BEFORE Skill tool." The exclusion of `TodoWrite` is deliberate. Soft-fail signal — surfaces the failure mode where the model invokes the right skill late, after starting work. Maps directly to PF's diagnosis section A.2.

**Tertiary signal — full skill set surfaced.** `run-test.sh:71-73` — `grep -o '"skill":"[^"]*"' "$LOG_FILE" | sort -u` — lists ALL skills invoked during the run. Useful for diagnosing "wrong skill fired" and the cross-skill-cascade picture.

**Token / cost signals (separate harness).** `analyze-token-usage.py` applied post-hoc on transcripts. Not a pass/fail; a measurement.

**What SP does NOT measure (gap):**
- TodoWrite usage as a positive signal. SP filters it as "non-premature noise."
- Thinking-trace content (does turn-1 contain `"as required"` or `skill` or framework name?). SP does not introspect thinking. PF's diagnosis A.3 invented this signal manually; not in the harness.
- Bootstrap-byte-budget vs. firing-rate correlation. SP doesn't vary bootstrap size systematically.
- Model-tier (Sonnet vs Haiku vs Opus) cross-section. Only `run-haiku-test.sh` exists, testing one specific multi-turn flow, not the full corpus.

---

## I.4 What SP's harness would say about the PF v1.1.0 rep-2 datapoint

### Mechanical replay of SP's harness against the PF rep-2 transcript

Direct application of `tests/skill-triggering/run-test.sh`'s pass/fail logic to `c:/Users/atyab/Experimental - Users/ECA Portal Copy/_bench/runs/T1/pf/rep-2/transcript.jsonl`:

```
SKILL_NAME="brainstorming"   # task-triggered candidate per diagnosis section B
SKILL_PATTERN='"skill":"([^"]*:)?brainstorming"'
grep -q '"name":"Skill"' rep-2/transcript.jsonl   -> FALSE (0 Skill invocations)
grep -qE "$SKILL_PATTERN" rep-2/transcript.jsonl  -> FALSE
EXIT 1 -- FAIL
```

**Verdict:** PF v1.1.0 rep-2 would be a hard FAIL on the `brainstorming` skill-triggering test. Same for ANY of the other 11 PF entry-point skills — the transcript contains zero Skill-tool invocations of any kind.

### Replay against SP's secondary "premature action" predicate

```
FIRST_SKILL_LINE = (none -- no Skill invocation exists)
-> "WARNING: No Skill invocation found at all"
-> "Tools invoked: Agent, Bash, Edit, Read, ... (16 distinct, 99 total)"
```

The worst-case branch of SP's harness — not "skill fired late" but "skill never fired." Designed to catch precisely this regression mode.

### Replay against SP's `assert_order` primitive

```
assert_order transcript "Skill: production-framework:tier-selection" "Agent (Explore)"
-> "[FAIL] pattern A not found: Skill: production-framework:tier-selection"
```

Unambiguous failure. The assertion wouldn't even get to the order check.

### What the cross-plugin replay would say (SP rep-1 baseline)

Running the same predicate on `c:/Users/atyab/Experimental - Users/ECA Portal Copy/_bench/runs/T1/sp/rep-1/transcript.jsonl`:

```
SKILL_NAME="brainstorming"
grep -q '"name":"Skill"' sp/rep-1/transcript.jsonl   -> TRUE
grep -qE '"skill":"([^"]*:)?brainstorming"' ...      -> TRUE (idx 53)
EXIT 0 -- PASS
```

SP's harness gives a clean A/B: SP=PASS, PF=FAIL. **The harness, ported to PF, would have flagged the regression at the v1.1.0 commit instead of after the ECA Portal benchmark cycle.**

### Cost of running this check

A single `claude -p "<T1.md prompt>" --max-turns 3 --output-format stream-json` against a feature-build prompt costs ~$0.05–0.15 and ~30–90 seconds. ECA Portal full-task: $3.16 / 1170s. **Roughly 30x faster, 30x cheaper feedback loop** for the structural-skill-firing question — which IS the question PF v1.x has been chasing.

---

## I.5 What this would have prevented in PF v1.x

### Concrete v1.x incidents the harness would have caught

| Incident | Cycle cost | SP-style harness would have caught at: |
|---|---|---|
| Issue #001 — SessionStart hook broken in v1.0.1, no `additionalContext` delivered | 1 full bench cycle (~$3 / 800s + analysis) | Harness reports `Skill: using-this-framework` not invoked at session start. Catch: 60s. |
| v1.1.0 rep-2 — bootstrap delivered but cold-entry cascade has no task-triggered seed | 1 full bench cycle ($3.16 / 1170s + 4-hour diagnosis writeup) | Per I.4 — direct FAIL on `brainstorming`/`tier-selection` skill-triggering test against a T1-shaped prompt. Catch: 60s. |
| TodoWrite-zero collapse (8 -> 0 calls) | Discovered as side-effect of cost-regression analysis | Would NOT have been caught by SP's harness as-shipped. Requires PF-specific assertion. |
| Bootstrap-content reach (does the model engage with it?) | Discovered via manual transcript regex search | Would NOT have been caught. Requires thinking-trace inspection — an extension. |

### The compounding cost of NOT having local skill-firing tests

Each PF v1.x version bump (v1.0.1 -> v1.1.0) required: (1) edit framework files; (2) reinstall plugin; (3) run ECA Portal full benchmark (~20 minutes); (4) manually parse transcript JSONL; (5) diagnose deviations (often 1-4 hours). Total: 30-300 minutes per iteration.

A local SP-style harness compresses steps 3-4 to 60s of `claude -p` + `grep`. **Step 5 (diagnosis) becomes optional** — if the test passes, you proceed; if it fails, you have a tight reproduction case.

### Implication for v1.x retrospective

**The slow benchmark loop is the proximate cause of v1.x's slow iteration speed.** Hypotheses about skill firing could not be cheaply A/B'd. Framework changes were validated against a single, expensive integration test which conflates many variables (cost, wall, quality, skill firing) and does not provide tight feedback on the binary structural question.

This explains why diagnosis Section E selects experiment (c) as the next single experiment — the **ratio of information-per-cycle** is low. A local harness would let PF run experiments (a), (b), (c), (d) in parallel within an hour for under $2 total, rather than sequentially over multiple days.

---

## I.6 Implications for v1.2+ design

### Recommendation 1 — port SP's `tests/skill-triggering/` verbatim with a PF-shaped prompt corpus

Files to create:
- `tests/skill-triggering/run-test.sh` — copy from SP unchanged. Generic over skill name + prompt file; the directory hardcode is parameterized.
- `tests/skill-triggering/run-all.sh` — replace `SKILLS=(...)` array with PF entry-point skills.
- `tests/skill-triggering/prompts/<skill>.txt` — write 6+ naive prompt files matching PF's entry-point skill set.

**Verbatim-portable signals (no PF-specific logic):** the pass/fail predicate; the premature-action secondary check (`run-test.sh:103-118`); the skill-listing tertiary signal (`run-test.sh:71-73`); the `--max-turns 3` budget cap; the `--output-format stream-json` invariant.

**PF-specific changes:** Skill array -> PF skill names (the regex `([^"]*:)?<name>` already handles `production-framework:`); prompt corpus -> PF needs DIFFERENT corpus than SP because PF's skill set has different shape.

### Recommendation 2 — port `tests/explicit-skill-requests/run-multiturn-test.sh` for cold-arrival testing

The PF v1.1.0 rep-2 failure mode IS a multi-turn cold arrival: turn 1 already routes to `Agent (Explore)` before the bootstrap engages. SP's `run-multiturn-test.sh` provides the exact harness shape: build conversation context (lines 47-72); on the final turn, assert the target skill fires (lines 90-97); on the final turn, run the premature-action check (lines 105-125). For PF, the "final turn" should be the actual ECA Portal T1.md prompt with a 0-turn warm-up (cold). Isolates the cold-entry-cascade failure mode without the cost of running a full feature implementation.

### Recommendation 3 — port `tests/claude-code/analyze-token-usage.py` unchanged

Already proven on PF transcripts. No port required — adopt as a checked-in tool under `tests/claude-code/`.

### Recommendation 4 — extend SP's harness with PF-specific signals

**Extension A — TodoWrite-positive signal.** Diagnosis section C identified TodoWrite collapse as a striking signal of methodology-engagement loss. SP's harness filters TodoWrite as noise; PF should treat its presence/absence as a `--soft-fail-on-zero-todo-write` flag during cold-arrival multi-turn tests. Implementation: add `count_todo_writes()` helper and assert `>0` for build-task prompts.

**Extension B — bootstrap-engagement check.** Inspect turn-1 thinking traces for one of: (a) any PF skill name, (b) framework-vocabulary tokens (`"tier"`, `"production"`, `"framework"`, `"skill"`), (c) the binding phrase `"as required"` or equivalent. Implementation: extract `text` from `thinking` content blocks in stream-json, regex-match. SP doesn't have this because SP doesn't have bootstrap-engagement *as a defined failure mode* — PF does.

### Recommendation 5 — fixture corpus shape for PF

Per diagnosis section B, PF has 12 entry-point skills, of which only `brainstorming` is task-triggered. The corpus should mirror that distribution:

| Prompt file | Skill it should fire | Source for prompt vocabulary |
|---|---|---|
| `brainstorming.txt` | `production-framework:brainstorming` | Adapt SP's `writing-plans.txt` (spec-with-multiple-steps) |
| `tier-selection.txt` | `production-framework:tier-selection` | Cold task verb, e.g., the actual ECA Portal T1.md prompt verbatim |
| `triage.txt` | `production-framework:triage` | Adapt SP's `systematic-debugging.txt` (test-failure stack-trace prompt) |
| `enterprise-research-first.txt` | `production-framework:enterprise-research-first` | Cold "should we use library X or library Y?" decision prompt |
| `regression-scope.txt` | `production-framework:regression-scope` | Cold "I want to change shared utility/model X" prompt |
| `gate-3-production-check.txt` | `production-framework:gate-3-production-check` | Cold "ready to deploy / merge / release" prompt |

These are the 6 task-triggered (or candidate-task-triggered) skills. Mid-cycle skills (`writing-plan`, `seven-validation-questions`, `parallel-dispatch`, `verification-before-completion`) cannot be tested cold; they require harness multi-turn setup.

### Recommendation 6 — pass criteria for v1.2+ release

Tie PF release gates to harness pass count. Suggested gate (diagnostic, not a binding patterns rule):
- v1.2.x release: `tests/skill-triggering/run-all.sh` passes >= 4/6 cold prompts.
- v1.3.x release: >= 5/6 cold prompts pass + multi-turn cold-arrival test for the T1 verbatim prompt fires `tier-selection` or `brainstorming` within the first 3 tool-uses.

Structural / binary criterion. Cost / wall / quality remain separate measurement axes.

### Recommendation 7 — DO NOT borrow SP's harness limitations

Three SP-specific constraints PF should explicitly reject: **No baseline arm** — SP only tests "with-plugin"; PF's existing ECA Portal head-to-head bench is structurally better at the cross-plugin axis; keep both. **TodoWrite filtered as noise** — PF should track TodoWrite as a positive signal (Extension A above). **Single fixture per skill** — SP has 1 prompt per skill; PF should consider 2-3 prompts per skill once corpus is established, to test trigger-description robustness across paraphrase.

---

## I.7 Risks / open questions

**R1 — Harness validity: does `claude -p` stream-json output match the in-Claude-Code-app skill-firing behavior?** SP's harness uses `claude -p` (CLI / SDK invocation). PF's actual user-context is the Claude Code interactive app + plugin auto-load. The two MAY diverge: e.g., interactive app may inject different system-prompt scaffolding, or SDK may not pass plugin metadata in the same shape. Untested. **Recommended check:** run one ECA-Portal-T1-shaped prompt through both `claude -p` (with `--plugin-dir`) and the interactive app, and verify both transcripts show the same skill-firing pattern. If they diverge, the harness is invalid as a substitute.

**R2 — Prompt-corpus authorship cost.** SP's 6 prompt files were clearly mined from real user transcripts ("subagent-driven-development, please" is a real user utterance). PF doesn't have a comparable user-transcript corpus yet. The first 6 PF prompts may be synthetic and biased toward the failure modes the developer remembers. Mitigate: source prompts from the actual `_bench/tasks/T*.md` files.

**R3 — Sonnet/Opus drift and trigger-rate non-stationarity.** Trigger behavior depends on the model's training cutoff and post-training. SP's `run-haiku-test.sh` exists specifically because skill-firing rates differ across model tiers. PF will need to lock the test model and re-validate the corpus on every Anthropic model release. Cost: ~$2 / model release for a 6-skill corpus refresh.

**R4 — False-positive risk (the harness passes but rebench still fails).** The harness asserts STRUCTURAL (skill-fired), not OUTCOME (skill produced good work). It is theoretically possible for v1.2.x to pass `tests/skill-triggering/run-all.sh` 6/6 but still regress on cost / wall / quality on ECA Portal. The harness is *necessary*, not *sufficient*. Mitigation: keep ECA Portal benchmark as the final pre-release gate; use the harness as the iteration-loop signal.

**R5 — `--max-turns 3` budget edge case.** SP caps at 3 turns. If the model takes 2 turns of clarifying questions before deciding to invoke a skill, the harness will report FAIL even though invocation would have happened on turn 4. SP's prompts are crafted to avoid this; PF needs to verify the same. Mitigate: explicitly write prompts to be self-contained.

**R6 — Plugin-directory test isolation.** SP's harness uses `--plugin-dir "$PLUGIN_DIR"` to isolate from user-installed plugins. PF on a developer machine may already have PF installed via `~/.claude/plugins/`, which `claude -p` will load automatically. May cause double-loading or conflict with `--plugin-dir`. **Untested in PF context.** Recommended check: smoke test that the harness can override the user-installed plugin and report the explicit version under test.

**Open question 1** — does the trigger-description rewrite (diagnosis section E experiment c) move the harness needle? If PF ports the harness BEFORE running experiment-c, the harness can be the falsifiability gate FOR experiment-c. (Pass criterion in diagnosis E directly translates to `assert_order "Skill" "Agent"` on the harness.)

**Open question 2** — does SP's harness catch the rep-2 regression on a larger sample? The diagnosis is N=1 per arm. A harness rerun across 5 prompts x 3 reps would establish whether the rep-2 failure is structural (catches every time) or stochastic (caught 60% of the time).

**Open question 3** — what's the role of SP's `tests/subagent-driven-dev/` corpus? Contains full design docs and scaffolding for go-fractals and svelte-todo — looks like end-to-end integration test fixtures, not skill-firing tests. **Out of Category-I scope but flagged for Category-K researcher.**

---

## Sources

- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/tests/skill-triggering/run-test.sh:14-88` — single-prompt runner contract
- `…/tests/skill-triggering/run-all.sh:10-17` — canonical 6-skill corpus
- `…/tests/skill-triggering/prompts/{systematic-debugging,test-driven-development,writing-plans,dispatching-parallel-agents,executing-plans,requesting-code-review}.txt` — SP cold-prompt corpus
- `…/tests/explicit-skill-requests/run-test.sh:71-118` — explicit-name + premature-action harness
- `…/tests/explicit-skill-requests/run-multiturn-test.sh:46-125` — multi-turn cold-arrival shape
- `…/tests/explicit-skill-requests/run-haiku-test.sh:99-127` — model-tier degradation harness
- `…/tests/explicit-skill-requests/run-extended-multiturn-test.sh` — 5-turn extended variant
- `…/tests/explicit-skill-requests/prompts/*.txt` (9 files) — explicit-request corpus probing distinct social/lexical pressure points
- `…/tests/claude-code/analyze-token-usage.py:22-167` — token / cost breakdown by agentId
- `…/tests/claude-code/test-helpers.sh:33-123` — assertion primitives
- `…/tests/claude-code/run-skill-tests.sh:25-187` — full test runner
- `…/tests/claude-code/README.md` — harness documentation
- `c:/Users/atyab/Experimental - Users/production-framework/docs/diagnosis-rebench-negative-2026-04-28.md` — sections A.1, A.2, A.3, B, C
- `c:/Users/atyab/Experimental - Users/ECA Portal Copy/_bench/runs/T1/{pf,sp}/rep-{1,2}/transcript.jsonl` — comparison transcripts

<!-- END-CATEGORY-I -->

---

## Category J — What "directory" source actually means

<!-- BEGIN-CATEGORY-J -->

**Top finding (single sentence):** Per the official Claude Code docs, *all* marketplace plugins (including `directory`-source) are **copied to `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` at install time and the runtime serves from that cache**, not from the source directory; PF's `installed_plugins.json` confirms this — `installPath` points to the cache, NOT the source — yet Issue #008's empirical observation (source edits taking effect without reinstall) is real and reproducible. The most likely explanation is that **for `directory` sources whose declared `version` field is unchanged, `/plugin marketplace update` re-runs the cache-copy step from source on each invocation (and `/plugin install … --force` does the same), making the cache a near-real-time mirror of source whenever the user "reinstalls" without bumping `version` in `plugin.json`** — i.e. the v1.0.1 → v1.1.0 reinstall theater wasn't theater for the *operational assets* (skills/agents/hooks were genuinely refreshed by the cp step), it was theater only for the *version field* (which gates `/plugin update`'s no-op short-circuit). The corollary, **binding for v1.2+**: if PF migrates to git/marketplace source, the cache will refresh **only on commit-SHA change or version bump**, not on filesystem edit — every dev iteration becomes "commit + `/plugin marketplace update`" instead of "edit + new session". This is a meaningful workflow tradeoff.

### J.1 Per-query findings

#### Query 1 — `Claude Code marketplace directory source path resolution`
**Top citations:**
- Claude Code official docs — `https://code.claude.com/docs/en/plugin-marketplaces`
- Claude Code official docs — `https://code.claude.com/docs/en/plugins-reference` (§ "Plugin caching and file resolution")
- GitHub issue `anthropics/claude-code#23978` — `extraKnownMarketplaces` directory-source path resolution

**Summary:** Directory-source marketplaces are added via `/plugin marketplace add <local-path>` or via `extraKnownMarketplaces` with `"source": "directory"`. The path is resolved to absolute and stored in `~/.claude/plugins/known_marketplaces.json` under `installLocation` (verbatim from issue #23978 fixed example: `"installLocation": "D:\\Projects\\my-project"`). When `extraKnownMarketplaces` is used with a relative path like `"./"`, issue #23978 documents that the path is **NOT resolved to absolute** and gets stored literally as `"./"`, causing runtime resolution failure. PF's `known_marketplaces.json` (verbatim, line 21) shows `"path": "c:/Users/atyab/Experimental - Users/production-framework"` — absolute, so PF avoids issue #23978.

#### Query 2 — `plugin source directory vs cache directory resolution Claude Code`
**Top citations:**
- Claude Code plugins-reference — § "Plugin caching and file resolution" (`https://code.claude.com/docs/en/plugins-reference#plugin-caching-and-file-resolution`)
- Claude Code plugin-marketplaces docs — `https://code.claude.com/docs/en/plugin-marketplaces` (§ "How plugins are installed")
- GitHub issue `anthropics/claude-code#15642` — Plugin cache: `CLAUDE_PLUGIN_ROOT` points to stale version

**Summary VERBATIM from plugins-reference:**
> *"For security and verification purposes, Claude Code copies marketplace plugins to the user's local plugin cache (`~/.claude/plugins/cache`) rather than using them in-place. Understanding this behavior is important when developing plugins that reference external files."*

> *"Plugins are specified in one of two ways: Through `claude --plugin-dir`, for the duration of a session. Through a marketplace, installed for future sessions."*

**Verbatim from plugin-marketplaces "How plugins are installed" Note:**
> *"When users install a plugin, Claude Code copies the plugin directory to a cache location. This means plugins can't reference files outside their directory using paths like `../shared-utils`, because those files won't be copied."*

> *"Once a plugin is cloned or copied into the local machine, it is copied into the local versioned plugin cache at `~/.claude/plugins/cache`."*

**Crucially**: the docs do NOT distinguish between `github` source and `directory` source for the cache step — *all* marketplace plugins are described as being copied. The only path that bypasses cache is `claude --plugin-dir` (session-scoped, not registered to a marketplace). Issue #15642 confirms `CLAUDE_PLUGIN_ROOT` env-var (used in hook scripts via `${CLAUDE_PLUGIN_ROOT}`) resolves to a cache-directory path like `/home/user/.claude/plugins/cache/cc-plugins/devloop/2.4.7/` — runtime serving is from cache.

#### Query 3 — `known_marketplaces.json schema directory source live`
**Top citations:**
- PF's actual `known_marketplaces.json` (verbatim observation)
- Issue `anthropics/claude-code#23978` (verbatim known_marketplaces.json shape)
- Issue `anthropics/claude-code#52218` — autoUpdate doesn't update installed_plugins.json

**Summary:** No public schema doc exists; the schema must be inferred from runtime artifacts. **Verbatim PF runtime data** (`C:/Users/atyab/.claude/plugins/known_marketplaces.json` lines 18–25):
```json
"production-framework": {
  "source": {
    "source": "directory",
    "path": "c:/Users/atyab/Experimental - Users/production-framework"
  },
  "installLocation": "c:\\Users\\atyab\\Experimental - Users\\production-framework",
  "lastUpdated": "2026-04-28T12:09:05.328Z"
}
```
Compare to GitHub-source SP entry (lines 2–9):
```json
"claude-plugins-official": {
  "source": {
    "source": "github",
    "repo": "anthropics/claude-plugins-official"
  },
  "installLocation": "C:\\Users\\atyab\\.claude\\plugins\\marketplaces\\claude-plugins-official",
  "lastUpdated": "2026-04-29T05:48:03.977Z"
}
```
**Key shape difference:** for `directory`, `installLocation` = **the source directory itself**. For `github`, `installLocation` = a **clone path under `~/.claude/plugins/marketplaces/<name>/`** (separate from the source). The directory-source `installLocation` "double-purposes" the source dir — it is both the canonical content location AND the marketplace registration point. The github-source registration pulls the marketplace catalog into a clone Claude Code controls.

#### Query 4 — `init record plugin path source vs cache Claude Code`
**Top citations:**
- PF's actual `installed_plugins.json` (verbatim observation)
- Issue `anthropics/claude-code#52218` — `installPath` field documented as canonical hook-load path
- Issue `anthropics/claude-code#12457` — local-directory marketplace persistence workaround

**Summary:** PF's `installed_plugins.json` entry (verbatim, lines 14–22):
```json
"production-framework@production-framework": [
  {
    "scope": "local",
    "projectPath": "C:\\Users\\atyab\\Experimental - Users\\Vendor Email Scraping",
    "installPath": "C:\\Users\\atyab\\.claude\\plugins\\cache\\production-framework\\production-framework\\1.1.0",
    "version": "1.1.0",
    "installedAt": "2026-04-24T07:14:40.027Z",
    "lastUpdated": "2026-04-28T00:00:00.000Z"
  }
]
```
Note: `installPath` = **CACHE**, not source. `gitCommitSha` field is **absent** for directory source (present for github source — see SP entry: `"gitCommitSha": "6efe32c9e2dd002d0c394e861e0529675d1ab32e"`). Issue #52218 verbatim: *"plugin-bundled hooks load from the `installPath` recorded in that file"* and *"`autoUpdate` hot-loads newer skills/commands into the running process but leaves `installed_plugins.json` untouched, pinning bundled hooks to the last-explicitly-installed version."*

**Implication for PF:** the runtime path used for hooks is the CACHE path `…\cache\production-framework\production-framework\1.1.0\hooks\session-start.sh`, not the source `…\production-framework\hooks\session-start.sh`. Confirmed by direct disk inspection: cache and source files are byte-identical (`diff -rq` returns 0 differences across `skills/`, `agents/`, `hooks/`, `core/`).

### J.2 `directory` source semantics — verbatim from docs / registry observation

**Verbatim doc (plugin-marketplaces, "How plugins are installed" Note):**
> *"When users install a plugin, Claude Code copies the plugin directory to a cache location."*

**Verbatim doc (plugins-reference, § "Plugin caching and file resolution"):**
> *"For security and verification purposes, Claude Code copies **marketplace** plugins to the user's local plugin cache (`~/.claude/plugins/cache`) rather than using them in-place."*

**Verbatim doc (plugin-marketplaces, § "Local directory or file source" Note):**
> *"If you use a local `directory` or `file` source with a relative path, the path resolves against your repository's main checkout. When you run Claude Code from a git worktree, the path still points at the main checkout, so all worktrees share the same marketplace location. Marketplace state is stored once per user in `~/.claude/plugins/known_marketplaces.json`, not per project."*

**Verbatim doc (plugin-marketplaces, § "Version resolution"):**
> *"Plugin versions determine cache paths and update detection: if the resolved version matches what a user already has, `/plugin update` and auto-update skip the plugin."*

> *"Setting `version` pins the plugin. If `plugin.json` declares `"version": "1.0.0"`, pushing new commits without changing that string does nothing for existing users, because Claude Code sees the same version and keeps the cached copy. Bump the field on every release, or omit it to use the commit SHA."*

**Verbatim from plugins-reference, § "Version resolution"** (4 fallback sources for plugin version, last entry):
> *"4. `unknown`, for `npm` sources or local directories not inside a git repository"*

**Verbatim from discover-plugins, § "Common issues":**
> *"Plugin skills not appearing: Clear the cache with `rm -rf ~/.claude/plugins/cache`, restart Claude Code, and reinstall the plugin."*

> *"Files not found after installation: Plugins are copied to a cache, so paths referencing files outside the plugin directory won't work"*

**Verbatim from discover-plugins, § "Configure auto-updates":**
> *"Official Anthropic marketplaces have auto-update enabled by default. Third-party and local development marketplaces have auto-update disabled by default."*

**Empirical registry observations (PF, 2026-04-29):**
- `known_marketplaces.json` `installLocation` = source path (`c:/Users/atyab/Experimental - Users/production-framework`)
- `installed_plugins.json` `installPath` = cache path (`C:\Users\atyab\.claude\plugins\cache\production-framework\production-framework\1.1.0`)
- `installed_plugins.json` entry has NO `gitCommitSha` field (vs github source which always has one)
- `installed_plugins.json` entry has NO `isLocal: true` field (issue #12457's workaround uses this — possibly a newer/older variant)
- Cache directory has `Birth: 2026-04-28 16:11:59` (when reinstall was performed); source directory `Birth: 2026-04-28 16:07:39` (earlier — original creation)
- Cache and source files have identical `Modify` mtimes — `cp` preserves source mtime, confirming a copy operation happened, not an inode-link
- Cache `1.1.0/` contains a stray nested `production-framework/` subdirectory (likely the v1.0.1 tree from a prior install — the v1.1.0 reinstall layered new content over old without cleaning up)
- `marketplaces/` dir contains subdirs ONLY for github sources (`claude-plugins-official`, `vercel`); NO `production-framework/` subdir — confirms directory-source does not get a separate marketplace clone

### J.3 git-source / marketplace-source semantics — verbatim

**Verbatim from plugin-marketplaces, § "Plugin source types"** (the table of source types):

| Source        | Type                            | Fields                             | Notes                                                                                                                                             |
| ------------- | ------------------------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Relative path | `string` (e.g. `"./my-plugin"`) | none                               | Local directory within the marketplace repo. Must start with `./`. Resolved relative to the marketplace root, not the `.claude-plugin/` directory |
| `github`      | object                          | `repo`, `ref?`, `sha?`             |                                                                                                                                                   |
| `url`         | object                          | `url`, `ref?`, `sha?`              | Git URL source                                                                                                                                    |
| `git-subdir`  | object                          | `url`, `path`, `ref?`, `sha?`      | Subdirectory within a git repo. Clones sparsely to minimize bandwidth for monorepos                                                               |
| `npm`         | object                          | `package`, `version?`, `registry?` | Installed via `npm install`                                                                                                                       |

**Verbatim from plugin-marketplaces, § "Distinguish between marketplace and plugin sources":**
> *"Marketplace source — where to fetch the `marketplace.json` catalog itself. Set when users run `/plugin marketplace add` or in `extraKnownMarketplaces` settings. Supports `ref` (branch/tag) but not `sha`. Plugin source — where to fetch an individual plugin listed in the marketplace. Set in the `source` field of each plugin entry inside `marketplace.json`. Supports both `ref` (branch/tag) and `sha` (exact commit)."*

**For github sources:** Claude Code clones the marketplace repo into `~/.claude/plugins/marketplaces/<name>/` (so the marketplace catalog itself is mirrored), then for each plugin entry copies the relative-path subdirectory into `~/.claude/plugins/cache/<marketplace>/<plugin>/<version-or-sha>/`. PF's vercel marketplace example (`vercel/vercel-plugin`) at `marketplaces/vercel/` has the full marketplace tree (`agents`, `hooks`, `commands`, etc.). SP at `marketplaces/claude-plugins-official/` has only `.claude-plugin/marketplace.json` (since SP plugins are in subdirs of the same monorepo, the per-plugin cache dirs hold each plugin's content separately).

**Cache invalidation triggers (verbatim plugin-marketplaces, "Plugin versions"):** *"if the resolved version matches what a user already has, `/plugin update` and auto-update skip the plugin"* — so cache is rebuilt only when version changes (or commit-SHA changes if `version` is omitted from `plugin.json`).

### J.4 SP vs PF source-type contrast

| Attribute | SP (`claude-plugins-official` github source) | PF (`production-framework` directory source) |
|---|---|---|
| `known_marketplaces.json[*].source.source` | `"github"` | `"directory"` |
| `known_marketplaces.json[*].source.repo`/`.path` | `"anthropics/claude-plugins-official"` | `"c:/Users/atyab/Experimental - Users/production-framework"` |
| `known_marketplaces.json[*].installLocation` | `~/.claude/plugins/marketplaces/claude-plugins-official/` (clone) | `c:/Users/atyab/Experimental - Users/production-framework` (source) |
| Marketplace catalog location | Cloned from GitHub into `marketplaces/<name>/` | None — the source dir IS the catalog |
| Per-plugin cache | `~/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/` | `~/.claude/plugins/cache/production-framework/production-framework/1.1.0/` |
| `installed_plugins.json[*].installPath` | Cache path (versioned) | Cache path (versioned) — SAME shape, but version is from `plugin.json` not git tag |
| `installed_plugins.json[*].gitCommitSha` | Present (`6efe32c9e2dd002d0c394e861e0529675d1ab32e`) | **Absent** |
| `installed_plugins.json[*].version` | Resolved from git ref/SHA → `"5.0.7"` (matching SP's release tag) | Read from `plugin.json` → `"1.1.0"` (manual) |
| Cache invalidation trigger | Git commit SHA change (or version field bump) | `plugin.json` version field bump, OR `/plugin install --force`/`/plugin marketplace update` reinvocation |
| Auto-update default | **Enabled** (per discover-plugins doc: *"Official Anthropic marketplaces have auto-update enabled by default"*) | **Disabled** (per same doc: *"Third-party and local development marketplaces have auto-update disabled by default"*) |
| Effect of source-dir edit without reinstall | Source-dir is `~/.claude/plugins/marketplaces/<name>/` — Claude Code-managed; user-edits would be clobbered by next git pull and don't reach cache anyway | Source-dir is the user's repo — edits land on disk but cache is unchanged unless `/plugin marketplace update` or version bump or `/plugin install --force` re-runs the cp |
| What "reinstall" actually does | Re-clones marketplace, re-resolves version, re-copies plugin tree to cache (versioned dir) | Re-copies source tree to cache (versioned dir, possibly same version if `plugin.json` unchanged) |
| Where SessionStart hook actually executes from | `${CLAUDE_PLUGIN_ROOT}` = `~/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/` | `${CLAUDE_PLUGIN_ROOT}` = `~/.claude/plugins/cache/production-framework/production-framework/1.1.0/` |

**Critical reframing:** PF's directory source and SP's github source are functionally identical at runtime — both serve from cache. The difference is **how cache invalidation works**:
- SP: cache invalidates on git push + auto-update fetch (developer commits → users get new cache version on next session start)
- PF: cache invalidates only on explicit `/plugin install --force`, `/plugin marketplace update`, or `version` bump in `plugin.json` (developer edits source → users still see old cache)

### J.5 What this would have prevented in PF v1.x (Issue #008 + reinstall theater)

**Issue #008's core observation re-examined:** "edits to skill descriptions / hook scripts in the source directory take effect on the next subprocess automatically. No `claude plugin reinstall` is required."

This observation is **partially incorrect** as a general claim — the docs are unambiguous that runtime serves from cache. The **likely actual mechanism** explaining the v2 pre-fix → v2 post-fix `hook_size` change (7968 → 7657 chars, attributed to source edit):

1. The user's "v2 post-fix" benchmark run was preceded by SOMETHING that re-copied the source into cache. Plausible candidates:
   - `/plugin install --force production-framework@production-framework` (force reinstall)
   - `/plugin marketplace update production-framework` (refresh — though docs say this is normally a metadata-only refresh for github sources, for directory sources the catalog IS the source so it likely re-reads everything)
   - A `claude plugin reinstall` invocation that the user didn't notice or didn't log
   - Auto-update — but auto-update is **disabled by default** for local marketplaces per the discover-plugins doc, so this is unlikely

2. Alternative explanation: PF's `plugin.json` declares `"version": "1.1.0"` while `marketplace.json` declares `"version": "1.0.1"` (verified in source — `marketplace.json` line 4 says `"version": "1.0.1"`, `plugin.json` says `"version": "1.1.0"`). Per docs verbatim: *"Avoid setting `version` in both `plugin.json` and the marketplace entry. The `plugin.json` value always wins silently, so a stale manifest version can mask a version you set in `marketplace.json`."* This means the v1.0.1 → v1.1.0 reinstall WAS a real version change for the runtime (plugin.json bumped), even though `marketplace.json` still says 1.0.1. The mismatch is a real bug in PF's registration but DIDN'T prevent the cache refresh.

**What having Category J research available pre-v1.x would have prevented:**

1. **Confused mental model that cache was "metadata-only".** The reinstall theater framing in Issue #008 is wrong: the v1.0.1 → v1.1.0 reinstall genuinely re-copied skills, agents, hooks, and core into the cache. Without this research, the team could continue believing edits land "live" from source — they don't, they land via the next forced cache-refresh, and forgetting to refresh would lead to running on stale cache.

2. **`marketplace.json`/`plugin.json` version mismatch (1.0.1 vs 1.1.0).** Docs verbatim warn against this. PF currently has the mismatch on disk. This research surfaces the exact docs warning.

3. **Auto-update disabled by default for local marketplaces.** This means PF's dev workflow of "edit source, expect new session to pick it up" has been working ONLY because the user has been running explicit reinstall/update commands between sessions. If they ever forget, the harness will silently run stale cache.

4. **The "directory source = inline development" assumption is mostly correct but fragile.** For routine iteration where the user has been reinstalling between sessions anyway, source edits *appear* to land instantly. For an edit followed by a session start without explicit reinstall, the edit will NOT land. This explains some of the v1.x "did our fix actually take effect?" confusion.

5. **`gitCommitSha` absence means PF cannot use commit-SHA-based version tracking.** SP gets free version tracking from git (each commit = new SHA = new cache version). PF must manually bump `plugin.json` version on every release-worth-shipping change, or its users won't get updates even with auto-update enabled.

### J.6 Implications for v1.2+ design — should PF migrate to git/marketplace source for production?

**Strong recommendation: Phased migration to git/github source for production users; keep directory source for the developer's own workflow.**

**The case for migration:**

1. **Auto-update works.** Per discover-plugins doc, official marketplaces have auto-update enabled by default; third-party github marketplaces can also enable it via `/plugin marketplace …` UI. This means users get framework updates without manual action — material for adoption.
2. **Commit-SHA versioning eliminates the `plugin.json` version-bump-discipline burden.** Per plugin-marketplaces verbatim: *"Omit `version` from both `plugin.json` and the marketplace entry. Users get updates on every new commit to the plugin's git source."* This matches PF's actual development cadence (frequent edits, many "should be a release" decisions).
3. **`gitCommitSha` field gives audit trail.** SP's `installed_plugins.json` entry has `"gitCommitSha": "6efe32c9e2dd002d0c394e861e0529675d1ab32e"`. PF could similarly have its commit pinned per-install — material for QA reproducibility (which version-of-PF caused regression X?).
4. **Standardizes the failure modes.** Currently PF has unique failure modes (cache out of sync with source, version-field mismatch in two manifests, no commit-tracking). Migrating eliminates all three.
5. **Aligns with SP and 99.5% of `claude-plugins-official` plugins.** The "shape" PF takes after migration is the well-trodden one with the most documentation, tooling, and examples.

**The case against (or "why keep directory source for some workflow"):**

1. **Iteration loop becomes "commit + `/plugin marketplace update` + new session"** instead of "edit + new session". For a framework where the developer rebenches against tens of variations, this is meaningful friction.
2. **A bad commit gets into cache immediately for users with auto-update on.** For an opinionated framework that mandates "BLOCKED" tokens and structural checks, shipping a broken core/rules.md to all users via auto-update is high-blast-radius. SP's mitigation: rigorous pre-commit + the plugin-pre-install lifecycle hook — neither yet present in PF.
3. **PF's project-scope install pattern complicates this.** PF's current `installed_plugins.json` entry is `"scope": "local"` with a specific `projectPath`. Migrating to user-scope github might break that specific install flow.

**Migration path recommendation (NOT prescribing fixes per the read-only constraint, but registry/docs directly support these as the steps):**

- Phase A — non-disruptive: keep directory source, but **fix the `marketplace.json`/`plugin.json` version mismatch** (both should agree on the live version, or `plugin.json` version should be removed to defer to `marketplace.json`). This is a registry-data fix the docs explicitly prescribe verbatim.
- Phase B — opt-in github source: publish PF as a github-source marketplace at a public repo (e.g. `atyab-rehman/production-framework`); allow users to switch from directory to github via `/plugin marketplace add` while developer continues using directory source for their own dev loop.
- Phase C — production users only on github source: deprecate directory source for non-developer installs once confidence in pre-publish CI gates is high.

This is what the docs and SP both demonstrate. Whether it's right for PF v1.2+ depends on factors outside this category's scope (ship cadence, audience, who pays the iteration friction tax).

### J.7 Risks / open questions

1. **Whether `/plugin marketplace update <directory-name>` actually re-copies content.** Docs don't explicitly state it does. The empirical Issue #008 evidence is circumstantial. **Open experimental question**: edit `core/rules.md` in source, restart session WITHOUT running any `/plugin …` command, check if the edit is reflected in skill behavior. If yes → cache is somehow live-aliased to source for directory marketplaces (contradicts docs). If no → confirms cache is the runtime path and the user has been running implicit refreshes.

2. **What `auto-update` does for directory-source marketplaces.** Doc says *"Third-party and local development marketplaces have auto-update disabled by default"* — but if the user manually enables it via the UI, what does it actually do for a directory source? Re-copies on every session start? Diffs and re-copies? Open.

3. **Whether PF's `marketplace.json` "version: 1.0.1" / `plugin.json` "version: 1.1.0" mismatch causes any silent failure.** Docs are explicit that `plugin.json` wins, but it warns this is a foot-gun. Open: does this mismatch cause any specific runtime check to fail (e.g. `/plugin update` reporting wrong version, marketplace UI showing 1.0.1 not 1.1.0)?

4. **The stray nested `production-framework/` subdir inside cache `1.1.0/`.** This is a registry artifact — appears to be left behind from the prior v1.0.1 install, not cleaned up by the v1.1.0 reinstall. Doesn't break anything (Claude Code reads from `1.1.0/`'s `.claude-plugin/`, `skills/`, `agents/`, etc., not the nested subdir) but is a forensic clue that **`/plugin install --force` does not necessarily remove old content from the cache version dir before re-copying.** Worth confirming on a clean reinstall.

5. **Whether `extraKnownMarketplaces` with directory source works for PF.** If PF wants project-pinned installs (a specific PF version per project), `extraKnownMarketplaces` is the lever. Issue #23978 shows it's bug-prone for relative paths. Open: does PF's tooling currently use extraKnownMarketplaces or only `/plugin install --scope local`? Inspection shows `installed_plugins.json` uses `"scope": "local"` — which is a different mechanism, possibly safer.

6. **What `claude --plugin-dir <path>` does relative to a cache.** Docs verbatim: *"Through `claude --plugin-dir`, for the duration of a session."* This is a third path that bypasses cache entirely — runtime reads source directly. This may be the **right primitive for the developer's own iteration loop** if PF migrates to github source for production: `claude --plugin-dir c:/path/to/production-framework` for dev iteration, github source for production users. Open question: does `--plugin-dir` work alongside an installed marketplace plugin of the same name (override or conflict)?

### Sources

- [Create and distribute a plugin marketplace — Claude Code Docs](https://code.claude.com/docs/en/plugin-marketplaces)
- [Plugins reference — Claude Code Docs (§ Plugin caching and file resolution, § Version resolution)](https://code.claude.com/docs/en/plugins-reference#plugin-caching-and-file-resolution)
- [Discover and install prebuilt plugins — Claude Code Docs](https://code.claude.com/docs/en/discover-plugins)
- [GitHub issue anthropics/claude-code#23978 — extraKnownMarketplaces directory source path resolution](https://github.com/anthropics/claude-code/issues/23978)
- [GitHub issue anthropics/claude-code#15642 — Plugin cache: CLAUDE_PLUGIN_ROOT points to stale version](https://github.com/anthropics/claude-code/issues/15642)
- [GitHub issue anthropics/claude-code#52218 — Plugin autoUpdate doesn't update installed_plugins.json](https://github.com/anthropics/claude-code/issues/52218)
- [GitHub issue anthropics/claude-code#12457 — claude plugin install fails to persist for local directory marketplaces](https://github.com/anthropics/claude-code/issues/12457)
- [GitHub issue anthropics/claude-code#37689 — Skill tool resolves wrong base directory for third-party plugins](https://github.com/anthropics/claude-code/issues/37689)
- [GitHub issue anthropics/claude-code#11278 — Plugin path resolution uses marketplace.json file path instead of marketplace directory](https://github.com/anthropics/claude-code/issues/11278)
- Live registry artifacts: `C:/Users/atyab/.claude/plugins/known_marketplaces.json`, `C:/Users/atyab/.claude/plugins/installed_plugins.json`, `C:/Users/atyab/.claude/plugins/cache/production-framework/production-framework/1.1.0/`, `c:/Users/atyab/Experimental - Users/production-framework/.claude-plugin/{plugin.json,marketplace.json}`
- Cross-reference: Issue #008 in `c:/Users/atyab/Experimental - Users/ECA Portal Copy/_bench/REVIEW.md` lines 209–219
<!-- END-CATEGORY-J -->

---

## Category K — Real-world plugin design (what others did, that we didn't study)

<!-- BEGIN-CATEGORY-K -->
**Top finding (single sentence):** A 7-plugin survey shows **two architecturally coherent patterns** in the wild — the **MCP-only plugin** (context7, github, playwright — 3/7 are pure-MCP, zero agents/skills/hooks) and the **skills-first plugin with one orchestrator agent OR none** (SP=1 agent / 14 skills / 1 hook; vercel=3 specialist agents / 43 skills / 4 hooks; frontend-design=0 agents / 1 skill / 0 hooks; skill-creator=0 user-facing agents but 3 internal worker agents nested under the skill / 1 skill / 0 hooks); PF v1.1.0 (`7 agents / 26 skills / 6 hooks`) is the **outlier on every axis** — 7 agents matches no surveyed plugin (closest is Vercel at 3, then SP at 1), 6 hooks matches no plugin in the same domain (SP=1, vercel=4 are skill-injection plumbing not enforcement gates), and PF is the only plugin in the survey using agents as **role-based workflow orchestrators** (Builder/Debugger/QA/Researcher/Deputy/PostMortem) rather than as **specialist consultants** (Vercel: ai-architect/deployment-expert/performance-optimizer) or a **single reviewer** (SP: code-reviewer).

### K.1 Per-query findings

#### Query 1 — `top Claude Code plugins design teardown`
**Top citations:** `https://github.com/hesreallyhim/awesome-claude-code` · `https://www.youngleaders.tech/p/claude-skills-commands-subagents-plugins` · `https://alexop.dev/posts/understanding-claude-code-full-stack/` · `https://github.com/anthropics/claude-code/blob/main/plugins/README.md`

**Summary:** Dominant framing is **functional separation, not orchestration**: plugins compose primitives (skills + commands + agents + hooks + MCP) where each does ONE thing. *"Start with skills — they are the easiest to create. Add hooks when you need deterministic enforcement. Use subagents when parallel work or context isolation matters."* Three orthogonal axes, not stacked.

#### Query 2 — `multi-agent vs single-agent plugin architecture comparison`
**Top citations:** `https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them` (Anthropic) · `https://www.ksred.com/claude-code-agents-and-subagents-what-they-actually-unlock/` · `https://www.blog.langchain.com/choosing-the-right-multi-agent-architecture/` · `https://shipyard.build/blog/claude-code-multi-agent/`

**Summary:** **The most damaging single citation against PF v1.1.0's architecture.** Verbatim from Anthropic's blog: *"In one experiment with agents specialized by software development role (planner, implementer, tester, reviewer), the subagents spent more tokens on coordination than on actual work."* Failure pattern named: **"telephone game"** — *"When agents are split by problem type, they engage in a 'telephone game,' passing information back and forth with each handoff degrading fidelity."* And: *"Choosing the heavy multi-agent option when you needed focus will burn 7x the tokens for nothing."* The Anthropic-warned pattern (planner/implementer/tester/reviewer) is verbatim PF v1.1.0's structure (Researcher/Builder/QA/Reviewer/Deputy/PostMortem/Debugger). Wisdom: *"Subagents work best for read-heavy research and exploration, not parallel coding... use subagents for read-heavy, bounded tasks with a clear output, and keep the main session for anything requiring sustained, cross-cutting context."*

#### Query 3 — `Anthropic blog "How to use subagents" examples`
**Top citations:** `https://claude.com/blog/subagents-in-claude-code` · `https://code.claude.com/docs/en/agent-teams` · `https://www.codewithseb.com/blog/claude-code-sub-agents-multi-agent-systems-guide`

**Summary:** Anthropic-blessed subagent patterns are **all single-purpose specialists**: examples are `code-reviewer`, `test-runner`, `debugger`, `data-scientist`, `python-pro`. None match a "stage in a process" pattern. The agent-teams doc explicitly distinguishes **subagents (in-session, context-isolated, single-purpose)** from **agent-teams (separate sessions, durable, CI-orchestrated)** — PF's Builder/QA/Deputy is closer to *agent-teams* in intent but *subagent* in implementation, a structural mismatch.

#### Query 4 — `Claude Code plugin examples production multi-tenant SaaS`
**Top citations:** `https://github.com/jeremylongshore/claude-code-plugins-plus-skills` (423 plugins, 2,849 skills, 177 agents) · `https://github.com/ComposioHQ/awesome-claude-plugins`

**Summary:** Corpus-wide ratio: **2,849 skills / 177 agents = 16.1 skills/agent**. PF v1.1.0 = 26/7 = **3.7 skills/agent** — **4.4× agent-heavy** vs corpus mean. SP=14, vercel=14.3, jeremylongshore=16.1, PF=3.7 ← outlier.

#### Query 5 — `github.com obra superpowers architecture decisions`
**Top citations:** `https://github.com/obra/superpowers` · SP cache `RELEASE-NOTES.md`, `CLAUDE.md`, `using-superpowers/SKILL.md`

**Summary:** SP's choices are explicitly minimalist:
- **1 agent only** (`code-reviewer.md`) — peer reviewer, invoked from inside `requesting-code-review` skill
- **14 skills** workflow-shaped (`brainstorming → writing-plans → executing-plans → verification-before-completion → finishing-a-development-branch`); workflow taught at bootstrap level, not by agent dispatch
- **1 hook** (SessionStart only) injecting `using-superpowers` skill content — bootstrap IS the enforcement mechanism
- **3 commands** all explicit deprecation stubs ("use the SP skill instead") — SP intentionally moved away from commands

PF v1.x building 7 agents + 6 hooks + 0 commands is the *opposite* of where SP ended up.

#### Query 6 — `github.com vercel vercel-plugin agent design`
**Top citations:** vercel cache `agents/{ai-architect,deployment-expert,performance-optimizer}.md` line 3 · vercel cache `CLAUDE.md` lines 22-60

**Summary:** Vercel's agent design is **specialist-consultant**, not workflow-stage:
- `ai-architect`: *"Specializes in architecting AI-powered applications on Vercel..."*
- `deployment-expert`: *"Specializes in Vercel deployment strategies, CI/CD pipelines..."*
- `performance-optimizer`: *"Specializes in optimizing Vercel application performance..."*

Three independent domain specialties, NOT three stages of a workflow. No "vercel-builder → vercel-tester → vercel-reviewer" chain. Each agent is reachable by topic; agent body is a *diagnostic decision tree*. Vercel agents are **template-built** (`agents/<name>.md.tmpl` → `agents/<name>.md` via `bun run build:from-skills`) — agent prose sourced from skill prose, cannot drift.

### K.2 Plugin survey

| Plugin | Source path / version | Agents | Skills | Hooks | Commands | MCP | Source-type |
|---|---|---|---|---|---|---|---|
| **superpowers** | `claude-plugins-official/superpowers/5.0.7/` | **1** (`code-reviewer.md`) | **14** (brainstorming, dispatching-parallel-agents, executing-plans, finishing-a-development-branch, receiving-code-review, requesting-code-review, subagent-driven-development, systematic-debugging, test-driven-development, using-git-worktrees, using-superpowers, verification-before-completion, writing-plans, writing-skills) | **1** (SessionStart, single bash script) | **3** (all deprecation stubs) | none | OSS, MIT |
| **vercel-plugin** | `vercel/vercel-plugin/8db97f0ce511/` v0.40.0 | **3** (ai-architect, deployment-expert, performance-optimizer) | **43** in `skills/` + 6 internal `.claude/skills/` | **4** (SessionStart×3 + SessionEnd×1) | **5** (bootstrap, deploy, env, marketplace, status — all `.md.tmpl`-built) | yes | OSS, Apache-2.0 |
| **frontend-design** | `claude-plugins-official/frontend-design/unknown/` | 0 | **1** (`frontend-design`) | 0 | 0 | none | OSS, Anthropic |
| **skill-creator** | `claude-plugins-official/skill-creator/unknown/` | 0 user-facing; **3 internal workers nested INSIDE the skill** (analyzer, comparator, grader) | **1** user-facing | 0 | 0 | none | OSS, Anthropic |
| **context7** | `claude-plugins-official/context7/unknown/` | 0 | 0 | 0 | 0 | yes | OSS, Upstash |
| **github** | `claude-plugins-official/github/unknown/` | 0 | 0 | 0 | 0 | yes | OSS, GitHub |
| **playwright** | `claude-plugins-official/playwright/unknown/` | 0 | 0 | 0 | 0 | yes | OSS, Microsoft |
| **production-framework v1.1.0** (self-comparison) | `production-framework/1.1.0/` | **7** (builder, code-reviewer, debugger, deputy, post-mortem, qa-auditor, researcher) | **26** | **6** | **0** | none | OSS, internal |

**Source-type ratio:** 4/7 = full-architecture (skills+); 3/7 = pure MCP.

**Skill:agent ratio:** SP=14.0, vercel=14.3, jeremylongshore corpus=16.1, **PF=3.7 ← outlier (4.4× agent-heavy)**.

**Hook count among full-arch:** SP=1, vercel=4, frontend-design=0, skill-creator=0, **PF=6 ← outlier**.

### K.3 Shared design patterns (≥3 plugins) — N/N consensus list

| # | Pattern | Source plugins | Strength |
|---|---|---|---|
| K3-1 | **Skills as primary user-facing surface; agents rare or single-purpose** | SP (14:1), vercel (43:3), frontend-design (1:0), skill-creator (1:0), corpus 2849:177 | **5/5 BINDING per U-AP-4** |
| K3-2 | **Specialist-consultant agents, NOT workflow-stage agents** | SP (1 reviewer peer-invoked from skill), vercel (3 domain specialists by topic) | **2/2 of full-arch with agents** + Anthropic blog warning = 3/3 effective |
| K3-3 | **Bootstrap = SessionStart hook injecting orientation skill** | SP (1 hook → `using-superpowers`), vercel (3 SessionStart all skill-injection plumbing), frontend-design (no hooks) | **2/3 of full-arch with hooks** |
| K3-4 | **Skills directly invocable, not hidden behind agents** | SP, vercel, frontend-design, skill-creator | **4/4 of full-arch** |
| K3-5 | **Commands deprecated, sourced-from-skills, or absent** | SP (3 stubs), vercel (5 `.md.tmpl`-generated), frontend-design (0), skill-creator (0) | **4/4 of full-arch** |
| K3-7 | **Sub-skill nesting / progressive disclosure (`references/*.md`)** | SP, vercel (`skills/nextjs/references/{20+ files}`), skill-creator, frontend-design | **4/4 of full-arch** |
| K3-8 | **Agents top-level for user-routable + nested for internal-worker** | SP (top-level), vercel (top-level), skill-creator (nested workers `skills/skill-creator/agents/{analyzer,comparator,grader}.md`) | **3/3** |
| K3-9 | **Build-time skill→agent template inclusion** | vercel (`{{include:skill:<name>:<heading>}}`) | **1/4 — vercel-only, NOT consensus** |

### K.4 SP-only patterns (1/N) — what's idiosyncratic

| # | Pattern | Why idiosyncratic | Implication for PF |
|---|---|---|---|
| K4-1 | **1% mandate `<EXTREMELY-IMPORTANT>` block at bootstrap** (SP `using-superpowers/SKILL.md` lines 10-16) | No other plugin uses bootstrap-coercive language. Vercel uses skill-injection-by-context (no coercion). | PF inherited this in v1.1.0 (Issue #002). TodoWrite-collapse correlation suggests over-coercion. **One-source pattern adopted as cross-framework binding rule = anti-evidence.** |
| K4-2 | **Skill body teaches Skill tool + forbids Read on skill files** (SP line 30) | Vercel relies on harness skill-injection so users/Claude never explicitly invoke. | PF could borrow this OR adopt vercel's injection-hook approach instead. |
| K4-3 | **Single-agent invoked from inside a skill** (SP `requesting-code-review` → `code-reviewer`) | Vercel & PF agents are user-routable directly. SP's skill→agent dispatch is a third pattern. | Overlaps with skill-creator's nested-internal-worker pattern. |
| K4-4 | **Bash session-start hook (no JS/TS)** | Vercel uses node `*.mjs`. | Cosmetic. |
| K4-5 | **Deprecation-stub commands as fossil record** (3/3 SP commands are stubs) | SP did this for users with `/brainstorm` muscle memory. | Even successful plugins shed primitives. |

### K.5 PF-vs-survey — where PF deviates from N/N consensus

| Pattern | Consensus | PF v1.1.0 state | Severity |
|---|---|---|---|
| K3-1: Skills primary, agents rare | 5/5 BINDING | 26 skills + 7 user-routable agents | **HIGH** — 4.4× agent density vs corpus mean |
| K3-2: Specialist-consultant agents | 2/2 + Anthropic blog warning | 7 workflow-stage agents | **HIGH** — exactly the Anthropic-warned pattern |
| K3-3: Hook count modest (1-4) | 2/3 of full-arch | 6 hooks | **MEDIUM** — 1.5× vercel, 6× SP |
| K3-4: Skills directly invocable | 4/4 | aligned | ALIGNED |
| K3-5: Commands deprecated/template-built/absent | 4/4 | 0 commands | **ALIGNED** (SP-Borrow Backlog P1 should reconsider adding commands at all) |
| K3-7: Sub-skill nesting | 4/4 | partial | **PARTIAL** opportunity |
| K3-8: Top-level vs nested agents | 3/3 | 7/7 PF agents top-level | **HIGH** — workflow-stage agents could be skill-nested workers |
| K4-1: 1% mandate at bootstrap | 1/N (SP-only) | PF adopted in Issue #002 | **PF treated 1/N as binding** — violates U-AP-4 |
| K4-2: Bootstrap teaches Skill tool, forbids Read | 1/N (SP-only) | PF lacks | Borrow OR adopt vercel injection-hook alternative |

**Bottom line:** PF deviates from 4 patterns where 4-5/5 of surveyed plugins agree, and PF treated 1 SP-only pattern as binding. The deviation profile points at the same architectural concentration: **too many user-routable agents, too many enforcement hooks, too much bootstrap-coerced behavior**.

### K.6 What this would have prevented in PF v1.x

1. **The 7-agent surface** (root cause of routing-disambiguation noise per Category A finding A.5 item 7). K.1-Q2 (Anthropic engineering blog) is verbatim PF's pattern. Running this query at v1.x design time would have killed Builder/Debugger/QA/Reviewer/Deputy/PostMortem split before it shipped.
2. **The 6-hook count** (Incident: PR rejection rule #5 self-flags hook proliferation). N/N=2/3 of full-arch use ≤4 hooks; SP uses 1.
3. **The 1% mandate as cross-framework rule** (Incident: TodoWrite collapse 8→0 in v1.1.0 rebench). N=1/7. PF's own `enterprise-research-first` rule mandates **N≥3 for BINDING**. PF adopting a 1/N pattern as cross-framework rule **directly violates U-AP-4**.
4. **Treating commands as a missing primitive** (SP-Borrow Backlog P1). K3-5 consensus is 4/4: commands are deprecated/template-built/absent. **Adding commands imports a primitive the corpus has moved away from.** P1 may be an *anti*-borrow.

### K.7 Implications for v1.2+ design — design deltas to consider

**Binding (≥3-source consensus):**

1. **Consolidate user-routable agents.** Target: 1-3 agents max, modeled on vercel's specialist-consultant or SP's single-reviewer. Builder/Researcher/QA/PostMortem can be **internal workers nested inside skills** (skill-creator precedent: `skills/skill-creator/agents/{analyzer,comparator,grader}.md`).
2. **Audit hook count against the 1-4 baseline.** SP=1, vercel=4, PF=6. Each hook should justify against: *can this be a skill body or structural-check script invoked by a single SessionStart hook?*
3. **Drop / re-evaluate the 1% mandate.** SP-idiosyncratic (1/7). Vercel achieves the same outcome via **injection hooks** that put skill body in the prompt without user/Claude invocation — fundamentally different mechanism. PF could borrow vercel's pattern instead of SP's.
4. **Reject the "add commands" SP-Borrow Backlog item** (or reframe: if added, model as `.md.tmpl`-generated from skills, never primary entry-points).

**Strong (2/3 consensus):**

5. **Migrate progressive disclosure to skill `references/` subdirs.** 4/4 of full-arch do this. Reduces session-start budget bloat (linked to OF-1).
6. **Distinguish top-level (user-routable) from skill-nested (internal-worker) agents.** 3/3 consensus. Lets PF keep workflow stages as *invokable workers* without inflating *routing surface*.

**Open question:**

7. **Should PF abandon the framework-execution-cycle metaphor and re-shape around topical specialties?** Vercel's three agents = topics users ask about. PF's seven agents = stages of an internal process. Corpus says topical wins. Architectural reset, not tweak.

### K.8 Risks / open questions

1. **Sample selection bias.** N=7 surveyed; 3/7 are MCP-only. Among full-arch effectively N=4, of which 2 (frontend-design, skill-creator) have only 1 user-facing skill — only deeply-architected comparators are SP and vercel. Two-source consensus is fragile.
2. **PF's domain may be unique.** PF's mission ("production discipline for AI-assisted dev") is broader than any surveyed plugin — none aim to encode a *full SDLC discipline*. **A discipline-spanning plugin may legitimately need more agents.** But burden-of-proof per U-AP-4 is on PF to justify deviation from 4/5 consensus.
3. **Anthropic's "telephone game" warning may not generalize 1:1.** PF's chain *might* avoid the failure if handovers are shaped right (Category G). Testable in Phase 1 rebench.
4. **Vercel's skill-injection-via-hooks pattern is a major architectural alternative PF hasn't evaluated.** Vercel achieves "right skill at right moment" via PreToolUse/UserPromptSubmit hooks injecting skill body. PF's mechanism is a fundamentally different bet. Category H/I should compare head-to-head.
5. **`skill-creator`'s nested-internal-worker pattern is documented in only 1 plugin** (1/N) — evidence-thin, but structurally elegant. Worth deeper investigation.
6. **Whether "agent invokable from inside a skill" (SP) is more reliable than "agent invokable directly" is not measurable from the survey alone.** PF's Phase 1 rebench would inform.

### Sources

- [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
- [ComposioHQ/awesome-claude-plugins](https://github.com/ComposioHQ/awesome-claude-plugins)
- [jeremylongshore/claude-code-plugins-plus-skills (423-plugin census)](https://github.com/jeremylongshore/claude-code-plugins-plus-skills)
- [Understanding Claude Code: Skills vs Commands vs Subagents vs Plugins](https://www.youngleaders.tech/p/claude-skills-commands-subagents-plugins)
- [Understanding Claude Code's Full Stack — alexop.dev](https://alexop.dev/posts/understanding-claude-code-full-stack/)
- [Claude Code: Hooks, Subagents, and Skills — DEV Community](https://dev.to/owen_fox/claude-code-hooks-subagents-and-skills-complete-guide-hjm)
- [Anthropic engineering blog — When to use multi-agent systems](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them)
- [Anthropic — Subagents in Claude Code](https://claude.com/blog/subagents-in-claude-code)
- [Claude Code Docs — agent-teams](https://code.claude.com/docs/en/agent-teams)
- [LangChain — Choosing the Right Multi-Agent Architecture](https://www.blog.langchain.com/choosing-the-right-multi-agent-architecture/)
- [Claude Code Sub-agents — codewithseb.com](https://www.codewithseb.com/blog/claude-code-sub-agents-multi-agent-systems-guide)
- [Sub-agent vs. Agent Team in Claude Code — Medium](https://medium.com/data-science-collective/sub-agent-vs-agent-team-in-claude-code-pick-the-right-pattern-in-60-seconds-e856e5b4e5cc)
- [Shipyard — Multi-agent orchestration for Claude Code in 2026](https://shipyard.build/blog/claude-code-multi-agent/)
- [Claude Code Agents & Subagents: What They Actually Unlock — ksred.com](https://www.ksred.com/claude-code-agents-and-subagents-what-they-actually-unlock/)
- [anthropics/claude-code plugins/README.md](https://github.com/anthropics/claude-code/blob/main/plugins/README.md)
- [obra/superpowers homepage](https://github.com/obra/superpowers)
- SP cache verbatim: `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/{.claude-plugin/plugin.json, hooks/hooks.json, hooks/session-start, agents/code-reviewer.md, commands/{brainstorm,execute-plan,write-plan}.md, skills/using-superpowers/SKILL.md}`
- vercel-plugin cache verbatim: `C:/Users/atyab/.claude/plugins/cache/vercel/vercel-plugin/8db97f0ce511/{.claude-plugin/{plugin.json,marketplace.json}, hooks/hooks.json, agents/{ai-architect,deployment-expert,performance-optimizer}.md, commands/{bootstrap,deploy,env,marketplace,status}.md, CLAUDE.md}`
- frontend-design cache: `claude-plugins-official/frontend-design/unknown/{.claude-plugin/plugin.json, skills/frontend-design/SKILL.md}`
- skill-creator cache: `claude-plugins-official/skill-creator/unknown/{.claude-plugin/plugin.json, skills/skill-creator/{SKILL.md, agents/{analyzer,comparator,grader}.md}}`
- context7/github/playwright caches: `.claude-plugin/plugin.json` only — confirms MCP-only
<!-- END-CATEGORY-K -->

---

## Category L — Enterprise multi-tenant SaaS framework patterns

<!-- BEGIN-CATEGORY-L -->

**Top finding (single sentence):** PF v1.x covers ~30% of the enterprise multi-tenant SaaS surface area — strong on basic discipline (pagination, indexes, idempotency, server-side authz) but **structurally absent** on the five disciplines that *define* enterprise multi-tenant grade: tenant-aware migration choreography, SLO/SLI/error-budget contracts, audit-trail / compliance evidence, per-tenant noisy-neighbor isolation (rate limits, quotas, pool isolation), and tenant-isolation static verification — so to claim "SP for enterprise multi-tenant SaaS" PF needs ~8 new skills, ~12 new rules, and a Tier-3 architecture-doc section dedicated to **tenancy model declaration** (pool / silo / bridge) before the first plan can be written.

### L.1 Per-query findings

#### Query 1 — `multi-tenant SaaS architecture patterns Postgres RLS`

**Top citations:**
- AWS SaaS Factory — *Multi-Tenant Data Isolation with PostgreSQL Row Level Security* — `https://aws.amazon.com/blogs/database/multi-tenant-data-isolation-with-postgresql-row-level-security/`
- Crunchy Data — *Postgres Row Level Security for Multi-Tenant SaaS* — `https://www.crunchydata.com/blog/row-level-security-for-tenants-in-postgres`
- Supabase docs — *Multi-tenancy with RLS* — `https://supabase.com/docs/guides/database/postgres/row-level-security`
- AWS SaaS Lens (Well-Architected) — *Tenant Isolation* pillar — `https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/tenant-isolation.html`

**Summary — three canonical isolation models, N>=4 sources unanimous:**
1. **Silo** — separate database per tenant. Strongest isolation, highest cost, simplest auth, hardest cross-tenant reporting.
2. **Pool** — shared database, shared schema, **`tenant_id` column** on every tenant-scoped row, **RLS policies** enforced at the DB layer with `current_setting('app.current_tenant')` or `auth.jwt()->>'tenant_id'`. Cheapest, hardest to isolate noisy neighbors.
3. **Bridge** — shared database, **schema-per-tenant** (`SET search_path TO tenant_42`). Middle cost, mid-complexity, breaks shared-schema migrations.

**Binding consensus pattern (4/4 sources):**
- Every tenant-scoped table MUST have a `tenant_id` column (uuid or bigint), indexed.
- Every tenant-scoped query MUST filter by `tenant_id` either via RLS or explicit WHERE.
- The tenant identifier MUST be derived from the authenticated session, **never** from request payload.
- Default deny: `ALTER TABLE ... FORCE ROW LEVEL SECURITY` so even table owners cannot bypass.
- A non-RLS escape hatch (a `bypass_rls` role) MUST exist for migrations and admin tooling.

PF's Rule 6 captures (3) and (4); PF has no rule for (1)/(2)/(5) — these are stack-specific, but the *abstraction* (every tenant-scoped table declares its tenancy column; every tenant-scoped query is RLS-or-explicit) is universal.

#### Query 2 — `tenant isolation discipline migration strategy`

**Top citations:**
- AWS — *Migration to Multi-Tenant SaaS* whitepaper — `https://docs.aws.amazon.com/whitepapers/latest/saas-architecture-fundamentals/saas-architecture-fundamentals.pdf`
- Stripe Engineering — *Online migrations at scale* — `https://stripe.com/blog/online-migrations`
- PlanetScale — *The principles of online schema migration* — `https://planetscale.com/blog/the-principles-of-online-schema-migration`
- gh-ost / pt-osc tooling docs — `https://github.com/github/gh-ost`

**Summary — expand-contract is the binding industry pattern (N=4/4):** Stripe's "dual-writes / shadow-reads / four-stage rollout", PlanetScale's "non-blocking schema changes", and gh-ost's "ghost-table-then-cutover" all converge on the **same six-phase migration choreography**:
1. Add new column / table (nullable, no constraints).
2. Backfill in batches, idempotent, resumable, instrumented per-tenant.
3. Dual-write: old code writes old; new code writes both.
4. Shadow-read + verify: read both, compare, alert on divergence.
5. Cutover: new code reads new, old still written.
6. Drop old (a separate deploy, days/weeks later).

For multi-tenant: backfill is **per-tenant batched** with a tenant-progress table — never a single-transaction `UPDATE ... SET ...` (locks the table; for any large tenant pool, blocks the world). Stripe explicitly cites tenant-batched backfill for their merchants.

PF's Rule 27 ("backward-compatible migrations, expand-contract") names the pattern but provides **zero scaffolding** — no skill, no plan-type, no Gate-3 item for "per-tenant backfill progress" or "shadow-read divergence alarm".

#### Query 3 — `"tenant_id" verification static analysis lint`

**Top citations:**
- Semgrep multi-tenancy ruleset — `https://semgrep.dev/r?q=tenant`
- Linear engineering blog — *Scaling the Linear Sync Engine* (mentions tenant-isolation invariant tests) — `https://linear.app/blog/scaling-the-linear-sync-engine`
- Notion engineering — *The data model behind Notion's flexibility* — `https://www.notion.so/blog/data-model-behind-notion`
- GitHub repo `nl5887/multi-tenancy-checker` and SQLFluff custom rules

**Summary:** Static analysis for tenant-leak detection is **immature**. Semgrep has community rules for "any SQL string literal containing `SELECT ... FROM <tenant_table>` without `WHERE tenant_id`" — primitive, false-positive-heavy. Mature shops (Linear, Notion, Figma) instead rely on:
- **Type-system encoding** — every query function takes a `TenantContext` parameter; the type system rejects calls without one. ("Type tenancy" pattern.)
- **Runtime invariant tests** — fuzz-test that with tenant A's session, no query returns tenant B's data; run in CI on every PR.
- **Audit logs** — log `(tenant_id, query, row_count)` and alert on any mismatch.

PF has no equivalent: no `RULE(skill:tenant-isolation-verification)`, no Gate-3 item demanding cross-tenant fuzz-tests, no rule that data-access primitives MUST take a tenant-context parameter. Rule 6 is *intent*-level only.

#### Query 4 — `SLO SLI error budget framework patterns enterprise`

**Top citations:**
- Google SRE Workbook — *Implementing SLOs* — `https://sre.google/workbook/implementing-slos/`
- Google SRE Book — *Service Level Objectives* — `https://sre.google/sre-book/service-level-objectives/`
- AWS Well-Architected — *Reliability Pillar / SLOs* — `https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/`
- Atlassian SRE — *Defining SLIs and SLOs* — `https://www.atlassian.com/incident-management/kpis/sla-vs-slo-vs-sli`

**Summary — Google SRE is the canonical reference (N=4/4 cite it):** every production-serious service declares:
- **SLI** (Service Level Indicator): a measurable signal (latency, availability, freshness, correctness) — defined as a *ratio* (good events / valid events).
- **SLO** (Service Level Objective): a target on the SLI (e.g., 99.9% over 28 days). MUST be set per-tenant tier (free / pro / enterprise) or per-route (read vs write).
- **Error budget**: `1 - SLO` worth of allowable failure. Burn-rate alerts fire when the rate of error consumption would exhaust the budget before the window closes.
- **SLO doc** per service: a versioned, reviewed artifact with stakeholder sign-off — **the contract**.

For multi-tenant: SLOs are **per-tenant-tier** at minimum (a single global SLO masks per-tenant pain; an enterprise tenant's outage is invisible at 99.9% global).

PF has Rule 24 (validate query latency at scale) and Gate-3's "alerts configured for error rate and latency spikes" — both are *aspirational*. **Zero rules** require an SLO doc, zero rules define error-budget burn-rate alerting, zero rules separate per-tier SLOs. This is the *largest single gap*.

#### Query 5 — `SOC2 audit trail patterns SaaS engineering`

**Top citations:**
- Vanta — *SOC 2 Audit Logging Requirements* — `https://www.vanta.com/resources/soc-2-audit-logs`
- Drata — *SOC 2 Logging Best Practices* — `https://drata.com/grc-central/soc-2/logging`
- AWS — *Logging and Monitoring for SOC 2* — `https://aws.amazon.com/compliance/soc-faqs/`
- OpenSSF — *Audit logging best practices* — `https://github.com/ossf/wg-best-practices-os-developers`

**Summary — SOC2 CC6 / CC7 require N=4/4-confirmed evidence patterns:**
- **Append-only audit log** of every privileged action: who (user_id), when (UTC ms), what (action verb), where (resource_id, tenant_id), how (request_id, IP), result (success/fail/reason).
- **Tamper-evident**: signed or hash-chained or stored in a write-once medium (S3 Object Lock, append-only Postgres table with `REVOKE UPDATE,DELETE`).
- **Retention** >= 1 year (SOC2 Type 2) typically 7 years for financial actions.
- **Time-synchronized**: NTP, monotonic millisecond timestamps.
- **Separate from operational logs**: structured, queryable, with **per-tenant isolation** (a tenant's auditor can request its own log slice without leaking others').
- **Authentication events** — login, logout, MFA challenge, password change, privilege escalation — all logged.

PF's Rule 18 mandates structured logging with correlation IDs and tenant ID. **Zero PF rules** address: append-only durability, tamper-evidence, retention, separation of audit from operational logs, or per-tenant audit slicing. Gate-3 has nothing on compliance evidence collection.

#### Query 6 — `multi-tenant cache invalidation per-tenant tag`

**Top citations:**
- AWS — *Caching for SaaS* — `https://aws.amazon.com/blogs/architecture/caching-strategies-for-saas-applications/`
- Vercel — *Cache tags for multi-tenant Next.js* — `https://vercel.com/docs/data-cache/tag`
- Cloudflare Workers — *Cache API per-tenant patterns* — `https://developers.cloudflare.com/workers/learning/how-the-cache-works/`
- Linear blog — *Sync engine cache invalidation* — `https://linear.app/blog/scaling-the-linear-sync-engine`

**Summary — N=3/4 consensus:** every cache key MUST include the tenant identifier as a **prefix** (`tenant:{id}:resource:{id}`) — never as a suffix (suffix prefixes can collide on key-eviction policies). Invalidation tags MUST be tenant-scoped (`tag: tenant-{id}-orders`) so that one tenant's invalidation cannot purge another's cache. Cross-tenant cache keys (rare — e.g., feature-flag config) MUST be explicitly named and reviewed.

For revalidation: writers tag invalidations to all tenant-scoped tags they touched; readers attach the tenant context from auth, **not** from the request body.

PF has no cache rule at all — Rule 22 covers rate-limiting only. Gate-3 mentions no cache invariants. This is a multi-tenant-specific gap.

#### Query 7 — `RLS-aware schema migration tenant-by-tenant rollout`

**Top citations:**
- Supabase — *RLS migrations* — `https://supabase.com/docs/guides/database/postgres/row-level-security#using-policies-with-migrations`
- Stripe — *Online migrations at scale* (revisited) — `https://stripe.com/blog/online-migrations`
- Notion — *Sharding Postgres at Notion* — `https://www.notion.so/blog/sharding-postgres-at-notion`
- Citus / Hyperscale — *Distributed multi-tenant migrations* — `https://docs.citusdata.com/`

**Summary — N=4/4 binding pattern for RLS migrations:**
1. Migration runs as `bypass_rls` role (else policies block the migration itself).
2. Schema change is split into **policy-OFF** and **policy-ON** phases: drop policies, change schema, recreate policies, re-enable RLS — all in one transaction or behind a feature flag.
3. **Per-tenant feature gating** for risky migrations — the new column/index/table is enabled only for a pilot tenant cohort first; rollout is tracked in a `tenant_features` table.
4. **Migration progress per tenant** is visible — a `tenant_migrations` table tracks `(tenant_id, migration_id, started_at, completed_at, status)`.
5. **Backfill is idempotent and resumable** — backfilling 10K tenants x 100K rows = 1B operations; a single failure must not require restart.

PF Rule 27 mandates expand-contract. **Zero PF rules** address: RLS policy lifecycle in migrations, per-tenant pilot rollout, per-tenant migration progress tracking, or resumable backfill discipline. The *Regression Scope* skill (Rule 34) is the closest existing primitive — it could plausibly be extended with multi-tenant migration scope items.

#### Query 8 — `"production readiness" checklist enterprise SaaS Google SRE`

**Top citations:**
- Google SRE Workbook — *Production Readiness Reviews (PRR)* — `https://sre.google/workbook/evolving-sre-engagement-model/`
- Google SRE Book — *The Production Environment* — `https://sre.google/sre-book/production-environment/`
- AWS Well-Architected — *Operational Excellence pillar* — `https://docs.aws.amazon.com/wellarchitected/latest/operational-excellence-pillar/`
- 12-Factor App — `https://12factor.net/` (referenced by SRE PRR as a precondition)

**Summary — Google PRR canonical checklist (N=4/4 sources): a mature production-readiness review covers seven categories**, in this order of weight:
1. **Architecture review** — dependencies, SPOFs, data flow.
2. **Capacity planning** — projected QPS / TPS, headroom, growth model.
3. **SLO definition** — per-route SLIs, targets, error budget, burn-rate alerts.
4. **Failure mode analysis** — what happens if X fails? (every external dep enumerated)
5. **Disaster recovery** — RTO, RPO, runbooks tested.
6. **Operational readiness** — runbooks, oncall rotation, alerts, dashboards.
7. **Security review** — auth, authz, data-at-rest, data-in-transit, audit logs, threat model.

For multi-tenant adds: **tenant onboarding/offboarding runbooks**, **noisy-neighbor mitigation plan**, **per-tenant capacity caps**, **tenant data export / deletion under GDPR Art 17**.

PF's Gate-3 covers items 1, 2 (partial), 6 (partial), 7 (partial). **Missing entirely:** SLO definition (item 3), failure-mode analysis (item 4), DR/RTO/RPO (item 5), tenant lifecycle runbooks, GDPR data-subject-rights tooling. Gate-3 is roughly **40% of a PRR** — adequate for a startup, well below enterprise.

### L.2 Canonical-reference inventory (12 sources, >=8 mandate met)

1. **Google SRE Workbook** — `https://sre.google/workbook/` — SLO/SLI/error-budget canon; PRR template; alerting on burn rate. **Cited by all 4 SLO sources, 3/4 PRR sources.**
2. **Google SRE Book** — `https://sre.google/sre-book/` — foundational; predates Workbook; introduces SLO grammar.
3. **AWS Well-Architected — SaaS Lens** — `https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/` — five-pillar SaaS-specific WAF: Operational Excellence, Security, Reliability, Performance Efficiency, Cost Optimization. Tenant Isolation is a dedicated section.
4. **AWS Well-Architected — Reliability Pillar** — `https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/` — RTO/RPO definitions, DR strategies (backup/restore, pilot light, warm standby, multi-site active/active).
5. **AWS SaaS Factory blog corpus** — `https://aws.amazon.com/blogs/aws/category/aws-saas-factory/` — RLS, silo/pool/bridge, tenant onboarding patterns; one of the few public end-to-end multi-tenant references with code.
6. **Stripe Engineering blog — *Online migrations at scale*** — `https://stripe.com/blog/online-migrations` — six-phase migration; canonical reference for high-volume schema change without downtime.
7. **PlanetScale — *Principles of online schema migration*** — `https://planetscale.com/blog/the-principles-of-online-schema-migration` — non-blocking schema change theory; algorithm for ghost-table cutover.
8. **Notion Engineering — *Sharding Postgres at Notion*** — `https://www.notion.so/blog/sharding-postgres-at-notion` — real-world tenant-aware sharding, dual-write cutover, multi-month rollout.
9. **Linear Engineering — *Scaling the Linear Sync Engine*** — `https://linear.app/blog/scaling-the-linear-sync-engine` — multi-tenant cache invalidation; per-tenant change feed; type-system tenant safety.
10. **Atlassian SRE / Vanta / Drata SOC2 corpus** — `https://www.atlassian.com/incident-management/`, `https://www.vanta.com/resources/`, `https://drata.com/grc-central/` — SOC2 evidence patterns, audit-log requirements, retention norms.
11. **OWASP Application Security Verification Standard (ASVS)** — `https://owasp.org/www-project-application-security-verification-standard/` — Section V8 (data protection), V9 (communications), V10 (malicious code) all reference tenant-isolation verification requirements.
12. **12-Factor App** — `https://12factor.net/` — referenced by SRE PRR as the configuration / dependency / process baseline; PF Rule 25 alludes but doesn't cite.

### L.3 Pattern catalogue — 5 discipline classes, >=2 sources each

| Class | Sub-pattern | Sources | Status in PF |
|---|---|---|---|
| **Tenancy model** | Silo / Pool / Bridge declaration | AWS SaaS Lens, Crunchy Data | **MISSING** — no rule requires the project to declare which model it uses; downstream rules cannot adapt. |
| **Tenancy model** | `tenant_id` on every tenant-scoped table; FK or RLS-enforced | AWS, Crunchy, Supabase, Notion | Partial (Rule 6 names "tenant isolation", no scaffolding). |
| **Tenancy model** | Tenant context derived from session, never payload | AWS, Supabase, Linear | Rule 6 covers (intent-level only). |
| **Scalability — noisy neighbor** | Per-tenant rate limit + quota | AWS SaaS Lens, Cloudflare | **MISSING** — Rule 22 is global rate-limit only. |
| **Scalability — noisy neighbor** | Connection-pool isolation per tenant tier | AWS SaaS, Stripe | **MISSING.** |
| **Scalability — noisy neighbor** | Per-tenant cache key namespace | AWS, Vercel, Linear | **MISSING.** |
| **Observability — SLO** | Per-route SLI declaration | Google SRE | **MISSING.** |
| **Observability — SLO** | Per-tenant-tier SLO targets | Google SRE Workbook, Atlassian | **MISSING.** |
| **Observability — SLO** | Error-budget burn-rate alerts | Google SRE Workbook | **MISSING.** |
| **Observability — audit** | Append-only audit log per tenant | Vanta, Drata, AWS SOC | Partial — Rule 18 mandates structured logs, no append-only requirement. |
| **Observability — audit** | Tamper-evidence (signed / WORM / hash-chain) | Vanta, OWASP ASVS | **MISSING.** |
| **Compliance** | GDPR Art 15 data export per tenant subject | GDPR text, Vanta | **MISSING.** |
| **Compliance** | GDPR Art 17 right-to-erasure per tenant | GDPR text, Vanta | **MISSING.** |
| **Compliance** | SOC2 evidence collection automation | Vanta, Drata | **MISSING.** |
| **Migration** | Expand-contract six-phase | Stripe, PlanetScale, gh-ost | Rule 27 names; no skill scaffolds. |
| **Migration** | Per-tenant batched backfill, idempotent, resumable | Stripe, Notion | **MISSING.** |
| **Migration** | RLS policy lifecycle in migration | Supabase, Citus | **MISSING.** |
| **Migration** | Per-tenant migration progress table | Notion, Citus | **MISSING.** |
| **Migration** | Pilot-tenant cohort gating | AWS SaaS, Stripe | **MISSING.** |

### L.4 Existing PF coverage — spot-check of `core/rules.md`, `core/patterns.md`, `core/gate-3.md`

**rules.md (verified by direct read):**
- Rule 6 — tenant isolation enforcement (intent-only, no scaffolding) — **partial.**
- Rule 7 — server-side authz — **adequate.**
- Rule 11 — security headers — **adequate.**
- Rule 16 — index discipline — **adequate.**
- Rule 18 — structured logging w/ tenant_id — **partial** (no append-only / tamper-evidence).
- Rule 22 — rate-limit (global only, no per-tenant) — **partial.**
- Rule 24 — scale validation — **partial** (no SLO codification).
- Rule 27 — expand-contract migration — **partial** (no per-tenant choreography).

**patterns.md (3 universal rows):** U-AP-4 (consensus), U-BP-7 (no-duplication), U-PP-10 (enterprise research first). **None tenancy-specific.**

**gate-3.md (verified by direct read):** Security section has ONE tenant-isolation line ("Tenant isolation enforced on every query (Rule 6)" / "No cross-tenant data in any response (Rule 6)"). Observability section names "alerts configured for error rate and latency spikes" — no SLO / error-budget / per-tenant alarm. **Zero items** on compliance, audit retention, DR, RTO/RPO, tenant lifecycle, noisy-neighbor isolation.

**Coverage estimate:** ~30% of the enterprise multi-tenant SaaS surface area defined in L.3.

### L.5 What PF v1.2+ would prevent / enable with this catalogue

If PF added the L.3 pattern set, the following classes of incident — common in real multi-tenant SaaS — become *gate-blockable*, not post-hoc-only:

1. **Cross-tenant data leak via missing WHERE clause** — fuzz-test rule + type-tenancy rule + Gate-3 cross-tenant fuzz-check would catch this **before merge**, not after a customer-facing incident.
2. **Migration locks production for a large tenant** — per-tenant batched-backfill skill would force the migration plan to declare batch size, resumability, and per-tenant progress — Builder cannot ship a `UPDATE all_rows SET ...` migration.
3. **Noisy neighbor takes the system down for everyone** — per-tenant rate-limit + connection-pool-tier rule + Gate-3 noisy-neighbor item would force the architecture to declare tenant-quota strategy at plan time.
4. **SOC2 / GDPR audit fails because evidence not collected** — append-only audit log rule + retention rule + GDPR data-subject-rights skill would force these into Gate-3 every release.
5. **No SLO, so an enterprise customer's outage is invisible** — SLO-doc skill + per-tier SLO rule + burn-rate-alert rule would make missing SLOs a Gate-3 block.
6. **Cache poisoning across tenants from a misnamed cache key** — cache-key-namespace rule + Gate-3 cache-namespace check would catch this in code review.
7. **Tenant offboarding leaves orphan data** — tenant-lifecycle runbook rule + Gate-3 offboarding-completeness check would force a deletion verification.

These seven classes are the load-bearing differentiators between "production discipline for a single-tenant app" (PF v1.x) and "production discipline for a multi-tenant SaaS" (PF v1.2+).

### L.6 Proposed new skill catalogue

(Names only — bodies are out of scope. Each skill maps to a discipline class in L.3.)

1. **`tenancy-model-declaration`** — Use at project bootstrap. Declares silo / pool / bridge in CONFIG.yaml. Downstream skills (writing-plan, writing-arch-doc, gate-3) read this slot. Hard-gates plan-writing if not declared.
2. **`writing-tenant-migration-plan`** — Plan type for tenant-aware migrations. Mandates: per-tenant batching, resumability checkpoint table, RLS-policy lifecycle, pilot-tenant cohort. Composable with `writing-plan`.
3. **`tenant-isolation-verification`** — Use after Builder finishes a data-access change. Generates fuzz-test cases (tenant-A session → assert zero tenant-B rows). Hard-gates QA without these tests.
4. **`writing-slo-doc`** — Use at module / feature design. Produces an SLO doc (per-route SLI, per-tier target, burn-rate alert config). Required before Gate-3 for any user-facing endpoint.
5. **`writing-audit-log-spec`** — Use when designing any privileged action. Produces an audit-log entry shape, retention statement, append-only mechanism, tenant-scoping. Required for SOC2-class actions.
6. **`writing-noisy-neighbor-plan`** — Use when designing any shared resource (DB pool, queue, cache, rate-limit pool). Produces per-tenant quota & isolation strategy. Required at architecture-doc time.
7. **`writing-tenant-lifecycle-runbook`** — Onboarding, offboarding, GDPR-export, GDPR-erasure runbooks. Each verifiable. Required at module-completion time for any tenant-scoped feature.
8. **`gate-3-multi-tenant-readiness`** — Extends `gate-3-production-check` with multi-tenant-specific checks (the L.3 missing items, ~25 line items). Composable / replaces the base `gate-3` for multi-tenant projects.

Plus 12+ new core rules (mapping to L.3): per-tenant rate-limit, connection-pool tier, cache-key-namespace, append-only audit, audit retention, tamper-evident audit, per-route SLI, per-tier SLO, error-budget burn-rate, RTO/RPO declared, per-tenant migration backfill, RLS policy in migration, GDPR Art-15 endpoint, GDPR Art-17 endpoint, tenant-isolation fuzz-test in CI.

### L.7 Risks and open questions

1. **Stack-agnostic invariant.** PF's hard guard (per `CLAUDE.md` rejection criteria #1) is **no stack references in `core/`**. Patterns like RLS, `current_setting()`, JWT claims, search_path, gh-ost — these are PostgreSQL / specific-tooling concepts. The discipline (every tenant-scoped query is tenant-filtered; migrations are per-tenant batched) is universal, but the *check* often is not. PF must phrase rules as *capability requirements* (e.g., "every tenant-scoped table declares its tenancy column") and put concrete enforcement (`grep`, schema lint) in `STACK-PATTERNS.template.md`. Risk: rules become abstractions thin enough to under-fire. Mitigation: each new universal rule must come with at least two concrete `STACK-PATTERNS.template.md` enforcement examples (Postgres+RLS, MongoDB+tenant_id field, MySQL+search_path) — proves the abstraction is real.

2. **Tier collapse risk.** PF's Tier 1/2/3 tiering is task-shape-based (trivial/feature/architecture). Multi-tenant SaaS tends toward Tier 3 by default — every change is potentially tenant-scoped. If PF v1.2+ defaults Tier 3 for any tenant-scoped table change, the architecture-doc overhead may sink the framework's perceived velocity. Mitigation: introduce a Tier-2.5 or "tenant-aware Tier 2" that requires `writing-tenant-migration-plan` + `tenant-isolation-verification` but skips full architecture doc.

3. **Audit-log append-only durability** is genuinely hard at the application layer — most enterprises use a separate service (CloudTrail, Datadog Audit, Vanta itself). Forcing every PF project to ship an append-only Postgres-table audit log may be over-prescriptive. Mitigation: rule wording is "audit log MUST be append-only by mechanism the project declares" — declaration goes in CONFIG.yaml.

4. **GDPR / SOC2 are jurisdictional.** A US-only B2B SaaS with no EU customers genuinely doesn't need GDPR Art-17 tooling shipped. Forcing it via Gate-3 hurts adoption. Mitigation: CONFIG.yaml `compliance: [SOC2, GDPR, HIPAA, ...]` slot; skills key off it.

5. **Cost of ratification.** PF's pattern-ratification path requires N=3 distinct incident hashes (Rule 43). Most v1.2+ multi-tenant rules are *consensus-backed* (`U-` prefix, blank `root_cause_hash`) — that's allowed by the schema but means PF v1.2+ ships ~12 universal rules drawn from external research, not internal incidents. The framework architecture supports this (U-AP-4 is itself consensus-backed) but the *volume* of consensus-only rules in v1.2+ may shift PF's character from "battle-tested by THIS project's incidents" toward "external-canon translation layer." Open question for the user: is that the desired character?

6. **Forking risk.** If the universal abstractions are too thin, multi-tenant projects will write their own STACK-PATTERNS extensions and the universal layer atrophies. If the universal abstractions are too thick (specific RLS terminology, etc.), `core/` becomes Postgres-flavored. The narrow path is: universal rules name *requirements*; STACK-PATTERNS provides *enforcement recipes*; new skill bodies (Skill files, not core/) can name technologies because skills are stack-aware by design.

7. **Architectural cost.** ~8 new skills + ~12 new universal rules + 1 new plan type + 1 extended Gate-3 = comparable in size to the entire current PF v1.1.0. This is a major version bump (v2.0.0 per PF's own version policy), and per `CLAUDE.md` rejection criteria #5 every new hook needs a MAJOR version + arch doc justifying it. None of the L.6 skills *require* new hooks — they extend existing skills + rules + Gate-3. So the version bump is justified by category (rule-category change) but does not need to break the hook contract.

### Sources

- AWS SaaS Lens — Tenant Isolation: `https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/tenant-isolation.html`
- AWS Reliability Pillar: `https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html`
- AWS Multi-Tenant Data Isolation with PostgreSQL RLS: `https://aws.amazon.com/blogs/database/multi-tenant-data-isolation-with-postgresql-row-level-security/`
- AWS SaaS Architecture Fundamentals (whitepaper): `https://docs.aws.amazon.com/whitepapers/latest/saas-architecture-fundamentals/saas-architecture-fundamentals.pdf`
- Crunchy Data — Postgres RLS for Multi-Tenant SaaS: `https://www.crunchydata.com/blog/row-level-security-for-tenants-in-postgres`
- Supabase RLS Guide: `https://supabase.com/docs/guides/database/postgres/row-level-security`
- Stripe — Online migrations at scale: `https://stripe.com/blog/online-migrations`
- PlanetScale — Principles of online schema migration: `https://planetscale.com/blog/the-principles-of-online-schema-migration`
- gh-ost: `https://github.com/github/gh-ost`
- Citus / Hyperscale docs: `https://docs.citusdata.com/`
- Notion — Sharding Postgres at Notion: `https://www.notion.so/blog/sharding-postgres-at-notion`
- Notion — Data model behind Notion's flexibility: `https://www.notion.so/blog/data-model-behind-notion`
- Linear — Scaling the Linear Sync Engine: `https://linear.app/blog/scaling-the-linear-sync-engine`
- Google SRE Workbook — Implementing SLOs: `https://sre.google/workbook/implementing-slos/`
- Google SRE Workbook — Production Readiness Reviews: `https://sre.google/workbook/evolving-sre-engagement-model/`
- Google SRE Book — Service Level Objectives: `https://sre.google/sre-book/service-level-objectives/`
- Atlassian — SLA vs SLO vs SLI: `https://www.atlassian.com/incident-management/kpis/sla-vs-slo-vs-sli`
- Vanta — SOC 2 Audit Logs: `https://www.vanta.com/resources/soc-2-audit-logs`
- Drata — SOC 2 Logging: `https://drata.com/grc-central/soc-2/logging`
- AWS — Logging and Monitoring for SOC 2: `https://aws.amazon.com/compliance/soc-faqs/`
- OWASP ASVS: `https://owasp.org/www-project-application-security-verification-standard/`
- 12-Factor App: `https://12factor.net/`
- Vercel — Cache tags: `https://vercel.com/docs/data-cache/tag`
- Cloudflare Workers — Cache: `https://developers.cloudflare.com/workers/learning/how-the-cache-works/`
- Semgrep multi-tenancy rules: `https://semgrep.dev/r?q=tenant`

<!-- END-CATEGORY-L -->

---

## Category M — AI dev framework existing landscape

<!-- BEGIN-CATEGORY-M -->

**Top finding (single sentence):** PF was designed in a vacuum and consequently reinvented at least eight load-bearing primitives that already exist as standardised patterns in the broader landscape — the most expensive being **(a) plan-vs-act mode separation** (Cline / Aider architect-mode is the dominant pattern, mirrored by Cursor's plan-mode and Claude Code's plan-mode; PF's brainstorm → write-plan → seven-validation-questions cascade is a partial reinvention of this), **(b) the AGENTS.md universal-instruction file** (now Linux Foundation–stewarded; PF should ship one alongside CLAUDE.md), **(c) polyglot adapter shape** (SP's tool-mapping references + per-platform manifest dirs is the dominant 5-platform pattern; PF is mono-platform and has no migration path), and **(d) repo-map / context cascade** (Aider's tree-sitter PageRank repo-map is the BINDING (5/5) pattern for "let the LLM see the codebase shape"; PF has no equivalent). The good news: PF's **incident-tagged pattern registry** and **U-AP-4 enterprise-research-first BINDING gate** are *novel* — no surveyed framework has either, and these are PF's strongest moats. The framework most architecturally aligned with PF's discipline-first positioning is **superpowers** (5.0.7) and the framework most aligned with its multi-agent ambition is the **Anthropic Claude Agent SDK** (orchestrator-worker pattern). Net: **8 frameworks surveyed, 5 BINDING gaps where PF reinvented prior art, 2 novel PF primitives worth preserving, 3 frameworks worth borrowing from explicitly in v1.2+.**

### M.1 Per-query findings

#### Query 1 — `"AI development framework" comparison 2025 2026`
**Top citations:**
- `https://www.faros.ai/blog/best-ai-coding-agents-2026`
- `https://www.secondtalent.com/resources/open-source-ai-coding-assistants/`
- `https://gurusup.com/blog/best-ai-for-coding`

**Summary:** The 2026 landscape clusters into **(a) IDE-embedded** (Cursor, Windsurf, Continue.dev, Cline, Roo Code), **(b) CLI/terminal** (Aider, Claude Code, Codex CLI, opencode, Gemini CLI), **(c) agent SDKs** (Claude Agent SDK, OpenAI Agents SDK, Strands, LangGraph, AutoGen, CrewAI), and **(d) cross-tool standards** (AGENTS.md, MCP, the Skill spec). The market reached an estimated $12.8B in 2026, up from $5.1B in 2024. **The unanimous architectural insight across all 2026 reviews: methodology > model.** "Tools like Claude Code, Codex, Cursor, and GitHub Copilot are increasingly capable of acting as autonomous agents… the differentiator is the workflow harness, not the model." This validates PF's bet on production discipline as the value layer — but also means PF's competitors are no longer just other "frameworks," they are the harness layer of every IDE.

#### Query 2 — `Aider plan mode methodology repo-map edit-format`
**Top citations:**
- `https://aider.chat/docs/repomap.html`
- `https://aider.chat/docs/usage/modes.html`
- `https://aider.chat/2023/10/22/repomap.html`
- `https://github.com/Aider-AI/aider/blob/main/aider/website/docs/repomap.md`

**Summary:** Aider's three load-bearing primitives are:

1. **Architect mode** — *"An architect model will propose changes and an editor model will translate that proposal into specific file edits."* This is **two-model orchestration with role separation**: the planner is a high-reasoning model (e.g. o1, Claude Opus); the editor is a fast/cheap model (e.g. Haiku, gpt-4o-mini) doing pure mechanical edit-format translation. The planner never touches files; the editor never reasons about design. PF's brainstorm/write-plan/Builder cascade is the **same shape but single-model and single-session** — PF has not exploited the cost/quality tradeoff Aider gets from cross-model role-separation.

2. **Repo-map** — Aider builds a tree-sitter–parsed signature map of the entire repo, runs **PageRank on the call graph** (each file is a node, edges are import/call dependencies), and sends only the top-ranked subset within `--map-tokens` (default 1k). *"This means even within projects with hundreds or thousands of source files, aider can identify and surface the parts of the codebase that are most relevant for any given task."* This is the dominant 2026 solution to the "context window vs codebase size" problem — and PF has **no equivalent**. PF currently relies on the Tier-3 architecture-doc TL;DR as a manual repo-map, which is high-cost-to-produce and easy to let go stale.

3. **Edit formats** — Aider standardises a small set of edit-format protocols (`whole`, `diff`, `udiff`, `editor-diff`, `editor-whole`) and tunes per-model edit-format selection so each model uses the format it produces most reliably. This is a **machine-checkable contract between LLM and harness** — the harness rejects edits that don't parse and re-prompts. PF's structural-check hooks are the *closest* analogue but operate on file content post-write, not on the LLM's edit emission, so PF has no early-rejection of malformed edits.

#### Query 3 — `Cursor "plugin-architect" agent project rules slash commands 2026`
**Top citations:**
- `https://cursor.com/docs/context/rules`
- `https://cursor.com/blog/agent-best-practices`
- `https://cursor.com/changelog/2-4`
- `https://forum.cursor.com/t/agent-plugins-isolated-packaging-lifecycle-management-for-sub-agents-skills-hooks-rules-incl-agent-md-across-cursor-ide-cli/151250`

**Summary:** Cursor's 2026 architecture is now **rules + slash-commands + subagents + skills + AGENTS.md** — converging on the Claude Code shape. Three findings load-bearing for PF:

1. **`.cursor/rules/` is hierarchical** — *"project-wide rules in the root `.cursor/rules/` directory, backend-specific rules in `backend/.cursor/rules/`, and frontend-specific rules in `frontend/.cursor/rules/`."* The agent walks up from CWD and merges. This is the **same discovery model as Claude Code subagents** (walks up, source-priority overrides) — meaning the cross-tool consensus is *filesystem-walk discovery, not config-registered*. PF's `core/` + project `STACK-PATTERNS.md` is filesystem-walk shaped, but PF does not currently support **module-scoped rules** (e.g., a frontend-only override under `app/dashboard/.claude/`). Adding this is cheap and matches the cross-tool norm.

2. **Slash commands map to rule files** — *"You can create custom slash commands using Cursor's Rules feature by mapping these simple shortcuts to specific AI actions."* PF's skills already support `/skill-name` invocation, so PF is aligned. But the Cursor 2026 release also added a `/rules` command that creates and edits rule files from inside the agent — i.e., **agent-self-extending the rule set during the session**. PF has no analogue and arguably should not, but this is now the cross-tool norm worth flagging.

3. **`Agent Plugins` proposal (Dec 2025–Apr 2026 forum thread)** — Cursor community is pushing for *"Isolated packaging + lifecycle management for sub-agents, skills, hooks, rules (incl. AGENT.md) across Cursor IDE + CLI."* This is the **same problem PF solves with `.claude-plugin/plugin.json` + `core/` + `hooks/`**. The Cursor proposal is currently a feature-request, not shipped — meaning **PF's plugin-shape is currently ahead of Cursor's**. This is a moat worth defending; if Cursor ships it, PF should immediately be installable as a Cursor plugin via the SP polyglot pattern (see M.3).

#### Query 4 — `Continue.dev IDE methodology cascade slash commands custom commands`
**Top citations:**
- `https://docs.continue.dev/customize/deep-dives/configuration`
- `https://docs.continue.dev/customize/slash-commands`
- `https://docs.continue.dev/reference`
- `https://deepwiki.com/continuedev/continue/5.1-plugin-architecture`

**Summary:** Continue.dev's `config.yaml` is the **most polished cross-modal config** in the surveyed set. It exposes **autocomplete, chat, agent-mode, edit-mode** as separate configurable surfaces — each can use a different model, different rules, different prompts. The configuration cascade is documented: *"YAML takes precedence if `config.yaml` exists; JSON fallback is used if only `config.json` exists; remote config is applied on top of local config if `remoteConfigServerUrl` is set."* And: *"slash commands are aggregated from built-in commands, custom JSON commands, V1 .prompt files, YAML prompts blocks, and invokable rule blocks."* This is **5-layer rule cascade**, exactly the shape Researcher I (rule-cascade research) is investigating for PF. Critically, Continue.dev has shipped a working multi-source cascade with merge-priority documentation, **whereas PF currently only has core → STACK-PATTERNS.md (2 layers)**. If PF wants project-scoped + module-scoped + remote-team-scoped rules, the Continue.dev cascade shape is the BINDING reference.

#### Query 5 — `opencode plugin model dispatching parallel`
**Top citations:**
- `https://opencode.ai/docs/agents/`
- `https://github.com/aptdnfapt/opencode-parallel-agents`
- `https://medium.com/@saurabbhatia/how-i-coordinate-19-ai-agents-across-4-model-families-with-opencode-and-recallium-00bc14fb8ccb`
- `https://github.com/kdcokenny/opencode-workspace`
- `https://dev.to/uenyioha/porting-claude-codes-agent-teams-to-opencode-4hol`

**Summary:** opencode is the **most aggressive multi-model dispatch harness in the 2026 landscape**. *"OpenCode handles agent dispatch, model routing, tool permissions, and phase sequencing… provider-agnostic, so you can define custom agents on any model family, chain them into teams, and run them in parallel phases from the terminal."* The `/multi` command runs N agents in parallel and the harness has documented **"fire-and-forget spawning, file-based inbox persistence, explicit sub-agent isolation, event-driven messaging, append-only JSONL writes, peer-to-peer communication, multi-model support."* In one cited 2026 case study, **19 agents across 4 model families were coordinated on a single project**.

This is **substantially beyond PF's current Deputy + 13 Researchers parallel-dispatch pattern** — opencode treats each agent as a long-lived process with persistent inbox/outbox, while PF treats each subagent as a one-shot prompt with a status-token return. PF is currently *N/A in the long-running-agent shape*. If PF v1.2+ wants enterprise multi-tenant orchestration (Researcher L), the opencode multi-model + JSONL-inbox pattern is the BINDING reference.

opencode's plugin architecture: *"runtime, agent, workspace, tracker, SCM, notifier, terminal, and lifecycle"* — eight extensibility slots. PF currently has *three* (skills, hooks, agents). The eight-slot model is the **richest plugin contract** in the surveyed set and is what enterprise integrations would require.

#### Query 6 — `SWE-bench framework methodology comparison`
**Top citations:**
- `https://www.swebench.com/verified.html`
- `https://openai.com/index/introducing-swe-bench-verified/`
- `https://www.morphllm.com/swe-bench-pro`
- `https://arxiv.org/abs/2510.08996` ("Saving SWE-Bench: A Benchmark Mutation Approach")
- `https://www.codeant.ai/blogs/swe-bench-scores`

**Summary:** SWE-bench Verified's evaluation methodology is **5-component**: *"prompts and information to direct the model, scaffold and tools used when running the model, samples used for evaluation, limits on model input/output, and the environment the benchmark runs in."* The 2026 movement is toward **standardised scaffolding** to prevent harness-tuning gaming: SWE-bench Pro (Scale AI's SEAL lab) *"uses standardised scaffolding where every model runs through identical tooling with a 250-turn limit, removing the distortion that vendors can tune their agent scaffolding to game specific benchmark tasks."*

Two findings load-bearing for PF:

1. **mini-SWE-agent is the new minimal harness baseline.** *"Language models are evaluated using mini-SWE-agent in a minimal bash environment with no tools, no special scaffold structure - just a simple ReAct agent loop."* This is the *opposite* of PF's design philosophy (heavy scaffold, many phases). The benchmark community's BINDING position is "scaffold-light → comparable scores"; PF's position is "scaffold-heavy → fewer production incidents." These are not mutually exclusive but PF must articulate that it is NOT competing on benchmark — it is competing on production-incident-rate. The PROJECT-PLAN already names this ("ratification + incident-tagged registry") but it is currently unmeasured.

2. **Benchmark contamination is a 2026 concern.** *"OpenAI has stopped reporting Verified scores after finding that every frontier model showed training data contamination."* This means **measuring framework effectiveness via SWE-bench is no longer credible alone** — PF's potential metric is incident-prevented-per-pattern, not benchmark-score-improved. This argues for the v1.2+ direction of "ratify-pattern + Post-Mortem clustering" (already in PF) being a *measurement* primitive, not just a process primitive.

### M.2 Framework inventory — table form

| Name | Discipline taught | Entry-point shape | Platform | Key innovation |
|---|---|---|---|---|
| **superpowers (SP) 5.0.7** | TDD, brainstorming, debugging, plan/execute, parallel dispatch, code review | Framework-triggered (`SessionStart` hook injects bootstrap; skills auto-fire on description match) | Polyglot: Claude Code, Cursor, Codex, opencode, Gemini CLI | Per-platform tool-mapping references; single skill body, multiple thin manifest dirs |
| **Aider** | Architect/editor split, repo-map, edit-format protocol, git-native pair programming | Task-triggered (CLI invocation `aider <files>`; chat-mode-toggle for plan vs code) | CLI + git, model-agnostic | Tree-sitter PageRank repo-map; two-model architect/editor cost/quality split |
| **Cursor** | Rule-driven persistent context, slash-commands, Composer multi-file edits, AGENTS.md | Framework-triggered (rules always-on at conversation start) + task-triggered (slash commands) | Cursor IDE + CLI | `.cursor/rules/` hierarchical filesystem-walk; rules apply at conversation start |
| **Continue.dev** | Per-modality config (autocomplete vs chat vs agent vs edit), prompt-files-as-rules, YAML cascade | Framework-triggered (config.yaml rules always-on) + task-triggered (slash commands) | VS Code, JetBrains, CLI | 5-source rule cascade with documented merge priority |
| **Cline / Roo Code** | Plan mode (read-only) → Act mode (write); plan-as-source-of-truth | Mode-toggled (user explicitly selects Plan vs Act) | VS Code extension | Hard read-only enforcement during planning; plan is the spec |
| **opencode** | Multi-model dispatch, parallel agent teams, persistent inbox/outbox, 8-slot plugin architecture | Mixed: agents are long-lived processes; `/multi` for parallel; @mentions for sequential | Polyglot: opencode + Codex; supports any model | Long-running agent processes with file-based JSONL inbox |
| **Anthropic Claude Agent SDK** | Orchestrator-worker pattern, hierarchical subagents, MCP integration | SDK-embedded (developer code spawns and coordinates agents programmatically) | SDK on Anthropic API | Subagents share session, return only results; deepest MCP integration |
| **AutoGen / CrewAI / LangGraph** | Conversational GroupChat (AutoGen), role-based crews (CrewAI), directed-graph state machines (LangGraph) | SDK-embedded (Python/JS code defines topology) | Library, any model via OpenAI-compatible API | LangGraph: O(1) graph node addition; CrewAI: role-team metaphor; AutoGen: peer conversation |
| **SWE-bench / mini-SWE-agent** | Minimal-scaffold ReAct loop; standardised eval harness | N/A (benchmark, not framework) | Docker eval environment | 250-turn limit, single bash tool, no scaffold = anti-gaming methodology |
| **Production Framework (PF) v1.1.0** | Tier-classified work, brainstorm → spec → plan → 7VQ → build → 2-stage review → gate-3, ratified incident-tagged patterns | Framework-triggered (SessionStart hook injects `using-this-framework`; skills auto-fire on description; structural-check hooks block on emit) | Claude Code only | **Incident-tagged pattern registry**, **U-AP-4 enterprise-research-first BINDING gate**, **ratify-pattern mechanical-gate suite** |

### M.3 SP polyglot pattern — file:line evidence

SP 5.0.7 ships a **single skills body** with **per-platform thin manifests + tool-mapping references**. The structure (cache: `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/`):

```
.claude-plugin/marketplace.json   ← Claude Code plugin manifest (Anthropic's plugin protocol)
.claude-plugin/plugin.json        ← Claude Code plugin metadata
.cursor-plugin/plugin.json        ← Cursor plugin manifest
.codex-plugin/plugin.json         ← Codex plugin manifest with `interface: { displayName, capabilities, defaultPrompt, brandColor, composerIcon, logo }` (Codex-specific store metadata)
.codex/INSTALL.md                 ← Codex install instructions (clone + symlink to ~/.agents/skills/superpowers)
.opencode/INSTALL.md              ← opencode install instructions ("plugin": ["superpowers@git+https://github.com/obra/superpowers.git"])
.opencode/plugins/superpowers.js  ← opencode plugin shim (Node.js): injects bootstrap into first user message, registers skills.paths into config singleton
gemini-extension.json             ← Gemini CLI extension manifest (`{ "name": "superpowers", "version": "5.0.7", "contextFileName": "GEMINI.md" }`)
AGENTS.md                         ← Single line: `CLAUDE.md` (delegates to CLAUDE.md — minimum viable AGENTS.md)
CLAUDE.md                         ← Long-form contributor guidelines (6.5 KB) + bootstrap delegation
GEMINI.md                         ← Two lines: imports `using-superpowers/SKILL.md` + `references/gemini-tools.md`
hooks/hooks.json                  ← Claude Code hooks (uses ${CLAUDE_PLUGIN_ROOT} substitution + run-hook.cmd shim)
hooks/hooks-cursor.json           ← Cursor hooks (different shape: `{ "version": 1, "hooks": { "sessionStart": [...] } }`)
skills/using-superpowers/references/codex-tools.md     ← tool name mapping table for Codex
skills/using-superpowers/references/copilot-tools.md   ← tool name mapping table for Copilot
skills/using-superpowers/references/gemini-tools.md    ← tool name mapping table for Gemini CLI
```

**The polyglot adapter pattern in concrete terms:**

1. **Skills bodies are platform-agnostic.** A skill like `brainstorming/SKILL.md` references generic tool concepts ("the Skill tool", "the Task tool") in its body, never platform-specific tool names.

2. **Per-platform tool-mapping references are bridges.** `skills/using-superpowers/references/gemini-tools.md` (verified content):
   ```
   | `Read` (file reading) | `read_file` |
   | `Write` (file creation) | `write_file` |
   | `Bash` (run commands) | `run_shell_command` |
   | `Task` tool (dispatch subagent) | No equivalent — Gemini CLI does not support subagents |
   ```
   When the skill body says "use the Task tool," the agent on Gemini CLI loads `references/gemini-tools.md`, sees there is no equivalent, and falls back to single-session execution.

3. **Per-platform thin manifests live in dotted directories.** `.cursor-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.opencode/INSTALL.md`, `gemini-extension.json` are all small (~600 bytes – 2 KB) and reference the shared `./skills/` and `./agents/` directories. A platform's package manager finds its own manifest and ignores the others.

4. **Bootstrap is platform-specific.** Claude Code uses `hooks/hooks.json` with `${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd session-start`. opencode uses a Node.js plugin (`.opencode/plugins/superpowers.js`) that injects bootstrap into the **first user message** (not a system message — explicitly to avoid token bloat issue #750 and Qwen multi-system-message issue #894). Cursor uses `hooks/hooks-cursor.json` with a different `version: 1, hooks: { sessionStart: [...] }` shape. Codex uses a symlink-based discovery (no hook). Gemini uses `gemini-extension.json` with a `contextFileName: "GEMINI.md"` declaration.

5. **`AGENTS.md` is the minimum-viable cross-tool fallback.** SP's `AGENTS.md` is **9 bytes** — literally the string `CLAUDE.md` — so any tool that reads AGENTS.md (Codex CLI, GitHub Copilot, Cursor, Windsurf, Amp, Devin per https://agents.md/) gets redirected to CLAUDE.md.

**What SP knows about each target's quirks (verbatim from `.opencode/plugins/superpowers.js` lines 84–88):**
> *"Inject bootstrap into the first user message of each session. Using a user message instead of a system message avoids: 1. Token bloat from system messages repeated every turn (#750); 2. Multiple system messages breaking Qwen and other models (#894)."*

This is **knowledge that PF does not currently have** because PF has only ever shipped on Claude Code. The opencode/Qwen system-message bug, the Codex symlink-based discovery quirk, the Cursor v1 hook schema vs Claude Code's v2 hook schema — these are *real load-bearing platform quirks* that PF will hit the moment it ships polyglot.

### M.4 N/N consensus on entry-point shape

Researcher B's framing: **task-triggered** (user explicitly invokes per-task — e.g. `aider <files>`, `/skill-name`) vs **framework-triggered** (always-on at session start — e.g. SessionStart hook, .cursor/rules always-loaded).

Surveyed 8 frameworks (excluding SWE-bench which is a benchmark, not a framework):

| Framework | Entry-point shape |
|---|---|
| superpowers (SP) | **Framework-triggered** (SessionStart hook injects `using-superpowers`) + task-triggered (skills auto-fire on description) |
| Aider | **Task-triggered** (CLI invocation per-task; chat mode is per-session-toggled, not persistent) |
| Cursor | **Framework-triggered** (`.cursor/rules/` always-on at conversation start) + task-triggered (slash-commands, Composer) |
| Continue.dev | **Framework-triggered** (config.yaml rules always-on) + task-triggered (slash commands) |
| Cline / Roo Code | **Mode-toggled** (Plan vs Act is a *user-toggled session mode*, neither task- nor framework-triggered in the binary sense — closer to framework with explicit mode-state) |
| opencode | **Mixed** (agent team is a long-running framework-shape; `/multi` is task-triggered) |
| Claude Agent SDK | **SDK-embedded** (developer code defines orchestration; task-triggered when developer invokes) |
| AutoGen / CrewAI / LangGraph | **SDK-embedded** (Python/JS code defines topology; task-triggered when developer runs) |

**Consensus (8/8 with nuance):** Every IDE/CLI-shaped framework (SP, Cursor, Continue.dev, Cline, opencode) has a **framework-triggered always-on layer** (rules file, bootstrap skill, plan-mode toggle) **layered with task-triggered slash-commands or skill auto-fire**. The pure task-triggered case (Aider) is the **outlier among IDE-shaped frameworks** but is the *norm* for CLI-shaped frameworks.

**For PF specifically:** PF currently has both layers — the SessionStart hook injects `using-this-framework` (framework-triggered) and skills auto-fire on description match (task-triggered). PF is **architecturally aligned with the 5/5 IDE consensus**. No change needed at this axis. **What's missing:** the *mode* layer (Cline plan-vs-act). PF's tier-selection skill is a partial substitute (it classifies the work) but does not gate write tools the way Cline's plan mode does. **This is the single largest unincorporated 2026 pattern** and is likely what Researcher #2 / wave-aware structural-check / Researcher #5 / rolling-handover were all gesturing at without naming.

### M.5 What patterns PF reinvented (or partially reinvented)

| Pattern | PF's name | Prior art (and where) | Reinvent verdict |
|---|---|---|---|
| **Plan-vs-act mode separation** | brainstorm → write-plan → 7VQ → build cascade | **Cline / Roo Code Plan & Act**; **Aider architect/editor**; Cursor plan mode; Claude Code plan-mode | **Partial reinvention** — PF has the *cascade* but not the *write-tool gate*. Cline hard-locks write tools in Plan mode; PF relies on convention. **GAP — should adopt write-tool gating in brainstorm/research/plan tiers.** |
| **Repo-map / context selection** | (none — PF has architecture-doc TL;DR which is manual) | **Aider tree-sitter PageRank repo-map** (BINDING for context selection in CLI tools) | **Full reinvention attempt that doesn't exist yet** — PF needs an automated repo-map. Manual TL;DR is too high-cost-to-maintain. |
| **Cross-platform manifests** | `.claude-plugin/plugin.json` + `core/` only | **SP polyglot adapter** (`.cursor-plugin/`, `.codex-plugin/`, `.opencode/`, `gemini-extension.json`, `AGENTS.md`) | **Not yet attempted** — PF is mono-platform. **GAP — adopt SP's structure if PF wants to ship beyond Claude Code.** |
| **Rule cascade (multi-source merge)** | `core/` + project `STACK-PATTERNS.md` (2 layers) | **Continue.dev 5-source cascade** (built-in commands, custom JSON, .prompt files, YAML prompts, invokable rule blocks); **Cursor `.cursor/rules/` hierarchical walk** | **Partial reinvention** — PF has 2 layers, surveyed frameworks have 3–5. PF currently lacks module-scoped rules and remote-team-scoped rules. |
| **Edit-format protocol** | (none — structural-check post-write hooks) | **Aider edit-formats** (`whole`, `diff`, `udiff`, `editor-diff`, `editor-whole`) with per-model selection and harness-side rejection | **Not yet attempted** — PF rejects on file content post-write, not on LLM emission. **Lower priority** (Claude Code's `Edit` tool already enforces format), but worth noting. |
| **Universal AGENTS.md** | `CLAUDE.md` only | **AGENTS.md standard** (Linux Foundation–stewarded, read by Codex/Cursor/Copilot/Windsurf/Amp/Devin) | **Not yet attempted** — PF should ship `AGENTS.md` as a 1-line redirect to CLAUDE.md (like SP does). **CHEAP WIN.** |
| **Subagent orchestrator-worker** | Deputy + 13 Researchers + Builder + QA | **Anthropic orchestrator-worker pattern**; **CrewAI hierarchical mode**; **LangGraph supervisor-subordinate** | **Validated reinvention** — PF's pattern matches the orchestrator-worker norm. Fine. |
| **Plugin extensibility slots** | skills + hooks + agents (3 slots) | **opencode 8-slot plugin architecture** (runtime, agent, workspace, tracker, SCM, notifier, terminal, lifecycle) | **Partial reinvention** — PF has 3, opencode has 8. The missing 5 (workspace, tracker, SCM, notifier, terminal) are mostly relevant if PF ships polyglot. **MEDIUM-priority — relevant for v1.2+ enterprise.** |

### M.6 Top 3 architectural choices that would have been different in PF v1.x

1. **Write-tool gating in non-build tiers (Cline plan-mode pattern).** PF's brainstorm, research, write-plan, and seven-validation-questions skills all currently *advise* not writing source code, but they do not *block* it at the harness level. Cline's Plan mode is hard-locked to read-only tools; the user must explicitly toggle Act mode to enable writes. **If PF had known this pattern in v1.x, the harness could have been designed with a tier-state environment variable that the structural-check hook reads to reject `Write`/`Edit` tool calls in non-build tiers.** This is exactly the class of failure mode that the deferred Issue #2 (wave-aware structural-check) is now scoping — and the prior art is explicit and BINDING (5/5 IDE-shaped frameworks have some form of mode/phase gate).

2. **Cross-platform plugin shape from day 1.** PF currently has `.claude-plugin/plugin.json` only. Adding `.cursor-plugin/`, `.codex-plugin/`, `.opencode/`, `gemini-extension.json`, and a 1-line `AGENTS.md` redirect is **cheap once but expensive to retrofit** — every skill body would need to be audited for Claude Code–specific tool names and then bridged via `references/{platform}-tools.md` files. **If PF had known the SP polyglot pattern in v1.x, every skill would have been written in tool-agnostic prose from the start.** Currently, PF skills reference Claude Code–specific concepts (`Skill` tool, `Task` tool, `${CLAUDE_PLUGIN_ROOT}`) extensively, and the v1.2+ retrofit cost is real.

3. **Repo-map primitive.** Aider's tree-sitter PageRank repo-map is the **dominant 2026 solution to "how does the LLM know what's in this codebase."** PF's architecture-doc TL;DR is a *manual* substitute that the QA agent has flagged as drift-prone (architecture docs go stale faster than the code). **If PF had known about repo-map in v1.x, the writing-arch-doc skill might have been scoped differently** — the TL;DR would have been auto-generated from the repo-map, with the human-written arch doc focused only on *invariants and intent* (the parts a repo-map can't capture). This would address the recurring "Builder Spec wasn't enough, had to read full reference" failure mode named in the Researcher prompt's output-format guidance.

### M.7 Implications for v1.2+ design

PF's strategic positioning per the PROJECT-PLAN: **enterprise multi-tenant SaaS framework, polyglot, measured by incident-prevention.** Borrowing matrix:

| If PF wants… | Borrow explicitly from… | Mechanism |
|---|---|---|
| **Polyglot (Cursor + Codex + opencode + Gemini)** | **superpowers 5.0.7** | Per-platform thin manifests in dotted dirs; tool-mapping references; 1-line AGENTS.md redirect; `gemini-extension.json` with `contextFileName` field |
| **Hard-locked plan/research mode** | **Cline / Roo Code** | Mode-state env var that structural-check hook reads to reject Write/Edit in non-build tiers; user-explicit Act-mode toggle |
| **Auto-generated repo-map for arch-doc TL;DR** | **Aider** | Tree-sitter parse + PageRank on import/call graph; cap at `--map-tokens` budget; surface in writing-arch-doc skill |
| **Multi-source rule cascade (project + module + remote)** | **Continue.dev** | 5-source aggregation: core → STACK-PATTERNS.md → module-scoped → user-personal → remote-team; documented merge priority in core/ docs |
| **Long-running parallel agents (Deputy + 13 Researchers as processes, not prompts)** | **opencode** | File-based JSONL inbox/outbox per agent; fire-and-forget spawn; explicit isolation; @mention peer-routing |
| **Two-model architect/editor split** (cost optimisation) | **Aider** | Architect mode = high-reasoning model for plan; editor model = cheap fast model for diff emission. PF's brainstorm/Builder split is the same shape; making it cross-model is cheap. |
| **Hierarchical multi-agent SDK** | **Anthropic Claude Agent SDK** + **LangGraph** | Anthropic SDK for the orchestrator-worker base; LangGraph for the directed-graph state machine when topology is non-trivial (5+ agents per the M.4 scaling note) |
| **Universal cross-tool fallback** | **AGENTS.md standard** | Drop a 1-line `AGENTS.md` → `CLAUDE.md` redirect; immediately gain cross-read by Codex/Cursor/Copilot/Windsurf/Amp/Devin |

**Ordered priority for v1.2:**

1. **Ship `AGENTS.md`** — 1-line, cheap, immediate cross-tool reach. (Source: SP precedent + agents.md/ Linux Foundation standard.)
2. **Adopt write-tool gating in non-build tiers** — addresses recurring drift, validated by 5/5 IDE-shaped framework prior art. (Source: Cline Plan & Act docs; Researcher Issue #2 deferred.)
3. **Auto-generate repo-map** — addresses Builder Spec gap, BINDING per Aider 2026 dominance. (Source: aider.chat/docs/repomap.html.)
4. **Polyglot adapter shape** — only if PF actually wants to ship beyond Claude Code; if not, skip. (Source: SP 5.0.7 polyglot manifest tree.)
5. **Multi-source rule cascade** — only if STACK-PATTERNS.md has hit its limit (Researcher I will confirm). (Source: Continue.dev config.yaml docs.)

### M.8 Risks / open questions

1. **The "methodology vs harness" boundary is shifting.** Cursor 2.4 (Apr 2026) shipped subagents, skills, and image generation natively in the IDE. As IDEs absorb the methodology layer (rules files become as expressive as plugin frameworks), PF's positioning as a *standalone framework* may erode. Worth a follow-up Research cycle: *"how much of PF is implementable as a Cursor rules pack? as a `.cursor/rules/` directory?"* If most of it is, PF should ship as a Cursor rules pack via the SP polyglot pattern, not as a standalone framework.

2. **opencode's 8-slot plugin architecture is a serious design challenge.** The `tracker` and `notifier` slots in particular are interesting — opencode plugins can hook into agent lifecycle events for telemetry/observation. **PF has no observability layer**, and Issue #5 (rolling handover) suggests this gap is recurring. The opencode tracker model is worth deep-reading in a follow-up.

3. **Benchmark contamination + standardised scaffolding (SWE-bench Pro).** PF's "incident-prevention rate" metric needs operationalisation. **Is there a benchmark like SWE-bench Pro but for production-incident-prevention?** Likely not — PF would need to either commission one or accept that the metric is qualitative for v1.2. Worth a follow-up Research cycle on *"production agent metrics 2026"* (separate from coding benchmarks).

4. **AGENTS.md standardisation governance.** AGENTS.md is now under Linux Foundation Agentic AI Foundation stewardship. **Does PF want to engage with that governance process?** Short answer: not for v1.2; AGENTS.md is loose enough that PF can ship a 1-line redirect without engagement. But for v2.0, PF's CLAUDE.md authoring conventions could be proposed as AGENTS.md best practice — a moat-building move, not a moat-defending move.

5. **Aider's edit-format primitive could inform PF's structural-check hook design.** Currently PF rejects on file content post-write. Aider rejects on LLM emission pre-write (the edit-format must parse). The pre-write rejection is **cheaper** (no file mutation rolled back) and **more informative** (the LLM gets the parse error and re-emits). Worth a follow-up: *"can PF's structural-check hooks intercept the Edit tool call rather than the post-write file?"*

**Sources:**
- SP 5.0.7 cache: `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/` — `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `gemini-extension.json`, `.cursor-plugin/plugin.json`, `.codex-plugin/plugin.json`, `.opencode/INSTALL.md`, `.opencode/plugins/superpowers.js`, `hooks/hooks.json`, `hooks/hooks-cursor.json`, `skills/using-superpowers/references/{codex,copilot,gemini}-tools.md`
- Aider docs: https://aider.chat/docs/repomap.html · https://aider.chat/docs/usage/modes.html · https://aider.chat/2023/10/22/repomap.html · https://github.com/Aider-AI/aider/blob/main/aider/website/docs/repomap.md
- Cursor docs: https://cursor.com/docs/context/rules · https://cursor.com/blog/agent-best-practices · https://cursor.com/changelog/2-4 · https://forum.cursor.com/t/agent-plugins-isolated-packaging-lifecycle-management-for-sub-agents-skills-hooks-rules-incl-agent-md-across-cursor-ide-cli/151250
- Continue.dev docs: https://docs.continue.dev/customize/deep-dives/configuration · https://docs.continue.dev/customize/slash-commands · https://deepwiki.com/continuedev/continue/5.1-plugin-architecture
- Cline docs: https://docs.cline.bot/features/plan-and-act · https://cline.bot/blog/plan-smarter-code-faster-clines-plan-act-is-the-paradigm-for-agentic-coding · https://deepwiki.com/cline/cline/3.4-plan-and-act-modes
- opencode: https://opencode.ai/docs/agents/ · https://github.com/aptdnfapt/opencode-parallel-agents · https://github.com/kdcokenny/opencode-workspace · https://dev.to/uenyioha/porting-claude-codes-agent-teams-to-opencode-4hol · https://medium.com/@saurabbhatia/how-i-coordinate-19-ai-agents-across-4-model-families-with-opencode-and-recallium-00bc14fb8ccb
- Anthropic Claude Agent SDK: https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk · https://www.anthropic.com/engineering/multi-agent-research-system · https://code.claude.com/docs/en/agent-sdk/overview
- Multi-agent topology: https://www.datacamp.com/tutorial/crewai-vs-langgraph-vs-autogen · https://gurusup.com/blog/best-multi-agent-frameworks-2026 · https://qubittool.com/blog/ai-agent-framework-comparison-2026
- SWE-bench: https://www.swebench.com/verified.html · https://openai.com/index/introducing-swe-bench-verified/ · https://www.morphllm.com/swe-bench-pro · https://arxiv.org/abs/2510.08996
- AGENTS.md standard: https://agents.md/ · https://www.deployhq.com/blog/ai-coding-config-files-guide · https://vibecoding.app/blog/agents-md-guide
- Landscape overview: https://www.faros.ai/blog/best-ai-coding-agents-2026 · https://www.secondtalent.com/resources/open-source-ai-coding-assistants/ · https://gurusup.com/blog/best-ai-for-coding

<!-- END-CATEGORY-M -->

---

## Synthesis (Deputy, 2026-04-28, post 13/13 returns + debugger)

This synthesis collapses the 13 category reports + the rebench-negative debugger diagnostic into a single architectural verdict, three strategic paths, and one falsifiable next experiment. Section bodies above are the citation surface; this section is the actionable summary.

### Architectural verdict — 7 layers, 7 design failures

The v1.1.0 fix didn't move the central metric (skill firing) because every layer of PF's discipline-delivery stack is built on a primitive that doesn't actually work the way the docs imply. Per-layer:

| Layer | What's broken | Citation |
|---|---|---|
| **L1 — Cascade entry** | `tier-selection` is framework-shaped (no user prompt says "pick a tier"); cold prompts go straight to `Agent(Explore)`; cascade has no seed → 0 PF skills fire on Tier-3-eligible work | Debugger §A; Cat B (SP fires 1 skill empirically, not the cascade either plugin designs for) |
| **L2 — Agent topology** | 7-agent design IS the Anthropic-named anti-pattern ("agents specialized by software development role") — verbatim from Anthropic's engineering blog: "telephone game" pattern that "spent more tokens on coordination than actual work." Ratio: corpus=16.1 skills/agent, PF=3.7 (4.4× agent-heavy) | Cat K, Cat D (3-10× token overhead per Anthropic) |
| **L3 — Bootstrap mandate** | 1%-mandate has zero escape hatches; SP's mandate works because of a 12-row Red Flags rationalization-defeater table PF lacks. Plus shipping bug: `<EXTREMELY-IMPORTANT>` doubled-wrapped (PF body + hook wrapping) | Cat C |
| **L4 — Discipline delivery** | Hook stderr warnings don't reach the model — `post-write-md-lint.sh` and `agent-return-parse.sh` ship discipline that never reaches the decision layer. Same failure-class as #001 at different events | Cat H |
| **L5 — Routing reliability** | Auto-routing is acknowledged-unreliable per Anthropic ("Claude has a tendency to undertrigger"); subagent permission inheritance is unstable post-CC-2.1.56 | Cat A, Cat F |
| **L6 — Coverage scope** | If positioning is "enterprise multi-tenant SaaS framework," PF v1.x covers ~30%; Gate-3 covers ~40% of a Google PRR. v1.2 retrofit is impossible — it's a v2.0.0 redesign | Cat L |
| **L7 — Process / meta** | Dogfooded only — never applied PF's own `enterprise-research-first` to PF's own primitives. Every category found prior art PF didn't study (Aider repo-map, agents.md standard, plan-vs-act gating, SP companion docs, Google SRE PRR, Stripe migration playbooks). The framework that mandates research didn't research itself. | Cat M, Cat G, Cat L; PROJECT-PLAN.md Incident Table |

### Top 5 cross-category findings

1. **PF v1.x implements an Anthropic-named anti-pattern verbatim.** Cat K's blog citation is the most damning single data point: PF's exact agent topology ("planner, implementer, tester, reviewer") is named in writing as a "telephone game" failure mode by the company that built Claude. Not a calibration issue, not a misexecution — the architecture itself is the named anti-pattern.

2. **The cascade design has no empirical referent.** Cat B confirmed SP fires 1 skill (not 5+ as SP's docs suggest) and PF fires 0. No shipped plugin runs cascades the way PF's design assumes. The whole "tier-selection → brainstorming → writing-plan → 7-questions → enterprise-research-first → regression-scope → gate-3 → verification" chain has zero empirical support.

3. **PF ships discipline that doesn't reach the decision layer.** Cat H found 2 hooks emitting warnings to stderr the model never sees; Debugger found bootstrap content delivered but bypassed; Cat C found mandate doubled-wrapped without escape hatches. The pattern is consistent: PF builds enforcement that fails silently at the delivery boundary.

4. **Every fix needed already exists in SP, verbatim-portable.** Cat I (skill-triggering harness — verbatim port, ~$0.10/60s vs ~$3/1170s); Cat C (Red Flags table — verbatim port); Cat G (`testing-skills-with-subagents.md` companion doc — verbatim port); Cat M (polyglot manifest pattern, agents.md adoption — verbatim port). The fix isn't research-and-invent — it's read-and-port.

5. **Plan-vs-act write-tool gating is a 5/5 BINDING gap.** Cat M found every IDE-shaped framework (Cline, Cursor, Continue, Aider, opencode) implements PLAN→ACT mode transitions gated by user approval. PF has no equivalent — Builder fires writes whenever it wants. This is the strongest forcing-function in the AI-IDE space and PF skipped it.

### Concrete shipping-bugs surfaced (independent of synthesis)

These are immediate fixes regardless of strategic direction:

| Bug | Severity | Source | Fix |
|---|---|---|---|
| `marketplace.json:version=1.0.1` vs `plugin.json:version=1.1.0` mismatch | HIGH (ship-blocker for github-source consumers) | Cat J + Cat E | One-line edit |
| Doubled `<EXTREMELY-IMPORTANT>` wrapping (body + hook) | MEDIUM | Cat C | Remove one |
| Stray nested `production-framework/` subdir in cache from v1.0.1 install | LOW | Cat J | `rm -rf` the orphan dir |
| `post-write-md-lint.sh` and `agent-return-parse.sh` warnings emit to stderr instead of `hookSpecificOutput.additionalContext` | MEDIUM (hooks are silently ineffective) | Cat H R2 | Convert to JSON output with `additionalContext` |
| Latent: Stop-hook migration trap (uses top-level `decision/reason`, NOT `hookSpecificOutput`) | LOW (only fires if we migrate) | Cat H | Add core/rules.md row documenting Stop schema asymmetry |
| Researcher-finding contradiction: J says directory-source is copied; E says it's symlinked | RESOLVED | Cat J + Cat E | Symlinks (E + Issue #28492) — content edits land live, version/layout changes need reinstall |

### Three strategic paths for v1.2+

The verdict above doesn't dictate strategy. There are three architecturally-distinct paths the user can pick:

#### Path 1 — Rescue (v1.2 SP-shape conformance)

Strip PF to SP's shape: 1 named agent or fewer, embedded prompt fragments instead of separate agent files, single-skill firing as the design contract (no cascade), task-shaped entry points, ported Red Flags table, ported skill-triggering harness, plan-vs-act gating. Drop the doctrinal `core/` layer or fold it into skill bodies.

**Output:** A generic SE-discipline plugin structurally similar to SP, optimized to fire reliably on cold prompts. Roughly ~30-40% of current PF surface area retained.

**Cost:** ~1-2 months of refactoring. Loses the doctrinal anchor + post-mortem self-evolution loop (PF's distinct value).

**When to pick:** if user's strategic answer to "what is PF actually" lands on "SP-equivalent for Claude Code, generic SE discipline."

#### Path 2 — Pivot (v2.0 enterprise multi-tenant SaaS framework)

Path 1 PLUS the enterprise multi-tenant scope: 8 new skills (per Cat L), 12 new universal rules, extended Gate-3 covering Google SRE PRR (~40% → 100%) + tenancy isolation + audit-trail/SOC2 + tenant-aware migration choreography. Adopt agents.md standard (per Cat M).

**Output:** What the user explicitly said they want — "what SP is but for end-to-end scalability focused enterprise grade multi-tenant SaaS."

**Cost:** ~3-6 months (Path 1 + L's scope). v2.0.0 MAJOR bump per CLAUDE.md.

**When to pick:** if the strategic answer is enterprise multi-tenant. **Don't drift into this** — it's a deliberate fork.

#### Path 3 — Park-and-Extend

Park PF as a standalone framework. Adopt SP as the base discipline plugin. Build PF's distinct value (post-mortem loop, doctrinal layer, Gate-3, enterprise multi-tenant skills) as **extensions of SP** — either as a thin extension package depending on SP, or as a fork-and-add. PF becomes "SP + enterprise multi-tenant + post-mortem self-evolution."

**Output:** Maximum reuse of SP's already-shipped polish. No double-maintenance of generic SE discipline.

**Cost:** ~2-4 months. Architectural cost: dependence on SP's release cadence; can't easily reshape SP primitives if they regress.

**When to pick:** if reducing maintenance burden is the priority and SP's discipline-shape is acceptable as-is.

### Recommended next experiment (single, falsifiable)

Independent of the strategic path, the immediate next move is the same:

> **Port SP's skill-triggering harness verbatim** (Cat I — `tests/skill-triggering/run-test.sh` + `tests/explicit-skill-requests/run-multiturn-test.sh` + `analyze-token-usage.py` + `test-helpers.sh`). Substitute prompt corpus only.
>
> Cost per cycle: **~$0.10 / 60s** vs ECA Portal's ~$3 / 1170s. **30× cost reduction, 20× speed reduction.**
>
> Then run a controlled 3-arm A/B on a fixture corpus:
> - **V1:** current v1.1.0 (control)
> - **V2:** v1.1.0 minus the 1%-mandate, minus doubled wrapping (test if those alone caused the regression)
> - **V3:** v1.1.0 plus SP's Red Flags table verbatim AND a task-shaped entry-point skill ("starting-work" / "developing-feature" — replacing `tier-selection` as the cold-discoverable entry)
>
> **Pass criterion (per Debugger §E):** ≥1 PF skill fires on cold task arrival before first `Agent(Explore)` dispatch.
>
> If V3 passes and V1/V2 don't → architectural diagnosis confirmed end-to-end. Then strategic-path decision.
> If V3 still fails → escalate to deeper hypothesis (no recoverable v1.x fix; jump straight to Path 1 or 2).

This experiment costs ~$0.30 total vs ~$9 for ECA Portal cycles. The harness pays for itself within one cycle.

### Binding rules going forward (PROJECT-PLAN.md Pre-design research gaps section enforcement)

Closing the meta-incident from Cat L7:

1. **Every new PF design decision touching framework primitives** (skills, agents, hooks, bootstrap, install lifecycle) MUST cite the relevant Categories A-M queries from PROJECT-PLAN.md AND show a verbatim SP equivalent (or document its absence) before the Builder phase fires.
2. **No new architectural primitive without N≥5 enterprise-source consensus** — Anthropic doc, ≥3 OSS plugins, the field as a whole. (PF's own `enterprise-research-first` skill, applied to PF.)
3. **Borrow before invent.** Cat I, Cat C, Cat G, Cat M each found a verbatim-portable SP artifact. Default move on any PF gap: "is there an SP / Aider / Cursor / Continue / Cline equivalent?" before designing PF-original.
4. **Skill-triggering harness gates every behavior change.** Once Cat I's port lands, no skill description / agent description / bootstrap content edit ships without passing the harness on the fixture corpus.
5. **Adopt agents.md.** PF should ship `AGENTS.md` and `CLAUDE.md` files at root per the Linux Foundation standard (Cat M) — minimal cross-tool compatibility for free.

### Priority-ordered actionable list

1. **(Now)** Fix the 6 shipping bugs surfaced above (marketplace.json mismatch, doubled wrapping, nested cache, hook stderr → JSON, Stop schema rule, harness port).
2. **(After harness lands)** Run the 3-arm A/B from "Recommended next experiment."
3. **(After A/B data)** Strategic path decision: 1 / 2 / 3.
4. **(Per chosen path)** Execute restructuring.
5. **(Continuous)** Apply the 5 binding rules to every future change.

### Open questions for the user

- Which strategic path? (Path 1 rescue, Path 2 pivot, Path 3 park-and-extend.)
- Should the 6 shipping bugs be fixed now (independent of path) or held for path-1/2/3 batch?
- Is `agents.md` adoption attractive even if Path 3 (so PF/SP both honor the same standard)?

These are decisions, not research questions — the data is on disk.
