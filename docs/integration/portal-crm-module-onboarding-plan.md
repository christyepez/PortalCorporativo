# Portal CRM Module Onboarding Plan

## Status

CrmModuleOnboardingReadiness: ContractPreparedNotRuntimeEnabled.

## Planned metadata

- Module code: `crm`.
- Planned route prefix: `/crm`.
- Owner: CRM domain team.
- Runtime status in P6: disabled.

## Portal capabilities to reuse

- Security API for resources and permissions.
- Menu API for navigation metadata.
- Configuration API for tenant/module/user settings.
- Audit API for trace events.
- Notification API for outbound notification requests.
- Gateway as future controlled edge boundary.
- Correlation and structured logging.

## Boundaries

P6 does not add CRM gateway routes, CRM services, CRM Docker services, CRM database schema or CRM frontend navigation.

## Next onboarding work

- Register CRM resource catalog in a future controlled sprint.
- Define CRM menu tree using Portal Menu contract.
- Validate CRM health endpoint before gateway activation.
- Confirm CRM owns its logical database and does not access Portal databases directly.
