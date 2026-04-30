# Agent Design Research: UX/Design Sub-agent

**Date:** 2026-04-29
**Type:** Research — no code modifications
**Triggered by:** PF v2 review of `agents/ux-design.md` for UX-craft references and multi-tenant boundary state coverage
**Current agent file:** `c:/Users/atyab/Experimental - Users/production-framework-v2/agents/ux-design.md`

---

## Canonical sources

| # | Source | URL | Used for |
|---|--------|-----|----------|
| 1 | NN/g — 10 Usability Heuristics (Nielsen) | https://www.nngroup.com/articles/ten-usability-heuristics/ | Universal heuristics, error/empty-state framing |
| 2 | Rosenfeld / Morville / Arango — *Information Architecture: For the Web and Beyond, 4th ed.* | O'Reilly (book) | IA pillars: organization, labeling, navigation, search |
| 3 | W3C — WCAG 2.2 Recommendation | https://www.w3.org/TR/WCAG22/ | Accessibility minimums; new 2.2 SC; conformance levels |
| 4 | W3C — What's new in WCAG 2.2 | https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/ | Nine new SC enumeration |
| 5 | Material Design 3 — States | https://m3.material.io/foundations/interaction/states/applying-states | Component interaction-state taxonomy |
| 6 | Carbon Design System — Empty States Pattern | https://carbondesignsystem.com/patterns/empty-states-pattern/ | Empty-state guidance (first-use vs cleared vs unavailable) |
| 7 | Atlassian Design System — Empty State, Skeleton | https://atlassian.design/components/empty-state/, https://atlassian.design/components/skeleton/ | Loading + empty-state design |
| 8 | Smashing Magazine — *True Lies of Optimistic UIs* | https://www.smashingmagazine.com/2016/11/true-lies-of-optimistic-user-interfaces/ | Optimistic-update pitfalls and rollback |
| 9 | Smashing Magazine — *How to Design Error States for Mobile Apps* | https://www.smashingmagazine.com/2016/09/how-to-design-error-states-for-mobile-apps/ | Error state copy + recovery |
| 10 | Smashing Magazine — *Designing Better Error Messages UX* | https://www.smashingmagazine.com/2022/08/error-messages-ux-design/ | Plain-language error patterns |
| 11 | NN/g — *Designing Empty States in Complex Applications* | https://www.nngroup.com/articles/empty-state-interface-design/ | Three empty-state guidelines |
| 12 | NN/g — Breakpoints in Responsive Design | https://www.nngroup.com/articles/breakpoints-in-responsive-design/ | Mobile breakpoint approach |
| 13 | TanStack Query — Optimistic Updates | https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates | Rollback semantics for partial failure |
| 14 | ChatDev (OpenBMB) | https://github.com/OpenBMB/ChatDev | "Designer" role precedent in multi-agent SE |
| 15 | WorkOS — Developer's guide to multi-tenant SaaS | https://workos.com/blog/developers-guide-saas-multi-tenant-architecture | Tenant-context, tenant-switcher patterns |
| 16 | SP visual-companion | `superpowers:brainstorming/visual-companion.md` | SP-inheritable visual mockup loop |

---

## Verbatim quotes by topic

### Topic A — UX flow documentation patterns

