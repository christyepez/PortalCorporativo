# Seguridad, datos y cumplimiento

## Principios

- Mínimo privilegio.
- Denegación por defecto.
- Segregación de funciones.
- Seguridad aplicada en backend.
- Auditoría de lectura y escritura sensible.
- Cifrado en tránsito y reposo.
- Retención y eliminación controladas.
- Revisión humana para decisiones laborales sensibles.

## Modelo de autorización

La autorización combina:

```text
Usuario
+ permiso
+ tenant
+ empresa
+ sede
+ unidad organizacional
+ relación jerárquica
+ clasificación del dato
+ vigencia
```

## Permisos iniciales

```text
hr.organization.read
hr.organization.manage
hr.position.read
hr.position.manage
hr.employee.read
hr.employee.create
hr.employee.update
hr.employee.archive
hr.employee.personal-data.read
hr.employee.document.read
hr.employee.salary.read
hr.employee.medical.read
hr.employee.disciplinary.read
hr.leave.request
hr.leave.approve
hr.leave.admin
hr.recruitment.read
hr.recruitment.manage
hr.recruitment.approve
hr.performance.evaluate
hr.performance.calibrate
hr.learning.manage
hr.compensation.read
hr.compensation.manage
hr.compensation.approve
hr.payroll.export
```

## Clasificación de datos

| Nivel | Ejemplos | Controles |
|---|---|---|
| Público | Vacantes publicadas | Integridad y aprobación |
| Interno | Área, cargo, sede | Usuario autenticado |
| Confidencial | Datos personales, contrato | Permiso y alcance organizacional |
| Restringido | Salario, salud, disciplina | Permiso especial, MFA, auditoría de lectura |
| Crítico | Exportaciones masivas, nómina | Doble control, cifrado, trazabilidad reforzada |

## Auditoría obligatoria

- Consulta de salario.
- Consulta de documentos médicos.
- Consulta de acciones disciplinarias.
- Exportación de colaboradores.
- Creación y terminación de relaciones laborales.
- Cambio de cargo, posición, salario o jefe.
- Aprobación y rechazo de ausencias.
- Modificación de evaluaciones.
- Generación y envío de novedades de nómina.

## Privacidad

- Recopilar únicamente datos necesarios.
- Registrar finalidad y base de tratamiento.
- Mantener consentimiento de candidatos cuando corresponda.
- Restringir campos sensibles por rol.
- Enmascarar datos en logs.
- No incluir documentos ni datos personales en eventos salvo necesidad expresa.
- Definir retención diferenciada para candidatos, colaboradores y exempleados.

## Seguridad documental

Content/File API debe implementar:

- Clasificación.
- Autorización por entidad.
- Versionamiento.
- Hash de integridad.
- análisis antivirus.
- enlaces temporales.
- cifrado.
- auditoría de descarga y visualización.
- retención.
- eliminación lógica y proceso de purga.

## Segregación de funciones

Ejemplos:

- Quien propone un cambio salarial no debe aprobarlo en el mismo nivel.
- Quien administra plantillas de evaluación no debe alterar resultados cerrados.
- Soporte técnico no debe consultar salarios por defecto.
- Reclutadores no deben acceder a expedientes médicos.
- Jefaturas ven información de su equipo dentro del alcance autorizado.

## IA responsable

Los agentes de IA pueden:

- Resumir documentos.
- Sugerir descripciones.
- Generar borradores de preguntas.
- Detectar campos incompletos.
- Ayudar a clasificar solicitudes.

No pueden decidir autónomamente:

- Contratación o descarte.
- Terminación laboral.
- Sanciones.
- Ajustes salariales.
- Evaluación final.
- Elegibilidad legal.

Toda recomendación debe indicar sus fuentes, criterios y limitaciones.

## Revisión de seguridad por pull request

Se requiere revisión especializada cuando existan:

- Nuevos permisos.
- Datos sensibles.
- cambios de autenticación.
- exportaciones.
- integraciones externas.
- archivos.
- cambios salariales.
- reglas de nómina.
