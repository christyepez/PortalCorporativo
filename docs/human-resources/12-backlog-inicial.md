# Backlog inicial

## Convenciones

- `PLT`: plataforma Portal.
- `HR-CORE`: núcleo de Talento Humano.
- `HR-DOC`: expediente.
- `HR-TIME`: tiempo y ausencias.
- `HR-REC`: reclutamiento.
- `HR-LIFE`: ciclo de vida.
- `HR-PERF`: desempeño.
- `HR-LRN`: aprendizaje.
- `HR-COMP`: compensación.
- `HR-PAY`: integración de nómina.

## Épica PLT-01 — Portal Shell

- PLT-001 Crear foundation Angular.
- PLT-002 Implementar layout corporativo.
- PLT-003 Consumir Menu API.
- PLT-004 Implementar guards por permiso.
- PLT-005 Propagar JWT y Correlation ID.
- PLT-006 Manejar errores y estados de carga.
- PLT-007 Crear biblioteca UI compartida.
- PLT-008 Registrar módulo Talento Humano.

## Épica PLT-02 — Identidad productiva

- PLT-020 Integrar Microsoft Entra ID.
- PLT-021 Validar tokens OIDC en Gateway y APIs.
- PLT-022 Mapear identidad externa a usuario Portal.
- PLT-023 Implementar logout y expiración.
- PLT-024 Probar autorización positiva y negativa.

## Épica PLT-03 — Content/File

- PLT-030 Crear metadatos de documentos.
- PLT-031 Implementar almacenamiento por ambiente.
- PLT-032 Versionar archivos.
- PLT-033 Autorizar por entidad y clasificación.
- PLT-034 Generar enlaces temporales.
- PLT-035 Integrar auditoría.
- PLT-036 Integrar análisis antivirus.
- PLT-037 Administrar retención y eliminación lógica.

## Épica PLT-04 — Workflow y Task Inbox

- PLT-040 Definir workflows versionados.
- PLT-041 Crear instancias y etapas.
- PLT-042 Soportar aprobación secuencial.
- PLT-043 Soportar aprobación paralela.
- PLT-044 Implementar rechazo, devolución y cancelación.
- PLT-045 Implementar delegación y escalamiento.
- PLT-046 Crear tareas y bandeja única.
- PLT-047 Publicar eventos y auditoría.

## Épica HR-CORE-01 — Organización

- HR-CORE-001 Administrar empresas y sedes.
- HR-CORE-002 Administrar unidades organizacionales.
- HR-CORE-003 Consultar organigrama.
- HR-CORE-004 Versionar cambios organizacionales.
- HR-CORE-005 Aplicar permisos por alcance.

## Épica HR-CORE-02 — Cargos y posiciones

- HR-CORE-020 Administrar cargos.
- HR-CORE-021 Definir perfiles y competencias.
- HR-CORE-022 Administrar posiciones.
- HR-CORE-023 Asignar centro de costo y ubicación.
- HR-CORE-024 Controlar vigencia y estado.

## Épica HR-CORE-03 — Personas y colaboradores

- HR-CORE-030 Registrar persona.
- HR-CORE-031 Crear colaborador.
- HR-CORE-032 Crear relación laboral.
- HR-CORE-033 Asignar posición y jefe.
- HR-CORE-034 Registrar contacto de emergencia.
- HR-CORE-035 Consultar historial laboral.
- HR-CORE-036 Terminar relación laboral.
- HR-CORE-037 Publicar eventos de colaborador.

## Épica HR-DOC-01 — Expediente

- HR-DOC-001 Definir categorías documentales.
- HR-DOC-002 Cargar documento mediante Content/File.
- HR-DOC-003 Consultar y descargar con auditoría.
- HR-DOC-004 Controlar vencimientos.
- HR-DOC-005 Solicitar documentos faltantes.
- HR-DOC-006 Restringir documentos sensibles.

## Épica HR-TIME-01 — Vacaciones y permisos

- HR-TIME-001 Configurar tipos de ausencia.
- HR-TIME-002 Calcular saldo inicial.
- HR-TIME-003 Solicitar vacaciones.
- HR-TIME-004 Crear workflow de aprobación.
- HR-TIME-005 Aprobar o rechazar.
- HR-TIME-006 Cancelar solicitud.
- HR-TIME-007 Consultar calendario del equipo.
- HR-TIME-008 Generar novedad para nómina.

## Épica HR-REC-01 — Reclutamiento

- HR-REC-001 Solicitar vacante.
- HR-REC-002 Aprobar vacante.
- HR-REC-003 Publicar vacante.
- HR-REC-004 Registrar candidato y consentimiento.
- HR-REC-005 Gestionar pipeline.
- HR-REC-006 Programar entrevista.
- HR-REC-007 Registrar evaluación.
- HR-REC-008 Seleccionar candidato.
- HR-REC-009 Convertir a colaborador.

## Épica HR-LIFE-01 — Onboarding y offboarding

- HR-LIFE-001 Crear plantilla de checklist.
- HR-LIFE-002 Iniciar onboarding.
- HR-LIFE-003 Asignar tareas a responsables.
- HR-LIFE-004 Controlar documentos y capacitación.
- HR-LIFE-005 Completar onboarding.
- HR-LIFE-006 Iniciar offboarding.
- HR-LIFE-007 Revocar accesos y recuperar activos.

## Épicas posteriores

- HR-PERF-01 Ciclos de desempeño.
- HR-LRN-01 Catálogo y rutas de aprendizaje.
- HR-EXP-01 Clima y experiencia.
- HR-COMP-01 Bandas y revisiones salariales.
- HR-PAY-01 Novedades y reconciliación de nómina.
- HR-AN-01 Modelo analítico y Power BI.

## Criterios obligatorios por historia

Cada issue generado desde este backlog debe completar:

- Actor y resultado esperado.
- reglas funcionales.
- datos y clasificación.
- permisos.
- componentes Portal reutilizados.
- contratos y eventos.
- criterios de aceptación.
- pruebas.
- observabilidad.
- riesgos.
