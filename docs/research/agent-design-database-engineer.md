# Agent Design Research — Database Engineer

**Date:** 2026-04-29
**Type:** Research — no code modifications
**Triggered by:** PF v2 binding rule — every feature must cite SP precedent OR Anthropic guidance. Database Engineer agent has no SP precedent (SP ships only `code-reviewer`) and Anthropic guidance is sparse on data/SQL agents. Industry references therefore required.
**Methodology disclosure:** WebFetch was permission-denied for several Percona, Supabase troubleshooting, and Anthropic blog URLs. WebSearch synthesis used as fallback for those, marked `(via WebSearch synthesis)`. All other quotes are verbatim from direct WebFetch of canonical URLs. Re-verify before binding architectural decisions.

---

## 1. Canonical Sources Consulted

| # | Source | URL | Fetch method | Status |
|---|---|---|---|---|
| 1 | PostgreSQL official RLS docs | https://www.postgresql.org/docs/current/ddl-rowsecurity.html | WebFetch direct | OK |
| 2 | Supabase RLS guide | https://supabase.com/docs/guides/database/postgres/row-level-security | WebFetch direct | OK |
| 3 | Supabase RLS performance section | https://supabase.com/docs/guides/database/postgres/row-level-security#rls-performance-recommendations | WebFetch direct | OK |
| 4 | Supabase RLS performance pitfalls (community) | https://github.com/orgs/supabase/discussions/14576 | WebFetch direct | OK |
| 5 | AWS SaaS Lens — Tenant Isolation overview | https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/tenant-isolation.html | WebFetch direct | Stub (referred to detailed pages) |
| 6 | AWS SaaS Lens — Silo / Pool / Bridge models | https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/silo-pool-and-bridge-models.html | WebFetch direct | OK |
| 7 | AWS SaaS Lens — Data Partitioning | https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/data-partitioning.html | WebFetch direct | Stub (referred to PDF) |
| 8 | Microsoft Azure SQL multi-tenant patterns | https://learn.microsoft.com/en-us/azure/azure-sql/database/saas-tenancy-app-design-patterns | WebFetch direct | OK |
| 9 | gh-ost README | https://github.com/github/gh-ost/blob/master/README.md | WebFetch direct | OK |
| 10 | pt-online-schema-change docs | https://docs.percona.com/percona-toolkit/pt-online-schema-change.html | WebFetch denied; WebSearch synthesis | Indirect |
| 11 | Percona blog — pt-osc + foreign keys | https://www.percona.com/blog/dont-auto-pt-online-schema-change-for-tables-with-foreign-keys/ | WebFetch denied; covered by WebSearch | Indirect |
| 12 | pgroll README (Xata) | https://github.com/xataio/pgroll | WebFetch direct | OK |
| 13 | AWS Database Blog — RLS for multi-tenancy | https://aws.amazon.com/blogs/database/multi-tenant-data-isolation-with-postgresql-row-level-security/ | WebFetch denied; WebSearch synthesis | Indirect |
| 14 | DDIA (Kleppmann) — Sharding for Multitenancy | book; ISBN 9781449373320 / 9781098119058 | WebSearch only (copyright limited verbatim) | Topical |
| 15 | Anthropic — Agent Skills overview / database-schema-designer skill | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview | WebSearch synthesis | Sparse |

**Anthropic data-agent guidance: confirmed sparse.** WebSearch returns generic "Skills are reusable filesystem resources" + a community-published `database-schema-designer` skill with a four-phase Analyze/Design/Optimize/Migrate framing. No Anthropic-authored prescriptive guidance on RLS, multi-tenant isolation, or migration safety beyond the generic skill-shape advice already cited in `sp-anthropic-citation-manifest.md` Part 2 §2.11–2.12.

---

## 2. Verbatim Quotes by Topic

### Topic A — Multi-tenant isolation models (silo / pool / bridge / hybrid)

**AWS SaaS Lens — Silo:**
> "The **silo model** refers to an architecture where tenants are provided dedicated resources. Imagine, for example, as SaaS environment where each tenant of your system has a fully independent infrastructure stack. Or, perhaps each tenant of your system has a separate database. When some or all of a tenant's resources are deployed in this dedicated fashion, we refer to this as a silo model."

> "It's important to note that—even though the silo has dedicated resources—a silo environment still relies on a shared identity, onboarding, and operational experience where all tenants are managed and deployed via a shared construct. This differentiates SaaS from a managed service model where customers might be running separate versions of your product with separate onboarding, management, and operational experiences."

