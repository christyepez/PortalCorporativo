# Portal Smoke Idempotency Evidence

## Clean-stack mode

- Initial condition: Docker Compose stack stopped.
- Action: `scripts/smoke/sprint1-smoke.ps1` executed with local-only placeholder JWT secret.
- Result: passed.
- StartedByScript: true.
- Cleanup: script executed `docker compose down`.
- NotificationStatus: Sent.

## Existing-stack mode

- Initial condition: Docker Compose stack already running from `.env.example`.
- Action: `scripts/smoke/sprint1-smoke.ps1` executed with local-only placeholder JWT secret.
- Result: passed.
- StartedByScript: false.
- Cleanup: script did not stop the reused stack.
- Protected endpoint result: 401 accepted as expected protected behavior.
- NotificationStatus: AuthorizationExpected.

## Idempotency decision

The smoke script is safe to run against either a stopped stack or an already running stack. It only stops services it starts itself unless `-LeaveRunning` is used.
