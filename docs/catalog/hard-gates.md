# Production-Framework v2.4.0 — HARD-GATE Catalog

**Schema version:** 1
**Last updated:** 2026-05-17
**Source of truth for:** `configure-project-gates` skill (reads this catalog → writes `.framework-state/active-gates.yaml` per project)
**Replaces:** scattered `<HARD-GATE>` blocks across skills/agents/hooks. Skill bodies retain the discipline text; the gate fires only when listed in the project's `.framework-state/active-gates.yaml`.

**Research grounding:**
- Trigger schema from [docs/research/configure-project-gates-trigger-format-2026-05-17.md](../research/configure-project-gates-trigger-format-2026-05-17.md) — Lefthook + Claude Code hooks hybrid (4/4 use-case-fit-pass frameworks)
- Severity/enforcement model from [docs/research/configure-project-gates-deny-vs-warn-2026-05-17.md](../research/configure-project-gates-deny-vs-warn-2026-05-17.md) — 5/5 enterprise consensus on 3-mode model
- Phase enforcement from [docs/research/configure-project-gates-phase-enforcement-2026-05-17.md](../research/configure-project-gates-phase-enforcement-2026-05-17.md) — 9/9 coordinator-layer consensus

---

## Schema

Each gate row has these fields:

| Field | Type | Notes |
|---|---|---|
| `id` | kebab-case slug | unique across the catalog |
| `category` | `universal` \| `stack_conditional` \| `configurable` | universal = always-active; stack_conditional = auto-activated by STACK-PATTERNS; configurable = project-selects |
| `trigger_class` | `pre_tool_use` \| `sub_agent_dispatch` \| `cycle_phase` \| `session_start` | where the gate fires |
| `trigger.tool` | regex string | e.g., `"Edit\|Write"` — matches Claude Code tool name |
| `trigger.file_pattern` | glob string | e.g., `"src/(lib\|hooks)/**/*.{ts,tsx}"` — Lefthook-style |
| `trigger.state_when` | array of bash predicates | optional, AND-combined; exit 0 = match |
| `trigger.agent` | string | for sub_agent_dispatch gates — which agent triggers it |
| `trigger.phase` | string | for cycle_phase gates — which phase boundary |
| `severity` | `critical` \| `standard` \| `friction` | author-set; locks `enforcement_mode` for `critical` |
| `enforcement_mode` | `block` \| `warn` \| `audit` | per-project-selectable within severity tier |
| `max_per_session` | integer (default 3) | for `warn` mode — auto-escalate to `block` after N warns |
| `justification_required` | bool (default `true` for `block`) | bypass logs to decision-log.jsonl |
| `bypass_env` | env var name | `PF_BYPASS=<id>` |
| `message` | string | human-readable rationale shown on deny/warn |
| `owner` | string | which agent/skill maintains the discipline |
| `source` | path | where this gate's HARD-GATE currently lives (skill body / agent file / FEEDBACK entry) |
| `citation` | array of strings | enterprise grounding (≥3 per binding rule); for skill-derived gates, points back at skill's citation block |

**Severity → enforcement_mode locks:**
- `critical` → `enforcement_mode: block` only (author-locked; cannot be downgraded)
- `standard` → `block` or `warn` (project-selectable; default `warn`)
- `friction` → `warn` or `audit` only (cannot escalate to `block` without operator override)

**`max_per_session` semantics:** in `warn` mode, the gate logs each warn. On the Nth warn within one session, the next firing escalates to `block`. Default N=3. ESLint `--max-warnings` pattern.

**Bypass + decision-log:** every deny + every bypass writes one JSON line to `.framework-state/decision-log.jsonl`. `configure-project-gates` mines this log on re-run to detect gates that never fire (de-activate?) or fire too often (re-tune trigger?).

---

## Category 1 — Universal Floor (9 entries, always-active)

Hardcoded into the plugin. Cannot be disabled via active-gates.yaml. These define what "production-framework" means.

### U-01 — Evidence-before-completion (verification Iron Law)

```yaml
id: evidence-before-completion
category: universal
trigger_class: sub_agent_dispatch    # fires when ANY agent returns DONE
trigger:
  agent: "*"
  state_when:
    - "agent_status == DONE"
    - "fresh_verification_command_run_count == 0"
severity: critical
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=evidence-before-completion
message: "Agent returned DONE without running fresh verification command. Re-run the command, paste output + exit code, then claim DONE."
owner: verification-before-completion (SP)
source: skills/verification-before-completion/SKILL.md (SP inherited)
citation:
  - "SP verification-before-completion/SKILL.md lines 18-22 (Iron Law)"
  - "Microsoft Engineering Playbook verification discipline"
  - "Google Engineering Practices reviewer rubric"
```

### U-02 — No-fix-without-root-cause (debugger Iron Law)

```yaml
id: no-fix-without-root-cause
category: universal
trigger_class: sub_agent_dispatch    # fires when builder dispatch follows debugger
trigger:
  agent: "production-framework:builder"
  state_when:
    - "preceding_dispatch_was_debug_cycle"
    - "docs/debug/<incident>.md.root_cause is empty"
severity: critical
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=no-fix-without-root-cause
message: "Debug cycle Builder dispatched before root cause identified. Return to Phase 1 — instrument, reproduce, trace."
owner: debugger
source: agents/debugger.md HARD-GATE lines 12-21
citation:
  - "SP systematic-debugging/SKILL.md lines 18-22 (Iron Law)"
  - "Kernighan & Pike, The Practice of Programming Ch. 5"
  - "Google SRE Book Ch. 12 'Effective Troubleshooting'"
```

### U-03 — N≥3 enterprise citation rule

```yaml
id: enterprise-citation-rule
category: universal
trigger_class: sub_agent_dispatch    # fires when researcher returns DONE
trigger:
  agent: "production-framework:researcher"
  state_when:
    - "research_doc.frameworks_cited_count < 3"
severity: critical
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=enterprise-citation-rule
message: "Researcher returned <3 citations. Return NEEDS_CONTEXT with search transcript. Do not fabricate."
owner: researcher + enterprise-research-first
source: agents/researcher.md HARD-GATE lines 12-14; skills/enterprise-research-first/SKILL.md HARD-GATE lines 14-16
citation:
  - "9/9 enterprise design-doc frameworks require alternatives-or-prior-art (Amazon PR/FAQ, Google Design Docs, Rust RFC 2333, K8s KEP, AWS WAF, ThoughtWorks Radar, ADR/MADR, Spotify, Squarespace)"
  - "Anthropic multi-agent research system Jun 2025 — source-quality heuristic"
```

### U-04 — Active-gates configuration fresh (NEW)