**AWS SaaS Lens — Pool:**
> "The **pool model** of SaaS refers to a scenario where tenants share resources. This is the more classic notion of multi-tenancy where tenants rely on shared, scalable infrastructure to achieve economies of scale, manageability, agility, and so on. These shared resources can apply to some or all of the elements of your SaaS architecture, including compute, storage, messaging, etc."

**AWS SaaS Lens — Bridge:**
> "The final pattern is the **bridge model**. _Bridge_ is meant to acknowledge the reality that SaaS businesses aren't always exclusively silo or pool. Instead, many systems have a mixed mode where some of the system is implemented in a silo model and some is in a pooled model."

> "For example, some microservices in your architecture might be implemented with silo and others might use pool. The regulatory profile of a service's data and its noisy neighbor attributes might steer a microservice to a silo model. Meanwhile the agility, access patterns, and cost profile of another microservice could tip it toward a pool model."

**Microsoft Azure SQL — terminology and choice criteria:**
> "A tenancy model determines how each tenant's data is mapped to storage. Your choice of tenancy model impacts application design and management. Switching to a different model later is sometimes costly."

> "*Single-tenancy:* Each database stores data from only one tenant. *Multi-tenancy:* Each database stores data from multiple separate tenants (with mechanisms to protect data privacy). Hybrid tenancy models are also available."

