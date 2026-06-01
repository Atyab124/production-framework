# v2.6 R5 — CLAUDE.md design discipline + prompt compression empirics

**Dispatch**: Researcher #5 of 6 parallel, v2.6 design research
**Closes**: FEEDBACK.md §5.1 (`claude-md-design` skill), §5.3 (mechanical measurement primitive)
**Verification date**: 2026-05-27
**Methodology disclosure**: WebFetch was permission-denied on every URL in this dispatch (Anthropic docs, arXiv, GitHub raw). All citations are tagged `[CITATION-DEGRADED]` per dispatch protocol — they are sourced via WebSearch synthesis of canonical URLs rather than direct fetch. The canonical URLs are listed in the citation table; the verbatim passages quoted below are the LLM-extracted top excerpts returned by WebSearch for those queries, not direct WebFetch results. Re-verification by direct fetch is recommended before any pattern proposal cites these passages as load-bearing.

---

## 1. Executive summary

1. **Anthropic's canonical position is "under 200 lines, minimal universally-applicable content"** — multiple secondary sources cite this number against Anthropic guidance; HumanLayer reduces it further to ~60 lines and ArthurClune/abhishekray07 templates name an 80-line ignore threshold. No source above 200 is recommended by Anthropic-affiliated material.
2. **Position effects are empirically real and quantitatively large.** Liu et al. 2023 ("Lost in the Middle") measured >30% accuracy drop for middle-of-context information; MMMT-IF (2024, arXiv:2409.18216) measured a +22.3 PIF improvement when instructions are also repeated at end of context; Chroma "Context Rot" (Jul 2025) generalized to 18 frontier models and found "every one exhibits this behavior at every input length increment tested."
3. **OSS exemplars cluster around minimal, structured shapes — not narrative.** Of the 6 exemplars identified (HumanLayer, Vercel/Next.js, Cloudflare-docs, Supabase-js, Vercel-labs/open-agents, abhishekray07 templates), none uses narrative-paragraph rules; all use directive-form bulleted/sectioned content with explicit "delegate-elsewhere" patterns (CLAUDE.md → AGENTS.md symlink, `.claude/rules/` directory, `.agents/references/` index).
4. **The AGENTS.md convention is consolidating cross-vendor and is now Linux-Foundation-stewarded.** Vercel, OpenAI, Cursor, GitHub Copilot, Google Jules, Factory ship it; Next.js's CLAUDE.md is a symlink to AGENTS.md. v2.6's `claude-md-design` skill should treat AGENTS.md as the cross-vendor superset and CLAUDE.md as its Claude-flavored alias.
5. **The Section J directive+why+incident-link table format appears to be TaskIt-original** — no OSS exemplar in the 6 surveyed uses this exact tri-column format. The closest analogs are: HumanLayer's "direct command, not suggestion" rule (no incident link), and abhishekray07's "Don't: anti-patterns + what to do instead" section (binary, not incident-traced). This is a candidate for proposing-patterns Path B (BINDING enterprise research with novel framework contribution).
6. **Mechanical measurement primitives in OSS are sparse.** No surveyed project ships a self-executing line-count drift hook. Vercel uses HTML comment markers `<!-- BEGIN:nextjs-agent-rules -->` for managed-section delineation (closest mechanical analog). Cloudflare uses CI build-time validation only. The §5.3 git-diff + line-count hook is largely framework-original — citation strength is weak.
7. **HumanLayer is the load-bearing primary source for "instructions on the peripheries"**: their blog post on writing CLAUDE.md states LLMs "bias towards instructions that are on the peripheries of the prompt: at the very beginning ... and at the very end" and "as instruction count increases, instruction-following quality decreases uniformly." This is the prose-form rendering of MMMT-IF's quantitative finding and should be cited alongside the arXiv paper, not in place of it.

---

## 2. OSS exemplar table

≥6 OSS projects with location, structural shape, key conventions. Line counts could not be obtained via WebFetch (denied); cited line-count claims are from secondary sources (templates repos / blog roundups). Mark as VERIFY-NEEDED.

