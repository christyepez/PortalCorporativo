$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$path = Join-Path $root 'scripts/local/prod-local-operations-status.ps1'
$text = Get-Content -LiteralPath $path -Raw

$required = @(
    'origin/main',
    'gitDirty=',
    'MaxBackupAgeHours',
    'MaxEvidenceAgeHours',
    'Get-ScheduledTask',
    'WakeToRun',
    'RestartCount',
    'RestartInterval',
    'DisallowStartIfOnBatteries',
    'StopIfGoingOnBatteries',
    'taskWrapperMissing=',
    'taskDependencyMissing=',
    'PORTAL_PROD_LOCAL_SCHEDULED_RUN_START',
    'PORTAL_PROD_LOCAL_SCHEDULED_RUN_PASS',
    'PORTAL_PROD_LOCAL_SCHEDULED_RUN_FAIL',
    'PORTAL_PROD_LOCAL_SCHEDULED_DEPENDENCY_PASS',
    'PORTAL_PROD_LOCAL_MAINTENANCE_PASS',
    'prod-local-verify.ps1',
    'DeepRuntime',
    'PORTAL_PROD_LOCAL_OPERATIONS_STATUS_PASS'
)

foreach ($marker in $required) {
    if (-not $text.Contains($marker)) { throw "Operations status contract missing marker: $marker" }
    Write-Host "PASS operations status marker $marker"
}

if ($text -match '(?i)(password|secret|token)\s*=') {
    throw 'Operations status must not embed secret values.'
}

Write-Host 'PORTAL_PROD_LOCAL_OPERATIONS_STATUS_GATE_PASS'
