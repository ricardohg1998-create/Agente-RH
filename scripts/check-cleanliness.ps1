[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$issues = New-Object System.Collections.Generic.List[string]

$excludedDirNames = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
@('.git', 'node_modules', '.venv', 'dist', 'build', 'out', 'coverage', '.cache') | ForEach-Object {
  [void]$excludedDirNames.Add($_)
}

function Normalize-ComparablePath {
  param([string]$Path)
  return $Path.TrimEnd('\', '/').Replace('/', '\')
}

function Get-RelativePath {
  param(
    [string]$Root,
    [string]$FullPath
  )

  $rootNorm = Normalize-ComparablePath -Path $Root
  $fullNorm = Normalize-ComparablePath -Path $FullPath
  $prefix = $rootNorm + '\'

  if ($fullNorm.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $fullNorm.Substring($prefix.Length)
  }

  return $fullNorm
}

$excludedAbsolutePaths = @(
  $(Normalize-ComparablePath -Path (Join-Path $repoRoot '.agent\local'))
)

function Should-SkipDirectory {
  param(
    [string]$FullPath,
    [string]$Name
  )

  if ($excludedDirNames.Contains($Name)) {
    return $true
  }

  $norm = Normalize-ComparablePath -Path $FullPath
  foreach ($excluded in $excludedAbsolutePaths) {
    if ($norm.Equals($excluded, [System.StringComparison]::OrdinalIgnoreCase)) {
      return $true
    }
    if ($norm.StartsWith($excluded + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
      return $true
    }
  }

  return $false
}

function Get-RepoFiles {
  param([string]$Root)

  $result = New-Object System.Collections.Generic.List[System.IO.FileInfo]
  $pending = New-Object System.Collections.Generic.Stack[string]
  $pending.Push($Root)

  while ($pending.Count -gt 0) {
    $current = $pending.Pop()
    $entries = Get-ChildItem -LiteralPath $current -Force -ErrorAction SilentlyContinue

    foreach ($entry in $entries) {
      if ($entry.PSIsContainer) {
        if (-not (Should-SkipDirectory -FullPath $entry.FullName -Name $entry.Name)) {
          $pending.Push($entry.FullName)
        }
        continue
      }

      $result.Add($entry)
    }
  }

  return $result
}

$allFiles = Get-RepoFiles -Root $repoRoot

$tempPatterns = @('*.tmp', '*.temp', '*.old', '*.orig', '*~')
foreach ($pattern in $tempPatterns) {
  $hits = $allFiles | Where-Object { $_.Name -like $pattern }
  foreach ($hit in $hits) {
    $relative = Get-RelativePath -Root $repoRoot -FullPath $hit.FullName
    $issues.Add("Basura detectada (recomendacion: borrar): $relative")
  }
}

foreach ($special in @('.DS_Store', 'Thumbs.db')) {
  $hits = $allFiles | Where-Object { $_.Name -eq $special }
  foreach ($hit in $hits) {
    $relative = Get-RelativePath -Root $repoRoot -FullPath $hit.FullName
    $issues.Add("Basura detectada (recomendacion: borrar): $relative")
  }
}

$sizeBuckets = @{}
foreach ($f in $allFiles) {
  if ($f.Name -eq '.gitkeep') { continue }
  if ($f.Length -eq 0) { continue }

  $len = $f.Length
  if ($null -eq $len) { continue }

  $sizeKey = [string]$len
  if ([string]::IsNullOrWhiteSpace($sizeKey)) { continue }

  if (-not $sizeBuckets.ContainsKey($sizeKey)) {
    $sizeBuckets[$sizeKey] = New-Object System.Collections.Generic.List[string]
  }
  $sizeBuckets[$sizeKey].Add($f.FullName)
}

$hashBuckets = @{}
foreach ($size in $sizeBuckets.Keys) {
  $bucket = $sizeBuckets[$size]
  if ($bucket.Count -lt 2) { continue }

  foreach ($fullPath in $bucket) {
    $hash = (Get-FileHash -Path $fullPath -Algorithm SHA256).Hash
    if (-not $hashBuckets.ContainsKey($hash)) {
      $hashBuckets[$hash] = New-Object System.Collections.Generic.List[string]
    }
    $hashBuckets[$hash].Add($fullPath)
  }
}

foreach ($hash in $hashBuckets.Keys) {
  $bucket = $hashBuckets[$hash]
  if ($bucket.Count -gt 1) {
    $rel = $bucket | ForEach-Object { Get-RelativePath -Root $repoRoot -FullPath $_ }
    $issues.Add("Posible duplicado (recomendacion: consolidar): $($rel -join ', ')")
  }
}

$criticalMustNotBeEmpty = @(
  'README.md',
  'AGENTS.md',
  'brain/now.md',
  'brain/current-state.md',
  'brain/stack.md',
  'brain/deep-summary.md',
  'brain/user-instructions.md'
)

foreach ($path in $criticalMustNotBeEmpty) {
  $fullPath = Join-Path $repoRoot $path
  if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
    $item = Get-Item -LiteralPath $fullPath
    if ($item.Length -eq 0) {
      $issues.Add("Archivo critico vacio (recomendacion: completar): $path")
    }
  }
}

$docPrefixes = @(
  $(Normalize-ComparablePath -Path (Join-Path $repoRoot 'brain')),
  $(Normalize-ComparablePath -Path (Join-Path $repoRoot 'docs'))
)

foreach ($doc in $allFiles) {
  $fullNorm = Normalize-ComparablePath -Path $doc.FullName
  $inScope = $false
  foreach ($prefix in $docPrefixes) {
    if ($fullNorm.StartsWith($prefix + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
      $inScope = $true
      break
    }
  }

  if (-not $inScope) { continue }

  $raw = Get-Content -Path $doc.FullName -Raw
  if ($raw -match '\[OBSOLETO\]' -or $raw -match 'STATUS:\s*DEPRECATED') {
    $relative = Get-RelativePath -Root $repoRoot -FullPath $doc.FullName
    $issues.Add("Contenido obsoleto marcado (recomendacion: archivar o limpiar): $relative")
  }
}

if ($issues.Count -gt 0) {
  Write-Host 'check-cleanliness: FALLA' -ForegroundColor Yellow
  Write-Host 'AGENT INSTRUCTION: No ignores este error. Lee los detalles abajo y limpia o consolidida los archivos detectados ANTES de continuar. NO reintentes sin hacer cambios.' -ForegroundColor Red
  $issues | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
  exit 1
}

Write-Host 'check-cleanliness: OK' -ForegroundColor Green
exit 0
