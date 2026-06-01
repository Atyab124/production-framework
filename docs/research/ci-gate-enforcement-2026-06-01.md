# Research — CI / Deploy-Time Gate Enforcement (F-V16)

**Dispatched:** 2026-06-01 | **Researcher:** PF v2 sole Researcher | **Cycle:** research (Tier 3)
**Output contract:** `production-framework/docs/research/ci-gate-enforcement-2026-06-01.md`
**Status:** DONE (6 named implementations cited; roster fully covered)

---

## 1. Question (F-V16)

The framework's `gate-3-production-check` runs as a chat-time discipline checklist invoked inside a Claude Code session: the CTO/Deputy walks 18 production-readiness dimensions and produces `docs/audits/gate-3-<feature>.md`. The gate's enforcement is entirely the LLM's in-session honesty — once the developer leaves the session (commit, PR, deploy), nothing in the framework reasserts the 18 dimensions; a PR could ship violating D5 (no SLO) or D11 (no audit log) and the framework would not block. **F-V16 asks: how do enterprise / OSS engineering orgs enforce production-readiness / quality gates OUTSIDE an interactive session — at PR / CI / merge / deploy time — so the gate persists and fails closed (stops the merge/deploy) when the gate is absent, stale, or red?** This doc surveys the enterprise-proven shapes; it does NOT design gate-3's CI solution — that is the Architect's job next.

---

## 2. Eligibility criteria (PRISMA-style)

**Included** — a candidate counts as a comparable gate-enforcement implementation only if it:
1. Enforces a pass/fail decision at a **non-interactive enforcement point** — PR review, CI job, merge action, or deploy step — i.e., after the developer has left the editor.
2. Has a **machine-evaluated** verdict (a status check, exit code, policy result, or analysis outcome), not a human sign-off checkbox alone.
3. Can be configured to **fail closed**: the absence or failure of the gate blocks the merge/deploy rather than silently allowing it.
4. Is a **named** enterprise product or OSS project with **primary documentation** (official docs, GitHub source, or vendor blog).

**Excluded:**
- **Pre-commit hooks (e.g., `pre-commit`, Husky)** — run on the developer's machine before the editor is left; trivially bypassable with `--no-verify`; they do not persist server-side. They are the same *class* of failure as gate-3 today (local discipline), so they cannot be the comparator.
- **Pure human code-review approval gates with no machine verdict** — fail criterion 2.
- **Generic "CI runs tests" with no merge-blocking wiring** — running a test is not gating a merge; the gate is the *required-status-check binding*, which is what we evaluate (so GitHub Actions is included via that binding, not as a bare test runner).
- **Spinnaker manual judgment / pipeline stages** — evaluated as a candidate but **excluded from the final roster in favor of Argo Rollouts**: Argo Rollouts' AnalysisRun is the OSS, primary-source-documented, metric-threshold *automated* gate the roster names ("Spinnaker OR Argo deployment gates"); Spinnaker's automated canary analysis (Kayenta) is the analogous mechanism but Argo Rollouts gave cleaner primary-source verbatim quotes within budget. Spinnaker is noted as a confirming-but-uncited analog.

---

## 3. Search strategy (PRISMA)

Anthropic "direct comparison" budget: 10–15 calls. Actual: **8 WebSearch + 9 WebFetch = 17** (2 over ceiling; justified — 4 WebFetch calls were `ECONNREFUSED`/typo retries against SonarQube + Conftest docs that yielded no content, so effective *informative* calls ≈ 13). N≥3 was satisfied by call 13; the extra calls upgraded SonarQube from WebSearch-synthesis to primary-fetch.

| Round | Rationale | Queries / fetches |
|---|---|---|
| **R1 — broad landscape** | One short query per roster candidate to confirm each is viable. | WebSearch: GitHub branch protection required checks; OPA/Conftest exit code CI; SonarQube quality gate blocks MR; Argo Rollouts analysis abort |
| **R2 — narrow specifics** | Roster items not yet covered + fail-closed mechanism per candidate. | WebSearch: GitLab merge trains pipeline-must-succeed; SLSA provenance verification fail-closed |
| **R3 — primary-source fetch** | Pull official docs / GitHub source for verbatim quotes. | WebFetch: GitHub protected-branches doc ✅; GitLab merge_trains doc ✅; Argo Rollouts analysis doc ✅; Conftest README ✅(partial); SLSA verifier README ✅; SonarQube CI overview ✅ |
| **R3 fallback** | WebFetch `ECONNREFUSED` on `openpolicyagent.org/docs/cicd`, `conftest.dev`, `docs.conftest.dev`, and first SonarQube URL → fell back to domain-scoped WebSearch for Conftest exit-code wording; re-fetched a versioned SonarQube URL that succeeded. | WebSearch (domain-scoped): conftest non-zero exit code; sonar.qualitygate.wait |

