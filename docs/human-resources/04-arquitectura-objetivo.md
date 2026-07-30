# Arquitectura objetivo

## Estilo

- Portal como contenedor de experiencia.
- Servicios transversales como bounded contexts de plataforma.
- Talento Humano dividido por capacidades de negocio.
- Vertical Slice Architecture dentro de cada módulo.
- Integración por API y eventos.
- Base de datos por bounded context.
- Consistencia eventual entre dominios.

## Vista lógica

```text
Portal Angular Shell
        │
        ▼
API Gateway YARP
        │
        ├── Platform APIs
        │   ├── Security
        │   ├── Menu
        │   ├── Configuration
        │   ├── Audit
        │   ├── Notification
        │   ├── Catalog
        │   ├── Content/File
        │   ├── Workflow
        │   ├── Task Inbox
        │   ├── Reporting
        │   └── Integration
        │
        └── Human Resources
            ├── HR.Core
            ├── HR.Recruitment
            ├── HR.EmployeeLifecycle
            ├── HR.Time
            ├── HR.Performance
            ├── HR.Learning
            ├── HR.EmployeeExperience
            ├── HR.Compensation
            ├── HR.PayrollIntegration
            └── HR.Analytics
```

## Responsabilidad del Portal

- Identidad y acceso.
- Navegación y experiencia común.
- Registro de módulos y permisos.
- Configuración global.
- Auditoría transversal.
- Notificaciones multicanal.
- Documentos y archivos.
- Workflow y tareas.
- Catálogos globales.
- Exportaciones.
- Integraciones técnicas comunes.
- Observabilidad.

## Responsabilidad de Talento Humano

- Reglas funcionales.
- Datos del dominio.
- Validaciones laborales.
- Historial efectivo.
- Procesos de ciclo de vida.
- Eventos de negocio.
- Adaptadores hacia capacidades del Portal.

## Estructura de solución sugerida

```text
src/
├── Platform/
├── Gateway/
├── PortalShell/
├── BuildingBlocks/
└── Modules/
    └── HumanResources/
        ├── Core/
        │   ├── Api/
        │   ├── Application/
        │   ├── Domain/
        │   ├── Infrastructure/
        │   └── Contracts/
        ├── Recruitment/
        ├── EmployeeLifecycle/
        ├── Time/
        ├── Performance/
        ├── Learning/
        ├── EmployeeExperience/
        ├── Compensation/
        └── PayrollIntegration/
```

## Vertical slices

Ejemplo en `HR.Time`:

```text
Features/
├── RequestLeave/
├── ApproveLeave/
├── RejectLeave/
├── CancelLeave/
├── GetLeaveBalance/
└── ListTeamAbsences/
```

Cada slice contiene endpoint, comando o consulta, validación, handler, contratos y pruebas necesarias. No se organizará el dominio únicamente en carpetas globales `Controllers`, `Services` y `Repositories`.

## Datos

- Cada dominio controla su esquema o base.
- No existen relaciones SQL entre bases de bounded contexts.
- Las referencias externas se almacenan por identificadores estables.
- Los cambios interdominio se publican mediante Outbox.
- Los consumidores usan Inbox para idempotencia.
- Los datos analíticos se replican a una plataforma de datos.

## Eventos principales

```text
EmployeeCreated
EmployeeUpdated
EmploymentStarted
EmploymentEnded
PositionAssigned
LeaveRequested
LeaveApproved
LeaveRejected
VacancyApproved
CandidateSelected
OnboardingStarted
OnboardingCompleted
PerformanceReviewCompleted
TrainingCompleted
CompensationChanged
PayrollNoveltyGenerated
```

## Integridad y transacciones

- Transacción ACID dentro de cada bounded context.
- Outbox en la misma transacción que el cambio funcional.
- Reintentos con backoff.
- DeadLetter para mensajes no procesables.
- Operaciones externas idempotentes.
- Reconciliación para nómina, biométrico e identidad.

## Despliegue

### Inicial

- Docker Compose.
- Un contenedor por API o Worker.
- SQL Server.
- Gateway YARP.
- Seq.
- Proveedores externos configurados por ambiente.

### Evolución

- Separación de escalado por servicio.
- Transporte de eventos productivo.
- Secretos centralizados.
- Orquestación administrada cuando la carga lo justifique.

## Reglas de dependencia

- Dominio no depende de infraestructura.
- Aplicación depende del dominio y contratos.
- Infraestructura implementa puertos.
- APIs no acceden directamente a bases de otros módulos.
- Portal no contiene reglas de Talento Humano.
- Talento Humano no implementa capacidades transversales existentes.
