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

Add-Content -Path $decisionPath -Encoding UTF8 -Value $block
Add-Content -Path $changelogPath -Encoding UTF8 -Value "- $today | Decision registrada ($Id): $Title"

$updateDeepSummaryScript = Join-Path $PSScriptRoot 'update-brain-deep-summary.ps1'
& $psBin -NoProfile -ExecutionPolicy Bypass -File $updateDeepSummaryScript
if ($LASTEXITCODE -ne 0) {
  throw 'No se pudo actualizar brain/deep-summary.md'
}

Write-Host "Decision registrada: $Id" -ForegroundColor Green
exit 0
