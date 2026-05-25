# fs-utils.psm1

function Resolve-RepoPath {
  [CmdletBinding()]
  param([string]$Path)

  $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }

  return (Join-Path $repoRoot $Path)
}

function ConvertTo-NormalizedEol {
  [CmdletBinding()]
  param([string]$Text)

  if ([string]::IsNullOrEmpty($Text)) { return $Text }
  return ($Text -replace "`r`n", "`n") -replace "`r", "`n"
}

function Get-RelativeRepoPath {
  [CmdletBinding()]
  param(
    [string]$FullPath,
    [string]$RepoRoot
  )

  if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
  }

  $prefix = $RepoRoot
  if (-not $prefix.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
    $prefix += [System.IO.Path]::DirectorySeparatorChar
  }

  if ($FullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    return ($FullPath.Substring($prefix.Length) -replace '\\', '/')
  }

  return ($FullPath -replace '\\', '/')
}

Export-ModuleMember -Function Resolve-RepoPath, ConvertTo-NormalizedEol, Get-RelativeRepoPath
