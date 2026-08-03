# Portal Auth / SSO Risk Register

| Risk | Status | Impact | Mitigation |
| --- | --- | --- | --- |
| Symmetric JWT foundation mistaken for production SSO | Open | High | Keep SSO production NoGo until OIDC provider and secret store are approved |
| Tokens stored in browser-readable storage | Open | High | Forbid `localStorage` and `sessionStorage` token storage; validate once frontend exists |
| Client secrets committed to Git | Open | High | Use guardrail scripts and secret-provider-only policy |
| CRM or Financiero creates duplicate Auth | Open | High | Consumers may extend resources/permissions only; Portal owns Auth |
| Logout/revocation behavior undefined | Open | Medium | P3 marks logout and session timeout as pending validation |
| Gateway authorization drift | Open | Medium | Keep routes protected and validate policy config before runtime rollout |

No risk is waived for production.
