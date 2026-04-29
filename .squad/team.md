# Squad Team

> **HLS Power Platform Demo (Contoso Continuum Health, Medtech CGM)**

Locked roster: 9 roles per [Topic 10](../docs/_planning/topic-10-squad-charter.md). Full team-wide charter lives at [.squad/charter.md](charter.md). Per-role charters at `.squad/agents/<name>/charter.md`.

## Coordinator

| Name | Role | Notes |
|------|------|-------|
| Squad | Coordinator | Routes work, enforces handoffs and reviewer gates per the conflict-resolution playbook. |

## Members

| Name | Role | Charter | Status |
|------|------|---------|--------|
| Lead | Architect / coordinator / installer owner | [agents/lead/charter.md](agents/lead/charter.md) | active |
| Dataverse-Engineer | Schema, security roles, env vars, migrations, seed data | [agents/dataverse-engineer/charter.md](agents/dataverse-engineer/charter.md) | active |
| Pages-Engineer | Power Pages Code Site, web roles, Web API, Pages auth | [agents/pages-engineer/charter.md](agents/pages-engineer/charter.md) | active |
| CodeApp-Engineer | Power Apps Code App, Demo Health, persona switcher, agent embed | [agents/codeapp-engineer/charter.md](agents/codeapp-engineer/charter.md) | active |
| Flows-Engineer | Power Automate flows (~30–34 total) | [agents/flows-engineer/charter.md](agents/flows-engineer/charter.md) | active |
| Agent-Builder | Copilot Studio agents (3 of them) | [agents/agent-builder/charter.md](agents/agent-builder/charter.md) | active |
| Governance | DLP, Managed Env, audit, Pipelines, permissions, M365 readiness | [agents/governance/charter.md](agents/governance/charter.md) | active |
| Tester | Quality infra: doctor, smoke, CI workflows, E2Es (embedded) | [agents/tester/charter.md](agents/tester/charter.md) | active |
| Scribe | Decisions, knowledge prose, demo script Phase-6, voice & tone short-doc | [agents/scribe/charter.md](agents/scribe/charter.md) | active |

## Project Context

- **Project:** HLS-PowerPlatform-Demo (Contoso Continuum Health — fictitious Medtech CGM)
- **Created:** 2026-04-29
- **Phase:** 0 (Tenant & governance setup) — see [phase.json](phase.json)
- **Audience:** Mixed BDM + TDM (HLS / Medtech / Pharma)
- **Owner:** Philip Urban (Microsoft Solution Engineer)
- **Repo flagged as GitHub template** so future scenarios (e.g. pharma) can fork via "Use this template"
