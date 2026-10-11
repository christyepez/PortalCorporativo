param(
    [string]$Package = 'config/prod-local-sync-package.json',
    [string[]]$EnvFile = @('.env.portal.local'),
    [double]$MinFreeGB = 10,
    [ValidateSet('Prerequisite','Aligned')][string]$Mode = 'Aligned'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

function Get-NormalizedTextSha256 {
    param([Parameter(Mandatory=$true)][string]$Path)
    $text = Get-Content -LiteralPath $Path -Raw
    $normalized = $text.Replace([string][char]0xFEFF,'').Replace("`r`n","`n").Replace("`r","`n")
    $utf8 = [System.Text.UTF8Encoding]::new($false)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = $utf8.GetBytes($normalized)
        return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-','')
    } finally {
        $sha.Dispose()
    }
}

$packagePath = if ([IO.Path]::IsPathRooted($Package)) { $Package } else { Join-Path $root $Package }
if (-not (Test-Path -LiteralPath $packagePath)) { throw "Sync package not found: $packagePath" }
$packageData = Get-Content -LiteralPath $packagePath -Raw | ConvertFrom-Json
$failures = @()

if ([int]$packageData.SchemaVersion -ne 1) { $failures += "schemaVersion=$($packageData.SchemaVersion)" }
if ([string]$packageData.BaselineHashMode -ne 'normalized-utf8-lf-sha256') { $failures += "baselineHashMode=$($packageData.BaselineHashMode)" }

$baselineFile = [string]$packageData.BaselineFile
if ([string]::IsNullOrWhiteSpace($baselineFile)) {
    $failures += 'baselineFile=missing'
} else {
    $baselinePath = if ([IO.Path]::IsPathRooted($baselineFile)) { $baselineFile } else { Join-Path $root $baselineFile }
    if (-not (Test-Path -LiteralPath $baselinePath)) {
        $failures += "baselineMissing=$baselineFile"
    } else {
        $baselineHash = Get-NormalizedTextSha256 -Path $baselinePath
        Write-Output "CHECK baselineSha256=$baselineHash hashMode=$($packageData.BaselineHashMode)"
        if ($baselineHash -ne [string]$packageData.BaselineSha256) { $failures += 'baselineHashMismatch=true' }
    }
}

foreach ($file in @($packageData.RequiredLocalFiles)) {
    $name = [string]$file
    if ([string]::IsNullOrWhiteSpace($name)) { continue }
    $path = if ([IO.Path]::IsPathRooted($name)) { $name } else { Join-Path $root $name }
    if (-not (Test-Path -LiteralPath $path)) { $failures += "localFileMissing=$name" }
}

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
    if (-not (Test-Path -LiteralPath $path)) { continue }
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
    $dirty = @(& git -C $repoPath status --porcelain)
    if ($dirty.Count -gt 0) { $failures += "repoDirty=$($repo.Name)" }
    $branch = (& git -C $repoPath branch --show-current).Trim()
    $revision = (& git -C $repoPath rev-parse HEAD).Trim()
    Write-Output "CHECK repo=$($repo.Name) branch=$branch revision=$revision"
    $branchMismatch = $branch -ne [string]$repo.Branch
    $revisionMismatch = $revision -ne [string]$repo.Revision
    if ($Mode -eq 'Aligned') {
        if ($branchMismatch) { $failures += "repoBranch=$($repo.Name)" }
        if ($revisionMismatch) { $failures += "repoRevision=$($repo.Name)" }
    } elseif ($branchMismatch -or $revisionMismatch) {
        Write-Output "ALIGN_REQUIRED repo=$($repo.Name) expectedBranch=$($repo.Branch) expectedRevision=$($repo.Revision)"
    }
}

$driveRoot = [IO.Path]::GetPathRoot($root)
$driveName = $driveRoot.TrimEnd('\').TrimEnd(':')
$drive = Get-PSDrive -Name $driveName
$freeGB = [math]::Round($drive.Free / 1GB, 2)
Write-Output ("CHECK freeGB={0:N2}" -f $freeGB)
if ($freeGB -lt $MinFreeGB) { $failures += "freeGB=$freeGB<$MinFreeGB" }

if ($envArgs.Count -gt 0) {
    $composeBase = @('compose','-p','portalcorporativo') + $envArgs + @('-f',(Join-Path $root 'docker-compose.yml'),'-f',(Join-Path $root 'docker-compose.prod-local.yml'))
    & docker @($composeBase + @('config','--quiet'))
    if ($LASTEXITCODE -ne 0) {
        $failures += 'composeConfig=failed'
    } else {
        $actualServices = @(& docker @($composeBase + @('config','--services')) | Sort-Object -Unique)
        $expectedServices = @($packageData.ExpectedServices | ForEach-Object { [string]$_ } | Sort-Object -Unique)
        Write-Output "CHECK composeServices=$($actualServices.Count) expectedServices=$($expectedServices.Count)"
        if (($actualServices -join '|') -ne ($expectedServices -join '|')) { $failures += 'composeServicesMismatch=true' }
    }
}

if ($failures.Count -gt 0) {
    $failures | Select-Object -Unique | ForEach-Object { Write-Output "PREFLIGHT_FAIL $_" }
    throw "PROD-local sync preflight failed with $(@($failures | Select-Object -Unique).Count) issue(s)."
}

if ($Mode -eq 'Prerequisite') {
    Write-Output 'PORTAL_PROD_LOCAL_SYNC_PREREQUISITE_PASS'
} else {
    Write-Output 'PORTAL_PROD_LOCAL_SYNC_ALIGNED_PASS'
}
Write-Output 'PORTAL_PROD_LOCAL_SYNC_PREFLIGHT_PASS'
