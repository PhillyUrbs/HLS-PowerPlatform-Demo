<#
.SYNOPSIS
    Read-only health check for the HLS Power Platform Demo. Reports posture without changing data.

.DESCRIPTION
    Per Topic 11 section C3 (Phase 0 multi-sitting), this is a **skeleton**: every section
    emits a single `[NotImplemented]` finding so the JSON output schema (Topic 11
    pin) is exercised end-to-end + the runner can already use --vignette / --mode flags.

    Real check implementations land in subsequent sittings/phases (typically as the
    surface they audit ships). Doctor is read-only and never mutates regardless of
    flags (locked Topic 5 + Topic 6 + Topic 8B + Topic 10 doctor rules).

.PARAMETER Vignette
    Subset to one vignette's pre-flight check set: V1 | V2 | V3 | V4 | V5 | V6.
    Used by Demo Health pre-flight buttons (Topic 9 + 9B).

.PARAMETER Mode
    full      Default. Run all sections.
    chained   Run union of all 6 vignette pre-flights + bridge-state checks.
    highlight Run V1 + V4 + V6 pre-flights only (highlight reel).

.PARAMETER Json
    Emit JSON to stdout (per Topic 11 doctor JSON output schema). Default: human-
    readable.

.PARAMETER Section
    Filter to a single section: Permissions | EnvVars | Governance | Telemetry |
    A11y | Knowledge | Squad | Agents.

.EXAMPLE
    pwsh ./scripts/doctor.ps1
    Full read-only health check, human output.

.EXAMPLE
    pwsh ./scripts/doctor.ps1 --vignette V4 --json
    Pre-flight check for V4 only, JSON output (consumed by Demo Health 'Pre-flight V4' button).

.NOTES
    Owner role: Tester (per scripts/AGENTS.md).
    Topic refs: Topic 11 (doctor JSON output schema pin), Topic 5 (Governance section),
                Topic 6 (Telemetry section), Topic 7 (A11y section), Topic 8B (Knowledge
                section), Topic 10 (Squad section), Topic 9 + 9B (vignette modes).
    Required PowerShell: 7+.
    Exit codes:
      0   all checks pass or info/warn only
      1   one or more checks errored (severity = error)
      2   doctor itself errored (cannot read phase.json, cannot reach env, etc.)
#>

#Requires -Version 7.0

[CmdletBinding()]
param(
    [ValidateSet('V1', 'V2', 'V3', 'V4', 'V5', 'V6')]
    [string] $Vignette,

    [ValidateSet('full', 'chained', 'highlight')]
    [string] $Mode = 'full',

    [switch] $Json,

    [ValidateSet('Permissions', 'EnvVars', 'Governance', 'Telemetry', 'A11y', 'Knowledge', 'Squad', 'Agents')]
    [string] $Section = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ─── Locate repo root ───────────────────────────────────────────────────────
$repoRoot = (git rev-parse --show-toplevel 2>$null)
if (-not $repoRoot) { Write-Error "doctor.ps1: not inside a git repo."; exit 2 }
$repoRoot = $repoRoot.Trim()

# ─── Run identity (per Topic 11 doctor JSON schema) ─────────────────────────
$runId  = [guid]::NewGuid().ToString()
$ranAt  = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
$result = [pscustomobject]@{
    version  = '1.0'
    runId    = $runId
    ranAt    = $ranAt
    vignette = $Vignette
    mode     = $Mode
    sections = @()
}

# ─── Helper: add a finding to a section ─────────────────────────────────────
function New-Finding {
    param(
        [Parameter(Mandatory)] [string] $Id,
        [Parameter(Mandatory)] [ValidateSet('pass', 'info', 'warn', 'error')] [string] $Severity,
        [Parameter(Mandatory)] [string] $Title,
        [string] $Detail,
        [string] $DeepLink
    )
    [pscustomobject]@{
        id       = $Id
        severity = $Severity
        title    = $Title
        detail   = $Detail
        deepLink = $DeepLink
    }
}

function Add-Section {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [array]  $Findings
    )
    $script:result.sections += [pscustomobject]@{
        name     = $Name
        findings = $Findings
    }
}

# ─── Section runners (skeletons) ────────────────────────────────────────────

