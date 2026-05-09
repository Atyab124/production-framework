---
name: rls-aware-migrations
description: "Use when designing or applying any Postgres schema migration on a multi-tenant project — enforces phase classification (expand → backfill → cutover → contract), client-shape-aware migration steps, RLS index requirements, and irreversible-migration disclosure. Composes with database-engineer agent and gate-3 D10."
---

## Overview

Multi-tenant Postgres migrations have two failure modes that single-tenant schemas don't share:

1. **RLS-bypass at migration time** — migrations typically run as table owner; without `FORCE ROW LEVEL SECURITY`, the owner bypasses every policy. The migration itself is fine; the runtime app role inherits the bypass.
2. **Lock contention + lock-bypass** — large-table migrations on tenant-scoped tables hold locks that affect every tenant.

This skill prescribes the migration phase pattern (expand → double-write → backfill → cutover → contract) per gh-ost / pgRoll / pt-osc 3/3 enterprise consensus. It pairs with `agents/database-engineer.md` HARD-GATEs on `FORCE ROW LEVEL SECURITY` and Data-Loss Disclosure.

**Enterprise grounding (DB Engineer research already cites all three):** gh-ost (MySQL online schema change), pgRoll (Postgres virtual-schema migrations), pt-osc (Percona online schema change). Plus PostgreSQL §5.9 (RLS bypass), Supabase RLS performance docs (99.94% / 94.97% / 99.78% / 99.993% measured fixes).

## When to Use

- Any migration on a multi-tenant table.
- Any migration adding / dropping / renaming a column on a table with ≥1 RLS policy.
- Any migration changing a column referenced in an RLS policy (USING or WITH CHECK clause).
- Any migration adding an index on a tenant-scoped table.

Do NOT use:
- Single-tenant migrations (cite STACK-PATTERNS.md `tenancy-model: single-tenant` + waive).
- DDL on tables without RLS policies AND no tenant_id column.

## Core Pattern

You MUST create a TodoWrite item per step.

### Step 1 — Phase classification (mandatory; gate-3 D10)

Declare ONE phase explicitly:

- **expand-only** — additive change (add column with default, add index, add policy). No data movement. Reversible any-time.
- **contract** — destructive change (drop column, drop policy). Requires prior expand phase to have shipped + been verified.
- **mixed** — some expand + some contract in the same migration. Avoid; split into 2 migrations.

For multi-step migrations, classify the cutover envelope: any-time / pre-cutover-only / post-cutover-only / irreversible.

If irreversible: produce 3-line Data-Loss Disclosure per `agents/database-engineer.md` HARD-GATE shape.

### Step 2 — RLS index requirement check

Per Supabase RLS performance docs:

> "Make sure you've added indexes on any columns used within the Policies which are not already indexed (or primary keys)."

For every column referenced in any RLS policy on the target table: verify an index exists. If absent → add the index in this migration's expand phase OR a prior expand-only migration.

Measured impact (Supabase): 99.94% query-time improvement (171ms → <0.1ms) by adding the index referenced in the policy USING clause.

### Step 3 — Client-shape-aware migration steps (per Wave 3 Pattern 4 / 7VQ Q3)

Migrations execute under a client. Name which:

- **Migration runner client** (typically table owner role) → BYPASSES RLS by default. `FORCE ROW LEVEL SECURITY` makes the migration honor RLS even when run as owner.
- **App runtime client** (user-scoped JWT) → applies RLS. Verify migration's data shape works under the app's runtime client.
- **Service-role client** (admin) → bypasses RLS. If migration's backfill needs to read across tenants, service-role is correct; explicit decision must be documented.

Per `agents/database-engineer.md` HARD-GATE: every multi-tenant table MUST declare exactly one of:
1. `ALTER TABLE ... FORCE ROW LEVEL SECURITY;` if the table owner is the runtime app role
2. A non-owning application role + the owner stays a separate role

### Step 4 — Phase pattern execution (gh-ost / pgRoll / pt-osc 3/3 consensus)

```
expand → double-write → backfill → cutover → contract
```

For non-trivial migrations:

1. **Expand:** create new column / table / index. Application code still reads/writes the old shape. Reversible any-time.
2. **Double-write:** application writes both shapes (old + new). Read still goes to old.
3. **Backfill:** populate new shape from old. Strategy: `synchronous-batch` (small tables; locks acceptable) OR `async-chunk` (large tables; chunked over time). Document which.
4. **Cutover:** application reads/writes new shape only. Trigger: `deploy-time` / `feature-flag` / `observability-gate`. Document which.
5. **Contract:** drop old shape. Requires cutover ship + verification window (typically ≥1 sprint of monitoring).

Single-step destructive migrations are an Anti-Pattern. Mixing expand + contract in one migration is rejected by gate-3 D10.

### Step 5 — Rollback envelope declaration

