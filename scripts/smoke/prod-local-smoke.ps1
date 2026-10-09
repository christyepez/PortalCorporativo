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
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$registryPath = Join-Path $root 'frontend/config/consumer-registry.json'
$consumerRegistry = Get-Content $registryPath -Raw | ConvertFrom-Json
$consumers = @($consumerRegistry.consumers)

foreach ($consumer in $consumers) {
    Invoke-Check "$($consumer.name) ready through Gateway" "$base$($consumer.probePath)" @(200)
}
foreach ($consumer in $consumers) {
    Invoke-Check "$($consumer.name) protected without token" "$web$($consumer.protectedSmoke)" @(401)
}

$consumerPermissions = @($consumers | ForEach-Object { [string]$_.smokePermission } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
$token = New-LocalJwt $consumerPermissions
$auth = @{ Authorization = "Bearer $token"; "X-Correlation-ID" = "prod-local-smoke-$([Guid]::NewGuid())" }
foreach ($consumer in $consumers) {
    Invoke-Check "$($consumer.name) protected with Portal JWT" "$web$($consumer.protectedSmoke)" @(200) $auth
}

Write-Host "PROD_LOCAL_SMOKE_PASS"
