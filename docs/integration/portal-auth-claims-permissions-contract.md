# Portal Auth Claims and Permissions Contract

## Canonical permission claim

Authorization uses repeatable claim:

```text
permission
```

Each claim value must be a permission code registered in Portal Security.

## Current platform permissions

- `portal.security.manage`
- `portal.configuration.manage`
- `portal.configuration.read`
- `portal.menu.manage`
- `portal.menu.read`
- `portal.audit.read`
- `portal.audit.write`
- `portal.notification.manage`
- `portal.notification.send`
- `portal.notification.read`

## Token validation expectations

Backends must validate:

- issuer.
- audience.
- signing key or trusted metadata.
- lifetime.
- permission claim integrity.

## Future consumer permissions

CRM and Financiero permissions must be registered as domain resources in Portal Security. They must not be hardcoded as frontend-only checks.

## Not accepted

- unsigned tokens.
- client-supplied claims without trusted validation.
- frontend-only authorization.
- localStorage/sessionStorage token storage.
