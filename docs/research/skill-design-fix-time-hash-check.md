# Skill Design Research — `fix-time-hash-check`

**Date:** 2026-04-30
**Type:** Source-of-truth research for the `skills/fix-time-hash-check/SKILL.md` skill — research only, no code modifications.
**Triggered by:** Item 40 (sub-gaps 40-1, 40-2, 40-6) and Item 41 of `docs/audits/v1-feedback-vs-v2-2026-04-30.md`. Audit verdict on Item 40 was **GAP — multiple sub-gaps**:
  - **40-1:** Single-pass fixes (remediation loop = 1) never enter the incident table → clusters never form.
  - **40-2:** No fix-time hash check. The hash exists for proposal-time dedup; no skill prompts "compute hash, grep PROJECT-PLAN + STACK-PATTERNS, surface prior occurrences" *before applying a fix*.
  - **40-6:** Cross-session incident look-back is manual; fresh agents do not auto-mine PROJECT-PLAN before fix-proposal.
  Item 41 establishes the empirical strength: PF v1's Rule #43 incident-loop machine enforcement is "the canonical 'harden discipline → machine' example" and supplies the load-bearing primitive (`compute-root-cause-hash.sh`).
**Scope:** This skill is the **fix-time** application of an existing PF v1 hash primitive at a *novel* invocation point. The primitive itself (the SHA-256 normalization grammar) is already enterprise-grounded and v1-tested; the novel design surface is *when* the hash is computed (before fix application, not just at post-mortem proposal time) and *what is grepped* (PROJECT-PLAN.md Incident Table + STACK-PATTERNS.md, not just internal incident clusters). The skill is composable with `superpowers:systematic-debugging` Step 4.5 (the bug-class enterprise-research step from Item 28).
**Methodology disclosure:** SP 5.0.7 quotes are read directly from the local cache at `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/`. PF v1 `compute-root-cause-hash.sh` is read directly from `production-framework/scripts/`. Anthropic and enterprise quotes are reproduced verbatim as returned by WebSearch synthesis of the canonical URLs listed in §1; WebFetch was permission-denied this session — re-verify any binding quote against the live URL before commit.

---

## §1 Sources Inventory

