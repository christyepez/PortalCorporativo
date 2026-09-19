param(
    [string[]]$EnvFile = @(".env.portal.local"),
    [string]$OutputRoot = "backups/prod-local",
    [int]$RetentionSets = 7,
    [string[]]$Database = @(
        "PortalSecurity","PortalConfiguration","PortalMenu",
        "PortalAudit","PortalNotification","PortalIntegration",
        "FinancieroDb","AppTTHHDb","HistoriasPaolinDb"
    )
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
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
foreach ($db in $Database) {
    if ($db -notmatch '^[A-Za-z0-9_]+$') { throw "Invalid database name: $db" }
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$outputBase = if ([IO.Path]::IsPathRooted($OutputRoot)) { $OutputRoot } else { Join-Path $root $OutputRoot }
$setPath = Join-Path $outputBase $stamp
New-Item -ItemType Directory -Path $setPath -Force | Out-Null
$containerDir = '/var/opt/mssql/backup/portal-local'
docker exec portalcorporativo-sqlserver-1 mkdir -p $containerDir | Out-Null

$manifest = @()
foreach ($db in $Database) {
    $fileName = "${db}_${stamp}.bak"
    $containerFile = "$containerDir/$fileName"
    $query = "BACKUP DATABASE [$db] TO DISK=N'$containerFile' WITH COPY_ONLY, COMPRESSION, INIT, CHECKSUM; RESTORE VERIFYONLY FROM DISK=N'$containerFile' WITH CHECKSUM;"
    docker exec portalcorporativo-sqlserver-1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $password -C -b -Q $query
    if ($LASTEXITCODE -ne 0) { throw "Backup failed for $db." }
    $hostFile = Join-Path $setPath $fileName
    docker cp "portalcorporativo-sqlserver-1:$containerFile" $hostFile
    if ($LASTEXITCODE -ne 0) { throw "Copy failed for $db." }
    docker exec portalcorporativo-sqlserver-1 rm -f $containerFile | Out-Null

    $item = Get-Item -LiteralPath $hostFile
    $hash = (Get-FileHash -LiteralPath $hostFile -Algorithm SHA256).Hash
    $manifest += [pscustomobject]@{
        Database = $db
        File = $fileName
        SizeBytes = $item.Length
        Sha256 = $hash
    }
}

$manifest | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $setPath 'manifest.json') -Encoding UTF8
$sets = Get-ChildItem -LiteralPath $outputBase -Directory | Sort-Object Name -Descending
if ($RetentionSets -gt 0 -and $sets.Count -gt $RetentionSets) {
    $sets | Select-Object -Skip $RetentionSets | Remove-Item -Recurse -Force
}

Write-Output "PORTAL_PROD_LOCAL_BACKUP_PASS $setPath"
