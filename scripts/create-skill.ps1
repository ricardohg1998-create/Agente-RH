[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string]$Id,
  [Parameter(Mandatory=$true)]
  [string]$Title,
  [switch]$GenerateCatalog
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$skillsDir = Join-Path $repoRoot '.agent\skills'
$targetDir = Join-Path $skillsDir $Id

if (-not (Test-Path -LiteralPath $skillsDir -PathType Container)) {
  New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
}

if (Test-Path -LiteralPath $targetDir -PathType Container) {
  throw "La skill '$Id' ya existe."
}

New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
$skillFile = Join-Path $targetDir 'SKILL.md'

$content = @"
---
id: $Id
name: $Title
version: 1.0.0
---

# $Title

## Prerrequisitos
- Detallar qué necesita el agente o el proyecto antes de invocar esta skill.

## Instrucciones principales
1. Analizar contexto.
2. Ejecutar cambios paso a paso.
3. Verificar resultados.
"@

Set-Content -Path $skillFile -Encoding UTF8 -Value $content

Write-Host "Skill '$Id' generada exitosamente en $skillFile." -ForegroundColor Green

if ($GenerateCatalog) {
  $catalogScript = Join-Path $PSScriptRoot 'generate-catalog.ps1'
  if (Test-Path -LiteralPath $catalogScript -PathType Leaf) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $catalogScript
  }
}
exit 0