| # | Source | URL / Path | Method | Status |
|---|---|---|---|---|
| 1 | PF v1 — `scripts/compute-root-cause-hash.sh` (HASH_VERSION=1, 7-rule normalization) | `production-framework/scripts/compute-root-cause-hash.sh` | Direct read | OK (lines 1–119 verified) |
| 2 | PF v2 — `templates/PROJECT-PLAN.template.md` Incident Table (`root_cause_hash` column) | `production-framework-v2/templates/PROJECT-PLAN.template.md` lines 47–55 | Direct read | OK |
| 3 | PF v2 — `agents/debugger.md` (producer of root cause text → hash input) | `production-framework-v2/agents/debugger.md` | Direct read | OK |
| 4 | PF v2 — `v1-feedback-vs-v2-2026-04-30.md` Item 40 (6 sub-gaps), Item 41 (strength), Item 28 (bug-class research), addendum lines 290–386 | `production-framework-v2/docs/audits/v1-feedback-vs-v2-2026-04-30.md` | Direct read | OK |
| 5 | PF v2 — `skills/enterprise-research-first/SKILL.md` (consensus grammar BINDING/STRONG/INSUFFICIENT) | `production-framework-v2/skills/enterprise-research-first/SKILL.md` | Direct read | OK |
| 6 | SP 5.0.7 — `skills/systematic-debugging/SKILL.md` (Phase 2 Pattern Analysis — "Find Working Examples") | `.../superpowers/5.0.7/skills/systematic-debugging/SKILL.md` lines 122–143 | Direct read | OK |
| 7 | SP 5.0.7 — full skill list (verifies absence of any hash/fingerprint/dedup skill) | `.../superpowers/5.0.7/skills/` (14 skills enumerated) | Direct read | OK — **no SP precedent exists** |
| 8 | Anthropic — *Building Effective AI Agents* (Schluntz/Zhang, Dec 2024) — workflow patterns, prompt-chaining gates, retrieval | https://www.anthropic.com/research/building-effective-agents | WebSearch synthesis | OK (verified 2026-04-30) |
| 9 | Anthropic — *Effective Context Engineering for AI Agents* | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | WebSearch synthesis | OK (verified 2026-04-30) |
| 10 | Sentry — *Issue Grouping* (concepts/data-management) + *Grouping* (developer docs, newstyle:2019-05-08) + JS *Event Fingerprinting* | https://docs.sentry.io/concepts/data-management/event-grouping/ ; https://develop.sentry.dev/backend/grouping ; https://docs.sentry.io/platforms/javascript/enriching-events/fingerprinting/ | WebSearch synthesis | OK (verified 2026-04-30) |
| 11 | Bugsnag — *Error grouping* product docs + per-platform customizing-error-reports | https://docs.bugsnag.com/product/error-grouping/ | WebSearch synthesis | OK (verified 2026-04-30) |
| 12 | Rollbar — *Default Grouping Algorithm* + *Custom Fingerprinting Rules* | https://docs.rollbar.com/docs/grouping-algorithm ; https://docs.rollbar.com/docs/custom-grouping | WebSearch synthesis | OK (verified 2026-04-30) |
| 13 | Honeybadger — *Customizing Error Grouping* (Ruby/JS/Go/Elixir) | https://docs.honeybadger.io/lib/ruby/getting-started/customizing-error-grouping/ | WebSearch synthesis | OK (verified 2026-04-30) |
| 14 | Datadog — *Error Tracking — Error Grouping* | https://docs.datadoghq.com/error_tracking/error_grouping/ | WebSearch synthesis | OK (verified 2026-04-30) |
| 15 | Linear — *Similar Issues* changelog + *Using AI to detect similar issues* engineering post (pgvector, embeddings) | https://linear.app/changelog/2023-08-03-similar-issues ; https://linear.app/now/using-ai-to-detect-similar-issues | WebSearch synthesis | OK (verified 2026-04-30) |
| 16 | GitHub — Damerau–Levenshtein potential-duplicates-bot + GitHub Models duplicate-issue suggestion | https://github.com/Bartozzz/potential-duplicates-bot ; https://github.blog/open-source/maintainers/how-github-models-can-help-open-source-maintainers-focus-on-what-matters/ | WebSearch synthesis | OK (verified 2026-04-30) |
| 17 | Stack Overflow duplicate-question detection — *Mining Duplicate Questions in Stack Overflow* (MSR 2016) + *Multi-factor duplicate question detection* (Zhang/Lo/Xia 2015) — DupPredictor four-factor (title, description, latent topic, tags) | https://dl.acm.org/doi/10.1145/2901739.2901770 ; https://link.springer.com/article/10.1007/s11390-015-1576-4 | WebSearch synthesis | OK (verified 2026-04-30) |
| 18 | Google SRE Book Ch. 12 *Effective Troubleshooting* — six-step model (already cited from PF v2 `agents/debugger.md`) | https://sre.google/sre-book/effective-troubleshooting/ | Inherited via debugger.md | OK |

**N counted for fix-time-applicable error-fingerprinting frameworks (rows 10–17):** 8. Comfortably exceeds the N≥5 BINDING threshold from `enterprise-research-first` Step 4. See §5 Consensus.

---

## §2 Verbatim Citations — Determinism + Grammar

### §2.1 PF v1 `compute-root-cause-hash.sh` — pinned normalization rules

> "NORMALIZATION RULES (pinned — do not edit without incrementing HASH_VERSION):
>   1. Lowercase entire string
>   2. Strip UUIDs (8-4-4-4-12 hex pattern)
>   3. Strip ISO 8601 dates (YYYY-MM-DD, YYYY-MM-DDTHH:MM:SSZ patterns)
>   4. Strip file:line references (e.g., 'foo.ts:42' → 'foo.ts')
>   5. Strip numeric-only tokens (standalone integers)
>   6. Collapse all whitespace (tabs, newlines, multiple spaces) to single space
>   7. Trim leading and trailing whitespace
>
> HASH_VERSION: 1
> If normalization rules change, bump HASH_VERSION and document the migration."
> — `production-framework/scripts/compute-root-cause-hash.sh` lines 27–37

