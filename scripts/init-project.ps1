[CmdletBinding()]
param(
  [switch]$CheckOnly,
  [switch]$InitGit,
  [switch]$InstallHook,
  [switch]$CreateCatalog,
  [string]$ProjectName,
  [string]$ProjectVision,
  [string]$FirstDeliverable,
  [switch]$CreateInitialCommit
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$resolvePsBinPath = Join-Path $PSScriptRoot 'lib/resolve-ps-bin.ps1'
. $resolvePsBinPath
$psBin = Resolve-PowerShellBinary
$bootstrapScript = Join-Path $PSScriptRoot 'bootstrap.ps1'
$installHookScript = Join-Path $PSScriptRoot 'install-hook.ps1'
$generateCatalogScript = Join-Path $PSScriptRoot 'generate-catalog.ps1'
$runChecksScript = Join-Path $PSScriptRoot 'run-checks.ps1'
$syncBrainScript = Join-Path $PSScriptRoot 'sync-brain.ps1'
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

function Read-RequiredValue {
  param(
    [string]$Label,
    [string]$CurrentValue
  )

  if (-not [string]::IsNullOrWhiteSpace($CurrentValue)) {
    return $CurrentValue
  }

  $value = Read-Host $Label
  if ([string]::IsNullOrWhiteSpace($value)) {
    throw "Valor requerido no informado: $Label"
  }

  return $value.Trim()
}

function Test-GitHeadExists {
  $previousErrorActionPreference = $ErrorActionPreference
  Push-Location $repoRoot
  try {
    $ErrorActionPreference = 'Continue'
    & git rev-parse --verify HEAD 2>$null 1>$null
    return ($LASTEXITCODE -eq 0)
  }
  finally {
    $ErrorActionPreference = $previousErrorActionPreference
    Pop-Location
  }
}

if (($InitGit -or $InstallHook -or $CreateInitialCommit) -and (-not (Test-Path -LiteralPath $gitDir -PathType Container))) {
  Ensure-GitAvailable
}

if ($InstallHook -and -not (Test-Path -LiteralPath $gitDir -PathType Container) -and -not $InitGit) {
  throw 'No se puede instalar el hook sin .git. Usa -InitGit o inicializa git antes.'
}

if ($CreateInitialCommit -and -not (Test-Path -LiteralPath $gitDir -PathType Container) -and -not $InitGit) {
  throw 'No se puede crear commit inicial sin .git. Usa -InitGit o inicializa git antes.'
}

$shouldPrepareProjectMetadata = $PSBoundParameters.ContainsKey('ProjectName') -or $PSBoundParameters.ContainsKey('ProjectVision') -or $PSBoundParameters.ContainsKey('FirstDeliverable')

if ($CheckOnly) {
  if (-not ($CreateCatalog -and -not (Test-Path -LiteralPath $catalogPath -PathType Leaf))) {
    Invoke-CheckedScript -ScriptPath $bootstrapScript -Arguments @('-CheckOnly')
  }

  Write-Host 'init-project: estado base OK.' -ForegroundColor Green

  if ($CreateCatalog -and -not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
    Write-Host ' - CATALOG.md faltante: se generaria en modo normal.' -ForegroundColor Yellow
  }

  if ($InitGit -and -not (Test-Path -LiteralPath $gitDir -PathType Container)) {
    Write-Host ' - .git faltante: se inicializaria en modo normal.' -ForegroundColor Yellow
  }

  if ($InstallHook -and ((Test-Path -LiteralPath $gitDir -PathType Container) -or $InitGit)) {
    Write-Host ' - Hook instalable con el estado previsto.' -ForegroundColor Yellow
  }

  if ($shouldPrepareProjectMetadata) {
    Write-Host ' - En modo normal se solicitarian los datos faltantes de proyecto si no se proporcionan.' -ForegroundColor Yellow
  }

  exit 0
}

if ($CreateCatalog -or -not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
  Invoke-CheckedScript -ScriptPath $generateCatalogScript
}

Invoke-CheckedScript -ScriptPath $bootstrapScript

if ($InitGit -and -not (Test-Path -LiteralPath $gitDir -PathType Container)) {
  Push-Location $repoRoot
  try {
    & git init | Out-Null
    if ($LASTEXITCODE -ne 0) {
      throw 'git init devolvio un codigo distinto de 0.'
    }
  }
  finally {
    Pop-Location
  }
  Write-Host 'init-project: repositorio git inicializado.' -ForegroundColor Green
}

if ($InstallHook) {
  Invoke-CheckedScript -ScriptPath $installHookScript
}

if ($shouldPrepareProjectMetadata) {
  $ProjectName = Read-RequiredValue -Label 'Nombre del proyecto' -CurrentValue $ProjectName
  $ProjectVision = Read-RequiredValue -Label 'Vision del proyecto' -CurrentValue $ProjectVision
  $FirstDeliverable = Read-RequiredValue -Label 'Primer entregable' -CurrentValue $FirstDeliverable

  $syncParams = @{
    SummaryNow    = "Proyecto $ProjectName inicializado en el cerebro."
    NextAction    = "Elegir e inicializar stack (ej. con npm/pip) manual o usar workflows."
    CurrentState  = 'inicializado (agnostico)'
    Phase         = 'arranque'
    Risk          = 'validar stack y herramientas CLI'
    ProjectVision = $ProjectVision
    ProjectGoals  = @("Entregar $FirstDeliverable")
    ScopeIn       = @("Estructura inicial operativa construida")
  }

  & $syncBrainScript @syncParams
  Write-Host "init-project: inicializacion terminada. Usa CLIs oficiales (npx, pip) para scaffolding de stack." -ForegroundColor Green
}

Invoke-CheckedScript -ScriptPath $runChecksScript

if ($CreateInitialCommit) {
  if (-not (Test-Path -LiteralPath $gitDir -PathType Container)) {
    throw 'No existe .git para crear commit inicial.'
  }

  if (Test-GitHeadExists) {
    throw 'El repositorio ya tiene commits. -CreateInitialCommit solo se permite sin HEAD.'
  }

  Push-Location $repoRoot
  try {
    & git add .
    if ($LASTEXITCODE -ne 0) {
      throw 'git add devolvio un codigo distinto de 0.'
    }

    & git commit -m 'chore: bootstrap project'
    if ($LASTEXITCODE -ne 0) {
      throw 'git commit devolvio un codigo distinto de 0.'
    }
  }
  finally {
    Pop-Location
  }

  Write-Host 'init-project: commit inicial creado.' -ForegroundColor Green
}

Write-Host 'init-project: OK' -ForegroundColor Green
exit 0
