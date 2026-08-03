# Portal Sprint P4 - Menu / Permissions / Navigation Baseline

## Decision

- PortalSprintP4MenuPermissionsNavigationBaselineExists: true.
- MenuBaselineReviewed: true.
- PermissionsBaselineReviewed: true.
- NavigationBaselineReviewed: true.
- ProductionActivationDecision: NoGo.
- MenuFoundationPresent: true.
- SecurityPermissionsFoundationPresent: true.
- PermissionPoliciesPresent: true.
- GatewayAuthorizationPolicyPresent: true.
- ConsumerModuleNavigationContractPrepared: true.
- CrmNavigationReadiness: PendingPortalConsumerContract.
- FinancialNavigationReadiness: PendingPortalConsumerContract.
- ProductiveExternalModuleNavigationEnabled: false.
- RealRoutesPresent: false.
- PrivateUrlsPresent: false.
- RealUserRoleDataPresent: false.
- MenuPermissionReadiness: BaselinePreparedNotProductionReady.
- NextGate: PortalSprintP5AuditConfigurationNotificationBaseline.

## Evidence

- Menu domain/application/contracts/infrastructure/API projects exist.
- Menu API uses JWT bearer authentication and `AddPortalPermissionAuthorization`.
- Menu endpoints require `portal.menu.manage` or `portal.menu.read`.
- Security API provides resources, permissions and `check-permission`.
- Gateway YARP routes use `AuthorizationPolicy: default`.
- Existing seeded menu routes are internal Portal administration placeholders only.

## Gate Result

P4 prepares the consumer module navigation contract but does not enable production external navigation for CRM or Financiero.
