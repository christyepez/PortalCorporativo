# Portal subagent status

| Stream | State | Next action |
|---|---|---|
| 00 Orchestrator | ACTIVE | coordinate remaining gates |
| 01 Core Security & Multi-tenancy | ACTIVE | close Integration tenant mismatch guard + runtime E2E |
| 02 Portal Workspace & Frontend | READY | regression after backend runtime |
| 03 Platform Data | IMPLEMENTED | validate DB upgrade/runtime |
| 04 Integration Reliability | ACTIVE | test tenant guard + worker restart |
| 05 Observability & Operations | READY | verify/smoke/drift after rebuild |
| 06 Quality & E2E | ACTIVE | full validation |
| 07 Release Integration | BLOCKED | waits for green gates |

Primary machine: trabajo.
Do not sync MarketingIndo until all streams are green.
