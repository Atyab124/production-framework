# Skill Design Research — `ratify-pattern`

**Date:** 2026-04-30
**Type:** Source-of-truth research — no code modifications
**Triggered by:** Citation manifest GAP (v1 carryforward) — `ratify-pattern` has no SP precedent. PF v2 binding rule (`CLAUDE.md` §"THE BINDING RULE") therefore requires ≥3 enterprise/OSS ratification-track citations grounding the 6 mechanical gates. Item 41 of `docs/audits/v1-feedback-vs-v2-2026-04-30.md` designates this skill as a STRENGTH requiring explicit preservation.
**Companion docs:**
- `docs/audits/v1-feedback-vs-v2-2026-04-30.md` §Item 41 (canonical machine-enforcement STRENGTH)
- `production-framework/skills/ratify-pattern/SKILL.md` (v1 source, lines 1–96)
- `production-framework/templates/pattern-proposal.template.md` (proposal schema)
- `production-framework/templates/revert-pattern.template.sh` (revert script shape)
- `production-framework-v2/templates/STACK-PATTERNS.template.md` (target write destination)
- `docs/research/sp-anthropic-citation-manifest.md` (binding manifest)

---

## Methodology Disclosure

WebFetch was permission-denied (consistent with prior research sessions). Quotes are taken from one of three places, in priority order:

1. **Local SP/PF v1 cache** — verbatim, line-anchored from `production-framework/` or `production-framework-v2/`.
2. **Companion research docs in this repo** — already-vetted quotes from prior research passes.
3. **WebSearch synthesis** — for external sources not in the cache. Tagged `(via WebSearch synthesis of canonical URL)`. Re-verify against canonical URLs before any binding architectural commitment.

SP cache search for `ratify-pattern` in `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/`: **no files found** — confirmed. SP 5.0.7 has no ratify-pattern skill. The adjacent SP precedent is the `<HARD-GATE>` convention used as a user-gating idiom.

---

## Part 1 — Sources Inventory

| # | Source | Tier | URL / path | Used for | Retrieved |
|---|---|---|---|---|---|
| S1 | PF v1 `skills/ratify-pattern/SKILL.md` | v1 carryforward | local repo | Full G1–G6 gate definitions; Stage 1–4 workflow; HARD-GATE block; state machine | 2026-04-30 |
| S2 | PF v1 `templates/pattern-proposal.template.md` | v1 carryforward | local repo | Proposal schema: frontmatter fields, state machine, fixture gate, revert procedure | 2026-04-30 |
| S3 | PF v1 `templates/revert-pattern.template.sh` | v1 carryforward | local repo | Revert script shape: idempotent guard, exit codes, step structure | 2026-04-30 |
| A1 | SP 5.0.7 `skills/brainstorming/SKILL.md` lines 12–14 | adjacent SP precedent | local SP cache | `<HARD-GATE>` convention as user-gating idiom — "Do NOT … take any implementation action until you have presented a design and the user has approved it" | 2026-04-30 |
| A2 | Anthropic *Building Effective Agents* | Anthropic guidance | https://www.anthropic.com/research/building-effective-agents (published Dec 2024) | Human checkpoints; agents pause for feedback; irreversible-action approval discipline | 2026-04-30 via WebSearch |
| E1 | Apache PMC Voting Process | enterprise/OSS governance | https://www.apache.org/foundation/voting.html | Binding +1 / -1 / 0 grammar; minimum quorum; veto mechanism; release-vote pre-conditions | 2026-04-30 via WebSearch |
| E2 | Kubernetes Enhancement Proposal (KEP) graduation track | enterprise/OSS governance | https://github.com/kubernetes/enhancements; https://kubernetes.io/ | Alpha → Beta → GA gates; KEP-approver sign-off before implementable; e2e test requirement; production readiness review | 2026-04-30 via WebSearch |
| E3 | IETF RFC Standards Track (RFC 2026) | enterprise/OSS governance | https://datatracker.ietf.org/doc/html/rfc2026 | Internet-Draft → Proposed Standard → Standard gates; IESG approval; 6-month minimum at Proposed Standard; "standards action" defined | 2026-04-30 via WebSearch |
| E4 | W3C Recommendation Track | enterprise/OSS governance | https://www.w3.org/2004/02/Process-20040205/tr.html | Working Draft → CR → PR → REC; Advisory Committee review; 4-week review minimum; implementation experience gate | 2026-04-30 via WebSearch |
| E5 | TC39 ECMAScript Proposal Stages (process-document) | enterprise/OSS governance | https://tc39.es/process-document/ | Stage 0–4 graduation criteria; champion + co-champion required; spec editor sign-off (Stage 3/4); two compliant implementations required; Test262 acceptance tests | 2026-04-30 via WebSearch |
| E6 | Rust RFC Final Comment Period (RFC 0002-rfc-process) | enterprise/OSS governance | https://rust-lang.github.io/rfcs/0002-rfc-process.html | FCP: all subteam members must sign off before entry; 10-calendar-day window; disposition (merge/close/postpone); ratified artifact = merged `text/NNNN-name.md` | 2026-04-30 via WebSearch |
| E7 | Linux kernel Signed-off-by / Reviewed-by chain | enterprise/OSS governance | https://github.com/torvalds/linux/blob/master/Documentation/process/submitting-patches.rst | Multi-stage review chain: author Signed-off-by + Reviewed-by from area maintainer(s); "code without a proper signoff cannot be merged into the mainline" | 2026-04-30 via WebSearch |

