# Portal Secret Provider Placeholder Evidence

## Placeholder sources

`.env.example` is allowed to contain placeholder values only:

- `SQLSERVER_SA_PASSWORD=CHANGE_ME_...`
- `REDIS_PASSWORD=CHANGE_ME_...`
- `JWT_SECRET=CHANGE_ME_...`
- `MINIO_ROOT_USER=CHANGE_ME_...`
- `MINIO_ROOT_PASSWORD=CHANGE_ME_...`

## Compose behavior

Docker Compose reads placeholders through variables and fails closed when required values are not supplied. The file does not define real provider URLs or real credentials.

## Evidence decision

- PlaceholderFallbackDocumented: true.
- RealSecretsPresent: false.
- EnvRealFileCommitted: false.
- RealSecretProviderConfigured: false.
