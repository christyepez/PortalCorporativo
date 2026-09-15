# Portal Sprint 22 - Functional Backlog Completion Closure

## Decision
Status: **COMPLETE**.

Portal functional NonProduction objective is achieved. Production activation remains **NoGo** because real IdP, secret-provider and production-provider inputs are external deployment/security gates, not missing foundation code.

## Completed scope
- Catalog API: domain, contracts, application service, repository abstraction, protected API endpoints.
- Content/File API: metadata, SHA-256 integrity, controlled upload/download/deactivation and repository abstraction.
- Reporting API: report catalog, parameter validation and controlled NonProduction execution.
- Integration API: protected Outbox/Inbox registration and processed-state endpoints over the existing reliable messaging model.
- Gateway: YARP paths aligned with functional APIs.
- Docker runtime: functional APIs wired with shared JWT configuration and health dependencies.
- Angular Shell: Security/Menu/Configuration plus Catalog/Reporting client integration; access token memory-only.
- Auth: shared JWT/OIDC validation boundary across Gateway and Portal APIs.
- Security: role and permission revocation endpoints plus automated authorization tests.
- Audit: transactional archive-before-purge retention implementation with minimum 365-day policy.
- Messaging ADR: SQL Outbox/Inbox retained; Kafka/RabbitMQ not introduced by default.
- CI: backend restore/build/test, frontend build/test/lint and Docker Compose validation.

## Verified CI evidence
Workflow: `Portal CI`, run #46, commit `022801e2270c15fff6a0ed70c60d3a686b80358c`.

- Backend restore: PASS.
- Backend build: PASS, 0 warnings, 0 errors.
- Backend tests: 61/61 PASS.
  - Notification: 14.
  - DynamicPlatform: 8.
  - Security: 9.
  - Reliability: 8.
  - Authorization: 22.
- Frontend build: PASS.
- Frontend tests: PASS.
- Frontend lint: PASS.
- Docker Compose config validation: PASS.

## Security / production gate
Real OIDC activation requires approved authority, audience/client registration, redirect/logout URIs, permission claim mapping, certificate/key rotation ownership and approved secret storage. None of those values are committed here.

Self-contained local JWTs cannot be force-invalidated after issuance without an issuer/revocation service. Permission revocation is immediate in the Security authorization model; newly issued/refreshed tokens no longer carry revoked permission claims. Active-token invalidation is delegated to the selected production IdP/session policy and must be validated during production activation.

## Runtime guardrails
- ProductionActivationDecision: `NoGo`.
- No real secrets committed.
- No private production URLs committed.
- No browser token persistence.
- No direct CRM/Financial database coupling.
- No shared cross-domain database.
- No broker introduced without a measured ADR gate.

## Outcome
`PortalFunctionalNonProductionObjectiveAchieved = true`.

Next gate: `ExternalProductionActivationInputs`.
