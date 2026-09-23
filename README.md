# Portal Corporativo Platform

Plataforma transversal agnóstica al giro de negocio. El objetivo PROD-local está cerrado y validado mediante Docker Compose, API Gateway, Angular Shell, SQL Server, workers, autorización JWT, correlación y smoke integrado.

## Capacidades disponibles

| Capacidad | Estado | Consumo |
|---|---|---|
| API Gateway YARP | Integrado | REUSE |
| Security API | Autorización, usuarios, roles, recursos y permisos | REUSE/EXTEND |
| Configuration API | Precedencia global → tenant → module → user | EXTEND |
| Menu API | Navegación dinámica filtrada en backend | EXTEND |
| Audit API | Append-only, redacción y consulta | ADAPT |
| Notification API | Plantillas, idempotencia, estados y proveedores dev | ADAPT |
| Catalog API | Integrado en PROD-local | REUSE/EXTEND |
| Content/File API | Integrado en PROD-local | REUSE/EXTEND |
| Reporting API | Integrado en PROD-local | REUSE/EXTEND |
| Integration API | Integrado en PROD-local | ADAPT/EXTEND |
| SQL Outbox/Inbox | Contratos, retry, idempotencia y DeadLetter | ADAPT/EXTEND |
| Workers | Outbox, Integration y Notification | EXTEND |
| Angular Shell | Integrado en PROD-local | REUSE/EXTEND |
| Health, logging y correlationId | Integrados con consola/Seq | REUSE |

Integraciones de dominio verificadas en PROD-local: CRM, Financiero, HistoriasPaolin y Talento Humano (AppTTHH), todas expuestas mediante el API Gateway. La operación objetivo se mantiene local en Docker Desktop/Docker Compose. El equipo `trabajo` es el entorno primario de implementación y validación; `MarketingIndo` se sincroniza posteriormente cuando esté disponible y nunca bloquea el avance.

## Ejecución local

Requisitos: Docker Desktop, Docker Compose v2 y PowerShell. Usar secretos locales no versionados y ejecutar el stack PROD-local con los archivos `docker-compose.yml` y `docker-compose.prod-local.yml`. CRM, Financiero, AppTTHH e HistoriasPaolin forman parte del mismo proyecto Compose `portalcorporativo` y se resuelven desde rutas configurables mediante `CRM_REPO_PATH`, `FINANCIERO_REPO_PATH`, `TTHH_REPO_PATH` y `HISTORIASPAOLIN_REPO_PATH`.

Gateway: `http://localhost:8080`; Portal web: `http://localhost:4200`; Seq: `http://localhost:5341`. En PROD-local, los puertos publicados al host se enlazan exclusivamente a `127.0.0.1`; SQL Server, Redis, MinIO, Seq, Gateway y Portal Web no se exponen directamente a la LAN.

Ciclo de vida local unificado:

```powershell
./scripts/local/prod-local-up.ps1 -Build
./scripts/local/prod-local-status.ps1
./scripts/local/prod-local-restart.ps1 -Service api-gateway
./scripts/local/prod-local-verify.ps1
./scripts/local/prod-local-down.ps1
```

Los scripts aceptan uno o varios archivos de entorno mediante `-EnvFile`. Cuando se entregan varios, se pasan a Docker Compose en el mismo orden, permitiendo separar infraestructura local y JWT sin copiar secretos al repositorio.

Ejemplo con dos archivos locales:

```powershell
./scripts/local/prod-local-up.ps1 -EnvFile '.env.portal.local','C:\Dev\PortalWorkspace\.env.portal-corporativo'
```

`prod-local-up.ps1` levanta Portal Core, CRM, Financiero, Talento Humano e HistoriasPaolin dentro del mismo proyecto Docker Compose `portalcorporativo` y la red `portal-local-network`. `prod-local-restart.ps1` permite reiniciar todo el stack o servicios específicos. `prod-local-verify.ps1` valida estado, healthchecks, restart counts y ejecuta el smoke autenticado; `-ScanLogs` agrega revisión opcional de errores críticos recientes.