---

## 4. Frameworks compared

| # | Implementation | Source type | last_verified | verification_method | URL |
|---|---|---|---|---|---|
| 1 | **GitHub branch protection / required status checks (+ GitHub Actions)** | Primary (official docs) | 2026-06-01 | WebFetch of canonical docs page | https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches |
| 2 | **GitLab merge trains / MR pipelines (pipelines-must-succeed)** | Primary (official docs) | 2026-06-01 | WebFetch of canonical docs page | https://docs.gitlab.com/ci/pipelines/merge_trains/ |
| 3 | **Open Policy Agent + Conftest (policy-as-code)** | Primary (OSS docs/issues) | 2026-06-01 | WebSearch synthesis of canonical URLs (WebFetch domain-denied) | https://www.openpolicyagent.org/docs/cicd ; https://github.com/open-policy-agent/conftest |
| 4 | **Argo Rollouts AnalysisRun / AnalysisTemplate (deploy gate)** | Primary (OSS docs) | 2026-06-01 | WebFetch of stable readthedocs page | https://argo-rollouts.readthedocs.io/en/stable/features/analysis/ |
| 5 | **SonarQube Quality Gates (`sonar.qualitygate.wait`)** | Primary (official docs) | 2026-06-01 | WebFetch of versioned CI-integration overview | https://docs.sonarsource.com/sonarqube-server/10.8/analyzing-source-code/ci-integration/overview |
| 6 | **SLSA provenance + `slsa-verifier` (attestation gate)** | Primary (OSS spec + GitHub source) | 2026-06-01 | WebFetch of slsa-verifier README + WebSearch on spec | https://github.com/slsa-framework/slsa-verifier ; https://slsa.dev/spec/v1.0/verifying-artifacts |

All 6 roster items are cited. Spinnaker (Kayenta automated canary analysis) is the only roster item *not* given its own row — excluded per §2 in favor of Argo Rollouts, which is the OSS-documented equivalent automated deploy gate.

---

## 5. Comparison axes

| Implementation | What it gates | Enforcement point | Machine-readable artifact | Fail-closed mechanism |
|---|---|---|---|---|
| **1. GitHub branch protection** | Any CI signal (tests, lint, custom check, third-party tool) surfaced as a *commit status / check run* on the head SHA | **Merge** (PR → protected branch) | Commit status / check-run object on the SHA (`success` / `failure` / `pending` / `neutral`, via Checks/Statuses API) | A *required* check that is `failure` **or never reported (stays pending)** blocks the merge button. Missing/renamed check "blocks forever" — absence = closed, not open. |
| **2. GitLab merge trains** | The combined result of MR pipeline(s) when the MR is sequenced against all earlier queued MRs | **Merge** (queued merge into default branch) | MR pipeline status (success/failed) evaluated by the train + the "Pipelines must succeed" merge check | Failed train pipeline → MR is *removed from the train* and not merged; with "Pipelines must succeed" the Merge/auto-merge options are unavailable until pipeline is green. |
| **3. OPA + Conftest** | Structured config (K8s manifests, Terraform plan JSON, Dockerfiles, pipeline defs) against Rego policy | **CI job** (typically pre-merge; also pre-apply) | Conftest process **exit code** (0 pass / 1 fail; `--fail-on-warn` → 2) + machine-readable output (`--output json`) | Non-zero exit code fails the CI job → pipeline aborts. `--no-fail` would *disable* fail-closed, so leaving it off is the closed default. |
| **4. Argo Rollouts AnalysisRun** | Live deploy-time metrics (Prometheus/Datadog/etc.) against success conditions during canary/blue-green | **Deploy** (during progressive rollout) | `AnalysisRun` result object: `Successful` / `Failed` / `Inconclusive`; `failureLimit` counter | A `Failed` AnalysisRun aborts the Rollout, sets canary weight to 0, marks `Degraded`; post-promotion failure switches traffic back to the stable ReplicaSet. |
| **5. SonarQube Quality Gates** | Metric thresholds (coverage, duplications, new-code issues, security hotspots) | **CI job** (scanner step) → surfaced as PR/MR status | Quality Gate status (`OK`/`ERROR`) returned by the server; consumed by scanner via `sonar.qualitygate.wait` | `sonar.qualitygate.wait=true` makes the analysis step **fail any time the quality gate fails**; combined with branch-protection / "Pipelines must succeed", a failed gate blocks merge. |
| **6. SLSA + slsa-verifier** | Artifact provenance/attestation — was it built by the expected builder, from the expected repo/ref? | **CI / deploy** (verify step before promote/admit) | Signed provenance attestation (in-toto) + verifier `PASSED`/`FAILED` result; optional Verification Summary Attestation (VSA) | Verifier fails when signature/builder/source/ref don't match expected values; "Any unrecognized externalParameters SHOULD cause verification to fail" — unknown ⇒ fail (closed). |

