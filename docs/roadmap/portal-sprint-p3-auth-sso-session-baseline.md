# Portal Sprint P3 - Auth / SSO / Session Baseline

## Decision

- PortalSprintP3AuthSsoSessionBaselineExists: true.
- AuthBaselineReviewed: true.
- ProductionActivationDecision: NoGo.
- SsoProductionActivationDecision: NoGo.
- JwtFoundationPresent: true.
- PermissionPoliciesPresent: true.
- OidcProviderConfiguredForProduction: false.
- RealClientSecretsPresent: false.
- RealTokensPresent: false.
- RealCertificatesPresent: false.
- PrivateUrlsPresent: false.
- TokenStorageInLocalStorageAllowed: false.
- TokenStorageInSessionStorageAllowed: false.
- CookiesPolicyPendingValidation: true.
- SessionTimeoutPolicyPendingValidation: true.
- LogoutFlowPendingValidation: true.
- CrmAuthIntegrationReadiness: PendingPortalAuthContract.
- FinancialAuthIntegrationReadiness: PendingPortalAuthContract.
- AuthSsoReadiness: BaselinePreparedNotProductionReady.
- NextGate: PortalSprintP4MenuPermissionsNavigationBaseline.

## Evidence

- Gateway and Security API use JWT Bearer authentication.
- Gateway routes use YARP `AuthorizationPolicy: default`.
- Portal permission policies are centralized in building blocks.
- No production OIDC provider, client secret, real token, certificate or private URL is added by P3.
- Browser token storage remains forbidden and unimplemented.

## Gate Result

Proceed to `PortalSprintP4MenuPermissionsNavigationBaseline` only for menu/permissions/navigation baseline work. Production remains NoGo.
