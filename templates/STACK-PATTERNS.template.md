# Stack Patterns: {Framework / Language / Runtime}

**This is the ONLY place stack-specific content lives.**

Universal agent prompts in `agents/` and universal skills in `skills/` reference this file by path. Every stack-conditional rule that an agent invokes is enumerated here.

Fork this file to `docs/STACK-PATTERNS.md` and fill in every section for your stack. Sections you do not use, mark `N/A — {reason}`. Do not delete unused sections; the agents grep for headings.

> Stack-specific rules belong here, not in `agents/` or `skills/`. Per CLAUDE.md rejection criterion #3 ("no stack references in core") and the citation discipline of `docs/research/sp-anthropic-citation-manifest.md` GAP-CR-1 / Gap-MT relocations.

---

## Stack Config (slot values)

Fill in your stack's concrete values for the slots referenced by `gate-3-production-check`, `verification-before-completion`, and the agent runbooks:

```yaml
# --- latency budgets (used by Architect quality-attribute matrix, SRE SLO catalog, Builder self-review) ---
query-latency-budget: 100ms          # critical query must stay below this at scale
read-budget: 500ms                   # P95 read latency target (per-route)
write-budget: 1s                     # P95 write latency target (per-route)
bundle-budget: 200KB                 # route bundle size gzipped (web only — N/A for backend-only)

# --- platform primitives (used by Builder, Architect, UX/Design) ---
client-boundary-marker: "{directive}"  # e.g. "use client" for Next.js, "use server" for server actions
lazy-loading-primitive: "{api}"        # e.g. React.lazy(), dynamic import, Suspense
data-access-primitive: "{primitive}"   # e.g. server action, controller, resolver, repository class
runtime-kind: "{kind}"                 # serverless | node | container | edge

# --- observability + perf (used by SRE/DevOps, Debugger) ---
explain-tool: "{tool}"                 # e.g. EXPLAIN ANALYZE for Postgres, db.collection.explain() for Mongo
perf-vitals: "{measurement}"           # e.g. web vitals, custom RUM metric, OpenTelemetry SDK

# --- security (used by Security/Compliance, Code Reviewer) ---
required-security-headers: "{list}"    # CSP, HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy
auth-migration-feature: "{feature}"    # e.g. RLS policy, middleware rule, controller before_action

# --- anti-patterns to grep (used by Code Reviewer, Builder self-review) ---
anti-pattern-refresh: "{call}"         # e.g. router.refresh(), window.location.reload()
anti-pattern-state-mutation: "{call}"  # e.g. direct mutation of nextjs cache without revalidation
```

If your stack is multi-tenant, also fill in the `Multi-Tenant Slot Values` block below.

---

## Multi-Tenant Slot Values

Required if the project is multi-tenant. Used by Builder, Database Engineer, Security/Compliance, SRE/DevOps, UX/Design, Code Reviewer.

```yaml
tenancy-model: "{silo|pool|bridge|hybrid}"  # AWS SaaS Lens classification — declare per resource if hybrid
tenant-id-source: "{source}"                 # authenticated session claim (e.g., JWT app_metadata.tenant_id) — NEVER request body or unsigned header
tenant-context-primitive: "{primitive}"      # how tenant context is bound at the data layer (e.g., RLS policy, scope filter, namespaced cache key)
tenant-context-scope-directive: "{directive}" # session-scope directive that prevents context leak across pooled connections (e.g., SET LOCAL not SET, per-request bind, per-job bind)
admin-bypass-key: "{key}"                    # the privileged key/role that bypasses tenant isolation (e.g., service_role, admin client) — must NEVER appear in client-reachable code
cache-key-prefix: "{template}"               # template for tenant-prefixed cache keys, e.g., tenant:{tenant_id}:{resource}:{id}
audit-log-fields: "{list}"                   # mandatory fields on every audit log row, must include actor_id, tenant_id, action, target, timestamp
```

---

## Project-Specific Tier 3 Triggers

