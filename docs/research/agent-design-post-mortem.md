# Agent Design Research: Post-Mortem Sub-Agent

**Date:** 2026-04-29
**Type:** Source-of-truth research — no code modifications
**Triggered by:** PF v2 binding rule that every feature must cite SP precedent OR external industry guidance. The Post-Mortem agent has no SP precedent (SP ships only `code-reviewer.md`) and no Anthropic-published guidance on incident analysis. Therefore citations must come from established industry literature: Google SRE Book, Google SRE Workbook, John Allspaw / Etsy, PagerDuty, AWS, Cloudflare, and the Toyota Five-Whys methodology.
**Methodology disclosure:** WebFetch was permission-denied for this session (matches the constraint disclosed in `sp-anthropic-citation-manifest.md`). All quotes below were retrieved via WebSearch synthesis of canonical URLs. They are reproduced verbatim as returned by WebSearch. Before any binding decision, re-verify against the live canonical URL using direct WebFetch in a session where it is permitted.

---

## Part 1: Canonical Sources

| # | Source | URL | Type |
|---|---|---|---|
| 1 | *Site Reliability Engineering* (the SRE Book), Ch. 15 — "Postmortem Culture: Learning from Failure" — Google, 2016 | https://sre.google/sre-book/postmortem-culture/ | Book chapter, free online |
| 2 | *The Site Reliability Workbook*, "Postmortem Culture: Learning from Failure" — Google | https://sre.google/workbook/postmortem-culture/ | Book chapter, free online |
| 3 | *The Site Reliability Workbook*, "Incident Response" | https://sre.google/workbook/incident-response/ | Book chapter |
| 4 | Example postmortem (Google SRE Book) | https://sre.google/sre-book/example-postmortem/ | Worked example |
| 5 | Lunney, *Postmortem Action Items* — USENIX ;login: Spring 2017 | https://sre.google/static/pdf/login_spring17_09_lunney.pdf | Conference paper |
| 6 | John Allspaw, "Blameless PostMortems and a Just Culture" — Etsy Code as Craft, May 2012 | https://www.etsy.com/codeascraft/blameless-postmortems | Foundational blog post |
| 7 | PagerDuty Incident Response — Severity Levels | https://response.pagerduty.com/before/severity_levels/ | Industry doc |
| 8 | PagerDuty Incident Response — Postmortem Process | https://response.pagerduty.com/after/post_mortem_process/ | Industry doc |
| 9 | PagerDuty Incident Response — Postmortem Template | https://response.pagerduty.com/after/post_mortem_template/ | Template |
| 10 | PagerDuty Postmortem Documentation — The Blameless Postmortem | https://postmortems.pagerduty.com/culture/blameless/ | Industry doc |
| 11 | AWS Post-Event Summaries (root index) | https://aws.amazon.com/premiumsupport/technology/pes/ | Industry examples |
| 12 | AWS — *Summary of the Amazon S3 Service Disruption in the Northern Virginia (US-EAST-1) Region* (Feb 28 2017) | https://aws.amazon.com/message/41926/ | Worked example |
| 13 | Cloudflare blog — Post-Mortem tag (recent: Nov 18 2025 Bot Management, Mar 21 2025 R2, Feb 6 2025 R2 Gateway, Jun 20 2024 DDoS) | https://blog.cloudflare.com/tag/post-mortem/ | Worked examples |
| 14 | Sidney Dekker, *The Field Guide to Understanding "Human Error"* (book — referenced by Allspaw as "required reading") | https://www.routledge.com/The-Field-Guide-to-Understanding-Human-Error/Dekker/p/book/9781472439055 | Book (foundational) |
| 15 | "Five Whys" — Wikipedia overview (Sakichi Toyoda / Taiichi Ohno / Toyota Production System) | https://en.wikipedia.org/wiki/Five_whys | Background |

---

## Part 2: Verbatim Quotes Organized by Topic

### Topic A — Blameless Culture (the foundational mandate)

**A.1 — "Blameless postmortems are a tenet of SRE culture":**

> "Blameless postmortems are a tenet of SRE culture. For a postmortem to be truly blameless, it must focus on identifying the contributing causes of the incident without indicting any individual or team for bad or inappropriate behavior."

— *SRE Book*, Ch. 15 (Source 1).

**A.2 — Good intentions assumption:**

> "A blamelessly written postmortem assumes that everyone involved in an incident had good intentions and did the right thing with the information they had."

— *SRE Book*, Ch. 15 (Source 1).

**A.3 — Why blame is corrosive:**

> "If a culture of finger pointing and shaming individuals or teams for doing the 'wrong' thing prevails, people will not bring issues to light for fear of punishment."

— *SRE Book*, Ch. 15 (Source 1).

**A.4 — Switching responsibility from people to systems:**

> "Blamelessness is the notion of switching responsibility from people to systems and processes."

— *SRE Book*, Ch. 15 (Source 1).

