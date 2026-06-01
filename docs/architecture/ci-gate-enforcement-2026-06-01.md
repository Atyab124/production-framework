# Architecture Recommendation — CI / Deploy-Time Gate Enforcement (F-V16)

**Cycle:** research (Tier 3) — RECOMMENDATION, not implementation. **Architect:** PF v2 sole Architect. **Date:** 2026-06-01.
**Closes the research phase of:** Open Finding **F-V16** (`docs/PROJECT-PLAN.md` line 93 — "No CI/deploy enforcement — gates live only in the chat session").
**Reads:** `docs/research/ci-gate-enforcement-2026-06-01.md` (the Researcher's 6-implementation survey), `skills/gate-3-production-check/SKILL.md` (the 18-dimension gate, +D19 = 19 rows), `CLAUDE.md` (THE BINDING RULE + zero-third-party-runtime-dependency), `docs/adr/002-hook-gating.md` (existing hook-gate architecture this composes with).
**Output contract:** `docs/architecture/ci-gate-enforcement-2026-06-01.md` (this file — the only path in `scope_write`).

> **Scope-write disclosure (read first).** This dispatch's `scope_write` is this single file. I therefore record the decision rationale **inline in MADR shape** (§10) rather than writing `docs/adr/018-*.md`. Ratifying ADR-018 is a deliberate, deferred action for the future Tier 3 **Build** cycle — see §11 Scope boundary. I did **not** retry-loop against the deny; the ADR write was never in scope and is correctly a build-cycle artifact.

---

## 1. Goal

Make `gate-3-production-check` persist past the chat session: a PR that violates a required gate-3 dimension (e.g. D5 no-SLO, D11 no-audit-log) is **blocked at the merge boundary**, and a gate-3 verdict that is **missing or stale** counts as failure — not as a silent pass.

---

## 2. File List (C4 Container + Component levels)

This is a recommendation; paths are the *proposed* shape for the future Build cycle, not files written now. New = N, Modified = M.

| File | N/M | Purpose | C4 level |
|---|---|---|---|
| `skills/gate-3-production-check/SKILL.md` | M | Add an "Output Artifact (machine-readable)" subsection: the in-session walk emits `docs/audits/gate-3-<feature>.json` **alongside** today's `.md`. The `.md` stays the human record; the `.json` is the machine verdict. | Component (existing skill, modified) |
| `docs/audits/gate-3-<feature>.json` | N (per-feature, runtime artifact) | The machine-readable verdict manifest — one record per dimension. Committed to the repo as part of the feature branch. Schema in §4. | Data artifact |
| `scripts/verify-gate-3.sh` | N | Pure-bash CI verifier. Reads the manifest(s) for the changed feature, applies the missing/stale/red rules, exits non-zero on any failure. No third-party runtime dependency. | Component (new, the verdict→stop converter) |
| `.github/workflows/gate-3.yml` (or stack-equivalent CI step) | N (template, project-side) | Calls `scripts/verify-gate-3.sh` in CI; surfaces a single named check (`gate-3`) on the head SHA. This is a **template shipped for downstream projects**, not a workflow on the framework's own repo (the framework has no production service — see §3 and CLAUDE.md Active Gates "Stack-conditional 0 of 10 active"). | Container (new deployable: a CI job) |
| `docs/onboarding-brownfield.md` / `docs/onboarding-greenfield.md` | M | Add the "wire `gate-3` as a required status check" step to project onboarding (the merge-block binding lives in the project's branch-protection config, not in the framework). | Docs |
| `docs/adr/018-ci-gate-enforcement.md` | N — **deferred to Build cycle** | MADR-ratified decision. NOT written now (out of `scope_write`); rationale captured inline in §10. | ADR |

---

## 3. Container / Component diagram

Two containers exist after this change. The chat session (where gate-3 already runs) **produces** the verdict; the CI job **enforces** it. This split is the single strongest finding in the research — see §10 driver 2 (consensus pattern 2, "produce verdict" ≠ "enforce verdict").

```
 CONTAINER A: Chat-time session (Claude Code / CTO)           CONTAINER B: CI runner (GitHub Actions / plain CI step)
 ┌──────────────────────────────────────────────┐            ┌──────────────────────────────────────────────────────┐
 │  gate-3-production-check SKILL (MODIFIED)      │            │  scripts/verify-gate-3.sh  (NEW component)             │
 │   walks 19 dimensions in-session              │            │   reads docs/audits/gate-3-<feature>.json             │
 │   ├─ writes docs/audits/gate-3-<f>.md  (today)│            │   checks: exists? all-required PASS/WAIVED?            │
 │   └─ writes docs/audits/gate-3-<f>.json (NEW) │            │           verified_at within freshness window?        │
 └───────────────────────┬───────────────────────┘            │           manifest commit == head commit?             │
                         │ commit on feature branch            │   exit 0 = pass ; exit !=0 = fail (fail-closed)       │
                         │ (manifest travels WITH the code)    └──────────────────────────┬───────────────────────────┘
                         ▼                                                                  │ surfaces as commit status / check-run
                  ┌─────────────┐   PR opened / updated   ┌──────────────────────────┐    │ named "gate-3" on head SHA
                  │ git remote  │ ──────────────────────▶ │ CI trigger (on: pull_request)│ ◀┘
                  └─────────────┘                          └─────────────┬────────────────┘
                                                                         ▼
                                              ┌─────────────────────────────────────────────┐
                                              │ MERGE BOUNDARY (branch protection — project) │
                                              │   "gate-3" is a REQUIRED status check        │
                                              │   failure OR never-reported  → merge blocked │  ← fail-closed lives HERE,
                                              └─────────────────────────────────────────────┘     not in the verifier
```

**Component inventory:**
- **Producer (modified):** `gate-3-production-check` skill — already exists, gains a JSON emitter. No new behavior in the walk; it serializes the verdict it already computes.
- **Verifier (new):** `scripts/verify-gate-3.sh` — the only genuinely new logic. Pure bash. Computes nothing about the feature; it only adjudicates the manifest against three rules (exists / fresh / all-required-green).
- **Binding (new, project-side config):** the merge-block is **branch protection**, declared in the downstream project's repo settings, not in framework code. Per research §6 consensus 2, the blocking must live at the enforcement boundary, separate from the verdict-producer.

---

## 4. Data Contracts — manifest schema sketch

`docs/audits/gate-3-<feature>.json`. No `jq` at write time (CLAUDE.md line 117: SP's `escape_for_json` bash-substitution approach is preserved). The schema mirrors SonarQube's `OK/ERROR` and Conftest's `--output json` (research §5 rows 3 & 5).

```jsonc
{
  "schema_version": 1,
  "feature": "<feature-slug>",          // matches docs/audits/gate-3-<feature>.md
  "generated_at": "2026-06-01T14:23:00Z", // ISO-8601 UTC; the freshness anchor
  "generated_for_commit": "9dc6686...",  // the HEAD sha at walk time — staleness anchor
  "tenancy_model": "single-tenant",      // drives which dimensions are legitimately WAIVED
  "overall": "PASS",                     // PASS only if every required dim is PASS or WAIVED-with-rationale
  "dimensions": [
    {
      "id": "D5",                        // matches the skill's dimension IDs (D1..D19)
      "title": "Burn-rate alerts wired",
      "status": "PASS",                  // enum: PASS | WAIVED | BLOCKED
      "evidence": "runbook.md#slo; alerts/burn.yaml (fast 2%/1h + slow 5%/6h)",
      "waiver_rationale": null,          // REQUIRED non-null string when status==WAIVED
      "control_ids": ["SRE-Workbook-Ch5"],
      "verified_at": "2026-06-01T14:21:00Z" // per-dimension freshness (Iron Law: fresh-in-session)
    }
    // ... one record per applicable dimension
  ]
}
```

**Per-dimension record shape (the contract the verifier reads):**

| Field | Type | Required | Verifier rule |
|---|---|---|---|
| `id` | string `D1..D19` | yes | Must cover every dimension in the required set (minus legitimately-waived). A missing required `id` → fail. |
| `status` | `PASS`\|`WAIVED`\|`BLOCKED` | yes | Any `BLOCKED` → fail. Any required `id` absent → fail (absence = failure, research §6 consensus 3). |
| `evidence` | string | yes when `PASS` | Empty/missing evidence on a `PASS` → fail (mirrors the skill's "✓ without evidence is dishonesty"). |
| `waiver_rationale` | string | yes when `WAIVED` | `WAIVED` with null/empty rationale → fail (the skill's drive-by-waiver rule, now machine-checked). |
| `verified_at` | ISO-8601 UTC | yes | Drives the per-dimension freshness check. |

**Freshness / staleness rule (the F-V16 "stale" requirement):**

A manifest is **stale** (→ fail-closed) if ANY of:
1. **Commit drift:** `generated_for_commit` ≠ the PR head commit. The verdict was computed against code that has since changed. This is the primary staleness signal — it is exact, not time-based, and immune to clock skew. (Mirrors GitHub's "status is bound to a SHA" model, research §5 row 1.)
2. **Time-box (secondary, for long-lived branches):** `generated_at` older than the freshness window `GATE3_MAX_AGE_HOURS` (default 72h, project-overridable). Catches a manifest that matches the SHA but was generated weeks ago on a stale branch that was force-matched.
3. **Absence:** no manifest file for the changed feature → fail. Per research §6 consensus 3 (GitHub "blocks forever" / SLSA "unrecognized → fail" / Conftest "only `--no-fail` opens it"), **absent = closed**. Opening the gate requires an explicit, logged waiver, never silence.

Commit-drift (rule 1) is the recommended primary; the time-box (rule 2) is a backstop. Using both means a re-run is forced whenever the code changes OR the verdict ages out.

---

## 5. Entity existence verification

Every entity named in §3–§4, with existence evidence (this is a recommendation, so several entities are *proposed* — flagged as such, with the producing artifact named):

| Entity | Kind | Existence evidence |
|---|---|---|
| `gate-3-production-check` skill | existing skill | `skills/gate-3-production-check/SKILL.md` (read this dispatch; 19 dimensions D1–D19, §"The 18 Dimensions" + D19 at line 202). **Exists today.** |
| `docs/audits/gate-3-<feature>.md` | existing output artifact | `skills/gate-3-production-check/SKILL.md` line 239 "Produce `docs/audits/gate-3-<feature>.md`". **Exists today as the `.md` record.** |
| `docs/audits/gate-3-<feature>.json` | PROPOSED artifact | Does not exist yet. Will be created by the modified skill (File List row 2). Flagged PROPOSED — build-cycle deliverable. |
| `scripts/verify-gate-3.sh` | PROPOSED component | Does not exist yet. Sibling-dir precedent exists: `scripts/structural-check.sh`, `scripts/framework-state-init.sh` (referenced in ADR-002 line 73 + PROJECT-PLAN Phase 8 line 25). The `scripts/` container exists; this file is new. |
| `hooks/pre-tool-use` etc. | existing | `hooks/` listing this dispatch: `session-start`, `pre-tool-use`, `post-tool-use`, `subagent-stop`, `user-prompt-submit`, `run-hook.cmd`, `v2-6-helpers.sh`. **Exists.** Relevant only to confirm we are NOT adding a hook (see §6). |
| `.github/workflows/gate-3.yml` | PROPOSED template | Does not exist. Shipped as a downstream-project template, not run on the framework repo. |
| branch-protection "required status check" | external-service contract (GitHub) | GitHub API, current contract per research §8 citation 1: "Required status checks must have a `successful`, `skipped`, or `neutral` status before collaborators can make changes to a protected branch." URL: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches (verified by Researcher 2026-06-01). |

No entity is named without evidence. PROPOSED entities are explicitly the future Build cycle's deliverables (closes the Audit-Item-1 fabrication risk at design time).

---

## 6. Sequence View (Tier 3 — ≥1 happy + ≥1 degraded path)

**Happy path — gate present, fresh, green:**
1. CTO walks `gate-3-production-check` in-session at cycle end → all required dimensions PASS/WAIVED.
2. Skill writes `docs/audits/gate-3-<f>.md` (today) **and** `docs/audits/gate-3-<f>.json` (new) with `generated_for_commit = HEAD`.
3. Developer commits the manifest on the feature branch, opens/updates PR.
4. CI triggers on `pull_request`; `scripts/verify-gate-3.sh` runs: manifest exists ✓, `generated_for_commit == head SHA` ✓, no `BLOCKED`, every required `id` PASS-or-WAIVED-with-rationale ✓, within freshness window ✓ → **exit 0**.
5. CI surfaces check `gate-3 = success` on the head SHA → branch protection allows merge.

**Degraded path A — manifest absent (the most important F-V16 case):**
1. Developer skips the in-session gate-3 walk entirely (the exact F-V16 failure: "developer leaves the session, nothing reasserts the gate").
2. No `docs/audits/gate-3-<f>.json` on the branch.
3. CI runs `verify-gate-3.sh` → manifest-for-changed-feature not found → **exit non-zero** with message "gate-3 manifest missing for feature <f>; run gate-3-production-check and commit the manifest."
4. Check `gate-3 = failure` → **merge blocked.** Absence = closed (research §6 consensus 3). The developer cannot silently bypass by *not running* the gate — the previously-undetected case now fails closed.

**Degraded path B — manifest stale (code changed after the walk):**
1. Gate-3 walked at commit `aaa`; manifest has `generated_for_commit = aaa`.
2. Developer pushes a new commit `bbb` (e.g. "quick fix") without re-walking gate-3.
3. CI runs at head `bbb` → `generated_for_commit (aaa) != head (bbb)` → **exit non-zero**, "gate-3 verdict is stale: computed against aaa, head is bbb; re-run gate-3."
4. Merge blocked until the verdict is regenerated against the current code. (This is the "stale" half of F-V16.)

**Degraded path C — verifier itself errors / CI never reports:**
1. `verify-gate-3.sh` crashes, or the CI job is mis-wired and never posts the `gate-3` status.
2. The required check stays `pending` / never reaches `success`.
3. Branch protection: a required check that never reports "blocks forever" (research §8 citation 1, troubleshooting doc). **Merge blocked.** The verifier failing open is structurally impossible because the *binding* (not the verifier) is what permits merge, and it only permits on an explicit `success`.

---

## 7. Multi-tenant isolation table

The framework itself is single-tenant / not-a-service (CLAUDE.md Active Gates: "Framework is not multi-tenant, no UI, no migrations, not a production service"). The artifact this gate enforces, however, is per-feature and (in downstream projects) per-tenant-aware. One row per shared resource:

| Resource | Isolation model | Mechanism | Client shape (what activates it) | Rationale |
|---|---|---|---|---|
| `gate-3-<feature>.json` manifest | pool | one file per feature slug, committed to that feature's branch; no shared mutable store | Producer is the in-session skill writing to `docs/audits/<feature>.json`; verifier reads the same path by feature slug. No DB client, no RLS — the isolation is filesystem path + git branch scoping. | The framework is single-tenant tooling; "only one tenant exists" (the repo). The manifest never crosses tenants because it lives in-repo on a branch. The slot is filled per the mandatory-table rule. |
| CI verifier runtime | pool | one CI job per PR; reads only that PR's checked-out tree | `scripts/verify-gate-3.sh` runs in the CI runner's ephemeral checkout — no cross-PR state, no shared cache that could leak one PR's verdict into another. | Ephemeral-per-PR execution is the isolation. No shared mutable state between PRs. |
| Downstream-project tenancy (informational) | n/a at framework layer | The manifest carries `tenancy_model` so a *downstream multi-tenant project's* verifier can require D1/D2/D7/D11 be PASS (not WAIVED) when `tenancy_model != single-tenant`. | In a downstream project the producer reads the project's `STACK-PATTERNS.md tenancy-model`; the verifier enforces the multi-tenant dimensions accordingly. | The framework ships the contract; the downstream project's tenancy model decides which dimensions are mandatory. Documented so the build cycle wires it. |

---

## 8. Quality-attribute matrix

| Attribute | Posture in this design | Mechanism | Measured how |
|---|---|---|---|
| Reliability | Fail-closed: any verifier error, missing/stale manifest, or unreported check blocks the merge. The verifier failing open is structurally impossible (the binding permits merge only on explicit `success`). | Branch protection required-status-check semantics (research §5/§8 row 1); commit-drift staleness rule. | A red/absent/stale manifest produces `gate-3 = failure`/`pending`; merge button disabled. Verifiable by opening a PR with no manifest and confirming the block. |
| Security | The gate cannot be bypassed by *not running it* (the F-V16 hole). Opening the gate requires an auditable waiver (manifest `WAIVED` + non-null rationale), never silence. | Absence-as-failure (research §6 consensus 3); per-dimension `waiver_rationale` required-non-null. | Degraded path A test: PR with no manifest → blocked. WAIVED-without-rationale test → blocked. |
| Performance Efficiency | Verifier is a pure-bash file read + field checks; sub-second on a single JSON. No network call, no DB. | `scripts/verify-gate-3.sh` reads one file, no `jq`, no external process. | CI job wall-clock for the `gate-3` step; target < 5s including checkout overhead amortized. |
| Operational Excellence | The verdict is a committed, diffable artifact (`gate-3-<f>.json`) — auditable in PR history and minable by the Post-Mortem agent (same pattern as `bypass-log.jsonl`, ADR-002 line 59). | Manifest committed on the branch; verifier emits a human-readable failure reason naming which dimension/rule failed. | PR-history grep for manifests; CI logs carry the exact failing dimension id. |
| Cost Optimization (optional) | Zero added runtime cost: no new service, no third-party SaaS, no OPA/Conftest binary to license or host. One short CI step on existing CI minutes. | Pure-bash verifier reusing the project's existing CI. | n/a — additive cost is one short CI job. |

---

## 9. Cross-cutting concepts

- **"Produce verdict ≠ enforce verdict" (the load-bearing separation).** The skill produces; the branch-protection binding enforces. The verifier is only an adjudicator in between. This is research §6 consensus 2 and the reason the verifier can be dumb (pure bash) — all the blocking power lives in GitHub-native config, which the framework does not own and does not ship as runtime code.
- **Absence = closed.** Reused from research §6 consensus 3 and already the spirit of the gate-3 skill's "a skipped dimension is a gate failure." Now machine-enforced past the session boundary.
- **Commit-binding as the staleness primitive.** Reused from GitHub's SHA-bound status model. Binding the verdict to `generated_for_commit` makes "stale" exact rather than heuristic, and avoids a clock-skew-prone time-only rule.
- **Manifest mirrors the existing `.md` artifact, does not replace it.** The `.md` stays the human-readable durable record (read by CTO + Post-Mortem). The `.json` is its machine twin. One walk, two serializations — no double bookkeeping for the LLM.

---

## 10. Decision rationale (MADR-shaped, inline — ADR-018 deferred to Build cycle)

> Recorded inline because `scope_write` is this file only. The Build cycle ratifies this as `docs/adr/018-ci-gate-enforcement.md`. Every driver rests on a row in the research doc — no new citations invented (per `enterprise-citation-rule`).

**Context and problem statement.** F-V16: `gate-3-production-check` is chat-time-only; a PR can ship violating a required dimension and nothing blocks it. Need an enforcement point that persists past the session and fails closed on missing/stale/red.

**Decision drivers (each → research-doc row):**
1. The verdict must be a machine-readable artifact, not a human attestation — research §6 consensus 1 (6/6 unanimous: GitHub commit status, GitLab pipeline status, Conftest exit code, Argo AnalysisRun, SonarQube OK/ERROR, SLSA attestation). → manifest (§4).
2. Fail-closed lives at the enforcement boundary, separate from the verdict-producer — research §6 consensus 2 (6/6). → branch-protection binding, not in the verifier (§3, §9).
3. Absent/stale = failure — research §6 consensus 3 (6/6: GitHub "blocks forever", SLSA "unrecognized → fail", Conftest "only `--no-fail` opens it"). → §4 freshness rules + §6 degraded paths.
4. Merge-time is the closer analog than deploy-time for gate-3 — research §6 finding 5 (4/6 enforce at merge/PR; gate-3 is conceptually a merge/PR-time gate). → CI-on-PR + required check, not a deploy gate.
5. Zero third-party runtime dependency — CLAUDE.md line 81 + PR-checklist line 62. → §10a dependency reconciliation below.

**Considered options (spectrum — see §11 for the rejected deploy-time category in full):**

| Option | Description | Outcome |
|---|---|---|
| **A. Pure-bash verifier + GitHub-native required check (CHOSEN)** | Skill emits JSON; `verify-gate-3.sh` adjudicates; branch protection blocks. | **Chosen.** Satisfies all 5 drivers with zero runtime dependency. |
| B. OPA/Conftest Rego over the manifest | Replace bash verifier with Conftest evaluating Rego policy on the JSON. | **Rejected as default; OPTIONAL opt-in.** Adds a third-party runtime binary → violates the zero-dependency rule (driver 5). Conftest's exit-code semantics (research §5 row 3) are reproducible in ~30 lines of bash; the policy expressiveness is not needed for 19 flat dimension checks. See §10a reconciliation. |
| C. Deploy-time Argo-style analysis gate | Live-metric analysis at rollout for D4/D5/D9. | **Rejected for the merge-time gate (spectrum, §11).** Right tool for live-metric dimensions, wrong layer for a merge-time static gate; also requires a K8s/rollout-controller runtime the framework neither ships nor assumes. |
| D. Discipline-only (status quo) | Keep chat-time-only. | **Rejected.** This *is* F-V16; the finding exists because D fails. |

**Decision outcome.** Option A. The skill gains a JSON emitter; a new pure-bash `scripts/verify-gate-3.sh` adjudicates; the merge-block is GitHub-native branch protection wired during project onboarding.

**Consequences.**
- *Positive:* closes F-V16; zero new runtime dependency; verdict is an auditable committed artifact; Post-Mortem can mine it; absence and staleness both fail closed.
- *Negative:* requires each downstream project to wire the required-status-check in its branch protection (a one-time onboarding step, documented). The framework cannot enforce *that* the project enabled branch protection — if a project skips the wiring, the gate is inert. (Open question Q1, §12.)
- *Neutral:* the framework's own repo will not run this (no production service); it ships as a downstream template.

---

## 10a. Dependency reconciliation (REQUIRED — `architect-dependency-inventory` gate)

> Numbered 10a because it is the dependency-inventory step backing the §10 decision (driver 5). The §3 Container/Component section above also carries a one-line dependency note pointing here.

**Constraint:** CLAUDE.md line 81 + PR checklist line 62 — "No third-party runtime dependencies. PF v2 is a zero-dependency plugin like SP." CLAUDE.md line 117 — "No `jq` dependency."

**Dependency inventory of the recommended shape (Option A):**

| Candidate dependency | Needed? | Reconciliation |
|---|---|---|
| `jq` (JSON parsing in the verifier) | **No** | Forbidden by CLAUDE.md line 117. The verifier reads a manifest *the framework itself wrote* in a known, line-oriented shape — so it can be parsed with the same bash-substitution approach SP uses for `escape_for_json` (CLAUDE.md line 117, `hooks/session-start` lines 17–25 precedent). **Recommendation:** the skill SHOULD emit the JSON in a grep-friendly one-record-per-line layout (or a sidecar `.tsv`) so the verifier needs only `grep`/`case`/parameter-substitution, never `jq`. This is a build-cycle design detail (Q3, §12). |
| `bash` | Already a dependency | CLAUDE.md Dependencies table line 114: `bash` is required by all hook scripts (Git Bash/WSL on Windows). The verifier reuses it. **No new dependency.** |
| GitHub Actions runner | Not a *runtime* dependency of the plugin | The Action runs in the *downstream project's* CI, not in the plugin. The plugin ships a YAML *template*; the project owns the runner. This is the same category as the existing `.github/` convention — config, not bundled runtime code. **No new plugin dependency.** |
| GitHub branch protection / required status checks | External-service contract, not a bundled dependency | GitHub-native feature (research §5 row 1). The framework depends on the *contract* (a named check can be marked required), not on shipping any code. Same posture as "we depend on Anthropic's `permissionDecision` JSON contract" (ADR-002 line 78). **No bundled dependency.** |
| **OPA / Conftest** | **No — OPTIONAL opt-in only** | Conftest is a third-party Go binary. Making it *required* would violate the zero-dependency rule outright. Its value (research §5 row 3: exit-code-1-on-fail + `--output json`) is reproducible in ~30 lines of bash for 19 flat boolean-ish checks; Rego's policy expressiveness buys nothing for this shape. **Reconciliation:** Conftest is marked **OPTIONAL** — a project already running OPA in CI MAY point Conftest at the same manifest as a second opinion, but the framework's shipped verifier is pure bash and the gate passes/fails identically without Conftest installed. The framework never requires it. |

**Conclusion:** the recommended shape adds **zero** third-party runtime dependencies. It reuses `bash` (already required), ships a CI-YAML *template* (config, not runtime), and depends on GitHub-native required-status-checks (an external-service contract, like the existing `permissionDecision` dependency). The verifier is pure bash, no `jq`. OPA/Conftest is explicitly OPTIONAL and never on the required path. **Reconciled: compliant with the zero-third-party-runtime-dependency rule.**

---

## 11. Spectrum, not binary — the deploy-time alternative, reasoned (`architect-spectrum-not-binary` gate)

The research (§7 final bullet, §6 finding 5) raises a real alternative: a **deploy-time Argo-Rollouts-style analysis gate** for the dimensions that can only be verified against live metrics — **D4 (SLO/SLI), D5 (burn-rate alerts firing), D9 (performance at scale)**. This is not binary-dismissed. Per-category disqualifying constraint for using deploy-time analysis *as the F-V16 enforcement mechanism*:

| Category | Does deploy-time analysis fit? | Disqualifying constraint (why it's not the merge-time gate) |
|---|---|---|
| **Enforcement timing** | Partial | F-V16 asks for a *merge/PR-time* block ("a PR could ship that violates D5"). Deploy-time analysis runs *after* merge, during rollout — it cannot block the merge that F-V16 is about. Research §6 finding 5: gate-3 is conceptually merge/PR-time; 4/6 enforce there. **Disqualifier: wrong enforcement point for the stated problem.** |
| **Runtime dependency** | No | Argo Rollouts requires a Kubernetes rollout controller + a metrics provider (Prometheus/Datadog). The framework ships no K8s assumption and no metrics runtime; mandating one violates the zero-dependency rule. **Disqualifier: requires a runtime the framework neither ships nor assumes.** |
| **Dimension coverage** | Only 3 of 19 | Deploy-time analysis can only adjudicate live-metric dimensions (D4/D5/D9). The other 16 (tenant isolation, RLS, audit log, PII, migration phase, build/test, etc.) are static/structural and are fully checkable at merge time from the manifest. **Disqualifier: covers <16% of the gate; would need the merge-time check anyway.** |
| **Artifact shape** | Compatible | The deploy-time path *would* still emit a verdict object (Argo's `AnalysisRun` result) — consistent with the manifest pattern. So it is not architecturally hostile; it is a *complementary later layer*, not a replacement. |

**Reasoned outcome:** deploy-time analysis is **not rejected as wrong** — it is the *right* mechanism for *live-metric* dimensions and a legitimate **future complementary layer**. It is disqualified *as the F-V16 merge-time enforcement mechanism* on three of four categories (timing, runtime dependency, coverage). The recommendation is therefore: merge-time pure-bash verifier **now** (closes F-V16); leave a documented seam (manifest field could later carry a `deploy_verified` sub-status for D4/D5/D9) so a future cycle can add an Argo-style deploy-time confirmation **without redesign**. This is the same "graduate later without redesign" posture ADR-002 took for `triage`/`brainstorming` (ADR-002 line 74).

---

## 12. Out-of-scope (this is research-cycle output)

| Out of scope | Reason |
|---|---|
| Writing any code (`scripts/verify-gate-3.sh`, the JSON emitter, the workflow YAML) | This is a research/recommendation cycle. Implementation is a separate Tier 3 **Build** cycle. HARD-GATE: Architect writes no source. |
| Ratifying `docs/adr/018-ci-gate-enforcement.md` | Out of `scope_write` (this dispatch can write only this file). Rationale captured inline §10; ADR file is a Build-cycle deliverable. |
| Deploy-time / Argo-style live-metric gate for D4/D5/D9 | A complementary *future* layer, not the F-V16 fix (§11 spectrum). Deferred with a documented seam. |
| The exact JSON serialization layout (grep-friendly vs nested) | Build-cycle design detail; the *contract* (fields, statuses, freshness rules) is fixed here (§4), the *byte layout* is the Builder's (Q3, §12). |
| Multi-developer / team-mode interaction with the manifest | Tied to F-V15 (team-mode undesigned). Out of scope until F-V15 is designed. |
| Non-GitHub CI hosts (GitLab merge trains, etc.) | Research §5 row 2 confirms GitLab "pipelines must succeed" is the direct analog; the design is host-portable (manifest + bash verifier are host-agnostic), but the *first* shipped binding targets GitHub. Other hosts are a documented follow-on. |

---

## 13. Open questions for the future Build cycle

These need a decision (some need ≥3-citation research) before or during the Build cycle:

1. **Q1 — How does the framework verify the project actually wired branch protection?** The gate is inert if a downstream project never marks `gate-3` as required. Options: onboarding-checklist discipline (cheap, unenforced) vs a one-time `gh api` probe in onboarding that asserts the required check is configured. Likely needs the GitHub MCP question (FD-02). *Decision needed, possibly research.*
2. **Q2 — Which of the 19 dimensions are "required" vs "advisory" for the merge block?** The skill already marks D2/D8/D10/D14 as BLOCKED-only (SKILL.md line 235). Recommendation: the verifier's required-set = the project's active gates (`.framework-state/active-gates.yaml` / CLAUDE.md Active Gates) intersected with applicable dimensions. *Build-cycle decision; reuses existing active-gates machinery.*
3. **Q3 — JSON byte layout for jq-free parsing.** Nested JSON needs care to parse in pure bash. Recommend a grep-friendly one-record-per-line emission (or a `.tsv` sidecar) so the verifier uses only `grep`/`case`/parameter-substitution. *Build-cycle design detail; contract in §4 is fixed regardless.*
4. **Q4 — Freshness window default + override surface.** §4 proposes `GATE3_MAX_AGE_HOURS=72` with commit-drift as primary. Confirm the default and where projects override it (CONFIG slot vs env var). *Build-cycle decision.*
5. **Q5 — Should the SubagentStop / existing hook surface participate?** The framework already has `hooks/subagent-stop` (v2.6.0, verifies `output_files` landed). A future option: a Stop/SubagentStop hook nudges "you walked gate-3 but didn't emit the `.json`." This is a hook-contract question (MAJOR bump per CLAUDE.md versioning) — deferred, NOT part of the merge-time recommendation. *Future, needs ADR if pursued.*

---

## ADR links

- **`docs/adr/018-ci-gate-enforcement.md`** — DEFERRED to the Build cycle (out of this dispatch's `scope_write`). Decision rationale captured inline in §10 (MADR-shaped). When ratified, it supersedes the inline §10 and is linked here.
- Composes with **`docs/adr/002-hook-gating.md`** (existing) — same "machine-enforce a bypass-prone discipline" philosophy; the merge-time verifier is the post-session sibling of ADR-002's in-session PreToolUse gates. This recommendation adds **no new hook** (it adds a CI step + a bash script), so it does NOT trigger ADR-002's MAJOR-bump hook-contract clause.

---

## Handover

- **Status:** recommendation complete. Primary shape: skill emits `gate-3-<feature>.json` → pure-bash `scripts/verify-gate-3.sh` fails closed on missing/stale/red → GitHub-native required status check blocks the merge. Zero third-party runtime dependency (OPA/Conftest OPTIONAL only). Deploy-time analysis reasoned-out as a complementary future layer, not the F-V16 fix.
- **For the future Tier 3 Build cycle:** ratify ADR-018 from §10; implement the JSON emitter (skill mod), `scripts/verify-gate-3.sh`, and the workflow template; resolve open questions Q1–Q5.
- **Closes:** the *research phase* of F-V16. F-V16 stays OPEN in PROJECT-PLAN until the Build cycle ships.
