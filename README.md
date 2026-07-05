# Portal Corporativo Platform

Repositorio base para una plataforma corporativa agnóstica al giro de negocio.

## Stack definido

- Backend: .NET 8 / ASP.NET Core
- Frontend: Angular
- Contenedores: Docker Compose
- Base de datos: SQL Server con bases por dominio
- Mensajería inicial: SQL Outbox + Workers
- Kafka: parametrizado para activación futura

## Objetivo

Construir una plataforma corporativa con login único, seguridad centralizada, menú dinámico, integración de aplicaciones, reportes, auditoría, notificaciones, contenidos, catálogos maestros y configuración visual administrable.

## Componentes principales

- Portal Angular
- API Gateway
- Security API
- Menu API
- Integration API
- Reporting API
- Audit API
- Notification API
- Content API
- Catalog API
- Configuration API

## Instrucciones para Codex

Leer primero:

1. `/codex/INSTRUCTIONS.md`
2. `/docs/01-arquitectura.md`
3. `/codex/TASKS.md`

No quemar en código menús, colores, logos, layouts, grids, acciones, permisos ni integraciones. Todo debe ser configurable y administrable.