Extend the universal trigger list from `skills/tier-selection/SKILL.md` with triggers specific to this stack:

```yaml
tier_3_triggers:
  project_specific:
    # - rls_policy_change          # any ALTER POLICY, CREATE POLICY, DROP POLICY
    # - server_action_added        # net-new mutation surface
    # - middleware_auth_change     # any change to request-pipeline auth checks
    # - tenant_id_columns_change   # adding/removing tenant_id from a table
    # - cache_key_template_change  # any change to cache namespacing
    # Add triggers from your project's incident table (Open Findings)
```

---

## Code-Review Pre-Flight Greps (Multi-Tenant)

Run these before any review of a diff that touches data access, API surface, or cache layer. Each row maps to a finding the Code Reviewer raises if matched.

> Sourced from Code-Reviewer research GAP-CR-1 (`docs/research/agent-design-code-reviewer.md` lines 189–204), citing OWASP Multi-Tenant Cheat Sheet + PostgreSQL §5.9 + Supabase RLS guide.

| # | Pattern (grep) | Severity | Why it's wrong |
|---|---|---|---|
| 1 | New table created without RLS policy or equivalent enforcement | Critical | OWASP MT cheat sheet — "include tenant identifiers in every data table"; data-layer enforcement is defense-in-depth against application-layer bugs. |
| 2 | `SELECT` / `UPDATE` / `DELETE` against a tenant-scoped table without `WHERE tenant_id = ?` (or RLS coverage) | Critical | "A query that forgets `WHERE org_id = ?` does not throw an error — it returns data, just the wrong tenant's data." Silent failure mode. |
| 3 | `tenantId` / `org_id` / `workspace_id` read from request body, query string, or unsigned header instead of authenticated session | Critical | OWASP MT cheat sheet — "do not trust tenant IDs from client headers or request parameters." Client-supplied tenant IDs enable IDOR/BOLA. |
| 4 | Use of `service_role` / admin-bypass key in client-reachable code (frontend bundle, public route, browser-shipped env var) | Critical | "Never expose the service_role key on the client side." Single leak voids all RLS. |
| 5 | `SET app.tenant_id` instead of `SET LOCAL app.tenant_id` (or stack-equivalent session-vs-transaction directive) | Critical | "Never use SET instead of SET LOCAL — SET persists across the session, and with connection pooling, the previous tenant's context leaks to the next request." |
| 6 | Background job / queue handler / cron runner that doesn't propagate tenant context at the job boundary | Important | "Tenant isolation requires walls in… job boundary." Async work runs outside the request context that established tenancy. |
| 7 | Cache write or read without tenant-prefixed key (e.g., `cache.set(userId, ...)` instead of `cache.set("tenant:" + tenantId + ":" + userId, ...)`) | Critical | OWASP MT cheat sheet — "include tenant_id in all resource queries, **cache keys**, and storage paths." Silent cross-tenant data return. |

**Stack-specific extensions** (5 patterns from `docs/research/skill-design-stack-patterns-extensions-2026-04-30.md`):

### Next.js / React (per Wave 3 P1, P2, P3)

**P1 — Client/server boundary** (CRITICAL — 3x recurrence in PF v1; auto-ratifiable BP under Path A):