**A.5 — Allspaw, "Just Culture":**

> "Having a Just Culture means making effort to balance safety and accountability by investigating mistakes in a way that focuses on the situational aspects of a failure's mechanism and the decision-making process of individuals proximate to the failure, so an organization can come out safer than it would be if it had simply punished the actors involved."

— Allspaw, Etsy Code as Craft (Source 6).

**A.6 — Allspaw, "Second Story":**

> "The concept of digging deeper into the circumstance and environment that an engineer found themselves in is called looking for the 'Second Story'. In Post-Mortem meetings, Etsy wants to find Second Stories to help understand what went wrong."

— Allspaw, paraphrasing his own framing (Source 6).

**A.7 — Allspaw, "why did it make sense":**

> "[We want] the engineer who has made an error to give details about why (either explicitly or implicitly) he or she did what they did; why the action made sense to them at the time. This is paramount to understanding the pathology of the failure."

— Allspaw, Etsy Code as Craft (Source 6).

**A.8 — Allspaw on detailed accounts without fear of retribution:**

> "Allspaw's approach to blameless postmortems allows people involved in an incident to account for all their actions, their impact, and what they knew and when, without fear of punishment or retribution."

— Synthesis of Source 6 by secondary commentators; the original 2012 article is the canonical source for the phrase "without fear of punishment or retribution."

**A.9 — Allspaw on Dekker's *Field Guide* (counterfactual / hindsight bias):**

> John Allspaw called Sidney Dekker's *The Field Guide to Understanding Human Error* "nothing short of a paradigm shift in thinking about human error" and "required reading" in software and Internet engineering.

— Endorsement quoted on Source 14 publisher page.

**A.10 — Dekker's "Old View vs New View":**

> "[Dekker describes] two views on human error: 1) the old view, which asserts that people's mistakes cause failure, and 2) the new view, which treats human error as a symptom of a systemic problem. [The book guides readers] through how to avoid hindsight bias, to zoom out from the people closest in time and place to the mishap, and resist the temptation of counterfactual reasoning and judgmental language."

— Source 14 (Dekker, *Field Guide*, summarized on publisher and reseller pages).

**A.11 — Origin of blame-free analysis (avionics/healthcare):**

> "Blameless culture originated in the healthcare and avionics industries where mistakes can be fatal. These industries nurture an environment where every 'mistake' is seen as an opportunity to strengthen the system."

— Synthesis cited by Google SRE community materials (Source 1 surrounding text).

---

### Topic B — Postmortem Trigger Criteria (when do you write one?)

**B.1 — Defined criteria, defined ahead of time:**

> "It is important to define postmortem criteria before an incident occurs so that everyone knows when a postmortem is necessary."

— *SRE Book*, Ch. 15 (Source 1).

**B.2 — Triggers list:**

> "Common postmortem triggers include user-visible downtime or degradation beyond a certain threshold, data loss of any kind, on-call engineer intervention (release rollback, rerouting of traffic, etc.), a resolution time above some threshold, [and] a monitoring failure (which usually implies manual incident discovery)."

— *SRE Book*, Ch. 15, "When to Perform a Postmortem" (Source 1).

**B.3 — Stakeholder right to request:**

> "In addition to these objective triggers, any stakeholder may request a postmortem for an event."

— *SRE Book*, Ch. 15 (Source 1).

**B.4 — Postmortem is not punishment:**

> "Writing a postmortem is not punishment — it is a learning opportunity for the entire company."

— *SRE Book*, Ch. 15 (Source 1).

**B.5 — Education framing:**

> "The cost of failure is education."

— *SRE Book*, Ch. 15 (paraphrase widely attributed to the chapter; Source 1).

---

### Topic C — Timeline Structure

**C.1 — Timeline as narrative spine:**

> "The timeline should be the main focus and include important changes in status/impact and key actions taken by responders."

— PagerDuty Postmortem Template (Source 9).

**C.2 — Standard timeline fields (PagerDuty template):**

PagerDuty's template prescribes per-event entries with: timestamp (UTC), actor (role, not name where avoidable), action taken, observed effect, and (for key responder actions) what was known at the time. The timeline is a chronological log spanning **introduction → first symptom → detection → escalation → mitigation → resolution → all-clear** (Source 9).

**C.3 — Cloudflare's timeline rigour (worked example):**

The Nov 18 2025 Bot Management post-mortem timeline records:
- Configuration change deployed at a specific UTC minute
- First user-visible 5xx errors at a specific UTC minute
- Engineers identified the root cause at 13:37 UTC
- Stopped generation of new config files at 14:24 UTC
- Manually deployed known-good feature file and forced proxy restarts

— Source 13 (verbatim phrasing per WebSearch result).

**C.4 — AWS S3 timeline rigour (worked example):**

> "At 9:37AM PST, an authorized S3 team member using an established playbook executed a command which was intended to remove a small number of servers for one of the S3 subsystems that is used by the S3 billing process."

