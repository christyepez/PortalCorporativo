param(
    [string]$Package = 'config/prod-local-sync-package.json',
    [string[]]$EnvFile = @('.env.portal.local'),
    [double]$MinFreeGB = 10
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$packagePath = if ([IO.Path]::IsPathRooted($Package)) { $Package } else { Join-Path $root $Package }
if (-not (Test-Path -LiteralPath $packagePath)) { throw "Sync package not found: $packagePath" }
$packageData = Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json
$failures = @()

try {
    $dockerVersion = (& docker version --format '{{.Server.Version}}').Trim()
    if (-not $dockerVersion) { throw 'empty version' }
    Write-Output "CHECK dockerServer=$dockerVersion"
} catch {
    $failures += 'dockerDesktop=unavailable'
}

$envNames = @()
$envArgs = @()
foreach ($file in $EnvFile) {
    $path = if ([IO.Path]::IsPathRooted($file)) { $file } else { Join-Path $root $file }
    if (-not (Test-Path -LiteralPath $path)) { $failures += "localFileMissing=$file"; continue }
    $envArgs += @('--env-file',$path)
    Get-Content -LiteralPath $path | ForEach-Object {
        if ($_ -match '^[#\s]*$') { return }
        $i = $_.IndexOf('=')
        if ($i -gt 0) { $envNames += $_.Substring(0,$i).Trim() }
    }
}
foreach ($name in $packageData.RequiredEnvironmentNames) {
    if ($envNames -notcontains [string]$name) { $failures += "missingEnvName=$name" }
}

foreach ($repo in $packageData.Repositories) {
    $repoPath = Join-Path $root ([string]$repo.RelativePath)
    if (-not (Test-Path -LiteralPath $repoPath)) { $failures += "repoMissing=$($repo.Name)"; continue }
    $branch = (& git -C $repoPath branch --show-current).Trim()
    $revision = (& git -C $repoPath rev-parse HEAD).Trim()
    Write-Output "CHECK repo=$($repo.Name) branch=$branch revision=$revision"
    if ($branch -ne [string]$repo.Branch) { $failures += "repoBranch=$($repo.Name)" }
    if ($revision -ne [string]$repo.Revision) { $failures += "repoRevision=$($repo.Name)" }
}

$driveRoot = [IO.Path]::GetPathRoot($root)
$driveName = $driveRoot.TrimEnd('\').TrimEnd(':')
$drive = Get-PSDrive -Name $driveName
$freeGB = [math]::Round($drive.Free / 1GB, 2)
Write-Output ("CHECK freeGB={0:N2}" -f $freeGB)
if ($freeGB -lt $MinFreeGB) { $failures += "freeGB=$freeGB<$MinFreeGB" }

if ($envArgs.Count -gt 0) {
    $composeArgs = @('compose','-p','portalcorporativo') + $envArgs + @('-f',(Join-Path $root 'docker-compose.yml'),'-f',(Join-Path $root 'docker-compose.prod-local.yml'),'config','--quiet')
    & docker @composeArgs
    if ($LASTEXITCODE -ne 0) { $failures += 'composeConfig=failed' }
}
if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output "PREFLIGHT_FAIL $_" }
    throw "PROD-local sync preflight failed with $($failures.Count) issue(s)."
}

Write-Output 'PORTAL_PROD_LOCAL_SYNC_PREFLIGHT_PASS'
