# Portal Consumer Onboarding Template

Use this template when an explicit new domain/application is selected for Portal integration. The consumer remains owner of its domain logic and database; Portal remains owner of transversal capabilities.

## 1. Consumer identity

- Consumer name:
- Repository path / URL:
- Module code:
- Runtime API service:
- Domain database:
- Technical owner:
- Current health/readiness endpoint:

## 2. Portal capability classification

| Need | Classification | Portal capability | Consumer work |
|---|---|---|---|
| Authentication / identity | REUSE | Security | No duplicated identity store |
| Authorization | EXTEND | Security | Register resource/actions and backend policies |
| Navigation | EXTEND | Menu | Register module/menu/routes |
| Functional/visual parameters | EXTEND | Configuration | Register module-scoped keys |
| Audit | ADAPT | Audit | Send allowlisted critical events |
| Notifications | ADAPT | Notification | Register templates and idempotent requests |
| Files/content | ADAPT | Content | Use Portal file contracts when generic |
| Catalogs | EXTEND | Catalog | Register shared/global catalogs only |
| Reporting | EXTEND | Reporting | Register transversal definitions as needed |
| Integrations/events | ADAPT/EXTEND | Integration/Outbox | Keep domain Outbox in domain DB |
## 3. Mandatory runtime contract

- [ ] Host-facing API reachable only through Portal Gateway.
- [ ] Backend validates Portal JWT and permission claims.
- [ ] `X-Correlation-ID` is propagated end-to-end.
- [ ] Tenant context is validated where the consumer is multi-tenant.
- [ ] Consumer owns its database; no Portal table sharing or cross-domain joins.
- [ ] Health/live/readiness endpoints are available.
- [ ] Docker Compose service joins `portal-local-network` without exposing domain API directly to the LAN.
- [ ] Portal Web navigation opens the consumer through the approved workspace pattern.
- [ ] No browser token persistence is introduced.
- [ ] No secrets, private production URLs, certificates or real credentials are committed.

## 4. Security registration

- Module/resource names:
- Read permission:
- Write permission:
- Administrative permission:
- Minimum-privilege roles affected:
- Anonymous endpoints allowed: health/readiness only, unless explicitly justified.

## 5. Menu and configuration registration

- Menu hierarchy:
- Portal route(s):
- Required permission per route/action:
- Configuration keys:
- Theme/layout/grid/form metadata required:

## 6. Quality gates

- [ ] Consumer build passes.
- [ ] Consumer unit/integration tests pass.
- [ ] Portal Compose config validates.
- [ ] Consumer container becomes healthy with `RestartCount=0`.
- [ ] Unauthorized Gateway request returns `401`/`403` as appropriate.
- [ ] Authorized Portal JWT reaches consumer through Gateway.
- [ ] Existing CRM, Financiero, HistoriasPaolin and TTHH smoke remains green.
- [ ] Full Portal E2E has no regression.
- [ ] `prod-local-verify.ps1 -ScanLogs` passes.
- [ ] Drift baseline is refreshed only after all runtime gates pass.
## 7. Closure evidence

Record:
- Branch / PR:
- Merge commit:
- Portal CI result:
- Consumer CI result:
- Smoke result:
- E2E result:
- Verify/ScanLogs result:
- Drift result:
- Runtime image IDs changed:

## Required implementation report

```text
Portal Capability Checked:
Reuse Classification:
Portal Components Reused:
Portal Components Extended:
New Components Created:
Reason for New Components:
Risks:
Next Step:
```

A consumer is not considered integrated until every mandatory runtime and quality gate above is green.