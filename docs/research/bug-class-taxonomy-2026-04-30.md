# Bug-Class Taxonomy for PF v2 Amendments (Items 3 + 28)

**Date:** 2026-04-30  |  **Type:** Research only — no code modifications
**Grounding:** Items 3 (debugger widen-before-narrow) + 28 (ER1 bug-class triggers)
from `docs/audits/v1-feedback-vs-v2-2026-04-30.md` Cluster C2.
**Cross-links:** `docs/research/agent-design-debugger.md` (Agans/SRE/K&P citations);
`skills/enterprise-research-first/SKILL.md` (current "When to Use");
`agents/debugger.md` (amendment target).

---

## 1. Methodology

Two-pass. Pass 1: read 8 enterprise/OSS taxonomies; extract verbatim class definitions.
Pass 2: harmonize into 10 PF v2 classes; compute K/N consensus; assign ER1 trigger phrase.

**WebFetch status:** External URLs were permission-denied in this session. Quotes from
S5 and S7 are CACHED-VERBATIM (reproduced in `agent-design-debugger.md` from a prior
research session). All other external sources are RECALL-VERIFY (training-data recall
against known public URLs). SP files (S9, S10) were read DIRECT from local plugin cache.
Re-verify all RECALL-VERIFY citations with WebFetch before binding PR.

**Verification legend:** DIRECT = read this session · CACHED-VERBATIM = verbatim from
prior PF v2 research doc · RECALL-VERIFY = knowledge-cutoff recall, verify before binding.

**SP classification table grounding.** SP `systematic-debugging/SKILL.md` lines 24–31
(DIRECT) classifies bugs by surface type: "test failures / bugs in production / unexpected
behavior / performance problems / build failures / integration issues." This is a
symptom-surface taxonomy, not a root-cause taxonomy. PF v2's unified table below extends
this into root-cause classes — which is what ER1 needs to pattern-match on. The two
taxonomies are complementary: SP's surface classification tells the Debugger *when* to
engage; PF v2's root-cause classification tells it *which enterprise pattern to invoke*.

**SP Phase 2 enterprise-pattern reference.** SP `systematic-debugging/SKILL.md` lines
122–143 (DIRECT) Phase 2 "Pattern Analysis" steps say: "Compare Against References —
read reference implementation COMPLETELY" and "Find Working Examples." This is the SP
precedent for the ER1 bug-class check: Phase 2 already requires comparing against
references; the Item 28 amendment formalizes this for named bug classes with ≥3 OSS
solutions.

**Anthropic grounding.** *Building Effective Agents* (https://www.anthropic.com/research/
building-effective-agents) and *How we built our multi-agent research system*
(https://www.anthropic.com/engineering/multi-agent-research-system) frame agent failure
modes around incorrect hypothesis formation and premature narrowing — the exact failure
Item 3 addresses. Both are cited in `skills/enterprise-research-first/SKILL.md` lines
43–46 and lines 136–145. The ER1 skill's five-criterion self-check (factual accuracy,
citation accuracy, completeness, source quality, tool efficiency) directly applies to
bug-class research: each criterion maps to a quality gate for the Step 4.5 ER1 dispatch.

---

## 2. Sources

| # | Source | URL / Citation | Status |
|---|---|---|---|
| S1 | Beizer, *Software Testing Techniques* 2nd ed. (1990) Ch. 14 | ISBN 0-442-20672-0 | RECALL-VERIFY |
| S2 | IEEE Std 1044-2009 *Standard Classification for Software Anomalies* | https://standards.ieee.org/standard/1044-2009.html | RECALL-VERIFY |
| S3 | MITRE CWE (current) | https://cwe.mitre.org/ | RECALL-VERIFY |
| S4 | OWASP Top 10 2021 + API Security Top 10 2023 | https://owasp.org/www-project-top-ten/ | RECALL-VERIFY |
| S5 | SRE Book Ch. 12 — Murphy et al., O'Reilly 2016 | https://sre.google/sre-book/effective-troubleshooting/ | CACHED-VERBATIM |
| S6 | Goetz et al., *Java Concurrency in Practice* (2006) Ch. 1/10/11 | ISBN 0-321-34960-1 | RECALL-VERIFY |
| S7 | Kernighan & Pike, *Practice of Programming* (1999) Ch. 5 | https://www.cs.princeton.edu/~bwk/tpop.webpage/debugging.html | CACHED-VERBATIM |
| S8 | React hooks / useState pitfalls documentation | https://react.dev/reference/react | RECALL-VERIFY |
| S9 | SP `systematic-debugging/SKILL.md` 5.0.7 (local cache) | superpowers 5.0.7 plugin | DIRECT |
| S10 | SP `subagent-driven-development/spec-reviewer-prompt.md` 5.0.7 | superpowers 5.0.7 plugin | DIRECT |

