# Portal Controlled Auth Go/NoGo

## Decision

- ControlledAuthReadiness: PreparedNonProductionOnly.
- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- NextGate: PortalSprint14SecretProviderPreparation.

## Go for next preparation gate

Portal may proceed to secret provider preparation because:

- Auth integration contract is documented.
- Claims and permissions contract is documented.
- Future SSO/OIDC boundary is documented.
- Gateway authorization policy presence is verified.
- Security permissions foundation is verified.
- Frontend token storage remains disallowed.

## NoGo for production

Production remains blocked because Sprint 13 does not configure:

- real SSO/OIDC authority.
- real issuer.
- real client_id.
- real client_secret.
- real token storage.
- real login/logout UI.
- real production identity provider callbacks.
- CRM or Financiero production navigation.