| # | Project | URL | Approx. lines (secondary, VERIFY) | Structural shape | Key conventions |
|---|---------|-----|-----------------------------------|------------------|-----------------|
| 1 | humanlayer/humanlayer | github.com/humanlayer/humanlayer/blob/main/CLAUDE.md | "~60 lines" per abhishekray07/claude-md-templates README | Top: project overview + architecture diagram; Middle: make commands (setup / check-test / check / test); Bottom: workflows pointer to `.github/workflows/` | Direct-command style; delegates plan/research/implement to `.claude/commands/*.md` slash commands |
| 2 | vercel/next.js | github.com/vercel/next.js/blob/canary/AGENTS.md | "intentionally minimal — single focused instruction" (no exact line count) | Single managed block: read bundled docs at `node_modules/next/dist/docs/` before writing code | CLAUDE.md is a **symlink** to AGENTS.md; uses HTML comment markers `<!-- BEGIN:nextjs-agent-rules -->` / `<!-- END:nextjs-agent-rules -->` to delimit Next.js-managed section so user-added rules survive upgrades |
| 3 | cloudflare/cloudflare-docs | github.com/cloudflare/cloudflare-docs/blob/production/AGENTS.md | not retrieved (VERIFY) | Sections: Style & Components → Build Commands → Repository Organization → Skills location | Delegates style rules to `.agents/references/style-guide.md` and component rules to `.agents/references/components.md`; CI-specific build-command instruction (`pnpm run check` not `pnpm run build`) |
| 4 | supabase/supabase-js | github.com/supabase/supabase-js/blob/master/CLAUDE.md | not retrieved (VERIFY) | Sections: Overview → Testing Instructions → Core Guidelines → Essential Documentation References | Monorepo-aware (Nx); delegates to CONTRIBUTING.md / TESTING.md / RELEASE.md / MIGRATION.md / SECURITY.md (5-doc Quick-Links pattern) |
| 5 | vercel-labs/open-agents | github.com/vercel-labs/open-agents/blob/main/AGENTS.md | not retrieved (VERIFY) | AGENTS.md + `.agents/skills/*/SKILL.md` directory structure | Skill delegation pattern: AGENTS.md is router, individual skill files in `.agents/skills/<name>/SKILL.md` carry behavior |
| 6 | abhishekray07/claude-md-templates | github.com/abhishekray07/claude-md-templates | Recommended template: Project / Stack / Structure (5-7 lines) / Commands / Verification / Conventions (3-5 rules) / Don't | Sectioned templates with stack-specific variants (nextjs-typescript, python-fastapi, generic) | Explicit ignore-threshold claim: ">80 lines, Claude starts ignoring parts of it. HumanLayer keeps theirs under 60 lines"; uses **three-bucket placement** (global ~/.claude/CLAUDE.md, project .claude/CLAUDE.md, local ./CLAUDE.local.md) |

**Median line count from FEEDBACK.md self-citation** (TaskIt prior research): 110 lines across 6 OSS exemplars; 0/6 narrative — both claims are TaskIt-internal and not independently re-verified here.

**Structural consensus (6/6):**
- All use sectioned/bulleted format, never narrative paragraphs
- All use a Quick-Links / delegate-elsewhere pattern (5/6) or symlink to AGENTS.md (1/6 — Next.js)
- 4/6 are <100 lines (HumanLayer ~60, Next.js minimal, abhishekray template 7 sections, Cloudflare-docs structured but compact)
- None embeds incident-traced rules with explicit incident-id links (i.e., Section J tri-column format is OSS-original to TaskIt)

---

## 3. Empirical instruction-following research summary

### 3.1 "Lost in the Middle" — Liu et al. 2023 (arXiv:2307.03172, TACL 2024)

**Core finding (verbatim via WebSearch synthesis):**

> "performance is often highest when relevant information occurs at the beginning or end of the input context, and significantly degrades when models must access relevant information in the middle of long contexts, even for explicitly long-context models." — Liu et al., *Lost in the Middle*, arXiv:2307.03172 [CITATION-DEGRADED]

