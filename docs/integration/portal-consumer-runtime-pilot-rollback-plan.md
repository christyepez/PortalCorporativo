# Consumer Runtime Pilot Rollback Plan

## Rollback triggers

- Gateway health degradation.
- CRM health contract failure.
- Missing correlation ID or unusable logs.
- Unauthorized route exposure.
- Unexpected CRM/Financiero runtime coupling.
- Any real secret, private URL or production provider appears.

## Rollback actions

1. Disable consumer route at the controlled Gateway configuration boundary.
2. Disable external navigation metadata.
3. Stop only the consumer pilot runtime if it was started by a later gate.
4. Keep Portal core services running when safe.
5. Collect local Seq logs and health evidence.
6. Record NoGo status and return to contract alignment.

Sprint 20 does not add a runtime toggle. This plan is documentary until the next gate approves controlled activation mechanics.
