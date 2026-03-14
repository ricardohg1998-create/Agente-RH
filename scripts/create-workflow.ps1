[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string]$Id,
  [Parameter(Mandatory=$true)]
  [string]$Title,
  [switch]$UpdateDocs
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$workflowsDir = Join-Path $repoRoot '.agent\workflows'
$workflowFile = Join-Path $workflowsDir "$Id.md"

if (-not (Test-Path -LiteralPath $workflowsDir -PathType Container)) {
  New-Item -ItemType Directory -Path $workflowsDir -Force | Out-Null
}

if (Test-Path -LiteralPath $workflowFile -PathType Leaf) {
  throw "El workflow '$Id' ya existe en $workflowFile"
}

$content = @"
---
id: $Id
name: $Title
activation: model-decision
version: 1.0.0
---

# $Title

<objective>
## Goal
Definir claramente el objetivo principal de este workflow.
</objective>

<context>
## Contexto o Pre-requisitos
- ¿Cuándo y por qué se usa este workflow?
</context>

<instructions>
## Steps
1. **Analizar la situación.**
2. **Ejecutar pasos resolutivos.**
3. **Validar y cerrar.**
</instructions>
"@

Set-Content -Path $workflowFile -Encoding UTF8 -Value $content

Write-Host "Workflow '$Id' generado exitosamente en $workflowFile." -ForegroundColor Green

if ($UpdateDocs) {
  $updateScript = Join-Path $PSScriptRoot 'generate-workflows-docs.ps1'
  if (Test-Path -LiteralPath $updateScript -PathType Leaf) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $updateScript
  }
}
exit 0
