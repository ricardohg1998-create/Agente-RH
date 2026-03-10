[CmdletBinding()]
param(
  [switch]$CheckOnly,
  [switch]$InitGit,
  [switch]$InstallHook,
  [switch]$CreateCatalog,
  [string]$Stack,
  [string]$ProjectName,
  [string]$ProjectVision,
  [string]$FirstDeliverable,
  [switch]$CreateInitialCommit,
  [switch]$ForceScaffold
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
$stacksRoot = Join-Path $repoRoot 'tools/stacks'

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

function ConvertTo-Slug {
  param([string]$Text)

  $slug = $Text.ToLowerInvariant()
  $slug = $slug -replace '[^a-z0-9]+', '-'
  $slug = $slug.Trim('-')
  if ([string]::IsNullOrWhiteSpace($slug)) {
    throw "No se pudo generar slug para: $Text"
  }

  return $slug
}

function ConvertTo-PythonPackage {
  param([string]$Slug)

  return ($Slug -replace '-', '_')
}

function ConvertTo-PascalCase {
  param([string]$Text)

  $parts = $Text -split '[^A-Za-z0-9]+'
  $result = ($parts | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object {
    if ($_.Length -eq 1) {
      $_.ToUpperInvariant()
    } else {
      $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1).ToLowerInvariant()
    }
  }) -join ''

  if ([string]::IsNullOrWhiteSpace($result)) {
    return 'ProjectApp'
  }

  return $result
}

function Resolve-StackManifest {
  param([string]$StackId)

  $manifestPath = Join-Path $stacksRoot $StackId
  $manifestPath = Join-Path $manifestPath 'stack.json'
  if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    $available = @()
    if (Test-Path -LiteralPath $stacksRoot -PathType Container) {
      $available = @(Get-ChildItem -Path $stacksRoot -Directory | Select-Object -ExpandProperty Name | Sort-Object)
    }

    $availableText = if ($available.Count -gt 0) { $available -join ', ' } else { '(sin stacks registrados)' }
    throw "Stack no soportado: $StackId. Disponibles: $availableText"
  }

  $manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
  $manifest | Add-Member -NotePropertyName ManifestPath -NotePropertyValue $manifestPath -Force
  $manifest | Add-Member -NotePropertyName TemplateRoot -NotePropertyValue (Join-Path (Split-Path -Path $manifestPath -Parent) 'template') -Force
  return $manifest
}

