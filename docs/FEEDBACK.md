# Framework Feedback

Running log of friction, gaps, and improvement ideas surfaced while using the production-framework on real projects. Append new entries — don't edit old ones unless resolved.

Each entry:
- **Source:** which project / session surfaced it
- **Surface:** which file, skill, hook, or template
- **Issue:** what's wrong or awkward
- **Suggestion:** proposed fix (optional)
- **Status:** `open` | `in-progress` | `resolved` | `wont-fix`

---

## 2026-04-24 — Vendor Email Scraping (first-session setup)

### 1. First-session check is slow for existing projects
- **Surface:** `using-this-framework` → First-Session Check
- **Issue:** Flow is audit → draft CONFIG.yaml → ask user to confirm scale targets / triggers / wrappers. Three round-trips before any real work.
- **Suggestion:** A scaffolding skill that fills everything inferable from the codebase in one pass and only flags the irreducibly subjective slots (scale, Tier 3 triggers). Could even be non-interactive for greenfield where defaults are fine.
- **Status:** open

### 2. CONFIG.yaml `scale_targets` are SaaS-shaped
- **Surface:** `templates/CONFIG.yaml`
- **Issue:** Fields `tenants`, `users_per_tenant`, `records_per_tenant_month`, `concurrent_users` assume multi-tenant web app. They don't map to batch pipelines, CLI tools, data jobs, single-mailbox scrapers, libraries, or desktop apps.
- **Suggestion:** Either a "project shape" selector (`saas` / `batch-pipeline` / `cli-tool` / `library` / `desktop`) that swaps the target schema, or free-form `scale_targets: {key: value}` with per-shape examples in comments.
- **Status:** open

### 3. `filtered_wrappers` defaults are JS/TS-shaped
- **Surface:** `templates/CONFIG.yaml` → `filtered_wrappers`
- **Issue:** `npm run build` / `npx tsc --noEmit` / `npm test` are useless for Python, Go, Rust, Ruby projects.
- **Suggestion:** Either auto-detect language from project files (package.json / requirements.txt / go.mod / Gemfile / Cargo.toml) and swap defaults, or leave blank with commented per-language examples.
- **Status:** open

### 4. `tenant_isolation_method` enum missing a natural option
- **Surface:** `templates/CONFIG.yaml` → `tenant_isolation_method`
- **Issue:** Options are `RLS | middleware | column-scope | none-single-tenant`. Single-user CLI tools aren't "single-tenant" — they have no tenant concept at all.
- **Suggestion:** Add `n/a` or `not-applicable`. Document that projects with no multi-user surface should pick this — and that Rule 6 audits are skipped when set.
- **Status:** open

### 5. Template placeholder syntax is inconsistent
- **Surface:** `templates/CONFIG.yaml`, `templates/STACK-PATTERNS.template.md`
- **Issue:** CONFIG.yaml uses `{project-name}` (curly braces); STACK-PATTERNS uses `{stack:*}` placeholders. Mixed conventions are harder to lint.
- **Suggestion:** Pick one placeholder convention. Add a structural-check script that fails loudly if any `{...}` placeholder remains unfilled in a project's forked copy — catches half-initialized configs before they ship.
- **Status:** open

### 6. `using-this-framework` doesn't orient the session to project-local memory
- **Surface:** `skills/using-this-framework/SKILL.md` — First-Session Check
- **Issue:** The skill tells me to check `CONFIG.yaml` and `STACK-PATTERNS.md`, but not to read `~/.claude/projects/<slug>/memory/MEMORY.md`. In this session, memory already contained the user-role note ("framework author, surface friction as feedback") and the FEEDBACK.md pointer — but I didn't read it, so I produced the exact SaaS-shaped / JS-shaped questions the user had already flagged in entries 2–4. The framework's first-session check ran redundantly with memory that was already on disk.
- **Suggestion:** Add a "Read project memory" step to the First-Session Check (or a standalone `memory-orient` sub-skill). At minimum: "Before asking the user anything, read `~/.claude/projects/<slug>/memory/MEMORY.md` and any file it indexes — the answer may already be there."
- **Status:** open

