# Portal Post-Baseline Roadmap

## Recommended next stage

RecommendedNextStage: PortalControlledRuntimeValidation.

NextGate: PortalSprint9ControlledRuntimeValidation.

## Stage 1 - Controlled runtime validation

- Start Portal runtime in a controlled non-production environment.
- Validate `/health`, `/health/live` and `/health/ready`.
- Run smoke tests with placeholders only.
- Capture logs, correlation IDs and rollback evidence.

## Stage 2 - Frontend shell buildability

- Add a buildable frontend shell package if approved.
- Integrate Menu, Security and Configuration contracts.
- Keep external navigation disabled until activation gates.

## Stage 3 - Secret provider

- Select secret provider.
- Move runtime secrets outside repository files.
- Validate no secret values are exposed through APIs or logs.

## Stage 4 - SSO/OIDC

- Select provider and flow.
- Use authorization code with PKCE or approved equivalent.
- Validate claims, permissions, logout and session policy.

## Stage 5 - Consumer onboarding

- Onboard CRM and Financiero through Portal contracts.
- Register resources, permissions, menu metadata and configuration.
- Activate gateway routes only after health, security and ownership review.
