<#
.SYNOPSIS
    Thin wrapper for `install.ps1 -Mode upgrade`. Default mode in CI.

.DESCRIPTION
    Forwards all arguments to install.ps1 with -Mode upgrade prepended. See
    install.ps1 for full behavior + parameter docs.

.NOTES
    Owner role: Lead. Skeleton today; real impl per install.ps1 'upgrade' branch.
#>
#Requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments)]
    [string[]] $Args
)

$ErrorActionPreference = 'Stop'
$repoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if (-not $repoRoot) { Write-Error "upgrade.ps1: not inside a git repo."; exit 1 }
& (Join-Path $repoRoot 'scripts/install.ps1') -Mode upgrade @Args
exit $LASTEXITCODE
