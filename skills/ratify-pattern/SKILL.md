---
name: ratify-pattern
description: "Use when a user wants to review, approve, reject, or postpone a pattern proposal. Runs all 6 mechanical gates (G1–G6), presents the diff, and on approval merges the proposal into STACK-PATTERNS.md. Includes 4-disposition Stage-3 workflow per Rust RFC FCP (approve / reject / edit / postpone). Never bypasses any gate."
---

## Overview

User-gated ratification flow for pattern proposals generated via `proposing-patterns` (Path A or Path B per ADR-003). Runs all 6 mechanical gates via `scripts/structural-check.sh` before presenting the proposal for human approval. On approval merges the proposed row into `STACK-PATTERNS.md`, strips the `[STRAWMAN]` prefix, sets `state: ratified`, and moves the proposal to `docs/pattern-proposals/archive/`. **Never bypasses any gate** — a gate failure blocks approval until resolved.

**Enterprise grounding** (per Wave 2 R-2):
- **G3 machine-verifiable check (5/7):** TC39 Test262, K8s e2e, Linux CI strict matches
- **G4 ratification traceability (6/7 — strongest consensus):** all 6 cited frameworks have an analog
- **G5 rollback path (5/7 partial; 2/7 strict):** K8s graduation, Linux Signed-off-by chain
- **G6 fixture gate (4/7):** TC39 Test262, K8s e2e strict matches
- **G1 (≤20-row bloat cap) and G2 (duplicate-incident hash) are PF-original** (0/7 analog) — kept with explicit failure-mode rationales rather than inventing citations

**4-disposition workflow per Wave 2 R-3** — adds `postpone` alongside `approve / reject / edit`, aligning Rust RFC FCP three-disposition model + preventing premature rejection of proposals needing more time.

## When to Use

- A proposal file exists at `docs/pattern-proposals/{date}-{id}.md` with `state: proposed`.
- User explicitly invokes ratification ("ratify BP-12", "review the pattern proposal", etc.).
- Structural-check has flagged a proposal as pending (G4 orphan-row check).

## Core Pattern

You MUST create a TodoWrite item per stage.

### Stage 1 — Read proposal

Read `docs/pattern-proposals/{date}-{id}.md`. Extract:
- `proposed_via` (Path A `incidents` or Path B `research`)
- `cited_incidents[]` (Path A) OR `cited_research` (Path B)
- `proposed_check`
- `bloat_projection`
- `revert_procedure`
- `is_state_mutating` + `revert_script` path
- `fixture_positive` + `fixture_negative` paths

### Stage 2 — Run all 6 gates

Run `bash scripts/structural-check.sh` (or equivalent per-gate commands). All 6 must pass:

| Gate | Check | Path A | Path B | Failure action |
|---|---|---|---|---|
| **G1 Bloat cap** | STACK-PATTERNS.md project rows ≤ `{stack:pattern-bloat-cap}` (parameterized per Wave 2 R-1; default 20) | applies | applies | Block; do not proceed |
| **G2A Duplicate-incident hash (Path A only)** | All 3 cited hashes distinct | applies | N/A | Block; return colliding hash to user |
| **G2B BINDING + use-case-fit (Path B only — added per ADR-003)** | K/N is N/N at N≥5 AND ER1 Step 6 use-case-fit passed | N/A | applies | Block; require BINDING + use-case-fit citation |
| **G3 Machine-verifiable check** | `proposed_check` starts with `grep:` or `script:` (5/7 enterprise consensus — TC39 Test262, K8s e2e, Linux CI) | applies | applies | Block; require machine-verifiable check |
| **G4 Ratification traceability** | `check_framework_health` (orphan-row sub-check) — STACK-PATTERNS.md has no pattern row without matching archive entry | applies | applies | Passes pre-approval; re-run post-merge |
| **G5 Rollback path** | `revert_procedure` non-empty; if `is_state_mutating: true`, `revert_script` exists, has shebang, includes idempotency + clean-branch test (Wave 2 R-2 K8s graduation alignment) | applies | applies | Block if any element missing |
| **G6 Fixture gate** | `fixture_positive` + `fixture_negative` exist AND `proposed_check` produces expected results against each | applies | applies | Block; list which fixture is missing or mismatched |

**G1 and G2A/G2B are PF-original** (0/7 enterprise analog per Wave 2 R-1). Failure-mode rationales:
- **G1 — Bloat cap:** without it, the pattern registry grows unbounded; the rule-set becomes folklore the next contributor can't audit. Parameterized in Stack Config — single-tenant projects can set 30; high-velocity projects can set 15.
- **G2A — Duplicate hash:** without it, one reopened bug reads as 3 incidents. Three reopens are not three independent occurrences — they're one unsolved problem.

<HARD-GATE>
All 6 gates must pass before presenting the disposition prompt.
If ANY gate fails, list the failure(s) and STOP.
Do not present the diff. Do not ask for disposition. Do not modify any file.
The user must fix the failing gate(s) and re-invoke ratify-pattern.
</HARD-GATE>

### Stage 3 — Present diff to user (4-disposition)

Display the proposed STACK-PATTERNS.md row as a diff. Include:
- The proposed `[STRAWMAN]`-prefixed rule text (will have prefix stripped on approve).
- The `Why` and `Check` fields from the proposal body.
- The `revert_procedure` text.
- Path A: 3 cited incident hashes + summaries. Path B: research artifact path + K/N consensus + use-case-fit citation.