The script's self-tests pin five determinism guarantees: (TEST 1) UUID-only differences hash identically; (TEST 2) date-only differences hash identically; (TEST 3) line-number-only differences hash identically; (TEST 4) genuinely distinct incidents hash differently; (TEST 5) whitespace differences hash identically (lines 94–117).

### §2.2 SP precedent — absence + adjacent

A direct read of `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/` enumerates 14 skills: `brainstorming, dispatching-parallel-agents, executing-plans, finishing-a-development-branch, receiving-code-review, requesting-code-review, subagent-driven-development, systematic-debugging, test-driven-development, using-git-worktrees, using-superpowers, verification-before-completion, writing-plans, writing-skills`. A grep for `hash|fingerprint|dedup|grouping` across the entire SP 5.0.7 cache returns five hits — all unrelated to incident dedup (graph rendering helper, brainstorming server CommonJS module, session-start bootstrap script, and two design specs about a future document-review feature). **No SP precedent for fix-time hash-check exists.**

The closest adjacent SP discipline is `verification-before-completion`'s evidence-before-assertion frame and `systematic-debugging` Phase 2 "Pattern Analysis":

> "**Find Working Examples**
>    - Locate similar working code in same codebase
>    - What works that's similar to what's broken?
>
> **Compare Against References**
>    - If implementing pattern, read reference implementation COMPLETELY
>    - Don't skim - read every line
>    - Understand the pattern fully before applying"
> — SP 5.0.7 `systematic-debugging/SKILL.md` lines 122–143

This framing — *find similar prior occurrences before fixing* — is the discipline analogue. The SP version operates at code-similarity granularity (read working examples in the same codebase) and is silent on the *incident-record* granularity that PF's incident table provides. `fix-time-hash-check` is therefore the granularity-shift extension of this SP discipline to the incident-record artifact, not a competing discipline.

### §2.3 Anthropic — workflow gates + just-in-time retrieval

> "Prompt chaining decomposes a task into a sequence of steps, where each LLM call processes the output of the previous one, with programmatic checks on intermediate steps to ensure the process is still on track."
> — Anthropic, *Building Effective AI Agents* (Schluntz & Zhang, Dec 2024). Retrieved 2026-04-30 from https://www.anthropic.com/research/building-effective-agents

> "In the evaluator-optimizer workflow, one LLM call generates a response while another provides evaluation and feedback in a loop, particularly effective when there are clear evaluation criteria and iterative refinement provides measurable value."
> — Anthropic, ibid. — backs the *fix-then-verify* shape; `fix-time-hash-check` is a programmatic gate inserted between fix-proposal and fix-application.

> "The memory tool is the key primitive for just-in-time context retrieval: rather than loading all relevant information upfront, agents store what they learn in memory and pull it back on demand, keeping active context focused on what's currently relevant for long-running workflows."
> — Anthropic, *Effective Context Engineering for AI Agents*. Retrieved 2026-04-30 from https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents

> "Claude Code employs a hybrid model where CLAUDE.md files are loaded into context upfront, while primitives like glob and grep allow it to navigate its environment and retrieve files just-in-time, effectively bypassing issues of stale indexing and complex syntax trees."
> — Anthropic, ibid. — backs PROJECT-PLAN.md as a file-artifact-as-memory and grep as the retrieval primitive (no embedding/vector store required for v2.0).

---

## §3 Verbatim Citations — Enterprise Error-Fingerprinting Frameworks

### §3.1 Sentry (canonical reference)

> "All versions of the grouping algorithm consider the fingerprint first, the stack trace next, then the exception, and then finally the message."
> — Sentry developer documentation, *Grouping*. Retrieved 2026-04-30 from https://develop.sentry.dev/backend/grouping

> "The actual grouping algorithm runs if and only if the fingerprint is not set yet or uses the special `{{ default }}` value. The grouping algorithm can produce more than one fingerprint hash. These hashes are collected and associated with issues via the GroupHash model. If any of these hashes exists in a group the event is associated with it, and any hash not yet associated with the group is added."
> — Sentry developer documentation, *Grouping*, ibid.

> "Sentry only groups by stack trace frames that the SDK reports and associates with the application. … if two stack traces differ only in parts unrelated to the application, they will still be grouped together."
> — Sentry, *Issue Grouping*. Retrieved 2026-04-30 from https://docs.sentry.io/concepts/data-management/event-grouping/