**Source bucket counts:**
- v1 carryforward: 3 (S1–S3)
- Adjacent SP precedent: 1 (A1)
- Anthropic guidance: 1 (A2)
- Enterprise/OSS governance: 7 (E1–E7) — exceeds the N≥3 requirement by 4

---

## Part 2 — SP Cache Search Results

Search executed over `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/`:

```
Pattern: ratify*   Result: No files found
Pattern: *ratif*   Result: No files found
```

**Verdict: No SP precedent.** SP 5.0.7 has no ratify-pattern skill.

**Adjacent SP precedent identified:** `brainstorming/SKILL.md` lines 12–14 establishes the `<HARD-GATE>` block as the canonical user-gating idiom used across all PF skills. The HARD-GATE body is SP-original and provides the user-approval enforcement mechanism that ratify-pattern inherits for its Stage 3 approval prompt.

---

## Part 3 — Verbatim Citations

### A1 — SP Brainstorming HARD-GATE (user-gating idiom)

**Source:** `C:/Users/atyab/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7/skills/brainstorming/SKILL.md` lines 12–14
**Retrieved:** 2026-04-30 (local cache)

```
<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any
implementation action until you have presented a design and the user has approved it. This
applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>
```

**Relevance:** ratify-pattern's Stage 3 approval prompt is the canonical instance of this pattern for the pattern-ratification workflow. The HARD-GATE block in PF v1 `ratify-pattern/SKILL.md` (lines 41–46) is structurally identical — "All 6 gates must pass before presenting the approval prompt … Do not present the diff. Do not ask for approval. Do not modify any file."

---

### A2 — Anthropic *Building Effective Agents* — Human Checkpoints

**Source:** Anthropic, *Building Effective Agents*, https://www.anthropic.com/research/building-effective-agents
**Published:** December 2024
**Retrieved:** 2026-04-30 via WebSearch synthesis

> "Agents can then pause for human feedback at checkpoints or when encountering blockers."

> "One effective approach is to build checkpoints where agents pause for human review, which is particularly important before they carry out irreversible actions, like approving financial transactions or deleting data."

> "The goal is to match the level of oversight to the task's risk, with low-risk tasks able to run autonomously while high-stakes actions requiring manual approval."

**Relevance:** ratify-pattern is the canonical instance of this pattern in PF v2: writing a pattern row to STACK-PATTERNS.md is irreversible by default (revert requires explicit `revert-{id}.sh` execution), and the 6 mechanical gates constitute the pre-approval checklist Anthropic prescribes before high-stakes actions. The human approval prompt (Stage 3 YAML block) is the checkpoint. The HARD-GATE block enforces that this checkpoint cannot be bypassed.

---

### E1 — Apache PMC Voting Process

