param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'
$failures = @()

function Add-Failure([string]$Message) {
  $script:failures += $Message
}

$envPath = Join-Path $Root '.env'
if (Test-Path $envPath) {
  Add-Failure 'A real .env file exists in the repository workspace. Keep it untracked and do not commit it.'
}

$forbiddenFiles = Get-ChildItem -Path $Root -Recurse -File -Include *.p12,*.pfx,*.key,*.cer,*.crt,*.pem -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch '\\(bin|obj|node_modules|\.git)\\' }
if ($forbiddenFiles) {
  Add-Failure ('Certificate/key-like files found: ' + (($forbiddenFiles | ForEach-Object { $_.FullName }) -join ', '))
}

$scanRoots = @('docker-compose.yml', '.env.example', 'docs', 'codex', 'scripts', 'tools') |
  ForEach-Object { Join-Path $Root $_ } |
  Where-Object { Test-Path $_ }

$scanFiles = foreach ($scanRoot in $scanRoots) {
  if (Test-Path $scanRoot -PathType Container) {
    Get-ChildItem -Path $scanRoot -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object { $_.FullName -notmatch '\\(bin|obj|node_modules|\.git)\\' -and $_.FullName -ne $PSCommandPath }
  }
  else {
    Get-Item $scanRoot
  }
}

$suspicious = $scanFiles |
  Select-String -Pattern 'BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY|BEGIN CERTIFICATE|password\s*=\s*(?!\$\{|CHANGE_ME|.*Local_Only)|secret\s*=\s*(?!\$\{|CHANGE_ME|.*Local_Only)|https://(?!github\.com|localhost)' -ErrorAction SilentlyContinue
if ($suspicious) {
  Add-Failure ('Potential secret/private URL patterns found. Review before committing.')
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host 'Portal guardrails OK: no real .env, certificate/key files, or obvious private secret patterns detected.'
