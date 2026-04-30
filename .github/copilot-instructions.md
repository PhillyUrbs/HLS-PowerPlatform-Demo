# Copilot Instructions — HLS Power Platform Demo

These instructions apply to **every** Copilot session in this repository. Read them before
suggesting code, running commands, or proposing architecture.

## What this repo is

A modular Power Platform demo for **Health & Life Sciences (Medtech)** built around a
fictitious continuous glucose monitor (CGM) manufacturer, **Contoso Continuum Health**.
It exercises Power Pages (Code Site), Power Apps (Code App), Power Automate, and
Copilot Studio. It is a personal demo asset — **not** a Microsoft product, sample, or
official reference. It is provided AS-IS under the MIT license.

## Locked decisions (do not relitigate without explicit user approval)

- **Subsector / scenario:** Medtech, CGM manufacturer (Contoso Continuum Health). Net-new
  fictitious company — no Microsoft Cloud for Healthcare data model.
- **Personas:** Patient · Endocrinologist (HCP) · Field Clinical Specialist · Quality/Complaints Analyst
- **Apps:** Power Apps **Code App** (React + Vite) · Power Pages **Code Site** (React SPA)
- **Auth (Pages):** Anonymous browse + Entra ID for HCP/Patient authenticated areas
- **Integrations:** Dataverse + M365 (Outlook/Teams/SharePoint) only. **No external/Azure
  services.** Shipment lifecycle is simulated entirely in Dataverse + Power Automate.
- **Runtime independence:** the deployed demo runs 100% in the Power Platform + M365 cloud.
  No developer machine, no Azure resources, no `localhost` services are required at demo
  time. CLIs (`pac`, `npm`, `node`, `gh`, `squad`, `func`) are **build-time only**.
- **Repo:** monorepo · single dev environment · structured to add Pipelines later
- **Data:** synthetic only (Faker-driven). **Never** add real PHI. Never log PII.
- **Vignette resets:** implemented as Power Automate flows (cloud-only) — not as scripts.
- **License:** MIT, © 2026 Philip Urban

## Vignettes (6, each demoable standalone or chained 1→6)

1. Patient onboarding & in-context support — Pages + customer agent + flow
2. HCP prescribing & patient roster — Pages (auth) + Web API + flow
3. Field Clinical Specialist account 360 — Code App + embedded agent
4. Autonomous complaint triage & MDR drafting — Copilot Studio (triggered)
5. Employee enablement agent — Copilot Studio (knowledge + tools)
6. Extend everywhere — same agent surfaced in Code App, Teams, SharePoint, and M365 Copilot

## Repo layout

```
solutions/ContinuumHealthDemo/   PAC-unpacked Dataverse solution (tables, flows, roles)
apps/field-companion/            Power Apps Code App
sites/continuum-portal/          Power Pages Code Site
agents/{patient-support,quality-analyst,employee-enablement}/  Copilot Studio exports
data/                            Faker seed scripts (build-time use only)
docs/                            demo-script · personas · architecture · governance
.squad/                          Squad team state (committed — do not gitignore the root)
```

## Naming & conventions

- **Dataverse publisher prefix:** `cch_` (Contoso Continuum Health)
- **Solution name:** `ContinuumHealthDemo`
- **Web roles:** `AnonymousPatient`, `AuthenticatedPatient`, `AuthenticatedHCP`
- **Security roles:** `PatientPortal`, `HCPPortal`, `FieldRep`, `QualityAnalyst`
- **Branch model:** trunk-based on `main`; short-lived `feature/p<N>-<name>` branches (where `<N>` is the numeric phase 0–6 and `<name>` is kebab-case). Tier-1 lints the pattern `^feature/p[0-6]-[a-z0-9-]+$` as a warning. **After squash-merge, do NOT delete the branch** — branches are preserved as an educational archive showing how each PR was authored and iterated. (Branches deleted before this convention was set are reconstructed under `archive/pr<NN>-<name>`.)
- **Commits:** Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`)
- **Code style:** Prettier + ESLint defaults; 2-space indent; LF line endings

## Tooling Copilot may use freely

- `pac` (Power Platform CLI 2.6+) — read & build commands auto-approved; `delete`/`admin` ops require user confirm
- `npm`/`npx`/`node` — install, run, test scripts
- `git` — local read & commit ops; **never** `push`, `reset --hard`, or `clean -fd` without asking
- `gh` — read & non-destructive write (issues/PRs); never `repo delete`
- `az` / `func` — read & local Function dev; resource deletion requires user confirm
- `squad` — status/doctor/nap freely; team-mutating commands require confirm

See `.vscode/settings.json` (`chat.tools.terminal.autoApprove`) for the exact allow-list.

## Skills available in this environment (use them — do not reinvent)

When working on…

| You're doing… | Use this skill |
|---|---|
| Creating Dataverse tables | `setup-datamodel` |
| Seeding sample data | `add-sample-data` |
| Creating the Power Pages Code Site | `create-site` |
| Wiring Pages auth | `setup-auth` + `create-webroles` |
| Calling Dataverse from Pages | `integrate-webapi` |
| Auditing Pages permissions | `audit-permissions` |
| Adding SEO to Pages | `add-seo` |
| Deploying / activating Pages | `deploy-site` + `activate-site` |
| Creating the Power Apps Code App | `create-code-app` |
| Adding Dataverse to the Code App | `add-dataverse` |
| Adding Outlook / Teams / OneDrive / SharePoint connectors | `add-office365` / `add-teams` / `add-onedrive` / `add-sharepoint` |
| Adding a Copilot Studio agent to the Code App | `add-mcscopilot` |
| Deploying the Code App | `deploy` |

## House rules

1. **Confirm before destructive Power Platform operations** — anything that deletes
   environments, solutions, tables, columns, sites, or flows.
2. **Never commit secrets.** `.env.local`, `local.settings.json`, `*.pem`, `*.pfx` are
   gitignored. App reg client secrets, Direct Line secrets, and SP credentials live
   only in `.env.local` (template is `.env.example`).
3. **Synthetic data only.** Patient names, MRNs, NPIs, addresses must be obviously fake.
   Use Faker. Add a banner to every demo screen reminding viewers data is synthetic.
4. **Compliance theme is lightweight.** Mention audit trails / MDR-reportable flags
   where natural; do not claim FDA/HIPAA/GxP validation.
5. **Single source of truth for back-end.** Tables, flows, and security roles live in
   `solutions/ContinuumHealthDemo/`. Export with `pac solution clone`.
6. **Run `audit-permissions` after any change to Pages table permissions.**
7. **Each vignette has a reset script** under `data/reset/` so it can be re-run cleanly.
8. **Document decisions** as you go in `.squad/decisions.md` (Squad's Scribe will
   maintain this — but it's owned by humans, not auto-clobbered).
9. **Don't add CI/CD jobs that run on push** until the user explicitly asks. The
   `.github/workflows/` directory may hold commented stubs only for now.
10. **Node version:** target Node 20 LTS in scaffolds (the dev machine has Node 25; if a
    scaffold pins to LTS, prefer `engines` declarations over downgrading).

## When in doubt

Ask. The user is a Microsoft Solution Engineer; technical detail is welcome.
