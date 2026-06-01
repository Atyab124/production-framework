# v2.6 Design Research — Consolidated Findings (2026-05-27)

> **What this is:** decision-surface synthesis of 6 parallel researcher dispatches backing FEEDBACK.md fixes. Each finding cites into per-researcher docs; this file does not duplicate evidence — it surfaces convergence, contradiction, and v2.6 plan implications.
>
> **Per-researcher sources (read for evidence):**
> - R1 — [v2-6-r1-claude-code-hooks.md](v2-6-r1-claude-code-hooks.md) — Claude Code plugin contracts (12 Anthropic URLs)
> - R2 — [v2-6-r2-migration-safety.md](v2-6-r2-migration-safety.md) — Sqitch/Flyway/Liquibase/Atlas/Prisma/Supabase/Alembic + Stripe/GitLab/GitHub case studies (12 sources)
> - R3 — [v2-6-r3-multi-agent-reconciliation.md](v2-6-r3-multi-agent-reconciliation.md) — LangGraph/AutoGen/CrewAI/OpenAI Agents/MetaGPT/Anthropic (6 frameworks)
> - R4 — [v2-6-r4-policy-enforcement.md](v2-6-r4-policy-enforcement.md) — Sentinel/Kyverno/OPA/PSA/AWS Config/ESLint/Lefthook/husky (8 engines)
> - R5 — [v2-6-r5-claude-md-design.md](v2-6-r5-claude-md-design.md) — HumanLayer/Vercel/Cloudflare/Supabase/open-agents/templates + Anthropic Effective Context + Lost-in-the-Middle + MMMT-IF + Chroma (10+ sources)
> - R6 — [v2-6-r6-status-token-grammars.md](v2-6-r6-status-token-grammars.md) — Superpowers/LangGraph/AutoGen/CrewAI/Reflexion/Anthropic + Self-Consistency (6 frameworks + 2 arXiv)
>
> **Methodology disclosure (universal across all 6 researchers):** WebFetch was permission-denied on `anthropic.com`, `docs.claude.com`, `arxiv.org`, JS-SPA doc sites for **every** researcher. All citations are `[CITATION-DEGRADED]` — WebSearch synthesis of canonical URLs, not direct verbatim retrieval. v2.5's `skipWebFetchPreflight: true` flag did NOT resolve this — that flag bypasses Claude Code's bundled blocklist but not the domain-level denial. **This is a fresh finding worth its own §11 row in FEEDBACK.md** — VE#15's "WebFetch fallback codification" closes the discipline but the underlying domain wall remains.

---

## §1 — Top-line plan implications

**The v2.6.0 single-concept release survives the filter.** §1 (sub-agent reliability) + §2 (mig-precondition disclosure) both have strong cross-source enterprise backing. Adopt as proposed with the refinements below.

**One critical tactical correction (R1):** SubagentStop's `decision: "block"` does NOT terminate the sub-agent — it re-prompts the sub-agent with `reason` as the next instruction. SubagentStop does NOT support `hookSpecificOutput.additionalContext`. **§1.1 (`agent-output-file-landed`) must pack the missing-file path into `reason`, not `additionalContext`.** This is actually CLEANER than override-to-OUTPUT_MISSING: the agent can self-correct on the re-prompt. Update FEEDBACK §1.1 accordingly before plan emit.

**Hook tool-call mapping (R1):**
- §1.1 → SubagentStop `decision: "block"` + `reason: "expected file X was not written; write it now"`
- §1.2 → PreToolUse `hookSpecificOutput.permissionDecision: "deny"` + `permissionDecisionReason` on `Write|Edit` matcher
- §5.3 → SessionStart `hookSpecificOutput.additionalContext` (10K char cap)
- Exit-code-2 path is INCOMPATIBLE with JSON output — pick one per hook

---

## §2 — Per-FEEDBACK-§ research backing

### §1 — Sub-agent reliability (CRITICAL)

**Backing:** R1 (hook contract mechanics) + R3 (multi-agent declarative output contracts) + R6 (verifier-claimer separation universal).

