# Portal Consumer Module Contract

## Purpose

Define how consumer domains request Portal navigation and permission metadata without coupling to Portal runtime internals.

## Contract Inputs

- `moduleCode`: stable lowercase module identifier.
- `displayName`: human-readable module label.
- `routePrefix`: safe relative route prefix, for example `/crm` or `/financial`.
- `resourceKey`: Portal protected resource key.
- `permissionCodes`: permission codes required for menu visibility and actions.
- `metadata`: optional non-sensitive JSON metadata.

## Guardrails

- Routes must be relative and must not include private URLs.
- Metadata must not contain secrets, tokens, certificates or real personal/customer data.
- Consumers must not write directly to Portal databases.
- Portal Security remains the permission decision owner.

## P4 Status

ConsumerModuleNavigationContractPrepared: true.

External production navigation remains disabled until a later gate approves runtime onboarding.
