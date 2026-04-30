---
name: tenant-isolation
description: "Use when designing tenant boundaries OR auditing existing boundaries — prescribes the silo / pool / bridge model classification per AWS SaaS Lens, names the client shape that activates the model, and walks the data-layer + cache + log + job-boundary checklist. Composes with architect (Multi-tenant isolation table) and security-compliance (control IDs)."
---

## Overview

Multi-tenant isolation has 4 separate enforcement layers that must each be wired correctly:

1. **Data layer** (RLS / scope filter / namespaced storage)
2. **Cache layer** (tenant-prefixed keys per OWASP Multi-Tenant Cheat Sheet)
3. **Log / observability layer** (every event tagged `tenant_id` per Honeycomb high-cardinality)
4. **Job boundary** (every queued job / cron / webhook propagates tenant context per OWASP MT)

PF v1 audit Item 9 G-CRIT-1 documents the failure when one layer is misclassified: arch doc said `SECURITY INVOKER` (RLS applies), implementation used `supabaseAdmin` (RLS bypassed). Same surface, different client shape, different security posture.

**Enterprise grounding:** AWS SaaS Lens silo / pool / bridge models (canonical), PostgreSQL §5.9 RLS, OWASP API1:2023 BOLA + Multi-Tenant Cheat Sheet, NIST AC-3 + SC-4, Supabase RLS guide.

## When to Use

- Designing a new feature that introduces tenant-scoped data or surface.
- Auditing an existing feature for tenant-isolation gaps (Security/Compliance review).
- Filling the `agents/architect.md` Multi-tenant isolation table for a new design.
- Filling `agents/security-compliance.md` cross-tenant control map for a new feature.

Do NOT use:
- Single-tenant projects — declare `tenancy-model: single-tenant` in STACK-PATTERNS.md and waive.

## Core Pattern

You MUST create a TodoWrite item per step.

### Step 1 — Choose isolation model per resource (AWS SaaS Lens)

For every shared resource the design touches:

- **Silo** — fully independent infrastructure stack OR separate database per tenant. Highest isolation, highest cost. Use for compliance-bound tenants.
- **Pool** — shared infrastructure with policy-enforced isolation (RLS, scope filter). Default. Use for SaaS economies of scale.
- **Bridge** — mixed; some resources silo, others pool. Use when some tenants need silo for compliance.

Document the choice per resource in the architect's Multi-tenant isolation table (per `agents/architect.md` extended schema with client-shape column).

### Step 2 — Name the client shape that activates the model (per Wave 3 Pattern 4 / 7VQ Q3 / Audit Item 9)

For every pool / bridge resource using RLS or scope-filter, name BOTH:

1. The mechanism (RLS policy / scope chain / `tenant_id` filter)
2. The client shape — the import path that produces it:
   - **User-scoped JWT** → "RLS applies. Cite import: `import { createServerClient } from '@/lib/supabase/server'`."
   - **Service-role + manual filter** → "RLS bypassed. Explicit `WHERE tenant_id = $X` REQUIRED. Cite import: `import { supabaseAdmin } from '@/lib/supabase/admin'`."
   - **RPC with explicit `p_user_id`** → "`SECURITY DEFINER` function with manual visibility check. Cite function file:line."

A row that names "RLS applies" without naming the client shape is incomplete. Audit Item 9 G-CRIT-1 shipped this exact gap.

### Step 3 — Walk the 4-layer checklist

For every tenant-scoped surface in the design:

| Layer | What to check | Pass criterion |
|---|---|---|
| **Data layer** | Every query / mutation against tenant-scoped table has RLS coverage OR explicit `WHERE tenant_id = $X` (when service-role) | grep clean per STACK-PATTERNS Code-Review Pre-Flight |
| **Cache layer** | Every cache key includes `tenant_id` per `cache-key-prefix` template | grep `cache.set\(` audit |
| **Log layer** | Every log line includes `tenant_id` field (Honeycomb high-cardinality) | sample logs from each emitter |
| **Job boundary** | Every queued job / cron / webhook propagates tenant context at job-boundary | grep job dispatch sites |

