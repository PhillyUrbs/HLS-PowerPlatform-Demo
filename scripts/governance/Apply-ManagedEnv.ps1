<#
.SYNOPSIS
    Converts the demo dev env to Managed Environment + enables a curated feature set.

.DESCRIPTION
    Per Topic 5 governance lock (2026-04-29):

    ENABLED features:
      - Solution Checker enforcement + weekly run
      - Maker welcome content + usage insights dashboard
      - Custom solution-checker rules (PA-prefer-environment-variable,
        PA-prefer-connection-reference)
      - Catalog publishing (so the demo solution shows up in the env catalog;
        supports the V6 governance-closer admin-screen-share)

    INTENTIONALLY OFF (commented blocks below; operator can flip individually):
      - Limit sharing of canvas apps + app/flow inactive cleanup
      - IP firewall restrictions
      - Customer Lockbox

    --whatif (default) prints the action plan without mutating anything.

.PARAMETER Apply
    Switch from --whatif preview to actual mutation.

.PARAMETER DeploymentSettingsPath
    Path to deployment-settings.json. Defaults to scripts/deployment-settings.json.

.EXAMPLE
    pwsh ./scripts/governance/Apply-ManagedEnv.ps1
    Preview only.

.EXAMPLE
    pwsh ./scripts/governance/Apply-ManagedEnv.ps1 -Apply
    Actually convert env to ME + enable the locked feature set.

.NOTES
    Owner role: Governance.
    Topic refs: Topic 5 (ME features enabled / not enabled).
    Required PowerShell: 7+. Real impl requires Microsoft.PowerApps.Administration.PowerShell.
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
    -ScriptName 'Apply-ManagedEnv.ps1' `
    -Purpose 'Convert dev env to Managed Environment + enable curated features' `
    -Apply $Apply.IsPresent `
    -Settings $settings

$plannedActions = @(
    "Connect to Power Platform admin"
    "Verify target env '$($settings.environment.name)' is not already Managed (idempotent: skip if already)"
    "Convert env to Managed Environment"
    ""
    "ENABLE (locked Topic 5):"
    "  - Solution Checker enforcement (block import on rule violations) + weekly run"
    "  - Maker welcome content (banner + tour for new makers)"
    "  - Usage insights dashboard"
    "  - Custom solution-checker rules:"
    "      * PA-prefer-environment-variable"
    "      * PA-prefer-connection-reference"
    "  - Catalog publishing (demo solution discoverable in env catalog)"
    ""
    "INTENTIONALLY OFF (Topic 5 documented; commented in script for operator override):"
    "  - Limit sharing of canvas apps + app/flow inactive cleanup"
    "      Reason: personal demo asset doesn't accumulate orphans at a rate that"
    "      justifies demo-time risk of a flow being auto-disabled mid-vignette."
    "  - IP firewall restrictions"
    "      Reason: blocks operators behind home networks; for prod tenants only."
    "  - Customer Lockbox"
    "      Reason: Microsoft-support-access feature; meaningless for personal demo."
)

Invoke-GovernanceNotImplemented `
    -ScriptName 'Apply-ManagedEnv.ps1' `
    -Purpose 'Managed Environment conversion + feature enablement' `
    -TopicRef 'Topic 5 (governance config) + handoff section 3.13' `
    -PlannedActions $plannedActions `
    -Apply $Apply.IsPresent
