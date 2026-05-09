#!/usr/bin/env bash
# =============================================================================
# scripts/measurement.sh — Session-derived metrics emitter (ADR-006 M1 + M2)
#
# PURPOSE:
#   Derives metrics from .framework-state/trigger-audit.jsonl. Project-agnostic
#   (works on any project with the framework installed). Outputs JSON to stdout
#   for piping to whatever observability surface the project uses.
#
# METRICS EMITTED:
#   - prompt_count        — total UserPromptSubmit events
#   - skill_invocations   — Skill tool invocations
#   - agent_dispatches    — Agent / Task dispatches
#   - mcp_calls           — MCP tool calls (post v2.2.0 R2 instrumentation)
#   - subagent_inherits   — Sub-agent dispatches that inherited tier-selection
#   - bypass_events       — Bypass log entries (PF_BYPASS / PF_BYPASS_ALL / kill switch)
#
# USAGE:
#   bash scripts/measurement.sh                # current project
#   PROJECT_DIR=/path/to/project bash scripts/measurement.sh
# =============================================================================

# Note: we do NOT set -e here. grep -c exits 1 when count is 0, which we want
# to treat as a normal "0 events" case, not a script failure.

PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
AUDIT_LOG="${PROJECT_DIR}/.framework-state/trigger-audit.jsonl"
BYPASS_LOG="${PROJECT_DIR}/.framework-state/bypass-log.jsonl"

if [ ! -f "${AUDIT_LOG}" ]; then
  echo '{"error":"trigger-audit.jsonl not found","project_dir":"'"${PROJECT_DIR}"'"}'
  exit 0
fi

# Counts (using grep -c for portability, no jq).
# grep -c outputs the count even when 0, then exits 1; `|| true` keeps the
# script going. Don't add `|| echo 0` because grep already printed 0.
PROMPT_COUNT=$(grep -c '"event":"prompt_received"' "${AUDIT_LOG}" 2>/dev/null || true)
SKILL_COUNT=$(grep -c '"event":"skill"' "${AUDIT_LOG}" 2>/dev/null || true)
AGENT_COUNT=$(grep -c '"event":"agent"' "${AUDIT_LOG}" 2>/dev/null || true)
MCP_COUNT=$(grep -c '"event":"mcp_tool_call"' "${AUDIT_LOG}" 2>/dev/null || true)
INHERIT_COUNT=$(grep -c '"event":"subagent_inherit"' "${AUDIT_LOG}" 2>/dev/null || true)

# Default to 0 if any count came back empty (defensive)
PROMPT_COUNT=${PROMPT_COUNT:-0}
SKILL_COUNT=${SKILL_COUNT:-0}
AGENT_COUNT=${AGENT_COUNT:-0}
MCP_COUNT=${MCP_COUNT:-0}
INHERIT_COUNT=${INHERIT_COUNT:-0}

BYPASS_COUNT=0
if [ -f "${BYPASS_LOG}" ]; then
  BYPASS_COUNT=$(wc -l < "${BYPASS_LOG}" 2>/dev/null | tr -d ' ' || true)
  BYPASS_COUNT=${BYPASS_COUNT:-0}
fi

# Top-3 skills by frequency
TOP_SKILLS=$(grep '"event":"skill"' "${AUDIT_LOG}" 2>/dev/null \
  | grep -oE '"name":"[^"]*"' \
  | sort | uniq -c | sort -rn | head -3 \
  | awk '{name=$2; for(i=3;i<=NF;i++) name=name" "$i; gsub(/"/, "\\\"", name); printf "{\"skill\":%s,\"count\":%s},", name, $1}' \
  | sed 's/,$//')

# Top-3 sub-agents by frequency
TOP_AGENTS=$(grep '"event":"agent"' "${AUDIT_LOG}" 2>/dev/null \
  | grep -oE '"name":"[^"]*"' \
  | sort | uniq -c | sort -rn | head -3 \
  | awk '{name=$2; for(i=3;i<=NF;i++) name=name" "$i; gsub(/"/, "\\\"", name); printf "{\"agent\":%s,\"count\":%s},", name, $1}' \
  | sed 's/,$//')

# Output JSON
cat <<EOF
{
  "project_dir": "${PROJECT_DIR}",
  "measured_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "prompt_count": ${PROMPT_COUNT},
  "skill_invocations": ${SKILL_COUNT},
  "agent_dispatches": ${AGENT_COUNT},
  "mcp_calls": ${MCP_COUNT},
  "subagent_inherits": ${INHERIT_COUNT},
  "bypass_events": ${BYPASS_COUNT},
  "top_skills": [${TOP_SKILLS}],
  "top_agents": [${TOP_AGENTS}]
}
EOF
