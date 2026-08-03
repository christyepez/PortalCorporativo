# Portal Sprint P6 - Integration Shell / External Modules Baseline

## Decision

- PortalSprintP6IntegrationShellExternalModulesBaselineExists: true.
- IntegrationShellBaselineReviewed: true.
- ExternalModuleOnboardingContractPrepared: true.
- GatewayExternalModuleBoundaryReviewed: true.
- ConsumerModuleBoundaryReviewed: true.
- ProductionActivationDecision: NoGo.
- ProductiveExternalModuleRuntimeEnabled: false.
- ProductiveExternalNavigationEnabled: false.
- ProductiveExternalGatewayRoutesEnabled: false.
- RealCrmRuntimeCouplingPresent: false.
- RealFinancialRuntimeCouplingPresent: false.
- SharedDatabaseWithConsumersPresent: false.
- PrivateUrlsPresent: false.
- RealDataPresent: false.
- SecretsPresent: false.
- CrmModuleOnboardingReadiness: ContractPreparedNotRuntimeEnabled.
- FinancialModuleOnboardingReadiness: ContractPreparedNotRuntimeEnabled.
- IntegrationShellReadiness: BaselinePreparedNotProductionReady.
- NextGate: PortalSprintP7DeploymentHardeningBaseline.

## Evidence reviewed

- P1 through P5 roadmap documents and architecture guardrails were reviewed.
- API Gateway uses YARP routes for Portal services only.
- Gateway routes use `AuthorizationPolicy: default`.
- Security, Menu, Audit, Configuration and Notification APIs exist as Portal-owned foundations.
- Notification and Integration workers exist as foundation components.
- Docker Compose is Portal-owned and does not introduce consumer-specific SQL Server containers.

## Gate result

P6 prepares the onboarding contract for external modules, including CRM and Financiero, but does not enable productive runtime navigation, gateway routes or direct module coupling.

## Acceptance criteria

- Contract documents exist for generic external modules, CRM and Financiero.
- Gateway boundary is documented and verified.
- Security policy for external modules is documented.
- P6 guardrail and foundation verification scripts exist.
- Existing P1-P5 validations remain runnable.
