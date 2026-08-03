# Portal to CRM Contract Alignment GO/NO-GO

## Decision

GO for CRM to start planning in its own repository from the Portal contract package.

NoGo for runtime activation, production activation, real CRM Gateway routes, real CRM navigation, CRM service in Portal Compose, shared database, cross-domain migrations, real secrets, private URLs or real providers.

## Current status

- PortalToCrmContractAlignmentReadiness: ReadyForCrmP2Planning.
- ProductionActivationDecision: NoGo.
- PortalProductionReady: false.
- ProductiveCrmGatewayRoutesEnabled: false.
- ProductiveCrmNavigationEnabled: false.
- CrmRuntimeCouplingEnabled: false.
- CrmServiceInPortalCompose: false.
- SharedDatabaseWithCrmPresent: false.
- CrossDomainMigrationsPresent: false.
- RealCrmPrivateUrlsPresent: false.

## Next gate

CRM must execute `CrmSprint10P2CommonDbControlledActivationPlan` in the CRM repository without duplicating Portal Auth, Menu, Permissions, Audit, Notification, Configuration, Secret Provider or Notification Provider capabilities.
