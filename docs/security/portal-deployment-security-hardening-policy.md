# Portal Deployment Security Hardening Policy

## Policy

PortalCorporativo deployment artifacts must remain safe for version control and non-production validation. Production activation is not approved in P7.

## Repository rules

- Do not commit `.env`.
- Do not commit real secrets, tokens, certificates, private keys or private URLs.
- Do not replace placeholders with real values.
- Do not commit real customer, employee, CRM or financial data.
- Do not activate productive providers or external routes.
- Do not create shared databases with CRM or Financiero.

## Runtime rules

- API Gateway routes require authorization policy.
- Production OIDC/SSO requires a later approval gate.
- Notification providers remain development/internal unless approved later.
- Runtime secrets must come from an external secret provider, not git.
- Logs must avoid secrets and sensitive payloads.

## P7 decision

- ProductionActivationDecision: NoGo.
- ProductionDeploymentReadiness: HardeningPreparedNotProductionReady.
