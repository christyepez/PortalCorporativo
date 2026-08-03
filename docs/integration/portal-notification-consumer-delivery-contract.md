# Portal Notification Consumer Delivery Contract

## Purpose

CRM, Financiero and future consumers request delivery through Portal Notification. Consumers do not configure global providers or send directly through external notification APIs.

## Consumer request fields

- template code.
- recipients.
- variables.
- channel requested or defaulted by Portal.
- idempotency key.
- correlation id.
- metadata with no secrets.

## Delivery semantics

- Request acceptance is not proof of real-world delivery.
- Portal owns queued processing, retry, cancellation and terminal status.
- Consumers poll or subscribe to status through approved Portal contracts.
- Consumer retries must reuse the same idempotency key for the same business intent.

## Consumer guardrails

- Do not store provider credentials in consumer repos.
- Do not create SMTP/SMS/push provider adapters in consumers.
- Do not bypass Portal audit and notification status.
- Do not depend on production delivery until Portal approves a future provider gate.

## Sprint 15 status

Consumer delivery contract is prepared, but runtime onboarding remains disabled.
