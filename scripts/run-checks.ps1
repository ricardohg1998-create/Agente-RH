[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$resolvePsBinPath = Join-Path $PSScriptRoot 'lib/resolve-ps-bin.ps1'
. $resolvePsBinPath
$psBin = Resolve-PowerShellBinary

$checks = @(
  @{ Name = 'check-structure'; Script = (Join-Path $PSScriptRoot 'check-structure.ps1') },
  @{ Name = 'generate-workflows-docs'; Script = (Join-Path $PSScriptRoot 'generate-workflows-docs.ps1'); Arguments = @('-CheckOnly') },
  @{ Name = 'generate-catalog'; Script = (Join-Path $PSScriptRoot 'generate-catalog.ps1'); Arguments = @('-CheckOnly') },
  @{ Name = 'check-crossrefs'; Script = (Join-Path $PSScriptRoot 'check-crossrefs.ps1') },
  @{ Name = 'check-links'; Script = (Join-Path $PSScriptRoot 'check-links.ps1') },
  @{ Name = 'check-skills-catalog'; Script = (Join-Path $PSScriptRoot 'check-skills-catalog.ps1') },
  @{ Name = 'check-cleanliness'; Script = (Join-Path $PSScriptRoot 'check-cleanliness.ps1') },
  @{ Name = 'check-brain-deep-summary-sync'; Script = (Join-Path $PSScriptRoot 'check-brain-deep-summary-sync.ps1') },
  @{ Name = 'check-context-budget'; Script = (Join-Path $PSScriptRoot 'check-context-budget.ps1') }
)

$failed = $false

foreach ($check in $checks) {
  Write-Host "run-checks: ejecutando $($check.Name)..." -ForegroundColor Cyan
  $arguments = @()
  if ($check.ContainsKey('Arguments')) {
    $arguments = @($check.Arguments)
  }
  & $psBin -NoProfile -ExecutionPolicy Bypass -File $check.Script @arguments
  $exitCode = $LASTEXITCODE
  if ($exitCode -ne 0) {
    Write-Host "run-checks: fallo en $($check.Name) (exit=$exitCode)" -ForegroundColor Red
    $failed = $true
    break
  }
}

if ($failed) {
  Write-Host 'run-checks: FALLA' -ForegroundColor Red
  exit 1
}

Write-Host 'run-checks: OK' -ForegroundColor Green
exit 0
