[CmdletBinding()]
param()

function Get-RelativeRepoPath {
  param(
    [string]$FullPath,
    [string]$RepoRoot
  )

  $prefix = $RepoRoot
  if (-not $prefix.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
    $prefix += [System.IO.Path]::DirectorySeparatorChar
  }

  if ($FullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    return ($FullPath.Substring($prefix.Length) -replace '\\', '/')
  }

  return ($FullPath -replace '\\', '/')
}
