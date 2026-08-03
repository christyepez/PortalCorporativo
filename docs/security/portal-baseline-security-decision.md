# Portal Baseline Security Decision

## Decision

ProductionActivationDecision: NoGo.

PortalProductionReady: false.

## Security posture at closure

- JWT/permission foundation exists for backend authorization validation.
- Production SSO/OIDC is not configured.
- Secret provider production runtime is not configured.
- Real notification providers are not configured.
- Browser token storage remains disallowed.
- CRM/Financiero runtime integration remains disabled.
- No production credentials, tokens, certificates or private URLs are added by P8.

## Required security gates after closure

- Secret provider selection and validation.
- OIDC provider selection and claims mapping.
- Token/session/logout policy validation.
- Gateway route security review for any external module.
- Log redaction and sensitive payload review before production.
