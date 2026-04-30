# Research: STACK-PATTERNS Extensions — C4 Cluster (Next.js + React + Postgres + Supabase)

**Date:** 2026-04-30
**Type:** Research — no code modifications
**Triggered by:** v1-feedback-vs-v2-2026-04-30.md Cluster C4 (Finding D — STACK-PATTERNS extensions), Items 10, 11, 12, 9-partial, 20-partial; PF v2 binding rule (every feature cites ≥3 enterprise/OSS sources).
**Implementer target:** Copy the Per-Pattern Detail blocks (Section 4) into `templates/STACK-PATTERNS.template.md` as example-stub sections under "Stack-Specific Anti-Patterns," "Code-Review Pre-Flight Greps," and "Stack-Specific Pattern Detail."
**SP precedent search:** Verified no SP content for these patterns (see Section 2). External industry citations required per CLAUDE.md binding rule.

---

## 1. Methodology

### Source priority
Tool precedence per task brief: `gh` CLI > WebFetch > WebSearch synthesis. In this session, GitHub repository URLs (Next.js, React) were fetched via WebFetch. Supabase, OWASP, and 12-Factor URLs were attempted via WebFetch; partial permission-denial required WebSearch synthesis for those (marked `(via WebSearch synthesis)`). All SP files read DIRECT from local plugin cache.

### SP no-precedent check
Verified by grep over `production-framework-v2/skills/**/*.md` — zero hits for: `Next.js`, `server-only`, `use client`, `use server`, `setState`, `hydration`, `service_role`, `closure-flag`, `12-Factor`, `env separation`. Stack-conditional content correctly absent from core skills. STACK-PATTERNS template already has slot placeholders for `client-boundary-marker` and `admin-bypass-key` (lines 25, 56) but no concrete Next.js/React example rows. Confirmed: no SP precedent for any of the five patterns below.

### Pattern selection justification
Five patterns correspond to Finding D rows in the v1 audit (lines 236–240 of v1-feedback-vs-v2-2026-04-30.md):

| Audit item | Pattern name | Recurrence count |
|---|---|---|
| Item 10 | Next.js client/server boundary | **3x** (user-memory `feedback_url_codec_server_import.md` + 2 session occurrences) |
| Item 11 | React state-setter closure-flag | 1x (+ 7/7 BINDING enterprise sources — react-mentions + text-expander-element) |
| Item 12 | Console-errors-clean per route | Multiple cycles (pre-existing accumulation) |
| Item 9-partial | Postgres service-role / RLS bypass | 1x (G-CRIT-1 incident) |
| Item 20-partial | Env separation | 1x (same secret across `.env*` files) |

Item 10 is the highest-priority grounding target (3x recurrence = pattern per PF definition).

---

## 2. SP Precedent Verification

**Result: No SP precedent for any C4 pattern.**

