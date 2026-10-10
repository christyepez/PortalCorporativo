$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$composePath = Join-Path $root 'docker-compose.yml'
$compose = Get-Content $composePath -Raw

$services = @('sqlserver','redis','minio','seq')
foreach ($service in $services) {
    $pattern = "(?ms)^  $([regex]::Escape($service)):\s*.*?(?=^  [a-zA-Z0-9_-]+:|^volumes:|\z)"
    $match = [regex]::Match($compose, $pattern)
    if (-not $match.Success) { throw "Missing core dependency service: $service" }
    if ($match.Value -notmatch '(?m)^    restart:\s*unless-stopped\s*$') {
        throw "Core dependency '$service' must use restart: unless-stopped"
    }
    Write-Host "PASS $service restart policy"
}
Write-Host 'PORTAL_CORE_DEPENDENCY_RESTART_POLICY_PASS'
