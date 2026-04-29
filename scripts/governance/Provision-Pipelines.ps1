<#
.SYNOPSIS
    Provisions the Power Platform Pipelines host env + 2 stage placeholders pointing back at dev (no-op).

.DESCRIPTION
    Per Topic 5 governance lock (2026-04-29) + handoff section 3.13:

    "provision Pipelines host now (no targets) so adding Test/Prod later is non-breaking"

    Specifically:
      - Create a small host environment (separate from the dev env)
      - Register the dev env as a deployable env
      - Define two stage *placeholders* (`Test`, `Prod`) whose target is **the dev env itself**
        — accidental "deploy to Prod" becomes a no-op.
      - Operator later edits the placeholders to point at real Test/Prod envs when those exist.

    Sets cch_IdPipelinesHostEnv (env var) on success.

    --whatif (default) prints the action plan without mutating anything.

.PARAMETER Apply
    Switch from --whatif preview to actual mutation.

.PARAMETER DeploymentSettingsPath
    Path to deployment-settings.json. Defaults to scripts/deployment-settings.json.

.EXAMPLE
    pwsh ./scripts/governance/Provision-Pipelines.ps1
    Preview only.

.EXAMPLE
    pwsh ./scripts/governance/Provision-Pipelines.ps1 -Apply
    Actually create the host env + register stage placeholders.

.NOTES
    Owner role: Governance.
    Topic refs: Topic 5 (Pipelines section) + handoff section 3.13.
    Required PowerShell: 7+. Real impl requires Microsoft.PowerApps.Administration.PowerShell
    + Pipelines REST API.
    Exit codes: 0 success | 1 user-facing error | 99 not yet implemented (skeleton).
#>

#Requires -Version 7.0

[CmdletBinding()]
param(
    [switch] $Apply,
    [string] $DeploymentSettingsPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '../lib/Governance.ps1')

$settings = Read-DeploymentSettings -Path $DeploymentSettingsPath

Write-GovernanceBanner `
    -ScriptName 'Provision-Pipelines.ps1' `
    -Purpose 'Pipelines host env + 2 stage placeholders pointing back at dev (no-op)' `
    -Apply $Apply.IsPresent `
    -Settings $settings

$plannedActions = @(
    "Connect to Power Platform admin"
    "Check for existing Pipelines host env (cch_IdPipelinesHostEnv in settings)"
    "  - If set: verify it exists; idempotent skip if so"
    "  - If unset: create new env named '<env-name>-pipelines-host' (small / sandbox tier)"
    ""
    "Provision Pipelines on the host env"
    "  - Install the Power Platform Pipelines maker app + admin app"
    "  - Create the cch_DeployableEnvironments record for the dev env"
    "      (target env id = '$($settings.environment.url)' looked up to env id)"
    ""
    "Define 2 stage placeholders (no-op):"
    "  - Stage 'Test'  -> target env = dev env id  (accidental deploy = no-op)"
    "  - Stage 'Prod'  -> target env = dev env id  (accidental deploy = no-op)"
    ""
    "Write back cch_IdPipelinesHostEnv to deployment-settings.json"
    ""
    "When operator is ready to add real Test/Prod envs:"
    "  1. Provision separate Test + Prod envs (operator's tenant decision)"
    "  2. Edit the stage placeholders in the Pipelines maker app to point at"
    "     the real env ids (replacing dev id)"
    "  3. No code change required; the install.ps1 lifecycle modes work the same"
    ""
    "Doctor's [Governance] section will report:"
    "  - Pipelines host env present?  (info if not provisioned -- optional)"
    "  - Dev env registered?           (pass/info)"
)

Invoke-GovernanceNotImplemented `
    -ScriptName 'Provision-Pipelines.ps1' `
    -Purpose 'Pipelines host + no-op stage placeholders' `
    -TopicRef 'Topic 5 (Pipelines section) + handoff section 3.13' `
    -PlannedActions $plannedActions `
    -Apply $Apply.IsPresent
