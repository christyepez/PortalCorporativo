# Instrucciones para Codex

Stack definido:

- Backend: .NET 8 / ASP.NET Core.
- Frontend: Angular.
- Contenedores: Docker Compose.
- Arquitectura: Clean Architecture, DDD y SOLID.
- Datos: SQL Server con bases por dominio lógico.
- Eventos iniciales: SQL Outbox.
- Kafka: preparado para una fase futura.

Principios:

- La configuración visual y funcional debe venir desde APIs.
- El portal debe ser agnóstico al giro de negocio.
- El frontend renderiza menús, grids, acciones y formularios desde metadata.
- La seguridad y autorización se resuelve en backend.
- Aplicar pruebas unitarias, integración, contrato y rendimiento.
