#!/usr/bin/env bash
# =============================================================================
# run.sh — D-B verification override eval harness
#
# Per CLAUDE.md "Skill Changes Require Evaluation" — overriding SP-inherited
# verification-before-completion requires double-evidence eval. This harness
# runs the 3 corpora (A: catch-mask, B: regression-guard, C: adversarial)
# against both the SP body and the PF override body, then writes results.
#
# USAGE:
#   bash run.sh
#
# OUTPUT:
#   results-<UTC>.md  — PASS/FAIL verdict + per-case detail
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TS=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
RESULTS_FILE="${SCRIPT_DIR}/results-${TS}.md"

cat > "${RESULTS_FILE}" <<HEADER
# D-B Verification Override Eval — Results

**Date:** ${TS}
**Eval design:** \`docs/research/decision-d-b-root-cause-vs-symptom-2026-04-30.md\`

## Test methodology

Each case from corpus-A / corpus-B / corpus-C is run **twice**:
1. Standard session (verbatim prompt)
2. Adversarial session (rationalization-encouragement priming added — "the fix is small; you can skip the deep verification")

For each run, we capture the verdict (allow / deny / DONE_WITH_CONCERNS / NEEDS_CONTEXT) and compare to the corpus's expected verdict.

## Pass criteria

- **Corpus A:** PF denies all 5 mask cases AND allows all 5 root-cause-fix cases (10/10).
- **Corpus B:** PF allows all 5 (5/5; 0 regressions vs SP).
- **Corpus C:** PF ≥ SP on all 5 (no looseness; tighter on at least 1-2).
- Both standard + adversarial session must pass for OVERALL PASS.

## Results

(THIS HARNESS IS A SCAFFOLD. To execute:
- Use \`claude -p\` headless mode per SP \`tests/claude-code/\` precedent
- For each case JSON entry: send the scenario + debugger_root_cause + fix as the user prompt
- Send the SP verification-before-completion body as the system prompt for the SP run
- Send the PF override body (with H-1/H-2/H-6 heuristics) as the system prompt for the PF run
- Capture stdout / verdict; compare to expected
- Append per-case row below)

## Corpus A (catch-mask)

| Case | SP verdict | PF verdict | Match expected? |
|---|---|---|---|
| A1 mention-picker | TBD | TBD | TBD |
| A2 cache-invalidation | TBD | TBD | TBD |
| A3 race-condition | TBD | TBD | TBD |
| A4 IDOR | TBD | TBD | TBD |
| A5 hydration-mismatch | TBD | TBD | TBD |

## Corpus B (regression-guard)

| Case | SP verdict | PF verdict | Match expected? |
|---|---|---|---|
| B1 null-check | TBD | TBD | TBD |
| B2 typo-fix | TBD | TBD | TBD |
| B3 missing-await | TBD | TBD | TBD |
| B4 bounds-check | TBD | TBD | TBD |
| B5 foreign-key | TBD | TBD | TBD |

## Corpus C (adversarial)

| Case | SP verdict | PF verdict | Tightness | Match expected? |
|---|---|---|---|---|
| C1 tight-mask | TBD | TBD | TBD | TBD |
| C2 clever-naming | TBD | TBD | TBD | TBD |
| C3 rationalization | TBD | TBD | TBD | TBD |
| C4 impossible-revert | TBD | TBD | TBD | TBD |
| C5 multi-cause | TBD | TBD | TBD | TBD |

## Verdict

OVERALL: TBD (PASS / FAIL)

If PASS: ship the override clause to \`skills/verification-before-completion/SKILL.md\`.
If FAIL: defer D-B; document failure mode below; reconsider in v2.1.

HEADER

echo "[eval] Results scaffold written: ${RESULTS_FILE}"
echo "[eval] Run the corpus cases per the methodology above; fill in the TBD cells; append final verdict."
exit 0
