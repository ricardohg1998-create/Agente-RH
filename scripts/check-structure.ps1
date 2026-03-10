[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$structurePath = Join-Path $repoRoot '.agent/config/repo-structure.json'

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

$errors = New-Object System.Collections.Generic.List[string]

foreach ($dir in $requiredDirs) {
  $dirPath = Resolve-RepoPath -Path $dir
  if (-not (Test-Path -LiteralPath $dirPath -PathType Container)) {
    $errors.Add("Directorio faltante: $dir")
  }
}

foreach ($file in $requiredFiles) {
  $filePath = Resolve-RepoPath -Path $file
  if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
    $errors.Add("Archivo faltante: $file")
  }
}

$rules = @(
  '.agent/rules/core.md',
  '.agent/rules/brain-maintenance.md',
  '.agent/rules/repo-hygiene.md',
  '.agent/rules/workflow-dispatch.md',
  '.agent/rules/context-budget.md'
)

foreach ($rule in $rules) {
  $rulePath = Resolve-RepoPath -Path $rule
  if (Test-Path -LiteralPath $rulePath -PathType Leaf) {
    $content = Get-Content -Path $rulePath -Raw
    if ($content.Length -gt 12000) {
      $errors.Add("Rule supera 12000 caracteres: $rule ($($content.Length))")
    }
  }
}

$configDir = Resolve-RepoPath -Path '.agent/config'
if (Test-Path -LiteralPath $configDir -PathType Container) {
  Get-ChildItem -Path $configDir -Filter *.json -File | ForEach-Object {
    try {
      Get-Content -Path $_.FullName -Raw | ConvertFrom-Json | Out-Null
    } catch {
      $relative = $_.FullName.Replace($repoRoot + [System.IO.Path]::DirectorySeparatorChar, '')
      $relative = $relative -replace '\\', '/'
      $errors.Add("JSON invalido: $relative")
    }
  }
}

$nowPath = Resolve-RepoPath -Path 'brain/now.md'
$statePath = Resolve-RepoPath -Path 'brain/current-state.md'
$stackPath = Resolve-RepoPath -Path 'brain/stack.md'
$deepPath = Resolve-RepoPath -Path 'brain/deep-summary.md'
$projectOverviewPath = Resolve-RepoPath -Path 'brain/project-overview.md'

$nowRaw = if (Test-Path -LiteralPath $nowPath -PathType Leaf) { Get-Content -Path $nowPath -Raw } else { '' }
$stateRaw = if (Test-Path -LiteralPath $statePath -PathType Leaf) { Get-Content -Path $statePath -Raw } else { '' }
$stackRaw = if (Test-Path -LiteralPath $stackPath -PathType Leaf) { Get-Content -Path $stackPath -Raw } else { '' }
$deepRaw = if (Test-Path -LiteralPath $deepPath -PathType Leaf) { Get-Content -Path $deepPath -Raw } else { '' }
$projectOverviewRaw = if (Test-Path -LiteralPath $projectOverviewPath -PathType Leaf) { Get-Content -Path $projectOverviewPath -Raw } else { '' }

if ($nowRaw -notmatch '<!-- QUICK-NOW:START -->' -or $nowRaw -notmatch '<!-- QUICK-NOW:END -->') {
  $errors.Add('brain/now.md no contiene marcadores QUICK-NOW.')
}
if ($stateRaw -notmatch '<!-- QUICK-STATE:START -->' -or $stateRaw -notmatch '<!-- QUICK-STATE:END -->') {
  $errors.Add('brain/current-state.md no contiene marcadores QUICK-STATE.')
}
if ($stackRaw -notmatch '<!-- QUICK-STACK:START -->' -or $stackRaw -notmatch '<!-- QUICK-STACK:END -->') {
  $errors.Add('brain/stack.md no contiene marcadores QUICK-STACK.')
}
if ($deepRaw -notmatch '<!-- QUICK-DEEP:START -->' -or $deepRaw -notmatch '<!-- QUICK-DEEP:END -->') {
  $errors.Add('brain/deep-summary.md no contiene marcadores QUICK-DEEP.')
}
if ($projectOverviewRaw -notmatch '<!-- QUICK-PROJECT:START -->' -or $projectOverviewRaw -notmatch '<!-- QUICK-PROJECT:END -->') {
  $errors.Add('brain/project-overview.md no contiene marcadores QUICK-PROJECT.')
}

if ($errors.Count -gt 0) {
  Write-Host 'check-structure: FALLA' -ForegroundColor Red
  $errors | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
  exit 1
}

Write-Host 'check-structure: OK' -ForegroundColor Green
exit 0
