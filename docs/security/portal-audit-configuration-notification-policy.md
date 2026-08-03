# Portal Audit / Configuration / Notification Policy

## Decision

- AuditBaselineReviewed: true.
- ConfigurationBaselineReviewed: true.
- NotificationBaselineReviewed: true.
- ProductionActivationDecision: NoGo.
- RealNotificationSendingEnabled: false.
- RealSmtpConfigured: false.
- RealSmsProviderConfigured: false.
- RealPushProviderConfigured: false.

## Ownership

Portal owns transversal Audit, Configuration and Notification capabilities. CRM, Financiero and future consumers integrate through published contracts and Gateway, not through shared databases or duplicated engines.

## Audit Policy

- Audit is append-only by contract.
- Consumers submit allowlisted audit events.
- Audit payloads must not include secrets, tokens, certificates or unnecessary personal data.
- `X-Correlation-ID` must be preserved across Gateway, APIs and workers.

## Configuration Policy

- Configuration is centralized in Portal.
- Consumers may request module/user/tenant scoped configuration entries through Portal contracts.
- Configuration metadata must not store secrets or private operational values.

## Notification Policy

- P5 permits development/log/internal notification providers only.
- Real SMTP, SMS, push or external notification providers are not configured.
- Consumers may request notification templates and message scheduling through Portal contracts after onboarding approval.

## Production NoGo

Production remains blocked until provider selection, secret sourcing, audit retention operations, consumer contracts and runtime smoke checks are validated.
