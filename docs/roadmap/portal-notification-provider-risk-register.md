# Portal Notification Provider Risk Register

| Risk | Impact | Sprint 15 status | Mitigation |
| --- | --- | --- | --- |
| Real provider credentials are committed | Credential leakage and external abuse | Guarded | Guardrails scan for provider keywords, real secrets, tokens, certificates and private URLs |
| Development provider accidentally sends real messages | User-facing side effects | Guarded | Current providers log only and are documented as placeholders |
| Retry causes duplicate delivery | Duplicate email, SMS or push | Prepared | Idempotency key and provider idempotency requirements documented |
| Consumers bypass Portal Notification | Fragmented delivery governance | Guarded | Consumer delivery contract states Portal owns orchestration |
| Provider adapter owns state | Broken retry/audit boundaries | Guarded | Architecture document assigns state to Notification API/Worker |
| Production is enabled too early | Uncontrolled external delivery | Blocked | Production remains NoGo until a future provider gate |
