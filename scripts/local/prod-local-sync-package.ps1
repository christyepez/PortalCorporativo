param(
    [string]$Baseline = 'config/prod-local-baseline.json',
    [string]$Output = 'config/prod-local-sync-package.json'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$baselinePath = if ([IO.Path]::IsPathRooted($Baseline)) { $Baseline } else { Join-Path $root $Baseline }
if (-not (Test-Path -LiteralPath $baselinePath)) { throw "Baseline not found: $baselinePath" }
$baselineData = Get-Content -LiteralPath $baselinePath -Raw | ConvertFrom-Json
$baselineHash = (Get-FileHash -LiteralPath $baselinePath -Algorithm SHA256).Hash

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
