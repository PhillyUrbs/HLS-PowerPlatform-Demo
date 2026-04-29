<#
.SYNOPSIS
    Resolves secret references per the Topic 4 SecretRef abstraction.

.DESCRIPTION
    Every secret stored in a Dataverse Environment Variable (or a deployment-settings
    .json file) uses one of two reference formats:

      plain:<value>                                Development mode (default today).
      kv:<keyVaultName>/<secretName>[?version=<v>] Future Key Vault mode.

    This module exports `Resolve-Secret` which takes a reference string and returns
    the plain-text secret value. Every PowerShell script and Power Automate child flow
    (cch_ResolveSecret) routes through this single source of truth so flipping plain →
    kv later requires zero changes to call sites.

    Per Topic 4: doctor warns on plain: mode in info-level findings; never blocks.

.EXAMPLE
    Import-Module ./scripts/lib/Secrets.ps1
    $token = Resolve-Secret -Reference $envvar.cch_SecretDirectLinePatientSupport

.EXAMPLE
    # KV mode (when operator is ready to migrate)
    Resolve-Secret -Reference 'kv:cch-demo-kv/DirectLinePatientSupport'

.NOTES
    Owner role: Lead (per scripts/AGENTS.md).
    Locked references: Topic 4 §SecretRef abstraction; Topic 11 §C4 doctor warning.
    Required PowerShell: 7+. KV mode requires Az.KeyVault module installed and
    operator authenticated (`Connect-AzAccount`); plain mode has no dependencies.
#>

#Requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-Secret {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The secret reference string (plain:<value> or kv:<vault>/<name>[?version=<v>]).
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string] $Reference,

        # Suppress the "consider migrating to Key Vault" warning emitted on plain: refs.
        [switch] $NoPlainWarning
    )

    if ($Reference -match '^plain:(?<value>.*)$') {
        if (-not $NoPlainWarning) {
            Write-Warning "Resolve-Secret: plain-mode secret reference detected. Consider migrating to Key Vault (kv:<vault>/<name>) for production use."
        }
        return $Matches.value
    }

    if ($Reference -match '^kv:(?<vault>[^/]+)/(?<name>[^?]+)(\?version=(?<version>.+))?$') {
        $vault   = $Matches.vault
        $name    = $Matches.name
        $version = $Matches.version

        if (-not (Get-Module -ListAvailable -Name 'Az.KeyVault')) {
            throw "Resolve-Secret: kv-mode reference '$Reference' requires the Az.KeyVault module. Install with: Install-Module Az.KeyVault -Scope CurrentUser"
        }

        Import-Module Az.KeyVault -ErrorAction Stop

        $params = @{
            VaultName = $vault
            Name      = $name
            AsPlainText = $true
        }
        if ($version) { $params['Version'] = $version }

        try {
            $secret = Get-AzKeyVaultSecret @params
        } catch {
            throw "Resolve-Secret: failed to read secret '$name' from Key Vault '$vault': $($_.Exception.Message)"
        }
        return $secret
    }

    throw "Resolve-Secret: invalid reference format. Expected 'plain:<value>' or 'kv:<vault>/<name>[?version=<v>]'. Got: '$Reference'"
}

function Test-SecretReference {
    <#
    .SYNOPSIS
        Validates a secret reference's format without resolving it (used by doctor).
    .OUTPUTS
        [pscustomobject] @{ Mode = 'plain' | 'kv' | 'invalid'; Vault = ...; Name = ...; Version = ...; }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string] $Reference
    )

    if ([string]::IsNullOrWhiteSpace($Reference)) {
        return [pscustomobject]@{ Mode = 'invalid'; Reason = 'empty or whitespace' }
    }

    if ($Reference -match '^plain:(?<value>.*)$') {
        $value = $Matches.value
        if ($value -match '^<set-me') {
            return [pscustomobject]@{ Mode = 'invalid'; Reason = 'placeholder template value not replaced' }
        }
        return [pscustomobject]@{ Mode = 'plain'; Length = $value.Length }
    }

    if ($Reference -match '^kv:(?<vault>[^/]+)/(?<name>[^?]+)(\?version=(?<version>.+))?$') {
        return [pscustomobject]@{
            Mode    = 'kv'
            Vault   = $Matches.vault
            Name    = $Matches.name
            Version = $Matches.version
        }
    }

    return [pscustomobject]@{ Mode = 'invalid'; Reason = 'does not match plain:* or kv:* format' }
}

# Functions are auto-discoverable by dot-sourcing (`. ./scripts/lib/Secrets.ps1`).
# When dot-sourced, both Resolve-Secret and Test-SecretReference become available
# in the caller's scope. No Export-ModuleMember needed (this is a .ps1, not .psm1).
