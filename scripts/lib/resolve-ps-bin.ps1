[CmdletBinding()]
param()

function Resolve-PowerShellBinary {
  [CmdletBinding()]
  param()

  foreach ($candidate in @('pwsh', 'powershell')) {
    if (Get-Command $candidate -ErrorAction SilentlyContinue) {
      return $candidate
    }
  }

  throw 'No se encontro pwsh ni powershell en PATH.'
}
