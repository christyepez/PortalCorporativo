param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$failures = @()

function Add-Failure([string]$Message) {
  $script:failures += $Message
}

$runtimeRoots = @('backend/audit-api', 'backend/configuration-api', 'backend/notification-api', 'backend/workers', 'backend/building-blocks', 'docker-compose.yml', '.env.example') |
  ForEach-Object { Join-Path $Root $_ } |
  Where-Object { Test-Path $_ }

$runtimeFiles = foreach ($runtimeRoot in $runtimeRoots) {
  if (Test-Path $runtimeRoot -PathType Container) {
    Get-ChildItem -Path $runtimeRoot -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -notmatch '\\(bin|obj|node_modules|\.git)\\' }
  }
  else {
    Get-Item $runtimeRoot
  }
}

$providerMatches = $runtimeFiles | Select-String -Pattern 'SmtpClient|SMTP__|Smtp__|SendEmail|SendGrid|Twilio|SmsProvider|PushProvider|Firebase|FCM|APNS|Mailgun|AmazonSES' -ErrorAction SilentlyContinue
if ($providerMatches) {
  Add-Failure 'Potential real notification provider or email/SMS/push sending configuration found in runtime files.'
}

$privateUrlMatches = $runtimeFiles | Select-String -Pattern 'https://(?!localhost|github\.com|json\.schemastore\.org)' -ErrorAction SilentlyContinue
if ($privateUrlMatches) {
  Add-Failure 'Potential private URL found in crosscutting runtime files.'
}

$envPath = Join-Path $Root '.env'
if (Test-Path $envPath) {
  Add-Failure 'A real .env file exists in the repository workspace.'
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal crosscutting guardrails OK: no real SMTP/SMS/push/email provider, private URL, or real .env detected.'