```yaml
id: active-gates-fresh
category: universal
trigger_class: session_start
trigger:
  event: SessionStart
  state_when:
    - "test ! -f <project-root>/CLAUDE.md || ! grep -q '## Active Gates' <project-root>/CLAUDE.md"
    - "OR <project-root>/CLAUDE.md last-modified < docs/FEEDBACK.md last-modified"
    - "OR (config.framework_state_dir/active-gates.yaml.timestamp) is older than 14 days"
severity: standard
enforcement_mode: warn
max_per_session: 1                   # remind once per session, not on every tool call
justification_required: false
bypass_env: PF_BYPASS=active-gates-fresh
message: "CLAUDE.md '## Active Gates' section is absent or stale. Run configure-project-gates before any non-trivial task. Per-project gate selection drifts out of date as FEEDBACK grows."
owner: configure-project-gates
source: NEW (user-proposed 2026-05-17; F-V40 root)
citation:
  - "Sentinel policy promotion lifecycle (Terraform Cloud)"
  - "Kubernetes Pod Security Admission profile-version model"
  - "AWS Config rules — periodic re-evaluation"
```

### U-05 — heavy-read-dispatch (no main-session reads ≥4 files)

```yaml
id: heavy-read-dispatch
category: universal
trigger_class: pre_tool_use
trigger:
  tool: "Read"
  state_when:
    # LOW-1 alignment (QA findings 2026-05-17): allow 3 deliverable-related reads,
    # deny on the 4th. Matches the hook's `>= 4` threshold. Framework-state +
    # .claude-plugin reads do not count (auto-allowed before counter increment).
    - "session.read_count_for_current_deliverable >= 4"
    - "AND main_session (not sub-agent)"
    - "AND file NOT in (.framework-state/*, .claude-plugin/*)"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=heavy-read-dispatch
message: "Main session has read >=4 files for one deliverable. Dispatch a production-framework:researcher sub-agent to absorb the context. This is the v1→v2 fork rationale; ignoring it returns the framework to v1's CTO-does-everything-in-main-context failure mode."
owner: heavy-read-dispatch
source: skills/heavy-read-dispatch/SKILL.md HARD-GATE lines 32-34
citation:
  - "Anthropic Effective Context Engineering — isolated subagent context windows"
  - "LangGraph supervisor pattern — orchestrator never reads source directly"
  - "AutoGen orchestrator + worker pool"
  - "CrewAI manager + worker crews — manager reads summaries only"
```

### U-06 — gate-3-production-check Iron Law

```yaml
id: gate-3-production-check
category: universal
trigger_class: cycle_phase           # fires at cycle-end before "production-ready" claim
trigger:
  phase: cycle_close
  state_when:
    - "agent_about_to_claim_production_ready == true"
    - "OR about_to_merge_release_branch"
    - "OR about_to_deploy_to_production"
severity: critical
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=gate-3-production-check
message: "Cannot declare production-ready / merge release / deploy without walking gate-3 18 dimensions with fresh evidence in this session."
owner: gate-3-production-check
source: skills/gate-3-production-check/SKILL.md HARD-GATE lines 22-34
citation:
  - "Google SRE Book Ch. 32 PRR (Production Readiness Review)"
  - "AWS Well-Architected Framework six pillars"
  - "CNCF/Mercari production-readiness check"
  - "+14 more in skill body"
```

### U-07 — Builder empty-diff self-attestation

```yaml
id: builder-empty-diff
category: universal
trigger_class: sub_agent_dispatch    # fires when builder returns DONE
trigger:
  agent: "production-framework:builder"
  state_when:
    - "builder.dispatch.scope == 'code'"
    - "AND git diff $BASE_SHA..HEAD --name-only is empty within declared file scope"
severity: critical
enforcement_mode: block              # in QA dispatch's Stage 1
justification_required: true
bypass_env: PF_BYPASS=builder-empty-diff
message: "Builder declared scope=code but zero files changed. Either dispatch was redundant (work already done) or silent failure (F-V10). QA must investigate before merging."
owner: builder + qa Stage 1
source: agents/builder.md lines 39-52 (EMPTY_DIFF_FLAG); agents/qa.md Stage 1 line 42 (REJECT on empty-diff under SCOPE=code)
citation:
  - "MetaGPT WriteCode rule 7 (no TODO placeholders)"
  - "Aider editblock_prompts.py (bounded shell-command)"
  - "F-V10 empirical (Taskforge PRIMARY-1 dispatch 2026-04-30)"
```

### U-08 — No PII in audit logs / log emission paths

```yaml
id: no-pii-in-logs
category: universal
trigger_class: pre_tool_use
trigger:
  tool: "Edit|Write"
  file_pattern: "**/*.{ts,tsx,py,go,rs,java,rb}"
  state_when:
    - "git diff --cached -G '(console\\.log|logger\\.|print\\().*(email|phone|password|ssn|credit|token|jwt)' returns matches"
severity: critical
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=no-pii-in-logs
message: "Log emission appears to include credentials/email/phone/payment/session-token. Per ASVS V7.1.1, NIST AU-11, SOC 2 CC6.7 — credentials and PII must not be logged in plaintext. Use correlation IDs + redaction."
owner: security-compliance
source: agents/security-compliance.md HARD-GATE lines 91-97 (cross-tenant variant is stack_conditional)
citation:
  - "OWASP ASVS V7.1.1, V7.1.2"
  - "NIST SP 800-53 AU-11, SI-12"
  - "SOC 2 TSC 2017 CC6.7"
```

### U-09 — Data-Loss Disclosure on irreversible migrations

```yaml
id: data-loss-disclosure
category: universal
trigger_class: pre_tool_use
trigger:
  tool: "Edit|Write"
  file_pattern: "**/migrations/**/*.{sql,ts,py,rb}"
  state_when:
    - "grep -qE '(DROP COLUMN|DROP TABLE|ALTER COLUMN.*TYPE|DELETE FROM)' the diff"
    - "AND grep -L 'DATA-LOSS DISCLOSURE' the docs/database/<feature>.md"
severity: critical
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=data-loss-disclosure
message: "Irreversible migration (DROP COLUMN / DROP TABLE / lossy ALTER TYPE / DELETE backfill) without DATA-LOSS DISCLOSURE block. Document: what's lost on rollback + estimated row count + recovery path."
owner: database-engineer
source: agents/database-engineer.md HARD-GATE lines 202-215
citation:
  - "pt-online-schema-change docs — rollback impossibility"
  - "Rails irreversible_migration exception"
  - "Liquibase <rollback><empty/></rollback>"
  - "gh-ost README (cut-over irreversibility)"
```

---

## Category 2 — Stack-Conditional (8 entries)

