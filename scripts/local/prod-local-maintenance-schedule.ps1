[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [ValidateSet('Show','Install','Remove')][string]$Action = 'Show',
    [string]$TaskName = 'PortalCorporativo PROD-local Maintenance',
    [string]$DailyAt = '02:30',
    [string]$BackupRoot = 'backups/prod-local',
    [switch]$RecoveryDrill
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

if ($Action -eq 'Show') {
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($task) {
        $info = Get-ScheduledTaskInfo -TaskName $TaskName
        Write-Output ("TASK {0} state={1} nextRun={2} lastRun={3} lastResult={4}" -f $TaskName,$task.State,$info.NextRunTime,$info.LastRunTime,$info.LastTaskResult)
    } else {
        Write-Output "TASK_NOT_REGISTERED $TaskName"
    }
    exit 0
}

if ($Action -eq 'Remove') {
    if ($PSCmdlet.ShouldProcess($TaskName, 'Unregister scheduled maintenance task')) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
        Write-Output "TASK_REMOVED $TaskName"
    }
    exit 0
}

if ($DailyAt -notmatch '^(?:[01]\d|2[0-3]):[0-5]\d$') { throw 'DailyAt must use HH:mm.' }

$maintenanceScript = Join-Path $PSScriptRoot 'prod-local-maintenance.ps1'
$powershell = Join-Path $PSHOME 'powershell.exe'
$arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$maintenanceScript`" -BackupRoot `"$BackupRoot`" -ScanLogs"
if ($RecoveryDrill) { $arguments += ' -RecoveryDrill' }

$at = [DateTime]::Today.Add([TimeSpan]::Parse($DailyAt))
$taskAction = New-ScheduledTaskAction -Execute $powershell -Argument $arguments -WorkingDirectory $root
$trigger = New-ScheduledTaskTrigger -Daily -At $at
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Hours 2)

if ($PSCmdlet.ShouldProcess($TaskName, "Register daily maintenance at $DailyAt")) {
    Register-ScheduledTask -TaskName $TaskName -Action $taskAction -Trigger $trigger -Settings $settings -Description 'PortalCorporativo Docker Desktop PROD-local operational maintenance check' -Force | Out-Null
    Write-Output "TASK_INSTALLED $TaskName $DailyAt"
}