**NN/g, *Heuristic 1: Visibility of system status*** (https://www.nngroup.com/articles/ten-usability-heuristics/):
> "The design should always keep users informed about what is going on, through appropriate feedback within a reasonable amount of time."

**NN/g, *Heuristic 3: User control and freedom***:
> "Users often choose system functions by mistake and will need a clearly marked 'emergency exit' to leave the unwanted state without having to go through an extended dialogue. Support undo and redo."

**Userpilot / AltexSoft** on user-flow components (paraphrased synthesis):
> "Entry points and end points are where your flow starts and ends... Actors are identified as anyone or anything that will interact with your product... Decision points are touchpoints where users make choices that direct them down different paths... System responses show how your system reacts to user actions."

A canonical user-flow doc captures, for each step: **actor action → system response → success state → failure state → next step**. This is the structure the agent must produce — not free-form prose.

### Topic B — Every-state coverage (empty / loading / error / partial-failure / optimistic)

**Carbon Design System — Empty States** (https://carbondesignsystem.com/patterns/empty-states-pattern/):
> "Empty states are moments in an app where there is no data to display to the user. They are most commonly seen the first time a user interacts with a product or page, but can be used when data has been deleted or is unavailable."

This implicitly defines THREE distinct empty-state archetypes that designers conflate:
1. **First-use empty** — onboarding opportunity; show what *will* appear and a primary CTA.
2. **Cleared empty** — user-initiated emptiness (deleted last item); show recovery / restore.
3. **Unavailable empty** — system/permission/tenant-boundary; show *why* and what to do.

**Atlassian Design System — Empty State** (https://atlassian.design/components/empty-state/):
> "An empty state appears when there is no data to display and describes what the user can do next."

**Atlassian Design System — Skeleton** (https://atlassian.design/components/skeleton/):
> "A skeleton acts as a placeholder for content, usually while the content loads. Skeletons are visual placeholders for information while data is still loading."

Skeletons (structural placeholders) are distinct from spinners (indeterminate progress) — designers should specify which.

**Australian Govt design system pattern** (cited via search) on the umbrella obligation:
> "When loading data in an application, it is important to consider and design for loading, empty, and error states. These states will help set user expectations and prevent them from assuming that the interface is unresponsive."

**Smashing Magazine — *Designing Better Error Messages UX*** (2022):
> "Tell people what's wrong in plain language and avoid using technical jargon by expressing everything in the user's vocabulary... Error states must include concise, polite, and instructive copy that clearly states what went wrong and possibly why, and what the next step the user should take to fix the error."

**NN/g — *Heuristic 9: Help users recognize, diagnose, and recover from errors***:
> "Error messages should be expressed in plain language (no error codes), precisely indicate the problem, and constructively suggest a solution."

**Smashing Magazine — *True Lies of Optimistic User Interfaces*** (2016):
> "Optimistic UI... is a pattern that helps you update the UI immediately, assuming the server operation will succeed, and if it later fails, you roll back the UI to the correct state."

**TanStack Query — Optimistic Updates** (https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates):
> "Optimistic updates... enable applications to update the UI immediately when a user performs an action before waiting for the server response, and if the server request fails, the update is automatically rolled back to maintain data consistency."

**Partial-failure design obligation** (Smashing synthesis):
> "If frequent failures or complex validations occur, consider a hybrid approach: partial optimistic updates for some actions, while more critical operations rely on immediate server confirmation."

The full state matrix the agent must enumerate per flow:

| State | Trigger | Visual | Recovery action |
|-------|---------|--------|----------------|
| First-use empty | No data exists yet | Illustration + CTA + value prop | Primary action that creates data |
| Cleared empty | User deleted last item | Hint + restore option | Undo / re-create |
| Unavailable empty | Permission / tenant / filter excludes | Reason + path forward | Switch tenant / clear filter / request access |
| Loading (skeleton) | Initial data fetch | Structural placeholder | (none — wait) |
| Loading (spinner) | Indeterminate background work | Inline indicator | Cancel if long-running |
| Optimistic-success | Action initiated, server pending | Item appears immediately | (none — happy path) |
| Optimistic-rollback | Server rejected after optimistic show | Item removed + toast with reason | Retry / edit |
| Partial-failure | Some sub-operations succeeded | Show what saved + what failed inline | Retry only failures |
| Error (recoverable) | Network/server fault | Plain-language reason + retry | Retry button |
| Error (unrecoverable) | Auth / permission lost | Clear next step | Sign in / contact admin |
| Stale (background-refetch) | Data shown but refresh in flight | Subtle indicator | (none — auto-refresh) |
| By-self vs by-other | Mutation came from current user vs another | Different attribution / animation | (informational) |

### Topic C — Information architecture principles (Morville)

**Rosenfeld / Morville / Arango — *Information Architecture for the Web and Beyond*, 4th ed.** (synthesis from book + Figma resource library):

> "Information Architecture is built on four primary pillars: organization, labeling, navigation, and search."

The four IA pillars the agent must address per feature:

1. **Organization systems** — hierarchical, faceted, ambiguous. (Where in the product does this live?)
2. **Labeling systems** — what we call this thing for users vs internally. (Words that survive translation and tenant context.)
3. **Navigation systems** — global, local, contextual. (How users get here from elsewhere.)
4. **Search systems** — query, filter, facet. (Findability when navigation fails.)

**Morville on findability** (Boxes & Arrows, "The Age of Findability"):
> "Findability is about designing systems that help people find what they need."

Faceted classification matters specifically for multi-tenant data:
> "Taxonomy affords a view from the top, facets help us muddle through the middle, and tags build bridges at the bottom."

For PF projects: tenant-scoped facets are a load-bearing IA decision (filter "tag by user" but ALSO "tag by tenant when user is multi-tenant").

### Topic D — Accessibility minimums (WCAG 2.2)

**W3C, *WCAG 2.2 Recommendation*** (https://www.w3.org/TR/WCAG22/), conformance:
> "WCAG 2.2 breaks down testable success criteria into three levels: A, AA, and AAA, with A representing the minimum conformance level and AAA representing the maximum. Meeting a conformance level is also backwards compatible, so achieving Level AA means that experience also conforms with A."

**Regulatory baseline** (W3C / Level Access / AudioEye):
> "Most global accessibility regulations, such as Section 508 of the Rehabilitation Act of 1973 in the U.S., EN 301 549 in Europe, and the Accessibility for Ontarians with Disabilities Act in Ontario, Canada, require Level AA conformance."

**WCAG 2.2 — Nine new SC** (W3C, "What's new in WCAG 2.2"). Of these, the four most-likely to surface in PF design docs:

- **2.4.11 Focus Not Obscured (Minimum) — Level AA**: "When a user interface component receives keyboard focus, at least a portion of it must remain visible and not be hidden by other content you provide." (Affects sticky headers, cookie banners, fixed footers.)
- **2.5.8 Target Size (Minimum) — Level AA**: "Target size of 24×24 CSS pixels" with spacing exception. (Affects icon buttons, chips, dense lists.)
- **3.3.8 Accessible Authentication (Minimum) — Level AA**: "A cognitive function test MUST NOT be required for any step in an authentication process, unless... another authentication method is available that does not rely on a cognitive function test." (Affects login, MFA, password rules.)
- **2.4.7 Focus Visible** (already in 2.1, escalated practical importance) — paired with 2.4.11.

**POUR principles** (WCAG foundational): Perceivable, Operable, Understandable, Robust. The agent should reference these as a per-flow checklist, not just cite WCAG numerically.

### Topic E — Multi-tenant boundary states & role-context indicators

**WorkOS — *Developer's guide to multi-tenant SaaS*** (https://workos.com/blog/developers-guide-saas-multi-tenant-architecture):
> "An organization switcher is typically always displayed in the header (Slack style)... Auth-based resolution with a tenant switcher in the UI handles this cleanly for applications where users operate across multiple organizations. When switching organizations, the cache should be cleared to ensure data integrity."

> "Your role within each organization should be clearly shown. This is essential since assigning roles and permissions per tenant is critical to ensure users only access the data and functionality they're entitled to, especially when users can belong to more than one tenant."

Synthesised pattern set the agent must require for any multi-tenant feature:

1. **Persistent tenant indicator** — visible at all times in chrome (header / sidebar). Slack, Notion, Linear all enforce this.
2. **Tenant switcher with cache invalidation** — switching MUST visually reset state; no leakage of tenant-A list rows into tenant-B view.
3. **Role badge in tenant context** — same user can be Admin in tenant-A, Member in tenant-B; UI must surface current role next to tenant label.
4. **Role-gated UI** — actions the current role can't perform are hidden or disabled-with-tooltip; never shown-then-403.
5. **Cross-tenant boundary "unavailable" empty state** — when a deep-link points to data in another tenant the user *also* belongs to, offer a "Switch to {tenant} to view this" recovery; if user has no access, give a clean 404-style page (no tenant existence leak).
6. **Tenant-scoped notifications/realtime** — design must specify what happens to subscriptions on tenant switch (unsubscribe + resubscribe).
7. **Role-switch (impersonation) indicator** — if the product supports support-impersonation, banner is mandatory and persistent during the session.

The current `agents/ux-design.md` mentions "user in tenant A sees no data from tenant B" — that's necessary but **not sufficient**. The doc must require all 7 items above as per-flow checkbox.

### Topic F — Mobile / responsive degradation

**NN/g — Breakpoints in Responsive Design**:
> "Most responsive websites perform best with 3-5 primary breakpoints, starting with mobile (320px+), tablet (768px+), and desktop (1024px+)."

**Mobile-first content priority** (UXPin / Adicator synthesis):
> "On mobile devices, key content is prioritized with less critical information hidden or moved to secondary screens. Small screens force you to answer: What is the single most important thing the user needs here?"

The agent should require, per flow: (a) primary action on small viewport — single tap reach; (b) what info is dropped vs deferred behind a "more" affordance; (c) how multi-step flows collapse from inline to wizard.

### Topic G — ChatDev "Designer" role precedent

**ChatDev paper** (https://arxiv.org/html/2307.07924v5) and repo (OpenBMB/ChatDev):
> "ChatDev's workflow follows a modified waterfall model that breaks up tasks into three sequential phases: design, coding and testing... ChatDev integrates multiple software agents for active involvement in three core phases: design, coding, and testing."

> "Within each subtask, pairs of specialized agents engage in multi-turn dialogues, exchanging structured JSON messages and blending natural language for strategic design with programming language for code generation and debugging."

ChatDev's "Art Designer" focuses on visual artefacts (icons, GUI mockups) — a narrower scope than PF v2's UX/Design. PF's role is closer to "design lead": flows, IA, states, accessibility — not pixel art. Useful precedent for **separation of design phase from build phase**, weaker precedent for the *contents* of a design doc (ChatDev's design output is mostly visual; PF's is structural prose).

---

## SP-inheritable from `visual-companion.md`

The SP visual-companion skill is directly applicable when the design needs visuals (mockups, wireframes, layout comparisons). The agent should **not** re-implement the loop — it should defer to SP. Inheritable behaviours:

1. **The decision rule** (SP `visual-companion.md` lines 5–25):
   > "Decide per-question, not per-session. The test: would the user understand this better by seeing it than reading it? ... A question *about* a UI topic is not automatically a visual question. 'What kind of wizard do you want?' is conceptual — use the terminal. 'Which of these wizard layouts feels right?' is visual — use the browser."

   This rule belongs verbatim in the agent's hard-rules — currently the agent only says "offer it before describing complex layouts in prose," which is weaker.

2. **2–4 options per screen, semantic filenames, never reuse filenames** (SP lines 269–274) — these are operational rules the agent can simply cite.

3. **Iteration model** (SP lines 113): "Only move to the next question when the current step is validated." This is a methodology constraint that should appear in the agent's `Hard rules` if the project enables visual-companion.

4. **Content fragments vs full documents** (SP line 31): "Write content fragments by default." Operational; the agent can defer to SP without restating.

5. **CSS classes available** (SP lines 158–245): wireframe building blocks (`mock-nav`, `mock-sidebar`, `mock-button`, `placeholder`, `pros-cons`, `split`). Useful for PF-style wireframing without bespoke CSS.

**Inheritance form:** the PF agent should reference SP `visual-companion.md` for *how* to use visuals; PF's own rules should specify *what* must be visualised (per-state mockups, multi-tenant boundary screens, error/empty/loading variants).

---

## Gaps in current `agents/ux-design.md`

| Gap ID | Severity | Description |
|--------|----------|-------------|
| GAP-1 | HIGH | No reference to NN/g 10 heuristics or WCAG 2.2 by SC number — citations are absent. Builder cannot validate design output against an external standard. |
| GAP-2 | HIGH | Multi-tenant boundary coverage is one sentence ("user in tenant A sees no data from tenant B"). Missing: tenant indicator, cache-invalidation-on-switch, role badge, role-gated UI, cross-tenant deep-link handling, realtime resubscribe, impersonation banner. |
| GAP-3 | HIGH | Interaction states list is partial. Missing explicit treatment of: skeleton vs spinner, partial-failure state, optimistic-rollback (distinct from generic "error"), stale/refetching state, first-use vs cleared vs unavailable empty states. |
| GAP-4 | MEDIUM | IA section says "where in the app this lives; what gets surfaced where" — does not invoke Morville's four pillars (organization / labeling / navigation / search). Findability and faceted classification not mentioned. |
| GAP-5 | MEDIUM | Accessibility section is a one-liner. WCAG 2.2 conformance level (AA expected per global regulation) is not stated. New 2.2 SC (focus-not-obscured, target-size 24×24, accessible-authentication) are not mentioned. POUR not invoked. |
| GAP-6 | MEDIUM | Mobile/responsive section lacks a content-priority directive. "Single most important thing on small viewport" question isn't asked. |
| GAP-7 | MEDIUM | SP visual-companion reference is weak ("offer it before describing complex layouts in prose"). The decision rule (visual vs conceptual question) and the iteration model (validate before advancing) aren't carried over. |
| GAP-8 | LOW | User-flow documentation format isn't specified. Builder has no template — actor / action / system response / success / failure / recovery columns aren't mandated. |
| GAP-9 | LOW | "Out-of-scope" is listed but no equivalent "must-include checklist" exists for the agent to self-verify before returning DONE. |
| GAP-10 | LOW | No `## Citations` references for NN/g, WCAG, Morville, Material/Carbon/Atlassian. Currently only SP and Anthropic are cited. |

---

## Suggested revisions to `agents/ux-design.md`

### Revision 1 — Replace the bullet "Interaction states" with a state-matrix requirement (addresses GAP-3)

Current:
> "**Interaction states** — every UI state: empty, loading, success, error, partial-failure, optimistic-update, by-self vs by-other, multi-tenant boundary states (e.g., 'user in tenant A sees no data from tenant B')"

Proposed:
> **Interaction states** — produce a state matrix per flow with all rows: first-use empty, cleared empty, unavailable empty (permission/tenant/filter), loading-skeleton, loading-spinner, optimistic-success, optimistic-rollback, partial-failure (per sub-operation), recoverable error, unrecoverable error, stale/refetching, by-self vs by-other, multi-tenant boundary. Each row specifies trigger, visual treatment, and recovery action. (Cite: Carbon empty-state pattern; Atlassian skeleton; Smashing optimistic UI; TanStack rollback.)

### Revision 2 — Expand multi-tenant rule to enforce the seven boundary patterns (addresses GAP-2)

Add as a `Hard rule`:
> **Multi-tenant boundary states are a 7-item checklist, not one item.** Every flow MUST specify:
> 1. Persistent tenant indicator in chrome
> 2. Tenant switcher with cache-invalidation behaviour
> 3. Role badge alongside tenant label
> 4. Role-gated UI (hide or disable-with-tooltip; never show-then-403)
> 5. Cross-tenant deep-link handling ("Switch to {tenant} to view this" recovery; clean 404 if no access — do not leak existence)
> 6. Realtime/subscription behaviour on tenant switch (unsubscribe + resubscribe)
> 7. Impersonation banner if support-impersonation is in product
>
> (Cite: WorkOS multi-tenant SaaS guide; Slack/Notion/Linear precedent.)

### Revision 3 — Make accessibility specific (addresses GAP-5)

Replace:
> "**Accessibility** — keyboard navigation, screen reader, contrast (note: don't design pixel-perfect mockups in markdown; describe semantic structure)"

With:
> **Accessibility — WCAG 2.2 Level AA minimum.** Apply POUR (Perceivable, Operable, Understandable, Robust) to every flow. Specifically address:
> - Keyboard navigation order, focus visibility (SC 2.4.7) and focus-not-obscured (SC 2.4.11 — sticky headers, banners must not occlude focus)
> - Target size (SC 2.5.8 — 24×24 CSS px minimum for tap targets; document spacing exception)
> - Accessible authentication (SC 3.3.8 — no cognitive-function-only auth)
> - Screen-reader semantic structure (landmarks, headings, ARIA only when native semantics are insufficient)
> - Contrast (SC 1.4.3 / 1.4.11) — describe required ratios, do not pixel-design
>
> (Cite: W3C WCAG 2.2 Recommendation; W3C WAI "What's new in 2.2".)

### Revision 4 — Add IA pillars per Morville (addresses GAP-4)

Replace:
> "**Information architecture** — where in the app this lives; what gets surfaced where"

With:
> **Information architecture — Morville's four pillars.** For every feature address: (1) organization (hierarchical / faceted / hybrid placement; tenant-scoped facets if multi-tenant), (2) labeling (user-facing words; internal vs external naming), (3) navigation (global / local / contextual entry points), (4) search (query, filter, facet — findability when nav fails). (Cite: Rosenfeld/Morville/Arango, *Information Architecture for the Web and Beyond*, 4th ed.)

### Revision 5 — Tighten visual-companion integration (addresses GAP-7)

Replace:
> "Visual companion (if available). If the project has the visual companion enabled and the design needs visuals, offer it before describing complex layouts in prose."

With:
> **Visual companion — apply SP decision rule per question.** Per `superpowers:brainstorming/visual-companion.md`: "would the user understand this better by seeing it than reading it?" Use the browser for layout/wireframe/state-comparison questions; use prose for requirements / tradeoff / labeling questions. Iterate before advancing — do not move to the next question until the current screen is validated. 2–4 options per screen.

### Revision 6 — Add a content-priority directive for mobile (addresses GAP-6)

Replace:
> "**Mobile/responsive** — how the flow degrades / adapts"

With:
> **Mobile/responsive — content priority first.** For each flow on a 320–767px viewport, answer: (a) what is the single most important thing the user needs here, (b) what info defers behind a "more" affordance, (c) how does a multi-step flow collapse (inline → wizard → modal). Default breakpoints: 320 / 768 / 1024 unless project specifies otherwise. (Cite: NN/g, *Breakpoints in Responsive Design*.)

### Revision 7 — Add user-flow doc template (addresses GAP-8)

Add to `Your job`:
> **User-flow documentation format.** For each flow, produce a numbered step list where every step has columns: actor action | system response | success state | failure state | recovery path. Free-form prose is not a substitute for this structure. (Cite: standard UX user-flow documentation pattern.)

### Revision 8 — Add a `Self-check before DONE` checklist (addresses GAP-9)

Append a new section:
```
## Self-check before returning DONE

Before returning DONE, verify the design doc contains:
- [ ] User-flow table per feature (actor / system / success / failure / recovery columns)
- [ ] State matrix with all 13 rows (see Hard rules)
- [ ] Multi-tenant 7-item checklist completed per flow
- [ ] WCAG 2.2 AA items addressed: focus visible, focus-not-obscured, target-size, accessible-auth, contrast, screen-reader semantics
- [ ] IA section invokes Morville's four pillars
- [ ] Mobile content-priority answer (single most important thing) per flow
- [ ] Out-of-scope items listed

If any unchecked item is intentional, downgrade to DONE_WITH_CONCERNS and name it.
```

### Revision 9 — Expand `## Citations` (addresses GAP-1, GAP-10)

Add:
```
- NN/g, *10 Usability Heuristics for User Interface Design* — https://www.nngroup.com/articles/ten-usability-heuristics/
- W3C, *Web Content Accessibility Guidelines (WCAG) 2.2 Recommendation* — https://www.w3.org/TR/WCAG22/
- Rosenfeld, Morville, Arango, *Information Architecture for the Web and Beyond*, 4th ed., O'Reilly
- Material Design 3, *States* — https://m3.material.io/foundations/interaction/states/applying-states
- Carbon Design System, *Empty States Pattern* — https://carbondesignsystem.com/patterns/empty-states-pattern/
- Atlassian Design System, *Empty State / Skeleton* — https://atlassian.design/components/empty-state/
- Smashing Magazine, *True Lies of Optimistic UIs* — https://www.smashingmagazine.com/2016/11/true-lies-of-optimistic-user-interfaces/
- WorkOS, *Developer's guide to multi-tenant SaaS architecture* — https://workos.com/blog/developers-guide-saas-multi-tenant-architecture
- ChatDev (OpenBMB) Designer-role precedent — https://github.com/OpenBMB/ChatDev
```

---

## Sources

- https://www.nngroup.com/articles/ten-usability-heuristics/
- https://www.nngroup.com/articles/empty-state-interface-design/
- https://www.nngroup.com/articles/breakpoints-in-responsive-design/
- https://www.w3.org/TR/WCAG22/
- https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/
- https://m3.material.io/foundations/interaction/states/applying-states
- https://carbondesignsystem.com/patterns/empty-states-pattern/
- https://atlassian.design/components/empty-state/
- https://atlassian.design/components/skeleton/
- https://www.smashingmagazine.com/2016/11/true-lies-of-optimistic-user-interfaces/
- https://www.smashingmagazine.com/2016/09/how-to-design-error-states-for-mobile-apps/
- https://www.smashingmagazine.com/2022/08/error-messages-ux-design/
- https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates
- https://workos.com/blog/developers-guide-saas-multi-tenant-architecture
- https://github.com/OpenBMB/ChatDev
- https://arxiv.org/html/2307.07924v5
- `superpowers:brainstorming/visual-companion.md` (SP plugin)
- Rosenfeld / Morville / Arango, *Information Architecture for the Web and Beyond*, 4th ed., O'Reilly (book)
