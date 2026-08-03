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

  $compose = if (Test-Path 'docker-compose.yml') { Get-Content 'docker-compose.yml' -Raw } else { '' }
  if ($compose -match '(?im)^\s{2}crm[-_a-z0-9]*\s*:') {
    Add-Failure 'Docker Compose defines CRM services before the CRM P2 planning gate.'
  }
  if ($compose -match 'Database=(CrmDb|CRM)|Initial Catalog=(CrmDb|CRM)') {
    Add-Failure 'Portal Compose contains CRM database connection strings.'
  }

  $gateway = if (Test-Path 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json') {
    Get-Content 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json' -Raw
  } else { '' }
  if ($gateway -match '"crm"|/crm') {
    Add-Failure 'Gateway contains CRM route or cluster before the CRM P2 planning gate.'
  }

  $frontendMatches = if (Test-Path 'frontend/src') {
    Get-ChildItem 'frontend/src' -Recurse -File |
      Select-String -Pattern 'localStorage|sessionStorage|https?://|/crm' -CaseSensitive:$false -ErrorAction SilentlyContinue
  }
  if ($frontendMatches) { Add-Failure 'Frontend source contains browser storage, private URL or productive CRM navigation marker.' }

  $runtimeFiles = $files | Where-Object {
    $_.FullName -match '\\(backend|frontend|scripts|docker-compose\.yml|\.env\.example)($|\\)' -or
    $_.Name -in @('docker-compose.yml', '.env.example')
  }
  $realProviderMatches = $runtimeFiles |
    Select-String -Pattern 'ApplicationInsights|APPINSIGHTS|InstrumentationKey|Datadog|NewRelic|New Relic|Splunk|Elastic|SIEM|Prometheus|Grafana|WebhookProvider|AlertWebhook|ConnectionString\s*[:=]\s*["''][^"'']+' -ErrorAction SilentlyContinue |
    Where-Object { $_.Line -notmatch 'Seq|localhost|CHANGE_ME|PLACEHOLDER|false' }
  if ($realProviderMatches) { Add-Failure 'Potential real external provider or connection string configuration found.' }

  $unsafe = $files |
    Select-String -Pattern 'BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE|client_secret\s*[:=]\s*["''][^"'']+|Bearer\s+[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+|https://(?!localhost|github\.com|json\.schemastore\.org|aka\.ms)' -ErrorAction SilentlyContinue |
    Where-Object { $_.Line -notmatch 'Select-String -Pattern|notmatch|match|PLACEHOLDER|CHANGE_ME|NoGo|No real|github\.com/christyepez' }
  if ($unsafe) { Add-Failure 'Potential real secret, token, certificate or private URL pattern found.' }

  if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
  }

  Write-Host 'Portal to CRM contract alignment guardrails OK: no CRM route, service, shared DB, cross migration, real provider, secret, private URL or browser token storage detected.'
}
finally {
  Pop-Location
}
