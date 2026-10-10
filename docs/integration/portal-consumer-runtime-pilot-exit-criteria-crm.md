# CRM Controlled Consumer Runtime Pilot Exit Criteria

The future CRM pilot may exit successfully only when all criteria below are met in NonProduction:

- Gateway controlled route is explicitly approved by a later gate.
- CRM health endpoint returns healthy through the agreed route.
- Portal correlation ID is propagated or mapped.
- Portal audit receives required consumer events through the contract.
- Portal menu/navigation displays only approved CRM metadata.
- CRM permissions are evaluated through Portal Security contracts.
- Rollback disables the CRM pilot route and navigation without data loss.
- No production provider, private URL, real secret or shared database is introduced.

Sprint 20 does not claim these criteria are already satisfied. It only defines them.


## Current automated decision

The current PROD-local automated decision is **NOGO / fail-closed**. The P25 gate is considered healthy when it proves that CRM remains inside the documented safety boundary while the real Portal runtime client is disabled.

A future GO requires an explicit implementation change plus updated runtime evidence for the existing exit criteria. The gate must not infer or auto-promote GO from documentation alone.
