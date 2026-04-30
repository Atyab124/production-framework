---
name: audit-trail
description: "Use when designing or auditing the audit-log surface for any multi-tenant SaaS feature — prescribes the append-only schema, mandatory fields (actor_id, tenant_id, action, target, timestamp), no-PII discipline, and the integrity-protection contract. Composes with security-compliance and gate-3 D11 + D12."
---

## Overview

Audit logs are the durable evidence trail for multi-tenant SaaS. They get checked at compliance audits (SOC 2 CC7.2), at incident retros (post-mortem reads them), and at security investigations (forensic). PF v2 prescribes the schema, mandatory fields, and integrity contract.

**Enterprise grounding:** NIST SP 800-53 Rev. 5 AU-2 + AU-3 + AU-9 + AU-11 (Event Logging / Content / Integrity / Retention); OWASP ASVS V7.1.1 + V7.1.2 + V7.1.3 + V7.2.1 + V7.2.2 + V7.4.1; SOC 2 CC7.2 + CC6.7.

## When to Use

- Designing the audit-log schema for any feature with state-changing operations.
- Auditing an existing audit-log writer for compliance gaps.
- Filling the `agents/security-compliance.md` audit row for a new feature.
- Filling `agents/architect.md` Quality-Attribute Matrix (Operational Excellence row references audit log).

Do NOT use:
- For purely read-only features (no state mutation; no audit row needed unless data-classification rules require read-audit).
- For ephemeral debug logs (those are different surface; see `agents/sre-devops.md` log discipline).

## Core Pattern

You MUST create a TodoWrite item per step.

### Step 1 — Identify state-changing surfaces

Enumerate every operation that mutates persistent state for the feature:
- INSERT / UPDATE / DELETE on tenant-scoped tables
- API mutations (POST / PUT / PATCH / DELETE on RESTful endpoints)
- RPC calls that modify state
- Async actions (queued jobs that mutate; cron writes)
- Permission grants / revokes / impersonation events

### Step 2 — Required fields per row (mandatory schema)

Per ASVS V7.2.2 + NIST AU-3 + STACK-PATTERNS `audit-log-fields` slot:

```
actor_id     -- who performed the action (user_id; NULL for system)
tenant_id    -- multi-tenant scope (REQUIRED if multi-tenant)
action       -- verb describing the operation (e.g., "user.create", "task.delete")
target       -- what was acted on (resource_type:resource_id)
timestamp    -- UTC ISO 8601
outcome      -- success | failure | partial
ip_address   -- requesting IP (per V7.2.1 authentication-decision logging)
user_agent   -- requesting user-agent
correlation_id -- request-trace ID (for cross-service correlation)
```

Optional but recommended:
```
before_state, after_state -- diff of changed fields (for audit-replay)
```

### Step 3 — Append-only enforcement

Per NIST AU-9 (Audit Record Protection):

> "Protect audit records and audit logging tools from unauthorized access, modification, and deletion."

Implementation:
- Audit table is append-only at the schema level (no UPDATE / DELETE policy).
- DB role used for audit writes is distinct from app runtime role.
- For compliance-grade tenants, write-once storage (S3 Object Lock, immutable bucket) per AU-11 (Audit Record Retention).

### Step 4 — No-PII discipline (D12 anchor)

Per ASVS V7.1.1 + V7.1.2:

> "Verify that the application does not log credentials or payment details."
> "Verify that the application does not log other sensitive data as defined under local privacy laws or relevant security policy."

Audit logs MUST NOT contain:
- Passwords, API keys, session tokens (full)
- Payment card numbers, SSNs, government IDs
- Raw PII unless required by audit semantics (then redact-on-read, not redact-on-write)

For correlation: log a hash or token-id, not the secret itself. Per ASVS V7.4.1 (generic error + correlation_id):

> "Verify that a generic message is shown when an unexpected or security-sensitive error occurs, potentially with a unique reference number."

### Step 5 — Retention policy

