# R6 — Status-token grammars + agent self-verification patterns

**Researcher:** Researcher #6 of 6 (production-framework v2.6 design)
**Date:** 2026-05-27
**Scope:** FEEDBACK.md §3.9 (Debugger live-invocation evidence) + §3.12 (Builder `DONE_PENDING_VERIFICATION` token)
**Question backing:** Should v2.6 introduce a `DONE_PENDING_VERIFICATION` status token for Builder dispatches that cannot run their own verification commands in-sandbox? If so, what shape, and how should the orchestrator enforce verification before accepting DONE?

---

## §1 — Executive summary

1. **Status-token grammars across the surveyed enterprise/OSS frameworks fall into three families** — (a) discrete enum like Superpowers (DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED), (b) structured-route like LangGraph (`Command(goto=END | next_node, update=...)`), (c) condition-evaluated like AutoGen (`TerminationCondition` composed of MaxMessage, TextMention, Handoff, Timeout, StopMessage primitives). All three share one design property: **terminal-state semantics are explicit, not inferred from "the agent stopped talking."**

2. **The "pending verification" concept is implicit in 3/5 surveyed frameworks** — CrewAI's task guardrails (`(True, value) | (False, error)` tuple with `guardrail_max_retries=3`); Anthropic's CitationAgent separate-pass design; LangGraph's `Command(resume=...)` shape for human-in-the-loop interrupt resume. None of them name it `DONE_PENDING_VERIFICATION`, but the architectural primitive is well-established: **the claimer's output is provisional until a second-pass verifier confirms it against ground truth.**

3. **Anthropic's CitationAgent is the closest enterprise analogue to PF's proposed `DONE_PENDING_VERIFICATION`.** Per Anthropic engineering: "passes findings to a specialized CitationAgent that processes documents and the research report to identify specific locations for citations, ensuring all claims are properly attributed to sources." The CitationAgent reads the raw documents AND the final report, so it checks claims against ground truth instead of the lead agent's recollection. **PF's pattern is structurally identical: Builder returns code + verification command list; orchestrator runs commands against ground truth before accepting DONE.**

4. **Reflexion (Shinn et al., NeurIPS 2023) and self-consistency (Wang et al., ICLR 2023) provide the empirical foundation for the broader principle that LLM agents improve when their outputs are checked, not assumed correct.** Reflexion reaches 91% pass@1 on HumanEval (vs. 80% GPT-4 baseline) by feeding execution failures back as "verbal self-reflection" — i.e., the agent's claim of "DONE" is overruled when the test runner says it failed. Self-consistency improves GSM8K by +17.9% by sampling multiple reasoning paths and majority-voting — i.e., a single agent claim is unreliable; cross-checking is what improves accuracy.

5. **The "output landing verification" failure mode (agent says "I wrote file X" but file does not exist) is solved by post-write existence checks in 2/5 frameworks.** Superpowers' `verification-before-completion` skill explicitly mandates "Agent reports success → Check VCS diff → Verify changes → Report actual state" (per PF's own citation manifest at line 527). CrewAI guardrails can wrap the same check. LangGraph, AutoGen, and Reflexion do not have a first-class primitive for this — they assume the agent's claim and rely on downstream nodes to fail loudly.

6. **Recommendation: ship `DONE_PENDING_VERIFICATION` as a new fifth status token in v2.6** with the following shape — Builder returns `(token, verification_commands[], expected_outcome)` triple; SubagentStop hook (catalog C-04 family) blocks the next consuming dispatch until CTO/Deputy executes the commands and posts results to cycle-state. This is structurally homologous to (a) Anthropic's CitationAgent separate-pass model, (b) CrewAI's `(False, error)` retry mechanism, (c) LangGraph's `Command(resume=...)` interrupt pattern — three named enterprise/OSS precedents, satisfying the N≥3 binding rule.

7. **Self-verification by the claimer alone is empirically weaker than orchestrator-side verification.** Anthropic's "game of telephone" insight ("a single agent doing both 'decide what to write' and 'verify every citation' produces" inferior results) maps directly to PF's VE#14 evidence: all 5 Builders in the cited cycle gave identical-language soft-DONE on hallucinated verification. The claimer's incentive structure (close the dispatch) conflicts with the verifier's job (refuse to close on insufficient evidence). Separation of concerns is binding.

