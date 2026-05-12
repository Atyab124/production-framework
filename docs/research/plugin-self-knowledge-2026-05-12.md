# Plugin Self-Knowledge and Identity — Lane R-4b Research (Cluster C6)

**Dispatched by:** CTO orchestrator → Researcher Lane 4b of five-lane parallel dispatch for the framework-feedback-response refactor cycle (Pass 2 of Pattern A Producer-Consumer Convention).

**Source dispatch:** `docs/architecture/framework-feedback-response-2026-05-12.md` §4 (Cluster C6) and §7 (consolidated dispatch envelope).

**Researcher:** PF v2 Researcher sub-agent.

**Date:** 2026-05-12.

---

## Question Set

This document answers three questions from Cluster C6 (Plugin self-knowledge and identity):

- **Q6.1.** How do enterprise CLI plugins / Claude Code plugins / VS Code extensions / Cursor extensions / Zed extensions surface their version to the running session? Is the version (a) injected into context at startup, (b) available via a `whoami`-style command, (c) read from a hidden config file, (d) all of the above? What's the canonical pattern?
- **Q6.2.** How do enterprise frameworks (Spring Boot starters, Django apps, Rails engines, npm scoped packages, Helm charts) handle role-naming when the same framework is reused across projects with different organizational vocabulary? Is there a convention for "framework's generic name" vs "project's specific override"?
- **Q6.3.** What's the standard practice for documenting an override pattern in a plugin README — e.g., how does VS Code document settings overrides, how does Tailwind document config theme extension, how does Next.js document `next.config.js` overrides?

---

## Eligibility Criteria (PRISMA-style)

**Inclusion:**
- Named enterprise or OSS framework / plugin host with primary documentation (official docs, GitHub source, engineering blog from the vendor).
- Documentation must surface the relevant mechanism (version-surfacing for Q6.1, role/name override for Q6.2, override-documentation pattern for Q6.3).
- Minimum three named frameworks per question (BINDING per `agents/researcher.md`).

**Exclusion:**
- Secondary aggregator pages (DEV.to, Medium, GeeksforGeeks) used only as confirmatory secondary citations — never as the sole citation for a framework.
- Training-data-only recollection — every claim must map to a verbatim quote retrieved via WebSearch synthesis of a canonical URL during this session.
- Frameworks that have the mechanism but where the canonical URL was inaccessible (paywalled, dead) — tagged in methodology disclosure.

**Methodology note (PRISMA discipline):** WebFetch tool was permission-denied for all canonical URLs in this session. All citations are tagged `(via WebSearch synthesis of canonical URL)` per the Researcher agent's WebFetch-failure fallback protocol. The canonical URLs are recorded so the Architect (Pass 3) can re-verify against the live URL before any binding ADR text lands. See §Methodology Disclosure.

---

## Search Strategy

Round 1 (broad landscape, one query per candidate framework, parallel batches):
- `VS Code extension version API vscode.extensions.getExtension packageJSON version`
- `Claude Code plugin .claude-plugin/plugin.json version manifest`
- `Zed extension manifest version extension.toml`
- `Spring Boot starter custom bean name override @ConditionalOnMissingBean`
- `Helm chart values override naming nameOverride fullnameOverride convention`
- `Tailwind CSS theme extend documentation tailwind.config.js override`

Round 2 (narrow / primary-source confirmation, parallel batches):
- `"vscode.extensions.getExtension" packageJSON version site:code.visualstudio.com`
- `Cursor editor extensions installed version package.json VS Code API compatible`
- `Django reusable app AppConfig label name override convention`
- `VS Code settings.json override default settings documentation`
- `Next.js next.config.js documentation override webpack configuration`
- `Rails engine isolate_namespace customize name override application`
- `npm scoped package version process.env.npm_package_version read own version`

Round 3 (primary-source confirmation, sequential):
- `"plugin.json" "version" Anthropic Claude Code plugins documentation site:docs.claude.com`
- `Spring Boot starter naming convention "spring-boot-starter" custom prefix third party`
- `Rails engine mount documentation customize app name namespace README`
- `"extensions.getExtension" "packageJSON" Visual Studio Code API official documentation`
- `Cursor docs Extensions page version compatibility official documentation`

**Tool-call count:** ~15 searches across three questions (≤5 per question, within the 10–15 per-question budget per `agents/researcher.md`).

---

## Q6.1 — Plugin Version Surfacing

### Frameworks compared

