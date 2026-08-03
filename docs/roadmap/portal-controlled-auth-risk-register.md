# Portal Controlled Auth Risk Register

| Risk | Impact | Status | Mitigation |
| --- | --- | --- | --- |
| Future SSO/OIDC provider details are incomplete | Production auth cannot be safely enabled. | Open | Defer real authority, issuer, client_id and secret sourcing to later gates. |
| Browser token storage is introduced accidentally | Tokens may leak through localStorage/sessionStorage. | Guarded | Sprint 13 guardrail scans frontend source for browser token storage. |
| Permission claims diverge from Security API | Gateway/API policy decisions may become inconsistent. | Controlled | Contract fixes repeatable `permission` claim as the canonical authorization claim. |
| Consumer apps bypass Portal Auth | CRM/Financiero could duplicate identity concerns. | Guarded | Consumer contract requires reuse of Portal Security and forbids local login duplication. |
| Secret provider is not ready | SSO secrets cannot be loaded safely. | Open | Next gate is `PortalSprint14SecretProviderPreparation`. |