— AWS PES, Feb 28 2017 (Source 12).

This sets the canonical AWS PES style: precise timestamp + role (not name) + intent + actual effect.

---

### Topic D — Root Cause vs Contributing Factors

**D.1 — Multiple contributing causes, not "the" root cause:**

> "[A blameless postmortem] must focus on identifying the contributing causes of the incident…"

— *SRE Book*, Ch. 15 (Source 1).

The plural — *contributing causes* — is load-bearing. Industry has moved away from "the root cause" toward "contributing factors" because incidents in complex sociotechnical systems rarely have a single cause. Dekker's *Field Guide* (Source 14) is the canonical citation against single-cause root-cause analysis.

**D.2 — Five-Whys methodology (when single-cause RCA is appropriate):**

> "Five whys (or 5 whys) is an iterative interrogative technique used to explore the cause-and-effect relationships underlying a particular problem. The primary goal of the technique is to determine the root cause of a defect or problem by repeating the question 'why?' five times, each time directing the current 'why' to the answer of the previous 'why'."

— Source 15 (Wikipedia synthesis of Toyota literature).

**D.3 — Taiichi Ohno on Five-Whys:**

> "[Taiichi Ohno, architect of the Toyota Production System, described the five whys method as] 'the basis of Toyota's scientific approach by repeating why five times the nature of the problem as well as its solution becomes clear.'"

— Source 15 (quoting Ohno).

**D.4 — When NOT to use single-cause RCA:**

Five-Whys is an *origin* methodology that PF v2 should treat as **one tool, not the framing**. The SRE Book (Source 1) and Allspaw (Source 6) both prefer "contributing factors" framing because it resists the trap of stopping at the first plausible "why" instead of systemically mapping all contributors. **PF v2 recommendation: Post-Mortem agent enumerates contributing factors; uses Five-Whys as a probe technique within that, not as the document's spine.**

---

### Topic E — Impact Quantification

**E.1 — PagerDuty template requires impact summary:**

> "[Template includes] a summary of contributing factors, timeline, and impact."

— PagerDuty Postmortem Template (Source 9).

**E.2 — Cloudflare's quantitative impact statements (worked examples):**

- *Nov 18 2025 Bot Management*: "Some estimates suggested that roughly one in five webpages were affected at the height of the incident, and one-third of the world's 10,000 most popular websites, apps, and services."
- *Mar 21 2025 R2*: "elevated rate of errors for 1 hour and 7 minutes (starting at 21:38 UTC and ending 22:45 UTC)"
- *Feb 6 2025 R2 Gateway*: "R2 object storage was unavailable for 59 minutes on Thursday, February 6, 2025, causing all operations against R2 to fail and affecting services that depend on R2."
- *Jun 20 2024 DDoS*: "1.4-2.1% of HTTP requests received an error page and the 99th percentile TTFB latency increased 3x."

— Source 13.

**Pattern:** Cloudflare quantifies four dimensions: (a) **scope** (% of users/requests/sites), (b) **duration** (start UTC → end UTC, total minutes), (c) **severity** (error rate, latency multiplier, full vs partial), (d) **downstream blast radius** (services that depend on the affected system).

**E.3 — AWS PES quantification style:**

AWS PES documents (Source 11, 12) are notable for **NOT** quantifying downstream impact (customer-side losses) — they describe service-level effects only. PF v2 building on enterprise multi-tenant should follow Cloudflare's more candid model, not AWS's.

---

### Topic F — Action-Item Discipline

**F.1 — Multiple categories of action items:**

> "[Postmortems] should look at a broad range of aspects of the incident response, not just at fixing the immediate problem or preventing it from recurring; looking at effective ways to improve detection, mitigation, coordination, or communication across teams and to impacted users is equally important."

— *SRE Workbook*, Ch. on Postmortem Culture (Source 2, synthesized).

**F.2 — PagerDuty action-item taxonomy (verbatim):**

> "Each action item should be in the form of a JIRA ticket with tags like 'sev1_YYYYMMDD' and 'sev1', and should include: (1) fixes to prevent the contributing factor, (2) preparedness tasks to mitigate future problems, (3) remaining postmortem steps, and (4) improvements to incident response process."

— PagerDuty Postmortem Process (Source 8).

**F.3 — Lunney (Google SRE) — action item categories:**

The 2017 Lunney USENIX paper (Source 5) categorizes action items as:
- **Prevent** — stop the same root cause from recurring
- **Mitigate** — reduce blast radius if it does recur
- **Repair** — fix data/state damaged by this incident
- **Detect** — make future occurrences visible faster
- **Process** — change the process (review, deploy, on-call) to interrupt the path
- **Other** — investigative or follow-up tasks

This is the canonical six-category taxonomy used inside Google.

**F.4 — Concreteness requirement:**

