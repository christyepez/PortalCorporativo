# Portal Financial Module Onboarding Plan

## Status

FinancialModuleOnboardingReadiness: ContractPreparedNotRuntimeEnabled.

## Planned metadata

- Module code: `financial`.
- Planned route prefix: `/financial`.
- Owner: Financiero domain team.
- Runtime status in P6: disabled.

## Portal capabilities to reuse

- Security API for SRI, accounting and fiscal permissions.
- Menu API for financial navigation metadata.
- Configuration API for module settings.
- Audit API for fiscal and integration trace events.
- Notification API for controlled notifications.
- Gateway as future controlled edge boundary.
- Correlation and structured logging.

## Boundaries

P6 does not add Financiero gateway routes, Financiero services, Financiero Docker services, financial database schema or financial frontend navigation.

## Next onboarding work

- Register financial resources and permission catalog in a future controlled sprint.
- Define menu tree without activating productive navigation.
- Validate financial health endpoint before gateway activation.
- Confirm Financiero owns its logical database and does not access Portal databases directly.
