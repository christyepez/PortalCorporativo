# Visión y alcance

## Visión

Construir una plataforma de Talento Humano integrada al Portal Corporativo que centralice la experiencia del colaborador, permita administrar el ciclo laboral completo y reutilice seguridad, navegación, configuración, auditoría, notificaciones, archivos, aprobaciones e integraciones comunes.

## Objetivos

- Consolidar una fuente funcional de colaboradores y estructura organizacional.
- Proporcionar autoservicio a colaboradores y jefaturas.
- Digitalizar expedientes, solicitudes, aprobaciones y trazabilidad.
- Integrar aplicaciones existentes sin reemplazos abruptos.
- Incorporar analítica y automatización progresiva.
- Reducir duplicación técnica entre módulos del Portal.
- Automatizar la implementación con agentes Codex especializados.

## Alcance funcional objetivo

- Organización, cargos y posiciones.
- Personas, colaboradores y relaciones laborales.
- Expediente digital.
- Reclutamiento y selección.
- Onboarding, movilidad y offboarding.
- Horarios, asistencia, permisos y vacaciones.
- Desempeño, objetivos y competencias.
- Aprendizaje y desarrollo.
- Clima, bienestar y experiencia.
- Compensación y beneficios.
- Integración de nómina.
- Analítica de talento.

## Alcance inicial

La primera entrega operativa incluirá:

1. Estructura organizacional.
2. Cargos y posiciones.
3. Maestro de colaboradores.
4. Relaciones laborales.
5. Perfil y autoservicio básico.
6. Expediente digital, condicionado a Content/File API.
7. Vacaciones y permisos, condicionados a Workflow y Task Inbox.
8. Auditoría, seguridad, notificaciones y menú reutilizados del Portal.

## Fuera del alcance inicial

- Motor propio completo de nómina ecuatoriana.
- Aplicación móvil nativa.
- Sustitución inmediata del biométrico, ERP o LMS.
- Inteligencia artificial tomando decisiones laborales autónomas.
- Acceso directo entre bases de datos de bounded contexts.

## Supuestos

- El Portal es el contenedor principal de navegación y experiencia.
- Microsoft Entra ID será el proveedor de identidad productivo.
- El sistema actual de nómina continuará operando durante las primeras fases.
- Power BI será la capa principal de analítica ejecutiva.
- Docker Compose se utilizará para desarrollo y ambientes iniciales.
- `christyepez/CodexCommonAgents` continuará como repositorio común de agentes.

## Criterios de éxito

- Cero duplicación de autenticación, menú, auditoría, notificaciones y archivos.
- Al menos 70 % de reutilización en capacidades transversales.
- Trazabilidad completa de operaciones sensibles.
- Flujos configurables, no codificados por cada solicitud.
- Pruebas automatizadas y quality gates en cada pull request.
- Implementación incremental con entregas funcionales por dominio.
