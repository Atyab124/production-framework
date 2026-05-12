# ADR-002 — Hook-Gating Architecture (D-A)

**Status:** Accepted
**Date:** 2026-04-30
**Decided by:** PF v2 maintainer
**Supersedes:** None
**Related:** `docs/research/decision-d-a-hook-gating-architecture-2026-04-30.md` (Wave 1.5 R-A); `docs/audits/v1-feedback-vs-v2-2026-04-30.md` Cluster C1 (13 audit items); ADR-001 G3 (Item 41 STRENGTH evidence).

## Context and Problem Statement

PF v1 production data (audit Items 14, 15, 17, 18, 19–27) shows a recurrent failure mode: skills are summoned by assistant choice; nothing prevents downstream `Edit`/`Write`/`Bash` calls when the assistant rationalizes past the discipline. The most-cited instance is the mention-picker bug (2026-04-30, post-`/compact`) where the assistant skipped `tier-selection` and went directly to local-patching via `systematic-debugging` — the wrong cycle for a Tier 3 state-reconciliation bug. Item 41 STRENGTH evidence demonstrates the alternative works: PF v1's Rule #43 (incident-loop traceability) is **triple-enforced** (`MACHINE(script:structural-check.sh:check_incident_logged) + RULE(agent:deputy) + RULE(agent:post-mortem)`) and is described in the audit as "the most carefully engineered subsystem in v1."

Per CLAUDE.md rejection-criterion #5: "Add a new hook without MAJOR version bump + architecture doc justifying it" → blocked. This ADR satisfies that gate.

## Decision Drivers

- 5/5 enterprise consensus on multiple hook-design heuristics (gate=non-zero/structured-deny; bypass-as-feature; file/env-var state; reason-surfaced; single-hook-multi-matchers — per R-A §K/N)
- SP precedent: `polyglot-hooks.md` PreToolUse example + `anthropic-best-practices.md` plan-validate-execute pattern
- Anthropic documented mechanism: `permissionDecision: "deny"` JSON form per https://docs.claude.com/en/docs/claude-code/sdk/sdk-permissions
- Known Claude Code bugs make exit-code-2 unreliable on `Edit`/`Write` matchers: GitHub issues #13744, #36071, #40580 (per R-A §3)
- Item 41 evidence: machine-enforcement of bypass-prone discipline is achievable, cost-bearable, and load-bearing in PF v1

## Considered Options

| Option | Description | Rejected for |
|---|---|---|
| **A. Defer all hook-gating to v2.1** | Ship v2.0 with discipline-only enforcement; revisit in v2.1 | Reproduces v1's documented failure mode for early adopters; Item 41 evidence shows the cost is bearable now |
| **B. Full sweep — gate every bypass-prone rule** | Add 8+ hooks covering all `RULE(prompt)` rules | Violates Atlassian/Datadog "alert fatigue" research (R-A §6); 93%-approve-everything failure mode per Anthropic; over-broad scope risks user backlash |
| **C. Scoped 5-gate ship in v2.0 (CHOSEN)** | Add 5 hook-gates for the highest-leverage bypass-prone rules; defer 3 to v2.1; leave 2 discipline-only | Lands the empirical proof-of-concept in v2.0 without alert-fatigue risk |
| **D. Discipline-only (status quo)** | No hooks; rely on assistant adherence | User has empirical data this fails (audit cluster C1) |

## Decision Outcome

**Option C: Scoped 5-gate ship in v2.0** with three-tier bypass grammar + append-only audit log.

### Per-rule scope

