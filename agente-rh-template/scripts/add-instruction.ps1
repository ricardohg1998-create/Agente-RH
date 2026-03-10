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

function Resolve-RepoPath {
  param([string]$Path)

  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }

  return (Join-Path $repoRoot $Path)
}

function Normalize-Text {
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
  $raw = Get-Content -Path $Path -Raw
  $start = $raw.IndexOf($StartMarker)
  $end = $raw.IndexOf($EndMarker)
  if ($start -lt 0 -or $end -lt 0 -or $end -le $start) { return }

  $insertionPoint = $end
  $prefix = $raw.Substring(0, $insertionPoint)
  $suffix = $raw.Substring($insertionPoint)
  $newRaw = $prefix.TrimEnd() + "`r`n- $Note`r`n" + $suffix
  Set-Content -Path $Path -Encoding UTF8 -Value $newRaw
}

$target = Resolve-RepoPath -Path 'brain/user-instructions.md'
if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
  throw "No existe $target"
}

$raw = Get-Content -Path $target -Raw
$normNew = Normalize-Text -Text $Instruction

$existingMatches = [regex]::Matches($raw, 'texto:\s*(.+)$', [System.Text.RegularExpressions.RegexOptions]::Multiline)
$alreadyExists = $false
foreach ($match in $existingMatches) {
  $normExisting = Normalize-Text -Text $match.Groups[1].Value
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

Set-Content -Path $target -Encoding UTF8 -Value ($raw.TrimEnd() + "`r`n" + $entry + "`r`n")

if ($AffectsNow) {
  $note = "[$today] Nueva instruccion persistente: $Instruction"
  Add-QuickNote -Path (Resolve-RepoPath -Path 'brain/now.md') -StartMarker '<!-- QUICK-NOW:START -->' -EndMarker '<!-- QUICK-NOW:END -->' -Note $note
  Add-QuickNote -Path (Resolve-RepoPath -Path 'brain/current-state.md') -StartMarker '<!-- QUICK-STATE:START -->' -EndMarker '<!-- QUICK-STATE:END -->' -Note $note

  $changelogPath = Resolve-RepoPath -Path 'brain/changelog.md'
  if (Test-Path -LiteralPath $changelogPath -PathType Leaf) {
    Add-Content -Path $changelogPath -Encoding UTF8 -Value "- $today | Instruccion persistente agregada: $Instruction"
  }
}

$updateDeepSummaryScript = Join-Path $PSScriptRoot 'update-brain-deep-summary.ps1'
& $psBin -NoProfile -ExecutionPolicy Bypass -File $updateDeepSummaryScript
if ($LASTEXITCODE -ne 0) {
  throw 'No se pudo actualizar brain/deep-summary.md'
}

Write-Host 'Instruccion agregada correctamente.' -ForegroundColor Green
exit 0
