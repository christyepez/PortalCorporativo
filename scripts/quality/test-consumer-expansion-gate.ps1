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
$registryPath = Join-Path $root 'frontend/config/consumer-registry.json'

$gateway = Get-Content $gatewayPath -Raw | ConvertFrom-Json
$compose = Get-Content $composePath -Raw
$smoke = Get-Content $smokePath -Raw
$shell = Get-Content $shellPath -Raw
$apiClient = Get-Content $apiClientPath -Raw
$registry = Get-Content $registryPath -Raw | ConvertFrom-Json
$consumers = @($registry.consumers)

Assert-True ($registry.version -eq 1) 'Consumer registry schema version is supported'
Assert-True ($consumers.Count -eq 4) 'Consumer registry contains exactly four approved consumers'
$approvedCodes = @('CRM','FINANCIAL','HR','HISTORIAS')
Assert-True (@($consumers | Where-Object { $_.code -notin $approvedCodes }).Count -eq 0) 'Consumer registry contains only approved consumer codes'
Assert-True (@($consumers.code | Sort-Object -Unique).Count -eq $consumers.Count) 'Consumer registry codes are unique'

foreach ($consumer in $consumers) {
    $route = $gateway.ReverseProxy.Routes.($consumer.route)
    $health = $gateway.ReverseProxy.Routes.($consumer.healthRoute)
    $cluster = $gateway.ReverseProxy.Clusters.($consumer.cluster)

    Assert-True ($null -ne $route) "$($consumer.name) application route exists"
    Assert-True ($route.AuthorizationPolicy -eq 'default') "$($consumer.name) application route requires default authorization"
    Assert-True ($route.Match.Path.StartsWith($consumer.gatewayPath)) "$($consumer.name) application route uses approved Gateway prefix"
    Assert-True ($null -ne $health) "$($consumer.name) health route exists"
    Assert-True ([string]::IsNullOrWhiteSpace([string]$health.AuthorizationPolicy)) "$($consumer.name) health route remains anonymous"
    Assert-True ($cluster.Destinations.primary.Address -eq $consumer.internalAddress) "$($consumer.name) cluster targets internal service DNS only"

    $servicePattern = "(?ms)^  $([regex]::Escape($consumer.service)):\s*.*?(?=^  [a-zA-Z0-9_-]+:|^networks:|\z)"
    $serviceMatch = [regex]::Match($compose, $servicePattern)
    Assert-True $serviceMatch.Success "$($consumer.name) Compose service exists"
    Assert-True ($serviceMatch.Value -match '(?m)^    expose:\s*\r?\n      - "8080"') "$($consumer.name) exposes only internal container port"
    Assert-True (-not ($serviceMatch.Value -match '(?m)^    ports:')) "$($consumer.name) has no host-published ports"

    Assert-True ($smoke.Contains($consumer.protectedSmoke)) "$($consumer.name) protected smoke endpoint is covered"
}

Assert-True ($shell.Contains('consumerRegistry.consumers')) 'Portal Shell applications and consumer health probes use the shared registry'
Assert-True ($smoke.Contains('"X-Correlation-ID"')) 'Authenticated smoke propagates X-Correlation-ID'
Assert-True (-not ($apiClient -match 'localStorage|sessionStorage')) 'Browser access tokens are not persisted'
Assert-True (Test-Path (Join-Path $root 'docs/coordination/consumer-onboarding-template.md')) 'Consumer onboarding template exists'
Write-Host 'PORTAL_CONSUMER_EXPANSION_GATE_PASS'