Auto-activate when STACK-PATTERNS declares the trigger condition. Project doesn't opt in or out — the stack contract drives activation. configure-project-gates reads STACK-PATTERNS at session start and writes the active subset into active-gates.yaml.

### S-01 — Tenancy model declared (multi-tenant only)

```yaml
id: tenancy-model-declared
category: stack_conditional
activator: "STACK-PATTERNS.tenancy-model in (pool, silo, bridge, hybrid)"
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:database-engineer"
  state_when:
    - "STACK-PATTERNS.tenancy-model is empty or missing"
severity: critical
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=tenancy-model-declared
message: "DB Engineer cannot author schema without declared tenancy model. Read STACK-PATTERNS.md or return NEEDS_CONTEXT to CTO."
owner: database-engineer
source: agents/database-engineer.md Step 0 HARD-GATE lines 22-36
citation:
  - "AWS SaaS Lens silo/pool/bridge"
  - "Microsoft Azure SQL multi-tenant patterns"
  - "WorkOS multi-tenant guide"
```

### S-02 — FORCE ROW LEVEL SECURITY or non-owning role

```yaml
id: rls-force-or-non-owning
category: stack_conditional
activator: "STACK-PATTERNS.tenancy-model in (pool, bridge) AND uses-RLS"
trigger_class: pre_tool_use
trigger:
  tool: "Edit|Write"
  file_pattern: "**/migrations/**/*.sql"
  state_when:
    - "grep -q 'ENABLE ROW LEVEL SECURITY' the diff"
    - "AND NOT grep -q 'FORCE ROW LEVEL SECURITY' the diff"
    - "AND docs/database/<feature>.md does not name a non-owning app role"
severity: critical
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=rls-force-or-non-owning
message: "RLS enabled without FORCE or non-owning role. Table owners bypass RLS by default. This is the most common multi-tenant footgun."
owner: database-engineer
source: agents/database-engineer.md HARD-GATE lines 49-67
citation:
  - "PostgreSQL §5.9 (verbatim)"
  - "Supabase RLS guide"
  - "OWASP Multi-Tenant Cheat Sheet"
```

### S-03 — Cache-key tenant-scoping

```yaml
id: cache-key-tenant-scoped
category: stack_conditional
activator: "STACK-PATTERNS.tenancy-model in (pool, bridge)"
trigger_class: pre_tool_use
trigger:
  tool: "Edit|Write"
  file_pattern: "**/*.{ts,tsx,py,go,rs,java,rb}"
  state_when:
    - "grep -qE '(cache\\.set|cache\\.get|redis\\.|client\\.set|kv\\.put)' the diff"
    - "AND NOT grep -qE 'tenant[_-]?id' near the cache call"
severity: critical
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=cache-key-tenant-scoped
message: "Cache write/read without tenant_id in key. NIST SC-4: caches are shared system resources — cross-tenant data leaks silently."
owner: security-compliance
source: agents/security-compliance.md HARD-GATE lines 79-87
citation:
  - "NIST SP 800-53 SC-4"
  - "OWASP Multi-Tenant Cheat Sheet"
  - "OWASP ASVS V4.2.1"
```

### S-04 — Cross-tenant safeguards (7-layer)

```yaml
id: cross-tenant-safeguards
category: stack_conditional
activator: "STACK-PATTERNS.tenancy-model in (pool, bridge)"
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:security-compliance"
  state_when:
    - "feature_touches_tenant_scoped_data == true"
    - "AND docs/security/<feature>.md does not have '## Cross-tenant safeguards' section with 7 rows"
severity: critical
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=cross-tenant-safeguards
message: "Security finding doc missing the 7-layer cross-tenant section: queries, caches, search indexes, exports, error messages, logs, background jobs."
owner: security-compliance
source: agents/security-compliance.md Output template lines 198-218
citation:
  - "OWASP Multi-Tenant Security Cheat Sheet"
  - "AWS SaaS Lens tenant isolation"
  - "OWASP ASVS V4.2.1 BOLA prevention"
```

### S-05 — Audit-trail with mandatory fields

```yaml
id: audit-trail-fields
category: stack_conditional
activator: "STACK-PATTERNS.audit-trail = required"
trigger_class: pre_tool_use
trigger:
  tool: "Edit|Write"
  file_pattern: "**/audit/**/*.{ts,py,sql}"
  state_when:
    - "AND NOT grep -qE 'tenant_id.*actor_id.*action.*target.*timestamp' the diff"
severity: standard
enforcement_mode: warn
max_per_session: 2
justification_required: true
bypass_env: PF_BYPASS=audit-trail-fields
message: "Audit-log writer should include 5 mandatory fields: tenant_id, actor_id, action, target, timestamp. Missing field detected — verify schema is complete."
owner: audit-trail
source: skills/audit-trail/SKILL.md
citation:
  - "NIST AU-2, AU-3"
  - "OWASP ASVS V7.1.3, V7.2.1"
  - "SOC 2 CC7.2"
```

### S-06 — Browser-driven verification on UI deliverables

```yaml
id: browser-driven-verification
category: stack_conditional
activator: "STACK-PATTERNS.surface includes UI"
trigger_class: sub_agent_dispatch    # fires when QA dispatched for UI feature
trigger:
  agent: "production-framework:qa"
  state_when:
    - "feature_touches_files matching src/(app|components)/**/*.{tsx,jsx,vue,svelte}"
    - "AND NOT docs/audits/qa-findings-<feature>.md contains browser_snapshot output OR browser_console_messages output"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=browser-driven-verification
message: "UI deliverable QA without browser-driven evidence. Static reasoning can't reproduce timing-dependent bugs (BC-1/BC-3/BC-4/BC-5). Capture ARIA snapshot + console-clean check via Playwright."
owner: browser-driven-verification + qa
source: skills/browser-driven-verification/SKILL.md HARD-GATE lines 22-31
citation:
  - "Playwright official Best Practices"
  - "Cypress Best Practices (fail-on-console-error)"
  - "Testing Library guiding principles"
  - "5/5 BINDING wait-for-condition"
```

### S-07 — RLS-aware migration phase classification

```yaml
id: migration-phase-classification
category: stack_conditional
activator: "STACK-PATTERNS.has-migrations = true"
trigger_class: pre_tool_use
trigger:
  tool: "Edit|Write"
  file_pattern: "**/migrations/**/*.sql"
  state_when:
    - "AND NOT grep -qE 'Migration Phase Classification|Type: (expand-only|contract-only|mixed)' the diff or sibling doc"
severity: standard
enforcement_mode: warn
max_per_session: 2
justification_required: true
bypass_env: PF_BYPASS=migration-phase-classification
message: "Migration without phase classification (expand-only/contract-only/mixed). Online migration discipline requires expand → backfill → cutover → contract pattern."
owner: database-engineer + rls-aware-migrations
source: agents/database-engineer.md lines 178-198; skills/rls-aware-migrations/SKILL.md
citation:
  - "gh-ost README"
  - "pgRoll README"
  - "pt-online-schema-change docs"
```

