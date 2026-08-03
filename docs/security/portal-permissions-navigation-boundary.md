# Portal Permissions / Navigation Boundary

## Boundary

Portal provides authorization and navigation capabilities as transversal platform services:

- Security API owns resources, roles, permissions and permission decisions.
- Menu API owns navigation metadata.
- API Gateway provides protected routing.
- Consumers extend by registering module metadata and permission requirements.

## Consumer Responsibilities

CRM and Financiero must define their own domain permissions as metadata requests to Portal. They must not create independent identity stores, duplicate global roles, or read Portal databases directly.

## Current State

The current seeded menu includes only Portal administration routes. No CRM or Financiero productive navigation is enabled.

## Pending

- Formal external module registration workflow.
- Versioned menu contract validation.
- UI shell rendering and route activation checks.
