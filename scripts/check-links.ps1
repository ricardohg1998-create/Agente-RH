[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$issues = New-Object System.Collections.Generic.List[string]
$filesToScan = New-Object System.Collections.Generic.List[string]

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

  $prefix = $repoRoot
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
  Get-ChildItem -Path $fullRoot -Recurse -Filter *.md -File | ForEach-Object {
    # Eliminar escaneo de skills (suelen contener links de ejemplo)
    if ($_.FullName -notmatch '[\\/]\.agent[\\/]skills[\\/]') {
      [void]$filesToScan.Add($_.FullName)
    }
  }
}

foreach ($file in ($filesToScan | Sort-Object -Unique)) {
  Write-Host "Scanning: $($file)" -ForegroundColor Cyan
  $raw = Get-Content -Path $file -Raw
  $rawWithoutCodeBlocks = [regex]::Replace($raw, '(?s)```.*?```', ' ')

  foreach ($linkMatch in [regex]::Matches($rawWithoutCodeBlocks, '\[[^\]\r\n]*\]\((?<target>[^)\r\n]+)\)')) {
    $target = $linkMatch.Groups['target'].Value.Trim()
    Test-PathToken -SourcePath $file -Token $target -ResolveRelativeToSource $true
  }

  foreach ($codeMatch in [regex]::Matches($rawWithoutCodeBlocks, '(?<!`)`(?<code>[^`\r\n]+)`(?!`)')) {
    $token = $codeMatch.Groups['code'].Value.Trim()
    if ($token -notmatch '[\\/]' -and $token -notmatch '\.(md|ps1|json|ya?ml|sh|txt)$') { continue }
    if ($token -match '^(?:implementation_plan\.md|task\.md|walkthrough\.md)$') { continue }
    Test-PathToken -SourcePath $file -Token $token -ResolveRelativeToSource $false
  }
}

if ($issues.Count -gt 0) {
  Write-Host 'check-links: FALLA' -ForegroundColor Red
  $issues | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
  exit 1
}

Write-Host 'check-links: OK' -ForegroundColor Green
exit 0
