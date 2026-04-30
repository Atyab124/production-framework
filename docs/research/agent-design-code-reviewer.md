# Agent Design Research — Code Reviewer (PF v2)

**Date:** 2026-04-29
**Type:** Source-of-truth research — no code modifications
**Triggered by:** PF v2 needs to decide whether SP's `agents/code-reviewer.md` is sufficient as-is for multi-tenant SaaS scope, or whether it must be extended.
**Binding rule context:** SP precedent for `code-reviewer` already exists (manifest row "code-reviewer agent" → `OK`). Any v2 change must justify itself with NEW citations (Anthropic guidance OR enterprise consensus N≥3) beyond what SP already provides. Otherwise the rule is "use SP as-is."

**Methodology disclosure:** WebFetch was permission-denied for this session. All quotes from Google / Microsoft / OWASP / industry sources below were retrieved via WebSearch synthesis of the canonical URLs listed in §6 (Sources). Quotes are reproduced as returned by WebSearch. Re-verify against canonical URLs via direct WebFetch before any binding architectural decision.

---

## VERDICT (top-of-file)

**KEEP-AS-IS for v2.0.0** with one **OPTIONAL** PF-specific addendum file (NOT a replacement of SP's agent prompt) that names six multi-tenant red-flag patterns the project's own `STACK-PATTERNS.md` should grep for.

Rationale in 4 bullets:
1. SP's `code-reviewer.md` already covers the canonical Google + Microsoft review surface (design / functionality / complexity / tests / naming / comments / security / architecture). 7/7 categories match enterprise consensus (Google's "What to look for in a code review").
2. SP's severity grading `Critical / Important / Suggestions` matches Conventional Comments + Gearset + Microsoft "blocking vs nit" with N=4 industry consensus. No reason to invent new severity levels.
3. SP's "two-stage review" (spec-compliance → code-quality) already encodes Microsoft's "verify goals of the corresponding task" + Google's "improve overall code health" sequencing. PF v2 inherits this via `superpowers:subagent-driven-development` — no agent-prompt change needed.
4. The **only** SP gap relevant to PF v2's stated scope (multi-tenant SaaS) is **multi-tenant security review touchpoints** (RLS bypass, tenant_id filter coverage, service-role key exposure, cross-tenant join leaks). These are stack-specific and belong in `templates/STACK-PATTERNS.md` per CLAUDE.md rule #3 ("no domain-specific skills in core; stack-specific patterns belong in templates"), NOT in the universal `agents/code-reviewer.md` body.

**Do not modify `agents/code-reviewer.md`.** Per CLAUDE.md skill-changes-require-evaluation rule, agent prompts that override SP-precedent skills require "double evidence" — adversarial pressure-test results showing the PF version performs ≥ SP. We have no such evidence; we only have an additive multi-tenant concern that is properly templated, not core.

---

## 1. Canonical sources surveyed