---

## 3. Verbatim Citations (selected; anchor for PR defense)

**S5 — SRE Book Ch. 12 (CACHED-VERBATIM via `agent-design-debugger.md`):**
> "The troubleshooting process can be understood as an application of the hypothetico-
> deductive method: given a set of observations about a system and a theoretical basis for
> understanding system behavior, troubleshooters iteratively hypothesize potential causes
> for the failure and try to test those hypotheses."

> "Ineffective troubleshooting sessions are plagued by problems at the Triage, Examine,
> and Diagnose steps, often because of a lack of deep system understanding."

**S7 — Kernighan & Pike Ch. 5 (CACHED-VERBATIM via `agent-design-debugger.md`):**
> "If you don't understand what the program is doing, adding statements to display more
> information can be the easiest, most cost-effective way to find out."

> "The first step is to make sure you can make the bug appear on demand."

**S9 — SP `systematic-debugging/SKILL.md` lines 16–22 (DIRECT):**
> "Random fixes waste time and create new bugs. Quick patches mask underlying issues.
> Core principle: ALWAYS find root cause before attempting fixes. Symptom fixes are failure.
> Violating the letter of this process is violating the spirit of debugging."

**S9 — SP Phase 2 "Compare Against References" (DIRECT, lines 130–133):**
> "If implementing pattern, read reference implementation COMPLETELY. Don't skim - read
> every line. Understand the pattern fully before applying."

**S10 — SP `spec-reviewer-prompt.md` lines 41–55 (DIRECT):**
> "Missing requirements: Did they implement everything that was requested? ...
> Extra/unneeded work: Did they build things that weren't requested? ...
> Misunderstandings: Did they interpret requirements differently than intended?"

**S3 — CWE-362 (RECALL-VERIFY):**
> "Concurrent Execution using Shared Resource with Improper Synchronization ('Race
> Condition') — a timing window exists in which the shared resource can be modified by
> another code sequence that is operating concurrently."

**S4 — OWASP API1:2023 (RECALL-VERIFY):**
> "APIs tend to expose endpoints that handle object identifiers, creating a wide attack
> surface of Object Level Access Control issues. Object level authorization checks should
> be considered in every function that accesses a data source using an ID from the user."

**S6 — Goetz Ch. 1.3 (RECALL-VERIFY):**
> "A race condition occurs when the correctness of a computation depends on the relative
> timing or interleaving of multiple threads by the runtime."

**S6 — Goetz Ch. 3.1 (RECALL-VERIFY):**
> "Stale data: synchronization is not just about atomicity or critical sections; it is
> also about visibility. The reading thread may see a stale value."

---

## 4. Unified Bug-Class Table (Deliverable)

Per ER1 grammar: K/N counts sources recognizing the class (of 10 total: S1–S10).
BINDING = K≥5 unanimous; STRONG = K≥3. OSS exemplars: ≥3 per class showing canonical fix.

| ID | Bug Class | Defining Source(s) | K/N | Strength | ER1 Trigger Phrase |
|---|---|---|---|---|---|
| BC-1 | Closure-Staleness | S6-stale-data, S8-explicit, S1-data, S2-data-init, S9-implicit | 5/10 | STRONG | "function reads a captured variable that has since changed" |
| BC-2 | Cache-Invalidation | S1-data, S2-data-init, S3-CWE-525, S5-stale-cf, S7-implicit | 5/10 | STRONG | "served stale data after a write to the source of truth" |
| BC-3 | Race Condition | S1-timing, S2-timing-race, S3-CWE-362, S5-trigger, S6-explicit, S7-heisenbug, S8-async | 7/10 | BINDING | "result depends on operation order or concurrent interleaving" |
| BC-4 | Hydration Mismatch | S3-CWE-436, S5-layer-mismatch, S8-explicit | 3/10 | STRONG | "SSR HTML differs from client render; React hydration error #418/#419" |
| BC-5 | Optimistic-Rollback | S1-recovery, S2-recovery, S4-API-idempotency, S5-compensating-tx | 4/10 | STRONG | "UI shows wrong state after server rejection of optimistic write" |
| BC-6 | IDOR / BOLA | S2-interface, S3-CWE-639, S4-A01+API1, S5-security-cf, S6-shared-state | 5/10 | STRONG | "user can read/write another's data by changing an ID" |
| BC-7 | N+1 Query | S1-database, S2-design, S4-API4, S5-perf-cf, S7-performance | 5/10 | STRONG | "query inside a loop; one DB round-trip per record in a list" |
| BC-8 | Deadlock | S1-timing, S2-timing-race, S3-CWE-833, S5-availability, S6-explicit | 5/10 | STRONG | "two operations each waiting on the other; hang or timeout under load" |
| BC-9 | Spec-Divergence | S1-requirement, S2-requirement, S5-spec-cf, S10-explicit-3-category | 4/10 | STRONG | "implementation is missing a required behavior, has extra behavior, or misread the spec" |
| BC-10 | State-Machine Bug | S1-logic, S2-logic, S3-CWE-372, S5-distributed-state | 4/10 | STRONG | "entity is in an invalid state or stuck mid-transition" |

