# Configuration y Menu

## Configuración efectiva

Los valores se evalúan `global -> tenant -> module -> user`; el último valor activo gana. CRM y Financiero crean overrides con sus códigos de módulo y consumen `/api/configuration/effective`; no almacenan secretos ni permisos en metadata.

Categorías: visual, funcional, grid, formulario, acción, layout y tema. Cada actualización incrementa versión. Los cambios generan `ConfigurationChangedV1` mediante un puerto de plataforma.

## Menú dinámico

Los módulos registran menús e ítems con rutas, jerarquía, orden, icono, recurso y permiso. `/api/menu/user/{userId}` consulta Security para cada recurso/acción; ocultar un ítem no reemplaza autorización backend.

Seeds: módulo Portal, menú Administración, Seguridad, Configuración, Auditoría y Notificaciones; acciones Ver, Crear, Editar y Desactivar.

## Diferido

UI Angular administrativa, historial completo de versiones, Outbox transaccional local por contexto, Audit HTTP resiliente, caching y multi-tenant real quedan para Sprint 2.
