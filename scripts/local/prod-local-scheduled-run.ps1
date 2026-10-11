[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Backup','Maintenance')]
    [string]$Operation,
    [string]$LogRoot = 'runtime/prod-local/operations',
    [int]$LogRetention = 14,
    [string]$EnvFile = '.env.portal.local',
    [int]$RetentionSets = 7,
    [string]$BackupRoot = 'backups/prod-local',
    [string]$DependencyTaskName = '',
    [double]$DependencyMaxAgeHours = 4,
    [int]$DependencyWaitSeconds = 1800,
    [int]$DependencyPollSeconds = 5,
    [switch]$RecoveryDrill
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$logBase = if ([IO.Path]::IsPathRooted($LogRoot)) { $LogRoot } else { Join-Path $root $LogRoot }
New-Item -ItemType Directory -Path $logBase -Force | Out-Null

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$prefix = $Operation.ToLowerInvariant()
$logPath = Join-Path $logBase "$prefix-$stamp.log"
$exitCode = 0

function Write-Evidence {
    param([Parameter(Mandatory=$true)][string]$Message)
    Add-Content -LiteralPath $logPath -Value $Message -Encoding UTF8
    Write-Output $Message
}

function Write-EvidenceObject {
    param(
        [Parameter(ValueFromPipeline=$true)]
        $InputObject
    )
    process {
        $text = ($InputObject | Out-String).TrimEnd()
        if (-not [string]::IsNullOrEmpty($text)) {
            Add-Content -LiteralPath $logPath -Value $text -Encoding UTF8
        }
        Write-Output $InputObject
    }
}

Write-Evidence "PORTAL_PROD_LOCAL_SCHEDULED_RUN_START operation=$Operation timestamp=$((Get-Date).ToString('o'))"

try {
    if (-not [string]::IsNullOrWhiteSpace($DependencyTaskName)) {
        if ($DependencyWaitSeconds -le 0) { throw 'DependencyWaitSeconds must be greater than zero.' }
        if ($DependencyPollSeconds -le 0) { throw 'DependencyPollSeconds must be greater than zero.' }
        if ($DependencyMaxAgeHours -le 0) { throw 'DependencyMaxAgeHours must be greater than zero.' }

        $deadline = (Get-Date).AddSeconds($DependencyWaitSeconds)
        while ($true) {
            $dependency = Get-ScheduledTask -TaskName $DependencyTaskName -ErrorAction SilentlyContinue
            if (-not $dependency) { throw "Dependency task not found: $DependencyTaskName" }
            if ($dependency.State -eq 'Disabled') { throw "Dependency task is disabled: $DependencyTaskName" }

            $dependencyInfo = Get-ScheduledTaskInfo -TaskName $DependencyTaskName
            $lastRun = $dependencyInfo.LastRunTime
            $ageHours = if ($lastRun -gt [datetime]'2000-01-01') { ((Get-Date) - $lastRun).TotalHours } else { [double]::PositiveInfinity }
            Write-Evidence ("CHECK dependencyTask={0} state={1} lastRun={2:o} result={3} ageHours={4:N2}" -f $DependencyTaskName,$dependency.State,$lastRun,$dependencyInfo.LastTaskResult,$ageHours)

            $dependencyIdle = $dependency.State -notin @('Running','Queued')
            $dependencyRecent = $ageHours -le $DependencyMaxAgeHours
            if ($dependencyIdle -and $dependencyRecent) {
                if ($dependencyInfo.LastTaskResult -ne 0) { throw "Dependency task failed: $DependencyTaskName result=$($dependencyInfo.LastTaskResult)" }
                Write-Evidence "PORTAL_PROD_LOCAL_SCHEDULED_DEPENDENCY_PASS task=$DependencyTaskName"
                break
            }

            if ((Get-Date) -ge $deadline) { throw "Dependency task did not become ready with a recent successful run: $DependencyTaskName" }
            Start-Sleep -Seconds $DependencyPollSeconds
        }
    }

    if ($Operation -eq 'Backup') {
        $script = Join-Path $PSScriptRoot 'prod-local-backup.ps1'
        & $script -EnvFile $EnvFile -RetentionSets $RetentionSets *>&1 | Write-EvidenceObject
    } else {
        $script = Join-Path $PSScriptRoot 'prod-local-maintenance.ps1'
        $params = @{
            BackupRoot = $BackupRoot
            ScanLogs = $true
        }
        if ($RecoveryDrill) { $params.RecoveryDrill = $true }
        & $script @params *>&1 | Write-EvidenceObject
    }
} catch {
    Write-Evidence (($_ | Out-String).TrimEnd())
    $exitCode = 1
}

if ($LogRetention -gt 0) {
    Get-ChildItem -LiteralPath $logBase -File -Filter "$prefix-*.log" |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -Skip $LogRetention |
        Remove-Item -Force -ErrorAction SilentlyContinue
}

if ($exitCode -eq 0) {
    Write-Evidence "PORTAL_PROD_LOCAL_SCHEDULED_RUN_PASS operation=$Operation log=$logPath"
    exit 0
}

Write-Evidence "PORTAL_PROD_LOCAL_SCHEDULED_RUN_FAIL operation=$Operation log=$logPath"
exit $exitCode
