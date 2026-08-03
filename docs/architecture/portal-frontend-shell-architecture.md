# Portal Frontend Shell Architecture

## Scope

The Sprint 10 shell is a minimal Angular application located at `frontend/`. It establishes a buildable frontend baseline without runtime coupling to consumer domains.

## Structure

- `frontend/package.json`: scripts and dependencies.
- `frontend/angular.json`: Angular build configuration.
- `frontend/src/main.ts`: standalone bootstrap.
- `frontend/src/app/app.component.*`: shell layout.
- `frontend/src/environments/*`: local relative configuration values.

## Runtime boundaries

- No login implementation.
- No browser credential persistence.
- No private API endpoint.
- No CRM runtime route.
- No Financiero runtime route.
- No production SSO/OIDC.
- No production secret provider.

## Integration posture

The shell displays placeholders for Portal platform capabilities. Dynamic Menu, Configuration, Security and external module navigation must be introduced through later controlled gates.
