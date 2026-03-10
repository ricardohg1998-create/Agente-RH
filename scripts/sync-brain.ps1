[CmdletBinding()]
param(
  [string]$SummaryNow = 'Sin resumen nuevo.',
  [string]$NextAction = 'Pendiente definir.',
  [string[]]$Blockers = @('Ninguno.'),
  [string]$CurrentState = 'activo',
  [string]$Risk = 'no definido',
  [string]$UpdatedBy = 'agent',
  [string]$Phase,
  [string]$ProjectVision,
  [string[]]$ProjectGoals,
  [string[]]$ScopeIn,
  [string[]]$ScopeOut,
  [string]$StackFrontend,
  [string]$StackBackend,
  [string]$StackDatabase,
  [string]$StackInfrastructure,
  [string]$StackHosting,
  [string]$StackRationale,
  [string[]]$StackAlternatives,
  [string[]]$StackVersions,
  [string[]]$StackCriticalDependencies,
  [switch]$SyncDeepSummary
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$resolvePsBinPath = Join-Path $PSScriptRoot 'lib/resolve-ps-bin.ps1'
. $resolvePsBinPath
$psBin = Resolve-PowerShellBinary
$script:boundParameters = @{}
foreach ($entry in $PSBoundParameters.GetEnumerator()) {
  $script:boundParameters[$entry.Key] = $entry.Value
}

function Resolve-RepoPath {
  param([string]$Path)

  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }

  return (Join-Path $repoRoot $Path)
}

function Replace-MarkedSection {
  param(
    [string]$Path,
    [string]$StartMarker,
    [string]$EndMarker,
    [string]$NewBody
  )

  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "Archivo no encontrado: $Path"
  }

  $raw = Get-Content -Path $Path -Raw
  $startIdx = $raw.IndexOf($StartMarker)
  $endIdx = $raw.IndexOf($EndMarker)

  if ($startIdx -lt 0 -or $endIdx -lt 0 -or $endIdx -le $startIdx) {
    throw "Marcadores no validos en $Path"
  }

  $head = $raw.Substring(0, $startIdx + $StartMarker.Length)
  $tail = $raw.Substring($endIdx)
  $updated = $head + "`r`n" + $NewBody.Trim() + "`r`n" + $tail
  Set-Content -Path $Path -Encoding UTF8 -Value $updated
}

function Get-MarkedSectionBody {
  param(
    [string]$Path,
    [string]$StartMarker,
    [string]$EndMarker
  )

  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "Archivo no encontrado: $Path"
  }

  $raw = Get-Content -Path $Path -Raw
  $startIdx = $raw.IndexOf($StartMarker)
  $endIdx = $raw.IndexOf($EndMarker)

  if ($startIdx -lt 0 -or $endIdx -lt 0 -or $endIdx -le $startIdx) {
    throw "Marcadores no validos en $Path"
  }

  return $raw.Substring($startIdx + $StartMarker.Length, $endIdx - ($startIdx + $StartMarker.Length))
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

  return $match.Groups['content'].Value
}

function Get-SectionLines {
  param(
    [string]$Body,
    [string]$Heading
  )

  $sectionBody = Get-SectionBody -Body $Body -Heading $Heading
  if ([string]::IsNullOrWhiteSpace($sectionBody)) {
    return @()
  }

  $items = New-Object System.Collections.Generic.List[string]
  foreach ($item in [regex]::Matches($sectionBody, '(?m)^\s*-\s*(.+?)\s*$')) {
    $value = $item.Groups[1].Value.Trim()
    if (-not [string]::IsNullOrWhiteSpace($value)) {
      $items.Add($value)
    }
  }

  return @($items)
}

function Get-FirstSectionLine {
  param(
    [string]$Body,
    [string]$Heading
  )

  $items = Get-SectionLines -Body $Body -Heading $Heading
  if ($items.Count -eq 0) {
    return $null
  }

  return $items[0]
}

function Get-LabeledBulletValue {
  param(
    [string]$Body,
    [string]$Label
  )

  $pattern = '(?m)^\s*-\s*' + [regex]::Escape($Label) + ':\s*(.+?)\s*$'
  $match = [regex]::Match($Body, $pattern)
  if ($match.Success) {
    return $match.Groups[1].Value.Trim()
  }

  return $null
}

function Get-PlainSectionParagraph {
  param(
    [string]$Body,
    [string]$Heading
  )

  $sectionBody = Get-SectionBody -Body $Body -Heading $Heading
  if ([string]::IsNullOrWhiteSpace($sectionBody)) {
    return $null
  }

  $lines = @()
  foreach ($line in ($sectionBody -split "`r?`n")) {
    $clean = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($clean)) {
      continue
    }

    if ($clean -match '^\s*-\s+') {
      continue
    }

    $lines += $clean
  }

  if ($lines.Count -eq 0) {
    return $null
  }

  return ($lines -join ' ')
}

