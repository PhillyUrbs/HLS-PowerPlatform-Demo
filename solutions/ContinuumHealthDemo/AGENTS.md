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
