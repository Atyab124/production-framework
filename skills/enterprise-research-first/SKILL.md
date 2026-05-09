---
name: enterprise-research-first
description: "Use before deciding any new interaction model, data shape, sync strategy, module location, or API contract — invoked by Architect, Database Engineer, and Researcher agents at design-decision time. Compares the proposed pattern against 3-6 enterprise/OSS implementations and computes consensus strength; unanimous consensus is binding."
---

## Overview

Most "invented" patterns have been solved ten or more times by enterprise tools. The edge cases that appear novel in a new codebase are usually documented bugs in Jira's changelog, shipped features in Linear's engineering blog, or open issues in a GitHub tracker. Inventing without checking pays the full discovery price again: weeks of edge-case bugs, rollbacks, and remediation cycles.

**9/9 enterprise sources** require an alternatives-or-prior-art section in the design artefact: Amazon PR/FAQ, Google Design Docs, Rust RFC template (RFC 2333), Kubernetes KEPs, AWS Well-Architected, ThoughtWorks Tech Radar, ADR/MADR, Spotify RFC+ADR, Squarespace opinionated RFC. PF v2 codifies this discipline as `enterprise-research-first`. The *discipline* is enterprise-cited and SP-precedented (5 SP skills enforce a smaller-scope analogue: "compare against references / existing patterns / baseline / requirements"). The *N≥3 STRONG / N≥5 BINDING* threshold is PF-internal calibration.

This skill operationalizes the discipline: it produces a structured comparison table, assigns a binding strength to each finding, and names outliers explicitly so they cannot be silently ignored.

<HARD-GATE>
Do NOT propose a new interaction model, data shape, sync strategy, module location, or API contract until the comparison table is written, the consensus strength is computed, outliers are named, and the use-case-fit check is documented. Skipping this skill at design-decision time is a U-PP-10 violation. "Based on training data" is not a citation. Verify the source at research time.
</HARD-GATE>

## When to Use

**At design time:**

- Any new **interaction model** (per-field auto-save, batch save, drag-and-drop reorder, inline edit, bulk action).
- Any new **data shape** or discriminator (new entity type, relationship type, polymorphic field, status enum).
- Any **sync strategy** (optimistic updates, realtime subscriptions, polling, background sync, offline-first).
- Any **module location / boundary** decision (where a new feature lives in the codebase).
- Any **API contract** shape (resource modeling, naming, error envelope).
- Before `writing-arch-doc` Tier 3 Step 1 interaction model check.
- Before `seven-validation-questions` Q2 ("Why this approach?") — research first, answer second.

**At fix time (added 2026-04-30 per `docs/research/bug-class-taxonomy-2026-04-30.md`):**

Before applying a fix to a bug class with ≥3 documented enterprise solutions. Name the class first; pull this skill before writing the fix. If the enterprise solution is structurally different from the proposed local fix, treat the local fix as STRONG (not BINDING) divergence requiring U-AP-4 framework-level proof.

The 10 documented bug classes (per Wave 1.5 R-E):

- **BC-1 Closure-staleness** — `react-mentions`, GitHub `text-expander-element` (7/7 BINDING — see Wave 3 Pattern 2)
- **BC-2 Cache-invalidation** — TanStack Query, SWR, Apollo Client
- **BC-3 Race condition** — Goetz *Java Concurrency in Practice*; Honeycomb timing-dependent diagnostics (BINDING 7/10)
- **BC-4 Hydration mismatch** — react.dev errors #418/#419; Next.js docs (STRONG 3/10; closes Audit Item 12)
- **BC-5 Optimistic-rollback** — TanStack Query mutations, Linear sync, Notion local-first
- **BC-6 IDOR / BOLA** — OWASP API1:2023, NIST AC-3 (closes G-CRIT-1 visibility leak class)
- **BC-7 N+1 query** — ActiveRecord, GraphQL DataLoader, Prisma
- **BC-8 Deadlock** — PostgreSQL locking docs, Goetz JCiP Ch. 10
- **BC-9 Spec-divergence (missing/extra/misunderstood)** — SP `subagent-driven-development/spec-reviewer-prompt.md` 3-category framing
- **BC-10 State-machine / transition** — Statecharts spec, XState, Erlang OTP gen_statem

(Full taxonomy at `docs/research/bug-class-taxonomy-2026-04-30.md`.)

## Core Pattern

You MUST create a TodoWrite item per step and complete them in order.

### Step 1 — Select tools

Pick 3–6 enterprise or open-source tools in the target problem space. Prefer open-source with accessible code (file paths are citable). Closed tools must be cited via engineering blog, public changelog, or official API/UI documentation.