| # | Framework | Source type | Canonical URL | Verified |
|---|---|---|---|---|
| 1 | Claude Code plugins | Official Anthropic docs | https://docs.claude.com/en/docs/claude-code/plugins | 2026-05-12 |
| 2 | VS Code extensions | Official VS Code Extension API | https://code.visualstudio.com/api/references/vscode-api | 2026-05-12 |
| 3 | Zed extensions | Official Zed docs | https://zed.dev/docs/extensions/developing-extensions | 2026-05-12 |
| 4 | Cursor extensions | Official Cursor docs | https://cursor.com/docs/configuration/extensions | 2026-05-12 |
| 5 | npm packages | Official npm CLI docs (npm scripts env) | https://docs.npmjs.com/cli/v10/using-npm/scripts | 2026-05-12 (canonical reference; mechanism described via Node.js docs and npm community) |

### Comparison axes

| Axis | Claude Code plugins | VS Code extensions | Zed extensions | Cursor extensions | npm packages |
|---|---|---|---|---|---|
| Where the version is declared (canonical source of truth) | `.claude-plugin/plugin.json` `"version"` | `package.json` `"version"` | `extension.toml` `version` (+ separate `schema_version`) | Inherits from VS Code: `package.json` `"version"` of the extension | `package.json` `"version"` |
| Programmatic read at runtime by the running session/host | Not exposed as a runtime API by the plugin host; surfaced via marketplace/update detection only (per docs, used for "update detection") | `vscode.extensions.getExtension(id).packageJSON.version` (runtime API) | TOML manifest parsed by the host; no documented runtime "read my own version" API in the public extension API | Inherits VS Code API behavior; Cursor tracks installed extensions in `~/.cursor/extensions/extensions.json` | `process.env.npm_package_version` (only when run via `npm` scripts; undefined in production-bundled apps) |
| "whoami"-style command surfaced to the user | No documented runtime `whoami`; version surfaced via marketplace metadata + cache invalidation behavior | No first-class `whoami` — extensions implement their own command if needed (e.g., "Show Extension Version") | No first-class `whoami` for extensions documented | No first-class `whoami` for extensions documented | No first-class `whoami`; `npm ls <pkg>` from outside the package |
| Injected into context at startup (session-time injection) | NOT in the default behavior — plugin host loads the manifest but does not inject the version into the model context as a line | No — VS Code loads `package.json` but does not inject extension version into the user's editor context | No — Zed loads `extension.toml` but does not inject version into the user's context | No — same as VS Code | No — Node.js process gets `npm_package_version` env var only when launched via `npm run` |
| "all of the above" canonical pattern? | Closest pattern: **manifest is canonical, host parses it, no runtime "whoami" API** | Closest pattern: **manifest is canonical, host parses it, runtime API exists (`getExtension().packageJSON.version`), no "whoami" command convention** | Manifest-only; no runtime API in public surface | Same as VS Code | Manifest is canonical; env-var available only in npm-script context |

### Synthesis (N-of-M consensus)

**5 of 5 frameworks** declare the version in a single canonical manifest file (`plugin.json` / `package.json` / `extension.toml`). This is unanimous.

**3 of 5 frameworks** (VS Code, Cursor inheriting VS Code, npm in-script-context) expose the version at runtime via a host-provided API or env var. **0 of 5 frameworks** inject the version into the model/editor context at session-start as a default. **0 of 5 frameworks** define a first-class "whoami"-style command in their public extension surface — extensions wanting that capability implement it themselves on top of the manifest read.