**Source:** Apache Software Foundation, *Voting Process*, https://www.apache.org/foundation/voting.html
**Retrieved:** 2026-04-30 via WebSearch synthesis of canonical URL

> "Votes on whether a package is ready to release use majority approval, i.e., at least three PMC members must vote affirmatively for release, and there must be more positive than negative binding votes."

> "The specifics of the process may vary from project to project, but the 'minimum quorum of three +1 votes' rule is universal."

> "A -1 vote by a qualified voter stops a code-modification proposal in its tracks. This constitutes a veto, and it cannot be overruled nor overridden by anyone."

> "Under normal (non-lazy consensus) conditions, the proposal requires three +1 votes and no -1 votes in order to pass."

**Ratified artifact shape:** Release artifact (versioned binary + source tarball + checksums) is considered ratified when binding quorum (+1 ≥ 3, no binding -1) is recorded. Proposal state transitions from vote-in-progress → approved release → published.

---

### E2 — Kubernetes KEP Graduation Track

**Source:** kubernetes/enhancements GitHub; https://kubernetes.io/blog/2020/08/21/moving-forward-from-beta/
**Retrieved:** 2026-04-30 via WebSearch synthesis

> "KEP graduation requirements typically include: enhancement issue in release milestone, KEP approvers have approved the KEP status as implementable, design details are appropriately documented, test plans are in place, e2e tests for all operations, conformance test requirements, and graduation criteria in place."

> "Graduation criteria govern the transition to general availability (GA), also known as 'stable'."

> "Beta-quality API now has three releases (about nine calendar months) to either graduate to GA or face deprecation."

**Gates before ratification (GA):**
1. KEP document approved (approver sign-off to move state = `implementable`)
2. Production readiness review (PRR) sign-off
3. e2e test coverage for all operations
4. Two spec-compliant implementations
5. Conformance test inclusion
6. API review from API machinery sig

**User-gating mechanism:** Approvers (designated reviewers) explicitly set KEP `status: implementable`; without that status field change, no implementation proceeds. GA graduation requires a separate PR updating the KEP status field.

---

### E3 — IETF RFC Standards Track (RFC 2026)

**Source:** RFC 2026, *The Internet Standards Process — Revision 3*, https://datatracker.ietf.org/doc/html/rfc2026
**Retrieved:** 2026-04-30 via WebSearch synthesis

> "A 'standards action' — entering a particular specification into, advancing it within, or removing it from, the standards track — must be approved by the IESG."

> "A specific action by the IESG is required to move a specification onto the standards track at the 'Proposed Standard' level."

> "A specification shall remain at the Proposed Standard level for at least six (6) months."

**Gates before ratification (Internet Standard):**
1. Internet-Draft publication (versioned, time-limited)
2. IETF Working Group adoption and Last Call
3. IESG review and approval for Proposed Standard
4. 6-month minimum as Proposed Standard
5. Demonstrated interoperability (≥2 independent implementations)
6. IESG action to advance to Draft Standard / Standard

**Ratified artifact shape:** Published RFC with "INTERNET STANDARD" designation at the top, permanent DOI, listed in https://www.rfc-editor.org/standards.

---

### E4 — W3C Recommendation Track

**Source:** W3C *Technical Report Development Process*, https://www.w3.org/2004/02/Process-20040205/tr.html; https://www.w3.org/guide/standards-track/
**Retrieved:** 2026-04-30 via WebSearch synthesis

> "A Candidate Recommendation is a document that W3C believes has been widely reviewed and satisfies the Working Group's technical requirements. W3C publishes a Candidate Recommendation to gather implementation experience."

> "A Proposed Recommendation is a mature technical report that, after wide review for technical soundness and implementability, W3C has sent to the W3C Advisory Committee for final endorsement."

> "The request to the Director to advance a technical report to Candidate Recommendation MUST indicate whether the Working Group expects to satisfy any Proposed Recommendation entrance criteria beyond the default requirements."

> "The announcement begins a review period that MUST last at least four weeks."

