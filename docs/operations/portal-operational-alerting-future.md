# Portal Operational Alerting Future

## Current status

Sprint 19 does not activate real external alerting.

## Future alert candidates

| Signal | Future route |
| --- | --- |
| Gateway readiness down | On-call alert |
| SQL dependency unhealthy | Platform alert |
| Worker repeated failures | Platform alert |
| High API error rate | Service owner alert |
| Notification dead letters | Platform plus module owner alert |

## Guardrail

External alerts require a future approval gate, secret provider runtime and documented escalation ownership.

RealExternalAlertsConfigured: false.
