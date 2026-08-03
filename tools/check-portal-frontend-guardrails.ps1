param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$failures = @()

function Add-Failure([string]$Message) {
  $script:failures += $Message
}

$frontendRoot = Join-Path $Root 'frontend'
if (-not (Test-Path (Join-Path $frontendRoot 'package.json'))) {
  Add-Failure 'frontend/package.json is missing.'
}

if (-not (Test-Path (Join-Path $frontendRoot 'angular.json'))) {
  Add-Failure 'frontend/angular.json is missing.'
}

$envPath = Join-Path $Root '.env'
if (Test-Path $envPath) {
  Add-Failure 'A real .env file exists in the repository workspace.'
}

Push-Location $Root
try {
  $trackedEnv = git ls-files .env
  if ($trackedEnv) { Add-Failure '.env is tracked by git.' }
}
finally {
  Pop-Location
}

$frontendFiles = @()
if (Test-Path $frontendRoot) {
  $frontendFiles = Get-ChildItem -Path $frontendRoot -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\(node_modules|dist|\.angular|coverage)\\' }
}

$certificateFiles = $frontendFiles | Where-Object { $_.Extension -match '^\.(p12|pfx|pem|key|cer|crt)$' }
if ($certificateFiles) {
  Add-Failure 'Certificate or key files found in frontend paths.'
}

$sourceFiles = $frontendFiles | Where-Object { $_.FullName -match '\\src\\' }

$forbiddenSourcePatterns = $sourceFiles |
  Select-String -Pattern 'localStorage|sessionStorage|Authorization|Bearer|client_secret|https?://|crm|financiero|financial' -CaseSensitive:$false -ErrorAction SilentlyContinue
if ($forbiddenSourcePatterns) {
  Add-Failure 'Frontend source contains browser credential storage, auth header, private URL, or consumer runtime coupling pattern.'
}

$component = Join-Path $frontendRoot 'src/app/app.component.ts'
if (Test-Path $component) {
  $componentText = Get-Content $component -Raw
  if ($componentText -notmatch 'standalone:\s*true') {
    Add-Failure 'Frontend shell component is not standalone.'
  }
}

$package = Join-Path $frontendRoot 'package.json'
if (Test-Path $package) {
  $packageText = Get-Content $package -Raw
  foreach ($script in @('"build"', '"test"', '"lint"')) {
    if ($packageText -notmatch [regex]::Escape($script)) {
      Add-Failure "frontend/package.json missing script $script."
    }
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal frontend guardrails OK: buildable shell manifest exists and no browser credential storage, private URL, or consumer runtime coupling was detected in frontend source.'
