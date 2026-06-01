---
name: configure-project-gates
description: "Use this skill to pick which production-framework HARD-GATEs activate for a specific project. Reads the canonical 42-gate catalog at docs/catalog/hard-gates.md, weighs each gate against the project's STACK-PATTERNS, FEEDBACK history, observed trigger rates, and user-stated priorities, then writes the project-specific activation list to .framework-state/active-gates.yaml plus a human-readable summary into the project's CLAUDE.md ## Active Gates section. Fire this skill on first-session-with-the-framework, after FEEDBACK.md gains new entries, after STACK-PATTERNS changes, or any time the user says 'configure gates', 'set up gates', 'tune which skills fire', 'too many gates triggering', 'gates aren't firing when they should', 'set up production-framework for this project', or anything similar. This is the canonical way to make the framework fit the project — every other skill activates or stays dormant based on what this skill writes."
---

# configure-project-gates

## Overview

Production-framework v2.4.0 ships a catalog of ~42 HARD-GATEs. Nine are universal (always-on, hardcoded). Eight are stack-conditional (auto-activated by STACK-PATTERNS). The remaining 25 are configurable — they apply when the project benefits from the discipline, and stay dormant otherwise.

This skill is the deliberation layer between the catalog and the project's CLAUDE.md. It reads project signals (stack contract, accumulated feedback, observed pain, user priorities), scores each configurable gate, and writes:

1. `.framework-state/active-gates.yaml` — machine-readable activation list the hook reads on every PreToolUse event
2. `<project-root>/CLAUDE.md` `## Active Gates` section — human-readable per-line summary with one citation per gate
3. A first-run report to the user explaining what activated, what stayed off, and why

Without this skill, the framework runs in two failure modes: (a) all gates fire everywhere, producing the F-V38 bypass-fatigue pattern, or (b) skill-body HARD-GATEs are read but ignored, the TaskIt pattern where 31 of 36 skills sat unused while their disciplines would have prevented real bugs.

## When to fire

Fire automatically when:

- `<project-root>/CLAUDE.md` is missing the `## Active Gates` section
- The `## Active Gates` section's `last_configured:` timestamp is older than `docs/FEEDBACK.md`'s last-modified time
- `.framework-state/active-gates.yaml` is missing
- `.framework-state/active-gates.yaml`'s `last_configured:` is older than 14 days
- `templates/STACK-PATTERNS.md` was modified since last configuration

Fire on user invocation when they say anything like:

- "configure the framework for this project"
- "set up gates / skills"
- "which skills should fire here"
- "too many gates are blocking me"
- "this gate keeps firing and shouldn't" (single-gate retune)
- "the framework isn't catching X" (gate-add request)
- "tune the production-framework for this project"
- Direct: `/configure-project-gates`

Do NOT fire for:

- A single Edit / Write task that doesn't change project shape
- Re-running cycle-selection mid-cycle
- Tier 1 changes (typo, comment) unrelated to framework configuration

## Core Pattern

You MUST create a TodoWrite item per phase and complete them in order. The skill has 5 phases.

### Phase 1 — Detect run mode

Three modes; pick one before reading anything:

1. **First-run.** No `.framework-state/active-gates.yaml` AND no `## Active Gates` section in CLAUDE.md. Activate the universal floor + stack-conditional auto-set + recommend a starter configurable set; produce a comprehensive first-run report; ask user to ratify before writing.
2. **Periodic re-run.** Files exist but are stale (older than `docs/FEEDBACK.md` or 14 days). Read the existing config; diff against catalog; surface gates the project should now activate (per new FEEDBACK entries) or deactivate (per high bypass rate in `.framework-state/decision-log.jsonl`).
3. **Targeted retune.** User asked about a specific gate ("X keeps firing", "Y isn't catching the bug"). Make the focused adjustment, not the full reconfiguration.

Output: which mode you're in, in your reply.

### Phase 2 — Read the catalog

The canonical catalog is at `docs/catalog/hard-gates.md` (~1700 lines, ~42 entries). Reading it in main session is heavy-read territory.

**Prefer in this order:**