### S-08 — SLO/SLI contract for production-ready surface

```yaml
id: slo-sli-contract
category: stack_conditional
activator: "STACK-PATTERNS.production-ready = true"
trigger_class: cycle_phase
trigger:
  phase: gate_3
  state_when:
    - "feature_serves_user_traffic == true"
    - "AND NOT docs/runbook/<feature>.md contains numeric SLO + 4-golden-signals SLI"
severity: standard
enforcement_mode: warn
max_per_session: 1
justification_required: true
bypass_env: PF_BYPASS=slo-sli-contract
message: "Production surface without SLO/SLI catalog. Cannot define error budget without numeric SLO (4 golden signals as the floor)."
owner: sre-devops + slo-sli-contracts
source: skills/slo-sli-contracts/SKILL.md
citation:
  - "Google SRE Book Ch. 4 (SLOs)"
  - "Google SRE Workbook Ch. 2"
  - "Honeycomb four golden signals"
```

---

## Category 3 — Configurable (25 entries, project-selectable)

`configure-project-gates` reads FEEDBACK.md + project pain history + STACK-PATTERNS + user-stated priorities and writes a curated subset into `active-gates.yaml`. Default-state shown per row; configure-project-gates may flip based on signals.

### C-01 — tier-selection on Edit/Write/Bash (current hook gate)

```yaml
id: tier-selection-on-task-shape
category: configurable
default_state: recommend_on    # for projects using Build/Refactor/Migration cycles
trigger_class: pre_tool_use
trigger:
  tool: "Edit|Write|Bash"
  state_when:
    - "user_prompt_was_task_shape (build/fix/refactor/audit/optimize/migrate/implement/add/create/deploy)"
    - "AND tier_selection_invoked_at < last_user_prompt_at"
    - "AND input_source NOT IN (system_notification, task_notification, system_reminder)"   # F-8 (2026-05-17) — system events are not user task-shape prompts (implementation: user-prompt-submit hook filter)
    - "AND prompt is NOT pure continuation directive (yes/ok/continue/keep going/proceed/sure/do it/carry on/do as you recommend)"   # F-2 (2026-05-17) — continuation directives don't signal new task; per-session cache effect via user-prompt-submit filter (last_user_prompt_at not advanced on continuations, so timestamp comparison keeps passing)
severity: standard
enforcement_mode: block        # per D-2 decision (2026-05-17): predicate refine + cache, NOT warn-demotion. Gate remains block-tier; the predicate is tightened so it stops over-firing on continuations + system events.
max_per_session: null
justification_required: true
bypass_env: PF_BYPASS=tier-selection
message: "tier-selection has not been invoked since the latest substantive user prompt (task-shape verb + not a continuation + not a system event). Invoke production-framework:tier-selection before Edit/Write/Bash on task-shape prompts."
owner: tier-selection + cto-mode
source: hooks/pre-tool-use Gate 1; hooks/user-prompt-submit (input filter); ADR-002 D-A bundle; FEEDBACK F-8 + F-2 (2026-05-17) — input-source filter + continuation-prompt filter
citation:
  - "Anthropic Building Effective AI Agents — Routing pattern"
  - "ITIL 4 Standard Change pre-approval"
  - "Risk-based change classification"
```

### C-02 — cycle-selection before agent dispatch

```yaml
id: cycle-selection-before-dispatch
category: configurable
default_state: recommend_on    # for projects using multi-cycle agent graph
trigger_class: pre_tool_use
trigger:
  tool: "Agent|Task"
  state_when:
    - "tool_input.subagent_type starts with production-framework:"
    - "AND cycle_selection_invoked_at < last_user_prompt_at"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=cycle-selection
message: "Cycle-selection must be invoked before dispatching a production-framework: sub-agent. A bug routed through build cycle wastes the team."
owner: cycle-selection + cto-mode
source: skills/cycle-selection/SKILL.md HARD-GATE lines 15-17
citation:
  - "Anthropic Building Effective AI Agents — Routing"
  - "MetaGPT SOP encoding"
  - "ChatDev phase role separation"
```

### C-03 — seven-validation-questions on Tier 2/3 plans

```yaml
id: seven-validation-questions
category: configurable
default_state: recommend_on    # for any project producing Tier 2+ plans
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:builder"
  state_when:
    - "preceding_phase produced docs/plans/<feature>.md"
    - "AND tier in (2, 3)"
    - "AND NOT cycle_state.7vq_passed == true"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=seven-validation-questions
message: "Tier 2/3 plan dispatched to Builder without 7-validation-questions pass. Plan-time gate prevents ship-time outage."
owner: seven-validation-questions
source: skills/seven-validation-questions/SKILL.md HARD-GATE lines 22-24
citation:
  - "Amazon Working Backwards PR/FAQ"
  - "Google Design Docs"
  - "AWS Well-Architected"
  - "MADR + Y-Statement (Zimmermann SATURN 2012)"
```

### C-04 — parallel-reconciliation after parallel dispatch

```yaml
id: parallel-reconciliation
category: configurable
default_state: recommend_on    # for projects using parallel-dispatch
trigger_class: sub_agent_dispatch
trigger:
  agent: "any"
  state_when:
    - "preceding_turn dispatched >=2 sub-agents in parallel"
    - "AND NOT docs/reconciliation/<wave>-<UTC>.md exists for this wave"
    - "AND .framework-state/pending-reconciliation.jsonl has an unresolved entry (written by SubagentStop hook on >=2 parallel returns within 10-min window; see PR-10)"   # F-9 (2026-05-17) — composes with PR-10 auto-load mechanism: SubagentStop hook flags the wave + injects the skill body; this gate blocks the next consuming dispatch until reconciliation doc lands
severity: standard
enforcement_mode: block        # F-9 escalation (2026-05-17): warn-tier was structurally undiscoverable per FEEDBACK F-9 (silent skip = silent override of minority findings = the F-4 transient inconsistency window). Now blocks until reconciliation doc materializes. Warn-tier max_per_session pattern removed.
max_per_session: null
justification_required: true
bypass_env: PF_BYPASS=parallel-reconciliation
message: "≥2 parallel agents returned and SubagentStop hook flagged this dispatch wave as pending reconciliation. The parallel-reconciliation skill body has been auto-loaded into your context via post-tool-use hook injection — run it to produce docs/reconciliation/<wave>-<UTC>.md before consuming the parallel outputs. Silent override of minority findings is the failure mode this gate prevents; structurally-undiscoverable warn-tier was the F-9 root cause."
owner: parallel-reconciliation + cto-mode
source: skills/parallel-reconciliation/SKILL.md HARD-GATE lines 14-18; FEEDBACK F-9 (2026-05-17) — warn→block escalation + SubagentStop hook composition
citation:
  - "LangGraph supervisor/summarizer pattern"
  - "ChatDev phase-end convergence"
  - "Anthropic Multi-Agent Research System — lead-agent synthesis"
  - "F-9 empirical (TaskIt session 2026-05-17) — warn-tier silent-skip caused F-4 staleness window"
```