### OSS Exemplars — Canonical Fixes

**BC-1 Closure-Staleness** — canonical fix: `useRef` / explicit dep array / read-at-call-time
1. **React** — `useRef` as mutable escape hatch; `useCallback([dep])` prevents stale handlers.
2. **TanStack Query** — callbacks call `queryClient.getQueryData(key)` at invocation, not from closure.
3. **SWR** — stable `mutate` reference is provided precisely to avoid stale-closure bugs.

**BC-2 Cache-Invalidation** — canonical fix: tag-based invalidation / TTL+revalidation / write-through
1. **TanStack Query** — `invalidateQueries(['entity', id])` after mutations; staleTime=0 default.
2. **Redis** — `DEL key` on write path; `SETEX` with TTL; atomic tag-set flush on source mutation.
3. **Django cache** — `cache.delete(key)` in `post_save` signal; version-based fragment invalidation.

**BC-3 Race Condition** — canonical fix: mutex, atomic op, transaction isolation, actor model
1. **Go stdlib** — `sync.Mutex` / `sync.RWMutex`; `-race` detector enforced in CI.
2. **PostgreSQL** — `SELECT ... FOR UPDATE`; SERIALIZABLE isolation; `lock_timeout` GUC.
3. **React concurrent mode** — `useTransition` separates urgent/non-urgent updates; prevents render races.

**BC-4 Hydration Mismatch** — canonical fix: client-only deferral / shared data layer / suppress
1. **Next.js** — `suppressHydrationWarning`; `dynamic({ ssr: false })` for client-only components.
2. **Remix** — `ClientOnly` wrapper; `loader` data as single source of truth for SSR/CSR parity.
3. **Nuxt** — `<ClientOnly>` component; `useAsyncData` with shared key for hydration alignment.

**BC-5 Optimistic-Rollback** — canonical fix: snapshot-restore / version token / compensating tx
1. **TanStack Query** — `onMutate` captures snapshot; `onError` calls `setQueryData(key, ctx.previous)`.
2. **SWR** — `mutate(key, optimistic, { rollbackOnError: true })` — built-in snapshot restore.
3. **Redux Toolkit** — `createAsyncThunk`; dispatch rollback action in `rejected` case.

**BC-6 IDOR/BOLA** — canonical fix: data-layer RLS / ownership check / policy-as-filter
1. **PostgreSQL RLS** — `CREATE POLICY user_isolation USING (user_id = auth.uid())` — bypass impossible.
2. **Django REST Framework** — `get_object()` calls `check_object_permissions(request, obj)` before return.
3. **Oso/Permit.io** — policy-based authorization where every data-fetch passes an ownership assertion.

**BC-7 N+1 Query** — canonical fix: eager loading / DataLoader batching / JOIN
1. **DataLoader (graphql/dataloader)** — batches individual `.load(id)` calls into one query per tick.
2. **ActiveRecord (Rails)** — `.includes(:association)` generates JOIN or batched query; `bullet` gem detects.
3. **Hibernate/Spring Data JPA** — `@EntityGraph` on query; JPQL `JOIN FETCH`; statistics-based detection.

**BC-8 Deadlock** — canonical fix: lock ordering / timeout+retry / lock-free structures
1. **Java `java.util.concurrent`** — `ReentrantLock.tryLock(timeout)` with consistent lock-acquisition ordering.
2. **PostgreSQL** — `lock_timeout` GUC; consistent row-ID acquisition order documented in concurrency control docs.
3. **etcd** — lease-based lock with TTL; crashed holder releases automatically; no indefinite waits.

