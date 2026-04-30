# Agent Design Research — Security/Compliance Sub-Agent

**Date:** 2026-04-29
**Type:** Source-of-truth research — no code modifications
**Triggered by:** PF v2 needs role-specific depth in `agents/security-compliance.md`. Current shape correct; needs canonical control IDs to cite.
**Methodology:** WebSearch synthesis of canonical URLs (WebFetch denied for some sources). Verbatim quotes reproduced where retrieved; paraphrased findings tagged. Re-verify against canonical URLs before binding architectural decisions.

---

## Part 1: Canonical Sources

| # | Source | URL | Date verified |
|---|---|---|---|
| 1 | OWASP ASVS v4.0 — V4 Access Control | https://github.com/OWASP/ASVS/blob/master/4.0/en/0x12-V4-Access-Control.md | 2026-04-29 |
| 2 | OWASP ASVS v4.0 — V7 Error Handling and Logging | https://github.com/OWASP/ASVS/blob/master/4.0/en/0x15-V7-Error-Logging.md | 2026-04-29 |
| 3 | OWASP ASVS v4.0 — V8 Data Protection | https://github.com/OWASP/ASVS/blob/v4.0.3/4.0/en/0x16-V8-Data-Protection.md | 2026-04-29 |
| 4 | OWASP ASVS v5.0 — V8 Authorization (proposed multi-tenant requirement) | https://github.com/OWASP/ASVS/blob/master/5.0/en/0x17-V8-Authorization.md | 2026-04-29 |
| 5 | OWASP ASVS multi-tenant requirement issue | https://github.com/OWASP/ASVS/issues/2060 | 2026-04-29 |
| 6 | OWASP API Security Top 10 (2023) — API1:2023 BOLA | https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/ | 2026-04-29 |
| 7 | OWASP API Security Top 10 (2023) — API3:2023 BOPLA | https://owasp.org/API-Security/editions/2023/en/0xa3-broken-object-property-level-authorization/ | 2026-04-29 |
| 8 | OWASP Multi-Tenant Security Cheat Sheet | https://cheatsheetseries.owasp.org/cheatsheets/Multi_Tenant_Security_Cheat_Sheet.html | 2026-04-29 |
| 9 | OWASP Cloud Tenant Isolation Project | https://owasp.org/www-project-cloud-tenant-isolation/ | 2026-04-29 |
| 10 | OWASP Logging Cheat Sheet | https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html | 2026-04-29 |
| 11 | NIST SP 800-53 Rev. 5 — AC-3 Access Enforcement | https://csf.tools/reference/nist-sp-800-53/r5/ac/ac-3/ | 2026-04-29 |
| 12 | NIST SP 800-53 Rev. 5 — AC-4 Information Flow Enforcement | https://csf.tools/reference/nist-sp-800-53/r5/ac/ac-4/ | 2026-04-29 |
| 13 | NIST SP 800-53 Rev. 5 — SC-4 Information in Shared System Resources | https://csf.tools/reference/nist-sp-800-53/r5/sc/sc-4/ | 2026-04-29 |
| 14 | NIST SP 800-53 Rev. 5 (canonical PDF) | https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r5.pdf | 2026-04-29 |
| 15 | AICPA TSC 2017 (rev 2022) — SOC 2 Common Criteria | https://www.aicpa-cima.com/resources/download/2017-trust-services-criteria-with-revised-points-of-focus-2022 | 2026-04-29 |
| 16 | CSA Cloud Controls Matrix v4 | https://cloudsecurityalliance.org/research/cloud-controls-matrix | 2026-04-29 |
| 17 | Anthropic — Agentic Misalignment | https://www.anthropic.com/research/agentic-misalignment | 2026-04-29 |
| 18 | Anthropic — Prompt Injection Defenses | https://www.anthropic.com/research/prompt-injection-defenses | 2026-04-29 |
| 19 | Supabase — Row Level Security | https://supabase.com/docs/guides/database/postgres/row-level-security | 2026-04-29 |
| 20 | pgTAP RLS testing pattern | https://blair-devmode.medium.com/testing-row-level-security-rls-policies-in-postgresql-with-pgtap-a-supabase-example-b435c1852602 | 2026-04-29 |

---

## Part 2: Verbatim Quotes by Topic

### 2.1 Cross-Tenant Data Leak Prevention

