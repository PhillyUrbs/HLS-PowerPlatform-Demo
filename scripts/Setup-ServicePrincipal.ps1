<#
.SYNOPSIS
    Provisions the Entra app registration that flows + agent tools authenticate as.
    Adds it as a Dataverse Application User on the target env.

.DESCRIPTION
    Per Topic 3 connection-ownership lock + Topic 11 section A3 sequencing:
    this script delivers the cch_IdEntraAppServicePrincipal env var. Run once per tenant.

    Uses `pac admin create-service-principal` which performs THREE operations atomically:
      1. Creates an Entra app registration in the operator's tenant
      2. Generates a client secret
      3. Adds the resulting SP as a Dataverse Application User on the target env
         with the assigned security role.

    Per Topic 11 section C8 + Topic 4: secret is written back to deployment-settings.json
    using the SecretRef abstraction (`plain:<value>`). Operator can later migrate
    to Key Vault by editing the value to `kv:<vault>/<name>` with no flow rewrites.

    --whatif (default) prints the action plan + checks for existing SP without mutating.
    -Apply runs `pac admin create-service-principal` for real.

    Idempotent: if cch_IdEntraAppServicePrincipal already set in deployment-settings.json
    AND --Force not passed, exits early with "already provisioned" message.

.PARAMETER Apply
    Switch from --whatif preview to actual mutation. Default is --whatif.

.PARAMETER DeploymentSettingsPath
    Path to deployment-settings.json. Defaults to scripts/deployment-settings.json.

.PARAMETER ApplicationName
    Display name for the Entra app reg. Defaults to "<env-name>-sp" derived from
    deployment-settings.json environment.name (lowercased + sanitized).

.PARAMETER SecurityRole
    Dataverse security role to assign the new app user.
    Default: 'System Administrator' (per `pac admin create-service-principal` default).

    PHASE 1 NOTE: After Dataverse-Engineer's PR #1 (issue #5) lands the bespoke
    'ServicePrincipal' role per Topic 3, change this default to 'ServicePrincipal'.

.PARAMETER Force
    Re-provision even if cch_IdEntraAppServicePrincipal is already set in
    deployment-settings.json. Creates a NEW Entra app + leaves the old one alone
    (does not delete). Operator must manually clean up.

.EXAMPLE
    pwsh ./scripts/Setup-ServicePrincipal.ps1
    Preview only (--whatif default). Reads target env, checks for existing SP,
    prints what would happen.

.EXAMPLE
    pwsh ./scripts/Setup-ServicePrincipal.ps1 -Apply
    Actually creates the Entra app + Dataverse Application User. Writes back to
    deployment-settings.json.

.EXAMPLE
    pwsh ./scripts/Setup-ServicePrincipal.ps1 -Apply -ApplicationName 'continuum-demo-sp'
    Use a custom app reg display name.

