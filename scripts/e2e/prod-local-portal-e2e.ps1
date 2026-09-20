param(
    [string]$WebBaseUrl = "http://localhost:4200",
    [string]$JwtIssuer = $(if ($env:JWT_ISSUER) { $env:JWT_ISSUER } else { "portal-corporativo" }),
    [string]$JwtAudience = $(if ($env:JWT_AUDIENCE) { $env:JWT_AUDIENCE } else { "portal-corporativo-clients" }),
    [string]$JwtSecret = $env:JWT_SECRET,
    [switch]$ExpectPersistedLifecycleData
)

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($JwtSecret)) { throw "JWT_SECRET must be set for PROD-local E2E." }

function ConvertTo-Base64Url([byte[]]$Bytes) {
    [Convert]::ToBase64String($Bytes).TrimEnd('=').Replace('+','-').Replace('/','_')
}

function New-LocalJwt {
    param([string[]]$Permissions)
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $header = @{ alg = "HS256"; typ = "JWT" } | ConvertTo-Json -Compress
    $payload = @{
        sub = "portal-prod-local-e2e"
        iss = $JwtIssuer
        aud = $JwtAudience
        iat = $now
        nbf = $now
        exp = $now + 600
        jti = [Guid]::NewGuid().ToString("N")
        permission = $Permissions
    } | ConvertTo-Json -Compress

    $headerPart = ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes($header))
    $payloadPart = ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes($payload))
    $unsigned = "$headerPart.$payloadPart"
    $hmac = [Security.Cryptography.HMACSHA256]::new([Text.Encoding]::UTF8.GetBytes($JwtSecret))
    try { $signature = ConvertTo-Base64Url ($hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($unsigned))) }
    finally { $hmac.Dispose() }
    "$unsigned.$signature"
}

function Invoke-E2E {
    param(
        [string]$Name,
        [string]$Uri,
        [int[]]$ExpectedStatus = @(200),
        [hashtable]$Headers = @{},
        [string]$Method = "GET",
        [string]$Body = "",
        [string]$ContentType = "application/json"
    )
    try {
        $request = @{
            Uri = $Uri
            Method = $Method
            Headers = $Headers
            UseBasicParsing = $true
            TimeoutSec = 20
        }
        if (-not [string]::IsNullOrWhiteSpace($Body)) {
            $request.Body = $Body
            $request.ContentType = $ContentType
        }
        $response = Invoke-WebRequest @request
        $status = [int]$response.StatusCode
        $body = [string]$response.Content
        $responseHeaders = $response.Headers
    }
    catch {
        if ($_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
            $body = ""
            $responseHeaders = $_.Exception.Response.Headers
        } else { throw }
    }

    if ($ExpectedStatus -notcontains $status) {
        throw "$Name failed. Expected $($ExpectedStatus -join ',') but got $status ($Uri)."
    }
    Write-Host "PASS $Name -> $status"
    [pscustomobject]@{ Status=$status; Body=$body; Headers=$responseHeaders }
}

$web = $WebBaseUrl.TrimEnd('/')
$shell = Invoke-E2E "Shell root" "$web/"

$scriptMatches = [regex]::Matches($shell.Body, '<script[^>]+src="([^"]+)"')
if ($scriptMatches.Count -eq 0) { throw "Angular shell script bundles were not found in index.html." }
$bundleText = ""
foreach ($match in $scriptMatches) {
    $src = $match.Groups[1].Value
    $bundleUri = if ($src.StartsWith("http")) { $src } else { "$web/$($src.TrimStart('/'))" }
    $bundle = Invoke-E2E "Angular bundle $src" $bundleUri @(200)
    $bundleText += $bundle.Body
}
foreach ($marker in @("Portal Corporativo","CRM","Financiero","HistoriasPaolin","Talento Humano")) {
    if ($bundleText -notmatch [regex]::Escape($marker)) { throw "Compiled shell marker missing: $marker" }
}
Write-Host "PASS Compiled Angular shell module markers"

$readPermissions = @(
    "portal.security.manage",
    "portal.configuration.read",
    "portal.menu.read",
    "portal.audit.read",
    "portal.audit.write",
    "portal.notification.read",
    "portal.catalog.read",
    "portal.catalog.manage",
    "portal.content.read",
    "portal.content.manage",
    "portal.reporting.read",
    "portal.integration.read",
    "financial.*",
    "historiaspaolin.channels.view",
    "hr.employees.view"
)
$readToken = New-LocalJwt $readPermissions
$correlationId = "prod-local-e2e-$([Guid]::NewGuid())"
$auth = @{ Authorization = "Bearer $readToken"; "X-Correlation-ID" = $correlationId }

