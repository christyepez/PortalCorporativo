# Portal Deployment Baseline Risk Register

| Risk | Status | Impact | Mitigation |
| --- | --- | --- | --- |
| Production activation before Auth/SSO validation | Open | High | Keep `ProductionActivationDecision=NoGo`; P3 owns Auth/SSO/session baseline |
| Runtime Docker startup not yet proven in this gate | Open | Medium | Run `docker compose up -d --build` only in controlled local environment with local `.env` |
| Health endpoints differ between APIs | Open | Medium | Use `tools/check-portal-health.ps1` once runtime is up; normalize `/health`, `/health/live`, `/health/ready` in later sprint |
| Placeholder secrets used accidentally beyond local config validation | Open | High | `.env.example` is for config rendering only; real `.env` stays untracked |
| Frontend shell not buildable | Open | Medium | Create Angular package manifest in a later frontend sprint |
| Consumer integration drift | Open | High | CRM and Financiero must use Portal contracts/Gateway, not Portal databases or embedded logic |

No risk is waived for production.
