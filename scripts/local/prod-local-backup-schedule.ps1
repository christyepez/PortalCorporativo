[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [ValidateSet('Show','Install','Remove')][string]$Action = 'Show',
    [string]$TaskName = 'PortalCorporativo PROD-local Backup',
    [string]$DailyAt = '02:00',
    [string]$EnvFile = '.env.portal.local',
    [int]$RetentionSets = 7
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$envPath = if ([IO.Path]::IsPathRooted($EnvFile)) { $EnvFile } else { Join-Path $root $EnvFile }

if ($Action -eq 'Show') {
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($task) {
        $info = Get-ScheduledTaskInfo -TaskName $TaskName
        Write-Output ("TASK {0} state={1} nextRun={2}" -f $TaskName,$task.State,$info.NextRunTime)
    } else {
        Write-Output "TASK_NOT_REGISTERED $TaskName"
    }
    exit 0
}
if ($Action -eq 'Remove') {
    if ($PSCmdlet.ShouldProcess($TaskName, 'Unregister scheduled backup task')) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
        Write-Output "TASK_REMOVED $TaskName"
    }
    exit 0
}

if (-not (Test-Path -LiteralPath $envPath)) { throw "Environment file not found: $envPath" }
if ($DailyAt -notmatch '^(?:[01]\d|2[0-3]):[0-5]\d$') { throw 'DailyAt must use HH:mm.' }

$backupScript = Join-Path $PSScriptRoot 'prod-local-backup.ps1'
$powershell = Join-Path $PSHOME 'powershell.exe'
$arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$backupScript`" -EnvFile `"$envPath`" -RetentionSets $RetentionSets"
$at = [DateTime]::Today.Add([TimeSpan]::Parse($DailyAt))
$taskAction = New-ScheduledTaskAction -Execute $powershell -Argument $arguments -WorkingDirectory $root
$trigger = New-ScheduledTaskTrigger -Daily -At $at
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 2)

if ($PSCmdlet.ShouldProcess($TaskName, "Register daily backup at $DailyAt")) {
    Register-ScheduledTask -TaskName $TaskName -Action $taskAction -Trigger $trigger -Settings $settings -Description 'PortalCorporativo Docker Desktop PROD-local SQL backup' -Force | Out-Null
    Write-Output "TASK_INSTALLED $TaskName $DailyAt"
}
