# Topic 10 — Squad team charter & subfolder AGENTS.md docs (locked)

**Locked on:** 2026-04-29
**Scenario layer:** 🟢 **Scenario-agnostic** — 9-role roster (Lead, Dataverse-Engineer, Pages-Engineer, CodeApp-Engineer, Flows-Engineer, Agent-Builder, Governance, Tester, Scribe), `.squad/charter.md` per-role template, `.squad/phase.json` + Tier-1 phase warning, decisions-log shape, PR template, CODEOWNERS pattern, conflict-resolution playbook, 6-row cross-cutting ownership table, 7 subfolder AGENTS.md files. All identical for any Power Platform demo regardless of scenario. Forking: copy as-is.

## Framing

- Locked **Squad roster** in handoff §10 + AGENTS.md: Lead, Dataverse-Engineer, Pages-Engineer, CodeApp-Engineer, Flows-Engineer, Agent-Builder, Governance, Tester, Scribe.
- Locked **operating principles** in AGENTS.md: phase-gated, use existing skills, document decisions, trunk-based + `feature/<phase>-<name>`, confirm-before-destructive, stay-in-lane.
- Locked **`squad init` deferred to Phase 0 final commit** (handoff §10).
- This topic locks: per-role charter + per-subfolder `AGENTS.md` files + phase-gate mechanism + decisions-log policy + PR mechanics.

## Decisions

