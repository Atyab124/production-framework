# evals/regression — Closed-finding regression tests

Per `docs/release-discipline.md` Gate 3: every closed finding ships with a test in this directory that fails if the bug returns.

## Format

Each test is a JSON manifest:

```json
{
  "name": "human-readable name",
  "finding_id": "F-VN",
  "symptom": "what the bug looks like",
  "repro_command": "exact bash command that reproduces the bug",
  "expected_output_match": "regex or substring the output must contain when fixed",
  "expected_output_no_match": "regex or substring the output must NOT contain when fixed",
  "fix_commit": "<sha>",
  "last_verified": "YYYY-MM-DD"
}
```

## Running

A future runner script (`scripts/run-regression.sh`) walks every JSON in this directory, executes `repro_command`, checks the output against the assertions, and exits non-zero if any test fails. The runner is part of v2.3.0+ scope; for now this directory is the manifest substrate.

## Adding a new test

When closing any finding in `docs/PROJECT-PLAN.md`:

1. Reproduce the bug at the original commit (the one that ships the bug).
2. Write the manifest with the exact reproducer.
3. Re-run after the fix; confirm the manifest's assertions hold.
4. Commit the manifest with the fix.

If you can't reproduce the bug deterministically, file as a non-regression-tested finding and explain why in the closing PR.
