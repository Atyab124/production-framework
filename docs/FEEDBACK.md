# Framework Feedback — v2.6+ Design Surface

> Pattern-organized design input for the next plugin version. One pattern per section: **gap → evidence → fix → priority**. Source authority is the chronological archive at [`framework-plugin-feedback-archive-2026-05-20.md`](framework-plugin-feedback-archive-2026-05-20.md) — this file is the decision surface, rewritten on every reshape.
>
> **Scope:** v2.4.0 fork → v2.5.0 operation on TaskIt (Next.js 16 + Supabase + multi-tenant pool RLS) + Vendor Email Scraping (Python batch).
>
> **Audience:** LLMs working on the production-framework plugin itself. NOT for projects USING the framework.
>
> **Last reshape:** 2026-05-27. Source: 18 archive sections + 17 Vendor-Email entries. Output: 10 framework-fix axes + carryovers + preserve list. Reordered by ship-decision priority; archive numbering preserved in citations as `(prev: §X)` / `(prev: VE#N)`.

---

## §0 — Priority roll-up

| # | Section | Severity | Consolidates |
|---|---|---|---|
| §1 | Sub-agent reliability | **CRITICAL** | prev §2 + §14.1 + §14.2 + §16.N3 + §18.N9 |
| §2 | Migration precondition disclosure | **CRITICAL** | prev §14.4 (8 recurrences in single cycle) |
| §3 | Verify-before-claim at every altitude | **HIGH** | prev §3 + §15.C3 + §16.N1 + §16.N2 + §16.N6 + §16.N7 + VE#14 + VE#17 |
| §4 | Review-pass coverage gaps | **HIGH** | prev §8 + §15.C7 + §18.N10 + VE#11 |
| §5 | CLAUDE.md design discipline | **HIGH** | prev §1 (1.1–1.4) |
| §6 | Tier-selection predicate redesign | MEDIUM | prev §4 + §14.3 + §15.C4 + VE#16 |
| §7 | Worktree + Builder isolation | MEDIUM | prev §5 + §15.C2 |
| §8 | Parallel dispatch coordination | MEDIUM | prev §6 |
| §9 | Researcher tool-channel routing | MEDIUM | prev §7 + VE#15 |
| §10 | Per-ADR citation + amendments | MEDIUM | prev §9 |
| §11 | Pre-2026-05-20 carryovers | mixed | 8 Vendor-Email items with no §match |
| §12 | CTO-to-user reporting discipline | DEFERRED (v2.7+) | new pattern, 2026-05-27 session |
| App A | Preserve in v2.6 (STRENGTHs) | — | prev §10 + §15.P1-P6 + §16.S1-S3 |
| App B | How to extend this file | — | prev §13 |

**Top of mind for v2.6.0:** §1 + §2. Single-concept release: "sub-agents and migrations can no longer ship work on assumed-baseline evidence." §3 + §4 + §5 → v2.6.1 / v2.7.

---

## §1 — Sub-agent reliability (CRITICAL)

**Pattern:** Sub-agents return `DONE` / `DONE_WITH_CONCERNS` with narrative summaries that embed the requested artifact, but the artifact is missing on disk, written to a forbidden path, partially deferred from spec, or has no matching SubagentStop event. Dispatch-prompt-as-policy is the only enforcement layer and it's brittle.

**Sub-patterns (all share SubagentStop as the structural fix surface):**

