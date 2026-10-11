$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$schedulePath = Join-Path $root 'scripts/local/prod-local-maintenance-schedule.ps1'
$schedule = Get-Content -LiteralPath $schedulePath -Raw

$required = @(
    "ValidateSet('Show','Install','Remove')",
    'SupportsShouldProcess=$true',
    'prod-local-maintenance.ps1',
    '-ScanLogs',
    'New-ScheduledTaskTrigger -Daily',
    'Register-ScheduledTask'
)

foreach ($marker in $required) {
    if (-not $schedule.Contains($marker)) { throw "Maintenance schedule contract missing marker: $marker" }
    Write-Host "PASS maintenance schedule marker $marker"
}

if ($schedule -match '(?i)(password|secret|token)\s*=') {
    throw 'Maintenance schedule must not embed secret values.'
}

Write-Host 'PORTAL_PROD_LOCAL_MAINTENANCE_SCHEDULE_GATE_PASS'
