param(
    [string]$EnvFile = ".env.local",
    [string]$ComposeFile = "docker-compose.local.yml",
    [switch]$WithFinanciero,
    [switch]$WithCrm
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $EnvFile)) {
    Write-Error "Missing env file: $EnvFile. Copy .env.example to .env.local first."
}

$profiles = @()
if ($WithFinanciero) { $profiles += @("--profile", "financiero") }
if ($WithCrm) { $profiles += @("--profile", "crm") }

Write-Host "Validating Docker Compose configuration..."
docker compose --env-file $EnvFile -f $ComposeFile @profiles config | Out-Null

Write-Host "Checking configured SQL Server services..."
$config = docker compose --env-file $EnvFile -f $ComposeFile @profiles config
$sqlServiceCount = ($config | Select-String -Pattern "image: mcr.microsoft.com/mssql/server" | Measure-Object).Count

if ($sqlServiceCount -ne 1) {
    Write-Error "Expected exactly one SQL Server service, found $sqlServiceCount."
}

Write-Host "OK: exactly one SQL Server service is configured."
Write-Host "Expected logical databases: PortalCorporativoDb, FinancieroDb, CrmDb."
