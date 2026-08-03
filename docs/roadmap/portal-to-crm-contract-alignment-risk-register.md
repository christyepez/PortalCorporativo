# Portal to CRM Contract Alignment Risk Register

| Risk | Impact | Sprint 21 disposition | Mitigation |
| --- | --- | --- | --- |
| CRM starts runtime work before Common DB planning | Boundary breach | Guarded | Next gate is CRM P2 planning only |
| CRM duplicates Portal auth or permissions | Platform drift | Guarded | Alignment matrix requires Portal Security contracts |
| CRM route is added to Gateway early | Runtime coupling | Guarded | Sprint 21 guardrail blocks CRM route markers in Gateway |
| CRM service is added to Portal Compose | Deployment coupling | Guarded | Sprint 21 guardrail blocks CRM services in Compose |
| Shared DB or cross migration appears | Data ownership breach | Guarded | DB boundary and migration criteria are explicit |
| Secrets or private URLs enter docs/runtime | Security exposure | Guarded | Secret/private URL scans remain mandatory |
