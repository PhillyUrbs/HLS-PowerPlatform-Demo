<#
.SYNOPSIS
    Lifecycle entry point for the HLS Power Platform Demo (install / upgrade / uninstall / doctor / seed / refresh-dates).

.DESCRIPTION
    Per Topic 11 §C3 (Phase 0 lands in multiple sittings), this script is currently a
    **skeleton**: every mode parses arguments, validates deployment-settings.json against
    its schema, then exits with a structured "[NotImplemented]" message and exit code 99.

    Real implementations land in subsequent sittings (Sitting 4g for Lead PR #2 = Entra
    app reg provisioning; later sittings for solution import, env var population, smoke,
    etc.).

    The script is invoked directly OR via the thin entry-point wrappers (upgrade.ps1,
    uninstall.ps1) which forward to install.ps1 with the appropriate -Mode.

.PARAMETER Mode
    install         First-time provision: env vars, Entra app regs, SharePoint, Teams,
                    solution import, seed data. Once per env.
    upgrade         Default in CI. Solution upsert, code app push, Pages re-publish,
                    agent re-publish, schema migrations, idempotent re-provision,
                    insert-only seed updates by default.
    uninstall       Manual + interactive. Default scope: solution + Entra apps +
                    SharePoint site + Teams team. Does NOT default to demo super user
                    delete or DLP/ME removal. --yes-to-all flag (TODO) for scripted use.
    doctor          Read-only health check across 7 sections (Permissions, EnvVars,
                    Governance, Telemetry, A11y, Knowledge, Squad). Reports drift;
                    never changes data. Delegates to scripts/doctor.ps1.
    seed            Re-seed Dataverse with synthetic data. Use --reseed to wipe + reseed
                    (default is insert-net-new only).
    refresh-dates   Run the cch_TunableDemoRefreshCron logic on demand (slides every
                    time-sensitive field forward by elapsed delta).

.PARAMETER DeploymentSettingsPath
    Path to deployment-settings.json. Defaults to scripts/deployment-settings.json.
    Override with -DeploymentSettingsPath or env var DEPLOYMENT_SETTINGS_PATH.

.PARAMETER Apply
    Mutate. Default is --whatif (preview only). Per locked Topic 5 + scripts/AGENTS.md
    house rule, every state-changing operation requires explicit -Apply.

.PARAMETER NonInteractive
    Skip all operator prompts (CI / scripted use). Will fail fast if any required env
    var is missing rather than prompting.

.PARAMETER LogLevel
    info (default) | debug | trace. Override with env var LOG_LEVEL.

.EXAMPLE
    pwsh ./scripts/install.ps1 -Mode install

    Preview install (--whatif default). Validates deployment-settings.json shape, prompts
    for any missing required env vars, prints the action plan, exits without mutating.

.EXAMPLE
    pwsh ./scripts/install.ps1 -Mode upgrade -Apply -NonInteractive

    Default mode in CI. Detects new required env vars added since last deploy, runs
    pending migrations, re-imports solution, refreshes Code App + Pages.

.EXAMPLE
    pwsh ./scripts/install.ps1 -Mode doctor

    Runs scripts/doctor.ps1 (read-only; no mutation regardless of -Apply flag).