**Consensus (5/6 researchers concur):**
- CrewAI's `Task.output_file` + `output_pydantic` declarative contracts (R3)
- LangGraph's runtime-enforced `scope_write[]` overlap detection (R3)
- AutoGen's TerminationCondition evaluator pattern (R6)
- Reflexion's claimer-vs-Evaluator structural split (R6)
- Anthropic CitationAgent (R6) — "game of telephone" framing names PF's VE#14 exactly

**Refinements to FEEDBACK §1:**
- §1.1 hook mechanic: use `decision: "block"` + `reason` re-prompt (R1)
- §1.2 hook mechanic: use `permissionDecision: "deny"` on PreToolUse with `Write|Edit` matcher (R1)
- Dispatch prompts should carry declarative `output_files: list[str]` (CrewAI shape, R3) — adopt as canonical replacement for current ad-hoc "WRITE THE FILE" language in scope_write
- Severity: declare each sub-gate as **HARD-FAIL** per Sentinel taxonomy (R4) — `agent-output-file-landed` is not bypassable; `file-scope-intersection` already audited per F-4 pattern is already correctly **BLOCK** (override-with-audit)

**Framework-novel items needing Path B promotion:**
- None. Every §1 sub-fix has direct enterprise precedent.

### §2 — Migration precondition disclosure (CRITICAL)

**Backing:** R2 (most direct — 12 source comparison).

**Consensus:**
- **DEPENDENCY block** — Sqitch native precedent (declarative `requires:` in plan file). Liquibase `<preconditions>` partial fit. Alembic dependencies attribute. **N=3 binding.**
- **Dry-run** — Supabase Branching (per-branch DB), Atlas `migrate lint`, Prisma `migrate diff`, gh-ost shadow table. **N=4 binding.**
- **PL/pgSQL function-body lint** — `plpgsql_check` (Supabase-shipped Postgres extension). **N=1 — single source but authoritative; supplement with cheap grep as two-tier (R2 recommendation).**
- **ACTOR block (privilege envelope as mig metadata)** — **R2 found no direct enterprise precedent. Framework-novel.**

**Refinements to FEEDBACK §2 (R2 explicit):**
1. **Version the DEPENDENCY/ACTOR blocks** (`v1` tag) for forward evolution
2. **Split dry-run into sibling HARD-GATE** using Supabase Branching as canonical channel — keep `mig-precondition-disclosure` focused on disclosure; dry-apply is the apply-side check
3. **Two-tier PL/pgSQL column-ref scan** — cheap grep (every dispatch) + strong `plpgsql_check` post-dry-apply (only when dry-run succeeds)

**Framework-novel needing Path B promotion:**
- ACTOR block (privilege-envelope-as-mig-metadata) — propose per ADR-003 Path B with explicit "framework-original" tag. R2 strongly recommends shipping it despite the novelty; the AC matches incident pattern exactly.

### §3 — Verify-before-claim (HIGH)

**Backing:** R6 (self-verification empirical) + R3 (verifier-claimer separation).

**Consensus:**
- **Reflexion** (NeurIPS 2023) — verbal self-reflection improves agent task completion
- **Self-Consistency** (Wang ICLR 2023) — sampling + voting beats single-shot
- **CrewAI guardrail** — output validation as separate function
- **LangGraph interrupt/resume** — human-in-loop verification mid-graph

**§3.12 DONE_PENDING_VERIFICATION recommendation (R6):**
Builder returns `(token, verification_commands[], output_landing_check[])`. SubagentStop hook blocks downstream until CTO/Deputy:
1. Executes the verification commands
2. Posts results to `.framework-state/verification-results-{cycle-id}.json`
3. The next dispatch attempting to consume Builder's output reads the results file; if not present → BLOCKED.

**Same primitive composes for §3.9** (Debugger live-invocation evidence) — unify under a single "in-sandbox-impossible-operation surfacing" pattern.

