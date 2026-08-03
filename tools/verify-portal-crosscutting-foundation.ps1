param(
  [string]$Root = (Resolve-Path "$PSScriptRoot\..").Path
)

$ErrorActionPreference = 'Stop'

$files = @{
  AuditProgram = 'backend/audit-api/src/Portal.Audit.Api/Program.cs'
  ConfigurationProgram = 'backend/configuration-api/src/Portal.Configuration.Api/Program.cs'
  NotificationProgram = 'backend/notification-api/src/Portal.Notification.Api/Program.cs'
  NotificationWorker = 'backend/workers/src/Portal.Notification.Worker/NotificationBackgroundWorker.cs'
  IntegrationWorker = 'backend/workers/src/Portal.Integration.Worker/Program.cs'
  Foundation = 'backend/building-blocks/src/Portal.BuildingBlocks/FoundationExtensions.cs'
  Correlation = 'backend/building-blocks/src/Portal.BuildingBlocks/CorrelationIdMiddleware.cs'
  NotificationPersistence = 'backend/notification-api/src/Portal.Notification.Infrastructure/NotificationPersistence.cs'
}

foreach ($entry in $files.GetEnumerator()) {
  $path = Join-Path $Root $entry.Value
  if (-not (Test-Path $path)) { throw "Required crosscutting foundation file missing: $($entry.Value)" }
}

$auditText = Get-Content (Join-Path $Root $files.AuditProgram) -Raw
$configurationText = Get-Content (Join-Path $Root $files.ConfigurationProgram) -Raw
$notificationText = Get-Content (Join-Path $Root $files.NotificationProgram) -Raw
$notificationWorkerText = Get-Content (Join-Path $Root $files.NotificationWorker) -Raw
$integrationWorkerText = Get-Content (Join-Path $Root $files.IntegrationWorker) -Raw
$foundationText = Get-Content (Join-Path $Root $files.Foundation) -Raw
$correlationText = Get-Content (Join-Path $Root $files.Correlation) -Raw
$notificationPersistenceText = Get-Content (Join-Path $Root $files.NotificationPersistence) -Raw

if ($auditText -notmatch 'AddAuditFoundation') { throw 'Audit foundation registration not found.' }
if ($configurationText -notmatch 'AddConfigurationFoundation') { throw 'Configuration foundation registration not found.' }
if ($notificationText -notmatch 'AddNotificationFoundation') { throw 'Notification foundation registration not found.' }
if ($notificationWorkerText -notmatch 'NotificationBackgroundWorker') { throw 'Notification worker not found.' }
if ($integrationWorkerText -notmatch 'Integration') { throw 'Integration worker not found.' }
if ($foundationText -notmatch 'WriteTo\.Seq' -or $foundationText -notmatch 'UseMiddleware<CorrelationIdMiddleware>') { throw 'Seq logging or correlation middleware not found.' }
if ($correlationText -notmatch 'X-Correlation-ID') { throw 'Correlation header foundation not found.' }
if ($notificationPersistenceText -notmatch 'DevelopmentNotificationProvider' -or $notificationPersistenceText -match 'SmtpClient|SendGrid|Twilio|Firebase|Mailgun|AmazonSES') { throw 'Notification provider baseline is not development-only.' }

Write-Host 'Portal crosscutting foundation verification OK: Audit, Configuration, Notification, workers, correlation and Seq logging are present; real providers are not configured.'
