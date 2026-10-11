$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$drillPath = Join-Path $root 'scripts/local/prod-local-recovery-drill.ps1'
$maintenancePath = Join-Path $root 'scripts/local/prod-local-maintenance.ps1'

$drill = Get-Content -LiteralPath $drillPath -Raw
$maintenance = Get-Content -LiteralPath $maintenancePath -Raw

$requiredDrillMarkers = @(
    'RESTORE VERIFYONLY',
    'DBCC CHECKDB',
    'PORTAL_PROD_LOCAL_RECOVERY_DRILL_PASS'
)
foreach ($marker in $requiredDrillMarkers) {
    if (-not $drill.Contains($marker)) { throw "Recovery drill contract missing marker: $marker" }
    Write-Host "PASS recovery drill marker $marker"
}

$forbidden = @(
    'RESTORE DATABASE',
    'WITH REPLACE',
    'SINGLE_USER'
)
foreach ($marker in $forbidden) {
    if ($drill.Contains($marker)) { throw "Recovery drill must remain non-destructive; forbidden marker found: $marker" }
}

if (-not $maintenance.Contains('[switch]$RecoveryDrill')) {
    throw 'Maintenance must expose RecoveryDrill as an explicit opt-in switch.'
}
if (-not $maintenance.Contains('prod-local-recovery-drill.ps1')) {
    throw 'Maintenance must invoke the recovery drill when requested.'
}

Write-Host 'PORTAL_PROD_LOCAL_RECOVERY_DRILL_GATE_PASS'
