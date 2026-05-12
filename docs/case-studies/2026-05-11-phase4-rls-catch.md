# Case Study: Phase 4 Caught 5 Production-Breaking Issues That Would Have Shipped

**Plugin version:** v2.3.0
**Project:** TaskIt — multi-tenant SaaS task management (Next.js 16 + Supabase + Vercel, 100 tenants × 1000 users × 100K records/tenant/month scale targets)
**Scenario:** Tier 3 perf optimization phase, Build cycle, Phase 4 (Database Engineer + Security/Compliance parallel pair)
**Date:** 2026-05-11

---

## The setup

The TaskIt team ran a Tier 3 perf research cycle that produced an architecture doc and three implementation plan docs — 1481 + 1477 + 1492 lines, covering ~30 deliverables across three waves: "infrastructure sub-day wins," "visible UX wins," and "TanStack Query adoption." The plan docs were authored by competent Plan agents reading 17 source research docs and an architect's binding decisions.

The Deputy was about to ship them straight to Builders.

Then PF v2's mandatory Phase 4 (Database Engineer + Security/Compliance, parallel pair) ran against the plan docs.

---

## What Phase 4 caught — 5 production-breakers in one Build cycle

### 1. RLS init-plan rewrite that would have widened the cross-tenant attack surface

The plan said "swap `auth.uid()` to `(SELECT auth.uid())` on 7 RLS policies — performance fix, low-risk." The Database Engineer agent didn't trust this. It read the LIVE `pg_policy` bodies from production and found the plan would have:

- Silently **DELETED** the `OR email = jwt->>email` clause from `invitations_select` → invitees would have seen nothing before accepting their invitation
- Changed the `msg_attach_*` join from `conversation_participants` to `messages` → would have **exposed sender's other-conversation attachments cross-conversation**
- Dropped the org-scope clause from 3 policies → silent **cross-tenant write surface widening**
- Referenced wrong column name (`organization_id` vs live `org_id`)

**Verdict:** FAIL. Required: re-author by reading `pg_policy` first; only swap `auth.uid()` → `(SELECT auth.uid())`, preserve every other clause verbatim.

### 2. REVOKE EXECUTE that would have broken every RLS policy

The plan said "REVOKE EXECUTE on 5 SECURITY DEFINER functions from `authenticated` — they're trigger-only per Supabase Security Advisor." Phase 4 caught that one of those 5 is `user_org_ids()` — **heavily used INSIDE every RLS policy** on `invitations_*`, `reaction_*`, `msg_attach_insert`, etc.

Revoking from `authenticated` would have failed every policy with `permission denied for function user_org_ids` → **the entire RLS isolation layer broken at apply time**.

**Verdict:** FAIL. Required: exclude `user_org_ids` from the REVOKE list; revoke only on the 3 actual trigger-only functions.

### 3. Visibility-predicate extraction that invented column names

The plan proposed extracting a `work_item_is_visible()` SQL function as a "1-2 day sub-day win." Phase 4 read the live source (migration 079 lines 38-687) and found the proposed signature was fundamentally wrong:

- Invented `p_is_public` parameter — live column is `is_private` (negated semantics)
- Invented `p_dept_id` field — live has `department_id` in some places, `assigned_department_ids[]` array in others
- Used `p_creator_id` — live column is `created_by`
- **Omitted mode flags** (`p_assigned_only`, `p_created_only`, `p_include_all`) that materially change which rows are returned
- **Mis-modeled department-shared visibility** — would have silently over-permitted to deactivated users' department peers

