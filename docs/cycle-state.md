# Cycle State — F-V16: research CI/deploy gate enforcement

**Cycle:** research · **Tier:** 3 · **Matched trigger:** decision support / "how should we approach X" without code change

**Target finding:** F-V16 (MEDIUM, OPEN) — `gate-3-production-check` is an 18-dimension checklist run *inside* a Claude Code session. Once the developer commits / opens a PR / deploys, nothing reasserts those dimensions. A PR can ship that violates a gate dimension and the framework will not block — only chat-time discipline catches it. The v2.2.0 cycle explicitly deferred F-V16 pending "a CI/deploy research cycle." **This is that cycle.**

**Goal:** ≥3 (ideally 5) named enterprise/OSS implementations of *out-of-session* gate enforcement (CI required-checks, policy-as-code, machine-readable gate manifests, deployment gates) + a comparison table + an Architect recommendation for the framework's enforcement shape. **No code ships this cycle** — output is a research doc + a recommendation doc.

## Dispatch Order
1. **researcher** (`production-framework:researcher`) → `production-framework/docs/research/ci-gate-enforcement-2026-06-01.md`
2. **architect** (`production-framework:architect`) → `production-framework/docs/architecture/ci-gate-enforcement-2026-06-01.md` (recommendation; reads the researcher output — sequenced AFTER researcher per the file-scope intersection rule)
3. CTO main session → synthesis to user + PROJECT-PLAN F-V16 update

## Competitor / comparison roster (researcher-competitor-roster gate — cite each OR document exclusion)
- GitHub branch protection / required status checks + GitHub Actions
- GitLab CI merge-request pipelines / merge trains
- Open Policy Agent (OPA) + Conftest (policy-as-code)
- Spinnaker or Argo deployment gates / automated analysis
- Datadog Quality Gates or SonarQube Quality Gates (metric-threshold gating)
- (optional) machine-readable manifest + CI verifier pattern (release-please / changesets / SLSA attestations)

## Open Handover
[Updated by each step on completion]
- 2026-06-01 — cycle-state written; dispatching Researcher (foreground; Architect waits on its output).
- 2026-06-01 — Researcher DONE → docs/research/ci-gate-enforcement-2026-06-01.md (6 citations, 6/6 consensus).
- 2026-06-01 — Architect DONE_WITH_CONCERNS → docs/architecture/ci-gate-enforcement-2026-06-01.md (manifest + pure-bash CI verifier + required-status-check; concern Q1: inert-if-downstream-unwired).
- 2026-06-01 — CYCLE CLOSED. PROJECT-PLAN updated: F-V16 → RESEARCH DONE / Build-ready; new F-V41 (CRITICAL) logged for the file-scope-intersection self-deadlock hit mid-cycle. gate-3 SKIPPED (research cycle, no code ships). Next: Debug cycle on F-V41; Build cycle on F-V16 when ready.
