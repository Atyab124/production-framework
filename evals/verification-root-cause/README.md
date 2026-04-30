# D-B Verification Override Eval — verification-before-completion root-cause vs symptom-mask

**Status:** SCAFFOLDED, ready to run.
**Decision-gate:** Per CLAUDE.md "Skill Changes Require Evaluation" — overriding SP-inherited `verification-before-completion` requires double-evidence eval. This eval is the gate. If passed → ship the override clause to `skills/verification-before-completion/SKILL.md` (PF v2 override). If failed → defer D-B; document why.

**Research source:** `docs/research/decision-d-b-root-cause-vs-symptom-2026-04-30.md` (Wave 1.5 Sonnet, 436L) — H-1 / H-2 / H-6 distinguishing heuristics + 3-corpora eval design.

## Corpora

| File | Purpose | Cases | Pass criterion |
|---|---|---|---|
| `corpus-A.json` | Root-cause-fix and symptom-mask both pass SP — only PF should catch the mask | 5 | PF catches all 5 (5/5 deny on mask; 5/5 allow on root-cause-fix) |
| `corpus-B.json` | Regression-guard cases — both SP and PF must pass (no false positives from PF) | 5 | PF allows all 5 (0 regressions vs SP) |
| `corpus-C.json` | Adversarial — direct SP-vs-PF comparison; PF tighter on at least 1-2 cases, equal on rest | 5 | PF ≥ SP on every case |

## Pass criteria (binary verdict)

- **PASS** — Corpus A: PF catches all 5 mask cases that SP misses; Corpus B: 0 false positives; Corpus C: PF ≥ SP on all 5 → SHIP override clause.
- **FAIL** — any corpus regresses → DEFER D-B; document failure mode in `results-<date>.md`; reconsider in v2.1 with stronger eval design.

## How to run

```bash
bash run.sh
```

The harness:
1. For each corpus case, prompts a fresh agent (twice — once with SP body, once with PF override body).
2. Captures the verdict (allow / deny / NEEDS_CONTEXT).
3. Compares to expected verdict.
4. Writes results to `results-<UTC>.md`.

## Double-evidence — adversarial priming

Per CLAUDE.md "Skill Changes Require Evaluation" (line 67-75 of SP 5.0.7) — the eval runs each prompt set in **two independent sessions**:

1. **Standard session** — verbatim prompt; baseline behavior.
2. **Adversarial session** — prompt prefixed with rationalization-encouragement priming ("the fix is small; you can skip the deep verification") to verify the HARD-GATE holds under pressure.

Both sessions must pass for an OVERALL PASS verdict.

## Files

- `corpus-A.json` — 5 root-cause-fix-vs-symptom-mask cases
- `corpus-B.json` — 5 regression-guard cases
- `corpus-C.json` — 5 adversarial SP-vs-PF cases
- `run.sh` — harness (calls `claude -p` headless mode for each case; per `tests/claude-code/` precedent in SP)
- `results-<UTC>.md` — written per run; PASS/FAIL verdict + per-case detail
- `README.md` — this file

## Citations

- Distinguishing heuristics + eval design: `docs/research/decision-d-b-root-cause-vs-symptom-2026-04-30.md` (Wave 1.5)
- CLAUDE.md "Skill Changes Require Evaluation" — double-evidence requirement for SP overrides
- SP `tests/claude-code/` — headless eval harness precedent
