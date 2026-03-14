[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$targetDir = Join-Path $repoRoot 'agente-rh-template'

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

# robocopy exit code < 8 means success (1=files copied, 2=extra files, 3=both, 0=no change)
if ($rc -ge 8) {
    Write-Host "Fallo copiando archivos (exit code: $rc)" -ForegroundColor Red
    exit 1
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
    Set-Content -Path $nowPath -Value $nowContent -Force
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
    Set-Content -Path $statePath -Value $stateContent -Force
}

Write-Host "deploy: OK. Template virgen exportado correctamente en 'agente-rh-template'." -ForegroundColor Green
exit 0
