# Portal Notification Provider Placeholder Evidence

## Evidence

- Existing provider classes are development-only.
- Provider names are `InternalDev`, `EmailDev` and `LogDev`.
- Smoke validation uses local Gateway and protected Notification API endpoints.
- Docker Compose does not define real notification provider services.
- `.env.example` contains placeholders only.

## NonProduction guarantees

- RealEmailProviderConfigured: false.
- RealSmtpConfigured: false.
- RealSmsProviderConfigured: false.
- RealPushProviderConfigured: false.
- RealWebhookProviderConfigured: false.
- RealNotificationProviderCredentialsPresent: false.
- RealNotificationSendingEnabled: false.
- ExternalApiCallsEnabled: false.

## Review note

`EmailDev` is a development channel name and does not imply real email delivery.
