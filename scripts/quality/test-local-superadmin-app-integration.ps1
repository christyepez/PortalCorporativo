$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$gateway = Get-Content -LiteralPath (Join-Path $root 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json') -Raw
$program = Get-Content -LiteralPath (Join-Path $root 'backend/security-api/src/Portal.Security.Api/Program.cs') -Raw
$endpoint = Get-Content -LiteralPath (Join-Path $root 'backend/security-api/src/Portal.Security.Api/LocalAdminSessionEndpoints.cs') -Raw
$seedCatalog = Get-Content -LiteralPath (Join-Path $root 'backend/security-api/src/Portal.Security.Infrastructure/SecuritySeedCatalog.cs') -Raw
$initializer = Get-Content -LiteralPath (Join-Path $root 'backend/security-api/src/Portal.Security.Infrastructure/SecurityDatabaseInitializer.cs') -Raw
$baseCompose = Get-Content -LiteralPath (Join-Path $root 'docker-compose.yml') -Raw
$localCompose = Get-Content -LiteralPath (Join-Path $root 'docker-compose.prod-local.yml') -Raw
$component = Get-Content -LiteralPath (Join-Path $root 'frontend/src/app/app.component.ts') -Raw
$template = Get-Content -LiteralPath (Join-Path $root 'frontend/src/app/app.component.html') -Raw
$apiService = Get-Content -LiteralPath (Join-Path $root 'frontend/src/app/portal-api.service.ts') -Raw
$registry = Get-Content -LiteralPath (Join-Path $root 'frontend/config/consumer-registry.json') -Raw | ConvertFrom-Json

$requiredEndpointMarkers = @(
    'PortalLocalAdmin:Enabled',
    'RolePermissions',
    'Permissions.AsNoTracking()',
    'SUPERADMIN',
    'PortalPermissions.ClaimType',
    'CacheControl',
    'no-store',
    'AllowAnonymous'
)
foreach ($marker in $requiredEndpointMarkers) {
    if (-not $endpoint.Contains($marker)) { throw "Local SuperAdmin endpoint missing marker: $marker" }
    Write-Host "PASS local SuperAdmin endpoint marker $marker"
}

if (-not $program.Contains('MapLocalAdminSessionEndpoints')) {
    throw 'Security API must map the local SuperAdmin endpoint.'
}
if (-not $gateway.Contains('"security-local-session"') -or -not $gateway.Contains('/api/security/local-session')) {
    throw 'Gateway must expose the exact local SuperAdmin session route.'
}
if ($baseCompose.Contains('PortalLocalAdmin__Enabled')) {
    throw 'Local SuperAdmin must not be enabled in base Compose.'
}
if (-not $localCompose.Contains('PortalLocalAdmin__Enabled: "true"')) {
    throw 'PROD-local overlay must explicitly enable local SuperAdmin.'
}

$consumerPermissions = @('crm.*','financial.*','hr.employees.view','hr.employees.manage','historiaspaolin.channels.view')
foreach ($permission in $consumerPermissions) {
    if (-not $seedCatalog.Contains('"' + $permission + '"')) {
        throw "Security seed catalog missing consumer permission: $permission"
    }
    Write-Host "PASS governed consumer permission $permission"
}
foreach ($marker in @('BootstrapGovernedSecurityAsync','SecuritySeedCatalog.Resources','SecuritySeedCatalog.Permissions','RolePermissions.Add')) {
    if (-not $initializer.Contains($marker)) { throw "Security initializer missing governed bootstrap marker: $marker" }
}

if ($registry.version -ne 2) { throw 'Consumer registry must use governed application surface version 2.' }
foreach ($consumer in $registry.consumers) {
    if ([string]::IsNullOrWhiteSpace([string]$consumer.moduleCode)) { throw "Consumer $($consumer.code) missing moduleCode." }
    if ([string]::IsNullOrWhiteSpace([string]$consumer.accessPermission)) { throw "Consumer $($consumer.code) missing accessPermission." }
    if ([string]::IsNullOrWhiteSpace([string]$consumer.protectedSmoke)) { throw "Consumer $($consumer.code) missing protected surface." }
    if ([string]$consumer.uiMode -notin @('native','iframe')) { throw "Consumer $($consumer.code) has invalid uiMode." }
    Write-Host "PASS governed application $($consumer.code)"
}

foreach ($marker in @(
    'createLocalSuperAdminSession()',
    'loadApplicationSurface(path: string)',
    'workspaceProbeState',
    'refreshWorkspaceData()',
    'initializeLocalPortal()',
    'localAdminSession',
    'probe(path: string)',
    'manageApplicationSecurity(application?: ApplicationCard)',
    'applicationAuthorized(application: ApplicationCard)',
    'applicationIntegrationLabel(application: ApplicationCard)',
    'manageApplicationMenu(application: ApplicationCard)',
    'manageApplicationConfiguration(application: ApplicationCard)'
)) {
    if (-not ($component.Contains($marker) -or $apiService.Contains($marker))) {
        throw "Frontend integration missing marker: $marker"
    }
}

if ($template -match 'Pega un token local|JWT local efímero') {
    throw 'Portal must not ask the PROD-local operator to paste a JWT manually.'
}
if ($component.Contains('sessionTokenInput')) {
    throw 'Portal component must not retain the obsolete manual JWT input.'
}
if (($component + $apiService) -match 'localStorage|sessionStorage') {
    throw 'Local administrative tokens must remain memory-only.'
}
if (-not $template.Contains('Integración gobernada por Portal') -or -not $template.Contains('Abrir en Portal')) {
    throw 'Application workspace must be visible and governed in the Portal shell.'
}
foreach ($marker in @('SuperAdmin autorizado','Módulo Portal / API','localAdminSession.displayName','localAdminSession.role')) {
    if (-not $template.Contains($marker)) { throw "Portal shell missing SuperAdmin governance marker: $marker" }
}

Write-Host 'PORTAL_LOCAL_SUPERADMIN_APP_INTEGRATION_GATE_PASS'
