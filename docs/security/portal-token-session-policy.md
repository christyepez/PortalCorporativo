# Portal Token and Session Policy

## Guardrails

- Do not store access tokens in `localStorage`.
- Do not store access tokens in `sessionStorage`.
- Do not commit real tokens, client secrets, certificates or private URLs.
- Do not pass tokens through URLs.
- Do not enable production Auth runtime from local placeholders.

## Current State

Backend services validate JWT bearer tokens using issuer, audience, signing key and lifetime checks. The current symmetric key setup is local/NonProduction foundation only and requires a secret source before production.

The Angular shell is implemented and keeps access tokens in memory only. For PROD-local administration, the Portal may request a short-lived SuperAdmin JWT from the Security API through the exact `/api/security/local-session` Gateway route when, and only when, the PROD-local overlay enables `PortalLocalAdmin`. The endpoint reads the current SuperAdmin permission assignments from Security DB, returns `404` when disabled, sends `no-store`/`no-cache`, and the browser never persists the token to localStorage/sessionStorage. The operator does not paste a token manually. Real login remains subject to the approved OIDC production gate.

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
