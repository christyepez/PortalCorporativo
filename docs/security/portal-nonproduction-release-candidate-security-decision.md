# Portal NonProduction Release Candidate Security Decision

## Decision

Security posture is acceptable for a controlled NonProduction deployment package.

## Explicit NO-GO for production

- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- SsoOidcProductionConfigured: false.
- RealSecretProviderConfigured: false.
- RealNotificationProvidersConfigured: false.
- RealNotificationSendingEnabled: false.

## Security guardrails

- No `.env` real versionado.
- No secretos reales.
- No tokens reales.
- No certificados reales.
- No URLs privadas reales.
- No browser token storage.
- No CRM/Financiero runtime coupling.
- No productive external navigation or Gateway routes.

## Future production criteria

Production requires approved SSO/OIDC, runtime Secret Provider, production Notification Provider, consumer route gates, observability, incident ownership and production rollback evidence.
