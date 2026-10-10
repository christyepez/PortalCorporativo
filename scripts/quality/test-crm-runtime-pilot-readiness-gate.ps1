$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
    Write-Host "PASS $Message"
}

$registryPath = Join-Path $root 'frontend/config/consumer-registry.json'
$e2ePath = Join-Path $root 'scripts/e2e/prod-local-portal-e2e.ps1'
$minimumsPath = Join-Path $root 'docs/integration/portal-consumer-runtime-pilot-contract-minimums.md'
$checklistPath = Join-Path $root 'docs/integration/portal-consumer-runtime-pilot-checklist-crm.md'
$exitCriteriaPath = Join-Path $root 'docs/integration/portal-consumer-runtime-pilot-exit-criteria-crm.md'

$registry = Get-Content $registryPath -Raw | ConvertFrom-Json
$crm = @($registry.consumers | Where-Object { $_.code -eq 'CRM' })
Assert-True ($crm.Count -eq 1) 'Exactly one governed CRM consumer exists'
$crm = $crm[0]

Assert-True ($crm.gatewayPath -eq '/api/crm') 'CRM uses the governed /api/crm Gateway boundary'
Assert-True ($crm.probePath -eq '/api/crm/health/ready') 'CRM readiness probe stays on the governed health route'
Assert-True ($crm.protectedSmoke -eq '/api/crm/readiness') 'CRM protected smoke stays on the governed application route'
Assert-True ($crm.internalAddress -eq 'http://crm-api:8080/') 'CRM registry uses only internal service DNS'

$e2e = Get-Content $e2ePath -Raw
Assert-True ($e2e.Contains('CRM pilot integration status through Gateway')) 'E2E validates CRM Portal integration status'
Assert-True ($e2e.Contains('CRM pilot controlled implementation status through Gateway')) 'E2E validates CRM controlled implementation status'
Assert-True ($e2e.Contains('PASS CRM runtime pilot P25 safe NOGO gate')) 'E2E emits the CRM P25 safe NOGO marker'
Assert-True ($e2e.Contains('productionActivationDecision -ne "NoGo"')) 'E2E blocks CRM promotion unless the declared decision changes explicitly'
Assert-True ($e2e.Contains('runtimePortalCallsEnabled -ne $false')) 'E2E verifies Portal runtime calls remain fail-closed'
Assert-True ($e2e.Contains('sharedPortalTablesAccessEnabled -ne $false')) 'E2E verifies shared Portal tables remain prohibited'
Assert-True ($e2e.Contains('portalDatabaseDirectAccessEnabled -ne $false')) 'E2E verifies direct Portal database access remains prohibited'
Assert-True ($e2e.Contains('secretsPresent -ne $false')) 'E2E verifies no real CRM runtime secrets are introduced'
Assert-True ($e2e.Contains('browserTokenStorageDetected -ne $false')) 'E2E verifies browser token storage remains absent'
Assert-True ($e2e.Contains('externalCallAttempted -ne $false')) 'E2E verifies the disabled CRM pilot performs no external call'
Assert-True ($e2e.Contains('status -ne "Locked"')) 'E2E verifies the CRM pilot dry-run remains locked'

foreach ($path in @($minimumsPath,$checklistPath,$exitCriteriaPath)) {
    Assert-True (Test-Path $path) "Required CRM pilot governance document exists: $(Split-Path $path -Leaf)"
}
$minimums = Get-Content $minimumsPath -Raw
$checklist = Get-Content $checklistPath -Raw
$exitCriteria = Get-Content $exitCriteriaPath -Raw
Assert-True ($minimums.Contains('Consumers must not create an independent login')) 'Pilot minimums prohibit independent consumer identity'
Assert-True ($minimums.Contains('Consumer configuration must use the Portal configuration contract')) 'Pilot minimums require Portal configuration contract'
Assert-True ($minimums.Contains('Consumer notifications must use the Portal notification contract')) 'Pilot minimums require Portal notification contract'
Assert-True ($checklist.Contains('Shared database boundaries remain intact')) 'CRM checklist preserves database boundaries'
Assert-True ($exitCriteria.Contains('No production provider, private URL, real secret or shared database is introduced')) 'CRM exit criteria preserves production safety boundary'

Write-Host 'PORTAL_CRM_RUNTIME_PILOT_READINESS_GATE_PASS'
