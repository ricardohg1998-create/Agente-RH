[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$issues = New-Object System.Collections.Generic.List[string]

$excludedDirNames = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
@('.git', 'node_modules', '.venv', 'dist', 'build', 'out', 'coverage', '.cache', 'agente-rh-template') | ForEach-Object {
  [void]$excludedDirNames.Add($_)
}

function ConvertTo-ComparablePath {
  param([string]$Path)
  return $Path.TrimEnd('\', '/').Replace('/', '\')
}

function Get-RelativePath {
  param(
    [string]$Root,
    [string]$FullPath
  )

  $rootNorm = ConvertTo-ComparablePath -Path $Root
  $fullNorm = ConvertTo-ComparablePath -Path $FullPath
  $prefix = $rootNorm + '\'

  if ($fullNorm.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $fullNorm.Substring($prefix.Length)
  }

  return $fullNorm
}

$excludedAbsolutePaths = @(
  $(ConvertTo-ComparablePath -Path (Join-Path $repoRoot '.agent\local'))
)

function Test-SkipDirectory {
  param(
    [string]$FullPath,
    [string]$Name
  )

  if ($excludedDirNames.Contains($Name)) {
    return $true
  }

  $norm = ConvertTo-ComparablePath -Path $FullPath
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
        if (-not (Test-SkipDirectory -FullPath $entry.FullName -Name $entry.Name)) {
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

$ephemeralFiles = @('implementation_plan.md', 'task.md', 'walkthrough.md')
foreach ($ephemeral in $ephemeralFiles) {
  $fullPath = Join-Path $repoRoot $ephemeral
  if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
    Write-Host " [WARN] Artefacto efimero activo (recomendacion: archivar en brain/session_logs o borrar antes del cierre): $ephemeral" -ForegroundColor Yellow
  }
}

$swarmDir = Join-Path $repoRoot 'brain\swarm'
if (Test-Path -LiteralPath $swarmDir -PathType Container) {
  $swarmFiles = @(Get-ChildItem -LiteralPath $swarmDir -File -Force | Where-Object { $_.Name -ne '.gitkeep' })
  if ($swarmFiles.Count -gt 0) {
    $issues.Add('Artefacto efimero activo (recomendacion: borrar brain/swarm antes del cierre): brain\swarm')
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
    $hash = (Get-FileHash -LiteralPath $fullPath -Algorithm SHA256).Hash
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
  $(ConvertTo-ComparablePath -Path (Join-Path $repoRoot 'brain')),
  $(ConvertTo-ComparablePath -Path (Join-Path $repoRoot 'docs'))
)

foreach ($doc in $allFiles) {
  $fullNorm = ConvertTo-ComparablePath -Path $doc.FullName
  $inScope = $false
  foreach ($prefix in $docPrefixes) {
    if ($fullNorm.StartsWith($prefix + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
      $inScope = $true
      break
    }
  }

  if (-not $inScope) { continue }

  $raw = [System.IO.File]::ReadAllText($doc.FullName, $utf8NoBom)
  if ($raw -match '\[OBSOLETO\]' -or $raw -match 'STATUS:\s*DEPRECATED') {
    $relative = Get-RelativePath -Root $repoRoot -FullPath $doc.FullName
    $issues.Add("Contenido obsoleto marcado (recomendacion: archivar o limpiar): $relative")
  }
}

$textExtensions = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
@('.md', '.ps1', '.psm1', '.json', '.yml', '.yaml', '.txt') | ForEach-Object {
  [void]$textExtensions.Add($_)
}

$mojibakeTokens = @(
  ([char]0x00C3).ToString(),
  ([char]0x00C2).ToString(),
  ([char]0x00E2).ToString(),
  ([char]0x00F0).ToString()
)
foreach ($textFile in $allFiles) {
  if (-not $textExtensions.Contains($textFile.Extension)) { continue }

  $relative = Get-RelativePath -Root $repoRoot -FullPath $textFile.FullName
  $relativeNorm = $relative -replace '\\', '/'
  if ($relativeNorm -like '.agent/skills/*') { continue }

  $raw = [System.IO.File]::ReadAllText($textFile.FullName, $utf8NoBom)
  foreach ($token in $mojibakeTokens) {
    if ($raw.Contains($token)) {
      $issues.Add("Mojibake detectado (recomendacion: reescribir en UTF-8 limpio): $relative")
      break
    }
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
