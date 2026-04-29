<#
.SYNOPSIS
    Shared helpers for governance scripts. Dot-source from Apply-*.ps1 / Provision-*.ps1.

.DESCRIPTION
    Per Topic 5 governance lock + Topic 11 section C3 multi-sitting Phase 0:
    every governance script defaults to --whatif (preview-only), is idempotent,
    reads target env from deployment-settings.json, and logs to scripts/governance/.last-run/<name>.log.

    This file factors out the boilerplate. Consumers dot-source it:
      . (Join-Path $PSScriptRoot '../lib/Governance.ps1')

.NOTES
    Owner role: Governance (per scripts/AGENTS.md).
    Topic refs: Topic 5 (governance config), Topic 11 section C3 (multi-sitting), Topic 11 doctor JSON pin.
    Required PowerShell: 7+.
    Exit codes (consumers should use these):
      0   success (whatif preview emitted, OR apply succeeded)
      1   user-facing error (settings missing, env unreachable, etc.)
      99  not yet implemented (skeleton)
#>

#Requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    $root = git rev-parse --show-toplevel 2>$null
    if (-not $root) {
        throw "Governance.ps1: not inside a git repo. Run from the HLS-PowerPlatform-Demo working tree."
    }
    return $root.Trim()
}

function Read-DeploymentSettings {
    <#
    .SYNOPSIS
        Loads scripts/deployment-settings.json (or path override) and validates required top-level keys exist.
        Returns the parsed object, or throws if the file is missing / malformed.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [string] $Path
    )

    if (-not $Path) {
        $Path = $env:DEPLOYMENT_SETTINGS_PATH
    }
    if (-not $Path) {
        $Path = Join-Path (Get-RepoRoot) 'scripts/deployment-settings.json'
    }

    if (-not (Test-Path $Path)) {
        throw "Read-DeploymentSettings: file not found at '$Path'. Copy scripts/deployment-settings.json.template and fill in values."
    }

    try {
        $settings = Get-Content $Path -Raw | ConvertFrom-Json
    } catch {
        throw "Read-DeploymentSettings: failed to parse '$Path' as JSON: $($_.Exception.Message)"
    }

    # Minimum-viable shape check (full schema validation deferred to Tier-1 ajv-cli).
    foreach ($key in @('environment', 'superUsers', 'tenant')) {
        if (-not $settings.PSObject.Properties.Name.Contains($key)) {
            throw "Read-DeploymentSettings: '$Path' missing required top-level key '$key'."
        }
    }
    if (-not $settings.environment.PSObject.Properties.Name.Contains('url')) {
        throw "Read-DeploymentSettings: 'environment.url' is required in '$Path'."
    }

    return $settings
}

function Write-GovernanceBanner {
    <#
    .SYNOPSIS
        Prints the standard banner shared by every governance script.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $ScriptName,
        [Parameter(Mandatory)] [string] $Purpose,
        [Parameter(Mandatory)] [bool]   $Apply,
        [Parameter(Mandatory)] [psobject] $Settings
    )
    $modeBanner = if ($Apply) {
        '[APPLY -- WILL MUTATE]'
    } else {
        '[WHATIF -- preview only; pass -Apply to actually run]'
    }

    Write-Host ""
    Write-Host "--- Governance: $ScriptName -----------------------------------------" -ForegroundColor Cyan
    Write-Host "  Purpose:           $Purpose"
    Write-Host "  Target env:        $($Settings.environment.name) ($($Settings.environment.url))"
    Write-Host "  Mode:              $modeBanner"
    Write-Host "----------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
}

function New-GovernanceLogPath {
    <#
    .SYNOPSIS
        Returns the path to scripts/governance/.last-run/<name>.log, ensuring the dir exists.
        Logs are gitignored (.gitignore: scripts/governance/.last-run/).
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] [string] $ScriptName
    )
    $dir = Join-Path (Get-RepoRoot) 'scripts/governance/.last-run'
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Join-Path $dir "$ScriptName.log"
}

function Invoke-GovernanceNotImplemented {
    <#
    .SYNOPSIS
        Standard skeleton exit per Topic 11 section C3 -- Phase-0 governance scripts emit
        the planned action plan (preview), then exit 99.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]   $ScriptName,
        [Parameter(Mandatory)] [string]   $Purpose,
        [Parameter(Mandatory)] [string]   $TopicRef,
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]] $PlannedActions,
        [bool] $Apply = $false
    )
    Write-Host "Planned actions (when implemented):" -ForegroundColor DarkCyan
    foreach ($action in $PlannedActions) {
        if ([string]::IsNullOrWhiteSpace($action)) {
            Write-Host ""
        } else {
            Write-Host "  $action" -ForegroundColor DarkGray
        }
    }
    Write-Host ""
    if ($Apply) {
        Write-Host "[NotImplemented] -Apply requested but '$ScriptName' has no real implementation yet." -ForegroundColor Yellow
    } else {
        Write-Host "[NotImplemented] '$ScriptName' is a Phase-0 skeleton." -ForegroundColor Yellow
    }
    Write-Host "  See: $TopicRef" -ForegroundColor DarkGray
    Write-Host "  Real implementation lands in a subsequent sitting." -ForegroundColor DarkGray
    Write-Host "  Exit code 99." -ForegroundColor DarkGray
    exit 99
}
