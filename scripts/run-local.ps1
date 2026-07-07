$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$environmentFile = Join-Path $repositoryRoot '.env'

if (-not (Test-Path -LiteralPath $environmentFile)) {
    throw 'Create .env from .env.example and replace every CHANGE_ME value before running locally.'
}

docker compose --project-directory $repositoryRoot --env-file $environmentFile up --build -d
docker compose --project-directory $repositoryRoot --env-file $environmentFile ps
