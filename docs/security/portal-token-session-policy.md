# Portal Token and Session Policy

## Guardrails

- Do not store access tokens in `localStorage`.
- Do not store access tokens in `sessionStorage`.
- Do not commit real tokens, client secrets, certificates or private URLs.
- Do not pass tokens through URLs.
- Do not enable production Auth runtime from local placeholders.

## Current State

Backend services validate JWT bearer tokens using issuer, audience, signing key and lifetime checks. The current symmetric key setup is local/NonProduction foundation only and requires a secret source before production.

Frontend session handling is not buildable yet because no Angular package manifest exists. Therefore browser storage behavior is policy-only in P3 and must be validated once the Portal shell is implemented.

## Future Session Baseline

The preferred production session direction is:

1. OIDC authorization code flow with PKCE.
2. Short-lived access tokens.
3. Refresh/session behavior controlled by the approved identity provider.
4. HttpOnly/Secure/SameSite cookie strategy evaluated before UI activation, or another approved non-browser-readable token handling strategy.
5. Explicit logout and revocation semantics documented before production.

## Pending

- Cookie policy.
- Session timeout.
- Logout flow.
- Token refresh/revocation behavior.