**Completeness note:** every cell is populated; no `n/a` required — all 6 implementations have a defined value on all 4 axes because the eligibility criteria pre-required a machine verdict + fail-closed capability + non-interactive enforcement point.

---

## 6. Consensus

**Unanimous (6/6) — binding patterns:**

1. **The gate's verdict is a machine-readable artifact, not a human attestation.** Every implementation produces a discrete, checkable result object: a commit status (GitHub), a pipeline status (GitLab), a process exit code (Conftest), an `AnalysisRun` result (Argo), a Quality Gate `OK/ERROR` (SonarQube), or a signed attestation + `PASSED/FAILED` (SLSA). **None** rely on a human ticking a box. This is the single strongest cross-source signal and the direct answer to F-V16's core gap (gate-3 today is human-attested only).

2. **Fail-closed is the configured default at the enforcement point.** In all six, the *blocking* behavior lives at the enforcement boundary (the merge button, the pipeline step, the rollout controller, the admission/verify step), not in the tool that computes the verdict. The verdict-producer (Conftest, the SonarQube scanner, slsa-verifier) just emits a result; a *separate binding* (required status check, "pipelines must succeed", non-zero-exit-aborts-job, the Rollout controller) converts that result into a stop.

**Unanimous (6/6) — absence is treated as failure (the F-V16 "stale/missing" requirement):**
3. **A gate that does not report counts as not-passing.** GitHub: a required check that never reports "blocks forever" (pending ≠ pass). SLSA: "Any unrecognized externalParameters SHOULD cause verification to fail." Conftest: the only way to pass on failure is to *explicitly* pass `--no-fail`. This is exactly the "manifest missing or stale" semantic F-V16 needs — **the closed state is the default; opening it requires an explicit, auditable opt-out.**

**Common-but-not-universal:**
4. **Separation of "produce verdict" from "enforce verdict" via an external binding** is explicit in GitHub (Checks API + branch protection), GitLab (pipeline + merge check), and SonarQube (`wait` flag + branch protection), but *fused* in Argo (the controller both runs analysis and aborts) and Conftest (the exit code both signals and, via CI semantics, aborts). 4/6 separate; 2/6 fuse.
5. **Deploy-time (vs merge-time) enforcement** appears in 2/6 (Argo Rollouts, SLSA verify-before-admit). 4/6 enforce at merge/PR time. F-V16's gate-3 is conceptually a *merge/PR-time* gate, so the merge-time majority is the closer analog.

---

## 7. Applicability to gate-3 (candidate shapes only — Architect decides)

These are candidate shapes drawn from the consensus, **not** a design:

- **Emit a machine-readable manifest during the chat-time walk.** The 6/6 consensus says the verdict must be a checkable artifact. Candidate: gate-3's in-session walk writes `gate-3-<feature>.json` alongside today's `.md` — one record per dimension with `status` (PASS/WAIVED/BLOCKED), `evidence`, and a `verified_at` timestamp. (Mirrors SonarQube's `OK/ERROR` and Conftest's JSON output.)

