# Portal OIDC / SSO Future Boundary

## Boundary

Future SSO/OIDC integration must be owned by Portal Corporativo. Consumer domains must not create their own identity provider integration, login screens, session stores or permission systems.

## Future provider inputs

The following values are intentionally not configured in Sprint 13:

- authority.
- issuer.
- client_id.
- client_secret.
- callback paths.
- logout callback paths.
- signing key discovery metadata.

## Secret sourcing

Real secrets must come from a future approved secret provider. They must not be stored in source control, `.env.example`, logs, Docker Compose literals or frontend bundles.

## Activation checklist

Before real SSO/OIDC activation:

- Secret provider gate is complete.
- NonProduction IdP tenant is approved.
- Redirect URIs are registered and reviewed.
- Token validation metadata is verified.
- Claims mapping to `permission` is tested.
- Frontend uses secure session handling without localStorage/sessionStorage token storage.
- Audit events for sign-in/session decisions are defined.
- Production remains blocked until a later explicit Go decision.
