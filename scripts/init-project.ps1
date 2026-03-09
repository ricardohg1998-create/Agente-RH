[CmdletBinding()]
param(
  [switch]$CheckOnly,
  [switch]$InitGit,
  [switch]$InstallHook,
  [switch]$CreateCatalog
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$resolvePsBinPath = Join-Path $PSScriptRoot 'lib/resolve-ps-bin.ps1'
. $resolvePsBinPath
$psBin = Resolve-PowerShellBinary
$bootstrapScript = Join-Path $PSScriptRoot 'bootstrap.ps1'
$installHookScript = Join-Path $PSScriptRoot 'install-hook.ps1'
$catalogPath = Join-Path $repoRoot 'CATALOG.md'
$gitDir = Join-Path $repoRoot '.git'

function Invoke-CheckedScript {
  param(
    [string]$ScriptPath,
    [string[]]$Arguments = @()
  )

  & $psBin -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Fallo ejecutando $ScriptPath (exit=$LASTEXITCODE)"
  }
}

function Ensure-GitAvailable {
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'No se encontro git en PATH.'
  }
}

function Write-CatalogFile {
  $content = @'
# CATALOG

Catalogo local minimo del workspace.

## Estado

- Base operativa disponible.
- Sin skills especificas del repo registradas todavia.

## Uso

- Documenta aqui solo skills propias de este workspace.
- Mantiene esta ruta valida para `.agent/config/skills-sources.json`.

## Skills workspace

- (sin registros)
'@

  Set-Content -Path $catalogPath -Encoding UTF8 -Value $content
}

if ($InstallHook -and -not (Test-Path -LiteralPath $gitDir -PathType Container) -and -not $InitGit) {
  throw 'No se puede instalar el hook sin .git. Usa -InitGit o inicializa git antes.'
}

if (($InitGit -or $InstallHook) -and (-not (Test-Path -LiteralPath $gitDir -PathType Container))) {
  Ensure-GitAvailable
}

if ($CreateCatalog -and -not (Test-Path -LiteralPath $catalogPath -PathType Leaf) -and -not $CheckOnly) {
  Write-CatalogFile
  Write-Host 'init-project: CATALOG.md creado.' -ForegroundColor Green
}

if (-not ($CreateCatalog -and $CheckOnly -and -not (Test-Path -LiteralPath $catalogPath -PathType Leaf))) {
  Invoke-CheckedScript -ScriptPath $bootstrapScript -Arguments @('-CheckOnly')
}

if ($CheckOnly) {
  Write-Host 'init-project: estado base OK.' -ForegroundColor Green

  if ($CreateCatalog -and -not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
    Write-Host ' - CATALOG.md faltante: se crearia en modo normal.' -ForegroundColor Yellow
  }

  if ($InitGit -and -not (Test-Path -LiteralPath $gitDir -PathType Container)) {
    Write-Host ' - .git faltante: se inicializaria en modo normal.' -ForegroundColor Yellow
  }

  if ($InstallHook -and (Test-Path -LiteralPath $gitDir -PathType Container)) {
    Write-Host ' - Hook instalable con el estado actual.' -ForegroundColor Yellow
  }

  exit 0
}

Invoke-CheckedScript -ScriptPath $bootstrapScript

if ($InitGit -and -not (Test-Path -LiteralPath $gitDir -PathType Container)) {
  Push-Location $repoRoot
  try {
    & git init | Out-Null
    if ($LASTEXITCODE -ne 0) {
      throw 'git init devolvio un codigo distinto de 0.'
    }
  } finally {
    Pop-Location
  }
  Write-Host 'init-project: repositorio git inicializado.' -ForegroundColor Green
}

if ($InstallHook) {
  Invoke-CheckedScript -ScriptPath $installHookScript
}

Write-Host 'init-project: OK' -ForegroundColor Green
exit 0