### 7. Gate 3 slot values in `STACK-PATTERNS.template.md` are web-app-shaped
- **Surface:** `templates/STACK-PATTERNS.template.md` → Stack Config (Gate 3 slot values)
- **Issue:** Of the 13 slots (`bundle-budget`, `client-boundary-marker`, `lazy-loading-primitive`, `explain-tool`, `required-security-headers`, `perf-vitals`, `auth-migration-feature`, `data-access-primitive`, `anti-pattern-refresh`, etc.), ≥6 are N/A for a batch pipeline / CLI tool / data job. I filled `Vendor Email Scraping/docs/STACK-PATTERNS.md` with 6 × `n/a` entries plus two repurposed fields (`query-latency-budget` as LLM call budget, `concurrent_users` as max concurrent LLM calls). The slot names carry web-app semantics; projects without a client surface have to either fake values or write n/a.
- **Suggestion:** Same "project shape" selector from entry #2 could swap the Gate 3 slot list. E.g., `shape: batch-pipeline` exposes `{llm-call-budget, throughput-target, persistence-flush-budget, dedup-persistence-surface, retry-policy-surface}` instead of `{bundle-budget, client-boundary-marker, …}`. Gate 3 then reads the shape-appropriate slots.
- **Status:** open

### 8. No natural `tsc_cmd` equivalent for Python (or any non-typed language)
- **Surface:** `templates/CONFIG.yaml` → `filtered_wrappers.tsc_cmd`
- **Issue:** Adjacent to entry #3 but distinct. Even after fixing JS/TS-shaped *defaults*, the *slot itself* (`tsc_cmd`) doesn't map to languages without a type checker. I ended up duplicating `python -m compileall` into both `build_cmd` and `tsc_cmd` — structurally a no-op. Projects using Ruby, dynamic Lua, or untyped JS have the same problem.
- **Suggestion:** Rename to `typecheck_cmd` and allow empty (explicit opt-out). Structural-check hook should warn-not-fail when empty, rather than skipping the gate silently. Longer-term: the "project shape" selector could suppress the slot entirely for languages without a typechecker.
- **Status:** open

### 9. No entry-point skill for "audit an existing brownfield project"
- **Surface:** `skills/` (inventory) — no `first-audit` / `brownfield-audit` / `project-health-check` skill
- **Issue:** `gate-3-production-check` is framed as "run after Builder finishes implementation, before handover" — i.e., per-feature. When the user asks "is this project production-ready overall?" there's no skill that says "here's how to audit an existing codebase from cold." I had to compose the path manually: tier-selection → gate-3-production-check + STACK-PATTERNS rows + seven-validation-questions + parallel-dispatch of researcher/code-reviewer/QA. That composition is reasonable but nothing in the framework tells me that's the right path — I derived it. A new user wouldn't.
- **Suggestion:** Add a `project-health-check` skill that wraps the compose: Tier 3 selection → parallel-dispatch of 3 audit agents → consolidated findings into PROJECT-PLAN.md Open Findings → severity-sorted triage. One skill, one entry point. Bonus: it should also run `seven-validation-questions` retroactively against existing arch decisions (not just new plans) — the framework currently only points those questions at *new* work, which is a gap for brownfield adoption.
- **Status:** open