| Area | Decision |
|---|---|
| **Charter file shape** | Single `.squad/charter.md` covering all 9 roles + operating model. Fixed per-role template (Mission · Owns · Doesn't own · Hand-offs to/from · Definition of done · Skills to use) |
| **Subfolder `AGENTS.md` files** | 7 files committed (see list below); fixed 6-section template, ≤80 lines each |
| **Phase enforcement** | `.squad/phase.json` singleton + Tier-1 lint **warning** (not block) when PRs touch out-of-phase files. Lead updates phase.json at transitions; Scribe records in decisions.md |
| **Decisions-log shape** | Date-prefixed entries (`## YYYY-MM-DD — <Title>`) with fixed fields (Decided / Why / Alternatives / Affects). Tier-1 lints heading shape. Auto-generated "recent 20" index appendix maintained by Scribe weekly |
| **decisions.md seed** | At `squad init`, decisions.md is seeded from Topics 1–9 (one entry per locked summary line) so the team starts with full context |
| **PR template** | `.github/pull_request_template.md` with role · phase · decisions affected · tests added · docs updated · audit-permissions clean (Pages) · a11y green |
| **Tester positioning** | **Embedded** — every role co-authors tests as a side effect; Tester *owns* doctor.ps1, smoke suite, 3 CI workflows, per-vignette Playwright E2Es, test-data tagging convention; reviews on shared concerns |
| **Installer** | Lead's scope (explicit charter scope-line); not split out as a separate role |
| **Branch naming** | Tier-1 lint (warning) on `feature/<phase>-<name>` pattern |
| **CODEOWNERS** | `.github/CODEOWNERS` mapping subfolders → role labels (single-operator today; future-proofs multi-contributor) |
| **Doctor coverage** | New `[Squad]` section: phase.json present + valid · charter.md present · subfolder AGENTS.md present · decisions.md freshness (warn if >30 days idle while other commits land). Info/warning only |

## `.squad/charter.md` shape

Per-role section template:

```markdown
## <Role Name>

**Mission:** one sentence.

**Owns:**
- file globs / responsibilities
- ...

**Doesn't own:** explicit non-responsibilities — when this role hits these, it hands off to Lead.

**Hand-offs to / from:**
- to → Lead when ...
- from ← Dataverse-Engineer when ...
- ...

**Definition of done (per PR):**
- [ ] Tests added or extended where applicable
- [ ] (other role-specific items)

**Skills to use** (from the user's environment):
- `setup-datamodel` for ...
- ...
```

## Per-role charter (locked content)

### Lead
- **Mission:** Architect, coordinator, phase-gate keeper, installer owner.
- **Owns:** `scripts/install.ps1`, `scripts/upgrade.ps1`, `scripts/uninstall.ps1`, `scripts/Setup-ServicePrincipal.ps1`, `scripts/lib/*` (Preflight/Environment/Solution/EntraApps/SharePoint/Teams/Connections/Seed), `scripts/governance/*`, `.squad/phase.json`, `docs/install.md`, `docs/upgrading.md`, `docs/uninstall.md`, `docs/architecture.md`, the migration framework.
- **Doesn't own:** schema, vignette implementation, tests beyond doctor.
- **Hand-offs:** to Dataverse-Engineer for schema migrations · to Tester for smoke suite hooks · to Governance for DLP/ME script content · from any role for cross-cutting decisions.
- **DoD:** lifecycle modes idempotent · `--whatif` default · doctor section updated · Decisions log entry if architecture-affecting.
- **Skills:** `pac` family · `gh` · `az`/`func` (build-time only).

### Dataverse-Engineer
- **Mission:** Schema, security roles, env vars, seed data, persona-attribution columns.
- **Owns:** `solutions/ContinuumHealthDemo/src/Entities/`, `solutions/.../OptionSets/`, `solutions/.../SecurityRoles/`, `solutions/.../EnvironmentVariables/`, `solutions/.../migrations/`, `data/seed.ts`, `data/offsets.ts`, `data/fixtures/`, `data/knowledge/<subfolder>/<doc>.md` skeletons.
- **Doesn't own:** flows (Flows-Engineer), agents (Agent-Builder), web roles (Pages-Engineer).
- **Hand-offs:** to Flows-Engineer for child-flow contracts · to Pages-Engineer for table permissions · to Tester for fixture rows.
- **DoD:** persona-attribution columns present on every audit-relevant table · all env vars in EnvVarManifest.json · migration declared destructive when applicable · audit-permissions clean.
- **Skills:** `setup-datamodel` · `add-sample-data` · `add-dataverse`.

### Pages-Engineer
- **Mission:** Power Pages Code Site (V1, V2 surfaces), web roles, Web API integration, Pages auth.
- **Owns:** `sites/continuum-portal/`, web roles in solution, Pages-only flows.
- **Doesn't own:** shared component library (CodeApp + Pages co-own; Lead-mediated for cross-surface contracts).
- **Hand-offs:** to Dataverse-Engineer for schema · to Agent-Builder for floating-bubble contracts · to Tester for E2Es.
- **DoD:** audit-permissions Tier-1 green · a11y axe Tier-1 green · `<DemoModeBanner/>` present on every page · Telemetry SDK events dispatched.
- **Skills:** `create-site` · `setup-auth` · `create-webroles` · `integrate-webapi` · `audit-permissions` · `add-seo` · `deploy-site` · `activate-site` · `test-site`.

### CodeApp-Engineer
- **Mission:** Power Apps Code App (V3, V4, V5 surfaces inside the Code App), Demo Health page.
- **Owns:** `apps/field-companion/`, `apps/field-companion/src/lib/telemetry.ts`, `apps/field-companion/src/config/promptStarters.ts`, Demo Health page implementation.
- **Doesn't own:** Pages site, agent specs, flows.
- **Hand-offs:** to Pages-Engineer for shared component library · to Agent-Builder for `<AgentChatHost/>` contracts · to Flows-Engineer for tool flow contracts · to Tester for E2Es.
- **DoD:** a11y axe Tier-1 green · Telemetry SDK events dispatched · Demo Health pre-flight buttons hooked to `doctor.ps1 --vignette=V_`.
- **Skills:** `create-code-app` · `add-dataverse` · `add-office365` · `add-teams` · `add-sharepoint` · `add-mcscopilot` · `deploy`.

### Flows-Engineer
- **Mission:** Power Automate flows — orchestration (V1 replacement, V2/V3 shipment lifecycle, V4 triage trigger), tool flows (18 from Topic 8), infrastructure flows (`cch_ResolveSecret`, `cch_IssueDirectLineToken`, `cch_LogTelemetry`, `cch_AgentToolWrapper`, `cch_TriggerQualityTriage`), live-sim, daily refresh, vignette resets, weekly templated-doc republish.
- **Owns:** all flows inside `solutions/ContinuumHealthDemo/src/Workflows/`, Adaptive Card templates under `solutions/.../AdaptiveCards/`.
- **Doesn't own:** schema (Dataverse-Engineer), agent topic logic (Agent-Builder).
- **Hand-offs:** to Dataverse-Engineer for table writes · to Agent-Builder for tool-envelope schema · to Governance for connector-bucket fit · to Tester for smoke triggers.
- **DoD:** every flow uses Connection References + Environment Variables · every tool flow uses `cch_AgentToolWrapper` · standard envelope schema validated · idempotency where applicable.
- **Skills:** none Power-Automate-specific in skills list; uses `pac` for solution sync.

### Agent-Builder
- **Mission:** 3 Copilot Studio agents — Patient Support, Quality Triage, Continuum Enablement.
- **Owns:** `agents/<name>/` × 3 (export, `spec.md`, `system-prompt.md`, avatar SVG, M365 readiness checklist for Enablement).
- **Doesn't own:** tool flows (Flows-Engineer), knowledge document content (Dataverse-Engineer authoring), agent embedding components (CodeApp/Pages-Engineers).
- **Hand-offs:** to Flows-Engineer for tool envelope · to Dataverse-Engineer for `cch_TelemetryEvent` mirror · to Pages-Engineer/CodeApp-Engineer for Direct Line embed · from Lead for Phase-5 gate.
- **DoD:** all 6 system-prompt sections present · standard envelope honored · safe-fallback wording matches Topic 8C · M365 readiness checklist all 6 boxes (Enablement only).
- **Skills:** `add-mcscopilot` for embed contracts.

### Governance
- **Mission:** DLP, Managed Environment, audit, Pipelines, end-to-end dry runs, permissions audit, M365 readiness.
- **Owns:** `scripts/governance/Apply-*.ps1`, `scripts/governance/Provision-Pipelines.ps1`, `docs/governance-recommendations.md`, `docs/permissions.md`, doctor's `[Governance]` section.
- **Doesn't own:** install.ps1 itself (Lead emits the governance scripts; Governance authors their content).
- **Hand-offs:** to Lead for emission wiring · to Tester for governance posture verification · to Pages-Engineer for audit-permissions follow-through.
- **DoD:** all governance scripts `--whatif` default · idempotent · doctor reports posture without changing it · `audit-permissions` Tier-1 clean.
- **Skills:** `audit-permissions`.

### Tester
- **Mission:** Quality infrastructure + ensures every other role's PRs land tested.
- **Owns:** `scripts/doctor.ps1`, `scripts/Test-All.ps1`, `scripts/lib/Smoke.ps1`, `.github/workflows/ci-tier1.yml`, `.github/workflows/nightly-smoke.yml`, `.github/workflows/deploy.yml`, per-vignette Playwright E2Es, test-data tagging (`cch_TestRun = true` convention), Vitest + axe + Pester wiring.
- **Doesn't own:** the implementations being tested.
- **Hand-offs:** reviews PRs from every role for "tests added or extended" DoD · escalates to Lead when test coverage gaps imply phase rework.
- **DoD:** Tier-1 green on every PR · Tier-3 nightly green or actively triaged · doctor sections cover every other role's owned surface.
- **Skills:** `test-site` for Pages E2E · ajv-cli · gitleaks · PSScriptAnalyzer · markdownlint-cli2.

### Scribe (default Squad role)
- **Mission:** Records decisions and per-agent history.
- **Owns:** `.squad/decisions.md`, `.squad/agents/*/history.md`, the auto-generated decisions index appendix, weekly squad-state hygiene.
- **Doesn't own:** any code or implementation.
- **Hand-offs:** receives append events from any role; flags drift to Lead.
- **DoD:** every locked decision has a date-prefixed entry · entry shape Tier-1-lint clean · index appendix regenerated weekly.
- **Skills:** none code-bound; uses `gh` for issue cross-references.

## Subfolder `AGENTS.md` files (7)

Each follows the fixed 6-section template (≤80 lines):

```markdown
# AGENTS.md

**Owner role(s):** <one or more from charter>

## Scope
What this folder is for, in 2–4 lines.

## House rules
Locked decisions specific to this surface (e.g., for `apps/`: "every interactive element imports
from the shared component library or applies aria-label").

## Skills to use
Bullets pointing to the user's environment skills relevant for this folder.

## Hand-off rules
When to call Lead. When to call other roles.

## Definition of done (per PR)
Per-PR checklist specific to this folder. Cross-references the role-charter DoD.
```

### `solutions/ContinuumHealthDemo/AGENTS.md` (Dataverse-Engineer)
House rules: persona-attribution columns on every audit-relevant table · publisher prefix `cch_` · audit enabled per Topic 5 · migrations numbered, declare destructive · env vars match `EnvVarManifest.json`.

### `apps/field-companion/AGENTS.md` (CodeApp-Engineer)
House rules: Fluent UI v9 only · light theme only · `<DemoModeBanner/>` on every screen · Telemetry SDK auto-imports persona context · `<AgentChatHost/>` for any agent embed · prompt-starter chips read from `config/promptStarters.ts`.

### `sites/continuum-portal/AGENTS.md` (Pages-Engineer)
House rules: Fluent UI v9 only · `<DemoModeBanner/>` on every page · `audit-permissions` clean before merge · web role / table-permission YAML co-located with the React route that uses it · floating-bubble agent uses `<AgentChatHost size="floatingBubble">`.

### `agents/AGENTS.md` (Agent-Builder)
House rules: per-agent `spec.md` + `system-prompt.md` co-located with export · 6 H2 sections lint · standard tool envelope honored · safe-fallback wording matches Topic 8C verbatim · M365 readiness checklist authoritative for Enablement.

### `scripts/AGENTS.md` (Lead + Tester)
House rules: PowerShell 7 · `--whatif` default for any state-changing operation · idempotent · `Resolve-Secret` for every secret · cross-platform path handling · Pester 5 for unit tests in `scripts/tests/`.

### `data/AGENTS.md` (Dataverse-Engineer + Tester)
House rules: synthetic only (Faker `en_US`) · names from `data/names/people.md` · offsets in `data/offsets.ts` (no hard-coded dates in seeds) · knowledge .md docs use `{{today}}` / `{{current_quarter}}` tokens · `cch_TestRun = true` tagging for E2E fixtures.

### `docs/AGENTS.md` (Scribe)
House rules: Markdown lint clean · file-link convention from copilot-instructions.md · planning artifacts under `docs/_planning/` · operator-facing docs at `docs/<topic>.md` · cross-references rather than duplication.

## `.squad/phase.json`

```json
{
  "$schema": "./phase.schema.json",
  "currentPhase": 0,
  "currentPhaseName": "Tenant & governance setup",
  "allowedFolders": ["scripts/", "docs/", ".squad/", ".github/", ".vscode/"],
  "warningFolders": ["solutions/", "apps/", "sites/", "agents/", "data/"],
  "phaseStartedAt": "2026-04-29",
  "completionChecklist": [
    "Phase 0 work items in handoff section 2 all done",
    "squad init run + decisions.md seeded",
    "branch protection on main",
    "Tier-1 workflow committed"
  ]
}
```

Phase transitions: Lead PRs phase.json + appends transition entry to decisions.md. Tier-1 lints `currentPhase` matches `phaseStartedAt` is recent.

## decisions.md entry shape

```markdown
## YYYY-MM-DD — <Title>

**Decided:** one to three sentences stating the decision.

**Why:** rationale (one paragraph max).

**Alternatives considered:** bullets (1–3) with one-line dismissal each.

**Affects:** Phase X / Vignette Y / Cross-cutting / Component <name> / etc.

**References:** topic-NN-…md · spec.md path · etc.
```

## Doctor `[Squad]` section spec

```
[Squad]
- .squad/phase.json exists + schema-valid               [pass | warn]
- currentPhase value matches expected (warn if behind)  [pass | warn | info: ahead]
- .squad/charter.md exists                              [pass | warn]
- All 7 subfolder AGENTS.md present                     [pass | warn: missing N]
- .squad/decisions.md last-updated freshness            [pass | warn: > 30 days while other commits landed]
- decisions.md entry shape lint                         [pass | warn: N malformed]
```

All info/warning only (locked doctor read-only rule).

## PR template

```markdown
## Summary
<one paragraph>

## Affected role(s)
- [ ] Lead
- [ ] Dataverse-Engineer
- [ ] Pages-Engineer
- [ ] CodeApp-Engineer
- [ ] Flows-Engineer
- [ ] Agent-Builder
- [ ] Governance
- [ ] Tester
- [ ] Scribe

## Affected phase(s)
- [ ] Phase 0 / 1 / 2 / 3 / 4 / 5 / 6 / Cross-cutting

## Decisions
- [ ] No new decisions
- [ ] New decisions added to `.squad/decisions.md` (paste entry text below)

## Checks
- [ ] Tests added or extended where applicable
- [ ] Docs updated where applicable
- [ ] `audit-permissions` clean (if Pages-affecting)
- [ ] a11y axe Tier-1 green (if React-affecting)
- [ ] `--whatif` default for any new state-changing script
```

## CODEOWNERS

```
# Single-operator today; role labels future-proof multi-contributor

solutions/ContinuumHealthDemo/   @PhillyUrbs   # Dataverse-Engineer
apps/field-companion/            @PhillyUrbs   # CodeApp-Engineer
sites/continuum-portal/          @PhillyUrbs   # Pages-Engineer
agents/                          @PhillyUrbs   # Agent-Builder
scripts/                         @PhillyUrbs   # Lead + Tester
scripts/governance/              @PhillyUrbs   # Governance
data/                            @PhillyUrbs   # Dataverse-Engineer + Tester
docs/                            @PhillyUrbs   # Scribe
.squad/                          @PhillyUrbs   # Lead + Scribe
.github/                         @PhillyUrbs   # Lead
```

## Updates to earlier locked decisions

- **Handoff §10 Squad roster** — confirmed; this topic is the *charter* of record.
- **AGENTS.md (root)** — gains a footer pointing to `.squad/charter.md` and the 7 subfolder `AGENTS.md` files for full role detail.
- **Topic 5 governance** — `audit-permissions` Tier-1 step + `cch_*` env-var check now joined by branch-naming + decisions.md-shape lints.
- **Topic 6 doctor** — gains `[Squad]` section.
- **Handoff §3.16 Tier 1** — list grows: branch naming · decisions.md shape · phase.json validity · subfolder AGENTS.md presence.
- **Phase-0 pending list** (handoff §2) — adds: `.squad/charter.md` author · 7 subfolder AGENTS.md files · `.squad/phase.json` · PR template · CODEOWNERS · decisions.md seed from Topics 1–9.

## Deliverables to commit

1. **`docs/_planning/topic-10-squad-charter.md`** ← this file
2. **`.squad/charter.md`** — full per-role content above
3. **7 subfolder `AGENTS.md` files** at the locations enumerated
4. **`.squad/phase.json`** + `.squad/phase.schema.json`
5. **`.github/pull_request_template.md`** — template above
6. **`.github/CODEOWNERS`** — mapping above
7. **decisions.md seeding script** (`scripts/Seed-Decisions.ps1`) that converts the locked summaries from Topics 1–9 into 9 date-prefixed entries
8. **Doctor `[Squad]` section spec** above implemented in `doctor.ps1`

## Open follow-ups (deferred — not blocking)

- **Per-role onboarding doc** for future contributors — defer until a second contributor exists.
- **Squad CLI hooks** for the auto-generated decisions index appendix — Phase 0 work item; mechanism (cron / git hook / manual) to be picked when authoring Scribe automation.
- **Multi-contributor CODEOWNERS** — current CODEOWNERS lists `@PhillyUrbs` everywhere; future expansion is a one-line edit per row.

---

# Topic 10B — First-PR targets, AGENTS.md prose, conflict playbook, cross-cutting ownership (locked)

**Locked on:** 2026-04-29

**Roster decision:** Keep the 9 roles. The role/scope mismatches surfaced by 9 topics of planning are addressed by the **Cross-cutting ownership table** below + the **Conflict-resolution playbook** below, not by adding new roles. (Adding roles = more hats for a single operator; cleaner seams come from explicit ownership at the artifacts where roles meet.)

## Conflict-resolution playbook (added to `.squad/charter.md`)

When two roles disagree on a contract:

1. **Check `.squad/decisions.md`** for prior lock. If found, follow it. Done.
2. **Consumer wins by default.** The role *consuming* the contract proposes the shape; the role *producing* it adapts. Example: if CodeApp-Engineer (consumer of `<AgentChatHost/>` `onToolCall` callback) wants shape A, and Flows-Engineer (producer of the upstream tool envelope) wants shape B that's incompatible at the React boundary, CodeApp's shape wins; Flows-Engineer adapts the envelope mapper.
3. **If still disagreement after step 2,** escalate to **Lead** with a 1-paragraph summary from each role. Lead decides.
4. **Every conflict resolution is a `decisions.md` entry,** authored by Scribe with the standard entry shape. Includes the resolution + which option each role originally preferred + why.

Locked exception: Lead's own decisions are escalated to the human (the user) since there's no Lead-of-Lead role.

## Cross-cutting ownership table (added to `.squad/charter.md`)

| Artifact | Primary owner (writes) | Secondary (reviews) | Arbiter (resolves disputes) |
|---|---|---|---|
| **Shared component library (24 components in `apps/.../components/` and `sites/.../components/`)** | CodeApp-Engineer | Pages-Engineer | Lead |
| **Knowledge `.md` prose (15 docs under `data/knowledge/`)** | Scribe | Agent-Builder reviews per-agent subfolder; Dataverse-Engineer reviews structural drift from skeleton | Lead |
| **Demo script `.md` Phase-6 prose** | Scribe (drafts talk track + Q&A answers) | Lead reviews vs. architecture; CodeApp/Pages-Engineer review per-vignette accuracy | Lead |
| **Adaptive Card JSON visual content (5 templates)** | Flows-Engineer (structure, data binding) | Pages+CodeApp (visual contract: brand teal, persona-in-header partial, status colors) | Lead |
| **Voice & tone short-doc (`docs/voice-and-tone.md`)** | Scribe | Agent-Builder per-agent rows from Topic 8 voice & tone | Lead |
| **Demo Health page (in `apps/field-companion/`)** | CodeApp-Engineer (host + tile rendering) | Tester (doctor JSON contract); Governance (governance posture data); Flows-Engineer (telemetry queries) | Lead |

**Notes:**
- "Primary owner" makes commits; PR review-required from "Secondary" before merge.
- "Arbiter" is invoked only if Primary/Secondary deadlock per the conflict playbook.
- Cross-cutting changes still get a `decisions.md` entry per the locked decisions-log policy.

## Per-role first-PR targets

Each role's first PR is sized to land in 1–2 sittings. Authored as the initial 9 GitHub issues at `squad init` time.

| # | Role | Phase | First PR target | Sized for |
|---|---|---|---|---|
| 1 | **Lead** | 0 | `scripts/install.ps1` skeleton with mode dispatcher (install / upgrade / uninstall / doctor / seed / refresh-dates) emitting `[NotImplemented]` with structured exit codes; reads `deployment-settings.json` shape; calls `scripts/lib/Preflight.ps1` placeholder | 1 sitting |
| 2 | **Dataverse-Engineer** | 1 | All 14 custom tables + 6 security roles + 3 web roles authored in one solution clone; persona-attribution columns on the 9 audit-relevant tables; `cch_TelemetryEvent` + `cch_DemoAnchor` + `cch_LiveSimSetting` + `cch_DeploymentHistory` singletons present. No data yet | 2 sittings |
| 3 | **Pages-Engineer** | 2 | `sites/continuum-portal/` scaffold via `create-site` skill + `<DemoModeBanner/>` rendered on Home + `<ContinuumLogo/>` in header + Anonymous web role wired + a11y axe Tier-1 green from day one | 1 sitting |
| 4 | **CodeApp-Engineer** | 3 | `apps/field-companion/` scaffold via `create-code-app` skill + `<AppShell/>` + `<PersonaSwitcher/>` + Demo Health route stub (placeholder tiles, no data) + `<DemoModeBanner/>` + a11y green | 2 sittings |
| 5 | **Flows-Engineer** | 4 | The 4 infrastructure flows: `cch_ResolveSecret` (child) + `cch_LogTelemetry` (child) + `cch_AgentToolWrapper` (child) + `cch_IssueDirectLineToken`. No tools or orchestration yet. Connection References + Env Vars from day one | 2 sittings |
| 6 | **Agent-Builder** | 5 | Patient Support agent skeleton in CS Studio + persona-router topic + greeting topic for all 4 personas with locked salutations + `agents/patient-support/system-prompt.md` skeleton with all 6 H2 sections + avatar SVG | 1–2 sittings |
| 7 | **Governance** | 0 | `scripts/governance/Apply-Dlp.ps1` with `--whatif` default + the locked Business/Blocked manifest from Topic 5 + idempotency + targets env named in `deployment-settings.json` | 1 sitting |
| 8 | **Tester** | 0 | `scripts/doctor.ps1` skeleton with all section headers (`[Governance]`, `[Telemetry]`, `[Knowledge]`, `[Squad]`, `[Agents]`, `[Permissions]`) emitting `[NotImplemented]` findings + `--vignette=V_` and `--mode=chained|highlight` and `--json` flag parsing + `Test-EnvVarManifest` placeholder | 2 sittings |
| 9 | **Scribe** | 0 (right after `squad init`) | Seed `.squad/decisions.md` from Topics 1–10 (10 date-prefixed entries) using `scripts/Seed-Decisions.ps1` + open this PR with the auto-generated index appendix populated | 1 sitting |

These become **9 GitHub issues** opened by `squad init`, labeled `phase:0` / `phase:1` / etc., assigned to `@PhillyUrbs`, with the role label.

## Subfolder AGENTS.md prose (7 files, ≤80 lines each)

### `solutions/ContinuumHealthDemo/AGENTS.md`

```markdown
# AGENTS.md — solutions/ContinuumHealthDemo/

**Owner role(s):** Dataverse-Engineer

## Scope
The Power Platform solution that holds every Dataverse table, choice, security role,
environment variable, connection reference, Adaptive Card template, and Power Automate
flow used by the demo. Source-controlled via `pac solution clone`. The single source
of truth for the back-end. Migrations under `migrations/` are authored numbered and
forward-only.

## House rules
- Publisher prefix `cch_` on every object.
- Persona-attribution columns (`cch_CreatedByPersona`, `cch_ModifiedByPersona`) on every
  audit-relevant table — see Topic 3 lock.
- Auditing enabled per Topic 5 — table-level on every `cch_*` table; column-level on
  persona-attribution and V4 agent-decision columns.
- Migrations numbered (`0001_baseline.ps1`, `0002_*` and onward); declare `destructive`
  in the header for any column drop / data loss.
- Environment variables match `scripts/lib/EnvVarManifest.json` shape.
- Connection References used by every flow (no hardcoded connections).
- 6 security roles: PatientPortal, HCPPortal, FieldRep, QualityAnalyst, ServicePrincipal,
  DemoOperator. 3 web roles: AnonymousPatient, AuthenticatedPatient, AuthenticatedHCP.

## Skills to use
- `setup-datamodel` for table + column + relationship authoring
- `add-sample-data` for seeding fixture rows
- `add-dataverse` (Code App skill) when generating TypeScript models for `apps/`

## Hand-off rules
- Hand off to **Flows-Engineer** when a column needs a flow trigger or a flow needs
  schema additions to bind to.
- Hand off to **Pages-Engineer** when a table needs Pages table-permission YAML.
- Hand off to **Lead** for migration framework changes.
- Receive **Tester**'s fixture-row tagging requests (`cch_TestRun = true`).

## Definition of done (per PR)
- [ ] Schema changes accompanied by a numbered migration under `migrations/`
- [ ] Persona-attribution columns present on any new audit-relevant table
- [ ] Auditing flags set per Topic 5
- [ ] `audit-permissions` Tier-1 green
- [ ] `EnvVarManifest.json` updated if env vars changed
- [ ] `decisions.md` entry if cross-cutting (e.g., new shared table)
```

### `apps/field-companion/AGENTS.md`

```markdown
# AGENTS.md — apps/field-companion/

**Owner role(s):** CodeApp-Engineer (primary) · Tester (E2E reviews) · Pages-Engineer (shared component co-owner)

## Scope
The Power Apps Code App (React + Vite + Fluent UI v9) hosting V3 (FCS account 360),
V4 (Quality triage workspace), V5 (Knowledge tab), and the Demo Health operator page.
Built per Topic 8C `<AgentChatHost/>` contract; per Topic 6 telemetry SDK; per Topic 7
a11y AA target.

## House rules
- Fluent UI v9 only — no v8, no third-party design systems.
- Light theme only (Topic 7 lock).
- `<DemoModeBanner/>` mounted at AppShell — present on every screen, dismissible per
  session, returns on refresh.
- Telemetry SDK auto-imports persona context from the persona overlay store; callers
  never pass it explicitly.
- `<AgentChatHost/>` is the only way to embed an agent (3 size variants).
- Prompt-starter chips read from `src/config/promptStarters.ts` per locked Topic 8B.
- Demo Health page nav restricted to `DemoOperator` role (Topic 3) — never visible
  to personas.
- `CitationsRenderer mode="popover"` for in-panel agents; `mode="sidebar"` only for
  V5 Knowledge tab.

## Skills to use
- `create-code-app` for scaffold
- `add-dataverse` for typed services
- `add-office365` / `add-teams` / `add-onedrive` / `add-sharepoint` for connectors
- `add-mcscopilot` for agent embedding contracts
- `deploy` for Code App publish

## Hand-off rules
- Hand off to **Pages-Engineer** for shared-component-library changes (CodeApp is
  primary; Pages reviews; Lead arbitrates per cross-cutting table).
- Hand off to **Flows-Engineer** when Demo Health needs a new telemetry query or
  a new pre-flight signal.
- Hand off to **Tester** when `doctor.ps1` JSON contract needs to change.
- Receive **Agent-Builder** spec changes that require new prop shapes.

## Definition of done (per PR)
- [ ] Tier-1 a11y axe green
- [ ] Tier-1 ESLint + jsx-a11y green
- [ ] Telemetry events dispatched for new beats / errors / persona switches
- [ ] Demo Health additions hooked to `doctor.ps1 --vignette=V_` JSON
- [ ] `<DemoModeBanner/>` not removed
- [ ] `decisions.md` entry if shared component contract changed
```

### `sites/continuum-portal/AGENTS.md`

```markdown
# AGENTS.md — sites/continuum-portal/

**Owner role(s):** Pages-Engineer (primary) · Tester (E2E reviews) · CodeApp-Engineer (shared component co-owner)

## Scope
The Power Pages Code Site (React SPA + Fluent UI v9) hosting V1 (patient onboarding +
in-context support) and V2 (HCP prescribing + roster). Anonymous + AuthenticatedPatient
+ AuthenticatedHCP web roles. Pages auth via Entra ID (single demo super user).

## House rules
- Fluent UI v9 only.
- `<DemoModeBanner/>` mounted at site shell — present on every page.
- `audit-permissions` Tier-1 must be clean before merge (Topic 3 lock).
- Web role + table-permission YAML co-located with the React route that uses it,
  not pooled centrally.
- Floating-bubble agent uses `<AgentChatHost size="floatingBubble">`.
- Anonymous Patient web role: create-only on `cch_Patient`, no reads on any custom
  table (Topic 3 lock).
- AuthenticatedHCP: relationship-scoped on Patients-where-PrimaryHCP=me.
- AuthenticatedPatient: self + record-owner scope on Patient; relationship reads on
  Prescription / Shipment / Complaint / Device.

## Skills to use
- `create-site` for scaffold
- `setup-auth` for Entra ID
- `create-webroles` for web role authoring
- `integrate-webapi` for Dataverse calls
- `audit-permissions` (run before every PR)
- `add-seo` for V1 public area
- `deploy-site` and `activate-site`
- `test-site` for runtime verification

## Hand-off rules
- Hand off to **CodeApp-Engineer** for shared-component-library changes (CodeApp is
  primary; Pages reviews; Lead arbitrates per cross-cutting table).
- Hand off to **Dataverse-Engineer** when a route needs schema additions.
- Hand off to **Agent-Builder** for floating-bubble persona-context contracts.

## Definition of done (per PR)
- [ ] `audit-permissions` Tier-1 green (this is the gating check for Pages PRs)
- [ ] Tier-1 a11y axe green
- [ ] Web role + table-permission YAML present for any new route
- [ ] `<DemoModeBanner/>` not removed
- [ ] `decisions.md` entry if shared component contract changed
```

### `agents/AGENTS.md`

```markdown
# AGENTS.md — agents/

**Owner role(s):** Agent-Builder

## Scope
The 3 Copilot Studio agents (Patient Support, Quality Triage, Continuum Enablement),
each in its own subfolder with the export, `spec.md`, `system-prompt.md`, avatar SVG,
and (for Enablement) `m365-readiness.md`. Authored against the locked Topic 8 + 8B + 8C
contracts.

## House rules
- Per-agent `spec.md` and `system-prompt.md` co-located with the export — never in
  `docs/`.
- `system-prompt.md` must contain all 6 H2 sections (Identity, Voice & Tone, Persona
  context contract, Tool catalog, Knowledge sources, Safety & fallback) — Tier-1 lints.
- Standard tool envelope honored: `{success, data, displayMessage, citations[],
  correlationId, errorCode?}`. Error codes from the 10-code enum.
- Safe-fallback wording matches Topic 8C verbatim — **do not paraphrase**.
- Confirm-before-write on every write tool. Read tools fire silently.
- Patient Support uses persona-router topic + per-persona groups (Patient / HCP / FCS
  / Anonymous). One agent identity, four personas.
- Quality Triage triggered by `cch_TriggerQualityTriage` wrapper flow only — never
  direct Dataverse trigger.
- Enablement agent = single persona (real signed-in user on M365/Teams/SP). M365
  readiness checklist all 6 boxes before V6 publish.

## Skills to use
- `add-mcscopilot` for any Code App embedding contract changes

## Hand-off rules
- Hand off to **Flows-Engineer** for new tool flows or envelope-schema changes.
- Hand off to **Dataverse-Engineer** if a topic needs new persona-attribution coverage.
- Hand off to **CodeApp-Engineer / Pages-Engineer** for `<AgentChatHost/>` prop changes.
- Receive **Scribe** voice & tone updates (Scribe owns `docs/voice-and-tone.md`).

## Definition of done (per PR)
- [ ] All 6 system-prompt sections present (Tier-1 lint)
- [ ] Standard envelope honored on all tool calls
- [ ] Safe-fallback wording verbatim
- [ ] M365 readiness checklist updated (Enablement only)
- [ ] `decisions.md` entry if voice / topic structure changed
```

### `scripts/AGENTS.md`

```markdown
# AGENTS.md — scripts/

**Owner role(s):** Lead (primary) · Tester (doctor + smoke + Test-All)

## Scope
PowerShell 7 scripts for the demo lifecycle: install · upgrade · uninstall · doctor ·
seed · refresh-dates. Plus governance scripts under `governance/`, super-user
management (`Add-DemoUser.ps1` etc.), service principal setup, GitHub secrets helper,
and the shared `lib/` modules.

## House rules
- PowerShell 7 only.
- `--whatif` is the **default** for any state-changing operation; operator must pass
  `-Apply` to mutate. Locked Topic 5.
- Idempotent — safe to re-run. Never assume prior state.
- Use `Resolve-Secret` (Topic 4) for every secret value. Never inline secrets, never
  read raw env vars in flows.
- Cross-platform path handling (`Join-Path`, no backslash literals).
- Pester 5 for unit tests in `scripts/tests/`.
- Logs to `scripts/.last-run/<name>.log` (gitignored).
- Confirm-before-destructive: any `delete` / `remove` / `clean` operation prompts
  unless `-AcceptDestructive` flag is passed (locked AGENTS.md house rule).

## Skills to use
- `pac` family for solution import/export
- `gh` for issue / release operations (non-destructive)
- `az` for KV operations (build-time only; runtime independence locked Topic 4)

## Hand-off rules
- Hand off to **Governance** for `scripts/governance/*` content (Lead emits; Governance
  authors).
- Hand off to **Tester** for new doctor sections + new smoke checks.
- Hand off to **Dataverse-Engineer** for new migration declarations.

## Definition of done (per PR)
- [ ] Pester 5 unit tests pass (`scripts/tests/`)
- [ ] PSScriptAnalyzer Tier-1 green
- [ ] `--whatif` default for any new mutation
- [ ] doctor section updated if new mutation surface added
- [ ] `decisions.md` entry if architecture-affecting (new lifecycle mode, new flag)
```

### `data/AGENTS.md`

```markdown
# AGENTS.md — data/

**Owner role(s):** Dataverse-Engineer (skeletons, fixtures) · Tester (test-data tagging) · Scribe (knowledge prose)

## Scope
Build-time-only assets that seed the demo: Faker-driven seed scripts (`seed.ts`),
date offsets (`offsets.ts`), demo-fill fixtures (`fixtures/demo-fills.ts`), the
user-populated `names/people.md`, and the 15 knowledge `.md` source documents
under `knowledge/<subfolder>/`.

## House rules
- Synthetic only. Faker locale fixed to `en_US` (Topic 7 lock).
- Names sourced from `names/people.md` (user-populated); never hard-coded in seed
  scripts.
- All time-sensitive fields use **offsets** from `offsets.ts`, never hard-coded
  dates. Seeds compute `now - offset` at runtime so data is evergreen.
- Knowledge `.md` docs use `{{today}}` and `{{current_quarter}}` template tokens —
  the templated-doc weekly republish flow substitutes at render time.
- Front-matter on every knowledge doc: `title`, `category`, `version`, `lastReviewed`,
  `owner` (synthetic).
- Fixture rows for E2E tests tagged `cch_TestRun = true` (Topic 6 + locked §3.17).
- Knowledge ACLs (Topic 8B): Read = SP + DemoOperator, Write = DemoOperator only,
  Anonymous = none. Enforced by `audit-permissions`.

## Skills to use
- `add-sample-data` for fixture seeding

## Hand-off rules
- Hand off to **Flows-Engineer** when the templated-doc republish flow needs new
  source files.
- Hand off to **Agent-Builder** when knowledge content needs alignment with a
  topic / utterance change.
- Receive **Scribe** PRs for knowledge prose content (Scribe owns prose; Dataverse-
  Engineer reviews structural drift from skeleton).

## Definition of done (per PR)
- [ ] Faker `en_US` locale used
- [ ] No hard-coded dates in seeds (use offsets)
- [ ] Knowledge .md front-matter complete and template tokens present
- [ ] `cch_TestRun` tagging on E2E fixtures
- [ ] doctor `[Knowledge]` section still passes (count, freshness)
```

### `docs/AGENTS.md`

```markdown
# AGENTS.md — docs/

**Owner role(s):** Scribe (primary) · all roles co-author own surface docs

## Scope
All operator-facing and audience-facing documentation — README, install / upgrade /
uninstall guides, architecture, governance recommendations, permissions, env vars,
telemetry, accessibility, localization, voice & tone, branding, demo script, and
planning artifacts under `_planning/`.

## House rules
- Markdown lint clean (markdownlint-cli2 in Tier-1).
- File-link convention from `.github/copilot-instructions.md` § fileLinkification —
  no backticks for file names; relative-path links with line anchors when applicable.
- Planning artifacts under `_planning/`; operator-facing docs at the top level.
- Cross-references rather than duplication — if a fact is stated in `permissions.md`,
  link to it from `architecture.md` rather than copying.
- Demo script (`demo-script.md`) is Scribe-authored; talk track in annotated bullets,
  never verbatim sentences (Topic 9 lock).
- Knowledge prose (`data/knowledge/*.md`) authored by Scribe but lives under `data/`
  not `docs/`.

## Skills to use
- `gh` for issue + PR cross-references in decision entries

## Hand-off rules
- Hand off to **Lead** when an architectural change requires `architecture.md`
  refactor.
- Hand off to **Tester** to verify any code-flow described in docs actually matches
  reality.
- Receive PRs from every other role updating their own surface's docs.

## Definition of done (per PR)
- [ ] markdownlint clean
- [ ] File-link convention followed
- [ ] No duplication of facts stated elsewhere
- [ ] `decisions.md` updated if doc represents a new locked decision
- [ ] Spelling pass (single-operator's responsibility — no automated spellcheck yet)
```

## Updates to earlier locked decisions

- **Roster:** confirmed at 9 roles. **No new roles added.** Mismatches resolved via the Cross-cutting ownership table + Conflict-resolution playbook above.
- **Topic 10 charter.md spec** — gains 2 new sections: "Cross-cutting ownership" and "Conflict resolution". Same file; appended after the per-role section.
- **`squad init` Phase-0 work item** (handoff §2) — gains: open the 9 first-PR-target GitHub issues with phase + role labels.

## Topic 10B deliverables

1. **Append 10B section to `docs/_planning/topic-10-squad-charter.md`** ✅ done
2. **`.squad/charter.md` spec** updated to include Cross-cutting ownership table + Conflict-resolution playbook (authoring lands at Phase-0 final commit)
3. **7 subfolder `AGENTS.md` files** authored above; committed verbatim at Phase-0 final commit
4. **9 GitHub issues** (one per role) opened by `squad init` with first-PR target as the body, `phase:N` and `role:<name>` labels

## Final Topic 10 — what's now in scope vs. out of scope

**In scope (locked across 10 + 10B):** charter shape · per-role mission/owns/handoffs/DoD/skills · 7 subfolder AGENTS.md (with full prose) · phase enforcement (`.squad/phase.json` + Tier-1 warning) · decisions-log shape + seeding · PR template · CODEOWNERS · Tester positioning (embedded) · installer = Lead · branch naming lint · doctor `[Squad]` section · Cross-cutting ownership (6 artifacts) · Conflict-resolution playbook · per-role first-PR targets (9 issues).

**Out of scope (Phase 0 + ongoing operational work):** actual `squad init` invocation · writing the seeded decisions.md text from Topics 1–10 · authoring the per-role onboarding doc for future contributors · multi-contributor CODEOWNERS expansion.
