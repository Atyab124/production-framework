---
name: proposing-patterns
description: "Use when drafting a new pattern proposal. Two ingest paths per ADR-003: Path A — Post-Mortem agent has clustered ≥3 incidents with distinct root_cause_hashes (v1 carryforward); Path B — enterprise-research-first has produced a BINDING finding (N/N at N≥5) AND use-case-fit check passed (NEW per Wave 2 broadening). Output is a proposal file at docs/pattern-proposals/{date}-{id}.md — never a direct write to STACK-PATTERNS.md."
---

## Overview

This skill defines the methodology for turning evidence (incidents OR external research) into a well-formed pattern proposal. Per **ADR-003 (Broadened Pattern Ingest)**, the skill ships in v2.0.x with **dual-path ingest** — Path A (incidents) carries forward verbatim from PF v1; Path B (research) is new per Wave 2 broadening.

The output is a proposal file; ratification is user-gated by `ratify-pattern`. This skill never writes to `STACK-PATTERNS.md` directly. STRAWMAN prefix discipline binds both paths identically.

**Enterprise grounding: 9/11 (82%) BINDING** on multi-trigger ingest — RFC 7942, Microsoft Engineering Playbook, AWS WAF, Refactoring Guru, Kubernetes KEP, Apache PMC, ThoughtWorks Tech Radar (7 explicit) + PLoP and Fowler Rule-of-Three (2 strict-recurrence-only outliers, both align with Path A). The two outliers don't contradict the broadening; they sit cleanly under Path A.

## When to Use

- **Path A (carryforward):** Post-Mortem agent is active and has computed hashes for ≥3 incident rows with distinct `root_cause_hash` values.
- **Path B (new):** `enterprise-research-first` has returned BINDING (N/N unanimous AND N≥5) AND its Step 6 use-case-fit check has passed. The orchestrator (CTO) records the finding and dispatches this skill in parallel with the build cycle.

Do NOT use:
- For incidents that haven't been recorded in PROJECT-PLAN.md yet (compute the hash + add the row first).
- For research findings that haven't passed Step 6 use-case-fit (cargo-cult risk).
- To write directly to STACK-PATTERNS.md (that's `ratify-pattern`'s job after user approval).

## Core Pattern

You MUST create a TodoWrite item per step.

### Step 0 — Source detection (NEW per Wave 2 R-1)

Before drafting, declare the path in the proposal frontmatter:

- **Path A** if triggered by ≥3 internal incidents → set `proposed_via: incidents`
- **Path B** if triggered by BINDING research → set `proposed_via: research`

The path determines which gate logic applies in Steps 2–4 (Step 3 splits into 3a / 3b).

### Step 1 — Compute / verify hashes (Path A) OR cite research (Path B)

**Path A:**

For each cited incident lacking `root_cause_hash`:

```bash
hash=$(bash scripts/compute-root-cause-hash.sh "$incident_summary_text")
```

Backfill `root_cause_hash` into the incident table row in `PROJECT-PLAN.md`. This is the only write to PROJECT-PLAN.md permitted.

**Path B:**

Cite the BINDING research artifact path (`docs/research/<topic>.md`) + the K/N consensus + the use-case-fit check result from Step 6 of `enterprise-research-first`. No hash computation needed.

### Step 2 — Group by shape (Path A only)

Path A: normalize each incident summary (lowercase, strip UUIDs and ISO dates). Group rows whose normalized summaries share a common noun+verb phrase (≥3 keywords overlap). Each group = one candidate cluster.

Path B: skip — research artifact is the cluster.

### Step 3a — Filter: N=3 distinct hashes (Path A)

A cluster qualifies only when it contains ≥3 rows with distinct `root_cause_hash` values. If a cluster has the same hash repeated across 3 rows, it is one bug reopened three times — not three independent incidents. Reject it with a `DONE_WITH_CONCERNS` note.

**Divergence rationale (U-AP-4):** Semgrep and CodeQL promote rules at N=1 (CVE response use case). PF's use case is cargo-cult prevention, not CVE response. Over-eager rule creation is the failure mode; N=3 is the calibrated threshold per ADR-003.

### Step 3b — Filter: BINDING + use-case-fit passed (Path B)

A research finding qualifies only when:

1. K/N is unanimous (N/N) AND N≥5 (BINDING per `enterprise-research-first` Step 4 grammar)
2. `enterprise-research-first` Step 6 use-case-fit check has passed (cargo-cult risk mitigated)

If K/N is STRONG but not BINDING (e.g., (N-1)/N at N≥3) → reject with `DONE_WITH_CONCERNS`. STRONG findings are recommendations to apply, not pattern-promotion candidates.

If use-case-fit didn't pass → reject. The 7/7 OAuth incident (`docs/research/skill-design-enterprise-research-first.md`) is the load-bearing example — BINDING patterns rejected after capability-need analysis.

### Step 4 — Bloat-cap check (both paths)

Count rows in `STACK-PATTERNS.md` matching `^\| (AP|BP|PP)-\d+ \|`. The bloat cap is parameterized in Stack Config (default ≤20; configurable per project). If `count + 1 > {stack:pattern-bloat-cap}`, do not draft. Return `DONE_WITH_CONCERNS`: "Bloat cap reached. A retirement proposal or existing-pattern revert must precede a new pattern proposal."