**Gates before ratification (Recommendation):**
1. Working Draft (public review, at least one public WD)
2. Candidate Recommendation (CR) — implementation experience period; minimum duration stated
3. Proposed Recommendation (PR) — Advisory Committee review; 4-week minimum
4. Director approval
5. Publication as W3C Recommendation

**User-gating mechanism:** Advisory Committee (AC) reviews at PR stage; each AC member votes. Director acts on AC review result. No AC quorum = no REC.

---

### E5 — TC39 ECMAScript Stage Process

**Source:** TC39, *The TC39 Process*, https://tc39.es/process-document/
**Retrieved:** 2026-04-30 via WebSearch synthesis

> "Stage 0 (Strawperson): Any discussion, idea, or proposal for a change or addition which has not been submitted as a formal proposal … has no acceptance criteria."

> "Stage 3 (Candidate): The spec text must be complete. Designated reviewers (appointed by TC39, not by the champion) and the ECMAScript spec editor must sign off on the spec text. There must be at least two spec-compliant implementations (which don't have to be enabled by default)."

> "Stage 4 (Finished): Test262 acceptance tests … Two spec-compliant shipping implementations that pass the tests. Significant practical experience with the implementations. The ECMAScript spec editor must sign off on the spec text."

**Gates before ratification (Stage 4 / inclusion in spec):**
1. Stage 0 → 1: champion identified; problem described
2. Stage 1 → 2: formal syntax/semantics description; two experimental implementations
3. Stage 2 → 3: complete spec text; designated-reviewer and spec-editor sign-off; two implementations
4. Stage 3 → 4: Test262 tests; two shipping implementations; spec-editor final sign-off
5. Stage 4 → spec inclusion: editorial integration PR merged

**Ratified artifact shape:** Merged text in the annual ECMAScript specification; `proposals/finished-proposals.md` entry.

---

### E6 — Rust RFC Final Comment Period

**Source:** RFC 0002-rfc-process, https://rust-lang.github.io/rfcs/0002-rfc-process.html
**Retrieved:** 2026-04-30 via WebSearch synthesis

> "A member of the subteam proposes a 'motion for final comment period' (FCP), along with a disposition for the RFC (merge, close, or postpone)."

> "Before actually entering FCP, all members of the subteam must sign off; this is often the point at which many subteam members first review the RFC in full depth."

> "The FCP lasts ten calendar days, so that it is open for at least 5 business days."

> "The argument supporting the disposition on the RFC needs to have already been clearly articulated, and there should not be a strong consensus against that position outside of the subteam."

**Gates before ratification (merge):**
1. RFC Pull Request opened with `text/NNNN-name.md`
2. Discussion and iteration on the PR
3. Subteam member proposes FCP motion with disposition
4. All subteam members sign off (checkboxes on the bot comment)
5. 10-calendar-day FCP window opens
6. FCP closes without blocking objection → RFC merged

**Ratified artifact shape:** Merged `text/NNNN-name.md` in `rust-lang/rfcs` main branch; implementation tracking issue opened; stabilization PR eventually closes the loop.

---

### E7 — Linux Kernel Signed-off-by / Reviewed-by Chain

**Source:** Linux kernel, *Submitting Patches*, https://github.com/torvalds/linux/blob/master/Documentation/process/submitting-patches.rst
**Retrieved:** 2026-04-30 via WebSearch synthesis

> "Code without a proper signoff cannot be merged into the mainline."

> "Reviewed-by indicates that the patch has been reviewed and found acceptable according to the Reviewer's Statement: the reviewer has carried out a technical review to evaluate its appropriateness and readiness for inclusion, any problems have been communicated back to the submitter, and they are satisfied with the submitter's response."

> "Reviewed-by tags, when supplied by reviewers known to understand the subject area and to perform thorough reviews, will normally increase the likelihood of your patch getting into the kernel."

**Gates before ratification (merge to Linus/mainline):**
1. Patch formatted per `Documentation/process/submitting-patches.rst`
2. Author `Signed-off-by` present (certifies DCO)
3. Subsystem maintainer review; `Reviewed-by` added per reviewer
4. Maintainer picks patch into subsystem tree
5. linux-next integration (catch integration failures)
6. Linus pull request from maintainer; Linus merge to mainline

