[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$resolvePsBinPath = Join-Path $PSScriptRoot 'lib/resolve-ps-bin.ps1'
. $resolvePsBinPath
$psBin = Resolve-PowerShellBinary
$issues = New-Object System.Collections.Generic.List[string]

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

function Get-WorkflowMetadata {
  param([System.IO.FileInfo]$File)

  $raw = Get-Content -LiteralPath $File.FullName -Raw
  $idMatch = [regex]::Match($raw, '(?m)^id:\s*(.+?)\s*$')
  $nameMatch = [regex]::Match($raw, '(?m)^name:\s*(.+?)\s*$')

  if (-not $idMatch.Success -or -not $nameMatch.Success) {
    throw "Workflow invalido sin id/name: $($File.FullName)"
  }

  return [pscustomobject]@{
    Id = $idMatch.Groups[1].Value.Trim()
    Name = $nameMatch.Groups[1].Value.Trim()
    RelativePath = Get-RelativeRepoPath -FullPath $File.FullName
  }
}

function Add-MissingAndExtraIssues {
  param(
    [string[]]$Expected,
    [string[]]$Actual,
    [string]$ContextLabel
  )

  foreach ($missing in ($Expected | Where-Object { $_ -notin $Actual })) {
    $issues.Add("$ContextLabel no referencia ruta esperada: $missing")
  }

  foreach ($extra in ($Actual | Where-Object { $_ -notin $Expected })) {
    $issues.Add("$ContextLabel referencia ruta inexistente o sobrante: $extra")
  }
}

function Invoke-CheckOnlyGenerator {
  param(
    [string]$ScriptName,
    [string]$Label
  )

  $scriptPath = Join-Path $PSScriptRoot $ScriptName
  & $psBin -NoProfile -ExecutionPolicy Bypass -File $scriptPath -CheckOnly
  if ($LASTEXITCODE -ne 0) {
    $issues.Add("$Label desincronizado: ejecuta $ScriptName")
  }
}

$workflowFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot '.agent/workflows') -Filter *.md -File | Sort-Object Name
$workflows = @($workflowFiles | ForEach-Object { Get-WorkflowMetadata -File $_ })
$workflowIds = @($workflows | ForEach-Object { $_.Id })
$workflowPaths = @($workflows | ForEach-Object { $_.RelativePath })

if (($workflowIds | Select-Object -Unique).Count -ne $workflowIds.Count) {
  $issues.Add('Hay ids de workflows duplicados en .agent/workflows/.')
}

$repoStructure = Get-Content -LiteralPath (Join-Path $repoRoot '.agent/config/repo-structure.json') -Raw | ConvertFrom-Json
$requiredFiles = @($repoStructure.requiredFiles)
$requiredWorkflowPaths = @($requiredFiles | Where-Object { $_ -like '.agent/workflows/*.md' })
Add-MissingAndExtraIssues -Expected $workflowPaths -Actual $requiredWorkflowPaths -ContextLabel 'repo-structure.json (workflows)'

$managedFiles = @(
  '.agent/templates/workflow-quick-layer-snippet.md',
  'scripts/sync-brain.ps1',
  'scripts/generate-workflows-docs.ps1',
  'scripts/generate-catalog.ps1',
  'scripts/check-links.ps1'
)

$actualStackFiles = @()
$stacksRoot = Join-Path $repoRoot 'tools/stacks'
if (Test-Path -LiteralPath $stacksRoot -PathType Container) {
  $actualStackFiles = @(Get-ChildItem -LiteralPath $stacksRoot -Recurse -File | ForEach-Object { Get-RelativeRepoPath -FullPath $_.FullName })
}

$expectedManagedFiles = @($managedFiles + $actualStackFiles | Sort-Object -Unique)
$actualManagedFiles = @($requiredFiles | Where-Object {
  $_ -in $managedFiles -or $_ -like 'tools/stacks/*'
})
Add-MissingAndExtraIssues -Expected $expectedManagedFiles -Actual $actualManagedFiles -ContextLabel 'repo-structure.json (managed files)'

$readmeRaw = Get-Content -LiteralPath (Join-Path $repoRoot 'README.md') -Raw
$indexRaw = Get-Content -LiteralPath (Join-Path $repoRoot 'brain/workflows-index.md') -Raw
$dispatchRaw = Get-Content -LiteralPath (Join-Path $repoRoot '.agent/rules/workflow-dispatch.md') -Raw

$readmePaths = @([regex]::Matches($readmeRaw, '\.agent/workflows/[a-z0-9-]+\.md') | ForEach-Object { $_.Value } | Select-Object -Unique)
$indexPaths = @([regex]::Matches($indexRaw, '\.agent/workflows/[a-z0-9-]+\.md') | ForEach-Object { $_.Value } | Select-Object -Unique)
Add-MissingAndExtraIssues -Expected $workflowPaths -Actual $readmePaths -ContextLabel 'README.md'
Add-MissingAndExtraIssues -Expected $workflowPaths -Actual $indexPaths -ContextLabel 'brain/workflows-index.md'

foreach ($workflow in $workflows) {
  if ($readmeRaw -notmatch [regex]::Escape($workflow.Name)) {
    $issues.Add("README.md no menciona el nombre del workflow: $($workflow.Name)")
  }

  if ($readmeRaw -notmatch [regex]::Escape("id: $($workflow.Id)")) {
    $issues.Add("README.md no menciona el id del workflow: $($workflow.Id)")
  }

  if ($indexRaw -notmatch [regex]::Escape($workflow.Name)) {
    $issues.Add("brain/workflows-index.md no menciona el workflow: $($workflow.Name)")
  }

  if ($indexRaw -notmatch [regex]::Escape($workflow.Id)) {
    $issues.Add("brain/workflows-index.md no menciona el id del workflow: $($workflow.Id)")
  }

  if ($dispatchRaw -notmatch [regex]::Escape($workflow.Name)) {
    $issues.Add("workflow-dispatch.md no menciona el workflow: $($workflow.Name)")
  }

  if ($dispatchRaw -notmatch [regex]::Escape($workflow.Id)) {
    $issues.Add("workflow-dispatch.md no menciona el id del workflow: $($workflow.Id)")
  }
}

$ruleIds = @(
  Get-ChildItem -LiteralPath (Join-Path $repoRoot '.agent/rules') -Filter *.md -File | ForEach-Object {
    $raw = Get-Content -LiteralPath $_.FullName -Raw
    $match = [regex]::Match($raw, '(?m)^id:\s*(.+?)\s*$')
    if ($match.Success) {
      $match.Groups[1].Value.Trim()
    }
  }
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

$allowedDispatchIds = @($workflowIds + $ruleIds | Select-Object -Unique)
$dispatchIds = @([regex]::Matches($dispatchRaw, '\(`([^`]+)`\)') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
foreach ($dispatchId in $dispatchIds) {
  if ($dispatchId -notin $allowedDispatchIds) {
    $issues.Add("workflow-dispatch.md referencia un id inexistente: $dispatchId")
  }
}

Invoke-CheckOnlyGenerator -ScriptName 'generate-workflows-docs.ps1' -Label 'Bloques generados de workflows'
Invoke-CheckOnlyGenerator -ScriptName 'generate-catalog.ps1' -Label 'CATALOG.md'

if ($issues.Count -gt 0) {
  Write-Host 'check-crossrefs: FALLA' -ForegroundColor Red
  $issues | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
  exit 1
}

Write-Host 'check-crossrefs: OK' -ForegroundColor Green
exit 0
