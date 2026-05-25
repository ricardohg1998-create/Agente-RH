# scripts/lib/link-utils.psm1
[CmdletBinding()]
param()

Import-Module (Join-Path $PSScriptRoot 'fs-utils.psm1') -Force

function Test-IgnoreLinkTarget {
  param([string]$Target)
  if ([string]::IsNullOrWhiteSpace($Target)) { return $true }
  if ($Target.StartsWith('#')) { return $true }
  if ($Target.StartsWith('//')) { return $true }
  if ($Target -match '^(?i)(https?|mailto|tel):') { return $true }
  if ($Target -like '<*') { return $true }
  if ($Target -like '~*') { return $true }
  if ($Target -like '$*') { return $true }
  if ($Target -match '^@[a-zA-Z0-9]') { return $true }
  if ($Target -match '(?i)[/\\](?:implementation_plan|task|walkthrough)\.md$') { return $true }
  if ($Target -match '(?i)^(?:implementation_plan|task|walkthrough)\.md$') { return $true }
  if ($Target -match '(?i)\.vscode[/\\]') { return $true }
  if ($Target -match '(?i)semantic-server[/\\]build[/\\]') { return $true }
  if ($Target -match '(?i)deploy\.ps1$') { return $true }
  return $false
}

function Test-PathToken {
  param(
    [string]$SourcePath,
    [string]$Token,
    [string]$repoRoot,
    [bool]$ResolveRelativeToSource = $true
  )
  if ([string]::IsNullOrWhiteSpace($Token)) { return $null }
  if ($Token -match '[*?]') { return $null }
  
  $clean = $Token.Trim().Trim('"').Trim("'") -replace '\\', '/'
  $clean = $clean -replace '#.*$', ''
  $clean = $clean -replace ':\d+(?::\d+)?$', ''
  if ($clean -match '[<>|"*?]') { return $null }

  # Desescapar codificaciones URL comunes de forma universal
  try {
    $clean = [System.Uri]::UnescapeDataString($clean)
  } catch {}

  if ($clean -match '^(?i)file://') {
    try {
      $clean = ([System.Uri]$clean).LocalPath
    } catch {}
  }

  if (Test-IgnoreLinkTarget -Target $clean) { return $null }

  $candidate = $null
  if ($clean.StartsWith('/')) {
    $candidate = Join-Path $repoRoot ($clean.TrimStart('/'))
  } elseif ([System.IO.Path]::IsPathRooted($clean)) {
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
    $relSource = Get-RelativeRepoPath -FullPath $SourcePath -repoRoot $repoRoot
    return "Ruta rota en ${relSource}: $Token"
  }

  return $null
}

Export-ModuleMember -Function Test-IgnoreLinkTarget, Test-PathToken
