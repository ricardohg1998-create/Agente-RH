[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Title,
  [Parameter(Mandatory = $true)]
  [string]$Context,
  [Parameter(Mandatory = $true)]
  [string]$Decision,
  [Parameter(Mandatory = $true)]
  [string]$Consequences,
  [string]$Status = 'accepted',
  [string]$Id
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$resolvePsBinPath = Join-Path $PSScriptRoot 'lib/resolve-ps-bin.ps1'
. $resolvePsBinPath
$psBin = Resolve-PowerShellBinary
$utf8IoPath = Join-Path $PSScriptRoot 'lib/utf8-io.psm1'
Import-Module $utf8IoPath -Force

if (-not $Id) {
  $Id = 'DEC-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
}

$today = Get-Date -Format 'yyyy-MM-dd'

$decisionPath = Join-Path $repoRoot 'brain/decisions.md'
$changelogPath = Join-Path $repoRoot 'brain/changelog.md'

if (-not (Test-Path -LiteralPath $decisionPath -PathType Leaf)) {
  throw "No existe $decisionPath"
}
if (-not (Test-Path -LiteralPath $changelogPath -PathType Leaf)) {
  throw "No existe $changelogPath"
}

$block = @"

---

### $Id

- Fecha: $today
- Estado: $Status
- Titulo: $Title

Contexto:
$Context

Decision:
$Decision

Consecuencias:
$Consequences
"@

$currentDecisions = Read-Utf8File -Path $decisionPath
Write-Utf8File -Path $decisionPath -Content ($currentDecisions.TrimEnd() + "`n" + $block.TrimEnd() + "`n")

$currentChangelog = Read-Utf8File -Path $changelogPath
Write-Utf8File -Path $changelogPath -Content ($currentChangelog.TrimEnd() + "`n- $today | Decision registrada ($Id): $Title`n")

$updateDeepSummaryScript = Join-Path $PSScriptRoot 'update-brain-deep-summary.ps1'
& $psBin -NoProfile -ExecutionPolicy Bypass -File $updateDeepSummaryScript
if ($LASTEXITCODE -ne 0) {
  throw 'No se pudo actualizar brain/deep-summary.md'
}

Write-Host "Decision registrada: $Id" -ForegroundColor Green
exit 0