### Step 5 — Draft proposal

Use `templates/pattern-proposal.template.md`. Required fields:

| Field | Path A | Path B |
|---|---|---|
| `id` | Next available project-local AP/BP/PP-N | Same |
| `state` | `proposed` | `proposed` |
| `proposed_via` | `incidents` | `research` |
| `proposed_by` | `post-mortem` | `cto` (orchestrator) |
| `proposed_at` | ISO date | ISO date |
| `cited_incidents` | ≥3 entries, distinct hashes + plan_ref + summary | Empty list (Path B) |
| `cited_research` | Empty | Path to `docs/research/<topic>.md` + K/N consensus + use-case-fit citation |
| `is_state_mutating` | `true` if ratifying mutates persistent state beyond row insert | Same |
| `revert_procedure` | Required plain-text steps even for non-state-mutating rules | Same |
| `revert_script` | Required if `is_state_mutating: true` | Same |
| `bloat_projection` | Current count + 1; must be ≤ stack-config cap | Same |
| `proposed_check` | Must start with `grep:` or `script:` — `agent:` rejected | Same |
| `fixture_positive` | `tests/fixtures/proposals/{id}/positive.*`; scaffold with `# USER_TBD` | Same |
| `fixture_negative` | `tests/fixtures/proposals/{id}/negative.*`; scaffold with `# USER_TBD` | Same |

**STRAWMAN prefix:** prefix the proposed rule text body with `[STRAWMAN]`. Both paths bind identically. The `ratify-pattern` skill strips it on user approval.

**Revert stub (state-mutating only):** copy `templates/revert-pattern.template.sh` to `docs/pattern-proposals/revert-{id}.sh` and fill in pattern-specific rollback steps + idempotency + clean-branch test (per Wave 2 R-2 K8s graduation alignment).

**Fixture scaffolding:** create `tests/fixtures/proposals/{id}/positive.{ext}` and `negative.{ext}` with `# USER_TBD: insert a code/config snippet that the proposed_check MUST flag` and `# USER_TBD: insert a code/config snippet that the proposed_check must NOT flag`. This skill does not fill these in — that is the ratifier's responsibility before approving (G6).

## Quick Reference

- **Two ingest paths per ADR-003:**
  - Path A: ≥3 distinct `root_cause_hash` values (v1 carryforward)
  - Path B: BINDING (N/N at N≥5) `enterprise-research-first` finding + Step 6 use-case-fit passed (NEW)
- N=3 distinct hashes required for Path A — same hash ×3 = one reopened bug, not three incidents.
- Path B reject if K/N is only STRONG (not BINDING).
- Bloat cap parameterized in Stack Config (`pattern-bloat-cap`); default ≤20; check applies to both paths.
- `proposed_check` must start with `grep:` or `script:` — `agent:` rejected at project scope (G3).
- `[STRAWMAN]` prefix on rule text; `ratify-pattern` strips it on approval.
- `revert_procedure` required for every proposal; `revert_script` + idempotency + clean-branch test required only if `is_state_mutating: true`.
- Fixture files scaffold with `# USER_TBD` — ratifier fills them in and must pass G6 before approving.

## Composability

- **Composable with `ratify-pattern`** — ratifier runs the 6 mechanical gates against the proposal this skill produces.
- **Composable with `enterprise-research-first`** — Path B consumes ER1's BINDING findings + Step 6 use-case-fit result.
- **Composable with Post-Mortem agent** — Path A is dispatched by Post-Mortem after incident clustering.
- **Composable with `fix-time-hash-check`** — when the fix-time-hash skill identifies ≥3 prior matches in one session, Path A trigger fires.
- **Composable with `find-similar-implementations`** — when 3rd ADAPT entry in the same shape, Path A trigger fires (Fowler Rule of Three).

## Citations

**SP precedent:** None — confirmed. Adjacent: `writing-skills/SKILL.md` (skill-as-pattern shape); `brainstorming/SKILL.md` (proposal generation).

**Anthropic guidance:**
- *Effective Context Engineering* — patterns as compressed context
- *Building Effective Agents* — "common patterns are composable building blocks"

**Enterprise / OSS (9/11 BINDING on multi-trigger ingest):**
- Christopher Alexander *A Pattern Language* (1977) — canonical
- Gang of Four *Design Patterns* (1994) + POSA series
- Microsoft Azure Architecture Center pattern catalog
- AWS Well-Architected pattern library
- Refactoring Guru pattern catalog
- Martin Fowler "Rule of Three" — *Refactoring* (2018)
- Kubernetes KEP graduation criteria (alpha → beta → GA)
- IETF RFC 7942 (running-code requirement before standardization)
- Apache PMC pattern adoption process
- ThoughtWorks Tech Radar (Adopt ring criteria)

**Companion PF v2 research + ADRs:**
- `docs/research/skill-design-proposing-patterns.md` (Wave 2 Opus, 381L; 9/11 BINDING; broadening verdict APPROVE)
- `docs/adr/003-broadened-pattern-ingest.md` (the binding ADR for Path B)
- `docs/adr/001-7-gap-decisions.md` G3 amendment (UN-DEFER from v2.1)

**v1 carryforward:**
- `production-framework/skills/proposing-patterns/SKILL.md` — 5-step methodology carried forward verbatim; extended with Step 0 + Step 3a/3b dual-path
