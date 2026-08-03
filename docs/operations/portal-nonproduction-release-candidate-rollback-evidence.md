# Portal NonProduction Release Candidate Rollback Evidence

## Rollback action

The RC validation requires stopping the local stack after health and smoke validation:

```powershell
docker compose --env-file .env.example down
```

## Expected result

- RollbackStopValidated: true.
- StackStoppedAfterValidation: true.
- No Portal containers remain running after validation.

## Production note

This rollback evidence is for local controlled NonProduction only. Production rollback remains out of scope and must be defined in a future production gate.
