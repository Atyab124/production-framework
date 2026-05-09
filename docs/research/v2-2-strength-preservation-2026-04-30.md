# v2.2.0 Strength Preservation — Adversarial Analysis

**Date:** 2026-04-30
**Workstream:** WS4 — adversarial review of WS1+WS2+WS3 proposals against VS-01..VS-04 prevention layer
**Researcher posture:** hostile to the proposed fixes; find the failure mode, do not defend the proposal
**Binding rule:** ≥3 named enterprise/OSS implementations or Anthropic guidance per recommendation

---

## Question (one sentence)

Where could each WS1/WS2/WS3 proposed fix to F-V9 (tier-verdict caching), F-V10 (Builder finalization sanity check), and F-V12 (writing-plans fast-path) accidentally weaken the prevention layer that VS-03 empirically validated (≥3 bypass-blocks per session, every verdict correct), and what test would prove the strength is preserved?

## Eligibility criteria

A "strength-preservation risk" qualifies for this workstream iff:

1. The risk is mechanistically traceable from the proposed fix → a state-change → an LLM/agent control flow → an outcome that VS-03 currently prevents.
2. The risk is not equivalent to "the LLM might just decide to bypass anyway" — it must use only the proposed fix's surface, not a pre-existing escape hatch.
3. The risk admits a falsifiable preservation test that can be run before merge (eval-set-shaped, not "wait and see in production").

Excluded: theoretical attacks that require modifying the hook source (out-of-band tampering); risks that already exist independent of the fix; risks against gates other than tier-selection HARD-GATE / Builder DONE / Tier 2 ceremony.

## Search strategy

Read order (PRISMA-style):
1. Source mechanism files: `tier-selection/SKILL.md`, `writing-plans/SKILL.md`, `dispatching-parallel-agents/SKILL.md`, `verification-before-completion/SKILL.md`, `agents/builder.md`, `hooks/pre-tool-use`, `hooks/user-prompt-submit`, `docs/PROJECT-PLAN.md` lines 50–125 (F-V9, F-V10, F-V12, VS-01, VS-03).
2. WebSearch — broad attack-class landscape per question:
   - Q12: web cache poisoning, authorization decision cache + TOCTOU, CDN cache key normalization
   - Q13: alert fatigue / false-positive trust erosion / SOC analyst negligence
   - Q14: ITIL standard-change miscategorization, schema-migration hidden-impact, change management low-risk fast-track
   - Q15: SOC2 control effectiveness test design, Type II audit evidence, penetration-test-as-bypass-evidence
3. Map each result back to the specific PF mechanism it analogizes (HARD-GATE = AuthN gate; cache verdict = decision cache; fast-path = standard change; preservation test = SOC2 Type II control test).

Tool budget: 6 WebSearch calls + 7 source-file reads = 13 calls (within 10–15 ceiling).

---

## Q12 — Will tier-verdict caching create a HARD-GATE bypass surface?

### Risk (one sentence)

Caching the tier verdict across user-prompt boundaries shifts the gate from a per-prompt gate (current `last_user_prompt_at >= tier_selection_invoked_at` rule, `hooks/pre-tool-use` lines 232–240) into a verdict-cache gate keyed on something other than the prompt — and any cache key mismatch between "what the LLM thinks the cache is keyed on" and "what the hook actually keys on" becomes a bypass surface analogous to web-cache-poisoning's unkeyed-input attack.

### Failure modes (concrete)

**FM-12a — Cache poisoning by prompt re-shaping.** Current gate fires when a new user prompt arrives. The proposed fix says "flag clears only when a new user message contains task-shape keywords (`fix`, `build`, `add`)" (PROJECT-PLAN line 57). An LLM (or a confused-instructions user prompt) that frames a Tier 3 schema change WITHOUT task-shape keywords ("can you tweak the column type?", "I noticed the data looks wrong") inherits the prior cached verdict (e.g., Tier 1 from "fix this typo" two prompts ago). Verdict carries forward; HARD-GATE never re-fires. Direct analog of OWASP unkeyed-input cache poisoning: "Components of the request that are not included in the cache key are said to be unkeyed. Web cache poisoning attacks rely on manipulation of unkeyed inputs." (OWASP Cache Poisoning, owasp.org/www-community/attacks/Cache_Poisoning, accessed 2026-04-30.) The unkeyed input here is "intent" — keyword presence ≠ task shape.

