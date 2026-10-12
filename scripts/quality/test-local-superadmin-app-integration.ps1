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
    'PortalLocalAdmin:Email',
    'PortalLocalAdmin:Password',
    'LocalAdminLoginRequest',
    'CredentialEquals',
    'Results.Unauthorized()',
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
foreach ($marker in @('AddPortalPermissionAuthorization()','portal_local_session','Headers.Authorization','Bearer {localSessionToken}','UseAuthentication()','MapReverseProxy()')) {
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
foreach ($marker in @('PortalLocalAdmin__Email:','PortalLocalAdmin__Password:')) {
    if (-not $localCompose.Contains($marker)) { throw "PROD-local login configuration missing marker: $marker" }
}

$corePortalPermissions = @('portal.catalog.manage','portal.catalog.read','portal.content.manage','portal.content.read','portal.reporting.read','portal.integration.manage','portal.integration.read')
foreach ($permission in $corePortalPermissions) {
    if (-not $seedCatalog.Contains('"' + $permission + '"')) {
        throw "Security seed catalog missing core Portal permission: $permission"
    }
    Write-Host "PASS governed core Portal permission $permission"
}

$consumerPermissions = @('crm.*','financial.*','hr.employees.view','hr.employees.manage','historiaspaolin.channels.view','historiaspaolin.episodes.view')
foreach ($permission in $consumerPermissions) {
    if (-not $seedCatalog.Contains('"' + $permission + '"')) {
        throw "Security seed catalog missing consumer permission: $permission"
    }
    Write-Host "PASS governed consumer permission $permission"
}
foreach ($marker in @('BootstrapGovernedSecurityAsync','SecuritySeedCatalog.Resources','SecuritySeedCatalog.Permissions','RolePermissions.Add')) {
    if (-not $initializer.Contains($marker)) { throw "Security initializer missing governed bootstrap marker: $marker" }
}

if ($registry.version -ne 3) { throw 'Consumer registry must use governed application surface version 3.' }
foreach ($consumer in $registry.consumers) {
    if ([string]::IsNullOrWhiteSpace([string]$consumer.moduleCode)) { throw "Consumer $($consumer.code) missing moduleCode." }
    if ([string]::IsNullOrWhiteSpace([string]$consumer.accessPermission)) { throw "Consumer $($consumer.code) missing accessPermission." }
    if ([string]::IsNullOrWhiteSpace([string]$consumer.protectedSmoke)) { throw "Consumer $($consumer.code) missing protected surface." }
    if (@($consumer.menuItems).Count -eq 0) { throw "Consumer $($consumer.code) missing application menu." }
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
    'createLocalSuperAdminSession(email: string, password: string)',
    'loadApplicationSurface(path: string)',
    'workspaceProbeState',
    'refreshWorkspaceData()',
    'initializeLocalPortal()',
    'localAdminSession',
    'probe(path: string)',
    'clearLocalSuperAdminSession()',
    'consumer.webPath',
    'updateWorkspaceUrl(application: ApplicationCard, item?: ApplicationMenuItem)',
    'visibleApplicationMenu(application: ApplicationCard)',
    'publishPortalShellContext(application: ApplicationCard)',
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
foreach ($marker in @('Acceso seguro','type="password"','autocomplete="username"','autocomplete="current-password"','class="admin-grid"')) {
    if (-not $template.Contains($marker)) { throw "Portal login/grid UI missing marker: $marker" }
}
if ($component.Contains('sessionTokenInput')) {
    throw 'Portal component must not retain the obsolete manual JWT input.'
}
if (($component + $apiService) -match 'localStorage|sessionStorage') {
    throw 'Local administrative tokens must remain memory-only.'
}
if (-not $template.Contains('workspace-app-menu') -or -not $template.Contains('Vista funcional integrada al Portal') -or -not $template.Contains('Abrir en Portal')) {
    throw 'Application workspace must expose embedded navigation and functional Portal-native views.'
}
foreach ($marker in @('SuperAdmin autorizado','localAdminSession.displayName','localAdminSession.role')) {
    if (-not $template.Contains($marker)) { throw "Portal shell missing SuperAdmin governance marker: $marker" }
}
if (-not $component.Contains("'Vista integrada Portal'")) {
    throw 'Portal component must identify native applications as integrated Portal views.'
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
    'pnpm exec ng build --base-href /apps/crm/',
    'pnpm exec ng build --configuration production --base-href /apps/financial/',
    '/usr/share/nginx/html/apps/crm',
    '/usr/share/nginx/html/apps/financial'
)) {
    if (-not $dockerfile.Contains($marker)) { throw "Portal web embedded image missing marker: $marker" }
}
foreach ($marker in @('location /apps/crm/','location /apps/financial/')) {
    if (-not $nginx.Contains($marker)) { throw "Nginx embedded app route missing marker: $marker" }
}

Write-Host 'PORTAL_LOCAL_SUPERADMIN_APP_INTEGRATION_GATE_PASS'
