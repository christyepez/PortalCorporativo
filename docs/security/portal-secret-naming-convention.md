# Portal Secret Naming Convention

## Format

Use logical names, not values:

```text
portal/{environment}/{component}/{purpose}
```

## Examples

| Component | Logical name |
| --- | --- |
| Gateway JWT | `portal/nonproduction/gateway/jwt-signing-secret` |
| Security DB | `portal/nonproduction/security/db-password` |
| Configuration DB | `portal/nonproduction/configuration/db-password` |
| Menu DB | `portal/nonproduction/menu/db-password` |
| Audit DB | `portal/nonproduction/audit/db-password` |
| Notification DB | `portal/nonproduction/notification/db-password` |
| Notification provider | `portal/nonproduction/notification/provider-api-key` |
| Future SSO client secret | `portal/nonproduction/auth/oidc-client-secret` |
| Future CRM onboarding | `portal/nonproduction/consumers/crm/trust-secret` |
| Future Financiero onboarding | `portal/nonproduction/consumers/financiero/trust-secret` |

## Rules

- Do not embed secret values in names.
- Do not include real tenant, user or customer data in names.
- Keep production names separate from NonProduction names.
- Use provider aliases only after the provider gate is approved.
