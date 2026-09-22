param(
    [string[]]$EnvFile = @('.env.portal.local'),
    [string]$Output = 'config/prod-local-baseline.json'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$repoDefs = @(
    @{ Name='PortalCorporativo'; RelativePath='.'; RevisionPolicy='self' },
    @{ Name='CRM'; RelativePath='../CRM'; RevisionPolicy='exact' },
    @{ Name='Financiero'; RelativePath='../Financiero'; RevisionPolicy='exact' },
    @{ Name='AppTTHH'; RelativePath='../AppTTHH'; RevisionPolicy='exact' },
    @{ Name='HistoriasPaolin'; RelativePath='../HistoriasPaolin_PORTAL_PROD'; RevisionPolicy='exact' }
)

$repos = foreach ($def in $repoDefs) {
    $repoPath = (Resolve-Path (Join-Path $root $def.RelativePath)).Path
    $revision = (& git -C $repoPath rev-parse HEAD).Trim()
    $branch = (& git -C $repoPath branch --show-current).Trim()
    if ($def.RevisionPolicy -eq 'self') { $branch = '*'; $revision = '*' }
    [pscustomobject]@{ Name=$def.Name; RelativePath=$def.RelativePath; RevisionPolicy=$def.RevisionPolicy; Branch=$branch; Revision=$revision }
}

$composeFiles = @('docker-compose.yml','docker-compose.prod-local.yml')
$compose = foreach ($file in $composeFiles) {
    $full = Join-Path $root $file
    [pscustomobject]@{ File=$file; Sha256=(Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash }
}
$requiredNames = @()
foreach ($file in $composeFiles) {
    $text = Get-Content -LiteralPath (Join-Path $root $file) -Raw
    foreach ($match in [regex]::Matches($text, '\$\{([A-Za-z_][A-Za-z0-9_]*)\:\?')) {
        $requiredNames += $match.Groups[1].Value
    }
}
$requiredNames = @($requiredNames | Sort-Object -Unique)

$envArgs = @()
foreach ($file in $EnvFile) {
    $path = if ([IO.Path]::IsPathRooted($file)) { $file } else { Join-Path $root $file }
    if (-not (Test-Path -LiteralPath $path)) { throw "Environment file not found: $path" }
    $envArgs += @('--env-file',$path)
    Get-Content -LiteralPath $path | ForEach-Object {
        if ($_ -match '^[#\s]*$') { return }
        $i = $_.IndexOf('=')
        if ($i -gt 0) { [Environment]::SetEnvironmentVariable($_.Substring(0,$i).Trim(),$_.Substring($i+1).Trim(),'Process') }
    }
}
$composeArgs = @('compose','-p','portalcorporativo') + $envArgs + @('-f',(Join-Path $root 'docker-compose.yml'),'-f',(Join-Path $root 'docker-compose.prod-local.yml'))
$services = @(& docker @composeArgs config --services | Sort-Object -Unique)
if ($LASTEXITCODE -ne 0) { throw 'Could not resolve Compose services.' }

$runtimeImages = @{}
$ids = @(& docker @composeArgs ps -a -q)
foreach ($id in $ids) {
    $inspect = (& docker inspect $id | ConvertFrom-Json)[0]
    $service = [string]$inspect.Config.Labels.'com.docker.compose.service'
    $image = [string]$inspect.Image
    if ($service) { $runtimeImages[$service] = $image }
}
$baseline = [ordered]@{
    SchemaVersion = 1
    Project = 'portalcorporativo'
    CapturedUtc = [DateTime]::UtcNow.ToString('o')
    Repositories = @($repos)
    ComposeFiles = @($compose)
    RequiredEnvironmentNames = @($requiredNames)
    ExpectedServices = @($services)
    RuntimeImages = $runtimeImages
}

$outputPath = if ([IO.Path]::IsPathRooted($Output)) { $Output } else { Join-Path $root $Output }
$parent = Split-Path -Parent $outputPath
New-Item -ItemType Directory -Path $parent -Force | Out-Null
$json = $baseline | ConvertTo-Json -Depth 8
$tempPath = "$outputPath.tmp-$PID"
$json | Set-Content -LiteralPath $tempPath -Encoding UTF8
try {
    $written = $false
    for ($attempt = 1; $attempt -le 8 -and -not $written; $attempt++) {
        try {
            Move-Item -LiteralPath $tempPath -Destination $outputPath -Force
            $written = $true
        }
        catch {
            if ($attempt -eq 8) { throw }
            Start-Sleep -Milliseconds 250
        }
    }
}
finally {
    Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
}
Write-Output "PORTAL_PROD_LOCAL_DRIFT_BASELINE_CREATED $outputPath"
