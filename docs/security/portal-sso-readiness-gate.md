# Portal SSO Readiness Gate

## P3 Decision

SSO production activation is NoGo.

## Ready For NonProduction Contract Design

- JWT bearer validation exists.
- Permission policies exist.
- Gateway routes require default authorization policy.
- Security API owns users, roles, permissions and permission checks.

## Not Ready For Production

- No approved OIDC provider.
- No production client registration.
- No secret-provider-backed client secret.
- No certificate/key material strategy for production.
- No browser token/session implementation.
- No logout and revocation validation.

## Gate To Pass Before Production

1. Define identity provider and tenant boundaries.
2. Register redirect URIs with placeholders in docs only.
3. Source client secrets from an approved secret store.
4. Validate token claims mapping to Portal permissions.
5. Validate CRM/Financiero consume identity through Portal/Gateway contracts only.
6. Validate failure modes: expired, missing, malformed and unauthorized tokens.