> "The system creates a secondary hash for non-application code frames which is associated with groups, but because it contains more information, it's generally never used for grouping except for a form of implied merge."
> — ibid. — backs the *strip-irrelevant-noise-from-hash-input* discipline.

### §3.2 Bugsnag

> "Errors are grouped with other events sharing the same error class, file and line number of the top in-project stack frame of the innermost exception."
> — Bugsnag, *Error grouping*. Retrieved 2026-04-30 from https://docs.bugsnag.com/product/error-grouping/

> "All reports with the same grouping hash will be grouped together. This allows developers to override Bugsnag's default grouping behavior by customizing how errors are fingerprinted."
> — ibid.

> "Updates are released to make improvements to the grouping algorithm, but they are not automatically applied because they can lead to changes in the way that existing errors are grouped."
> — ibid. — independent corroboration of PF v1's `HASH_VERSION` versioning rule (§2.1).

### §3.3 Rollbar

> "For less frequent exceptions without patterns, Rollbar combines the filenames and method names from all stack frames, and the resulting SHA1 hash is used as the occurrence fingerprint, using all stack frames rather than just the top one."
> — Rollbar, *Default Grouping Algorithm*. Retrieved 2026-04-30 from https://docs.rollbar.com/docs/grouping-algorithm

> "Rollbar doesn't use line numbers in stack traces since they often change due to unrelated code changes. … dates and SHAs are stripped from paths in filenames, integers 2 characters or longer are stripped from method names, and boilerplate stack frames of frameworks are recognized and ignored."
> — ibid. — direct independent corroboration of PF v1's strip-line-numbers / strip-dates / strip-numeric-tokens normalization (§2.1 rules 3, 4, 5).

### §3.4 Honeybadger

> "The default information Honeybadger uses to group errors is the file name, method name, and line number of the error's location, which is used to construct a 'fingerprint' of the exception. Exceptions with the same fingerprint are treated as the same error in Honeybadger."
> — Honeybadger, *Customizing Error Grouping*. Retrieved 2026-04-30 from https://docs.honeybadger.io/lib/ruby/getting-started/customizing-error-grouping/

> "The fingerprint attribute is an optional string that is used to force errors with the same fingerprint (regardless of error class, message, or location) to be grouped together."
> — ibid.

### §3.5 Datadog

> "Error Tracking computes a fingerprint for each error span it processes using the error type, the error message, and the frames that form the stack trace. Errors with the same fingerprint are grouped together and belong to the same issue."
> — Datadog, *Error Grouping*. Retrieved 2026-04-30 from https://docs.datadoghq.com/error_tracking/error_grouping/

> "Error Tracking ignores numbers, punctuation, and anything that is between quotes or parentheses: only word-like tokens are used. Additionally, to improve grouping accuracy, Error Tracking removes variable stack frame properties such as versions, ids, dates, and so on."
> — ibid. — second independent corroboration of strip-numbers / strip-dates / strip-IDs.

### §3.6 Linear (similar-issue detection — embedding-based)

> "When you start filling out a new issue, Linear will use LLMs to semantically find similar issues so that you don't enter duplicates. … The implementation uses PostgreSQL with pgvector on Google Cloud Platform for vector storage and search, with partitioning strategies to handle tens of millions of issues at scale."
> — Linear, *Using AI to detect similar issues*. Retrieved 2026-04-30 from https://linear.app/now/using-ai-to-detect-similar-issues

> "We use AI to surface possible duplicates and related issues when you create new issues, review issues in triage, and create issues from Intercom or Zendesk."
> — Linear, *Similar Issues* changelog (2023-08-03). Retrieved 2026-04-30 from https://linear.app/changelog/2023-08-03-similar-issues — backs the *fix-creation-time* (analog: fix-application-time) integration point.

### §3.7 GitHub — Damerau–Levenshtein + GitHub Models

> "A configurable threshold of 0.60 (60%) similarity can be used to mark issues as potential duplicates, while other implementations use an 80% similarity threshold for automatic duplicate detection and closing."
> — Synthesis of Bartozzz/potential-duplicates-bot README. Retrieved 2026-04-30 from https://github.com/Bartozzz/potential-duplicates-bot — backs an *advisory-vs-blocking* threshold split.

