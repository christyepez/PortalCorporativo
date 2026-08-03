# Portal Notification Provider Contract

## Purpose

Define the provider adapter boundary for future notification delivery without enabling real providers in Sprint 15.

## Provider port

A provider adapter receives a prepared notification message and returns a delivery result. It must be selected by channel and provider configuration controlled by Portal.

Minimum provider metadata:

- provider name.
- provider family: internal, email, SMTP, SMS, push or webhook.
- logical credential references.
- timeout and retry compatibility.
- idempotency support.
- delivery result status.
- external correlation or message id when available.

## Payload contract

The provider receives:

- message id.
- template code and version.
- channel.
- recipients.
- rendered subject.
- rendered body.
- metadata.
- correlation id.
- idempotency key.

## Provider result contract

The provider must return one of:

- sent.
- failed retryable.
- failed terminal.
- cancelled before delivery.

## Rules

- Provider adapters must not read secrets directly from Git-tracked files.
- Provider adapters must not mutate consumer domains.
- Provider adapters must not own retry scheduling.
- Provider adapters must not expose credential values.
- Real providers require a future gate.
