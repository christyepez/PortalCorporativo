# Portal Health Smoke Risk Register

| Risk | Impact | Status | Mitigation |
| --- | --- | --- | --- |
| Existing-stack smoke can use different JWT secret than script token | Protected endpoints may return 401. | Controlled | Smoke treats 401/403 as expected protected behavior when reusing a stack. |
| Clean-stack smoke mutates local development database with a test notification | Local test data can accumulate in volumes. | Accepted | Uses local-only recipient and no production providers; no volume deletion is performed. |
| Generic health on APIs may duplicate manual `/health` mappings | Future endpoint changes could create confusion. | Monitored | Sprint 11 keeps `/health` common and validates Gateway contract; later cleanup can remove duplicated per-service mappings. |
| Production readiness could be inferred incorrectly | Premature activation risk. | Controlled | Production remains `NoGo` across Sprint 11 documents and guardrails. |
