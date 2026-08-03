# Portal External Consumer Onboarding Go/No-Go

## Current decision

`NoGo` for production external consumer onboarding.

## Allowed in Sprint 16

- Documentation of CRM and Financiero onboarding checklists.
- Contract-only module, navigation, security and crosscutting boundaries.
- NonProduction Portal validation.
- Guardrails against accidental runtime coupling.

## Not allowed in Sprint 16

- Productive external navigation.
- Productive external Gateway routes.
- CRM or Financiero services in Portal Docker Compose.
- Shared Portal/CRM/Financiero databases or tables.
- Private URLs.
- Real secrets, tokens or certificates.
- SSO/OIDC production activation.
- Secret Provider or Notification Provider production activation.

## Go conditions for a future gate

- Consumer repository ready and explicitly approved.
- Portal Security resources and permissions reviewed.
- Navigation metadata approved and still non-sensitive.
- Gateway route reviewed for NonProduction first.
- Consumer health endpoint and rollback documented.
- Separate logical database confirmed.
- Audit, Configuration and Notification adapters validated.
- No production activation without a dedicated release candidate gate.
