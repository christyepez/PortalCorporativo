$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

function Assert-Contains {
    param([string]$Text,[string]$Marker,[string]$Message)
    if (-not $Text.Contains($Marker)) { throw $Message }
    Write-Host "PASS $Message"
}

$session = Get-Content (Join-Path $root 'backend/security-api/src/Portal.Security.Api/LocalAdminSessionEndpoints.cs') -Raw
$auth = Get-Content (Join-Path $root 'backend/building-blocks/src/Portal.BuildingBlocks/PortalAuthentication.cs') -Raw
$gateway = Get-Content (Join-Path $root 'backend/api-gateway/src/Portal.ApiGateway/appsettings.json') -Raw
$compose = Get-Content (Join-Path $root 'docker-compose.prod-local.yml') -Raw
$dockerfile = Get-Content (Join-Path $root 'frontend/Dockerfile.prod') -Raw
$nginx = Get-Content (Join-Path $root 'frontend/nginx.prod.conf') -Raw
$template = Get-Content (Join-Path $root 'frontend/src/app/app.component.html') -Raw
$component = Get-Content (Join-Path $root 'frontend/src/app/app.component.ts') -Raw
$api = Get-Content (Join-Path $root 'frontend/src/app/portal-api.service.ts') -Raw
$registry = Get-Content (Join-Path $root 'frontend/config/consumer-registry.json') -Raw | ConvertFrom-Json

foreach ($marker in @(
    'PortalLocalAdmin:Enabled',
    'PortalLocalAdmin:Email',
    'PortalLocalAdmin:Password',
    'LocalAdminLoginRequest',
    'CredentialEquals',
    'HttpOnly = true',
    'SameSite = SameSiteMode.Strict',
    'EnsureLocalSuperAdminAsync',
    'UserRole.Create',
    'Permissions.AsNoTracking()',
    'MaxAge = TimeSpan.FromMinutes(10)',
    '/api/security/local-session/logout'
)) {
    Assert-Contains $session $marker "Local SuperAdmin contract contains $marker"
}
if ($session -match '(?i)(secret|password)s*=s*"[^"]+"') { throw 'Local SuperAdmin endpoint must not embed secrets.' }

Assert-Contains $auth 'portal_local_session' 'Portal JWT authentication accepts the local HttpOnly session cookie'
Assert-Contains $gateway '"security-local-session"' 'Gateway exposes the local session bootstrap without the protected catch-all'
Assert-Contains $gateway '"AuthorizationPolicy": "crm.*"' 'CRM route is governed by crm wildcard permission'
Assert-Contains $gateway '"AuthorizationPolicy": "financial.*"' 'Financiero route is governed by financial wildcard permission'
Assert-Contains $gateway '"AuthorizationPolicy": "hr.employees.view"' 'HR route is governed by HR permission'
Assert-Contains $gateway '"AuthorizationPolicy": "historiaspaolin.channels.view"' 'Historias route is governed by Historias permission'

Assert-Contains $compose 'PortalLocalAdmin__Enabled: "true"' 'PROD-local explicitly enables the local SuperAdmin login'
Assert-Contains $compose 'PortalLocalAdmin__Email:' 'PROD-local configures local admin email'
Assert-Contains $compose 'PortalLocalAdmin__Password:' 'PROD-local configures local admin password'
Assert-Contains $compose 'additional_contexts:' 'Portal web build declares external source contexts'
Assert-Contains $compose 'crm_source:' 'Portal web build includes CRM source'
Assert-Contains $compose 'financial_source:' 'Portal web build includes Financiero source'

foreach ($marker in @(
    'COPY --from=crm_source',
    'COPY --from=financial_source',
    '--base-href /apps/crm/',
    '--base-href /apps/financial/',
    '/usr/share/nginx/html/apps/crm',
    '/usr/share/nginx/html/apps/financial'
)) {
    Assert-Contains $dockerfile $marker "Portal web image contains $marker"
}
Assert-Contains $nginx 'location /apps/crm/' 'Nginx serves embedded CRM'
Assert-Contains $nginx 'location /apps/financial/' 'Nginx serves embedded Financiero'

if ([int]$registry.version -ne 3) { throw 'Consumer registry must use schema version 3.' }
$embedded = @($registry.consumers | Where-Object { $_.uiMode -eq 'iframe' })
if ($embedded.Count -ne 2) { throw 'Exactly two consumers must be web embedded in the current baseline.' }
if (@($embedded.code | Sort-Object) -join ',' -ne 'CRM,FINANCIAL') { throw 'Only CRM and FINANCIAL may advertise embedded UI in this baseline.' }
foreach ($consumer in $embedded) {
    if (-not ([string]$consumer.webPath).StartsWith('/apps/')) { throw "$($consumer.code) webPath must remain under /apps." }
}
if (@($registry.consumers | Where-Object { $_.uiMode -eq 'native' -and $_.webPath }).Count -ne 0) { throw 'Native API consumers must not advertise webPath.' }

Assert-Contains $api 'createLocalSuperAdminSession(email: string, password: string)' 'Portal API client requests credentialed local SuperAdmin session'
Assert-Contains $api 'clearLocalSuperAdminSession()' 'Portal API client revokes local SuperAdmin session'
Assert-Contains $component 'updateWorkspaceUrl(application: ApplicationCard, item?: ApplicationMenuItem)' 'Embedded app URLs are governed by application menu routes'
Assert-Contains $component 'publishPortalShellContext(application: ApplicationCard)' 'Portal publishes shared shell context to embedded apps'
Assert-Contains $template 'workspace-app-menu' 'Portal renders an application-owned submenu in the embedded workspace'
Assert-Contains $template 'Acceso seguro' 'Portal exposes a credentialed login screen'
Assert-Contains $template 'type="password"' 'Portal login collects password securely'
Assert-Contains $template 'class="admin-grid"' 'Portal administrative records render in grids'
if ($template -match 'Pega un token local|JWT local efímero') { throw 'Manual JWT input must not return to the Security UI.' }
if ($api -match 'localStorage|sessionStorage') { throw 'Browser credentials must not be persisted.' }

Write-Host 'PORTAL_LOCAL_SUPERADMIN_EMBEDDED_APPS_GATE_PASS'
