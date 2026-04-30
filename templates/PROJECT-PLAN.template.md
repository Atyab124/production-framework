# {Project} Plan

Fork this file to `docs/PROJECT-PLAN.md`. Update after every phase. Sections marked `[preserved verbatim]` must survive `/compact`.

---

## Phase Status

| Phase | Status | Gate | Notes |
|---|---|---|---|
| Phase 1 | PENDING | — | — |

**Status tokens:** `PENDING` | `IN_PROGRESS` | `COMPLETE` | `COMPLETE_AWAITING_QA` | `BLOCKED`

---

## Open Findings

[Preserved verbatim across /compact — each finding is an active incident until resolved]

| ID | Severity | Area | Description | Rule |
|---|---|---|---|---|
| — | — | — | — | — |

**Severity levels:** `CRITICAL` | `HIGH` | `MEDIUM` | `LOW`

---

## Remnant Watchlist

[Things to remove before ship — debug logs, feature flags, TODO stubs, FRAMEWORK_ALLOW_DEBUG_EXIT skips, FRAMEWORK_SKIP_PRECOMMIT skips]

| Item | Where | Remove by |
|---|---|---|
| — | — | — |

---

## Architecture Documents

| Module | Doc | Last-verified |
|---|---|---|
| — | — | — |

---

## Incident Table

[Append-only. Each remediation / post-mortem adds a row. Impact column must inline: `Xh lost | N findings | blast radius: <scope>`]

[`root_cause_hash` is nullable for existing rows. Post-Mortem agent backfills it via `scripts/compute-root-cause-hash.sh`. Required for rows that qualify as cited incidents in a pattern proposal.]

| Principle | Incident | Impact | root_cause_hash |
|---|---|---|---|
| — | — | — | — |

---

## Regression Scope Catalog

[Reusable across phases — what touches what. Add a row when a module-crossing dependency is discovered.]

| Feature / Module | Depends on | Depended on by |
|---|---|---|
| — | — | — |
