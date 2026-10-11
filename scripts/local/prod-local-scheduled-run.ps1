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

try {
    if ($Operation -eq 'Backup') {
        $script = Join-Path $PSScriptRoot 'prod-local-backup.ps1'
        & $script -EnvFile $EnvFile -RetentionSets $RetentionSets *>&1 | Tee-Object -FilePath $logPath
    } else {
        $script = Join-Path $PSScriptRoot 'prod-local-maintenance.ps1'
        $params = @{
            BackupRoot = $BackupRoot
            ScanLogs = $true
        }
        if ($RecoveryDrill) { $params.RecoveryDrill = $true }
        & $script @params *>&1 | Tee-Object -FilePath $logPath
    }
} catch {
    $_ | Out-String | Tee-Object -FilePath $logPath -Append | Write-Output
    $exitCode = 1
}

if ($LogRetention -gt 0) {
    Get-ChildItem -LiteralPath $logBase -File -Filter "$prefix-*.log" |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -Skip $LogRetention |
        Remove-Item -Force -ErrorAction SilentlyContinue
}

if ($exitCode -eq 0) {
    Write-Output "PORTAL_PROD_LOCAL_SCHEDULED_RUN_PASS operation=$Operation log=$logPath"
    exit 0
}

Write-Output "PORTAL_PROD_LOCAL_SCHEDULED_RUN_FAIL operation=$Operation log=$logPath"
exit $exitCode
