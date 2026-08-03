# Portal Operational Observability Strategy

## Scope

Operational observability for Sprint 19 is NonProduction-only and uses:

- Structured logs emitted by backend services and workers.
- Local Seq container from Docker Compose.
- `X-Correlation-ID` propagation through Portal building blocks.
- Health endpoints: `/health`, `/health/live`, `/health/ready`.
- Smoke evidence from the controlled NonProduction package.

## Out of scope

- Real Application Insights.
- Real Datadog.
- Real New Relic.
- Productive Prometheus/Grafana.
- Real SIEM.
- External alert delivery.
- Production incident workflow.

OperationalObservabilityReadiness: PreparedNonProductionOnly.
ProductionActivationDecision: NoGo.
