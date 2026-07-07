# Security API

Responsable de usuarios, roles, perfiles, permisos, sistemas, grupos, recursos y evaluación de autorización.

## Estado P2

Identity & Access Foundation implementa tenant `default`, usuarios, roles, permisos, recursos protegidos y asignaciones. La autenticacion local, emision de tokens y OAuth/OIDC quedan diferidos; no se almacenan contrasenas.

Todos los endpoints funcionales requieren JWT valido tanto en Gateway como en Security API. Health checks permanecen anonimos.

## Endpoints v1

| Metodo | Ruta | Contrato |
|---|---|---|
| POST | `/api/security/users` | `CreateUserRequest` |
| GET | `/api/security/users/{id}` | `UserResponse` |
| POST | `/api/security/roles` | `CreateRoleRequest` |
| POST | `/api/security/permissions` | `CreatePermissionRequest` |
| POST | `/api/security/users/{id}/roles` | `AssignRoleToUserRequest` |
| POST | `/api/security/roles/{id}/permissions` | `AssignPermissionToRoleRequest` |
| POST | `/api/security/resources` | `RegisterProtectedResourceRequest` |
| POST | `/api/security/check-permission` | `CheckPermissionRequest` |
| GET | `/api/security/users/{id}/permissions` | `UserPermissionsResponse` |
| GET | `/health` | Health report |

Las respuestas funcionales usan `ApiResponse<T>` e incluyen `correlationId`.

## Persistencia y seeds

La base `PortalSecurity` y el esquema `security` son exclusivos de este bounded context. El script inicial está en `infrastructure/sql/security/001-security-foundation.sql`. Docker local puede inicializar el modelo mediante `Security__InitializeDatabase=true`; otros entornos deben aplicar un mecanismo controlado de migracion/despliegue.

Seeds: tenant `default`, roles `SuperAdmin` y `PortalAdmin`, diez permisos y cinco recursos base del portal. Los endpoints funcionales exigen `portal.security.manage`; la matriz completa está en `docs/security/authorization-policy-matrix.md`.

## Consumidores

CRM, Financiero y futuros dominios deben registrar recursos/permisos y consultar decisiones mediante esta API. No deben crear usuarios, roles globales ni tablas de seguridad propias, ni acceder directamente a `PortalSecurity`.
