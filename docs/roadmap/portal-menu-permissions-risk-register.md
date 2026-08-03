# Portal Menu / Permissions Risk Register

| Risk | Status | Impact | Mitigation |
| --- | --- | --- | --- |
| Consumer modules bypass Portal permissions | Open | High | Consumers must register resources/permissions through Portal contracts |
| External navigation enabled with private routes | Open | High | P4 forbids private URLs and keeps external productive navigation disabled |
| CRM/Financiero duplicate menu engines | Open | High | Portal owns global navigation; consumers provide metadata only |
| Role/permission seeds contain real user data | Open | High | Seeds must remain platform placeholders and non-production metadata |
| Frontend shell unavailable | Open | Medium | Keep route rendering pending until Angular shell exists |
| Gateway authorization drift | Open | Medium | Verify `AuthorizationPolicy: default` in gateway route config |

No risk is waived for production.
