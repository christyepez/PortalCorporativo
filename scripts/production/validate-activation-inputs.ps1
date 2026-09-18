param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Error "Activation input file not found."
    exit 2
}

$raw = Get-Content -LiteralPath $Path -Raw
try {
    $data = $raw | ConvertFrom-Json
}
catch {
    Write-Output 'FAIL input-file - invalid JSON'
    Write-Output 'PRODUCTION_ACTIVATION_PREFLIGHT_NOGO'
    exit 1
}
$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure([string]$Field, [string]$Reason) {
    $failures.Add("$Field - $Reason")
}

function Is-UsableText($Value) {
    $text = [string]$Value
    if ([string]::IsNullOrWhiteSpace($text)) { return $false }
    if ($text -match '(?i)^(TBD|Pending|replace-at-deploy-time)$') { return $false }
    if ($text -match '(?i)example\.invalid') { return $false }
    return $true
}

function Assert-RequiredText($Value, [string]$Field) {
    if (-not (Is-UsableText $Value)) {
        Add-Failure $Field 'missing or placeholder value'
        return
    }
    Write-Output "PASS $Field"
}
function Assert-HttpsUri($Value, [string]$Field) {
    if (-not (Is-UsableText $Value)) {
        Add-Failure $Field 'missing or placeholder value'
        return
    }

    $uri = $null
    if (-not [Uri]::TryCreate([string]$Value, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -ne 'https') {
        Add-Failure $Field 'must be an absolute HTTPS URI'
        return
    }

    Write-Output "PASS $Field"
}

function Assert-Approved($Value, [string]$Field) {
    if ([string]$Value -ne 'Approved') {
        Add-Failure $Field 'approval is not Approved'
        return
    }
    Write-Output "PASS $Field"
}

$sensitivePropertyPattern = '"(clientSecret|password|accessToken|refreshToken|privateKey)"\s*:'
if ($raw -match $sensitivePropertyPattern) {
    Add-Failure 'input-file' 'contains a prohibited sensitive property'
}

Assert-HttpsUri $data.identity.authority 'identity.authority'
Assert-RequiredText $data.identity.audience 'identity.audience'
Assert-RequiredText $data.identity.clientId 'identity.clientId'
Assert-HttpsUri $data.identity.redirectUri 'identity.redirectUri'
Assert-HttpsUri $data.identity.logoutUri 'identity.logoutUri'
Assert-RequiredText $data.identity.permissionClaim 'identity.permissionClaim'
if ($data.identity.requireHttpsMetadata -ne $true) {
    Add-Failure 'identity.requireHttpsMetadata' 'must be true'
} else {
    Write-Output 'PASS identity.requireHttpsMetadata'
}

Assert-RequiredText $data.secretProvider.provider 'secretProvider.provider'
Assert-RequiredText $data.secretProvider.owner 'secretProvider.owner'
Assert-RequiredText $data.secretProvider.rotationOwner 'secretProvider.rotationOwner'

Assert-RequiredText $data.network.sqlServerEndpoint 'network.sqlServerEndpoint'
Assert-RequiredText $data.network.redisEndpoint 'network.redisEndpoint'
Assert-RequiredText $data.network.objectStorageEndpoint 'network.objectStorageEndpoint'
Assert-RequiredText $data.network.observabilityEndpoint 'network.observabilityEndpoint'

Assert-RequiredText $data.operations.releaseApprover 'operations.releaseApprover'
Assert-RequiredText $data.operations.incidentOwner 'operations.incidentOwner'
Assert-RequiredText $data.operations.backupOwner 'operations.backupOwner'
Assert-RequiredText $data.operations.observabilityOwner 'operations.observabilityOwner'

Assert-Approved $data.approvals.architecture 'approvals.architecture'
Assert-Approved $data.approvals.security 'approvals.security'
Assert-Approved $data.approvals.operations 'approvals.operations'

foreach ($guardrail in @('realSriTransmission', 'browserTokenPersistence', 'secretsInRepository')) {
    if ($data.guardrails.$guardrail -ne $false) {
        Add-Failure "guardrails.$guardrail" 'must remain false'
    } else {
        Write-Output "PASS guardrails.$guardrail"
    }
}
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Output "FAIL $failure"
    }
    Write-Output 'PRODUCTION_ACTIVATION_PREFLIGHT_NOGO'
    exit 1
}

Write-Output 'PRODUCTION_ACTIVATION_PREFLIGHT_PASS'
exit 0
