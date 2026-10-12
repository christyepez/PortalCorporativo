$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$gateway = Get-Content -LiteralPath (Join-Path $root 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json') -Raw
$gatewayProgram = Get-Content -LiteralPath (Join-Path $root 'backend/api-gateway/src/Portal.ApiGateway/Program.cs') -Raw
$program = Get-Content -LiteralPath (Join-Path $root 'backend/security-api/src/Portal.Security.Api/Program.cs') -Raw
$endpoint = Get-Content -LiteralPath (Join-Path $root 'backend/security-api/src/Portal.Security.Api/LocalAdminSessionEndpoints.cs') -Raw
$seedCatalog = Get-Content -LiteralPath (Join-Path $root 'backend/security-api/src/Portal.Security.Infrastructure/SecuritySeedCatalog.cs') -Raw
$initializer = Get-Content -LiteralPath (Join-Path $root 'backend/security-api/src/Portal.Security.Infrastructure/SecurityDatabaseInitializer.cs') -Raw
$baseCompose = Get-Content -LiteralPath (Join-Path $root 'docker-compose.yml') -Raw
$localCompose = Get-Content -LiteralPath (Join-Path $root 'docker-compose.prod-local.yml') -Raw
$component = Get-Content -LiteralPath (Join-Path $root 'frontend/src/app/app.component.ts') -Raw
$template = Get-Content -LiteralPath (Join-Path $root 'frontend/src/app/app.component.html') -Raw
$apiService = Get-Content -LiteralPath (Join-Path $root 'frontend/src/app/portal-api.service.ts') -Raw
$authentication = Get-Content -LiteralPath (Join-Path $root 'backend/building-blocks/src/Portal.BuildingBlocks/PortalAuthentication.cs') -Raw
$dockerfile = Get-Content -LiteralPath (Join-Path $root 'frontend/Dockerfile.prod') -Raw
$nginx = Get-Content -LiteralPath (Join-Path $root 'frontend/nginx.prod.conf') -Raw
$registry = Get-Content -LiteralPath (Join-Path $root 'frontend/config/consumer-registry.json') -Raw | ConvertFrom-Json

$requiredEndpointMarkers = @(
    'PortalLocalAdmin:Enabled',
    'RolePermissions',
    'Permissions.AsNoTracking()',
    'SUPERADMIN',
    'PortalPermissions.ClaimType',
    'CacheControl',
    'no-store',
    'AllowAnonymous',
    'portal_local_session',
    'HttpOnly = true',
    'SameSite = SameSiteMode.Strict',
    'EnsureLocalSuperAdminAsync',
    'UserRole.Create',
    '/api/security/local-session/logout'
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
if (-not $gateway.Contains('"security-local-session-logout"') -or -not $gateway.Contains('/api/security/local-session/logout')) {
    throw 'Gateway must expose the exact local SuperAdmin logout route.'
}
if (-not $authentication.Contains('portal_local_session') -or -not $authentication.Contains('OnMessageReceived')) {
    throw 'Portal JWT authentication must accept the local HttpOnly session cookie.'
}
foreach ($marker in @('portal_local_session','Headers.Authorization','Bearer {localSessionToken}','UseAuthentication()','MapReverseProxy()')) {
    if (-not $gatewayProgram.Contains($marker)) { throw "Gateway downstream forwarding missing marker: $marker" }
}
if ($gatewayProgram.IndexOf('portal_local_session') -gt $gatewayProgram.IndexOf('UseAuthentication()')) {
    throw 'Gateway must translate the local session cookie before authentication and proxying.'
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
    if ([string]$consumer.uiMode -eq 'iframe') {
        if ([string]::IsNullOrWhiteSpace([string]$consumer.webPath)) { throw "Consumer $($consumer.code) iframe missing webPath." }
        if (-not ([string]$consumer.webPath).StartsWith('/apps/')) { throw "Consumer $($consumer.code) webPath must stay under /apps." }
    } elseif (-not [string]::IsNullOrWhiteSpace([string]$consumer.webPath)) {
        throw "Consumer $($consumer.code) native integration must not expose webPath."
    }
    $routePattern = '"' + [regex]::Escape([string]$consumer.route) + '"'
    if (-not $gateway.Contains('"' + [string]$consumer.accessPermission + '"')) {
        throw "Gateway missing governed Security policy for $($consumer.code): $($consumer.accessPermission)"
    }
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
    'clearLocalSuperAdminSession()',
    'consumer.webPath',
    'new URL(application.webPath, window.location.origin)',
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
foreach ($marker in @('SuperAdmin autorizado','localAdminSession.displayName','localAdminSession.role')) {
    if (-not $template.Contains($marker)) { throw "Portal shell missing SuperAdmin governance marker: $marker" }
}
if (-not $component.Contains("'Módulo Portal / API'")) {
    throw 'Portal component must identify native API applications explicitly.'
}

$embedded = @($registry.consumers | Where-Object { $_.uiMode -eq 'iframe' })
if (($embedded.code | Sort-Object) -join ',' -ne 'CRM,FINANCIAL') {
    throw 'Exactly CRM and FINANCIAL must expose embedded UIs in the current baseline.'
}
foreach ($marker in @(
    'additional_contexts:',
    'crm_source:',
    'financial_source:'
)) {
    if (-not $localCompose.Contains($marker)) { throw "PROD-local embedded build missing marker: $marker" }
}
foreach ($marker in @(
    'COPY --from=crm_source',
    'COPY --from=financial_source',
    'pnpm run build -- --base-href /apps/crm/',
    'pnpm run build -- --configuration production --base-href /apps/financial/',
    '/usr/share/nginx/html/apps/crm',
    '/usr/share/nginx/html/apps/financial'
)) {
    if (-not $dockerfile.Contains($marker)) { throw "Portal web embedded image missing marker: $marker" }
}
foreach ($marker in @('location /apps/crm/','location /apps/financial/')) {
    if (-not $nginx.Contains($marker)) { throw "Nginx embedded app route missing marker: $marker" }
}

Write-Host 'PORTAL_LOCAL_SUPERADMIN_APP_INTEGRATION_GATE_PASS'
