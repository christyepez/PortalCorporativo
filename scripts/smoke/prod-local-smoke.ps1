param(
    [string]$GatewayBaseUrl = "http://localhost:8080",
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
Invoke-Check "Gateway ready" "$base/health/ready" @(200)
Invoke-Check "CRM ready through Gateway" "$base/api/crm/health/ready" @(200)
Invoke-Check "Financiero ready through Gateway" "$base/api/financial/health/ready" @(200)
Invoke-Check "CRM protected without token" "$base/api/crm/readiness" @(401)
Invoke-Check "Financiero protected without token" "$base/api/financial/accounts" @(401)

$token = New-LocalJwt @("financial.*")
$auth = @{ Authorization = "Bearer $token"; "X-Correlation-ID" = "prod-local-smoke-$([Guid]::NewGuid())" }
Invoke-Check "CRM protected with Portal JWT" "$base/api/crm/readiness" @(200) $auth
Invoke-Check "Financiero protected with Portal JWT" "$base/api/financial/accounts" @(200) $auth

Write-Host "PROD_LOCAL_SMOKE_PASS"
