# Migrations — Continuum Health Demo

This directory contains ordered PowerShell migration scripts for the `ContinuumHealthDemo` Dataverse solution.

## Framework

Migrations are **numbered, ordered, and idempotent**. Each script:

- Has a filename prefix `NNNN_` (zero-padded 4-digit sequence number).
- Accepts `-EnvironmentUrl` (required) and `-Apply` (switch, default=whatif).
- Is **non-destructive by default** — run without `-Apply` to preview what would change.
- Declares `Destructive: true/false` in its `.METADATA` block.
- Is never deleted or renumbered once merged to `main`.

## Running migrations

```powershell
# Preview (whatif)
.\migrations\0001_baseline.ps1 -EnvironmentUrl "https://org.crm.dynamics.com"

# Apply
.\migrations\0001_baseline.ps1 -EnvironmentUrl "https://org.crm.dynamics.com" -Apply
```

Migrations should be run **in order** after `pac solution import`. The `cch_DeploymentHistory` table records each successful run.

## Migration manifest

| # | Script | Version | Destructive | Description |
|---|--------|---------|-------------|-------------|
| 0001 | `0001_baseline.ps1` | 0.1.0 | false | Baseline schema — 15 tables, 6 security roles, 3 web roles, 6 option sets. Stamps `cch_DeploymentVersion=0.1.0`. |

## Conventions

- **Owner:** Dataverse-Engineer role (see `AGENTS.md`).
- **Review gate:** Any migration marked `Destructive: true` requires Lead + human approval before merge.
- **Naming:** `NNNN_<kebab-description>.ps1` — e.g., `0002_add-complaint-severity-column.ps1`.
- **Environment variable:** `cch_DeploymentVersion` tracks the highest migration version applied to a given environment.
