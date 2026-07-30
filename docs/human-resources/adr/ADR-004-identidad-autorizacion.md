# ADR-004: Identidad y autorización

- Estado: Proposed
- Fecha: 2026-07-30

## Contexto

El Portal ya dispone de Security API foundation, pero requiere identidad productiva. Talento Humano maneja datos cuyo acceso depende de permisos, organización, jerarquía y clasificación.

## Decisión

Microsoft Entra ID será el proveedor de identidad mediante OIDC/OAuth 2.0. Security API administrará recursos y permisos globales. HR aplicará adicionalmente alcance organizacional y clasificación del dato.

## Consecuencias

- Inicio de sesión institucional.
- Autorización consistente.
- Necesidad de mapear identidad externa, usuario Portal y colaborador.
- Políticas contextuales más complejas.

## Restricciones

- La UI no es frontera de seguridad.
- Datos restringidos requieren permisos específicos y auditoría de lectura.
- Cambios de autenticación o autorización requieren revisión de seguridad.
