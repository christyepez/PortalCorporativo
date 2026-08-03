# Portal Controlled NonProduction Environment Guide

## Local `.env`

Create a local `.env` by copying `.env.example`. The `.env` file must stay unversioned.

```powershell
Copy-Item .env.example .env
```

Replace `CHANGE_ME` values only for the controlled NonProduction environment. Do not use real production secrets, real tokens, real certificates or private provider URLs.

## Required posture

- EnvRealFileCommitted: false.
- SecretsPresent: false.
- PrivateUrlsPresent: false.
- SsoOidcProductionConfigured: false.
- RealSecretProviderConfigured: false.
- RealNotificationProvidersConfigured: false.

## Ports

If a port is unavailable, change the local `.env` value. Do not edit Compose just to solve a workstation port conflict.