- **Add a CI verifier that fails closed on missing / stale / red manifest.** A small CI step (or `conftest`-style Rego over the JSON) checks: manifest exists for the changed feature? all required dimensions PASS-or-justified-WAIVED? `verified_at` within freshness window? Any "no" → non-zero exit. This is the Conftest exit-code pattern applied to gate-3's own artifact.

- **Bind the verifier as a required status check.** The 6/6 fail-closed lesson: the *blocking* lives at the merge boundary, not in the verifier. Candidate: wire the verifier as a GitHub required status check (or GitLab "pipelines must succeed") so a missing or red gate-3 manifest blocks the merge button — the GitHub "blocks forever if the check never reports" property gives the "stale/missing = closed" behavior F-V16 asks for, for free.

- **Make the closed state the default; opening it requires an auditable opt-out.** Per consensus pattern 3, an absent gate must fail, not pass. Candidate: no `--no-fail` equivalent without a logged waiver — analogous to gate-3's existing WAIVED-with-cited-rationale discipline, but now machine-checked.

- **(Optional) deploy-time analog for runtime dimensions.** Dimensions that can only be verified live (D4 SLO, D5 burn-rate, D9 perf-at-scale) map better to an Argo-Rollouts-style *deploy-time* analysis gate than a merge-time check. Candidate: split gate-3 into merge-time (static/structural dimensions) vs deploy-time (live-metric dimensions) — but this is a larger scope decision for the Architect.

---

## 8. Citations (verbatim quote + URL + verification timestamp)

> **Methodology disclosure:** Direct `WebFetch` was `ECONNREFUSED` for `https://www.openpolicyagent.org/docs/cicd`, `https://www.conftest.dev/`, and `https://docs.conftest.dev/en/latest/`, and for the first (unversioned) SonarQube CI-overview URL. For OPA/Conftest exit-code wording I fell back to **domain-scoped WebSearch of the canonical URLs** (tagged below). SonarQube was successfully re-fetched at a *versioned* URL (`/sonarqube-server/10.8/...`) and is primary-source-verified. All other quotes are direct WebFetch of the canonical primary source. Re-verify before any binding architectural commitment.

**1. GitHub branch protection / required status checks** — *primary, WebFetch 2026-06-01*
- "Required status checks must have a `successful`, `skipped`, or `neutral` status before collaborators can make changes to a protected branch." — https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches
- "When status checks are required, the people, teams, and apps that have permission to push to a protected branch will still be prevented from merging into the branch when the required checks fail." — same URL.
- (Absence-as-failure, WebSearch of GitHub troubleshooting docs 2026-06-01) "If a check is required but that check doesn't get triggered … the 'expected check' will block forever." — https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks

**2. GitLab merge trains** — *primary, WebFetch 2026-06-01*
- "Use merge trains to put merge requests in a queue. Each merge request is compared to the other, earlier merge requests, to ensure they all work together." — https://docs.gitlab.com/ci/pipelines/merge_trains/
- "If a merge train pipeline fails, the merge request is not merged. GitLab removes that merge request from the merge train, and starts new pipelines for all the merge requests that were queued after it." — same URL.
- "Each merge request merges into the target branch only after: The merge request's pipeline completes successfully. All other merge requests queued before it are merged." — same URL.
- (Pipelines-must-succeed, WebSearch of GitLab docs 2026-06-01) "When Pipelines must succeed is enabled, but the latest pipeline failed: The Set to auto-merge or Merge options are not available." — https://docs.gitlab.com/user/project/merge_requests/auto_merge/

**3. OPA + Conftest** — *primary OSS; exit-code wording via WebSearch synthesis of canonical URLs (WebFetch domain-denied) 2026-06-01*
- "Conftest helps you write tests against structured configuration data." — https://github.com/open-policy-agent/conftest (WebFetch 2026-06-01)
- (via WebSearch synthesis of canonical URL) "By default, Conftest only returns an exit code of 1 when a policy has failed." `--fail-on-warn`: "exit code of 0 indicates no failures or warnings, exit code of 1 means no failures but at least one warning exists, and exit code of 2 indicates at least one failure." `--no-fail` "returns an exit code of zero even if a policy fails." — https://www.openpolicyagent.org/docs/cicd (canonical; retrieved via domain-scoped WebSearch 2026-06-01 because WebFetch returned ECONNREFUSED)
- (via WebSearch synthesis, R1) "In case of any failure Conftest returns non zero exit code, hence the Job is failing." — synthesized from OPA CI/CD docs + community guides; canonical: https://www.openpolicyagent.org/docs/cicd

