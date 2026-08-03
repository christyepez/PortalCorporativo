# Portal External Module Onboarding Contract

## Status

ContractPreparedNotRuntimeEnabled.

## Required module metadata

- `moduleCode`: stable lowercase code, for example `crm` or `financial`.
- `displayName`: user-facing name.
- `owner`: accountable domain owner.
- `routePrefix`: planned shell route. Must be reviewed before activation.
- `healthEndpoint`: future readiness endpoint.
- `permissions`: resource/action list owned by Portal Security.
- `menuEntries`: menu metadata owned by Portal Menu.
- `configurationKeys`: module configuration owned by Portal Configuration.
- `auditEvents`: event catalog sent to Portal Audit.
- `notifications`: notification templates or events sent to Portal Notification.

## Security contract

External modules must reuse Portal authorization and must not create a parallel identity, login, global role, permission or token store.

## Gateway contract

Gateway routes for external modules are disabled in P6. A future route must define:

- explicit path prefix;
- authorization policy;
- internal destination approved for the environment;
- health and timeout behavior;
- owner and rollback instructions.

## Data contract

External modules must own their logical database. They may share the local SQL Server container only as infrastructure.

## Activation checklist

- Portal Security resources and permissions approved.
- Menu metadata approved and non-productive route reviewed.
- Gateway route approved by architecture.
- Audit, configuration and notification adapters reviewed.
- Health and logging verified.
- No real secrets, tokens, private URLs or production data committed.