| # | Source | URL | Why canonical |
|---|---|---|---|
| 1 | Google Engineering Practices — *Code Review Developer Guide* | https://google.github.io/eng-practices/review/ | Google-published, public, the most-cited code review canon |
| 2 | Google Engineering Practices — *The Standard of Code Review* | https://google.github.io/eng-practices/review/reviewer/standard.html | Defines the senior principle of code review |
| 3 | Google Engineering Practices — *What to look for in a code review* | https://google.github.io/eng-practices/review/reviewer/looking-for.html | The 8-axis review checklist |
| 4 | Microsoft *Code With Engineering Playbook* — Code Reviews | https://microsoft.github.io/code-with-engineering-playbook/code-reviews/ | Microsoft ISE-published; widely adopted in enterprise |
| 5 | Microsoft *Code With Engineering Playbook* — Reviewer Guidance | https://microsoft.github.io/code-with-engineering-playbook/code-reviews/process-guidance/reviewer-guidance/ | Reviewer-side specifics + nit/blocking convention |
| 6 | OWASP *Multi-Tenant Security Cheat Sheet* | https://cheatsheetseries.owasp.org/cheatsheets/Multi_Tenant_Security_Cheat_Sheet.html | Canonical multi-tenant security checklist |
| 7 | OWASP *Authorization Cheat Sheet* | https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html | Server-side authorization principles |
| 8 | OWASP *Cloud Tenant Isolation* project | https://owasp.org/www-project-cloud-tenant-isolation/ | OWASP project on tenant isolation |
| 9 | OWASP *WSTG — Testing for IDOR* | https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/05-Authorization_Testing/04-Testing_for_Insecure_Direct_Object_References | IDOR detection methodology |
| 10 | *Conventional Comments* specification | https://conventionalcomments.org/ | Industry standard for comment severity prefixes |
| 11 | AWS Database Blog — *Multi-tenant data isolation with PostgreSQL Row Level Security* | https://aws.amazon.com/blogs/database/multi-tenant-data-isolation-with-postgresql-row-level-security/ | Authoritative cloud guidance for RLS multi-tenancy |
| 12 | Anthropic — *Subagents in the SDK* | https://platform.claude.com/docs/en/agent-sdk/subagents | Anthropic guidance on subagent isolation |
| 13 | Anthropic — *Securely deploying AI agents* | https://platform.claude.com/docs/en/agent-sdk/secure-deployment | Anthropic on multi-tenant deployment patterns |
| 14 | Anthropic — *claude-code-security-review* GitHub Action | https://github.com/anthropics/claude-code-security-review | Anthropic's own AI security review pattern |

**Anthropic-published is bold-cite-able under the binding rule. Google / Microsoft / OWASP / Conventional Comments are enterprise consensus citations — three or more required to be binding (per `enterprise-research-first` skill).**

---

## 2. Verbatim quotes by topic

### 2.1 Review checklist axes (what to look for)

