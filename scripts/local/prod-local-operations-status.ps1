[CmdletBinding()]
param(
    [string]$BackupTaskName = 'PortalCorporativo PROD-local Backup',
    [string]$MaintenanceTaskName = 'PortalCorporativo PROD-local Maintenance',
    [string]$BackupRoot = 'backups/prod-local',
    [string]$LogRoot = 'runtime/prod-local/operations',
    [double]$MaxBackupAgeHours = 24,
    [double]$MaxEvidenceAgeHours = 24,
    [switch]$DeepRuntime
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$backupPath = if ([IO.Path]::IsPathRooted($BackupRoot)) { $BackupRoot } else { Join-Path $root $BackupRoot }
$logPath = if ([IO.Path]::IsPathRooted($LogRoot)) { $LogRoot } else { Join-Path $root $LogRoot }
$failures = @()

$branch = (& git -C $root branch --show-current).Trim()
$head = (& git -C $root rev-parse HEAD).Trim()
$originMain = (& git -C $root rev-parse origin/main 2>$null).Trim()
$dirty = @(& git -C $root status --porcelain)
Write-Output "CHECK git branch=$branch head=$head originMain=$originMain dirty=$($dirty.Count)"
if ($branch -ne 'main') { $failures += "gitBranch=$branch" }
if ([string]::IsNullOrWhiteSpace($originMain) -or $head -ne $originMain) { $failures += 'gitOriginMainMismatch=true' }
if ($dirty.Count -gt 0) { $failures += "gitDirty=$($dirty.Count)" }

if (-not (Test-Path -LiteralPath $backupPath)) {
    $failures += "backupRootMissing=$backupPath"
} else {
    $latestSet = Get-ChildItem -LiteralPath $backupPath -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if (-not $latestSet) {
        $failures += 'backupSets=0'
    } else {
        $manifest = Join-Path $latestSet.FullName 'manifest.json'
        if (-not (Test-Path -LiteralPath $manifest)) {
            $failures += "manifestMissing=$($latestSet.Name)"
        } else {
            $backupAgeHours = ((Get-Date).ToUniversalTime() - (Get-Item $manifest).LastWriteTimeUtc).TotalHours
            Write-Output ("CHECK backupSet={0} ageHours={1:N2}" -f $latestSet.Name,$backupAgeHours)
            if ($backupAgeHours -gt $MaxBackupAgeHours) { $failures += "backupAgeHours=$([math]::Round($backupAgeHours,2))>$MaxBackupAgeHours" }
        }
    }
}

function Test-Task {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][ValidateSet('Backup','Maintenance')][string]$Kind
    )
    $task = Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue
    if (-not $task) {
        $script:failures += "taskMissing=$Name"
        return
    }
    $info = Get-ScheduledTaskInfo -TaskName $Name
    $settings = $task.Settings
    Write-Output ("CHECK task={0} state={1} wake={2} restartCount={3} restartInterval={4} nextRun={5:o} lastRun={6:o} lastResult={7}" -f $Name,$task.State,$settings.WakeToRun,$settings.RestartCount,$settings.RestartInterval,$info.NextRunTime,$info.LastRunTime,$info.LastTaskResult)
    if ($task.State -eq 'Disabled') { $script:failures += "taskDisabled=$Name" }
    if (-not $settings.WakeToRun) { $script:failures += "taskWakeToRun=$Name" }
    if ($settings.DisallowStartIfOnBatteries) { $script:failures += "taskBatteryStartBlocked=$Name" }
    if ($settings.StopIfGoingOnBatteries) { $script:failures += "taskBatteryStopEnabled=$Name" }
    if ([int]$settings.RestartCount -lt 3) { $script:failures += "taskRestartCount=${Name}:$($settings.RestartCount)" }
    $restartInterval = [System.Xml.XmlConvert]::ToTimeSpan([string]$settings.RestartInterval)
    if ($restartInterval -gt (New-TimeSpan -Minutes 10)) { $script:failures += "taskRestartInterval=${Name}:$($settings.RestartInterval)" }

    $arguments = @($task.Actions | ForEach-Object { [string]$_.Arguments }) -join ' '
    if ($arguments -notmatch 'prod-local-scheduled-run\.ps1') { $script:failures += "taskWrapperMissing=$Name" }
    if ($Kind -eq 'Maintenance') {
        if ($arguments -notmatch [regex]::Escape('-DependencyTaskName "' + $BackupTaskName + '"')) { $script:failures += "taskDependencyMissing=$Name" }
    }
}