$insufficientToken = New-LocalJwt @("portal.menu.read")
$insufficient = @{ Authorization = "Bearer $insufficientToken"; "X-Correlation-ID" = "$correlationId-denied" }
Invoke-E2E "Permission enforcement denies Catalog without catalog.read" "$web/api/catalog/entries" @(403) $insufficient | Out-Null

Invoke-E2E "Security users list through Portal Web proxy" "$web/api/security/users" @(200) $auth | Out-Null
Invoke-E2E "Security roles list through Portal Web proxy" "$web/api/security/roles" @(200) $auth | Out-Null
Invoke-E2E "Security permissions list through Portal Web proxy" "$web/api/security/permissions" @(200) $auth | Out-Null
Invoke-E2E "Security resources list through Portal Web proxy" "$web/api/security/resources" @(200) $auth | Out-Null
Invoke-E2E "Menu through Portal Web proxy" "$web/api/menu/modules/portal" @(200) $auth | Out-Null
Invoke-E2E "Configuration through Portal Web proxy" "$web/api/configuration/scopes/0" @(200) $auth | Out-Null
Invoke-E2E "Audit through Portal Web proxy" "$web/api/audit/events/?page=1&pageSize=1" @(200) $auth | Out-Null

$auditCorrelationId = "$correlationId-audit"
$auditBody = @{
    actorId = "portal-prod-local-e2e"
    tenantId = "default"
    resource = "portal.e2e"
    action = "validate"
    entityName = "PortalRuntime"
    entityId = $correlationId
    beforeJson = $null
    afterJson = '{"status":"validated"}'
    metadataJson = '{"source":"prod-local-e2e"}'
    correlationId = $auditCorrelationId
    causationId = $correlationId
    requestId = $correlationId
    ipAddress = "127.0.0.1"
    userAgent = "portal-prod-local-e2e"
    severity = 1
} | ConvertTo-Json -Compress
$auditCreate = Invoke-E2E "Create Audit event through Portal Web" "$web/api/audit/events/" @(201) $auth "POST" $auditBody
$auditCreated = $auditCreate.Body | ConvertFrom-Json
if (-not $auditCreated.data.id) { throw "Audit create response did not return id." }

$auditSearch = Invoke-E2E "Search Audit by correlation id" "$web/api/audit/events/?correlationId=$([uri]::EscapeDataString($auditCorrelationId))&page=1&pageSize=10" @(200) $auth
$auditSearchPayload = $auditSearch.Body | ConvertFrom-Json
if (-not ($auditSearchPayload.data.items | Where-Object { $_.correlationId -eq $auditCorrelationId })) {
    throw "Audit event was not found by correlation id."
}

$auditSummary = Invoke-E2E "Read Audit operational summary" "$web/api/audit/events/summary?tenantId=default&hours=24" @(200) $auth
$auditSummaryPayload = $auditSummary.Body | ConvertFrom-Json
if ([long]$auditSummaryPayload.data.total -lt 1 -or [long]$auditSummaryPayload.data.warningOrHigher -lt 1) {
    throw "Audit operational summary did not include the E2E event."
}

Invoke-E2E "Notification through Portal Web proxy" "$web/api/notifications/templates" @(200) $auth | Out-Null
$catalogList = Invoke-E2E "Catalog through Portal Web proxy" "$web/api/catalog/entries" @(200) $auth
$contentList = Invoke-E2E "Content through Portal Web proxy" "$web/api/content/documents" @(200) $auth
if ($ExpectPersistedLifecycleData) {
    $persistedCatalog = @($catalogList.Body | ConvertFrom-Json | Where-Object { $_.catalog -eq "portal-e2e" })
    $persistedContent = @($contentList.Body | ConvertFrom-Json | Where-Object { $_.moduleCode -eq "PORTAL" })
    if ($persistedCatalog.Count -lt 1) { throw "Persisted Catalog lifecycle data was not found after restart." }
    if ($persistedContent.Count -lt 1) { throw "Persisted Content lifecycle data was not found after restart." }
    Write-Host "PASS Catalog lifecycle data persisted across restart -> $($persistedCatalog.Count) row(s)"
    Write-Host "PASS Content lifecycle data persisted across restart -> $($persistedContent.Count) row(s)"
}
Invoke-E2E "Reporting through Portal Web proxy" "$web/api/reporting/reports" @(200) $auth | Out-Null
Invoke-E2E "Integration through Portal Web proxy" "$web/api/integration/inbox/processed?tenantId=default&source=e2e&idempotencyKey=$correlationId" @(200) $auth | Out-Null