function Get-TemplatePlan {
  param(
    [pscustomobject]$Manifest,
    [hashtable]$Tokens
  )

  if (-not (Test-Path -LiteralPath $Manifest.TemplateRoot -PathType Container)) {
    throw "Template faltante para stack $($Manifest.id): $($Manifest.TemplateRoot)"
  }

  $plan = New-Object System.Collections.Generic.List[object]
  foreach ($target in @($Manifest.copyTargets)) {
    $sourcePath = Join-Path $Manifest.TemplateRoot $target
    if (-not (Test-Path -LiteralPath $sourcePath)) {
      throw "copyTarget faltante en stack $($Manifest.id): $target"
    }

    if (Test-Path -LiteralPath $sourcePath -PathType Container) {
      $targetItems = @((Get-Item -LiteralPath $sourcePath)) + @(Get-ChildItem -LiteralPath $sourcePath -Recurse -Force)
      foreach ($item in $targetItems) {
        $relative = $item.FullName.Substring($Manifest.TemplateRoot.Length).TrimStart('\')
        $renderedRelative = Resolve-RenderedText -Text ($relative -replace '\\', '/') -Tokens $Tokens
        $destination = Join-Path $repoRoot ($renderedRelative -replace '/', [string][System.IO.Path]::DirectorySeparatorChar)
        $plan.Add([pscustomobject]@{
          Source = $item.FullName
          Destination = $destination
          Type = if ($item.PSIsContainer) { 'Directory' } else { 'File' }
        })
      }
    } else {
      $relative = $target -replace '\\', '/'
      $renderedRelative = Resolve-RenderedText -Text $relative -Tokens $Tokens
      $destination = Join-Path $repoRoot ($renderedRelative -replace '/', [string][System.IO.Path]::DirectorySeparatorChar)
      $plan.Add([pscustomobject]@{
        Source = $sourcePath
        Destination = $destination
        Type = 'File'
      })
    }
  }

  return $plan.ToArray()
}

function Resolve-RenderedText {
  param(
    [string]$Text,
    [hashtable]$Tokens
  )

  $rendered = $Text
  foreach ($key in ($Tokens.Keys | Sort-Object Length -Descending)) {
    $rendered = $rendered.Replace($key, [string]$Tokens[$key])
  }

  return $rendered
}

function Assert-NoTemplateConflicts {
  param(
    [object[]]$Plan,
    [switch]$AllowOverwrite
  )

  if ($AllowOverwrite) {
    return
  }

  $conflicts = New-Object System.Collections.Generic.List[string]
  foreach ($entry in $Plan) {
    if ($entry.Type -eq 'Directory') {
      if (Test-Path -LiteralPath $entry.Destination -PathType Leaf) {
        $conflicts.Add($entry.Destination)
      }
      continue
    }

    if (Test-Path -LiteralPath $entry.Destination) {
      $conflicts.Add($entry.Destination)
    }
  }

  if ($conflicts.Count -gt 0) {
    Write-Host 'init-project: hay rutas en conflicto con el scaffold.' -ForegroundColor Red
    $conflicts | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
    throw 'Scaffold abortado por colisiones. Usa -ForceScaffold para sobrescribir.'
  }
}

function Invoke-Scaffold {
  param(
    [pscustomobject]$Manifest,
    [hashtable]$Tokens,
    [switch]$AllowOverwrite
  )

  $plan = Get-TemplatePlan -Manifest $Manifest -Tokens $Tokens
  Assert-NoTemplateConflicts -Plan $plan -AllowOverwrite:$AllowOverwrite

  foreach ($entry in ($plan | Where-Object { $_.Type -eq 'Directory' } | Sort-Object Destination)) {
    if (-not (Test-Path -LiteralPath $entry.Destination -PathType Container)) {
      New-Item -ItemType Directory -Path $entry.Destination -Force | Out-Null
    }
  }

  foreach ($entry in ($plan | Where-Object { $_.Type -eq 'File' } | Sort-Object Destination)) {
    $parent = Split-Path -Path $entry.Destination -Parent
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
      New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $content = Get-Content -Path $entry.Source -Raw
    $rendered = Resolve-RenderedText -Text $content -Tokens $Tokens
    Set-Content -Path $entry.Destination -Encoding UTF8 -Value $rendered
  }

  foreach ($placeholder in @('src/.gitkeep', 'tests/.gitkeep', 'tools/.gitkeep')) {
    $placeholderPath = Join-Path $repoRoot $placeholder
    if (-not (Test-Path -LiteralPath $placeholderPath -PathType Leaf)) {
      continue
    }

    $parent = Split-Path -Path $placeholderPath -Parent
    $children = @(Get-ChildItem -LiteralPath $parent -Force | Where-Object { $_.Name -ne '.gitkeep' })
    if ($children.Count -gt 0) {
      Remove-Item -LiteralPath $placeholderPath -Force
    }
  }
}

function Get-StackBrainData {
  param(
    [string]$StackId,
    [string]$ProjectLabel,
    [string]$Deliverable
  )

  $commonScopeIn = @(
    "Scaffold reproducible para $ProjectLabel",
    "Primer entregable definido: $Deliverable",
    'Arranque guiado con checks operativos listos'
  )

  $commonScopeOut = @(
    'Instalacion automatica de dependencias',
    'Despliegue productivo completo',
    'Integraciones externas no necesarias para el primer entregable'
  )

  switch ($StackId) {
    'node-api' {
      return @{
        StackFrontend = '(sin definir)'
        StackBackend = 'Fastify + TypeScript'
        StackDatabase = '(sin definir)'
        StackInfrastructure = '(sin definir)'
        StackHosting = '(sin definir)'
        StackRationale = "Base backend ligera para entregar $Deliverable con arranque rapido."
        StackVersions = @('Node 22', 'Fastify 5', 'TypeScript 5')
        ProjectGoals = @(
          "Entregar $Deliverable",
          'Disponer de una API base con endpoint de health',
          'Mantener arranque y checks reproducibles'
        )
        ScopeIn = $commonScopeIn
        ScopeOut = $commonScopeOut
      }
    }
    'next-app' {
      return @{
        StackFrontend = 'Next.js 15 + React'
        StackBackend = 'Route Handlers (si aplica)'
        StackDatabase = '(sin definir)'
        StackInfrastructure = '(sin definir)'
        StackHosting = '(sin definir)'
        StackRationale = "Base full-stack ligera para validar $Deliverable con App Router."
        StackVersions = @('Node 22', 'Next 15', 'React 19', 'TypeScript 5')
        ProjectGoals = @(
          "Entregar $Deliverable",
          'Disponer de una UI base con App Router',
          'Mantener scaffold y checks reproducibles'
        )
        ScopeIn = $commonScopeIn
        ScopeOut = $commonScopeOut
      }
    }
    'python-cli' {
      return @{
        StackFrontend = '(sin definir)'
        StackBackend = 'CLI Python'
        StackDatabase = '(sin definir)'
        StackInfrastructure = '(sin definir)'
        StackHosting = 'CLI/local'
        StackRationale = "Base simple para validar $Deliverable con una interfaz de linea de comandos."
        StackVersions = @('Python 3.12')
        ProjectGoals = @(
          "Entregar $Deliverable",
          'Disponer de un entrypoint CLI reusable',
          'Mantener estructura reproducible y facil de extender'
        )
        ScopeIn = $commonScopeIn
        ScopeOut = $commonScopeOut
      }
    }
    default {
      throw "No hay brain mapping definido para stack: $StackId"
    }
  }
}

function Add-RepeatedArguments {
  param(
    [System.Collections.Generic.List[string]]$ArgumentList,
    [string]$ParameterName,
    [string[]]$Values
  )

  foreach ($value in @($Values)) {
    if ([string]::IsNullOrWhiteSpace($value)) {
      continue
    }

    $ArgumentList.Add($ParameterName)
    $ArgumentList.Add($value)
  }
}

function Test-GitHeadExists {
  $previousErrorActionPreference = $ErrorActionPreference
  Push-Location $repoRoot
  try {
    $ErrorActionPreference = 'Continue'
    & git rev-parse --verify HEAD 2>$null 1>$null
    return ($LASTEXITCODE -eq 0)
  } finally {
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

$manifest = $null
if (-not [string]::IsNullOrWhiteSpace($Stack)) {
  $manifest = Resolve-StackManifest -StackId $Stack
}

$shouldPrepareProjectMetadata = $null -ne $manifest -or $PSBoundParameters.ContainsKey('ProjectName') -or $PSBoundParameters.ContainsKey('ProjectVision') -or $PSBoundParameters.ContainsKey('FirstDeliverable')

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

  if ($null -ne $manifest) {
    Write-Host " - Stack preparado para scaffold: $($manifest.id)." -ForegroundColor Yellow
    if ($shouldPrepareProjectMetadata) {
      Write-Host ' - En modo normal se solicitarian los datos faltantes de proyecto si no se proporcionan.' -ForegroundColor Yellow
    }
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
  } finally {
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
}

if ($null -ne $manifest) {
  $projectSlug = ConvertTo-Slug -Text $ProjectName
  $pythonPackage = ConvertTo-PythonPackage -Slug $projectSlug
  $tokens = @{
    '__PROJECT_NAME__' = $ProjectName
    '__PROJECT_SLUG__' = $projectSlug
    '__PROJECT_PASCAL__' = (ConvertTo-PascalCase -Text $ProjectName)
    '__FIRST_DELIVERABLE__' = $FirstDeliverable
    '__PROJECT_VISION__' = $ProjectVision
    '__PYTHON_PACKAGE__' = $pythonPackage
  }

  Invoke-Scaffold -Manifest $manifest -Tokens $tokens -AllowOverwrite:$ForceScaffold
  Write-Host "init-project: scaffold aplicado para $($manifest.id)." -ForegroundColor Green

  $brainData = Get-StackBrainData -StackId $manifest.id -ProjectLabel $ProjectName -Deliverable $FirstDeliverable
  $syncParams = @{
    SummaryNow = "Proyecto $ProjectName scaffoldeado con stack $($manifest.id)."
    NextAction = "Instalar dependencias y empezar el entregable '$FirstDeliverable'."
    CurrentState = 'inicializado'
    Phase = 'arranque'
    Risk = 'validar runtime local tras instalar dependencias'
    ProjectVision = $ProjectVision
    ProjectGoals = @($brainData.ProjectGoals)
    ScopeIn = @($brainData.ScopeIn)
    ScopeOut = @($brainData.ScopeOut)
    StackFrontend = $brainData.StackFrontend
    StackBackend = $brainData.StackBackend
    StackDatabase = $brainData.StackDatabase
    StackInfrastructure = $brainData.StackInfrastructure
    StackHosting = $brainData.StackHosting
    StackRationale = $brainData.StackRationale
    StackVersions = @($brainData.StackVersions)
    SyncDeepSummary = $true
  }

  & $syncBrainScript @syncParams
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
  } finally {
    Pop-Location
  }

  Write-Host 'init-project: commit inicial creado.' -ForegroundColor Green
}

Write-Host 'init-project: OK' -ForegroundColor Green
exit 0
