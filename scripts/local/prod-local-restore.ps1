param(
    [Parameter(Mandatory=$true)][string]$BackupSetPath,
    [Parameter(Mandatory=$true)][string]$Database,
    [string[]]$EnvFile = @(".env.portal.local"),
    [switch]$Apply,
    [switch]$SkipSafetyBackup
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$allowed = @(
    'PortalSecurity','PortalConfiguration','PortalMenu',
    'PortalAudit','PortalNotification','PortalIntegration',
    'FinancieroDb','AppTTHHDb','HistoriasPaolinDb'
)
if ($allowed -notcontains $Database) { throw "Database is not managed by this recovery script: $Database" }
if (-not $Apply) { throw 'Restore is destructive. Re-run with -Apply after validating the backup set.' }

$setPath = if ([IO.Path]::IsPathRooted($BackupSetPath)) { $BackupSetPath } else { Join-Path $root $BackupSetPath }
$manifestPath = Join-Path $setPath 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath)) { throw "Manifest not found: $manifestPath" }
$item = (Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json) | Where-Object Database -eq $Database | Select-Object -First 1
if (-not $item) { throw "Database $Database is not present in the backup set." }
$backupFile = Join-Path $setPath ([string]$item.File)
if (-not (Test-Path -LiteralPath $backupFile)) { throw "Backup file not found: $backupFile" }
$actualHash = (Get-FileHash -LiteralPath $backupFile -Algorithm SHA256).Hash
if ($actualHash -ne [string]$item.Sha256) { throw 'Backup SHA256 does not match the manifest.' }

$vars = @{}
foreach ($file in $EnvFile) {
    $path = if ([IO.Path]::IsPathRooted($file)) { $file } else { Join-Path $root $file }
    Get-Content -LiteralPath $path | ForEach-Object {
        if ($_ -match '^[#\s]*$') { return }
        $i = $_.IndexOf('=')
        if ($i -gt 0) { $vars[$_.Substring(0,$i).Trim()] = $_.Substring($i + 1).Trim() }
    }
}
$password = $vars['SQLSERVER_SA_PASSWORD']
if ([string]::IsNullOrWhiteSpace($password)) { throw 'SQLSERVER_SA_PASSWORD is required.' }

if (-not $SkipSafetyBackup) {
    & (Join-Path $PSScriptRoot 'prod-local-backup.ps1') -EnvFile $EnvFile -Database @($Database)
    if ($LASTEXITCODE -ne 0) { throw 'Safety backup failed; restore aborted.' }
}
$serviceMap = @{
    PortalSecurity = @('portalcorporativo-security-api-1')
    PortalConfiguration = @('portalcorporativo-configuration-api-1')
    PortalMenu = @('portalcorporativo-menu-api-1')
    PortalAudit = @('portalcorporativo-audit-api-1')
    PortalNotification = @('portalcorporativo-notification-api-1','portalcorporativo-notification-worker-1')
    PortalIntegration = @('portalcorporativo-integration-api-1','portalcorporativo-integration-worker-1')
    FinancieroDb = @('portalcorporativo-financial-api-1')
    AppTTHHDb = @('portalcorporativo-hr-api-1')
    HistoriasPaolinDb = @('portalcorporativo-historiaspaolin-api-1','portalcorporativo-historiaspaolin-worker-1')
}
$containers = @($serviceMap[$Database])
$containerFile = "/var/opt/mssql/backup/portal-local/restore-$Database.bak"

try {
    foreach ($container in $containers) { docker stop $container | Out-Null }
    docker exec portalcorporativo-sqlserver-1 mkdir -p /var/opt/mssql/backup/portal-local | Out-Null
    docker cp $backupFile "portalcorporativo-sqlserver-1:$containerFile"
    if ($LASTEXITCODE -ne 0) { throw 'Could not stage backup inside SQL Server.' }
    $query = "ALTER DATABASE [$Database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; RESTORE DATABASE [$Database] FROM DISK=N'$containerFile' WITH REPLACE, RECOVERY, CHECKSUM; ALTER DATABASE [$Database] SET MULTI_USER; DBCC CHECKDB([$Database]) WITH NO_INFOMSGS;"
    docker exec portalcorporativo-sqlserver-1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $password -C -b -Q $query
    if ($LASTEXITCODE -ne 0) { throw "Restore failed for $Database." }
    Write-Output "PORTAL_PROD_LOCAL_RESTORE_PASS $Database"
}
finally {
    docker exec portalcorporativo-sqlserver-1 rm -f $containerFile 2>$null | Out-Null
    $multi = "IF DB_ID(N'$Database') IS NOT NULL ALTER DATABASE [$Database] SET MULTI_USER;"
    docker exec portalcorporativo-sqlserver-1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $password -C -Q $multi 2>$null | Out-Null
    foreach ($container in $containers) { docker start $container 2>$null | Out-Null }
}
