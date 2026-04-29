<#
.SYNOPSIS
    Applies a custom Data Loss Prevention policy to the demo dev env.

.DESCRIPTION
    Per Topic 5 governance lock (2026-04-29):
      - Scope: the named demo dev env from deployment-settings.json (not tenant-wide).
      - Business bucket: locked baseline (Dataverse, Outlook, Teams, SharePoint,
        Approvals, HTTP-with-Entra) + Direct Line + OneDrive for Business + Power BI
        + Word/Excel Online + Microsoft Forms.
      - Non-Business bucket: empty.
      - Everything else: Blocked.

    --whatif (default) prints the action plan without mutating anything.
    -Apply runs the actual Set-AdminDlpPolicy / similar admin cmdlets (Phase 1+).

    Idempotent: re-running with the same manifest is a no-op. Logs to
    scripts/governance/.last-run/Apply-Dlp.log.

.PARAMETER Apply
    Switch from --whatif preview to actual mutation. Default is --whatif.

.PARAMETER DeploymentSettingsPath
    Path to deployment-settings.json. Defaults to scripts/deployment-settings.json.

.EXAMPLE
    pwsh ./scripts/governance/Apply-Dlp.ps1
    Preview only (--whatif default). Prints the planned bucket assignments + target env.

.EXAMPLE
    pwsh ./scripts/governance/Apply-Dlp.ps1 -Apply
    Actually creates / updates the DLP policy on the target env.

.NOTES
    Owner role: Governance.
    Topic refs: Topic 5 (DLP scope + Business bucket members), Topic 5 (intentionally OFF
                features documented in commented-out blocks below for operator reference).
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
    -ScriptName 'Apply-Dlp.ps1' `
    -Purpose 'Custom DLP policy: Business / Blocked split, scoped to demo dev env' `
    -Apply $Apply.IsPresent `
    -Settings $settings

$plannedActions = @(
    "Connect to Power Platform admin (Connect-PowerAppsAccount or service principal)"
    "Verify target env '$($settings.environment.name)' exists and is accessible"
    "Create or update DLP policy 'cch-demo-dlp' scoped to env id (looked up by url)"
    ""
    "BUSINESS bucket (combinable):"
    "  - Microsoft Dataverse"
    "  - Office 365 Outlook"
    "  - Microsoft Teams"
    "  - SharePoint Online"
    "  - Approvals"
    "  - HTTP with Microsoft Entra ID (preauthorized)"
    "  - Direct Line                  (Topic 5 addition: required for V3/V4/V5 chats)"
    "  - OneDrive for Business        (Topic 5 addition: hybrid connection ownership)"
    "  - Power BI                     (Topic 5 addition: defensive for placeholder tiles)"
    "  - Word / Excel Online (Business) (Topic 5 addition: templated-doc republish flow)"
    "  - Microsoft Forms              (Topic 5 addition: forms-driven Approvals)"
    ""
    "NON-BUSINESS bucket: <empty> (locked Topic 5; sharpens demo posture)"
    ""
    "BLOCKED: everything else (default)"
    ""
    "INTENTIONALLY NOT in Business (commented blocks operator can flip):"
    "  - Azure family (Functions/Storage/Service Bus) -- violates runtime independence"
    "  - LinkedIn / X / Mailchimp -- not used by demo"
    ""
    "After apply: write audit-permissions Tier-1 will validate the bucket assignments"
    "match this manifest on every Pages-touching PR."
)

Invoke-GovernanceNotImplemented `
    -ScriptName 'Apply-Dlp.ps1' `
    -Purpose 'Custom DLP policy' `
    -TopicRef 'Topic 5 (governance config) + handoff section 3.13 (governance approach)' `
    -PlannedActions $plannedActions `
    -Apply $Apply.IsPresent
