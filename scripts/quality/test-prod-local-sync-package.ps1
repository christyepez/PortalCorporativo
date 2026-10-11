$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

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

$packagePath = Join-Path $root 'config/prod-local-sync-package.json'
$preflightPath = Join-Path $root 'scripts/local/prod-local-sync-preflight.ps1'
$applyPath = Join-Path $root 'scripts/local/prod-local-sync-apply.ps1'

if (-not (Test-Path -LiteralPath $packagePath)) { throw 'Sync package is missing.' }
$package = Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json
if ([int]$package.SchemaVersion -ne 1) { throw "Unsupported sync package schema: $($package.SchemaVersion)" }
if ([string]$package.BaselineHashMode -ne 'normalized-utf8-lf-sha256') { throw "Unsupported sync package baseline hash mode: $($package.BaselineHashMode)" }

$baselinePath = Join-Path $root ([string]$package.BaselineFile)
if (-not (Test-Path -LiteralPath $baselinePath)) { throw "Sync baseline is missing: $($package.BaselineFile)" }
$baselineHash = Get-NormalizedTextSha256 -Path $baselinePath
if ($baselineHash -ne [string]$package.BaselineSha256) {
    throw 'Committed sync package is stale: BaselineSha256 does not match the committed normalized baseline.'
}
Write-Host "PASS sync package baseline hash mode=$($package.BaselineHashMode)"

$preflight = Get-Content -LiteralPath $preflightPath -Raw
foreach ($marker in @("ValidateSet('Prerequisite','Aligned')",'repoDirty=','ALIGN_REQUIRED','PORTAL_PROD_LOCAL_SYNC_PREREQUISITE_PASS','PORTAL_PROD_LOCAL_SYNC_ALIGNED_PASS','baselineHashMismatch=true','composeServicesMismatch=true','RequiredLocalFiles','PORTAL_PROD_LOCAL_SYNC_PREFLIGHT_PASS')) {
    if (-not $preflight.Contains($marker)) { throw "Sync preflight contract missing marker: $marker" }
    Write-Host "PASS sync preflight marker $marker"
}

$apply = Get-Content -LiteralPath $applyPath -Raw
foreach ($marker in @('[switch]$Apply','status --porcelain','--ff-only','prod-local-sync-preflight.ps1','-Mode Prerequisite','-Mode Aligned','PORTAL_PROD_LOCAL_SYNC_APPLY_WHATIF_PASS','PORTAL_PROD_LOCAL_SYNC_APPLY_PASS')) {
    if (-not $apply.Contains($marker)) { throw "Sync apply safety contract missing marker: $marker" }
    Write-Host "PASS sync apply marker $marker"
}
if ($apply -match '(?i)reset\s+--hard|push\s+--force') { throw 'Sync apply must not use destructive Git operations.' }

Write-Host 'PORTAL_PROD_LOCAL_SYNC_PACKAGE_GATE_PASS'
