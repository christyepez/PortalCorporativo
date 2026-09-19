param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [string]$ReportPath
)

$ErrorActionPreference = 'Stop'

$validator = Join-Path $PSScriptRoot 'validate-activation-inputs.ps1'
if (-not (Test-Path -LiteralPath $Path)) {
    Write-Output 'ACTIVATION_INPUT_REVIEW_BLOCKED'
    exit 2
}

$raw = Get-Content -LiteralPath $Path -Raw
try {
    $data = $raw | ConvertFrom-Json
}
catch {
    Write-Output 'ACTIVATION_INPUT_REVIEW_BLOCKED'
    exit 1
}

$shellExe = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }
$validatorOutput = & $shellExe -NoProfile -ExecutionPolicy Bypass -File $validator -Path $Path 2>&1
$validatorExitCode = $LASTEXITCODE
$preflightPass = $validatorExitCode -eq 0 -and (($validatorOutput -join [Environment]::NewLine) -match 'PRODUCTION_ACTIVATION_PREFLIGHT_PASS')

$hash = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
$reviewStatus = if ($preflightPass) { 'ReadyForHumanReview' } else { 'BlockedByPreflight' }

$report = [ordered]@{
    generatedAtUtc = [DateTimeOffset]::UtcNow.ToString('O')
    inputSha256 = $hash
    preflightStatus = if ($preflightPass) { 'Pass' } else { 'NoGo' }
    reviewStatus = $reviewStatus
    approvals = [ordered]@{
        architecture = [string]$data.approvals.architecture
        security = [string]$data.approvals.security
        operations = [string]$data.approvals.operations
    }
    guardrails = [ordered]@{
        realSriTransmission = [bool]$data.guardrails.realSriTransmission
        browserTokenPersistence = [bool]$data.guardrails.browserTokenPersistence
        secretsInRepository = [bool]$data.guardrails.secretsInRepository
    }
    evidenceRequired = @(
        'Identity registration evidence',
        'Secret provider ownership and rotation evidence',
        'Network and DNS approval evidence',
        'Backup and restore ownership evidence',
        'Release and rollback approval evidence'
    )
    note = 'This report intentionally excludes endpoint values, identifiers and credentials.'
}

if ($ReportPath) {
    $parent = Split-Path -Parent $ReportPath
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $ReportPath -Encoding UTF8
}

if ($preflightPass) {
    Write-Output 'ACTIVATION_INPUT_REVIEW_READY_FOR_REVIEW'
    exit 0
}

Write-Output 'ACTIVATION_INPUT_REVIEW_BLOCKED'
exit 1
