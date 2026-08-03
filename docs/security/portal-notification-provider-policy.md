# Portal Notification Provider Policy

Portal Notification owns notification templates, requests, message status, retry policy and provider orchestration.

## Allowed in Sprint 15

- Development/log/internal providers.
- Documentation of future provider families.
- Logical credential names with no values.
- NonProduction health, build, test and smoke validation.

## Not allowed in Sprint 15

- Real SMTP.
- Real email provider.
- Real SMS provider.
- Real push provider.
- Real webhook delivery.
- Provider API keys.
- Provider passwords.
- Provider tokens.
- Provider certificates or private keys.
- Private provider URLs.
- Browser token storage.
- CRM or Financiero runtime coupling.

## Future production policy

Production delivery requires a dedicated gate after Secret Provider runtime is approved. Provider adapters must fail closed if credentials are missing, malformed or sourced from unsafe configuration.
