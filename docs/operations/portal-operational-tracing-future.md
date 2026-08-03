# Portal Operational Tracing Future

## Current status

Distributed tracing is not enabled as a production provider in Sprint 19. Correlation IDs and structured logs provide the current NonProduction traceability baseline.

## Future contract

Future tracing should define:

- Trace ID and span ID propagation.
- Gateway-to-API boundaries.
- Worker and outbox correlation.
- Sampling policy.
- Retention and privacy controls.
- Provider selection and failure behavior.

RealApplicationInsightsConfigured: false.
RealDatadogConfigured: false.
RealNewRelicConfigured: false.