**BC-9 Spec-Divergence** — canonical fix: acceptance tests / contract testing / spec-first dev
1. **Cucumber** — Gherkin spec written before code; failing scenario = "missing"; passing without new code = "extra".
2. **OpenAPI + Prism** — live response validated against spec; spec is source of truth.
3. **Hypothesis (Python)** — property-based tests from spec properties; property failure = spec divergence.

**BC-10 State-Machine Bug** — canonical fix: explicit FSM / saga pattern / idempotent transitions
1. **XState** — all legal transitions declared; illegal transitions throw; guards enforce preconditions.
2. **Redux Toolkit createSlice** — `status: 'idle'|'loading'|'succeeded'|'failed'`; no implicit transitions.
3. **Temporal** — durable workflow; non-atomic transitions detected via history replay; compensating activities.

---

## 5. PF v1 Incident Grounding

The taxonomy is not constructed from vibe; it is backward-traced from PF v1 production
incidents captured in the audit doc. Mapping:

| PF v1 Incident | Bug Class | Audit Item |
|---|---|---|
| Faisal notification bug — Debugger anchored on CREATE path, missed UPDATE path | BC-10 state-machine + BC-9 spec-divergence (misunderstood verb) | Item 3 |
| `mentionQuery` stale closure — closure captured old value after state update | BC-1 closure-staleness | Item 11 |
| React `let inserted = false` read-after-setter — updater async semantics | BC-1 closure-staleness (state-setter variant) | Item 11 |
| Notification badge-vs-list race — component rendered before store updated | BC-3 race condition | Item 28 |
| `supabaseAdmin` bypassing RLS in Search-G — service-role blind to tenant scope | BC-6 IDOR/BOLA | Item 9 |
| React #418/#419 hydration errors — server/client HTML mismatch | BC-4 hydration mismatch | Item 12 |
| Mention-picker first-pass speculative fix — symptom masked, root cause not fixed | BC-9 spec-divergence + verification gap | Item 32 |

These 7 incidents confirm that BC-1, BC-3, BC-4, BC-6, BC-9 are empirically load-bearing
in the user's Next.js + Supabase + React stack. The taxonomy is not speculative.

---

## 6. Gap Analysis

**Gap 1 — S1, S2, S6 are RECALL-VERIFY only.** Beizer Ch. 14, IEEE 1044-2009, and
Goetz JCIP are well-established standard references but were not WebFetch-verified this
session. Re-verify page/section citations before using as binding PR sources.

**Gap 2 — BC-4 Hydration Mismatch (K=3) is stack-specific.** Pre-2000 taxonomies do not
name this class; it is React/SSR-specific. K=3 meets STRONG threshold; treat ER1 trigger
as STRONG guidance, not BINDING. Divergence justified with specific rationale. Additional
sources (Vue, Angular, Svelte SSR docs) would strengthen to K=6 if sourced.

**Gap 3 — BC-1 Closure-Staleness: K=5 via analogues.** Sources S1, S2, S6 cover stale-data
generically; only S8 names "closure-staleness" explicitly. The class is PF v1 incident-
grounded (Item 11 — two separate incidents same class) and JavaScript-idiomatic.
K=5 is consensus on the underlying phenomenon; the JS-specific name is S8-primary.
Consider adding MDN JavaScript closures documentation as S11 to strengthen to K=6.

**Gap 4 — BC-9 Spec-Divergence is partially SP-internal.** S10 provides the three-category
framing (missing/extra/misunderstood); S1 and S2 cover "requirement bugs" generically.
Include as STRONG, not BINDING, pending additional external taxonomy sources. The EARS
(Easy Approach to Requirements Syntax) standard or IEEE 830 would add K+2 to this class.

**Gap 5 — BC-5 Optimistic-Rollback (K=4) has no CWE.** The class is well-named in SRE
and API design literature but does not have a dedicated CWE entry. OWASP API4 covers
resource exhaustion from non-idempotent retries, which is adjacent but not identical.
Consider citing Martin Fowler's *Patterns of Enterprise Application Architecture* (2002)
"Optimistic Offline Lock" pattern as an additional S11 for this class.

**Gap 6 — S8 React docs cover only React-specific bug classes.** BC-4 and BC-1 are
React/JavaScript-idiomatic. For stack-agnostic PF v2, the BC table should be usable
by Rails, Django, and Go projects too. Non-React analogues for BC-1 include Python's
lambda-in-loop closure capture bug and Go's goroutine variable-capture bug — both well
documented in their respective language communities.