### C-05 — find-similar-implementations before new primitive

```yaml
id: find-similar-implementations
category: configurable
default_state: recommend_on    # for projects with reuse-gap history
trigger_class: pre_tool_use
trigger:
  tool: "Write"
  file_pattern: "src/(lib|components|hooks|utils|primitives)/**/*.{ts,tsx,jsx,py,go,rs}"
  state_when:
    - "new_file == true"
severity: friction
enforcement_mode: warn
max_per_session: 3
justification_required: false
bypass_env: PF_BYPASS=find-similar-implementations
message: "New primitive in shared module — invoke find-similar-implementations first (audit Item 39). REUSE / ADAPT / NEW judgment per row."
owner: find-similar-implementations
source: skills/find-similar-implementations/SKILL.md HARD-GATE lines 14-16
citation:
  - "Sourcegraph Code search at scale"
  - "Aider PageRank navigation"
  - "Semgrep + ast-grep structural search"
  - "Fowler Rule of Three"
```

### C-06 — regression-scope on shared-module changes

```yaml
id: regression-scope
category: configurable
default_state: recommend_on    # for any project with shared modules
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:qa"
  state_when:
    - "feature_touches_files matching src/(lib|hooks|context|cache)/**"
    - "AND NOT docs/PROJECT-PLAN.md regression-scope-catalog has new rows for this feature"
severity: standard
enforcement_mode: warn
max_per_session: 2
justification_required: false
bypass_env: PF_BYPASS=regression-scope
message: "Shared-module change without regression-scope catalog entry. Tests catch what they cover; regression-scope names the explicit consumers."
owner: regression-scope + qa
source: skills/regression-scope/SKILL.md; agents/qa.md
citation:
  - "Google Engineering Practices code review"
  - "Microsoft Engineering Playbook Risk-Based Testing"
  - "ISTQB Foundation Level §4.2"
```

### C-07 — Architect "no source code"

```yaml
id: architect-no-source-code
category: configurable
default_state: recommend_on    # always-on if architect agent is used
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:architect"
  state_when:
    - "architect.diff includes files outside docs/architecture/, docs/adr/, docs/cycle-state.md"
severity: critical
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=architect-no-source-code
message: "Architect attempted source-code write outside docs/architecture/. C4 Container/Component is your level; Code level is the Builder's."
owner: architect
source: agents/architect.md HARD-GATE lines 152-154
citation:
  - "MetaGPT §3.2-3.3 role separation"
  - "ChatDev Architect/Engineer split"
  - "C4 Model levels"
```

### C-08 — QA Stage 1 blocks Stage 2

```yaml
id: qa-stage-1-blocks-stage-2
category: configurable
default_state: recommend_on    # always-on if QA agent is used
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:qa"
  state_when:
    - "qa.stage_2_started == true"
    - "AND qa.stage_1_passed == false"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=qa-stage-1-blocks-stage-2
message: "QA Stage 2 started before Stage 1 passed. Spec compliance first; code quality only if spec passes."
owner: qa
source: agents/qa.md HARD-GATE lines 28-32
citation:
  - "SP subagent-driven-development line 247 (Red Flags)"
  - "Anthropic Building Effective AI Agents — evaluator-optimizer"
```

### C-09 — Security "no finding without control ID"

```yaml
id: security-control-id
category: configurable
default_state: recommend_on    # always-on if security agent is used
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:security-compliance"
  state_when:
    - "docs/security/<feature>.md findings table has any row without control ID column"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=security-control-id
message: "Security finding without OWASP/NIST/SOC2 control ID. A 'security concern' without a control ID is not actionable."
owner: security-compliance
source: agents/security-compliance.md Iron Law lines 14-28
citation:
  - "OWASP ASVS V4/V5"
  - "NIST SP 800-53 Rev. 5"
  - "SOC 2 TSC 2017"
```

### C-10 — Post-mortem blameless mandate

```yaml
id: postmortem-blameless
category: configurable
default_state: recommend_on    # always-on if post-mortem agent is used
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:post-mortem"
  state_when:
    - "docs/post-mortem/<incident>.md contains any of: 'should have caught', 'forgot to', 'careless mistake', 'if only', 'supposed to', 'anyone reasonable'"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=postmortem-blameless
message: "Forbidden blame-framing detected. Switch to systemic framing: 'The system did not surface...' / 'The process did not require...'"
owner: post-mortem
source: agents/post-mortem.md HARD-GATE lines 55-63
citation:
  - "Allspaw, Etsy Code as Craft, 2012"
  - "Google SRE Book Ch. 15"
  - "Dekker Field Guide to Human Error"
```

### C-11 — Incident-response rollback-first

```yaml
id: incident-response-rollback-first
category: configurable
default_state: recommend_on    # for projects with production deploys
trigger_class: cycle_phase
trigger:
  phase: incident_response_phase_3_contain
  state_when:
    - "forward_fix_chosen_without_rollback_evaluation == true"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=incident-response-rollback-first
message: "Forward-fix chosen without explicit rollback evaluation. Rollback is the FIRST action in Contain. Document why rollback isn't viable before forward-fix."
owner: incident-response
source: skills/incident-response/SKILL.md HARD-GATE lines 28-34
citation:
  - "Google SRE Ch. 8 'Rollback early'"
  - "PagerDuty Remediate"
  - "AWS Incident Manager"
```

### C-12 — PM Given-When-Then ACs

```yaml
id: pm-given-when-then
category: configurable
default_state: recommend_off   # format-prescriptive; many projects use other AC formats
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:product-manager"
  state_when:
    - "docs/specs/<feature>.md acceptance criteria not all in Given-When-Then format"
severity: friction
enforcement_mode: warn
max_per_session: 1
justification_required: false
bypass_env: PF_BYPASS=pm-given-when-then
message: "Acceptance criteria not in Given-When-Then. QA agent uses Then clause verbatim as verification assertion."
owner: product-manager
source: agents/product-manager.md HARD-GATE lines 20-23
citation:
  - "Cucumber BDD"
  - "Fowler GivenWhenThen"
  - "INVEST 'Testable'"
```

### C-13 — TDD Iron Law

