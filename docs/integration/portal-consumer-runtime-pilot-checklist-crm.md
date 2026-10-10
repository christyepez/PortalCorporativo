# CRM Controlled Consumer Runtime Pilot Checklist

## Entry checklist

- CRM repository status is clean and based on the approved frozen or successor base.
- CRM Common DB Controlled Activation Plan is approved.
- CRM Portal Consumer Contract Alignment is approved.
- CRM module metadata is reviewed by Portal.
- CRM navigation contract is reviewed by Portal.
- CRM permissions and claims contract is reviewed by Portal Security.
- CRM audit, configuration and notification usage is reviewed.
- CRM health endpoint contract is reviewed.
- CRM deployment owner and rollback owner are identified.

## Portal checklist

- Portal NonProduction package remains healthy.
- Local Seq observability remains available.
- Gateway routes remain disabled until the activation gate.
- External navigation remains disabled until the activation gate.
- Shared database boundaries remain intact.


## Automated P25 readiness evidence

Portal CI validates the governed CRM registry and the required pilot governance documents through `scripts/quality/test-crm-runtime-pilot-readiness-gate.ps1`.

PROD-local E2E validates CRM through the Portal Gateway and requires the current safe state to remain fail-closed:

- Portal integration status reports `connected=false` and `PortalIntegrationPlanned`.
- Controlled implementation reports `ProductionActivationDecision=NoGo` and `CrmProductionReady=false`.
- Portal runtime coupling/calls remain disabled.
- Shared Portal table access and direct Portal database access remain disabled.
- No real secrets or browser token storage are present.
- Controlled dry-run is prepared but locked, with no activation or external call attempted.

This evidence is a safety/readiness gate only. It does not authorize runtime activation.
