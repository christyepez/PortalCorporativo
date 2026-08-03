# Portal to CRM Future Runtime Pilot Exit Criteria

The future CRM runtime pilot can exit only after a later gate proves:

- CRM route is explicitly approved for controlled NonProduction.
- CRM navigation is explicitly approved for controlled NonProduction.
- CRM health checks pass through the approved route.
- CRM permissions are validated through Portal Security.
- CRM audit events are accepted through Portal Audit.
- CRM configuration reads use Portal Configuration boundaries.
- CRM notifications use Portal Notification contracts.
- Correlation IDs are visible in Portal logs.
- Rollback disables route and navigation cleanly.
- No production provider, private URL, real secret, token, certificate, shared DB or cross migration exists.

FutureRuntimePilotExitCriteriaPrepared: true.