Use a minimal YAML disposition block:

```yaml
# Disposition for this pattern proposal?
# proposal: docs/pattern-proposals/{date}-{id}.md
# id: {id}
# proposed_via: {incidents|research}
# proposed_check: {check}
# bloat_projection: {N}
# action: approve | reject | edit | postpone
action: approve
```

Wait for user to fill in `action:` and return the block.

### Stage 4a — On approve

1. Append the new pattern row to `STACK-PATTERNS.md` with the `[STRAWMAN]` prefix stripped from the rule text.
2. Update `docs/pattern-proposals/{date}-{id}.md` frontmatter: set `state: ratified`.
3. Move the proposal file to `docs/pattern-proposals/archive/{date}-{id}.md`.
4. If `is_state_mutating: true`: confirm `revert_script` is executable + idempotent + clean-branch-test passes.
5. Re-run G4 (`check_framework_health` orphan sub-check) against the updated STACK-PATTERNS.md.

### Stage 4b — On reject

1. Update `docs/pattern-proposals/{date}-{id}.md` frontmatter: set `state: rejected`.
2. Move to `docs/pattern-proposals/archive/{date}-{id}.md`.
3. No change to `STACK-PATTERNS.md`.

### Stage 4c — On edit

Return the proposal to user with a comment list of what must change. Re-invoke ratify-pattern after edits. The `[STRAWMAN]` prefix stays until a full approval cycle completes.

### Stage 4d — On postpone (NEW per Wave 2 R-3 / Rust RFC FCP)

1. Update `docs/pattern-proposals/{date}-{id}.md` frontmatter: set `state: postponed`.
2. Add `postponed_until: <ISO date | condition>` field — when to revisit (e.g., "2026-07-01" or "after BP-X ratification").
3. Leave the proposal in place (NOT moved to archive — it's still active).
4. No change to `STACK-PATTERNS.md`.

**Why `postpone` is distinct from `reject`:** binary approve/reject forces premature decisions on proposals that merely need more time / more incidents / more research. Per Rust RFC FCP three-disposition model: explicit "not now, revisit later" surface beats silent rejection.

## Anti-Patterns

### "G6 fixtures aren't ready, but the proposal looks right — let me approve"

HARD-GATE blocks. G6 is 6/7 enterprise consensus (TC39 Test262, K8s e2e, ESLint, SonarQube, Semgrep, CodeQL) — highest-value gate. Fixtures are how the rule's machine-checkability is proven. Skipping = approving a rule that can't enforce itself.

### "We approved this last week, just merge it"

Each ratification cycle is fresh. State changes (new patterns, new incidents) since the last approval may invalidate the proposal. Re-run all 6 gates.

### "It's a small rule, the bloat cap doesn't apply"

Bloat cap applies to ALL proposals. The rule-set's auditability depends on bounded size. If the cap blocks, propose a retirement first (PF v1 G1 retirement-via-empty-incident-column convention).

## Quick Reference

- 6 gates ALL must pass before disposition prompt — no exceptions, no bypasses.
- G6 is 6/7 enterprise consensus — highest-value gate.
- G2A (Path A) OR G2B (Path B) — split per ADR-003 dual-path ingest.
- G1 + G2A/G2B are PF-original (0/7 analog) — kept with failure-mode rationales.
- 4 dispositions: approve / reject / edit / **postpone** (new per Wave 2 R-3 + Rust RFC FCP).
- On approve: row appended, `[STRAWMAN]` stripped, archived `state: ratified`.
- On postpone: proposal stays in place with `postponed_until` field; not archived.

## Composability

- **Pairs with `proposing-patterns`** — that skill produces the proposal this skill ratifies.
- **Composable with Post-Mortem agent** — Path A proposals come from Post-Mortem.
- **Composable with `enterprise-research-first`** — Path B proposals cite ER1 BINDING findings + Step 6 use-case-fit.
- **Distinct from `gate-3-production-check`** — Gate 3 is pre-ship feature gate; this skill is pattern-registry gate.

## Citations

**SP precedent:** None — confirmed. Adjacent: HARD-GATE convention (`brainstorming/SKILL.md` lines 12–14) for user-gating idiom.

**Anthropic guidance:**
- *Building Effective Agents* — "user as final approver in agent workflows"

**Enterprise / OSS (≥3 satisfied 7 ratification frameworks):**
- Apache PMC vote rules — binding +1 / -1 / 0 grammar
- Kubernetes KEP graduation — alpha → beta → GA gates (G5 idempotency + clean-branch test alignment)
- IETF RFC publication track — Internet-Draft → Proposed Standard → Standard
- W3C Recommendation track — CR → PR → REC
- ECMAScript TC39 Stage 0–4 (G6 fixture-gate alignment via Test262)
- Rust RFC FCP — Final Comment Period + lazy consensus (`postpone` 4th disposition source)
- Linux kernel maintainer Signed-off-by + Reviewed-by chain (G5 rollback alignment)

**Companion PF v2 research + ADRs:**
- `docs/research/skill-design-ratify-pattern.md` (Wave 2 Sonnet, 359L)
- `docs/adr/003-broadened-pattern-ingest.md` (G2A/G2B split per dual-path)
- `docs/adr/001-7-gap-decisions.md` G3 amendment (UN-DEFER from v2.1)

**v1 carryforward:**
- `production-framework/skills/ratify-pattern/SKILL.md` — 6 gates carried forward; extended with G2B + 4th disposition + parameterized G1
