[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$configPath = Join-Path $repoRoot '.agent/config/skills-sources.json'

function Resolve-RepoPath {
  param([string]$Path)

  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }

  return (Join-Path $repoRoot $Path)
}

$config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
$enabledSessionSource = @($config.sessionSources | Where-Object { $_.enabled -eq $true }).Count -gt 0
$catalogEntries = New-Object System.Collections.Generic.List[object]

if ($null -ne $config.preferredCatalog -and $config.preferredCatalog.enabled -eq $true -and -not [string]::IsNullOrWhiteSpace($config.preferredCatalog.path)) {
  $catalogEntries.Add([pscustomobject]@{
    Name = $config.preferredCatalog.name
    Path = $config.preferredCatalog.path
  })
}

foreach ($catalog in @($config.fallbackCatalogs)) {
  if ($catalog.enabled -eq $true -and -not [string]::IsNullOrWhiteSpace($catalog.path)) {
    $catalogEntries.Add([pscustomobject]@{
      Name = $catalog.name
      Path = $catalog.path
    })
  }
}

$warnings = New-Object System.Collections.Generic.List[string]
$errors = New-Object System.Collections.Generic.List[string]
$seenPaths = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)

foreach ($entry in $catalogEntries) {
  $fullPath = Resolve-RepoPath -Path $entry.Path
  if (-not $seenPaths.Add($fullPath)) {
    continue
  }

  if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
    continue
  }

  if ($enabledSessionSource) {
    $warnings.Add("[WARN] Catalogo local faltante con fallback de sesion disponible: $($entry.Path)")
  } else {
    $errors.Add("Catalogo local faltante sin fallback de sesion: $($entry.Path)")
  }
}

if ($warnings.Count -gt 0) {
  Write-Host 'check-skills-catalog: WARNINGS' -ForegroundColor Yellow
  $warnings | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
}

if ($errors.Count -gt 0) {
  Write-Host 'check-skills-catalog: FALLA' -ForegroundColor Red
  $errors | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
  exit 1
}

Write-Host 'check-skills-catalog: OK' -ForegroundColor Green
exit 0
