$ErrorActionPreference = 'Stop'

Write-Host 'Validating ARBAutomation repository assets...'

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$jsonFiles = Get-ChildItem -Path $root -Recurse -File -Filter '*.json' | Where-Object {
    $_.FullName -notmatch '\\.git\\'
}

foreach ($file in $jsonFiles) {
    Write-Host "Checking JSON: $($file.FullName)"
    Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json | Out-Null
}

$secretPatterns = @(
    'apikey\s*[:=]',
    'api[_-]?key\s*[:=]',
    'password\s*[:=]',
    'client_secret\s*[:=]',
    'bearer\s+[a-z0-9._-]{20,}',
    'qlik[_-]?api[_-]?key'
)

$scanFiles = Get-ChildItem -Path $root -Recurse -File | Where-Object {
    $_.FullName -notmatch '\\.git\\' -and
    $_.FullName -notmatch '\\apps\\.*\.qvf$'
}

foreach ($file in $scanFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($null -eq $text) { continue }

    foreach ($pattern in $secretPatterns) {
        if ($text -match $pattern) {
            throw "Possible secret pattern '$pattern' found in $($file.FullName). Remove secrets before promotion."
        }
    }
}

Write-Host 'Validation complete.'
