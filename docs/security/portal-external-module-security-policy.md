# Portal External Module Security Policy

## Policy

PortalCorporativo owns cross-cutting security for external modules. CRM, Financiero and future modules consume Portal Security contracts and must not duplicate login, identity, global role, global permission or token storage capabilities.

## Required controls

- External modules must register resources and permissions through the approved contract.
- Gateway routes must require an authorization policy.
- Menu entries must reference permission metadata.
- Audit events must avoid sensitive payloads and include correlation identifiers.
- Configuration must not store secrets directly.
- Real secrets, tokens, certificates and private URLs must not be committed.

## P6 activation status

- ProductiveExternalModuleRuntimeEnabled: false.
- ProductiveExternalNavigationEnabled: false.
- ProductiveExternalGatewayRoutesEnabled: false.
- ProductionActivationDecision: NoGo.

## Future approval gates

Before productive activation, complete:

- Portal auth/SSO production readiness.
- External module permission catalog review.
- Gateway route review.
- Consumer health and observability review.
- Secret provider and deployment environment review.
