# Portal Baseline Closure Runbook

## Purpose

Close the PortalCorporativo baseline stage without activating production.

## Closure steps

1. Confirm `main` contains the approved P7 merge.
2. Review P1-P7 evidence documents.
3. Verify `codex/TASKS.md` contains P1-P7 gate history.
4. Run all available guardrails and foundation verifiers.
5. Build and test backend solution.
6. Render Docker Compose config with `.env.example`.
7. Confirm no real `.env`, secrets, tokens, certificates, private URLs or real data are present.
8. Record P8 closure decision.

## Do not do in P8

- Do not start production.
- Do not require runtime Docker up.
- Do not execute real health/smoke runtime as a closure requirement.
- Do not activate SSO/OIDC or secret provider runtime.
- Do not activate CRM/Financiero routes or navigation.

## Expected result

Baseline closes as preparation-only and proceeds to controlled runtime validation.