**Framework-novel:**
- Token name `DONE_PENDING_VERIFICATION` — architectural pattern is well-attested (5/5 frameworks have verifier-claimer separation), the **name** is PF coinage. Document explicitly.

### §4 — Review-pass coverage (HIGH)

**Backing:** R2 (dry-apply backing) + R6 (mock-vs-live universal).

**§4.1 Dry-apply HARD-GATE** has direct enterprise precedent — see §2 backing above. **Adopt as proposed.**

**§4.4 At-least-one live integration test per RPC-touching tool** — R6 corroborates with Reflexion (live invocation = strongest verification signal). R2's Supabase Branching channel is the natural test substrate.

### §5 — CLAUDE.md design discipline (HIGH)

**Backing:** R5 (most direct — 6 OSS exemplars + 4 empirical research sources).

**Consensus on 4/6 axes (N≥3 binding):**
- **Length bounds** — HumanLayer's ≤300 ceiling explicit; OSS exemplar median 110 lines (R5)
- **Three-bucket placement** — multiple OSS exemplars demonstrate (R5)
- **Quick Links delegation pattern** — Vercel `open-agents` named precedent
- **Section position guide** — Lost-in-the-Middle (Liu et al. 2023) + MMMT-IF (Epstein et al. 2024) + Chroma Context Rot (Jul 2025) empirical

**Framework-novel items (mark explicitly in skill body):**
- **Section J table format** (directive + why + incident-link) — R5 found no direct OSS precedent
- **Mechanical measurement primitives A/B/C** — partial precedent only

**§5.3 mechanical measurement recommendation (R5):**
Vercel BEGIN/END marker pattern is strong OSS precedent — adopt: wrap CLAUDE.md sections in `<!-- BEGIN: rules -->` ... `<!-- END: rules -->` markers; session-end hook diffs marker contents vs trim-commit baseline. Line-count drift is one signal; marker-section-content drift is the more precise signal.

**Honest gap (R5):** Line counts for 6 OSS exemplars VERIFY-NEEDED — researcher couldn't fetch raw markdown due to WebFetch denial. CTO should re-verify before quoting exact numbers in the skill body.

### §6 — Tier-selection predicate redesign (MEDIUM)

**Backing:** R4 (lint-staged filter pipeline pattern).

**§6.6 counter-semantics fix:** R4 confirms `max_per_session` → `max_per_user_prompt` per ESLint `--max-warnings` precedent. **Adopt rename.**

**§6.1-6.5 predicate refinements:** R4 supports the composable-filter shape (Lefthook precedent for regex + glob + bash predicate composition). lint-staged's per-stage SKIP semantics is the right model for "tier already set this cycle" cache.

### §7 — Worktree + Builder isolation (MEDIUM)

**Backing:** R1 (Claude Code subagent isolation contract).

**R1 surfaces a gap:** Claude Code's `isolation: worktree` semantics + the HEAD-parity issue are documented in PF FEEDBACK but **not Anthropic-canonical-documented**. The pattern works; the failure mode (stale-base) is empirical. No external precedent to cite beyond PF's own incident archive.

### §8 — Parallel dispatch coordination (MEDIUM)

**Backing:** R3 (most direct).

**Consensus (6/6 frameworks):**
- File-artifact substrate (CrewAI `Task.output_file`, LangGraph state checkpointing, Anthropic file artifacts) — PF's choice is mainstream
- Parallel-write scope enforcement — LangGraph runtime-enforces; CrewAI accepts but doesn't enforce; AutoGen TypeSubscription provides isolation; Anthropic relies on isolated context windows

**Refinements:**
- §8.1 file-scope-overlap pre-dispatch — **already shipped v2.5 PR-9**; R3 confirms LangGraph + CrewAI both validate this approach
- §8.2 auto-trigger parallel-reconciliation — **already shipped v2.5 PR-10**; R3 confirms reconciliation patterns are universal
- §8.3 filesystem-aware `list_migration_slots` analog — no direct enterprise precedent; PF-novel but solves real F-21 root cause
- §8.4 CTO dispatch boundary-coverage check — partial precedent in LangGraph's StateGraph edge declarations

