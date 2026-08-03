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

  $certificateFiles = $files | Where-Object { $_.Extension -match '^\.(p12|pfx|pem|key|cer|crt)$' }
  if ($certificateFiles) { Add-Failure 'Certificate/private key files are present.' }

  $compose = if (Test-Path 'docker-compose.yml') { Get-Content 'docker-compose.yml' -Raw } else { '' }
  if ($compose -match '(?im)^\s{2}(crm|financiero|financial)[-_a-z0-9]*\s*:') {
    Add-Failure 'Docker Compose defines CRM/Financiero services during NonProduction RC.'
  }
  if ($compose -match 'SendGrid|Mailgun|Twilio|Firebase|FCM|APNS|AmazonSES|SMTP__|Smtp__|WebhookProvider') {
    Add-Failure 'Docker Compose contains real notification provider markers.'
  }

  $gateway = if (Test-Path 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json') {
    Get-Content 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json' -Raw
  } else { '' }
  if ($gateway -match '"(crm|financiero|financial)"') {
    Add-Failure 'Gateway contains CRM/Financiero/financial route or cluster before activation gate.'
  }

  $frontendMatches = if (Test-Path 'frontend/src') {
    Get-ChildItem 'frontend/src' -Recurse -File |
      Select-String -Pattern 'localStorage|sessionStorage|https?://|/crm|/financial|/financiero' -CaseSensitive:$false -ErrorAction SilentlyContinue
  }
  if ($frontendMatches) { Add-Failure 'Frontend source contains browser storage, private URL or productive consumer navigation marker.' }

  $unsafe = $files |
    Select-String -Pattern 'BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE|client_secret\s*[:=]\s*["''][^"'']+|Bearer\s+[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+|https://(?!localhost|github\.com|json\.schemastore\.org|aka\.ms)' -ErrorAction SilentlyContinue |
    Where-Object { $_.Line -notmatch 'Select-String -Pattern|notmatch|match|LOCAL_ONLY_PLACEHOLDER|PLACEHOLDER|CHANGE_ME|NoGo|No real|Bearer\\s|client_secret\\s|BEGIN CERTIFICATE|github\.com/christyepez' }
  if ($unsafe) { Add-Failure 'Potential real secret, token, certificate or private URL pattern found.' }

  if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
  }

  Write-Host 'Portal NonProduction RC guardrails OK: no production activation, real providers, secrets, private URLs, browser token storage, consumer routes or runtime coupling detected.'
}
finally {
  Pop-Location
}