Document explicitly:
- `any-time` — full reversibility throughout (rare for non-trivial migrations)
- `pre-cutover-only` — reversible until Step 4; afterward forward-fix only
- `post-cutover-only` — reversible only after Step 4 (rare; specific double-write scenarios)
- `irreversible` — requires Data-Loss Disclosure (gate-3 D10 HARD-GATE)

## Anti-Patterns

### "It's a small migration; skip the phase classification"

D10 (gate-3) requires phase classification on every migration touching multi-tenant data. "Small" is the rationalization that ships destructive single-step migrations.

### "FORCE ROW LEVEL SECURITY is overkill for this migration"

If the migration's table is tenant-scoped, FORCE RLS is the data-layer enforcement primitive. Skipping it makes migrations bypass policies — a defense-in-depth gap.

### "Async backfill — we'll just run it manually"

Manual backfill is not a strategy. Document `async-chunk` with named chunk size + named runner (cron / one-off script / pgRoll-style virtual-schema). Without a named runner, backfill never completes.

### "Rollback envelope is implicit; the team knows"

Item 9 evidence: arch docs that don't name the rollback envelope produce surprises. Declare explicitly per gate-3 D10.

## Quick Reference

- Phase classification mandatory (expand-only / contract / mixed-avoid).
- RLS-policy column index requirement (Supabase 99.94% measured).
- Client shape declaration (runner vs runtime vs service-role; per Wave 3 Pattern 4).
- 5-step phase pattern (expand → double-write → backfill → cutover → contract) — gh-ost / pgRoll / pt-osc 3/3.
- Rollback envelope explicit (any-time / pre-cutover-only / post-cutover-only / irreversible-with-disclosure).
- D10 (gate-3) reads this skill's outputs as evidence.

## Common Recovery

When the migration tool (Supabase CLI, plain SQL, or migration runner) fails, recovery paths:

| Symptom | Error class | Recovery path | Escalation if recovery fails |
|---|---|---|---|
| `relation "<table>" does not exist` during a backfill phase | Schema-state mismatch — backfill assumes a table that the expand phase didn't create yet | Verify expand phase ran successfully; check `list_tables` against expected schema; re-run expand if missing. | If expand ran and table is still absent, the migration ordering is broken; revert and re-author with explicit phase deps. |
| `permission denied for table` | RLS policy active but role doesn't satisfy it; or migration role lacks privileges | Confirm the migration runs as superuser / service-role for DDL; user-role for DML. Check policy `USING` clause. | If permission persists with correct role, the policy is over-restrictive; revise per the architect's plan. |
| `cannot drop column referenced by view / FK / index` | Contract phase missing dependency cleanup | Drop dependents first (views, indexes, FKs) in their own phase before the column. | If dependency graph is unclear, revert and add a `pg_depend` audit step to the plan. |
| `deadlock detected` during migration | Concurrent reads/writes hold conflicting locks | Re-run during a maintenance window, OR switch to `CREATE INDEX CONCURRENTLY` / `ALTER TABLE ... NOT VALID` patterns. | If still failing, the migration cannot be done online; declare it offline and add downtime plan. |

Document any new failure mode in `docs/PROJECT-PLAN.md` Open Findings.

## Composability

- **Invoked by `agents/database-engineer.md`** for every multi-tenant migration.
- **Pairs with `gate-3-production-check` D10** — D10 reads the phase classification + rollback envelope this skill produces.
- **Pairs with `tenant-isolation` skill** — RLS policy correctness + this skill's index requirements.
- **Composable with `audit-trail`** — when migration adds/drops audit-related columns, audit-trail skill extends.

## Citations

**SP precedent:** None — domain-specific.

**Anthropic guidance:** *Effective Context Engineering* — file artifacts for migration plans.

**Enterprise / OSS (3/3 BINDING + 99.94% measured):**
- gh-ost (MySQL online schema change): https://github.com/github/gh-ost
- pgRoll (Postgres virtual-schema migrations): https://github.com/xataio/pgroll
- pt-osc (Percona online schema change): https://docs.percona.com/percona-toolkit/pt-online-schema-change.html
- PostgreSQL §5.9 (RLS bypass + FORCE ROW LEVEL SECURITY): https://www.postgresql.org/docs/current/ddl-rowsecurity.html
- Supabase RLS performance docs: https://supabase.com/docs/guides/database/postgres/row-level-security#rls-performance-recommendations
- AWS SaaS Lens silo / pool / bridge: https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/silo-pool-and-bridge-models.html

**Companion PF v2 research:**
- `docs/research/agent-design-database-engineer.md` Topics A–D — Postgres §5.9 + Supabase RLS guide + perf section + community discussion
- `agents/database-engineer.md` — HARD-GATEs on FORCE RLS + Data-Loss Disclosure
- `skills/gate-3-production-check/SKILL.md` D10 — reads this skill's outputs
