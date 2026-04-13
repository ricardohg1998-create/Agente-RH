[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$resolvePsBinPath = Join-Path $PSScriptRoot 'lib/resolve-ps-bin.ps1'
. $resolvePsBinPath
$psBin = Resolve-PowerShellBinary

$updateScript = Join-Path $PSScriptRoot 'update-brain-deep-summary.ps1'
& $psBin -NoProfile -ExecutionPolicy Bypass -File $updateScript -CheckOnly
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
  Write-Host '[CRITICAL] deep-summary desincronizado con deepLayer.files. Ejecuta scripts/update-brain-deep-summary.ps1.' -ForegroundColor Red
  exit 1
}

Write-Host 'check-brain-deep-summary-sync: OK' -ForegroundColor Green
exit 0
