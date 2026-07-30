# Gates de entrada y salida

## Definition of Ready

Una historia puede entrar al sprint cuando tiene:

- objetivo y valor.
- repositorio propietario.
- owner funcional y técnico.
- criterios de aceptación verificables.
- dependencias identificadas.
- contrato API/evento cuando aplique.
- datos de prueba.
- decisión de reutilización del Portal.
- estimación y riesgos.

## Definition of Done global

- Código integrado mediante PR.
- pruebas unitarias e integración aprobadas.
- health/readiness actualizados.
- autorización backend verificada.
- correlation ID propagado.
- auditoría y logging sin secretos.
- documentación y ADR actualizados.
- evidencia reproducible adjunta.
- sin capacidad compartida duplicada.

## Gate Portal Runtime PASS

- SQL accesible desde contenedores.
- secretos resueltos sin valores en repositorio/logs.
- Gateway health y readiness 200.
- token real validado.
- contexto y permisos resueltos.
- Shell carga menú y navega.
- CRM y Financiero alcanzables detrás del Gateway.

## Gate CRM Productization

- Portal Runtime PASS.
- DbContext y migraciones reales.
- autorización Portal activa.
- ruta productiva registrada.
- CRUD vertical y pruebas E2E.
- rollback y observabilidad.

## Gate Financiero E2E

- preflight `SCRIPT_EXIT=0`.
- evidencia SQL/Gateway/Shell/Auth aceptada.
- prueba técnica y funcional.
- ningún componente Portal duplicado.

## Gate HR fase 2

- Content/File disponible para expediente.
- Workflow y Task Inbox disponibles para solicitudes.
- permisos sensibles y auditoría de lectura aprobados.
