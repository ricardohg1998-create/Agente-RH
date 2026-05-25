[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$utf8IoPath = Join-Path $PSScriptRoot 'lib/utf8-io.psm1'
Import-Module $utf8IoPath -Force
$targetDir = Join-Path $repoRoot 'agente-rh-template'
$resolvePsBinPath = Join-Path $PSScriptRoot 'lib/resolve-ps-bin.ps1'
. $resolvePsBinPath
$psBin = Resolve-PowerShellBinary

Write-Host "Iniciando empaquetado del template virgen en: $targetDir" -ForegroundColor Cyan

if (Test-Path -LiteralPath $targetDir -PathType Container) {
    Write-Host " - Limpiando carpeta destino existente..." -ForegroundColor Yellow
    Remove-Item -LiteralPath $targetDir -Recurse -Force
}

New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

$excludeList = @(
    '.git',
    '.agent/local',
    'agente-rh-template',
    '.github/workflows/windows-checks.yml', # Opcionalmente, se podria mantener, pero la base virgen prioriza no tener historial
    '.gemini',
    'node_modules',
    '.venv',
    'brain/session_logs',
    '*.tmp',
    '*.log'
)

$robocopyArgs = @(
    $repoRoot,
    $targetDir,
    '/S',
    '/XD', '.git', '.agent\local', 'agente-rh-template', '.gemini', 'node_modules', '.venv', 'brain\session_logs',
    '/XF', '*.tmp', '*.log',
    '/NFL', '/NDL', '/NJH', '/NJS', '/nc', '/ns', '/np'
)

& robocopy $robocopyArgs
$rc = $LASTEXITCODE

if ($null -eq $rc) {
    Write-Host "Error crítico: No se pudo determinar el código de salida de Robocopy." -ForegroundColor Red
    exit 1
}

# robocopy exit code < 8 means success (1=files copied, 2=extra files, 3=both, 0=no change)
if ($rc -ge 8) {
    Write-Host "Fallo copiando archivos (exit code: $rc)" -ForegroundColor Red
    exit 1
}

# robocopy /XD no soporta bien rutas con subdirectorios.
# Limpiamos session_logs post-copia para asegurar que no se filtren.
$exportSessionLogs = Join-Path $targetDir 'brain/session_logs'
if (Test-Path -LiteralPath $exportSessionLogs) {
    Get-ChildItem -LiteralPath $exportSessionLogs -Recurse -File | Where-Object { $_.Name -ne '.gitkeep' } | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -LiteralPath $exportSessionLogs -Recurse -Directory | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    if (-not (Test-Path -LiteralPath (Join-Path $exportSessionLogs '.gitkeep'))) {
        Write-Utf8File -Path (Join-Path $exportSessionLogs '.gitkeep') -Content ''
    }
}
$exportArchiveLogs = Join-Path $targetDir 'brain/archive/session_logs'
if (Test-Path -LiteralPath $exportArchiveLogs) {
    Get-ChildItem -LiteralPath $exportArchiveLogs -Recurse -File | Where-Object { $_.Name -ne '.gitkeep' } | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -LiteralPath $exportArchiveLogs -Recurse -Directory | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# Eliminar artefactos de planificación o de sesión que se hayan copiado accidentalmente
$artifactsToClean = @('implementation_plan.md', 'task.md', 'walkthrough.md')
foreach ($art in $artifactsToClean) {
    $artPath = Join-Path $targetDir $art
    if (Test-Path -LiteralPath $artPath) {
        Remove-Item -LiteralPath $artPath -Force -ErrorAction SilentlyContinue
    }
    Get-ChildItem -LiteralPath $targetDir -Filter $art -Recurse -File | Remove-Item -Force -ErrorAction SilentlyContinue
}

# Eliminar scripts de deploy/update específicos del repositorio maestro que no deben estar en el clon
$scriptsToClean = @('scripts/deploy.ps1', 'scripts/update-template.ps1')
foreach ($scr in $scriptsToClean) {
    $scrPath = Join-Path $targetDir $scr
    if (Test-Path -LiteralPath $scrPath) {
        Remove-Item -LiteralPath $scrPath -Force -ErrorAction SilentlyContinue
    }
}

# Eliminar PDFs de documentación histórica específica del proyecto maestro
$pdfPath = Join-Path $targetDir 'brain/archive/Análisis de estructura IDE.pdf'
if (Test-Path -LiteralPath $pdfPath) {
    Remove-Item -LiteralPath $pdfPath -Force -ErrorAction SilentlyContinue
}

$exportSwarmDir = Join-Path $targetDir 'brain\swarm'
if (Test-Path -LiteralPath $exportSwarmDir -PathType Container) {
    Remove-Item -LiteralPath $exportSwarmDir -Recurse -Force -ErrorAction SilentlyContinue
}

# The generated brain must be very clean and we should erase actual project specific things if any.
# Let's ensure the user instructions remain logic but specific. Also replace now.md with an empty placeholder.
$nowPath = Join-Path $targetDir 'brain/now.md'
$statePath = Join-Path $targetDir 'brain/current-state.md'

if (Test-Path -LiteralPath $nowPath) {
    $nowContent = @"
# Now
 
<!-- QUICK-NOW:START -->
## Estado actual

- Base virgen de Agente-RH inicializada.

## Siguiente accion recomendada

- Iniciar nuevo proyecto y definir el alcance.

## Bloqueos activos

- Ninguno.

## Cambios recientes

- Generada desde deploy.
<!-- QUICK-NOW:END -->
"@
    Write-Utf8File -Path $nowPath -Content $nowContent
}

if (Test-Path -LiteralPath $statePath) {
    $stateContent = @"
# Current State

<!-- QUICK-STATE:START -->
## Resumen operativo

- Estado: Template virgen.
- Fase: Arranque.
- Riesgo principal: Por definir.

## Calidad de contexto

- Cerebro listo y a la espera de iteraciones reales.

## Proxima validacion

- Confirmar variables operativas.
<!-- QUICK-STATE:END -->
"@
    Write-Utf8File -Path $statePath -Content $stateContent
}

# --- Reset de capa profunda del brain ---
# Estos archivos acumulan contexto especifico del repo maestro
# y no deben filtrarse a clones derivados.

$changelogPath = Join-Path $targetDir 'brain/changelog.md'
if (Test-Path -LiteralPath $changelogPath) {
    $changelogContent = @"
# Changelog

## Registros

"@
    Write-Utf8File -Path $changelogPath -Content $changelogContent
}

$decisionsPath = Join-Path $targetDir 'brain/decisions.md'
if (Test-Path -LiteralPath $decisionsPath) {
    $decisionsContent = @"
# Decisiones Tecnicas

<!-- EJEMPLO: (Manten este bloque comentado. Solo para guiar al agente de como redactar tareas).
## [YYYY-MM-DD] Titulo de la Decision

- **Contexto**: Relatos breves de por que se toma la decision.
- **Alternativas Estudiadas**:
  - Opcion 1: Pros vs contras.
  - Opcion 2: Pros vs contras.
- **Decision Adoptada**: 
  - Que se decidio finalmente.
- **Consecuencias Esperadas**:
  - Bueno: que hemos ganado.
  - Malo: que hemos cedido (deuda tecnica).
-->

"@
    Write-Utf8File -Path $decisionsPath -Content $decisionsContent
}

$techDebtPath = Join-Path $targetDir 'brain/technical-debt.md'
if (Test-Path -LiteralPath $techDebtPath) {
    $techDebtContent = @"
# Technical Debt

## Actual

## Resuelto

## Riesgos de deuda futura

"@
    Write-Utf8File -Path $techDebtPath -Content $techDebtContent
}

$pitfallsPath = Join-Path $targetDir 'brain/pitfalls-and-errors.md'
if (Test-Path -LiteralPath $pitfallsPath) {
    $pitfallsContent = @"
# Pitfalls and Errors

## Registros

"@
    Write-Utf8File -Path $pitfallsPath -Content $pitfallsContent
}

$metricsPath = Join-Path $targetDir 'brain/workflow-metrics.md'
if (Test-Path -LiteralPath $metricsPath) {
    $metricsContent = @"
# Workflow Metrics

## Uso por workflow

| Workflow | Veces usado | Ultima vez | Satisfaccion |
|----------|-------------|------------|--------------|
| autista-cafeinado | 0 | - | - |
| implementacion-quirurgica | 0 | - | - |
| cierre-operativo | 0 | - | - |
| code-review | 0 | - | - |
| retrospectiva | 0 | - | - |
| desarrollador-profundidad | 0 | - | - |
| mr-problem-solver | 0 | - | - |
| higiene-contexto | 0 | - | - |
| buscar-skills | 0 | - | - |
| inicio-proyecto | 0 | - | - |
| spike-investigacion | 0 | - | - |
| qa-testing | 0 | - | - |
| pre-release | 0 | - | - |

## Patrones detectados

## Ajustes pendientes

"@
    Write-Utf8File -Path $metricsPath -Content $metricsContent
}

$deepSummaryPath = Join-Path $targetDir 'brain/deep-summary.md'
if (Test-Path -LiteralPath $deepSummaryPath) {
    $deepSummaryContent = @"
# Deep Summary

<!-- QUICK-DEEP:START -->
## Resumen profundo (auto)

- brain/project-overview.md | estado: base | resumen: sin novedades | mod: -
- brain/architecture.md | estado: base | resumen: sin novedades | mod: -
- brain/decisions.md | estado: base | resumen: sin novedades | mod: -
- brain/milestones.md | estado: base | resumen: sin novedades | mod: -
- brain/backlog.md | estado: base | resumen: sin novedades | mod: -
- brain/open-questions.md | estado: base | resumen: sin novedades | mod: -
- brain/technical-debt.md | estado: base | resumen: sin novedades | mod: -
- brain/pitfalls-and-errors.md | estado: base | resumen: sin novedades | mod: -
- brain/ideas.md | estado: base | resumen: sin novedades | mod: -
- brain/changelog.md | estado: base | resumen: sin novedades | mod: -
- brain/skills-available.md | estado: base | resumen: sin novedades | mod: -
- brain/workflows-index.md | estado: base | resumen: sin novedades | mod: -
- brain/user-instructions.md | estado: base | resumen: sin novedades | mod: -
- brain/workflow-metrics.md | estado: base | resumen: sin novedades | mod: -
- brain/access.md | estado: base | resumen: sin novedades | mod: -
<!-- QUICK-DEEP:END -->

"@
    Write-Utf8File -Path $deepSummaryPath -Content $deepSummaryContent
}

$targetDeepSummaryScript = Join-Path $targetDir 'scripts\update-brain-deep-summary.ps1'
if (Test-Path -LiteralPath $targetDeepSummaryScript -PathType Leaf) {
    & $psBin -NoProfile -ExecutionPolicy Bypass -File $targetDeepSummaryScript
    if ($LASTEXITCODE -ne 0) {
        throw 'No se pudo regenerar brain/deep-summary.md dentro del template exportado.'
    }
}

Write-Host "deploy: OK. Template virgen exportado correctamente en 'agente-rh-template'." -ForegroundColor Green
exit 0
