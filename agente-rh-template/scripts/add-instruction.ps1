[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Instruction,
  [string]$Type = 'operativa',
  [string]$Source = 'usuario',
  [switch]$AffectsNow
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$resolvePsBinPath = Join-Path $PSScriptRoot 'lib/resolve-ps-bin.ps1'
. $resolvePsBinPath
$psBin = Resolve-PowerShellBinary

$utf8IoPath = Join-Path $PSScriptRoot 'lib/utf8-io.psm1'
Import-Module $utf8IoPath -Force
$fsUtilsPath = Join-Path $PSScriptRoot 'lib/fs-utils.psm1'
Import-Module $fsUtilsPath -Force

function ConvertTo-NormalizedText {
  param([string]$Text)
  $normalized = $Text.ToLowerInvariant()
  $normalized = $normalized -replace '[^a-z0-9\s]', ' '
  $normalized = $normalized -replace '\s+', ' '
  return $normalized.Trim()
}

function Add-QuickNote {
  param(
    [string]$Path,
    [string]$StartMarker,
    [string]$EndMarker,
    [string]$Note
  )

  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }
  $raw = Read-Utf8File -Path $Path
  $start = $raw.IndexOf($StartMarker)
  $end = $raw.IndexOf($EndMarker)
  if ($start -lt 0 -or $end -lt 0 -or $end -le $start) { return }

  $insertionPoint = $end
  $prefix = $raw.Substring(0, $insertionPoint)
  $suffix = $raw.Substring($insertionPoint)
  $newRaw = $prefix.TrimEnd() + "`n- $Note`n" + $suffix
  Write-Utf8File -Path $Path -Content $newRaw
}

$target = Resolve-RepoPath -Path 'brain/user-instructions.md'
if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
  throw "No existe $target"
}

$raw = Read-Utf8File -Path $target
$normNew = ConvertTo-NormalizedText -Text $Instruction

$existingMatches = [regex]::Matches($raw, 'texto:\s*(.+)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
$alreadyExists = $false
foreach ($match in $existingMatches) {
  $normExisting = ConvertTo-NormalizedText -Text $match.Groups[1].Value
  if ($normExisting -eq $normNew) {
    $alreadyExists = $true
    break
  }
}

if ($alreadyExists) {
  Write-Host 'La instruccion ya existe. No se agrega duplicado.' -ForegroundColor Yellow
  exit 0
}

$today = Get-Date -Format 'yyyy-MM-dd'
$entry = "- [x] $today | fuente: $Source | tipo: $Type | texto: $Instruction"

Write-Utf8File -Path $target -Content ($raw.TrimEnd() + "`n" + $entry + "`n")

if ($AffectsNow) {
  $note = "[$today] Nueva instruccion persistente: $Instruction"
  Add-QuickNote -Path (Resolve-RepoPath -Path 'brain/now.md') -StartMarker '<!-- QUICK-NOW:START -->' -EndMarker '<!-- QUICK-NOW:END -->' -Note $note
  Add-QuickNote -Path (Resolve-RepoPath -Path 'brain/current-state.md') -StartMarker '<!-- QUICK-STATE:START -->' -EndMarker '<!-- QUICK-STATE:END -->' -Note $note

  $changelogPath = Resolve-RepoPath -Path 'brain/changelog.md'
  if (Test-Path -LiteralPath $changelogPath -PathType Leaf) {
    $changelogContent = Read-Utf8File -Path $changelogPath
    Write-Utf8File -Path $changelogPath -Content ($changelogContent.TrimEnd() + "`n- $today | Instruccion persistente agregada: $Instruction`n")
  }
}

$updateDeepSummaryScript = Join-Path $PSScriptRoot 'update-brain-deep-summary.ps1'
& $psBin -NoProfile -ExecutionPolicy Bypass -File $updateDeepSummaryScript
if ($LASTEXITCODE -ne 0) {
  throw 'No se pudo actualizar brain/deep-summary.md'
}

Write-Host 'Instruccion agregada correctamente.' -ForegroundColor Green
exit 0
