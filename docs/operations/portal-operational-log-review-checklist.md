# Portal Operational Log Review Checklist

Use this checklist after controlled NonProduction deploy or smoke validation.

- Confirm the stack was started from the approved NonProduction package.
- Capture `docker compose --env-file .env.example logs --tail 150`.
- Open local Seq through the configured local port.
- Filter by `CorrelationId` from smoke output.
- Review `Error` and `Warning` events.
- Confirm no CRM/Financiero runtime route appears.
- Confirm no external provider delivery appears.
- Confirm no private URL, real token, certificate or real secret appears.
- Confirm health endpoints returned 200 through Gateway.

LogReviewChecklistPrepared: true.
