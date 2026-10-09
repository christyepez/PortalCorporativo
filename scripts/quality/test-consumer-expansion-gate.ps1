$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
    Write-Host "PASS $Message"
}

function Assert-SameSet {
    param([object[]]$Actual, [object[]]$Expected, [string]$Message)
    $a = @($Actual | ForEach-Object { [string]$_ } | Sort-Object -Unique)
    $e = @($Expected | ForEach-Object { [string]$_ } | Sort-Object -Unique)
    Assert-True (($a -join '|') -eq ($e -join '|')) $Message
}

$gatewayPath = Join-Path $root 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json'
$composePath = Join-Path $root 'docker-compose.prod-local.yml'
$smokePath = Join-Path $root 'scripts/smoke/prod-local-smoke.ps1'
$e2ePath = Join-Path $root 'scripts/e2e/prod-local-portal-e2e.ps1'
$shellPath = Join-Path $root 'frontend/src/app/app.component.ts'
$apiClientPath = Join-Path $root 'frontend/src/app/portal-api.service.ts'
$registryPath = Join-Path $root 'frontend/config/consumer-registry.json'

$gateway = Get-Content $gatewayPath -Raw | ConvertFrom-Json
$compose = Get-Content $composePath -Raw
$smoke = Get-Content $smokePath -Raw
$e2e = Get-Content $e2ePath -Raw
$shell = Get-Content $shellPath -Raw
$apiClient = Get-Content $apiClientPath -Raw
$registry = Get-Content $registryPath -Raw | ConvertFrom-Json
$consumers = @($registry.consumers)

Assert-True ($registry.version -eq 1) 'Consumer registry schema version is supported'
Assert-True ($consumers.Count -eq 4) 'Consumer registry contains exactly four approved consumers'
$approvedCodes = @('CRM','FINANCIAL','HR','HISTORIAS')
Assert-SameSet $consumers.code $approvedCodes 'Consumer registry contains exactly the approved consumer codes'

$requiredFields = @('name','code','service','route','healthRoute','gatewayPath','cluster','internalAddress','protectedSmoke','probePath')
foreach ($field in $requiredFields) {
    Assert-True (@($consumers | Where-Object { [string]::IsNullOrWhiteSpace([string]$_.$field) }).Count -eq 0) "Consumer registry field '$field' is populated"
}

foreach ($field in @('code','service','route','healthRoute','gatewayPath','cluster','internalAddress','protectedSmoke','probePath')) {
    Assert-True (@($consumers.$field | Sort-Object -Unique).Count -eq $consumers.Count) "Consumer registry field '$field' is unique"
}

$coreRoutes = @('security','configuration','menu','audit','notification','catalog','content','integration','reporting')
$coreClusters = @('security','configuration','menu','audit','notification','catalog','content','integration','reporting')
$expectedConsumerRoutes = @($consumers | ForEach-Object { $_.route; $_.healthRoute })
$actualConsumerRoutes = @($gateway.ReverseProxy.Routes.PSObject.Properties.Name | Where-Object { $_ -notin $coreRoutes })
$actualConsumerClusters = @($gateway.ReverseProxy.Clusters.PSObject.Properties.Name | Where-Object { $_ -notin $coreClusters })
Assert-SameSet $actualConsumerRoutes $expectedConsumerRoutes 'Gateway contains no undeclared consumer routes'
Assert-SameSet $actualConsumerClusters $consumers.cluster 'Gateway contains no undeclared consumer clusters'

