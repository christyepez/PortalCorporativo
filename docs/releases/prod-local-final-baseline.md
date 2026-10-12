# PROD-local final baseline

Date: 2026-10-11

## Baseline

PortalCorporativo remains a local Docker Desktop deployment. The canonical branch is `main`.

## Access

- Portal shell: `http://127.0.0.1:4200/`
- API Gateway: `http://127.0.0.1:8080/`
- Administration is part of the Portal shell, not a separate web application. Use the left navigation for Security, Menus, Parameters, Catalogs, Content, Audit, Reports, Notifications, Integration and Operations.

## Local administration authentication

The current PROD-local administration baseline does not use a seeded username/password login and does not require the operator to paste a JWT. The Portal requests a short-lived SuperAdmin session from the Security API through the Gateway only when the PROD-local overlay explicitly enables `PortalLocalAdmin`. The JWT permissions are read from the current `SuperAdmin` role assignments in Security DB, remain in browser memory only, and are cleared on refresh or explicit local-session logout.

CRM, Financiero, Talento Humano and HistoriasPaolin are governed as Portal applications. Each application declares its module code, required permission, Gateway boundary and health/protected surface. Applications that do not publish a separate local web UI render a native workspace inside the Portal with links to Security, Menu, Parameters and Operations plus protected data through the Gateway; real web UIs may be embedded when explicitly registered.

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
