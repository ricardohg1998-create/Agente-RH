[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string]$Id,
  [Parameter(Mandatory=$true)]
  [string]$Title,
  [string]$Description = '',
  [switch]$UpdateDocs
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$workflowsDir = Join-Path $repoRoot '.agent\workflows'
$workflowFile = Join-Path $workflowsDir "$Id.md"
$templatePath = Join-Path $repoRoot '.agent\templates\workflow-quick-layer-snippet.md'

if (-not (Test-Path -LiteralPath $workflowsDir -PathType Container)) {
  New-Item -ItemType Directory -Path $workflowsDir -Force | Out-Null
}

if (Test-Path -LiteralPath $workflowFile -PathType Leaf) {
  throw "El workflow '$Id' ya existe en $workflowFile"
}

$quickLayerSnippet = ''
if (Test-Path -LiteralPath $templatePath -PathType Leaf) {
  $quickLayerSnippet = (Get-Content -Path $templatePath -Raw).Trim()
}

if ([string]::IsNullOrWhiteSpace($Description)) {
  $Description = "(pendiente de definir)"
}

$content = @"
---
id: $Id
name: $Title
description: $Description
version: 1.0.0
modes: [planning, execution]
---

# Workflow: $Title

## Proposito

$Description

## Cuando usarlo

- (definir situaciones en las que se activa este workflow)

## Input esperado

- Alcance concreto.
- Objetivo.
- Restricciones (tiempo, riesgo, compatibilidad).

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
$quickLayerSnippet
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a capa profunda solo si hay gatillos de contexto.

## Pasos internos

1. Leer capa rapida.
2. Expandir a capa profunda si hay gatillos.
3. (definir pasos resolutivos)
4. Emitir output obligatorio.

## Herramientas sugeridas

- (mapear herramientas de Antigravity a pasos concretos: ``grep_search``, ``view_file``, ``run_command``, ``browser_subagent``, ``search_web``, ``list_dir``, etc.)

## Output obligatorio

1. Diagnostico general.
2. Hallazgos priorizados.
3. Plan de accion.
4. Riesgos y dudas abiertas.

## Criterios de calidad

- Cada hallazgo con evidencia y accion concreta.
- Priorizacion defendible tecnicamente.

## Composicion

- **Suele preceder a**: (workflows que tipicamente siguen)
- **Suele seguir a**: (workflows que tipicamente preceden)
- **Workflow sugerido al completar**: (el mas natural como siguiente paso)

## Brain read/write

- Leer: ``brain/now.md``, ``brain/current-state.md``, ``brain/stack.md``, ``brain/deep-summary.md``.
- Escribir: ``brain/now.md``, ``brain/current-state.md``, ``brain/deep-summary.md``, ``brain/changelog.md``.
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
