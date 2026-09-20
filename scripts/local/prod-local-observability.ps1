param(
    [string]$GatewayBaseUrl = "http://127.0.0.1:8080",
    [string]$SeqBaseUrl = "http://127.0.0.1:5341",
    [int]$Attempts = 6
)

$ErrorActionPreference = 'Stop'
$correlationId = "portal-observability-$([Guid]::NewGuid().ToString('N'))"
$headers = @{ 'X-Correlation-ID' = $correlationId }

$response = Invoke-WebRequest "$($GatewayBaseUrl.TrimEnd('/'))/health/ready" -Headers $headers -UseBasicParsing -TimeoutSec 10

if ([int]$response.StatusCode -ne 200) {
    throw "Gateway readiness expected 200 but returned $($response.StatusCode)."
}

$echo = [string]$response.Headers['X-Correlation-ID']
if ($echo -ne $correlationId) {
    throw "Gateway did not echo the expected correlation id."
}
Write-Host "PASS Gateway correlation echo -> $correlationId"

$filter = [uri]::EscapeDataString("CorrelationId = '$correlationId'")
$eventsUrl = "$($SeqBaseUrl.TrimEnd('/'))/api/events?filter=$filter&count=10"
$events = @()

for ($attempt = 1; $attempt -le [Math]::Max(1, $Attempts); $attempt++) {
    $result = Invoke-RestMethod $eventsUrl -Method Get -TimeoutSec 10
    if ($null -ne $result.value) {
        $events = @($result.value)
    } else {
        $events = @($result)
    }
    if ($events.Count -gt 0) { break }
    Start-Sleep -Seconds 1
}

if ($events.Count -eq 0) {
    throw "Seq did not receive the Gateway event for correlation id $correlationId."
}

$matched = $events | Where-Object {
    $properties = @{}
    foreach ($property in @($_.Properties)) {
        if ($null -eq $property) { continue }
        $name = [string]$property.Name
        if ([string]::IsNullOrWhiteSpace($name)) { continue }
        $properties[$name] = $property.Value
    }

    $statusCode = 0
    if ($properties.ContainsKey('StatusCode')) {
        [void][int]::TryParse([string]$properties['StatusCode'], [ref]$statusCode)
    }

    $properties.ContainsKey('CorrelationId') -and
    $properties.ContainsKey('Service') -and
    $properties.ContainsKey('Environment') -and
    $properties['CorrelationId'] -eq $correlationId -and
    $properties['Service'] -eq 'Portal.ApiGateway' -and
    $properties['Environment'] -eq 'Production' -and
    $statusCode -eq 200
} | Select-Object -First 1

if (-not $matched) {
    throw "Seq event exists but is missing the required structured observability properties."
}

Write-Host "PASS Seq structured event ingestion -> Portal.ApiGateway / Production / 200"
Write-Host "PORTAL_PROD_LOCAL_OBSERVABILITY_PASS"