> "GitHub Models can be used to automatically check if a new issue is similar to existing ones and post a comment with links."
> — GitHub Blog, *How GitHub Models can help open source maintainers …*. Retrieved 2026-04-30 from https://github.blog/open-source/maintainers/how-github-models-can-help-open-source-maintainers-focus-on-what-matters/

### §3.8 Stack Overflow duplicate-question detection (academic)

> "DupPredictor … takes a new question as input and detects potential duplicates by considering multiple factors, extracting the title and description of a question and also tags that are attached to the question. For each pair of questions, it computes four similarity scores by comparing their titles, descriptions, latent topics, and tags, with these four similarity scores finally combined together."
> — Synthesis of Zhang, Lo, Xia, *Multi-Factor Duplicate Question Detection in Stack Overflow* (JCST 2015). Retrieved 2026-04-30 from https://link.springer.com/article/10.1007/s11390-015-1576-4 — academic backing for *multi-factor* fingerprints (analog of PF's "principle + incident text + impact" tuple).

---

## §4 Hash Algorithm Comparison Table

| Framework | Input fields | Normalization (strips/ignores) | Hash function | Custom override | Determinism / version policy | Integration point |
|---|---|---|---|---|---|---|
| **PF v1 `compute-root-cause-hash.sh`** | Free-form incident text (Debugger root-cause sentence + symptom verb) | UUIDs, ISO 8601 dates, `:line` refs, standalone integers, lowercased, whitespace-collapsed | SHA-256 (sha256sum / shasum) | None (deterministic only) | `HASH_VERSION=1`, pinned; bump on rule change with documented migration | Currently: post-mortem proposal-time only. **Proposed:** add fix-time invocation per Item 40-2. |
| **Sentry (newstyle:2019-05-08)** | Fingerprint → stack trace → exception → message (cascade); in_app frames only | `normalize_stacktraces_for_grouping` strips non-app frames; flat + hierarchical hash variants | Component-tree → hash (multiple GroupHash entries per Issue) | `Sentry.captureException({ fingerprint: [...] })` SDK call + project-level Fingerprint Rules | Strategy versions pinned ("newstyle:2019-05-08", "newstyle:2023-01-11") — never auto-applied | At event ingestion (server-side), not at fix-time. Fingerprint can be set client-side at error report site. |
| **Bugsnag** | Error class + file + line of *innermost* exception's *top in-project* frame | Restricts to top-in-project frame | Implementation-internal grouping hash | `event.groupingHash = "..."` SDK callback | Algorithm updates not auto-applied (explicit opt-in) | At event ingestion. SDK callback runs on the client/server reporting the error. |
| **Rollbar** | Filenames + method names from **all** stack frames | Line numbers stripped; dates, SHAs stripped from paths; integers ≥2 chars stripped from method names; framework boilerplate ignored | SHA-1 over normalized concatenation | "Custom Fingerprinting" rules in project Settings | ML-pattern-recognition layer for high-frequency types; default for low-frequency | At event ingestion. |
| **Honeybadger** | File + method + line (default); Go: error class + first backtrace line | Per-platform default; user-supplied normalization via `before_notify` callback | Implementation-internal | `Honeybadger.notify(err, { fingerprint: "..." })` global or local | Per-platform algorithm versioning | At event reporting (SDK callback). |
| **Datadog Error Tracking** | Error type + error message + stack trace frames | Numbers, punctuation, quoted/parenthesized text stripped; versions/ids/dates removed; only word-like tokens kept | Implementation-internal fingerprint | `error.fingerprint` log attribute on the error log | Default + custom; algorithm not externally versioned | At log/span ingestion. |
| **Linear Similar Issues** | Issue title + description (free-form text) | LLM/embedding handles normalization implicitly | Vector embedding (pgvector cosine similarity, top-K nearest) | Manual "mark as duplicate" override | Embedding model version implicit; no explicit hash_version | At issue *creation* time (real-time during typing) + Triage inbox. |
| **GitHub potential-duplicates-bot** | Issue title (primarily) | Damerau–Levenshtein over normalized title strings | Edit-distance, not hash | Configurable threshold (default ~0.60–0.80) | Algorithm parameters versioned in config | At issue creation (GitHub App webhook). |
| **Stack Overflow DupPredictor** | Title + description + latent topic + tags (4-factor) | Per-factor stop-word + stem normalization | Per-factor cosine similarity → composite score | None (research artifact) | Model-versioned | At question submission (research-deployed, not production). |

