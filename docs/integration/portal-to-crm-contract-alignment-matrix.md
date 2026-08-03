# Portal to CRM Contract Alignment Matrix

| Contract area | Portal owner | CRM expected evidence | Sprint 21 status |
| --- | --- | --- | --- |
| Module metadata | Portal Menu / Integration | `moduleCode`, display name, owner, lifecycle and relative placeholder route | Aligned for planning |
| Navigation | Portal Menu | Menu entries with permission binding and no external absolute URL | Aligned for planning |
| Security/Auth | Portal Security | No CRM login; trusted Portal identity context only | Aligned for planning |
| Permission claims | Portal Security | CRM permission codes proposed as Portal resources and `permission` claims | Aligned for planning |
| Audit | Portal Audit | Event names, actor context, resource key, correlation id and PII notes | Aligned for planning |
| Configuration | Portal Configuration | Module-scoped keys, safe defaults, owner and change impact | Aligned for planning |
| Notification | Portal Notification | Template/event intent, recipients model, idempotency and correlation id | Aligned for planning |
| Health | Portal Operations / CRM | Logical health contract for future NonProduction validation | Aligned for planning |
| Observability | Portal Operations | Correlation ID and local Seq review expectations | Aligned for planning |
| Deployment ownership | Portal + CRM | CRM owns CRM runtime; Portal owns Gateway and platform rollback coordination | Aligned for planning |
| Rollback | Portal + CRM | Disable route/navigation and collect logs without production impact | Aligned for planning |
| DB boundary | CRM Data Owner | Separate CRM logical database; no Portal schema migrations | Aligned for planning |

No runtime route is activated by this matrix.
