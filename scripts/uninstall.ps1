<#
.SYNOPSIS
    Thin wrapper for `install.ps1 -Mode uninstall`.

.DESCRIPTION
    Forwards all arguments to install.ps1 with -Mode uninstall prepended. See
    install.ps1 for full behavior + parameter docs. Default uninstall scope:
    solution + Entra app regs + SharePoint site + Teams team. Does NOT default to
    demo super user delete or DLP/ME removal.

.NOTES
    Owner role: Lead. Skeleton today; real impl per install.ps1 'uninstall' branch.
    Confirms before each destructive operation per scripts/AGENTS.md house rule.
#>
#Requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments)]
    [string[]] $Args
)

$ErrorActionPreference = 'Stop'
$repoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if (-not $repoRoot) { Write-Error "uninstall.ps1: not inside a git repo."; exit 1 }
& (Join-Path $repoRoot 'scripts/install.ps1') -Mode uninstall @Args
exit $LASTEXITCODE
