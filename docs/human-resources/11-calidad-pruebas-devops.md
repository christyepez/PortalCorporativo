# Calidad, pruebas y DevOps

## Estrategia de calidad

La calidad se aplica desde la historia hasta producción. Codex puede generar y ejecutar verificaciones, pero no sustituye la aprobación funcional, de seguridad o de producción.

## Pirámide de pruebas

### Unitarias

- Reglas de dominio.
- cálculos.
- validadores.
- políticas de autorización contextual.
- transformaciones.

### Integración

- Persistencia SQL Server.
- Outbox e Inbox.
- adaptadores del Portal.
- Content/File.
- Workflow.
- Notification.
- integraciones externas simuladas.

### Contrato

- APIs entre Portal y HR.
- eventos versionados.
- proveedores externos.
- compatibilidad hacia atrás.

### End-to-end

- Inicio de sesión.
- menú por permisos.
- creación de colaborador.
- carga de documento.
- solicitud y aprobación de vacaciones.
- publicación y selección de candidato.

### Seguridad

- Autorización negativa.
- aislamiento por tenant y organización.
- acceso a datos restringidos.
- exportaciones.
- carga maliciosa de archivos.
- secretos.
- dependencias vulnerables.

## Quality gates

Un pull request no puede completarse si falla:

- Compilación.
- lint y formato.
- pruebas unitarias.
- pruebas de integración críticas.
- análisis estático.
- escaneo de secretos.
- escaneo de dependencias.
- cobertura mínima acordada.
- validación de migraciones.
- política de reutilización.
- documentación obligatoria.

## Cobertura objetivo

- Dominio: 85 % o superior.
- Aplicación: 80 % o superior.
- Infraestructura: cobertura enfocada en rutas críticas.
- Endpoints críticos: al menos un happy path y casos de autorización/error.

La cobertura no reemplaza la calidad de los escenarios.

## CI/CD

```text
Pull request
→ restore
→ build
→ lint
→ unit tests
→ integration tests
→ security scans
→ architecture tests
→ package
→ preview/development deploy
→ smoke tests
→ approval
→ merge
```

## Ambientes

| Ambiente | Propósito |
|---|---|
| Local | Desarrollo con Docker Compose |
| Development | Integración continua |
| QA | Pruebas funcionales y técnicas |
| UAT | Validación de usuarios clave |
| Production | Operación controlada |

## Migraciones

- Una migración por cambio funcional coherente.
- Nunca modificar migraciones aplicadas en ambientes compartidos.
- Scripts reversibles cuando sea viable.
- respaldo antes de cambios destructivos.
- pruebas con datos representativos anonimizados.
- despliegue compatible con versión anterior durante transición.

## Observabilidad

Cada servicio debe publicar:

- Logs estructurados.
- métricas técnicas.
- métricas funcionales.
- trazas distribuidas.
- health checks.
- Correlation ID.
- alertas.

### Métricas funcionales iniciales

- Colaboradores activos.
- movimientos procesados.
- documentos próximos a vencer.
- solicitudes pendientes.
- tiempo de aprobación.
- mensajes en DeadLetter.
- errores de sincronización.

## SLO iniciales

- APIs principales: 99,5 % mensual, sujeto a infraestructura.
- Operaciones de lectura: p95 menor a 800 ms en condiciones nominales.
- Operaciones de escritura: p95 menor a 1.500 ms, excluyendo procesos asíncronos.
- Notificaciones: procesamiento inicial menor a 5 minutos.
- Integraciones críticas: reconciliación diaria completa.

## Runbooks mínimos

- Servicio no disponible.
- migración fallida.
- mensajes en DeadLetter.
- integración de nómina inconsistente.
- proveedor de identidad no disponible.
- archivos bloqueados o infectados.
- fuga o acceso indebido sospechado.
- restauración de respaldo.

## Release

Cada versión debe incluir:

- Notas de cambio.
- migraciones.
- compatibilidad.
- riesgos.
- plan de rollback.
- evidencias de pruebas.
- aprobación funcional.
- aprobación de seguridad cuando corresponda.
