# ADR - Portal messaging transport

Status: Accepted for Portal Sprint 22.

## Context
Portal Integration already provides SQL-backed Outbox/Inbox, idempotency, retries and a transport abstraction. The backlog requested an explicit Kafka/RabbitMQ evaluation without introducing a broker by default.

## Decision
Keep SQL Outbox/Inbox as the default controlled NonProduction transport boundary. Do not add Kafka or RabbitMQ to the baseline runtime.

Kafka becomes a candidate when durable event streaming, replay, consumer fan-out or sustained throughput justify operating a broker platform. RabbitMQ becomes a candidate when queue-oriented routing, work distribution, acknowledgements or short-lived commands/events dominate.

Any broker adoption requires a separate ADR containing measured throughput, latency, retention, replay, HA/DR, security, observability and operational ownership requirements.

## Consequences
- Current Portal runtime stays simpler and deterministic.
- Domain/application code remains broker-agnostic through `IEventPublisher`.
- Outbox/Inbox remain the reliability mechanism regardless of a future transport.
- `Worker__Transport: Disabled` remains the safe default until a transport gate is approved.
