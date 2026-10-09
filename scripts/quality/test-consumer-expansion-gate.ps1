$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
    Write-Host "PASS $Message"
}

$gatewayPath = Join-Path $root 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json'
$composePath = Join-Path $root 'docker-compose.prod-local.yml'
$smokePath = Join-Path $root 'scripts/smoke/prod-local-smoke.ps1'
$shellPath = Join-Path $root 'frontend/src/app/app.component.ts'
$apiClientPath = Join-Path $root 'frontend/src/app/portal-api.service.ts'

$gateway = Get-Content $gatewayPath -Raw | ConvertFrom-Json
$compose = Get-Content $composePath -Raw
$smoke = Get-Content $smokePath -Raw
$shell = Get-Content $shellPath -Raw
$apiClient = Get-Content $apiClientPath -Raw

$consumers = @(
    @{ Name='CRM'; Service='crm-api'; Route='crm'; Health='crm-health'; Path='/api/crm'; Cluster='crm'; Address='http://crm-api:8080/'; ProtectedSmoke='/api/crm/readiness' },
    @{ Name='Financiero'; Service='financial-api'; Route='financial'; Health='financial-health'; Path='/api/financial'; Cluster='financial'; Address='http://financial-api:8080/'; ProtectedSmoke='/api/financial/accounts' },
    @{ Name='Talento Humano'; Service='hr-api'; Route='hr'; Health='hr-health'; Path='/api/hr'; Cluster='hr'; Address='http://hr-api:8080/'; ProtectedSmoke='/api/hr/employees' },
    @{ Name='HistoriasPaolin'; Service='historiaspaolin-api'; Route='historiaspaolin'; Health='historiaspaolin-health'; Path='/api/historiaspaolin'; Cluster='historiaspaolin'; Address='http://historiaspaolin-api:8080/'; ProtectedSmoke='/api/historiaspaolin/api/channels' }
)

foreach ($consumer in $consumers) {
    $route = $gateway.ReverseProxy.Routes.($consumer.Route)
    $health = $gateway.ReverseProxy.Routes.($consumer.Health)
    $cluster = $gateway.ReverseProxy.Clusters.($consumer.Cluster)

    Assert-True ($null -ne $route) "$($consumer.Name) application route exists"
    Assert-True ($route.AuthorizationPolicy -eq 'default') "$($consumer.Name) application route requires default authorization"
    Assert-True ($route.Match.Path.StartsWith($consumer.Path)) "$($consumer.Name) application route uses approved Gateway prefix"
    Assert-True ($null -ne $health) "$($consumer.Name) health route exists"
    Assert-True ([string]::IsNullOrWhiteSpace([string]$health.AuthorizationPolicy)) "$($consumer.Name) health route remains anonymous"
    Assert-True ($cluster.Destinations.primary.Address -eq $consumer.Address) "$($consumer.Name) cluster targets internal service DNS only"

    $servicePattern = "(?ms)^  $([regex]::Escape($consumer.Service)):\s*.*?(?=^  [a-zA-Z0-9_-]+:|^networks:|\z)"
    $serviceMatch = [regex]::Match($compose, $servicePattern)
    Assert-True $serviceMatch.Success "$($consumer.Name) Compose service exists"
    Assert-True ($serviceMatch.Value -match '(?m)^    expose:\s*\r?\n      - "8080"') "$($consumer.Name) exposes only internal container port"
    Assert-True (-not ($serviceMatch.Value -match '(?m)^    ports:')) "$($consumer.Name) has no host-published ports"

    Assert-True ($smoke.Contains($consumer.ProtectedSmoke)) "$($consumer.Name) protected smoke endpoint is covered"
    Assert-True ($shell.Contains("gatewayPath: '$($consumer.Path)'")) "$($consumer.Name) Portal Shell navigation uses Gateway prefix"
}

Assert-True ($smoke.Contains('"X-Correlation-ID"')) 'Authenticated smoke propagates X-Correlation-ID'
Assert-True (-not ($apiClient -match 'localStorage|sessionStorage')) 'Browser access tokens are not persisted'
Assert-True (Test-Path (Join-Path $root 'docs/coordination/consumer-onboarding-template.md')) 'Consumer onboarding template exists'
Write-Host 'PORTAL_CONSUMER_EXPANSION_GATE_PASS'
