# Portal Integration Shell Risk Register

| Risk | Impact | Mitigation | Status |
| --- | --- | --- | --- |
| External module routes are enabled before auth and ownership are approved. | Unauthorized or unstable consumer access. | Keep productive routes disabled in P6; require P7 gate. | Open |
| CRM or Financiero duplicate Portal security, menu, audit or notification. | Platform drift and inconsistent controls. | Enforce do-not-duplicate contract during onboarding. | Open |
| Consumers share Portal databases. | Bounded context and data ownership violation. | Reuse one SQL Server container only for local infrastructure; keep logical DBs separate. | Open |
| Private URLs or real credentials leak into repository. | Security incident. | Guardrail scans reject `.env`, private URLs and secret/certificate patterns. | Open |
| Menu metadata points to real routes before gateway is ready. | Broken navigation and accidental coupling. | P6 allows documentation and placeholders only. | Open |
| External modules bypass audit/outbox contracts. | Incomplete traceability. | Require audit/outbox adapter review before runtime activation. | Open |
| Angular shell is treated as production-ready too early. | UX and security assumptions become embedded. | Keep shell readiness as baseline, not production-ready. | Open |
