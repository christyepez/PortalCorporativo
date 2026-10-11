$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$maintenancePath = Join-Path $root 'scripts/local/prod-local-maintenance-schedule.ps1'
$backupPath = Join-Path $root 'scripts/local/prod-local-backup-schedule.ps1'
$scheduledRunPath = Join-Path $root 'scripts/local/prod-local-scheduled-run.ps1'

$maintenance = Get-Content -LiteralPath $maintenancePath -Raw
$backup = Get-Content -LiteralPath $backupPath -Raw
$scheduledRun = Get-Content -LiteralPath $scheduledRunPath -Raw

$contracts = @(
    [pscustomobject]@{
        Name = 'maintenance'
        Text = $maintenance
        Required = @(
            "ValidateSet('Show','Install','Remove')",
            'SupportsShouldProcess=$true',
            'prod-local-scheduled-run.ps1',
            '-Operation Maintenance',
            'BackupTaskName',
            '-DependencyTaskName',
            'New-ScheduledTaskTrigger -Daily',
            'Register-ScheduledTask'
        )
    },
    [pscustomobject]@{
        Name = 'backup'
        Text = $backup
        Required = @(
            "ValidateSet('Show','Install','Remove')",
            'SupportsShouldProcess=$true',
            'prod-local-scheduled-run.ps1',
            '-Operation Backup',
            'New-ScheduledTaskTrigger -Daily',
            'Register-ScheduledTask'
        )
    },
    [pscustomobject]@{
        Name = 'scheduled-run'
        Text = $scheduledRun
        Required = @(
            "ValidateSet('Backup','Maintenance')",
            'runtime/prod-local/operations',
            'LogRetention',
            'Write-Evidence',
            'Write-EvidenceObject',
            'PORTAL_PROD_LOCAL_SCHEDULED_RUN_START',
            'DependencyTaskName',
            'DependencyMaxAgeHours',
            'DependencyWaitSeconds',
            'PORTAL_PROD_LOCAL_SCHEDULED_DEPENDENCY_PASS',
            'prod-local-backup.ps1',
            'prod-local-maintenance.ps1',
            'ScanLogs',
            'PORTAL_PROD_LOCAL_SCHEDULED_RUN_PASS',
            'PORTAL_PROD_LOCAL_SCHEDULED_RUN_FAIL'
        )
    }
)

foreach ($contract in $contracts) {
    foreach ($marker in $contract.Required) {
        if (-not $contract.Text.Contains($marker)) {
            throw "$($contract.Name) schedule contract missing marker: $marker"
        }
        Write-Host "PASS $($contract.Name) marker $marker"
    }
}

foreach ($name in @('backup','maintenance')) {
    $text = if ($name -eq 'backup') { $backup } else { $maintenance }
    foreach ($marker in @('-AllowStartIfOnBatteries','-DontStopIfGoingOnBatteries','-WakeToRun')) {
        if (-not $text.Contains($marker)) { throw "$name schedule must include $marker" }
        Write-Host "PASS $name battery marker $marker"
    }
}

foreach ($candidate in @($maintenance,$backup,$scheduledRun)) {
    if ($candidate -match '(?i)(password|secret|token)\s*=') {
        throw 'Scheduled operational scripts must not embed secret values.'
    }
}

Write-Host 'PORTAL_PROD_LOCAL_MAINTENANCE_SCHEDULE_GATE_PASS'