> Choice criteria enumerated: scalability (number of tenants, storage per-tenant, aggregate, workload); tenant isolation (data isolation and performance — whether one tenant's workload impacts others); per-tenant cost; development complexity (schema and query changes); operational complexity (monitoring, schema management, restoring a tenant, disaster recovery); customizability.

**Microsoft — three patterns, comparison table verbatim:**

| Measurement | Standalone app | Database-per-tenant | Sharded multitenant |
| --- | --- | --- | --- |
| Scale | Medium *(1-100 s)* | High *(1-100,000 s)* | Unlimited *(1-1,000,000s)* |
| Tenant isolation | High | High | Low; except for any single tenant (that is alone in an MT database). |
| Database cost per tenant | High; is sized for peaks. | Low; pools used. | Lowest, for small tenants in MT databases. |
| Development complexity | Low | Low | Medium; due to sharding. |
| Operational complexity | Low-High. Individually simple, complex at scale. | Low-Medium. Patterns address complexity at scale. | Low-High. Individual tenant management is complex. |

> "A multitenant database necessarily sacrifices tenant isolation. The data of multiple tenants is stored together in one database. During development, ensure that queries never expose data from more than one tenant. SQL Database supports row-level security, which can enforce that data returned from a query be scoped to a single tenant."

**DDIA (Kleppmann), 2nd edition — topical (verbatim limited by copyright):** Chapter on Sharding (Partitioning) explicitly covers "Sharding for Multitenancy" as a named subsection alongside "Sharding by Key Range" and "Sharding by Hash of Key." The pattern matches the Azure trichotomy: single DB → DB-per-tenant → sharded multi-tenant. Topical confirmation only — re-verify against the printed text before any binding citation.

---

### Topic B — RLS policy patterns

**PostgreSQL official — default behavior:**
> "By default, tables do not have any policies, so that if a user has access privileges to a table according to the SQL privilege system, all rows within it are equally available for querying or updating."

**PostgreSQL official — default-deny on enable:**
> "When row security is enabled on a table (with ALTER TABLE ... ENABLE ROW LEVEL SECURITY), all normal access to the table for selecting rows or modifying rows must be allowed by a row security policy. (However, the table's owner is typically not subject to row security policies.) If no policy exists for the table, a default-deny policy is used, meaning that no rows are visible or can be modified."

**PostgreSQL official — bypass attributes:**
> "Superusers and roles with the `BYPASSRLS` attribute always bypass the row security system when accessing a table. Table owners normally bypass row security as well, though a table owner can choose to be subject to row security with ALTER TABLE ... FORCE ROW LEVEL SECURITY."

**PostgreSQL official — USING vs WITH CHECK:**
> "Separate expressions may be specified to provide independent control over the rows which are visible and the rows which are allowed to be modified."

> "The policy above implicitly provides a `WITH CHECK` clause identical to its `USING` clause, so that the constraint applies both to rows selected by a command (so a manager cannot `SELECT`, `UPDATE`, or `DELETE` existing rows belonging to a different manager) and to rows modified by a command (so rows belonging to a different manager cannot be created via `INSERT` or `UPDATE`)."

**PostgreSQL official — permissive vs restrictive combinator:**
> "When multiple policies apply to a given query, they are combined using either `OR` (for permissive policies, which are the default) or using `AND` (for restrictive policies)."

**PostgreSQL official — in-row policy expressions:**
> "In the examples above, the policy expressions consider only the current values in the row to be accessed or updated. This is the simplest and best-performing case; when possible, it's best to design row security applications to work this way."

**PostgreSQL official — race condition warning on cross-table policies:**
> "If it is necessary to consult other rows or other tables to make a policy decision, that can be accomplished using sub-`SELECT`s, or functions that contain `SELECT`s, in the policy expressions. Be aware however that such accesses can create race conditions that could allow information leakage if care is not taken."

**PostgreSQL official — referential integrity bypass:**
> "Referential integrity checks, such as unique or primary key constraints and foreign key references, always bypass row security to ensure that data integrity is maintained."

**Supabase — policies are implicit WHERE:**
> "You can just think of them as adding a `WHERE` clause to every query."

**Supabase — auth metadata split:**
> "`raw_user_meta_data` — can be updated by the authenticated user… It is not a good place to store authorization data. `raw_app_meta_data` — cannot be updated by the user, so it's a good place to store authorization data."

**Supabase — JWT freshness caveat:**
> "Keep in mind that a JWT is not always 'fresh'… that will not be reflected using `auth.jwt()` until the user's JWT is refreshed."

**Supabase — explicit auth check:**
> "To avoid confusion and make your intention clear, we recommend explicitly checking for authentication: `USING (auth.uid() IS NOT NULL AND auth.uid() = user_id)`"

**Supabase — UPDATE requires SELECT policy:**
> "To perform an `UPDATE` operation, a corresponding SELECT policy is required. Without a `SELECT` policy, the `UPDATE` operation will not work as expected."

**AWS Database Blog — multi-tenant RLS pattern (via WebSearch synthesis):** The recommended approach uses (a) a dedicated application user that does not own the tables (since table owners bypass RLS by default), or (b) a single database user with policies that read a runtime parameter (`current_setting()`) holding the current tenant context, set per-session via `set_config()` or `SET`. `FORCE ROW LEVEL SECURITY` is required if the application user is also the table owner — without it, RLS is silently bypassed.

---

### Topic C — RLS performance / index strategy

**Supabase — index policy columns (verbatim with code):**
> "Make sure you've added indexes on any columns used within the Policies which are not already indexed (or primary keys)."

```sql
-- BEFORE: no index
create policy "rls_test_select" on test_table
to authenticated
using ( (select auth.uid()) = user_id );

-- AFTER: user_id indexed
create index userid on test_table using btree (user_id);
```
**Reported result:** 99.94% improvement (171ms → <0.1ms).

**Supabase — wrap auth functions in SELECT (initPlan caching):**
> "Wrapping the function causes an `initPlan` to be run by the Postgres optimizer, which allows it to 'cache' the results per-statement, rather than calling the function on each row."

```sql
-- BEFORE
using ( auth.uid() = user_id );
-- AFTER
using ( (select auth.uid()) = user_id );
```
**Reported result:** 94.97% improvement (179ms → 9ms).

**Supabase — security definer for cross-table joins:**
> "A 'security definer' function runs using the same role that _created_ the function… that function will have `bypassrls` privileges."
**Reported result:** 99.993% improvement (178,000ms → 12ms).

**Supabase — security definer placement rule:**
> "Security-definer functions should never be created in a schema in the 'Exposed schemas' inside your API settings."

**Supabase — minimize joins, rewrite to use IN with reverse lookup:**
```sql
-- BEFORE: joins to source table
using (
  (select auth.uid()) in (
    select user_id from team_user
    where team_user.team_id = team_id
  )
);
-- AFTER: no join
using (
  team_id in (
    select team_id from team_user
    where user_id = (select auth.uid())
  )
);
```
**Reported result:** 99.78% improvement (9,000ms → 20ms).

**Supabase — always filter:**
> "Policies are 'implicit where clauses,' so it's common to run `select` statements without any filters. This is a bad pattern for performance."

**Supabase community pitfalls (discussion #14576):**
> "queries that look at every row in a table like for many select operations and updates" can be heavily impacted by RLS.
> "Add a filter in addition to the RLS" rather than relying exclusively on policies.
> "Never just use RLS involving auth.uid() or auth.jwt() as your way to rule out 'anon' role."

---

### Topic D — Migration safety + rollback (online migration tools)

**gh-ost (GitHub):**
> "`gh-ost` is a triggerless online schema migration solution for MySQL. It is testable and provides pausability, dynamic control/reconfiguration, auditing, and many operational perks."

> "`gh-ost` produces a light workload on the master throughout the migration, decoupled from the existing workload on the migrated table."

> "they create a _ghost_ table in the likeness of your original table, migrate that table while empty, slowly and incrementally copy data from your original table to the _ghost_ table, meanwhile propagating ongoing changes (any `INSERT`, `DELETE`, `UPDATE` applied to your table) to the _ghost_ table."

> "`gh-ost` differs from all existing tools by not using triggers… [it] uses the binary log stream to capture table changes, and asynchronously applies them onto the _ghost_ table."

> "True pause: when `gh-ost` throttles, it truly ceases writes on master."
> "Control over cut-over phase: `gh-ost` can be instructed to postpone what is probably the most critical step."

**pt-online-schema-change (Percona, via WebSearch synthesis of canonical docs):**
- Trigger-based design: tool creates AFTER INSERT/UPDATE/DELETE triggers on the original table to copy changes to the new table during the row-by-row backfill.
- Foreign-key handling has two strategies, `rebuild_constraints` and `drop_swap`:
> "Foreign keys complicate the tool's operation and introduce additional risk, as the technique of atomically renaming the original and new tables does not work when foreign keys refer to the table."
- Rollback risk:
> "In the event of an error during the rename operation, rollback is impossible, as the original table has already been dropped, which can result in data loss or other unintended consequences."

**pgroll (Xata) — expand/contract + virtual schemas:**
> "Zero-downtime migrations (no database locking, no breaking changes)."

> "`pgroll` follows a expand/contract workflow. On migration start, it will perform all the additive changes (create tables, add columns, etc) in the physical schema, without breaking it."

> "When a breaking change is required on a column, it will create a new column in the physical schema, and backfill it from the old column. Also, configure triggers to make sure all writes to the old/new column get propagated to its counterpart during the whole active migration period."

> "pgroll works by creating virtual schemas by using views on top of the physical tables. This allows for performing all the necessary changes needed for a migration without affecting the existing clients."

> "At any point during a migration, it can be rolled back to the previous version. This will remove the new schema and leave the old one as it was before the migration started."

**Cross-tool synthesis:** all three solve the "schema change without downtime" problem with the same skeleton — (1) create shadow/new structure, (2) double-write (via triggers OR binlog OR app-level), (3) backfill, (4) cutover, (5) drop old. Differences are in the double-write mechanism (triggers vs binlog vs view-based) and the rollback envelope (pgroll: rollback any time before complete; pt-osc: irreversible after rename; gh-ost: pausable + cutover-postponable).

---

### Topic E — Data-loss disclosure on irreversible migrations

**PostgreSQL official:** Forward DDL like `DROP COLUMN`, `DROP TABLE`, `ALTER COLUMN ... TYPE` (with cast that loses precision), and any `DELETE` backfill is irreversible at the data layer. The official docs do not prescribe a "data-loss disclosure" agent ritual — that pattern is industry-internal.

**pt-online-schema-change (Percona, via synthesis):**
> "In the event of an error during the rename operation, rollback is impossible, as the original table has already been dropped, which can result in data loss or other unintended consequences."

**pgroll (Xata):**
> "At any point during a migration, it can be rolled back to the previous version."
— this is the explicit counter-example: pgroll's design promises rollback up until completion. The implication for an agent: distinguish "migration is rolled-back-able" from "data change is reversible."

**Industry consensus on data-loss disclosure:** No single canonical source mandates a textual "data-loss disclosure" block in migration files. The closest analogues:
- Rails's `irreversible_migration` exception class (raised when `down` is impossible).
- Liquibase's `<rollback>` element (must be authored explicitly; `<empty/>` permitted to acknowledge irreversibility).
- Knex/Prisma migrations have no built-in disclosure; convention is up to the team.

**Recommendation for PF v2 Database Engineer:** require the migration doc to explicitly state ONE of: (a) "rollback path: <SQL>"; (b) "rollback impossible — irreversible due to: <reason>; data loss scope: <columns/rows>"; (c) "rollback partial — old schema restored, but data in column X is lost." This is PF-internal IP, not SP- or Anthropic-derived; document accordingly.

---

### Topic F — Schema-vs-row vs database-per-tenant trade-offs (synthesized)

| Dimension | DB-per-tenant (silo) | Schema-per-tenant (silo-light) | Shared DB + RLS (pool) |
|---|---|---|---|
| Tenant isolation (data) | Highest — physical | High — namespace + permissions | Lowest — defense rests on RLS correctness |
| Per-tenant cost | Highest (Azure: "sized for peaks") | Medium | Lowest |
| Scale ceiling | Azure: "1–100,000s" | Postgres: ~thousands of schemas before catalog bloat | Azure: "1–1,000,000s" with sharding |
| Schema migration | One run per DB; automatable; per-tenant rollback possible | One DDL per schema; metadata bloat at high N | Single DDL covers all tenants instantly |
| Restore one tenant | Trivial (restore DB) | Moderate (pg_restore filtered) | Hard (logical extract + insert) |
| Noisy neighbor | None | Some (shared connection pool) | Yes — see Azure quote |
| Custom schema per tenant | Easy | Easy | Hard — schema is shared |
| Operational complexity at high N | Tooling-dependent | High | Lowest until you shard |

— synthesis from AWS SaaS Lens (Topic A), Microsoft Azure (Topic A), Postgres RLS docs (Topic B), Supabase (Topics B, C). Hybrid/bridge reconciles the trade-offs by mixing models per tenant tier.

---

## 3. Superpowers-Inheritable Patterns

**Likely none.** SP 5.0.7 ships exactly one agent (`agents/code-reviewer.md`) and zero database-, schema-, RLS-, or migration-related skills. Verified by reading the citation manifest at `docs/research/sp-anthropic-citation-manifest.md` Part 1 — no row in the SP precedent table covers schema, RLS, indexes, or migrations.

**What CAN inherit from SP-via-PF v2:**

| PF v2 / SP convention | Inheritance basis | Where in DB Engineer agent |
|---|---|---|
| Status-token grammar `DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED` | SP `subagent-driven-development/SKILL.md` lines 102–118 | Already present in `agents/database-engineer.md` lines 38–42 |
| Subagent context isolation framing | Anthropic *Create custom subagents* §2.9 of citation manifest | Already cited in agent doc line 10 |
| HARD-GATE markers for non-negotiable rules | SP `brainstorming/SKILL.md` lines 12–14 | NOT present — see Gap G3 |
| Iron Law framing (NO X WITHOUT Y) | SP three-skill convention | NOT present — see Gap G4 |
| Red Flags / rationalization-prevention table | SP `test-driven-development`, `verification-before-completion` | NOT present — see Gap G5 |

Conclusion: domain-specific *content* (RLS, migration, indexes) has no SP analogue. Only the *shape* of the agent prompt (status tokens, Red Flags, Iron Law, HARD-GATE) inherits from SP.

---

## 4. Gaps Against the Current `agents/database-engineer.md`

The current file (50 lines, read 2026-04-29) covers job description, output artifacts, a "Hard rules" section (5 bullets), status tokens, and citations. Comparison against the canonical research:

### G1 — Tenancy-model selection is unaddressed

**Current state:** "Tenant isolation contract — how multi-tenant boundary is enforced; cite `skills/rls-aware-migrations` skill if applicable" (line 26). Assumes RLS-pool model.
**Canonical consensus (3/3 sources — AWS SaaS Lens, Microsoft Azure, DDIA):** the tenancy model is a project-level decision among silo / pool / bridge / hybrid, not a default. Migration cost between models is high (Azure: "Switching to a different model later is sometimes costly").
**Severity:** HIGH. The agent silently assumes pool/RLS but enterprise frameworks treat the model selection as a first-class architectural choice.
**Suggested revision:** require the agent to confirm which model the project's `STACK-PATTERNS.md` declares (silo / pool / bridge / hybrid) and produce model-appropriate output. If the model is not declared, status `NEEDS_CONTEXT` and ask Architect.

### G2 — RLS performance pitfalls are not enumerated

**Current state:** "No speculative indexes" (line 34) and "Performance budget" (line 28) — generic.
**Canonical consensus (3/3 — Supabase docs, Supabase community pitfalls thread, AWS Database Blog):** four named pitfalls with measured fixes:
1. Missing indexes on policy columns (171ms → 0.1ms — 99.94%)
2. Unwrapped auth functions (179ms → 9ms — 94.97%)
3. Cross-table joins inside policies (9000ms → 20ms — 99.78%)
4. Cross-table reads without security-definer (178s → 12ms — 99.993%)
**Severity:** HIGH. These are the four most-cited RLS production failure modes. The DB Engineer is the agent that ships them; the agent prompt currently has no mention.
**Suggested revision:** add a "RLS Performance Checklist" section listing the four patterns + reverse-form (BEFORE/AFTER snippet) so the agent recognizes them when reading or writing policies.

### G3 — `FORCE ROW LEVEL SECURITY` and table-owner bypass not flagged

**Current state:** silent on `BYPASSRLS` and `FORCE ROW LEVEL SECURITY`.
**Canonical consensus (2/2 — PostgreSQL official, AWS Database Blog):** RLS without `FORCE` is silently bypassed by the table owner, which is the most common multi-tenant footgun (AWS recommends a separate non-owning application user OR `FORCE ROW LEVEL SECURITY`).
**Severity:** CRITICAL — this is a security bypass, not a performance issue.
**Suggested revision:** add a HARD-GATE: "Every multi-tenant table must declare ONE of: (a) tables not owned by the application user; (b) `ALTER TABLE ... FORCE ROW LEVEL SECURITY`. Otherwise the migration is rejected."

### G4 — Permissive vs Restrictive policy combinator is not addressed

**Current state:** "exact policy definitions for SELECT/INSERT/UPDATE/DELETE per role" (line 23) — does not distinguish permissive (OR-combined, default) from restrictive (AND-combined).
**Canonical citation (1/1 — PostgreSQL official):** policies combine via OR by default; restrictive (AND) is opt-in. Multi-tenant + role-based combinations frequently want restrictive tenant gate AND permissive role policy on top.
**Severity:** MEDIUM. Can lead to silently over-permissive policies if the agent stacks two permissive policies expecting AND semantics.
**Suggested revision:** require the design doc to state the combinator class for each policy and the rationale.

### G5 — `WITH CHECK` vs `USING` distinction not enforced

**Current state:** "exact policy definitions" (line 23) — no syntactic structure.
**Canonical citation (1/1 — PostgreSQL official):** `USING` filters visibility, `WITH CHECK` filters writes; omitting `WITH CHECK` defaults it to the `USING` clause, which is *usually* what you want — but for INSERT-only policies and policies on writable views, the distinction matters.
**Severity:** MEDIUM. Common cause of "I can SELECT my row but not UPDATE it back" or "I can INSERT a row I can't see."
**Suggested revision:** require the design doc to spell out both `USING` and `WITH CHECK` for every policy (or explicitly state "WITH CHECK = USING").

### G6 — Migration safety pattern is unspecified

**Current state:** "Test in shadow database first" (line 35); "Migrations have rollback paths" (line 33). No expand/contract framing.
**Canonical consensus (3/3 — gh-ost, pt-osc, pgroll):** the canonical online-migration shape is expand → double-write → backfill → cutover → contract. All three tools implement this; differences are in mechanism.
**Severity:** HIGH. Without the shape, the agent will write blocking ALTERs and call it "rollback path forward = old DDL, rollback path back = `DROP COLUMN`."
**Suggested revision:** require the migration doc to declare:
- Phase classification (expand-only / contract / mixed)
- Backfill strategy (none / synchronous batch / async chunk)
- Cutover trigger (deploy-time / feature-flag / observability gate)
- Rollback envelope (any time / pre-cutover only / post-cutover only / irreversible)

### G7 — Irreversibility / data-loss disclosure is implicit

**Current state:** "If rollback is technically impossible (e.g., dropped column with data), the migration doc states so explicitly with the data-loss disclosure" (line 33). Good in principle; missing structured form.
**Canonical:** no industry consensus on the form (Rails: exception; Liquibase: `<rollback><empty/></rollback>`; pgroll: rollback always available pre-finalize). PF needs to pick.
**Severity:** MEDIUM. Already present in spirit; needs structured form.
**Suggested revision:** define a 3-line block the agent must include in any migration that drops a column or table:
```
DATA-LOSS DISCLOSURE
Lost on rollback: <columns/rows/precision>
Estimated row count at rollback time: <approx>
Recovery path if rollback hits prod: <restore from backup / unrecoverable>
```

### G8 — Index-per-query justification is present but lacks the inverse rule

**Current state:** "No speculative indexes. Every index has a named query that justifies it" (line 34) — strong.
**Canonical (Supabase 99.94% benchmark):** the inverse is also true — every column referenced inside a policy MUST have an index unless explicitly justified ("low-cardinality enum used in a tiny table, full scan acceptable").
**Severity:** MEDIUM. Currently the agent could ship an unindexed `tenant_id` column inside a policy and pass its own checklist.
**Suggested revision:** add the inverse rule. "Every column referenced in any RLS policy MUST be indexed unless the design doc justifies otherwise."

### G9 — JWT staleness / `auth.jwt()` freshness window is not flagged

**Current state:** silent.
**Canonical (Supabase official):** "a JWT is not always 'fresh'… that will not be reflected using `auth.jwt()` until the user's JWT is refreshed."
**Severity:** MEDIUM. Affects role-revocation workflows — if an admin revokes a user's role at `t=0`, they may retain RLS access until their JWT expires (default 1h).
**Suggested revision:** flag in the tenant-isolation contract section that role-revocation latency = JWT TTL, and require an out-of-band check (DB-side role read) when the policy must be revocation-instant.

### G10 — Sole-source-of-truth on multi-tenant binary in `auth.users` schema

**Current state:** silent.
**Canonical (Supabase official):** `raw_user_meta_data` user-mutable, `raw_app_meta_data` app-only — security-critical metadata MUST live in `app_meta_data`.
**Severity:** MEDIUM (Supabase-stack-specific, so belongs in `STACK-PATTERNS.template.md` not the universal agent prompt — but the agent should know to check it when the project is on Supabase).
**Suggested revision:** add a stack-conditional check: "if project uses Supabase auth, tenant/role data goes in `raw_app_meta_data`, not `raw_user_meta_data`."

### G11 — Hybrid model (silo for premium tier, pool for free tier) not represented

**Current state:** "If the project is single-tenant, write 'single-tenant — no RLS needed.' If multi-tenant, every table referenced must have an explicit RLS policy" (line 32) — binary, no hybrid.
**Canonical (Microsoft Azure hybrid pattern; AWS bridge model):** real production SaaS routinely mixes — e.g., free trial in a shared multi-tenant DB, premium tier in dedicated DBs.
**Severity:** LOW (most projects start one-mode); MEDIUM (PF v2's enterprise-multi-tenant focus makes hybrid non-rare).
**Suggested revision:** add a tri-state: single / multi / hybrid; if hybrid, the design doc enumerates which tables are silo and which pool.

### G12 — No HARD-GATE / Iron Law / Red Flags framing

**Current state:** the agent uses bullet-list "Hard rules" — same intent as SP HARD-GATE but not in the SP-precedent format.
**Canonical (SP convention):** non-negotiables get `<HARD-GATE>...</HARD-GATE>`; rationalization-prevention gets a Red Flags table.
**Severity:** LOW (cosmetic); MEDIUM (consistency with rest of PF v2 agents).
**Suggested revision:** convert the existing 5 hard rules into one `<HARD-GATE>` block; add a Red Flags table for the four most common excuses ("we'll add the index later," "rollback is just `DROP COLUMN`," "the table owner is the app so RLS is fine," "we'll backfill in prod").

---

## 5. Suggested Revisions to `agents/database-engineer.md`

Concrete revisions, ordered by severity. All have ≥2 canonical citations except where flagged PF-internal.

### R1 (CRITICAL — covers G3) — Add `FORCE ROW LEVEL SECURITY` HARD-GATE

```markdown
<HARD-GATE>
Every multi-tenant table MUST declare exactly one of:
1. `ALTER TABLE … FORCE ROW LEVEL SECURITY;` — required if the table owner is also the runtime application role
2. A non-owning application role — verify the table is owned by a role distinct from the application's connection role; document the owner role explicitly

Migrations that enable RLS without one of these two artifacts are REJECTED.

Citation: PostgreSQL 18 official docs §5.9 — "Table owners normally bypass row security as well, though a table owner can choose to be subject to row security with ALTER TABLE … FORCE ROW LEVEL SECURITY"; AWS Database Blog "Multi-tenant data isolation with PostgreSQL Row Level Security."
</HARD-GATE>
```

### R2 (HIGH — covers G1, G11) — Tenancy-model gate before policy work

Add a new section "Step 0 — Confirm tenancy model" requiring the agent to read the project's STACK-PATTERNS for one of: silo / pool / bridge / hybrid / single-tenant. If undeclared, return `NEEDS_CONTEXT`. (Citation: AWS SaaS Lens silo/pool/bridge; Microsoft Azure SQL multi-tenant patterns.)

### R3 (HIGH — covers G2, G8) — RLS Performance Checklist (4 named patterns)

Add a "RLS Performance Checklist" with the four BEFORE/AFTER snippets (verbatim from §2 Topic C of this research). Every policy review must walk this checklist and flag any unfixed pattern. (Citation: Supabase RLS performance section; community pitfalls discussion #14576.)

### R4 (HIGH — covers G6, G7) — Migration safety phase declaration

Add a required block in the migration doc:
```markdown
## Migration Phase Classification
- Type: [expand-only | contract | mixed]
- Backfill: [none | synchronous-batch | async-chunk]
- Cutover trigger: [deploy-time | feature-flag | observability-gate]
- Rollback envelope: [any-time | pre-cutover-only | post-cutover-only | irreversible]
- Data-loss disclosure (required if rollback envelope is irreversible): [block per G7]
```
(Citation: gh-ost README; pgroll README; pt-online-schema-change docs.)

### R5 (MEDIUM — covers G4, G5) — Policy structural requirements

For every policy, the design doc states:
- Combinator: PERMISSIVE (default OR) | RESTRICTIVE (AND) + rationale
- USING clause: <expr>
- WITH CHECK clause: <expr> | "= USING"
(Citation: PostgreSQL 18 official docs §5.9 — both quotes in §2 Topic B.)

### R6 (MEDIUM — covers G9) — JWT staleness flag in the tenant-isolation contract

If the project uses JWT-based role/tenant claims, the contract section must declare:
- Maximum revocation latency (= JWT TTL)
- If revocation must be instant, a fallback DB-side check is required
(Citation: Supabase RLS guide JWT freshness caveat.)

### R7 (MEDIUM — covers G10) — Stack-conditional auth-metadata source rule

Conditional on Supabase stack: tenant/role data MUST live in `raw_app_meta_data`, not `raw_user_meta_data`. Belongs primarily in `STACK-PATTERNS.template.md`; the agent prompt only references it conditionally. (Citation: Supabase RLS guide auth.jwt section.)

### R8 (LOW — covers G12) — Adopt SP framing conventions

Convert "Hard rules" bullets to a single `<HARD-GATE>` block. Add a Red Flags table with the rationalizations enumerated in G12. (Citation: SP `brainstorming/SKILL.md` lines 12–14; SP three-skill Iron Law convention; PF v2 binding rule per `CLAUDE.md`.)

### R9 (PF-internal — formalize G7) — Data-loss disclosure block schema

3-line structured block (defined verbatim in G7 above). Document as PF-original; no SP precedent and no Anthropic citation — owns honestly under PF v2 binding rule. Closest enterprise analogue is Liquibase's explicit `<rollback><empty/></rollback>`; cite as inspiration not precedent.

---

## 6. Sources

**Direct WebFetch (verbatim):**
- PostgreSQL 18 — Row Security Policies — https://www.postgresql.org/docs/current/ddl-rowsecurity.html
- Supabase — Row Level Security — https://supabase.com/docs/guides/database/postgres/row-level-security
- Supabase — RLS Performance Recommendations — https://supabase.com/docs/guides/database/postgres/row-level-security#rls-performance-recommendations
- Supabase community discussion #14576 — https://github.com/orgs/supabase/discussions/14576
- AWS SaaS Lens — Tenant Isolation — https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/tenant-isolation.html
- AWS SaaS Lens — Silo, Pool, Bridge — https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/silo-pool-and-bridge-models.html
- Microsoft Azure SQL — Multitenant SaaS Patterns — https://learn.microsoft.com/en-us/azure/azure-sql/database/saas-tenancy-app-design-patterns
- gh-ost README — https://github.com/github/gh-ost/blob/master/README.md
- pgroll — https://github.com/xataio/pgroll

**WebSearch synthesis (re-verify before binding):**
- pt-online-schema-change docs — https://docs.percona.com/percona-toolkit/pt-online-schema-change.html
- Percona blog — pt-osc and foreign keys — https://www.percona.com/blog/dont-auto-pt-online-schema-change-for-tables-with-foreign-keys/
- AWS Database Blog — Multi-tenant data isolation with PostgreSQL RLS — https://aws.amazon.com/blogs/database/multi-tenant-data-isolation-with-postgresql-row-level-security/
- DDIA (Kleppmann) 2nd ed — Sharding for Multitenancy — https://dataintensive.net/

**Cross-referenced internal:**
- `c:/Users/atyab/Experimental - Users/production-framework-v2/docs/research/sp-anthropic-citation-manifest.md`
- `c:/Users/atyab/Experimental - Users/production-framework-v2/agents/database-engineer.md`