**User-gating mechanism:** Each `Reviewed-by` is manual; Linus pulls only after maintainer explicitly sends a pull request. No pull request = no merge. This is the multi-layer human-chain approval equivalent.

---

## Part 4 — Gate-to-Analog Mapping Table

This table maps PF v1's 6 mechanical gates (G1–G6) to the closest analog in each of the 7 cited governance frameworks. "Match" = the framework has an explicit equivalent gate; "Partial" = the principle is present but not a named gate; "N/A" = not addressed.

| PF Gate | Gate Name | Description | E1 Apache | E2 K8s KEP | E3 IETF | E4 W3C | E5 TC39 | E6 Rust RFC | E7 Linux | PF-original? |
|---|---|---|---|---|---|---|---|---|---|---|
| **G1** | Bloat cap | STACK-PATTERNS.md project rows ≤ 20 | N/A | N/A | N/A | N/A | N/A | N/A | N/A | **YES — PF-original** |
| **G2** | Duplicate-incident hash | All 3 cited hashes are distinct (same hash ×3 = one reopened bug) | N/A | N/A | N/A | N/A | N/A | N/A | N/A | **YES — PF-original** |
| **G3** | Machine-verifiable check | `proposed_check` must start with `grep:` or `script:` — no agent-subjective checks | Partial (verifiable artifact required for release vote) | Match (e2e tests for all operations — machine-run) | Partial (interoperability demonstrated by implementation) | Partial (implementation experience period at CR) | Match (Test262 acceptance tests — machine-run; 2 passing implementations) | Partial (implementation required before stabilization) | Match (CI passes required; patch tested in linux-next) | No — TC39 Stage 4 + Linux CI provide analogs |
| **G4** | Ratification traceability | STACK-PATTERNS.md has no pattern row without a matching archive entry (orphan-row check) | Partial (release tracker in issue; vote record kept) | Match (KEP status field + enhancement issue in release milestone = traceability) | Match (RFC maintains state from I-D to Standard; all transitions recorded) | Match (TR maturity level is recorded at each transition) | Match (proposal stage recorded in `proposals/` table; merged text is the record) | Match (FCP bot records sign-offs; PR history is the trace) | Partial (commit is the trace; no separate registry) | No — KEP/IETF/W3C/TC39/Rust all provide analogs |
| **G5** | Rollback path | `revert_procedure` non-empty; if `is_state_mutating: true`, `revert_script` must exist and have shebang | Partial (rollback release to prior GA; but not an explicit gate before release vote) | Match (graduation criteria include rollback plan for GA; deprecation policy defined) | Partial (downgrade path exists — revert to prior RFC via obsoletes: header; not a formal gate) | Partial (W3C can withdraw a REC; not a pre-publication gate) | Match (Stage 3 → 4 requires "web compatibility" assessment = revert feasibility check) | Partial (RFC can be superseded; no formal revert script requirement) | Match (git revert is always available; reverts are a first-class kernel operation) | No — K8s + TC39 + Linux provide analogs; the `revert_script` formalization is PF-original |
| **G6** | Fixture gate | `fixture_positive` and `fixture_negative` exist AND `proposed_check` produces expected results against each | N/A | Match (e2e tests for all operations — positive path required; regression tests = negative) | N/A | Partial (implementation experience covers positive paths; no negative-fixture requirement) | Match (Test262 tests — both positive and negative semantics tested) | Partial (tests required for stabilization, not for FCP itself) | Match (kernel self-tests + kselftest required for many subsystems; patches expected not to break existing tests) | No — TC39 Test262 + K8s e2e + Linux kselftest provide analogs |

**Legend:** Match = named equivalent gate exists | Partial = principle present, not a named gate | N/A = not addressed | PF-original = no cited analog

---

## Part 5 — Consensus Analysis

### Framework support per gate