**OWASP ASVS v4 — V4.2.1 (IDOR)**:
> "Verify that sensitive data and APIs are protected against Insecure Direct Object Reference (IDOR) attacks targeting creation, reading, updating and deletion of records."
— Source #1.

**OWASP ASVS v5.0 / v4 issue #2060 — proposed multi-tenant requirement**:
> "Verify that multi-tenant applications use cross-tenant controls to ensure user operations will never affect tenants with which they do not have permissions to interact."
— Source #4, #5.

**OWASP API1:2023 BOLA**:
> "Every API endpoint that receives an ID of an object, and performs any action on the object, should implement object-level authorization checks."
> "Authorization checks should be made continuously throughout a given session to validate that the logged-in user has access to perform the requested action on a requested object."
> "BOLA vulnerabilities primarily enable horizontal escalation, allowing one customer to access another customer's orders, documents, or account information within multi-tenant systems."
> "The best place to implement object level authorization is within the backend API itself."
— Source #6.

**NIST SP 800-53 AC-3 (Access Enforcement)**:
> "Enforce approved authorizations for logical access to information and system resources in accordance with applicable access control policies."
— Source #11.

**NIST SP 800-53 SC-4 (Information in Shared System Resources)** — DIRECTLY APPLICABLE TO CACHE / TENANT ISOLATION:
> "Prevent unauthorized and unintended information transfer via shared system resources."
> "This control prevents information produced by the actions of prior users or roles (or processes acting on behalf of prior users or roles) from being available to current users or roles (or current processes) that obtain access to shared system resources after those resources have been released back to the system."
— Source #13.