Test-Task -Name $BackupTaskName -Kind Backup
Test-Task -Name $MaintenanceTaskName -Kind Maintenance

function Test-Evidence {
    param([Parameter(Mandatory=$true)][ValidateSet('backup','maintenance')][string]$Kind)
    if (-not (Test-Path -LiteralPath $logPath)) {
        $script:failures += "logRootMissing=$logPath"
        return
    }
    $latest = Get-ChildItem -LiteralPath $logPath -File -Filter "$Kind-*.log" | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
    if (-not $latest) {
        $script:failures += "evidenceMissing=$Kind"
        return
    }
    $ageHours = ((Get-Date).ToUniversalTime() - $latest.LastWriteTimeUtc).TotalHours
    $text = Get-Content -LiteralPath $latest.FullName -Raw
    Write-Output ("CHECK evidence={0} file={1} ageHours={2:N2}" -f $Kind,$latest.Name,$ageHours)
    if ($ageHours -gt $MaxEvidenceAgeHours) { $script:failures += "evidenceAgeHours=${Kind}:$([math]::Round($ageHours,2))>$MaxEvidenceAgeHours" }
    if ($text -notmatch 'PORTAL_PROD_LOCAL_SCHEDULED_RUN_START') { $script:failures += "evidenceStartMissing=$Kind" }
    if ($text -notmatch 'PORTAL_PROD_LOCAL_SCHEDULED_RUN_PASS') { $script:failures += "evidencePassMissing=$Kind" }
    if ($text -match 'PORTAL_PROD_LOCAL_SCHEDULED_RUN_FAIL') { $script:failures += "evidenceContainsFail=$Kind" }
    if ($Kind -eq 'maintenance') {
        if ($text -notmatch 'PORTAL_PROD_LOCAL_SCHEDULED_DEPENDENCY_PASS') { $script:failures += 'maintenanceDependencyEvidenceMissing=true' }
        if ($text -notmatch 'PORTAL_PROD_LOCAL_MAINTENANCE_PASS') { $script:failures += 'maintenancePassEvidenceMissing=true' }
    }
}

Test-Evidence -Kind backup
Test-Evidence -Kind maintenance

if ($DeepRuntime) {
    $restartBaselinePath = Join-Path ([IO.Path]::GetTempPath()) ("portal-restarts-operations-{0}.json" -f [guid]::NewGuid())
    try {
        & (Join-Path $PSScriptRoot 'prod-local-restart-snapshot.ps1') -Output $restartBaselinePath
        & (Join-Path $PSScriptRoot 'prod-local-verify.ps1') -RestartBaselineFile $restartBaselinePath -ScanLogs
        if ($LASTEXITCODE -ne 0) { $failures += 'deepRuntimeVerify=failed' }
    } catch {
        $failures += 'deepRuntimeVerify=failed'
        Write-Output $_.Exception.Message
    } finally {
        Remove-Item -LiteralPath $restartBaselinePath -Force -ErrorAction SilentlyContinue
    }
}

if ($failures.Count -gt 0) {
    @($failures | Select-Object -Unique) | ForEach-Object { Write-Output "FAIL $_" }
    throw "PROD-local operations status failed with $(@($failures | Select-Object -Unique).Count) issue(s)."
}

Write-Output 'PORTAL_PROD_LOCAL_OPERATIONS_STATUS_PASS'
