# CRM Controlled Consumer Runtime Pilot Plan

## Scope

CRM is the first candidate for a future controlled runtime pilot. Sprint 20 does not activate CRM runtime. It defines the planning boundary that CRM must satisfy before Portal enables any controlled route.

## CRM prerequisites

- CRM base remains frozen at `ec0515e961c35ae0dab71aae4d85b43a65964e7f` until CRM resumes through its own repository workflow.
- CRM completes Sprint 10 P2 - Common DB Controlled Activation Plan.
- CRM prepares Portal Consumer Contract Alignment evidence.
- CRM confirms it consumes Portal Security, Menu, Permissions, Audit, Notification and Configuration contracts instead of duplicating them.

## Pilot shape

The future pilot is limited to NonProduction. Any documented consumer endpoint must remain logical or relative until the activation gate approves an actual route.

## Not activated

- No productive Gateway route.
- No productive external navigation.
- No CRM service in Portal Docker Compose.
- No CRM database or shared schema in Portal.
- No Portal production readiness.