.NOTES
    Owner role: Lead (per scripts/AGENTS.md).
    Topic refs: Topic 4 (env vars), Topic 5 (governance scripts emitted but not run),
                Topic 11 §A3 (Entra provisioning is Lead PR #2 = Sitting 4g).
    Required PowerShell: 7+.
    Exit codes:
      0   success
      1   user-facing error (validation failed, missing required env var, etc.)
      2   environment error (target env unreachable, auth failure, etc.)
      99  not yet implemented (this skeleton)
#>

#Requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('install', 'upgrade', 'uninstall', 'doctor', 'seed', 'refresh-dates')]
    [string] $Mode,

    [string] $DeploymentSettingsPath,

    [switch] $Apply,

    [switch] $NonInteractive,

    [ValidateSet('info', 'debug', 'trace')]
    [string] $LogLevel
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ─── Resolve repo root ──────────────────────────────────────────────────────
$repoRoot = git rev-parse --show-toplevel 2>$null
if (-not $repoRoot) {
    Write-Error "install.ps1: not inside a git repo. Run from the HLS-PowerPlatform-Demo working tree."
    exit 1
}
$repoRoot = $repoRoot.Trim()

# ─── Resolve LogLevel from env if not passed ────────────────────────────────
if (-not $PSBoundParameters.ContainsKey('LogLevel')) {
    $envLog = $env:LOG_LEVEL
    if ($envLog) {
        if ($envLog -in @('info', 'debug', 'trace')) {
            $LogLevel = $envLog
        } else {
            Write-Warning "install.ps1: ignoring invalid LOG_LEVEL='$envLog' from env; using 'info'."
            $LogLevel = 'info'
        }
    } else {
        $LogLevel = 'info'
    }
}

# ─── Resolve DeploymentSettingsPath ─────────────────────────────────────────
if (-not $DeploymentSettingsPath) {
    $DeploymentSettingsPath = $env:DEPLOYMENT_SETTINGS_PATH
    if (-not $DeploymentSettingsPath) {
        $DeploymentSettingsPath = Join-Path $repoRoot 'scripts/deployment-settings.json'
    }
}

# ─── Banner ─────────────────────────────────────────────────────────────────
$bannerMode = if ($Apply) { '[APPLY]' } else { '[WHATIF — no mutation; pass -Apply to actually run]' }
Write-Host ""
Write-Host "─── HLS Power Platform Demo — install.ps1 ─────────────────────────────" -ForegroundColor Cyan
Write-Host "  Mode:                      $Mode"
Write-Host "  Deployment settings:       $DeploymentSettingsPath"
Write-Host "  Apply:                     $bannerMode"
Write-Host "  Non-interactive:           $($NonInteractive.IsPresent)"
Write-Host "  Log level:                 $LogLevel"
Write-Host "  Repo root:                 $repoRoot"
Write-Host "────────────────────────────────────────────────────────────────────────" -ForegroundColor Cyan
Write-Host ""

# ─── Mode dispatcher ────────────────────────────────────────────────────────

function Invoke-NotImplemented {
    param([string] $What, [string] $Topic)
    Write-Host "[NotImplemented] $What" -ForegroundColor Yellow
    Write-Host "  See: $Topic" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "This is a Phase 0 skeleton. Real implementation lands in a subsequent sitting." -ForegroundColor DarkGray
    Write-Host "Exit code 99." -ForegroundColor DarkGray
    exit 99
}

switch ($Mode) {
    'install' {
        # TODO Lead (Sitting 4g+):
        #   1. Validate deployment-settings.json against deployment-settings.schema.json
        #   2. Prompt for missing required env vars (unless -NonInteractive)
        #   3. Provision Entra app regs (cch_IdEntraAppPagesAuth + cch_IdEntraAppServicePrincipal)
        #      — see Setup-ServicePrincipal.ps1 (Sitting 4g per Topic 11 §A3)
        #   4. Provision SharePoint site + Continuum Knowledge library + 4 subfolders
        #   5. Provision Teams team + 4 channels (Quality, Leadership, Field, Enablement)
        #      + add SP to team membership; prompt for Graph admin consent for ChannelMessage.Send
        #   6. Import solution (pac solution import) — empty in Phase 0; tables land Phase 1
        #   7. Populate Dataverse env vars from settings + EnvVarManifest defaults
        #   8. Run baseline migration (0001_baseline.ps1) — stamps cch_DeploymentVersion
        #   9. Insert seed data (via data/seed.ts when Phase 1 ships)
        #  10. Emit governance scripts (scripts/governance/*.ps1) per Topic 5; print paths.
        #      Do NOT run them.
        #  11. Run smoke suite (scripts/lib/Smoke.ps1) — Sitting 5+
        #  12. Print pre-demo checklist + Demo Health URL
        Invoke-NotImplemented `
            -What "install: full first-time provision" `
            -Topic "Topic 4 (env vars), Topic 5 (governance), Topic 11 §A3 (Entra sequencing)"
    }

    'upgrade' {
        # TODO Lead:
        #   1. Validate deployment-settings.json
        #   2. Detect schema migrations newer than current cch_DeploymentVersion
        #   3. Detect new required env vars added since last deploy; prompt for values
        #      (unless -NonInteractive, in which case fail fast)
        #   4. Print pre-upgrade summary: solution version delta, migrations to run
        #      (and how many destructive), agents to republish, env vars needing values,
        #      connection refs needing binding
        #   5. If interactive AND there are destructive migrations, confirm; if
        #      -NonInteractive AND -AllowDestructive not set, fail fast
        #   6. Run migrations in order
        #   7. Solution upsert (pac solution import --force-overwrite)
        #   8. Code App push (pac code push) — when apps/field-companion/ exists
        #   9. Pages re-publish (pac pages upload + activate) — when sites/continuum-portal/ exists
        #  10. Agent re-publish (only if version changed; --force-agents overrides)
        #  11. Insert-only seed updates (--reseed wipes + reseeds)
        #  12. Run smoke suite
        #  13. Append entry to cch_DeploymentHistory
        Invoke-NotImplemented `
            -What "upgrade: solution upsert + delta migrations + idempotent re-provision" `
            -Topic "Topic 4 (env-var lifecycle), handoff §3.15 (lifecycle modes + migrations)"
    }

    'uninstall' {
        # TODO Lead:
        #   1. Interactive selection of what to remove (or -YesToAll for scripted)
        #   2. Default scope: solution + Entra app regs + SharePoint site + Teams team
        #   3. Confirm before each destructive operation (per scripts/AGENTS.md house rule)
        #   4. Does NOT default to demo super user delete or DLP/ME removal
        #   5. With --include-governance: emit Revert-*.ps1 scripts (do not run them)
        #   6. Append entry to cch_DeploymentHistory before deleting solution
        Invoke-NotImplemented `
            -What "uninstall: interactive scope selection + reverse provisioning" `
            -Topic "Topic 5 (governance not in default uninstall scope), handoff §3.14"
    }

    'doctor' {
        # Doctor is read-only and can be invoked directly via scripts/doctor.ps1.
        # Forward to it preserving relevant flags. Doctor never mutates regardless of -Apply.
        $doctorPath = Join-Path $repoRoot 'scripts/doctor.ps1'
        if (-not (Test-Path $doctorPath)) {
            Write-Error "install.ps1: scripts/doctor.ps1 not found at $doctorPath"
            exit 1
        }
        Write-Host "Delegating to scripts/doctor.ps1 (read-only health check)..." -ForegroundColor DarkCyan
        Write-Host ""
        & $doctorPath
        exit $LASTEXITCODE
    }

    'seed' {
        # TODO Dataverse-Engineer (Phase 1):
        #   1. Load data/names/people.md + data/offsets.ts + data/seed.ts
        #   2. Generate synthetic rows via Faker (en_US locale)
        #   3. Insert net-new rows by default; --reseed wipes + reseeds
        #   4. Tag E2E fixture rows with cch_TestRun = true
        #   5. Anchor cch_DemoAnchor.LastRefreshedOn = utcnow()
        Invoke-NotImplemented `
            -What "seed: Faker-driven synthetic data generation" `
            -Topic "Topic 7 (Faker en_US), handoff §3.9 (anchor-and-offset), §3.10 (names file)"
    }

    'refresh-dates' {
        # TODO Flows-Engineer (Phase 4):
        #   This mode invokes the daily refresh flow on demand (no cron wait).
        #   Slides every time-sensitive field forward by elapsed delta from
        #   cch_DemoAnchor.LastRefreshedOn. Resets MDR-clock complaint to
        #   cch_TunableMdrClockHours (default 18h).
        Invoke-NotImplemented `
            -What "refresh-dates: invoke daily refresh flow on demand" `
            -Topic "handoff §3.9 (evergreen design), Topic 4 (cch_TunableMdrClockHours)"
    }
}