1. **If `docs/catalog/hard-gates.json` exists AND is newer than the .md** — read the JSON directly. It's the parsed form; iterate over `.gates[]`.
2. **If the catalog content is already loaded in the current context window** (rare — only when the skill's author just wrote it, e.g. during dogfood bootstrap) — parse inline. Document this branch in the report so future sessions don't replicate the shortcut.
3. **Otherwise dispatch a `production-framework:researcher` sub-agent** to generate the JSON form:

```
Parse docs/catalog/hard-gates.md and return a compact JSON list. For each gate, include:
- id
- category (universal | stack_conditional | configurable)
- trigger_class
- trigger (tool, file_pattern, state_when, agent, phase as applicable)
- severity (critical | standard | friction)
- default_state (only meaningful for configurable category)
- activator (only meaningful for stack_conditional category)
- source
Write to docs/catalog/hard-gates.json and return DONE with the file path.
```

The JSON form is the input to Phases 3-4. Cache it; re-generate only when the .md is newer.

### Phase 3 — Score each gate against the project

Walk the catalog and bucket each gate.

**Universal floor (11 entries)** — always activate. No project input. These are the framework's identity; they cannot be disabled. v2.6.0 added U-10 (`agent-output-file-landed`) and U-11 (`subagent-scope-write-enforcement`) — both fire on every sub-agent dispatch / Write/Edit regardless of project shape.

**Stack-conditional (10 entries)** — activate IFF the project's `templates/STACK-PATTERNS.md` (or equivalent stack-contract file declared in `CONFIG.yaml`) declares the activator condition. Walk each gate's `activator:` field:

- `STACK-PATTERNS.tenancy-model in (pool, bridge, hybrid)` → activate tenant-set
- `STACK-PATTERNS.surface includes UI` → activate browser-driven-verification
- `STACK-PATTERNS.has-migrations = true` → activate migration-phase-classification
- **`STACK-PATTERNS declares postgres + migrations directory` (v2.6.0)** → activate S-09 `mig-precondition-disclosure` (Gate A — pre-dispatch disclosure check)
- **`STACK-PATTERNS.supabase_branching: true` (v2.6.0)** → activate S-10 `mig-dry-apply` (Gate B — post-write dry-apply against branch DB)
- etc.

If STACK-PATTERNS is missing or unparseable, ask the user the equivalent questions inline ("Is this project multi-tenant? Does it have a UI surface? Does it ship migrations?") and treat their answers as the stack contract. Offer to write a minimal STACK-PATTERNS.md so the same questions don't get asked next session.

**Configurable (25 entries)** — score each against the decision rubric below; sort by score; recommend activation per band.

### Phase 4 — The decision rubric (configurable gates only)

For each configurable gate, compute a score from these signals. The skill is not a maximizer — over-activation produces F-V38 bypass-fatigue. Aim for ~10-15 configurable gates active per project, not 25.

Signals that **raise** the score (gate is more valuable for this project):

- **`default_state: recommend_on` in catalog** — base score +2
- **FEEDBACK.md contains an entry tagged with this gate's source (e.g., F-V34 → pm-audit-first)** — +3 per matching entry (compounds)
- **`.framework-state/trigger-audit.jsonl` shows the gate's owning skill never fired despite many sessions** — +1 (under-triggering signal)
- **STACK-PATTERNS declares a feature the gate guards** (e.g., gates touching `architect` agent when the project has architecture docs) — +2
- **User explicitly asked for the discipline** — +5 (user voice is highest signal)

Signals that **lower** the score:

- **`.framework-state/decision-log.jsonl` shows this gate bypassed ≥3 times in last 30 sessions** — -3 (likely overcorrection or too-broad trigger)
- **`default_state: recommend_off` in catalog** — base score -2
- **Project shape doesn't match** (e.g., browser-driven-verification when project is a CLI tool) — -5
- **The gate's owning agent isn't used by this project** (e.g., post-mortem gates when project has no incidents) — -2
- **User explicitly objected ("we don't enforce TDD here")** — -5

**Activation bands** (computed against final score per gate):

- Score ≥ +3: recommend activation as `enforcement_mode: block` (high-signal)
- Score 0 to +2: recommend activation as `enforcement_mode: warn` with `max_per_session: 3`
- Score -2 to -1: leave dormant; surface as "consider adding" in report
- Score ≤ -3: leave dormant; do not surface unless user asks

Severity tier locks: `critical` gates cannot be downgraded below `block`; `friction` gates cannot be escalated to `block` without operator override.

### Phase 5 — Write artifacts + first-run report

Three writes, in order:

#### Output 1 — `.framework-state/active-gates.yaml`

The hook reads this on every PreToolUse. Schema follows the catalog row, with project-specific override fields:

```yaml
# .framework-state/active-gates.yaml
schema_version: 1
last_configured: "2026-05-17T18:42:00Z"
catalog_version: "1"               # tracks docs/catalog/hard-gates.md schema_version
configured_by: configure-project-gates
configured_for: "<project name>"

# Universal floor — always-active, listed here for transparency only.
# The hook activates these regardless of what's in this file.
universal_floor:
  - evidence-before-completion
  - no-fix-without-root-cause
  - enterprise-citation-rule
  - active-gates-fresh
  - heavy-read-dispatch
  - gate-3-production-check
  - builder-empty-diff
  - no-pii-in-logs
  - data-loss-disclosure

# Stack-conditional — auto-activated by STACK-PATTERNS at <path>.
# Lists only the ones currently active per the stack contract.
stack_conditional_active:
  - id: tenancy-model-declared
    activated_by: "STACK-PATTERNS.tenancy-model = pool"
  - id: rls-force-or-non-owning
    activated_by: "STACK-PATTERNS.tenancy-model = pool AND uses-RLS = true"
  # ... 6 more if applicable

# Configurable — project-selected. The list this skill writes.
configurable_active:
  - id: tier-selection-on-task-shape
    enforcement_mode: block
    max_per_session: null
    justification_required: true
    score: 5
    reason: "Universal-floor adjacent; project runs Tier 2/3 cycles per PROJECT-PLAN"
  - id: worktree-preflight
    enforcement_mode: block
    max_per_session: null
    justification_required: true
    score: 6
    reason: "FEEDBACK WORKTREE family (5 entries) — 100% recurrence on multi-Builder waves"
  - id: pm-audit-first
    enforcement_mode: block
    max_per_session: null
    justification_required: true
    score: 8
    reason: "FEEDBACK F-V34 — 2 cycles saved this session; project has shipped history"
  # ... 7-12 more depending on project signals

# Dormant — listed for transparency. Hook does NOT enforce these.
# configure-project-gates will reconsider on next re-run.
dormant:
  - id: pm-given-when-then
    score: -1
    reason: "Project AC format is already structured; no BDD-tooling in stack"
  - id: tdd-iron-law
    score: -2
    reason: "Project policy is post-hoc tests for non-critical paths; CLAUDE.md does not declare TDD"
  # ... etc

# Bypass policy (project-wide overrides)
bypass_policy:
  log_path: ".framework-state/decision-log.jsonl"
  require_justification_for_session_wide: true   # PF_BYPASS_ALL needs PF_BYPASS_REASON
  kill_switch_path: ".framework-state/PF_GATES_DISABLED"
```

Bash hook's parsing strategy (no jq required, per CLAUDE.md zero-deps posture): treat `id:` as record separator within each section; for each record extract `enforcement_mode` and `max_per_session` via grep + bash parameter substitution.

#### Output 2 — `<project-root>/CLAUDE.md` `## Active Gates` section

Human-readable per-line summary the CTO session and sub-agents read. Format:

```markdown
## Active Gates

<!-- Managed by production-framework:configure-project-gates. Re-run that skill after FEEDBACK.md updates. -->
<!-- last_configured: 2026-05-17T18:42:00Z -->
<!-- catalog: docs/catalog/hard-gates.md v1 -->

### Universal floor (always-active)
- `evidence-before-completion` — fresh verification command before any DONE claim (SP verification Iron Law)
- `no-fix-without-root-cause` — debugger Iron Law before any builder dispatch in debug cycle
- ... (9 total)

### Stack-conditional (auto-activated by STACK-PATTERNS)
- `tenancy-model-declared` — multi-tenant project; DB Engineer cannot author schema without declared model
- `rls-force-or-non-owning` — RLS-using project; FORCE or non-owning role required
- ... (N active out of 8)

### Configurable — project-selected
- `worktree-preflight` (block) — Builder worktree dispatches require clean git status + pinned SHA (FEEDBACK WORKTREE, 5 incidents)
- `pm-audit-first` (block) — PM specs require §0 Pre-spec audit (FEEDBACK F-V34, 2 cycles saved)
- `find-similar-implementations` (warn, max 3) — new primitive in src/(lib|hooks|utils) — invoke 4-step search (audit Item 39)
- ... (~10-15 active)

### Dormant — reconsidered on next re-run
- `pm-given-when-then` — project AC format is already structured
- `tdd-iron-law` — project policy is post-hoc tests
- ... (~10-15 dormant)

### Bypass grammar
- Per-rule: `PF_BYPASS=<gate-id>` (logs to decision-log.jsonl)
- Session-wide: `PF_BYPASS_ALL=1 PF_BYPASS_REASON="<reason>"` (logs)
- Project kill switch: `touch .framework-state/PF_GATES_DISABLED` (logs every invocation)
```

This section is the contract between configure-project-gates (the writer) and the CTO session + sub-agents (the readers). Sub-agent dispatches that need to enforce project-specific gates read from here.

#### Output 3 — First-run / re-run report to user

Return ≤30 lines summarizing what changed. Lead with the deltas; do not narrate the unchanged universal floor.

```
configure-project-gates — <first-run | periodic re-run | targeted retune>

Activated:
  + worktree-preflight (block) — FEEDBACK WORKTREE 5 entries, 100% recurrence
  + pm-audit-first (block) — F-V34, 2 cycles saved
  + find-similar-implementations (warn, max 3) — audit Item 39
  + early-playwright-smoke (block) — F-V15/F-V17, UI surface declared
  + ... (N total newly-active)

Kept active from prior run: <M gates>
Deactivated:
  - pm-given-when-then — project AC format already structured (score -1)

Stayed dormant: <K gates>
Bypass-rate-flagged (consider retuning): <L gates with citations>

Next re-run trigger: when docs/FEEDBACK.md changes OR after 14 days
Files written: .framework-state/active-gates.yaml, <project>/CLAUDE.md ## Active Gates section
```

The report doubles as input for the user to ratify before the writes commit. On first-run, pause for ratification; on periodic re-run, write directly but show the delta.

## Inputs the skill reads

The skill ranks evidence in this order — lower-ranked sources cannot override higher-ranked ones:

1. **User explicit input** in this session — highest priority
2. **CLAUDE.md `## Active Gates` section** (the project's prior choice — preserve unless explicitly overruled)
3. **STACK-PATTERNS.md** (the stack contract — drives stack-conditional gates)
4. **FEEDBACK.md** (accumulated pain log — drives configurable gate weighting)
5. **`.framework-state/decision-log.jsonl`** (bypass history — surfaces over-eager gates)
6. **`.framework-state/trigger-audit.jsonl`** (skill invocation history — surfaces under-firing gates)
7. **PROJECT-PLAN.md Open Findings** (active project pain — adds context)
8. **Catalog `default_state`** — lowest priority; baseline only

When sources conflict, take the highest-priority source. Document the conflict in the report.

## Re-run handling

On periodic re-run (mode 2 from Phase 1):

- **Never silently deactivate a gate the user explicitly enabled.** Even if its score dropped, surface for user decision.
- **Always honor new FEEDBACK entries.** A new HARD-GATE-tagged entry in FEEDBACK.md gets considered for activation.
- **Mine the decision-log.** A gate with bypass-rate ≥3/30-sessions becomes a "consider retune" item. Don't auto-deactivate; ask.
- **Diff before writing.** Show the user the before/after for active-gates.yaml and the CLAUDE.md section. Commit only after acknowledgment (one-line "ok" is enough).

On targeted retune (mode 3):

- Touch only the specific gate the user asked about.
- Re-run the rubric for that gate; show the user the new score + reason.
- Update active-gates.yaml + CLAUDE.md selectively; don't rewrite the whole file.

## Edge cases

- **No STACK-PATTERNS.md exists.** Ask the user a 5-question stack survey (multi-tenant? UI? migrations? has-deploys? has-audit-trail-requirement?) and offer to write a minimal stack contract.
- **No FEEDBACK.md exists.** Skip the FEEDBACK signal; weight catalog `default_state` more heavily for the first run; ask user if they have any pain points to seed the file.
- **No decision-log.jsonl exists.** It's a fresh project; no bypass history to mine. Note in the report.
- **CLAUDE.md does not exist.** Create it with the `## Active Gates` section + a one-paragraph header explaining the framework. Do not invent other CLAUDE.md content — only add the gates section.
- **CLAUDE.md exists but has no `## Active Gates` section.** Append it; do not modify any other section.
- **User says "activate all configurable gates".** Honor but warn: "Activating all 25 produces ~5-10 gates firing per Edit/Write; F-V38 bypass-fatigue is highly likely. Recommend starting with the high-signal subset first." Then activate all if user confirms.
- **User says "deactivate everything".** Cannot deactivate the universal floor (hardcoded). Deactivate all configurable; preserve stack-conditional. Surface the limit clearly.
- **Project shape: the production-framework itself (meta).** Use the preset below. The active-gates.yaml lives at the framework repo's `.framework-state/active-gates.yaml` and gates the framework's own contributors. The bootstrap deviation declared in RELEASE-NOTES v2.4.0 applies — the framework configures itself for itself.

### Meta-project preset (production-framework configuring itself)

When the project IS the production-framework repo:

- Inferred project shape: `tenancy: n/a · surface: no-UI · has-migrations: no · production-ready: no (plugin not service) · audit-trail: informal (.framework-state logs)`
- Universal floor: 9/9 always active
- Stack-conditional: 0/10 (no multi-tenant, no UI, no migrations, no SLO surface — same rationale extends to v2.6.0's mig-precondition-disclosure + mig-dry-apply which require postgres+migrations the framework itself doesn't ship)
- Configurable: prefer ~18 active (high cross-cutting concern density per dogfood validation 2026-05-17)

Do not ask the 5-question stack survey for this case; use the preset values verbatim. Document the run as `configured_for: "production-framework v2.X.X (meta)"`.

### Trigger path overrides (project-specific path remapping)

The catalog's `trigger:` blocks reference canonical filenames (e.g., `docs/COMPETITORS.md`, `docs/STACK-PATTERNS.md`). Real projects may use different filenames. Read `CONFIG.yaml > trigger_path_overrides:` if it exists:

```yaml
# CONFIG.yaml
trigger_path_overrides:
  competitors_doc: "docs/research/enterprise-multi-agent-architecture.md"
  stack_patterns: "docs/conventions.md"
  feedback_log: "docs/FEEDBACK.md"
```

When `configure-project-gates` writes `.framework-state/active-gates.yaml`, it should substitute the override paths into each gate's `state_when:` predicates so the hook's evaluation matches the project's actual file layout. Without this, gates that depend on canonical paths never fire even when activated.

### Score-0 gates whose owning agent is never used

A configurable gate with score 0 normally activates as `warn`. But if `.framework-state/trigger-audit.jsonl` shows the gate's owning agent (e.g., `production-framework:security-compliance`) has 0 dispatches in the last 30 sessions, demote the gate to `dormant` — activating costs near-zero but adds noise to the CLAUDE.md section without ever firing.

**Threshold:** 0 dispatches in last 30 sessions → demote. 1+ dispatches in last 30 → keep at warn. No trigger-audit history exists yet → keep at warn (give the gate a chance to fire on first use).

## Self-Check Before Declaring DONE

Before writing the files, audit your output:

1. **Universal floor count is exactly 9.** If you wrote fewer, you missed one. If you wrote more, you elevated a configurable gate without authority.
2. **Every stack-conditional gate in `stack_conditional_active` has a non-empty `activated_by:` field.** Empty means you couldn't justify activation; remove it.
3. **No configurable gate has `enforcement_mode: block` if its catalog severity is `friction`.** Severity tier locks must hold.
4. **Every active configurable gate has a `reason:` field with at least one source citation.** "Recommended" isn't a reason; "FEEDBACK F-V34, 2 cycles saved" is.
5. **The CLAUDE.md write does not modify any section other than `## Active Gates`.** Read the file before and after; verify diff is bounded.
6. **The report's delta count matches the diff between prior and new active-gates.yaml.** If you wrote "Activated: 4 gates" but the diff shows 5, fix the report.
7. **`last_configured:` timestamp written in ISO 8601 UTC.** Other formats break the staleness check (U-04).

If any audit fails, fix before writing.

## Status tokens

- `DONE` — active-gates.yaml + CLAUDE.md ## Active Gates section + report all written; audit passed
- `DONE_WITH_CONCERNS` — written but flagged: low-signal project (no FEEDBACK, no decision-log, fresh-clone); recommend re-running after first real cycle
- `NEEDS_CONTEXT` — STACK-PATTERNS unparseable AND user-survey returned ambiguous answers; cannot proceed
- `BLOCKED` — catalog at `docs/catalog/hard-gates.md` missing or unparseable; cannot proceed without it

## Composability

- **Replaces** the prior implicit "every HARD-GATE is on for every project" model.
- **Consumed by** the pre-tool-use hook (reads `.framework-state/active-gates.yaml` to know which configurable gates to enforce).
- **Consumed by** every CTO sub-agent dispatch (orchestrator reads the project's `## Active Gates` section and prepends active gates to the dispatch prompt; see ADR-FUTURE).
- **Read by** the U-04 universal floor gate (active-gates-fresh) at session start.
- **Triggers** when FEEDBACK.md is updated by writing-framework-feedback (or any other feedback-authoring) skill.

## Common Mistakes

- **Activating every gate by default.** F-V38 bypass-fatigue is real. Activating 25 configurable gates produces a session where every Edit/Write triggers 5+ gates; the user bypasses everything; the discipline collapses. Aim for ~10-15 active configurable gates; prune by score, not enthusiasm.
- **Silently deactivating a gate the user enabled.** Always surface. Even if the score moved against the gate, the user's prior intent is signal.
- **Reading the catalog in main session.** It's ~1700 lines; that's heavy-read. Dispatch a researcher to parse it once into hard-gates.json; reuse the cached JSON on re-runs.
- **Writing CLAUDE.md from scratch when it already exists.** Only the `## Active Gates` section. Anything else is the project's choice; not yours.
- **Treating decision-log bypass as auto-deactivate.** ≥3 bypasses in 30 sessions is a "consider retune" signal — surface it for user decision. The bypass might be legitimate (every project does some destructive work; the gate exists for the rare cases). Auto-deactivating defeats the discipline.
- **Forgetting the report.** Without the report, the user has no idea what changed. The report is the contract — write it before the files commit.

## Citations

**Catalog:**
- `docs/catalog/hard-gates.md` v1 — source of truth for all 42 gates with schema, citations, and overcorrection-watch notes
- `RELEASE-NOTES.md` v2.4.0 entry — pivot rationale and scope

**Research grounding (3 parallel researcher dispatches, 2026-05-17):**
- `docs/research/configure-project-gates-trigger-format-2026-05-17.md` — schema: Lefthook + Claude-Code-hooks hybrid (4/4 use-case-fit-pass frameworks)
- `docs/research/configure-project-gates-deny-vs-warn-2026-05-17.md` — severity model: 3-mode block/warn/audit (5/5 enterprise consensus)
- `docs/research/configure-project-gates-phase-enforcement-2026-05-17.md` — coordinator-layer enforcement (9/9 enterprise consensus)

**Enterprise grounding for the activation rubric (N≥3):**
- ESLint config inheritance + `--max-warnings` quantitative escalation
- HashiCorp Sentinel policy promotion lifecycle (advisory → soft-mandatory → hard-mandatory)
- Kubernetes Pod Security Admission profile selection by namespace
- AWS Config periodic rule re-evaluation

**Anthropic guidance:**
- *Building Effective AI Agents* — Routing pattern; "find the simplest solution possible, only increasing complexity when needed"
- *Effective Context Engineering* — file artifacts as cross-agent comms substrate (the active-gates.yaml IS one)

**SP precedent:**
- `superpowers/5.0.7/skills/writing-skills/SKILL.md` — skill structure conventions; description-as-trigger-mechanism principle
- `superpowers/5.0.7/skills/subagent-driven-development/SKILL.md` lines 102-118 — status-token grammar (DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED)

**Empirical motivation:**
- FEEDBACK F-V40 (2026-05-17) — meta-fix: no mechanism converts proposed-HARD-GATEs into enforced project gates
- TaskIt session signal: 31 of 36 skills sat unused while their disciplines would have prevented documented bugs
