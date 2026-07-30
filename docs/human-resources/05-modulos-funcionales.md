# Módulos funcionales

## HR.Core

Responsable del núcleo organizacional y laboral.

### Capacidades

- Empresas, sedes y unidades organizacionales.
- Organigramas.
- Cargos y perfiles.
- Posiciones y plazas.
- Personas y colaboradores.
- Relaciones laborales.
- Contactos y direcciones.
- Información académica y experiencia.
- Historial de movimientos.
- Acciones de personal.

### Entidades principales

```text
Organization
OrganizationUnit
Job
Position
Person
Employee
Employment
Assignment
EmployeeMovement
```

## HR.Recruitment

- Solicitud y aprobación de vacantes.
- Publicación interna y externa.
- Candidatos y postulaciones.
- Pipeline de selección.
- Entrevistas y evaluaciones.
- Referencias.
- Oferta laboral.
- Selección y conversión a colaborador.

## HR.EmployeeLifecycle

- Preboarding.
- Onboarding.
- Checklists.
- Documentos requeridos.
- Creación de accesos.
- Entrega de activos.
- Inducción.
- Periodo inicial.
- Movilidad interna.
- Offboarding.
- Revocación de accesos y devolución de activos.

## HR.Time

- Calendarios laborales.
- Jornadas y turnos.
- Integración de marcaciones.
- Vacaciones.
- Permisos.
- Licencias.
- Horas extras.
- Teletrabajo.
- Saldos.
- Novedades para nómina.

## HR.Performance

- Ciclos de evaluación.
- Objetivos.
- Competencias.
- Modelos 90, 180 y 360.
- Retroalimentación.
- Calibración.
- Planes de mejora.
- Planes de desarrollo.
- Historial de desempeño.

## HR.Learning

- Catálogo de cursos.
- Rutas de aprendizaje.
- Inscripciones.
- Asistencia.
- Evaluaciones.
- Certificados.
- Vencimientos.
- Proveedores.
- Presupuesto.
- Integración con LMS.

## HR.EmployeeExperience

- Encuestas de clima.
- Pulsos organizacionales.
- eNPS.
- Reconocimientos.
- Bienestar.
- Beneficios informativos.
- Casos y solicitudes al área.
- Comunicación segmentada.

## HR.Compensation

- Bandas salariales.
- Componentes de compensación.
- Historial salarial.
- Revisiones.
- Presupuestos.
- Bonos.
- Beneficios.
- Aprobaciones.
- Costo empresa.

## HR.PayrollIntegration

Primera estrategia: integrar, no reemplazar.

- Novedades.
- Validación previa.
- Envío al sistema de nómina.
- Recepción de resultados.
- Roles de pago.
- Reconciliación.
- Contabilización.
- Archivos bancarios cuando corresponda.

## HR.Analytics

- Headcount.
- Rotación.
- Ausentismo.
- Tiempo de contratación.
- Cumplimiento de onboarding.
- Desempeño.
- Aprendizaje.
- Clima.
- Compensación.
- Costos.

La analítica histórica se publicará hacia la plataforma de datos y Power BI; no se resolverá mediante consultas operativas complejas sobre las bases transaccionales.

## Dependencias entre módulos

```text
HR.Core
├── Recruitment
├── EmployeeLifecycle
├── Time
├── Performance
├── Learning
├── EmployeeExperience
├── Compensation
└── PayrollIntegration
```

Los módulos no compartirán tablas. Consumirán contratos publicados o vistas de lectura específicamente diseñadas, evitando acoplamiento transaccional.

## Orden de implementación

1. HR.Core.
2. Expediente y autoservicio.
3. HR.Time.
4. HR.Recruitment.
5. HR.EmployeeLifecycle.
6. HR.Performance.
7. HR.Learning.
8. HR.EmployeeExperience.
9. HR.Compensation.
10. HR.PayrollIntegration.
11. HR.Analytics incremental desde la primera fase.
