[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$issues = New-Object System.Collections.Generic.List[string]

function Get-WorkflowMetadata {
  param([System.IO.FileInfo]$File)

  $raw = Get-Content -Path $File.FullName -Raw
  $idMatch = [regex]::Match($raw, '(?m)^id:\s*(.+?)\s*$')
  $nameMatch = [regex]::Match($raw, '(?m)^name:\s*(.+?)\s*$')

  if (-not $idMatch.Success -or -not $nameMatch.Success) {
    throw "Workflow invalido sin id/name: $($File.FullName)"
  }

  return [pscustomobject]@{
    Id = $idMatch.Groups[1].Value.Trim()
    Name = $nameMatch.Groups[1].Value.Trim()
    RelativePath = ('.agent/workflows/' + $File.Name)
  }
}

function Add-MissingAndExtraIssues {
  param(
    [string[]]$Expected,
    [string[]]$Actual,
    [string]$ContextLabel
  )

  foreach ($missing in ($Expected | Where-Object { $_ -notin $Actual })) {
    $issues.Add("$ContextLabel no referencia workflow esperado: $missing")
  }

  foreach ($extra in ($Actual | Where-Object { $_ -notin $Expected })) {
    $issues.Add("$ContextLabel referencia workflow inexistente: $extra")
  }
}

$workflowFiles = Get-ChildItem -Path (Join-Path $repoRoot '.agent/workflows') -Filter *.md -File | Sort-Object Name
$workflows = @($workflowFiles | ForEach-Object { Get-WorkflowMetadata -File $_ })

$workflowIds = @($workflows | ForEach-Object { $_.Id })
$workflowPaths = @($workflows | ForEach-Object { $_.RelativePath })

if (($workflowIds | Select-Object -Unique).Count -ne $workflowIds.Count) {
  $issues.Add('Hay ids de workflows duplicados en .agent/workflows/.')
}

$repoStructure = Get-Content -Path (Join-Path $repoRoot '.agent/config/repo-structure.json') -Raw | ConvertFrom-Json
$requiredWorkflowPaths = @($repoStructure.requiredFiles | Where-Object { $_ -like '.agent/workflows/*.md' })
Add-MissingAndExtraIssues -Expected $workflowPaths -Actual $requiredWorkflowPaths -ContextLabel 'repo-structure.json'

$readmeRaw = Get-Content -Path (Join-Path $repoRoot 'README.md') -Raw
$indexRaw = Get-Content -Path (Join-Path $repoRoot 'brain/workflows-index.md') -Raw
$dispatchRaw = Get-Content -Path (Join-Path $repoRoot '.agent/rules/workflow-dispatch.md') -Raw

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
  Get-ChildItem -Path (Join-Path $repoRoot '.agent/rules') -Filter *.md -File | ForEach-Object {
    $raw = Get-Content -Path $_.FullName -Raw
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

if ($issues.Count -gt 0) {
  Write-Host 'check-crossrefs: FALLA' -ForegroundColor Red
  $issues | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
  exit 1
}

Write-Host 'check-crossrefs: OK' -ForegroundColor Green
exit 0