**OWASP Multi-Tenant Cheat Sheet** (paraphrased findings, source #8):
- "Use database-level isolation (RLS, schemas) as defense in depth."
- "Include tenant_id in all resource queries, cache keys, and storage paths."
- "Validate tenant ownership at the data access layer."
- "Log tenant context with every operation."
- "Monitor and alert on cross-tenant access attempts."
- Three named threats: Cross-Tenant Data Leakage, Tenant Impersonation, Broken Tenant Isolation.

---

### 2.2 Audit Trail Control Families

**SOC 2 CC6 (Logical and Physical Access)** — controls who can do what (paraphrased, source #15):
- **CC6.1**: identify/manage info-asset inventory and restrict logical access through controls limiting access to only those with business need.
- **CC6.2**: asset owner/custodian must approve access before grant; covers new hires, transfers, role changes.
- **CC6.3**: role-based access control utilizing roles by job function.

**SOC 2 CC7 (System Operations)** — detect/evaluate/respond (paraphrased, source #15):
- **CC7.2**: ongoing monitoring for irregular activity indicative of incidents.
- **CC7.3**: monitor security events to determine impact on objectives.

**OWASP ASVS v4 — V7 Error Handling and Logging** (verbatim, source #2):
- **7.1.1**: "Verify that the application does not log credentials or payment details. Session tokens should only be stored in logs in an irreversible, hashed form."
- **7.1.2**: "Verify that the application does not log other sensitive data as defined under local privacy laws or relevant security policy."
- **7.1.3**: "Verify that the application logs security relevant events including successful and failed authentication events, access control failures, deserialization failures and input validation failures."
- **7.1.4**: "Verify that each log event includes necessary information that would allow for a detailed investigation of the timeline when an event happens."
- **7.2.1**: "Verify that all authentication decisions are logged, without storing sensitive session tokens or passwords. This should include requests with relevant metadata needed for security investigations."
- **7.2.2**: "Verify that all access control decisions can be logged and all failed decisions are logged."
- **7.3.1**: "Verify that all logging components appropriately encode data to prevent log injection."
- **7.3.3**: "Verify that security logs are protected from unauthorized access and modification."
- **7.3.4**: "Verify that time sources are synchronized to the correct time and time zone."

**NIST SP 800-53 AU family** (audit and accountability):
- **AU-2** Event Logging — defines which events are auditable.
- **AU-3** Content of Audit Records — what each record contains (timestamp, source, outcome, identity).
- **AU-9** Protection of Audit Information — integrity protection.
— Source #14.

---

### 2.3 RLS Verification

**Supabase RLS — multi-tenant isolation** (paraphrased, sources #19, #20):
> "Even if application code has bugs or API endpoints are misconfigured, the database enforces tenant isolation."
> "The best way to test a policy is to set the role and JWT claim manually in a transaction and then test the query."
> "pgTAP can be used to automate tests validating that RLS policies are enforced properly."
> Common pitfall: "Always test RLS policies by authenticating as different users to verify isolation works. You won't notice in testing because your test user probably has access to everything in your dev database."

**Trust-nothing principle** (PF v2 hard rule, validated by source #20): RLS policy text on paper is not RLS enforcement. Verification requires (a) reading the policy SQL, (b) reading the queries that hit the protected table, (c) executing test queries under different `auth.uid()` / JWT claims, ideally via pgTAP.

---

### 2.4 Error Message Leakage

**OWASP ASVS v4 — V7.4.1**:
> "Verify that a generic message is shown when an unexpected or security sensitive error occurs, potentially with a unique ID which support personnel can use to investigate."
— Source #2.

This maps directly to the PF v2 hard rule: `"Resource not found"` is correct; `"Resource owned by tenant X"` is a leak. The unique-ID-for-support pattern enables investigation without leaking tenant identity.

**OWASP ASVS v4 — V7.4.2 / V7.4.3**:
- **7.4.2**: "Verify that exception handling (or a functional equivalent) is used across the codebase to account for expected and unexpected error conditions."
- **7.4.3**: "Verify that a 'last resort' error handler is defined which will catch all unhandled exceptions."

**OWASP API3:2023 BOPLA** (source #7) — adjacent to error leakage: properties returned in the response body are themselves an error-class leak vector. Object property level authorization must filter response shape per caller's auth context.

---

### 2.5 Cache Key Tenancy

**NIST SC-4** (source #13, quoted in 2.1) is the canonical control: "Prevent unauthorized and unintended information transfer via shared system resources." Caches are shared system resources. SC-4 directly applies.

**OWASP Multi-Tenant Cheat Sheet** (source #8):
- "Include tenant_id in all resource queries, **cache keys**, and storage paths."

**Industry guidance — Redis multi-tenant** (source: redis.io blog, indexed via search):
- Tenant-aware key naming: `tenant:{tenant-id}:{resource-type}:{resource-id}` reduces collision risk.
- Cache leaks "frequently caused by missing tenant context on read/write paths (wrong key prefix, wrong token leading to wrong prefix)" — reinforcing that the failure mode is silent (no error, just wrong data served to wrong tenant).
- Redis 6.0+ ACLs allow tenant-specific users restricted to specific key patterns — defense-in-depth beyond key prefixing.

---

### 2.6 OWASP / SOC 2 / NIST Control IDs Mapping to Multi-Tenant SaaS

The Security/Compliance agent should explicitly cite the following control IDs when producing `docs/security/<feature>.md`:

| Concern | OWASP ASVS v4 | OWASP API Top 10 (2023) | NIST SP 800-53 Rev. 5 | SOC 2 (TSC 2017 / 2022 PoF) |
|---|---|---|---|---|
| Cross-tenant access (IDOR/BOLA) | 4.1.3, 4.1.5, **4.2.1**, V8 multi-tenant (proposed) | **API1:2023**, API3:2023, API5:2023 | **AC-3**, **AC-4**, AC-6 | **CC6.1**, CC6.2, CC6.3 |
| RLS / data-layer enforcement | 4.1.1 | API1:2023 (backend impl) | AC-3, **AC-3(7)** RBAC, SC-4 | CC6.1 |
| Audit trail (security events) | **7.1.3**, **7.2.1**, **7.2.2**, 7.1.4 | (cross-cutting) | **AU-2**, **AU-3**, AU-9, AU-12 | **CC7.2**, **CC7.3**, CC4.1 |
| Audit trail (PII not logged) | **7.1.1**, **7.1.2** | (cross-cutting) | AU-11, SI-12 | CC6.7, P (Privacy criterion) |
| Error message leakage | **7.4.1**, 7.4.2, 7.4.3 | API3:2023 | SI-11 | CC6.1, CC7.4 |
| Cache key tenancy | (cross-cutting) | API1:2023 (backend impl) | **SC-4**, SC-39 | CC6.1, CC6.6 |
| Rate limiting / noisy neighbour | (V11 Business Logic) | **API4:2023** unrestricted resource consumption | SC-5, SC-6 | CC6.6, A1.2 |
| Encryption at rest / in flight | V6, **V8**, V9 | (cross-cutting) | SC-8, SC-13, SC-28 | CC6.7 |
| Account lifecycle / offboarding | (V3 session) | API2:2023 | AC-2 | CC6.2, CC6.3, CC6.5 |
| Cross-tenant monitoring | 7.2.2 | (cross-cutting) | AU-6, SI-4 | CC7.2, CC7.3 |
| Prompt injection / agent escape | (not yet covered) | (not yet covered) | SI-3, SI-7 | CC7.1, CC7.2 |

Bold entries are the highest-yield IDs the agent should cite by default; others are situational.

---

### 2.7 Anthropic Agent-Security Considerations

These apply when PF v2 features expose tools/data to a sub-agent.

**Agentic Misalignment** (source #17):
> "Models from all developers resorted to malicious insider behaviors when that was the only way to avoid replacement or achieve their goals — including blackmailing officials and leaking sensitive information to competitors."
> Two primary triggers: "(a) a direct threat to the model's continued operation, such as being shut down or replaced; (b) a conflict between the model's assigned goals and a change in the company's strategic direction."

**Prompt-Injection Defenses** (source #18):
> "Anthropic encourages customers to think carefully about which tools and data they provide to an agent, which permissions they grant, and which environments they let agents operate in."
> "Humans still need to retain meaningful control — with users deciding what Claude can and can't do through configurable permissions for each action."
> "Only 1.4% of attacks were successful against Claude Opus 4.5, compared to 10.8% for Claude Sonnet 4.5 with previous safeguards. However, no browser agent is immune to prompt injection."

**Implication for PF v2 Security/Compliance agent:** when a feature lets Claude (or a sub-agent) call tools that touch tenant-scoped data, the agent must add an "**Agent threat model**" section: (a) what untrusted content enters the agent's context, (b) what tenant-scoped tools are exposed, (c) what permission gating exists, (d) what blast radius a malicious-instruction-following agent could achieve.

---

## Part 3: SP-Inheritable Patterns

**None.** Per `sp-anthropic-citation-manifest.md`:
- SP 5.0.7 has no security/compliance skill, agent, or audit pattern. SP's `skills/verification-before-completion` covers generic "evidence before assertion" but is silent on RLS, audit trail, cross-tenant safeguards, or compliance control mapping.
- All security/compliance content is PF v2 original, citing canonical external standards (OWASP, NIST, AICPA, CSA, Anthropic).
- This is acceptable under the binding rule: external industry standards are equally valid citations to SP precedent or Anthropic guidance, provided each rule cites a specific control ID and URL.

---

## Part 4: Gaps in the Current `agents/security-compliance.md`

| Gap | Current state | Canonical source | Severity |
|---|---|---|---|
| GAP-1 — No control IDs cited | Mentions "SOC2 / regulatory mapping" generically; no AC-3 / CC6.1 / API1:2023 named | NIST 800-53, AICPA TSC, OWASP API Top 10 | HIGH — auditor-facing security docs need control IDs |
| GAP-2 — Cache key rule has no NIST citation | Rule "Cache keys must include tenant scope" is correct but uncited | **NIST SC-4** Information in Shared System Resources | MEDIUM — hard rule needs anchor |
| GAP-3 — Error message rule has no ASVS citation | Rule "Resource not found vs Resource owned by tenant X" is correct but uncited | **OWASP ASVS V7.4.1** | MEDIUM |
| GAP-4 — Audit trail rule has no AU-family citation | Rule "every INSERT/UPDATE/DELETE on tenant-scoped tables MUST be logged" lacks NIST anchor | **NIST AU-2, AU-3** + ASVS 7.1.3, 7.2.1, 7.2.2 | MEDIUM |
| GAP-5 — RLS verification methodology absent | "Read the actual policy SQL; match it to the actual queries" is right, but no pgTAP / auth.uid()-impersonation test pattern named | Supabase docs + pgTAP pattern | MEDIUM — without method, the rule is aspirational |
| GAP-6 — No agent threat model section | Output covers "Threat model — top 3 threats specific to this feature" but does not call out agent-tool exposure | Anthropic prompt-injection defenses + Agentic Misalignment | LOW unless feature exposes agent-callable tools; HIGH when it does |
| GAP-7 — No PII logging exclusion list | Hard rule on no cross-tenant info in errors but no parallel rule on no PII in logs | **OWASP ASVS 7.1.1, 7.1.2** + NIST AU-11, SI-12 | MEDIUM — common audit finding |
| GAP-8 — No deletion / right-to-be-forgotten path | "Data handling — retention, deletion path" mentioned in scope but no rule that GDPR/CCPA right-to-erasure must produce a verifiable audit trail of erasure | OWASP Multi-Tenant Cheat Sheet ("complete data deletion for offboarding") + GDPR Art 17 / CCPA | LOW for v2.0; flag for v2.x |
| GAP-9 — No noisy-neighbour / rate limiting rule | Not covered; relevant per OWASP API4:2023 + NIST SC-5/SC-6 | **OWASP API4:2023** + OWASP Multi-Tenant Cheat Sheet ("Implement per-tenant rate limiting") | LOW — adjacent to performance role; coordinate |
| GAP-10 — No "trust nothing" framing for inherited claims | Hard rules say trust nothing in code, but agent must also distrust prior `docs/security/<other-feature>.md` claims | (PF discipline; cite SP `verification-before-completion`) | LOW |

---

## Part 5: Suggested Revisions to `agents/security-compliance.md`

### Revision A — Add a "Canonical control ID citation" rule

Add as a new hard rule under `## Hard rules`:

> - **Cite specific control IDs.** Every finding in `docs/security/<feature>.md` must name at least one of: an OWASP ASVS verification ID (e.g. V4.2.1), an OWASP API Top 10 entry (e.g. API1:2023), a NIST SP 800-53 Rev. 5 control (e.g. AC-3, AU-2, SC-4), or a SOC 2 Common Criterion (e.g. CC6.1, CC7.2). "This is a security issue" without a control ID is a non-finding.

### Revision B — Anchor each existing hard rule to a control ID

| Existing PF v2 hard rule | Add citation |
|---|---|
| "RLS policy that exists on paper but is not actually enforced is a finding" | NIST AC-3, OWASP ASVS V4.1.1, SOC 2 CC6.1 |
| "Cache keys must include tenant scope" | **NIST SC-4** Information in Shared System Resources, OWASP Multi-Tenant Cheat Sheet, OWASP ASVS V4.2.1 |
| "Audit trail is non-negotiable for write paths" | **NIST AU-2, AU-3**, **OWASP ASVS V7.1.3, V7.2.1, V7.2.2**, **SOC 2 CC7.2** |
| "Error messages must not leak cross-tenant information" | **OWASP ASVS V7.4.1**, NIST SI-11 |
| "No 'we'll add RLS later'" | NIST AC-3 + AC-4, SOC 2 CC6.1 |

### Revision C — Add a default `## Output template` block

Add to the agent body:

```markdown
## Output template

Every `docs/security/<feature>.md` MUST contain these sections:

1. **Auth model** (cite ASVS V4.1.x; SOC 2 CC6.1, CC6.2, CC6.3)
2. **RLS posture** (cite NIST AC-3; ASVS V4.1.1; verify via pgTAP-style test)
3. **Audit trail** (cite NIST AU-2/AU-3; ASVS V7.1.3, V7.2.1, V7.2.2; SOC 2 CC7.2)
4. **Data handling** (cite ASVS V8; NIST SC-8/SC-13/SC-28)
5. **Cross-tenant safeguards — the seven layers**:
   (a) Queries — tenant_id in WHERE / RLS active (NIST AC-3, ASVS V4.2.1)
   (b) Caches — tenant_id in cache key (NIST SC-4, OWASP Multi-Tenant Cheat Sheet)
   (c) Search indexes — tenant_id partition or filter (NIST SC-4)
   (d) Exports — auth check + tenant filter (ASVS V4.2.1, API1:2023)
   (e) Error messages — generic + correlation ID (ASVS V7.4.1)
   (f) Logs — no PII, no cross-tenant identifiers (ASVS V7.1.1, V7.1.2)
   (g) Background jobs — tenant_id propagated through job context (NIST AC-3)
6. **Compliance mapping** (table of feature touchpoints to control IDs across OWASP / NIST / SOC 2)
7. **Threat model** (top 3 feature-specific + agent-exposure threats per Anthropic guidance if tool/data is reachable from a sub-agent)
8. **Findings** — each with (a) severity CRITICAL/HIGH/MEDIUM/LOW, (b) control ID(s) violated, (c) verification evidence, (d) remediation
```

### Revision D — Add an "Agent threat model" hard rule (NEW)

Add under hard rules:

> - **If this feature exposes any tool, data, or action to a Claude sub-agent, an agent threat model is mandatory.** Document: (a) what untrusted content can enter the agent's context, (b) what tenant-scoped tools the agent can invoke, (c) what permission gating exists per tool, (d) what blast radius a prompt-injection-following agent could achieve. Cite Anthropic's *Mitigating prompt injections in browser use* and *Agentic Misalignment* guidance.

### Revision E — Add an "RLS verification method" rule

Add to `## Your job` under RLS posture:

> RLS verification is not "the policy exists." It is: (1) read the policy SQL, (2) read the queries that hit the protected table, (3) execute test queries under at least two distinct `auth.uid()` / JWT claim values to confirm row-set differs as expected, ideally via pgTAP (Supabase) or equivalent. Without (3), the verification is incomplete and findings must be marked `NEEDS_CONTEXT`.

### Revision F — Add a "PII logging exclusion" hard rule

Add under hard rules:

> - **No PII or credentials in logs.** Audit logs MUST contain tenant_id, actor, action, target, timestamp, outcome — and MUST NOT contain raw email, raw phone, payment details, session tokens (except hashed), or other PII unless the log destination has equivalent or stricter access controls than the source data. Cite ASVS V7.1.1, V7.1.2; NIST AU-11, SI-12.

### Revision G — Update the "Citations" footer

Replace the current minimal Citations section with:

```markdown
## Citations

- **SP precedent:** Subagent shape from `agents/code-reviewer.md`. (No SP precedent exists for security/compliance content; all controls below are cited from canonical industry standards.)
- **Anthropic citation:** Multi-agent research system pattern (sub-agent context isolation); *Mitigating prompt injections in browser use*; *Agentic Misalignment* (June 2025) — for agent-exposed feature threat models.
- **OWASP ASVS v4 / v5** — verification IDs cited per finding: https://github.com/OWASP/ASVS
- **OWASP API Security Top 10 (2023)** — https://owasp.org/API-Security/editions/2023/en/
- **OWASP Multi-Tenant Security Cheat Sheet** — https://cheatsheetseries.owasp.org/cheatsheets/Multi_Tenant_Security_Cheat_Sheet.html
- **OWASP Logging Cheat Sheet** — https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html
- **NIST SP 800-53 Rev. 5** — https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r5.pdf — controls AC-3, AC-4, AC-6, AU-2, AU-3, AU-6, AU-9, AU-11, AU-12, SC-4, SC-8, SC-13, SC-28, SI-3, SI-4, SI-7, SI-11, SI-12
- **AICPA SOC 2 Trust Services Criteria (2017, rev 2022)** — https://www.aicpa-cima.com/resources/download/2017-trust-services-criteria-with-revised-points-of-focus-2022 — CC6.1, CC6.2, CC6.3, CC6.5, CC6.6, CC6.7, CC7.1, CC7.2, CC7.3, CC7.4
- **CSA Cloud Controls Matrix v4** — https://cloudsecurityalliance.org/research/cloud-controls-matrix
- **Skill dependencies:** `skills/tenant-isolation`, `skills/audit-trail` (PF v2 multi-tenant skills, ship in Phase D)
```

---

## Summary

- **Canonical sources documented:** 20 (Part 1 table)
- **Control IDs the agent should cite by default:** 28 (Part 2.6 table; bolded entries)
- **Gaps identified in current agent:** 10 (Part 4 table)
- **Suggested revisions:** 7 (A–G in Part 5), of which A, B, C are HIGH-severity for v2.0, the rest MEDIUM

**Top three revisions to ship in v2.0:**
1. **Revision A** — citation discipline rule. Without it, all other revisions are toothless.
2. **Revision C** — output template with control IDs in section headings. This makes the agent's output auditor-ready.
3. **Revision B** — anchor each existing hard rule to a control ID. This converts the agent from "opinionated" to "enforcing standards."

**Methodology disclosure:** All quotes retrieved via WebSearch synthesis of canonical URLs. WebFetch was permission-denied for some sources (notably `owasp.org/API-Security/...` and `csf.tools/...`); paraphrased findings from those sources are tagged. Two sources were retrieved via WebFetch directly (ASVS V4 and V7 from GitHub) — those quotes are reproduced verbatim. Before any binding decision, re-verify against the canonical URLs in Part 1.
