# Portal Docker Full Stack Security Decision

## Decision

Sprint 12 validates Docker full stack runtime with local placeholders only. It does not activate production authentication, production secret providers, real notification providers, private URLs, real certificates, CRM coupling or Financiero coupling.

## Allowed

- Local placeholder JWT secret passed at execution time.
- `.env.example` placeholders.
- Anonymous health endpoints.
- Protected endpoint smoke that accepts 401/403 as valid protected behavior.

## Not allowed

- Real `.env` committed.
- Real tokens committed.
- Real certificates or private keys committed.
- Real SSO/OIDC runtime activation.
- Real secret provider activation.
- Real notification providers.
- Browser token storage.
- CRM/Financiero production navigation or runtime coupling.

## Production decision

ProductionActivationDecision: NoGo.
PortalProductionReady: false.
