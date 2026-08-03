# Portal Secret Provider Contract

## Purpose

Define how Portal services and future consumers will reference secrets without committing values.

## Contract

Services must reference secrets by logical name and environment. Runtime value resolution belongs to the approved provider or local untracked configuration.

## Required metadata

- logical name.
- owner component.
- environment.
- purpose.
- rotation owner.
- expiration policy.
- audit requirement.

## Consumer onboarding

Future CRM and Financiero onboarding may require trust secrets or client credentials. Those values must be owned by Portal secret policy and never committed to consumer repositories.

## Not implemented

- provider SDK integration.
- real provider credentials.
- production secret resolution.
- consumer runtime activation.
