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

# Detect PowerShell version. We only do parallel if PS >= 7
$psVer = $PSVersionTable.PSVersion

if ($psVer.Major -ge 7) {
  Write-Host "run-checks: PowerShell 7+ detectado. Ejecutando checks en paralelo..." -ForegroundColor Cyan
  $results = $checks | ForEach-Object -Parallel {
    $arguments = @()
    if ($_.ContainsKey('Arguments')) {
      $arguments = @($_.Arguments)
    }
    
    $proc = Start-Process -FilePath $using:psBin -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $_.Script, $arguments) -NoNewWindow -PassThru -Wait
    $exitCode = $proc.ExitCode
    
    [PSCustomObject]@{
      Name = $_.Name
      ExitCode = $exitCode
    }
  } -ThrottleLimit 4

  foreach ($res in $results) {
    if ($res.ExitCode -ne 0) {
      Write-Host "run-checks: fallo en $($res.Name) (exit=$($res.ExitCode))" -ForegroundColor Red
      $failed = $true
    } else {
      Write-Host "run-checks: $($res.Name) finalizó OK." -ForegroundColor Green
    }
  }
} else {
  Write-Host "run-checks: PowerShell v$($psVer.Major) detectado. Ejecutando checks secuencialmente..." -ForegroundColor Cyan
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
      # Continuamos ejecutando los demás para tener reporte completo
    }
  }
}

if ($failed) {
  Write-Host 'run-checks: FALLA' -ForegroundColor Red
  exit 1
}

Write-Host 'run-checks: OK' -ForegroundColor Green
exit 0
