[CmdletBinding()]
param(
  [switch]$CheckOnly,
  [switch]$InitGit,
  [switch]$InstallHook,
  [switch]$CreateCatalog,
  [string]$ProjectName,
  [string]$ProjectVision,
  [string]$FirstDeliverable,
  [switch]$CreateInitialCommit,
  [switch]$SkipChecks
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

function Assert-GitAvailable {
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
  Assert-GitAvailable
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

  # Factory Reset de memoria heredada del template
  Write-Host 'init-project: purgados logs e historial del template base para el nuevo proyecto.' -ForegroundColor Cyan
  $sessionLogsDir = Join-Path $repoRoot 'brain/session_logs'
  $archiveLogsDir = Join-Path $repoRoot 'brain/archive/session_logs'

  if (Test-Path $sessionLogsDir) {
    Get-ChildItem -Path $sessionLogsDir -Recurse -File | Where-Object { $_.Name -ne '.gitkeep' } | Remove-Item -Force -ErrorAction SilentlyContinue
    [System.IO.File]::WriteAllText("$sessionLogsDir\.gitkeep", "", [System.Text.UTF8Encoding]::new($false))
  }
  if (Test-Path $archiveLogsDir) {
    Get-ChildItem -Path $archiveLogsDir -Recurse -File | Where-Object { $_.Name -ne '.gitkeep' } | Remove-Item -Force -ErrorAction SilentlyContinue
    [System.IO.File]::WriteAllText("$archiveLogsDir\.gitkeep", "", [System.Text.UTF8Encoding]::new($false))
  }

  $nowPath = Join-Path $repoRoot 'brain/now.md'
  if (Test-Path $nowPath) {
    $nowResetContent = "# Now`n`n<!-- QUICK-NOW:START -->`n## Estado actual`n`n- Memoria reseteada para nuevo proyecto.`n`n## Siguiente accion recomendada`n- Definir base arquitectónica.`n<!-- QUICK-NOW:END -->`n"
    [System.IO.File]::WriteAllText($nowPath, $nowResetContent, [System.Text.UTF8Encoding]::new($false))
  }

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

  # Automatización de instalación del MCP Semantic Server
  if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Host "init-project: Detectado Node.js. Autoinstalando y compilando el MCP Semantic Server..." -ForegroundColor Magenta
    
    $mcpDir = Join-Path $repoRoot ".agent\mcp\semantic-server"
    $installMcpScript = Join-Path $repoRoot ".agent\scripts\install-mcp.ps1"
    
    if (Test-Path $mcpDir) {
      try {
        Push-Location $mcpDir
        try {
          Write-Host "  -> npm install..."
          & npm install --silent | Out-Null
          Write-Host "  -> compilando (tsc)..."
          & npm run build --silent | Out-Null
        } finally {
          Pop-Location
        }
        
        if (Test-Path $installMcpScript) {
          Write-Host "  -> enlazando el cliente MCP con el IDE..."
          Invoke-CheckedScript -ScriptPath $installMcpScript
          Write-Host "init-project: Semantic Server instalado y enganchado con exito." -ForegroundColor Green
        }
      } catch {
        Write-Warning "init-project: La autoinstalacion o prueba de humo del Semantic Server ha fallado: $_"
        
        # Desenganche seguro para evitar dejar un servidor roto registrado
        $ConfigPath = "$env:USERPROFILE\.gemini\antigravity\mcp_config.json"
        if (Test-Path $ConfigPath) {
          try {
            $json = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
            $cleanProjectName = "Agente-RH-Semantic"
            $pkgPath = Join-Path $repoRoot "package.json"
            if (Test-Path $pkgPath) {
              $pkg = Get-Content $pkgPath | ConvertFrom-Json
              if ($pkg.name) { $cleanProjectName = $pkg.name + "-Semantic" }
            }
            if ($json.mcpServers.PSObject.Properties.Match($cleanProjectName).Count -gt 0) {
              $json.mcpServers.PSObject.Properties.Remove($cleanProjectName)
              $jsonStr = $json | ConvertTo-Json -Depth 10
              [System.IO.File]::WriteAllText($ConfigPath, $jsonStr, (New-Object System.Text.UTF8Encoding($False)))
              Write-Host "init-project: Removido registro MCP corrupto de mcp_config.json para higiene." -ForegroundColor Yellow
            }
          } catch {
            Write-Warning "init-project: No se pudo limpiar mcp_config.json de forma segura."
          }
        }
        
        # Declarar el servidor inactivo en brain/stack.md
        $stackPath = Join-Path $repoRoot 'brain/stack.md'
        if (Test-Path $stackPath) {
          try {
            $stackContent = Get-Content -Path $stackPath -Raw
            if ($stackContent -match '`semantic_server_active`:\s*true') {
              $stackContent = $stackContent -replace '`semantic_server_active`:\s*true', '`semantic_server_active`: false'
              [System.IO.File]::WriteAllText($stackPath, $stackContent, (New-Object System.Text.UTF8Encoding($False)))
              Write-Host "init-project: Desactivado flag semantic_server_active en brain/stack.md." -ForegroundColor Yellow
            }
          } catch {
             Write-Warning "init-project: No se pudo actualizar brain/stack.md."
          }
        }
      }
    }
  } else {
    Write-Host "init-project: (Aviso) No se detecto 'npm'. El servidor MCP semantico no pudo compilarse automaticamente." -ForegroundColor Yellow
    # Declarar el servidor inactivo en brain/stack.md si no hay npm
    $stackPath = Join-Path $repoRoot 'brain/stack.md'
    if (Test-Path $stackPath) {
      $stackContent = Get-Content -Path $stackPath -Raw
      if ($stackContent -match '`semantic_server_active`:\s*true') {
        $stackContent = $stackContent -replace '`semantic_server_active`:\s*true', '`semantic_server_active`: false'
        [System.IO.File]::WriteAllText($stackPath, $stackContent, (New-Object System.Text.UTF8Encoding($False)))
      }
    }
  }
}

if (-not $SkipChecks) {
  Invoke-CheckedScript -ScriptPath $runChecksScript
}

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
