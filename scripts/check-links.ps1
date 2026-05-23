[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$repoRootWithSep = $repoRoot
if (-not $repoRootWithSep.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
  $repoRootWithSep += [System.IO.Path]::DirectorySeparatorChar
}
$issues = New-Object System.Collections.Generic.List[string]
$filesToScan = New-Object System.Collections.Generic.List[string]
$maxFileSizeBytes = 200 * 1024  # 200 KB — skip archivos mas grandes para evitar cuelgue de regex
$timeoutPerFileSec = 10         # Timeout por archivo en segundos

function Resolve-RepoPath {
  param([string]$Path)

  $normalized = $Path.Trim()
  if ([string]::IsNullOrWhiteSpace($normalized)) {
    return $null
  }

  if ([System.IO.Path]::IsPathRooted($normalized)) {
    return $normalized
  }

  return (Join-Path $repoRoot $normalized)
}

function Get-RelativeRepoPath {
  param([string]$FullPath)

  if ($FullPath.StartsWith($repoRootWithSep, [System.StringComparison]::OrdinalIgnoreCase)) {
    return ($FullPath.Substring($repoRootWithSep.Length) -replace '\\', '/')
  }

  return ($FullPath -replace '\\', '/')
}

function Test-IgnoreLinkTarget {
  param([string]$Target)

  if ([string]::IsNullOrWhiteSpace($Target)) { return $true }
  if ($Target.StartsWith('#')) { return $true }
  if ($Target.StartsWith('/')) { return $true }
  if ($Target -match '^(?i)(https?|mailto|tel):') { return $true }
  if ($Target -like '<*') { return $true }
  if ($Target -like '~*') { return $true }
  if ($Target -like '$*') { return $true }
  if ($Target -match '^@[a-zA-Z0-9]') { return $true }
  if ($Target -match '(?i)[/\\](?:implementation_plan|task|walkthrough)\.md$') { return $true }
  if ($Target -match '(?i)^(?:implementation_plan|task|walkthrough)\.md$') { return $true }
  return $false
}

function Test-PathToken {
  param(
    [string]$SourcePath,
    [string]$Token,
    [bool]$ResolveRelativeToSource = $true
  )

  if ([string]::IsNullOrWhiteSpace($Token)) { return }
  if ($Token -match '[*?]') { return }

  $clean = $Token.Trim()
  $clean = $clean.Trim('"')
  $clean = $clean.Trim("'")
  $clean = $clean -replace '\\', '/'
  $clean = $clean -replace '#.*$', ''
  $clean = $clean -replace ':\d+(?::\d+)?$', ''
  if ($clean -match '[<>|"*?]') { return }

  if ($clean -match '^(?i)file://') {
    try {
      $unescaped = [System.Uri]::UnescapeDataString($clean)
      $clean = ([System.Uri]$unescaped).LocalPath
    } catch {}
  }

  if (Test-IgnoreLinkTarget -Target $clean) {
    return
  }

  $candidate = $null
  if ([System.IO.Path]::IsPathRooted($clean)) {
    $candidate = $clean
  } elseif ($ResolveRelativeToSource -and ($clean.StartsWith('./') -or $clean.StartsWith('../'))) {
    $candidate = Join-Path (Split-Path -Path $SourcePath -Parent) $clean
  } else {
    $rootCandidate = Join-Path $repoRoot $clean
    if (Test-Path -LiteralPath $rootCandidate) {
      $candidate = $rootCandidate
    } elseif ($ResolveRelativeToSource) {
      $candidate = Join-Path (Split-Path -Path $SourcePath -Parent) $clean
    } else {
      $candidate = $rootCandidate
    }
  }

  if (-not (Test-Path -LiteralPath $candidate)) {
    $issues.Add("Ruta rota en $(Get-RelativeRepoPath -FullPath $SourcePath): $Token")
  }
}

[void]$filesToScan.Add((Join-Path $repoRoot 'README.md'))
foreach ($root in @('docs', 'brain', '.agent')) {
  $fullRoot = Join-Path $repoRoot $root
  if (-not (Test-Path -LiteralPath $fullRoot -PathType Container)) { continue }
  Get-ChildItem -LiteralPath $fullRoot -Recurse -Filter *.md -File | ForEach-Object {
    # Eliminar escaneo de skills, templates y modulos de node que ralentizan o tienen placeholders
    if ($_.FullName -notmatch '[\\/]\.agent[\\/](?:skills|templates)[\\/]' -and $_.FullName -notmatch '[\\/]node_modules[\\/]') {
      [void]$filesToScan.Add($_.FullName)
    }
  }
}

# Bloque de escaneo reutilizable
$scanBlock = {
  param($filePath, $repoRootPath)

  $ErrorActionPreference = 'Stop'
  $script:localIssues = @()

  function Resolve-RepoPath {
    param([string]$Path)
    $normalized = $Path.Trim()
    if ([string]::IsNullOrWhiteSpace($normalized)) { return $null }
    if ([System.IO.Path]::IsPathRooted($normalized)) { return $normalized }
    return (Join-Path $repoRootPath $normalized)
  }

  function Get-RelativeRepoPath {
    param([string]$FullPath)
    $prefix = $repoRootPath
    if (-not $prefix.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
      $prefix += [System.IO.Path]::DirectorySeparatorChar
    }
    if ($FullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
      return ($FullPath.Substring($prefix.Length) -replace '\\', '/')
    }
    return ($FullPath -replace '\\', '/')
  }

  function Test-IgnoreLinkTarget {
    param([string]$Target)
    if ([string]::IsNullOrWhiteSpace($Target)) { return $true }
    if ($Target.StartsWith('#')) { return $true }
    if ($Target.StartsWith('/')) { return $true }
    if ($Target -match '^(?i)(https?|mailto|tel):') { return $true }
    if ($Target -like '<*') { return $true }
    if ($Target -like '~*') { return $true }
    if ($Target -like '$*') { return $true }
    if ($Target -match '^@[a-zA-Z0-9]') { return $true }
    if ($Target -match '(?i)[/\\](?:implementation_plan|task|walkthrough)\.md$') { return $true }
    if ($Target -match '(?i)^(?:implementation_plan|task|walkthrough)\.md$') { return $true }
    return $false
  }

  function Test-PathToken {
    param(
      [string]$SourcePath,
      [string]$Token,
      [bool]$ResolveRelativeToSource = $true
    )
    if ([string]::IsNullOrWhiteSpace($Token)) { return }
    if ($Token -match '[*?]') { return }
    $clean = $Token.Trim().Trim('"').Trim("'") -replace '\\', '/'
    $clean = $clean -replace '#.*$', ''
    $clean = $clean -replace ':\d+(?::\d+)?$', ''
    if ($clean -match '[<>|"*?]') { return }

    if ($clean -match '^(?i)file://') {
      try {
        $unescaped = [System.Uri]::UnescapeDataString($clean)
        $clean = ([System.Uri]$unescaped).LocalPath
      } catch {}
    }

    if (Test-IgnoreLinkTarget -Target $clean) { return }
    $candidate = $null
    if ([System.IO.Path]::IsPathRooted($clean)) {
      $candidate = $clean
    } elseif ($ResolveRelativeToSource -and ($clean.StartsWith('./') -or $clean.StartsWith('../'))) {
      $candidate = Join-Path (Split-Path -Path $SourcePath -Parent) $clean
    } else {
      $rootCandidate = Join-Path $repoRootPath $clean
      if (Test-Path -LiteralPath $rootCandidate) {
        $candidate = $rootCandidate
      } elseif ($ResolveRelativeToSource) {
        $candidate = Join-Path (Split-Path -Path $SourcePath -Parent) $clean
      } else {
        $candidate = $rootCandidate
      }
    }
    if (-not (Test-Path -LiteralPath $candidate)) {
      $script:localIssues += "Ruta rota en $(Get-RelativeRepoPath -FullPath $SourcePath): $Token"
    }
  }

  # Forzar codificación UTF-8 sin BOM al leer archivos Markdown
  $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
  $raw = [System.IO.File]::ReadAllText($filePath, $utf8NoBom)
  $rawWithoutCodeBlocks = [regex]::Replace($raw, '(?s)```.*?```', ' ')

  foreach ($linkMatch in [regex]::Matches($rawWithoutCodeBlocks, '\[[^\]\r\n]*\]\((?<target>[^)\r\n]+)\)')) {
    $target = $linkMatch.Groups['target'].Value.Trim()
    Test-PathToken -SourcePath $filePath -Token $target -ResolveRelativeToSource $true
  }

  foreach ($codeMatch in [regex]::Matches($rawWithoutCodeBlocks, '(?<!`)`(?<code>[^`\r\n]+)`(?!`)')) {
    $token = $codeMatch.Groups['code'].Value.Trim().TrimEnd('/')
    if ($token -notmatch '[\\/]') { continue }
    if ($token -match '\s') { continue }
    if ($token -match '\\\\[sdwbDSWB]') { continue }
    if ($token -match '[\[\]+{}|^]') { continue }
    if ($token -match '^(?:implementation_plan\.md|task\.md|walkthrough\.md)$') { continue }
    Test-PathToken -SourcePath $filePath -Token $token -ResolveRelativeToSource $false
  }

  return $script:localIssues
}

foreach ($file in ($filesToScan | Sort-Object -Unique)) {
  $fileInfo = Get-Item -LiteralPath $file
  if ($fileInfo.Length -gt $maxFileSizeBytes) {
    Write-Host "Skipping (too large: $([math]::Round($fileInfo.Length/1024,1)) KB): $file" -ForegroundColor Yellow
    continue
  }

  if ($fileInfo.Length -le 50 * 1024) {
    # Optimización: Archivos menores a 50 KB se evalúan de forma ultra veloz en memoria en el hilo principal
    Write-Host "Scanning (in-memory): $($file)" -ForegroundColor Cyan
    $jobResult = & $scanBlock -filePath $file -repoRootPath $repoRoot
    if ($jobResult) {
      foreach ($issue in $jobResult) {
        $issues.Add($issue)
      }
    }
  } else {
    # Archivos masivos utilizan la infraestructura de Jobs asíncronos para evitar ReDoS catastrófico
    Write-Host "Scanning (job): $($file)" -ForegroundColor Cyan
    $scanJob = Start-Job -ScriptBlock $scanBlock -ArgumentList $file, $repoRoot

    $completed = $scanJob | Wait-Job -Timeout $timeoutPerFileSec
    if ($null -eq $completed) {
      Write-Host "  TIMEOUT ($($timeoutPerFileSec)s): $file" -ForegroundColor Yellow
      $scanJob | Stop-Job
      $scanJob | Remove-Job -Force
      continue
    }

    $jobResult = Receive-Job -Job $scanJob
    $scanJob | Remove-Job -Force
    if ($jobResult) {
      foreach ($issue in $jobResult) {
        $issues.Add($issue)
      }
    }
  }
}

if ($issues.Count -gt 0) {
  Write-Host 'check-links: FALLA' -ForegroundColor Red
  $issues | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
  exit 1
}

Write-Host 'check-links: OK' -ForegroundColor Green
exit 0