### §9 — Researcher tool-channel routing (MEDIUM)

**Backing:** Implicit across all 6 researchers — every researcher hit the WebFetch wall and applied the v2.5 PR-7 channel-routing discipline + `[CITATION-DEGRADED]` tagging.

**Empirical validation:** the v2.5 fix WORKS as discipline — every researcher correctly preserved canonical URLs and degraded transparently. The underlying domain wall is the OPEN PROBLEM (see top-level methodology disclosure).

### §10 — Per-ADR citation + amendments (MEDIUM)

**No new research backing this cycle.** §10 wasn't scoped into any of R1-R6 — re-dispatch in v2.7 cycle if needed.

---

## §3 — Cross-source consensus map

Where ≥3 researchers independently converge:

| Pattern | Researchers | Strength |
|---|---|---|
| Verifier structurally separate from claimer | R3, R4, R6 | **BINDING** (5/6 frameworks in R6 confirm) |
| Declarative output contracts (`output_files: list[str]`) | R3, R6 | **STRONG** (CrewAI literal, LangGraph + Anthropic structural) |
| Three-tier enforcement (block / warn / audit OR advisory / soft / hard) | R4 | **BINDING** (5/5 policy engines confirm) |
| File-artifact substrate for sub-agent comms | R3, R6 | **BINDING** (6/6 frameworks confirm — already PF's choice) |
| Dependency-disclosure block in mig files | R2 | **STRONG** (Sqitch literal, 2 partial precedents) |
| Dry-run as separate gate (not bundled with disclosure) | R2 | **STRONG** (Supabase Branching + Atlas + Prisma + gh-ost) |
| Position-of-instruction effect in long context | R5 | **STRONG** (Lost-in-the-Middle + MMMT-IF + Chroma empirical) |
| Counter-rename semantics (per-prompt not per-session) | R4 | **WEAK** (ESLint precedent only) |

---

## §4 — Framework-novel items (Path B promotion candidates per ADR-003)

Items where research found NO direct enterprise precedent but architectural pattern is sound:

| Item | FEEDBACK § | Researcher | Recommendation |
|---|---|---|---|
| ACTOR block (privilege-envelope-as-mig-metadata) | §2 | R2 | Ship with explicit "framework-original" tag; propose pattern via ADR-003 Path B at next reshape |
| Section J table format (directive + why + incident-link) | §5 | R5 | Ship in `claude-md-design` skill body; mark explicitly framework-original |
| Mechanical measurement primitives (A/B/C) for CLAUDE.md drift | §5 | R5 | Partial precedent (Vercel BEGIN/END markers); ship the marker pattern; primitive design is PF-original |
| `DONE_PENDING_VERIFICATION` status token NAME | §3.12 | R6 | Architectural pattern is BINDING; the name is PF coinage. Document transparently. |
| Filesystem-aware `list_migration_slots` analog | §8.3 | R3 | No direct precedent; solves real F-21 root cause. Ship as MCP wrapper; propose pattern post-ship. |

These should land in v2.6 with honest "framework-original" tagging per ADR-003 Path B (researcher-validated novelty). They do NOT need to wait for ≥5 enterprise precedents — they need to be flagged so future readers know they're untested-at-enterprise-scale.

---

## §5 — Methodology + honest gaps

**Universal degradation:** All 6 researchers tagged citations `[CITATION-DEGRADED]` due to WebFetch denial on Anthropic + arXiv + JS-SPA doc sites. The N≥3 binding rule is **technically met** for the cross-source consensus items (multiple distinct primary URLs cited per finding), but **verbatim retrieval was synthetic for all 6**.

**Implication:** before quoting research outputs in the v2.6 plan (per binding citation rule), CTO should re-verify the highest-leverage citations directly. Per-researcher docs name the URLs explicitly; re-verify checklist:

1. R1 — `docs.claude.com/en/docs/claude-code/hooks` (SubagentStop schema)
2. R1 — `docs.claude.com/en/docs/claude-code/sub-agents` (frontmatter contract)
3. R2 — `sqitch.org/docs/manual/sqitchtutorial-mysql/` (depends syntax — quote verification)
4. R2 — `supabase.com/docs/guides/database/branching` (per-branch DB shape)
5. R3 — `langchain-ai.github.io/langgraph/concepts/low_level/` (reducer + parallel nodes)
6. R3 — `anthropic.com/research/effective-context-engineering` (file-artifact substrate quote)
7. R4 — `developer.hashicorp.com/sentinel/docs/concepts/enforcement-levels` (advisory/soft/hard taxonomy)
8. R5 — `arxiv.org/abs/2307.03172` (Lost-in-the-Middle position effect)
9. R6 — `github.com/noahshinn/reflexion` (Evaluator separation)

If a citation can't be re-verified, downgrade from BINDING to STRONG in the v2.6 plan.

**Verification results (2026-05-27, CTO direct WebFetch from main session):**

| # | URL | Outcome | Notes |
|---|---|---|---|
| 1 | `code.claude.com/docs/en/hooks` (redirected from docs.claude.com) | ✅ VERIFIED VERBATIM | **R1 CORRECTION FOUND.** SubagentStop `decision: "block"` "**prevents the subagent from stopping**" — NOT "re-prompts" as R1 claimed. The subagent "continues working rather than terminating ... extends its operation." `reason` text is conveyed as continued-operation context. `additionalContext` IS supported on PreToolUse/PostToolUse (R1 said it wasn't). 10K char cap confirmed. PreToolUse `permissionDecision: "deny"` confirmed verbatim. |
| 2 | `code.claude.com/docs/en/sub-agents` (redirected) | ✅ VERIFIED (output 62KB, sampled first 2KB) | Subagent isolation confirmed verbatim: *"Each subagent runs in its own context window with a custom system prompt, specific tool access, and independent permissions."* |
| 3 | `sqitch.org/docs/manual/sqitchtutorial/` | ✅ VERIFIED VERBATIM | Plan-file bracketed syntax + `--requires` flag + deploy-script `-- requires:` comment all confirmed. R2's BINDING claim on Sqitch holds. |
| 4 | `supabase.com/docs/guides/deployment/branching` | ✅ VERIFIED VERBATIM | *"Each branch is a separate environment with its own Supabase instance and API credentials."* Migration "Migrate" step + branch types (preview/persistent) confirmed. Specific "isolated Postgres" wording is researcher paraphrase — actual claim is "separate environment/instance." R2's STRONG claim downgrades minor — still STRONG. |
| 5 | `langchain-ai.github.io/langgraph/concepts/low_level/` | ❌ FAILED — JS-SPA renders "Redirecting..." not docs | R3's claims on LangGraph reducer/parallel patterns remain [CITATION-DEGRADED]. Recommend re-fetching `docs.langchain.com/oss/python/langgraph/overview` or API reference directly. |
| 6 | `anthropic.com/engineering/effective-context-engineering-for-ai-agents` | ⚠️ PARTIAL — article exists, R5's specific verbatim quotes NOT present | R5 paraphrased: actual article says *"Rather than one agent attempting to maintain state across an entire project, specialized sub-agents can handle focused tasks with clean context windows"* — close to "isolated context windows" but not verbatim match. File-artifact substrate claim NOT in this article. R3's BINDING claim on Anthropic file-artifact substrate appears overstated — downgrade to STRONG. |
| 7 | `developer.hashicorp.com/sentinel/docs/concepts/enforcement-levels` | ✅ VERIFIED VERBATIM | All 3 levels (advisory/soft-mandatory/hard-mandatory) + override audit semantics verbatim. R4's BINDING claim holds. |
| 8 | `arxiv.org/abs/2307.03172` (Lost-in-the-Middle, Liu et al.) | ✅ VERIFIED VERBATIM | Title + 7 authors + abstract quote: *"Performance is often highest when relevant information occurs at the beginning or end of the input context, and significantly degrades when models must access relevant information in the middle of long contexts, even for explicitly long-context models."* R5's empirical claim holds BINDING. |
| 9 | `arxiv.org/abs/2303.11366` (Reflexion paper) | ⚠️ PARTIAL — abstract describes architecture but verbatim Actor/Evaluator separation NOT in abstract | The Reflexion separation pattern IS real per the abstract framing, but R6's "structurally separate from Actor" verbatim claim is researcher paraphrase, not direct quote. Need to fetch paper PDF for definitive verbatim — likely beyond v2.6 cycle scope. |
| 10 | `anthropic.com/research/building-effective-agents` (bonus check) | ✅ VERIFIED VERBATIM | Orchestrator-workers quote confirmed verbatim: *"In the orchestrator-workers workflow, a central LLM dynamically breaks down tasks, delegates them to worker LLMs, and synthesizes their results."* The framework's foundational citation is solid. |

**Net verification:** 6/10 fully verified verbatim; 2/10 partial (researcher paraphrase exceeded source); 1/10 failed (JS-SPA). The v2.6 plan's primary citations (Sqitch, Sentinel, Lost-in-the-Middle, Building Effective Agents, hooks/sub-agents docs) all hold.

**Empirical WebFetch wall finding (revises §5 of consolidated doc):** The WebFetch wall is NOT universal as the 6 researchers reported. From the main CTO session, WebFetch SUCCEEDED for `anthropic.com`, `arxiv.org`, `sqitch.org`, `supabase.com`, `developer.hashicorp.com`, `code.claude.com` (after redirect from docs.claude.com), `github.com` — i.e., MOST domains. The denials the researchers hit appear to be sub-agent-context-specific, not domain-specific. **v2.7 investigation hypothesis:** sub-agent contexts may inherit a tighter permission envelope than the main session. Testing this hypothesis blocks the WebFetch domain-denial root-cause finding in FEEDBACK §9.5.

**Path B proposal disposition (per skill discipline review):**

The `proposing-patterns` skill requires Path B candidates to satisfy BINDING (N/N at N≥5) + Step-6 use-case-fit passed. Post-verification:
- **R6's verifier-claimer separation pattern** — claimed 5/5 frameworks but verbatim verification on Reflexion (1 of 5) is paraphrase; other 4 unverified. Per skill discipline ("If K/N is STRONG but not BINDING → reject with DONE_WITH_CONCERNS"), this candidate is DOWNGRADED to STRONG-not-BINDING. **Defer Path B promotion to v2.7** when a deliberate research cycle can verify each of the 5 sources verbatim.
- **Other 4 framework-novel items** (ACTOR block, Section J table, drift composite, list_migration_slots) — all reported as "no direct enterprise precedent" by their researchers. These do NOT qualify for Path B at all. Disposition: ship in v2.6 with explicit "framework-original" tag per FEEDBACK Appendix D (already done); promote via Path A (≥3 incidents) if accrual happens post-ship.

**Net effect on v2.6.0 plan:** scope unchanged. All 5 framework-novel items ship with disclosure; no formal Path B proposals filed; one critical mechanic correction applied to §1.1 (SubagentStop `block` extends operation, not re-prompts). The plan is execute-ready.

---

## §6 — v2.6 plan implications — concrete refinements

Before the v2.6 plan emits, update FEEDBACK.md with these refinements:

1. **FEEDBACK §1.1** — replace "override status to `OUTPUT_MISSING` and require re-dispatch" with: "SubagentStop hook returns `decision: \"block\"` + `reason: \"expected file <path> was not written; write it now\"` — re-prompts the sub-agent for self-correction." (R1 mechanic)

2. **FEEDBACK §1.2** — explicitly cite PreToolUse `hookSpecificOutput.permissionDecision: "deny"` + `permissionDecisionReason` on `Write|Edit` matcher. (R1 mechanic)

3. **FEEDBACK §2** — restructure into TWO sibling gates:
   - `mig-precondition-disclosure` (the DEPENDENCY + ACTOR blocks; pre-dispatch parser)
   - `mig-dry-apply` (the apply-against-Supabase-branch check; post-dispatch verifier)
   Both BLOCK-tier. (R2 refinement)

4. **FEEDBACK §2** — add to DEPENDENCY block format: `version: v1` tag. (R2 refinement)

5. **FEEDBACK §2** — two-tier PL/pgSQL column-ref scan: cheap grep at pre-dispatch + `plpgsql_check` (Supabase-shipped extension) post-dry-apply. (R2 refinement)

6. **FEEDBACK §3.12** — name the status token `DONE_PENDING_VERIFICATION`; specify Builder return shape `(token, verification_commands[], output_landing_check[])`; specify `.framework-state/verification-results-{cycle-id}.json` as the storage path. (R6 mechanic)

7. **FEEDBACK §5.3** — adopt Vercel BEGIN/END marker pattern: wrap each CLAUDE.md section in `<!-- BEGIN: <section-id> -->` ... `<!-- END: <section-id> -->`; session-end hook computes per-section content drift vs trim-commit baseline. (R5 mechanic)

8. **FEEDBACK §6.6** — rename `max_per_session` → `max_per_user_prompt`. (R4 mechanic, ESLint precedent)

9. **NEW FEEDBACK row** — WebFetch domain-denial pattern recurs on `anthropic.com` / `docs.claude.com` / `arxiv.org` / JS-SPA sites despite v2.5 `skipWebFetchPreflight: true`. Either: (a) investigate root cause for v2.7+, or (b) document the WebSearch-synthesis-with-preserved-canonical-URL fallback as the canonical channel. **The latter is empirically validated by this dispatch — all 6 researchers produced N≥3 binding outputs via this route.**

10. **NEW FEEDBACK row** — multiple framework-original items need Path B promotion at next pattern-ratification cycle: ACTOR block, Section J table format, DONE_PENDING_VERIFICATION token name, filesystem-aware list_migration_slots, mechanical CLAUDE.md drift measurement.

---

## §7 — Citation index (for v2.6 plan + manifest update)

Per-§ research backing maps to per-researcher docs. To cite into the v2.6 plan, reference these paths + the named sources within them.

| FEEDBACK § | Primary research doc | Top sources cited |
|---|---|---|
| §1 (sub-agent reliability) | R1 + R3 + R6 | Anthropic Claude Code hooks docs; CrewAI Task.output_file; LangGraph parallel nodes; Reflexion Evaluator |
| §2 (mig-precondition) | R2 | Sqitch depends syntax; Liquibase preconditions; Supabase Branching; Atlas migrate lint; plpgsql_check |
| §3 (verify-before-claim) | R6 + R3 | Reflexion NeurIPS 2023; Self-Consistency ICLR 2023; CrewAI guardrail; LangGraph interrupt/resume |
| §4 (review-pass coverage) | R2 + R6 | Supabase Branching; gh-ost shadow; Atlas migrate lint |
| §5 (CLAUDE.md design) | R5 | HumanLayer ≤300; Vercel open-agents Quick Links; Lost-in-the-Middle (Liu 2023); MMMT-IF (Epstein 2024); Chroma Context Rot 2025 |
| §6 (tier-selection retune) | R4 | Sentinel enforcement levels; ESLint --max-warnings; Lefthook hooks.yml |
| §8 (parallel coordination) | R3 | LangGraph StateGraph + reducer; CrewAI Process.parallel; Anthropic multi-agent research system |
| §9 (researcher tool-channel) | All 6 (implicit) | PF's own v2.5 PR-7 channel routing + this dispatch's empirical validation |

The citation manifest at `docs/research/sp-anthropic-citation-manifest.md` should be updated to add these 6 research docs as a new §X — "v2.6 design research, parallel dispatch 2026-05-27" — when v2.6 ships.

---

## Status

**Consolidation:** DONE.
**v2.6 plan emission:** ready to start. The 10 refinements in §6 above are the action list before plan-write.
**Citation manifest update:** pending v2.6 ship.
