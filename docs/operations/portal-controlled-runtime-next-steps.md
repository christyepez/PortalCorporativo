# Portal Controlled Runtime Next Steps

## Goal

Prepare PortalSprint9ControlledRuntimeValidation.

## Required evidence

- Docker runtime startup in controlled non-production environment.
- API Gateway health readiness.
- API health checks for Security, Configuration, Menu, Audit, Notification, Catalog, Content, Integration and Reporting.
- Worker health checks.
- Smoke test execution with placeholder-only local values.
- Seq logs and correlation ID evidence.
- Rollback stop/start procedure evidence.

## Runtime restrictions

- Use untracked `.env` only.
- Use placeholders or local-only secrets.
- Do not use production URLs.
- Do not activate CRM/Financiero runtime routes.
- Do not activate production SSO/OIDC.
- Do not activate real notification providers.

## Exit criteria

Controlled runtime validation exits only when startup, readiness, smoke and rollback evidence are captured and reviewed.