Invoke-E2E "CRM navigation/API through Portal Web" "$web/api/crm/readiness" @(200) $auth | Out-Null
Invoke-E2E "Financiero navigation/API through Portal Web" "$web/api/financial/accounts" @(200) $auth | Out-Null
Invoke-E2E "HistoriasPaolin navigation/API through Portal Web" "$web/api/historiaspaolin/api/channels" @(200) $auth | Out-Null
Invoke-E2E "Talento Humano navigation/API through Portal Web" "$web/api/hr/employees" @(200) $auth | Out-Null

$catalogCode = "e2e-$([Guid]::NewGuid().ToString('N').Substring(0,12))"
$catalogCreateBody = @{
    catalog = "portal-e2e"
    code = $catalogCode
    name = "Portal E2E Entry"
    description = "Runtime lifecycle validation"
    sortOrder = 10
} | ConvertTo-Json -Compress
$catalogCreate = Invoke-E2E "Create Catalog entry through Portal Web" "$web/api/catalog/entries" @(201) $auth "POST" $catalogCreateBody
$catalogEntry = $catalogCreate.Body | ConvertFrom-Json
if (-not $catalogEntry.id) { throw "Catalog create response did not return id." }
Invoke-E2E "Read Catalog entry through Portal Web" "$web/api/catalog/entries/$($catalogEntry.id)" @(200) $auth | Out-Null
$catalogUpdateBody = @{
    name = "Portal E2E Entry Updated"
    description = "Runtime lifecycle validation completed"
    isActive = $false
    sortOrder = 20
} | ConvertTo-Json -Compress
$catalogUpdate = Invoke-E2E "Update Catalog entry through Portal Web" "$web/api/catalog/entries/$($catalogEntry.id)" @(200) $auth "PUT" $catalogUpdateBody
if (($catalogUpdate.Body | ConvertFrom-Json).isActive -ne $false) { throw "Catalog update did not persist inactive state." }

$contentBytes = [Text.Encoding]::UTF8.GetBytes("Portal local E2E content $correlationId")
$contentCreateBody = @{
    moduleCode = "PORTAL"
    fileName = "$catalogCode.txt"
    contentType = "text/plain"
    content = [Convert]::ToBase64String($contentBytes)
} | ConvertTo-Json -Compress
$contentCreate = Invoke-E2E "Create Content document through Portal Web" "$web/api/content/documents" @(201) $auth "POST" $contentCreateBody
$contentDocument = $contentCreate.Body | ConvertFrom-Json
if (-not $contentDocument.id) { throw "Content create response did not return id." }
$contentDownload = Invoke-E2E "Download Content document through Portal Web" "$web/api/content/documents/$($contentDocument.id)/download" @(200) $auth
if ($contentDownload.Body -notmatch [regex]::Escape($correlationId)) { throw "Downloaded content does not match uploaded content." }
Invoke-E2E "Deactivate Content document through Portal Web" "$web/api/content/documents/$($contentDocument.id)/deactivate" @(204) $auth "POST" | Out-Null
Invoke-E2E "Inactive Content download is hidden" "$web/api/content/documents/$($contentDocument.id)/download" @(404) $auth | Out-Null

$reportList = Invoke-E2E "List Reporting definitions through Portal Web" "$web/api/reporting/reports" @(200) $auth
$reportDefinitions = $reportList.Body | ConvertFrom-Json
if (-not ($reportDefinitions | Where-Object { $_.key -eq "portal-overview" })) { throw "portal-overview report definition is missing." }
$reportBody = @{ parameters = @{} } | ConvertTo-Json -Compress
$reportExecution = Invoke-E2E "Execute Portal Overview report through Portal Web" "$web/api/reporting/reports/portal-overview/execute" @(200) $auth "POST" $reportBody
$report = $reportExecution.Body | ConvertFrom-Json
if ($report.key -ne "portal-overview" -or -not $report.rows) { throw "Portal Overview report execution payload is invalid." }
$activityBody = @{ parameters = @{ moduleCode = "PORTAL" } } | ConvertTo-Json -Compress
Invoke-E2E "Execute Module Activity report through Portal Web" "$web/api/reporting/reports/module-activity/execute" @(200) $auth "POST" $activityBody | Out-Null

$revocableToken = New-LocalJwt @("portal.menu.read")
$revocableAuth = @{ Authorization = "Bearer $revocableToken"; "X-Correlation-ID" = "$correlationId-revocation" }
Invoke-E2E "JWT valid before revocation" "$web/api/menu/modules/portal" @(200) $revocableAuth | Out-Null
Invoke-E2E "Revoke current JWT session" "$web/api/security/sessions/current/revoke" @(200) $revocableAuth "POST" | Out-Null
Invoke-E2E "Revoked JWT rejected by Gateway" "$web/api/menu/modules/portal" @(401) $revocableAuth | Out-Null

Write-Host "PORTAL_PROD_LOCAL_E2E_PASS"