```yaml
id: tdd-iron-law
category: configurable
default_state: recommend_off   # project-policy decision; not every project enforces TDD
trigger_class: pre_tool_use
trigger:
  tool: "Write"
  file_pattern: "src/**/*.{ts,tsx,py,go,rs,java}"
  state_when:
    - "new_file == true"
    - "AND NOT file_path ends in .test.* or .spec.*"
    - "AND NOT git log --all --grep 'test:' contains test for this symbol"
severity: friction
enforcement_mode: warn
max_per_session: 3
justification_required: false
bypass_env: PF_BYPASS=tdd-iron-law
message: "Production code without preceding failing test. Per TDD: red → green → refactor. Skip if project doesn't enforce TDD."
owner: test-driven-development
source: skills/test-driven-development/SKILL.md (SP inherited)
citation:
  - "SP test-driven-development/SKILL.md"
  - "Anthropic Claude Code Best Practices (TDD strongest pattern)"
  - "Kent Beck TDD By Example"
```

### C-14 — Builder EXECUTE verb + scope declaration

```yaml
id: builder-execute-verb-scope
category: configurable
default_state: recommend_on    # for any project using Builder dispatches
trigger_class: pre_tool_use
trigger:
  tool: "Agent|Task"
  state_when:
    - "tool_input.subagent_type == production-framework:builder"
    - "AND NOT tool_input.prompt starts with 'EXECUTE'"
    - "OR tool_input.prompt does not contain 'scope: (code|verdict|analysis|docs)'"
severity: standard
enforcement_mode: block
justification_required: false  # mechanical fix, not a discretionary call
bypass_env: PF_BYPASS=builder-execute-verb-scope
message: "Builder dispatch missing EXECUTE verb or scope: declaration. Ambiguous 'execute the plan' produces empty-diff silent failures (F-V7)."
owner: cto-mode + builder
source: skills/cto-mode/SKILL.md lines 82-105
citation:
  - "F-V7 empirical 2026-04-30"
  - "MetaGPT WriteCode role contracts"
  - "ChatDev role-separation discipline"
```

### C-15 — Researcher visual verification when anchor-bound (F-V31)

```yaml
id: researcher-anchor-visual-verification
category: configurable
default_state: recommend_on    # for projects citing specific UX anchors (Asana, Linear, Figma)
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:researcher"
  state_when:
    - "STACK-PATTERNS or memory binds research to specific anchor"
    - "AND NOT docs/research/<topic>.md contains browser_navigate('<anchor>') OR browser_take_screenshot('<anchor>')"
    - "AND NOT research_topic_keywords match (database|queue|retrieval algorithm|observability|infrastructure|encryption|scheduling|RAG|embeddings|cache|migration|RPC|hook|gate|index|partition|replication)"   # F-3 (2026-05-17) — technical/architectural research has zero signal from UX-anchor browsing
bound_target:                                                                                                   # F-3 (2026-05-17) — names WHAT the anchor is, so the researcher knows browser_navigate goes to this domain AND not elsewhere (composes with F-11 tool-channel discipline in agents/researcher.md)
  domain: "<configured anchor domain per STACK-PATTERNS UX-binding row>"
  scope: authenticated_ui_exploration
severity: standard
enforcement_mode: warn
max_per_session: 1
justification_required: true   # if WebFetch denied, must tag INSUFFICIENT — visual verification blocked
bypass_env: PF_BYPASS=researcher-anchor-visual
message: "Project binds research to specific UX anchor (e.g., 'Asana PRIMARY'). When research scope is UX/UI/feature-study, Researcher must browser_navigate(bound_target.domain) + browser_take_screenshot OR tag section INSUFFICIENT. Technical/architectural research (database, queue, RAG, infrastructure) is EXCLUDED — UX-anchor browsing yields zero signal for backend patterns."
owner: researcher + enterprise-research-first
source: FEEDBACK F-V31 (2026-05-17), F-3 (2026-05-17) — predicate too broad on technical topics
citation:
  - "F-V31 empirical (TaskIt research lanes 2026-05-17)"
  - "Anthropic source-quality heuristic (Jun 2025)"
  - "PRISMA citation-accuracy principle"
```

### C-16 — Researcher citation freshness (F-V39)

```yaml
id: researcher-citation-freshness
category: configurable
default_state: recommend_on    # for projects committing patterns from research
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:researcher"
  state_when:
    - "docs/research/<topic>.md has any citation row without last_verified field"
    - "OR last_verified date is older than 90 days for a binding decision"
    - "OR verification_method is training-data-only"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=researcher-citation-freshness
message: "Citation lacks last_verified + verification_method. Patterns true in training data may no longer ship. Re-verify via WebFetch or browser_navigate within 90d, or tag INSUFFICIENT — verification blocked."
owner: researcher + enterprise-research-first
source: FEEDBACK F-V39 (2026-05-17)
citation:
  - "F-V39 empirical (TaskIt Phase 5 AI Brain research 2026-05-17)"
  - "Anthropic citations API discipline"
  - "PRISMA 2020 verification recency"
```

### C-17 — PM audit-first before greenfield spec (F-V34)

```yaml
id: pm-audit-first
category: configurable
default_state: recommend_on    # HIGH-leverage gate; recommend for projects with shipped history
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:product-manager"
  state_when:
    - "docs/specs/<feature>.md missing '## §0 Pre-spec audit' section"
    - "OR audit section missing SHIPPED/NEEDS-EXTENSION/NOT-SHIPPED/DEAD-CODE classification per finding"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=pm-audit-first
message: "PM spec without §0 Pre-spec audit. Two TaskIt cycles wasted on greenfield duplication of already-shipped work (F-V34). Grep existing code, list prior plans, classify."
owner: product-manager
source: FEEDBACK F-V34 (2026-05-17)
citation:
  - "F-V34 empirical (TaskIt Phase 4 + Phase 5 PM 2026-05-17)"
  - "Cagan SVPG audit-first product discovery"
  - "Wix Engineering design-log methodology"
```

### C-18 — Worktree pre-flight (WORKTREE CRITICAL)

