# Portal Controlled NonProduction Deployment Package

## Purpose

Provide a repeatable NonProduction-only package to build, run, validate, inspect and stop Portal Corporativo after the Sprint 17 Release Candidate.

## Included assets

- Deployment runbook.
- Validation runbook.
- Rollback/stop runbook.
- `.env` local guide.
- Service/port matrix.
- Command matrix.
- Guardrail and package verification scripts.
- Optional safe wrappers:
  - `tools/portal-nonproduction-deploy.ps1`
  - `tools/portal-nonproduction-validate.ps1`
  - `tools/portal-nonproduction-stop.ps1`

## Deployment boundary

The package runs Portal services only. CRM and Financiero remain external consumers with contract-only preparation.

ProductionActivationDecision: NoGo.
PortalProductionReady: false.
ControlledNonProductionDeploymentReadiness: PackagePreparedNonProductionOnly.
