param(
  [Parameter(Mandatory=$true)][string]$JwtSecret,
  [string]$SqlPassword = 'Portal_Local_Only_123!',
  [int]$GatewayPort = 8080,
  [int]$SqlPort = 21433
)
$ErrorActionPreference='Stop'
if($JwtSecret.Length -lt 32){throw 'JwtSecret must contain at least 32 characters.'}
$env:JWT_SECRET=$JwtSecret;$env:SQLSERVER_SA_PASSWORD=$SqlPassword;$env:REDIS_PASSWORD='Portal_Redis_Local_Only';$env:MINIO_ROOT_USER='portal-local';$env:MINIO_ROOT_PASSWORD='Portal_Minio_Local_Only_123!';$env:SQLSERVER_PORT="$SqlPort";$env:API_GATEWAY_PORT="$GatewayPort"
function Base64Url([string]$value){[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($value)).TrimEnd('=').Replace('+','-').Replace('/','_')}
$permissions=@('portal.security.manage','portal.configuration.manage','portal.configuration.read','portal.menu.manage','portal.menu.read','portal.audit.read','portal.audit.write','portal.notification.manage','portal.notification.send','portal.notification.read')
$header=Base64Url ((@{alg='HS256';typ='JWT'}|ConvertTo-Json -Compress))
$payload=Base64Url ((@{sub='sprint1-smoke';iss='portal-corporativo';aud='portal-corporativo-clients';exp=[DateTimeOffset]::UtcNow.AddMinutes(15).ToUnixTimeSeconds();permission=$permissions}|ConvertTo-Json -Compress))
$unsigned="$header.$payload";$hmac=[Security.Cryptography.HMACSHA256]::new([Text.Encoding]::UTF8.GetBytes($JwtSecret));$signature=[Convert]::ToBase64String($hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($unsigned))).TrimEnd('=').Replace('+','-').Replace('/','_');$token="$unsigned.$signature"
$headers=@{Authorization="Bearer $token";'X-Correlation-ID'='sprint1-smoke'}
docker compose up -d --build sqlserver seq security-api configuration-api menu-api audit-api notification-api notification-worker api-gateway
try {
  $health=$null;for($attempt=1;$attempt-le 30;$attempt++){try{$health=Invoke-WebRequest -UseBasicParsing "http://localhost:$GatewayPort/health/ready";if($health.StatusCode-eq 200){break}}catch{};Start-Sleep -Seconds 2}
  if($null-eq $health-or $health.StatusCode-ne 200){throw 'Gateway readiness did not become healthy within 60 seconds.'}
  $calls=@(
    @{Method='GET';Uri="http://localhost:$GatewayPort/api/security/users/00000000-0000-0000-0000-000000000000"},
    @{Method='GET';Uri="http://localhost:$GatewayPort/api/configuration/effective?key=smoke.missing"},
    @{Method='GET';Uri="http://localhost:$GatewayPort/api/menu/modules/portal"},
    @{Method='GET';Uri="http://localhost:$GatewayPort/api/audit/events/?page=1&pageSize=5"}
  );foreach($call in $calls){try{$r=Invoke-WebRequest -UseBasicParsing -Method $call.Method -Headers $headers $call.Uri}catch{$r=$_.Exception.Response};if($r.StatusCode.value__ -in 401,403){throw "Authorization failed for $($call.Uri)"}}
  $body=@{templateCode='portal.notification.test';recipients=@('dev@example.test');variables=@{name='Smoke'};channel=2;idempotencyKey="sprint1-$([guid]::NewGuid())";metadataJson='{}'}|ConvertTo-Json -Compress
  $sent=Invoke-RestMethod -Method Post -Uri "http://localhost:$GatewayPort/api/notifications/send" -Headers $headers -ContentType 'application/json' -Body $body
  Start-Sleep -Seconds 7
  $status=Invoke-RestMethod -Uri "http://localhost:$GatewayPort/api/notifications/$($sent.data.id)" -Headers $headers
  if($status.data.status-ne 2){throw "Notification did not reach Sent; status=$($status.data.status)"}
  [pscustomobject]@{Health='Healthy';CorrelationId=$health.Headers['X-Correlation-ID'];NotificationStatus='Sent';MessageId=$sent.data.id}
} finally { docker compose down }