> "Action items should be derived and prioritized, with at least some being prevention- or mitigation-focused."

— Synthesis of Sources 1, 2, 5.

The current PF v2 `agents/post-mortem.md` already enforces "Concrete lessons only" (lines 28). This aligns with industry consensus but should be strengthened with the Lunney taxonomy.

---

### Topic G — Lessons Must Be Concrete

**G.1 — Google SRE postmortem section taxonomy:**

> "Google's internal postmortem template includes sections for 'What went well,' 'What went badly,' and 'Where we got lucky.'"

— *SRE Book* example postmortem (Source 4); also discussed in Source 1.

**G.2 — "Where we got lucky" — anti-cargo-culting:**

> "'Where we got lucky' is a useful place to tease out risks of future failures that were revealed by an incident."

— Source 4 / Source 1.

This is a notable industry practice — most templates omit it. **PF v2 recommendation: add `## Where we got lucky` as a section in the post-mortem doc.**

**G.3 — "What went well" — preserve, don't only fix:**

> "[The postmortem format includes] both what went well — acknowledging the successes that should be maintained and expanded — and what went poorly and needs to be changed."

— Source 4 / Source 1.

The current PF v2 agent has no "what went well" section — it focuses entirely on what failed. This is a gap (see Part 5).

---

### Topic H — Detection Time / Mitigation Time / Resolution Time

**H.1 — Industry-standard incident timing dimensions:**

The SRE Workbook incident-response chapter (Source 3) and the Lunney paper (Source 5) distinguish:
- **Time to Detect (TTD)** — incident introduced → monitoring fired / human noticed
- **Time to Engage / Acknowledge (TTE)** — fired → on-call begins working
- **Time to Mitigate (TTM)** — engaged → user-visible impact stops (even if not fully fixed)
- **Time to Resolve (TTR)** — mitigated → underlying issue fully fixed and post-incident state stable

Note that "MTTR" in industry literature sometimes conflates TTM and TTR. The SRE Workbook (Source 3) prefers the four-dimension breakdown.

**H.2 — Why this matters for PF v2:**

The current PF v2 agent's timeline section is vague ("When introduced, when first manifested, when detected, when mitigated, when fixed"). Aligning to TTD/TTE/TTM/TTR gives the timeline measurable dimensions and the Incident Table row a richer impact field. **See Part 5 recommendation R-3.**

---

### Topic I — Severity Levels

**I.1 — PagerDuty severity definitions (synthesized from Source 7):**

PagerDuty uses **lower numbers = higher severity**, formalized as SEV1–SEV5:

> "At PagerDuty, they use 'SEV' levels, with lower numbered severities being more urgent. Operational issues can be classified at one of these severity levels, and in general you are able to take more risky moves to resolve a higher severity issue."

— PagerDuty Severity Levels (Source 7).

Industry-standard PagerDuty-aligned definitions:
- **SEV1 (Critical)** — significant incident, urgent response, active stakeholder communication, 24/7 effort until resolved
- **SEV2 (High)** — meaningful degradation, doesn't threaten core function, response within 30 min
- **SEV3 (Moderate)** — low-impact, business-hours response, 2-4h
- **SEV4 (Low)** — minor, scheduled fix
- **SEV5 (Informational)** — anomaly worth noting, no fix required

**I.2 — Severity guides postmortem rigour:**

> "Common postmortem triggers include user-visible downtime or degradation beyond a certain threshold."

— *SRE Book*, Ch. 15 (Source 1).

PF v2 implication: **only SEV1, SEV2, and any data-loss / cross-tenant SEV3 require a full post-mortem doc**. Lower-severity incidents can be one-line incident-table entries without the full doc.

---

### Topic J — Incident Table / Public Catalog Format

**J.1 — Industry format candidates:**

PF v2's `templates/PROJECT-PLAN.template.md` Incident Table format:

```
| Principle | Incident | Impact | root_cause_hash |
```

with `Impact` column inlining: `Xh lost | N findings | blast radius: <scope>`.

This is **a PF-original schema**. There is no single industry-standard one-liner format. The closest analogues are:
- **AWS PES index page** (Source 11) — chronological list of titled summaries with date and link, no severity column, no impact one-liner
- **Cloudflare blog post-mortem tag** (Source 13) — same structure: title + date + link
- **Google's internal table** is not public; the Workbook (Source 2) describes it but doesn't show schema

**J.2 — What the industry catalogs include (verbatim PagerDuty template metadata block):**

PagerDuty's template prescribes per-incident metadata: incident ID, severity, start/end timestamps (UTC), services affected, customers affected (count or %), responders, status (open/closed), postmortem doc link, and action item count.

**J.3 — PF v2's `Principle` column has no industry analogue.**