- **NR-1:** File transitively imports `next/cache`, `next/server`, `@/lib/supabase/admin`, `@/lib/sentry/server`, OR any module declaring `import "server-only"` — AND the file does NOT itself declare `import "server-only"` AND has ≥1 named export consumed from a client component. **Stop-the-review condition.**
- **Canonical fix:** split into a separate file with no transitive server-only imports; OR add `import "server-only"` and refactor consumers to server-only paths.
- **Cited:** Next.js `"use client"` / `"use server"` directives (https://nextjs.org/docs/app/building-your-application/rendering); Vercel "Avoid leaking server-side dependencies"; `import "server-only"` package (https://www.npmjs.com/package/server-only); React Server Components docs.
- **Detected by:** Code-Reviewer pre-flight grep + Builder hard rule.

**P2 — React state-setter closure-flag** (CRITICAL — 7/7 BINDING enterprise via react-mentions + GitHub `text-expander-element`; first Path-B candidate per ADR-003):

- **Grep:** `let \w+ = false;\s*set\w+\(prev\s*=>` or analogous `let inserted = false; setX(prev => { ... inserted = true; ...}); if (inserted) ...`
- **Why:** React state-setter updaters run ASYNCHRONOUSLY. `if (inserted)` always reads `false` on the next line. PF v1 audit Item 11 shipped this exact pattern; pagination footer drift in prod.
- **Canonical fix:** compute the decision SYNCHRONOUSLY via `useRef` of current state (per react-mentions `queryInfo` pattern); OR move dependent state into the same updater.
- **Cited:** react.dev hooks reference (https://react.dev/reference/react); React state-update batching docs; GitHub `text-expander-element`; `react-mentions`.
- **Detected by:** QA Stage 2 stack-conditional reasoning hook (per `agents/qa.md` post-2026-04-30 amendment).

**P3 — Console-errors-clean per route** (HIGH — pairs with `gate-3-production-check` D19):

- **Check:** Playwright `browser_console_messages` empty on every route touched by ship. Pre-existing errors filed as separate findings, not absorbed silently.
- **Why:** PF v1 audit Item 12 — React #418/#419 visible across many ship cycles, never caught because each cycle audited only its own changes.
- **Canonical fix:** suppression-by-fix, not suppression-by-filter. Hydration mismatches (#418/#419) are ship-blockers.
- **Cited:** Cypress `fail-on-console-error`; react.dev errors #418/#419 (https://react.dev/errors/418); Web Vitals (https://web.dev/vitals/) on hydration impact; Sentry React error capture; Vercel observability docs.
- **Detected by:** `browser-driven-verification` skill + gate-3 D19 (no deterministic grep — Playwright execution is sole enforcement).

### Postgres + Supabase (extension to row #4 of Code-Review Pre-Flight Greps + Wave 3 P4)

**P4 — Service-role / RLS bypass** (CRITICAL — extends row #4):

- `CREATE TABLE` without subsequent `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` AND `... FORCE ROW LEVEL SECURITY`
- `auth.users.raw_user_meta_data` referenced for authorization decisions (user-mutable; use `raw_app_meta_data`)
- Policy without `auth.uid() IS NOT NULL` guard alongside `auth.uid() = user_id`
- `auth.jwt()` called without wrapping `(SELECT auth.jwt())` for initPlan caching (Supabase 94.97% measured improvement)
- `CREATE POLICY` referencing function not marked `SECURITY DEFINER` for cross-table joins (Supabase 99.993% measured improvement)
- Service-role client used in code paths gated by RLS without explicit `p_user_id` parameter and visibility check inside the RPC
- **Cited:** PostgreSQL §5.9; Supabase RLS guide service-role section; OWASP IDOR/BOLA; AWS SaaS Lens cross-tenant access.
- **Detected by:** Architect Multi-tenant isolation table client-shape column (per `agents/architect.md` post-2026-04-30 amendment) + 7VQ Q3 client-shape requirement; arch-doc-time gate (no deterministic grep).

### Cross-stack environment / secrets (per Wave 3 P5)

**P5 — Env separation** (LOW):

- Same secret value across `.env`, `.env.local`, `.env.production` (cross-environment duplication masks dev leaks as prod leaks).
- **Canonical fix:** distinct values per environment; secrets manager for prod (HashiCorp Vault / Doppler / Infisical); `.env.example` with placeholders only.
- **Cited:** 12-Factor App III (Config); HashiCorp Vault env separation; GitHub Secrets best practices; Doppler/Infisical docs; OWASP secrets management cheatsheet.
- **Detected by:** Code-Reviewer pre-flight grep on `.env*` files.

### Rails / ActiveRecord (project-fill stub)

<!-- EXAMPLE — fill in if Rails project -->
<!-- - `Model.find(params[:id])` without `current_tenant.scope` chain -->
<!-- - `default_scope` for tenancy (anti-pattern — silently breaks bulk queries; use explicit scope) -->

### MongoDB (project-fill stub)

<!-- EXAMPLE — fill in if Mongo project -->
<!-- - `db.collection.find({})` without `tenantId` filter -->
<!-- - Schema documents without `tenantId` indexed field -->

> **Note on auto-ratification:** Pattern 1 (Next.js boundary) at 3x recurrence is the first **auto-ratifiable BP** under `proposing-patterns` Path A. Pattern 2 (React state-setter) at 7/7 BINDING enterprise is the first auto-ratifiable BP under `proposing-patterns` Path B (per ADR-003 dual-path ingest). Both should be routed through `proposing-patterns` → `ratify-pattern` for the project's pattern registry.

<!-- ## MongoDB -->
<!-- - `db.collection.find({})` without `tenantId` filter -->
<!-- - Schema documents without `tenantId` indexed field -->

---

## Database Engineer — Stack-Conditional Rules

Fill in only the subsections that match your stack. Each rule cites the canonical source.

### Postgres + RLS

> Sourced from `docs/research/agent-design-database-engineer.md` Topics A–C (PostgreSQL §5.9, Supabase RLS guide, Supabase RLS perf section).

- **FORCE ROW LEVEL SECURITY is mandatory on every tenant-scoped table.** "Table owners normally bypass row security as well, though a table owner can choose to be subject to row security with `ALTER TABLE ... FORCE ROW LEVEL SECURITY`." (PostgreSQL §5.9.) Without FORCE, the migration runner (typically the table owner) bypasses every policy.
- **Auth metadata split.** Authorization data lives in `auth.users.raw_app_meta_data` only. `raw_user_meta_data` is user-mutable. (Supabase auth guide.)
- **`USING` vs `WITH CHECK`.** `USING` filters rows visible/affectable by SELECT/UPDATE/DELETE; `WITH CHECK` validates rows being inserted or updated. Both required on UPDATE policies for correct read-write semantics.
- **UPDATE requires SELECT policy.** "To perform an `UPDATE` operation, a corresponding SELECT policy is required." (Supabase RLS guide.)
- **Index every column referenced in a policy.** Supabase reported 99.94% improvement (171ms → <0.1ms) after indexing `user_id` referenced in `USING (user_id = auth.uid())`.
- **Wrap `auth.*()` functions in `(SELECT ...)` for initPlan caching.** "Wrapping the function causes an `initPlan` to be run by the Postgres optimizer, which allows it to 'cache' the results per-statement, rather than calling the function on each row." Reported 94.97% improvement (179ms → 9ms).
- **Use SECURITY DEFINER functions for cross-table policy joins.** Reported 99.993% improvement (178s → 12ms) by wrapping cross-table tenancy lookups in a SECURITY DEFINER function.
- **JWT freshness caveat.** "Keep in mind that a JWT is not always 'fresh'… that will not be reflected using `auth.jwt()` until the user's JWT is refreshed." Auth/role changes require sign-out or token refresh to take effect.
- **Migration phase pattern.** Schema changes follow expand → double-write → backfill → cutover → contract. Tools: gh-ost (MySQL), pgRoll (Postgres), pt-osc (Percona). Single-step destructive migrations are an Anti-Pattern.

### Rails / ActiveRecord

<!-- EXAMPLE — fill in if applicable -->
<!-- - Tenant scoping via explicit `current_tenant.posts.find(...)` — never `default_scope`. -->
<!-- - `acts_as_tenant` gem if used: must be enforced in every controller via `before_action :set_current_tenant`. -->

### MongoDB

<!-- EXAMPLE — fill in if applicable -->
<!-- - Compound index on `{ tenantId: 1, <other>: 1 }` for every query path. -->
<!-- - Mongoose plugin or middleware that injects `tenantId` filter at the query level. -->

---

## Builder — Stack-Specific Hard Rules

Per Gap-MT (`docs/research/agent-design-builder.md` lines 552–563), the Builder agent treats this section as the authoritative source of stack-specific Hard Rules. Builder reads `agents/builder.md`'s "Honor every safety rule in `templates/STACK-PATTERNS.md` as Hard Rules" line and applies the rules below.

### Multi-tenant Hard Rules

**Iron Law:** Every query, every API endpoint, every cache key, every job handler MUST honor tenant scope. If the plan does not specify it for a touch point, return `NEEDS_CONTEXT`.

Concrete rules — every Builder must satisfy these on every changed file:

1. **Data access:** Use the `tenant-context-primitive` declared in Stack Config. Never reach a tenant-scoped table without it.
2. **Tenant ID source:** Read tenant_id from `tenant-id-source` only. Never from request body, query string, or unsigned header.
3. **Cache keys:** Use the `cache-key-prefix` template. A cache key without `{tenant_id}` is a bug.
4. **Session directives:** Use `tenant-context-scope-directive` (e.g., `SET LOCAL`). Session-persistent directives are forbidden.
5. **Admin bypass:** The `admin-bypass-key` MUST NOT appear in any code path reachable from the client (frontend bundle, public route, browser-shipped env var). Server-only paths must be auditable.
6. **Job boundary:** Every queued job, cron, webhook handler propagates tenant context explicitly via constructor or first-line bind.
7. **Audit logging:** Every state-changing operation writes a row with the `audit-log-fields` shape.

### Stack-specific verification commands

```yaml
# Builder runs these before reporting DONE — never run unrelated diagnostic commands.
lint:        "{command}"   # e.g. eslint, rubocop, ruff
typecheck:   "{command}"   # e.g. tsc --noEmit, mypy, sorbet
test:        "{command}"   # e.g. vitest, pytest, rspec, jest
build:       "{command}"   # e.g. next build, rails assets:precompile
```

---

## UX/Design — Multi-Tenant Per-Flow Checklist

Every user-facing flow must explicitly specify all 7 items below. Source: `docs/research/agent-design-ux-design.md` lines 147–156. Patterns drawn from Slack, Notion, Linear chrome conventions.

1. **Persistent tenant indicator** — visible at all times in chrome (header / sidebar). "Slack, Notion, Linear all enforce this."
2. **Tenant switcher with cache-invalidation behaviour** — switching MUST visually reset state; no leakage of tenant-A list rows into tenant-B view.
3. **Role badge in tenant context** — same user can be Admin in tenant-A, Member in tenant-B; UI surfaces current role next to tenant label.
4. **Role-gated UI** — actions the current role can't perform are hidden or disabled-with-tooltip; never shown-then-403.
5. **Cross-tenant deep-link handling** — when a deep-link points to data in another tenant the user *also* belongs to, offer a "Switch to {tenant} to view this" recovery; if user has no access, give a clean 404-style page (no tenant existence leak).
6. **Tenant-scoped notifications/realtime** — design specifies what happens to subscriptions on tenant switch (unsubscribe + resubscribe).
7. **Role-switch (impersonation) indicator** — if the product supports support-impersonation, banner is mandatory and persistent during the session.

WCAG 2.2 success-criterion floor (also enforced per design):

- **2.4.7 Focus Visible** — every interactive control has a visible focus indicator
- **2.4.11 Focus Not Obscured (Min)** — focused elements are not hidden behind sticky headers/footers
- **2.5.8 Target Size (Min)** — interactive targets ≥ 24×24 CSS pixels
- **3.3.8 Accessible Authentication** — no cognitive function tests in auth flows
- **1.4.3 Contrast (Min)** — text contrast 4.5:1 (normal) / 3:1 (large)
- **1.4.11 Non-text Contrast** — UI components and graphics 3:1 against adjacent colors

---

## Security / Compliance — Per-Stack Control Mappings

Source: `docs/research/agent-design-security-compliance.md`. Every Security/Compliance finding cites a control ID from one of the standards below. Map your stack's primitives to control IDs here so findings are auditable.

### Standards in scope (declare which apply)

```yaml
standards:
  applicable:
    # - NIST_800-53_Rev5
    # - OWASP_ASVS_v4
    # - OWASP_API_Top10_2023
    # - SOC2_TSC_2017
    # - GDPR
    # - CCPA
    # - HIPAA
    # - PCI_DSS_v4
```

### Multi-tenant control map

| Concern | NIST 800-53 | OWASP ASVS v4 | SOC 2 TSC | OWASP API 2023 | Stack-specific check |
|---|---|---|---|---|---|
| Cross-tenant access prevention | AC-3 (Access Enforcement), SC-4 (Information in Shared Resources) | V4.1.1, V4.2.1, V8 (proposed multi-tenant req in v5 / issue #2060) | CC6.1 | API1:2023 (BOLA), API3:2023 (BOPLA) | `{your data-layer enforcement, e.g., RLS policy presence}` |
| Cache isolation | SC-4 | V8 | CC6.1 | API1:2023 | `{cache-key-prefix}` enforcement check |
| Audit log integrity | AU-2 (Event Logging), AU-3 (Content of Audit Records), AU-11 (Audit Record Retention) | V7.1.1, V7.1.2, V7.1.3 | CC7.2 | — | Append-only log table; immutable trail |
| No PII in logs | SI-11 (Error Handling), SI-12 (Information Management and Retention) | V7.1.1 (no sensitive data in logs), V7.1.2 | CC6.7 | — | grep audit log writers for PII shape |
| Authentication freshness | IA-5 | V2 | CC6.1 | API2:2023 (Broken Authentication) | Token/session refresh on auth state change |
| Right to erasure | — | — | — | — | GDPR Art.17, CCPA §1798.105 — implement deletion path with cascade rules per data model |

### Per-stack security primitives

<!-- EXAMPLE — replace with your stack values -->
<!-- ## Supabase + Postgres -->
<!-- - RLS as the AC-3 / V4.1.1 enforcement primitive -->
<!-- - `raw_app_meta_data` for authorization claims (V8.3 — user-mutable claims forbidden) -->
<!-- - Edge function service_role usage audited per AC-3 / V4.1.1 -->

<!-- ## Rails + Devise/Pundit -->
<!-- - Pundit policies as AC-3 enforcement -->
<!-- - `current_user.tenant` scoping as V4.2.1 enforcement -->

---

## SRE/DevOps — Stack-Conditional Observability + Deploy

Source: `docs/research/agent-design-sre-devops.md`. The agent's universal rules (burn-rate alerts, runbook-per-alert, SLO catalog, blast-radius) are in `agents/sre-devops.md`. Stack-conditional rules:

### Tenant-scoped observability (mandatory if multi-tenant)

Per Honeycomb high-cardinality / wide-events principle:

- **Every log line, trace span, and metric label MUST include `tenant_id` as a field.** Pre-aggregated tenant-blind metrics (Prometheus-style without tenant_id label) are rejected.
- **Wide structured events preferred over the metrics/logs/traces silos.** Cite Honeycomb *OpenTelemetry Is Not Three Pillars* if the project resists.
- **Cardinality budgets:** Declare per-metric cardinality limits. `tenant_id × user_id × route` cardinality scales fast — use sampling or aggregation policies, not pre-aggregation that drops the dimension.

### Stack-specific deploy primitives

```yaml
deploy-strategy: "{strategy}"          # blue-green | canary | rolling
rollback-mechanism: "{mechanism}"      # one-click rollback URL or command — required, not optional
canary-traffic-percent: "{percent}"    # e.g. 5% for 30 minutes before full rollout
slo-error-budget-policy: "{policy}"    # e.g. burn-rate alerts at 14.4× / 6× / 1× per Workbook Ch. 5
runbook-template-path: "{path}"        # e.g. docs/runbook/<feature>.md — every alert points to a runbook
```

### Stack-specific observability tooling

<!-- EXAMPLE — replace with your stack values -->
<!-- ## Cloud + tooling -->
<!-- - Tracing: OpenTelemetry SDK + {Honeycomb | Datadog | Tempo} -->
<!-- - Metrics: {Prometheus | Datadog | CloudWatch} with tenant_id label budget per metric -->
<!-- - Logs: structured JSON, {Loki | Datadog | CloudWatch}, tenant_id field always present -->
<!-- - Errors: {Sentry | Bugsnag} with tenant_id tag -->

---

## Project Patterns Registry (BP / AP / PP)

Use bare `AP-N / BP-N / PP-N` IDs (numbered independently from other projects). Patterns are derived from this project's incident history — every row corresponds to a Post-Mortem-recorded incident.

### Quick Reference

| ID | Category | Rule | Check |
|---|---|---|---|
| AP-N | Architecture | ... | ... |
| BP-N | Bug | ... | grep: ... |
| PP-N | Performance | ... | ... |

### Full Pattern Detail

Format: every pattern row carries an `Incident` column. Patterns without incidents are cargo-cult — reject during ratification.

| ID | Category | Rule | Why | Check | Incident |
|---|---|---|---|---|---|
| AP-N | Architecture | ... | ... | ... | ... |
| BP-N | Bug | ... | ... | grep: ... | ... |
| PP-N | Performance | ... | ... | ... | ... |

---

## Stack-Specific Anti-Patterns

List anti-patterns unique to this stack. Format: pattern → why it's wrong → correct alternative.

<!-- EXAMPLE — replace with your stack's anti-patterns -->
<!-- | Anti-pattern | Correct alternative | Why | -->
<!-- | `raw_connection_per_request` | Use connection pool | Exhausts DB limits under load | -->
<!-- | `client_side_secret_access` | Server-side only via env vars | Client bundles are public | -->
<!-- | `sync_external_call_in_render` | useEffect + loading state | Blocks render thread | -->
<!-- | `default_scope :tenant_id` (Rails) | Explicit `current_tenant.scope.find` | default_scope silently breaks bulk queries and is invisible at call sites | -->
<!-- | `auth.jwt()` per-row in policy (Postgres) | `(SELECT auth.jwt())` wrapped for initPlan caching | 94.97% latency improvement reported by Supabase | -->

---

## Stack-Specific Pattern Detail

Full `Rule | Why | Check | Incident` for each project pattern. Populate from your Post-Mortem incident table (`docs/PROJECT-PLAN.md` Incident Table column).

---

## Citations

- Multi-tenant grep patterns: `docs/research/agent-design-code-reviewer.md` GAP-CR-1, citing OWASP Multi-Tenant Cheat Sheet + PostgreSQL §5.9 + Supabase RLS guide
- UX 7-item checklist: `docs/research/agent-design-ux-design.md` lines 147–156, citing NN/g, Morville's IA pillars, WCAG 2.2 SCs
- Builder Hard Rules relocation: `docs/research/agent-design-builder.md` Gap-MT (lines 552–563)
- Database Engineer RLS specifics: `docs/research/agent-design-database-engineer.md` Topics A–C (PostgreSQL §5.9, Supabase RLS guide + perf section, Supabase community discussion)
- Security/Compliance control IDs: `docs/research/agent-design-security-compliance.md` (NIST 800-53 Rev5, OWASP ASVS v4, OWASP API 2023, SOC 2 TSC)
- SRE/DevOps tenant-scoped observability: `docs/research/agent-design-sre-devops.md` G8 (Honeycomb high-cardinality / wide-events)
- Project Patterns Registry shape: PF v1 `templates/STACK-PATTERNS.template.md` precedent
