param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('DEV', 'UAT', 'PROD')]
    [string]$EnvironmentName
)

$ErrorActionPreference = 'Stop'

Write-Host "Preparing ARBAutomation promotion for $EnvironmentName..."

$required = @('QLIK_TENANT_URL', 'QLIK_API_KEY')
if ($EnvironmentName -eq 'PROD') {
    $required += @('QLIK_SHARED_SPACE_ID', 'QLIK_MANAGED_SPACE_ID')
} else {
    $required += @('QLIK_SPACE_ID')
}

$missing = @()
foreach ($name in $required) {
    if (-not [Environment]::GetEnvironmentVariable($name)) {
        $missing += $name
    }
}

if ($missing.Count -gt 0) {
    Write-Warning "Qlik environment is not configured. Missing: $($missing -join ', '). Running validation-only mode."
    Write-Host 'Add the missing values as GitHub environment secrets to enable live deployment.'
    exit 0
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$appFiles = Get-ChildItem -Path (Join-Path $repoRoot 'apps') -File -Filter '*.qvf' -ErrorAction SilentlyContinue

if (-not $appFiles -or $appFiles.Count -eq 0) {
    Write-Warning 'No QVF files found under apps/. Nothing to deploy.'
    exit 0
}

$qlik = Get-Command qlik -ErrorAction SilentlyContinue
if (-not $qlik) {
    Write-Warning 'Qlik CLI is not installed on this runner. Running validation-only mode.'
    exit 0
}

Write-Host 'Qlik CLI detected. Deployment commands should be enabled after service-account testing.'
Write-Host 'Current scaffold intentionally stops before modifying Qlik Cloud.'
Write-Host 'Enable import/publish/reload commands here after DEV and UAT dry runs are approved.'