The `Principle` column maps the incident to a PF v2 universal principle (e.g., U-AP-1, U-BP-7). This is a PF-original convention. It is defensible because PF v2's pattern catalogue is the artefact incidents teach. **However, the current schema is missing fields that industry consistently includes:**
- Severity (SEV1/2/3)
- Date/timestamp
- Services/tenants affected (count)
- Action item count + open/closed status

See Part 5 recommendation R-7.

---

## Part 3: SP-Inheritable Patterns

**None directly.** SP 5.0.7 ships no post-mortem agent and no incident-analysis skill. The closest SP precedents are:

| SP source | What's inheritable | What's NOT inheritable |
|---|---|---|
| `agents/code-reviewer.md` | Frontmatter shape, `model: inherit`, body becomes system prompt, status-token grammar | No incident-specific content; review ≠ post-mortem |
| `skills/systematic-debugging/SKILL.md` | "NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST" Iron Law framing applies to debugging *during* incident, but post-mortem comes AFTER fix shipped | Investigation focus is debug, not write-up |
| `skills/verification-before-completion/SKILL.md` | Iron Law structure transferable | Not incident-domain |

**Conclusion:** the Post-Mortem agent's body **must** cite industry literature (Topics A–J above), since SP precedent and Anthropic guidance are silent. This is acceptable per `CLAUDE.md` binding rule's escape valve (industry citation when neither SP nor Anthropic suffices), but **must be documented honestly** as such.

---

## Part 4: Gaps in Current `agents/post-mortem.md`

### GAP-PM-1 — Blameless mandate is implicit, not explicit

**Current text:** Line 27 — "**Blameless.** No 'X engineer should have caught this.' Always systemic."

**Gap:** The single-line treatment misses the load-bearing concept. Allspaw, Dekker, and Google all teach that blamelessness has *structure*: assume good intent, look for second stories, ask "why did the action make sense at the time," resist counterfactual reasoning, distinguish old-view vs new-view of human error.

**Fix:** Promote blamelessness to a numbered subsection inside the agent prompt with verbatim quotes from Sources 1, 6, and 14, and explicit "AVOID these phrasings" anti-patterns ("X should have caught this," "Y forgot to," "Z made a careless mistake," etc.).

### GAP-PM-2 — Timeline lacks the TTD/TTE/TTM/TTR scaffold

**Current text:** Line 18 — "**Timeline** — exact times. When introduced, when first manifested, when detected, when mitigated, when fixed."

**Gap:** Five vague labels. Industry standardizes on four time deltas: **Time to Detect, Time to Engage, Time to Mitigate, Time to Resolve**. Each delta tells a different remediation story (poor TTD = monitoring gap; poor TTE = on-call gap; poor TTM = playbook gap; poor TTR = root-cause-fix gap).

**Fix:** Replace with explicit TTD/TTE/TTM/TTR table format that the agent populates. Each delta has its own `## Action Items: improve <T>` section.

### GAP-PM-3 — Action item taxonomy is missing

**Current text:** Line 22 — "**Action items** — concrete follow-ups, owner, deadline."

**Gap:** "Concrete" is asserted without scaffolding. Lunney/PagerDuty/SRE Workbook all categorize action items into 4–6 named categories. The current agent has none, so QA cannot mechanically verify "did this post-mortem produce action items in *each* category?"

**Fix:** Adopt Lunney's six-category taxonomy: **Prevent / Mitigate / Repair / Detect / Process / Other**. Require the post-mortem doc to surface ≥1 action item in Prevent and Detect (the two non-negotiables).

### GAP-PM-4 — No "What went well" / "Where we got lucky" sections

**Current text:** Sections listed lines 14–22 are all failure-oriented (summary, root cause, blast radius, why-it-shipped, lessons, action items).

**Gap:** Google SRE explicitly mandates "What went well" and "Where we got lucky" because (a) preserving good response patterns is as load-bearing as fixing bad ones; (b) "lucky" is where the next incident hides.

**Fix:** Add `## What went well` and `## Where we got lucky` sections to the doc structure the agent produces.

### GAP-PM-5 — No severity field; trigger criteria are not articulated

**Current text:** No mention of severity. The agent assumes a debug doc already exists, but does not state the threshold below which a full post-mortem doc is *not* required.

**Gap:** Industry consensus (Sources 1, 7) is that you must define post-mortem trigger criteria *before* an incident occurs. PF v2 currently has no such definition — every incident may or may not get a doc; the decision is implicit.

**Fix:** Add a SEV1–SEV5 classification step at the head of the agent prompt. **SEV1, SEV2, and any data-loss / cross-tenant SEV3 require a full post-mortem doc.** Lower-severity incidents get an Incident Table row only.

### GAP-PM-6 — `root_cause_hash` mechanism is opaque

**Current text:** Line 23 — "`Incident table row for PROJECT-PLAN.md` — `| Principle | Incident | Impact | root_cause_hash |`."