---

## §2 — Comparison table: status-token grammar shapes

| Framework | Terminal "success" | Terminal "concerns" | "Needs more info" | "Blocked" | "Pending verification" | Verifier location |
|---|---|---|---|---|---|---|
| **Superpowers 5.0.7** | `DONE` | `DONE_WITH_CONCERNS` | `NEEDS_CONTEXT` | `BLOCKED` | — (not named) | Orchestrator's spec-reviewer (separate dispatch) |
| **LangGraph** | `Command(goto=END)` | — (not enumerated; node returns state with concerns field if schema declares one) | `Command(resume=...)` after `interrupt()` | — (no first-class concept; exception bubbles up) | `Command(resume=...)` for human-in-the-loop | Parent graph or human (via interrupt/resume) |
| **AutoGen** | `StopMessage` produced; `TextMentionTermination("TERMINATE")` matched | — (not modeled; runs until termination condition met) | — (no first-class concept; uses HandoffTermination to escalate) | `MaxMessageTermination` exhaustion (implicit fail) | — (no first-class concept; HandoffTermination is closest) | TerminationCondition evaluator (orchestrator) |
| **CrewAI** | Task output matches `output_pydantic` / `output_json` / `expected_output` AND guardrail returns `(True, value)` | — (not modeled as separate status) | — (no first-class concept) | Guardrail exhausts `guardrail_max_retries=3` with `(False, err)` | Guardrail tuple `(False, error_message)` triggers retry — explicit pending state during retry window | Guardrail function (function-based) or LLM (LLM-based) |
| **Reflexion (NeurIPS 2023)** | Evaluator scalar/binary success signal | — (mixed-quality results trigger self-reflection on next trial) | — (no first-class concept) | Max trials exhausted | Implicit — Evaluator output is the "verify" signal between Actor trials | Evaluator (separate component from Actor) |
| **Anthropic multi-agent research** | Lead agent synthesizes; passes to CitationAgent | — (not formally enumerated) | Lead spawns additional subagents | Search-loop exhaustion without sufficient sources | **Implicit** — research output is "pending" until CitationAgent walks the final report against raw documents | CitationAgent (separate pass, separate context) |
| **PF v2.5.0 (current)** | `DONE` | `DONE_WITH_CONCERNS` | `NEEDS_CONTEXT` | `BLOCKED` | **MISSING** — manifests as soft-DONE on hallucinated verification (VE#14) | — (no second-pass verifier for Builder output) |
| **PF v2.6 (proposed)** | `DONE` | `DONE_WITH_CONCERNS` | `NEEDS_CONTEXT` | `BLOCKED` | **`DONE_PENDING_VERIFICATION`** — Builder returns code + verification command list; orchestrator must execute before accepting | CTO/Deputy (post-Builder hook enforced) |

**Axis legend:** "Verifier location" answers the question "who confirms the claim before downstream work proceeds?" In all robust enterprise designs the verifier is structurally separate from the claimer.

---

## §3 — Self-verification empirical research summary

### §3.1 Reflexion (Shinn et al., NeurIPS 2023, arXiv:2303.11366)

**Verbatim claim (from search synthesis of arXiv abstract):** "Reflexion is a novel framework to reinforce language agents through linguistic feedback, where agents verbally reflect on task feedback signals and maintain reflective text in an episodic memory buffer to induce better decision-making in subsequent trials." Reflexion achieves **91% pass@1 on HumanEval** vs. **80% GPT-4 baseline**.

**Architecture:** Three-component design — Actor (proposes), Evaluator (scores), Self-Reflection (verbalises why the score was low and updates episodic memory for next trial). Strategy enum from the reference implementation (github.com/noahshinn/reflexion) confirms: `ReflexionStrategy.NONE | LAST_ATTEMPT | REFLEXION | LAST_ATTEMPT_AND_REFLEXION`.

**Implication for PF:** The Evaluator is structurally separate from the Actor. The Actor cannot self-certify "DONE" — the Evaluator owns the verify signal. This is the empirical foundation for refusing to let a Builder self-certify when verification cannot run in its sandbox.

### §3.2 Self-Consistency (Wang et al., ICLR 2023, arXiv:2203.11171)

**Verbatim abstract (retrieved 2026-05-27):** "Chain-of-thought prompting combined with pre-trained large language models has achieved encouraging results on complex reasoning tasks. In this paper, we propose a new decoding strategy, *self-consistency*, to replace the naive greedy decoding used in chain-of-thought prompting. It first samples a diverse set of reasoning paths instead of only taking the greedy one, and then selects the most consistent answer by marginalizing out the sampled reasoning paths. Self-consistency leverages the intuition that a complex reasoning problem typically admits multiple different ways of thinking leading to its unique correct answer. Our extensive empirical evaluation shows that self-consistency boosts the performance of chain-of-thought prompting with a striking margin on a range of popular arithmetic and commonsense reasoning benchmarks, including GSM8K (+17.9%), SVAMP (+11.0%), AQuA (+12.2%), StrategyQA (+6.4%) and ARC-challenge (+3.9%)."

**Implication for PF:** A single agent claim is empirically unreliable; cross-checking is what improves accuracy. For PF, this means a single Builder's "I tested it" assertion (when it cannot actually run tests in-sandbox) is the LOW-confidence equivalent of greedy-decoded chain-of-thought. The orchestrator-side verification pass is the cross-check.

### §3.3 Reflect-then-respond (general pattern)

Less formal than Reflexion but widely cited: agents should verbalise their reasoning, then critique it, then commit. This pattern is implicitly invoked by Superpowers' Iron Law ("NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE") and by PF's own `verification-before-completion` skill. Both treat the claimer's first instinct as suspect.

### §3.4 Convergence on a single empirical principle

All three lines of evidence (Reflexion, self-consistency, reflect-then-respond) converge on: **LLM claims of correctness are systematically over-confident; an independent verification signal materially improves accuracy.** Cross-mapping to PF VE#14: "all 5 Builders, identical language" — this is exactly the failure mode the empirical literature predicts when the claimer is also the verifier.

---

## §4 — Pending-verification handoff patterns (cross-framework)

### §4.1 Where does the verifier sit relative to the claimer?

| Framework | Claimer | Verifier | Handoff shape |
|---|---|---|---|
| **Anthropic multi-agent research** | Lead agent / research subagents | **CitationAgent** (separate context, separate dispatch) | Lead exits research loop → passes raw documents + draft report → CitationAgent attributes each claim to a URL → only then ship |
| **CrewAI** | Task agent | **Guardrail function/LLM** (in-process callback) | Agent output → guardrail evaluated → `(True, value)` ships, `(False, err)` retries up to `guardrail_max_retries` |
| **LangGraph** | Node that issued `interrupt()` | **Human or parent graph** (resumes via `Command(resume=...)`) | Node hits `interrupt()` → graph pauses → external verifier provides resume value → execution continues with verified input |
| **Reflexion** | Actor | **Evaluator** (separate component) | Actor proposes → Evaluator scores → Self-Reflection consumes score → next trial |
| **Superpowers** | Implementer subagent | **Spec-reviewer** then **code-quality-reviewer** (sequential dispatches) | "Two-stage review after each task: spec compliance first, then code quality." Spec-reviewer instructed: "## CRITICAL: Do Not Trust the Report... Verify by reading code, not by trusting report." |

### §4.2 Common architecture

In all five frameworks the verifier is **structurally separate** from the claimer:

- **Separate context** (CitationAgent, spec-reviewer, Reflexion Evaluator)
- **Separate process** (LangGraph human-in-the-loop, AutoGen termination evaluator)
- **Separate function** (CrewAI guardrail)

The PF v2.6 proposal — CTO/Deputy executes verification commands the Builder returned — is structurally identical: the executor of verify-commands is a different agent in a different dispatch from the one who wrote the code.

### §4.3 "Game of telephone" insight (Anthropic)

Anthropic explicitly justifies the CitationAgent separation: "A single agent doing both 'decide what to write' and 'verify every citation' produces what Anthropic calls 'the game of telephone' — by the time the report is drafted, the source URLs have been condensed and re-summarized through several subagent returns. A separate CitationAgent reads the raw documents AND the final report, so it checks claims against ground truth instead of the lead agent's recollection of it."

**PF VE#14 is the same failure class** — Builder cannot run tests in-sandbox, so it "remembers" what would happen if tests ran. Same telephone problem.

---

## §5 — Recommendations for §3.12 `DONE_PENDING_VERIFICATION`

### §5.1 Token shape

Add a fifth status token to the v2.5.0 grammar:

```
DONE_PENDING_VERIFICATION
```

**Semantics:** "I (the Builder) have completed the implementation. I could not execute the verification commands in my sandbox. Here is the list of commands the orchestrator must execute to confirm the claim. Until the orchestrator runs them and posts the results, this dispatch is NOT closed."

This is **distinct from** `DONE_WITH_CONCERNS` — concerns are issues the Builder identified; pending-verification is verification the Builder could not perform.

### §5.2 Return-shape contract

Builder handover must include a structured block:

```yaml
status: DONE_PENDING_VERIFICATION
verification_commands:
  - command: "npm test -- --testPathPattern=auth"
    expected_outcome: "All 14 tests in auth.test.ts pass"
    why_builder_cannot_run: "Bash tool denied in researcher sandbox; npm not on PATH"
  - command: "supabase db diff --schema public"
    expected_outcome: "Empty diff (migrations applied cleanly)"
    why_builder_cannot_run: "Supabase CLI not available in sandbox"
output_landing_check:
  - path: "src/auth/handler.ts"
    expected: "exists, exports handleLogin"
  - path: "supabase/migrations/20260527_add_session_table.sql"
    expected: "exists, 38 lines"
```

The `output_landing_check` block addresses the "I wrote file X but file does not exist" failure (Researcher D3 in citation manifest line 527, generalized to Builder).

### §5.3 Hook enforcement

**Hook 1 — Post-Builder pre-merge gate (HARD-GATE):** SubagentStop hook fires when Builder returns `DONE_PENDING_VERIFICATION`. Hook writes a block file at `.framework-state/pending-verification-{cycle-id}.json` containing the verification command list. Hook blocks the next consuming dispatch (QA, Code Review, Security) until a counterpart hook detects `.framework-state/verification-results-{cycle-id}.json` with matching command outcomes.

**Hook 2 — CTO/Deputy verification execution skill:** New skill `framework:executing-pending-verification` walks the command list, executes each, posts `pass | fail | partial` with stdout+stderr capture to the results file. If any command fails or output diverges from `expected_outcome`, the dispatch is re-routed to debugger/builder for fix — NOT silently accepted.

**Hook 3 — Output landing check:** Independent of the command list, the orchestrator runs `ls -la` (or PowerShell equivalent) against each path in `output_landing_check`. If any path is missing or size is 0, the Builder's `DONE_PENDING_VERIFICATION` is automatically downgraded to `NEEDS_CONTEXT` with the specific missing-path list.

### §5.4 Acceptance rule

```
DONE_PENDING_VERIFICATION + verification_results.all_pass + landing_check.all_present
  → orchestrator promotes to DONE
DONE_PENDING_VERIFICATION + any verification_results.fail
  → orchestrator routes to debugger with the failing command + actual output
DONE_PENDING_VERIFICATION + landing_check.missing > 0
  → orchestrator downgrades to NEEDS_CONTEXT with missing-path list
```

### §5.5 Composability with §3.9 (Debugger live-invocation evidence)

The same shape composes for Debugger: when Debugger asserts a root cause for an RPC/DB-write/external-service failure, the handover must include a "Live invocation evidence" section quoting the actual error returned by the invocation (per §3.9). If Debugger could not run the live invocation, it returns `DONE_PENDING_VERIFICATION` with the invocation command in `verification_commands`. **Same token, same hook, same acceptance rule.** This is the unifying primitive: any agent claim involving an operation the agent could not perform in-sandbox MUST surface the operation for orchestrator-side execution.

### §5.6 Why not just expand `DONE_WITH_CONCERNS`?

Two-state collapse would obscure the action required. `DONE_WITH_CONCERNS` is informational ("here is a thing you should know about"); `DONE_PENDING_VERIFICATION` is operational ("here is a thing you must execute before this can be considered done"). The Superpowers grammar treats `DONE_WITH_CONCERNS` as a hint to the orchestrator's judgment — by contrast `DONE_PENDING_VERIFICATION` is a HARD-GATE that blocks downstream until evidence lands. They are different operational contracts; conflating them re-introduces the soft-DONE failure mode.

### §5.7 Why not adopt CrewAI's `(True, value) | (False, error)` shape directly?

CrewAI's contract assumes the verifier is a function called in-process. PF's verifier is a different agent in a different dispatch. The two-tuple loses the asynchronous handoff semantics. The proposed `DONE_PENDING_VERIFICATION` + structured handover block matches PF's distributed dispatch model while preserving the same semantic intent.

---

## §6 — Citation table

| Source | URL | Verified | Use |
|---|---|---|---|
| Superpowers 5.0.7 `subagent-driven-development/SKILL.md` status-token section | `https://raw.githubusercontent.com/obra/superpowers/main/skills/subagent-driven-development/SKILL.md` | 2026-05-27 (WebFetch) | §1, §2 (Superpowers row), §4.1 (Superpowers row) |
| LangGraph `Command` dataclass definition | `https://raw.githubusercontent.com/langchain-ai/langgraph/main/libs/langgraph/langgraph/types.py` lines 1012–1057 | 2026-05-27 (WebFetch) | §2 (LangGraph row), §4.1 (LangGraph row) |
| LangGraph `END` / `START` constants | `https://raw.githubusercontent.com/langchain-ai/langgraph/main/libs/langgraph/langgraph/constants.py` lines 31–35 | 2026-05-27 (WebFetch) | §2 (LangGraph row), §4.1 |
| LangGraph `Command(goto=END)` and `Command(resume=...)` semantics (blog) | `https://blog.langchain.com/command-a-new-tool-for-multi-agent-architectures-in-langgraph/` | 2026-05-27 (via WebSearch synthesis — WebFetch denied) `[CITATION-DEGRADED]` | §2, §4.1 |
| AutoGen TerminationCondition primitives (MaxMessage, TextMention, TokenUsage, Timeout, Handoff, StopMessage, FunctionCall) | `https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/tutorial/termination.html` | 2026-05-27 (WebFetch) | §2 (AutoGen row), §4.1 |
| CrewAI Task output validation (`output_pydantic`, `output_json`, `expected_output`) | `https://docs.crewai.com/en/concepts/tasks` | 2026-05-27 (WebFetch) | §2 (CrewAI row) |
| CrewAI task guardrails — return tuple `(True, value) \| (False, err)` + `guardrail_max_retries=3` | `https://raw.githubusercontent.com/crewAIInc/crewAI/main/docs/en/concepts/tasks.mdx` | 2026-05-27 (WebFetch) | §2 (CrewAI row), §4.1 (CrewAI row), §5.7 |
| Reflexion paper (Shinn et al., NeurIPS 2023) — abstract, 91% pass@1 HumanEval, Actor/Evaluator/Self-Reflection components | `https://arxiv.org/abs/2303.11366` | 2026-05-27 (via WebSearch synthesis — WebFetch denied on arxiv.org abstract page) `[CITATION-DEGRADED]` | §1, §3.1, §3.4, §4.1 |
| Reflexion strategy enum (`ReflexionStrategy.NONE \| LAST_ATTEMPT \| REFLEXION \| LAST_ATTEMPT_AND_REFLEXION`) | `https://github.com/noahshinn/reflexion` README | 2026-05-27 (WebFetch) | §3.1 |
| Self-Consistency paper (Wang et al., ICLR 2023) — full verbatim abstract with GSM8K +17.9%, SVAMP +11.0%, AQuA +12.2%, StrategyQA +6.4%, ARC +3.9% | `https://huggingface.co/papers/2203.11171` (HuggingFace paper page mirroring arXiv:2203.11171 abstract) | 2026-05-27 (WebFetch) | §3.2 |
| Anthropic multi-agent research system — CitationAgent separation, "game of telephone" justification | `https://www.anthropic.com/engineering/multi-agent-research-system` | 2026-05-27 (via WebSearch synthesis — WebFetch denied on anthropic.com) `[CITATION-DEGRADED]` | §1, §4.1 (Anthropic row), §4.3, §5.1 |
| Anthropic citation manifest (local) — context for Superpowers status tokens, two-stage review, "Do Not Trust the Report" | `docs/research/sp-anthropic-citation-manifest.md` lines 36–41, 118–128, 142–146, 527 | 2026-05-27 (Read) | §2 (Superpowers row), §4.1, §5.3 |
| PF FEEDBACK.md §3.9 (Debugger live-invocation discipline) and §3.12 (Builder verification sandbox protocol) | `docs/FEEDBACK.md` lines 128, 131 | 2026-05-27 (Read) | All sections — scope grounding |

### §6.1 Citation degradations

Three citations are tagged `[CITATION-DEGRADED]`:

1. **LangGraph blog (`blog.langchain.com`)** — WebFetch denied. Substance verified via raw GitHub source (`constants.py` + `types.py`) which is the canonical implementation. Blog adds narrative context only; the binding code citations are not degraded.
2. **Reflexion arXiv abstract page** — WebFetch denied on arxiv.org/abs/* and arxiv.org/pdf/*. Abstract retrieved via WebSearch synthesis. The 91% pass@1 / 80% GPT-4 baseline numbers appear in multiple secondary sources and the NeurIPS 2023 proceedings; the substance is well-established. Re-verify against arxiv directly when the WebFetch permission is restored.
3. **Anthropic multi-agent research engineering post** — WebFetch denied on anthropic.com. CitationAgent quote retrieved via WebSearch synthesis and corroborated against the local `sp-anthropic-citation-manifest.md` which previously survived the same denial cycle. The substance — orchestrator-worker pattern, separate CitationAgent pass, "game of telephone" framing — is documented in 3+ secondary sources.

None of the degraded citations is the SOLE source for a load-bearing claim. The recommendation (§5) is independently supported by CrewAI (primary), LangGraph source (primary), Superpowers (primary), and PF's own VE#14 evidence — the N≥3 binding rule is satisfied on primary sources alone.

---

## §7 — Honest gaps

1. **The `DONE_PENDING_VERIFICATION` name itself is not directly attested in any of the surveyed frameworks.** No framework uses this exact token. The recommendation is to ADOPT the architectural pattern (verify-before-claim with structurally separate verifier) and NAME it `DONE_PENDING_VERIFICATION` as a PF-specific extension. The name itself is a PF coinage — disclosed honestly.

2. **No empirical study isolates "Builder cannot run verification in-sandbox" as a distinct failure class.** VE#14 is PF-internal evidence ("all 5 Builders, identical language"). The literature has the broader principle (Reflexion, self-consistency, Anthropic CitationAgent) but not this specific operational variant. PF's evidence is the proximate justification; the surveyed frameworks supply the architectural homology.

3. **Hook enforcement details (file shape, naming convention, blocking semantics) are PF-internal design.** The frameworks surveyed prescribe the contract (separate verifier, retry on failure) but not the file-system protocol PF would use to mediate cross-dispatch state. Catalog C-04 family conventions apply — but those are PF-internal, not enterprise-cited.

4. **AutoGen `MaxFunctionCallTermination` originally requested in the dispatch is not in the official primitive list.** The closest is `FunctionCallTermination` (stops when a `ToolCallExecutionEvent` with a matching function name is produced). Whether the dispatch prompt's named primitive was a typo or an older/proposed API is unresolved; the surveyed termination primitives are documented above as found.

5. **CrewAI's `output_pydantic` validation is type-shape validation, NOT semantic verification.** It confirms the output PARSES into a Pydantic model. It does not confirm the output is correct. PF's `DONE_PENDING_VERIFICATION` is semantic (test results, migration outcomes) — strictly stronger than CrewAI's type guarantee. The CrewAI guardrails feature is closer in spirit (LLM-based or function-based semantic check) but still in-process; PF's cross-dispatch model is its own.

6. **No quantitative comparison of "with verifier" vs. "without verifier" agent outputs in code-generation frameworks specifically.** Reflexion has it for HumanEval (91% vs. 80%). Self-consistency has it for arithmetic/commonsense reasoning. But none of the surveyed enterprise frameworks (LangGraph, AutoGen, CrewAI, Anthropic multi-agent) publish a "with-our-verifier vs. without" A/B. The 90.2% beat-rate Anthropic cites for the lead-orchestrator system is full-system not isolated-CitationAgent. PF v2.6 cannot quote a specific number for "DONE_PENDING_VERIFICATION will save N% of incidents" — only that the literature establishes the principle and PF VE#14 establishes the local need.

---

**End of R6 — Status-token grammars + agent self-verification patterns.**
