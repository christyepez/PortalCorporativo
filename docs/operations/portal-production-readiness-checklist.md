# Portal Production Readiness Checklist

## Status

ProductionActivationDecision: NoGo.

This checklist is prepared for future use and does not approve production deployment.

## Required before production

- Approved architecture gate for production activation.
- Real secret provider selected and validated outside git.
- No `.env` committed.
- No real tokens, certificates, private URLs or data in repository files.
- Docker Compose or deployment manifests reviewed for environment-specific overrides.
- Health, live and ready endpoints validated in controlled runtime.
- Smoke tests executed against controlled non-production environment.
- API Gateway authorization policy reviewed for every route.
- CRM and Financiero external module routes remain disabled unless separately approved.
- SQL Server, Redis, MinIO and Seq ownership documented.
- Backup, restore, rollback and recovery drills completed.
- Observability dashboard and alert ownership assigned.
- Incident owner and release approver assigned.

## Exit criteria for a future production gate

- Build and tests pass from clean main.
- Deployment manifest renders without secret exposure.
- Readiness and smoke checks pass.
- Rollback plan has an identified previous version.
- Operational risks have owner and mitigation.