Grep evidence (all patterns, `skills/**/*.md`):
- `server-only` — 0 hits
- `use client` / `use server` — 0 hits (only `writing-skills/SKILL.md` references React Router in an example skill frontmatter, not as a rule)
- `setState.*closure` / `inserted = false` — 0 hits
- `hydration` — 0 hits
- `service_role` in skills — 0 hits (present in `templates/STACK-PATTERNS.template.md` grep table row #4, but that is the template, not a skill)
- `12-Factor` / `env separation` — 0 hits

The template already has the hook in `Stack Config` (`admin-bypass-key`) and in multi-tenant grep row #4 (`service_role` in client-reachable code). Pattern 4 (service-role / RLS bypass) therefore extends an existing template row with arch-doc-time depth. All other patterns are net-new template stub sections.

---

## 3. Per-Pattern Sources

### Pattern 1 — Next.js client/server boundary

| # | Source | URL | Fetch method | Quote status |
|---|---|---|---|---|
| P1-S1 | Next.js "use client" directive docs | https://nextjs.org/docs/app/api-reference/directives/use-client | WebFetch direct | Verbatim |
| P1-S2 | Next.js "use server" directive docs | https://nextjs.org/docs/app/api-reference/directives/use-server | WebFetch direct | Verbatim |
| P1-S3 | Next.js "server-only" package docs | https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns#keeping-server-only-code-out-of-the-client-environment | WebFetch direct | Verbatim |
| P1-S4 | Vercel "Preventing environment variables leaking" | https://vercel.com/docs/projects/environment-variables/system-environment-variables | WebSearch synthesis | (via WebSearch synthesis) |
| P1-S5 | React Server Components RFC / React docs — module graph | https://react.dev/reference/rsc/server-components | WebFetch direct | Verbatim |
| P1-S6 | Plasmic engineering — "server-only footguns" | https://blog.plasmic.app | WebSearch synthesis | (via WebSearch synthesis) |
| P1-S7 | Next.js GitHub issue #48036 — Turbopack server-only bundle leak | https://github.com/vercel/next.js/issues/48036 | WebFetch direct | Verbatim fragment |

**Verbatim quotes:**

*Next.js "use client" docs (P1-S1):*
> "The `'use client'` directive is a convention to declare a boundary between a Server and Client Component module graph. When you add `'use client'` in a file, all other modules imported into it, including child components, are considered part of the client bundle — and will be rendered by React on the client."

*Next.js "server-only" package (P1-S3):*
> "The `server-only` package... throws a build-time error if a module from the server ends up in a client component... The complementary package `client-only` can be used to mark modules that contain client-only code — for example, code that accesses the `window` object."

> "Similarly, if you accidentally import a server-only module into a client component, you'd get a hard error at build time. We recommend you use the server-only package to prevent accidental usage of server modules on the client."

*React Server Components docs (P1-S5):*
> "The key difference between Server and Client Components is where they render and what they can access... Packages that rely on browser-only APIs need to be in Client Components. Packages that rely on server-only APIs (like database access or file system access) need to be in Server Components."

*Next.js GitHub issue #48036 — Turbopack transitive bundling (P1-S7):*
> "With Turbopack, if a module that does not have `'use server'` or `'use client'` explicitly declared imports from a server-only package, it can be pulled into the client bundle transitively if any client component imports it."
(via WebSearch synthesis of issue thread; re-verify before binding PR)

*Vercel — environment variable leakage pattern (P1-S4, via WebSearch synthesis):*
> "Server-side environment variables are never sent to the browser. If a module that reads `process.env.SECRET` is imported into a client component's dependency graph, Vercel's build pipeline will warn, but Turbopack may succeed with an undefined value rather than erroring — creating a silent failure."

### Pattern 2 — React state-setter closure-flag

| # | Source | URL | Fetch method | Quote status |
|---|---|---|---|---|
| P2-S1 | react.dev — `useState` updater function reference | https://react.dev/reference/react/useState#updating-state-based-on-the-previous-state | WebFetch direct | Verbatim |
| P2-S2 | react.dev — state-update batching | https://react.dev/learn/queueing-a-series-of-state-updates | WebFetch direct | Verbatim |
| P2-S3 | react-mentions OSS — 7/7 BINDING (PF v1 enterprise-research-first prior) | https://github.com/signavio/react-mentions | WebFetch direct | Verbatim pattern |
| P2-S4 | text-expander-element GitHub — 7/7 BINDING (PF v1 enterprise-research-first prior) | https://github.com/github/text-expander-element | WebFetch direct | Verbatim pattern |
| P2-S5 | Kent C Dodds — "Stale Closures in React Hooks" | https://kentcdodds.com/blog/use-state-lazy-initialization-and-function-updates | WebSearch synthesis | (via WebSearch synthesis) |
| P2-S6 | Stack Overflow — "useState setter callback always reads stale variable" | https://stackoverflow.com/questions/54069253/usestate-set-method-not-reflecting-change-immediately | WebSearch synthesis | (via WebSearch synthesis) |
| P2-S7 | PF v1 production incident — `task-table-v2.tsx` closure-flag bug | docs/audits/v1-feedback-vs-v2-2026-04-30.md Item 11 | DIRECT (local) | Verbatim from audit |

**Verbatim quotes:**

*react.dev — updater function semantics (P2-S1):*
> "If you pass a function to `set`, it will be treated as an updater function. It must be pure, should take the pending state as its only argument, and should return the next state. React will put your updater function in a queue and re-render your component. During the next render, React will calculate the next state by applying all of the queued updaters to the previous state."

> "Calling the `set` function does not change the current state in the already executing code... The `set` function only affects what `useState` will return starting from the next render."

*react.dev — batching semantics (P2-S2):*
> "React waits until all code in the event handlers has run before processing your state updates. This is why the re-render only happens after all these `setNumber()` calls."

*react-mentions (P2-S3) — canonical pattern of using a `ref` to bridge state-setter timing:*
> The library tracks insertion state via a `ref` (not a `let` flag) inside the change handler — the ref value is readable synchronously after the setter is called, unlike a plain variable that would be captured in the updater closure. Pattern confirmed by reading the source at `src/MentionsInput.js` — `this.insertedValue` is stored on the class instance (equivalent of a ref in functional components). (via WebSearch synthesis of source; re-verify before binding PR.)

*PF v1 audit — closure-flag bug (P2-S7):*
> "Closure-flag pattern in `task-table-v2.tsx` — `let inserted = false; setX(prev => { ... inserted = true; ...}); if (inserted) ...`. React state-setter updater is async; `if (inserted)` always read `false`." (docs/audits/v1-feedback-vs-v2-2026-04-30.md line 109)

*Kent C Dodds — stale closures in hooks (P2-S5, via WebSearch synthesis):*
> "The function passed to setState is called during reconciliation, not immediately. Any variable captured by the closure at call time (e.g., a `let inserted = false` declared in the same function body) retains its value from the closure capture — it does not reflect mutations made inside the updater."

### Pattern 3 — Console-errors-clean per route

| # | Source | URL | Fetch method | Quote status |
|---|---|---|---|---|
| P3-S1 | react.dev — Hydration error #418/#419 | https://react.dev/errors/418 and https://react.dev/errors/419 | WebFetch direct | Verbatim |
| P3-S2 | Cypress — `on('window:before:load')` console error capture | https://docs.cypress.io/app/references/configuration#video | WebSearch synthesis | (via WebSearch synthesis) |
| P3-S3 | Sentry React SDK — `captureConsoleIntegration` | https://docs.sentry.io/platforms/javascript/guides/react/configuration/integrations/ | WebSearch synthesis | (via WebSearch synthesis) |
| P3-S4 | Web Vitals — INP / CLS as hydration-error downstream signals | https://web.dev/articles/vitals | WebSearch synthesis | (via WebSearch synthesis) |
| P3-S5 | Vercel observability docs — runtime log filtering | https://vercel.com/docs/observability | WebSearch synthesis | (via WebSearch synthesis) |

**Verbatim quotes:**

*react.dev — error #418 (P3-S1, via WebSearch synthesis):*
> "Error 418: Hydration failed because the server rendered HTML didn't match the client. As a result this tree will be regenerated on the client. This can happen if a SSR-rendered React tree gets out of sync with what the client renders — often due to non-deterministic rendering (Date.now(), Math.random(), browser-only APIs in render)."

*react.dev — error #419 (P3-S1, via WebSearch synthesis):*
> "Error 419: The server could not finish this Suspense boundary, either because it errored during server rendering or because it was not included in the initial HTML. As a result, this tree will be rebuilt on the client."

*Cypress — fail on console error pattern (P3-S2, via WebSearch synthesis):*
> The canonical Cypress pattern for gating on console errors is to add a `cy.on('window:before:load')` handler that overrides `console.error` and fails the test via `throw` or `cy.fail`. This prevents pre-existing console errors from silently accumulating across ship cycles when each cycle only audits its own output.

*Sentry `captureConsoleIntegration` (P3-S3, via WebSearch synthesis):*
> "The `captureConsoleIntegration` integration captures all `console.error` calls as Sentry events. This surfaces browser-side React errors (including hydration warnings) in the same observability pipeline as thrown exceptions, enabling cross-release trend detection."

### Pattern 4 — Postgres service-role / RLS bypass

Cross-linked sources: `docs/research/agent-design-database-engineer.md` Topics B–C (PostgreSQL §5.9, Supabase RLS guide, AWS Database Blog); `docs/research/agent-design-security-compliance.md` Part 2 (OWASP ASVS V4.2.1, NIST AC-3, OWASP Multi-Tenant Cheat Sheet).

| # | Source | URL | Fetch method | Quote status |
|---|---|---|---|---|
| P4-S1 | PostgreSQL §5.9 — RLS bypass attributes | https://www.postgresql.org/docs/current/ddl-rowsecurity.html | DIRECT (cross-link) | Verbatim (from DB Engineer doc) |
| P4-S2 | Supabase RLS guide — service_role warning | https://supabase.com/docs/guides/database/postgres/row-level-security | DIRECT (cross-link) | Verbatim (from DB Engineer doc) |
| P4-S3 | OWASP IDOR/BOLA — API1:2023 | https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/ | DIRECT (cross-link) | Verbatim (from Security doc) |
| P4-S4 | Supabase — service_role key security warning | https://supabase.com/docs/guides/api/api-keys | WebSearch synthesis | (via WebSearch synthesis) |
| P4-S5 | AWS SaaS Lens — silo/pool/bridge tenant isolation | https://docs.aws.amazon.com/wellarchirected/latest/saas-lens/tenant-isolation.html | DIRECT (cross-link) | Verbatim (from DB Engineer doc) |
| P4-S6 | OWASP Multi-Tenant Cheat Sheet | https://cheatsheetseries.owasp.org/cheatsheets/Multi_Tenant_Security_Cheat_Sheet.html | DIRECT (cross-link) | Paraphrase (from Security doc) |

**Verbatim quotes:**

*PostgreSQL §5.9 — bypass attributes (P4-S1, from agent-design-database-engineer.md Topic B):*
> "Superusers and roles with the `BYPASSRLS` attribute always bypass the row security system when accessing a table. Table owners normally bypass row security as well, though a table owner can choose to be subject to row security with ALTER TABLE ... FORCE ROW LEVEL SECURITY."

*Supabase — service_role key security (P4-S4, via WebSearch synthesis):*
> "The `service_role` key bypasses Row Level Security. Never expose this key in the browser or client-side code. If a user gains access to your `service_role` key, they can read and write to your entire database, bypassing any RLS policies you have set up."

*OWASP API1:2023 BOLA (P4-S3, from agent-design-security-compliance.md §2.1):*
> "Every API endpoint that receives an ID of an object, and performs any action on the object, should implement object-level authorization checks."
> "BOLA vulnerabilities primarily enable horizontal escalation, allowing one customer to access another customer's orders, documents, or account information within multi-tenant systems."

*OWASP Multi-Tenant Cheat Sheet (P4-S6, paraphrased in agent-design-security-compliance.md §2.1):*
> "Validate tenant ownership at the data access layer." "Include tenant_id in all resource queries, cache keys, and storage paths."

### Pattern 5 — Env separation

| # | Source | URL | Fetch method | Quote status |
|---|---|---|---|---|
| P5-S1 | 12-Factor App — III Config | https://12factor.net/config | WebFetch direct | Verbatim |
| P5-S2 | OWASP Secrets Management Cheat Sheet | https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html | WebSearch synthesis | (via WebSearch synthesis) |
| P5-S3 | GitHub — Encrypted secrets best practices | https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions | WebSearch synthesis | (via WebSearch synthesis) |
| P5-S4 | Doppler — environment separation guide | https://docs.doppler.com/docs/environments | WebSearch synthesis | (via WebSearch synthesis) |
| P5-S5 | HashiCorp Vault — secrets isolation patterns | https://developer.hashicorp.com/vault/docs/secrets | WebSearch synthesis | (via WebSearch synthesis) |

**Verbatim quotes:**

*12-Factor III — Config (P5-S1):*
> "The twelve-factor app stores config in environment variables (often shortened to env vars or env). Env vars are easy to change between deploys without changing any code; unlike config files, there is little chance of them being checked into the code repo accidentally; and unlike custom config files, or other config mechanisms such as Java System Properties, they are a language- and OS-agnostic standard."

> "A litmus test for whether an app has all config correctly factored out of the code is whether the codebase could be made open source at any moment, without compromising any credentials."

> "The twelve-factor app does not batch config together into 'environments'... Instead, the twelve-factor app manages configs as independent env vars that are orthogonally combinable."

*OWASP Secrets Management Cheat Sheet (P5-S2, via WebSearch synthesis):*
> "Secrets should never be stored in the same secret store as production secrets for non-production environments. Separate secret stores per environment (dev, staging, prod) ensures that a compromised non-production secret cannot be used against production."

*GitHub Encrypted Secrets — per-environment scoping (P5-S3, via WebSearch synthesis):*
> "Environment secrets are scoped to a specific environment and are only available to jobs that reference that environment. If the same secret name exists at the environment and repository level, the environment secret overrides the repository secret for jobs referencing that environment."

---

## 4. Per-Pattern Detail

---

### Pattern 1 — Next.js Client/Server Boundary Violation

**Severity:** CRITICAL
**Recurrence:** 3x (highest priority for Code-Reviewer pre-flight gate)
**Stack:** Next.js (App Router) + Turbopack

#### Rule (Code-Reviewer pre-flight / Builder hard rule)

> A module that (a) is imported by any client component (direct or transitive), AND (b) imports `server-only`, `next/cache`, `next/server`, a Sentry server SDK, or a Supabase admin/service-role client MUST declare `import "server-only"` at the top of its file. Any named export added to such a file that a client consumer could call MUST be moved to a client-safe sibling file.

#### Grep patterns (Code-Reviewer pre-flight)

```
# Pattern A — module imports server-only marker or server-only deps but also has named exports (transitive pull risk)
# Run against any .ts/.tsx file touched in the diff:
grep -l "from 'server-only'\|from 'next/cache'\|from 'next/server'" <changed-files> | xargs grep -l "^export (const|function|class|type|interface)"

# Pattern B — client component imports from a file that directly or transitively imports server-only deps
grep -rn "'use client'" --include="*.tsx" | while read f; do
  grep -l "from '.*notifications\|from '.*server-helpers\|from '.*server-utils'" "$f"
done

# Pattern C — named export added to a file that already has server-only imports
# (manually verify on diff review: file has `import "server-only"` or `from 'next/cache'` AND a new `export const|function` was added in this diff)
```

#### Canonical fix

1. **Immediate:** Add `import "server-only"` at the top of any file that imports server-only dependencies. This causes a build-time error if any client component transitively imports the file.
2. **Structural:** When adding a helper to a module that may be consumed by both server and client paths, create a client-safe sibling: `notifications.ts` (server-only imports) and `notifications-client.ts` (no server deps, safe to import from `"use client"` files).
3. **Builder hard rule (bake into STACK-PATTERNS Builder section):** "Before adding any export to an existing module, verify it does not import server-only, next/cache, next/server, or supabase admin client (directly or transitively). If it does, propose a client-safe sibling instead."

#### Citations
- P1-S1: Next.js `"use client"` directive — https://nextjs.org/docs/app/api-reference/directives/use-client — 2026-04-30
- P1-S3: Next.js `server-only` package — https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns#keeping-server-only-code-out-of-the-client-environment — 2026-04-30
- P1-S5: React Server Components — https://react.dev/reference/rsc/server-components — 2026-04-30
- P1-S7: Next.js GitHub #48036 — Turbopack transitive bundling — https://github.com/vercel/next.js/issues/48036 — (via WebSearch synthesis) — 2026-04-30

#### Recurrence signal
3x Builder failure in PF v1 TaskIt sessions (user-memory `feedback_url_codec_server_import.md` + Item 10 + prior session). Classifies as a **ratifiable pattern** (BP-class, ≥3 internal incidents). Strongest grounding justification in the C4 cluster.

#### Composability
- **Code-Reviewer pre-flight:** grep patterns A/B/C run on every diff touching `.ts`/`.tsx` files. Severity = CRITICAL, stop-the-review if matched without `server-only` declaration.
- **Builder hard rule:** pre-export checklist item — verify module's import graph before adding exports.
- **Gate-3 production check:** D-class dimension: build must complete without Turbopack client-bundle errors. Build failure on server-only import in client bundle is a BLOCKED finding.
- **Architect schema check:** module graph constraint — any module shared between server and client paths must be explicitly declared as server-only or client-safe in the architecture document.

---

### Pattern 2 — React State-Setter Closure-Flag Anti-Pattern

**Severity:** HIGH
**Recurrence:** 1x internal + 7/7 BINDING (react-mentions + text-expander-element enterprise-research-first prior)
**Stack:** React (functional components, hooks)

#### Rule (Code-Reviewer pre-flight / Builder self-review)

> Never read a flag or variable that was mutated inside a `setState(prev => ...)` updater on the line after the setter call. The updater function is async — it runs during reconciliation, not inline. The flag will always reflect its captured closure value (typically `false`) on the synchronous line that follows the `set*()` call.

#### Grep patterns (Code-Reviewer pre-flight)

```bash
# Pattern A — let flag declared, mutated inside setState updater, read after
# Matches the exact shape: let <flag> = false; set*((prev) => { ... <flag> = true ...}); if (<flag>)
grep -n "let \w\+ = false" --include="*.tsx" --include="*.ts" -r .

# Follow-up: for each match, check if the variable is mutated inside a setState updater and read after
# Shape: let inserted = false; setX(prev => { ... inserted = true; ... }); if (inserted) ...
grep -n "set[A-Z]\w*(prev =>" --include="*.tsx" --include="*.ts" -r .
```

#### Canonical fix

Option A — **Synchronous ref (preferred for functional components):**
```typescript
const wasInsertedRef = React.useRef(false);
setX(prev => {
  wasInsertedRef.current = true;
  return { ...prev, inserted: true };
});
if (wasInsertedRef.current) { /* reads correctly */ }
```

Option B — **Compute from state synchronously:**
```typescript
// Move the dependent decision INSIDE the updater or derive it from current state
// before calling the setter — never from a flag mutated inside the updater.
const currentX = xRef.current; // snapshot of current value via ref
setX(prev => ({ ...prev, inserted: true }));
if (currentX !== newValue) { /* use snapshot, not mutated flag */ }
```

Option C — **Single updater with early return:**
If the dependent logic can be co-located, move everything inside the updater and return the decision as part of the next state value. Use a `useEffect` to react to the state change.

#### Citations
- P2-S1: react.dev — useState updater — https://react.dev/reference/react/useState#updating-state-based-on-the-previous-state — 2026-04-30
- P2-S2: react.dev — batching — https://react.dev/learn/queueing-a-series-of-state-updates — 2026-04-30
- P2-S3: react-mentions — ref-based insertion tracking (7/7 BINDING) — https://github.com/signavio/react-mentions — (via WebSearch synthesis) — 2026-04-30
- P2-S4: text-expander-element — ref-based state tracking (7/7 BINDING) — https://github.com/github/text-expander-element — (via WebSearch synthesis) — 2026-04-30
- P2-S5: Kent C Dodds — stale closures in hooks — https://kentcdodds.com/blog/use-state-lazy-initialization-and-function-updates — (via WebSearch synthesis) — 2026-04-30
- P2-S7: PF v1 audit Item 11 — docs/audits/v1-feedback-vs-v2-2026-04-30.md — DIRECT — 2026-04-30

#### Recurrence signal
1x internal (TaskIt `task-table-v2.tsx`). Enterprise grounding at 7/7 BINDING from prior ER1 sessions makes this a proposal-candidate per the PF proposing-patterns rule (BINDING N/N ≥5 qualifies). Downstream recommendation: ratify as BP row after implementer review.

#### Composability
- **Code-Reviewer pre-flight:** grep patterns A/B on every diff touching `.tsx`/`.ts` files using `useState`. Finding = HIGH.
- **Builder self-review:** checklist item — "If I mutated a variable inside a setState updater, I MUST NOT read it synchronously after the call."
- **QA / bug-class taxonomy:** classifies under "Stale-closure / async-state-setter" bug class (see `bug-class-taxonomy-2026-04-30.md` — ER1 trigger phrase: "closure-staleness").

---

### Pattern 3 — Console-Errors-Clean Per Route (Pre-Existing Hydration Error Accumulation)

**Severity:** MEDIUM (escalates to HIGH if React errors #418/#419 are present — hydration errors degrade INP/CLS)
**Recurrence:** Multiple ship cycles silently absorbing pre-existing errors (Item 12 audit)
**Stack:** React / Next.js (SSR) + any observability tool

#### Rule (Gate-3 production check / QA gate)

> On every route touched by a ship, the browser console must contain no React errors — including pre-existing #418/#419 recoverable hydration errors. Pre-existing errors are NOT absorbed silently; they are filed as separate findings with their own severity and remediation path. A gate-3 or QA sign-off on a route with known pre-existing React errors is incomplete.

#### Grep patterns / verification method

```bash
# Playwright — fail-on-console-error fixture (attach to every route test)
page.on('console', (msg) => {
  if (msg.type() === 'error') {
    throw new Error(`Console error on ${page.url()}: ${msg.text()}`);
  }
});

# Grep in codebase for suppressHydrationWarning — each instance must be justified
grep -rn "suppressHydrationWarning" --include="*.tsx" --include="*.ts" .

# Grep for known React error codes in test output or Sentry dashboards
# Error 418: "Hydration failed because the server rendered HTML didn't match"
# Error 419: "The server could not finish this Suspense boundary"
```

#### Canonical fix

1. **Detection gate:** Add a Playwright `console` event listener to every route test that throws on `console.error`. This surfaces accumulating errors that visual inspection misses.
2. **Hydration error #418 remediation:** Find the non-deterministic render path (Date.now(), Math.random(), browser API accessed during SSR). Extract to a `useEffect` or use `suppressHydrationWarning` with explicit justification comment.
3. **Hydration error #419 remediation:** Identify the Suspense boundary that timed out during SSR. Either (a) add a `fallback` that matches the server-rendered initial shape, or (b) defer the suspended component to client-only render with `dynamic(() => import('./Component'), { ssr: false })`.
4. **Registry pattern:** Maintain a `docs/known-console-errors.md` (or equivalent PROJECT-PLAN section) listing pre-existing errors with: route, error text, created date, owner. Any ship that touches a route with a pre-existing error must either fix it or explicitly re-acknowledge it.

#### Citations
- P3-S1: react.dev errors #418/#419 — https://react.dev/errors/418 / https://react.dev/errors/419 — (via WebSearch synthesis) — 2026-04-30
- P3-S2: Cypress console error capture pattern — https://docs.cypress.io — (via WebSearch synthesis) — 2026-04-30
- P3-S3: Sentry `captureConsoleIntegration` — https://docs.sentry.io/platforms/javascript/guides/react/configuration/integrations/ — (via WebSearch synthesis) — 2026-04-30
- P3-S4: Web Vitals — INP/CLS downstream of hydration — https://web.dev/articles/vitals — (via WebSearch synthesis) — 2026-04-30

#### Recurrence signal
Qualifies for a gate-3 dimension (D19 candidate): "console-errors-clean on every touched route." Cross-link to `browser-driven-verification` skill (Item 16) — Playwright is the enforcement mechanism.

#### Composability
- **Gate-3 production check:** new dimension D19 — "On every route in scope, browser console contains no React errors (including pre-existing #418/#419). BLOCKED if violated."
- **QA agent:** route audit checklist item — run Playwright console capture, file any errors as separate findings.
- **SRE/DevOps:** Sentry `captureConsoleIntegration` feeds into the existing observability pipeline. Hydration errors classified as SLI degradation (CLS/INP downstream).
- **`browser-driven-verification` skill:** this pattern is a primary trigger — "console errors accumulating across ship cycles" is the Playwright-verification use case.

---

### Pattern 4 — Postgres Service-Role / RLS Bypass in Read Paths

**Severity:** CRITICAL
**Recurrence:** 1x internal (G-CRIT-1 within-tenant visibility leak, Item 9 audit)
**Stack:** Postgres + Supabase (RLS) + any multi-tenant pool model
**Cross-links:** `docs/research/agent-design-database-engineer.md` Topic B (§2, G3); `docs/research/agent-design-security-compliance.md` §2.1, §2.6; STACK-PATTERNS multi-tenant grep row #4

#### Rule (Code-Reviewer pre-flight / Architect schema check / seven-validation-questions Q3)

> Service-role clients bypass ALL RLS policies. They MUST NOT appear in any code path that performs a read gated by a tenant-scoping RLS policy, unless the query includes an explicit `p_user_id` parameter AND a visibility check inside a SECURITY DEFINER RPC. When the arch doc states the auth model as "SECURITY INVOKER so RLS applies," the implementation MUST use the user-scoped client (not the service-role / admin client).

#### Grep patterns (Code-Reviewer pre-flight)

```bash
# Pattern A — service_role / admin client used anywhere outside explicitly marked server-admin files
grep -rn "createClient.*service_role\|supabaseAdmin\|SUPABASE_SERVICE_ROLE" --include="*.ts" --include="*.tsx" .
# Every match must be in a file that is: (a) not importable from client components, AND (b) either an admin action with no tenant-gated read OR explicitly calls a SECURITY DEFINER RPC with p_user_id

# Pattern B — service_role key in any client-reachable environment variable
grep -rn "NEXT_PUBLIC.*SERVICE_ROLE\|NEXT_PUBLIC.*SUPABASE_SERVICE" --include="*.env*" --include="*.ts" .

# Pattern C — arch-doc claims "SECURITY INVOKER" / "RLS applies" but implementation uses supabaseAdmin
# (Manual check on diff review: grep arch doc + grep implementation for consistency)
grep -rn "SECURITY INVOKER\|supabaseAdmin\|service_role" --include="*.ts" --include="*.tsx" --include="*.sql" . | grep -v "^Binary"
```

#### Canonical fix

**When the read path is RLS-gated (SECURITY INVOKER):**
```typescript
// WRONG — service-role bypasses RLS; visibility leak
const { data } = await supabaseAdmin.from('notifications').select('*').eq('user_id', userId);

// CORRECT — user-scoped client; RLS enforces tenant isolation
const supabase = createServerComponentClient({ cookies });
const { data } = await supabase.from('notifications').select('*');
// RLS policy USING (auth.uid() = user_id) filters automatically
```

**When the read path requires service-role for elevated access (e.g., cross-tenant admin query):**
```sql
-- Wrap in SECURITY DEFINER RPC with explicit visibility check
CREATE FUNCTION get_user_notifications(p_user_id uuid)
RETURNS SETOF notifications
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT * FROM notifications WHERE user_id = p_user_id;
$$;
```

**Arch-doc requirement (seven-validation-questions Q3 amendment):**
For every read path, the architecture document MUST specify: (a) auth model (SECURITY INVOKER / SECURITY DEFINER / service-role-with-explicit-filter), (b) client shape that activates it (user-scoped client / admin client / RPC call), (c) the import path that produces that client shape.

#### Citations
- P4-S1: PostgreSQL §5.9 — bypass attributes — https://www.postgresql.org/docs/current/ddl-rowsecurity.html — DIRECT cross-link — 2026-04-29
- P4-S2: Supabase RLS guide — https://supabase.com/docs/guides/database/postgres/row-level-security — DIRECT cross-link — 2026-04-29
- P4-S3: OWASP API1:2023 BOLA — https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/ — DIRECT cross-link — 2026-04-29
- P4-S4: Supabase — service_role key warning — https://supabase.com/docs/guides/api/api-keys — (via WebSearch synthesis) — 2026-04-30
- P4-S5: AWS SaaS Lens — tenant isolation — https://docs.aws.amazon.com/wellarchirected/latest/saas-lens/tenant-isolation.html — DIRECT cross-link — 2026-04-29
- P4-S6: OWASP Multi-Tenant Cheat Sheet — https://cheatsheetseries.owasp.org/cheatsheets/Multi_Tenant_Security_Cheat_Sheet.html — DIRECT cross-link — 2026-04-29

#### Recurrence signal
1x internal incident (G-CRIT-1). Extends existing STACK-PATTERNS multi-tenant grep row #4 with arch-doc-time depth. The gap is that the existing row catches service_role in client-reachable code at code-review time; this pattern adds the earlier arch-doc gate (seven-validation-questions Q3) and the implementation-vs-arch-doc consistency check.

#### Composability
- **Code-Reviewer pre-flight:** grep patterns A/B/C on every diff touching data-access files. Severity = CRITICAL.
- **Architect schema check:** Q3 of seven-validation-questions — "name the client shape that activates the auth model."
- **Database Engineer:** when producing migration docs, explicitly state which client (user-scoped vs admin) is the intended caller for each query path.
- **Security/Compliance:** NIST AC-3 / OWASP ASVS V4.2.1 / SOC2 CC6.1 citation chain — cross-ref from security doc per `agent-design-security-compliance.md` Revision B.

---

### Pattern 5 — Env Separation (Same Secret Across `.env*` Files)

**Severity:** HIGH
**Recurrence:** 1x internal (Item 20 audit)
**Stack:** Any Next.js / Node.js project with multiple `.env` files (`.env`, `.env.local`, `.env.production`, `.env.staging`)

#### Rule (Code-Reviewer pre-flight / Builder self-review)

> Secrets MUST be unique per environment. The same key value appearing in both `.env.local` and `.env.production` (or `.env.staging`) is a violation. Non-production secrets MUST NOT be usable against production systems. A "litmus test": if the `.env.production` file were accidentally checked in, would production credentials be exposed? If the values are the same as local/staging, the answer is yes.

#### Grep patterns (Code-Reviewer pre-flight)

```bash
# Pattern A — check if same secret value appears in multiple env files
# (Compare key values across env files — manual or scripted)
# Script: for each key in .env.local, check if the same value appears in .env.production
diff <(sort .env.local) <(sort .env.production) | grep "^>" | grep -i "KEY\|SECRET\|TOKEN\|PASSWORD"

# Pattern B — any secret committed to a tracked env file (not .gitignored)
git ls-files | grep "^\.env" | xargs ls -la
# Any .env file NOT in .gitignore is a finding

# Pattern C — NEXT_PUBLIC prefix on a secret (browser-exposed)
grep -rn "NEXT_PUBLIC_.*SECRET\|NEXT_PUBLIC_.*KEY\|NEXT_PUBLIC_.*TOKEN" --include="*.env*" --include="*.ts" .
```

#### Canonical fix

1. **Immediate:** Rotate any secret that appears in both non-production and production env files. Treat as compromised until rotated.
2. **Structural:** Each environment (`local`, `staging`, `production`) uses its own secret with its own credentials in the secret management system (GitHub Encrypted Secrets per-environment, Doppler per-config, HashiCorp Vault per-namespace).
3. **`.gitignore` audit:** All `.env*.local` files must be in `.gitignore`. Only `.env.example` (with redacted values) is committed.
4. **12-Factor compliance check:** Apply the 12-Factor III litmus test — "could the codebase be made open source at any moment, without compromising any credentials?" If no: env separation is broken.

#### Citations
- P5-S1: 12-Factor III Config — https://12factor.net/config — WebFetch direct — 2026-04-30
- P5-S2: OWASP Secrets Management Cheat Sheet — https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html — (via WebSearch synthesis) — 2026-04-30
- P5-S3: GitHub Encrypted Secrets — https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions — (via WebSearch synthesis) — 2026-04-30
- P5-S4: Doppler env separation — https://docs.doppler.com/docs/environments — (via WebSearch synthesis) — 2026-04-30
- P5-S5: HashiCorp Vault secrets isolation — https://developer.hashicorp.com/vault/docs/secrets — (via WebSearch synthesis) — 2026-04-30

#### Recurrence signal
1x internal. Below the 3-incident threshold for auto-ratification but above zero — file as an Open Finding with severity HIGH and revisit after second occurrence. The 12-Factor and OWASP grounding gives it institutional weight for Code-Reviewer pre-flight inclusion now.

#### Composability
- **Code-Reviewer pre-flight:** grep patterns A/B/C on any diff touching `.env*` files. Severity = HIGH.
- **Builder self-review:** before declaring DONE on any env-configuration change, verify no secret value is shared across environment files.
- **Gate-3 production check:** D-class check — "env files audited: no secret shared across `.env.local` and `.env.production`." Can be automated as a pre-deploy script.
- **Security/Compliance:** NIST SC-8 (transmission) + OWASP Secrets Management + GitHub best practices citation chain.

---

## 5. Recommendations for STACK-PATTERNS Template Sections

The five patterns map to four distinct sections of `templates/STACK-PATTERNS.template.md`. The implementer should add them as follows:

### 5.1 Stack-Specific Anti-Patterns section

Add five rows to the anti-patterns table (replaces the `<!-- EXAMPLE -->` placeholder section):

```markdown
| Anti-pattern | Correct alternative | Why |
|---|---|---|
| Exporting a helper from a module that imports `server-only`, `next/cache`, or Sentry server SDK, when that module may be imported by client components | Create a client-safe sibling file with only the client-callable logic; mark the server module with `import "server-only"` | Turbopack pulls server-only deps into the client bundle transitively; build fails or secrets leak silently (Next.js docs; GitHub #48036; 3x recurrence in PF v1) |
| `let inserted = false; setX(prev => { inserted = true; ... }); if (inserted)` — reading a flag mutated inside a setState updater synchronously | Use `useRef` to track side effects, or compute the decision synchronously from current state before calling the setter | `setState` updater runs during reconciliation, not inline; the flag always reads its captured closure value (react.dev; 7/7 BINDING — react-mentions + text-expander-element) |
| Ignoring pre-existing React console errors (#418/#419) across ship cycles | File each pre-existing error as a separate finding; gate each route via Playwright console capture in CI | Pre-existing hydration errors accumulate silently; each ship cycle absorbs them without fixing them; downstream CLS/INP degradation (react.dev errors docs) |
| Using `supabaseAdmin` (service-role client) in a read path gated by an RLS policy when the arch doc declares "SECURITY INVOKER" | Use the user-scoped Supabase client for RLS-gated reads; wrap elevated reads in a SECURITY DEFINER RPC with explicit `p_user_id` parameter | service_role bypasses ALL RLS policies; arch-doc/impl mismatch creates silent within-tenant visibility leaks (PostgreSQL §5.9; Supabase docs; OWASP API1:2023) |
| Same secret value in both `.env.local` and `.env.production` | Each environment uses unique credentials; `.env*.local` files are gitignored; use per-environment secrets in GitHub/Doppler/Vault | A non-prod compromise exposes prod; violates 12-Factor III litmus test; rotate immediately on detection (12-Factor III; OWASP Secrets Management Cheat Sheet) |
```

### 5.2 Code-Review Pre-Flight Greps (Next.js / React extension)

Add below the existing multi-tenant grep table (after the `<!-- ## Postgres / Supabase -->` comment block):

```markdown
## Next.js / React — Code-Review Pre-Flight Greps

| # | Pattern (grep) | Severity | Why it's wrong |
|---|---|---|---|
| NR-1 | File imports `server-only`, `next/cache`, `next/server`, or Sentry server SDK AND has named exports AND is not itself marked `import "server-only"` | Critical | Turbopack transitively bundles server-only deps into client bundle; build fails or server secrets exposed (Next.js docs; GitHub #48036; 3x PF v1 recurrence) |
| NR-2 | `let \w+ = false` declared in a component/hook body AND subsequently mutated inside a `set\w+\(prev =>` updater AND read on the next synchronous line | High | React state-setter updater runs asynchronously; flag always reads closure-captured value (false); logic branch never executes (react.dev; 7/7 BINDING) |
| NR-3 | Any route test (Cypress/Playwright) missing a `console.error` capture assertion | Medium | Pre-existing React errors #418/#419 accumulate silently across ship cycles; each cycle audits only its own output (react.dev errors; Sentry captureConsoleIntegration) |
| NR-4 | `supabaseAdmin` or `createClient` with `SUPABASE_SERVICE_ROLE_KEY` used in a file that reads from a table with RLS policy, without a SECURITY DEFINER wrapper | Critical | service_role bypasses all RLS; arch-doc "SECURITY INVOKER" claim is invalidated (PostgreSQL §5.9; Supabase service_role warning; OWASP API1:2023 BOLA) |
| NR-5 | `NEXT_PUBLIC_` prefix on any env var whose name contains `SECRET`, `KEY`, `TOKEN`, or `PASSWORD` | Critical | `NEXT_PUBLIC_` prefixed vars are bundled into the client; secrets are browser-exposed (12-Factor III; Vercel env var docs) |
| NR-6 | Same secret value appearing in both `.env.local` and `.env.production` | High | Non-prod compromise → prod compromise; violates 12-Factor III env-per-stage requirement (12-Factor III; OWASP Secrets Management) |
```

### 5.3 Builder — Stack-Specific Hard Rules (Next.js / React extension)

Add below the existing multi-tenant hard rules:

```markdown
### Next.js / React Hard Rules

1. **Client/server boundary:** Before adding any export to an existing `.ts`/`.tsx` module, verify it does not import `server-only`, `next/cache`, `next/server`, a Sentry server SDK, or a Supabase admin client (directly or transitively). If it does, the export goes in a client-safe sibling file. The original file gets `import "server-only"` at the top.

2. **State-setter timing:** Never read a variable mutated inside a `setState(prev => ...)` updater synchronously after the setter call. Use `useRef` for side-effect flags. Document the ref's purpose in a comment.

3. **Console errors:** Before declaring any UI task DONE, run the affected routes through Playwright with a `console.error` capture fixture. Zero console errors is the acceptance bar. Pre-existing errors not fixed in this task must be filed as separate Open Findings.

4. **Service-role client:** The admin/service-role client MUST NOT appear in any read path gated by an RLS policy (declared "SECURITY INVOKER" in the arch doc). Violations are BLOCKED findings, not concerns.

5. **Env separation:** Before any DONE that touches env configuration, verify no secret value is shared between `.env.local` and `.env.production`. Rotate immediately if shared.
```

### 5.4 Project Patterns Registry (BP / AP / PP) — stub rows

Add to the Quick Reference table when the project has ratified these (pending ≥3 incident threshold or ≥5/N BINDING for BP-2):

```markdown
| ID | Category | Rule | Check |
|---|---|---|---|
| BP-1 | Bug | Next.js server-only module transitively pulled into client bundle via shared helper | grep: `from 'server-only'` + named export + no `import "server-only"` declaration |
| BP-2 | Bug | React state-setter closure-flag reads stale captured value | grep: `let \w+ = false` + `set\w+\(prev =>` mutation + synchronous read after setter |
| BP-3 | Bug | Postgres service-role client used where RLS-gated user-scoped client required | grep: `supabaseAdmin` in RLS-gated read path |
| PP-1 | Performance | Pre-existing hydration errors (#418/#419) degrade CLS/INP without active detection | Playwright console capture on every route in test suite |
```

---

## 6. Cluster C4 Summary + Implementation Guidance

| Pattern | Severity | BP/PP ID | Template section | Composability primary |
|---|---|---|---|---|
| P1 — Next.js client/server boundary | CRITICAL | BP-1 | Anti-patterns + Greps NR-1 + Builder HR-1 | Code-Reviewer pre-flight (stop-the-review) |
| P2 — React state-setter closure-flag | HIGH | BP-2 | Anti-patterns + Greps NR-2 + Builder HR-2 | Code-Reviewer pre-flight + QA bug-class |
| P3 — Console-errors-clean per route | MEDIUM→HIGH | PP-1 | Anti-patterns + Greps NR-3 + Gate-3 D19 | Gate-3 / browser-driven-verification skill |
| P4 — Postgres service-role / RLS bypass | CRITICAL | BP-3 | Anti-patterns + Greps NR-4 + Architect Q3 | Code-Reviewer pre-flight + seven-validation-questions Q3 |
| P5 — Env separation | HIGH | (Open Finding) | Anti-patterns + Greps NR-5/NR-6 + Builder HR-5 | Code-Reviewer pre-flight |

**Top-3 implementation recommendations:**

1. **Ship NR-1 + Builder HR-1 first.** Pattern 1 (client/server boundary) is 3x recurrent — it meets the ratifiable-pattern threshold today. The grep is deterministic; the Builder hard rule is a single checklist item. This is the highest-leverage single change in C4.

2. **Add Gate-3 D19 (console-errors-clean) and wire `browser-driven-verification`.** Pattern 3 has no deterministic grep; it requires Playwright execution. Gate-3 D19 is the enforcement mechanism. The `browser-driven-verification` skill (Item 16, already proposed for Phase D) is the prescribed execution method. These two ship together.

3. **Extend seven-validation-questions Q3 with Pattern 4's client-shape-naming requirement.** The service-role / RLS bypass (Pattern 4) already has a Code-Reviewer grep in the template (row #4). The gap is the earlier arch-doc-time gate. Q3 amendment ("name the client shape that activates the auth model") closes the gap between the arch doc promise and the implementation.

---

## 7. Citations Footer

**Directly fetched (WebFetch):**
- Next.js `"use client"` directive — https://nextjs.org/docs/app/api-reference/directives/use-client — 2026-04-30
- Next.js `"use server"` directive — https://nextjs.org/docs/app/api-reference/directives/use-server — 2026-04-30
- Next.js server-only composition patterns — https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns#keeping-server-only-code-out-of-the-client-environment — 2026-04-30
- React Server Components — https://react.dev/reference/rsc/server-components — 2026-04-30
- react.dev — useState updater — https://react.dev/reference/react/useState#updating-state-based-on-the-previous-state — 2026-04-30
- react.dev — batching — https://react.dev/learn/queueing-a-series-of-state-updates — 2026-04-30
- 12-Factor III Config — https://12factor.net/config — 2026-04-30

**Via WebSearch synthesis (re-verify before binding PR):**
- Vercel env variable leakage — https://vercel.com/docs/projects/environment-variables/system-environment-variables
- Next.js GitHub #48036 — Turbopack transitive bundling — https://github.com/vercel/next.js/issues/48036
- react-mentions — ref-based insertion tracking — https://github.com/signavio/react-mentions
- text-expander-element — ref-based state tracking — https://github.com/github/text-expander-element
- Kent C Dodds — stale closures in hooks — https://kentcdodds.com/blog/use-state-lazy-initialization-and-function-updates
- Stack Overflow — useState setter stale variable — https://stackoverflow.com/questions/54069253
- react.dev errors #418/#419 — https://react.dev/errors/418 + https://react.dev/errors/419
- Cypress console error capture — https://docs.cypress.io
- Sentry captureConsoleIntegration — https://docs.sentry.io/platforms/javascript/guides/react/configuration/integrations/
- Web Vitals INP/CLS — https://web.dev/articles/vitals
- Supabase service_role key warning — https://supabase.com/docs/guides/api/api-keys
- OWASP Secrets Management Cheat Sheet — https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html
- GitHub Encrypted Secrets — https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions
- Doppler env separation — https://docs.doppler.com/docs/environments
- HashiCorp Vault secrets isolation — https://developer.hashicorp.com/vault/docs/secrets
- Plasmic engineering — server-only footguns — https://blog.plasmic.app

**Cross-linked internal (DIRECT — read this session):**
- `docs/research/agent-design-database-engineer.md` Topics B–C (PostgreSQL §5.9, Supabase RLS guide, AWS Database Blog) — P4 citations
- `docs/research/agent-design-security-compliance.md` §2.1, §2.6 (OWASP ASVS V4.2.1, NIST AC-3, OWASP API1:2023, OWASP Multi-Tenant Cheat Sheet) — P4 citations
- `docs/audits/v1-feedback-vs-v2-2026-04-30.md` Items 9, 10, 11, 12, 20 — incident grounding for all five patterns
- `docs/research/bug-class-taxonomy-2026-04-30.md` — P2 bug-class cross-link (closure-staleness ER1 trigger)
- `templates/STACK-PATTERNS.template.md` — current shape; no-SP-precedent confirmed for all five patterns
