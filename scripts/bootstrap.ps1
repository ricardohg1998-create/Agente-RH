[CmdletBinding()]
param(
  [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$structurePath = Join-Path $repoRoot '.agent/config/repo-structure.json'
$safeFiles = @('src/.gitkeep', 'tests/.gitkeep', 'tools/.gitkeep')

function Resolve-RepoPath {
  param([string]$Path)

  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }

  return (Join-Path $repoRoot $Path)
}

if (-not (Test-Path -LiteralPath $structurePath -PathType Leaf)) {
  throw "No existe manifiesto estructural: $structurePath"
}

$structure = Get-Content -Path $structurePath -Raw | ConvertFrom-Json
$requiredDirs = @($structure.requiredDirs)
$requiredFiles = @($structure.requiredFiles)

if ($requiredDirs.Count -eq 0 -or $requiredFiles.Count -eq 0) {
  throw "El manifiesto estructural no define requiredDirs/requiredFiles: $structurePath"
}

$created = New-Object System.Collections.Generic.List[string]
$missing = New-Object System.Collections.Generic.List[string]
$missingTrackedFiles = New-Object System.Collections.Generic.List[string]

foreach ($dir in $requiredDirs) {
  $dirPath = Resolve-RepoPath -Path $dir
  if (-not (Test-Path -LiteralPath $dirPath -PathType Container)) {
    if ($CheckOnly) {
      $missing.Add($dir)
    } else {
      New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
      $created.Add($dir)
    }
  }
}

foreach ($file in $requiredFiles) {
  $filePath = Resolve-RepoPath -Path $file
  if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
    if ($CheckOnly) {
      $missing.Add($file)
    } else {
      $missingTrackedFiles.Add($file)
    }
  }
}

foreach ($keep in $safeFiles) {
  $keepPath = Resolve-RepoPath -Path $keep
  if (-not (Test-Path -LiteralPath $keepPath -PathType Leaf)) {
    if (-not $CheckOnly) {
      Set-Content -Path $keepPath -Encoding UTF8 -Value ""
      $created.Add($keep)
    } else {
      $missing.Add($keep)
    }
  }
}

if ($CheckOnly) {
  if ($missing.Count -gt 0) {
    Write-Host 'Estructura incompleta. Faltan rutas:' -ForegroundColor Yellow
    $missing | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
    exit 1
  }

  Write-Host 'Estructura minima OK.' -ForegroundColor Green
  exit 0
}

if ($missingTrackedFiles.Count -gt 0) {
  Write-Host 'Bootstrap parcial: directorios y archivos seguros creados, pero faltan archivos versionados.' -ForegroundColor Yellow
  Write-Host 'Bootstrap no genera placeholders para archivos complejos. Restaura estas rutas desde el repo:' -ForegroundColor Yellow
  $missingTrackedFiles | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
  exit 1
}

if ($created.Count -eq 0) {
  Write-Host 'No se crearon rutas nuevas. Estructura ya presente.' -ForegroundColor Green
} else {
  Write-Host 'Bootstrap completado. Rutas creadas:' -ForegroundColor Green
  $created | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
}
