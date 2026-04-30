# Production Framework v2 — Contributor Guard

This `CLAUDE.md` is the contributor guard for **this repository** — not the agent runtime config. It applies to agents and humans contributing to the production-framework v2 plugin itself, not to projects using the framework.

**If you are using this framework in a project:** your project's own `CLAUDE.md` is authoritative. This file does not affect your project.

---

## What This Repo Is

**production-framework v2.0.0** — a Claude Code plugin that turns a regular Claude session into a CTO running 13 specialist sub-agents in parallel cycles to build enterprise multi-tenant SaaS.

**Forked from:** Superpowers 5.0.7 (MIT, © 2025 Jesse Vincent <jesse@fsck.com>) at https://github.com/obra/superpowers. Attribution + LICENSE preserved.

**Why fork:** PF v1 (a separate plugin) used a custom 7-agent topology that empirically failed to fire skills (Anthropic-named "telephone game" anti-pattern). v2 abandons that shape and rebuilds atop SP's empirically-firing skill cascade, layering enterprise multi-tenant primitives on top.

---

## THE BINDING RULE

**Every feature in this repo MUST cite either:**

1. **A Superpowers (SP) precedent** — paste the exact path + relevant snippet from SP 5.0.7, OR
2. **A quoted reference from an Anthropic manual** — exact quote + URL + verification date

**Features that have neither will be rejected.** This is the U-AP-1 rule of v2 development. The citation manifest at `docs/research/sp-anthropic-citation-manifest.md` is the source of truth — every skill, agent, hook, or convention must map to a row in that manifest.

If a feature has no SP precedent AND no Anthropic citation, the choices are:
- (a) Find a citation (research first)
- (b) Redesign to align with one that exists
- (c) REDIRECT — drop the feature

There is no (d) "ship it anyway."

This rule supersedes invent-from-thin-air design. The framework's own rule of enterprise-research-first applies to the framework itself: **if Anthropic or SP haven't done it, we don't do it without explicit citations from at least 3 enterprise/OSS frameworks** (see `docs/research/enterprise-multi-agent-architecture.md` for the N≥3 procedure).

---

## What Requires a PR

- Any change to `skills/` — new skill, modified skill body, or modified frontmatter
- Any change to `agents/` — new agent, modified agent prompt
- Any change to `hooks/` — behavior or contract changes
- Any change to `.claude-plugin/plugin.json` or `.claude-plugin/marketplace.json`
- Any change to `templates/` that alters the PROJECT-PLAN schema
- Any change to `docs/research/sp-anthropic-citation-manifest.md`

## What Can Ship Direct (no PR)

- Typos and formatting in `docs/` (excluding the citation manifest)
- `README.md` updates
- New entries in `docs/adr/` for clearly-bounded design decisions
- New entries in `docs/research/` for new framework comparisons

---

## PR Checklist

Before merging any PR:

- [ ] **Citation present.** Every new skill / agent / convention cites either SP precedent (path + snippet) or Anthropic guidance (quote + URL + date).
- [ ] **No third-party runtime dependencies.** PF v2 is a zero-dependency plugin like SP.
- [ ] **No domain-specific skills in core.** Stack-specific patterns (Next.js, Supabase, Rails) belong in `templates/STACK-PATTERNS.md` or a downstream project, not in `skills/`.
- [ ] **HARD-GATE markers explicit.** If a skill is non-negotiable, format as `<HARD-GATE>...</HARD-GATE>` per SP convention.
- [ ] **Frontmatter discipline.** `description:` is action-oriented imperative ("You MUST use this when..." or "Use when..."), not topic-label.
- [ ] **No bulk PRs.** One concern per PR.
- [ ] **No speculative fixes.** Every change must solve a real observed problem; "my review agent flagged this" is not a problem statement.

---

## Rejection Criteria

PRs are rejected (not merged, not discussed) if they:

1. **Add a feature without SP or Anthropic citation** — see binding rule.
2. **Inline framework-internal jargon into a project's `CLAUDE.md`** — the framework flows via SessionStart bootstrap. Projects must NOT copy core rules into their project `CLAUDE.md`.
3. **Add a stack reference to `core/`** — language, framework, or service names. Extract to `templates/`.
4. **Bundle unrelated changes.** One concern per PR.
5. **Modify carefully-tuned skill content** (Red Flags tables, rationalization lists, hard-gate language) without before/after eval evidence. Skills are code that shapes agent behavior, not prose.
6. **Rebrand or fork-sync.** Do not push fork-specific customizations upstream — those belong in your own fork.
7. **Add a third-party runtime dependency.** PF v2 is zero-dependency.
8. **Fabricate problem descriptions** or invent functionality.

---

## Skill Changes Require Evaluation

Per SP precedent (`CLAUDE.md` line 67-75 of SP 5.0.7):

> Skills are not prose — they are code that shapes agent behavior. If you modify skill content:
> - Use `superpowers:writing-skills` to develop and test changes
> - Run adversarial pressure testing across multiple sessions
> - Show before/after eval results in your PR
> - Do not modify carefully-tuned content (Red Flags tables, rationalization lists, "human partner" language) without evidence the change is an improvement

This applies to PF v2 with one extension: changes to skills that override SP-precedent skills (e.g., if PF v2 adds a `brainstorming` skill that overrides SP's) require **double evidence** — adversarial pressure tests showing the PF version performs ≥ SP version on the same prompts.

---

## Versioning

- **Patch (2.0.x):** docs, typos, formatting, citation-manifest additions
- **Minor (2.x.0):** new skill, new agent, new template section, new structural check
- **Major (3.0.0):** hook contract change, agent dispatch shape change, breaking change to shared-context substrate

Bump `version` in `.claude-plugin/plugin.json` AND `.claude-plugin/marketplace.json` together.

---

## Dependencies

| Tool | Required by | Install |
|---|---|---|
| `bash` | All hook scripts | Pre-installed on macOS/Linux; Git Bash or WSL on Windows |
| Git Bash on Windows | `hooks/run-hook.cmd` polyglot wrapper | https://gitforwindows.org/ |

No `jq` dependency — SP's `escape_for_json` bash-parameter-substitution approach (verified at `hooks/session-start` lines 17-25) is preserved.

---

## File Layout

```
.claude-plugin/
  plugin.json                      # PF v2 manifest
  marketplace.json                 # PF v2 marketplace registration
skills/
  using-production-framework/      # SessionStart bootstrap (auto-injected)
  cto-mode/                        # Orchestrator behavior the entry session adopts
  cycle-selection/                 # Picks 1 of 8 execution cycles
  tier-selection/                  # Scales cycle rigor to blast radius
  enterprise-research-first/       # N≥3 citation discipline
  gate-3-production-check/         # Final production gate
  ...                              # SP-inherited skills + PF additions
agents/
  cto.md                           # NOT a sub-agent (CTO is the entry session role)
  architect.md
  researcher.md
  ...                              # 13 specialist sub-agents
hooks/
  session-start                    # Bash polyglot, fork of SP's
  run-hook.cmd                     # Polyglot wrapper for Windows
  hooks.json
docs/
  research/
    enterprise-multi-agent-architecture.md   # N=7 framework validation
    sp-anthropic-citation-manifest.md        # THE binding citation source
  adr/                                       # Architecture Decision Records
templates/
  PROJECT-PLAN.template.md         # Project state template (carried from PF v1)
evals/
  triggering/
    tier-selection.json            # 20-query trigger rate eval set
LICENSE                             # MIT, Jesse Vincent attribution preserved
README.md
RELEASE-NOTES.md
```