.NOTES
    Owner role: Lead (per scripts/AGENTS.md).
    Topic refs: Topic 3 (connection ownership + ServicePrincipal role),
                Topic 4 (cch_IdEntraAppServicePrincipal + cch_SecretSPClient + SecretRef),
                Topic 11 section A3 (Lead PR #2 sequencing).
    Required PowerShell: 7+. Required CLI: pac 2.6+.
    Required auth: operator must have run `pac auth create -url <env-url>` first AND
                   have either Global admin / Power Platform admin / Application admin
                   role in the tenant (to create app regs).

    Out of scope (separate concerns):
      - cch_IdEntraAppPagesAuth -- handled by install.ps1 -Mode install via scripts/lib/EntraApps.ps1
        (separate Entra app reg with web-app redirect URI; uses az ad app create)
      - Microsoft Graph admin consent for ChannelMessage.Send -- separately printed by
        install.ps1 with operator-confirms-once-per-tenant pattern

    Exit codes:
      0   success (whatif preview emitted, OR apply succeeded, OR already provisioned)
      1   user-facing error (settings missing, env unreachable, pac auth failure)
      2   pac command failed unexpectedly
      99  not yet implemented (this script is REAL, not a skeleton; this exit code is
          here for shape consistency only)
#>

#Requires -Version 7.0

[CmdletBinding()]
param(
    [switch] $Apply,
    [string] $DeploymentSettingsPath,
    [string] $ApplicationName,
    [string] $SecurityRole = 'System Administrator',
    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'lib/Governance.ps1')
. (Join-Path $PSScriptRoot 'lib/Secrets.ps1')

# ─── Pre-flight ─────────────────────────────────────────────────────────────

if (-not (Get-Command pac -ErrorAction SilentlyContinue)) {
    Write-Error "Setup-ServicePrincipal: 'pac' CLI not found on PATH. Install from https://aka.ms/pacinstall."
    exit 1
}

$settings = Read-DeploymentSettings -Path $DeploymentSettingsPath

# Derive default app name from env name (sanitized) if not passed
if (-not $ApplicationName) {
    $envName = $settings.environment.name
    $sanitized = ($envName -replace '[^A-Za-z0-9]+', '-').ToLowerInvariant().Trim('-')
    $ApplicationName = "$sanitized-sp"
}

# ─── Banner ─────────────────────────────────────────────────────────────────

Write-GovernanceBanner `
    -ScriptName 'Setup-ServicePrincipal.ps1' `
    -Purpose 'Provision Entra app reg + Dataverse Application User for service principal' `
    -Apply $Apply.IsPresent `
    -Settings $settings

Write-Host "  Application name:  $ApplicationName"
Write-Host "  Security role:     $SecurityRole"
Write-Host "  Force re-provision:$($Force.IsPresent)"
Write-Host ""

# ─── Idempotency check ──────────────────────────────────────────────────────

$existingId = $null
if ((Test-PSObjectProperty -InputObject $settings -PropertyName 'ids') -and
    (Test-PSObjectProperty -InputObject $settings.ids -PropertyName 'cch_IdEntraAppServicePrincipal')) {
    $existingId = $settings.ids.cch_IdEntraAppServicePrincipal
}

if ($existingId -and -not $Force) {
    Write-Host "[idempotent skip] cch_IdEntraAppServicePrincipal already set: $existingId" -ForegroundColor Green
    Write-Host "  Pass -Force to re-provision (creates a NEW app reg; old one is NOT deleted)." -ForegroundColor DarkGray
    exit 0
}

# ─── Action plan ────────────────────────────────────────────────────────────

$plannedActions = @(
    "Verify pac auth context targets '$($settings.environment.url)'"
    "Run: pac admin create-service-principal --environment '$($settings.environment.url)' --name '$ApplicationName' --role '$SecurityRole'"
    "Capture from output:"
    "  - Application (client) ID  -> cch_IdEntraAppServicePrincipal"
    "  - Tenant ID                -> validate matches deployment-settings.tenant.id"
    "  - Generated client secret  -> cch_SecretSPClient (wrapped as plain:<value>)"
    ""
    "Write back to deployment-settings.json:"
    "  ids.cch_IdEntraAppServicePrincipal = <application-id>"
    "  secrets.cch_SecretSPClient         = plain:<generated-secret>"
    ""
    "Verify the SP appears in 'pac admin list-service-principal' for the env"
    ""
    "PHASE 1 follow-up: after Dataverse-Engineer issue #5 lands the bespoke"
    "'ServicePrincipal' security role, re-run with -SecurityRole 'ServicePrincipal'"
    "to downgrade from System Administrator to least-privilege."
)

if (-not $Apply) {
    # --whatif mode: print plan and exit 0 (preview success; the script IS implemented)
    Show-GovernancePreview `
        -ScriptName 'Setup-ServicePrincipal.ps1' `
        -PlannedActions $plannedActions
}

# ─── -Apply path ────────────────────────────────────────────────────────────

Write-Host "[Apply] Running pac admin create-service-principal..." -ForegroundColor Yellow
Write-Host "  This will:" -ForegroundColor DarkGray
Write-Host "    * Create an Entra app registration named '$ApplicationName' in your tenant" -ForegroundColor DarkGray
Write-Host "    * Generate a client secret (you must capture it)" -ForegroundColor DarkGray
Write-Host "    * Add the SP as a Dataverse Application User on $($settings.environment.url)" -ForegroundColor DarkGray
Write-Host "    * Assign security role '$SecurityRole'" -ForegroundColor DarkGray
Write-Host ""

$logPath = New-GovernanceLogPath -ScriptName 'Setup-ServicePrincipal'
Write-Host "  Logging to: $logPath" -ForegroundColor DarkGray
Write-Host ""

# Capture pac output. pac writes structured-ish text; we parse for the IDs.
try {
    $pacOutput = & pac admin create-service-principal `
        --environment $settings.environment.url `
        --name $ApplicationName `
        --role $SecurityRole 2>&1
    $pacExitCode = $LASTEXITCODE
} catch {
    Write-Error "Setup-ServicePrincipal: pac admin create-service-principal threw: $($_.Exception.Message)"
    exit 2
}

# Persist full pac output to log
$pacOutput | Out-File -FilePath $logPath -Encoding utf8

if ($pacExitCode -ne 0) {
    Write-Error "Setup-ServicePrincipal: pac admin create-service-principal failed (exit $pacExitCode). See log: $logPath"
    exit 2
}

# Parse pac output. Format (verified 2026-04-29 against pac 2.6.4):
#   Application Name         <name>
#   Tenant Id                xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#   Application Id           xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#   Service Principal Id     xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#   Client Secret            <secret>
#   Client Secret Expiration <date>
#   System User Id           xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
# Note: 'Id' (not 'ID'), no colon separator, whitespace-aligned columns.
$outputText = $pacOutput -join "`n"

$tenantIdMatch = [regex]::Match($outputText, '^\s*Tenant\s+Id\s+(?<id>[0-9a-fA-F-]{36})\s*$', 'Multiline')
$appIdMatch    = [regex]::Match($outputText, '^\s*Application\s+Id\s+(?<id>[0-9a-fA-F-]{36})\s*$', 'Multiline')
# Client secret has no fixed format -- match everything after "Client Secret" up to end-of-line.
# Avoid matching the "Client Secret Expiration" line by requiring the next non-whitespace
# after "Secret" to NOT be 'Expiration'.
$secretMatch   = [regex]::Match($outputText, '^\s*Client\s+Secret\s+(?!Expiration)(?<secret>\S+)\s*$', 'Multiline')

if (-not $appIdMatch.Success) {
    Write-Error "Setup-ServicePrincipal: could not parse Application ID from pac output. See log: $logPath"
    exit 2
}
if (-not $secretMatch.Success) {
    Write-Error "Setup-ServicePrincipal: could not parse Client Secret from pac output. See log: $logPath"
    exit 2
}

$newAppId  = $appIdMatch.Groups['id'].Value
$newSecret = $secretMatch.Groups['secret'].Value

Write-Host "[Apply] pac succeeded:" -ForegroundColor Green
Write-Host "  Application (client) ID: $newAppId" -ForegroundColor Green
Write-Host "  Client secret captured (length $($newSecret.Length); not echoed)" -ForegroundColor Green
Write-Host ""

# Optional: validate tenant id if the operator's deployment-settings.tenant.id is set
if ($tenantIdMatch.Success) {
    $observedTenantId = $tenantIdMatch.Groups['id'].Value
    $declaredTenantId = $settings.tenant.id
    if ($declaredTenantId -and $declaredTenantId -ne '<set-me: tenant GUID>' -and $observedTenantId -ne $declaredTenantId) {
        Write-Warning "Setup-ServicePrincipal: pac reported tenant '$observedTenantId' but deployment-settings.tenant.id is '$declaredTenantId'. Continuing, but you may want to update settings."
    }
}

# ─── Write back to deployment-settings.json ─────────────────────────────────

Write-Host "[Apply] Writing back to deployment-settings.json..." -ForegroundColor Yellow

# Ensure the ids + secrets sections exist
if (-not (Test-PSObjectProperty -InputObject $settings -PropertyName 'ids')) {
    $settings | Add-Member -MemberType NoteProperty -Name 'ids' -Value ([pscustomobject]@{})
}
if (-not (Test-PSObjectProperty -InputObject $settings -PropertyName 'secrets')) {
    $settings | Add-Member -MemberType NoteProperty -Name 'secrets' -Value ([pscustomobject]@{})
}

# Set / update the two values
Set-PSObjectProperty -InputObject $settings.ids -PropertyName 'cch_IdEntraAppServicePrincipal' -Value $newAppId

$secretRef = "plain:$newSecret"
Set-PSObjectProperty -InputObject $settings.secrets -PropertyName 'cch_SecretSPClient' -Value $secretRef

# Write back. Use Depth 10 to preserve nested objects.
$settingsPath = if ($DeploymentSettingsPath) { $DeploymentSettingsPath } elseif ($env:DEPLOYMENT_SETTINGS_PATH) { $env:DEPLOYMENT_SETTINGS_PATH } else { Join-Path (Get-RepoRoot) 'scripts/deployment-settings.json' }

# Validate the resulting secret reference parses cleanly
$parsed = Test-SecretReference $secretRef
if ($parsed.Mode -ne 'plain') {
    Write-Error "Setup-ServicePrincipal: unexpected SecretRef shape after wrap: $($parsed | ConvertTo-Json -Compress). Aborting write-back."
    exit 2
}

$settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding utf8

Write-Host "[Apply] Wrote: $settingsPath" -ForegroundColor Green
Write-Host "  ids.cch_IdEntraAppServicePrincipal = $newAppId" -ForegroundColor Green
Write-Host "  secrets.cch_SecretSPClient         = plain:<redacted; length $($newSecret.Length)>" -ForegroundColor Green
Write-Host ""

# ─── Reminder for follow-up steps ───────────────────────────────────────────

Write-Host "Next steps for the operator:" -ForegroundColor Cyan
Write-Host "  1. Run 'pac admin list-service-principal --environment $($settings.environment.url)' to verify." -ForegroundColor DarkGray
Write-Host "  2. After Dataverse-Engineer issue #5 (Phase 1) lands the bespoke 'ServicePrincipal' role," -ForegroundColor DarkGray
Write-Host "     re-run this script with -SecurityRole 'ServicePrincipal' to downgrade from SysAdmin." -ForegroundColor DarkGray
Write-Host "  3. install.ps1 will separately handle the Pages Entra app reg + Graph admin consent" -ForegroundColor DarkGray
Write-Host "     for ChannelMessage.Send (operator confirms inline at install time)." -ForegroundColor DarkGray
Write-Host ""

exit 0
