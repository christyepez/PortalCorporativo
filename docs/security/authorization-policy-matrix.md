# Backend Authorization Policy Matrix

JWT is validated at Gateway and again by every protected API. Authorization uses repeatable claim `permission`; health endpoints (`/health`, `/health/live`, `/health/ready`) are anonymous and disclose only health state.

| Endpoint | Resource / action | Permission | Seed roles | Anonymous | Consumer impact |
|---|---|---|---|---|---|
| `/api/security/**` | `portal.security/manage` | `portal.security.manage` | SuperAdmin, PortalAdmin | No | Domains register resources; never manage identity locally. |
| Configuration writes/activation | `portal.configuration/manage` | `portal.configuration.manage` | SuperAdmin, PortalAdmin | No | CRM/Financiero extend keys through authorized administration. |
| Configuration effective/scope reads | `portal.configuration/read` | `portal.configuration.read` | SuperAdmin, PortalAdmin | No | Runtime consumers need a read grant. |
| Menu writes/reorder/activation | `portal.menu/manage` | `portal.menu.manage` | SuperAdmin, PortalAdmin | No | Domain modules extend navigation metadata. |
| Menu module/user reads | `portal.menu/read` | `portal.menu.read` | SuperAdmin, PortalAdmin | No | Shell and consumers need a read grant. |
| `POST /api/audit/events` | `portal.audit/write` | `portal.audit.write` | SuperAdmin, PortalAdmin | No | Domain adapters submit allowlisted audit records. |
| Audit reads/search | `portal.audit/read` | `portal.audit.read` | SuperAdmin, PortalAdmin | No | Restricted operational access. |
| Notification templates/retry/cancel | `portal.notification/manage` | `portal.notification.manage` | SuperAdmin, PortalAdmin | No | Template governance remains central. |
| Notification send/schedule | `portal.notification/send` | `portal.notification.send` | SuperAdmin, PortalAdmin | No | Domain adapters request delivery. |
| Notification templates/messages/status reads | `portal.notification/read` | `portal.notification.read` | SuperAdmin, PortalAdmin | No | Consumers can query delivery state. |
| `/health*` | platform health | none | n/a | Yes | Orchestrators may probe without credentials. |

New CRM/Financiero permissions are registered in Security with their own resource/action and assigned by least privilege. Tokens must obtain permissions from a trusted issuer; client-supplied claims are never trusted without signature, issuer, audience and lifetime validation.

Sprint 2 risks: external IdP/issuer, automated end-to-end JWT tests, permission revocation latency and formal least-privilege role design.