Build backend:

```powershell
dotnet restore backend/PortalCorporativo.sln
dotnet build backend/PortalCorporativo.sln --no-restore
```

Smoke PROD-local integrado:

```powershell
./scripts/smoke/prod-local-smoke.ps1
```

El smoke valida Portal web, Gateway, las rutas protegidas de Security, Configuration, Menu, Audit, Notification, Catalog, Content, Integration y Reporting, además de CRM, Financiero, HistoriasPaolin y Talento Humano. Incluye endpoints públicos de readiness y endpoints protegidos con y sin JWT.

E2E PROD-local de runtime:

```powershell
./scripts/e2e/prod-local-portal-e2e.ps1
```

El E2E valida el Shell Angular compilado, enforcement de permisos, capacidades Core y navegación/API hacia CRM, Financiero, HistoriasPaolin y Talento Humano a través del proxy del Portal Web y el Gateway. También valida aislamiento multi-tenant entre dos tenants independientes para Security, Configuration, Notification, Catalog, Content, Reporting, Audit e Integration, incluido el rechazo de un `X-Tenant-ID` que no coincida con el claim autenticado.

Contrato multi-tenant: el tenant efectivo se resuelve desde `tenant_id` (o `tenant` por compatibilidad), con fallback local a `default`; los valores de tenant recibidos en body/query no pueden sobreescribir el contexto autenticado. Ver `docs/security/multitenancy.md`.

Backup y recuperación local:

```powershell
./scripts/local/prod-local-backup.ps1
./scripts/local/prod-local-backup-list.ps1
./scripts/local/prod-local-backup-validate.ps1
```

Los respaldos se almacenan fuera de Git en `backups/prod-local`. La validación restaura todas las bases administradas por Portal en un SQL Server temporal aislado y ejecuta `DBCC CHECKDB`. El restore real está protegido por `-Apply`; ver `docs/operations/prod-local-backup-recovery.md`.

Mantenimiento operativo en un comando:

```powershell
./scripts/local/prod-local-maintenance.ps1 -ScanLogs
```

También existe registro opcional de backup diario mediante `prod-local-backup-schedule.ps1`; usar primero `-WhatIf`. Ver `docs/operations/prod-local-maintenance.md`.

Detección de drift local:

```powershell
./scripts/local/prod-local-drift-baseline.ps1
./scripts/local/prod-local-drift-check.ps1
```

La baseline versionada contiene únicamente metadatos no sensibles (SHA de repositorios, hashes de Compose, nombres de variables requeridas, servicios e identidades de imágenes). El mantenimiento diario ejecuta el drift check automáticamente cuando existe la baseline. Ver `docs/operations/prod-local-drift-detection.md`.

Paquete de sincronización diferida:

```powershell
./scripts/local/prod-local-sync-package.ps1
./scripts/local/prod-local-sync-preflight.ps1
./scripts/local/prod-local-sync-apply.ps1 -Apply -WhatIf
```

El paquete permite preparar y validar una futura sincronización de `MarketingIndo` sin que ese equipo deba estar conectado. La aplicación real exige `-Apply`, repositorios limpios y sólo permite fast-forward; ver `docs/operations/prod-local-synchronization.md`.

## Consumo desde dominios

Financiero, CRM, HistoriasPaolin, Talento Humano y futuros dominios pasan por Gateway, registran sus recursos/permisos y extienden Menu/Configuration. Adaptan Audit/Notification y mantienen sus datos de dominio en sus propias bases. Nunca consultan bases internas del Portal ni duplican identidad, autorización, menús, configuración, auditoría o notificaciones.

Consultar `docs/coordination/consumer-onboarding-guide.md`, `codex/REUSABLE_CAPABILITIES.md`, `codex/next-task.md` y `docs/security/authorization-policy-matrix.md` antes de implementar nuevos consumidores.
