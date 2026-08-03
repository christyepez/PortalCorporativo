# Portal NonProduction Release Candidate Architecture

```mermaid
flowchart LR
  Gateway["API Gateway"] --> Security["Security API"]
  Gateway --> Config["Configuration API"]
  Gateway --> Menu["Menu API"]
  Gateway --> Audit["Audit API"]
  Gateway --> Notification["Notification API"]
  Worker["Notification Worker"] --> Notification
  Sql["Single local SQL Server container"] --> Security
  Sql --> Config
  Sql --> Menu
  Sql --> Audit
  Sql --> Notification
  Frontend["Frontend shell"] -. nonproduction shell .-> Gateway
  Consumers["CRM / Financiero"] -. contract only .-> Gateway
```

## RC architecture posture

- Portal services run as a self-contained NonProduction stack.
- Consumers remain contract-only.
- The local SQL Server container is shared infrastructure only; logical Portal databases remain separated.
- No CRM or Financiero service is part of the Portal Compose runtime.
- No production SSO/OIDC, Secret Provider or Notification Provider is enabled.

## Promotion boundary

Sprint 17 approves only the next package gate: `PortalSprint18ControlledNonProductionDeploymentPackage`.
