# Portal Gateway External Module Boundary

## Current state

The Portal API Gateway routes only Portal-owned APIs in P6:

- Security.
- Configuration.
- Menu.
- Audit.
- Notification.
- Catalog.
- Content.
- Integration.
- Reporting.

All configured routes must keep `AuthorizationPolicy: default` or a stricter approved policy.

## P6 rule

Do not add productive CRM, Financiero, financial or other external module routes.

## Future route requirements

A future external module route must include:

- approved module code;
- path prefix;
- destination name;
- authorization policy;
- timeout and retry policy;
- health contract;
- owner and rollback plan;
- evidence that the destination does not expose private URLs or secrets in repository files.

## Rejection criteria

Reject the change if it introduces:

- production URLs;
- private internal URLs;
- real tokens or client secrets;
- direct database access;
- a route without authorization policy;
- CRM/Financiero coupling before the activation gate.
