# Portal Rollback / Recovery Runbook

## Status

RollbackRunbookPrepared: true.
RecoveryRunbookPrepared: true.
ProductionActivationDecision: NoGo.

## Rollback principles

- Roll back to a known Git commit or released image tag.
- Do not rewrite git history.
- Do not delete persisted volumes during rollback unless explicitly approved.
- Keep database rollback separate from application rollback.
- Preserve logs and correlation IDs for incident analysis.

## Minimal rollback steps

1. Identify current commit, image tags and deployment manifest.
2. Identify last known good commit or image tag.
3. Stop only affected services.
4. Deploy last known good artifact.
5. Validate `/health/live` and `/health/ready`.
6. Run smoke checks.
7. Record incident timeline and recovery evidence.

## Recovery considerations

- SQL Server, Redis, MinIO and Seq data recovery must use environment-approved backup procedures.
- Portal services must not restore CRM or Financiero data.
- Cross-domain recovery requires explicit owner approval.
- Secrets must be rotated outside git if exposure is suspected.

## P7 limitation

This runbook is baseline only. No production rollback drill is executed in P7.