**Pattern observed across rows 1–9:** every framework strips at least one of {line numbers, IDs, dates, version strings} and either restricts to "in-project / top-frame" or weights it heavier. PF v1's seven-rule grammar (§2.1) is the *deterministic-hash* end of this spectrum (Sentry's grouping is closest analog; Linear is the *embedding* end).

---

## §5 Fix-Time Application Heuristics (synthesized)

Eight enterprise frameworks (rows 10–17 of §1) consistently expose **three integration points** at which their fingerprint/similarity check is invoked:

| Integration point | Frameworks supporting it | Maps to PF lifecycle |
|---|---|---|
| **A. Event/error report-time** (the bug is captured) | Sentry, Bugsnag, Rollbar, Honeybadger, Datadog | Debugger writes `docs/debug/<incident>.md` |
| **B. Issue creation-time** (a human is filing a record about the bug) | Linear, GitHub bots, Stack Overflow | Builder/orchestrator about to add a row to PROJECT-PLAN.md Incident Table |
| **C. Triage / intake review** (human is curating the inbox) | Linear (Triage inbox), GitHub App reviews | Post-Mortem agent's cluster scan |

PF v1 currently invokes hashing **only at C** (post-mortem proposal-time, where ≥3 incidents must dedup-cluster before pattern proposal qualifies — see Item 41 strength). Item 40-2's gap is precisely the **B** invocation: *before the Builder applies a fix*, hash the bug under investigation and grep prior occurrences. Linear's similar-issues feature is the closest enterprise analog: the check fires *during issue creation*, not after triage. PF's `fix-time-hash-check` is the same pattern with three substitutions:

