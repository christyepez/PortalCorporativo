# Portal External Consumer Boundary Policy

## Policy

External consumers must integrate through approved Portal APIs, events and contracts. They must not become hidden runtime dependencies of Portal.

## Forbidden

- CRM or Financiero services in Portal Docker Compose.
- Productive CRM or Financiero Gateway routes.
- Productive external navigation.
- Shared Portal/consumer database tables.
- Cross-repository migrations.
- Private URLs in committed configuration.
- Real secrets, tokens or certificates.
- Browser token storage.
- Consumer-owned platform Auth, Audit, Configuration or Notification.

## Required before runtime activation

- Architecture approval.
- Security approval.
- Consumer repository readiness.
- Separate logical database validation.
- Gateway route review.
- Rollback plan.
- NonProduction evidence.

## Sprint 16 status

ExternalConsumerOnboardingReadiness: PreparedContractOnly.
