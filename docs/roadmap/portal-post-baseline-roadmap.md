# Portal Post-Baseline Roadmap

## Current state

`PortalProdLocalObjectiveAchieved = true`.

Portal Core, Angular Shell, CRM, Financiero, HistoriasPaolin and Talento Humano are validated behind the Portal Gateway in local Production-mode execution on both `MarketingIndo` and `trabajo`.

## Recommended next stage

RecommendedNextStage: ExternalProductionActivationInputs.

NextGate: ProductionActivationDecision.

The previous controlled runtime, frontend shell, consumer onboarding and PROD-local integration stages are complete and must not be reopened unless a regression is detected.

## Stage 1 - External activation metadata

- Obtain approved OIDC/OAuth2 authority, audience and client registration metadata.
- Obtain approved redirect/logout URIs and permission claim mapping.
- Assign secret-provider, rotation, release, incident, backup and observability ownership.
- Obtain Architecture, Security and Operations approvals.
- Keep real credentials and private material outside git.

## Stage 2 - Automated preflight

- Populate a local copy of `deploy/production/activation-inputs.example.json`.
- Run `scripts/production/validate-activation-inputs.ps1`.
- Require `PRODUCTION_ACTIVATION_PREFLIGHT_PASS` before an activation review.

## Stage 3 - Controlled external validation

- Map approved OIDC values to `Jwt__Authority` and `Jwt__Audience` with HTTPS metadata required.
- Validate Gateway, Security and Angular end-to-end authentication in an approved non-production environment.
- Validate logout, permission claims, session policy, readiness, smoke and rollback.
- Keep CRM, Financiero, HistoriasPaolin and Talento Humano external activation subject to the same gate.

## Stage 4 - Production activation decision

- Review the production readiness checklist.
- Verify backup/restore and rollback evidence.
- Confirm monitoring, alerting and incident ownership.
- Change `ProductionActivationDecision` only through the approved release process.
- Real SRI transmission remains a separate explicit approval.
