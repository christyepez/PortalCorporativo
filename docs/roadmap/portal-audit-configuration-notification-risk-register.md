# Portal Audit / Configuration / Notification Risk Register

| Risk | Status | Impact | Mitigation |
| --- | --- | --- | --- |
| Consumers write directly to Portal databases | Open | High | Consumers must use Gateway/API contracts only |
| Secrets stored in configuration values | Open | High | Configuration contract forbids secrets; use secret providers in later gates |
| Real notification provider enabled too early | Open | High | Keep only development providers in P5; production providers require a future gate |
| Audit payloads include sensitive data | Open | High | Use allowlists, redaction and correlation metadata |
| Worker behavior not runtime-smoked | Open | Medium | Runtime worker checks remain pending controlled environment validation |
| CRM/Financiero duplicate crosscutting capabilities | Open | High | Portal owns audit/configuration/notification; consumers adapt/extend only |

No risk is waived for production.
