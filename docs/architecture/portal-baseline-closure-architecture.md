# Portal Baseline Closure Architecture

## Closure view

```mermaid
flowchart TD
  p1["P1 Current State"] --> p2["P2 Deployment Baseline"]
  p2 --> p3["P3 Auth / SSO / Session"]
  p3 --> p4["P4 Menu / Permissions / Navigation"]
  p4 --> p5["P5 Audit / Configuration / Notification"]
  p5 --> p6["P6 Integration Shell / External Modules"]
  p6 --> p7["P7 Deployment Hardening"]
  p7 --> p8["P8 Closure Gate"]
  p8 --> p9["P9 Controlled Runtime Validation"]
```

## Baseline capabilities closed

- API Gateway foundation.
- Security and permission foundation.
- Menu and navigation metadata foundation.
- Audit, Configuration and Notification foundations.
- Worker and SQL Outbox/Inbox foundation.
- Health, readiness, logging and correlation foundation.
- External module onboarding contract.
- Deployment hardening documentation and guardrails.

## Architecture boundaries

- Production remains NoGo.
- CRM and Financiero remain consumers, not embedded runtime dependencies.
- Logical databases remain owned by each bounded context.
- Secret provider, SSO/OIDC and frontend shell buildability are future gates.
