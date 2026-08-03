# Portal External Consumer Checklist - CRM

## Current CRM status

- Repository: `christyepez/CRM`.
- Base frozen: `ec0515e961c35ae0dab71aae4d85b43a65964e7f`.
- ProductizationStatus: PreparationOnly.
- ProductionActivationDecision: NoGo.
- Next CRM step: Sprint 10 P2 - Common DB Controlled Activation Plan.

## Checklist

- Confirm CRM remains contract-only until a Portal gate approves runtime onboarding.
- Define `moduleCode`: `crm`.
- Define relative route prefix only; no private URL.
- Register planned protected resources and permission codes with Portal Security.
- Define menu entries without enabling productive navigation.
- Define configuration keys with no secrets.
- Define audit events and correlation requirements.
- Define notification templates/events through Portal Notification.
- Confirm CRM database is a separate logical database.
- Confirm CRM migrations never modify Portal schemas.
- Confirm CRM does not configure its own platform Auth, Audit, Configuration or Notification engines.
- Confirm deployment is independent from Portal Compose.

## Sprint 16 decision

CRM checklist is prepared. CRM runtime coupling remains disabled.
