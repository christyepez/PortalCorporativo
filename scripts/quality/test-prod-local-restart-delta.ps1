$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$snapshotPath = Join-Path $root 'scripts/local/prod-local-restart-snapshot.ps1'
$verifyPath = Join-Path $root 'scripts/local/prod-local-verify.ps1'
$maintenancePath = Join-Path $root 'scripts/local/prod-local-maintenance.ps1'
$operationsPath = Join-Path $root 'scripts/local/prod-local-operations-status.ps1'

$snapshot = Get-Content -LiteralPath $snapshotPath -Raw
$verify = Get-Content -LiteralPath $verifyPath -Raw
$maintenance = Get-Content -LiteralPath $maintenancePath -Raw
$operations = Get-Content -LiteralPath $operationsPath -Raw

$snapshotRequired = @(
    'RestartCount',
    'PORTAL_PROD_LOCAL_RESTART_SNAPSHOT_CREATED',
    'ConvertTo-Json'
)
$verifyRequired = @(
    'RestartBaselineFile',
    'restartBaseline=',
    'restartDelta=',
    '$restartCount -gt $baselineCount'
)
$consumerRequired = @(
    'prod-local-restart-snapshot.ps1',
    '-RestartBaselineFile',
    'Remove-Item -LiteralPath $restartBaselinePath'
)

foreach ($marker in $snapshotRequired) {
    if (-not $snapshot.Contains($marker)) { throw "Restart snapshot contract missing marker: $marker" }
    Write-Host "PASS restart snapshot marker $marker"
}
foreach ($marker in $verifyRequired) {
    if (-not $verify.Contains($marker)) { throw "Restart delta verify contract missing marker: $marker" }
    Write-Host "PASS restart delta verify marker $marker"
}
foreach ($name in @('maintenance','operations')) {
    $text = if ($name -eq 'maintenance') { $maintenance } else { $operations }
    foreach ($marker in $consumerRequired) {
        if (-not $text.Contains($marker)) { throw "$name restart delta contract missing marker: $marker" }
        Write-Host "PASS $name restart delta marker $marker"
    }
}

if ($maintenance.Contains('-IgnoreRestartCount')) { throw 'Maintenance must not ignore restart counters after restart-delta hardening.' }
if ($operations.Contains('-IgnoreRestartCount')) { throw 'Operations status must not ignore restart counters after restart-delta hardening.' }

Write-Host 'PORTAL_PROD_LOCAL_RESTART_DELTA_GATE_PASS'