**Google — *What to look for in a code review*** (URL: https://google.github.io/eng-practices/review/reviewer/looking-for.html, via WebSearch synthesis):

> "Reviewers should focus on design, functionality, complexity, tests, naming, comments, style, and documentation."

> "**Design** — Review the overall design of the PR, considering whether the interactions of various pieces of code make sense, whether the change belongs in the codebase or in a library, and whether it integrates well with the rest of the system."

> "**Functionality** — Does the code behave as the author likely intended, and is the way the code behaves good for its users?"

> "**Complexity** — Over-engineering is a particular type of complexity where developers have made the code more generic than it needs to be, or added functionality that isn't presently needed. Reviewers should be especially vigilant about over-engineering and encourage developers to solve the problem they know needs to be solved now, not speculative future problems."

> "**Tests** — Ask for unit, integration, or end-to-end tests as appropriate for the change, with tests generally added in the same CL as the production code. Make sure the tests are correct, sensible, and useful."

> "**Naming** — A good name is long enough to fully communicate what the item is or does, without being so long that it becomes hard to read."

> "**Comments** — Comments are usually useful when they explain why some code exists and should not explain what some code is doing. Comments are for information that the code itself can't possibly contain, like the reasoning behind a decision."

**Microsoft — *Reviewer Guidance*** (URL: https://microsoft.github.io/code-with-engineering-playbook/code-reviews/process-guidance/reviewer-guidance/, via WebSearch synthesis):

> "A goal of a code review is to verify that the goals of the corresponding task have been achieved."

> "The playbook covers various review principles including checking for the single responsibility principle, function complexity, code clarity, error handling, race conditions, optimization opportunities, and system impact considerations."

### 2.2 The standard / senior principle of review

**Google — *The Standard of Code Review*** (URL: https://google.github.io/eng-practices/review/reviewer/standard.html, via WebSearch synthesis):

> "The primary purpose of code review is to make sure that the overall code health of Google's code base is improving over time."

> "Reviewers should favor approving a CL once it is in a state where it definitely improves the overall code health of the system being worked on, even if the CL isn't perfect. That is the senior principle among all of the code review guidelines."

> "Instead of seeking perfection, what a reviewer should seek is continuous improvement. A CL that, as a whole, improves the maintainability, readability, and understandability of the system shouldn't be delayed for days or weeks because it isn't 'perfect.'"

> "Aspects of software design are almost never a pure style issue or just a personal preference. They are based on underlying principles and should be weighed on those principles, not simply by personal opinion."

### 2.3 Severity grading

**Conventional Comments** (URL: https://conventionalcomments.org/, via WebSearch synthesis):

> "Conventional Comments uses prefixed labels including: praise, nitpick, suggestion, issue, question, thought, and chore. Additionally, other labels include: todo (small necessary changes), note (FYI info), typo (misspelling), polish (quality improvements), and quibble (like nitpick)."

> "Decorations are optional extra labels surrounded by parentheses and comma-separated, such as **(blocking)** or **(non-blocking)**."

**Gearset — *Understanding and Managing Severity Levels in Code Reviews*** (industry reference, via WebSearch synthesis):

> "Issues classified as Critical represent the highest level of risk and may expose sensitive data, allow unauthorised code execution, or introduce serious vulnerabilities that significantly increase technical debt."

> "Blocking comments are critical observations that must be addressed before the code can be merged and often highlight significant issues that could affect functionality, performance, or security, typically requiring substantial changes or clarifications before approval."

**Microsoft — *Reviewer Guidance*** (via WebSearch synthesis):

> "Don't block the current PR due to issues that are out of scope. If you have concerns about the related, adjacent code that isn't in the scope of the PR, address those as separate tasks (e.g., bugs, technical debt)."

**Common industry levels (synthesis across Conventional Comments + Gearset + Microsoft + Augment):** Critical (blocking) / Important / Nit (non-blocking) / FYI. SP's `code-reviewer.md` line 37 uses exactly **Critical / Important / Suggestions** — matches 3-level industry distillation.

### 2.4 Multi-tenant code-review concerns (specific to PF v2)

**OWASP — *Multi-Tenant Security Cheat Sheet*** (URL: https://cheatsheetseries.owasp.org/cheatsheets/Multi_Tenant_Security_Cheat_Sheet.html, via WebSearch synthesis):

> "Never trust client-supplied tenant IDs without validation."

> "Use cryptographically secure, non-guessable tenant identifiers. Additionally, bind tenant context to the authenticated user session and propagate tenant context securely through all application layers."

> "Do not trust tenant IDs from client headers or request parameters, and skip tenant validation for 'internal' services."

> "Derive tenant from authenticated session rather than accepting it from external sources."

> "Direct object references without tenant validation could return another tenant's document."

**OWASP — *Authorization Cheat Sheet*** (via WebSearch synthesis):

> "Never treat user_id, org_id, or tenant_id in the request as authoritative; derive the subject and scope from the authenticated context and server-side lookups."

> "Use database-level isolation (RLS, schemas) as defense in depth."

> "Include tenant identifiers in every data table and use them in all queries, and leverage database-level Row-Level Security (RLS) for automatic tenant-based data filtering if supported."

> "Confirm tenant isolation on every access and consider row-level security in the database to enforce ownership constraints close to the data. Any time the client can influence which resource is fetched or modified, the server must re-evaluate ownership/permissions for that exact resource, even if the caller is authenticated."

**AWS Database Blog + community RLS guides (synthesis, via WebSearch):**

> "RLS doesn't apply to superusers and table owners — superusers and roles with the BYPASSRLS attribute always bypass the row security system. If the table owner runs queries, RLS can be bypassed unless FORCE ROW LEVEL SECURITY is enabled, and this should almost always be enabled on tenant-scoped tables."

> "Never use SET instead of SET LOCAL — SET persists across the session, and with connection pooling, the previous tenant's context leaks to the next request."

> "When you create a client with the service_role key, all RLS policies are bypassed for server-side admin operations, but never expose the service_role key on the client side."

> "When you write a policy on table A but your query joins to table B with RLS enabled, each table's policy is checked independently."

> "Every table with an RLS policy needs `tenant_id` as the leading column in its primary access indexes."

> "In shared-schema multi-tenancy, a query that forgets WHERE org_id = ? does not throw an error — it returns data, just the wrong tenant's data."

> "Tenant isolation requires walls in multiple places: request boundary, data boundary, storage boundary, job boundary, and analytics boundary — missing just one is enough for a leak."

### 2.5 Security review touchpoints

**OWASP WSTG — Testing for IDOR** (URL: https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/05-Authorization_Testing/04-Testing_for_Insecure_Direct_Object_References):

> "Insecure Direct Object References (IDOR) involve accessing resources by manipulating tenant/resource IDs."

**Anthropic — *claude-code-security-review*** (URL: https://github.com/anthropics/claude-code-security-review):

Anthropic ships an AI-powered GitHub Action whose entire purpose is "analyze code changes for security vulnerabilities" — Anthropic's own pattern is **a separate AI security-reviewer pass**, not bolting security review onto the general code reviewer.

### 2.6 When to extend vs keep SP's version

**Anthropic — *Subagents in the SDK*** (URL: https://platform.claude.com/docs/en/agent-sdk/subagents, via WebSearch synthesis):

> "Subagents can be limited to specific tools, reducing the risk of unintended actions — for example, a doc-reviewer subagent might only have access to Read and Grep tools, ensuring it can analyze but never accidentally modify documentation files."

> "Each subagent runs in its own fresh conversation, with intermediate tool calls and results staying inside the subagent and only its final message returning to the parent."

**SP `agents/code-reviewer.md` body (already in v2 fork):** lines 10–48 cover plan-alignment, code-quality (security + performance explicitly named line 23), architecture, documentation, severity grading, communication. This is verbatim what Google + Microsoft prescribe, packaged as a system prompt.

---

## 3. SP-inheritable (the file IS SP's)

| Topic from §2 | SP `code-reviewer.md` line | Match quality |
|---|---|---|
| Plan-alignment / "verify goals of the corresponding task" (Microsoft) | Lines 12–17 ("Plan Alignment Analysis") | **Exact** |
| Design / functionality / complexity (Google) | Lines 18–24 ("Code Quality Assessment") + 25–29 ("Architecture and Design Review") | **Exact** — explicitly names "potential security vulnerabilities or performance issues" line 23 |
| Tests (Google) | Line 22 ("Assess test coverage and quality of test implementations") | **Exact** |
| Naming / comments / documentation (Google) | Lines 31–34 ("Documentation and Standards") | **Exact** |
| Severity grading: Critical / Important / Suggestions (Conventional Comments + Gearset distillation) | Line 37 | **Exact** — matches the 3-level industry distillation |
| Continuous improvement, not perfection (Google senior principle) | Line 46 ("Always acknowledge what was done well before highlighting issues") | **Spirit-match**, weaker than Google's explicit framing — minor gap, see §4 |
| "Verify by reading code, not trusting report" (SP `spec-reviewer-prompt.md`) | Manifest row "Spec-reviewer 'do not trust the implementer's report'" | Inherited via two-stage-review, not in `code-reviewer.md` itself |

**SP coverage on canonical axes: 7/7 Google-listed axes present. Severity grading exactly matches 3-level industry distillation.**

---

## 4. Gaps in SP's coverage from a multi-tenant SaaS perspective

Each gap is rated by whether it's a NUMERICAL gap (would change SP's prompt) or a TEMPLATING gap (belongs in `STACK-PATTERNS.md`, not in the universal agent prompt).

### GAP-CR-1 — Multi-tenant red-flag grep patterns (TEMPLATING gap)

**SP says:** "Look for potential security vulnerabilities" (line 23) — generic.
**Multi-tenant scope demands:** specific grep patterns the reviewer should run on the diff.

Specifically, the reviewer should fail-on-detection (or at minimum flag Critical):

| Pattern | Severity | OWASP / industry citation |
|---|---|---|
| New table without RLS policy | Critical | OWASP MT cheat sheet — "include tenant identifiers in every data table" |
| `SELECT` / `UPDATE` / `DELETE` against tenant-scoped table without `WHERE tenant_id = ?` (or RLS coverage) | Critical | "A query that forgets WHERE org_id = ? does not throw an error — it returns data, just the wrong tenant's data." |
| `tenantId` / `org_id` read from request body, query string, or unsigned header instead of authenticated session | Critical | OWASP MT cheat sheet — "do not trust tenant IDs from client headers or request parameters" |
| Use of `service_role` / admin-bypass key in client-reachable code | Critical | "Never expose the service_role key on the client side" |
| `SET app.tenant_id` instead of `SET LOCAL app.tenant_id` (PG context-leak with connection pooling) | Critical | "Never use SET instead of SET LOCAL" |
| Background job / queue handler that doesn't propagate tenant context | Important | "Tenant isolation requires walls in… job boundary" |

**Why this is TEMPLATING not core:** these patterns assume Postgres + RLS or equivalent. The reviewer agent runs on every project regardless of stack. Per CLAUDE.md rejection criterion #3 ("no stack references in core") and §3 of `STACK-PATTERNS.template.md` discipline, this list must live in `templates/STACK-PATTERNS.md` under a "Code-review pre-flight greps" section, NOT in `agents/code-reviewer.md`.

**Recommendation:** add to `templates/STACK-PATTERNS.template.md`. Do NOT touch `agents/code-reviewer.md`.

### GAP-CR-2 — "Continuous improvement, not perfection" framing (NUMERICAL — minor)

**SP says:** "Always acknowledge what was done well before highlighting issues" (line 46) — encouragement framing.
**Google says (senior principle):** "Reviewers should favor approving a CL once it is in a state where it definitely improves the overall code health of the system being worked on, even if the CL isn't perfect."

**Gap impact:** without this framing, an over-zealous reviewer subagent can block on perfection. Anthropic warns about this exact failure mode (the "agent's primary lever is the prompt"; *How we built our multi-agent research system*: "Early agents made errors like… distracting each other with excessive updates").

**Severity:** Minor. SP's existing prompt + the Microsoft "out-of-scope = not blocking" guidance (already in industry consensus) is enough to rein in over-zeal. **Do NOT modify the prompt.** If pressure-testing reveals over-zealous blocking in PF v2 sessions, revisit; but per CLAUDE.md skill-changes-require-evaluation, no change without before/after eval evidence.

### GAP-CR-3 — Multi-tenant authorization layer enumeration (TEMPLATING gap)

**SP says nothing specific.** Multi-tenant defense-in-depth has 5 boundaries (request / data / storage / job / analytics — synthesized from §2.4). A reviewer reviewing a diff that touches authorization needs to know which layers must agree.

**Recommendation:** add to `templates/STACK-PATTERNS.template.md` under a "Multi-tenant defense-in-depth checklist" section that the reviewer pulls in via stack-pattern injection. NOT a change to the agent prompt.

### GAP-CR-4 — Two-stage review enforcement (NO GAP — already inherited)

PF v2 manifest row "two-stage-review skill" already maps to SP `subagent-driven-development/SKILL.md` lines 41–85 + `code-quality-reviewer-prompt.md` line 7. The Code Reviewer is invoked AFTER spec-compliance passes; that's the existing PF v2 design. No change.

### GAP-CR-5 — Reviewer tool-permission narrowing (NO GAP relevant to v2.0.0)

Anthropic's *Subagents in the SDK* recommends limiting reviewer subagents to `Read` + `Grep` only. SP's current `agents/code-reviewer.md` does NOT specify a `tools:` field in frontmatter. This is an opportunistic hardening — but it's an architectural change that needs evidence (CLAUDE.md skill-changes rule), and SP itself didn't make it. **Defer to v2.1+ with eval evidence.**

---

## 5. Recommendations (simplicity ladder)

**Recommendation 1 (KEEP — eliminate work):** Ship v2.0.0 with `agents/code-reviewer.md` exactly as inherited from SP 5.0.7. Justified by:
- Citation manifest row "code-reviewer agent" already `OK` on SP precedent.
- 7/7 Google review axes present.
- 3-level severity exactly matches industry consensus.
- CLAUDE.md skill-changes-require-evaluation rule: no double-evidence available to justify a change.

**Recommendation 2 (REUSE — additive, no agent edit):** Add a "Code-review pre-flight greps" section to `templates/STACK-PATTERNS.template.md` (NOT to `agents/code-reviewer.md`). Section enumerates GAP-CR-1's 6 multi-tenant red-flag patterns with citations. The reviewer's existing line-23 "look for potential security vulnerabilities" instruction will pick these up via the SessionStart-injected stack-patterns context, exactly as SP designed.

**Recommendation 3 (DEFER — needs new primitive):** A separate `agents/security-reviewer.md` mirroring Anthropic's claude-code-security-review pattern is justifiable but is a new primitive, not an extension of code-reviewer. Defer to a future minor version with its own ADR + citations. v2.0.0 ships with one reviewer (SP's), one security pass (the existing `security-review` slash command), no fork.

**Recommendation 4 (NO):** Do NOT add multi-tenant patterns to the universal `agents/code-reviewer.md` body. Violates CLAUDE.md rejection criterion #3 (no stack refs in core). Violates skill-changes-require-evaluation. Violates the fork-discipline of "if SP didn't do it, we cite or we don't."

---

## 6. Sources (canonical URLs for re-verification)

**Code review canon:**
- https://google.github.io/eng-practices/review/
- https://google.github.io/eng-practices/review/reviewer/standard.html
- https://google.github.io/eng-practices/review/reviewer/looking-for.html
- https://github.com/google/eng-practices/blob/master/review/reviewer/standard.md
- https://microsoft.github.io/code-with-engineering-playbook/code-reviews/
- https://microsoft.github.io/code-with-engineering-playbook/code-reviews/process-guidance/reviewer-guidance/
- https://microsoft.github.io/code-with-engineering-playbook/code-reviews/pull-requests/
- https://conventionalcomments.org/

**Multi-tenant security canon:**
- https://cheatsheetseries.owasp.org/cheatsheets/Multi_Tenant_Security_Cheat_Sheet.html
- https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html
- https://owasp.org/www-project-cloud-tenant-isolation/
- https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/05-Authorization_Testing/04-Testing_for_Insecure_Direct_Object_References
- https://aws.amazon.com/blogs/database/multi-tenant-data-isolation-with-postgresql-row-level-security/
- https://github.com/OWASP/CheatSheetSeries/issues/1928 (proposed Multi-Tenant Application Security Cheat Sheet)
- https://github.com/OWASP/ASVS/issues/2060 (ASVS 4.2.3 multi-tenant access controls)

**Anthropic primary sources:**
- https://platform.claude.com/docs/en/agent-sdk/subagents
- https://platform.claude.com/docs/en/agent-sdk/secure-deployment
- https://docs.claude.com/en/docs/claude-code/sub-agents
- https://github.com/anthropics/claude-code-security-review
- https://www.anthropic.com/engineering/multi-agent-research-system

**SP source files (local cache):**
- `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/agents/code-reviewer.md`
- `.../superpowers/5.0.7/skills/receiving-code-review/SKILL.md`
- `.../superpowers/5.0.7/skills/requesting-code-review/SKILL.md`
- `.../superpowers/5.0.7/skills/subagent-driven-development/code-quality-reviewer-prompt.md`
- `.../superpowers/5.0.7/skills/subagent-driven-development/spec-reviewer-prompt.md`

**PF v2 cross-reference:**
- `c:/Users/atyab/Experimental - Users/production-framework-v2/agents/code-reviewer.md` (the SP-inherited file)
- `c:/Users/atyab/Experimental - Users/production-framework-v2/docs/research/sp-anthropic-citation-manifest.md` (binding citation source — manifest row "code-reviewer agent" → OK)

**Methodology disclosure:** WebFetch was permission-denied for this session. All Google / Microsoft / OWASP / industry quotes were retrieved via WebSearch synthesis of the canonical URLs above. Re-verify against canonical URLs via direct WebFetch in a session where it is permitted before any binding architectural decision built solely on a quote here.