### 10. Gate 3 category-level mismatch (not just slot-level) for non-web projects
- **Surface:** `core/gate-3.md` → 7 categories
- **Issue:** Entry #7 covered slot-level mismatch. The category structure itself has the same problem: **Frontend** (6 items) is 100% N/A for a CLI/batch pipeline. Parts of **Infrastructure** ("service region colocated with database", "connection pooling") and **Security** ("tenant isolation on every query", "cross-tenant data", "security headers") also don't apply. Effectively ~15 of the ~38 items in the checklist are N/A for this project. A reviewer walking the list sees mostly N/As and may lose discipline on the items that *do* apply.
- **Suggestion:** The "project shape" selector (see #2) should select a tailored Gate 3 checklist. For `batch-pipeline` shape the categories could be: `Data Flow / LLM Call Discipline / Error Handling & Retries / Dedup & Idempotency / Observability / Regression / Process`. Each category carries items that actually apply, so every row is a real check. The universal rules are the same; only the checklist framing changes.
- **Status:** open

### 11. Gate 3 alone misses latent correctness bugs
- **Surface:** `core/gate-3.md` + `skills/gate-3-production-check/SKILL.md` — framing as "the production-readiness bar"
- **Issue:** Empirical result from Vendor Email Scraping audit (2026-04-24): three agents dispatched in parallel against the same codebase. **QA walked Gate 3 → returned `CONDITIONAL PASS, 0 CRITICAL, 0 HIGH`**. **Code-reviewer** on same codebase → 2 CRITICAL + 5 HIGH (secret leak, `_extract_with_retry` falls through to `None` crashing the caller, SQLite thread-safety, etc.). **Researcher** (pattern-fidelity + retroactive 7 validation questions) → 2 CRITICAL + 5 HIGH (prompt duplication ×6, scale-math failure at defaults, silent `except: pass`). If the framework is taken at its word — "Gate 3 is the production-readiness bar" — a project passing Gate 3 with zero HIGH findings would ship 4 CRITICAL bugs. Gate 3's 7 categories (Backend/Frontend/Infra/Security/Observability/Regression/Process) don't have a slot for "latent correctness bug" — the framework assumes code correctness is verified elsewhere, but that "elsewhere" isn't named in the gate-3 skill's composability notes. The skill mentions `verification-before-completion` (which checks claims are true, not that logic is bug-free) but doesn't mention dispatching a code-reviewer + researcher alongside.
- **Suggestion:** Either (a) add a Category 8 "Correctness" to gate-3.md with items like "no unreachable returns / fall-through to None", "no silent exception swallow outside boundary layers", "no shared-mutable state across threads without explicit serialization", OR (b) change `gate-3-production-check` composability to explicitly require parallel-dispatch of code-reviewer + researcher agents before Gate 3 can PASS. My recommendation is (b) — Gate 3 is a *checklist*; finding latent correctness bugs is a *review* activity and belongs in a different skill. The framework should make the parallel composition mandatory, not optional.
- **Status:** open

### 12. Three-agent consensus is strong signal but no mechanism captures it
- **Surface:** Audit composition pattern — `parallel-dispatch` of Researcher + Code-reviewer + QA
- **Issue:** From the Vendor Email Scraping audit: all three agents independently flagged `SharePointClient.create_contact` bypassing `retry_with_backoff` (Researcher = BP-1 scope-leak HIGH, Code-reviewer = reliability HIGH, QA = Gate 3 Observability MEDIUM). Three-agent convergence on the same file:line is extremely strong signal — much stronger than any single agent's individual severity. But there's no mechanism in the framework that *captures* this. The writing-qa-findings skill doesn't ask "did other agents flag this too", the PROJECT-PLAN template has no "consensus-level" column, and severity is per-agent not cross-agent. A finding flagged MEDIUM by one agent but also independently flagged HIGH by another should auto-promote.
- **Suggestion:** Add a `consolidate-audit-findings` skill that runs after parallel-dispatch of audit agents. Inputs: N findings files. Process: (1) key findings by `(file, line_range, rule)`; (2) union + dedupe; (3) severity-boost rule — if a finding appears in ≥2 agent files, promote by one level (MEDIUM→HIGH, HIGH→CRITICAL). Output: consolidated Open Findings table written to PROJECT-PLAN.md with `Consensus: 2/3` or `Consensus: 3/3` column. I did this manually this session but it's deterministic work that the framework could own.
- **Status:** open

### 13. No template for Researcher / Code-reviewer findings files
- **Surface:** `templates/qa-findings.template.md` exists; no equivalent for researcher or code-reviewer
- **Issue:** The writing-qa-findings skill produced a beautifully structured file (category walkthrough, evidence column, manual verification steps, commit architecture suggestion). The researcher and code-reviewer files in this session were fine but were shaped by each agent's implicit defaults — tables with different column orders, severity symbols, and "strengths" vs "verdict" vs "executive summary" framings. Cross-audit comparison and mechanical consolidation (see #12) is harder when the three findings files have different structures.
- **Suggestion:** Add `templates/researcher-audit.template.md` and `templates/code-review.template.md` with a shared minimal column contract: `| ID | Severity | Area | File:line | Description | Rule-or-pattern-ID | Remediation |`. Agents remain free to add sections (executive summary, strengths, recommendations) but the findings *table* is canonical. That makes consolidation mechanical.
- **Status:** open

### 14. Builder agents can't execute verification in their sandbox
- **Surface:** `agents/builder.md` + `skills/verification-before-completion/SKILL.md` (HARD-GATE) + `skills/subagent-driven-development/SKILL.md`
- **Issue:** All 5 Builders dispatched today (storage.py fix, config.py defaults, pipeline.py terminal raise, sharepoint+graph MSAL scrub, llm/*.py prompt extraction) returned `DONE_WITH_CONCERNS` with identical language: "Bash and PowerShell permissions were denied — I could not run `pytest -q` or `python -m compileall -q`." The Builders honestly flagged the gap and deferred verification to the orchestrator. I (main session) ran `pytest -q` → 151 passed, and `compileall` → clean. But this is dangerous in principle: `verification-before-completion` is a HARD-GATE in the framework, and if a less-careful future Builder silently claimed DONE without the ability to verify (or hallucinated verification output), the orchestrator would not know from the return message alone. The framework assumes Builders can run verification — they can't here.
- **Suggestion:** Pick one of three patterns and codify it in the Builder agent config:
  1. **Explicit delegation** — `verification-before-completion` skill documents an "orchestrator-runs-verify" path. Builders return `DONE_PENDING_VERIFICATION` with a verification command list; Deputy is contracted to run it before accepting DONE.
  2. **Permission-request protocol** — Builder agents preflight-check `Bash`/`PowerShell` availability; if denied, abort with `NEEDS_CONTEXT` citing the specific commands they need. Better than a soft DONE_WITH_CONCERNS because the protocol makes the gap explicit.
  3. **Sandbox-upgrade** — document that Builder agents need elevated permissions and provide a permissions profile template for `settings.json`.
  My preference is (1) + (2) — new status token `DONE_PENDING_VERIFICATION` that the Deputy MUST resolve before accepting; verification command list in the return contract. That matches the current de-facto behavior but makes it first-class.
- **Status:** open

---

## 2026-05-07 — Vendor Email Scraping (post-audit Tier 3 cycle: vendor-classifier noise-fix research)

### 15. `enterprise-research-first` HARD-GATE collides with WebFetch denial — researchers improvise an undocumented fallback
- **Surface:** `skills/enterprise-research-first/SKILL.md` Step 2 — citation discipline ("OSS: file:line + commit hash; Closed: URL + verbatim quote") AND HARD-GATE ("Verify the source at research time. 'Based on training data' is not a citation.")
- **Issue:** Researcher C (multi-stage-inbox-filtering, agent `a7989942a9c13d48f`) returned `DONE` with N=5 tools cited and BINDING/STRONG verdicts. Return message disclosed: *"WebFetch was permission-denied for every primary URL — all quotes tagged `(via WebSearch synthesis of canonical URL)` per agent fallback protocol."* WebSearch returns a SERP snippet, not the live primary source. Better than training-data recall, but it's not what the HARD-GATE requires either. Researcher honored the spirit (no fabrication, full disclosure) but violated the letter, and the skill has no codified fallback. The "agent fallback protocol" is something researchers invent on the fly — not framework-defined.
- **Suggestion:** Add a "When primary-source fetching is unavailable" section to the skill:
  1. Document degradation order: WebFetch → WebSearch synthesis → mark `[CITATION-DEGRADED]` → escalate `NEEDS_CONTEXT` if effective N drops below 3.
  2. Per-row degradation flag in the comparison table.
  3. State that BINDING (N≥5 unanimous) cannot be claimed if more than X% of cells are degraded.
  4. Codify the existing improvisation as the canonical fallback. Three of three researchers on this run will hit the same wall.
- **Status:** open

### 17. `enterprise-research-first` consensus can be standards-compliant but live-data wrong; skill has no live-data-verification step
- **Surface:** `skills/enterprise-research-first/SKILL.md` — Steps 1-6 cover tool selection, citation, comparison table, consensus strength, outliers, use-case-fit. There is no step that verifies the consensus pattern actually applies to the project's live data.
- **Issue:** Researcher A produced a textbook-quality output: N=9 sources, BINDING on List-Unsubscribe (5/5), STRONG on Auto-Submitted/Precedence/List-Id, all with verbatim RFC quotes. The arch doc adopted the pattern as Stage 1 of the cascade. Dry-run verification then revealed: of the 5 noise items we wanted to catch, **the RFC-compliant headers are not set on the actual senders we receive in our Microsoft 365 inbox**. Salesforce `techcomms@mail.salesforce.com` newsletter sets none of List-Id, List-Unsubscribe, Precedence, or Auto-Submitted. Microsoft Power Automate `flow-noreply@microsoft.com` notifications set none of them either. The senders DO set Microsoft-shaped headers (`x-auto-response-suppress`) and route via bulk subdomains (`bounce.mail.salesforce.com`) — neither captured in Researcher A's standards-based pattern. Result: shipped a STRONG-consensus cascade that initially missed 2 of 5 target noise items in production. Required a `_debug_headers.py` one-off script to fetch live mail and discover the gap, then add Rules 5 and 6 to the cascade with the live-observed signals.
- **Suggestion:** Add a Step 7 to `enterprise-research-first`: "Live-data verification before adoption". For pattern types that can be live-tested (header detection, regex matching, API-shape assumptions), the skill should require running a small probe against the project's actual data before locking the pattern into the arch doc. Concrete: a `verify_against_live_data:` block in the comparison table where the researcher (or builder) commits to running a verification probe and reporting back ≤1 hour. If the probe fails, the pattern is downgraded from BINDING/STRONG to "research-only" and the cascade is extended with live-observed signals before shipping. The current skill encourages literature-grounded confidence; reality has its own opinions and the framework should make space for them in the cycle, not after.
- **Status:** open

### 16. Per-prompt tier-selection enforcement re-fires inside an established Tier 3 cycle
- **Surface:** Hook `${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd pre-tool-use` — message: "tier-selection has not been invoked since the latest user prompt. Per ADR-002 D-A bundle: invoke production-framework:tier-selection before Edit/Write/Bash on task-shape prompts."
- **Issue:** I tier-selected this work as Tier 3 in my response to the user's prompt. The cycle is now in mid-execution — researchers running, no scope change. Each agent return-notification (`<task-notification>`) appears to count as a "new prompt" to the hook, which then blocks the next Edit/Bash until I re-invoke `tier-selection`. So far this turn I've invoked it twice in service of the same Tier 3 cycle. Effect: each invocation injects ~3KB of skill text into context, slows the response, and forces a ceremonial restatement of "Tier 3" with no decision change. Over a multi-agent cycle (3 researchers + N builders + QA + handover), this could be ≥10 redundant invocations.
- **Suggestion:** Either (a) the hook treats only true *user* prompts (not task-notifications) as cycle-resets, OR (b) `tier-selection` exposes a "cycle-already-established-as-Tier-N" short-circuit so re-invocation is a one-line ack rather than re-printing the whole skill, OR (c) the hook reads cycle state from a stash file (e.g., `.framework-state/current-cycle.json`) and skips when an active cycle is recorded. Option (c) generalizes — same stash could be read by `cto-mode` for dispatch-blocking.
- **Status:** open

- New entries go at the bottom under a dated session heading.
- When fixing an issue, update `Status: resolved` and add a one-line "Resolved by:" pointer (commit / PR / skill change) — don't delete.
- Group entries by session, not by category. Session grouping preserves context about what the user was *trying to do* when the friction surfaced.
- If a piece of feedback recurs across sessions, promote it to the top of the file under a "**Recurring pain**" subsection.
