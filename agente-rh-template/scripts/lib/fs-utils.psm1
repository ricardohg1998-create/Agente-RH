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

Export-ModuleMember -Function Resolve-RepoPath, ConvertTo-NormalizedEol
