# Portal Auth / SSO / Session Baseline

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

## Current Foundation

Portal currently validates JWT bearer tokens in the API Gateway and core APIs. Permission policies are provided by `AddPortalPermissionAuthorization` and require authenticated users with a `permission` claim matching the Portal permission code.

This is a foundation for authorization validation only. It is not a production SSO/OIDC activation decision.

## Production NoGo

Production Auth/SSO remains blocked until:

- OIDC/OAuth2 provider selection and metadata are approved.
- Client secrets are sourced only from a secret provider.
- Token/session storage policy is validated end to end.
- Logout, refresh, expiration and revocation behavior are tested.
- CRM and Financiero consume published Portal Auth contracts through Gateway; they do not own identity.

## Consumer Boundary

CRM and Financiero must not implement their own login, user directory, role ownership or permission engine. They may register resources/permissions and consume Portal-issued identity/authorization context once the Portal Auth contract is approved.
