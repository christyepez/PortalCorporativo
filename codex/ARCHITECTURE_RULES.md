# Reglas de arquitectura

1. Cada API representa un bounded context.
2. La comunicación entre dominios debe hacerse por API o eventos.
3. Todo evento debe tener correlationId.
4. Todo acceso a recurso debe auditarse.
5. Todo recurso visible debe existir en Security API.
6. Todo recurso abierto debe validarse nuevamente en backend.
7. Los tokens reales no deben viajar por URL.
8. Los parámetros visuales deben ser configurables.
9. Los catálogos críticos deben versionarse y aprobarse antes de publicarse.
10. Los contratos JSON entre servicios deben versionarse.
