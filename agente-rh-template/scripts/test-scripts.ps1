[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$testsPath = Join-Path $repoRoot 'tests/Pester'
$testScripts = @(Get-ChildItem -Path $testsPath -Filter *.Tests.ps1 -File | Select-Object -ExpandProperty FullName)

if ($testScripts.Count -eq 0) {
  throw 'No se encontraron tests en tests/Pester.'
}

$pesterModule = Get-Module -ListAvailable Pester | Where-Object { $_.Version.Major -eq 4 } | Sort-Object Version -Descending | Select-Object -First 1

if ($null -eq $pesterModule) {
  Write-Host "test-scripts: Instalando Pester 4.x..." -ForegroundColor Yellow
  Install-Module -Name Pester -MaximumVersion 4.99.99 -Force -SkipPublisherCheck -Scope CurrentUser -AllowClobber
  $pesterModule = Get-Module -ListAvailable Pester | Where-Object { $_.Version.Major -eq 4 } | Sort-Object Version -Descending | Select-Object -First 1
}

if ($null -eq $pesterModule) {
  throw 'No se encontro Pester 4.x instalado.'
}

Import-Module $pesterModule.Path -Force
$majorVersion = [int]$pesterModule.Version.Major

if ($majorVersion -ge 5) {
  $result = Invoke-Pester -Path $testScripts -PassThru
} else {
  $result = Invoke-Pester -Script $testScripts -PassThru
}

$failedCount = 0
if ($result.PSObject.Properties.Name -contains 'FailedCount') {
  $failedCount = [int]$result.FailedCount
}

if ($failedCount -gt 0) {
  Write-Host "test-scripts: FALLA ($failedCount tests fallidos)" -ForegroundColor Red
  exit 1
}

Write-Host 'test-scripts: OK' -ForegroundColor Green
exit 0
