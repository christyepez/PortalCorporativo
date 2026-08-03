# Portal Deployment Hardening Risk Register

| Risk | Impact | Mitigation | Status |
| --- | --- | --- | --- |
| Production is marked ready without runtime evidence. | Unsafe release decision. | Keep `ProductionActivationDecision: NoGo` and runtime checks pending controlled environment. | Open |
| Real `.env`, secrets, tokens or certificates are committed. | Credential exposure. | Guardrail scripts fail on real `.env`, secret patterns and certificate/key files. | Open |
| Placeholder credentials are replaced in repository files. | Accidental secret leakage. | Keep `CHANGE_ME` placeholders only; real values live outside git. | Open |
| Health checks pass but dependencies are not ready. | Partial outage during promotion. | Require readiness checks for SQL Server, Redis, MinIO, Seq, workers and APIs before production gate. | Open |
| Rollback is undocumented during an incident. | Longer recovery time. | Maintain rollback/recovery runbook and release artifact traceability. | Open |
| CRM/Financiero runtime routes are enabled prematurely. | Cross-domain coupling and security drift. | Keep external runtime disabled and covered by P6/P7 guardrails. | Open |
| Observability lacks correlation. | Harder incident diagnosis. | Keep `X-Correlation-ID` and Seq logging in the foundation. | Open |