foreach ($consumer in $consumers) {
    Assert-True ($consumer.gatewayPath.StartsWith('/api/')) "$($consumer.name) Gateway path is under /api"
    Assert-True ($consumer.protectedSmoke.StartsWith($consumer.gatewayPath)) "$($consumer.name) protected smoke stays inside its Gateway boundary"
    Assert-True ($consumer.probePath.StartsWith("$($consumer.gatewayPath)/health/")) "$($consumer.name) health probe stays inside its health boundary"

    $route = $gateway.ReverseProxy.Routes.($consumer.route)
    $health = $gateway.ReverseProxy.Routes.($consumer.healthRoute)
    $cluster = $gateway.ReverseProxy.Clusters.($consumer.cluster)

    Assert-True ($null -ne $route) "$($consumer.name) application route exists"
    Assert-True ($route.ClusterId -eq $consumer.cluster) "$($consumer.name) application route targets the governed cluster"
    Assert-True ($route.AuthorizationPolicy -eq 'default') "$($consumer.name) application route requires default authorization"
    Assert-True ($route.Match.Path -eq "$($consumer.gatewayPath)/{**catch-all}") "$($consumer.name) application route uses exact governed Gateway prefix"

    Assert-True ($null -ne $health) "$($consumer.name) health route exists"
    Assert-True ($health.ClusterId -eq $consumer.cluster) "$($consumer.name) health route targets the governed cluster"
    Assert-True ([string]::IsNullOrWhiteSpace([string]$health.AuthorizationPolicy)) "$($consumer.name) health route remains anonymous"
    Assert-True ($health.Match.Path -eq "$($consumer.gatewayPath)/health/{**catch-all}") "$($consumer.name) health route uses exact governed health prefix"
    $removePrefix = @($health.Transforms | Where-Object { $_.PathRemovePrefix } | Select-Object -First 1).PathRemovePrefix
    Assert-True ($removePrefix -eq $consumer.gatewayPath) "$($consumer.name) health transform removes only the governed Gateway prefix"

    Assert-True ($null -ne $cluster) "$($consumer.name) Gateway cluster exists"
    Assert-True ($cluster.Destinations.primary.Address -eq $consumer.internalAddress) "$($consumer.name) cluster targets internal service DNS only"

    $servicePattern = "(?ms)^  $([regex]::Escape($consumer.service)):\s*.*?(?=^  [a-zA-Z0-9_-]+:|^networks:|\z)"
    $serviceMatch = [regex]::Match($compose, $servicePattern)
    Assert-True $serviceMatch.Success "$($consumer.name) Compose service exists"
    Assert-True ($serviceMatch.Value -match '(?m)^    expose:\s*\r?\n      - "8080"') "$($consumer.name) exposes only internal container port"
    Assert-True (-not ($serviceMatch.Value -match '(?m)^    ports:')) "$($consumer.name) has no host-published ports"
}

Assert-True ($shell.Contains('consumerRegistry.consumers')) 'Portal Shell applications and consumer health probes use the shared registry'
Assert-True ($smoke.Contains('consumer-registry.json')) 'Authenticated smoke loads the governed consumer registry'
Assert-True ($smoke.Contains('$consumer.probePath')) 'Authenticated smoke derives consumer health probes from the registry'
Assert-True ($smoke.Contains('$consumer.protectedSmoke')) 'Authenticated smoke derives protected endpoints from the registry'
Assert-True ($smoke.Contains('$_.smokePermission')) 'Authenticated smoke derives consumer permissions from the registry'
Assert-True ($e2e.Contains('consumer-registry.json')) 'PROD-local E2E loads the governed consumer registry'
Assert-True ($e2e.Contains('$consumer.protectedSmoke')) 'PROD-local E2E derives consumer navigation checks from the registry'
Assert-True ($e2e.Contains('$_.smokePermission')) 'PROD-local E2E derives consumer permissions from the registry'
Assert-True ($smoke.Contains('"X-Correlation-ID"')) 'Authenticated smoke propagates X-Correlation-ID'
Assert-True (-not ($apiClient -match 'localStorage|sessionStorage')) 'Browser access tokens are not persisted'
Assert-True (Test-Path (Join-Path $root 'docs/coordination/consumer-onboarding-template.md')) 'Consumer onboarding template exists'
Write-Host 'PORTAL_CONSUMER_EXPANSION_GATE_PASS'
