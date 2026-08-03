# Portal Controlled Auth Integration Policy

## Policy

Portal Auth integration is prepared but not activated for production. Sprint 13 allows only controlled NonProduction placeholder JWT validation and documentation of future SSO/OIDC integration.

## Allowed in Sprint 13

- Document future SSO/OIDC contract.
- Use existing local placeholder JWT validation for controlled runtime smoke.
- Validate signed JWT issuer, audience, lifetime and signing key in backend.
- Require permission claims for protected APIs.
- Keep anonymous health endpoints.

## Not allowed in Sprint 13

- Real SSO/OIDC authority.
- Real issuer URL.
- Real client_id.
- Real client_secret.
- Real production login/logout.
- Browser token storage.
- Real token persistence or refresh-token flow.
- CRM/Financiero runtime coupling.

## Current backend behavior

Gateway and protected APIs validate local placeholder JWTs with:

- issuer.
- audience.
- signing key.
- lifetime.

Authorization uses the repeatable `permission` claim and backend policies.

## Production decision

ProductionActivationDecision: NoGo.
PortalProductionReady: false.