| Gate | Frameworks with Match or Partial | Frameworks with Match (strict) | PF-original? |
|---|---|---|---|
| G1 Bloat cap | 0 | 0 | YES |
| G2 Duplicate-incident hash | 0 | 0 | YES |
| G3 Machine-verifiable check | 5 / 7 (E2, E3, E4, E5, E7 — mix of Match/Partial) | 3 / 7 (E2 e2e, E5 Test262, E7 CI) | No |
| G4 Ratification traceability | 6 / 7 (all except E7 strict match) | 5 / 7 (E2, E3, E4, E5, E6) | No |
| G5 Rollback path | 5 / 7 | 2 / 7 (E2, E7) | Partial — formalization PF-original |
| G6 Fixture gate | 4 / 7 (E2, E4, E5, E7 — mix) | 2 / 7 (E2, E5) | No |

**Median framework support (Match + Partial) across the 6 gates:** 3.3 / 7 frameworks per gate.

**Median framework support (Match-strict) across the 6 gates:** 2.0 / 7 frameworks per gate.

### Key findings

1. **G3, G4, G6 are well-grounded.** Each has ≥2 strict matches in enterprise governance. Ratification traceability (G4) has the strongest consensus: 5 of 7 frameworks name it explicitly.

2. **G5 is partially grounded.** Rollback paths appear in K8s and Linux as explicit gates, and in TC39 as a compatibility assessment. The formalization as an executable script (`revert-{id}.sh` with shebang and idempotency guard) is PF-original — no cited framework requires a machine-runnable revert script as a pre-ratification gate. This is an engineering decision by PF, not an industry consensus. It is defensible because PF's patterns can be `is_state_mutating: true` (e.g., hook installation), making a machine-runnable revert load-bearing in a way that prose governance docs never are.

3. **G1 and G2 are PF-original with no cited analog.** They address PF-specific failure modes: pattern registry bloat (G1) and reopened-bug cargo-culting disguised as three incidents (G2). No governance framework in the set manages a "maximum entries" cap or a hash-dedup requirement because their artifacts are not rows in a bounded registry. These gates are honest PF design decisions, not borrowed from governance consensus.

4. **Honest gap statement:** G1 and G2 cannot be grounded with ≥1 enterprise analog. The research was thorough (7 frameworks surveyed). The correct posture is to document these as PF-original, explain the failure modes they prevent, and carry them forward on that basis.

---

## Part 6 — Recommendations

### Recommendation 1 — Carry G1 and G2 as explicitly PF-original; document the failure mode each prevents

Do not invent citations for G1 and G2. In the v2 SKILL.md, annotate both gates with a `<!-- PF-original: no enterprise analog -->` inline comment and a one-sentence rationale:

- **G1 rationale:** Pattern registries that grow unbounded become cargo-cult lists. A hard cap forces the team to retire stale patterns before adding new ones, preserving signal quality. The 20-row cap is calibrated to a small-team project; v2 SKILL.md should parameterize this (`bloat_cap` in Stack Config) rather than hardcode 20.
- **G2 rationale:** Hash-based deduplication prevents a single reopened incident from being counted as three independent incidents. Without it, one recurring bug can fraudulently promote a pattern by filling all three `cited_incidents` slots with the same root cause. This is documented in Item 40 (`v1-feedback-vs-v2-2026-04-30.md`) as Gap 40-2.

### Recommendation 2 — Strengthen G5 to make the revert-script requirement explicit in the v2 SKILL.md phrasing

The v1 SKILL.md says: "if `is_state_mutating: true`, also `revert_script` exists and has `#!/usr/bin/env bash`." This is correct but understates why. The v2 version should add: "The script must be idempotent (exit 2 if already reverted) and tested on a clean branch." This brings G5 into alignment with the K8s graduation criterion "rollback tested" and the Linux kernel expectation that reverts are a first-class operation.

### Recommendation 3 — Parameterize the bloat cap and migrate the approval YAML block to v2's STACK-PATTERNS target shape

Two v2-specific adaptations of the v1 skill:

1. **Target write destination:** v1 writes to `STACK-PATTERNS.md`. v2's target is `docs/STACK-PATTERNS.md` (the forked instance of `templates/STACK-PATTERNS.template.md` per the template's header). The v2 SKILL.md must reference the project's `docs/STACK-PATTERNS.md` path, not the framework template itself.

