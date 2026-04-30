---
id: BP-N                            # project-local ID: AP-N / BP-N / PP-N
state: proposed                     # state machine: proposed | ratified | rejected | postponed | reverted
proposed_via: incidents             # incidents (Path A — ≥3 distinct hashes) | research (Path B — BINDING ER1 + use-case-fit) per ADR-003
proposed_by: post-mortem            # post-mortem (Path A) | cto (Path B) | structural-check (retirement proposals)
proposed_at: YYYY-MM-DD             # ISO date
postponed_until:                    # OPTIONAL — only set when state: postponed (per Wave 2 R-3 + Rust RFC FCP); ISO date OR named condition
category: Bug                       # Bug | Architecture | Performance

# ---------------------------------------------------------------------------
# Path A fields (incidents) — required if proposed_via: incidents
# ---------------------------------------------------------------------------
cited_incidents:
  - hash: ""                        # root_cause_hash from scripts/compute-root-cause-hash.sh
    plan_ref: "PROJECT-PLAN.md#incident-YYYY-MM-DD"
    summary: "One-line description of the incident."
  - hash: ""
    plan_ref: "PROJECT-PLAN.md#incident-YYYY-MM-DD"
    summary: "One-line description of the second independent incident."
  - hash: ""
    plan_ref: "PROJECT-PLAN.md#incident-YYYY-MM-DD"
    summary: "One-line description of the third independent incident."

# ---------------------------------------------------------------------------
# Path B fields (research) — required if proposed_via: research per ADR-003
# ---------------------------------------------------------------------------
cited_research:
  artifact_path: ""                 # e.g., "docs/research/skill-design-stack-patterns-extensions-2026-04-30.md"
  k_n_consensus: ""                 # e.g., "7/7 BINDING" — must be N/N unanimous AND N≥5
  use_case_fit_passed: false        # MUST be true; cite the ER1 Step 6 paragraph in the research artifact
  use_case_fit_citation: ""         # path:line into the research artifact's Step 6 result

# ---------------------------------------------------------------------------
# Common fields (both paths)
# ---------------------------------------------------------------------------
is_state_mutating: false            # true if ratifying mutates persistent state beyond STACK-PATTERNS.md row insert. If true, revert_script is REQUIRED.
revert_procedure: |                 # REQUIRED for every proposal (plain text; script required ONLY if is_state_mutating: true)
  1. Remove the {id} row from STACK-PATTERNS.md.
  2. Remove tests/fixtures/proposals/{id}/ directory.
  3. Remove any agent/skill references citing {id}.
revert_script: ""                   # Path to revert-{id}.sh — REQUIRED only if is_state_mutating: true; must include idempotency + clean-branch test per Wave 2 R-2
bloat_projection: 1                 # Current STACK-PATTERNS.md project-pattern row count + 1; must be ≤ {stack:pattern-bloat-cap} (default 20)
proposed_check: "grep: PATTERN"     # MUST start with grep: or script: — agent: is REJECTED at project scope (G3)
fixture_positive: "tests/fixtures/proposals/{id}/positive.{ext}"   # Input that proposed_check MUST flag (G6)
fixture_negative: "tests/fixtures/proposals/{id}/negative.{ext}"   # Input that proposed_check must NOT flag (G6)
---

## Proposed rule

[STRAWMAN] {One-paragraph rule text. The `[STRAWMAN]` prefix is stripped by `ratify-pattern` on user approval. Until then, this text is a draft — do not cite as authoritative.}

## Why

{One-paragraph rationale derived from the cited evidence:}

- **Path A:** reference the specific failure pattern shared across all 3 cited incidents, not just the symptoms.
- **Path B:** reference the K/N consensus + the specific architectural lever the consensus pattern provides + the use-case-fit check result demonstrating this project needs it.

## Check

{Repeat the `proposed_check` value from frontmatter here. Must be a `grep:` pattern or `script:` invocation — not a description or agent instruction.}

## Ratification checklist

- [ ] `proposed_via` is `incidents` OR `research` (Step 0 source detection per ADR-003)
- [ ] **If Path A:** 3 independent `root_cause_hash` values (all distinct — same hash ×3 = one reopened bug) (G2A)
- [ ] **If Path B:** K/N is N/N unanimous AND N≥5 (BINDING per ER1 Step 4 grammar) AND ER1 Step 6 use-case-fit passed with cited paragraph (G2B)
- [ ] `proposed_check` is machine-verifiable (`grep:` or `script:`) — `agent:` rejected at project scope (G3)
- [ ] `bloat_projection` ≤ `{stack:pattern-bloat-cap}` (G1; cap parameterized in Stack Config)
- [ ] `revert_procedure` field populated with plain-text steps (G5)
- [ ] If `is_state_mutating: true`: `revert_script` path populated AND file exists AND has `#!/usr/bin/env bash` shebang AND includes idempotency check + clean-branch test (G5; Wave 2 R-2 K8s graduation alignment)
- [ ] `fixture_positive` and `fixture_negative` paths exist; `proposed_check` passes against both (G6)
- [ ] Rule does not overlap an existing BP-*/AP-*/PP-* row in STACK-PATTERNS.md (`check_rule_conflict`)

---

## State machine (4 dispositions per Rust RFC FCP)

```
proposed
  ├─→ ratified   (via ratify-pattern; user approves after all 6 gates pass)
  │     └─→ reverted  (via revert-{id}.sh; operator runs script; state = reverted)
  ├─→ rejected   (via ratify-pattern; user rejects)
  └─→ postponed  (via ratify-pattern; user postpones with postponed_until field)
        └─→ proposed  (when postponed_until condition met → user re-invokes ratify-pattern)

Terminal states (ratified-then-reverted, rejected) move file to docs/pattern-proposals/archive/.
postponed proposals stay in place with postponed_until field set.
```

---

## Notes for the proposer (Post-Mortem agent or CTO orchestrator)

- Do NOT fill in `fixture_positive` / `fixture_negative` bodies — scaffold the files with `# USER_TBD` markers only. Ratifier fills them in.
- Do NOT remove `[STRAWMAN]` prefix — `ratify-pattern` handles that on approval.
- Do NOT write the ID row to `STACK-PATTERNS.md` — that is `ratify-pattern`'s job.
- If `is_state_mutating: true`: also create `docs/pattern-proposals/revert-{id}.sh` from `templates/revert-pattern.template.sh` (must include idempotency + clean-branch test per Wave 2 R-2).
- **Path A:** all 3 cited_incidents must have computed hashes (run `scripts/compute-root-cause-hash.sh` and backfill PROJECT-PLAN.md).
- **Path B:** cite the research artifact's exact Step 6 use-case-fit paragraph. The path-line citation is the audit trail.
