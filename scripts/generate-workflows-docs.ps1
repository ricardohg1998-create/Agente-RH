[CmdletBinding()]
param(
  [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$utf8IoPath = Join-Path $PSScriptRoot 'lib/utf8-io.psm1'
Import-Module $utf8IoPath -Force
$workflowDir = Join-Path $repoRoot '.agent/workflows'
$templatePath = Join-Path $repoRoot '.agent/templates/workflow-quick-layer-snippet.md'
$readmePath = Join-Path $repoRoot 'README.md'
$dispatchPath = Join-Path $repoRoot '.agent/rules/workflow-dispatch.md'
$indexPath = Join-Path $repoRoot 'brain/workflows-index.md'

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

function Get-MarkedSectionUpdate {
  param(
    [string]$Path,
    [string]$StartMarker,
    [string]$EndMarker,
    [string]$NewBody
  )

  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "Archivo no encontrado: $Path"
  }

  $raw = Read-Utf8File -Path $Path
  $startIdx = $raw.IndexOf($StartMarker)
  $endIdx = $raw.IndexOf($EndMarker)

  if ($startIdx -lt 0 -or $endIdx -lt 0 -or $endIdx -le $startIdx) {
    throw "Marcadores no validos en $Path"
  }

  $head = $raw.Substring(0, $startIdx + $StartMarker.Length)
  $tail = $raw.Substring($endIdx)
  $updated = $head + "`r`n" + $NewBody.Trim() + "`r`n" + $tail

  return [pscustomobject]@{
    Path = $Path
    Raw = $raw
    Updated = $updated
  }
}

function Get-SectionBody {
  param(
    [string]$Body,
    [string]$Heading
  )

  $escapedHeading = [regex]::Escape($Heading)
  $pattern = "(?ms)^##\s+$escapedHeading\s*(?<content>.*?)(?=^\s*##\s+|\z)"
  $match = [regex]::Match($Body, $pattern)
  if (-not $match.Success) {
    return ''
  }

  return $match.Groups['content'].Value.Trim()
}

function Get-FirstParagraph {
  param(
    [string]$Body,
    [string]$Heading
  )

  $sectionBody = Get-SectionBody -Body $Body -Heading $Heading
  if ([string]::IsNullOrWhiteSpace($sectionBody)) {
    return 'Sin descripcion.'
  }

  $paragraphs = [regex]::Split($sectionBody, "(\r?\n){2,}") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  foreach ($paragraph in $paragraphs) {
    $normalized = (($paragraph -split "`r?`n") | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join ' '
    if (-not [string]::IsNullOrWhiteSpace($normalized)) {
      return $normalized.Trim()
    }
  }

  return 'Sin descripcion.'
}

function Get-FirstBullet {
  param(
    [string]$Body,
    [string]$Heading
  )

  $sectionBody = Get-SectionBody -Body $Body -Heading $Heading
  if ([string]::IsNullOrWhiteSpace($sectionBody)) {
    return 'sin criterio documentado'
  }

  $match = [regex]::Match($sectionBody, '(?m)^\s*-\s*(.+?)\s*$')
  if ($match.Success) {
    return $match.Groups[1].Value.Trim().TrimEnd('.')
  }

  return 'sin criterio documentado'
}

function Format-InlineCode {
  param([string]$Text)

  return ('`' + $Text + '`')
}

function ConvertFrom-WorkflowFile {
  param([System.IO.FileInfo]$File)

  $raw = Read-Utf8File -Path $File.FullName
  $frontMatterMatch = [regex]::Match($raw, '(?s)^---\s*(?<front>.*?)\s*---\s*(?<body>.*)$')
  if (-not $frontMatterMatch.Success) {
    throw "Workflow sin frontmatter valido: $($File.FullName)"
  }

  $frontMatter = $frontMatterMatch.Groups['front'].Value
  $body = $frontMatterMatch.Groups['body'].Value.TrimStart()

  $idMatch = [regex]::Match($frontMatter, '(?m)^id:\s*(.+?)\s*$')
  $nameMatch = [regex]::Match($frontMatter, '(?m)^name:\s*(.+?)\s*$')
  $versionMatch = [regex]::Match($frontMatter, '(?m)^version:\s*(.+?)\s*$')
  $descriptionMatch = [regex]::Match($frontMatter, '(?m)^description:\s*(.+?)\s*$')
  $modesMatch = [regex]::Match($frontMatter, '(?m)^modes:\s*(.+?)\s*$')
  $modeMatch = [regex]::Match($frontMatter, '(?m)^mode:\s*(.+?)\s*$')

  if (-not $idMatch.Success -or -not $nameMatch.Success) {
    throw "Workflow sin id o name: $($File.FullName)"
  }

  $modes = if ($modesMatch.Success) { $modesMatch.Groups[1].Value.Trim() } elseif ($modeMatch.Success) { $modeMatch.Groups[1].Value.Trim() } else { 'sin definir' }
  $summary = if ($descriptionMatch.Success) { $descriptionMatch.Groups[1].Value.Trim() } else { Get-FirstParagraph -Body $body -Heading 'Proposito' }

  return [pscustomobject]@{
    Id = $idMatch.Groups[1].Value.Trim()
    Name = $nameMatch.Groups[1].Value.Trim()
    Version = if ($versionMatch.Success) { $versionMatch.Groups[1].Value.Trim() } else { 'sin definir' }
    Modes = $modes
    Summary = $summary
    Trigger = Get-FirstBullet -Body $body -Heading 'Cuando usarlo'
    RelativePath = Get-RelativeRepoPath -FullPath $File.FullName
    FullPath = $File.FullName
  }
}

if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
  throw "Falta template de quick layer: $templatePath"
}

$quickLayerSnippet = (Read-Utf8File -Path $templatePath).Trim()
$workflows = @(Get-ChildItem -Path $workflowDir -Filter *.md -File | Sort-Object Name | ForEach-Object { ConvertFrom-WorkflowFile -File $_ })

$workflowUpdates = New-Object System.Collections.Generic.List[object]
foreach ($workflow in $workflows) {
  $workflowUpdates.Add(
    (Get-MarkedSectionUpdate -Path $workflow.FullPath -StartMarker '<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->' -EndMarker '<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->' -NewBody $quickLayerSnippet)
  )
}

$readmeWorkflowsBody = ($workflows | ForEach-Object {
  '- ' + (Format-InlineCode -Text $_.Name) + ' (id: ' + $_.Id + ') -> ' + (Format-InlineCode -Text $_.RelativePath)
}) -join "`n"

$dispatchMapBody = ($workflows | ForEach-Object {
  '- ' + (Format-InlineCode -Text $_.Name) + ' (' + (Format-InlineCode -Text $_.Id) + '): ' + $_.Summary.TrimEnd('.') + '.'
}) -join "`n"

$dispatchCriteriaBody = ($workflows | ForEach-Object {
  '- Usar ' + (Format-InlineCode -Text $_.Name) + ' (' + (Format-InlineCode -Text $_.Id) + ') cuando: ' + $_.Trigger + '.'
}) -join "`n"

$readmeUpdate = Get-MarkedSectionUpdate -Path $readmePath -StartMarker '<!-- GENERATED:README-WORKFLOWS:START -->' -EndMarker '<!-- GENERATED:README-WORKFLOWS:END -->' -NewBody $readmeWorkflowsBody
$dispatchMapUpdate = Get-MarkedSectionUpdate -Path $dispatchPath -StartMarker '<!-- GENERATED:WORKFLOW-MAP:START -->' -EndMarker '<!-- GENERATED:WORKFLOW-MAP:END -->' -NewBody $dispatchMapBody
$dispatchTempPath = Join-Path $env:TEMP ('workflow-dispatch-' + [guid]::NewGuid().ToString() + '.md')
Write-Utf8File -Path $dispatchTempPath -Content $dispatchMapUpdate.Updated
try {
  $dispatchCriteriaUpdate = Get-MarkedSectionUpdate -Path $dispatchTempPath -StartMarker '<!-- GENERATED:WORKFLOW-DISPATCH:START -->' -EndMarker '<!-- GENERATED:WORKFLOW-DISPATCH:END -->' -NewBody $dispatchCriteriaBody
} finally {
  Remove-Item -LiteralPath $dispatchTempPath -Force -ErrorAction SilentlyContinue
}

$indexSummaryBody = ($workflows | ForEach-Object {
  '- ' + (Format-InlineCode -Text $_.Name) + ' (' + (Format-InlineCode -Text $_.Id) + ') -> ' + $_.Summary.TrimEnd('.') + '.'
}) -join "`n"

$indexDispatchBody = ($workflows | ForEach-Object {
  '- ' + (Format-InlineCode -Text $_.Name) + ' (' + (Format-InlineCode -Text $_.Id) + ') -> ' + $_.Trigger + '.'
}) -join "`n"

$indexSourcesBody = @(
  $workflows | ForEach-Object { '- ' + (Format-InlineCode -Text $_.RelativePath) }
  '- ' + (Format-InlineCode -Text '.agent/rules/context-budget.md')
) -join "`r`n"

$expectedIndex = @"
# Workflows Index

## Resumen

$indexSummaryBody
- `context-budget` -> control de deriva documental y consumo de contexto.

## Dispatch rapido

$indexDispatchBody
- `context-budget` acompana siempre al workflow elegido.

## Uso recomendado

1. Definir alcance.
2. Seleccionar workflow por objetivo.
3. Ejecutar con output obligatorio.
4. Actualizar capa rapida de `brain/` (`now.md`, `current-state.md`, `stack.md` si aplica).
5. Si cambia memoria profunda, sincronizar `deep-summary.md` en la misma tarea.

## Ubicacion fuente

$indexSourcesBody
"@

$pending = New-Object System.Collections.Generic.List[string]

foreach ($update in $workflowUpdates) {
  if ((ConvertTo-TrimmedEol -Text $update.Raw) -ne (ConvertTo-TrimmedEol -Text $update.Updated)) {
    $pending.Add((Get-RelativeRepoPath -FullPath $update.Path))
  }
}

if ((ConvertTo-TrimmedEol -Text $readmeUpdate.Raw) -ne (ConvertTo-TrimmedEol -Text $readmeUpdate.Updated)) {
  $pending.Add('README.md')
}

$dispatchExpected = $dispatchCriteriaUpdate.Updated
$dispatchCurrent = Read-Utf8File -Path $dispatchPath
if ((ConvertTo-TrimmedEol -Text $dispatchCurrent) -ne (ConvertTo-TrimmedEol -Text $dispatchExpected)) {
  $pending.Add('.agent/rules/workflow-dispatch.md')
}

$indexCurrent = Read-Utf8File -Path $indexPath
if ((ConvertTo-TrimmedEol -Text $indexCurrent) -ne (ConvertTo-TrimmedEol -Text $expectedIndex)) {
  $pending.Add('brain/workflows-index.md')
}

if ($CheckOnly) {
  if ($pending.Count -gt 0) {
    Write-Host 'generate-workflows-docs: desincronizado.' -ForegroundColor Red
    $pending | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
    exit 1
  }

  Write-Host 'generate-workflows-docs: OK' -ForegroundColor Green
  exit 0
}

foreach ($update in $workflowUpdates) {
  if ((ConvertTo-TrimmedEol -Text $update.Raw) -ne (ConvertTo-TrimmedEol -Text $update.Updated)) {
    Write-Utf8File -Path $update.Path -Content $update.Updated
  }
}

Write-Utf8File -Path $readmePath -Content $readmeUpdate.Updated
Write-Utf8File -Path $dispatchPath -Content $dispatchExpected
Write-Utf8File -Path $indexPath -Content $expectedIndex

Write-Host 'generate-workflows-docs: actualizado.' -ForegroundColor Green
exit 0
