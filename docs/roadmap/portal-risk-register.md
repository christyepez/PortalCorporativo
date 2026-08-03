# Portal Risk Register

| Risk | Status | Impact | Mitigation |
| --- | --- | --- | --- |
| Production activation before Auth/SSO validation | Open | High | Keep `ProductionActivationDecision=NoGo` until SSO/OIDC and secret handling are validated |
| Frontend shell not buildable | Open | Medium | Create/validate Angular shell in a later sprint before UI rollout |
| Local `.env` required for runtime | Open | Medium | Keep `.env.example` only in Git and document secret provisioning |
| Docker startup not validated in P1 | Open | Medium | Run controlled deployment baseline in P2 with local non-secret placeholders |
| Consumer integration drift | Open | High | CRM and Financiero must onboard through Portal contracts, not direct DB/shared logic |
| Compose health checks may not match every API route | Open | Medium | Validate health endpoints per service during P2 |
| Catalog/Content/Reporting/Integration production maturity pending | Open | Medium | Gate each capability before consumer production use |

No production blocker is waived by this document.
