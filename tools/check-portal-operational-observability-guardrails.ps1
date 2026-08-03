param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'
$failures = @()
function Add-Failure([string]$Message) { $script:failures += $Message }

Push-Location $Root
try {
  if (Test-Path '.env') { Add-Failure 'A real .env file is present in the Portal repository root.' }

  $files = Get-ChildItem -Recurse -File |
    Where-Object {
      $_.FullName -notmatch '\\(bin|obj|node_modules|dist|\.angular|\.git)\\' -and
      $_.FullName -notmatch '\\frontend\\package-lock\.json$'
    }

  $forbiddenFiles = $files | Where-Object { $_.Extension -match '^\.(p12|pfx|pem|key|cer|crt)$' }
  if ($forbiddenFiles) { Add-Failure 'Certificate/private key files are present.' }

  $runtimeFiles = $files | Where-Object {
    $_.FullName -match '\\(backend|frontend|docker-compose\.yml|\.env\.example)($|\\)' -or
    $_.Name -in @('docker-compose.yml', '.env.example')
  }

  $realProviderMatches = $runtimeFiles |
    Select-String -Pattern 'ApplicationInsights|APPINSIGHTS|InstrumentationKey|Datadog|NewRelic|New Relic|Splunk|Elastic|SIEM|Prometheus|Grafana|WebhookProvider|AlertWebhook|Alert__|ConnectionString\s*[:=]\s*["''][^"'']+' -ErrorAction SilentlyContinue |
    Where-Object { $_.Line -notmatch 'Seq|localhost|CHANGE_ME|PLACEHOLDER|false' }
  if ($realProviderMatches) { Add-Failure 'Potential real external observability provider or alert configuration found.' }

  $compose = if (Test-Path 'docker-compose.yml') { Get-Content 'docker-compose.yml' -Raw } else { '' }
  if ($compose -notmatch 'seq:') { Add-Failure 'Local Seq service is missing from Docker Compose.' }
  if ($compose -match '(?im)^\s{2}(crm|financiero|financial)[-_a-z0-9]*\s*:') {
    Add-Failure 'Docker Compose defines CRM/Financiero services during observability preparation.'
  }

  $frontendMatches = if (Test-Path 'frontend/src') {
    Get-ChildItem 'frontend/src' -Recurse -File |
      Select-String -Pattern 'localStorage|sessionStorage|https?://|/crm|/financial|/financiero' -CaseSensitive:$false -ErrorAction SilentlyContinue
  }
  if ($frontendMatches) { Add-Failure 'Frontend source contains browser storage, private URL or productive consumer navigation marker.' }

  $unsafe = $files |
    Select-String -Pattern 'BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE|client_secret\s*[:=]\s*["''][^"'']+|Bearer\s+[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+|https://(?!localhost|github\.com|json\.schemastore\.org|aka\.ms)' -ErrorAction SilentlyContinue |
    Where-Object { $_.Line -notmatch 'Select-String -Pattern|notmatch|match|LOCAL_ONLY_PLACEHOLDER|PLACEHOLDER|CHANGE_ME|NoGo|No real|github\.com/christyepez' }
  if ($unsafe) { Add-Failure 'Potential real secret, token, certificate or private URL pattern found.' }

  if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
  }

  Write-Host 'Portal operational observability guardrails OK: local Seq only; real external observability providers, alerts, secrets, private URLs and consumer runtime coupling are disabled.'
}
finally {
  Pop-Location
}
