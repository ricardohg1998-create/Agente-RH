[CmdletBinding()]
param(
  [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$catalogPath = Join-Path $repoRoot 'CATALOG.md'
$skillsRoot = Join-Path $repoRoot '.agent/skills'

$utf8IoPath = Join-Path $PSScriptRoot 'lib/utf8-io.psm1'
Import-Module $utf8IoPath -Force

function ConvertTo-TrimmedEol {
  param([string]$Text)

  return ($Text -replace "`r`n", "`n").Trim()
}

function Get-RelativeRepoPath {
  param([string]$FullPath)

  $prefix = $repoRoot
  if (-not $prefix.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
    $prefix += [System.IO.Path]::DirectorySeparatorChar
  }

  if ($FullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    return ($FullPath.Substring($prefix.Length) -replace '\\', '/')
  }

  return ($FullPath -replace '\\', '/')
}

function Get-SectionParagraph {
  param([string]$Raw)

  $lines = @()
  foreach ($line in ($Raw -split "`r?`n")) {
    $clean = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($clean)) { continue }
    if ($clean.StartsWith('#')) { continue }
    if ($clean.StartsWith('```')) { continue }
    if ($clean.StartsWith('---')) { continue }
    $lines += $clean
  }

  if ($lines.Count -eq 0) {
    return 'Sin descripcion.'
  }

  $summary = ($lines -join ' ')
  if ($summary.Length -gt 120) {
    $summary = $summary.Substring(0, 120).TrimEnd() + '...'
  }

  return $summary
}

function Format-InlineCode {
  param([string]$Text)

  return ('`' + $Text + '`')
}

$skillFiles = @()
if (Test-Path -LiteralPath $skillsRoot -PathType Container) {
  $skillFiles = @(Get-ChildItem -Path $skillsRoot -Filter SKILL.md -Recurse -File | Sort-Object FullName)
}

$skillLines = New-Object System.Collections.Generic.List[string]
foreach ($skillFile in $skillFiles) {
  $raw = Read-Utf8File -Path $skillFile.FullName
  $directoryName = Split-Path -Path $skillFile.DirectoryName -Leaf
  $summary = Get-SectionParagraph -Raw $raw
  $relativePath = Get-RelativeRepoPath -FullPath $skillFile.FullName
  $skillLines.Add(('- ' + (Format-InlineCode -Text $directoryName) + " -> $summary (" + (Format-InlineCode -Text $relativePath) + ').'))
}

$skillsBody = if ($skillLines.Count -eq 0) { '- (sin registros)' } else { $skillLines -join "`n" }
$statusLine = if ($skillLines.Count -eq 0) { '- Sin skills locales registradas todavia.' } else { "- Skills locales detectadas: $($skillLines.Count)." }

$expected = @"
# CATALOG

Catalogo local generado automaticamente desde `.agent/skills/`.

## Estado

- Generado automaticamente por `scripts/generate-catalog.ps1`.
$statusLine

## Uso

- Este catalogo solo refleja skills locales versionadas en este workspace.
- Las fuentes globales o de sesion siguen resolviendose fuera de este archivo.

## Skills workspace

$skillsBody
"@

if ($CheckOnly) {
  if (-not (Test-Path -LiteralPath $catalogPath -PathType Leaf)) {
    Write-Host 'generate-catalog: CATALOG.md faltante.' -ForegroundColor Red
    exit 1
  }

  $current = Read-Utf8File -Path $catalogPath
  if ((ConvertTo-TrimmedEol -Text $current) -ne (ConvertTo-TrimmedEol -Text $expected)) {
    Write-Host 'generate-catalog: desincronizado.' -ForegroundColor Red
    exit 1
  }

  Write-Host 'generate-catalog: OK' -ForegroundColor Green
  exit 0
}

Write-Utf8File -Path $catalogPath -Content $expected
Write-Host 'generate-catalog: actualizado.' -ForegroundColor Green
exit 0
