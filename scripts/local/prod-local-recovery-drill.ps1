param(
    [Parameter(Mandatory=$true)][string]$BackupSetPath,
    [string[]]$EnvFile = @(".env.portal.local"),
    [string[]]$Database = @()
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$setPath = if ([IO.Path]::IsPathRooted($BackupSetPath)) { $BackupSetPath } else { Join-Path $root $BackupSetPath }
$manifestPath = Join-Path $setPath 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath)) { throw "Manifest not found: $manifestPath" }

$vars = @{}
foreach ($file in $EnvFile) {
    $path = if ([IO.Path]::IsPathRooted($file)) { $file } else { Join-Path $root $file }
    if (-not (Test-Path -LiteralPath $path)) { throw "Environment file not found: $path" }
    Get-Content -LiteralPath $path | ForEach-Object {
        if ($_ -match '^[#\s]*$') { return }
        $i = $_.IndexOf('=')
        if ($i -gt 0) { $vars[$_.Substring(0,$i).Trim()] = $_.Substring($i + 1).Trim() }
    }
}
$password = $vars['SQLSERVER_SA_PASSWORD']
if ([string]::IsNullOrWhiteSpace($password)) { throw 'SQLSERVER_SA_PASSWORD is required.' }

$items = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if ($Database.Count -gt 0) {
    $items = @($items | Where-Object { $Database -contains [string]$_.Database })
}
if ($items.Count -eq 0) { throw 'No backup entries selected for recovery drill.' }

$containerDir = '/var/opt/mssql/backup/portal-local/recovery-drill'
docker exec portalcorporativo-sqlserver-1 mkdir -p $containerDir | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Could not prepare recovery drill directory in SQL Server.' }

try {
    foreach ($item in $items) {
        $db = [string]$item.Database
        if ($db -notmatch '^[A-Za-z0-9_]+$') { throw "Invalid database name in manifest: $db" }

        $backupFile = Join-Path $setPath ([string]$item.File)
        if (-not (Test-Path -LiteralPath $backupFile)) { throw "Backup file not found: $backupFile" }
        $actualHash = (Get-FileHash -LiteralPath $backupFile -Algorithm SHA256).Hash
        if ($actualHash -ne [string]$item.Sha256) { throw "Backup SHA256 mismatch for $db." }

        $containerFile = "$containerDir/$([IO.Path]::GetFileName($backupFile))"
        docker cp $backupFile "portalcorporativo-sqlserver-1:$containerFile" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Could not stage backup for $db." }

        $query = "RESTORE VERIFYONLY FROM DISK=N'$containerFile' WITH CHECKSUM; DBCC CHECKDB([$db]) WITH NO_INFOMSGS;"
        docker exec portalcorporativo-sqlserver-1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $password -C -b -Q $query
        if ($LASTEXITCODE -ne 0) { throw "Recovery drill failed for $db." }

        docker exec portalcorporativo-sqlserver-1 rm -f $containerFile | Out-Null
        Write-Output "RECOVERY_DRILL_PASS $db"
    }
}
finally {
    docker exec portalcorporativo-sqlserver-1 sh -c "rm -f $containerDir/*" 2>$null | Out-Null
}

Write-Output 'PORTAL_PROD_LOCAL_RECOVERY_DRILL_PASS'
