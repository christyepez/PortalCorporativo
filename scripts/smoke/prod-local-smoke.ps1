param(
    [string]$GatewayBaseUrl = "http://localhost:8080",
    [string]$WebBaseUrl = "http://localhost:4200",
    [string]$JwtIssuer = $(if ($env:JWT_ISSUER) { $env:JWT_ISSUER } else { "portal-corporativo" }),
    [string]$JwtAudience = $(if ($env:JWT_AUDIENCE) { $env:JWT_AUDIENCE } else { "portal-corporativo-clients" }),
    [string]$JwtSecret = $env:JWT_SECRET
)

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($JwtSecret)) { throw "JWT_SECRET must be set for PROD-local smoke." }

function ConvertTo-Base64Url([byte[]]$Bytes) {
    return [Convert]::ToBase64String($Bytes).TrimEnd('=').Replace('+','-').Replace('/','_')
}

function New-LocalJwt {
    param([string[]]$Permissions)
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $header = @{ alg = "HS256"; typ = "JWT" } | ConvertTo-Json -Compress
    $payload = @{
        sub = "portal-prod-local-smoke"
        iss = $JwtIssuer
        aud = $JwtAudience
        iat = $now
        nbf = $now
        exp = $now + 600
        permission = $Permissions
    } | ConvertTo-Json -Compress
    $headerPart = ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes($header))
    $payloadPart = ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes($payload))
    $unsigned = "$headerPart.$payloadPart"
    $hmac = [Security.Cryptography.HMACSHA256]::new([Text.Encoding]::UTF8.GetBytes($JwtSecret))
    try { $signature = ConvertTo-Base64Url ($hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($unsigned))) }
    finally { $hmac.Dispose() }
    return "$unsigned.$signature"
}

function Invoke-Check {
    param(
        [string]$Name,
        [string]$Uri,
        [int[]]$ExpectedStatus,
        [hashtable]$Headers = @{}
    )
    try {
        $response = Invoke-WebRequest -Uri $Uri -Headers $Headers -UseBasicParsing -TimeoutSec 20
        $status = [int]$response.StatusCode
    }
    catch {
        if ($_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode }
        else { throw }
    }
    if ($ExpectedStatus -notcontains $status) { throw "$Name failed. Expected $($ExpectedStatus -join ',') but got $status ($Uri)." }
    Write-Host "PASS $Name -> $status"
}

$base = $GatewayBaseUrl.TrimEnd('/')
$web = $WebBaseUrl.TrimEnd('/')
Invoke-Check "Portal web health" "$web/health" @(200)
Invoke-Check "Portal web root" "$web/" @(200)
Invoke-Check "Gateway ready" "$base/health/ready" @(200)
Invoke-Check "Security route protected" "$base/api/security/smoke" @(401)
Invoke-Check "Configuration route protected" "$base/api/configuration/smoke" @(401)
Invoke-Check "Menu route protected" "$base/api/menu/smoke" @(401)
Invoke-Check "Audit route protected" "$base/api/audit/smoke" @(401)
Invoke-Check "Notification route protected" "$base/api/notifications/smoke" @(401)
Invoke-Check "Catalog route protected" "$base/api/catalog/smoke" @(401)
Invoke-Check "Content route protected" "$base/api/content/smoke" @(401)
Invoke-Check "Integration route protected" "$base/api/integration/smoke" @(401)
Invoke-Check "Reporting route protected" "$base/api/reporting/smoke" @(401)
Invoke-Check "CRM ready through Gateway" "$base/api/crm/health/ready" @(200)
Invoke-Check "Financiero ready through Gateway" "$base/api/financial/health/ready" @(200)
Invoke-Check "HistoriasPaolin ready through Gateway" "$base/api/historiaspaolin/health/ready" @(200)
Invoke-Check "Talento Humano ready through Gateway" "$base/api/hr/health/ready" @(200)
Invoke-Check "CRM protected without token" "$web/api/crm/readiness" @(401)
Invoke-Check "Financiero protected without token" "$web/api/financial/accounts" @(401)
Invoke-Check "HistoriasPaolin protected without token" "$web/api/historiaspaolin/api/channels" @(401)
Invoke-Check "Talento Humano protected without token" "$web/api/hr/employees" @(401)

$token = New-LocalJwt @("financial.*", "historiaspaolin.channels.view", "hr.employees.view")
$auth = @{ Authorization = "Bearer $token"; "X-Correlation-ID" = "prod-local-smoke-$([Guid]::NewGuid())" }
Invoke-Check "CRM protected with Portal JWT" "$web/api/crm/readiness" @(200) $auth
Invoke-Check "Financiero protected with Portal JWT" "$web/api/financial/accounts" @(200) $auth
Invoke-Check "HistoriasPaolin protected with Portal JWT" "$web/api/historiaspaolin/api/channels" @(200) $auth
Invoke-Check "Talento Humano protected with Portal JWT" "$web/api/hr/employees" @(200) $auth

Write-Host "PROD_LOCAL_SMOKE_PASS"
