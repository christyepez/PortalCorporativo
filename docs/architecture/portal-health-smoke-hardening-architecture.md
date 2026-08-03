# Portal Health Smoke Hardening Architecture

## Health contract

Portal foundation maps three health endpoints for every service using the common building block:

- `/health`
- `/health/live`
- `/health/ready`

The API Gateway inherits the same contract through `UsePortalFoundation()`, closing the Sprint 9 generic health blocker.

## Smoke contract

The Sprint 1 smoke script is hardened for two runtime states:

- If Gateway readiness is already healthy, the script reuses the current stack.
- If Gateway readiness is not healthy, the script starts the required Compose subset.

The script validates health endpoints before protected endpoint checks and stops Compose only when it started the stack.

## Security boundary

Protected endpoints remain protected. The smoke can validate either a successful local placeholder-token flow or a 401/403 protected response when the stack was already started with a different local secret.

## Production boundary

This hardening does not activate production, external module routes, CRM runtime coupling, Financial runtime coupling, production SSO/OIDC, production secret provider or real notification providers.
