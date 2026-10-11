$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$packagePath = Join-Path $root 'config/prod-local-sync-package.json'
$preflightPath = Join-Path $root 'scripts/local/prod-local-sync-preflight.ps1'
$applyPath = Join-Path $root 'scripts/local/prod-local-sync-apply.ps1'

if (-not (Test-Path -LiteralPath $packagePath)) { throw 'Sync package is missing.' }
$package = Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json
if ([int]$package.SchemaVersion -ne 1) { throw "Unsupported sync package schema: $($package.SchemaVersion)" }

$baselinePath = Join-Path $root ([string]$package.BaselineFile)
if (-not (Test-Path -LiteralPath $baselinePath)) { throw "Sync baseline is missing: $($package.BaselineFile)" }
$baselineHash = (Get-FileHash -LiteralPath $baselinePath -Algorithm SHA256).Hash
if ($baselineHash -ne [string]$package.BaselineSha256) {
    throw 'Committed sync package is stale: BaselineSha256 does not match the committed baseline.'
}
Write-Host 'PASS sync package baseline hash'

$preflight = Get-Content -LiteralPath $preflightPath -Raw
foreach ($marker in @('baselineHashMismatch=true','composeServicesMismatch=true','RequiredLocalFiles','PORTAL_PROD_LOCAL_SYNC_PREFLIGHT_PASS')) {
    if (-not $preflight.Contains($marker)) { throw "Sync preflight contract missing marker: $marker" }
    Write-Host "PASS sync preflight marker $marker"
}

$apply = Get-Content -LiteralPath $applyPath -Raw
foreach ($marker in @('[switch]$Apply','status --porcelain','--ff-only','PORTAL_PROD_LOCAL_SYNC_APPLY_PASS')) {
    if (-not $apply.Contains($marker)) { throw "Sync apply safety contract missing marker: $marker" }
    Write-Host "PASS sync apply marker $marker"
}
if ($apply -match '(?i)reset\s+--hard|push\s+--force') { throw 'Sync apply must not use destructive Git operations.' }

Write-Host 'PORTAL_PROD_LOCAL_SYNC_PACKAGE_GATE_PASS'
