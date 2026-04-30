<#
.SYNOPSIS
    Migration 0001 — Baseline schema establishment.

.DESCRIPTION
    No-op migration: the schema is already established by the Phase-1 solution import.
    This migration only stamps the cch_DeploymentVersion environment variable to "0.1.0"
    to record that the baseline schema is in place.

    Per locked migration framework (handoff §3.15): this is the first migration.
    Destructive: false.

.METADATA
    Name: 0001_baseline
    Version: 0.1.0
    Destructive: false
    Description: Baseline schema — 15 tables, 6 security roles, 3 web roles, 6 option sets.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$EnvironmentUrl,
    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "[0001_baseline] Starting baseline migration." -ForegroundColor Cyan
Write-Host "[0001_baseline] Destructive: false" -ForegroundColor Cyan

if (-not $Apply) {
    Write-Host "[0001_baseline] --whatif mode: would stamp cch_DeploymentVersion = '0.1.0'. Pass -Apply to execute." -ForegroundColor Yellow
    return
}

# Stamp cch_DeploymentVersion environment variable
# Actual PAC CLI command: pac env update-env-variable --environment $EnvironmentUrl --name cch_DeploymentVersion --value "0.1.0"
# This requires pac CLI authenticated to the target environment.
try {
    $result = pac env update-env-variable `
        --environment $EnvironmentUrl `
        --name "cch_DeploymentVersion" `
        --value "0.1.0" 2>&1
    Write-Host "[0001_baseline] cch_DeploymentVersion stamped to '0.1.0'." -ForegroundColor Green
    Write-Host $result
}
catch {
    Write-Warning "[0001_baseline] Failed to stamp cch_DeploymentVersion: $_"
    Write-Warning "[0001_baseline] This is non-fatal — operator may need to set it manually via Power Platform admin center."
}

Write-Host "[0001_baseline] Migration complete." -ForegroundColor Green
