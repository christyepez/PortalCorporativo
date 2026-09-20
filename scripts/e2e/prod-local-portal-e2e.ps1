param(
    [string]$WebBaseUrl = "http://localhost:4200",
    [string]$JwtIssuer = $(if ($env:JWT_ISSUER) { $env:JWT_ISSUER } else { "portal-corporativo" }),
    [string]$JwtAudience = $(if ($env:JWT_AUDIENCE) { $env:JWT_AUDIENCE } else { "portal-corporativo-clients" }),
    [string]$JwtSecret = $env:JWT_SECRET
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
        [string]$Method = "GET"
    )
    try {
        $response = Invoke-WebRequest -Uri $Uri -Method $Method -Headers $Headers -UseBasicParsing -TimeoutSec 20
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
    "portal.configuration.read",
    "portal.menu.read",
    "portal.audit.read",
    "portal.notification.read",
    "portal.catalog.read",
    "portal.content.read",
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

Invoke-E2E "Menu through Portal Web proxy" "$web/api/menu/modules/portal" @(200) $auth | Out-Null
Invoke-E2E "Configuration through Portal Web proxy" "$web/api/configuration/scopes/0" @(200) $auth | Out-Null
Invoke-E2E "Audit through Portal Web proxy" "$web/api/audit/events/?page=1&pageSize=1" @(200) $auth | Out-Null
Invoke-E2E "Notification through Portal Web proxy" "$web/api/notifications/templates" @(200) $auth | Out-Null
Invoke-E2E "Catalog through Portal Web proxy" "$web/api/catalog/entries" @(200) $auth | Out-Null
Invoke-E2E "Content through Portal Web proxy" "$web/api/content/documents" @(200) $auth | Out-Null
Invoke-E2E "Reporting through Portal Web proxy" "$web/api/reporting/reports" @(200) $auth | Out-Null
Invoke-E2E "Integration through Portal Web proxy" "$web/api/integration/inbox/processed?tenantId=default&source=e2e&idempotencyKey=$correlationId" @(200) $auth | Out-Null

Invoke-E2E "CRM navigation/API through Portal Web" "$web/api/crm/readiness" @(200) $auth | Out-Null
Invoke-E2E "Financiero navigation/API through Portal Web" "$web/api/financial/accounts" @(200) $auth | Out-Null
Invoke-E2E "HistoriasPaolin navigation/API through Portal Web" "$web/api/historiaspaolin/api/channels" @(200) $auth | Out-Null
Invoke-E2E "Talento Humano navigation/API through Portal Web" "$web/api/hr/employees" @(200) $auth | Out-Null

$revocableToken = New-LocalJwt @("portal.menu.read")
$revocableAuth = @{ Authorization = "Bearer $revocableToken"; "X-Correlation-ID" = "$correlationId-revocation" }
Invoke-E2E "JWT valid before revocation" "$web/api/menu/modules/portal" @(200) $revocableAuth | Out-Null
Invoke-E2E "Revoke current JWT session" "$web/api/security/sessions/current/revoke" @(200) $revocableAuth "POST" | Out-Null
Invoke-E2E "Revoked JWT rejected by Gateway" "$web/api/menu/modules/portal" @(401) $revocableAuth | Out-Null

Write-Host "PORTAL_PROD_LOCAL_E2E_PASS"