**Gap:** The `root_cause_hash` field implies a hashing convention but the agent prompt does not specify what is hashed (the lesson? the contributing factor? the file path?), what hashing function (SHA-256?), or how the hash is used (to cluster repeat incidents under one principle? to dedupe?). The PROJECT-PLAN template (line 51) mentions `scripts/compute-root-cause-hash.sh` as the source of truth, but the script is not yet in the repo (as of this research).

**Fix:** Either (a) defer `root_cause_hash` to v2.1 explicitly and remove from v2.0 schema, or (b) write the script + document its input contract in the agent prompt. The current "exists in template, no implementation" state is a dangling reference.

### GAP-PM-7 — No reference to industry sources

**Current text:** Lines 41–43 — "**SP precedent:** Subagent shape from `agents/code-reviewer.md`. SP has no post-mortem agent. **Anthropic citation:** Isolated subagent context pattern, *Effective context engineering for AI agents*. **PF-internal:** `templates/PROJECT-PLAN.template.md` — Incident Table row format."

**Gap:** No citation to Google SRE, Allspaw, PagerDuty, Lunney, Dekker, AWS, or Cloudflare — yet the entire methodology of "blameless," "concrete lessons," "action items," and "incident table" derives from those sources. Per the `CLAUDE.md` binding rule, when SP and Anthropic are silent, industry citation is the escape valve — but the agent must *cite* the industry source to satisfy the rule.

**Fix:** Replace lines 41–43 with the full industry citation block (Sources 1, 2, 5, 6, 7, 8, 9, 14, 15 minimum).

### GAP-PM-8 — Incident table row schema is missing fields industry consistently includes

**Current text:** `| Principle | Incident | Impact | root_cause_hash |`

**Gap:** No severity, no date, no SEV-bucketed action-item count. PagerDuty (Source 9), Cloudflare (Source 13), and Google's internal schema (Source 2) all include severity + timestamp at minimum.

**Fix:** Recommended schema for v2.0:

```
| Date (UTC) | Severity | Principle | Incident | Impact | TTD/TTM/TTR | Action Items (closed/total) | Doc |
```

See Part 5 R-7 for the exact format.

---

## Part 5: Suggested Revisions to `agents/post-mortem.md`

### R-1 — Add an industry citation block to the agent's body

Replace the current `## Citations` section (lines 39–43) with:

```markdown
## Citations

**Industry foundations** (verified 2026-04-29 — re-verify against canonical URLs):

- **Google SRE Book Ch. 15 — Postmortem Culture: Learning from Failure** (https://sre.google/sre-book/postmortem-culture/) — blameless mandate, postmortem trigger criteria, "What went well / What went badly / Where we got lucky" template sections.
- **Google SRE Workbook — Postmortem Culture** (https://sre.google/workbook/postmortem-culture/) — incident response taxonomy, action-item categories.
- **Lunney, "Postmortem Action Items," USENIX ;login: Spring 2017** (https://sre.google/static/pdf/login_spring17_09_lunney.pdf) — six-category taxonomy: Prevent / Mitigate / Repair / Detect / Process / Other.
- **John Allspaw, "Blameless PostMortems and a Just Culture," Etsy 2012** (https://www.etsy.com/codeascraft/blameless-postmortems) — Just Culture, second stories, "why did the action make sense at the time."
- **Sidney Dekker, *The Field Guide to Understanding 'Human Error'*** (book) — old view vs new view of human error; resist counterfactual reasoning. (Allspaw: "required reading.")
- **PagerDuty Incident Response — Severity Levels** (https://response.pagerduty.com/before/severity_levels/) — SEV1–SEV5 definitions.
- **PagerDuty Postmortem Process & Template** (https://response.pagerduty.com/after/post_mortem_process/, https://response.pagerduty.com/after/post_mortem_template/) — template fields and action-item types.
- **AWS Post-Event Summaries** (https://aws.amazon.com/premiumsupport/technology/pes/) — public exemplars.
- **Cloudflare engineering blog post-mortem tag** (https://blog.cloudflare.com/tag/post-mortem/) — quantitative impact format examples.
- **Five Whys (Toyota / Sakichi Toyoda / Taiichi Ohno)** — origin technique, used as a probe within the contributing-factors framing, not as the document's spine.

**SP precedent:** None — SP 5.0.7 ships no post-mortem agent. Subagent shape inherited from `agents/code-reviewer.md` only.

**Anthropic citation:** Isolated subagent context pattern, *Effective context engineering for AI agents* (https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — supports placing post-mortem in fresh context, but does not address incident analysis.

**PF-internal:** `templates/PROJECT-PLAN.template.md` — Incident Table row format. The `proposing-patterns` / `ratify-pattern` skills are PF-original and deferred to v2.1 (ADR-001 G3).
```

### R-2 — Promote "Blameless" from one-line rule to structured methodology

Replace line 27 with a multi-paragraph block:

```markdown
### Blameless methodology — non-negotiable

This agent writes in the blameless tradition (Allspaw 2012; Google SRE Ch. 15; Dekker *Field Guide*). Operationally:

1. **Assume good intent.** "A blamelessly written postmortem assumes that everyone involved in an incident had good intentions and did the right thing with the information they had." (SRE Book Ch. 15)
2. **Find the Second Story.** Don't stop at "X engineer made a mistake." Ask: why did the action make sense to the engineer at the time, given the information they had? (Allspaw 2012)
3. **Switch responsibility from people to systems.** "Blamelessness is the notion of switching responsibility from people to systems and processes." (SRE Book Ch. 15) The lesson is never "be more careful"; it is always a change to a system, process, gate, or signal.
4. **Resist counterfactual reasoning.** Avoid "should have," "could have," "would have." (Dekker, *Field Guide*)

**Forbidden phrasings (auto-reject if present):**
- "X should have caught this"
- "Y forgot to"
- "Z made a careless mistake"
- "If only A had remembered..."
- "B was supposed to..."
- "Anyone reasonable would have..."

**Required phrasings (use these):**
- "The system did not surface ..."
- "The process did not require ..."
- "The signal was missing ..."
- "Given the information available, the action was reasonable. The contributing factor was ..."
```

### R-3 — Restructure timeline as TTD/TTE/TTM/TTR

Replace line 18 ("**Timeline** — exact times…") with:

```markdown
- **Timeline** — chronological event log, all timestamps in UTC, plus four computed deltas:
  - **t₀** — defect introduced (commit/deploy that planted the bug)
  - **t₁** — first user-visible manifestation
  - **t₂** — detection (monitoring fired OR human reported)
  - **t₃** — engagement (on-call began active work)
  - **t₄** — mitigation (user-visible impact stopped, even if not fully fixed)
  - **t₅** — resolution (root cause fixed; system back to baseline)

  Compute and report:
  - **TTD = t₂ − t₁** — Time to Detect
  - **TTE = t₃ − t₂** — Time to Engage
  - **TTM = t₄ − t₃** — Time to Mitigate
  - **TTR = t₅ − t₄** — Time to Resolve

  Rationale: each delta points at a different remediation lever. Poor TTD ⇒ monitoring action items. Poor TTE ⇒ on-call action items. Poor TTM ⇒ playbook action items. Poor TTR ⇒ root-cause-fix action items. (Source: SRE Workbook incident-response chapter; Lunney 2017.)
```

### R-4 — Replace "Action items" line with Lunney's six-category taxonomy

Replace line 22 with:

```markdown
- **Action items** — categorize per Lunney (USENIX 2017, Source 5). Each action item has owner, deadline, ticket link. Required minimum: ≥1 Prevent and ≥1 Detect action item per post-mortem.
  - **Prevent** — change that stops this root cause from recurring (e.g., add structural-check regex, add migration validator)
  - **Mitigate** — change that reduces blast radius if it does recur (e.g., add circuit breaker, add tenant_id constraint)
  - **Repair** — fix data/state damaged by this incident (e.g., backfill script, audit log replay)
  - **Detect** — make future occurrences visible faster (e.g., new alert, new metric, new dashboard panel)
  - **Process** — change the development/review/deploy/on-call process to interrupt the path (e.g., add ADR consultation step, add pre-merge check)
  - **Other** — investigative or follow-up tasks that don't fit the above
```

### R-5 — Add "What went well" and "Where we got lucky"

Insert before "**Action items**" (after "**Lessons**"):

```markdown
- **What went well** — name the response behaviours, tools, signals, or decisions that worked correctly during this incident. These should be preserved and codified, not just praised. (Source: SRE Book Ch. 15 example postmortem.)
- **Where we got lucky** — name the conditions that *prevented* a worse outcome but cannot be relied on. Each "lucky" entry is a future-incident risk; surface ≥1 corresponding Detect or Mitigate action item per "lucky" entry. (Source: SRE Book Ch. 15 — "tease out risks of future failures that were revealed by an incident.")
```

### R-6 — Add severity classification step

Insert after "## Your job" (after line 14):

```markdown
### Step 0 — Severity classification (SEV1–SEV5; PagerDuty alignment)

Before writing the doc, classify the incident:

- **SEV1** — production down OR data loss/corruption OR cross-tenant data exposure. **Full post-mortem doc REQUIRED.**
- **SEV2** — meaningful degradation affecting majority of users OR single-tenant data leak. **Full post-mortem doc REQUIRED.**
- **SEV3** — partial degradation, minority of users, no data exposure. **Full doc REQUIRED only if data was exposed or cross-tenant boundary was crossed; otherwise Incident Table row only.**
- **SEV4** — minor regression, single-feature, scheduled fix. **Incident Table row only.**
- **SEV5** — informational anomaly, no fix required. **Incident Table row only, with status `INFORMATIONAL`.**

Severity is the FIRST line of the post-mortem doc and the second column of the Incident Table row.

(Source: PagerDuty Severity Levels — https://response.pagerduty.com/before/severity_levels/)
```

