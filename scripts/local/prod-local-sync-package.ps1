param(
    [string]$Baseline = 'config/prod-local-baseline.json',
    [string]$Output = 'config/prod-local-sync-package.json'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

function Get-NormalizedTextSha256 {
    param([Parameter(Mandatory=$true)][string]$Path)
    $text = Get-Content -LiteralPath $Path -Raw
    $normalized = $text.Replace([string][char]0xFEFF,'').Replace("`r`n","`n").Replace("`r","`n")
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = $utf8.GetBytes($normalized)
        return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-','')
    } finally {
        $sha.Dispose()
    }
}

$baselinePath = if ([IO.Path]::IsPathRooted($Baseline)) { $Baseline } else { Join-Path $root $Baseline }
if (-not (Test-Path -LiteralPath $baselinePath)) { throw "Baseline not found: $baselinePath" }
$baselineData = Get-Content -LiteralPath $baselinePath -Raw | ConvertFrom-Json
$baselineHash = Get-NormalizedTextSha256 -Path $baselinePath

$repos = @($baselineData.Repositories | Where-Object { [string]$_.RevisionPolicy -eq 'exact' } | ForEach-Object {
    [pscustomobject]@{
        Name = [string]$_.Name
        RelativePath = [string]$_.RelativePath
        Branch = [string]$_.Branch
        Revision = [string]$_.Revision
    }
})

$package = [ordered]@{
    SchemaVersion = 1
    SourceRuntime = 'trabajo'
    PortalBranch = 'main'
    BaselineFile = 'config/prod-local-baseline.json'
    BaselineHashMode = 'normalized-utf8-lf-sha256'
    BaselineSha256 = $baselineHash
    RequiredLocalFiles = @('.env.portal.local')
    RequiredEnvironmentNames = @($baselineData.RequiredEnvironmentNames)
    Repositories = $repos
    ExpectedServices = @($baselineData.ExpectedServices)
}
$outputPath = if ([IO.Path]::IsPathRooted($Output)) { $Output } else { Join-Path $root $Output }
$parent = Split-Path -Parent $outputPath
New-Item -ItemType Directory -Path $parent -Force | Out-Null
$package | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $outputPath -Encoding UTF8
Write-Output "PORTAL_PROD_LOCAL_SYNC_PACKAGE_CREATED $outputPath"