function Resolve-MergedValue {
  param(
    [string]$ParameterName,
    [string]$ExistingValue,
    [string]$Fallback
  )

  if ($script:boundParameters.ContainsKey($ParameterName)) {
    return [string](Get-Variable -Name $ParameterName -Scope Script -ValueOnly)
  }

  if (-not [string]::IsNullOrWhiteSpace($ExistingValue)) {
    return $ExistingValue
  }

  return $Fallback
}

function Resolve-MergedList {
  param(
    [string]$ParameterName,
    [object[]]$ExistingValue,
    [string[]]$Fallback
  )

  if ($script:boundParameters.ContainsKey($ParameterName)) {
    $value = Get-Variable -Name $ParameterName -Scope Script -ValueOnly
    if ($null -eq $value) {
      return @()
    }

    return @($value | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  }

  if ($null -ne $ExistingValue -and $ExistingValue.Count -gt 0) {
    return @($ExistingValue)
  }

  return @($Fallback)
}

function Format-BulletList {
  param(
    [string[]]$Items,
    [string]$EmptyFallback = '(sin registros)'
  )

  $normalized = @($Items | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
  if ($normalized.Count -eq 0) {
    return "- $EmptyFallback"
  }

  return ($normalized | ForEach-Object { "- $_" }) -join "`r`n"
}

$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
$nowPath = Resolve-RepoPath -Path 'brain/now.md'
$statePath = Resolve-RepoPath -Path 'brain/current-state.md'
$stackPath = Resolve-RepoPath -Path 'brain/stack.md'
$projectOverviewPath = Resolve-RepoPath -Path 'brain/project-overview.md'

$nowBodyCurrent = Get-MarkedSectionBody -Path $nowPath -StartMarker '<!-- QUICK-NOW:START -->' -EndMarker '<!-- QUICK-NOW:END -->'
$stateBodyCurrent = Get-MarkedSectionBody -Path $statePath -StartMarker '<!-- QUICK-STATE:START -->' -EndMarker '<!-- QUICK-STATE:END -->'

$summaryNowValue = Resolve-MergedValue -ParameterName 'SummaryNow' -ExistingValue (Get-FirstSectionLine -Body $nowBodyCurrent -Heading 'Estado actual') -Fallback 'Sin resumen nuevo.'
$nextActionValue = Resolve-MergedValue -ParameterName 'NextAction' -ExistingValue (Get-FirstSectionLine -Body $nowBodyCurrent -Heading 'Siguiente accion recomendada') -Fallback 'Pendiente definir.'
$blockersValue = Resolve-MergedList -ParameterName 'Blockers' -ExistingValue (Get-SectionLines -Body $nowBodyCurrent -Heading 'Bloqueos activos') -Fallback @('Ninguno.')
$currentStateValue = Resolve-MergedValue -ParameterName 'CurrentState' -ExistingValue (Get-LabeledBulletValue -Body $stateBodyCurrent -Label 'Estado') -Fallback 'activo'
$phaseValue = Resolve-MergedValue -ParameterName 'Phase' -ExistingValue (Get-LabeledBulletValue -Body $stateBodyCurrent -Label 'Fase') -Fallback 'sin definir'
$riskValue = Resolve-MergedValue -ParameterName 'Risk' -ExistingValue (Get-LabeledBulletValue -Body $stateBodyCurrent -Label 'Riesgo principal') -Fallback 'no definido'
$blockersText = ($blockersValue | ForEach-Object { "- $_" }) -join "`r`n"

$nowBody = @"
## Estado actual

- $summaryNowValue

## Siguiente accion recomendada

- $nextActionValue

## Bloqueos activos

$blockersText

## Cambios recientes

- [$stamp] Actualizacion rapida por $UpdatedBy.
"@

$stateBody = @"
## Resumen operativo

- Estado: $currentStateValue
- Fase: $phaseValue
- Ultima actualizacion: $stamp
- Riesgo principal: $riskValue

## Calidad de contexto

- Capa rapida actualizada en esta ejecucion.
- Capa profunda: actualizar si aplica.

## Proxima validacion

- Ejecutar `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1`.
"@

Replace-MarkedSection -Path $nowPath -StartMarker '<!-- QUICK-NOW:START -->' -EndMarker '<!-- QUICK-NOW:END -->' -NewBody $nowBody
Replace-MarkedSection -Path $statePath -StartMarker '<!-- QUICK-STATE:START -->' -EndMarker '<!-- QUICK-STATE:END -->' -NewBody $stateBody

$stackParameterNames = @(
  'StackFrontend',
  'StackBackend',
  'StackDatabase',
  'StackInfrastructure',
  'StackHosting',
  'StackRationale',
  'StackAlternatives',
  'StackVersions',
  'StackCriticalDependencies'
)

$shouldUpdateStack = $false
foreach ($parameterName in $stackParameterNames) {
  if ($script:boundParameters.ContainsKey($parameterName)) {
    $shouldUpdateStack = $true
    break
  }
}

if ($shouldUpdateStack) {
  $stackCurrentBody = Get-MarkedSectionBody -Path $stackPath -StartMarker '<!-- QUICK-STACK:START -->' -EndMarker '<!-- QUICK-STACK:END -->'
  $stackBody = @"
## Stack elegido

- Frontend: $(Resolve-MergedValue -ParameterName 'StackFrontend' -ExistingValue (Get-LabeledBulletValue -Body $stackCurrentBody -Label 'Frontend') -Fallback '(sin definir)')
- Backend: $(Resolve-MergedValue -ParameterName 'StackBackend' -ExistingValue (Get-LabeledBulletValue -Body $stackCurrentBody -Label 'Backend') -Fallback '(sin definir)')
- Base de datos: $(Resolve-MergedValue -ParameterName 'StackDatabase' -ExistingValue (Get-LabeledBulletValue -Body $stackCurrentBody -Label 'Base de datos') -Fallback '(sin definir)')
- Infraestructura: $(Resolve-MergedValue -ParameterName 'StackInfrastructure' -ExistingValue (Get-LabeledBulletValue -Body $stackCurrentBody -Label 'Infraestructura') -Fallback '(sin definir)')
- Hosting/Deploy: $(Resolve-MergedValue -ParameterName 'StackHosting' -ExistingValue (Get-LabeledBulletValue -Body $stackCurrentBody -Label 'Hosting/Deploy') -Fallback '(sin definir)')

## Razon de la eleccion

- $(Resolve-MergedValue -ParameterName 'StackRationale' -ExistingValue (Get-FirstSectionLine -Body $stackCurrentBody -Heading 'Razon de la eleccion') -Fallback '(pendiente de definir alcance del proyecto)')

## Alternativas descartadas

$(Format-BulletList -Items (Resolve-MergedList -ParameterName 'StackAlternatives' -ExistingValue (Get-SectionLines -Body $stackCurrentBody -Heading 'Alternativas descartadas') -Fallback @('(sin registros)')))

## Versiones pinneadas

$(Format-BulletList -Items (Resolve-MergedList -ParameterName 'StackVersions' -ExistingValue (Get-SectionLines -Body $stackCurrentBody -Heading 'Versiones pinneadas') -Fallback @('(sin registros)')))

## Dependencias criticas

$(Format-BulletList -Items (Resolve-MergedList -ParameterName 'StackCriticalDependencies' -ExistingValue (Get-SectionLines -Body $stackCurrentBody -Heading 'Dependencias criticas') -Fallback @('(sin registros)')))
"@

  Replace-MarkedSection -Path $stackPath -StartMarker '<!-- QUICK-STACK:START -->' -EndMarker '<!-- QUICK-STACK:END -->' -NewBody $stackBody
}

$projectParameterNames = @('ProjectVision', 'ProjectGoals', 'ScopeIn', 'ScopeOut')
$shouldUpdateProjectOverview = $false
foreach ($parameterName in $projectParameterNames) {
  if ($script:boundParameters.ContainsKey($parameterName)) {
    $shouldUpdateProjectOverview = $true
    break
  }
}

if ($shouldUpdateProjectOverview) {
  $projectBodyCurrent = Get-MarkedSectionBody -Path $projectOverviewPath -StartMarker '<!-- QUICK-PROJECT:START -->' -EndMarker '<!-- QUICK-PROJECT:END -->'
  $projectVisionValue = Resolve-MergedValue -ParameterName 'ProjectVision' -ExistingValue (Get-PlainSectionParagraph -Body $projectBodyCurrent -Heading 'Vision') -Fallback 'Vision pendiente de definir.'
  $projectGoalsValue = Resolve-MergedList -ParameterName 'ProjectGoals' -ExistingValue (Get-SectionLines -Body $projectBodyCurrent -Heading 'Objetivos') -Fallback @('(sin registros)')
  $scopeInValue = Resolve-MergedList -ParameterName 'ScopeIn' -ExistingValue (Get-SectionLines -Body $projectBodyCurrent -Heading 'Alcance actual') -Fallback @('(sin registros)')
  $scopeOutValue = Resolve-MergedList -ParameterName 'ScopeOut' -ExistingValue (Get-SectionLines -Body $projectBodyCurrent -Heading 'Fuera de alcance actual') -Fallback @('(sin registros)')

  $projectBody = @"
## Vision

$projectVisionValue

## Objetivos

$(Format-BulletList -Items $projectGoalsValue)

## Alcance actual

$(Format-BulletList -Items $scopeInValue)

## Fuera de alcance actual

$(Format-BulletList -Items $scopeOutValue)
"@

  Replace-MarkedSection -Path $projectOverviewPath -StartMarker '<!-- QUICK-PROJECT:START -->' -EndMarker '<!-- QUICK-PROJECT:END -->' -NewBody $projectBody
}

if ($SyncDeepSummary) {
  $syncScript = Join-Path $PSScriptRoot 'update-brain-deep-summary.ps1'
  & $psBin -NoProfile -ExecutionPolicy Bypass -File $syncScript
  if ($LASTEXITCODE -ne 0) {
    throw 'No se pudo sincronizar brain/deep-summary.md'
  }
}

Write-Host 'sync-brain: OK' -ForegroundColor Green
return
