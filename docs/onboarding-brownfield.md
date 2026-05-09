# Onboarding PF v2 to a Brownfield Project

PF v2 was designed greenfield-first. The README assumes you start fresh: `docs/PROJECT-PLAN.md`, `docs/specs/`, `docs/architecture/`, etc. This doc covers what to do when your project already has its own patterns docs, ADR conventions, or non-`docs/` directory structures.

The CONFIG path indirection (added v2.1.0, F-V5 fix) is the load-bearing primitive. Skills and agents read paths from `CONFIG.yaml > file_paths.*` instead of the convention paths.

## Available CONFIG slots

```yaml
file_paths:
  project_plan: docs/PROJECT-PLAN.md     # default
  patterns: docs/STACK-PATTERNS.md       # default
  citation_manifest: docs/research/sp-anthropic-citation-manifest.md  # default
  adr_dir: docs/adr/                     # default
  research_dir: docs/research/           # default
  plans_dir: docs/plans/                 # default
  audits_dir: docs/audits/               # default
```

Override any slot by setting the CONFIG value to your project's path. Examples:

- Project has plan at `docs/TASKIT-PLAN.md` → set `file_paths.project_plan: docs/TASKIT-PLAN.md`.
- Project has ADRs at `architecture/decisions/` → set `file_paths.adr_dir: architecture/decisions/`.
- Project has patterns doc at `engineering-patterns.md` (root) → set `file_paths.patterns: engineering-patterns.md`.

## Step-by-step retrofit

1. **Inventory existing artifacts.** What does your project already have? Common candidates:
   - Project plan / roadmap doc
   - ADR or RFC folder
   - Patterns / conventions doc
   - Architecture document
   - Audit / review folder
   - Specs / design docs

2. **Map each to a CONFIG slot.** Use the table above. If your project has an artifact PF v2 doesn't have a slot for, that's a finding — file in `docs/PROJECT-PLAN.md` Open Findings.

3. **Set CONFIG.yaml at project root.** PF v2 reads CONFIG before falling back to convention paths.

4. **Smoke test the framework.** Invoke `cto-mode` on a small task. Verify the framework reads from your CONFIG-declared paths, not the convention paths. Common failure: a skill that hardcodes the convention path is a finding (file it).

5. **Don't migrate existing content into convention paths.** PF v2 reads CONFIG; you don't need to move your existing plan into `docs/PROJECT-PLAN.md`. The indirection IS the retrofit primitive.

## What if my project has no CONFIG.yaml?

Default behavior. PF v2 falls back to convention paths. Greenfield projects get the simplest experience.

## What if my project has its own SessionStart hooks / pre-commit hooks?

PF v2's hooks live in `.claude-plugin/hooks/`. They coexist with project-level `.git/hooks/` and other plugin hooks via Claude Code's hook composition rules. If conflicts arise (e.g. two hooks want to deny the same tool call), file as a finding in `docs/PROJECT-PLAN.md`.

## What if my project's existing patterns conflict with PF v2's?

PF v2 ships its own patterns in `templates/STACK-PATTERNS.template.md` (template; not the runtime patterns doc). Your project's patterns doc (whatever its path) is authoritative. If your patterns conflict with PF v2's enforcement (e.g. PF v2 wants RLS on all tables but your project doesn't use Supabase), the patterns doc wins — PF v2 enforcement is opt-in via CONFIG project_specific_triggers.

## When NOT to retrofit

- Project is entirely separate from PF v2's intended use case (multi-tenant SaaS) — e.g. data pipelines, libraries, CLI tools. PF v2 may be over-prescriptive; a lighter framework or no framework may fit better.
- Your team's discipline is already strong and the framework's friction outweighs its catches. Retrofit is opt-in; no obligation.
