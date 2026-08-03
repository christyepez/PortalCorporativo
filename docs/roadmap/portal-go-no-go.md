# Portal GO / NO-GO

## Current decision

ProductionActivationDecision: NoGo.

PortalProductionReady: false.

## GO for next stage

Portal is GO for controlled runtime validation:

- render Docker Compose config;
- start local/non-production runtime only with untracked placeholders;
- validate health/readiness;
- execute smoke tests;
- collect evidence without production activation.

## NO-GO for production

Portal is NO-GO for production because:

- runtime Docker startup has not been validated in a controlled environment for this closure gate;
- health and smoke checks are pending controlled runtime evidence;
- frontend shell is not buildable;
- production SSO/OIDC is not configured;
- production secret provider is not configured;
- real notification providers are not configured;
- CRM/Financiero onboarding is contract-only and not runtime-enabled.

## Required future approval

Any production promotion requires a new gate and explicit approval after controlled runtime validation succeeds.