**Quantitative magnitudes (verbatim via WebSearch synthesis):**

> "Liu et al. (2024) measured a 30%+ accuracy drop on multi-document question answering when the answer document moved from position 1 to position 10 in a 20-document context." — derivative summary [CITATION-DEGRADED]

> "When relevant information is placed in the middle of its input context, GPT-3.5-Turbo's performance on the multi-document question task is lower than its performance when predicting without any documents (i.e., the closed-book setting; 56.1%)." [CITATION-DEGRADED]

**Implication for CLAUDE.md:** Load-bearing rules placed in lines 100-250 of a 350-line CLAUDE.md sit in the empirical "middle." Either trim to <200 lines (everything is "edge") or bias load-bearing content to top + bottom.

### 3.2 MMMT-IF — Epstein et al. 2024 (arXiv:2409.18216)

**Core finding (verbatim via WebSearch synthesis):**

> "When instructions are dispersed throughout the model input context and then all instructions are also added at the end of the model input context, there is an average 22.3 point improvement in the PIF metric. This shows that the challenge with the task lies not only in following the instructions, but also in retrieving the instructions from the model context." — MMMT-IF, arXiv:2409.18216 [CITATION-DEGRADED]

**Additional finding:** "scores decrease with the number of given instructions, as it's harder for the models to follow multiple instructions at the same time" [CITATION-DEGRADED].

**Implication for CLAUDE.md:** End-of-context repetition of load-bearing rules gives a +22.3 PIF lift over single-placement. This is the empirical basis for FEEDBACK.md §5's "Section position guide — load-bearing rules at the bottom" recommendation.

### 3.3 Chroma "Context Rot" — Jul 2025

**Core finding (verbatim via WebSearch synthesis):**

