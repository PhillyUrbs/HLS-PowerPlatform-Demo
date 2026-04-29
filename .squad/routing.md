# Work Routing

How to decide who handles what. Companion to [.squad/charter.md](charter.md) (cross-cutting ownership table) and [.squad/team.md](team.md) (roster).

## Routing Table — work type → role

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Cross-cutting decisions, install/upgrade/uninstall scripts, phase transitions, conflict arbitration | Lead | install.ps1 modes, Entra app reg provisioning, migration framework |
| Dataverse schema, security roles, env var definitions, migrations, seed data | Dataverse-Engineer | new `cch_*` table, persona-attribution columns, Faker seed |
| Power Pages Code Site, web roles, Pages table-permission YAML, Pages auth | Pages-Engineer | V1 + V2 surfaces, AnonymousPatient/AuthenticatedPatient/AuthenticatedHCP roles |
| Power Apps Code App, persona switcher, Demo Health, shared component library | CodeApp-Engineer | V3/V4/V5 surfaces, `<AppShell/>`, `<PersonaSwitcher/>`, `<AgentChatHost/>` |
| Power Automate flows (tool flows, infrastructure, lifecycle/orchestration), Adaptive Card JSON structure | Flows-Engineer | `cch_AgentToolWrapper`, `cch_TriggerQualityTriage`, V1 replacement, shipment lifecycle |
| Copilot Studio agents, system prompts, topic logic, M365 readiness | Agent-Builder | Patient Support persona-router, Quality Triage trigger, Enablement multi-surface |
| DLP, Managed Env, audit, Pipelines, permissions matrix, governance posture | Governance | `Apply-Dlp.ps1`, `Apply-ManagedEnv.ps1`, `docs/permissions.md` |
| Tests, doctor.ps1, smoke, Tier-1/Tier-3 workflows, per-vignette E2Es | Tester | wires axe + Playwright + Pester; reviews on shared concerns |
| Decision log, knowledge prose, demo script prose, voice & tone, doc hygiene | Scribe | `.squad/decisions.md`, `data/knowledge/*.md` content, `docs/demo-script.md` |
| Quick facts ("what's the locked palette color?") | Coordinator answers directly | Don't spawn an agent for grep-able answers |

## Cross-cutting artifacts (multi-role; see [charter.md](charter.md))

| Artifact | Primary | Reviewers | Arbiter |
|---|---|---|---|
| Shared component library (24) | CodeApp-Engineer | Pages-Engineer | Lead |
| Knowledge `.md` prose (15 docs) | Scribe | Agent-Builder, Dataverse-Engineer | Lead |
| Demo script Phase-6 prose | Scribe | Lead, CodeApp/Pages-Engineer | Lead |
| Adaptive Card JSON visual content | Flows-Engineer | Pages, CodeApp | Lead |
| Voice & tone short-doc | Scribe | Agent-Builder | Lead |
| Demo Health page | CodeApp-Engineer | Tester, Governance | Lead |

## Issue Routing

| Label | Action | Who |
|-------|--------|-----|
| `squad` | Triage: analyze issue, assign `squad:<member>` label | Lead |
| `squad:<name>` | Pick up issue and complete the work | Named member |
| `phase:0` … `phase:6` | Phase scope marker | Set by issue author or Lead at triage |
| `role:<name>` | Role scope marker | Set automatically by `squad:<name>` |

### How Issue Assignment Works

1. When a GitHub issue gets the `squad` label, the **Lead** triages it — analyzing content, assigning the right `squad:<member>` label, and commenting with triage notes.
2. When a `squad:<member>` label is applied, that member picks up the issue in their next session.
3. Members can reassign by removing their label and adding another member's label.
4. The `squad` label is the "inbox" — untriaged issues waiting for Lead review.
5. Phase 0 will open 9 first-PR-target issues (one per role) at `squad init` completion (Topic 10B).

## Conflict Resolution (4-step playbook from [charter.md](charter.md))

1. Check `.squad/decisions.md` for prior lock.
2. Consumer wins by default.
3. Escalate to Lead with 1-paragraph each.
4. Every resolution → `decisions.md` entry by Scribe.

## Rules

1. **Eager by default** — spawn all agents who could usefully start work, including anticipatory downstream work.
2. **Scribe always runs** after substantial work, always as `mode: "background"`. Never blocks.
3. **Quick facts → coordinator answers directly.** Don't spawn an agent for grep-able questions.
4. **When two agents could handle it**, pick the one whose domain is the primary concern.
5. **"Team, ..." → fan-out.** Spawn all relevant agents in parallel as `mode: "background"`.
6. **Anticipate downstream work.** If a feature is being built, spawn Tester to write test cases from requirements simultaneously.
7. **Issue-labeled work** — when a `squad:<member>` label is applied to an issue, route to that member.
8. **Phase warnings** — Tier-1 lints PR file paths against `.squad/phase.json`'s `allowedFolders` and `warningFolders`. Soft gate (warn only).
