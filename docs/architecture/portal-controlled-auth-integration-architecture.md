# Portal Controlled Auth Integration Architecture

## Current architecture

Portal currently uses backend JWT validation in Gateway and protected APIs. The Security API owns resources, roles and permissions. Authorization is enforced by backend policies based on the `permission` claim.

## Future architecture

Future SSO/OIDC will sit at the Portal boundary:

1. External IdP authenticates the user.
2. Portal validates tokens and maps trusted claims.
3. Security API remains the source for permissions and resource ownership.
4. Gateway and APIs enforce backend authorization policies.
5. Frontend shell reflects auth status but does not own identity.

## Session boundary

Frontend may display a NonProduction Auth status placeholder. It must not implement real login, store access tokens in localStorage/sessionStorage, or create a productized session runtime in Sprint 13.

## Consumer boundary

CRM and Financiero consume Portal Auth contracts. They do not own login, Security API permissions, or platform session handling.