### Step 4 — Map to control IDs

For each layer, cite the control ID being satisfied (per `agents/security-compliance.md` cross-tenant control map):

| Layer | NIST 800-53 | OWASP ASVS | OWASP API 2023 | SOC 2 |
|---|---|---|---|---|
| Data | AC-3, SC-4 | V4.2.1, V8 | API1:2023 (BOLA) | CC6.1 |
| Cache | SC-4 | V8 | API1:2023 | CC6.1 |
| Log | AU-2, AU-3 | V7.1.1, V7.1.2 | — | CC7.2 |
| Job | AC-3 | V4.2.1 | API1:2023 | CC6.1 |

Output: `docs/security/<feature>.md` with one row per layer × resource.

### Step 5 — Verify with multi-tenant integration test

Per `gate-3-production-check` D1: integration test executes under ≥2 tenant identities and returns disjoint result sets. Wire this in regression scope.

## Anti-Patterns

### "Pool model with RLS — done"

Naming pool + RLS without naming the client shape is the audit Item 9 failure. Step 2 is mandatory.

### "Cache keys are scoped by user_id, that's enough"

User belongs to ≥1 tenant. user_id alone doesn't isolate cross-tenant. The cache key must include `tenant_id` (OWASP Multi-Tenant Cheat Sheet "include tenant_id in all resource queries, cache keys, and storage paths").

### "Background jobs inherit tenant context from the request"

False — jobs run outside the request context. Every job constructor or first-line bind must explicitly accept + propagate tenant_id. Closes Item 9-style boundary leaks.

## Quick Reference

- AWS SaaS Lens silo / pool / bridge classification per resource.
- Client shape (user-scoped JWT / service-role+filter / RPC-with-p_user_id) named explicitly per Wave 3 Pattern 4.
- 4-layer checklist: data + cache + log + job boundary.
- Control IDs (NIST AC-3/SC-4 + ASVS V4.2.1/V8 + OWASP API1:2023 + SOC2 CC6.1) cited per finding.
- D1 integration test: ≥2 tenant identities; disjoint result sets.

## Composability

- **Invoked by `agents/architect.md`** when filling the Multi-tenant isolation table.
- **Invoked by `agents/security-compliance.md`** when filling the cross-tenant control map.
- **Pairs with `rls-aware-migrations`** for Postgres-specific migration discipline.
- **Pairs with `audit-trail`** for log-layer discipline.
- **Reads from `templates/STACK-PATTERNS.md`** Multi-Tenant Slot Values + Code-Review Pre-Flight Greps.
- **Feeds `gate-3-production-check`** D1, D2, D7, D11 evidence inputs.

## Citations

**SP precedent:** None — domain-specific.

**Anthropic guidance:** *Effective Context Engineering* — context isolation principle (extends to tenant context).

**Enterprise / OSS (≥3 satisfied):**
- AWS Well-Architected SaaS Lens silo / pool / bridge: https://docs.aws.amazon.com/wellarchitected/latest/saas-lens/silo-pool-and-bridge-models.html
- PostgreSQL §5.9 (RLS): https://www.postgresql.org/docs/current/ddl-rowsecurity.html
- Supabase RLS guide: https://supabase.com/docs/guides/database/postgres/row-level-security
- OWASP Multi-Tenant Security Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Multi_Tenant_Security_Cheat_Sheet.html
- OWASP API Security Top 10 (2023) API1: BOLA: https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/
- NIST SP 800-53 Rev. 5 — AC-3, SC-4: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r5.pdf
- Honeycomb high-cardinality / wide-events: https://www.honeycomb.io/blog/observability-101-terminology-and-concepts

**Companion PF v2 research:**
- `docs/research/agent-design-database-engineer.md` (RLS specifics)
- `docs/research/agent-design-security-compliance.md` (control IDs)
- `docs/research/skill-design-stack-patterns-extensions-2026-04-30.md` Pattern 4 (client-shape naming)
