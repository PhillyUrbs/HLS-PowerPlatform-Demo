<#
.SYNOPSIS
    Enables auditing at all 3 layers: tenant + env + every cch_* table.

.DESCRIPTION
    Per Topic 5 governance lock (2026-04-29): full 3-layer audit trail to back the
    V4 "every change is traceable" demo beat.

      1. Tenant-level Office 365 audit log (no-op if already enabled in M365 tenant)
      2. Env-level Dataverse audit
      3. Per-table cch_* audit (table flags ride with solution import; this script
         verifies they're applied correctly post-import)

    Column-level auditing on persona-attribution columns + V4 agent-decision columns
    is declared in the schema by Dataverse-Engineer (Phase 1) and rides with the solution.

    --whatif (default) prints the action plan without mutating anything.

.PARAMETER Apply
    Switch from --whatif preview to actual mutation.

.PARAMETER DeploymentSettingsPath
    Path to deployment-settings.json. Defaults to scripts/deployment-settings.json.

.EXAMPLE
    pwsh ./scripts/governance/Apply-Auditing.ps1
    Preview only.

.EXAMPLE
    pwsh ./scripts/governance/Apply-Auditing.ps1 -Apply
    Actually flip the switches.

.NOTES
    Owner role: Governance.
    Topic refs: Topic 5 (audit log scope), Topic 3 (persona-attribution columns),
                Topic 6 (cch_TelemetryEvent — separate from audit log; this script
                does NOT touch telemetry).
    Required PowerShell: 7+. Real impl requires Microsoft.Online.Audit + Microsoft.Xrm.Data.PowerShell.
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
    -ScriptName 'Apply-Auditing.ps1' `
    -Purpose 'Enable auditing at tenant + env + every cch_* table (3 layers)' `
    -Apply $Apply.IsPresent `
    -Settings $settings

$plannedActions = @(
    "Layer 1 -- Tenant (Office 365 audit log):"
    "  - Connect to Exchange Online admin"
    "  - Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled \$true (idempotent; usually on)"
    ""
    "Layer 2 -- Environment (Dataverse audit):"
    "  - Connect to target env '$($settings.environment.url)'"
    "  - Set OrgDbOrgSettings:"
    "      AuditLog = on"
    "      RetentionDays = 90 (default)"
    ""
    "Layer 3 -- Per-table cch_* audit:"
    "  - List all tables matching prefix 'cch_' from solution metadata"
    "  - Verify each has IsAuditEnabled = true"
    "  - Report count of tables already audit-enabled at solution-import time"
    "  - Warn (not fail) if any cch_* table lacks audit (Dataverse-Engineer Phase-1 fix)"
    ""
    "Column-level audit (NOT mutated by this script -- declared in schema):"
    "  - cch_CreatedByPersona, cch_ModifiedByPersona on every audit-relevant table"
    "  - V4 agent-decision columns on cch_Complaint:"
    "      cch_AgentClassification, cch_AgentSeverity, cch_AgentConfidence,"
    "      cch_AgentRationale, cch_AnalystOverride, cch_MdrDraft"
    ""
    "After apply: doctor's [Governance] section reports counts; the V4 demo beat"
    "can claim 'every change to this complaint is in the audit log -- including which"
    "agent / persona made each edit'."
)

Invoke-GovernanceNotImplemented `
    -ScriptName 'Apply-Auditing.ps1' `
    -Purpose 'Audit at tenant + env + per-table layers' `
    -TopicRef 'Topic 5 (audit scope) + Topic 3 (persona-attribution columns)' `
    -PlannedActions $plannedActions `
    -Apply $Apply.IsPresent
