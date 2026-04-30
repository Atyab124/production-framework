# ADR-003 — Broadened Pattern Ingest (D-E)

**Status:** Accepted
**Date:** 2026-04-30
**Decided by:** PF v2 maintainer
**Supersedes:** Modifies ADR-001 G3 (un-defer `proposing-patterns` + `ratify-pattern` from v2.1 to v2.0.x)
**Related:** `docs/research/skill-design-proposing-patterns.md` (Wave 2 Opus, 381L); `docs/research/skill-design-ratify-pattern.md` (Wave 2 Sonnet, 359L); `docs/research/skill-design-stack-patterns-extensions-2026-04-30.md` Pattern 2 (first independent test of Path B); `docs/audits/v1-feedback-vs-v2-2026-04-30.md` Items 39 + 40 + 41.

## Context and Problem Statement

PF v1's `proposing-patterns` skill gates pattern-registry ingest to **≥3 internal incidents** (Path A). Audit Items 39 + 40 surfaced two convergent gaps:

1. **Single-pass fixes never enter the incident table** (Item 40-1) — without recurrence, no path to pattern.
2. **External BINDING research findings (N/N at N≥5) bypass the incident loop entirely** (Item 40-5) — `enterprise-research-first` produces consensus-grade evidence stronger than 3 internal observations, but no skill promotes it to a pattern row.

Wave 2 research (`skill-design-proposing-patterns.md`) recommends broadening ingest with **Path B**: BINDING research findings (N/N at N≥5) qualify as proposal candidates parallel to the ≥3-incident path, gated by `enterprise-research-first` Step 6 use-case-fit check. 9/11 (82%) enterprise pattern-proposal frameworks support multi-trigger ingest.

The Wave 3 STACK-PATTERNS research produced **the first independent test** of this broadening: Pattern 2 (React state-setter closure-flag) has 1 internal incident + 7/7 BINDING enterprise grounding (react-mentions + text-expander-element). Under Path A alone, it would never qualify; under Path B, it qualifies cleanly.

## Decision Drivers

- 9/11 enterprise pattern-proposal frameworks support multi-trigger ingest (PLoP and Fowler's Rule of Three are the only strict-recurrence-only outliers; both still align with Path A)
- Path B's cargo-cult risk is mitigated by `enterprise-research-first` Step 6 use-case-fit check (load-bearing 7/7 OAuth incident — broadening *inherits* the mitigation rather than inventing one)
- Wave 3 produced a Path-A candidate (Pattern 1, 3x recurrence) and a Path-B candidate (Pattern 2, BINDING research) **simultaneously** — empirical demonstration of broadening's value
- Item 41 STRENGTH: PF v1's Rule #43 incident-loop is "the most carefully engineered subsystem in v1" — porting it to v2.0.x (not v2.1 per ADR-001 G3) preserves the strength

## Considered Options

| Option | Description | Rejected for |
|---|---|---|
| **A. Keep ADR-001 G3 — defer to v2.1** | Continue with v1 carryforward in v2.1; ship v2.0 without `proposing-patterns` / `ratify-pattern` | Item 41 STRENGTH evidence + Wave 3 Path-B candidate make the defer indefensible — we have a working primitive and live test cases |
| **B. Port v1 verbatim — incidents-only ingest (Path A)** | Carry v1 unchanged; Path A only | 9/11 enterprise consensus on multi-trigger ingest; Pattern 2 from Wave 3 would never qualify; underuses the BINDING research signal |
| **C. Broaden to dual-path (Path A + Path B) (CHOSEN)** | Carry v1 5-step methodology + add Step 0 (source detection) + Step 3a/3b dual-path branch | None — research consensus + empirical test cases all align |

## Decision Outcome

**Option C: Dual-path ingest (Path A + Path B), shipped in v2.0.x (un-deferred from v2.1).**

### Path A (carryforward) — Incident-driven

- **Trigger:** ≥3 incidents in PROJECT-PLAN.md Incident Table sharing the same `root_cause_hash`.
- **Skill:** `proposing-patterns` runs the v1 5-step methodology verbatim (cluster → threshold → bloat-cap → STRAWMAN draft → ratify hand-off).
- **Citation strength:** Fowler "Rule of Three" + Microsoft Engineering Playbook + PLoP (3/11 explicit; 9/11 support recurrence-as-trigger).

### Path B (new) — Research-driven

- **Trigger:** `enterprise-research-first` produces a BINDING finding (N/N unanimous AND N≥5) AND Step 6 use-case-fit check passes.
- **Skill:** `proposing-patterns` runs the v1 5-step methodology with Step 0 (source detection: tag as Path A or Path B) and Step 3b (BINDING research substituted for ≥3-incident clustering).
- **Citation strength:** RFC 7942 + Microsoft + AWS WAF + Refactoring Guru + KEP + Apache + ThoughtWorks Tech Radar (7/11 explicit support for external-evidence-as-trigger).

### Both paths

- **Ratification:** all 6 mechanical gates in `ratify-pattern` apply equally. G2 refactors to G2A (incidents) OR G2B (BINDING research); STRAWMAN prefix discipline binds both paths.
- **User-gated:** ratification requires explicit user approval per `ratify-pattern` HARD-GATE.
- **`postpone` as 4th Stage-3 disposition** (per `ratify-pattern` R-3 — Rust RFC FCP-aligned; prevents premature rejection of proposals needing more time).

### Carryforward scope

- `scripts/compute-root-cause-hash.sh` (verbatim port; preserve HASH_VERSION=1; Rollbar + Datadog independently corroborate the 7-rule normalization grammar verbatim).
- `scripts/structural-check.sh:check_incident_logged` function (Rule #43 MACHINE enforcement).
- `skills/proposing-patterns/SKILL.md` (Path A + Path B).
- `skills/ratify-pattern/SKILL.md` (6 mechanical gates + `postpone` disposition; G1 ≤20-row bloat cap parameterized in Stack Config; G1 + G2 explicitly tagged PF-original with failure-mode rationales).
- `templates/pattern-proposal.template.md` (carryforward + Path B section).
- `templates/revert-pattern.template.sh` (carryforward + idempotency + clean-branch test requirements per K8s graduation alignment).

## Consequences

**Positive:**
- Closes audit Items 39, 40 (broadening), 41 (un-defer + carryforward port).
- Pattern registry grows from internally-validated incidents AND externally-validated research — neither path silently exclusive.
- Wave 3 Pattern 2 (React state-setter) becomes the first ratifiable Path-B pattern when v2.0.x ships.
- Sets precedent for future BINDING research → pattern promotion (Wave 3 Pattern 1 already qualifies via Path A at 3x recurrence).

**Negative:**
- Updates `sp-anthropic-citation-manifest.md` GAP-3 framing: composition is PF-original; components are enterprise-cited 9/11 (manifest update is itself an implementation task).
- Scope increase to v2.0.x — was scheduled for v2.1.

**Neutral:**
- ADR-001 G3 row is amended (not deleted) per append-only ADR discipline.

## More Information

- `docs/research/skill-design-proposing-patterns.md` (Wave 2 Opus, 381L) — full R-1, R-2, R-3 recommendations
- `docs/research/skill-design-ratify-pattern.md` (Wave 2 Sonnet, 359L) — gate-to-analog mapping; G1+G2 PF-original justification; `postpone` disposition rationale
- `docs/research/skill-design-stack-patterns-extensions-2026-04-30.md` Pattern 2 — first Path-B candidate
- `docs/research/skill-design-fix-time-hash-check.md` — Rollbar + Datadog corroborate v1 hash normalization verbatim
- ADR-001 G3 (amended in same commit cluster as this ADR)