Per NIST AU-11:

> "Retain audit records for [Assignment: organization-defined time period] to provide support for after-the-fact investigations of security incidents and to meet regulatory and organizational information retention requirements."

Document the retention period (typical: 7 years for SOC 2; 90 days for non-compliance feature). Add to STACK-PATTERNS.md `audit-retention-policy` slot.

### Step 6 — Cite control IDs in `docs/security/<feature>.md`

For each audit row written, the security findings doc references:
- NIST AU-2 (Event Logging) — feature has audit coverage
- NIST AU-3 (Content of Audit Records) — fields meet requirements
- ASVS V7.1.3 (security events logged), V7.2.1 (auth decisions), V7.2.2 (access-control decisions)
- SOC 2 CC7.2 (system monitoring) + CC6.7 (confidentiality at rest)

## Anti-Patterns

### "Audit logs include the full request body for forensic completeness"

ASVS V7.1.2 forbids logging "sensitive data as defined under local privacy laws." Full request bodies typically contain PII. Log a hash or correlation_id; redact on retrieval per consumer authorization.

### "We'll add the audit table later, after the feature works"

D11 (gate-3) blocks ship if audit-log writes are absent on state-changing operations. "Later" doesn't pass the gate.

### "INSERT-only — no UPDATE or DELETE — that's append-only"

Append-only at the application layer is necessary but not sufficient. The DB schema must lack UPDATE/DELETE policies on the audit table; the role used for writes must lack those rights. Otherwise a compromised role could rewrite history.

### "tenant_id isn't applicable for system actions"

For system actions (cron, automated cleanup, compliance scans), set actor_id=NULL but still tag tenant_id when the action acts on tenant-scoped data. System-level actions that span tenants get tenant_id=NULL with explicit "cross-tenant action" annotation in the action field.

## Quick Reference

- 9 mandatory fields: actor_id, tenant_id, action, target, timestamp, outcome, ip_address, user_agent, correlation_id.
- Append-only at schema + role layers. NIST AU-9 integrity protection.
- No PII / credentials / payment details — ASVS V7.1.1 + V7.1.2.
- Retention policy documented in STACK-PATTERNS — NIST AU-11.
- Cite control IDs in security findings doc per layer.

## Composability

- **Invoked by `agents/security-compliance.md`** for every feature audit.
- **Reads from `templates/STACK-PATTERNS.md`** `audit-log-fields` + `audit-retention-policy` slots.
- **Pairs with `tenant-isolation`** — log layer of the 4-layer checklist references this skill.
- **Pairs with `rls-aware-migrations`** — when migration adds/drops audit-related columns.
- **Feeds `gate-3-production-check`** D11 (audit log writes) + D12 (no PII in logs) evidence inputs.
- **Feeds `agents/post-mortem.md`** — post-mortem reads audit log for blast-radius quantification.

## Citations

**SP precedent:** None — domain-specific.

**Anthropic guidance:** *Effective Context Engineering* — file artifacts as durable evidence.

**Enterprise / OSS (≥3 satisfied):**
- NIST SP 800-53 Rev. 5 — AU-2, AU-3, AU-9, AU-11: https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r5.pdf
- OWASP ASVS v4 — V7 Logging: https://github.com/OWASP/ASVS/blob/master/4.0/en/0x15-V7-Error-Logging.md
- OWASP ASVS v4 — V8 Data Protection
- SOC 2 TSC 2017 — CC7.2, CC6.7
- Honeycomb structured-events / wide-events: https://www.honeycomb.io/blog/observability-101-terminology-and-concepts

**Companion PF v2 research:**
- `docs/research/agent-design-security-compliance.md` (NIST + ASVS + SOC 2 control IDs)
- `agents/security-compliance.md` (Iron Law: NO FINDING WITHOUT NAMED CONTROL ID)
- `templates/STACK-PATTERNS.template.md` Multi-Tenant Slot Values (audit-log-fields)