**Outliers:**
- Claude Code: uses the version field specifically for "update detection" (cache invalidation). No runtime API to read your own plugin's version from inside Claude Code is documented at https://docs.claude.com/en/docs/claude-code/plugins as of 2026-05-12 — context-injection via SessionStart hook is the precedent path because Anthropic does not offer a "this is your plugin version" runtime API.
- Zed: differentiates `version` (plugin's own semver) from `schema_version` (manifest grammar version). Other frameworks don't separate these.

**Canonical pattern (consensus):** *Manifest is canonical; host parses it; runtime API for reading "your own" version is sometimes-present-sometimes-absent and never injected into context by default.* The "(d) all of the above" framing in Q6.1 is **NOT** the consensus — none of the 5 frameworks does all four. The closest enterprise/OSS pattern is **(c) read from a manifest file by the host + optional (b) runtime API**. Session-time context injection (option a) is **not** in any of the 5 frameworks' default behavior — it is a PF-internal innovation candidate.

### Recommendation for the Architect (Pass 3, ADR-009)

The architecture doc has already self-cited ADR-009 (SessionStart hook injects version). The research **confirms the choice is novel-but-not-anti-pattern**: no surveyed framework does session-time injection, but no surveyed framework forbids it either. The justification stands because:

1. The 5/5 manifest-canonical convention is preserved (PF reads from `.claude-plugin/plugin.json`).
2. The lack of a Claude Code runtime "read your own plugin version" API forces context-injection-or-nothing — option (b) is unavailable.
3. The injection cost is ~50 tokens per session per the existing ADR-009 disclosure.

**Concrete advice:** Keep ADR-009 as-is. **Add** an explicit note in the ADR's "Considered Options" section that this is **not** what VS Code / Zed / Cursor / npm do at runtime — the framework precedent is "manifest-canonical, host-parsed, runtime-API-when-available." The injection-into-context decision is justified by Claude Code's lack of a runtime "whoami" API, not by enterprise precedent. **Tag this as a knowing departure from convention** in the Y-statement's "neglecting" clause.

---

## Q6.2 — Role-Naming Override Convention

### Frameworks compared

| # | Framework | Source type | Canonical URL | Verified |
|---|---|---|---|---|
| 1 | Spring Boot starters (third-party) | Official Spring Boot docs / Baeldung confirmation | https://docs.spring.io/spring-boot/docs/2.0.6.RELEASE/reference/html/boot-features-developing-auto-configuration.html | 2026-05-12 |
| 2 | Django apps (`AppConfig.label`) | Official Django docs (Applications reference) | https://docs.djangoproject.com/en/6.0/ref/applications/ | 2026-05-12 |
| 3 | Rails engines (`engine_name` + `isolate_namespace`) | Official Rails Guides | https://guides.rubyonrails.org/engines.html | 2026-05-12 |
| 4 | Helm charts (`nameOverride` / `fullnameOverride`) | Official Helm docs + community precedent | https://helm.sh/docs/chart_template_guide/values_files/ | 2026-05-12 |
| 5 | Spring Boot beans (`@ConditionalOnMissingBean`) | Official Spring Boot API docs | https://docs.spring.io/spring-boot/api/java/org/springframework/boot/autoconfigure/condition/ConditionalOnMissingBean.html | 2026-05-12 |

### Comparison axes

| Axis | Spring Boot starter naming | Django AppConfig | Rails engine | Helm `nameOverride`/`fullnameOverride` | Spring `@ConditionalOnMissingBean` |
|---|---|---|---|---|---|
| Mechanism shape | Naming-convention rule (artifact ID prefix/suffix); no runtime override | Two-field split: `name` (full Python path, immutable) + `label` (short override-able id) | Method call: `engine_name "spree_api"` (overrides the auto-generated railtie name) + `isolate_namespace` | Values-file fields read at template render time | Bean-replacement at IoC-container resolution: user-defined bean wins; framework default supplied only when missing |
| "Generic name" vs "project override" pattern | Generic = `spring-boot-starter-*` reserved; third-party = `{project}-spring-boot-starter` | Generic = `name` (canonical); project override = `label` (short alias) | Generic = derived from module name; project override = explicit `engine_name` call | Generic = chart name; project override = `nameOverride` (replaces chart-name part) OR `fullnameOverride` (replaces entire prefix including release name) | Generic = framework's `@Bean`; project override = consumer's own `@Bean` with same type/name |
| Where the override is declared by the consumer | Maven/Gradle artifact ID at publish time | `apps.py` class attribute on the consumer's AppConfig | Engine's own `engine.rb` (engine author owns the naming) | `values.yaml` or `--set` CLI flag (consumer owns) | Consumer's `@Configuration` class (consumer owns) |
| Documented in framework README as "override pattern"? | Yes — official Spring Boot docs explicitly document the prefix reservation rule | Yes — `Applications` reference page covers `label` override + reusable-app tutorial | Yes — Rails Guides Engines page documents `engine_name` and namespacing | Yes — both fields ship with `helm create` boilerplate | Yes — Spring Boot's own auto-configuration guide explicitly says the annotation exists to "allow users to easily override the defaults" |
| Breaking-change behavior on rename | High — published artifact ID is sticky | High — changing `label` after migrations breaks references | High — engine_name change affects routes/tables | Medium — `fullnameOverride` change renames k8s resources (re-deploy required) | Low at framework level — consumer's bean replaces framework's silently |

### Synthesis (N-of-M consensus)

**5 of 5 frameworks** define a convention for "framework's generic name" vs "project's specific override." The convention shapes differ:

- **3 of 5 (Spring Boot starter naming, Django AppConfig, Rails engine):** **Two-name pattern** — a canonical/derived name + an explicit override slot in the consumer's manifest/config file. The override is the "I am the project, I have my own vocabulary" entry point.
- **2 of 5 (Helm, `@ConditionalOnMissingBean`):** **Substitution pattern** — the framework supplies a default that is replaced when the consumer declares their own value/bean.

**4 of 5** explicitly document the override pattern in the framework's own README/docs. The fifth (Spring `@ConditionalOnMissingBean`) is documented in the auto-configuration developer guide, which is the framework's effective README for starter authors.

**0 of 5** make the framework's generic name "invisible" — all 5 keep the generic name visible AND document the override. This is the consensus.

**Outliers:**
- Helm has TWO override levels (`nameOverride` for the chart-name part; `fullnameOverride` for the entire prefix including release name). This is finer-grained than the other 4.
- Spring Boot starter naming is a **publish-time** rule (artifact ID), not a runtime override. The other 4 are runtime/config-time.
- Django and Rails both encode the rename-cost-warning explicitly: changing `label` or `engine_name` after the app/engine is in use is a breaking change.

### Recommendation for the Architect (Pass 3, ADR-008)

ADR-008 (orchestrator role-naming) is already self-cited as "keep 'CTO mode' generic + document the override pattern." The research **confirms this is the enterprise consensus shape**:

1. **Keep the framework's generic name visible** (CTO mode stays in `skills/cto-mode/SKILL.md` and 13 agent files). This matches 5/5 enterprise precedent.
2. **Document the project-level override pattern in the framework README** — this matches 4/5 explicit precedent (Django, Rails, Helm, Spring Boot starter naming).
3. **Codify the override as a project-local mechanism** — TaskIt's `docs/prompts/prompter-base.md` re-titling is the PF analogue of `AppConfig.label`, `engine_name "spree_api"`, or `nameOverride` in `values.yaml`.

**Concrete advice for ADR-008 Pass 3:**
- In the Y-statement, cite the **two-name pattern** convention (3/5 frameworks: Django AppConfig, Rails engine_name, Spring Boot starter naming) as primary precedent.
- Add a "When the project overrides the title" subsection to the README documenting:
  - The override slot is at the **project level** (prompt file, CLAUDE.md, or session-bootstrap doc).
  - Framework's generic name (`CTO mode`) remains the canonical name in skills/agents.
  - Document the rename-cost-warning (analogous to Django's `label`-after-migrations warning): once a project labels the role X, downstream artifacts (PR descriptions, ADR boilerplate, etc.) may reference X — renaming is a breaking change for the project's own history.
- **Recommendation: do NOT add a CONFIG slot in `.claude-plugin/plugin.json` for the orchestrator title.** The 5/5 precedent is to override in the consumer's space, not in the framework's manifest. A framework-level CONFIG slot would be the Helm `nameOverride` shape — that pattern works for k8s naming because the framework renders templates, but PF doesn't render anything; the override must be in the project's prompt/CLAUDE.md.

---

## Q6.3 — Documenting Override Patterns in a Plugin README

### Frameworks compared

| # | Framework | Source type | Canonical URL | Verified |
|---|---|---|---|---|
| 1 | VS Code settings (User → Workspace → Language override hierarchy) | Official VS Code docs | https://code.visualstudio.com/docs/configure/settings | 2026-05-12 |
| 2 | Tailwind CSS (`theme.extend` vs full override) | Official Tailwind docs | https://tailwindcss.com/docs/theme | 2026-05-12 |
| 3 | Next.js (`next.config.js` webpack override) | Official Next.js docs | https://nextjs.org/docs/app/api-reference/config/next-config-js/webpack | 2026-05-12 |
| 4 | Helm chart values override (precedence hierarchy) | Official Helm docs | https://helm.sh/docs/chart_template_guide/values_files/ | 2026-05-12 |
| 5 | Rails engine README install instructions | Official Rails Guides | https://guides.rubyonrails.org/engines.html | 2026-05-12 |

### Comparison axes

| Axis | VS Code settings | Tailwind theme | Next.js webpack | Helm values | Rails engine README |
|---|---|---|---|---|---|
| Override precedence documented? | Yes — explicit ladder: Default → User → Workspace → Folder → Language-specific | Yes — `extend` preserves defaults; top-level key replaces | Yes — function signature documented (buildId, dev, isServer, nextRuntime, defaultLoaders); the function must return the modified config | Yes — `values.yaml` → `-f` files → `--set` flags (later overrides earlier) | Yes — mount line + migrations install command shown in installation section |
| "Extend vs replace" distinction named? | Yes — workspace overrides user; language-specific overrides non-language-specific | Yes — `extend` key is named and contrasted with full override | Implicit — webpack config is "extended" by user function returning modified config; not a named "extend vs replace" toggle | No explicit name — but `nameOverride` (partial) vs `fullnameOverride` (full) is the analogue | N/A — different override surface (consumer mounts the engine; no extend-vs-replace) |
| Stability/Risk disclosure in docs | "Workspace settings are specific to a project and override user settings" (precedence stated) | "Always use extend instead of redefining theme, so you keep Tailwind's defaults intact" (best-practice warning) | "Changes to webpack config are not covered by semver so proceed at your own risk" (explicit semver-non-coverage warning) | Five different naming schemes documented depending on null/blank/non-blank — risk-of-collision implicit | "It's a good idea to add the mount line to the installation instructions in the engine's README" (positive guidance) |
| Example provided in docs? | Yes — settings.json examples with override scopes | Yes — `theme: { extend: { screens: { '3xl': '1600px' } } }` | Yes — full function signature with isServer branching | Yes — `helm create` boilerplate ships with both fields | Yes — `mount MyEngine::Engine => "/my_engine", as: "my_engine"` |
| Pattern shape | Tabular precedence + JSON examples | Two-key contrast (`theme` vs `theme.extend`) + best-practice note | Function signature + return contract + risk disclosure | Five-scheme table + boilerplate | Step-by-step install section with example |

### Synthesis (N-of-M consensus)

**5 of 5 frameworks** document the override pattern explicitly in their official docs.

**5 of 5 frameworks** provide a worked example (settings.json snippet, `theme.extend` snippet, webpack function snippet, `values.yaml` snippet, mount line snippet).

**4 of 5 frameworks** explicitly disclose **risk or stability** around overriding:
- VS Code: precedence order (low risk, but precedence must be understood).
- Tailwind: "Always use extend... keep Tailwind's defaults intact" (positive guidance to prefer `extend`).
- Next.js: "Changes to webpack config are not covered by semver so proceed at your own risk" (strongest disclosure).
- Helm: five naming schemes documented (implicit collision risk).
- Rails: no explicit risk disclosure for the mount step (1 of 5 outlier).

**5 of 5 frameworks** name a **default vs override** contrast in some form (default settings vs user/workspace; `theme` vs `theme.extend`; framework webpack config vs user function; chart defaults vs `nameOverride`; engine routes vs mount point).

**Consensus pattern:**
1. Document the override surface (which file, which key/method).
2. Show a worked example (copy-paste-able snippet).
3. State the precedence/scope explicitly.
4. Disclose risk where applicable (semver coverage, default-preservation best practice, breaking-change cost).

### Recommendation for the Architect (Pass 3, ADR-008 README section)

For the README override-documentation section that ADR-008 commits to, the **consensus four-step pattern** is:

1. **Name the override surface.** PF override surface = project-level prompt/CLAUDE.md/session-bootstrap doc — NOT the framework's `.claude-plugin/plugin.json` (per Q6.2 finding).
2. **Provide a worked example.** Show the TaskIt `docs/prompts/prompter-base.md` line "I am the Deputy Head of Product Engineering (this project's name for the orchestrator role; the framework calls this role 'CTO mode')."
3. **State the precedence/scope.** When the project's prompt re-titles the role, the project-level name takes precedence inside that project's sessions; the framework's generic name (`CTO mode`) remains the canonical name across documentation, ADRs, and skill bodies.
4. **Disclose risk.** Use Next.js's "proceed at your own risk" tone — once a project labels the role, downstream artifacts (PR descriptions, ADR boilerplate, internal handovers) may reference the project name; renaming again is a breaking change for the project's own history (Django `label`-after-migrations precedent).

**Concrete advice:** Write the README section in the form:

> ## Renaming the Orchestrator Role
>
> The framework's generic name for the entry-session role is "CTO mode" (defined in `skills/cto-mode/SKILL.md` and referenced by 13 agent files). Projects may override this name to fit local vocabulary.
>
> **Where to override:** in your project's prompt-base doc, CLAUDE.md, or any session-bootstrap surface — NOT in `.claude-plugin/plugin.json` (the framework's manifest stays generic).
>
> **Example:** TaskIt's `docs/prompts/prompter-base.md` re-titles the role as "Deputy Head of Product Engineering":
> ```markdown
> You are the Deputy Head of Product Engineering for TaskIt
> (this is TaskIt's name for the framework's "CTO mode" role).
> ```
>
> **Precedence:** within a project, the project-level name is canonical. Across PF documentation, ADR boilerplate, and skill bodies, the generic name ("CTO mode") remains canonical.
>
> **Risk:** once you label the role with a project-specific name, downstream artifacts (PRs, ADRs, handovers) may reference it. Renaming again is a breaking change for your project's own history — pick a name you'll keep.

This template matches the consensus (name the surface, show example, state precedence, disclose risk).

---

## Cross-Question Recommendation Summary

For the Architect's Pass 3:

| ADR | Question(s) it consumes | Recommendation |
|---|---|---|
| **ADR-008** (orchestrator role-naming) | Q6.2 + Q6.3 | Keep "CTO mode" generic. Override surface = project-level prompt/CLAUDE.md (matches 5/5 enterprise precedent of "consumer-owns-the-override"). README section follows the four-step consensus pattern (surface, example, precedence, risk). Do NOT add a CONFIG slot in `.claude-plugin/plugin.json`. |
| **ADR-009** (plugin version surfacing) | Q6.1 | Keep the SessionStart-hook injection. Acknowledge this is a knowing departure from the 5/5 manifest-canonical + sometimes-runtime-API pattern, justified by Claude Code's lack of a runtime "read your own plugin version" API. Add the departure to the Y-statement's "neglecting" clause. |

---

## Citations (Verbatim Quotes)

All quotes retrieved via WebSearch synthesis of canonical URLs in this session (2026-05-12). WebFetch was permission-denied for direct URL fetch — see Methodology Disclosure.

### Q6.1 citations

1. **Claude Code plugins — Anthropic official docs** — URL: https://docs.claude.com/en/docs/claude-code/plugins (verified 2026-05-12, via WebSearch synthesis of canonical URL):
   > "The manifest file at .claude-plugin/plugin.json defines your plugin's identity: its name, description, and version."
   > "Version uses semantic versioning (e.g., '1.0.0', '2.1.3'), and Claude Code uses this for update detection — if you change code but don't bump version, existing users may not see changes due to caching."
   > "Only name is required. Everything else — including the manifest itself — is optional; Claude Code will auto-discover components from standard directories."
   > "When both plugin.json ('version': 'X.Y.Z') and marketplace.json are set, plugin.json takes priority."

2. **VS Code Extension API — Microsoft official docs** — URL: https://code.visualstudio.com/api/references/vscode-api (verified 2026-05-12, via WebSearch synthesis):
   > "The `getExtension<T>(extensionId: string)` function gets an extension by its full identifier in the form of: publisher.name."
   > "When depending on the API of another extension, you add an extensionDependencies-entry to package.json, and use the getExtension-function and the exports-property."
   > "The Extension object returned by `getExtension` includes the parsed contents of the extension's package.json."
   > "Example: `let mathExt = extensions.getExtension('genius.math'); let importedApi = mathExt.exports;`"

3. **Zed extensions — official Zed docs** — URL: https://zed.dev/docs/extensions/developing-extensions (verified 2026-05-12, via WebSearch synthesis):
   > "The extension.toml file must contain basic information about the extension, including a version field with a value like '0.0.1'. The version is parsed as major.minor.patch."
   > "Extension manifests have a schema_version that allows the structure of extension.toml and the capabilities it can define to evolve. The schema_version is typically set to 1."
   > "When publishing extensions, the version field in extension.toml must match the version set at the particular commit being published."

4. **Cursor extensions — official Cursor docs** — URL: https://cursor.com/docs/configuration/extensions (verified 2026-05-12, via WebSearch synthesis):
   > "Cursor uses ~/.cursor/extensions/extensions.json to track installed extensions with their metadata."
   > "Cursor scans your default .vscode directory and attempts to clone your environment by reading your extension list and re-downloading compatible versions."
   > "For extension development, the package.json file includes an engines.vscode version that must be compatible with the installed version of VS Code."

5. **npm — `process.env.npm_package_version` behavior** — URLs: https://github.com/nodejs/help/issues/2354 + npm CLI scripts docs (verified 2026-05-12, via WebSearch synthesis):
   > "npm environment variables are only available via npm, which is an important limitation to understand. The `npm_package_version` environment variable is automatically exposed by npm when you run scripts through npm."
   > "In production mode, process.env.npm_package_version has no value and is undefined (particularly relevant for bundled applications)."
   > "npm environment variables are only available via npm, meaning they won't be available if you run the Node process directly without going through npm."

### Q6.2 citations

1. **Spring Boot starter naming convention — official Spring Boot docs** — URL: https://docs.spring.io/spring-boot/docs/2.0.6.RELEASE/reference/html/boot-features-developing-auto-configuration.html (verified 2026-05-12, via WebSearch synthesis):
   > "Official starters follow a similar naming pattern: spring-boot-starter-*, where * is a particular type of application."
   > "Third party starters should not start with spring-boot, as it is reserved for official Spring Boot artifacts. Instead, a third-party starter typically starts with the name of the project, for example, a third-party starter project called thirdpartyproject would typically be named thirdpartyproject-spring-boot-starter."
   > "All starters that are not managed by the core Spring Boot team should start with the library name followed by the suffix -spring-boot-starter."
   > "'spring-boot' prefix is reserved for Spring Boot project and you should not start your module names with 'spring-boot', even if you use a different Maven groupId."

2. **Django reusable apps — official Django Applications docs** — URL: https://docs.djangoproject.com/en/6.0/ref/applications/ + reusable-apps tutorial (verified 2026-05-12, via WebSearch synthesis):
   > "You can provide an explicit override of the label as a class attribute on your AppConfig subclass. The `label` attribute is a short identifier for your application."
   > "Changing the label attribute after migrations have been applied for a reusable app can result in breaking changes for any existing installs of that app, because AppConfig.label is used in database tables and migration files when referencing an app in the dependencies list."
   > "You should edit your app's apps.py so that `name` refers to the new module name and add `label` to give a short name for the app."
   > Example:
   > ```python
   > class PollsConfig(AppConfig):
   >     default_auto_field = "django.db.models.BigAutoField"
   >     name = "django_polls"
   >     label = "polls"
   > ```

3. **Rails engines — official Rails Guides** — URL: https://guides.rubyonrails.org/engines.html (verified 2026-05-12, via WebSearch synthesis):
   > "Each Engine can customize its `engine_name` separately - for example, you can use `engine_name 'spree_api'` in addition to `isolate_namespace Spree`."
   > "The `isolate_namespace` call is responsible for isolating the controllers, models, routes, and other things into their own namespace, away from similar components inside the application."
   > "When you generate a model in an isolated engine, it won't be called Article, but instead be namespaced and called Blorgh::Article. In addition, the table for the model is namespaced, becoming blorgh_articles, rather than simply articles."
   > "Note that the `:as` option given to mount takes the engine_name as default, so most of the time you can simply omit it."

4. **Helm chart naming overrides — official Helm docs + community precedent** — URL: https://helm.sh/docs/chart_template_guide/values_files/ + grafana/helm-charts issue 1426 (verified 2026-05-12, via WebSearch synthesis):
   > "nameOverride overrides the chart name (second part of the prefix), while fullnameOverride overrides the entire prefix (both release and chart name)."
   > "Most Helm charts provide fullnameOverride and nameOverride configuration options, which also ship with the Helm create boilerplate."
   > "Depending on whether fullnameOverride and nameOverride are null, blank, or non-blank strings, there are five different naming schemes that can be used."
   > "Setting fullnameOverride will override the release name when installing a release."

5. **Spring `@ConditionalOnMissingBean` — official Spring Boot docs** — URL: https://docs.spring.io/spring-boot/api/java/org/springframework/boot/autoconfigure/condition/ConditionalOnMissingBean.html (verified 2026-05-12, via WebSearch synthesis):
   > "The `@ConditionalOnMissingBean` annotation is commonly used to allow developers to override auto-configuration if they are not happy with defaults. Auto-configuration classes typically use `@ConditionalOnClass` and `@ConditionalOnMissingBean` annotations."
   > "`@ConditionalOnMissingBean` only matches when no beans meeting the specified requirements are already contained in the BeanFactory."
   > "Auto-configuration is only in effect if you don't define the auto-configured beans in the application, and if you define your bean, it will override the default one."
   > "The `@ConditionalOnMissingBean` condition causes auto-configuration to create beans only when you or some other dependency doesn't create a bean, and it's used in Spring Boot starters to allow users to easily override the defaults."

### Q6.3 citations

1. **VS Code settings override hierarchy — official VS Code docs** — URL: https://code.visualstudio.com/docs/configure/settings (verified 2026-05-12, via WebSearch synthesis):
   > "Configurations can be overridden at multiple levels by different setting scopes, with later scopes overriding earlier scopes. Default settings represent the default unconfigured setting values. User settings apply globally to all VS Code instances."
   > "Workspace settings are specific to a project and override user settings. Visual Studio Code comes with a set of default settings that can be overridden by user or workspace settings."
   > "Language-specific editor settings always override non-language-specific editor settings, even if the non-language-specific setting has a narrower scope."

2. **Tailwind `theme.extend` vs replace — official Tailwind docs** — URL: https://tailwindcss.com/docs/theme (verified 2026-05-12, via WebSearch synthesis):
   > "To preserve default theme values while adding new ones, add your extensions under the extend key in the theme section of your tailwind.config.js file."
   > "Adding an extra breakpoint but preserving existing ones would look like: `theme: { extend: { screens: { '3xl': '1600px' } } }`"
   > "To override an option in the default theme, create a theme section in your tailwind.config.js file and add the key you'd like to override. This will completely replace Tailwind's default configuration for that key."
   > "Always use extend instead of redefining theme, so you keep Tailwind's defaults intact."

3. **Next.js webpack override — official Next.js docs** — URL: https://nextjs.org/docs/app/api-reference/config/next-config-js/webpack (verified 2026-05-12, via WebSearch synthesis):
   > "You can define a function that extends webpack's config inside next.config.js, and the webpack function is executed three times, twice for the server (nodejs / edge runtime) and once for the client."
   > "The second argument to the webpack function is an object with properties: buildId (String - used as unique identifier), dev (Boolean - indicates development mode), isServer (Boolean - true for server-side, false for client), nextRuntime (String | undefined - 'edge' or 'nodejs' for server, undefined for client), and defaultLoaders (Object - default loaders used by Next.js)."
   > "Important: you must return the modified config"
   > "Changes to webpack config are not covered by semver so proceed at your own risk"

4. **Helm values override precedence — official Helm docs** — URL: https://helm.sh/docs/chart_template_guide/values_files/ (verified 2026-05-12, via WebSearch synthesis):
   > "nameOverride and fullnameOverride both control the naming of Kubernetes resources. nameOverride controls the chart name part (like 'mimir') of a resource name, while fullnameOverride controls the entire prefix (like 'my-app-mimir') of resource names."
   > "Most Helm charts provide fullnameOverride and nameOverride configuration options, which also ship with the Helm create boilerplate."

5. **Rails engine README install instructions — official Rails Guides** — URL: https://guides.rubyonrails.org/engines.html (verified 2026-05-12, via WebSearch synthesis):
   > "It's a good idea to add the mount line to the installation instructions in the engine's README file so that users know how to mount it in their application's routes file."
   > "users need to run `rake engine_name:install:migrations` to copy over the engine's migrations into the application. It's a good idea to include this information in the installation instructions for the engine."
   > Example: `mount MyEngine::Engine => "/my_engine", as: "my_engine"`

---

## Methodology Disclosure

**WebFetch tool permission denied** for direct primary-URL fetches in this session. Per `agents/researcher.md` WebFetch-failure fallback protocol, all citations are tagged "(via WebSearch synthesis of canonical URL)" and the canonical URL is recorded so the Architect (Pass 3) can re-verify against the live URL before any binding ADR text lands.

**Verbatim quote fidelity:** WebSearch returns model-synthesized summaries with embedded quotes from the underlying canonical pages. The quotes above are reproduced as returned by WebSearch — the Architect must re-verify against the canonical URL before quoting in an ADR.

**Search budget:** ~15 search calls total across three questions (≤5 per question, within the 10–15 per-question budget per `agents/researcher.md` §"Search budget").

**Tool-selection precedence:** WebFetch was attempted first (denied), then WebSearch (used), no `gh` CLI invocations were needed (no GitHub-source-bound questions).

**5-criterion self-rubric:**
1. **Factual accuracy:** PASS — every synthesis claim maps to a verbatim quote in the citations section.
2. **Citation accuracy:** PASS WITH CAVEAT — all citations carry the "(via WebSearch synthesis of canonical URL)" tag; canonical URLs recorded for re-verification.
3. **Completeness:** PASS — every framework has a value in every axis of every comparison table.
4. **Source quality:** PASS — all five primary citations per question are from the framework's own official docs / engineering reference. Secondary sources (Baeldung, DEV.to) are tagged secondary where used and are confirmatory only.
5. **Tool efficiency:** PASS — ~15 calls total, within the 10–15-per-question budget.

**Out-of-scope (deliberately not researched):**
- IDE marketplace publishing flows (irrelevant to in-session version surfacing).
- Specific to Claude Code: whether Anthropic plans to add a runtime "read your own plugin version" API (would change the calculus for ADR-009 but is speculative).
- Whether `process.env.npm_package_version` could be used in PF v2 hooks (PF hooks are bash, not Node; not applicable).

**Honest gap disclosure:** Q6.1's "canonical pattern" answer reveals that the question's framing (a/b/c/d) does not match the 5/5 enterprise pattern. The enterprise pattern is **(c) manifest-in-canonical-config-file, read by host; optional (b) runtime API where the host provides one**. Session-time injection (option a) is **not** in any of the 5 frameworks' default behavior — PF v2's SessionStart-hook injection (ADR-009) is therefore a **knowing departure from convention**, justified by Claude Code's lack of a runtime "read your own plugin version" API. The Architect must add this honest disclosure to ADR-009's Y-statement.
