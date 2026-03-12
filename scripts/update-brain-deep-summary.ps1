[CmdletBinding()]
param(
  [switch]$CheckOnly,
  [string]$PolicyPath = '.agent/config/brain-policy.json',
  [string]$SummaryPath = 'brain/deep-summary.md'
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$replaceMarkedSectionPath = Join-Path $PSScriptRoot 'lib/replace-marked-section.ps1'
. $replaceMarkedSectionPath

function Resolve-RepoPath {
  param([string]$Path)

  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }

  return (Join-Path $repoRoot $Path)
}

function Normalize-Eol {
  param([string]$Text)
  return ($Text -replace "`r`n", "`n").Trim()
}

function Normalize-ShortText {
  param([string]$Text)
  $t = $Text.Trim()
  $t = $t -replace '`', ''
  $t = $t -replace '\|', '/'
  $t = $t -replace '\s+', ' '
  return $t
}

function Get-DeepSummary {
  param([string]$Raw)

  $placeholderRegex = '(?i)\(sin registros\)|\(pendiente definir\)|\(sin definir\)|\(sin novedades\)|\bsin registros\b|\bpendiente definir\b|\bsin definir\b'

  $lines = @()
  foreach ($line in ($Raw -split "`r?`n")) {
    $clean = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($clean)) { continue }
    if ($clean.StartsWith('#')) { continue }
    if ($clean -eq '---') { continue }
    if ($clean.StartsWith('<!--')) { continue }
    if ($clean.StartsWith('```')) { continue }

    $item = $clean -replace '^\s*[-*+]\s+', ''
    $item = $item -replace '^\s*\d+\.\s+', ''
    $item = Normalize-ShortText -Text $item
    if ([string]::IsNullOrWhiteSpace($item)) { continue }
    if ($item -match $placeholderRegex) { continue }
    $lines += $item
  }

  if ($lines.Count -eq 0) {
    return 'sin novedades'
  }

  $summary = $lines[0]
  if ($summary.Length -gt 90) {
    $summary = $summary.Substring(0, 90).TrimEnd() + '...'
  }
  return $summary
}

function Get-DeepState {
  param(
    [string]$Raw,
    [string]$Summary
  )

  $placeholderRegex = '(?i)\(sin registros\)|\(pendiente definir\)|\(sin definir\)|\(sin novedades\)|\bsin registros\b|\bpendiente definir\b|\bsin definir\b'
  $hasPlaceholder = $Raw -match $placeholderRegex
  $hasDate = $Raw -match '\b\d{4}-\d{2}-\d{2}\b'
  $hasChecked = $Raw -match '\-\s*\[x\]'

  if ($hasDate -or $hasChecked) {
    return 'activo'
  }

  if ($hasPlaceholder) {
    return 'base'
  }

  if ($Summary -eq 'sin novedades') {
    return 'base'
  }

  return 'activo'
}

$policyFullPath = Resolve-RepoPath -Path $PolicyPath
$summaryFullPath = Resolve-RepoPath -Path $SummaryPath

if (-not (Test-Path -LiteralPath $policyFullPath -PathType Leaf)) {
  throw "No existe config: $PolicyPath"
}

if (-not (Test-Path -LiteralPath $summaryFullPath -PathType Leaf)) {
  throw "No existe archivo resumen: $SummaryPath"
}

$policy = Get-Content -Path $policyFullPath -Raw | ConvertFrom-Json
$deepFiles = @($policy.deepLayer.files)
if ($deepFiles.Count -eq 0) {
  throw "deepLayer.files vacio en $PolicyPath"
}

$lines = New-Object System.Collections.Generic.List[string]
foreach ($file in $deepFiles) {
  $deepFileFullPath = Resolve-RepoPath -Path $file

  if (-not (Test-Path -LiteralPath $deepFileFullPath -PathType Leaf)) {
    throw "Archivo profundo faltante: $file"
  }

  $raw = Get-Content -Path $deepFileFullPath -Raw
  $summary = Get-DeepSummary -Raw $raw
  $state = Get-DeepState -Raw $raw -Summary $summary
  $mod = (Get-Item -LiteralPath $deepFileFullPath).LastWriteTime.ToString('yyyy-MM-dd')
  $lines.Add("- $file | estado: $state | resumen: $summary | mod: $mod")
}

$newBody = @"
## Resumen profundo (auto)

$($lines -join "`r`n")
"@

$replace = Replace-MarkedSection -Path $summaryFullPath -StartMarker '<!-- QUICK-DEEP:START -->' -EndMarker '<!-- QUICK-DEEP:END -->' -NewBody $newBody -NoWrite

if ($CheckOnly) {
  if ((Normalize-Eol -Text $replace.CurrentBody) -ne (Normalize-Eol -Text "`r`n$newBody`r`n")) {
    Write-Host 'update-brain-deep-summary: desincronizado.' -ForegroundColor Red
    exit 1
  }

  Write-Host 'update-brain-deep-summary: sincronizado.' -ForegroundColor Green
  exit 0
}

Set-Content -Path $summaryFullPath -Encoding UTF8 -Value $replace.Updated
Write-Host 'update-brain-deep-summary: actualizado.' -ForegroundColor Green
exit 0