| Rule | Scope in v2.0 | Hook gate | Bypass-escape-hatch | State-file marker |
|---|---|---|---|---|
| `tier-selection` (Item 14) | **Gate** | `PreToolUse` on `Edit\|Write\|Bash` (task-shape prompts) | `PF_BYPASS=tier-selection` | `.framework-state/session.json` `tier_selection_invoked_at` ≥ latest user-prompt-ts |
| Destructive ops (Item 21) | **Gate** | `PreToolUse` on `Bash` matching destructive-verb regex | `PF_BYPASS=destructive` + `PF_BYPASS_REASON` | `.framework-state/destructive-allowlist` per-session |
| Phase-break before `src/**` (Item 22) | **Gate** | `PreToolUse` on `Write` matching `src/**` | `PF_BYPASS=phase-break` | reads PROJECT-PLAN current-phase marker |
| Critical-finding-blocks-next-phase (Item 24) | **Gate** | `PreToolUse` on `Write` matching `src/**` | `PF_BYPASS=critical-override` | reads PROJECT-PLAN Open Findings table |
| Dep-add (Item 19) | **Gate** | `PreToolUse` on `Bash` matching `(npm\|pnpm\|yarn\|bun)\s+(add\|install)\s+\S` | `PF_BYPASS=dep-add` | requires "Tool Selection Chain:" prefix in prior assistant turn |
| `triage` (Item 26) | **Defer to v2.1** | — | — | Pre-condition: ship `triage` skill first per Wave 3 R-3 verdict (Option C — write new triage skill) |
| `brainstorming` (Item 27) | **Defer to v2.1** | — | — | Pre-condition: creative-prompt classifier eval |
| Plan-update after phase (Item 23) | **Defer to v2.1** | — | — | Better as a `Stop` hook than `PreToolUse` |
| Tool Selection Chain (Item 19 lighter) | **Discipline-only** | — | — | Captured in `cto-mode` checklist + Builder self-review |
| Plan-dir (Item 25) | **Discipline-only** | — | — | SP convention `docs/plans/` is sufficient; gate is overkill |

### Three-tier bypass grammar

```
PF_BYPASS=<rule-id>           # per-rule; valid for ONE tool call
PF_BYPASS_ALL=1               # session-wide; requires PF_BYPASS_REASON env var
.framework-state/PF_GATES_DISABLED   # project-level kill switch (file presence)
```

All bypasses logged append-only to `.framework-state/bypass-log.jsonl` with: timestamp, rule-id, reason (if applicable), the tool-call payload. Post-Mortem agent mines this log for repeat-bypass patterns at retro time.

### Implementation contract

- **Mechanism:** `PreToolUse` hook returns JSON with `permissionDecision: "deny"` + `permissionDecisionReason` per Anthropic SDK Permissions docs. **Do NOT use exit-code-2** — known CC bugs (#13744, #36071, #40580) make it unreliable on `Edit`/`Write` matchers.
- **State file:** `.framework-state/session.json` initialized at SessionStart hook; tracks `tier_selection_invoked_at`, `triage_invoked_at` (when triage ships), latest-user-prompt-ts. `.gitignored` per `.framework-state/.gitignore`.
- **Bypass log:** `.framework-state/bypass-log.jsonl` is append-only; never rotated; mined by Post-Mortem agent.
- **Single hook script:** `hooks/pre-tool-use.sh` handles all 5 matchers internally (per R-A 5/5 consensus on single-hook-multi-matchers heuristic).

## Consequences

**Positive:**
- Closes Cluster C1 (13 audit items + 1 from C5 sub-fix) at the architectural level.
- Auditable bypass trail (bypass-log.jsonl) feeds back into Post-Mortem for system-level learning.
- Item 41's machine-enforcement pattern propagates: Rule #43 was the proof of concept; this ADR replicates the shape for 5 more rules.
- v2.1 can graduate `triage` and `brainstorming` from defer-to-gate without redesign — the hook architecture absorbs them.

**Negative:**
- Adds ~5 friction points per task-shape session turn (one TodoWrite invocation of `tier-selection` is the cost). Mitigated by three-tier bypass grammar.
- New hook surface to maintain; CC bug landscape (#13744, etc.) means we depend on Anthropic's `permissionDecision` JSON contract staying stable.
- Increases v2.0.0 scope by ~6-10h of implementation work (per Pass 2 plan Workstream C).

**Neutral:**
- v2.0.0 marketplace release notes must document the hook contract + bypass grammar. RELEASE-NOTES.md update is part of Workstream C deliverables.

## More Information

- Full research: `docs/research/decision-d-a-hook-gating-architecture-2026-04-30.md` (R-A; Wave 1.5; 403L)
- Audit context: `docs/audits/v1-feedback-vs-v2-2026-04-30.md` Cluster C1 (Items 14–27 + 39 sub-fix)
- Implementation plan: `docs/plans/pass-2-implementation-2026-04-30.md` Workstream C
- Item 41 STRENGTH evidence: PROJECT-PLAN.md Phase 6 Wave 2 entry for `proposing-patterns` (R-3 un-defer rationale cross-references this ADR)
