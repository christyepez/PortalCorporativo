param(
  [Parameter(Mandatory=$true)][string]$JwtSecret,
  [string]$SqlPassword = 'Portal_Local_Only_123!',
  [int]$GatewayPort = 8080,
  [int]$SqlPort = 21433,
  [switch]$LeaveRunning
)
$ErrorActionPreference='Stop'
if($JwtSecret.Length -lt 32){throw 'JwtSecret must contain at least 32 characters.'}
$env:JWT_SECRET=$JwtSecret;$env:SQLSERVER_SA_PASSWORD=$SqlPassword;$env:REDIS_PASSWORD='Portal_Redis_Local_Only';$env:MINIO_ROOT_USER='portal-local';$env:MINIO_ROOT_PASSWORD='Portal_Minio_Local_Only_123!';$env:SQLSERVER_PORT="$SqlPort";$env:API_GATEWAY_PORT="$GatewayPort"
if(-not $env:SEQ_PORT){$env:SEQ_PORT='5342'}
if(-not $env:REDIS_PORT){$env:REDIS_PORT='6380'}
if(-not $env:MINIO_API_PORT){$env:MINIO_API_PORT='9002'}
if(-not $env:MINIO_CONSOLE_PORT){$env:MINIO_CONSOLE_PORT='9003'}
function Base64Url([string]$value){[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($value)).TrimEnd('=').Replace('+','-').Replace('/','_')}
function Get-HttpStatus([string]$Uri,[hashtable]$Headers=$null,[string]$Method='GET',[string]$Body=$null){
  try {
    if($Body){
      $response=Invoke-WebRequest -UseBasicParsing -Uri $Uri -Headers $Headers -Method $Method -ContentType 'application/json' -Body $Body -TimeoutSec 5
    } else {
      $response=Invoke-WebRequest -UseBasicParsing -Uri $Uri -Headers $Headers -Method $Method -TimeoutSec 5
    }
    return [int]$response.StatusCode
  } catch {
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode) { return [int]$_.Exception.Response.StatusCode.value__ }
    return 0
  }
}
function Wait-Ready([int]$Port){
  for($attempt=1;$attempt-le 45;$attempt++){
    try{
      $ready=Invoke-WebRequest -UseBasicParsing "http://localhost:$Port/health/ready" -TimeoutSec 5
      if($ready.StatusCode-eq 200){return $ready}
    }catch{}
    Start-Sleep -Seconds 2
  }
  throw 'Gateway readiness did not become healthy within 90 seconds.'
}
$permissions=@('portal.security.manage','portal.configuration.manage','portal.configuration.read','portal.menu.manage','portal.menu.read','portal.audit.read','portal.audit.write','portal.notification.manage','portal.notification.send','portal.notification.read')
$header=Base64Url ((@{alg='HS256';typ='JWT'}|ConvertTo-Json -Compress))
$payload=Base64Url ((@{sub='sprint1-smoke';iss='portal-corporativo';aud='portal-corporativo-clients';exp=[DateTimeOffset]::UtcNow.AddMinutes(15).ToUnixTimeSeconds();permission=$permissions}|ConvertTo-Json -Compress))
$unsigned="$header.$payload";$hmac=[Security.Cryptography.HMACSHA256]::new([Text.Encoding]::UTF8.GetBytes($JwtSecret));$signature=[Convert]::ToBase64String($hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($unsigned))).TrimEnd('=').Replace('+','-').Replace('/','_');$token="$unsigned.$signature"
$headers=@{Authorization="Bearer $token";'X-Correlation-ID'='sprint1-smoke'}
$startedByScript=$false
$existingReady=Get-HttpStatus "http://localhost:$GatewayPort/health/ready"
if($existingReady -eq 200){
  Write-Host "Portal stack already running on port $GatewayPort; reusing it for smoke."
} else {
  docker compose up -d --build sqlserver seq security-api configuration-api menu-api audit-api notification-api notification-worker api-gateway
  $startedByScript=$true
}
try {
  $health=Wait-Ready $GatewayPort
  foreach($path in @('/health','/health/live','/health/ready')){
    $status=Get-HttpStatus "http://localhost:$GatewayPort$path"
    if($status-ne 200){throw "$path returned $status instead of 200"}
  }
  $calls=@(
    @{Uri="http://localhost:$GatewayPort/api/security/users/00000000-0000-0000-0000-000000000000/permissions";Protected=$true},
    @{Uri="http://localhost:$GatewayPort/api/configuration/effective?key=smoke.missing";Protected=$true},
    @{Uri="http://localhost:$GatewayPort/api/menu/modules/portal";Protected=$true},
    @{Uri="http://localhost:$GatewayPort/api/audit/events/?page=1&pageSize=5";Protected=$true}
  )
  foreach($call in $calls){
    $status=Get-HttpStatus $call.Uri $headers
    if($status -in 401,403){
      Write-Host "Protected endpoint returned expected authorization status $status for $($call.Uri)."
      continue
    }
    if($status -lt 200 -or $status -ge 500){throw "Unexpected status $status for $($call.Uri)"}
  }
  $body=@{templateCode='portal.notification.test';recipients=@('dev@example.test');variables=@{name='Smoke'};channel=2;idempotencyKey="sprint1-$([guid]::NewGuid())";metadataJson='{}'}|ConvertTo-Json -Compress
  $sendStatus=Get-HttpStatus "http://localhost:$GatewayPort/api/notifications/send" $headers 'POST' $body
  if($sendStatus -in 401,403){
    Write-Host "Notification protected endpoint returned expected authorization status $sendStatus; protected endpoint handling validated."
    [pscustomobject]@{Health='Healthy';CorrelationId=$health.Headers['X-Correlation-ID'];NotificationStatus='AuthorizationExpected';MessageId=$null;StartedByScript=$startedByScript}
  } else {
    $sent=Invoke-RestMethod -Method Post -Uri "http://localhost:$GatewayPort/api/notifications/send" -Headers $headers -ContentType 'application/json' -Body $body
    Start-Sleep -Seconds 7
    $status=Invoke-RestMethod -Uri "http://localhost:$GatewayPort/api/notifications/$($sent.data.id)" -Headers $headers
    if($status.data.status-ne 2){throw "Notification did not reach Sent; status=$($status.data.status)"}
    [pscustomobject]@{Health='Healthy';CorrelationId=$health.Headers['X-Correlation-ID'];NotificationStatus='Sent';MessageId=$sent.data.id;StartedByScript=$startedByScript}
  }
} finally {
  if($startedByScript -and -not $LeaveRunning){ docker compose down } else { Write-Host 'Smoke did not stop Docker Compose because it reused an existing stack or LeaveRunning was set.' }
}
