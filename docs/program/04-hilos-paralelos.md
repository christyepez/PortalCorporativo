# Hilos paralelos

## Stream A — Portal Runtime

Responsable de SQL, secretos, Gateway, identidad, contexto, Shell, health, observabilidad y evidencia E2E. Es el camino crítico.

## Stream B — Servicios compartidos

Content/File, Catalog, Notification, Workflow, Task Inbox y Reporting. Debe priorizar capacidades consumidas por dos o más dominios.

## Stream C — CRM

- Antes del PASS Portal: modelo, contratos, pruebas y vertical preparada.
- Después del PASS: DB real, Auth real, rutas productivas y Cliente/Organización.
- No continuar creando gates sin una activación concreta asociada.

## Stream D — Financiero

- Antes del PASS Portal: dominio, pruebas, XML/SRI foundation y hardening.
- Después del PASS: preflight, E2E, homologación y productización controlada.
- No repetir ciclos de escalamiento sin evidencia nueva.

## Stream E — Talento Humano

- Inicio inmediato: empresas, sedes, unidades, cargos, posiciones y colaboradores.
- Expediente espera Content/File.
- Vacaciones y onboarding esperan Workflow/Task Inbox.

## Stream F — Codex y calidad

Automatización cross-repo, contratos, generación de issues, quality gates, pruebas y trazabilidad.

## Reglas de sincronización

- Reunión de dependencias: lunes y jueves, máximo 30 minutos.
- Demo integrada al cierre de cada sprint.
- Un contrato compartido se publica antes de que el consumidor lo implemente.
- Cada stream mantiene un máximo de dos historias activas críticas.
- Cuando un stream queda bloqueado, toma historias marcadas `ready-without-dependency`.
