$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$maintenancePath = Join-Path $root 'scripts/local/prod-local-maintenance-schedule.ps1'
$backupPath = Join-Path $root 'scripts/local/prod-local-backup-schedule.ps1'
$maintenance = Get-Content -LiteralPath $maintenancePath -Raw
$backup = Get-Content -LiteralPath $backupPath -Raw

$maintenanceRequired = @(
    "ValidateSet('Show','Install','Remove')",
    'SupportsShouldProcess=$true',
    'prod-local-maintenance.ps1',
    '-ScanLogs',
    'New-ScheduledTaskTrigger -Daily',
    'Register-ScheduledTask'
)

foreach ($marker in $maintenanceRequired) {
    if (-not $maintenance.Contains($marker)) { throw "Maintenance schedule contract missing marker: $marker" }
    Write-Host "PASS maintenance schedule marker $marker"
}

foreach ($name in @('backup','maintenance')) {
    $text = if ($name -eq 'backup') { $backup } else { $maintenance }
    foreach ($marker in @('-AllowStartIfOnBatteries','-DontStopIfGoingOnBatteries')) {
        if (-not $text.Contains($marker)) { throw "$name schedule must include $marker" }
        Write-Host "PASS $name battery marker $marker"
    }
}

if ($maintenance -match '(?i)(password|secret|token)\s*=') {
    throw 'Maintenance schedule must not embed secret values.'
}
if ($backup -match '(?i)(password|secret|token)\s*=') {
    throw 'Backup schedule must not embed secret values.'
}

Write-Host 'PORTAL_PROD_LOCAL_MAINTENANCE_SCHEDULE_GATE_PASS'
