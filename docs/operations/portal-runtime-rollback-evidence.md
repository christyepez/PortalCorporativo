# Portal Runtime Rollback Evidence

## Rollback scope

Rollback for Sprint 9 means stopping the controlled local Docker Compose stack without deleting volumes or real data.

## Evidence

- RollbackStopValidated: true.
- Command used: `docker compose --env-file .env.example down`.
- Destructive cleanup used: false.
- Volume deletion used: false.
- Real data deletion used: false.

## Notes

The Sprint 1 smoke script also contains a `finally { docker compose down }` cleanup path. Sprint 9 keeps rollback limited to service stop/removal and does not remove volumes.
