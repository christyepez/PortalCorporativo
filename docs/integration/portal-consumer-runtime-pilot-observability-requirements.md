# Consumer Runtime Pilot Observability Requirements

## Required before any pilot activation

- Portal local Seq remains available for NonProduction review.
- Gateway, Portal APIs and CRM pilot traffic must include correlation evidence.
- Health checks must exist for Portal and the consumer route.
- Logs must identify service, environment, request path, status and correlation ID.
- Pilot review must use `tools/portal-nonproduction-logs.ps1` or equivalent approved evidence.

## Deferred

- Real Application Insights.
- Real Datadog.
- Real New Relic.
- Real Prometheus/Grafana.
- Real SIEM.
- Real external alert routing.

RealObservabilityProviderConfigured: false.
OperationalObservabilityReadiness: PreparedNonProductionOnly.
