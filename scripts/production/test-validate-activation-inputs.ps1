$ErrorActionPreference = 'Stop'

$validator = Join-Path $PSScriptRoot 'validate-activation-inputs.ps1'
$template = Join-Path $PSScriptRoot '..\..\docs\production\activation-inputs.template.json'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('portal-activation-preflight-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot | Out-Null

$shellExe = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }

function Invoke-Validator([string]$InputPath) {
    $output = & $shellExe -NoProfile -ExecutionPolicy Bypass -File $validator -Path $InputPath 2>&1
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Output = ($output -join [Environment]::NewLine)
    }
}

function Assert-Result($Result, [int]$ExpectedExitCode, [string]$ExpectedMarker, [string]$Name) {
    if ($Result.ExitCode -ne $ExpectedExitCode -or $Result.Output -notmatch [regex]::Escape($ExpectedMarker)) {
        throw "$Name failed. Exit=$($Result.ExitCode). Output=$($Result.Output)"
    }
    Write-Output "PASS $Name"
}

try {
    $templateResult = Invoke-Validator $template
    Assert-Result $templateResult 1 'PRODUCTION_ACTIVATION_PREFLIGHT_NOGO' 'placeholder template is rejected'

    $validPath = Join-Path $tempRoot 'valid.json'
    $valid = @{
        identity = @{
            authority = 'https://login.contoso.test/tenant'
            audience = 'portal-api'
            clientId = 'portal-client-id'
            redirectUri = 'https://portal.contoso.test/signin-callback'
            logoutUri = 'https://portal.contoso.test/signout-callback'
            permissionClaim = 'permissions'
            requireHttpsMetadata = $true
        }
        secretProvider = @{ provider = 'ApprovedProvider'; owner = 'Platform'; rotationOwner = 'Security' }
        network = @{ sqlServerEndpoint = 'sql.internal'; redisEndpoint = 'redis.internal'; objectStorageEndpoint = 'object.internal'; observabilityEndpoint = 'observe.internal' }
        operations = @{ releaseApprover = 'ReleaseManager'; incidentOwner = 'Operations'; backupOwner = 'DBA'; observabilityOwner = 'SRE' }
        approvals = @{ architecture = 'Approved'; security = 'Approved'; operations = 'Approved' }
        guardrails = @{ realSriTransmission = $false; browserTokenPersistence = $false; secretsInRepository = $false }
    }
    $valid | ConvertTo-Json -Depth 8 | Set-Content -Path $validPath -Encoding UTF8
    Assert-Result (Invoke-Validator $validPath) 0 'PRODUCTION_ACTIVATION_PREFLIGHT_PASS' 'complete approved input passes'

    $sensitivePath = Join-Path $tempRoot 'sensitive.json'
    $sensitive = $valid.Clone()
    $sensitive['clientSecret'] = 'dummy-not-a-real-secret'
    $sensitive | ConvertTo-Json -Depth 8 | Set-Content -Path $sensitivePath -Encoding UTF8
    Assert-Result (Invoke-Validator $sensitivePath) 1 'PRODUCTION_ACTIVATION_PREFLIGHT_NOGO' 'sensitive property is rejected'

    $invalidJsonPath = Join-Path $tempRoot 'invalid.json'
    Set-Content -Path $invalidJsonPath -Value '{ invalid json' -Encoding UTF8
    Assert-Result (Invoke-Validator $invalidJsonPath) 1 'PRODUCTION_ACTIVATION_PREFLIGHT_NOGO' 'malformed JSON is rejected'

    Write-Output 'PRODUCTION_ACTIVATION_PREFLIGHT_TESTS_PASS'
}
finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

exit 0