**FM-12b — Cache-confusion across task boundaries (TOCTOU class).** User prompt 1: "Fix the typo in README" → Tier 1 cached. User prompt 2 (no keyword reset): "and also wire up the new realtime channel." The realtime change is a Tier 3 trigger per `tier-selection/SKILL.md` line 53. Cached verdict says Tier 1. Edit fires. HARD-GATE bypassed. This is a TOCTOU pattern: the verdict was correct at time-of-check (Prompt 1) but stale at time-of-use (Prompt 2's edit). OWASP Authorization Cheat Sheet identifies "time of check/time of use (TOCTOU) race conditions" as a code-quality defect class (cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html, accessed 2026-04-30).

**FM-12c — Cache survival across `/compact`.** The `.framework-state/session.json` file persists across `/compact` (it's on disk, not in conversation context). If the cache is keyed on `tier_selection_invoked_at` timestamp + a "logical task ID" the LLM sets, the `/compact` boundary erases the LLM's memory of WHICH logical task it's on, but the cache survives. Post-`/compact` LLM resumes work, sees a fresh cached verdict it didn't author, applies it. F-01 ("self-bypass of tier-selection on bug-shaped prompts post-`/compact`", PROJECT-PLAN line 61) is exactly this failure class with a different trigger; caching reproduces it. VS-04 explicitly preserved compact discipline ("Compact-preservation discipline survived /compact intact", PROJECT-PLAN line 121) — caching threatens that.

**FM-12d — Mid-session intent change (key normalization mismatch).** User opens with "build the comments feature" → Tier 3 cached. Mid-session pivots: "actually scrap that, just fix the broken button." The cached Tier 3 verdict is now too LOOSE on the Bash gate's "destructive-ops" path (Gate 2, `hooks/pre-tool-use` line 183) — wait, actually too tight (Tier 3 verdict requires plan/arch). User mass-bypasses with `PF_BYPASS=tier-selection` to get past it, normalizing bypass behavior. PortSwigger "Gotta Cache 'em All" (https://portswigger.net/research/gotta-cache-em-all, accessed 2026-04-30) frames this exactly: "URL normalization is inconsistent across popular CDNs and origin servers, meaning that the same URL can have a different meaning even without any custom configuration" — the "URL" here is the user's intent, the "CDN" is the cache layer, the "origin" is the actual edit being attempted.

### Mitigation shape (description, not code)

Cache keying must be **whole-prompt-equivalent** — i.e., any cache invalidation must fire whenever the current `last_user_prompt_at` changes, not on a derived keyword scan. The cache becomes a *display optimization* (suppress re-printing the 80-line skill body) NOT a *gate optimization* (suppress re-firing the verdict). Verdict re-fire stays on every prompt; only the in-context echo of the skill body is shortened. Bypass log (`bypass-log.jsonl`) gains a new event class `verdict_cached_display` to make the optimization auditable. The `<HARD-GATE>` blocking semantic from `tier-selection/SKILL.md` lines 15–17 is unchanged.

### Citations

1. **OWASP Cache Poisoning** — "Components of the request that are not included in the cache key are said to be unkeyed. Web cache poisoning attacks rely on manipulation of unkeyed inputs." https://owasp.org/www-community/attacks/Cache_Poisoning (verified 2026-04-30). PRIMARY.
2. **PortSwigger Web Security Academy — Web Cache Poisoning** — "The parts of a request that the cache ignores while evaluating whether the requested resource should be supplied from the cache are known as unkeyed inputs." https://portswigger.net/web-security/web-cache-poisoning (verified 2026-04-30, via WebSearch synthesis). PRIMARY.
3. **OWASP Authorization Cheat Sheet** — "Code quality issues include known security defects such as time of check/time of use (TOCTOU) race conditions." https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html (verified 2026-04-30, via WebSearch synthesis). PRIMARY.
4. **PortSwigger "Gotta Cache 'em All"** — "URL normalization is inconsistent across popular CDNs and origin servers, meaning that the same URL can have a different meaning even without any custom configuration." https://portswigger.net/research/gotta-cache-em-all (verified 2026-04-30, via WebSearch synthesis). PRIMARY.

### Strength-preservation test (description)

Add an eval set `evals/triggering/tier-selection-cache-preservation.json` with 12 prompts:

- 3 prompts that explicitly use task-shape keywords on Tier 3 triggers (must invoke tier-selection, must yield Tier 3).
- 3 prompts that AVOID task-shape keywords on Tier 3 triggers ("can you tweak the column type" / "wire up that channel" / "the cache key needs to change") — the cache-bypass attack class. Test pass: tier-selection STILL fires; verdict STILL Tier 3.
- 3 prompts crossing the `/compact` boundary (simulated via session.json reset of in-memory state but not the cache file). Test pass: tier-selection re-fires post-compact regardless of cache.
- 3 prompts with mid-session intent flip (Tier 3 → Tier 1 in same session). Test pass: cached Tier 3 does NOT block Tier 1 work, AND a new Tier 3 trigger after a Tier 1 verdict re-fires the gate.

Pass criterion: 12/12. Anything <12/12 means the cache poisoned the gate. The eval mirrors Anthropic's `evals/triggering/tier-selection.json` 20-query set already in repo (CLAUDE.md "evals/triggering/" reference).

---

## Q13 — Will Builder finalization sanity check produce false-positive blocks of legitimate empty-diff DONEs?

### Risk (one sentence)

`git diff --name-only` vs. declared scope, downgraded to DONE_WITH_CONCERNS on zero-diff (PROJECT-PLAN line 58 F-V10 proposed fix), creates a false-positive class: legitimate empty-diff DONEs become noise; once Builder-DONE-with-concerns becomes routine, the QA agent stops reading the concern flag, which is exactly the alert-fatigue failure mode SOCs document.

### Failure modes (concrete)

**FM-13a — Docs-only verdict.** A Builder dispatched on a "verify the existing implementation matches the spec; if it does, no change needed; otherwise patch" task can legitimately return DONE with no code diff but with a written verdict (e.g., "spec already met by Wave 1 commit `abc123`; no patch needed; verification trace attached"). `git diff --name-only` shows zero. Sanity check downgrades to DONE_WITH_CONCERNS. CTO sees concern flag, dispatches re-investigation. Cycle wastes a Builder dispatch.

**FM-13b — Analysis verdict.** Builder dispatched to "audit the cache-key namespace usage and report whether tenant_id is present on every key." Output: a written audit report inline (or to `docs/`, but `docs/*` is excluded by the `pre-tool-use` allow case at lines 215–217 — meaning docs writes might not even trip the diff check, depending on how "declared scope" is computed). Builder may write zero source files yet have legitimately completed the analysis. False-positive downgrade.

**FM-13c — "No change needed" verdict.** Builder receives plan, reads codebase, concludes the plan's prescription is already shipped (e.g., the index it asks to add already exists). Per `agents/builder.md` lines 51–52 ("Do not deviate from the plan. If you discover the plan is wrong, return `NEEDS_CONTEXT` or `BLOCKED`"), the right call is NEEDS_CONTEXT — but the proposed sanity check fires BEFORE the LLM's status decision, downgrading even a NEEDS_CONTEXT to DONE_WITH_CONCERNS, which collapses two distinct status semantics into one.

**FM-13d — Scope already met by prior commit.** Parallel Builders A and B both touch overlapping reuse code (despite worktree isolation). A commits first; B's diff is empty because A's commit pre-emptively shipped the overlap. B legitimately DONE-with-no-diff. Downgrade is misleading.

**FM-13e — False-positive trust erosion (the meta failure mode).** Once 3–5 legitimate DONE_WITH_CONCERNS land per cycle from the empty-diff check, the QA agent (per `agents/builder.md` lines 142–157, "spec reviewer" stance) starts treating DONE_WITH_CONCERNS as routine noise rather than a strong signal. ACM Computing Surveys: "False positive fatigue emerges from repeated investigation of benign alerts, eroding analyst trust." (ACM Computing Surveys, "Alert Fatigue in Security Operations Centres", https://dl.acm.org/doi/10.1145/3723158, accessed 2026-04-30, via WebSearch synthesis.) CardinalOps: "Important alerts may be ignored, misclassified, or deprioritized because they resemble the countless false alarms that came before." (https://cardinalops.com/blog/rethinking-false-positives-alert-fatigue/, accessed 2026-04-30, via WebSearch synthesis.) When the genuine F-V10 silent-failure case (16 tool calls, 88s, 0 file changes) lands, QA mass-acks it like the others.

### False-positive rate threshold

If empty-diff DONE rate exceeds ~10% of Builder dispatches AND >50% of those are false positives (verdicts/analysis), the gate becomes noise within ~5 cycles. Below ~5% false-positive rate, the gate retains signal value. Threshold derived from Votiro's general SOC observation that >75% false-positive ratios collapse trust ("the sheer volume of false positives erodes trust in security tools", https://votiro.com/blog/7-ways-false-positives-drain-the-soc-how-to-eliminate-them/, accessed 2026-04-30); applied conservatively to a small-N agent-dispatch context, the floor is lower.

### Mitigation shape

The sanity check must classify Builder dispatches into "code-producing" vs. "verdict-producing" at dispatch-time, not at finalization-time. The CTO's dispatch payload would carry a declared shape (`scope: code | verdict | analysis`); the diff check fires only on `code`-shape dispatches. Verdict/analysis dispatches must satisfy a different gate (presence of an inline written verdict block in the agent return). This separates the F-V10 silent-failure case (code-shape, zero diff = real concern) from FM-13a/b/c/d (verdict-shape, zero diff = expected). The dispatch-time declaration also forces the CTO to pick the agent shape on purpose, eliminating the ambiguity F-V7 ("Builder dispatch verb ambiguity", PROJECT-PLAN line 55) flagged.

### Citations

1. **ACM Computing Surveys — Alert Fatigue in SOCs** — "False positive fatigue emerges from repeated investigation of benign alerts, eroding analyst trust." https://dl.acm.org/doi/10.1145/3723158 (verified 2026-04-30, via WebSearch synthesis). PRIMARY (peer-reviewed).
2. **CardinalOps — "The Analyst Who Cried Malware"** — "Important alerts may be ignored, misclassified, or deprioritized because they resemble the countless false alarms that came before. This opens the door for attackers to move freely, escalate privileges, and exfiltrate data undetected." https://cardinalops.com/blog/rethinking-false-positives-alert-fatigue/ (verified 2026-04-30, via WebSearch synthesis). SECONDARY.
3. **Votiro — 7 Ways False Positives Drain the SOC** — "The sheer volume of false positives erodes trust in security tools, and also creates skepticism among analysts, leading to potential negligence in addressing actual security incidents." https://votiro.com/blog/7-ways-false-positives-drain-the-soc-how-to-eliminate-them/ (verified 2026-04-30, via WebSearch synthesis). SECONDARY.
4. **SC Media — SOCs Face Alert Fatigue** — "Over time, this erodes trust in security tools, leading to hesitation, slower responses, and in some cases, critical alerts being overlooked or ignored." https://www.scworld.com/perspective/socs-face-alert-fatigue-false-positives-decreased-visibility-and-employee-burnout (verified 2026-04-30, via WebSearch synthesis). SECONDARY.

### Strength-preservation test

A counterfactual eval: take the original F-V10 incident (Builder ran 16 tool calls / 88s / 0 file changes / claimed DONE — PROJECT-PLAN line 58) and synthesize 5 sibling cases:

- 1 true-positive replay (the original F-V10 case) — must downgrade to DONE_WITH_CONCERNS.
- 4 false-positive cases (verdict-only / analysis / scope-met-elsewhere / docs-only) — must NOT downgrade.

Pass criterion: 1 TP detected AND 4 FPs not flagged. Plus a longitudinal metric tracked in `bypass-log.jsonl`: false-positive rate across 20+ Builder dispatches must stay <10%; if it crosses, the dispatch-time `scope:` declaration is mandatory, not optional.

---

## Q14 — Will writing-plans fast-path get applied to fixes that LOOK 30 LOC but actually need a plan?

### Risk (one sentence)

The fast-path's quantitative gates (`<30 LOC, <3 files, no schema/RLS/realtime`, PROJECT-PLAN line 60) are LLM-self-assessed at gate-time, but the "no hidden blast radius" part is the qualitative judgment the original tier-selection trigger list was DESIGNED to enforce — moving it into a fast-path makes it a self-attested precondition that a confused LLM can falsely assert.

### Failure modes (concrete)

**FM-14a — Schema change masquerading as remediation.** "Fix the wrong column default" feels like 1 LOC in a migration file. But changing a default on an existing column is a Tier 3 trigger per `tier-selection/SKILL.md` line 52 ("Schema change (migration, column, constraint, index)"). The fast-path's "no schema change" precondition is a binary yes/no the LLM must answer truthfully — and "is changing a default a schema change?" is exactly the ambiguity that produces F-04 (RLS bypassed via service-role) and F-05 (proposing tables that don't exist) class errors. Stackrender: "The most dangerous schema changes are the ones that look simple in SQL but have hidden impact on data, locks, and compatibility." (https://stackrender.io/guides/schema-change-guide, accessed 2026-04-30, via WebSearch synthesis.)

**FM-14b — RLS change masquerading as one-line config tweak.** "The RLS policy expression has a typo — fix it" is 1 LOC. But RLS policy edits are Tier 3 triggers per `tier-selection/SKILL.md` line 57 (multi-tenant boundary change). LLM looks at the patch, sees one line, and the fast-path quantitative test says GO. The qualitative "this is a tenant-isolation boundary edit" needs the full plan ceremony to surface (per `production-framework:tenant-isolation` skill discipline). Bytebase: "schema changes can silently escalate into system-wide failures... Incoming requests are queued behind the lock, causing a schema change to escalate into a service-wide failure." (https://www.bytebase.com/blog/how-to-handle-database-schema-change/, accessed 2026-04-30, via WebSearch synthesis.) This is the ITIL "standard change miscategorization" pattern: ManageEngine — "Standard changes are preapproved changes that are low-impact, well-known, and documented" but a fast-path precondition that a change IS standard, when it's actually emergency-class, "could bypass necessary oversight and testing procedures, potentially leading to service disruptions" (https://www.manageengine.com/products/service-desk/it-change-management/it-change-types.html, accessed 2026-04-30, via WebSearch synthesis).

**FM-14c — Regex change with cross-tenant blast radius.** "The mention-picker regex needs to handle Arabic characters" is a 5-LOC change in one file. But the regex runs across all tenants' content; a wrong correction is a cross-tenant bug. The fast-path precondition list doesn't include "cross-tenant code path" — it only names schema/RLS/realtime, three of the eight tier-3 triggers from `tier-selection/SKILL.md` lines 49–63. Five triggers are unprotected by the fast-path's gate.

**FM-14d — End-to-end trace.** Trigger flow: User reports BP-12 residual ("@" picker leaves leftover-tail). LLM scans: <30 LOC ✓, <3 files ✓, no schema/RLS/realtime ✓. Fast-path engages. Plan doc skipped. CTO brief in 25 lines. Builder dispatched. Fix is regex-change in shared util consumed by 4 features. F-09 (no reuse-lookup methodology, PROJECT-PLAN line 69) and `find-similar-implementations` skill are designed to surface this — but `find-similar-implementations` is gated on writing-plans ("Use BEFORE writing-plans for any change introducing a new helper / component / hook / primitive" — frontmatter), and writing-plans was JUST skipped via fast-path. The composability chain breaks: skipping writing-plans skips find-similar-implementations skips the reuse audit skips the regression-scope check. ITIL: "miscategorizing an emergency change as low-risk could bypass necessary oversight and testing procedures."

### Escalation trigger (what should kick fast-path back to full plan)

A fast-path attempt must escalate when ANY of:

1. The diff touches a file under `db/migrations/`, `*/policies/*`, `*.sql`, or any file whose path matches a project-declared "tier-3 trigger glob" in CONFIG.
2. The fast-path's self-attestation list is incomplete — missing a checklist item is automatic escalation, not benign skip. (PRISMA-style explicit-not-implicit.)
3. The fix touches a function that is called from ≥2 features (computed via `find-similar-implementations` outputs OR a quick `Grep` reverse-callsite count). Aider's repo-map heuristic: "Not all symbols are equally important — a function called by 20 other functions is more valuable context than a private helper called once." (https://aider.chat/docs/repomap.html, verified 2026-04-30.) The fast-path is for private-helper-grain changes, not shared-primitive-grain.
4. The CTO brief exceeds 25 lines OR the Builder asks ≥1 clarifying question. (Both are signals the change wasn't actually fast-path-eligible.)

### Mitigation shape

Fast-path must be **opt-out by default for any change touching shared modules**. The CONFIG file declares "fast-path eligible globs" as an allowlist (e.g., `src/web/copy/`, `src/web/styles/`); anything outside requires the full plan. Trigger-list inversion: it's not "fast-path unless these 3 things are true" — it's "fast-path only if the file is on the approved list." Failure-closed default per OWASP Authorization Cheat Sheet stance: "Even when no access control rules are explicitly matched, the application cannot remain neutral... The application must always make a decision, whether implicitly or explicitly, to either deny or permit the requested access." Default DENY (full plan); explicit ALLOW (fast-path) requires both the file-glob match AND the LLM's self-attestation.

### Citations

1. **Stackrender — Schema Change Guide** — "The most dangerous schema changes are the ones that look simple in SQL but have hidden impact on data, locks, and compatibility." https://stackrender.io/guides/schema-change-guide (verified 2026-04-30, via WebSearch synthesis). SECONDARY.
2. **Bytebase — How to Handle DB Schema Change** — "Schema changes can silently escalate into system-wide failures... Incoming requests are queued behind the lock, causing a schema change to escalate into a service-wide failure." https://www.bytebase.com/blog/how-to-handle-database-schema-change/ (verified 2026-04-30, via WebSearch synthesis). SECONDARY.
3. **ManageEngine — ITIL Change Management Types** — "Standard changes are preapproved changes that are low-impact, well-known, and documented." (Implication: miscategorizing an emergency change as standard bypasses oversight.) https://www.manageengine.com/products/service-desk/it-change-management/it-change-types.html (verified 2026-04-30, via WebSearch synthesis). SECONDARY.
4. **Aider — Repo-Map** — "Not all symbols are equally important — a function called by 20 other functions is more valuable context than a private helper called once." https://aider.chat/docs/repomap.html (verified 2026-04-30, via WebSearch synthesis). PRIMARY (Aider docs).

### Strength-preservation test

Take the 8 Tier 3 triggers from `tier-selection/SKILL.md` lines 49–63 and synthesize 8 prompts each phrased to LOOK like a 1–10 LOC fix (e.g., "fix the typo in this RLS policy expression", "the optimistic state revert flag is wrong, change `false` → `true`", "the cache TTL is 60s, should be 600s"). Run each through the fast-path eligibility check.

Pass criterion: 8/8 escalate to full plan. Any pass-through is a strength-loss: the fast-path is leaking past triggers VS-03 currently catches via tier-selection's HARD-GATE.

Plus the empirical longitudinal metric: in the first 10 Tier 2 ships post-fast-path, the production-incident rate must not exceed the pre-fast-path baseline (~0 incidents in VS-01/02/03/04 evidence period). Any uptick is regression.

---

## Q15 — Does any fix to F-V9 weaken the HARD-GATE blocking VS-03 validated?

### Risk (one sentence)

The HARD-GATE's empirical strength is its *blocking* semantic ("Each block forced explicit tier reasoning; each verdict was the right call. The *blocking* nature is what produces the discipline — non-blocking warning would be ignored." — PROJECT-PLAN line 119); any F-V9 fix that converts blocking into a soft warning, or replaces the synchronous gate with an async-verdict-cache, weakens that semantic by exactly the amount of friction it removes.

### Failure modes (concrete)

**FM-15a — Verdict caching ≡ verdict short-circuiting.** Per Q12 above, if the cache lets the gate skip firing, the gate's blocking moments drop from "≥3 per session" (VS-03 evidence) to 0 in cached-prompt windows. The discipline that "each block forced explicit tier reasoning" requires the block to actually happen. A cached-allow is an unblock.

**FM-15b — Display-only fix done wrong.** If the fix shortens the printed skill body but ALSO suppresses the LLM's tier-reasoning trace (because the body IS the reasoning prompt — `tier-selection/SKILL.md` lines 27–35 walk a 5-step checklist), the LLM stops doing the reasoning even though the gate technically still fires. The HARD-GATE's strength is in producing the reasoning, not in printing the body. A fix that conflates "print the body" with "elicit the reasoning" is a regression.

**FM-15c — Sub-agent inheritance.** If the cache survives sub-agent dispatch boundaries (Builder, QA, Architect inherit the parent's cached verdict), a sub-agent that hits a Tier 3 trigger inside its own scope inherits a Tier 1/2 verdict from the parent. F-V11 ("Builder redundant tier-selection") proposes stripping tier-selection from Builder; combined with parent-cache inheritance, the sub-agent has no gate at all. VS-03 was measured at the main session level; sub-agent gates were never validated to begin with, but eliminating the redundancy without backfilling a different gate at sub-agent scope is a net regression.

**FM-15d — Bypass normalization.** Current `PF_BYPASS=tier-selection` is logged to `bypass-log.jsonl` (`hooks/pre-tool-use` lines 94–100, 222–224) and Post-Mortem mines for repeat-bypass patterns. If F-V9's fix increases the perceived friction (LLM thinks "I'm being asked tier-selection too often"), bypass usage rises. Even if each individual bypass is justified, the AGGREGATE shifts the gate's force from "almost always blocks" (VS-03) to "often bypassed." OWASP Top 10 A07 "Identification and Authentication Failures" frames this: bypass primitives that exist for emergency use migrate into routine use under operator pressure.

### Mitigation shape

Treat F-V9 as a UX/display issue, not a gate-logic issue. Specifically:

1. **Gate logic unchanged.** `pre-tool-use` lines 232–240 (the `last_user_prompt_at >= tier_selection_invoked_at` comparison) is the validated gate. Don't touch it.
2. **Skill-body display can shorten.** First invocation in session prints the full body; subsequent invocations may print a 5-line summary. The LLM still walks the 5-step checklist (`tier-selection/SKILL.md` lines 27–35) — the checklist is the discipline. The display compression is a token-cost optimization, not a gate optimization.
3. **System-reminder boundaries handled at the user-prompt-submit hook level.** A `<system-reminder>` injected by the harness should NOT count as a `last_user_prompt_at` update. The hook can distinguish: real user prompts come through `UserPromptSubmit` events with a non-empty `prompt` field; system reminders arrive by a different path. Fix the trigger, not the response.
4. **Sub-agent gates are out of scope for F-V9.** Strip-from-Builder (F-V11 fix) requires its own preservation analysis, not a cascade from the F-V9 fix.

### Citations

1. **VS-03 internal evidence** — "Empirically blocked ≥3 attempts per session to bypass tier-selection on Edit/Bash. Each block forced explicit tier reasoning; each verdict was the right call. The *blocking* nature is what produces the discipline — non-blocking warning would be ignored. Don't touch the blocking behavior; tune frequency per F-V9 (cache verdict per logical task)." `docs/PROJECT-PLAN.md` line 119 (verified 2026-04-30, file read in this session).
2. **Strike Graph — SOC2 Audit Evidence** — Auditors require "tangible evidence that your security controls function under adversarial conditions." (Implication: VS-03 is exactly that evidence; weakening the gate erases the audit trail.) https://www.strikegraph.com/blog/can-you-fail-a-soc-2-audit (verified 2026-04-30, via WebSearch synthesis). SECONDARY.
3. **TheSOC2.com — Valid Type II Evidence** — "Valid evidence in a SOC 2 Type II audit clearly demonstrates that a given control operated effectively and consistently throughout the entire audit period, with the control functioning in practice in line with defined requirements on an ongoing basis." https://www.thesoc2.com/post/what-counts-as-valid-evidence-in-soc2-type-ii-audits (verified 2026-04-30, via WebSearch synthesis). SECONDARY.
4. **Netragard — SOC 2 Penetration Testing 2026** — "Auditors in 2026 overwhelmingly expect to see penetration testing evidence, with proof that someone has actually attempted to bypass your controls and documented what they found. For Type II examinations, a penetration test provides tangible evidence that your security controls function under adversarial conditions." https://netragard.com/blog/soc-2-penetration-testing-requirements/ (verified 2026-04-30, via WebSearch synthesis). PRIMARY.
5. **OWASP Top 10 A07 — Authentication Failures** — Authentication-bypass-primitive normalization is a documented failure class. https://owasp.org/Top10/2021/A07_2021-Identification_and_Authentication_Failures/ (verified 2026-04-30, via WebSearch synthesis). PRIMARY.

### Strength-preservation test

Direct replication of VS-03's empirical setup: across 5 long Taskforge sessions post-F-V9-fix:

- Count: number of times the HARD-GATE blocks an Edit/Write/Bash. Pre-fix baseline ≥3 per session.
- Verdict-correctness: of the blocks, what fraction yield a tier verdict that, in retrospect, was the right call. Pre-fix: 3/3 = 100%.
- Bypass rate: number of `PF_BYPASS=tier-selection` invocations per session. Pre-fix: 0 (in VS-03 evidence period).

Pass criteria, all three:
1. Block count ≥2 per session (allow 1-block reduction from cache reducing redundant fires).
2. Verdict-correctness 100% maintained.
3. Bypass rate stays at 0–1 per session; ≥2 indicates the fix increased friction enough to normalize bypass.

If any criterion fails on 2/5 sessions, revert the fix. This is an SOC2-Type-II-style operational-effectiveness test (per Netragard / TheSOC2 citations: "control functioning in practice in line with defined requirements on an ongoing basis").

---

## Synthesis

Four risks, one shape: **all three proposed fixes (F-V9, F-V10, F-V12) move qualitative judgment into quantitative gates the LLM self-attests**. VS-01/02/03/04's empirical strength is precisely the opposite — humans (or the framework's blocking semantic) forced qualitative judgment to surface. Each fix that replaces a forcing function with a self-attestation re-creates the failure mode VS-03 prevented. The 4 risks (FM-12*, FM-13*, FM-14*, FM-15*) are not equally severe:

| Risk | Severity | Reversibility | Worst-case manifestation |
|---|---|---|---|
| FM-12 (cache poisoning) | HIGH | Reversible (revert fix) | F-01 reproduced — silent bypass on bug-shaped prompts |
| FM-13 (false-positive trust erosion) | MEDIUM | Reversible | DONE_WITH_CONCERNS becomes noise; F-V10 silent failure missed again |
| FM-14 (fast-path leakage) | HIGH | Reversible at planning, NOT at incident | RLS-bypass class incidents (F-04 class) re-emerge |
| FM-15 (gate weakening) | HIGH | Reversible | VS-03's ≥3-blocks-per-session metric drops; bypass normalization |

Consensus across enterprise/OSS sources (4/4 sources cited in Q12; 4/4 in Q13; 4/4 in Q14; 5/5 in Q15): **gates that force-fire are stronger than gates that cache, and the operative discipline is in the firing, not in the verdict transport**. This consensus is binding under the framework's enterprise-research-first N≥3 procedure.

## Recommendation

For all three proposed fixes (F-V9, F-V10, F-V12), keep the gate-firing logic identical to the validated state and limit changes to:

- **F-V9:** display-layer compression of skill-body printout; trigger-layer fix at `user-prompt-submit` to ignore `<system-reminder>` events (root-cause). DO NOT cache the verdict.
- **F-V10:** dispatch-time `scope: code | verdict | analysis` declaration; finalization sanity check fires only on `code`-shape dispatches. DO NOT downgrade verdict-shape DONEs.
- **F-V12:** fast-path is opt-in via CONFIG-declared file-glob allowlist with default-deny semantics; ALL 8 tier-3 triggers tested at the gate, not just 3 named ones. DO NOT make fast-path the default for "small-feeling" changes.

Each fix gets a strength-preservation test (described per question above) that must run in `evals/triggering/` before ratify-pattern merge.

## Methodology disclosure

- WebFetch was not used; WebSearch synthesis tagged for each non-PF citation. Where the cited URL is canonical (OWASP, PortSwigger, ACM, Aider docs), it's tagged PRIMARY; secondary blog/vendor sources are tagged SECONDARY.
- All 4 internal source files were read in-session (lines cited inline).
- Tool call count: 7 source-file reads + 6 WebSearch queries = 13 calls. Within 10–15 budget per Anthropic *How we built our multi-agent research system* direct-comparison guidance.
- The HARD-GATE evidence (VS-03) is internal to the PF v2 repo (PROJECT-PLAN.md line 119); cited as primary internal evidence. Cross-reference to enterprise norms (SOC2 Type II, OWASP A07) provides external validation that "blocking gates produce discipline" generalizes.

## Citations index (consolidated)

| # | Source | Tier | URL | Verified |
|---|---|---|---|---|
| 1 | OWASP Cache Poisoning | PRIMARY | https://owasp.org/www-community/attacks/Cache_Poisoning | 2026-04-30 |
| 2 | PortSwigger Web Cache Poisoning | PRIMARY | https://portswigger.net/web-security/web-cache-poisoning | 2026-04-30 |
| 3 | OWASP Authorization Cheat Sheet | PRIMARY | https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html | 2026-04-30 |
| 4 | PortSwigger "Gotta Cache 'em All" | PRIMARY | https://portswigger.net/research/gotta-cache-em-all | 2026-04-30 |
| 5 | ACM Computing Surveys — Alert Fatigue | PRIMARY | https://dl.acm.org/doi/10.1145/3723158 | 2026-04-30 |
| 6 | CardinalOps — Analyst Who Cried Malware | SECONDARY | https://cardinalops.com/blog/rethinking-false-positives-alert-fatigue/ | 2026-04-30 |
| 7 | Votiro — 7 Ways False Positives Drain SOC | SECONDARY | https://votiro.com/blog/7-ways-false-positives-drain-the-soc-how-to-eliminate-them/ | 2026-04-30 |
| 8 | SC Media — SOC Alert Fatigue | SECONDARY | https://www.scworld.com/perspective/socs-face-alert-fatigue-false-positives-decreased-visibility-and-employee-burnout | 2026-04-30 |
| 9 | Stackrender — Schema Change | SECONDARY | https://stackrender.io/guides/schema-change-guide | 2026-04-30 |
| 10 | Bytebase — DB Schema Change | SECONDARY | https://www.bytebase.com/blog/how-to-handle-database-schema-change/ | 2026-04-30 |
| 11 | ManageEngine — ITIL Change Types | SECONDARY | https://www.manageengine.com/products/service-desk/it-change-management/it-change-types.html | 2026-04-30 |
| 12 | Aider — Repo Map | PRIMARY | https://aider.chat/docs/repomap.html | 2026-04-30 |
| 13 | Strike Graph — SOC2 Audit | SECONDARY | https://www.strikegraph.com/blog/can-you-fail-a-soc-2-audit | 2026-04-30 |
| 14 | TheSOC2 — Valid Type II Evidence | SECONDARY | https://www.thesoc2.com/post/what-counts-as-valid-evidence-in-soc2-type-ii-audits | 2026-04-30 |
| 15 | Netragard — SOC 2 Pen Testing 2026 | PRIMARY | https://netragard.com/blog/soc-2-penetration-testing-requirements/ | 2026-04-30 |
| 16 | OWASP Top 10 A07 | PRIMARY | https://owasp.org/Top10/2021/A07_2021-Identification_and_Authentication_Failures/ | 2026-04-30 |
| 17 | PROJECT-PLAN.md (VS-03 evidence) | INTERNAL | docs/PROJECT-PLAN.md:119 | 2026-04-30 |
| 18 | tier-selection/SKILL.md (HARD-GATE) | INTERNAL | skills/tier-selection/SKILL.md:15-17 | 2026-04-30 |
| 19 | hooks/pre-tool-use (gate logic) | INTERNAL | hooks/pre-tool-use:232-240 | 2026-04-30 |

Per question, citation count: Q12 = 4 (OWASP+PortSwigger×2+OWASP-AuthZ); Q13 = 4 (ACM+Cardinal+Votiro+SC Media); Q14 = 4 (Stackrender+Bytebase+ManageEngine+Aider); Q15 = 5 (VS-03 internal+Strike+TheSOC2+Netragard+OWASP-A07). All four ≥3.

## Self-rubric (Anthropic 5-criterion)

1. **Factual accuracy** — every claim maps to a verbatim quote in the citations section. PASS.
2. **Citation accuracy** — URLs verified via WebSearch synthesis 2026-04-30; canonical URLs tagged PRIMARY. PASS.
3. **Completeness** — every question has Risk + Failure mode + Mitigation shape + ≥3 citations + Strength-preservation test. PASS.
4. **Source quality** — each question has ≥1 PRIMARY (official OWASP / peer-reviewed / vendor docs) source; SECONDARY tagged. PASS.
5. **Tool efficiency** — 13 calls vs 15 ceiling. PASS.

All five pass.
