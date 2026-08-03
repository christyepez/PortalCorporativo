# Portal Operational Observability Risk Register

| Risk | Impact | Status | Mitigation |
| --- | --- | --- | --- |
| Local observability is mistaken for production readiness | Unsafe promotion | Blocked | Production remains `NoGo` and external providers remain disabled |
| Provider credentials are introduced too early | Credential exposure | Guarded | Guardrails scan for provider names, connection strings, secrets, tokens and private URLs |
| Alerts are sent externally from NonProduction | Unwanted side effects | Guarded | Alerting remains future/documentary only |
| Correlation IDs are not captured during incident review | Slow triage | Guarded | Logging/correlation runbook defines required fields |
| Logs include sensitive data | Security exposure | Open | Redaction and PII review stay mandatory before production |
| Metrics are too coarse for production | Poor operations | Open | Production metrics/dashboard are deferred to later gates |
| Consumer runtime traffic changes Portal signals | Noisy observability | Guarded | CRM/Financiero runtime coupling remains disabled |