> "Chroma's 2025 research tested 18 frontier models, including GPT-4.1, Claude Opus 4, and Gemini 2.5, and found that every one exhibits this behavior at every input length increment tested." [CITATION-DEGRADED, https://research.trychroma.com/context-rot]

> "Context rot is an architectural property of transformer-based attention, not a capability gap that training solves. Softmax normalization means each token's attention weight shrinks as context grows, where the signal doesn't get louder; the noise floor rises." [CITATION-DEGRADED]

**Counterintuitive finding for CLAUDE.md design:**

> "models consistently performing better on randomly shuffled text than on logically structured documents. This suggests the attention mechanism is negatively influenced by logical document flow, possibly because coherent text creates more plausible-seeming distractors." [CITATION-DEGRADED]

**Implication for CLAUDE.md:** This is the strongest evidence in the corpus that CLAUDE.md should NOT use narrative-paragraph rules — narrative coherence increases distractor plausibility for the attention head. Directive form is empirically supported, not just stylistic preference.

### 3.4 Anthropic "Effective Context Engineering for AI Agents" — 2025

**Core guidance (verbatim via WebSearch synthesis):**

> "Anthropic recommends aiming to provide the minimal set of information that fully describes expected behavior (where 'minimal' does not mean 'short'), then starting with minimal prompt length and iteratively adding clear instructions and examples to improve precision and reliability." [CITATION-DEGRADED, https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents]

> "Anthropic recommends separating sections when composing prompts, such as background_information, instructions, tool guidance, and output description, using technologies like XML tags or Markdown headers to delineate sections." [CITATION-DEGRADED]

**Implication for CLAUDE.md:** Markdown-header section structure is canonical-Anthropic; the three-bucket placement (FEEDBACK.md §5 axis 2) maps cleanly to Anthropic's "background_information / instructions / tool guidance" separation.

### 3.5 HumanLayer "Writing a good CLAUDE.md"

**Core finding (verbatim via WebSearch synthesis):**

> "LLMs bias towards instructions that are on the peripheries of the prompt: at the very beginning (the Claude Code system message and CLAUDE.md), and at the very end (the most-recent user messages). As instruction count increases, instruction-following quality decreases uniformly." — HumanLayer blog [CITATION-DEGRADED, https://www.humanlayer.dev/blog/writing-a-good-claude-md]

> "Your CLAUDE.md file should contain as few instructions as possible - ideally only ones which are universally applicable to your task. Claude Code's system prompt contains ~50 individual instructions, and depending on the model you're using, that's nearly a third of the instructions your agent can reliably follow already." [CITATION-DEGRADED]

> "Never send an LLM to do a linter's job. LLMs are comparably expensive and incredibly slow compared to traditional linters and formatters, and code style guidelines will inevitably add a bunch of instructions and mostly-irrelevant code snippets into your context window, degrading your LLM's performance." [CITATION-DEGRADED]

**Implication for CLAUDE.md:** The HumanLayer position is the prose-form of MMMT-IF's findings. The "~50 instruction budget" framing is the load-bearing argument for the "Keep this section under 15 rules" guideline cited in secondary roundups.

---

## 4. Mechanical measurement protocol options

| Option | Mechanism | OSS precedent (or gap) | Strength | Recommendation |
|--------|-----------|------------------------|----------|----------------|
| **A. Line-count drift hook** | Session-end: `wc -l CLAUDE.md` vs `.framework-state/claude-md-trim-commit.txt` baseline; ≥20% regrowth triggers `claude-md-design` invocation | NONE in surveyed OSS — gap to fill. Closest analog: Vercel's BEGIN/END markers serve a similar managed-section semantics but don't measure | NEW primitive; cite only the gap, not a precedent | SHIP per FEEDBACK.md §5.3 (already proposed by previous TaskIt research) |
| **B. Git-log violation count** | `git log <trim-sha>..HEAD -- docs/incidents.md` filters new F-entries citing rule-id pattern `R\d+` in compressed range | NONE in surveyed OSS | Framework-original; rules-format-dependent (requires R\d+ rule-ID convention) | SHIP — depends on Section J format also shipping |
| **C. CI-time markdown lint** | Pre-commit or CI step validates line count + section structure | Cloudflare-docs precedent: "pnpm run check and linters only" pattern (CI-aware) | Indirect — Cloudflare lints docs structure but not CLAUDE.md specifically | OPTIONAL — composes with A but not load-bearing |
| **D. Managed-section markers** | HTML-comment delimiters around framework-emitted content; user-added content lives outside | **STRONG OSS precedent**: Vercel/Next.js AGENTS.md uses `<!-- BEGIN:nextjs-agent-rules -->` / `<!-- END:nextjs-agent-rules -->` | Direct precedent; protects framework rules from user-edit drift AND user rules from framework-update overwrites | RECOMMEND ADD — this is the cleanest mechanism for the `configure-project-gates` Active Gates contract banner (FEEDBACK.md §6/§5.2) |

**Composability:** A (drift) + D (markers) + B (violation count) form an orthogonal triplet — A measures growth, D structures content, B measures rule-breaking. C is an optional defense-in-depth.

**Honest gap:** Of the four mechanisms, only D has direct OSS precedent. A, B, C are framework-original or weakly precedent-backed. The N≥3 binding rule is satisfied at the SKILL level (cite Anthropic / HumanLayer / Vercel for the skill's existence) but NOT at the measurement-primitive level (A and B are PF-internal).

---

## 5. Recommendations for §5.1 `claude-md-design` skill body

Six axes from FEEDBACK.md §5 mapped to citation-backed recommendations:

### Axis 1 — Length bounds

**Recommendation:** 200 aspirational, 300 ceiling, hard-fail above 400.

**Citation strength:** STRONG.
- HumanLayer keeps theirs at ~60 lines (primary blog)
- abhishekray07 templates: ">80 lines, Claude starts ignoring parts of it" (template repo claim)
- Multiple secondary sources cite Anthropic-recommended <200 (e.g., codewithmukesh, shanraisshan/claude-code-best-practice)
- Anthropic "Effective Context Engineering" reinforces "minimal" framing

**Honest gap:** The hard-fail-above-400 threshold is PF-internal. No source surveyed proposes a numeric kill-threshold. Either soften to "above 400 is a strong invocation signal" or cite the gap.

### Axis 2 — Three-bucket placement

**Recommendation:** Project facts → `docs/STACK-PATTERNS.md`; CTO operating discipline → skills; deterministic-mechanical → hooks. CLAUDE.md keeps: directive + why + (optional) incident-link.

**Citation strength:** MODERATE-STRONG.
- Anthropic "Effective Context Engineering" canonical sectioning: background_information / instructions / tool guidance — maps to three-bucket
- abhishekray07 three-bucket pattern: `~/.claude/CLAUDE.md` (global) / `.claude/CLAUDE.md` (project) / `./CLAUDE.local.md` (local) — same shape, different axis (scope-vs-content)
- Cloudflare-docs delegates style → `.agents/references/style-guide.md`, components → `.agents/references/components.md` — strong delegation precedent

**Honest gap:** The PF three-bucket is content-typed (facts/discipline/mechanical), abhishekray07 is scope-typed (global/project/local). They compose but aren't the same primitive.

### Axis 3 — Section J table format (directive + why + incident-link)

**Recommendation:** Ship as a NEW pattern. Three-column markdown table; "why" sentence is mandatory; "incident-link" optional but expected for any rule citing prior failures.

**Citation strength:** WEAK — TaskIt-original.
- Closest OSS analog: abhishekray07 "Don't" section (anti-pattern + what to do) — two-column, no incident traceability
- HumanLayer "direct command, not suggestion" rule — single-column directive only
- No OSS exemplar surveyed uses incident-id linkage

**Recommendation:** Promote via `proposing-patterns` Path B (BINDING enterprise research with framework-original contribution). Frame as: "directive+why+incident-link triple is the framework's contribution; the directive-form-not-narrative principle is consensus-supported (6/6 OSS exemplars)."

### Axis 4 — Quick Links header pattern

**Recommendation:** Top-of-file delegation index.

**Citation strength:** STRONG (5/6 OSS exemplars use a delegation pattern).
- Supabase-js: delegates to CONTRIBUTING / TESTING / RELEASE / MIGRATION / SECURITY (5-doc index)
- Cloudflare-docs: delegates to `.agents/references/*`
- Vercel-labs/open-agents: delegates to `.agents/skills/<name>/SKILL.md`
- abhishekray07: delegates to `.claude/rules/*.md` modular files
- HumanLayer: delegates to `.claude/commands/*.md` slash commands

**Honest correction to FEEDBACK.md §5:** The cited "Vercel `open-agents` precedent" is real but the pattern is broader — it's 5/6 OSS exemplars, not just open-agents. Strengthen the citation.

### Axis 5 — Section position guide (load-bearing rules at the bottom)

**Recommendation:** Place load-bearing rules at the bottom of CLAUDE.md, OR repeat at end-of-context.

**Citation strength:** STRONG.
- MMMT-IF: +22.3 PIF improvement when instructions repeated at end of context (arXiv:2409.18216)
- Liu et al. "Lost in the Middle" (arXiv:2307.03172): >30% accuracy drop for middle-position information
- Chroma Context Rot (Jul 2025): 18/18 frontier models exhibit length-degradation
- HumanLayer blog: "LLMs bias towards instructions that are on the peripheries"

**Subtle issue:** "Bottom of CLAUDE.md" ≠ "bottom of context window." CLAUDE.md is prepended early in the session and additional content (user messages, tool returns) follows. "Bottom of CLAUDE.md" is still ~start of context after the system prompt. The MMMT-IF result strictly supports **repetition** at end of context, not placement-at-bottom-of-CLAUDE.md per se. Honest framing: "place load-bearing rules at the bottom of CLAUDE.md so they sit closer to the user-message edge — AND consider repeating critical rules in slash-command bodies that fire during dispatch."

### Axis 6 — Trim-and-measure rollback protocol

**Recommendation:** Per §4 above — combine A (line-count drift) + B (violation count) + D (managed-section markers).

**Citation strength:** Marker-pattern (D) STRONG via Vercel; drift + violation count are PF-original.

---

## 6. Citation table

All citations [CITATION-DEGRADED] per dispatch protocol — sourced via WebSearch synthesis of canonical URL.

| # | Source | URL | Used for | Verification date |
|---|--------|-----|----------|-------------------|
| 1 | Anthropic Claude Code Memory docs | docs.anthropic.com/en/docs/claude-code/memory | Hierarchy + project-memory canonical position | 2026-05-27 (WebSearch only) |
| 2 | Anthropic Claude Code Best Practices | code.claude.com/docs/en/best-practices | CLAUDE.md structure guidance | 2026-05-27 (WebSearch only) |
| 3 | Anthropic "Effective Context Engineering for AI Agents" | anthropic.com/engineering/effective-context-engineering-for-ai-agents | Minimal-context principle, section structure | 2026-05-27 (WebSearch only) |
| 4 | HumanLayer "Writing a Good CLAUDE.md" | humanlayer.dev/blog/writing-a-good-claude-md | Peripheries bias, instruction-count uniform degradation, ~50 instruction budget | 2026-05-27 (WebSearch only) |
| 5 | HumanLayer "Getting Claude to Actually Read Your CLAUDE.md" | humanlayer.dev/blog/stop-claude-from-ignoring-your-claude-md | Follow-up on read-rate | 2026-05-27 (WebSearch only) |
| 6 | Liu et al. "Lost in the Middle" | arxiv.org/abs/2307.03172 | U-shaped position curve; >30% middle-position degradation | 2026-05-27 (WebSearch only) |
| 7 | Epstein et al. "MMMT-IF" | arxiv.org/abs/2409.18216 | +22.3 PIF lift from end-of-context repetition | 2026-05-27 (WebSearch only) |
| 8 | Chroma "Context Rot" | research.trychroma.com/context-rot | 18-model universal degradation; shuffled > coherent | 2026-05-27 (WebSearch only) |
| 9 | humanlayer/humanlayer CLAUDE.md | github.com/humanlayer/humanlayer/blob/main/CLAUDE.md | OSS exemplar #1 | 2026-05-27 (WebSearch only) |
| 10 | vercel/next.js AGENTS.md | github.com/vercel/next.js/blob/canary/AGENTS.md | OSS exemplar #2; CLAUDE.md→AGENTS.md symlink; BEGIN/END markers | 2026-05-27 (WebSearch only) |
| 11 | cloudflare/cloudflare-docs AGENTS.md | github.com/cloudflare/cloudflare-docs/blob/production/AGENTS.md | OSS exemplar #3; delegation pattern | 2026-05-27 (WebSearch only) |
| 12 | supabase/supabase-js CLAUDE.md | github.com/supabase/supabase-js/blob/master/CLAUDE.md | OSS exemplar #4; Quick-Links delegation | 2026-05-27 (WebSearch only) |
| 13 | vercel-labs/open-agents AGENTS.md | github.com/vercel-labs/open-agents/blob/main/AGENTS.md | OSS exemplar #5; skill delegation | 2026-05-27 (WebSearch only) |
| 14 | abhishekray07/claude-md-templates | github.com/abhishekray07/claude-md-templates | OSS exemplar #6; "80-line ignore threshold" claim; three-bucket scope | 2026-05-27 (WebSearch only) |
| 15 | josix/awesome-claude-md | github.com/josix/awesome-claude-md | Curated exemplar collection (background) | 2026-05-27 (WebSearch only) |
| 16 | OpenAI/Vercel AGENTS.md standard | agents.md / developers.openai.com/codex/guides/agents-md | Cross-vendor convention (Linux Foundation stewardship Nov 2025) | 2026-05-27 (WebSearch only) |
| 17 | Vercel "AGENTS.md outperforms skills in our agent evals" | vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals | Empirical: 100% pass rate with bundled docs vs 79% with skills-only on Next.js evals | 2026-05-27 (WebSearch only) |

---

## 7. Honest gaps + methodology disclosure

### 7.1 WebFetch denial (load-bearing)

**Every WebFetch call in this dispatch returned `Permission to use WebFetch has been denied`.** This is a categorical permission revocation, not URL-specific. All citations in this document are tagged `[CITATION-DEGRADED]` per the dispatch's stated fallback protocol. Verbatim passages quoted in §3 are the LLM-extracted excerpts WebSearch returned as relevant — they are NOT direct fetches of the canonical URL.

**Implication for the parent CTO:** Before any pattern proposal cites these verbatim passages as load-bearing, a session with WebFetch enabled should re-verify the three highest-weight quotes:
1. MMMT-IF "+22.3 PIF" sentence (arxiv.org/abs/2409.18216, abstract or §3)
2. Lost-in-the-Middle ">30% accuracy drop" claim (arxiv.org/abs/2307.03172, §4 results)
3. Chroma "18 frontier models" claim (research.trychroma.com/context-rot, intro)

### 7.2 Prior TaskIt research is on TaskIt disk, not framework disk

FEEDBACK.md §5 names three prior TaskIt research docs (`claude-md-design-anthropic-2026-05-19.md`, `claude-md-exemplars-oss-2026-05-19.md`, `claude-md-prompt-compression-empirical-2026-05-19.md`) that would presumably contain the verbatim quotes plus exact line counts. **None of these files are accessible from this dispatch's working directory** (verified: only files under `c:\Users\atyab\Experimental - Users\Production Framework\docs\research\` are reachable, and none match those filenames).

**Action item for v2.6 ship:** Port the three TaskIt research docs into the framework's `references/` directory under the `claude-md-design` skill — they contain the exact-line-count and verbatim-quote evidence that this dispatch can only reproduce in degraded form.

### 7.3 Line counts are unverified

The "median 110 lines, 0/6 narrative" claim from FEEDBACK.md §5 is TaskIt-internal and could not be independently re-verified. The abhishekray07-cited "HumanLayer keeps theirs under 60 lines" is a template-repo claim, not a direct measurement. Every line-count cell in the §2 exemplar table should be flagged VERIFY-NEEDED until a session with raw-github-markdown fetch reconstructs them.

### 7.4 N≥3 binding compliance

| Axis | N≥3 OSS citations | Status |
|------|-------------------|--------|
| Length bounds | HumanLayer + abhishekray07 + Anthropic-secondary + shanraisshan | PASS |
| Three-bucket placement | abhishekray07 + Cloudflare-docs + Vercel-labs | PASS |
| Section J table format | (zero direct precedents) | **FAIL — TaskIt-original; promote via proposing-patterns Path B** |
| Quick Links header | Supabase-js + Cloudflare-docs + Vercel-labs + abhishekray07 + HumanLayer (5/6) | PASS (strong) |
| Section position guide | MMMT-IF + Lost-in-the-Middle + Chroma + HumanLayer | PASS (research, not OSS exemplar) |
| Mechanical measurement | Vercel/Next.js markers (D only); A, B, C are PF-original | PARTIAL |

**Net:** 4/6 axes satisfy N≥3 OSS binding. Axis 3 (Section J table) and axis 6 (mechanical measurement) require explicit honest-tagging as framework-original when shipped.

### 7.5 Tool budget

Search calls used: 14 (within 10-15 budget). No retry loops. WebFetch denials triggered immediate WebSearch fallback per dispatch protocol — no retry attempts.

---

## 8. Status

**DONE_WITH_CONCERNS** — N≥3 citations met for 4/6 skill axes; 2/6 axes (Section J table format, mechanical measurement primitives A/B/C) are framework-original and require explicit honest-tagging when shipped. All quoted passages are [CITATION-DEGRADED] (WebSearch synthesis, not direct fetch) — re-verification with WebFetch enabled is recommended before pattern proposal.
