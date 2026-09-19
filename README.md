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

Gateway: `http://localhost:8080`; Portal web: `http://localhost:4200`; Seq: `http://localhost:5341`.

Ciclo de vida local unificado:

```powershell
./scripts/local/prod-local-up.ps1 -Build
./scripts/local/prod-local-status.ps1
./scripts/local/prod-local-down.ps1
```

Los scripts aceptan uno o varios archivos de entorno mediante `-EnvFile`. Cuando se entregan varios, se pasan a Docker Compose en el mismo orden, permitiendo separar infraestructura local y JWT sin copiar secretos al repositorio.

Ejemplo con dos archivos locales:

```powershell
./scripts/local/prod-local-up.ps1 -EnvFile '.env.portal.local','C:\Dev\PortalWorkspace\.env.portal-corporativo'
```

`prod-local-up.ps1` levanta Portal Core, CRM, Financiero, Talento Humano e HistoriasPaolin dentro del mismo proyecto Docker Compose `portalcorporativo` y la red `portal-local-network`.

Build backend:

```powershell
dotnet restore backend/PortalCorporativo.sln
dotnet build backend/PortalCorporativo.sln --no-restore
```

Smoke PROD-local integrado:

```powershell
./scripts/smoke/prod-local-smoke.ps1
```

El smoke valida Portal web, Gateway, CRM, Financiero, HistoriasPaolin y Talento Humano, incluyendo endpoints públicos de readiness y endpoints protegidos con y sin JWT.

## Consumo desde dominios

Financiero, CRM, HistoriasPaolin, Talento Humano y futuros dominios pasan por Gateway, registran sus recursos/permisos y extienden Menu/Configuration. Adaptan Audit/Notification y mantienen sus datos de dominio en sus propias bases. Nunca consultan bases internas del Portal ni duplican identidad, autorización, menús, configuración, auditoría o notificaciones.

Consultar `docs/coordination/consumer-onboarding-guide.md`, `codex/REUSABLE_CAPABILITIES.md`, `codex/next-task.md` y `docs/security/authorization-policy-matrix.md` antes de implementar nuevos consumidores.
