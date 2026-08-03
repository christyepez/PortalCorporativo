# Portal Consumer Runtime Pilot Risk Register

| Risk | Impact | Sprint 20 disposition | Mitigation |
| --- | --- | --- | --- |
| Contract-only plan is mistaken for runtime approval | Unsafe activation | Guarded | Production and runtime activation remain NoGo |
| CRM route appears in Gateway before alignment | Cross-domain coupling | Guarded | Sprint 20 guardrail blocks CRM/Financiero route or service definitions |
| Consumer database is shared with Portal | Data boundary violation | Guarded | No shared DB, tables or migrations are allowed |
| CRM has not completed its DB controlled activation plan | Pilot cannot start | Open | CRM must complete Sprint 10 P2 before runtime pilot |
| Observability is insufficient during pilot | Poor triage | Open | Sprint 20 defines minimum health, correlation and log review requirements |
| Financiero scope slips into pilot | Scope creep | Guarded | Financiero remains future consumer and contract-only |
