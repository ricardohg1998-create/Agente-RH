[CmdletBinding()]
param()

function Normalize-Eol {
  param([string]$Text)
  return ($Text -replace "`r`n", "`n").Trim()
}