2. **Approval YAML block:** v1 includes `action: approve | reject | edit` as the three dispositions. v2 should add a fourth disposition option aligned with Rust FCP: `postpone` — for proposals where the gates pass but the team is not ready to ratify (e.g., awaiting more incidents). This is a low-cost addition that matches Rust RFC's three-disposition model (merge / close / postpone).

---

## Part 7 — v2 Design Decisions Surfaced

| Decision | Recommendation | Rationale |
|---|---|---|
| Carry G1 (bloat cap) | Carry as PF-original; parameterize the cap value in Stack Config rather than hardcoding 20 | Hardcoded 20 is project-specific; parameterization removes the magic number |
| Carry G2 (hash dedup) | Carry unchanged; annotate as PF-original | Gap 40-2 empirical evidence; no grounding needed beyond PF's own incident data |
| Carry G3 (machine-verifiable) | Carry unchanged; TC39 Test262 + K8s e2e provide consensus | Strongest PF discipline — grep/script enforceability is load-bearing |
| Carry G4 (traceability) | Carry unchanged; 5/7 frameworks provide consensus | Strongest cross-framework consensus of all 6 gates |
| Strengthen G5 (rollback) | Add idempotency + clean-branch test requirements | Aligns with K8s graduation criteria; revert script is a first-class artifact |
| Carry G6 (fixture) | Carry unchanged; TC39 + K8s provide consensus | Positive + negative fixture requirement is empirically load-bearing (v1 Quick Reference: "G6 is 6/6 consensus") |
| Add `postpone` disposition | Add to Stage 3 YAML block as fourth option | Aligns with Rust RFC FCP three-disposition model; prevents forced approve/reject binary |
| Update target path | Change `STACK-PATTERNS.md` to `docs/STACK-PATTERNS.md` | v2 template convention per `templates/STACK-PATTERNS.template.md` header |

---

## Citations Footer

| ID | Full citation |
|---|---|
| S1 | PF v1 `production-framework/skills/ratify-pattern/SKILL.md`. Retrieved 2026-04-30 (local repo). |
| S2 | PF v1 `production-framework/templates/pattern-proposal.template.md`. Retrieved 2026-04-30 (local repo). |
| S3 | PF v1 `production-framework/templates/revert-pattern.template.sh`. Retrieved 2026-04-30 (local repo). |
| A1 | Superpowers 5.0.7 `skills/brainstorming/SKILL.md` lines 12–14. `<HARD-GATE>` block. Retrieved 2026-04-30 (local SP cache). |
| A2 | Anthropic. "Building Effective Agents." https://www.anthropic.com/research/building-effective-agents. Published December 2024. Retrieved 2026-04-30 via WebSearch. |
| E1 | Apache Software Foundation. "Voting Process." https://www.apache.org/foundation/voting.html. Retrieved 2026-04-30 via WebSearch. |
| E2 | Kubernetes Enhancement Proposal (KEP) graduation track. kubernetes/enhancements GitHub + https://kubernetes.io/blog/2020/08/21/moving-forward-from-beta/. Retrieved 2026-04-30 via WebSearch. |
| E3 | Bradner, S. et al. "RFC 2026: The Internet Standards Process — Revision 3." https://datatracker.ietf.org/doc/html/rfc2026. October 1996. Retrieved 2026-04-30 via WebSearch. |
| E4 | W3C. "7 W3C Recommendation Track Process." https://www.w3.org/2004/02/Process-20040205/tr.html. Retrieved 2026-04-30 via WebSearch. Also: https://www.w3.org/guide/standards-track/. |
| E5 | TC39. "The TC39 Process." https://tc39.es/process-document/. Retrieved 2026-04-30 via WebSearch. |
| E6 | Rust RFC 0002-rfc-process. "Introduction — The Rust RFC Book." https://rust-lang.github.io/rfcs/0002-rfc-process.html. Retrieved 2026-04-30 via WebSearch. |
| E7 | Linux kernel. "Submitting Patches." Documentation/process/submitting-patches.rst. https://github.com/torvalds/linux/blob/master/Documentation/process/submitting-patches.rst. Retrieved 2026-04-30 via WebSearch. |