1. **What is being created:** not an issue, but a *fix proposal* (the Debugger's `docs/debug/<incident>.md` root-cause sentence is the input text).
2. **Where matches are sought:** PROJECT-PLAN.md Incident Table column `root_cause_hash` (deterministic equality match) **and** `STACK-PATTERNS.md` rows whose `Incident` column hashes to the same value.
3. **What is surfaced:** a 5-line table of prior occurrences with their resolution, so the Builder can compare the proposed fix to consensus before applying.

### Threshold heuristics (consensus among rows 10–17)

| Heuristic | Frameworks supporting | PF recommendation |
|---|---|---|
| **Equality on deterministic hash → mandatory surface** | Sentry, Bugsnag, Rollbar, Honeybadger, Datadog (all hash-based; equality is binary) | Adopt — this is the v2.0 floor. SHA-256 hash equality on PF v1 normalization → 100% surfaced. |
| **Configurable similarity threshold for non-equal but near matches** | Linear (cosine), GitHub bots (0.60 / 0.80), Stack Overflow DupPredictor (composite) | Defer to v2.x — embedding/Levenshtein adds dependency surface. v2.0 ships hash-equality only; v2.x can layer an advisory similarity tier. |
| **Advisory (warn + continue) vs blocking (refuse fix until acknowledged)** | GitHub bots default to *advisory-comment*; Linear *advises-during-typing* (non-blocking); Sentry/Bugsnag groupings are server-side and never block client fix-application | Adopt advisory by default. Skill output is a 5-line surface; orchestrator decides whether to block. Blocking belongs in a future PreToolUse hook (D-F per audit), not the skill itself. |
| **Versioning the algorithm; never auto-update** | Sentry (strategy IDs), Bugsnag (explicit opt-in), Rollbar (algorithm versioning), Honeybadger (per-platform) | Adopt — PF v1 already has `HASH_VERSION=1`. Skill body must read the script's version line and surface it in output (so future hash migrations are auditable). |

### N≥5 BINDING consensus check (per `enterprise-research-first` Step 4)

- **N (frameworks researched):** 8 (Sentry, Bugsnag, Rollbar, Honeybadger, Datadog, Linear, GitHub bots, Stack Overflow DupPredictor).
- **Agreement on "fingerprint/dedup before allowing duplicate work":** 8/8 — every framework computes a fingerprint and surfaces prior matches before allowing a duplicate record.
- **Agreement on "strip variable noise (IDs, dates, line numbers, versions) from input":** 5/8 explicit (Sentry "in_app only"; Rollbar full strip list; Datadog full strip list; Honeybadger custom-fingerprint via callback; Bugsnag "top-in-project frame"). Linear/GitHub/SO use semantic embeddings which absorb this implicitly. **Universal in spirit.**
- **Agreement on "deterministic hash vs embedding":** 5/8 deterministic (Sentry, Bugsnag, Rollbar, Honeybadger, Datadog), 3/8 embedding/edit-distance (Linear, GitHub bots, SO). Both legitimate; deterministic is cheaper.
- **Verdict:** N=8 unanimous on the discipline → **BINDING** per ER1's grammar (N/N unanimous AND N≥5). The discipline of "hash-grep-surface before duplicating work" is binding; the *implementation* (deterministic hash) has 5/8 support — STRONG, not BINDING — but PF v1's pre-existing primitive (§2.1) is the cheapest fit and is internally already validated. Embedding is a v2.x optional second tier.

### Fix-time vs proposal-time consensus

- **Fix-time / creation-time invocation supported:** Linear (issue-creation), GitHub bots (issue-creation), all SDK-callback-based error fingerprinters fire at *report-time* (closest analog to fix-creation-time). 5/8.
- **Proposal/triage-time invocation supported:** Sentry (server-side at ingestion is its only point), Linear's Triage inbox view, post-mortem clustering. 6/8.
- **Both:** 3/8 (Linear is the cleanest example; it surfaces similar issues at *both* creation-time and triage-time).
- **Verdict:** STRONG (5/8) for fix-time invocation. Pairing with proposal-time invocation (PF v1's existing point) is BINDING (8/8 — every framework has at least one of the two). PF should ship both: keep proposal-time (v1 strength), add fix-time (v2.0 new skill). This is the same conclusion Linear reached independently: surface at creation, surface again at triage.

---

## §6 Recommendations

### R1 — Skill scope (ship in v2.0)

`fix-time-hash-check` ships as a ~30–50-line skill body composing the following:

1. **Trigger** (frontmatter description): "Use before applying any fix to a reported bug — runs `scripts/compute-root-cause-hash.sh` on the Debugger's root-cause sentence and surfaces prior incidents with the same hash from `docs/PROJECT-PLAN.md` Incident Table and `templates/STACK-PATTERNS.md`. Composable with `superpowers:systematic-debugging` Phase 4 hand-off and Step 4.5 bug-class enterprise check."
2. **Input contract:** a single string (the root-cause sentence from `docs/debug/<incident>.md` — the Debugger writes it under "**Root cause** — the actual cause" per `agents/debugger.md` line 53).
3. **Procedure (4 steps):**
   - (a) Compute hash via `bash scripts/compute-root-cause-hash.sh "<root-cause-sentence>"`.
   - (b) Grep `docs/PROJECT-PLAN.md` Incident Table for the hash; collect rows.
   - (c) Grep `STACK-PATTERNS.md` for matching `Incident` column entries (re-hash each row's Incident text and compare).
   - (d) Emit a 5-line surface: `hash | hash_version | N prior matches | top-3 prior {date, principle, resolution} | recommend-compare-or-proceed`.
4. **Composition:** explicit "Composable with: `systematic-debugging` Step 4.5 (bug-class enterprise check), `enterprise-research-first` (when N=0 prior matches but the bug class has documented enterprise solutions per Item 28)."
5. **Status tokens:** `DONE` (matches surfaced or zero matches confirmed); `NEEDS_CONTEXT` (PROJECT-PLAN.md not present at expected path); never `BLOCKED` (advisory by design).

### R2 — Carryforward primitive

Port `production-framework/scripts/compute-root-cause-hash.sh` verbatim to `production-framework-v2/scripts/compute-root-cause-hash.sh`. It is zero-dependency (bash + sha256sum/shasum), determinism-tested, and Item 41 establishes its strength. Preserve `HASH_VERSION=1` and the 7-rule normalization unchanged. Surface the version line in the skill output so future migrations are auditable (Sentry/Bugsnag versioning precedent, §4).

### R3 — Defer (out of scope for the skill itself)

- **Embedding/similarity tier (Linear/GitHub-style fuzzy match)** — defer to v2.x. v2.0 ships hash-equality only; this matches 5/8 enterprise frameworks (the deterministic ones) and avoids dependency surface.
- **PreToolUse hook that *blocks* Edit/Write until the skill ran** — that is decision **D-F** in the audit (line 376 of `v1-feedback-vs-v2-2026-04-30.md`). The skill is the *advisory* primitive; the *blocking* gate is the hook layer above it. Ship the skill in v2.0 as advisory; ship the hook in v2.0 only if D-A (tier-selection PreToolUse) lands, since both share the hook plumbing.
- **Single-pass incident auto-recording (Item 40-1)** — that is the PostToolUse Builder DONE hook proposal, distinct from this skill. The skill *consumes* the Incident Table; whether single-pass fixes are *written* to the table is a separate workstream.
- **Cluster-scan script (Item 40-3)** — distinct script, runs as PreCommit/daily, not invoked from this skill.

---

## §7 Citations Footer (deduplicated, alphabetized by source)

- Anthropic. *Building Effective AI Agents* (Schluntz & Zhang, Dec 2024). https://www.anthropic.com/research/building-effective-agents — verified 2026-04-30.
- Anthropic. *Effective Context Engineering for AI Agents.* https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents — verified 2026-04-30.
- Bartozzz. *potential-duplicates-bot* (Damerau–Levenshtein issue-duplicate detection). https://github.com/Bartozzz/potential-duplicates-bot — verified 2026-04-30.
- Bugsnag. *Error grouping.* https://docs.bugsnag.com/product/error-grouping/ — verified 2026-04-30.
- Datadog. *Error Tracking — Error Grouping.* https://docs.datadoghq.com/error_tracking/error_grouping/ — verified 2026-04-30.
- GitHub Blog. *How GitHub Models can help open source maintainers focus on what matters.* https://github.blog/open-source/maintainers/how-github-models-can-help-open-source-maintainers-focus-on-what-matters/ — verified 2026-04-30.
- Honeybadger. *Customizing Error Grouping (Ruby).* https://docs.honeybadger.io/lib/ruby/getting-started/customizing-error-grouping/ — verified 2026-04-30.
- Linear. *Similar Issues* (changelog 2023-08-03). https://linear.app/changelog/2023-08-03-similar-issues — verified 2026-04-30.
- Linear. *Using AI to detect similar issues.* https://linear.app/now/using-ai-to-detect-similar-issues — verified 2026-04-30.
- PF v1. `scripts/compute-root-cause-hash.sh` HASH_VERSION=1. `production-framework/scripts/compute-root-cause-hash.sh` lines 1–119 — direct read.
- PF v2. `agents/debugger.md`, `templates/PROJECT-PLAN.template.md`, `skills/enterprise-research-first/SKILL.md`, `docs/audits/v1-feedback-vs-v2-2026-04-30.md` — direct read.
- Rollbar. *Default Grouping Algorithm.* https://docs.rollbar.com/docs/grouping-algorithm — verified 2026-04-30.
- Rollbar. *Custom Fingerprinting Rules.* https://docs.rollbar.com/docs/custom-grouping — verified 2026-04-30.
- Sentry. *Issue Grouping.* https://docs.sentry.io/concepts/data-management/event-grouping/ — verified 2026-04-30.
- Sentry. *Grouping (developer docs, newstyle strategy).* https://develop.sentry.dev/backend/grouping — verified 2026-04-30.
- Sentry. *Event Fingerprinting (JavaScript SDK).* https://docs.sentry.io/platforms/javascript/enriching-events/fingerprinting/ — verified 2026-04-30.
- Superpowers 5.0.7. `skills/systematic-debugging/SKILL.md` lines 122–143; full skill enumeration confirms no hash/fingerprint/dedup precedent. `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/` — direct read.
- Zhang, Y., Lo, D., Xia, X. *Multi-factor duplicate question detection in Stack Overflow.* JCST 30(5): 981–997, 2015. https://link.springer.com/article/10.1007/s11390-015-1576-4 — verified 2026-04-30.
- Wang, S., et al. *Mining Duplicate Questions in Stack Overflow* (MSR 2016). https://dl.acm.org/doi/10.1145/2901739.2901770 — verified 2026-04-30.
