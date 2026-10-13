$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$path = Join-Path $root 'backend\menu-api\src\Portal.Menu.Infrastructure\MenuPersistence.cs'
$source = Get-Content -LiteralPath $path -Raw

function Assert-Contains([string]$Expected,[string]$Message) {
    if (-not $source.Contains($Expected)) { throw $Message }
}

foreach ($token in @(
    'BootstrapApplicationMenusAsync',
    'new("crm", "CRM"',
    'new("financial", "Financiero"',
    'new("hr", "Talento Humano"',
    'new("historiaspaolin", "HistoriasPaolin"',
    '"foundation/leads"',
    '"accounting/accounts"',
    '"accounting/journal-entries"',
    '"accounting/fiscal-years"',
    '"accounting/fiscal-periods"',
    '"/api/hr/employees"',
    '"/api/historiaspaolin/api/channels"',
    '"/api/historiaspaolin/api/historiaspaolin/episodes"',
    'existingCodes.Contains(x.Code)',
    'SingleOrDefaultAsync(',
    'MenuDefinition.Create(',
    'MenuItem.Create('
)) {
    Assert-Contains $token "Missing governed menu bootstrap token: $token"
}

if ($source -match 'ExecuteDelete|RemoveRange|db\.Items\.Remove|db\.Menus\.Remove') {
    throw 'Governed menu bootstrap must not delete administrator-managed menu data.'
}

if ($source -match 'item\.Update\(|SetActive\(') {
    throw 'Governed menu bootstrap must not overwrite or reactivate existing administrator-managed menu items.'
}

Write-Host 'GOVERNED_APP_MENU_BOOTSTRAP_GATE_PASS'
