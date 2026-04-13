$script:Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Read-Utf8File {
  param([string]$Path)
  return [System.IO.File]::ReadAllText($Path, $script:Utf8NoBom)
}

function Write-Utf8File {
  param([string]$Path, [string]$Content)
  [System.IO.File]::WriteAllText($Path, $Content, $script:Utf8NoBom)
}

Export-ModuleMember -Function Read-Utf8File, Write-Utf8File -Variable Utf8NoBom