**Verdict:** FAIL. Required: re-author signature against live predicate; add pgTAP cross-tenant test; defer until pgTAP harness exists; split out of "sub-day" wave (it's no longer sub-day).

### 4. Migration that would have failed at apply time

The plan's keyset pagination index migration said `WHERE deleted_at IS NULL`. The `work_items` table has **no `deleted_at` column** — it's `archived_at`. The migration would have aborted at apply time mid-deploy. The plan's own awareness section flagged the column name correctly, but the actual migration SQL contradicted it — exactly the kind of internal inconsistency a Builder reading the file linearly would have applied without catching.

**Verdict:** CONDITIONAL. Required: rename throughout the migration body.

### 5. Migration number collision between two parallel plan agents

Plan agent 1 (infrastructure wave) reserved migrations 094-100. Plan agent 2 (visible UX wave) reserved migrations 094-096 — independently, with no awareness of the first plan's reservations. Without Phase 4's cross-plan audit, the second migration to apply would have collided with the first's number, causing an apply-time failure during what was supposed to be a coordinated multi-wave deploy.

**Verdict:** HIGH cross-cutting finding (C1). Required: global renumbering 094 → 104 with explicit reservation table.

---

## Plus 9 Security/Compliance findings (zero CRITICAL — all caught before any Builder dispatched)

- **A1 batched signed-URL BOLA** (OWASP API1:2023) — batched signing endpoint missing per-attachment participant check; without remediation would have allowed users to enumerate signed URLs for attachments in conversations they don't belong to
- **AQ cross-tab session-hangover** (NIST SC-4 + ASVS V3.5.2) — tab B serves stale tenant data after tab A signs out, until the tab is closed manually. Required: `BroadcastChannel('taskit-auth')` to fire `queryClient.clear()` cross-tab on sign-out
- **AQ persisted IndexedDB cache survives role downgrades up to 24h** — required: `roleRev` token in query key derived from `org_memberships.updated_at`
- 3 latent HIGH gates on a future search-DSL feature (B27) — formal grammar doc + `websearch_to_tsquery` not raw `to_tsquery(user_input)` + per-tenant rate limit

---

## What this case study demonstrates

**The plans were written by competent Plan agents.** They cited the architect's binding decisions, used the `writing-plans` skill template correctly, included acceptance grep checks, listed regression scope per Rule 34. By every check visible at the plan-doc layer, they were ready to ship.

**Phase 4 caught what plan-doc review couldn't.** Five fundamental errors that would only surface at apply-time or, worse, silently in production. Three of them (RLS init-plan, REVOKE, visibility-predicate) had direct multi-tenant security implications.

**The Phase 4 specialist agents hit the live database.** They didn't trust the plan docs' schema assumptions — they read `pg_policy`, `pg_proc`, the live migrations, and the actual column names via Supabase MCP. That's the structural advantage of having Database Engineer + Security/Compliance as a mandatory parallel pair before any Builder code dispatches: plan-doc review catches plan-doc problems, but live-DB review catches schema-drift problems, and only Phase 4 does both.

**Without PF v2, this would have shipped to production.** The Deputy explicitly drifted past Phase 4 — went from architecture (Phase 3) straight to plan-writing (Phase 5) — and was caught only when the user asked the right framework-discipline question: "Are you running a Tier 3 Build cycle?" After that, the Phase 4 agents ran in parallel for ~10 minutes and caught everything above.

---

## The framework gap this exposed

PF v2 v2.3.0 defines Phase 4 as **mandatory** for cycles that touch schema/RLS/migrations OR auth/data-handling. But the framework doesn't STRUCTURALLY enforce phase ordering — the Deputy can drift past Phase 4 without the plugin flagging the skip. This was logged as framework-feedback Item 12 (HIGH) in the same TaskIt session.

Even with that gap unfixed, the value of Phase 4 — *when actually invoked* — is unambiguous: it catches what no other reviewer can.

---

## Source artifacts (TaskIt repo, available for verification)

- DB Engineer audit: `docs/audits/phase4-db-engineer-perf-2026-05-11.md`
- Security/Compliance audit: `docs/audits/phase4-security-compliance-perf-2026-05-11.md`
- Plan docs audited: `docs/plans/phase-perf-{a0-a6-a7-infrastructure,a1-a5-visible-ux-wins,aq-tanstack-query}.md`
- Architect doc: `docs/audits/architecture-tanstack-query-adoption-2026-05-11.md`
- Canonical synthesis: `docs/audits/research-perf-tier3-synthesis-2026-05-11.md`

---

## The cost of skipping Phase 4

Counting only the production-breakers (items 1–4 above), the cost without Phase 4 would have been:

| Issue | Cost if shipped |
|---|---|
| RLS clause deletion → cross-tenant data exposure | Security incident; SOC 2 breach disclosure to customers; postmortem cycle; trust loss |
| REVOKE on `user_org_ids` → entire RLS layer broken | Site-wide outage at apply time; emergency rollback; user-facing error toasts on every action |
| Visibility-predicate over-permissioning to deactivated dept peers | Silent unauthorized data access; difficult to detect; compliance violation |
| Migration `deleted_at` typo | Apply-time deploy failure; partial-state schema; recovery via manual SQL |
| Migration number collision | Second-deploy apply-time failure; coordinated rollback across both waves |

Phase 4 caught all five in ~10 minutes of parallel agent runtime.

This is what "Database Engineer + Security/Compliance as mandatory parallel pair before Builder dispatch" buys you.