```yaml
id: worktree-preflight
category: configurable
default_state: recommend_on    # for any project using Builder with isolation: worktree
trigger_class: pre_tool_use
trigger:
  tool: "Agent|Task"
  state_when:
    - "tool_input.subagent_type == production-framework:builder"
    - "AND production-framework:builder has isolation: worktree in agent definition"
    - "AND (git status --porcelain returns non-empty OR no pinned SHA in dispatch OR session-start-branch-SHA != main-session-current-HEAD-SHA)"   # F-6 (2026-05-17) — 4th sub-pattern: stale parent-branch base. After SessionStart, if main session does `git checkout` to another branch + commits, subsequent Builder worktree spawns from session-START parent-branch state instead of current HEAD. SessionStart hook captures branch ref + SHA into .framework-state/session.json; pre-tool-use reads + compares.
severity: critical
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=worktree-preflight
message: "Builder worktree dispatch fails pre-flight: (a) dirty `git status`, (b) no pinned SHA in dispatch, or (c) parent-branch base is stale relative to current main-session HEAD (F-6). WORKTREE family (F-V10/11/21/25/27) + F-6 stale-base together recur 100% on the relevant triggers. Commit design artifacts; pin SHA via `git rev-parse HEAD` at dispatch time; pass BASE_SHA to dispatch. If branch-switched mid-session, verify session-start-SHA matches HEAD before dispatching Builder."
owner: cto-mode + builder
source: FEEDBACK WORKTREE consolidated (2026-05-17); F-6 (2026-05-17) — 4th sub-pattern (stale parent-branch base after mid-session branch switch)
citation:
  - "F-V10/11/21/25/27 empirical (TaskIt 2026-05-15+)"
  - "F-6 empirical (TaskIt session 2026-05-17) — Builder Lane C stale-base dispatch"
  - "Aider repo-state-aware editing"
  - "GitHub Codespaces worktree semantics"
```

### C-19 — Early Playwright smoke on Builder cherry-pick (F-V15/F-V17)

```yaml
id: early-playwright-smoke
category: configurable
default_state: recommend_on    # for projects with UI surface (auto if STACK-PATTERNS.surface UI)
trigger_class: cycle_phase
trigger:
  phase: post_builder_integration
  state_when:
    - "Builder cherry-pick complete"
    - "AND feature touched src/(app|components)/**"
    - "AND NOT browser_navigate + browser_console_messages captured for new routes"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=early-playwright-smoke
message: "Builder cherry-pick complete on UI surface without Playwright smoke. F-V15/F-V17: tsc/test/build/structural all PASS while /route renders 404. Only Playwright catches bundler/HMR/FF drift."
owner: cto-mode + qa
source: FEEDBACK F-V15, F-V17 (2026-05-17)
citation:
  - "F-V15/F-V17 empirical (TaskIt 2026-05-16)"
  - "Playwright official Best Practices"
  - "Cypress fail-on-console-error"
```

### C-20 — Quality Gate before phase close (F-V20)

```yaml
id: quality-gate-phase-close
category: configurable
default_state: recommend_off   # NOTE: see overcorrection-watch below
trigger_class: cycle_phase
trigger:
  phase: pre_phase_close
  state_when:
    - "phase about to close"
    - "AND NOT 4-pillar Quality Gate audits produced for: works, right-architecture, fast, looks-good"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=quality-gate-phase-close
message: "Phase closing without 4-pillar Quality Gate (works / right / fast / good). gate-3 is checklist; this is review."
owner: cto-mode + qa + code-reviewer + debugger + ux-design
source: FEEDBACK F-V20 (2026-05-17)
citation:
  - "F-V20 empirical (TaskIt 2026-05-17)"
  - "Google Engineering Practices code review"
  - "AWS Well-Architected reviews"
```

### C-21 — Architect contract-conventions section (F-V29)

```yaml
id: architect-contract-conventions
category: configurable
default_state: recommend_on    # for projects with multiple sibling-action files
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:architect"
  state_when:
    - "feature has sibling files in src/actions/** or similar action-family directory"
    - "AND NOT docs/architecture/<feature>.md contains 'Codebase contract conventions' section"
severity: standard
enforcement_mode: warn
max_per_session: 1
justification_required: false
bypass_env: PF_BYPASS=architect-contract-conventions
message: "Architect doc missing Codebase contract conventions. Action-family envelope drift (F-V29) ships always-false guards TypeScript can't catch."
owner: architect
source: FEEDBACK F-V29 (2026-05-17)
citation:
  - "F-V29 empirical (TaskIt 2026-05-17)"
  - "Result<T,E> envelope discipline (Rust std)"
  - "MetaGPT data-contract specification"
```

### C-22 — Researcher reads COMPETITORS.md on Research cycle (Item 1)

```yaml
id: researcher-competitor-roster
category: configurable
default_state: recommend_on    # for projects with declared competitive set
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:researcher"
  state_when:
    - "Research cycle"
    - "AND docs/COMPETITORS.md exists"
    - "AND NOT docs/research/<topic>.md cites each competitor (or documents exclusion reason per lens)"
severity: standard
enforcement_mode: block
justification_required: true
bypass_env: PF_BYPASS=researcher-competitor-roster
message: "Research cycle excluded direct competitors. Each must be included OR have a documented exclusion reason for THIS lens (not a prior lens)."
owner: researcher + enterprise-research-first
source: FEEDBACK Item 1 (2026-05-11)
citation:
  - "Item 1 empirical (TaskIt perf research 2026-05-11)"
  - "ThoughtWorks Tech Radar lens discipline"
  - "Porter Five Forces competitive set"
```

### C-23 — Architect dependency inventory (Item 3)

```yaml
id: architect-dependency-inventory
category: configurable
default_state: recommend_on    # for any project with package manifest
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:architect"
  state_when:
    - "feature proposes new library/dependency"
    - "AND NOT docs/architecture/<feature>.md contains 'Dependency Inventory' section"
severity: friction
enforcement_mode: warn
max_per_session: 2
justification_required: false
bypass_env: PF_BYPASS=architect-dependency-inventory
message: "Architect recommended library without dependency inventory step. Check package.json/requirements.txt for already-installed siblings; family-cohesion matters."
owner: architect
source: FEEDBACK Item 3 (2026-05-11)
citation:
  - "Item 3 empirical (TaskIt 2026-05-11)"
  - "AWS Well-Architected Cost Optimization (reuse over add)"
  - "Microsoft Engineering Playbook dependency hygiene"
```

### C-24 — Spectrum-vs-binary validation (Item 5)

```yaml
id: architect-spectrum-not-binary
category: configurable
default_state: recommend_on    # for any project doing architectural decisions
trigger_class: sub_agent_dispatch
trigger:
  agent: "production-framework:architect"
  state_when:
    - "architect REJECTED an approach citing N enterprise examples"
    - "AND NOT documented whether the cited examples all share the same disqualifying constraint"
severity: standard
enforcement_mode: warn
max_per_session: 2
justification_required: true
bypass_env: PF_BYPASS=architect-spectrum-not-binary
message: "Architect collapsed spectrum decision to binary REJECT. Enumerate categories with citations per category; identify disqualifying constraint per rejected category."
owner: architect + enterprise-research-first + seven-validation-questions Q8
source: FEEDBACK Item 5 (2026-05-11)
citation:
  - "Item 5 empirical (TaskIt 2026-05-11)"
  - "Rust RFC 2333 'prior art, both the good and the bad'"
  - "ADR/MADR Considered Options enumeration"
```

