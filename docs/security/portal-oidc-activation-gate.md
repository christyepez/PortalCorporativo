# Portal OIDC/OAuth2 activation gate

## Runtime capability
Portal BuildingBlocks now supports two JWT validation modes:

1. `Jwt:Authority` configured: validate bearer tokens against an OIDC/OAuth2 authority and audience.
2. No authority: controlled local JWT validation using issuer, audience and a secret supplied from environment/secret storage.

Browser access tokens remain memory-only; localStorage/sessionStorage persistence is prohibited.

## Required production inputs
Production activation requires an approved IdP authority URL, client/application registration, audience/resource identifier, HTTPS metadata, approved redirect/logout URIs, claim mapping for `permission`, key/certificate rotation ownership and an external secret provider where client credentials are necessary.

## Go/NoGo
Current decision: **NoGo for real IdP activation**. No real authority, tenant/client identifiers, credentials, certificates or private URLs are committed by this sprint.

The code boundary is provider-ready, but enabling a real provider is an external security/deployment gate and must be validated through Security, Gateway and Angular E2E before ProductionActivationDecision can change.
