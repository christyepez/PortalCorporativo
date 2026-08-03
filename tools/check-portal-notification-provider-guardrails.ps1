param([string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path)
$ErrorActionPreference = 'Stop'
$failures = @()
function Add-Failure([string]$Message) { $script:failures += $Message }

Push-Location $Root
try {
  if (Test-Path '.env') { Add-Failure 'A real .env file is present in the repository root.' }

  $files = Get-ChildItem -Recurse -File |
    Where-Object {
      $_.FullName -notmatch '\\(bin|obj|node_modules|dist|\.angular|\.git)\\' -and
      $_.FullName -notmatch '\\frontend\\package-lock\.json$'
    }

  $certificateFiles = $files | Where-Object { $_.Extension -match '^\.(p12|pfx|pem|key|cer|crt)$' }
  if ($certificateFiles) { Add-Failure 'Certificate/private key files are present.' }

  $runtimeRoots = @(
    'backend/notification-api',
    'backend/workers/src/Portal.Notification.Worker',
    'backend/building-blocks',
    'backend/configuration-api',
    'docker-compose.yml',
    '.env.example',
    'frontend/src',
    'scripts/smoke/sprint1-smoke.ps1'
  )

  $runtimeFiles = foreach ($path in $runtimeRoots) {
    if (Test-Path $path) {
      $item = Get-Item $path
      if ($item.PSIsContainer) {
        Get-ChildItem $item.FullName -Recurse -File |
          Where-Object { $_.FullName -notmatch '\\(bin|obj|node_modules|dist|\.angular)\\' }
      } else {
        $item
      }
    }
  }

  $realProviderPatterns = 'SmtpClient|SMTP__|Smtp__|SendGrid|Mailgun|AmazonSES|Twilio|Firebase|FCM|APNS|SmsProvider|PushProvider|WebhookProvider|api_key\s*[:=]\s*["''][^"'']+'
  $realProviders = $runtimeFiles | Select-String -Pattern $realProviderPatterns -ErrorAction SilentlyContinue |
    Where-Object { $_.Line -notmatch 'EmailDev|LogDev|InternalDev|DevelopmentNotificationProvider|No SMTP|No real|Future|guardrails|Select-String|realProviderPatterns' }
  if ($realProviders) { Add-Failure 'Potential real notification provider configuration or implementation found in runtime files.' }

  $unsafe = $runtimeFiles |
    Select-String -Pattern 'BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE|client_secret\s*[:=]\s*["''][^"'']+|Bearer\s+[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+|https://(?!localhost|github\.com|json\.schemastore\.org|aka\.ms)' -ErrorAction SilentlyContinue |
    Where-Object { $_.Line -notmatch 'Select-String -Pattern|notmatch|match|LOCAL_ONLY_PLACEHOLDER|PLACEHOLDER|CHANGE_ME|NoGo|No real|Bearer\\s|client_secret\\s|BEGIN CERTIFICATE' }
  if ($unsafe) { Add-Failure 'Potential real secret, token, certificate or private URL pattern found.' }

  $browserStorage = if (Test-Path 'frontend/src') {
    Get-ChildItem 'frontend/src' -Recurse -File |
      Select-String -Pattern 'localStorage|sessionStorage' -ErrorAction SilentlyContinue
  }
  if ($browserStorage) { Add-Failure 'Browser token storage marker found in frontend source.' }

  $compose = if (Test-Path 'docker-compose.yml') { Get-Content 'docker-compose.yml' -Raw } else { '' }
  if ($compose -match '(?im)^\s{2}(crm|financiero|financial)[-_a-z0-9]*\s*:') {
    Add-Failure 'Docker Compose defines CRM/Financiero services during Notification Provider preparation.'
  }
  if ($compose -match 'SendGrid|Mailgun|Twilio|Firebase|FCM|APNS|AmazonSES|SMTP__|Smtp__|WebhookProvider') {
    Add-Failure 'Docker Compose contains real notification provider markers.'
  }

  if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
  }

  Write-Host 'Portal Notification Provider guardrails OK: development providers only, no real notification credentials, no external provider runtime, no browser token storage and no consumer runtime coupling detected.'
}
finally {
  Pop-Location
}
