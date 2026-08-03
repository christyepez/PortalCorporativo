# Portal Secret Provider Policy

## Policy

Portal secrets must not be stored in Git, frontend bundles, Docker Compose literals, documentation examples with real values, logs or committed `.env` files.

Sprint 14 prepares the policy only. Real provider activation is not allowed.

## Allowed in Sprint 14

- `.env.example` placeholders.
- logical secret names.
- local untracked `.env` for developer machines.
- documentation of future provider contracts.

## Not allowed in Sprint 14

- real Key Vault configuration.
- real AWS Secrets Manager configuration.
- real GCP Secret Manager configuration.
- real HashiCorp Vault configuration.
- real client_secret.
- real tokens.
- real certificates or private keys.
- real issuer/authority private URLs.
- secrets in frontend source.

## Runtime rule

Services may continue to fail closed when required local placeholders are missing. Production must wait for a future approved provider and rotation process.