function Get-Section_Permissions {
    @(
        New-Finding -Id 'permissions.skeleton' -Severity 'info' `
            -Title '[NotImplemented] Permissions section' `
            -Detail 'TODO Pages-Engineer + Governance: wire audit-permissions skill output here. See Topic 3 + Topic 8B knowledge ACL extension.'
    )
}

function Get-Section_EnvVars {
    # Real check (we have what we need today): parse EnvVarManifest.json + verify
    # naming pattern. Full env-var validation against deployed Dataverse is Phase 1+.
    $findings = @()
    $manifestPath = Join-Path $repoRoot 'scripts/lib/EnvVarManifest.json'
    if (-not (Test-Path $manifestPath)) {
        $findings += New-Finding -Id 'envvars.manifest.missing' -Severity 'error' `
            -Title 'EnvVarManifest.json missing' `
            -Detail "Expected at $manifestPath"
    } else {
        try {
            $m = Get-Content $manifestPath -Raw | ConvertFrom-Json
            $count = $m.variables.Count
            $required = @($m.variables | Where-Object { $_.required }).Count
            $findings += New-Finding -Id 'envvars.manifest.parsed' -Severity 'pass' `
                -Title "EnvVarManifest.json parsed ($count vars, $required required)"

            # Naming pattern check
            $bad = @($m.variables | Where-Object { $_.name -notmatch '^cch_(Url|Id|Secret|Tunable|Feature|Brand)[A-Z][A-Za-z0-9]*$' })
            if ($bad.Count -gt 0) {
                $findings += New-Finding -Id 'envvars.naming.malformed' -Severity 'error' `
                    -Title "$($bad.Count) env var(s) violate cch_<Category><Name> convention" `
                    -Detail (($bad | ForEach-Object { $_.name }) -join ', ')
            } else {
                $findings += New-Finding -Id 'envvars.naming.clean' -Severity 'pass' `
                    -Title "All env var names match cch_<Category><Name>"
            }
        } catch {
            $findings += New-Finding -Id 'envvars.manifest.parse-fail' -Severity 'error' `
                -Title 'EnvVarManifest.json failed to parse' `
                -Detail $_.Exception.Message
        }
    }

    # TODO Tester (Phase 1+): once a target Dataverse env exists,
    #   - Load deployed cch_* env vars
    #   - Cross-reference against manifest (missing-required → upgrade prompt)
    #   - URL env vars must start with https:// + no localhost / 127.0.0.1
    #   - GUID env vars match GUID regex
    #   - Secret env vars: non-empty + format-valid via Test-SecretReference;
    #     plain:* emits info-level "consider KV" finding
    #   - Cron tunables parse (Cronos)
    #   - Boolean feature flags must be 'true' or 'false'
    $findings += New-Finding -Id 'envvars.deployed.not-yet-checked' -Severity 'info' `
        -Title '[NotImplemented] Deployed Dataverse env-var check' `
        -Detail 'Lands in Phase 1+ once a target env exists.'

    # Entra app reg checks (per Topic 11 section A3 / Lead PR #2 / Sitting 4g):
    # We can already verify deployment-settings.json *contains* the two Entra app IDs
    # without needing tenant access. Doctor stays read-only.
    $settingsPath = Join-Path $repoRoot 'scripts/deployment-settings.json'
    if (Test-Path $settingsPath) {
        try {
            $s = Get-Content $settingsPath -Raw | ConvertFrom-Json
            $hasIds = ($s.PSObject.Properties.Name -contains 'ids') -and $s.ids -and (@($s.ids.PSObject.Properties).Count -gt 0)
            foreach ($idName in @('cch_IdEntraAppServicePrincipal', 'cch_IdEntraAppPagesAuth')) {
                $present = $false
                $value = $null
                if ($hasIds) {
                    $props = @($s.ids.PSObject.Properties)
                    if ($props.Name -contains $idName) {
                        $value = $s.ids.$idName
                        $present = ($null -ne $value -and $value -ne '')
                    }
                }
                if ($present) {
                    $findings += New-Finding -Id "envvars.entra.$idName.present" -Severity 'pass' `
                        -Title "$idName populated in deployment-settings.json"
                } else {
                    $findings += New-Finding -Id "envvars.entra.$idName.missing" -Severity 'info' `
                        -Title "$idName not yet populated" `
                        -Detail 'Run scripts/Setup-ServicePrincipal.ps1 (for SP) or scripts/install.ps1 -Mode install (for Pages auth) to provision.'
                }
            }
        } catch {
            $findings += New-Finding -Id 'envvars.settings.parse-fail' -Severity 'warn' `
                -Title 'deployment-settings.json failed to parse for Entra-id check' `
                -Detail $_.Exception.Message
        }
    } else {
        $findings += New-Finding -Id 'envvars.settings.missing' -Severity 'info' `
            -Title 'deployment-settings.json not present' `
            -Detail 'Operator copies scripts/deployment-settings.json.template before running install.ps1.'
    }

    $findings
}

function Get-Section_Governance {
    @(
        New-Finding -Id 'governance.skeleton' -Severity 'info' `
            -Title '[NotImplemented] Governance section' `
            -Detail 'TODO Governance (Sitting 5): report DLP applied, ME enabled, audit at 3 layers, Pipelines host present, CoE installed (info-only). See Topic 5 Doctor coverage.'
    )
}

function Get-Section_Telemetry {
    @(
        New-Finding -Id 'telemetry.skeleton' -Severity 'info' `
            -Title '[NotImplemented] Telemetry section' `
            -Detail 'TODO Tester (Phase 4): cch_TelemetryEvent row count, errors last 24h, agent tool-call success rate, flow success rate, oldest event > retention, cch_LogTelemetry enabled, payload schema-drift. See Topic 6 Doctor.'
    )
}

function Get-Section_A11y {
    @(
        New-Finding -Id 'a11y.skeleton' -Severity 'info' `
            -Title '[NotImplemented] A11y section' `
            -Detail 'TODO Tester: read last CI run summary; report a11y status as info only (Topic 7).'
    )
}

function Get-Section_Knowledge {
    @(
        New-Finding -Id 'knowledge.skeleton' -Severity 'info' `
            -Title '[NotImplemented] Knowledge section' `
            -Detail 'TODO Scribe + Tester (Phase 1+): SharePoint library exists, 4 subfolders present, 15 docs match inventory, lastReviewed freshness < 8d, ACLs match spec. See Topic 8B Doctor Knowledge.'
    )
}

function Get-Section_Squad {
    # Real check today: phase.json validity + AGENTS.md presence + decisions.md staleness
    $findings = @()

    $phasePath = Join-Path $repoRoot '.squad/phase.json'
    if (-not (Test-Path $phasePath)) {
        $findings += New-Finding -Id 'squad.phase-json.missing' -Severity 'error' `
            -Title '.squad/phase.json missing'
    } else {
        try {
            $p = Get-Content $phasePath -Raw | ConvertFrom-Json
            $required = @('currentPhase','currentPhaseName','phaseStartedAt','allowedFolders','warningFolders','completionChecklist')
            $missing = @($required | Where-Object { -not $p.PSObject.Properties.Name.Contains($_) })
            if ($missing.Count -gt 0) {
                $findings += New-Finding -Id 'squad.phase-json.shape' -Severity 'error' `
                    -Title 'phase.json missing required keys' -Detail ($missing -join ', ')
            } else {
                $findings += New-Finding -Id 'squad.phase-json.ok' -Severity 'pass' `
                    -Title "phase.json valid (currentPhase=$($p.currentPhase) — $($p.currentPhaseName))"
            }
        } catch {
            $findings += New-Finding -Id 'squad.phase-json.parse-fail' -Severity 'error' `
                -Title 'phase.json failed to parse' -Detail $_.Exception.Message
        }
    }

    # AGENTS.md presence (root + 7 subfolders)
    $required = @(
        'AGENTS.md',
        'solutions/ContinuumHealthDemo/AGENTS.md',
        'apps/field-companion/AGENTS.md',
        'sites/continuum-portal/AGENTS.md',
        'agents/AGENTS.md',
        'scripts/AGENTS.md',
        'data/AGENTS.md',
        'docs/AGENTS.md'
    )
    $missing = @($required | Where-Object { -not (Test-Path (Join-Path $repoRoot $_)) })
    if ($missing.Count -gt 0) {
        $findings += New-Finding -Id 'squad.agents-md.missing' -Severity 'warn' `
            -Title "$($missing.Count) AGENTS.md file(s) missing" -Detail ($missing -join ', ')
    } else {
        $findings += New-Finding -Id 'squad.agents-md.ok' -Severity 'pass' `
            -Title 'All 8 AGENTS.md files present (root + 7 subfolders)'
    }

    # decisions.md freshness
    $decPath = Join-Path $repoRoot '.squad/decisions.md'
    if (Test-Path $decPath) {
        $age = (Get-Date) - (Get-Item $decPath).LastWriteTime
        if ($age.TotalDays -gt 30) {
            $findings += New-Finding -Id 'squad.decisions.stale' -Severity 'warn' `
                -Title "decisions.md last updated $([math]::Round($age.TotalDays)) days ago" `
                -Detail 'May indicate drift if commits have landed in this period.'
        } else {
            $findings += New-Finding -Id 'squad.decisions.fresh' -Severity 'pass' `
                -Title "decisions.md last updated $([math]::Round($age.TotalDays)) day(s) ago"
        }
    }

    $findings
}

function Get-Section_Agents {
    @(
        New-Finding -Id 'agents.skeleton' -Severity 'info' `
            -Title '[NotImplemented] Agents section' `
            -Detail 'TODO Agent-Builder + Tester (Phase 5): m365-readiness.md exists, all 6 checklist boxes checked, agents/employee-enablement/icons/ present. See Topic 8C M365 readiness.'
    )
}

# ─── Run sections ───────────────────────────────────────────────────────────

# Section selection logic (Section filter trumps Vignette/Mode)
$sectionsToRun = if ($Section) {
    @($Section)
} elseif ($Vignette) {
    # Vignette mode: minimal subset
    # TODO Tester (Sitting 4 follow-up + Phase 3+): per-vignette section subset per Topic 9B.
    # For now, run all sections so the runner is exercised end-to-end.
    @('Permissions','EnvVars','Governance','Telemetry','A11y','Knowledge','Squad','Agents')
} else {
    @('Permissions','EnvVars','Governance','Telemetry','A11y','Knowledge','Squad','Agents')
}

foreach ($sectionName in $sectionsToRun) {
    $fn = "Get-Section_$sectionName"
    $findings = & $fn
    Add-Section -Name $sectionName -Findings $findings
}

# ─── Output ─────────────────────────────────────────────────────────────────

if ($Json) {
    # -Compress emits single-line JSON which avoids embedded CR/LF in strings on Windows
    # (Python's strict JSON parser rejects bare \r in string values).
    $result | ConvertTo-Json -Depth 10 -Compress
} else {
    Write-Host ""
    Write-Host "--- doctor.ps1 - read-only health check ------------------------------" -ForegroundColor Cyan
    $vignetteLabel = if ($Vignette) { " [$Vignette]" } else { '' }
    Write-Host "  Run:    $runId" -ForegroundColor DarkGray
    Write-Host "  Mode:   $Mode$vignetteLabel" -ForegroundColor DarkGray
    Write-Host "----------------------------------------------------------------------" -ForegroundColor Cyan

    foreach ($sectionResult in $result.sections) {
        Write-Host ""
        Write-Host "[$($sectionResult.name)]" -ForegroundColor Cyan
        foreach ($f in $sectionResult.findings) {
            $color = switch ($f.severity) {
                'pass'  { 'Green' }
                'info'  { 'DarkGray' }
                'warn'  { 'Yellow' }
                'error' { 'Red' }
            }
            $marker = switch ($f.severity) {
                'pass'  { '  pass ' }
                'info'  { '  info ' }
                'warn'  { '  warn ' }
                'error' { '  ERR  ' }
            }
            Write-Host "$marker $($f.title)" -ForegroundColor $color
            if ($f.detail) {
                Write-Host "         $($f.detail)" -ForegroundColor DarkGray
            }
        }
    }
    Write-Host ""
}

# Exit 1 if any error-severity finding exists
$errors = @($result.sections | ForEach-Object { $_.findings | Where-Object { $_.severity -eq 'error' } })
if ($errors.Count -gt 0) {
    if (-not $Json) {
        Write-Host "doctor: $($errors.Count) error-level finding(s)." -ForegroundColor Red
    }
    exit 1
}
exit 0