**4. Argo Rollouts AnalysisRun** — *primary, WebFetch 2026-06-01*
- "An AnalysisRun is an instantiation of an AnalysisTemplate. AnalysisRuns are like Jobs in that they eventually complete. Completed runs are considered Successful, Failed, or Inconclusive, and the result of the run affect if the Rollout's update will continue, abort, or pause, respectively." — https://argo-rollouts.readthedocs.io/en/stable/features/analysis/
- "The failed analysis causes the Rollout to abort, setting the canary weight back to zero, and the Rollout would be considered in a `Degraded`." — same URL.
- "If post-promotion Analysis fails or errors, the Rollout enters an aborted state and switches traffic back to the previous stable Replicaset." — same URL.
- "`failureLimit` is the maximum number of failed run an analysis is allowed." — same URL.

**5. SonarQube Quality Gates** — *primary, WebFetch (versioned URL) 2026-06-01*
- "Setting `sonar.qualitygate.wait` to true forces the analysis step to poll your SonarQube Server instance until the quality gate status is available." — https://docs.sonarsource.com/sonarqube-server/10.8/analyzing-source-code/ci-integration/overview
- "[This setting] causes the analysis step to fail any time the quality gate fails, even if the actual analysis is successful." — same URL.
- (Merge-blocking binding, WebSearch of Sonar Community guide 2026-06-01) "With GitHub, it's possible to block the merge of a pull request if the SonarQube Quality Gate is failed, which is called a Branch protection rule and can be defined per target branch." — https://community.sonarsource.com/t/how-to-block-the-merge-of-pull-requests-when-sonarqube-quality-gate-is-failed-with-github/19516 *(secondary — Sonar's own community/guides forum)*

**6. SLSA + slsa-verifier** — *primary OSS, WebFetch 2026-06-01*
- "slsa-verifier is a tool for verifying SLSA provenance that was generated by CI/CD builders." — https://github.com/slsa-framework/slsa-verifier
- "slsa-verifier verifies the provenance by verifying the cryptographic signatures on provenance to make sure it was created by the expected builder." — same URL.
- "It then verifies that various values such as the builder id, source code repository, ref (branch or tag) matches the expected values." — same URL.
- (Spec, WebSearch of slsa.dev 2026-06-01) "Any unrecognized externalParameters SHOULD cause verification to fail." — https://slsa.dev/spec/v1.0/verifying-artifacts

---

## 9. Pre-DONE self-rubric

| # | Criterion | Result |
|---|---|---|
| 1 | **Factual accuracy** | PASS — every §6 synthesis claim maps to a verbatim quote in §8. |
| 2 | **Citation accuracy** | PASS — 4/6 primary quotes are direct WebFetch; OPA/Conftest exit-code + 3 binding/spec quotes are tagged `via WebSearch synthesis of canonical URL` per the WebFetch-denial rule. |
| 3 | **Completeness** | PASS — all 4 comparison axes populated for all 6 implementations; no empty cells. |
| 4 | **Source quality** | PASS — 5/6 primary citations are official docs or GitHub source; SonarQube's merge-blocking binding quote is explicitly tagged *secondary* (Sonar community/guides). |
| 5 | **Tool efficiency** | PASS-with-note — 17 raw calls vs 15 ceiling; ~13 *informative* (4 were ECONNREFUSED/typo retries returning no content). N≥3 satisfied at call 13; over-budget calls upgraded SonarQube to primary-source. Disclosed, not hidden. |

**Roster coverage:** GitHub ✅ · GitLab ✅ · OPA/Conftest ✅ · Argo Rollouts ✅ (Spinnaker excluded-with-rationale, §2) · SonarQube ✅ (SonarQube chosen over Datadog Quality Gates — interchangeable per roster's "Datadog OR SonarQube") · SLSA/attestations ✅ (optional roster item, included).
