---
name: fix-time-hash-check
description: "Use before applying any fix — compute the bug's root_cause_hash, grep PROJECT-PLAN.md Incident Table + STACK-PATTERNS.md for matches, surface prior occurrences. Advisory only (DONE / NEEDS_CONTEXT, never blocking). Closes the fix-time dedup gap (Audit Items 40-1, 40-2, 40-6); pairs with proposing-patterns Path A (≥3 incidents) for pattern promotion."
---

## Overview

PF v1 documented (Audit Item 40) that single-pass fixes never enter the incident table — clusters never form because the constituent incidents were never recorded. The closure-stale `mentionQuery` fix (PF v1, 2026-04-30) had a `root_cause_hash` that no skill computed. Checking it would have surfaced the React state-setter incident from Item 11 (PF v1, 2026-04-29) — same root-cause class, never reconciled.

This skill is the fix-time dedup primitive. It runs BEFORE the Builder applies a fix. It is **advisory only** — its output is one of:
- `DONE` — hash computed; surface checked; ≤30-line summary in handoff
- `NEEDS_CONTEXT` — hash inputs missing (e.g., debugger root cause sentence not yet written)

It NEVER returns `BLOCKED`. It is a cheap dedup signal, not a gate.

**Enterprise grounding:** 8/8 BINDING on the fingerprint-and-surface-priors discipline (Sentry, Bugsnag, Rollbar, Honeybadger, Datadog, Linear, GitHub similar-issue bots, Stack Overflow DupPredictor). PF v1's 7-rule normalization grammar is **independently corroborated VERBATIM by Rollbar + Datadog** (per Wave 2 research) — the v1 primitive is enterprise-consensus, not bespoke.

## When to Use

- **Before Builder applies any fix** in Build / Debug / Performance / Migration cycles.
- **Required input:** Debugger's root-cause sentence (from `docs/debug/<incident>.md` Root Cause section). If absent → return `NEEDS_CONTEXT`.

Do NOT use:
- For new feature work (no bug, no hash) — use `find-similar-implementations` instead.
- During live production fire (incident-response Phase 3) — too slow; check happens in retro post-mortem only.

## Core Pattern

You MUST create a TodoWrite item per step.

### Step 1 — Read inputs

- `docs/debug/<incident>.md` Root Cause section (the sentence describing what went wrong)
- `docs/PROJECT-PLAN.md` Incident Table
- `docs/STACK-PATTERNS.md` Project Patterns Registry

If the Root Cause sentence isn't written yet → return `NEEDS_CONTEXT`. Don't fabricate.

### Step 2 — Compute hash

Invoke `scripts/compute-root-cause-hash.sh` with the Root Cause sentence as input. The script applies the 7-rule normalization grammar (verbatim port from PF v1; corroborated by Rollbar + Datadog):

1. lowercase
2. strip line numbers
3. strip identifiers (variable names, function names) → replace with `<id>`
4. strip dates / timestamps → replace with `<date>`
5. strip version strings → replace with `<ver>`
6. collapse whitespace
7. SHA-256 of the result, truncated to 12 hex chars

The script prints the hash + the `HASH_VERSION=1` line. **Surface the version line in your output** — Sentry/Bugsnag versioning precedent (never auto-update; explicit migration when grammar changes).

### Step 3 — Grep prior occurrences

Search Incident Table for `root_cause_hash` column matching the computed hash. Search STACK-PATTERNS for the same hash referenced in any pattern row's Incident column.

### Step 4 — Emit 5-line surface

```
ROOT-CAUSE-HASH: <12-char hex> (HASH_VERSION=1)
PRIOR INCIDENTS: <N> matches in PROJECT-PLAN — most recent <date>
PRIOR PATTERNS: <N> matches in STACK-PATTERNS — IDs <BP-X, BP-Y>
PROMOTION CANDIDATE: Path A (≥3 incidents) → YES / NO
ACTION: <one of: 'apply fix; cluster pending'; 'apply fix; trigger proposing-patterns Path A'; 'fix is repeat — review prior pattern adequacy'>
```

### Step 5 — Hand off

Pass the 5-line surface to the Builder via the hand-off message. Builder applies the fix; if the surface said "trigger proposing-patterns Path A," the CTO dispatches `proposing-patterns` in parallel after the fix lands.

## Composability

- **Pairs with** `proposing-patterns` Path A — when this skill identifies ≥3 prior incidents matching the hash, it triggers proposing-patterns Path A (per ADR-003).
- **Composable with** `systematic-debugging` Step 4.5 (bug-class enterprise check) — the two run together: bug-class identification + hash dedup are complementary signals.
- **Composable with** `enterprise-research-first` — if hash dedup surfaces ≥3 prior incidents AND bug-class is in BC-1..BC-10 with documented enterprise solutions, both skills run before the fix is applied.

## Anti-Patterns

### "I'll check the hash after I apply the fix"

Defeats the dedup purpose. Hash check produces actionable signal (is this a known root cause?) BEFORE the fix shape is decided. Post-fix dedup is incident-table hygiene only — fine, but not what this skill is for.

### "The hash doesn't match anything; safe to apply"

Hash dedup is one signal among many. A non-match doesn't mean the bug is novel — it means either (a) it's truly first occurrence, or (b) the normalization grammar misclassified. Cross-reference with bug-class taxonomy.

## Quick Reference

- Advisory only (DONE / NEEDS_CONTEXT — never blocking).
- Input: Debugger Root Cause sentence.
- Output: 5-line surface (hash, prior incidents, prior patterns, promotion candidate, action).
- Pairs with proposing-patterns Path A and systematic-debugging Phase 4.5.
- HASH_VERSION=1 — surface the version; never auto-update grammar.

## Citations

**SP precedent:** None — confirmed via grep. Adjacent: `verification-before-completion` (gate-before-claiming-done discipline).

**Anthropic guidance:**
- *Building Effective Agents* — verification step in agent workflow
- *Effective Context Engineering* — file artifacts as memory; cross-session lookup

**Enterprise / OSS (8/8 BINDING):**
- Sentry event-grouping (fingerprint): https://docs.sentry.io/concepts/data-model/event-grouping/ — canonical
- Bugsnag / Rollbar / Honeybadger error fingerprinting (Rollbar + Datadog corroborate v1's normalization grammar verbatim)
- Datadog event aggregation
- Linear / GitHub similar-issue detection
- Stack Overflow DupPredictor (heuristic + ML-assisted)
- Splunk / Honeycomb event aggregation
- Google Borg fingerprint-based crash dedup (SRE Book mentions)

**v1 carryforward:**
- `scripts/compute-root-cause-hash.sh` — 7-rule normalization grammar; HASH_VERSION=1; ported verbatim from PF v1 (per ADR-001 G3 amendment + ADR-003)

**Companion PF v2 research:**
- `docs/research/skill-design-fix-time-hash-check.md` (Wave 2, Opus, 278L)
- `docs/research/skill-design-proposing-patterns.md` (Path A trigger)
