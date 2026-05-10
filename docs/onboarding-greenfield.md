# Onboarding PF v2 to a Greenfield Project

This guide takes a fresh-clone reader from "I just installed the plugin" to "I shipped my first tiny feature with the framework" in roughly 15 minutes. It is the greenfield counterpart to [`docs/onboarding-brownfield.md`](onboarding-brownfield.md), which covers retrofitting PF v2 onto a project with existing patterns docs / ADRs / plan files.

The structure follows the N≥3 consensus shape extracted from 11 enterprise/OSS dev-tool onboarding guides (see `docs/research/greenfield-onboarding-2026-05-10.md` — sections that appear in fewer than 3 surveyed frameworks were dropped).

---

## 1. Prerequisites

Already covered in [`README.md`](../README.md#prerequisites). Briefly: Claude Code, Git, and Bash (Git Bash on Windows). No third-party runtime dependencies.

If your project will use multi-tenant primitives (RLS, audit-trail discipline), no extra install — those are skill bodies that fire when relevant cycles run.

## 2. Install

Already covered in [`README.md`](../README.md#installation). Two commands inside any Claude Code session, then restart the session so the SessionStart hook can fire.

## 3. Quickstart (5 minutes)

After install, in a fresh project directory:

```
mkdir my-project && cd my-project
git init
mkdir -p docs
cp <PF_V2_INSTALL_PATH>/templates/PROJECT-PLAN.template.md docs/PROJECT-PLAN.md
```

Then open Claude Code in that directory. Type:

```
What version of the production-framework can you see?
```

If Claude responds with `2.2.0` and identifies as the CTO orchestrator, the install is live. Move to the smoke test.

## 4. Smoke test

Already covered in [`README.md`](../README.md#smoke-test-verify-the-install-works). The README's smoke test is the canonical 30-second check; do that first. The deeper smoke test is in section 7 below.

## 5. Initialize the first project

Three files seed a greenfield project. Two are required, one is optional.

### Required: `docs/PROJECT-PLAN.md`

Copy from the template:

```
cp <PF_V2_INSTALL_PATH>/templates/PROJECT-PLAN.template.md docs/PROJECT-PLAN.md
```

The template has placeholders (`{project-name}`, `{started-date}`, `{maintainer}`) — fill them in. The PROJECT-PLAN is the long-lived state of your project: phase status, open findings, incident table, ratified pattern table, validated discipline. The framework reads and writes this file every cycle.

### Required: `CONFIG.yaml` at project root

Create the file with at least the path-indirection slots:

```yaml
file_paths:
  project_plan: docs/PROJECT-PLAN.md           # default
  patterns: docs/STACK-PATTERNS.md             # optional, see below
  citation_manifest: docs/research/sp-anthropic-citation-manifest.md
  adr_dir: docs/adr/
  research_dir: docs/research/
  plans_dir: docs/plans/
  audits_dir: docs/audits/

scale_targets:                                  # optional, project-shape-specific
  tenants: 1                                    # set to your expected scale
  users_per_tenant: 1
  records_per_tenant_month: 0
  concurrent_users: 1

tenant_isolation_method: none-single-tenant     # or RLS / middleware / column-scope

filtered_wrappers:                              # optional, language-specific test/build commands
  test: npm test
  typecheck: npx tsc --noEmit
  build: npm run build
```

The framework reads CONFIG before falling back to convention paths. Greenfield can use defaults; brownfield overrides. See `docs/onboarding-brownfield.md` for the full slot list.

### Optional: `docs/STACK-PATTERNS.md`

Stack-specific patterns (Next.js client/server boundaries, Supabase RLS idioms, Rails strong-parameter conventions) live here. Copy from the template only when you have a stack and at least one ratified pattern to record:

```
cp <PF_V2_INSTALL_PATH>/templates/STACK-PATTERNS.template.md docs/STACK-PATTERNS.md
```

For a brand-new greenfield project, leave this empty until you have ≥3 incidents that cluster into a pattern proposal (the framework's `proposing-patterns` skill walks you through that when the time comes).

## 6. Explore what got set up

After step 5, your project directory should look like:

```
my-project/
├── .git/
├── CONFIG.yaml
└── docs/
    └── PROJECT-PLAN.md
```

The framework will lazily create everything else as cycles run:

| Directory | Created when | By |
|---|---|---|
| `docs/specs/` | Build cycle phase 1 | Product Manager agent |
| `docs/design/` | Build cycle phase 2 (Tier 3) | UX/Design agent |
| `docs/architecture/` | Build/Refactor/Migration cycle | Architect agent |
| `docs/research/` | Any cycle that needs ≥3 enterprise citations | Researcher agent |
| `docs/database/` | Build cycle phase 4, Migration cycle phase 3 | Database Engineer agent |
| `docs/security/` | Build phase 4, Security-Audit cycle, Migration | Security/Compliance agent |
| `docs/plans/` | Build/Refactor cycle | `writing-plans` skill |
| `docs/audits/` | After any Builder dispatch | QA + Code Reviewer |
| `docs/runbook/` | Build cycle phase 8, Migration phase 8 | SRE/DevOps agent |
| `docs/adr/` | Whenever the Architect ratifies a non-obvious choice | Architect agent |
| `docs/cycle-state.md` | First cycle dispatch | CTO synthesis |

You should not pre-create any of these. The framework's cycles auto-create the directories they need.

## 7. Example: ship one tiny feature

This is the deeper smoke test — it exercises the full Build cycle at Tier 1 and confirms cycle-selection, tier-selection, and the production-readiness gate are all wired up.

In your project, add a single file `hello.txt` with the content `hello world`. Then in Claude Code, type:

```
Add a "Hello, PF v2!" line to hello.txt.
```

Expected behavior:
1. The framework's CTO mode fires.
2. `cycle-selection` matches **build cycle** (new behavior — adding a line).
3. `tier-selection` matches **Tier 1** (typo/style/copy change, no logic change).
4. The CTO executes the change directly without dispatching agents (Tier 1 = direct execution).
5. The CTO synthesizes a one-sentence result.

Now try a tiny Tier 2 task:

```
Refactor hello.txt to a JSON file with a "greeting" key containing the same content.
```

Expected behavior:
1. CTO mode fires.
2. cycle-selection matches **refactor cycle** (restructure, no new behavior).
3. tier-selection matches **Tier 2** (single feature, <6 deliverables).
4. The CTO walks the Refactor cycle's three-pass Architect → Researcher → Architect (Pattern A), then dispatches a Builder, then QA, then Code Reviewer. Or, at Tier 2, it may collapse the Architect revision into CTO reconciliation per the Producer-Consumer Convention.
5. The CTO returns synthesis with paths to the architecture doc, plan doc, and any ADRs ratified.

If both work, the framework is end-to-end functional in your project.

## 8. Configuration

The `CONFIG.yaml` slots are documented above (section 5). Other knobs you may want:

- **`scale_targets`** — project-shape-specific scale signals (tenants, users-per-tenant, records-per-month). The framework reads these to size index strategies and SLO/SLI defaults.
- **`tenant_isolation_method`** — `RLS` / `middleware` / `column-scope` / `none-single-tenant` / `n/a`. Drives which security gates fire on schema changes.
- **`filtered_wrappers`** — language-specific test/build/typecheck commands. Defaults are JS/TS-shaped; override for Python/Go/Rust/Ruby projects.
- **PF_BYPASS environment variables** — per-rule bypass tokens (e.g., `PF_BYPASS=tier-selection`) for ad-hoc gate suppression. Documented in `hooks/pre-tool-use`. Use sparingly; bypass writes to `.framework-state/bypass-log.jsonl` for audit.

## 9. Workflow you'll hit

The recurring rhythm after the first feature ships:

```
You: "<intent — fix this, build that, audit X, optimize Y>"

CTO classifies:
  cycle-selection → which cycle (build / debug / research / refactor /
                                  security-audit / performance / migration / postmortem)
  tier-selection  → which rigor (Tier 1 direct / Tier 2 minimal / Tier 3 full)

CTO dispatches sub-agents per the cycle's graph:
  - Tier 1 → CTO executes directly, no dispatch
  - Tier 2 → minimal graph (skip PM/UX/SRE on Build cycle, skip post-mortem on Debug cycle)
  - Tier 3 → full graph + gate-3-production-check

Each sub-agent:
  reads from disk (paths the CTO supplies)
  writes its output to disk
  returns a status token: DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED

CTO mediates handovers between phases, runs gate-3 before completion (Tier 3),
updates docs/PROJECT-PLAN.md, synthesizes ≤30 lines for you.
```

The framework dispatches based on language triggers in your prompt (the Cycle Trigger List in `skills/cycle-selection/SKILL.md`). Match your prompts to the trigger language for predictable routing — e.g., "broken / unexpected / failing" → Debug cycle; "audit / harden / pen-test" → Security-Audit cycle.

## 10. Troubleshooting

**SessionStart hook didn't fire.** Plugin is installed but the framework doesn't introduce itself. Likely the session was opened before the install completed. Restart Claude Code. If that fails, run `/plugin list` and verify `production-framework@production-framework` is enabled.

**Hook gate keeps re-firing on every prompt.** The `pre-tool-use` hook re-arms the tier-selection requirement on every user-prompt boundary by design (F-V9 partial-resolved in v2.2.0). If this becomes friction within a single open cycle, set `PF_BYPASS=tier-selection` for that turn — but the bypass writes to `.framework-state/bypass-log.jsonl` and over-using it defeats the gate's purpose.

**Builder sub-agent reports it can't use Bash / PowerShell / Write.** Known issue tracked as F-V19 (CRITICAL OPEN) in `docs/PROJECT-PLAN.md`. Workaround: replace `production-framework:builder` dispatch with the local generic `Builder` subagent_type. The CTO will note the deviation in the cycle-state handover.

**Researcher returned `NEEDS_CONTEXT` saying "cannot find 3 citations."** That is the framework working as designed. The N≥3 binding rule prefers an honest gap over a fabricated third citation. Either narrow the question or accept that the pattern lacks enterprise consensus and surface that to the user.

**Cycle ran but `docs/cycle-state.md` was not updated.** The CTO is supposed to write a one-line handover summary to that file at each phase transition. If absent, the cycle ran in a degraded shape — file a finding in `docs/PROJECT-PLAN.md` Open Findings and reference the cycle's PROJECT-PLAN row.

**Parent-platform-specific exception (disclosed):** the framework runs inside Claude Code, which means hook behavior, plugin resolution, and SessionStart timing are governed by Claude Code's runtime — not by the framework. If the framework appears not to fire and the cause is upstream (e.g., a Claude Code version that doesn't support a hook event), it is a Claude Code issue, not a PF v2 bug. The framework's own gate logic verifies state via `.framework-state/session.json`; inspect that file for diagnostic context.

## 11. Next steps

- **Read `CLAUDE.md`** at the framework root — the contributor guard, the binding citation rule, and the rejection criteria for changes.
- **Read `README.md`** Cycles-at-a-glance table — memorize the trigger language for each of the 8 cycles so your prompts route predictably.
- **Browse the Open Findings table** in `docs/PROJECT-PLAN.md` — known issues, deferred work, and validated discipline. F-V19, F-V14, and FD-03 are the three to read first.
- **For a real feature:** start with a Build cycle Tier 3 task that exercises a multi-tenant boundary. The full agent graph (PM → UX∥Researcher → Architect three-pass → DB+Security → plan → Builders → QA+Reviewer → SRE → gate-3) is the framework's load-bearing path; running it once exposes any per-project wiring gap.
- **For migrating an existing project:** see [`docs/onboarding-brownfield.md`](onboarding-brownfield.md) for the CONFIG path-indirection retrofit.
- **For framework development:** see `CLAUDE.md` rejection criteria. Every change requires SP precedent or Anthropic guidance + ≥3 enterprise/OSS analogs.

---

## Provenance

This guide's structure is grounded in `docs/research/greenfield-onboarding-2026-05-10.md`, which surveyed 11 enterprise/OSS dev-tool onboarding patterns. The N≥3 consensus sections (Install, First-project init, Example project, Next steps, Configuration, Prerequisites, Quickstart, Smoke test, Workflow, Modify-redeploy loop, Explore-what-got-generated) all appear above. Sections that appeared in fewer than 3 frameworks (e.g., "Architecture diagram" — N=1) were dropped per PF v2's binding rule.