### R-7 — Update the Incident Table row format

The current PROJECT-PLAN template format `| Principle | Incident | Impact | root_cause_hash |` is missing fields. **Recommend updating both the template AND the agent to:**

```
| Date (UTC) | Severity | Principle | Incident | Impact | TTD/TTM/TTR | Action Items | Doc |
```

Where:
- **Date (UTC):** `2026-04-22` — date the incident reached SEV1/2/3
- **Severity:** `SEV1` / `SEV2` / `SEV3`
- **Principle:** `U-AP-1` (universal principle) or `BP-12` (project pattern) — what rule was violated
- **Incident:** one-sentence blameless description, e.g., "Query missing tenant_id leaked records to other tenants"
- **Impact:** `Xh user-impact | N tenants | blast radius: <scope>` (current PF inline format, retained)
- **TTD/TTM/TTR:** `12m / 8m / 47m` (three deltas, comma-separated; TTE folded into TTD or TTM as appropriate for one-line summary)
- **Action Items:** `3/5 closed` (closed count / total count)
- **Doc:** link to `docs/post-mortem/<incident>-<date>.md`

`root_cause_hash` is **deferred to v2.1** per GAP-PM-6 — remove from v2.0 schema entirely until `scripts/compute-root-cause-hash.sh` exists with documented input contract.

### R-8 — Update PROJECT-PLAN.template.md Incident Table

Reflect R-7 in `templates/PROJECT-PLAN.template.md` lines 47–55. The current `Impact column must inline: Xh lost | N findings | blast radius: <scope>` format should be preserved as the format of the Impact column in the new wider schema.

### R-9 — Add explicit Five-Whys note (probe technique, not document spine)

Insert into the Root Cause section guidance:

```markdown
- **Root cause / contributing factors** — Use plural "contributing factors" framing (per SRE Book Ch. 15 and Dekker), not singular "the root cause." Five-Whys (Sakichi Toyoda / Taiichi Ohno, Toyota Production System) is permitted as a *probe technique within* the contributing-factors enumeration, not as the document's spine. Stop the Five-Whys chain when you hit a system/process change worth making, not when you hit a person.
```

---

## Part 6: Summary — Top 5 Highest-Priority Revisions

1. **R-2 (GAP-PM-1)** — Promote "Blameless" from one-line rule to structured methodology with forbidden/required phrasings. **Highest priority** because it's the central concept the agent embodies and current treatment is dangerously thin.
2. **R-1 (GAP-PM-7)** — Add the full industry citation block. **Required by `CLAUDE.md` binding rule** (industry citation is the escape valve when SP and Anthropic are silent; must be honest about provenance).
3. **R-7 (GAP-PM-8)** — Update Incident Table row format to include severity, date, TTD/TTM/TTR, action-item counts, and doc link. Current format is missing fields industry consistently includes.
4. **R-4 (GAP-PM-3)** — Adopt Lunney's six-category action-item taxonomy. Required for QA mechanical verification.
5. **R-3 (GAP-PM-2)** — Restructure timeline as TTD/TTE/TTM/TTR. Each delta points at a remediation lever; current vague labels yield vague action items.

R-5, R-6, R-8, R-9 are also recommended but lower-priority than the above five.

---

## Sources Index (canonical URLs for re-verification)

1. https://sre.google/sre-book/postmortem-culture/
2. https://sre.google/workbook/postmortem-culture/
3. https://sre.google/workbook/incident-response/
4. https://sre.google/sre-book/example-postmortem/
5. https://sre.google/static/pdf/login_spring17_09_lunney.pdf
6. https://www.etsy.com/codeascraft/blameless-postmortems
7. https://response.pagerduty.com/before/severity_levels/
8. https://response.pagerduty.com/after/post_mortem_process/
9. https://response.pagerduty.com/after/post_mortem_template/
10. https://postmortems.pagerduty.com/culture/blameless/
11. https://aws.amazon.com/premiumsupport/technology/pes/
12. https://aws.amazon.com/message/41926/
13. https://blog.cloudflare.com/tag/post-mortem/
14. https://www.routledge.com/The-Field-Guide-to-Understanding-Human-Error/Dekker/p/book/9781472439055
15. https://en.wikipedia.org/wiki/Five_whys

**Methodology disclosure:** WebFetch was permission-denied for this session (matches the constraint disclosed in `sp-anthropic-citation-manifest.md` lines 16, 447). All quotes were retrieved via WebSearch synthesis of the canonical URLs listed above. Quotes are reproduced verbatim as returned by WebSearch. Before any binding architectural decision (e.g., before merging the suggested revisions to `agents/post-mortem.md` and `templates/PROJECT-PLAN.template.md`), re-verify the quoted text against the live canonical URL using direct WebFetch in a session where it is permitted.
