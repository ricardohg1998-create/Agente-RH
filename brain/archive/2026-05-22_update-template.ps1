[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$templateDir = Join-Path $repoRoot 'agente-rh-template'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$resolvePsBinPath = Join-Path $PSScriptRoot 'lib/resolve-ps-bin.ps1'
. $resolvePsBinPath
$psBin = Resolve-PowerShellBinary

Write-Host "Iniciando sincronizacion de la plantilla..." -ForegroundColor Cyan

# 1. Sincronizar archivos ignorando carpetas innecesarias o recursivas
$excludeDirs = @('.git', 'agente-rh-template', 'node_modules', 'dist', 'out', '.gemini', 'tmp')
robocopy $repoRoot $templateDir /MIR /XD $excludeDirs /NJH /NJS /NDL /NP
# robocopy devuelve < 8 como exito
if ($LASTEXITCODE -ge 8) {
    throw "Error en robocopy al sincronizar. Codigo: $LASTEXITCODE"
}
$LASTEXITCODE = 0

Write-Host "Archivos copiados. Limpiando memoria (brain) en la plantilla..." -ForegroundColor Cyan

# 2. Limpiar logs
$logsDir = Join-Path $templateDir 'brain\session_logs'
$archiveLogsDir = Join-Path $templateDir 'brain\archive\session_logs'

if (Test-Path -LiteralPath $logsDir) {
    Get-ChildItem -LiteralPath $logsDir -File | Where-Object { $_.Name -ne '.gitkeep' } | Remove-Item -Force
}
if (Test-Path -LiteralPath $archiveLogsDir) {
    Get-ChildItem -LiteralPath $archiveLogsDir -File | Where-Object { $_.Name -ne '.gitkeep' } | Remove-Item -Force
}

# Eliminar artefactos de planificación o de sesión que se hayan copiado accidentalmente
$artifactsToClean = @('implementation_plan.md', 'task.md', 'walkthrough.md')
foreach ($art in $artifactsToClean) {
    $artPath = Join-Path $templateDir $art
    if (Test-Path -LiteralPath $artPath) {
        Remove-Item -LiteralPath $artPath -Force -ErrorAction SilentlyContinue
    }
    Get-ChildItem -LiteralPath $templateDir -Filter $art -Recurse -File | Remove-Item -Force -ErrorAction SilentlyContinue
}

$swarmDir = Join-Path $templateDir 'brain\swarm'
if (Test-Path -LiteralPath $swarmDir -PathType Container) {
    Remove-Item -LiteralPath $swarmDir -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. Resetear archivos clave de estado
$cleanNow = @"
# Now

<!-- QUICK-NOW:START -->
## Estado actual

- Proyecto inicializado desde la plantilla base.

## Siguiente accion recomendada
- Definir base arquitectónica y stack.
<!-- QUICK-NOW:END -->
"@

$cleanCurrentState = @"
# Current State

<!-- QUICK-STATE:START -->
## Resumen operativo
Proyecto recien inicializado.

## Arquitectura y Stack
(Por definir)
<!-- QUICK-STATE:END -->
"@

$cleanDeepSummary = @"
# Deep Summary

<!-- QUICK-DEEP:START -->
## Resumen profundo (auto)

- brain/access.md | estado: activo | resumen: Acceso restringido (credenciales seguras) | mod: 2026-05-22
<!-- QUICK-DEEP:END -->
"@

$cleanChangelog = @"
# Changelog

- Inicializacion del proyecto.
"@

$cleanTechDebt = @"
# Deuda Tecnica

No hay deuda tecnica registrada.
"@

$cleanMetrics = @"
# Metricas de Workflows

(Vacio)
"@

$cleanDecisions = @"
# Registro de Decisiones Arquitectonicas (ADR)

(Vacio)
"@

$cleanPitfalls = @"
# Pitfalls and Errors

Registro de errores comunes. Vacio en inicializacion.
"@

$cleanAccess = @"
# Credenciales y Accesos

(Vacio)
"@

$cleanIdeas = @"
# Ideas y Tareas Futuras

(Vacio)
"@

$cleanBacklog = @"
# Backlog

(Vacio)
"@

$cleanMilestones = @"
# Milestones

(Vacio)
"@

# Escritura de archivos con UTF-8 sin BOM para robustez total en Windows 11
[System.IO.File]::WriteAllText((Join-Path $templateDir 'brain\now.md'), $cleanNow, $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $templateDir 'brain\current-state.md'), $cleanCurrentState, $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $templateDir 'brain\deep-summary.md'), $cleanDeepSummary, $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $templateDir 'brain\changelog.md'), $cleanChangelog, $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $templateDir 'brain\technical-debt.md'), $cleanTechDebt, $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $templateDir 'brain\workflow-metrics.md'), $cleanMetrics, $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $templateDir 'brain\decisions.md'), $cleanDecisions, $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $templateDir 'brain\pitfalls-and-errors.md'), $cleanPitfalls, $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $templateDir 'brain\access.md'), $cleanAccess, $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $templateDir 'brain\ideas.md'), $cleanIdeas, $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $templateDir 'brain\backlog.md'), $cleanBacklog, $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $templateDir 'brain\milestones.md'), $cleanMilestones, $utf8NoBom)

$templateDeepSummaryScript = Join-Path $templateDir 'scripts\update-brain-deep-summary.ps1'
if (Test-Path -LiteralPath $templateDeepSummaryScript -PathType Leaf) {
    & $psBin -NoProfile -ExecutionPolicy Bypass -File $templateDeepSummaryScript
    if ($LASTEXITCODE -ne 0) {
        throw 'No se pudo regenerar brain/deep-summary.md dentro de la plantilla.'
    }
}

Write-Host "Plantilla actualizada y lista para usar." -ForegroundColor Green
