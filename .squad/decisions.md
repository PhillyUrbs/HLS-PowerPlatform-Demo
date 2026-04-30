# Squad Decisions

> Append-only decision log. Entry shape locked per [Topic 10](../docs/_planning/topic-10-squad-charter.md). Reverse-chronological (most recent at top of "Active Decisions"). Scribe owns this file; any agent may write to `.squad/decisions/inbox/<role>-<slug>.md` and Scribe will merge.

## Active Decisions

---

## 2026-04-29 — Phase 0 closed; Phase 1 opens

**Decided:** Phase 0 (Tenant & governance setup) is complete. `.squad/phase.json` `currentPhase` bumps from 0 to 1 (Data model & seed). Per locked CI strategy + Topic 11 §A3, **v0.1.0 tag holds until end-of-Phase-1** (Dataverse-Engineer issue #5 lands the schema).

**What landed in Phase 0** (sittings 1–6 + 4g; 5 PRs merged + 4 closure-trail issues + 6 active first-PR-target issues):

| Sitting | What | Commit / PR |
|---|---|---|
| 1 | Planning corpus (11 topic docs + handoff) + repo scaffolding (AGENTS.md, copilot-instructions, .vscode, .env.example, .gitignore, README, names file with 4 heroes) + repo flagged `isTemplate=true` | `d5e99ff` |
| 2 | Squad: 9-role roster, `.squad/charter.md`, `.squad/team.md`, `.squad/routing.md`, 9 agent charters + histories, `.squad/phase.json` (Phase 0), `.squad/phase.schema.json`, decisions.md seeded with 11 entries (Topics 1–11), 7 subfolder AGENTS.md files (lifted verbatim from Topic 10B), 28 GitHub labels | `5b56a3a` + `b39c19d` |
| 3 | PR template + CODEOWNERS + Tier-1 workflow skeleton (15 jobs + aggregator) + branch protection ruleset 'main-protection' (PRs required, squash-only, conversation resolution, Tier-1 summary required, admin bypass) | `d3a9412` + PR #1 `f616921` |
| 4 | scripts/lib/EnvVarManifest.json (40 cch_* vars; 5/12/5/5/9/4 split across Url/Id/Secret/Tunable/Feature/Brand; 19 required) + EnvVarManifest.schema.json + Secrets.ps1 (Resolve-Secret + Test-SecretReference; 6/6 smoke tests passed) + deployment-settings.json.template + .schema.json + install.ps1 (mode dispatcher; --whatif default) + upgrade.ps1 + uninstall.ps1 + doctor.ps1 (8 sections; 5 real passes + 7 honest [NotImplemented] info; --vignette/--mode/--section/--json flags) | PR #2 `aff6476` |
| 5 | scripts/lib/Governance.ps1 (shared helpers) + 4 governance scripts (Apply-Dlp + Apply-ManagedEnv + Apply-Auditing + Provision-Pipelines; --whatif default; install emits paths but never runs) + .gitignore security fix (deployment-settings.json was always documented as gitignored but missed in Sitting 1) | PR #3 `7750bf0` |
| 6 | 7 phase:0..6 GitHub labels + 3 release:v0.1.0..v0.3.0 labels + 6 fresh first-PR-target issues (#4 Lead PR #2; #5 Dataverse-Engineer; #6 Pages-Engineer; #7 CodeApp-Engineer; #8 Flows-Engineer; #9 Agent-Builder) + 4 closure-trail issues (#10–#13) | (no PR; pure issue tracker) |
| 4g | Setup-ServicePrincipal.ps1 (real --Apply implementation; idempotent; parses pac 2.6.4 actual output format) + scripts/lib/EntraApps.ps1 (Pages auth helpers via az ad app; 4/4 smoke tests) + scripts/lib/Governance.ps1 refactor (Test-/Set-PSObjectProperty StrictMode-safe helpers + Show-GovernancePreview) + install.ps1 'install' branch (12-step pipeline visible; steps 1+3a real; step 3b sequenced behind step 7+; steps 2+3b+4-12 are labeled stubs) + doctor.ps1 [EnvVars] gains Entra-app presence checks | PR #14 `321f4f5`; closes issue #4 |

**Tenant + env state at Phase-0 close:**
- **Env:** Continuum Demo (Dev) at `https://orgeeaa078f.crm.dynamics.com/` — **Sandbox tier** (initially provisioned as trial, converted to sandbox via admin portal)
- **Tenant:** M365 Developer tenant `M365x06004729.onmicrosoft.com` (id `72f7eef5-723a-4b8a-acaa-04a2b168cd00`)
- **Super user:** `admin@M365x06004729.onmicrosoft.com` (MOD Administrator)
- **Service Principal app reg:** `continuum-demo-dev-sp` / App ID `d60beb65-8f08-433c-892e-9d5670434dd7` / secret expires 2027-04-30 / role: System Administrator (downgrade to bespoke `ServicePrincipal` role queued for Phase 1 once Dataverse-Engineer issue #5 ships it)
- **Pages auth Entra app:** NOT yet provisioned (sequenced behind step 7+ — needs `cch_UrlPagesSite` for redirect URI; lib is ready in `scripts/lib/EntraApps.ps1`)
- **Dataverse Application User for SP:** registered on Continuum Demo (Dev) env via `pac admin create-service-principal`
- **Solution:** not yet imported (Phase 1 work)

**What's NOT yet done (queued for later phases):**
- Pages auth Entra app reg (Phase 2 — gates Pages-Engineer issue #6 PR #2)
- Governance scripts have NEVER been -Apply'd (skeletons + planned-action listings only). Operator runs Apply-Dlp.ps1 -Apply etc. on demand per Topic 5.
- SharePoint site / Teams team / Copilot Studio agents / solution import / seed data — all Phase 1+ work
- Tier-1 stub jobs (lint+format+types, JSON/YAML/MD lint, PSScriptAnalyzer, solution structure, audit-permissions content, axe content, schema-drift validators) — fill in as code lands
- Microsoft Graph admin consent for `ChannelMessage.Send` — required for Teams channel posts (Topic 5); deferred until Teams team exists

**Why:** Phase gates exist to make rework cheap. Phase 0's job was scaffolding + gates + lifecycle skeletons + the SP provisioning that gates other roles. All ✅. Phase 1 unblocks 4 other roles (anyone who needs schema to exist).

**Alternatives considered:**
- Hold Phase 0 open until governance scripts -Apply'd → premature; Topic 5 explicitly says they're operator-on-demand, not part of install.
- Hold until Pages auth provisioned → premature; needs Pages site URL which is Phase 2.
- Tag v0.1.0 at Phase-0 close → contradicts locked CI strategy (handoff §3.16: v0.1.0 = end of Phase 1).

**Affects:** Cross-cutting. Opens Phase 1 (Dataverse-Engineer issue #5 = schema baseline; sized at 2 sittings). Pages-Engineer (issue #6 PR #1, scaffold) can run parallel to Phase 1 since it doesn't need schema.

**Operator runbook items captured for posterity:**
- Sandbox env was trial-tier originally; trial → sandbox conversion was done via admin.powerplatform.com → Manage → Convert (CLI doesn't expose this conversion). Note for `docs/install.md` when authored: future operators in dev tenants without sandbox capacity should expect to start with trial + plan conversion.
- `pac admin create-service-principal` has NO --whatif/dry-run mode — it always executes against the default-authenticated env. Our `Setup-ServicePrincipal.ps1`'s --whatif default is essential. Author accidentally provisioned a stray SP in Sitting 4g during parser-format verification; cleaned up via `az ad app delete`.

**References:** [Topic 11 §A3](../docs/_planning/topic-11-audit-corrections.md) (Lead PR #2 sequencing); [.squad/phase.json](phase.json) (now currentPhase=1); [scripts/Setup-ServicePrincipal.ps1](../scripts/Setup-ServicePrincipal.ps1); GitHub issues #4–#13.

---

## 2026-04-29 — Topic 11: Audit corrections (12 + 3)

**Decided:** Run a post-planning audit on Topics 1–10 + handoff. Capture all findings as **C1–C12** corrections in [docs/_planning/topic-11-audit-corrections.md](../docs/_planning/topic-11-audit-corrections.md), which becomes the **authoritative correction layer** that supersedes earlier topic docs where they conflict. A **second-pass audit** added **A1–A3** (V6 vignette gap in README/copilot-instructions, Tier-1 budget reality, Entra provisioning sequencing).

**Why:** A planning corpus this dense (10 topics, multiple addenda) accumulates conflicts and oddities. Catching them in a dedicated correction doc rather than rewriting history preserves the planning narrative while keeping the *current state* unambiguous. The second-pass caught the most important miss (root README listed 5 vignettes).

**Alternatives considered:**
- Edit each topic doc inline to fix conflicts → loses audit trail; harder to spot future drift.
- Skip audit, start Phase 0 → high rework risk on cross-cutting concerns.

**Affects:** Cross-cutting. Notable headlines:
- C1: Component library = **23 React components + 1 CSS utility (`sr-only`)** [was wrongly counted as 24]
- C2: Handoff §5 "12+" → "17+" typo
- C3: Phase 0 lands in **multiple sittings**, not one
- **C4: Tier-1 budget revised to 60–90s** (was handoff's ~30s) — Tester measures actual in Phase 0; if > 120s, demote `audit-permissions` + `axe-core` to Tier-1.5 / touched-folder-only
- C5: Final flow count **~30–34** (was Topic 8's "23 core")
- C6: Demo Health drops Flows-Engineer from secondary owners
- C7: Voice & tone owner = Scribe (not branding role; branding role doesn't exist)
- C8: Anonymous-vs-agent ACL clarification line for `agents/AGENTS.md` House Rules — agent reads as SP identity; anonymous browser never reads SharePoint
- C9: **Branch naming = `feature/p<N>-<name>`** (regex `^feature/p[0-6]-[a-z0-9-]+$`)
- C10: CS analytics iframe = Phase-3 spike (CodeApp-Engineer); fall back to deep-link button if iframe SSO breaks
- **C11: Pages auth (Phase 2 PR #2) gated on Lead PR #2** delivering real `install.ps1` Entra app reg provisioning
- C12: V6 demo script needs conversation-reset narration line ("each surface starts fresh — that's intentional")
- **Doctor JSON output schema pinned** (used by Demo Health pre-flight buttons + Tier-3 nightly summary + V6 governance closer)
- A1: README + `.github/copilot-instructions.md` updated to **6 vignettes** (was 5; missing V6 "Extend everywhere") + corrected stale "mocked carrier API" → "in-platform Shipment lifecycle"
- A2: Tier-1 budget revision (C4) seeded here for Phase-0 visibility
- A3: Entra provisioning sequencing (C11) locked: **Lead PR #1 = install.ps1 skeleton (stubbed); Lead PR #2 = real `Setup-ServicePrincipal.ps1` + install.ps1 `provision-entra-apps`; Pages PR #2 (auth wiring) gated on Lead PR #2**

**References:** [docs/_planning/topic-11-audit-corrections.md](../docs/_planning/topic-11-audit-corrections.md) — full per-correction text and rationale.

---

## 2026-04-29 — Topic 10 + 10B: Squad team charter & subfolder AGENTS.md docs

**Decided:** **Roster confirmed at 9 roles** (no additions; mismatches addressed by cross-cutting ownership table + conflict-resolution playbook, not by adding new hats). Single `.squad/charter.md` with fixed per-role template (Mission/Owns/Doesn't own/Hand-offs/DoD/Skills). 7 subfolder AGENTS.md files authored verbatim. `.squad/phase.json` singleton + Tier-1 warning lint. PR template + branch-naming Tier-1 lint + CODEOWNERS. Tester is **embedded** (every role co-authors tests; Tester owns infrastructure). Installer = Lead's scope. Doctor adds `[Squad]` section.

**10B additions:** 4-step conflict-resolution playbook (check log → consumer-wins → Lead → log it). 6-row cross-cutting ownership table (component library / knowledge prose / demo script / Adaptive Cards / voice & tone / Demo Health). Per-role first-PR targets pinned (9 GitHub issues opened at `squad init`). 7 subfolder AGENTS.md files fully authored.

**Why:** Single-operator personal asset benefits from clear seams without role bloat. The 9 roles map cleanly to the 4 Power Platform pillars + 4 supporting concerns (governance, testing, scribing, leadership). Cross-cutting artifacts get explicit owners to prevent silent ownership voids.

**Alternatives considered:**
- Add a 10th "Content & Demo Author" role → resolves knowledge prose + demo script ownership but adds management overhead.
- Add an 11th "UI-Library Engineer" → resolves component library + Adaptive Card visual contract ownership but doubles abstraction surface.
- Re-derive roster from scratch using Topics 1–9 outputs → biggest cost; planning is generic enough at the architecture layer that this would mostly recreate the same 9 roles.
- 8 roles (no Tester) → would require a final test-authoring phase; loses "tested as built" benefit.

**Affects:** Squad operations cross-repo; PR template, CODEOWNERS, branch protection (Sitting 3); doctor `[Squad]` section (Sitting 4).

**References:** [docs/_planning/topic-10-squad-charter.md](../docs/_planning/topic-10-squad-charter.md) (10 + 10B addendum). [.squad/charter.md](charter.md) (operational doc derived from this topic).

---

## 2026-04-29 — Topic 9 + 9B: Demo script outline

**Decided:** Single `docs/demo-script.md` with 6 vignette sections + Intro + Closer + appendices. **8-element vignette inner template:** TL;DR · Pre-flight checklist · Beat-by-beat table · Recovery moves per beat · Q&A anticipation (5–10 questions, BDM/TDM tagged) · Bridge-out (chained mode) · Demo Health watch tiles · "This vignette is *not*…" scope-line. **1-min Intro + 1-min Closer** (Closer reuses Topic 5 + Topic 6 governance/observability bullets). **Inline `[BDM]` / `[TDM]` / `[both]` audience tags** on beats + Q&A. **Highlight reel = V1 + V4 + V6 in ~12 min** (hook → hero → close). Demo Health gains **8 pre-flight buttons** (one per vignette + chained + highlight reel). Cast bios pinned (placeholder names; resolved via `data/names/people.md` heroes: **Maria Sullivan / Jacob Hancock, MD / Nicole Wagner / Quincy Brooks**). 7 appendices (cast / glossary / recovery cookbook / demo modes / "what this is NOT" / pre-demo runbook / Demo Health controls).

**9B additions:** Common 4-item pre-flight (Demo Health all green / last refresh < 24h / persona starting state / browser tabs ready) + per-vignette specifics. Q&A inventory pinned (5–7 questions per vignette with BDM/TDM tags + answer-source pointers; V4 has 7). 6 vignette-specific recovery cookbook entries. `doctor.ps1 --vignette=V_ | --mode=chained|highlight` invocation spec.

**Why:** Pinning script *shape* now means Phase-6 prose authoring is fill-in-the-blanks against a structured skeleton. Pre-flight buttons + doctor coupling pre-empt demo-time surprises.

**Alternatives considered:**
- Per-vignette files under `docs/demo-script/V1.md`...`V6.md` → easier to swap order; harder to print/share as one piece.
- Multi-format authoring (Markdown + PowerPoint + speaker notes) → maintenance nightmare for personal demo asset.
- Verbatim talk track → reads worse than annotated bullets; reading scripted sentences sounds robotic.

**Affects:** Phase 3 (Demo Health pre-flight buttons), Phase 4 (doctor `--vignette` modes), Phase 6 (talk-track authoring against pinned skeleton).

**References:** [docs/_planning/topic-09-demo-script.md](../docs/_planning/topic-09-demo-script.md).

---

## 2026-04-29 — Topic 8 + 8B + 8C: Per-agent topic & tool design

**Decided:** Per-agent `spec.md` co-located under `agents/<name>/` (not in `docs/`). **Standard tool envelope** `{success, data, displayMessage, citations[], correlationId, errorCode?}` with **10-code error enum** (`validation_failed`, `not_found`, `forbidden`, `dependency_failed`, `rate_limited`, `timeout`, `internal_error`, `data_conflict`, `consent_required`, `feature_disabled`). One SharePoint library `Continuum Knowledge` with per-agent + Shared subfolders + Dataverse-as-knowledge for Quality/Patient (no public-web grounding). Patient Support persona-router topic + per-persona groups (Patient/HCP/FCS/Anonymous). Quality Triage triggered by `cch_TriggerQualityTriage` wrapper flow with idempotency + retry. `cch_AgentToolWrapper` child flow standardizes per-tool start/finish telemetry. 6-item M365 readiness checklist + doctor verification (Enablement only). **Voice:** Patient warm/7th-grade; Quality clinical/citation-led; Enablement upbeat/expert-peer. Cross-cutting persona-aware salutation + safe-fallback (per-agent wording **pinned verbatim**) + confirm-before-write. **18 distinct tool flows** (12 Patient Support + 8 Quality Triage − 2 shared) + 5 infrastructure flows.

**8B additions:** **15 minimum-viable knowledge docs** (3 Patient + 2 Quality + 7 Enablement + 3 Shared) under `data/knowledge/` with `{{today}}` / `{{current_quarter}}` template tokens. ACLs: Read=SP+DemoOperator, Write=DemoOperator-only, Anonymous=none (clarified in Topic 11 §C8 — agent reads as SP, not anonymous browser). Prompt-starter chip text pinned for **5 surfaces** (V1 Patient/Anonymous, V2 HCP, V3 FCS, V5 Knowledge tab, V6 Teams welcome). Doctor adds `[Knowledge]` section.

**8C additions:** Fixed **6-section system-prompt template** per agent (`agents/<name>/system-prompt.md`); Tier-1 lints H2 presence. **5 Adaptive Card templates** (TriageCard, ChannelUpdateCard, ToolResultCard, EscalationCard, _persona-header-partial). Two new components: **`<AgentChatHost/>`** (3 sizes: floatingBubble/dockedPanel/fullScreen) + **`<CitationsRenderer/>`** (4 modes: sidebar/popover/teamsCard/m365). Read-only chips auto-send / write-action chips populate-only. **No live inter-agent handoff** (Patient Support fires-and-confirms; Quality Triage runs autonomously). Per-conversation memory only; new conversation on persona switch. **No staleness disclaimers** (republish flow keeps docs ≤7 days fresh; doctor warns >8d). Per Topic 11 §C1: component library = **23 components + 1 utility** (not 24).

**Why:** Three agents on three lifecycles (interactive / autonomous / multi-surface). Standardizing the envelope + wrapper + cards lets Phase 5 focus on agent voice/topic iteration, not plumbing.

**Alternatives considered:**
- Three separate Patient Support agents (one per persona) → loses "one agent identity, persona-aware" narrative; tripled maintenance.
- Direct Copilot Studio Dataverse trigger (no wrapper) → loses idempotency + retry + clean error path.
- Microsoft Graph (mailbox/OneDrive personal) as grounding → violates persona-overlay model.
- Public-web grounding source for Enablement (FDA URL set) → adds grounding-source maintenance + a new failure mode for live demos.
- Live conversational handoff Patient Support → Quality Triage → 3× agent-to-agent plumbing; brittle.

**Affects:** Phase 4 (18 tool flows + 5 infrastructure + 5 Adaptive Cards), Phase 5 (3 agents authored against locked spec), Phase 2/3 (`<AgentChatHost/>` + `<CitationsRenderer/>` components), Phase 1 (knowledge `.md` skeletons). Cross-cutting telemetry hooks via `cch_AgentToolWrapper`.

**References:** [docs/_planning/topic-08-agents.md](../docs/_planning/topic-08-agents.md) (8 + 8B + 8C addenda).

---

## 2026-04-29 — Topic 7: A11y & localization

**Decided:** **WCAG 2.1 AA** target on every authored component; rely on Fluent UI v9 defaults elsewhere. Self-attest in `docs/accessibility.md` (no formal third-party audit). **8 coverage areas:** keyboard navigation, ARIA roles + live regions, color-not-the-only-signal, reduced-motion (`prefers-reduced-motion`), form labelling + error announcements, persona-switch announcement (one polite live-region message per switch via `<PersonaSwitchAnnouncer/>`), palette contrast verification, text-resize/zoom to 200%. **Enforcement:** axe-core in Vitest (component-level) + axe-core in Playwright (E2E per locked §3.17). **Tier-1 fails on AA violations.** Doctor reads last CI run summary and reports `a11y: pass | N issues | unknown` (info only).

**Localization:** **English-only (en-US).** No i18n scaffolding. All in-app dates rendered in `cch_TunableTimezone` (default `Eastern Standard Time`); explicit TZ suffix on dashboards. Glucose **mg/dL only** (US clinical units). Faker locale fixed to `en_US`. Currency USD. Grounding-doc `{{today}}` substitutions use US long form (`April 29, 2026`). Component library grew from 19 to **22** (`<ReducedMotionProvider/>`, `<PersonaSwitchAnnouncer/>`, `sr-only`) — note Topic 11 §C1 clarifies these as 21 React components + 1 CSS utility.

**Why:** Demo audience is North America; demo language is English. Fluent v9 + axe-core cover most a11y at low cost. Hard-gating a11y at Tier-1 prevents rot accumulating between demos.

**Alternatives considered:**
- WCAG 2.1 AAA → requires re-tinting locked teal palette; many small constraints incompatible with brand.
- Multi-locale at runtime (en-US + fr-CA) → doubles QA surface; translations get stale; agents' grounding docs become a maintenance nightmare.
- i18n scaffolding (English-only at runtime; strings externalized) → ships a half-broken i18n shell; promises future features we don't intend to deliver.
- Lint-only via eslint-plugin-jsx-a11y; no axe → misses ARIA-runtime issues.

**Affects:** Phase 2 component library additions, Tier-1 (`npm run test:a11y` + interactive-component static check), Tier-3 (axe-playwright per vignette), branding contrast verification (Topic 2 deliverable § Contrast).

**References:** [docs/_planning/topic-07-a11y-l10n.md](../docs/_planning/topic-07-a11y-l10n.md).

---

## 2026-04-29 — Topic 6: Telemetry / observability

**Decided:** Native PP signals (flow run history, agent analytics, Pages analytics) + **one new Dataverse table `cch_TelemetryEvent`** for app-side events the platform doesn't capture. Surface through Demo Health page. **6 event categories:** PersonaSwitch, VignetteBeat, AgentEvent, ClientError, PerformanceMark, DemoHealthControl. Schema = narrow filterable columns (Timestamp, Category, EventName, Surface, PersonaId, SessionId, CorrelationId, Severity, IsTestRun) + one `PayloadJson` for category-specific data. **Agent mirroring:** mirror only what Copilot Studio analytics misses (tool-call success/failure, latency, deflection). **`cch_LogTelemetry` child flow** invoked at checkpoint by every flow. **Redaction:** allowlist + hash-by-default (SHA-256 first 8 chars) + drop free-text. **30-day retention** via nightly bulk-delete in the daily refresh flow. Demo Health gains **6 tiles** (recent persona switches, errors panel, sparklines, heartbeat, warm-up button, embedded CS analytics iframe — see Topic 11 §C10 spike). Doctor adds `[Telemetry]` section. Tier-1 gains payload-schema-drift validator.

**Why:** Honors locked runtime independence (no Azure / no laptop services). Single Dataverse table + Demo Health = one operator pane of glass.

**Alternatives considered:**
- Wire Application Insights via instrumentation key → violates runtime-independence (Azure required).
- Skip telemetry entirely; rely on Dataverse audit log alone → loses agent latency, persona switches, client errors.
- Mirror every conversation turn → biggest write volume, biggest Dataverse footprint; CS analytics already covers turn-level.

**Affects:** Schema (Phase 1: `cch_TelemetryEvent` table), Code App + Pages telemetry SDK (Phase 2/3), `cch_LogTelemetry` child flow (Phase 4), `cch_AgentToolWrapper` consumes this checkpoint (Topic 8), Demo Health tiles (Phase 3), Tier-1 schema-drift validator (Phase 0).

**References:** [docs/_planning/topic-06-telemetry.md](../docs/_planning/topic-06-telemetry.md).

---

## 2026-04-29 — Topic 5: Governance config

**Decided:** Custom DLP **scoped to dev env only** (not tenant-wide). **Business bucket** = locked baseline (Dataverse, Outlook, Teams, SharePoint, Approvals, HTTP-with-Entra) + Direct Line, OneDrive for Business, Power BI, Word/Excel Online, Microsoft Forms. **Non-Business empty.** Everything else **Blocked.** Managed Environment enables Solution Checker enforcement + weekly run, Maker welcome content + usage insights dashboard, custom solution-checker rules (PA-prefer-environment-variable, PA-prefer-connection-reference), Catalog publishing. **Intentionally OFF** (commented-out blocks operator can flip on): Limit sharing of canvas apps + app/flow inactive cleanup, IP firewall, Customer Lockbox. Auditing **on at all 3 layers**: tenant + env + every custom `cch_*` table (table flags ride with solution). Pipelines = **host env + 2 stage placeholders pointing back at dev** (no-op until edited). **Per-concern scripts** under `scripts/governance/` (Apply-Dlp/ManagedEnv/Auditing + Provision-Pipelines), all `--whatif` default. **install.ps1 emits but never runs** them (matches locked "generated but never auto-applied"). Doctor reports `[Governance]` posture as info/warning. **V6 governance closer talking points (3 bullets) drafted.**

**Why:** Locked governance approach (handoff §3.13) operationalized as concrete config. Dev-env-only DLP keeps blast radius minimal. ME selections are the headline features; intentional-OFF set documents *why* we didn't enable certain things.

**Alternatives considered:**
- Tenant-wide DLP scope → way over scope for personal demo asset.
- Empty Business bucket beyond locked baseline → breaks Direct Line (V3/V4/V5 chats), OneDrive (V3 personal saves), Word/Excel templated-doc republish.
- Single umbrella `Apply-Governance.ps1` script → simpler entry point; harder to audit/diff per concern.
- Doctor with `-Apply` flag fixes drift → violates locked doctor-is-read-only rule.

**Affects:** Phase 0 governance script stubs (Sitting 5), Phase 0 doctor `[Governance]` section spec, V6 demo closer (Phase 6). Adds `cch_IdPipelinesHostEnv` (optional) to Topic 4 env-var manifest.

**References:** [docs/_planning/topic-05-governance.md](../docs/_planning/topic-05-governance.md).

---

## 2026-04-29 — Topic 4: Environment variables

**Decided:** Naming convention **`cch_<Category><Name>` PascalCase**. **6 categories:** Url, Id, Secret, Tunable, Feature, Brand. Concrete inventory drafted (~36 env vars total). **Secret storage = plaintext now with `plain:`/`kv:` SecretRef abstraction** + `cch_ResolveSecret` child flow, so KV switch is **zero-flow-rewrite**. `deployment-settings.json` is categorized (one top-level key per category + `superUsers` array + `connections`). Lifecycle: **install prompts for missing required, upgrade detects deltas, doctor validates** (presence + format + KV reachability + plain-mode "consider KV" info finding). All 6 vignette feature flags **ON by default**. Adds `cch_ResolveSecret` + `cch_IssueDirectLineToken` infrastructure flows + `scripts/lib/EnvVarManifest.json` (machine-readable inventory).

**Why:** Honors runtime independence (no required Azure). Plaintext-with-abstraction means future KV migration doesn't touch flows. JSON Schema on `deployment-settings.json` gives editor IntelliSense + required-vs-optional enforcement.

**Alternatives considered:**
- Plain-text Text env vars without abstraction → security smell escalates if/when KV becomes desired; flows would need rewrites.
- Skip Dataverse secret env vars; flows pull from KV via HTTP-with-Entra → more plumbing in every flow; loses "demo runs without Azure" promise.
- Manual env-var setting in maker portal → brittle, no audit, no doctor coverage.
- Vignette feature flags off by default → demo-time friction; misses "each vignette demoable standalone" lock.

**Affects:** Schema (Phase 1: env var definitions in solution), `install.ps1` lifecycle (Phase 0), `doctor.ps1` env-var-check section (Phase 0), `scripts/lib/EnvVarManifest.json` (Phase 0), `cch_ResolveSecret` + `cch_IssueDirectLineToken` flows (Phase 4).

**References:** [docs/_planning/topic-04-env-vars.md](../docs/_planning/topic-04-env-vars.md).

---

## 2026-04-29 — Topic 3: Permission matrix

**Decided:** Single `docs/permissions.md` with 3 matrix tables (Dataverse role × table; web role × table; connector × default owner). **Org-level Dataverse role scopes** for the 4 persona security roles (PatientPortal, HCPPortal, FieldRep, QualityAnalyst); UI-layer persona filtering does the per-persona narrowing. **AuthenticatedPatient web role:** Self + record-owner scope on Patient; relationship-scoped reads on Prescription/Shipment/Complaint/Device tied to the patient. **AuthenticatedHCP web role:** relationship-scoped on Patients-where-PrimaryHCP=me; create on Prescription; read on tied lifecycle rows. **AnonymousPatient web role:** create-only on Patient (registration submit); no reads on any custom table. **2 new bespoke Dataverse security roles** added (security roles grow 4→6): **`ServicePrincipal`** (org-scoped on every table SP writes) and **`DemoOperator`** (super-user + SP only; covers `cch_DemoAnchor`, `cch_LiveSimSetting`, `cch_DeploymentHistory`). **No Field-Level Security** (synthetic data; rely on Demo Mode banner). **`audit-permissions` skill runs Tier-1 on every PR touching `sites/continuum-portal/**` or Pages table-permission YAML.** Mermaid "who-can-touch-what" diagram in `architecture.md`.

**Why:** Locked persona overlay is UI-only — every Dataverse write actually originates from SP or super user. Loose Dataverse-side scopes match this reality; the *real* access control is Pages table permissions + UI filtering. Bespoke `ServicePrincipal` + `DemoOperator` roles give clean audit ("which writes were the agent vs. an analyst?").

**Alternatives considered:**
- Business-Unit scoped (FieldRep + QualityAnalyst BU-scoped) → defensible realism; costs Phase-1 setup time + adds owner-reassignment overhead on every write.
- Reuse `QualityAnalyst` security role for SP → conflates SP identity with QualityAnalyst privileges; weaker audit.
- FLS on MRN + NPI → adds Phase-1 setup cost + audit-permissions surface area + demo-time confusion.
- Skip the doc; let the solution + audit-permissions output be the matrix → no narrative for SP, super-user, or Dataverse-direct paths.

**Affects:** Phase 1 schema (6 security roles, 3 web roles), `audit-permissions` Tier-1 wiring (Phase 0), Phase 2 Pages table-permission YAML co-located with routes.

**References:** [docs/_planning/topic-03-permissions.md](../docs/_planning/topic-03-permissions.md).

---

## 2026-04-28 — Topic 2: Branding & visual identity

**Decided:** Wordmark + simple geometric mark (hand-authored SVG, exposed as `<ContinuumLogo/>` component). **Palette: teal-forward** — primary teal **`#0E7C86`** + supporting cobalt + neutral slate. Fluent UI v9 brand ramp derived from the primary. Typography: **Segoe UI Variable everywhere** (apps + Pages + Word/PDF grounding docs). Hero imagery: **AI-generated medtech imagery** (Designer/DALL·E), committed as static assets under `sites/continuum-portal/public/img/`. Demo Mode banner: **slim full-width top strip, brand-tinted, dismissible-per-session** (returns on every page refresh / persona switch / new tab). Three distinct geometric agent avatars sharing Continuum palette + common "spark" motif (one SVG per agent under `agents/<name>/avatar.svg`). **Light mode only** (no system-follow, no toggle). **Component library grows from 17 to 19** (`<ContinuumLogo/>`, `<DemoModeBanner/>`).

**Why:** Distinct from Microsoft chrome (so screenshots don't blur into product UI); reads as medtech; AA-contrast achievable. Static AI imagery is controllable + on-brand + no licensing overhead. Banner + light-only + AI imagery is the cheapest path to a polished, on-brand demo.

**Alternatives considered:**
- Wordmark only (no mark) → flatter; doesn't anchor as "this could be a real company".
- Cobalt-forward palette → too close to default Microsoft 365 chrome; muddies screenshots.
- Auto-follow system theme / dark mode toggle → doubles screenshot/test surface; healthcare audiences expect clinical-light.
- Inter web-loaded font for differentiation → adds @font-face plumbing + drifts from Microsoft-stack aesthetic.

**Affects:** Phase 2 component library first-commits (`<ContinuumLogo/>`, `<DemoModeBanner/>`); `theme.ts` brand ramp tokens; `docs/branding.md` deliverable; agent avatar SVGs (Phase 5); hero imagery generation (Phase 2).

**References:** [docs/_planning/topic-02-branding.md](../docs/_planning/topic-02-branding.md).

---

## 2026-04-28 — Topic 1: Detailed UX/click-paths per vignette + Founding scenario lock

**Decided:** Locked the entire founding scenario in [handoff-2026-04-28.md](../docs/_planning/handoff-2026-04-28.md). Subsector = Medtech CGM (fictitious **Contoso Continuum Health**). 4 personas: Patient · Endocrinologist (HCP) · Field Clinical Specialist · Quality/Complaints Analyst. **6 vignettes**, each demoable standalone or chained 1→6 (5–10 min each, total 32–44 min). Surfaces: Power Pages **Code Site** (V1, V2) + Power Apps **Code App** (V3, V4, V5) + Power Automate flows + 3 Copilot Studio agents. UI: **Fluent UI v9** shared. Top-bar + left-nav + content. Medium-high density. Subtle slide-in/highlight on live updates. **Persona overlay** (no real auth switching beats); always-visible top-right with full-population searchable + Anonymous Visitor pseudo-persona. **Single demo super user** via Entra ID; multi-user "Flavor A" alternates (array of UPNs, all equal). **Hybrid connection ownership:** SP via Graph by default; interactive identity reserved for personal-mailbox/calendar/Teams-1:1/OneDrive-personal. **Persona attribution columns** (`cch_CreatedByPersona`, `cch_ModifiedByPersona`) on all audit-relevant tables (initial schema). **Evergreen design:** anchor-and-offset seed pattern + `cch_DemoAnchor` singleton + daily 5am ET refresh flow + live-sim every 10min Mon-Fri 8-6 ET (toggleable) + MDR-clock complaint reset to ~18h. **Demo Health page** in Code App. **Templated agent grounding docs** (Markdown source → weekly rendered to PDF + Word + republished to SharePoint). **Names file** at `data/names/people.md` (user-populated). Repo layout, lifecycle modes (install/upgrade/uninstall/doctor/seed/refresh-dates), migration framework (numbered `.ps1`, forward-only, `0001_baseline`), CI tiers (Tier-1 PR / Tier-3 nightly / personal `deploy.yml`), testing strategy (Vitest/Playwright/Pester/Direct Line). Custom tables list (14 + Topic 6 adds `cch_TelemetryEvent` = 15 total) + V4 agent columns + persona attribution + calculated columns. **17 reusable components** (handoff §5). 3 agents: Patient Support (V1/V2/V3 persona-aware), Quality Triage (V4 autonomous), Continuum Enablement (V5 + V6). **Vignettes 1–6 detailed click-paths** (handoff §7). **Runtime independence is non-negotiable** — 100% Power Platform + M365 cloud at runtime; CLIs build-time only. **Synthetic data only** (Faker `en_US`). License **MIT**, public from day one, AS-IS.

**Why:** This entry summarizes the founding scenario as locked across the cross-instance Copilot Chat planning conversation. All subsequent topics build on these decisions.

**Alternatives considered:** Captured per-area in the handoff itself.

**Affects:** Everything. The handoff is the scenario anchor.

**References:** [docs/_planning/handoff-2026-04-28.md](../docs/_planning/handoff-2026-04-28.md) (full context). Subsequent topics 2–11 build incrementally on this baseline.

---

## Governance

- All meaningful decisions get a date-prefixed entry in this file (entry shape locked per [Topic 10](../docs/_planning/topic-10-squad-charter.md)).
- Reverse-chronological — most recent at top of "Active Decisions".
- Append-only. Reversals get a new entry that supersedes the previous one (the previous entry stays for history).
- Other agents drop into `.squad/decisions/inbox/<role>-<slug>.md`; Scribe merges and deletes the inbox file.
- Tier-1 lints heading shape (`## YYYY-MM-DD — <Title>`).
- Auto-generated "recent decisions" index appendix maintained weekly by Scribe (mechanism TBD; currently manual regeneration).
