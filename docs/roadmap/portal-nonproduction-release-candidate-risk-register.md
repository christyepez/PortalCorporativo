# Portal NonProduction Release Candidate Risk Register

| Risk | Impact | RC status | Mitigation |
| --- | --- | --- | --- |
| RC is mistaken for production readiness | Unsafe production deployment | Blocked | Production remains `NoGo` and `PortalProductionReady: false` |
| Local placeholder secrets are reused beyond NonProduction | Credential weakness | Guarded | Secret Provider remains preparation-only and `.env.example` placeholders are documented |
| Real Auth, Secret Provider or Notification Provider is enabled too early | Security exposure | Guarded | Guardrails scan for production markers, private URLs and real secrets |
| CRM/Financiero runtime coupling is enabled before approval | Consumer drift | Guarded | Sprint 16 contracts remain `PreparedContractOnly` |
| Rollback is not exercised for package deployment | Recovery uncertainty | Open | Sprint 18 must package rollback steps for controlled NonProduction deployment |
| Observability is insufficient for production | Incident response risk | Open | Production promotion criteria remain deferred |
