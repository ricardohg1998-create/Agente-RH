[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

Write-Host "Ejecutando chequeos de entorno (doctor.ps1)..." -ForegroundColor Cyan
$issues = 0

# 1. Verificar versión de PowerShell (Requerido 7+ para paralelismo opcional y mejor cross-platform)
$psVer = $PSVersionTable.PSVersion
if ($psVer.Major -ge 7) {
    Write-Host "[OK] PowerShell versión $($psVer.ToString())" -ForegroundColor Green
} else {
    Write-Host "[WARN] PowerShell versión es $($psVer.ToString()). Se recomienda PowerShell 7+ para usar '-Parallel' en run-checks." -ForegroundColor Yellow
}

# 2. Verificar Git en PATH
if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitVer = (& git --version)
    Write-Host "[OK] Git detectado: $gitVer" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Git no encontrado en el PATH de sistema." -ForegroundColor Red
    $issues++
}

# 3. Verificar Pester (Testing framework)
if (Get-Module -ListAvailable -Name Pester) {
    $pesterVer = (Get-Module -ListAvailable -Name Pester).Version | Sort-Object -Descending | Select-Object -First 1
    Write-Host "[OK] Pester detectado: v$pesterVer" -ForegroundColor Green
} else {
    Write-Host "[WARN] Pester no está instalado. Sin él, no podrás correr 'scripts/test-scripts.ps1'. Puedes instalarlo usando 'Install-Module Pester -Force -SkipPublisherCheck'." -ForegroundColor Yellow
}

# 4. Verificar existencia del Root del repositorio
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (Test-Path (Join-Path $repoRoot ".git")) {
    Write-Host "[OK] Repositorio Git inicializado correctamente." -ForegroundColor Green
} else {
    Write-Host "[WARN] No se detectó un directorio '.git'. Usa 'scripts/init-project.ps1 -InitGit'." -ForegroundColor Yellow
}

if ($issues -gt 0) {
    Write-Host "`nDoctor ha detectado $issues problema(s) bloqueante(s)." -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nDoctor: El entorno operativo parece estar listo." -ForegroundColor Green
    exit 0
}
 
