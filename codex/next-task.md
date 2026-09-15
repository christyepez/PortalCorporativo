# Next Codex Task

## Repository

christyepez/PortalCorporativo

## Phase

Portal Functional Roadmap - COMPLETE

## Current Branch

portal-sprint22-functional-backlog-completion

## Objective Status

`PortalFunctionalNonProductionObjectiveAchieved = true`

The Portal functional foundation is complete through Sprint 22. Catalog, Content/File, Reporting, Integration, Angular Shell integration, shared JWT/OIDC validation boundary, permission revocation foundation, Audit retention and CI validation are implemented.

## Verified Evidence

- Portal CI run #46: success.
- Backend build: 0 warnings / 0 errors.
- Backend tests: 61/61 PASS.
- Frontend build/test/lint: PASS.
- Docker Compose validation: PASS.
- Closure: `docs/releases/portal-sprint-22-functional-backlog-closure.md`.

## Next Gate

`ExternalProductionActivationInputs`

This is not another implementation sprint. Production activation requires external approved inputs:

- Real OIDC/OAuth2 IdP authority and app/client registration.
- Audience/resource and permission-claim mapping.
- Redirect/logout URIs and session/revocation policy.
- Real secret provider and rotation ownership.
- Production notification/integration providers where required.
- Production environment/network URLs and deployment approvals.

## Guardrails

- ProductionActivationDecision remains `NoGo` until those external inputs are supplied and validated.
- Do not commit secrets, private production URLs, certificates or real data.
- Do not persist browser access tokens.
- Do not create direct CRM/Financial database coupling.
- Do not add Kafka/RabbitMQ without a separate measured ADR.

## Closure Expected

Sprint implementation work is complete. Only the external Production Activation Gate remains.