Good tool sets by problem space:
- Task/project management: Linear, Asana, ClickUp, Jira, Notion, Todoist, Height.
- Real-time collaboration: Figma, Notion, Google Docs, Liveblocks (OSS), Yjs (OSS).
- Chat/messaging: Mattermost (OSS), Rocket.Chat (OSS), Slack (blog/changelog), Discord (blog).
- Data sync / offline: TanStack Query (OSS), SWR (OSS), RxDB (OSS), PouchDB (OSS).
- Multi-tenant data isolation: AWS SaaS Lens silo/pool/bridge, Postgres RLS, Linear's workspace model, Notion's workspace model.

**Source-quality heuristic:** prefer **primary sources** (OSS code in the repo, official engineering blog, public changelog) over **secondary sources** (third-party tutorials, SEO-optimized listicles). Anthropic's multi-agent research system documents this exact failure mode:

> "Human testers noticed that early agents consistently chose SEO-optimized content farms over authoritative sources like academic PDFs, and adding source quality heuristics to prompts helped resolve this issue."
> — *How we built our multi-agent research system*, Anthropic Engineering, Jun 2025 (https://www.anthropic.com/engineering/multi-agent-research-system)

### Step 2 — Trace the exact implementation

For each tool, find the specific implementation. Not "they do X" — provide a citation:
- OSS: `file:line` or `directory/` in the repo with a commit hash or tag.
- Closed: URL to engineering blog post, public changelog, or official docs page, plus a verbatim quote.

If a source cannot be cited, it cannot contribute to a consensus claim.

**Citation discipline (Anthropic-grounded):** cite verbatim text or precise file:line — not paraphrase.

> "Support the answer with citations that incorporate direct quotations from the underlying source documents."
> — Anthropic Citations API framing (https://docs.claude.com/en/docs/build-with-claude/citations)

### Step 3 — Produce the comparison table

```
| Aspect | Tool A | Tool B | Tool C | ... | Consensus strength | Binding? |
|---|---|---|---|---|---|---|
| <design aspect> | <how A does it> | <how B does it> | <how C does it> | ... | N/N unanimous | YES |
```

One row per design aspect (not one row per tool). Each cell is the tool's specific approach with a citation — not a yes/no. The last two columns are computed from the rows.

### Step 4 — Assign consensus strength

| Strength | Condition | Action |
|---|---|---|
| **BINDING** | N/N unanimous AND N≥5 | Must follow. Divergence requires framework-level proof that the consensus approach is impossible in this stack, documented with links. "Simpler" is never sufficient. |
| **STRONG** | (N-1)/N or better AND N≥3 | Should follow. Divergence justified with a specific rationale in the plan. |
| **SPLIT** | No clear majority | Choose an approach, document the reasoning. |
| **INSUFFICIENT** | N<3 | Cannot claim consensus. State the finding as preliminary, gather more sources. |

**N counts the number of tools researched, not the number that agree.** Unanimous means every tool in the set converges. The N≥3 / N≥5 thresholds are PF-internal calibration; the *discipline* of consensus-before-decision is enterprise-cited (9/9).

### Step 5 — Name outliers explicitly

When one tool diverges from the others, name it and explain why:

> "Matrix is the exception: it uses a DAG sync model rather than OT/CRDT because federation across homeservers requires conflict-free merges at the transport layer, not the document layer."

An unnamed outlier cannot be evaluated. Naming it either strengthens the consensus ("the exception is domain-specific, not applicable here") or weakens it ("the exception applies to our case too").

Rust RFC 2333 captures this:

> "Discuss prior art, both the good and the bad, in relation to this proposal."
> — Rust RFC template (https://github.com/rust-lang/rfcs/blob/master/0000-template.md)

### Step 6 — Use-case-fit check (before adopting N/N)

Even when consensus is BINDING, adopting the pattern requires verifying it fits the project's use case. Skip this step and you risk cargo-culting a solution designed for a different capability surface.

1. **List the capabilities the consensus pattern enables.** For each aspect of the pattern, name the concrete capability — e.g., "server-initiated API calls," "refresh tokens surviving browser-cache clear," "cross-device session handoff," "offline writes reconciled on reconnect."
2. **For each capability, name the concrete project use case needing it.** Not a hypothetical future use case — a current one.
3. **If no use case maps to a capability, that capability is over-engineering for your project.**

**"We don't need capability X that the pattern enables" IS valid divergence — distinct from "simpler."** The former is a scoped capability-need claim; the latter is a preference. U-AP-4 rejects the latter and accepts the former.

Document the check result in the plan. An N/N adoption without a use-case-fit check risks adopting a pattern built for a different scale, workload, or threat model than yours.

**Incident:** 7/7 enterprise tools used server-side OAuth for a document-picker integration. Adopting without a use-case-fit check nearly forced a full Tier-3 server-side auth phase. A domain expert's pushback surfaced that the project needed none of the server-side capabilities the pattern enables; browser-only MSAL + metadata-only attach was the correct scope. The consensus was BINDING for projects with that capability need — not ours.

## Anti-Patterns

### Anti-Pattern: "I already know what Tool X does"

Training-data recall is not a citation. Verify at research time. The model's snapshot of "what Linear does" can be 18 months stale or wrong. Even if it's correct, you cannot defend the decision in a design review without the source.

### Anti-Pattern: "Two tools agree, that's enough"

N<3 is INSUFFICIENT per the consensus grammar. Two-tool agreement is coincidence, not consensus. Three is the floor for claiming a pattern is shared; five is the floor for BINDING.

### Anti-Pattern: "This pattern is simpler than the consensus, so simpler wins"

U-AP-4 explicitly rejects this. The valid divergence rationale is "the consensus pattern requires capabilities our project does not need" (Step 6 use-case-fit check), not "simpler." If you find yourself reaching for "simpler" — run Step 6 honestly.

## Red Flags

| Excuse | Reality |
|---|---|
| "Most tools do X" | "Most" without a count is unverifiable. State 4/6 or 5/5 explicitly. |
| "Based on training data" | Training data is a starting list of tools to research, not a citation. Verify against the live source. |
| "These three tools agree" (cherry-picked from a larger set) | If two more tools were researched and diverged, report 3/5, not 3/3. Cherry-picking produces a false unanimous claim. |
| "Simpler is better" | U-AP-4 rejects this. Valid divergence is "no use case for the capability the consensus pattern enables." |
| "BINDING with N=3 unanimous" | BINDING requires N≥5 unanimous. N=3 is STRONG, not BINDING. |
| "We already researched this last sprint" | If `docs/research/<topic>.md` doesn't exist or is stale, re-verify at research time. |
| "The framework's docs cover this" | Framework docs are one source. They count as one tool, not three. |

## Self-Check Before Declaring DONE

Before reporting the comparison table to the dispatching agent, audit your output against the five criteria Anthropic uses for its LeadResearcher (multi-agent research system, Jun 2025):

1. **Factual accuracy** — does each cell in the comparison table match the cited source?
2. **Citation accuracy** — does each citation resolve to the exact line/section claimed?
3. **Completeness** — are all design aspects covered, not just the easy ones?
4. **Source quality** — are sources primary (OSS code, official docs) rather than secondary (tutorials, SEO content)?
5. **Tool efficiency** — N=3-6 sources researched, not N=12 (over-research) or N=2 (under-research)?

A row that fails any criterion is unverified. Re-verify or strike it.

## Quick Reference

- Adopt > invent. Pull this skill before designing any new model.
- Cite sources. "Based on training data" is not a citation.
- Count tools explicitly. "Most tools" must become "4/6 tools."
- N≥3 to claim consensus. N≥5 to claim BINDING.
- N/N unanimous + N≥5 = BINDING per U-AP-4. Divergence requires proof, not preference.
- Name outliers. An unnamed outlier invalidates the consensus claim.
- Use-case-fit check before adopting N/N. "We don't need capability X" is valid divergence; "simpler" is not.

## Common Recovery

When research tooling fails (WebFetch denied, search results sparse):

| Symptom | Error class | Recovery path | Escalation if recovery fails |
|---|---|---|---|
| `WebFetch` returns permission-denied for a URL | Domain not in allowlist OR site blocks scrapers | Fall back to WebSearch with the canonical URL as one of the search terms. Tag the citation `(via WebSearch synthesis of canonical URL)` per researcher discipline. | If the URL is critical and WebSearch can't surface it, return NEEDS_CONTEXT — don't fabricate. |
| Search returns <3 candidate frameworks for the question | Question too narrow OR domain is genuinely niche | Broaden query terms; widen the comparison axis. Try `gh search code` for OSS-implementation-anchored searches. | If <3 found after 15-call budget, return NEEDS_CONTEXT with the search transcript. |
| Same source cited from multiple URLs (mirrors / aggregators) | Surface diversity is illusory | Treat as one source; find genuinely-different second + third. | If genuine diversity isn't available, the question may be a single-source space; honestly report N=1. |
| Citation date older than 90 days | Source may have evolved | Re-fetch the URL; verify the quote still appears. Update verification timestamp. | If quote no longer appears, find the new equivalent; update the row; note the change in the methodology section. |

Document any new failure mode in `docs/PROJECT-PLAN.md` Open Findings.

## Composability

- Feeds into `writing-arch-doc` as the interaction model check.
- Precedes `seven-validation-questions` Q2 — Q2 asks "Why this approach?" and cites the output of this skill.
- Pull before `writing-plans` when the plan introduces a new data shape, sync strategy, or module boundary.
- Output artifact: `docs/research/<topic>.md` — read by Architect, Database Engineer, Security/Compliance, and `gate-3-production-check`.

## Citations

**SP precedent (smaller-scope analogues — 5 distinct skills enforce "compare against references"):**

- `superpowers/5.0.7/skills/brainstorming/SKILL.md` line 103 — "Explore the current structure before proposing changes. Follow existing patterns."
- `superpowers/5.0.7/skills/systematic-debugging/SKILL.md` lines 122–143 — Phase 2: Pattern Analysis ("Compare Against References", "Find Working Examples")
- `superpowers/5.0.7/skills/subagent-driven-development/implementer-prompt.md` line 91 — "Did I follow existing patterns in the codebase?"
- `superpowers/5.0.7/skills/writing-skills/anthropic-best-practices.md` line 733 — "Iterate: Execute evaluations, compare against baseline, and refine"
- `superpowers/5.0.7/skills/requesting-code-review/code-reviewer.md` line 7 — "Compare against {PLAN_OR_REQUIREMENTS}"

**Anthropic guidance (verified 2026-04-30; re-verify with WebFetch in a permitted session before binding decisions):**

- *Building Effective AI Agents* — https://www.anthropic.com/research/building-effective-agents — "find the simplest solution possible, and only increasing complexity when needed"
- *How we built our multi-agent research system* — https://www.anthropic.com/engineering/multi-agent-research-system — source-quality heuristic; five-criterion evaluation rubric
- *Effective context engineering for AI agents* — https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- *Citations* — https://docs.claude.com/en/docs/build-with-claude/citations — "support the answer with citations that incorporate direct quotations"

**Enterprise / OSS sources — 9/9 require an alternatives-or-prior-art section:**

- Amazon Working Backwards / PR-FAQ — https://workingbackwards.com/concepts/working-backwards-pr-faq-process/
- Google Design Docs — https://www.industrialempathy.com/posts/design-docs-at-google/ ("trade-offs that were considered")
- Rust RFC template + RFC 2333 — https://github.com/rust-lang/rfcs/blob/master/0000-template.md , https://rust-lang.github.io/rfcs/2333-prior-art.html
- Kubernetes KEP template — https://github.com/kubernetes/enhancements/blob/master/keps/NNNN-kep-template/README.md ("Alternatives" section required)
- AWS Well-Architected Framework — https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html
- ThoughtWorks Technology Radar — https://www.thoughtworks.com/radar (Adopt/Trial/Assess/Hold rings as N-source consensus model)
- ADR / MADR — https://adr.github.io/adr-templates/ ("Considered Options" section)
- Spotify RFC + ADR — https://engineering.atspotify.com/2024/7/technical-decision-making-in-a-fragmented-space-spotify-in-car-case-study
- Squarespace opinionated RFC — https://engineering.squarespace.com/blog/2019/the-power-of-yes-if

**Companion PF v2 research:**

- `docs/research/skill-design-enterprise-research-first.md` — full sources inventory + recommendations
- `docs/research/sp-anthropic-citation-manifest.md` (GAP-1 framing source)
- `docs/research/enterprise-multi-agent-architecture.md` (consensus-strength grammar; N≥3 / N≥5 thresholds)

## Common Mistakes

- **"Based on training data" without verifying sources at research time.** Training data is a starting point for identifying tools to research, not a citable source.
- **"Most tools do X" without a count.** Every consensus claim must name the count: "4/6 tools," "5/5 tools."
- **Claiming consensus with N=2.** N≥3 is the minimum for a consensus claim; N≥5 for BINDING.
- **"Simpler" as rationale for diverging from unanimous consensus.** U-AP-4 explicitly rejects this.
- **Citing only tools that agree.** If three agree and two diverge, report 3/5, not 3/3.
- **Treating BINDING as a default.** BINDING requires N≥5 unanimous. N=3 or N=4 unanimous is STRONG, not BINDING.
- **Skipping the use-case-fit check on N/N adoptions.** The 7/7 OAuth incident is the load-bearing example.
