# Portal Secret Provider Architecture

## Current state

Portal currently uses local placeholders and environment variables for NonProduction runtime validation. `.env.example` contains only replaceable placeholder values.

## Future architecture

Future provider integration will load secrets at runtime from an approved secret provider:

1. Deployment environment identifies the provider.
2. Service resolves logical secret names.
3. Secret values are injected into backend configuration.
4. Frontend receives only non-secret public configuration.
5. Rotation and access are audited outside the repository.

## Provider candidates

- Azure Key Vault.
- AWS Secrets Manager.
- GCP Secret Manager.
- HashiCorp Vault.

No candidate is configured in Sprint 14.

## Boundaries

Portal owns the platform secret policy. CRM and Financiero must not duplicate platform secret provider integrations without a consumer onboarding contract.
