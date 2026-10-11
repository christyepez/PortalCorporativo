# PROD-local final baseline

Date: 2026-10-11

## Baseline

PortalCorporativo remains a local Docker Desktop deployment. The canonical branch is `main`.

## Access

- Portal shell: `http://127.0.0.1:4200/`
- API Gateway: `http://127.0.0.1:8080/`
- Administration is part of the Portal shell, not a separate web application. Use the left navigation for Security, Menus, Parameters, Catalogs, Content, Audit, Reports, Notifications, Integration and Operations.

## Local administration authentication

The current PROD-local administration baseline does not use a seeded username/password login. Administrative modules use an ephemeral local JWT session entered from Security. The token remains in browser memory only and is cleared on refresh or explicit local-session logout.

Do not store local JWTs or secret values in source control or documentation.

## Operational baseline

The local environment includes:

- scheduled backup and maintenance with wake/retry/dependency controls;
- consolidated operations status and deep runtime verification;
- restart-delta validation;
- backup integrity validation;
- non-destructive recovery validation;
- opt-in temporary restore recovery drill using isolated `PortalRecovery_*` databases;
- authenticated smoke and observability checks.

Success marker for the consolidated deep status:

`PORTAL_PROD_LOCAL_OPERATIONS_STATUS_PASS`
