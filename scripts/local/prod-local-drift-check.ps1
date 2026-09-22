param(
    [string[]]$EnvFile = @('.env.portal.local'),
    [string]$Baseline = 'config/prod-local-baseline.json'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$baselinePath = if ([IO.Path]::IsPathRooted($Baseline)) { $Baseline } else { Join-Path $root $Baseline }
if (-not (Test-Path -LiteralPath $baselinePath)) { throw "Baseline not found: $baselinePath" }
$baselineData = Get-Content -LiteralPath $baselinePath -Raw | ConvertFrom-Json
$failures = @()

$envNames = @()
$envArgs = @()
foreach ($file in $EnvFile) {
    $path = if ([IO.Path]::IsPathRooted($file)) { $file } else { Join-Path $root $file }
    if (-not (Test-Path -LiteralPath $path)) { throw "Environment file not found: $path" }
    $envArgs += @('--env-file',$path)
    Get-Content -LiteralPath $path | ForEach-Object {
        if ($_ -match '^[#\s]*$') { return }
        $i = $_.IndexOf('=')
        if ($i -gt 0) {
            $name = $_.Substring(0,$i).Trim()
            $envNames += $name
            [Environment]::SetEnvironmentVariable($name,$_.Substring($i+1).Trim(),'Process')
        }
    }
}
foreach ($name in $baselineData.RequiredEnvironmentNames) {
    if ($envNames -notcontains [string]$name) { $failures += "missingEnvName=$name" }
}
foreach ($repo in $baselineData.Repositories) {
    $repoPath = (Resolve-Path (Join-Path $root ([string]$repo.RelativePath))).Path
    $revision = (& git -C $repoPath rev-parse HEAD).Trim()
    $branch = (& git -C $repoPath branch --show-current).Trim()
    if ([string]$repo.RevisionPolicy -eq 'exact') {
        if ($revision -ne [string]$repo.Revision) { $failures += "repoRevision=$($repo.Name)" }
        if ($branch -ne [string]$repo.Branch) { $failures += "repoBranch=$($repo.Name)" }
    }
    Write-Output "CHECK repo=$($repo.Name) branch=$branch revision=$revision"
}

foreach ($entry in $baselineData.ComposeFiles) {
    $file = Join-Path $root ([string]$entry.File)
    $hash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash
    if ($hash -ne [string]$entry.Sha256) { $failures += "composeHash=$($entry.File)" }
}

$composeArgs = @('compose','-p','portalcorporativo') + $envArgs + @('-f',(Join-Path $root 'docker-compose.yml'),'-f',(Join-Path $root 'docker-compose.prod-local.yml'))
$services = @(& docker @composeArgs config --services | Sort-Object -Unique)
$expectedServices = @($baselineData.ExpectedServices | ForEach-Object { [string]$_ } | Sort-Object -Unique)
if (($services -join '|') -ne ($expectedServices -join '|')) { $failures += 'composeServicesMismatch=true' }

$runtimeServices = @(& docker @composeArgs ps -a --services | Sort-Object -Unique)
if (($runtimeServices -join '|') -ne ($expectedServices -join '|')) { $failures += 'runtimeServicesMismatch=true' }
$runtimeImages = @{}
$ids = @(& docker @composeArgs ps -a -q)
foreach ($id in $ids) {
    $inspect = (& docker inspect $id | ConvertFrom-Json)[0]
    $service = [string]$inspect.Config.Labels.'com.docker.compose.service'
    $image = [string]$inspect.Image
    if ($service) { $runtimeImages[$service] = $image }
}
foreach ($property in $baselineData.RuntimeImages.PSObject.Properties) {
    $service = $property.Name
    $expectedImage = [string]$property.Value
    if (-not $runtimeImages.ContainsKey($service)) {
        $failures += "runtimeImageMissing=$service"
    } elseif ($runtimeImages[$service] -ne $expectedImage) {
        $failures += "runtimeImageDrift=$service"
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output "DRIFT $_" }
    throw "PROD-local drift detected: $($failures.Count) issue(s)."
}

Write-Output 'PORTAL_PROD_LOCAL_DRIFT_CHECK_PASS'
