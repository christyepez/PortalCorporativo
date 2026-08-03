# Portal Notification Provider Secret Boundary

Notification provider credentials are secrets and must be resolved through the Portal Secret Provider contract prepared in Sprint 14.

## Logical credential references

| Provider family | Logical credential examples |
| --- | --- |
| SMTP | `portal/nonproduction/notification/smtp/password`, `portal/nonproduction/notification/smtp/user` |
| Email API | `portal/nonproduction/notification/email/api-key` |
| SMS | `portal/nonproduction/notification/sms/api-key` |
| Push | `portal/nonproduction/notification/push/credential` |
| Webhook | `portal/nonproduction/notification/webhook/signing-secret` |

## Boundary rules

- Do not commit credential values.
- Do not place provider secrets in frontend code.
- Do not log credential values.
- Do not expose provider credentials through API responses.
- Do not duplicate Secret Provider logic inside consumers.
- Do not configure real providers until a future approval gate.

## Sprint 15 status

- RealNotificationProviderCredentialsPresent: false.
- SecretProviderReadiness: PreparedNonProductionOnly.
- RealSecretProviderConfigured: false.