### C-25 — Phase-state enforcement (Item 12 + ADR-012)

```yaml
id: phase-state-enforcement
category: configurable
default_state: recommend_on    # core to multi-cycle discipline; recommend for Tier 3 projects
trigger_class: cycle_phase
trigger:
  phase: any_phase_dispatch
  state_when:
    - "CTO about to dispatch Phase N+1"
    - "AND docs/cycle-state.md Phase N status not in (DONE, SKIPPED+justification)"
severity: standard
enforcement_mode: block
justification_required: true   # skip requires written justification
bypass_env: PF_BYPASS=phase-state-enforcement
message: "Phase N+1 dispatch blocked: prior phase not DONE or SKIPPED+justification. Per ADR-012 (validated by 9/9 enterprise consensus on coordinator-layer enforcement)."
owner: cto-mode
source: ADR-012 + FEEDBACK Item 12 (2026-05-11) + research dispatch 3 (2026-05-17)
citation:
  - "Item 12 empirical (TaskIt 2026-05-11)"
  - "AWS Step Functions state machine"
  - "Apache Airflow trigger_rule + dependencies"
  - "Magentic-One Task-and-Progress Ledger"
  - "9 frameworks corroborate (research 2026-05-17)"
```

---

## Overcorrection-Watch

Rows I'm flagging as least confident. **Push back here if any of these feel wrong.**

**OW-1 — C-20 Quality Gate before phase close (F-V20) — defaulted to recommend_off.**

The 4-pillar Quality Gate caught real bugs in TaskIt — but F-V32 honestly notes that every CRIT it caught was a bug the same session shipped. The signal might be "framework introduces and catches its own bugs at high rate" rather than "framework defends against external risk." Recommend keeping `recommend_off` until F-V32's framing concern is resolved; alternatively, reframe as a "high-rigor self-correction" gate not a "defensive" gate. Don't promote to floor.

**OW-2 — U-08 No PII in logs — universal floor.**

The regex match for `email|phone|password|ssn|credit|token|jwt` near `console.log|logger\.|print\(` is fast but high-false-positive (e.g., `console.log("user logged in")` matches `logged in` which contains "log"). Real production projects might bypass this constantly. Two options: (a) keep as `block` with bypass-friendly UX + decision log mining; (b) downgrade to `warn` with `max_per_session: 5`. I picked (a) because PII leak is irreversible once it happens. If you'd rather (b), say so.

**OW-3 — U-09 Data-Loss Disclosure — universal floor.**

The trigger requires both a destructive SQL statement AND the absence of a DATA-LOSS DISCLOSURE block in the sibling `docs/database/<feature>.md`. This is heavy synthesis. A simpler check would be: "any migration file containing `DROP COLUMN|DROP TABLE` must declare `-- DATA-LOSS:` as a comment in the file itself." More mechanical, harder to bypass by accident. Worth swapping the trigger to the inline-comment shape.

**OW-4 — C-25 Phase-state enforcement — defaulted recommend_on.**

This is the ADR-012 implementation. Researcher 3 RATIFIED it (9/9 consensus), but real-world cost is non-trivial: every cycle now requires cycle-state.md schema discipline + skip-justification + visible diff. For a project doing 10 small Tier 2 cycles a week, this is overhead per cycle. Default-on for Tier 3 projects; should be default-off for projects that mostly run Tier 1/2. Configure-project-gates should make this call based on the project's actual tier distribution. Flagging because the user-friction-cost trade-off isn't trivial.

**OW-5 — C-04 parallel-reconciliation — defaulted recommend_on with max_per_session=3.**

This only fires when ≥2 parallel agents return. For projects that rarely parallel-dispatch, this gate fires 0 times in a session — zero cost. For projects with heavy parallel use, max=3 is appropriate (3 unreconciled waves before block). The default is safe but the gate is high-value only in specific shapes. May want to leave configure-project-gates to decide based on observed parallel-dispatch frequency in trigger-audit.jsonl.

**OW-6 — C-14 Builder EXECUTE verb + scope — `justification_required: false`.**

This is a mechanical fix (Builder dispatch format), not a discretionary call. The bypass is intended for tooling that constructs Builder dispatches programmatically and may pre-validate the format itself. Justified by F-V7 being 83% recurrence on Sonnet Builders — the gate exists to prevent silent failure, not to enforce policy. But if you want every bypass to require a written reason regardless, flip to `true`.

**OW-7 — Not catalogued, but flagging:**

I did NOT catalog these as gates because I judged them to be cycle/process changes rather than per-event gates:

- F-V33 Tier 2.5 / DELTA cycle — this is a new cycle definition (work for cycle-selection skill body), not a gate
- F-V36 doc-to-code ratio — this is a metric, not a gate (could be a measurement script)
- F-V18 cherry-pick tax / `isolation: none` — this is a dispatch option (Agent tool change), not a gate
- F-V19 union-merge driver for hot files — this is a `.gitattributes` setting, not a runtime gate
- F-V35 Pattern A 3-pass conditional on OQs — this is a cycle-template change, not a gate
- F-V38 tier-selection re-fire per Builder — partially closed already by F-V20 sub-agent inheritance; remaining work is hook tuning, not a new gate
- F-V40 configure-project-gates itself — this is the META-skill we're building; not catalogued as a gate but it IS the consumer of this catalog

If you want any of these elevated to gate-status, say which and I'll draft the row.

---

## Total counts

- **Universal:** 9 entries (always-active)
- **Stack-conditional:** 8 entries (auto-activated)
- **Configurable:** 25 entries (project-selectable)
- **Cycle/process changes (not catalogued as gates):** 7 items from FEEDBACK

**Catalog total: 42 rows.**

---

## Next-step inputs for configure-project-gates skill

When this skill runs against a project, it needs to read:

1. **This catalog** (`docs/catalog/hard-gates.md`) — the source of truth for what's available
2. **The project's STACK-PATTERNS.md** — to auto-activate stack-conditional gates (Category 2)
3. **The project's FEEDBACK.md** (if it exists) — to weight recommendations
4. **`.framework-state/trigger-audit.jsonl`** — historical fire rates per gate (drift detection)
5. **`.framework-state/decision-log.jsonl`** — historical bypass rates per gate (false-positive detection)
6. **User-stated priorities** — pain points and project shape

It writes:

1. **`.framework-state/active-gates.yaml`** — the runtime configuration the hook reads
2. **The project's `CLAUDE.md` `## Active Gates` section** — human-readable summary with one line per activated gate citing its source
3. **A first-run report** to the user showing which gates were activated/skipped and why

This is the next skill to draft.
