# Portal Corporativo Platform

Plataforma transversal agnóstica al giro de negocio. Sprint 1 Foundation está cerrado: 50 pruebas aprobadas y smoke integrado de Gateway, APIs, SQL, Worker, autorización y correlación.

## Capacidades disponibles

| Capacidad | Estado | Consumo |
|---|---|---|
| API Gateway YARP | Foundation lista | REUSE |
| Security API | Autorización, usuarios, roles, recursos y permisos | REUSE/EXTEND |
| Configuration API | Precedencia global → tenant → module → user | EXTEND |
| Menu API | Navegación dinámica filtrada en backend | EXTEND |
| Audit API | Append-only, redacción y consulta | ADAPT |
| Notification API | Plantillas, idempotencia, estados y proveedores dev | ADAPT |
| SQL Outbox/Inbox | Contratos, retry, idempotencia y DeadLetter | ADAPT/EXTEND |
| Workers | Outbox y Notification | EXTEND |
| Health, logging y correlationId | Integrados con consola/Seq | REUSE |

Pendientes: Catalog, Content/File, Reporting, Integration productiva, Angular Shell e IdP/OIDC productivo.

## Ejecución local

Requisitos: Docker Compose v2 y PowerShell. Copiar `.env.example` a `.env`, reemplazar todos los valores `CHANGE_ME` y ejecutar:

```powershell
./scripts/run-local.ps1
```

Gateway: `http://localhost:8080`; Seq: `http://localhost:5341`. Detalles en `docs/local-development.md`.

Build:

```powershell
dotnet restore backend/PortalCorporativo.sln
dotnet build backend/PortalCorporativo.sln --no-restore
```

Smoke integrado, con secreto local no versionado:

```powershell
./scripts/smoke/sprint1-smoke.ps1 -JwtSecret '<mínimo-32-caracteres>'
```

## Consumo desde dominios

Financiero, CRM y futuros dominios pasan por Gateway, registran sus recursos/permisos y extienden Menu/Configuration. Adaptan Audit/Notification y mantienen Outbox en su propia base. Nunca consultan bases del portal ni duplican identidad, autorización, menús, configuración, auditoría o notificaciones.

Consultar `docs/coordination/consumer-onboarding-guide.md`, `codex/REUSABLE_CAPABILITIES.md` y `docs/security/authorization-policy-matrix.md` antes de implementar.