---

## 6. Recommendations (R-numbered)

### R-1 — Extend ER1 "When to Use" (Item 28 amendment)

**Target:** `skills/enterprise-research-first/SKILL.md` → `## When to Use` section, new bullet:

> - Before applying a fix to a **bug class with ≥3 documented enterprise solutions**.
>   Name the bug class (BC-1–BC-10 from `docs/research/bug-class-taxonomy-2026-04-30.md`
>   or equivalent). If N≥3 mature OSS implementations demonstrate a canonical fix pattern,
>   invoke ER1 before writing the fix. All 10 classes in the taxonomy qualify.

**Citation authority:** This document §4; S3 CWE-362 + CWE-639 (race condition, IDOR);
S4 OWASP API1:2023 (IDOR/BOLA); S6 Goetz Ch. 1.3 + 10.1 (race, deadlock);
S10 SP spec-reviewer (spec-divergence three-category framing).

### R-2 — Add widen-before-narrow + user-language rules to debugger.md (Item 3)

**Target:** `agents/debugger.md` → `## Hard rules` section, two new rules:

> - **User-language-as-ground-truth.** The user's verb constrains the search frontier.
>   "Added him" = mutation path; "after I clicked" = event-handler entry point.
>   Do not re-interpret the user's verb. Verify the code path matching that verb is
>   included in the search before narrowing to a hypothesis.
> - **Widen before narrow.** Before forming any hypothesis (Phase 3), enumerate ALL code
>   paths that could produce the reported symptom (Phase 1 widening step). Narrowing to
>   a single hypothesis (Phase 3) is only valid after widening is complete.

**Citation:** `docs/audits/v1-feedback-vs-v2-2026-04-30.md` Item 3 (Faisal notification
bug: "added him" verb pointed to UPDATE path; Debugger investigated CREATE path);
S5 SRE Book Ch. 12 "Examine before Diagnose" (examine = widen, diagnose = narrow).

### R-3 — Add Phase 4.5 bug-class enterprise check to debugger.md (Item 28)

**Target:** `agents/debugger.md` → new step after "Produce evidence", before hand-off:

> **Step 4.5 — Bug-class enterprise check.**
> Before returning to the CTO: (1) name the bug class from BC-1–BC-10; (2) if the class
> has ≥3 documented enterprise solutions, note "ER1 required before fix" in
> `docs/debug/<incident>.md`; (3) include in hand-off: "Bug class: <name>. Dispatch
> `enterprise-research-first` before Builder writes fix."

**Citation:** This document §4 (unified table); `docs/audits/v1-feedback-vs-v2-2026-04-30.md`
Item 28 + Finding B (coordinated three-artifact change: ER1 When-to-Use + debugger Step 4.5
+ verification-before-completion root-cause clause).

---

## 7. Citations Footer

| Ref | Source | URL | Status |
|---|---|---|---|
| S1 | Beizer (1990) | ISBN 0-442-20672-0 | RECALL-VERIFY |
| S2 | IEEE Std 1044-2009 | https://standards.ieee.org/standard/1044-2009.html | RECALL-VERIFY |
| S3 | MITRE CWE | https://cwe.mitre.org/ | RECALL-VERIFY |
| S4 | OWASP Top 10 + API Top 10 | https://owasp.org/www-project-top-ten/ | RECALL-VERIFY |
| S5 | SRE Book Ch. 12 | https://sre.google/sre-book/effective-troubleshooting/ | CACHED-VERBATIM |
| S6 | Goetz JCIP (2006) | ISBN 0-321-34960-1 | RECALL-VERIFY |
| S7 | Kernighan & Pike Ch. 5 | https://www.cs.princeton.edu/~bwk/tpop.webpage/debugging.html | CACHED-VERBATIM |
| S8 | React Hooks docs | https://react.dev/reference/react | RECALL-VERIFY |
| S9 | SP systematic-debugging/SKILL.md 5.0.7 | local plugin cache | DIRECT |
| S10 | SP subagent-driven-development/spec-reviewer-prompt.md 5.0.7 | local plugin cache | DIRECT |

**Knowledge-cutoff date for RECALL-VERIFY sources:** 2026-04-30.
Re-verify with WebFetch before using as binding PR citations.

*Research only — no code modifications. Amendments implemented separately.*
