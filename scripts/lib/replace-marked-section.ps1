function Replace-MarkedSection {
  param(
    [string]$Path,
    [string]$StartMarker,
    [string]$EndMarker,
    [string]$NewBody,
    [switch]$NoWrite,
    [switch]$PassThru
  )

  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "Archivo no encontrado: $Path"
  }

  $raw = Get-Content -Path $Path -Raw
  $startIdx = $raw.IndexOf($StartMarker)
  $endIdx = $raw.IndexOf($EndMarker)

  if ($startIdx -lt 0 -or $endIdx -lt 0 -or $endIdx -le $startIdx) {
    throw "Marcadores no validos en $Path"
  }

  $head = $raw.Substring(0, $startIdx + $StartMarker.Length)
  $tail = $raw.Substring($endIdx)
  $updated = $head + "`r`n" + $NewBody.Trim() + "`r`n" + $tail

  if (-not $NoWrite) {
    Set-Content -Path $Path -Encoding UTF8 -Value $updated
  }

  if ($NoWrite -or $PassThru) {
    return [pscustomobject]@{
      Raw = $raw
      Updated = $updated
      CurrentBody = $raw.Substring($startIdx + $StartMarker.Length, $endIdx - ($startIdx + $StartMarker.Length))
    }
  }
}