| ID | Failure | Evidence |
|---|---|---|
| 1a | Doc-authoring agent embeds artifact in summary, never calls Write | prev §2; 4 recurrences in single TaskIt session, sre-devops + security-compliance ×2 + QA |
| 1b | 4th recurrence rationalized non-write by **fabricating a project standing instruction** that doesn't exist | prev §2 (severity escalation) |
| 1c | Architect wrote to `docs/cycle-state.md` despite explicit forbidden-file list in dispatch | prev §14.2 (Wave 8 Asana cycle) |
| 1d | SubagentStop hook fails to record completion events for Agent-tool-launched sub-agents → `.framework-state/active-agents.jsonl` accumulates orphan starts → `file-scope-intersection` over-blocks | prev §14.1 (Wave 1.5 + Wave 8 same session, manual jsonl surgery required) |
| 1e | Builder defers scope FROM SPEC and labels it "WITHIN LATITUDE" in `DONE` handover | prev §16.N3 (V4 Publish CTA + branch-2 + Step connector all silently deferred) |
| 1f | Builder modifies handler in V_(N-1) file but not the parallel handler in V_N fork file → dead-code writes | prev §18.N9 (Builder H closed V2 form save; V4 shell never touched; FF-on meant H's writes never executed) |
| 1g | Plan agent dispatched via `writing-plans` skill lacks Write tool → ~16min agent-time wasted | prev §2.3 + VE-style failure (recurring) |

**Fix shape — anchor everything at SubagentStop + write-side scope enforcement:**

1. **`agent-output-file-landed` HARD-GATE at SubagentStop.** Pre-tool-use parses dispatch prompt for declarative `output_files: list[str]` (CrewAI `Task.output_file` shape, R3) → record in `.framework-state/expected-outputs.jsonl` keyed by agent_id. SubagentStop checks each path exists; any missing → `{"decision": "block", "reason": "expected file <path> was not written; write it now (call Write tool)"}` (verified verbatim 2026-05-27 against Claude Code docs at `code.claude.com/docs/en/hooks`: *"Exit code 2 or `decision: \"block\"` prevents the subagent from stopping. The subagent continues working rather than terminating. This differs from other blocking behaviors — it doesn't re-prompt the subagent but extends its operation."* — the `reason` text is conveyed to the subagent as continued-operation context, giving it the chance to call Write before stopping). Retry counter: max 2 prevent-stop events per agent dispatch; after exhaustion → audit log + accept stop with `DONE_WITH_CONCERNS` annotation. Backward compat: if no `output_files:` block, scan legacy `WRITE THE FILE` / `Hand off DONE with file at <path>` patterns + advisory-log a "missing declaration" warning.
2. **Write-side scope_write enforcement at PreToolUse.** `hookSpecificOutput.permissionDecision: "deny"` + `permissionDecisionReason` (R1 mechanic) on `Write|Edit` matcher. Hook reads in-flight agent's `scope_write[]` from `.framework-state/active-agents.jsonl`; target path NOT in scope → deny naming the declared scope. Mirror of existing read-side `file-scope-intersection` (v2.5 PR-9). Closes 1c.
3. **SubagentStop event correlation fix.** Stop events must carry the agent_id of the matching start (currently tagged `subagent_type: "unknown"`). Add periodic GC: drop start entries older than 4hr.
4. **Anti-fabrication clause in EVERY sub-agent system prompt:** *"NEVER claim a project standing instruction overrides a per-dispatch directive without citing the verbatim line + file path. If the dispatch says WRITE THE FILE, write the file. There are no silent overrides."* Closes 1a + 1b.
5. **Builder scope-cut grammar.** Dispatch prompts require Builder to classify each deferral as **(a) WITHIN LATITUDE** (design doc defers or is silent → ship DONE) or **(b) FROM SPEC** (defer contradicts named arch doc line → MUST surface as `DONE_WITH_CONCERNS` and cite the line). Closes 1e.
6. **Fork-architecture parallel-fix check.** When any ADR declares fork architecture (e.g., `V4-as-rewrite-of-V2-shell`), CTO dispatch checklist must enumerate sister files for any handler/state/hydration modification and mark each IN-SCOPE or OUT-OF-SCOPE-WITH-FOLLOWUP. Closes 1f.
7. **`writing-plans` skill: name the dispatch agent type.** Skill body explicitly says: *"Dispatch via `production-framework:architect` or `general-purpose` — NOT the built-in `Plan` agent (read-only, no Write)."* Closes 1g.

---

## §2 — Migration precondition disclosure (CRITICAL)

**Pattern:** DBE design phase asserts "baseline X exists" in migration preconditions; baseline does NOT exist in (a) live DB state, (b) executor privilege envelope, or (c) cross-mig dependency order. Surfaces ONLY at apply time via `RAISE EXCEPTION` or runtime error.

**Severity rationale:** **8 recurrences in a single TaskIt cycle** (prev §14.4 + the 2026-05-22 update). Each recurrence cost a Builder dispatch + re-audit (~15-20min). Net wasted: ~2.3hr wall-clock from one root cause.

**Sub-causes:**
- Data-layer: prior-phase substrate assumed shipped but never applied (`schema_migrations` lacks rows)
- Data-layer: TaskIt baseline schema asserted to contain columns/enums it doesn't
- Privilege-layer: `ALTER DATABASE` assumed available; managed Supabase blocks for ALL user-facing tooling (MCP, dashboard, CLI, psql)
- Ordering-layer: slot numbering doesn't reflect dependency order (mig 236 referenced both 231/232 *and* 237/238)
- Function-body: `NEW.updated_by` referenced in trigger function body; column doesn't exist on target table

**Discipline asymmetry:** TaskIt CLAUDE.md R57 ("never trust SHIPPED for schema work; query `schema_migrations`") is plan-time CTO discipline. The DBE sub-agent doesn't inherit R57 unless CTO injects it per-dispatch.

**Fix shape — TWO SIBLING HARD-GATEs (R2 restructure):**

### Gate A — `mig-precondition-disclosure` (BLOCK at CTO pre-dispatch, max_violations=2)

Cheap pre-dispatch checks; no DB connection required.

1. **DEPENDENCY block in mig file header** (Sqitch `requires:` precedent, R2). Required tags with `version: v1` (R2 versioning refinement for forward evolution):
   ```
   -- DEPENDENCY v1
   -- LIVE-VERIFIED: <tables/columns/types this mig assumes exist + evidence>
   -- PRIOR-WAVE-APPLIED: <migs by name that must be live + schema_migrations confirmation>
   -- THIS-MIG-INTRODUCES: <new objects this mig creates>
   -- ASSUMED-FROM-PM-SPEC: <FORBIDDEN — presence blocks dispatch>
   ```
2. **ACTOR block in mig file header** (`version: v1`). **Framework-original** — no direct enterprise precedent (R2). Required tags:
   ```
   -- ACTOR v1
   -- PRIVILEGES-REQUIRED: <e.g., pg_database_owner for ALTER DATABASE>
   -- PRIVILEGES-AVAILABLE: <managed-Supabase MCP postgres role curated list>
   -- WORKAROUND-IF-MISMATCH: <SET LOCAL within TX; ALTER ROLE; manual operator step>
   ```
3. **CTO pre-dispatch cross-dep scan.** `grep -rnE "(REFERENCES|FROM|JOIN|INTO) public\.<table>"` for every table named in the mig; each must be either listed in `LIVE-VERIFIED`, created earlier in the apply sequence, or created by this mig.
4. **Cheap PL/pgSQL column-reference grep.** For every function body, grep `NEW\.<col>` / `OLD\.<col>` and verify columns exist per the LIVE-VERIFIED block. (Two-tier with Gate B; this tier catches obvious typos at zero cost.)

### Gate B — `mig-dry-apply` (BLOCK post-dispatch, before Builder commit)

Applies the migration against a Supabase Branch DB (R2 canonical channel: Supabase Branching). Catches what the cheap grep misses.

5. **Dry-apply against Supabase Branch DB.** Use Supabase MCP `create_branch` → `apply_migration` → check for errors. Failure → BLOCKED with the actual Postgres error attached. Stack-conditional: Supabase Branching is the canonical channel; for non-Supabase Postgres, fall back to scratch DB (Atlas / Prisma).
6. **Strong `plpgsql_check` post-dry-apply** (R2 recommendation; Supabase-shipped extension). Full function-body lint catches type mismatches, ambiguous references, missing tables that cheap grep can't see.

Fits at existing block-tier (`worktree-preflight` precedent: "verify environment shape before dispatch"). Gate A is the disclosure floor; Gate B is the apply-time confirmation.

---

## §3 — Verify-before-claim at every altitude (HIGH)

**Pattern:** Claim outpaces verification at Builder, Architect, CTO, PM, Debugger altitudes. Single largest velocity-mode failure class across the archive (9+ instances in TaskIt; 5+ in Vendor Email Scraping).

**Instances by altitude:**

| Altitude | Failure | Evidence |
|---|---|---|
| Builder | Fabricated plan-exemption comment justifying not shipping 3 routes | prev F-31 (CRITICAL) |
| Builder | Copies surface pattern from prior version without verifying preconditions hold (e.g., disabled Publish "mirroring V2" — V2 had inner Save fallback, V4 didn't) | prev §16.N2 |
| Builder | Copies competitor brand strings verbatim ("Asana AI" as user-visible TaskIt label) | prev §16.N5 |
| Builder + QA | Mock unit tests green; live RPC invocation hit Postgres 42702 ambiguity / JWT propagation failure | prev F-46 + §15.C3 (2nd occurrence) |
| Builder | Cannot run verification in sandbox (`Bash`/`PowerShell` denied) → DONE_WITH_CONCERNS without verify; soft-DONE on hallucinated verification is the systemic risk | prev VE#14 (all 5 Builders, identical language) |
| Architect | Silently chose convention against cited research §1.1 | prev F-35 |
| Architect | Estimated reuse of `<TriggerConfigPaneV2/>` for all 3 pane modes without reading component body; modes were stubs | prev §16.N7 (2× estimate blow-out) |
| Architect | Spec'd 3 UI modes but `scope_read` only included 1 mode's capture; extrapolated UX from adjacent surface | prev §16.N6 (action + condition pane shipped broken) |
| CTO | Authored 3-layer RLS narrative from memory; live `pg_policies` refuted | prev F-37 |
| CTO | Asserted priority enum values from session memory; per-org FK rejected | prev F-42 |
| CTO | Numeric/structural meta-claims (file length, section purpose) from memory | prev F-51 |
| PM/Architect | Classified migrations "SHIPPED" based on git presence, not `schema_migrations` rows | prev F-20 + F-22 (cascaded through Architect+DBE+Security+Builder) |
| Debugger | Read-only code trace produced confident wrong root cause; live invocation refuted in 30s | prev F-3y |
| Researcher | BINDING N=5 consensus on standards-compliant pattern; live data does not set those headers (Salesforce + Power Automate) | prev VE#17 |
| QA | Stage-1 PASS with surface-behavior ACs ("page loads, no console errors"); end-to-end create-path was never functional | prev §16.N1 (V2 canvas shipped with V1 fallback mounted) |

**Fix shape — one primitive applied across altitudes:**

1. **Builder forbidden-scope-cut-comment lint** (post-Builder, pre-commit). Grep diff for `/\b(not in V[12] scope|out of scope|deferred to V[2-9]|skipped per (cto|plan))\b/i`. Match blocks commit unless scope-cut is present in plan/cycle-state with CTO ratification. Closes F-31.
2. **Builder reused-pattern precondition rule.** Add to `production-framework:builder` system prompt: *"When reusing a pattern from a prior version (V_(N-1) → V_N), explicitly verify the prior version's preconditions hold in the new context. Document the verification in your handover."* Closes §16.N2.
3. **Builder competitor-brand re-author rule.** When dispatching with anchor-on-competitor cycles, system prompt: *"All user-visible strings must be re-authored in the host product's brand voice. Competitor brand names (e.g., 'Asana AI') must NEVER appear as user-visible text. If unsure of host product's preferred AI naming, return `NEEDS_CONTEXT`."* Closes §16.N5.
4. **Architect cited-convention adoption-or-rejection lint** (post-Architect-doc). Each cited convention in research docs must appear in either "Adopted" or "Rejected" lists in the arch doc. Silent non-adoption blocks downstream Builder dispatch. Closes F-35.
5. **Architect `architect-evidence-coverage` HARD-GATE.** Dispatch prompt must enumerate each UI surface the design specifies. `scope_read` must include ≥1 visual evidence file per surface OR Architect returns `NEEDS_CONTEXT` naming the uncovered surface. Extrapolation from adjacent surfaces is forbidden. Closes §16.N6.
6. **Architect reused-component body-read rule.** When proposing reuse of an existing component or extending its modes/branches, READ the component's full body, not filename + props. Verify each depended-on mode/branch has implementation (not stub/TODO). If stubbed, treat as NEW WORK in cycle estimate. Closes §16.N7.
7. **CTO evidence-grounding rule** (cto-mode skill convention). When responding to "how is X enforced / scoped / secured," do ONE evidence-fetch (execute_sql against `pg_policies` / `information_schema`, OR file:line read) BEFORE narrating. Memory-based correctness assertions block. Closes F-37 + F-42 + F-51.
8. **PM + Architect SHIPPED-vs-APPLIED grammar.** Pre-spec audit + SHIPPED matrix MUST classify three states: `IN-REPO-NOT-APPLIED` (flag as NOT-SHIPPED), `APPLIED-LIVE` (cite `schema_migrations` row + `information_schema` evidence), `PARTIALLY-APPLIED` (mid-cutover, name which migs). Closes F-20 + F-22.
9. **Debugger live-invocation discipline.** For bugs involving RPC / DB-write / external-service calls with "operation rejected with code X" symptom, REPRODUCE via the actual invocation tool BEFORE asserting root cause. Findings doc requires "Live invocation evidence" section quoting actual error. Contradiction-check: contradicting data points must be addressed before settling on hypothesis. Closes F-3y.
10. **Researcher live-data verification step** (extend `enterprise-research-first` skill with Step 7). For patterns that can be live-tested (header detection, regex matching, API-shape assumptions), run a probe against the project's actual data before locking the pattern. Failed probe downgrades BINDING/STRONG → "research-only." Closes VE#17.
11. **QA end-to-end-artifact AC mandate.** For any feature creating user-visible artifacts, dispatch prompt MUST include: *"Create the simplest valid artifact via the new UI; verify persistence; verify it surfaces in parent list/view."* Empirical not visual — fails if create-path is non-functional regardless of surface. Closes §16.N1.
12. **`DONE_PENDING_VERIFICATION` status token** (R6 — verifier-claimer separation is universal in 5/5 surveyed frameworks: CrewAI guardrail / LangGraph interrupt-resume / AutoGen TerminationCondition / Reflexion Evaluator / Anthropic CitationAgent). Builder returns `(token, verification_commands[], output_landing_check[])`. SubagentStop hook blocks downstream dispatches until CTO/Deputy executes commands and posts results to `.framework-state/verification-results-<cycle-id>.json`. The next dispatch attempting to consume Builder's output reads the results file; absent → BLOCKED. Same primitive composes for §3.9 Debugger live-invocation evidence — unify under "in-sandbox-impossible-operation surfacing" pattern. NAME `DONE_PENDING_VERIFICATION` is PF coinage; architectural pattern is BINDING (R6). Closes VE#14.
13. **F-46 live-test mandate expansion.** From "SQL-touching code" → "any server action invoking a SECURITY DEFINER RPC, OR any RPC body referencing `auth.uid()`." JWT-propagation root cause requires the broader scope. Closes §15.C3 + §15.C5.
14. **useEffect-once Builder primitive** (stack-conditional: React 19 + dev strict mode). Add reference pattern to Builder system prompt: when "fire exactly once per mount" matters and the body dispatches state-changing actions, use `useRef` flip-flag, NOT state-derived guards. State-derived guards (`state.x === 0`) race when effects double-invoke in dev strict mode → duplicate dispatch → 2 rows persisted. Reference: `const fired = useRef(false); useEffect(() => { if (fired.current) return; fired.current = true; if (state.actions.length === 0) dispatch(...) }, [])`. Closes prev §18.N11.

---

## §4 — Review-pass coverage gaps (HIGH)

**Pattern:** Multiple review passes (DBE pass 1+2, Security pass 1+2, Code Review, QA, mocked unit tests) collectively cannot catch: SQL grammar errors that surface only at apply-time, Postgres antipatterns that look correct in code, capability-mismatch (pgvector dim limits), runtime semantics of mocked RPCs, wrong business logic when verify-blocks cover only schema state, branch-asymmetric state-management bugs, latent correctness bugs Gate 3 doesn't have a slot for.

**Evidence:**
- prev F-14 (PRIMARY KEY syntax surfaces at apply)
- prev F-24 (`has_function_privilege('PUBLIC', ...)` antipattern)
- prev F-25 (pgvector HNSW dim limit per element type)
- prev F-26 (wrong function-body logic with passing schema-state verify-block)
- prev F-46 (mocked Supabase client passes; live runtime fails)
- prev §18.N10 (branch-1 has nested-provider seed; branch-0 outer-provider missing seed → silent no-op on user input)
- prev §15.C7 (latent defects in never-FF-flipped substrate surface on first live exercise)
- **prev VE#11**: 3-agent parallel audit on Vendor Email Scraping → QA Gate 3 = `CONDITIONAL PASS, 0 CRITICAL`; same codebase: Code-reviewer = 2 CRITICAL + 5 HIGH (secret leak, fallthrough-to-None crash, SQLite thread-safety); Researcher = 2 CRITICAL + 5 HIGH (prompt duplication ×6, scale-math failure, silent `except: pass`). Gate 3 alone shipped 4 CRITICAL bugs as PASS.

**Fix shape:**

1. **Dry-apply HARD-GATE before DBE pass DONE.** Migration runs against scratch DB / branch DB; failure to apply OR failed in-mig verify-block → `BLOCKED` with actual Postgres error attached. Promote v2.5's STRENGTH-8 (DBE live-DB pre-flight discipline) from best-practice to HARD-GATE. Closes F-14 + F-24 + F-25.
2. **Substrate capability lookup in DBE pre-flight.** For any index type touched (pgvector HNSW/IVFFlat dim limits per element type; tsvector/GIN size budgets; RLS-Pattern-4 thresholds), auto-dispatch Researcher when pre-flight catalogs the substrate as "high-capability-mismatch-surface." Closes F-25-class gaps.
3. **Clone-detection field in DBE handover.** Handover declares "this mig is a near-clone of mig N; deltas at lines X, Y, Z" so CTO can confidently skim sibling-pattern migs while full-reading novel bodies. Honors `[[framework-bidirectional]]`. Closes F-26's read-scaling friction.
4. **At-least-one live integration test per RPC-touching tool.** For any AI-tool-wrapper / handler calling an RPC, Builder includes integration test that spawns a temp DB row, invokes against a REAL Supabase client (or local stack), asserts response shape AND persisted side effects. Mocked-client unit tests fine for argsSchema + error-mapping + audit_extra but INSUFFICIENT as sole shipping gate. Closes F-46. Same proposal as §3.13.
5. **Branch-asymmetry test plan mandate.** When architecture doc declares per-branch state-management asymmetry (e.g., outer vs nested provider), test plan MUST exercise both branches independently. Closes §18.N10.
6. **`gate-3-production-check` composability fix.** Skill body explicitly requires parallel-dispatch of `production-framework:code-reviewer` + `production-framework:researcher` agents BEFORE Gate 3 can PASS. Either (a) add Category 8 "Correctness" to gate-3.md (unreachable returns, silent exception swallow, shared-mutable state, fallthrough-to-None), OR (b) make parallel composition mandatory not optional. Recommend (b). Closes VE#11.
7. **Latent-defect-discovery stress test pre-FF-flip.** When adopting an INTEGRATED but never-FF-flipped substrate, first cycle to FF-flip must budget for surfacing latent defects via F-46-against-real-traffic stress test before flip. Closes §15.C7.
8. **Playwright spec + dep parity check** (stack-conditional: Next.js / any JS project). Pre-commit or skill-level detection: Playwright spec file (`tests/e2e/*.spec.ts`) authored but `@playwright/test` not in `package.json` → surface to user as one-time SRE task ("install dep + write config + remove `@ts-nocheck`"). Decorative specs that can't run in CI provide false confidence. Alternative: forbid authoring Playwright specs without the dep. Closes prev §16.N4.

---

## §5 — CLAUDE.md design discipline (HIGH)

**Pattern:** No framework primitive addresses CLAUDE.md *shape*, *length*, or *where rules vs facts vs narratives belong*. Every adopting project will accumulate bloat on the same trajectory (TaskIt: stock template → 355 lines → demonstrable model-attention degradation). The fix discovered through 3 parallel researchers on TaskIt is replicable only if the framework ships the playbook.

**Self-flag (do NOT skip):** prev §1.4 documented that v1's measurement protocol (`r43-r62-violations.jsonl`, `Rule born:` annotations, 14-day window) was **shipped but never executed**. The jsonl file was never built; annotations didn't propagate (verified by grep: 0 hits in incidents.md). CLAUDE.md regrew 280 → 347 lines (+24%) in 8 days post-trim. **Author-discipline-dependent measurement does not self-sustain.** v2.6 measurement must be mechanical (git-based, line-count drift), not annotation-based.

**Fix shape — `claude-md-design` skill (Priority A):**

```yaml
name: claude-md-design
description: Use when project CLAUDE.md exceeds 200 lines OR contains narrative-paragraph rules OR has not been audited in 90 days.
```

Skill body covers six axes:

1. **Length bounds.** 200 aspirational, 300 ceiling. Hard-fail above 400.
2. **Three-bucket placement.** Project facts → `docs/STACK-PATTERNS.md`; CTO operating discipline → skills (not CLAUDE.md); deterministic-mechanical → hooks (not CLAUDE.md). CLAUDE.md keeps: directive + 1-sentence why + (optional) incident-id link.
3. **Section J table format** — directive + why + incident-link. Companion `docs/incidents.md` carries narratives.
4. **Quick Links header pattern** — top-of-file delegation index (Vercel `open-agents` precedent).
5. **Section position guide** — load-bearing rules at the bottom (MMMT-IF benchmark; arXiv:2409.18216 +22.3 PIF retention at end-of-context).
6. **Trim-and-measure rollback protocol** — git-based, not annotation-based (see fix 3).

**Skill bundles three research docs** (already on TaskIt disk; move into plugin `references/`):
- `claude-md-design-anthropic-2026-05-19.md` — Anthropic Claude Code best practices
- `claude-md-exemplars-oss-2026-05-19.md` — 6 OSS exemplars; median 110 lines; 0/6 narrative
- `claude-md-prompt-compression-empirical-2026-05-19.md` — MMMT-IF + HumanLayer ≤300 ceiling + Chroma Context Rot 2025

**Other fixes:**

2. **`configure-project-gates` emits contract banner inline.** Active Gates section emitted with: `<!-- CONTRACT: Per-gate descriptions are READ by CTO sub-agent dispatches at prepend time. Do NOT compress to bare names. -->`. Optionally extend `active-gates-fresh` HARD-GATE to validate STRUCTURE (each gate has `— description` line), not just freshness. Closes prev §1.2.

3. **Mechanical measurement primitive — Vercel BEGIN/END marker pattern as primary** (R5 — `open-agents` OSS precedent). Drop the `Rule born:` annotation requirement entirely (proven non-propagating). Replace with:
   - **PRIMARY — Per-section marker drift** (Vercel BEGIN/END pattern). Wrap each CLAUDE.md section in `<!-- BEGIN: <section-id> -->` ... `<!-- END: <section-id> -->`. Session-end hook computes per-section content drift vs trim-commit baseline. More precise than gross line-count — flags WHICH section regrew, not just total bloat.
   - **SECONDARY — Line-count drift.** `wc -l CLAUDE.md` vs trim-commit baseline stored in `.framework-state/claude-md-trim-commit.txt`. ≥20% regrowth triggers `claude-md-design` skill invocation recommendation. Cheap fallback when marker discipline isn't adopted.
   - **TERTIARY — Violation surface count.** `git log <trim-sha>..HEAD -- docs/incidents.md` — any new F-entry whose body cites a rule-id pattern (`R\d+`) in the compressed range. ≥2 violations of single rule triggers per-rule rollback recommendation.
   - All three signals contribute to "should the trim be rolled back" decision.

---

## §6 — Tier-selection predicate redesign (MEDIUM)

**Pattern:** `tier-selection-on-task-shape` BLOCK gate fires too broadly (system task-notifications, closure commits, continuation prompts, in-cycle agent returns) AND its continuation-directive filter has too narrow a keyword set. Compounding consequence: bypass-fatigue accelerates → operator routinely uses `PF_BYPASS=tier-selection` → gate's value when it ACTUALLY catches a wrong tier is undermined.

**Evidence:** prev F-2, F-8, F-15, F-28 + prev §14.3 (3 invocations in single Asana session; Bash blocked, PowerShell exempt — tool-substitution workaround was the rational response) + prev §15.C4 (`max_per_session` semantics: counter resets per-prompt, not per-session) + prev VE#16 (re-fires per agent return-notification inside established Tier 3 cycle).

**Fix shape — three composable predicate refinements:**

1. **Source filter.** EXCLUDE inputs whose origin is `system_notification` / `task_notification` / `system_reminder` / `hook-injected`. Hook needs visibility into input-source-discriminator.
2. **Continuation filter.** Broaden keyword set to semantic continuations ("try", "do it", "go", "keep going", "don't stop", "carry on", "next", "now") + soft-classify any prompt <8 words as continuation-candidate.
3. **Cycle-cache.** Once tier is set in `docs/cycle-state.md`, gate auto-passes for the cycle's duration unless user explicitly invokes a NEW task-shape verb on a new subject. Read cycle state from `.framework-state/current-cycle.json`.
4. **Closure-commit sub-case.** If commit-staged files are exclusively closure artifacts of an active dispatched agent's output (paths match cycle-state expectations), skip gate. Closes F-28.
5. **Tool-channel consistency.** Include PowerShell + Edit + Write in gate scope alongside Bash — inconsistency rewards tool-substitution workarounds.
6. **Counter rename: `max_per_session` → `max_per_user_prompt`** (R4 — ESLint `--max-warnings` precedent). The counter resets per-user-prompt in practice; the misnaming was the root cause of bypass-fatigue. Rename in catalog + hook predicates + Active Gates emission.

---

## §7 — Worktree + Builder isolation (MEDIUM)

**Pattern:** `production-framework:builder` has `isolation: worktree` HARDCODED. Auto-spawned worktree inherits SESSION-START parent-branch state, not current HEAD. `worktree-preflight` catches uncommitted files + missing BASE_SHA but NOT stale-base nor user-controlled untracked artifacts (project-CLAUDE.md-forbidden). HEAD-parity gate (v2.5) catches stale-base correctly but workaround (general-purpose as Builder) was the **default for 14+ dispatches** in the Asana cycle.

**Evidence:** prev F-6 + F-40 + F-3z + F-43 + §15.C2 (HEAD-parity fallback to general-purpose burns Builder mechanical-bug-catch discipline at-scale).

**Fix shape:**

1. **WORKTREE catalog 4th sub-pattern.** Document the HEAD-parity case explicitly: "Builder worktree spawn SHA matches dispatch-time `git rev-parse HEAD` of named branch, not session-start parent-branch tip."
2. **User-controlled-artifact allowlist.** `worktree-preflight` categorizes untracked files: if dirty state is exclusively patterns in `.gitignore` / `.git/info/exclude` / `CONFIG.yaml > worktree.user_controlled_patterns`, gate passes. Currently treats every `??` entry as Builder-impacting. Closes F-40.
3. **Fail-closed isolation + explicit fallback doc.** If Builder cannot spawn worktree, fail-closed with: *"Isolation could not be established; dispatch BLOCKED. Workaround: switch to `subagent_type: general-purpose` (no built-in isolation; same dispatch-prompt discipline carries through per F-43)."* Document `general-purpose`-as-Builder fallback verbatim in `using-production-framework` with exact swap command.
4. **Investigate Builder-without-worktree mode** for long-cycle scenarios where session-start divergence is expected. Either relax HARDCODE or ship a parallel agent type that preserves Builder's `EMPTY_DIFF_FLAG` + `scope_write` + post-Bash mechanical-bug heuristics minus the worktree requirement. F-46 mandate is what kept the Asana cycle safe; equivalence is not guaranteed for shorter cycles.

---

## §8 — Parallel dispatch coordination (MEDIUM)

**Pattern:** No framework primitive coordinates parallel sub-agent dispatches beyond v2.5's auto-load of `parallel-reconciliation`. Three concrete failure modes remain.

**Evidence:**
- prev F-4: parallel producer-edit (Researcher) + consumer-read (Security) on same upstream doc → Security pass 1 builds findings on evidence Researcher subsequently invalidates
- prev F-9: `parallel-reconciliation` skill in catalog but partial auto-load (v2.5 escalated `warn` → `block` per PR-11; verify still firing)
- prev F-21: 3 parallel DBE dispatches all called `list_migrations` → returned DB-applied state only → silent slot collision on filesystem (last-writer-wins); avoided only by CTO manual coordination

**Fix shape:**

1. **File-scope-overlap pre-dispatch check** (partly shipped v2.5 PR-9; verify completeness). When new dispatch's required-read intersects running agent's write list → BLOCKED with: *"wait for upstream {agent-id}; reading {file} that is being modified."*
2. **Auto-trigger `parallel-reconciliation` post-hook** (shipped v2.5 PR-10; verify firing). Convergent-returns exemption: when all parallel returns converge on same recommendation, reconciliation can be a one-line note in cycle-state instead of separate doc.
3. **Filesystem-aware `list_migration_slots` analog.** New MCP wrapper returns `max(applied_slot, max_filesystem_slot)` — single source of truth for slot allocation. Closes F-21 structurally without CTO manual reservation. Alternative: lighter `cycle-state.md` reservation section ("reserves slots X..Y for Phase N") read by DBE dispatches at start.
4. **CTO dispatch boundary-coverage check** (prev §17 N6+N7). Before any wave dispatch, CTO writes one-line "critical path crossings" list (e.g., `canvas → store → server-action → DB → executor`) and confirms the union of Builder `scope_write` paths covers every crossing. Missing crossing → add a wave or extend an existing Builder's scope. Closes V4-style "wiring was two halves; dispatch named only one" failure.
5. **Browser-walk discipline** (prev §17 N8 + §18 closing). For canvas/UI features, cycle-final browser walk is non-optional even on Builder `DONE_WITH_CONCERNS`. Pre-customer mode: CTO walks inline (no QA agent dispatch), validated as ~2-5min per walk vs 30-45min QA dispatch.
6. **Commit-batch-shape mandate as Tier-3 cycle template deliverable** (prev §15.C6). End-of-cycle 41-file uncommitted endgame is a review-burden risk. Tier-3 cycle template requires Phase-B Wave-N deliverable: 3-6 logical commit batches (e.g., substrate-migs / server-actions / UI / integration-fixes / SRE-docs) with file lists, surfaced for user review BEFORE single-tree dump.
7. **Per-cycle token economics measurement** (prev §15.C8 / §15.B6). Instrument cycle retrospectives with per-dispatch model + input-token + output-token + clean-diff-yes/no. If a Builder-style dispatch averages <50k input tokens + clean diff, sonnet is a viable cost-reduction path. Output: `.framework-state/dispatch-economics.jsonl`. Aggregate per cycle in handover doc.

---

## §9 — Researcher tool-channel routing (MEDIUM)

**Pattern:** Researcher over-generalizes tool selection. When `researcher-anchor-visual-verification` gate fires (binding research to UX anchor like Asana), Researcher reads "browser_navigate is the right tool for the bound anchor" as "browser_navigate is the right tool for ALL web research in this dispatch" — uses browser for arxiv papers, GitHub READMEs, vendor docs where WebFetch would be 1/20th the token cost. Separately, the deferred-tools registry exposes vendor MCP catalogs that Researcher routinely misses, falling back to WebFetch / WebSearch on questions the registry answers in-session. Separately again, WebFetch permission-denial → researchers invent ad-hoc WebSearch-synthesis fallback that the skill never codified.

**Evidence:** prev F-3 (resolved v2.5 scope retune), F-11, F-36 + prev VE#15 (3 of 3 researchers on same run will hit WebFetch wall).

**Fix shape:**

1. **Browser-channel discipline section in `agents/researcher.md`.** (Shipped v2.5 PR-7; verify includes:)
   > `browser_navigate` is reserved for AUTHENTICATED PRODUCT EXPLORATION of the bound anchor domain only. All citation gathering (docs, blog posts, GitHub READMEs, papers, RFCs, vendor pages) uses `WebFetch` or `WebSearch`.
   >
   > **Anti-pattern:** "I'll use browser for everything because the gate said browser is required."

   3-row decision table: bound anchor authenticated UI → browser; public product docs of anchor → WebFetch; non-anchor research → WebFetch/WebSearch.
2. **Deferred-tools registry pre-flight for MCP catalogs.** Before WebFetch / WebSearch for ANY MCP catalog enumeration question, FIRST grep CTO session prompt for `mcp__claude_ai_<vendor>__*` deferred-tool definitions. If present, `ToolSearch select:<name>` extracts full parameter schemas. Primary-source; no WebFetch failures.
3. **`bound_target` sub-field in C-15 gate.** Names WHAT browser_navigate is for: `domain: <anchor URL>`, `scope: authenticated_ui_exploration`.
4. **WebFetch degradation protocol — codify the ad-hoc fallback** (prev VE#15). Add to `enterprise-research-first` skill:
   - Degradation order: `WebFetch → WebSearch synthesis → mark [CITATION-DEGRADED] → escalate NEEDS_CONTEXT if effective N drops below 3`
   - Per-row degradation flag in comparison table
   - BINDING (N≥5 unanimous) cannot be claimed if more than X% of cells are degraded
5. **WebFetch denial is sub-agent-context-specific, NOT domain-specific — refined 2026-05-27.** Initial finding: all 6 v2.6 researchers hit denials on `anthropic.com` / `docs.claude.com` / `arxiv.org` / JS-SPA doc sites. **Refined finding from CTO direct-WebFetch re-verification:** the same domains SUCCEEDED for the main session (6/10 URLs verified verbatim including anthropic.com, arxiv.org, code.claude.com after redirect, sqitch.org, supabase.com, developer.hashicorp.com). Only JS-SPA sites (LangGraph docs) and 2 paraphrase-not-verbatim cases failed. **Hypothesis for v2.7 investigation:** sub-agent contexts inherit a tighter permission envelope than the main session — the same WebFetch tool behaves differently based on dispatch context. Fix shape candidates:
   - (a) **Make sub-agent WebFetch envelope match main-session envelope.** Investigate Claude Code subagent tool permission inheritance (the v2.6.0 plan R1 sub-citation references `code.claude.com/docs/en/sub-agents` which has 62KB of docs — likely answers this).
   - (b) **Codify direct-CTO-WebFetch as a Researcher route-around.** When sub-agent WebFetch denies, the Researcher's NEEDS_CONTEXT return surfaces the failure; CTO re-fetches directly + injects into next dispatch via `scope_read` of the saved evidence file.
   - (c) **Document WebSearch-synthesis-with-preserved-canonical-URL as the canonical channel for sub-agents** (current empirical workaround — adequate but degraded).
   Recommend (a) as the v2.7 investigation; (b) and (c) ship as documented fallbacks in v2.6.x.

---

## §10 — Per-ADR citation + amendments (MEDIUM)

**Pattern:** `enterprise-research-first` N≥3 binding rule fires at PLAN level, not per-ADR level. Architects can author ADRs with THIN citation strength ("X is the only sensible choice") and ship to Builder. Adjacent: mid-cycle user-decision overrides require ~80 lines of amendment prose + manual pointer injection into every downstream dispatch (override-amnesia risk by 5th+ dispatch).

**Evidence:** prev F-27 + F-30.

**Fix shape:**

1. **Per-ADR citation strength gate.** When Architect emits new ADR (file under `docs/adr/**`), Researcher dispatch MUST audit each ADR's "Enterprise validation" section and tag THIN / WEAK / STRONG with N anchors. THIN/WEAK blocks cycle until ad-hoc research closes.
2. **Amendment-writer sub-agent.** Triggered by CTO directive "Decision X overrides decision Y from doc Z." Sub-agent writes the amendment doc + scans downstream pending dispatch slots to inject override pointer into each. Reduces CTO prose work + amnesia risk.

---

## §11 — Pre-2026-05-20 carryovers (open, no §match)

Vendor Email Scraping items still open in v2.5 and not covered by §1-§10. Each is a candidate for a future § promotion.

| ID | Surface | Gap (one line) | Suggested fix shape |
|---|---|---|---|
| VE#1 | `using-this-framework` First-Session Check | 3 round-trips before any real work on existing projects | Scaffolding skill that fills everything inferable from codebase in one pass; flags only irreducibly subjective slots |
| VE#2 | `templates/CONFIG.yaml` `scale_targets` | Fields (`tenants`, `users_per_tenant`, `records_per_tenant_month`) assume multi-tenant web app; don't map to batch/CLI/library/desktop | "project shape" selector (`saas` / `batch-pipeline` / `cli-tool` / `library` / `desktop`) swaps the target schema |
| VE#3 | `templates/CONFIG.yaml` `filtered_wrappers` | Defaults (`npm run build`, `npx tsc`, `npm test`) useless for Python/Go/Rust/Ruby | Auto-detect language from project files OR leave blank with per-language examples |
| VE#4 | `templates/CONFIG.yaml` `tenant_isolation_method` | Enum lacks `n/a` for single-user CLI tools (which aren't "single-tenant" — no tenant concept) | Add `n/a` / `not-applicable`; document Rule 6 audits skip when set |
| VE#5 | Template placeholder syntax | CONFIG.yaml uses `{project-name}`, STACK-PATTERNS uses `{stack:*}` — mixed conventions | Pick one convention; structural-check script fails loudly on unfilled placeholders |
| VE#6 | `using-this-framework` First-Session Check | Doesn't read `~/.claude/projects/<slug>/memory/MEMORY.md` — re-asks questions memory already answered | Add "Read project memory" step OR standalone `memory-orient` skill |
| VE#7 | `templates/STACK-PATTERNS.template.md` Gate 3 slots | ≥6 of 13 slots N/A for batch pipeline / CLI / data job | "project shape" selector (per VE#2) swaps Gate 3 slot list |
| VE#8 | `templates/CONFIG.yaml` `tsc_cmd` | No natural equivalent for Python / Ruby / dynamic Lua / untyped JS | Rename `typecheck_cmd`; allow empty (explicit opt-out); warn-not-fail when empty |
| VE#9 | `skills/` inventory | No entry-point skill for "audit an existing brownfield project" | New `project-health-check` skill: Tier 3 → parallel-dispatch 3 audit agents → consolidated findings → severity-sorted triage |
| VE#10 | `core/gate-3.md` 7 categories | ~15 of ~38 items N/A for batch pipeline; reviewer loses discipline walking mostly-N/As | "project shape" selector (per VE#2) selects tailored Gate 3 checklist with categories that apply |
| VE#12 | Audit composition (Researcher + Code-reviewer + QA parallel) | Three-agent consensus on same file:line is strong signal but no mechanism captures it | New `consolidate-audit-findings` skill: key by `(file, line_range, rule)`; severity-boost rule (`≥2 agents → promote one level`); output to PROJECT-PLAN.md with `Consensus: N/M` column |
| VE#13 | `templates/` directory | No template for Researcher / Code-reviewer findings files (only `qa-findings.template.md` exists); cross-agent consolidation harder when shapes differ | Add `researcher-audit.template.md` + `code-review.template.md` with shared minimal column contract |

---

## §12 — CTO-to-user reporting discipline (DEFERRED v2.7+)

**Pattern:** CTO defaults to comprehensive paragraph-form reports (opinions, status updates, decision-requests, retrospectives) when the user wants terse. No skill scopes response length to question type. User-correction is the only signal; correction has to be repeated across sessions because the discipline isn't codified.

**Evidence:** 2026-05-27 session (this doc's authoring) — user prompted *"less words opus, less crisp highest impact words"* after an 18-sentence opinion response. Same pattern observed across prior sessions per user-feedback memory entries.

**Fix shape — new skill `cto-reporting` (or fold into `cto-mode`):**

1. **Response-budget table by question type.** Defaults:
   - Opinion / "what do you think?" — ≤8 bullets, no paragraphs
   - Status update — ≤5 lines, bulleted
   - Decision-request — 2-3 options + one-line tradeoff each
   - Retrospective / debrief — sectioned, but each bullet ≤2 lines
   - Plan synthesis — table form preferred over prose
2. **Expansion is opt-in.** User must explicitly request long-form ("walk me through it", "explain in depth"). Default is terse.
3. **Highest-impact-word rule.** Prefer the word that carries the most decision weight per syllable. Cut hedges ("might consider", "could potentially", "in some sense"). Cut throat-clearing ("a few honest reactions:", "let me explain").
4. **No mid-response summary.** Don't restate what was just said. Don't end with "Net:" or "In summary:" — the reader has the text.

**Priority:** DEFERRED. Add to v2.7+ once §1 + §2 (mechanical-floor) ship. Not blocking.

---

## Appendix A — Preserve in v2.6 (STRENGTHs)

v2.6 design MUST NOT regress these. Each cites archive evidence.

1. **Builder Iron Law** (prev STRENGTH-2/3/4/5/9). Builders under `model: opus` consistently identify mechanical plan-bugs, preserve plan design intent, correct ONLY mechanical defects, document deviations in commit body, escalate `NEEDS_CONTEXT` rather than guess. 5+ dispatches across late-session Asana cycle: ZERO false-positive NEEDS_CONTEXT. **Preserve verbatim in `agents/builder.md`; `model: opus` default; on-disk audit authoritative over dispatch text.**

2. **Pattern A three-pass producer-consumer** (prev STRENGTH-1/7). Architect → Security → Architect-Pass-2 produced 77KB arch doc that all downstream lanes read without further Architect intervention. DBE Pass 2 single-shot resolved 23 distinct items vs v2.3's 3-5 remediation waves. Security Pass 1 caught 2 design-time defects pre-Builder. **Preserve for Tier 3 Build cycles; resist "skip pass 3 because consensus already" pressure when Security findings would meaningfully alter Architect ratification.**

3. **Plan author as gap-finder + dependency-graph surfacing** (prev STRENGTH-6/10). Plan author identified 4 migs not in Architect's §6; surfaced inter-Builder type-export contracts for parallelization. **Preserve `writing-plans` discipline of cross-referencing Architect + Security outputs for gap-detection.**

4. **Browser-driven verification as last-defense** (prev STRENGTH-11). `early-playwright-smoke` caught F-31 contract bug (4 endpoints 404'ing) in 37 seconds after 17hr of compounding work. **Promote `early-playwright-smoke` from WARN → BLOCK for all UI-touching Builder dispatches.**

5. **Parallel researcher dispatch + researcher honesty** (prev STRENGTH-12/13). 3 parallel researchers (disjoint scopes, ~20min wall-clock, complementary findings, zero overlap). R3's "Honest gap" section forced operational measurement instead of asserted confidence. **Preserve Researcher prompt's emphasis on honest-gap-flagging over confidence-synthesis.**

6. **User open-meta-question as R43-trigger** (prev STRENGTH-14). User asks "what do you think?" / "are you sure?" / "is this solid?" → forces verification CTO would otherwise skip. **Not actionable framework-side beyond §3.7 (CTO evidence-grounding); preserve as observed pattern.**

7. **`framework-bidirectional` principle** (prev archive L494). User-stated: "framework supports CTO and vice versa — CTO steps in anywhere needed regardless of altitude." **v2.6 MUST preserve CTO-as-failsafe in every gate. Do NOT auto-apply migrations. Do NOT remove CTO from any decision boundary.**

8. **Asana cycle additions (prev §15.P1-P6, §16.S1-S3):**
   - **F-46 live test binding** is last-line discipline (caught 8/8 R57/F-22 recurrences before prod) — expand mandate per §3.13
   - **Mid-cycle scope check-ins** save more than rework discovery cost (Forms scope cut: ~2-3 builder days saved by 15-min admin interview) — codify "scope check-in points" in Tier-3 cycle template
   - **Parallel dispatch under autonomy directive** compresses ~14 calendar days into ~50hr wall-clock when scope is disjoint
   - **Cycle-state.md + resume-state section survives `/compact`** at ~76 lines/section overhead, zero re-work on resume — make resume-state section mandatory Phase-A deliverable
   - **Architect file:line evidence** enables fast CTO verification of Builder defers (2 Read calls vs broader grep)
   - **Open-ended Researcher dispatch beats target floor by 3.5×** when given latitude ("every doc Asana has" → 53 distinct URLs vs ≥15 target)
   - **CTO BS self-check via TodoWrite trim** ("how much of the todo is BS?") surfaced 5/9 todos as ceremony — TodoWrite items must pass "is this my next physical action" filter

---

## Appendix B — How to extend this file

**When a new pattern surfaces:**

1. Append to chronological archive ([`framework-plugin-feedback-archive-2026-05-20.md`](framework-plugin-feedback-archive-2026-05-20.md)) per `[[maintain-framework-log]]` — incident citation + commit SHA + agent ID. Archive is append-only.
2. Check whether it's a new instance of an existing §1-§10. If yes, add a row to that section's table + cite archive line range.
3. If it's a genuinely new pattern, add new § with the shape: pattern → evidence → fix → priority.

**When a pattern closes (plugin ships the fix):**

1. Mark § as CLOSED with plugin version + release notes URL.
2. Move § to `## Appendix C — Closed in v2.X` at file bottom.
3. Do NOT delete — closed patterns are evidence that the framework learns.

**When this file exceeds ~300 lines:**

1. Apply §5's `claude-md-design` skill to this file. Bloat in design docs has same model-attention cost as bloat in CLAUDE.md.
2. This file eats §5's dogfood once §5 ships.

**Next reshape trigger:** ≥3 new patterns added OR any §1-§10 section closes. Until then, append to archive + add table rows here.

---

## Appendix C — v2.6 mechanical-floor filter pass (2026-05-27)

**Rule:** v2.6 scope = HOOK + HYBRID. PROMPT-only → v2.7+.

**Definitions:**
- **HOOK** — mechanical check catches the violation by itself; no prompt change required
- **HYBRID** — hook floor catches violation + prompt teaches actor how to comply (closes §5 self-flag)
- **PROMPT** — only an agent/skill/CLAUDE.md text edit; no mechanical backstop feasible

**v2.6 scope (HOOK + HYBRID) — 32 fixes:**

| Fix | Class | Notes |
|---|---|---|
| §1.1 agent-output-file-landed at SubagentStop | HOOK | file existence check post-DONE |
| §1.2 write-side scope_write intersection | HOOK | mirror of read-side |
| §1.3 SubagentStop event correlation + GC | HOOK | fixes §14.1 orphan starts |
| §1.5 Builder scope-cut (a)/(b) grammar | HYBRID | hook requires cited arch line on (b) |
| §1.6 fork-architecture parallel-fix check | HYBRID | scan ADRs for fork decl + flag sister-file omissions |
| §2 mig-precondition-disclosure (full gate) | HYBRID | parser + DBE prompt teaches format |
| §3.1 Builder forbidden-scope-cut-comment lint | HOOK | grep diff at pre-commit |
| §3.3 Builder competitor-brand re-author | HYBRID | hook greps known brand strings in user-visible labels |
| §3.4 Architect cited-convention adoption lint | HOOK | scan arch doc vs research-doc references |
| §3.5 architect-evidence-coverage gate | HYBRID | hook enforces scope_read per surface |
| §3.8 PM/Architect SHIPPED-vs-APPLIED grammar | HYBRID | hook requires evidence tag adjacent to SHIPPED |
| §3.9 Debugger live-invocation evidence section | HYBRID | hook requires section in handover |
| §3.10 Researcher live-data verification step | HYBRID | hook requires `verify_against_live_data` column |
| §3.11 QA end-to-end-artifact AC mandate | HYBRID | hook checks AC pattern in QA dispatch prompt |
| §3.12 DONE_PENDING_VERIFICATION status token | HYBRID | new token + hook enforces verify before accept |
| §3.13 F-46 mandate expansion | HYBRID | hook checks RPC server-actions have matching .test.ts |
| §3.14 useEffect-once primitive (stack-conditional) | HYBRID | linter rule, React/Next.js |
| §4.1 Dry-apply HARD-GATE for DBE | HOOK | run mig against scratch/branch DB |
| §4.2 Substrate capability lookup in DBE pre-flight | HYBRID | hook lookup table + prompt teaches scope |
| §4.4 Live integration test per RPC-touching tool | HYBRID | hook checks file existence per RPC |
| §4.6 gate-3-production-check parallel composability | HYBRID | hook enforces parallel dispatch before Gate 3 PASS |
| §4.8 Playwright spec + dep parity check | HOOK | file-scan, pre-commit |
| §5.1 claude-md-design skill | HYBRID | skill teaches + §5.3 hook enforces |
| §5.2 configure-project-gates contract banner | HYBRID | banner is prompt; structure-validate is hook |
| §5.3 line-count drift + git-log violation scan | HOOK | mechanical, no annotation discipline needed |
| §6.1 tier-selection source filter (exclude notifications) | HOOK | predicate refinement |
| §6.2 tier-selection continuation filter broadening | HOOK | predicate refinement |
| §6.3 tier-selection cycle-cache via .framework-state | HOOK | predicate refinement |
| §6.4 tier-selection closure-commit sub-case | HOOK | predicate refinement |
| §6.5 tier-selection tool-channel consistency | HOOK | scope expansion |
| §6.6 tier-selection counter semantics fix | HOOK | rename or fix |
| §7.2 worktree user-controlled-artifact allowlist | HOOK | predicate refinement |
| §8.1 file-scope-overlap pre-dispatch (verify v2.5) | HOOK | already shipped v2.5 PR-9; verify firing |
| §8.2 auto-trigger parallel-reconciliation (verify v2.5) | HOOK | already shipped v2.5 PR-10; verify firing |
| §8.3 filesystem-aware list_migration_slots | HOOK | new MCP wrapper |
| §8.7 per-cycle token economics instrumentation | HOOK | `.framework-state/dispatch-economics.jsonl` |
| §9.3 bound_target sub-field in C-15 gate | HYBRID | gate field + hook reads |
| §10.1 per-ADR citation strength gate | HYBRID | hook scans ADR for citation tags |

**Deferred to v2.7+ (PROMPT-only, 21 fixes):**

§1.4 anti-fabrication clause · §1.7 writing-plans dispatch-type · §3.2 Builder reused-pattern precondition · §3.6 Architect reused-component body-read · §3.7 CTO evidence-grounding · §4.3 DBE clone-detection field · §4.5 branch-asymmetry test plan · §4.7 latent-defect stress test pre-FF-flip · §7.1 WORKTREE catalog 4th sub-pattern · §7.3 fail-closed isolation skill text · §7.4 Builder-without-worktree investigation · §8.4 CTO dispatch boundary-coverage check · §8.5 browser-walk discipline · §8.6 commit-batch-shape mandate · §9.1 browser-channel discipline (researcher.md) · §9.2 deferred-tools registry pre-flight · §9.4 WebFetch degradation protocol · §10.2 amendment-writer sub-agent · §12 cto-reporting skill

**v2.6 release shape (by surface):**

| Surface | Touched | Sections |
|---|---|---|
| `hooks/pre-tool-use` | 11 new checks | §1.2, §2, §3.1, §3.3, §3.4, §3.8, §3.13, §4.4, §6.1-6.6 partial, §10.1 |
| `hooks/subagent-stop` | 2 new checks | §1.1, §1.3 |
| `hooks/session-start` | 1 new check | §5.3 |
| `hooks/post-tool-use` (or pre-commit) | 3 new checks | §3.1 lint, §4.1 dry-apply, §4.8 Playwright parity |
| New skill | 1 | §5.1 claude-md-design |
| Skill body edit | 2 | §3.5 architect-evidence-coverage, §4.6 gate-3 composability |
| Agent system prompt edit (HYBRID side) | ~8 | §1.5, §1.6, §2, §3.3, §3.5, §3.8-3.14 |
| New MCP wrapper | 1 | §8.3 list_migration_slots |
| New status token | 1 | §3.12 DONE_PENDING_VERIFICATION |
| Verify existing v2.5 hooks fire correctly | 2 | §8.1, §8.2 |

**Cut from v2.6 (HOOK count) — top single-concept candidates:**

- **Sub-agent reliability mechanical floor** = §1.1 + §1.2 + §1.3 (3 hooks at SubagentStop + pre-tool-use)
- **Mig-precondition gate** = §2 (1 gate, ~4 sub-checks)
- **Tier-selection retune** = §6.1-§6.6 (6 predicate changes in one hook)
- **CLAUDE.md measurement** = §5.3 (1 session-start check)

Any 1-2 of these as v2.6.0; rest as v2.6.x. Recommend **sub-agent floor (§1.1-1.3) + mig-precondition gate (§2)** as v2.6.0 single-concept: "framework can no longer trust sub-agent claims on output or baseline."

---

## Appendix D — Framework-novel items needing Path B promotion (2026-05-27 research findings)

Items where parallel-researcher dispatch found NO direct enterprise precedent but architectural pattern is sound. These should ship in v2.6 with explicit "framework-original" tagging per ADR-003 Path B (researcher-validated novelty). They do NOT need to wait for ≥5 enterprise precedents — they need to be flagged so future readers know they're untested-at-enterprise-scale.

| Item | FEEDBACK § | Researcher source | Disposition |
|---|---|---|---|
| ACTOR block (privilege-envelope-as-mig-metadata) | §2 Gate A | R2 (docs/research/v2-6-r2-migration-safety.md) | Ship with `version: v1` tag + "framework-original" comment in skill body |
| Section J table format (directive + why + incident-link) | §5 | R5 (docs/research/v2-6-r5-claude-md-design.md) | Ship in `claude-md-design` skill body; mark explicitly framework-original |
| Mechanical CLAUDE.md drift measurement (composite of A/B/C signals) | §5.3 | R5 | PARTIAL precedent (Vercel BEGIN/END markers); ship marker pattern as primary; composite is PF-original |
| `DONE_PENDING_VERIFICATION` status token NAME | §3.12 | R6 (docs/research/v2-6-r6-status-token-grammars.md) | Architectural pattern BINDING (5/5 frameworks); NAME is PF coinage — document transparently |
| Filesystem-aware `list_migration_slots` analog | §8.3 | R3 (docs/research/v2-6-r3-multi-agent-reconciliation.md) | No direct precedent; solves F-21 root cause. Ship as MCP wrapper; propose formal pattern post-ship |

**Path B trigger (per ADR-003):** parallel-researcher dispatch produced BINDING enterprise-research findings on the SURROUNDING pattern but flagged these specific items as novel. Honest disclosure now; formal pattern proposal at next pattern-ratification cycle when v2.6 has empirical evidence the items work.

**Citation backing:** [docs/research/v2-6-design-research-2026-05-27.md](research/v2-6-design-research-2026-05-27.md) §4.

---
