# Portal Menu / Permissions Policy

## Decision

- MenuBaselineReviewed: true.
- PermissionsBaselineReviewed: true.
- ProductionActivationDecision: NoGo.
- MenuFoundationPresent: true.
- SecurityPermissionsFoundationPresent: true.
- PermissionPoliciesPresent: true.
- ProductiveExternalModuleNavigationEnabled: false.

## Ownership

Portal owns menu metadata, protected resources, permission codes and backend authorization policy enforcement. Consumer domains such as CRM and Financiero may request module registration through documented contracts, but they must not own the global menu engine or permission engine.

## Runtime Policy

- Menu API endpoints require Portal permission policies.
- Menu visibility for a user is filtered through Security permission checks.
- Gateway routes must remain protected by an authorization policy.
- External module navigation stays disabled for production until the consumer module contract is approved.

## Forbidden

- Real user/role/customer data in seeded menu metadata.
- Private URLs in navigation records.
- Direct runtime coupling to CRM or Financiero.
- Consumer databases sharing Portal menu/security tables.
