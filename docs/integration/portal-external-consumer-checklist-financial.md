# Portal External Consumer Checklist - Financiero

## Current Financiero status

Financiero is a future Portal consumer for accounting, tax and SRI capabilities. Sprint 16 does not inspect or modify the Financiero repository.

## Checklist

- Confirm Financiero remains contract-only until a Portal gate approves runtime onboarding.
- Define `moduleCode`: `financial`.
- Define relative route prefix only; no private URL.
- Register planned protected resources and permission codes with Portal Security.
- Define menu entries without enabling productive navigation.
- Define configuration keys with no secrets.
- Define audit events and correlation requirements.
- Define notification templates/events through Portal Notification.
- Confirm Financiero database is a separate logical database.
- Confirm Financiero migrations never modify Portal schemas.
- Confirm Financiero does not configure its own platform Auth, Audit, Configuration or Notification engines.
- Confirm deployment is independent from Portal Compose.

## Sprint 16 decision

Financiero checklist is prepared. Financiero runtime coupling remains disabled.
