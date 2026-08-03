# Portal Operational Logging and Correlation

## Current baseline

Portal services use structured logging and local Seq. Requests pass through the common foundation middleware that preserves `X-Correlation-ID`.

## Required fields for NonProduction review

| Field | Purpose |
| --- | --- |
| Timestamp | Event time |
| Level | Severity |
| Service | Emitting service |
| Environment | Runtime environment |
| CorrelationId | Cross-service request trace |
| RequestPath | HTTP path when available |
| StatusCode | HTTP result when available |
| EventId | Framework or domain event marker |

## Review rule

Every incident review starts by collecting the correlation ID from the failing request, smoke output or Seq query.
