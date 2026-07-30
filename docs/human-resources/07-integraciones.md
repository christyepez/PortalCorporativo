# Integraciones

## Objetivo

Integrar Talento Humano con sistemas institucionales mediante contratos estables, idempotencia, trazabilidad y reconciliación, evitando accesos directos entre bases.

## Sistemas previstos

| Sistema | Dirección | Información |
|---|---|---|
| Microsoft Entra ID | Bidireccional controlada | Usuario, estado y grupos |
| Microsoft 365/Teams | Salida y consulta | Notificaciones, tareas y colaboración |
| Sistema de nómina | Bidireccional | Empleados, novedades, resultados y roles |
| Biométrico | Entrada | Marcaciones e incidencias |
| ERP/Financiero | Bidireccional | Centros de costo, presupuesto y contabilización |
| LMS/Moodle | Bidireccional | Cursos, inscripciones y resultados |
| Power BI/plataforma de datos | Salida | Datos analíticos |
| SharePoint/gestor documental | Evaluar | Documentos heredados |
| Bolsas de empleo | Bidireccional | Vacantes y postulaciones |

## Responsabilidad de Integration API

- Autenticación técnica.
- Clientes HTTP/SOAP/SFTP comunes.
- Políticas de timeout y reintento.
- Secretos.
- telemetría.
- conectores Microsoft Graph.
- webhooks.
- transferencia de archivos.

## Responsabilidad de HR

- Reglas de sincronización.
- Mapeo funcional.
- validación de datos.
- propiedad de eventos.
- reconciliación funcional.
- tratamiento de inconsistencias.

## Contrato mínimo de integración

```yaml
integration:
  id: hr-payroll-employees
  source: hr-core
  target: payroll
  owner: human-resources
  direction: outbound
  frequency: event-driven
  authentication: managed-secret
  timeout_seconds: 30
  retries: 5
  idempotency_key: employeeId+version
  contains_sensitive_data: true
  reconciliation: daily
```

## Eventos

### Publicados por HR

- `EmployeeCreated`.
- `EmployeeUpdated`.
- `EmploymentStarted`.
- `EmploymentEnded`.
- `PositionAssigned`.
- `LeaveApproved`.
- `PayrollNoveltyGenerated`.
- `OnboardingStarted`.
- `OffboardingStarted`.

### Consumidos por HR

- `IdentityAccountCreated`.
- `IdentityAccountDisabled`.
- `AttendanceImported`.
- `PayrollCalculated`.
- `TrainingCompleted`.
- `AssetAssigned`.
- `AssetReturned`.

## Reglas técnicas

- Outbox local en cada dominio productor.
- Inbox local en cada consumidor.
- Eventos versionados.
- Consumidores tolerantes a campos nuevos.
- Nunca reutilizar entidades internas como mensajes.
- Datos sensibles reducidos al mínimo.
- Correlation ID obligatorio.
- DeadLetter y reejecución controlada.

## Reconciliación

Cada integración crítica debe comparar:

- Registros enviados.
- registros recibidos.
- estado funcional.
- duplicados.
- faltantes.
- errores permanentes.

La integración de nómina y biométrico requiere panel de conciliación y acciones manuales auditadas.

## Ambientes

- Local: mocks o contenedores controlados.
- Desarrollo: sandbox institucional.
- QA: datos anonimizados.
- Producción: credenciales administradas y restricciones de red.

## Criterios de aceptación

- Operación idempotente.
- Logs correlacionados.
- reintentos verificados.
- DeadLetter probado.
- reconciliación documentada.
- secretos fuera del código.
- pruebas de contrato.
- runbook de soporte.
