$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'Invoke-QlikPromotion.ps1') -EnvironmentName PROD
