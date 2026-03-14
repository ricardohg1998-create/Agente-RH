# brain-utils.psm1

function Get-BrainBlock {
  [CmdletBinding()]
  param(
    [string]$Content,
    [string]$BlockId
  )

  $pattern = "(?s)<!-- ${BlockId}:START -->.*?<!-- ${BlockId}:END -->"
  $match = [regex]::Match($Content, $pattern)
  if ($match.Success) {
    return $match.Value
  }
  return $null
}

function Set-BrainBlock {
  [CmdletBinding()]
  param(
    [string]$Content,
    [string]$BlockId,
    [string]$NewBlockContent
  )

  $pattern = "(?s)<!-- ${BlockId}:START -->.*?<!-- ${BlockId}:END -->"
  if ($Content -match $pattern) {
    return $Content -replace $pattern, $NewBlockContent
  }
  return $Content
}

function Resolve-MergedValue {
  [CmdletBinding()]
  param(
    [string]$CurrentBlock,
    [string]$RegexPattern,
    [string]$NewValue
  )

  if (-not [string]::IsNullOrWhiteSpace($NewValue)) {
    return $NewValue
  }

  if ([string]::IsNullOrWhiteSpace($CurrentBlock)) {
    return '(sin definir)'
  }

  $match = [regex]::Match($CurrentBlock, $RegexPattern)
  if ($match.Success) {
    return $match.Groups[1].Value.Trim()
  }

  return '(sin definir)'
}

function Resolve-MergedList {
  [CmdletBinding()]
  param(
    [string]$CurrentBlock,
    [string]$RegexHeader,
    [string[]]$NewList
  )

  if ($null -ne $NewList -and $NewList.Count -gt 0) {
    return $NewList
  }

  if ([string]::IsNullOrWhiteSpace($CurrentBlock)) {
    return @()
  }

  $pattern = "(?s)## ${RegexHeader}\s*\n(.*?)(?=\n## |\n<!-- |$)"
  $match = [regex]::Match($CurrentBlock, $pattern)

  if ($match.Success) {
    $lines = $match.Groups[1].Value -split "`n"
    $list = New-Object System.Collections.Generic.List[string]
    foreach ($line in $lines) {
      if ($line -match '^\s*-\s+(.+)$') {
        $val = $matches[1].Trim()
        if ($val -ne '(sin registros)') {
          $list.Add($val)
        }
      }
    }
    return $list.ToArray()
  }

  return @()
}

Export-ModuleMember -Function Get-BrainBlock, Set-BrainBlock, Resolve-MergedValue, Resolve-MergedList
