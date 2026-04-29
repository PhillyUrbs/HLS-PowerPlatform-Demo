<#
.SYNOPSIS
    Entra ID app registration helpers — used by install.ps1 to provision the Power Pages
    identity provider app reg (cch_IdEntraAppPagesAuth).

.DESCRIPTION
    Per Topic 11 section A3 sequencing:
      - Setup-ServicePrincipal.ps1 handles cch_IdEntraAppServicePrincipal (uses pac admin
        create-service-principal which also creates the Dataverse Application User).
      - This lib handles cch_IdEntraAppPagesAuth (a separate Entra app reg used as Power
        Pages identity provider; web-app type with redirect URI to the Pages site).

    The Pages app reg has different shape than the SP app reg:
      - Web platform with redirect URI = <Pages site URL>/signin-oidc
      - ID tokens enabled
      - No Dataverse Application User (Pages users authenticate AS themselves, not as the app)
      - Confidential client; client secret needed for token exchange

    Uses 'az ad app' (Azure CLI) since pac doesn't expose Entra app reg primitives
    beyond the SP+ApplicationUser pair.

    Functions exported (via dot-sourcing):
      - New-PagesAuthApp       Provision the Pages auth app reg (idempotent)
      - Get-PagesAuthApp       Look up an existing Pages auth app reg by display name
      - Test-AzCliAvailable    Pre-flight check

.NOTES
    Owner role: Lead (per scripts/AGENTS.md).
    Topic refs: Topic 11 section A3 (Lead PR #2 sequencing), Topic 4 (cch_IdEntraAppPagesAuth).
    Required PowerShell: 7+. Required CLI: az 2.0+ with operator authenticated
    (az login + tenant scope).
#>

#Requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-AzCliAvailable {
    <#
    .SYNOPSIS
        Returns $true if 'az' is on PATH and the operator has run 'az login'.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        return $false
    }
    try {
        $null = az account show --query id -o tsv 2>$null
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function Get-PagesAuthApp {
    <#
    .SYNOPSIS
        Look up an existing Pages auth Entra app reg by display name.
        Returns $null if not found, or a pscustomobject with appId + displayName + tenantId.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory)] [string] $DisplayName
    )

    if (-not (Test-AzCliAvailable)) {
        throw "Get-PagesAuthApp: az CLI not available or not authenticated. Run 'az login' first."
    }

    $jsonRaw = az ad app list --display-name $DisplayName --query "[0].{appId:appId, displayName:displayName}" -o json 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $jsonRaw -or $jsonRaw -eq 'null') {
        return $null
    }

    try {
        $app = $jsonRaw | ConvertFrom-Json
    } catch {
        return $null
    }

    # Look up tenant id separately
    $tenantId = az account show --query tenantId -o tsv 2>$null

    return [pscustomobject]@{
        appId       = $app.appId
        displayName = $app.displayName
        tenantId    = $tenantId
    }
}

function New-PagesAuthApp {
    <#
    .SYNOPSIS
        Provision the Power Pages identity-provider Entra app reg. Idempotent.

    .DESCRIPTION
        If an app with the same DisplayName already exists, returns its details
        unchanged (no secret rotation, no redirect-URI overwrite).

        On fresh provision, creates:
          - Web platform with redirect URI: <PagesSiteUrl>/signin-oidc
          - ID tokens enabled (oauth2AllowIdTokenImplicitFlow)
          - One client secret (1-year expiry)

        Returns:
          [pscustomobject] @{ appId; displayName; tenantId; clientSecret (only on fresh
          provision); created (bool) }

    .PARAMETER DisplayName
        Entra app reg display name. Convention: '<env-slug>-pages-auth'.

    .PARAMETER PagesSiteUrl
        The deployed Power Pages site URL. The redirect URI is appended as /signin-oidc.
        Per Topic 4 cch_UrlPagesSite spec: must start with https; cannot contain localhost.
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory)] [string] $DisplayName,
        [Parameter(Mandatory)] [string] $PagesSiteUrl
    )

    if (-not (Test-AzCliAvailable)) {
        throw "New-PagesAuthApp: az CLI not available or not authenticated. Run 'az login' first."
    }

    if ($PagesSiteUrl -notmatch '^https://') {
        throw "New-PagesAuthApp: PagesSiteUrl must start with https:// (got '$PagesSiteUrl'). Per Topic 4 runtime independence."
    }
    if ($PagesSiteUrl -match 'localhost|127\.0\.0\.1') {
        throw "New-PagesAuthApp: PagesSiteUrl cannot contain localhost or 127.0.0.1 (got '$PagesSiteUrl'). Per locked runtime independence."
    }

    # Idempotency: if app exists, return as-is
    $existing = Get-PagesAuthApp -DisplayName $DisplayName
    if ($existing) {
        return [pscustomobject]@{
            appId        = $existing.appId
            displayName  = $existing.displayName
            tenantId     = $existing.tenantId
            clientSecret = $null  # we don't rotate on idempotent return
            created      = $false
        }
    }

    # Compose redirect URI
    $redirectUri = $PagesSiteUrl.TrimEnd('/') + '/signin-oidc'

    # Create the app reg
    $createOutput = az ad app create `
        --display-name $DisplayName `
        --sign-in-audience AzureADMyOrg `
        --web-redirect-uris $redirectUri `
        --enable-id-token-issuance true `
        -o json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "New-PagesAuthApp: az ad app create failed: $createOutput"
    }

    $newApp = $createOutput | ConvertFrom-Json

    # Generate a client secret (1-year expiry)
    $secretOutput = az ad app credential reset `
        --id $newApp.appId `
        --display-name "$DisplayName-secret" `
        --years 1 `
        -o json 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "New-PagesAuthApp: az ad app credential reset failed: $secretOutput"
    }

    $cred = $secretOutput | ConvertFrom-Json
    $tenantId = az account show --query tenantId -o tsv

    return [pscustomobject]@{
        appId        = $newApp.appId
        displayName  = $newApp.displayName
        tenantId     = $tenantId
        clientSecret = $cred.password
        created      = $true
    }
}
