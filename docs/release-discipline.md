# Release Discipline

What each PF v2 release type promises and what must clear before it ships. The framework's own binding rule (cite SP precedent or Anthropic guidance + N≥3 enterprise analogs) applies to releases for the framework itself, not just to user features built with it.

**Effective from v2.1.1 onward.** Prior releases predate this contract.

> Anthropic-cited foundation: "evaluator-optimizer pattern: one LLM generates a response while another provides evaluation and feedback in a loop."
> — *Building Effective AI Agents*, Anthropic, Dec 2024 (https://www.anthropic.com/research/building-effective-agents)
>
> Releases run through their own evaluator (the dogfood pass) before merging. The framework that evaluates user code must be evaluated the same way.

---

## Release Types

| Type | Versioning | Scope |
|---|---|---|
| **Production fix** | 2.x.y (patch) | Empirical defect fixes; critical / high findings closed since the previous release. Examples: Windows path-separator bug; sub-agent gate-deny inheritance. |
| **Upgrade** | 2.x.0 (minor) | New skills, new agents, new template sections, new structural checks. |
| **Major** | 3.0.0 (major) | Hook contract changes; agent dispatch shape changes; breaking changes to the shared-context substrate. |

---

## Pre-Release Gates

Every release type clears all four gates. No exceptions.

### Gate 1 — Dogfood pass

The maintainer runs the framework on real or synthetic work, in this repo's own dev environment OR in a project running this build of the framework. Concretely:

- Invoke `cto-mode` → `cycle-selection` → `tier-selection` → dispatch
- Cover at least one Tier 1, one Tier 2, and one Tier 3 cycle in the pass
- Dispatch each specialist agent type at least once across the pass (Builder, Researcher, Architect, QA, Database Engineer, Security/Compliance, SRE/DevOps, Code Reviewer, Debugger, Post-Mortem, Product Manager, UX/Design)
- Verify hook gate behavior end-to-end (HARD-GATE blocks; bypass grammar works; `trigger-audit.jsonl` logs as expected)
- Log every finding that surfaces in `docs/PROJECT-PLAN.md` before declaring the release ready

Findings classified CRITICAL or HIGH must be resolved, OR explicitly deferred-with-rationale, before the release ships. Silent hold-overs are rejected.

### Gate 2 — Cross-platform smoke

A fixed checklist runs on Linux, macOS, and Windows-via-Git-Bash. Each step's expected behavior is identical across all three platforms; any divergence is a finding before release:

1. Plugin loads successfully — SessionStart hook fires
2. `framework-state-init` populates `.framework-state/session.json` and creates `.framework-state/bypass-log.jsonl`
3. `pre-tool-use` denies Edit / Write / Bash when tier-selection has not been invoked since the last user prompt
4. `pre-tool-use` allows Edit on paths under `docs/`, `.framework-state/`, and `.claude-plugin/` regardless of OS path separator
5. Bypass grammar works at all three layers — `PF_BYPASS=<rule>`, `PF_BYPASS_ALL=1` with `PF_BYPASS_REASON`, and the `PF_GATES_DISABLED` filesystem kill switch
6. Builder sub-agent dispatches successfully from a git-backed project (worktree creation succeeds)

### Gate 3 — Regression test per closed finding

Every finding closed since the previous release ships with a test in `evals/regression/` that fails if the bug returns. The test file is named for the finding's stable identifier (e.g. `f-v13-windows-path-separator.json`) and references the closing commit. Tests are simple and falsifiable — a JSON manifest with the bug's exact symptom, or a shell script with the reproducer.

Releases that close findings without their regression tests are rejected.

### Gate 4 — Citation manifest current

Every new skill, agent, hook, or convention added since the previous release maps to a row in `docs/research/sp-anthropic-citation-manifest.md`. Per `CLAUDE.md` THE BINDING RULE — features without citations are rejected.

---

## Findings Log Discipline

- Every finding logged in `PROJECT-PLAN.md` before the release ships, not after.
- Severity tags re-graded against the dogfood pass evidence — not held at their original tag if the dogfood pass changed the picture.
- Deferred findings explicitly listed with rationale.

---

## Trade-Off

Each release ships slower under this discipline than under the prior "ship fast, log findings post-hoc, repeat" pace. That trade is intentional. The framework's value to its users is durability — a release that breaks a user's project once destroys more user trust than a feature gain creates. Slow + correct beats fast + reactive.

---

## Citations

Per `CLAUDE.md` THE BINDING RULE.

- **SP precedent.** `superpowers/5.0.7/CLAUDE.md` lines 67-75 — "Skills are not prose — they are code that shapes agent behavior. Show before/after eval results in your PR. Run adversarial pressure testing across multiple sessions." This doc applies the same evidence-before-merge discipline to releases.
- **Anthropic guidance.** *Building Effective AI Agents* (Dec 2024, https://www.anthropic.com/research/building-effective-agents) — evaluator-optimizer pattern.
- **Enterprise analog 1.** Google SRE Book, Chapter 8 (Release Engineering) — release engineering as a dedicated discipline; reproducible builds; release branches; canary signals.
- **Enterprise analog 2.** Rust RFC process — every RFC requires a reference implementation before stabilization; alpha → beta → stable graduation gates.
- **Enterprise analog 3.** Linux kernel `tools/testing/selftests/` — per-bug regression tests live in-tree; closing a bug ships with the test that guards against re-introduction.
