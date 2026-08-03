param(
  [string]$BaseUrl = 'http://localhost:8082'
)

$ErrorActionPreference = 'Stop'
$paths = @('/health', '/health/live', '/health/ready')
$failed = @()

foreach ($path in $paths) {
  $uri = "$BaseUrl$path"
  try {
    $response = Invoke-WebRequest -UseBasicParsing -Uri $uri -TimeoutSec 5
    Write-Host "$uri -> $($response.StatusCode)"
  }
  catch {
    $failed += "$uri -> $($_.Exception.Message)"
  }
}

if ($failed.Count -gt 0) {
  $failed | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal health checks OK.'
