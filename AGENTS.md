# AGENTS.md

Guidance for **AI agents** (GitHub Copilot CLI, Squad team members, sub-agents) working in
this repository. For human-facing project docs see `README.md`. For Copilot Chat
instructions see `.github/copilot-instructions.md` (the rules in that file apply here too —
this file adds agent-team-specific guidance).

## Mission

Build a modular Power Platform demo for Health & Life Sciences (Medtech) — fictitious
**Contoso Continuum Health** CGM scenario — phase by phase, with humans-in-the-loop at
phase boundaries.

**Runtime independence is non-negotiable.** The deployed demo must run 100% in the
Power Platform + M365 cloud. No external Azure resources, no laptop-hosted services, no
`localhost` URLs in any flow, agent, app, or site. CLIs are build-time only.

## Squad team roster (9 roles — finalized in Topic 10)

`squad init` will be run in Phase 0; the locked roster:

| Member | Role | Primary surface |
|---|---|---|
| **Lead** | Architect / coordinator. Owns phase orchestration, cross-cutting decisions, and the installer (`scripts/install.ps1` family). | Repo-wide |
| **Dataverse-Engineer** | Schema, security roles, env vars, migrations, seed data | `solutions/`, `data/` |
| **Pages-Engineer** | Power Pages Code Site, web roles, Web API integration, Pages auth | `sites/continuum-portal/` |
| **CodeApp-Engineer** | Power Apps Code App, Demo Health page, persona switcher, agent embed | `apps/field-companion/` |
| **Flows-Engineer** | Power Automate flows — 18 tool flows + 5 infrastructure + ~7–11 lifecycle/orchestration flows | flows in solution |
| **Agent-Builder** | Copilot Studio agents (3 of them: Patient Support, Quality Triage, Continuum Enablement) | `agents/*/` |
| **Governance** | DLP, managed env, audit, Pipelines provisioning, permissions audit, M365 readiness | `scripts/governance/`, `docs/governance-recommendations.md` |
| **Tester** | `doctor.ps1`, smoke suite, Tier-1 + Tier-3 GitHub Actions, per-vignette Playwright E2Es. **Embedded** — every other role co-authors tests; Tester reviews on shared concerns. | `scripts/doctor.ps1`, `.github/workflows/`, test files everywhere |
| **Scribe** *(default Squad role)* | Records decisions, knowledge prose, demo script Phase-6 prose, voice & tone short-doc | `.squad/decisions.md`, `data/knowledge/`, `docs/demo-script.md` |

Full per-role charter (Mission · Owns · Doesn't own · Hand-offs · Definition of done · Skills) lives in `.squad/charter.md` once `squad init` runs. See [docs/_planning/topic-10-squad-charter.md](docs/_planning/topic-10-squad-charter.md) for the spec it's built from + the 4-step conflict-resolution playbook + 6-row cross-cutting ownership table.

## Operating principles

1. **Phase-gated.** Do not start Phase N+1 work until Phase N's verification checklist
   passes and the human approves. Phases:
   - Phase 0 — Tenant & governance setup *(in progress)*
   - Phase 1 — Data model & seed *(blocking foundation)*
   - Phase 2 — Power Pages Code Site
   - Phase 3 — Power Apps Code App
   - Phase 4 — Power Automate flows (orchestration + vignette resets)
   - Phase 5 — Copilot Studio agents
   - Phase 6 — Demo script & polish
   Phases 2/3/4 can run in parallel after Phase 1; Phase 5 depends on Phase 1 + relevant
   flows.

2. **Use the Power Platform skills available in the user's environment.** See the table in
   `.github/copilot-instructions.md`. Do not hand-write what a skill can generate.

3. **Single source of truth.** Tables, flows, and security roles live in
   `solutions/ContinuumHealthDemo/`. Export via `pac solution clone`.

4. **Synthetic data only.** Use Faker. Banner every demo screen.

5. **Confirm before destructive Power Platform operations.** Even in `--yolo` mode, agents
   must explicitly ask the human before deleting environments, solutions, tables, columns,
   sites, flows, or app registrations.

6. **Document every non-trivial decision** in `.squad/decisions.md`. Include: what was
   decided, why, alternatives considered, and which phase/vignette it affects. The Scribe
   maintains the file; any agent may append.

7. **Branching:** trunk-based on `main`. Short-lived `feature/p<N>-<name>` branches
   (where `<N>` is the numeric phase 0–6 and `<name>` is kebab-case; e.g.
   `feature/p0-tier1-workflow`, `feature/p2-pages-shell`). PRs go to `main`.
   Squash-merge. Tier-1 lints the branch pattern as a warning.
   **After squash-merge, delete the branch** (`gh pr merge --squash --delete-branch`).
   The PR conversation, inline reviews, and per-commit history are preserved on the
   PR page itself; branch refs add no educational value beyond what the PR shows.

8. **Never commit secrets.** Use `.env.local` (template `.env.example`).

9. **Stay in your lane.** Cross-component changes require a Lead handoff so Scribe can log
   the coordination.

## Tools allowed without human approval

See `chat.tools.terminal.autoApprove` in `.vscode/settings.json` for the full allow-list.
Summary: `pac` reads/builds, `npm`/`node`, `git` local ops, `gh` reads & non-destructive
writes, `az`/`func` reads & local Function dev, Squad status commands. Pushes, force
operations, and resource deletions always require human approval.

## When you (an agent) get blocked

1. Check `.squad/decisions.md` first — the answer may already be locked.
2. Check the Microsoft Learn MCP server for documentation grounding before guessing.
3. Look for a relevant Power Platform skill in the user's environment.
4. If still blocked, **escalate to the human** via the Lead — do not brute-force, do not
   silently change scope.
