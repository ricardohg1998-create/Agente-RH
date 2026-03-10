[CmdletBinding()]
param(
  [string]$ConfigPath = '.agent/config/context-budget.json'
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

function Resolve-RepoPath {
  param([string]$Path)

  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }

  return (Join-Path $repoRoot $Path)
}

function Get-RelativePath {
  param(
    [string]$Root,
    [string]$FullPath
  )

  $rootWithSlash = $Root
  if (-not $rootWithSlash.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
    $rootWithSlash += [System.IO.Path]::DirectorySeparatorChar
  }

  if ($FullPath.StartsWith($rootWithSlash, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $FullPath.Substring($rootWithSlash.Length)
  }

  return $FullPath
}

function Normalize-Paragraph {
  param([string]$Text)

  $norm = $Text.ToLowerInvariant()
  $norm = $norm -replace '(?m)^\s{0,3}#{1,6}\s+', ''
  $norm = $norm -replace '(?m)^\s{0,3}[-*+]\s+', ''
  $norm = $norm -replace '(?m)^\s{0,3}\d+\.\s+', ''
  $norm = $norm -replace '[^a-z0-9\s]', ' '
  $norm = $norm -replace '\s+', ' '
  return $norm.Trim()
}

function Get-Paragraphs {
  param(
    [string]$Raw,
    [int]$MinChars
  )

  $withoutCode = [regex]::Replace($Raw, '(?s)```.*?```', ' ')
  $parts = [regex]::Split($withoutCode, "(\r?\n){2,}")

  $result = New-Object System.Collections.Generic.List[object]
  foreach ($part in $parts) {
    if ([string]::IsNullOrWhiteSpace($part)) { continue }

    $norm = Normalize-Paragraph -Text $part
    if ($norm.Length -lt $MinChars) { continue }

    $preview = $norm
    if ($preview.Length -gt 120) {
      $preview = $preview.Substring(0, 120) + '...'
    }

    $result.Add([pscustomobject]@{
        Normalized = $norm
        Preview    = $preview
      })
  }

  return $result
}

$configFullPath = Resolve-RepoPath -Path $ConfigPath
if (-not (Test-Path -LiteralPath $configFullPath -PathType Leaf)) {
  throw "No existe config: $ConfigPath"
}

$config = Get-Content -Path $configFullPath -Raw | ConvertFrom-Json

$warnMaxLines = [int]$config.warn.maxLines
$warnMaxChars = [int]$config.warn.maxChars
$criticalQuickLines = [int]$config.critical.quickLayer.maxLines
$criticalQuickChars = [int]$config.critical.quickLayer.maxChars
$dupMinParagraphChars = [int]$config.critical.duplication.minParagraphChars
$dupMinFiles = [int]$config.critical.duplication.minFiles

$textExtensions = @($config.textExtensions)
if ($textExtensions.Count -eq 0) {
  $textExtensions = @('.md', '.txt', '.json', '.yml', '.yaml')
}

$extensionSet = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)
foreach ($ext in $textExtensions) {
  if ([string]::IsNullOrWhiteSpace($ext)) { continue }
  $normalizedExt = $ext.Trim()
  if (-not $normalizedExt.StartsWith('.')) {
    $normalizedExt = '.' + $normalizedExt
  }
  [void]$extensionSet.Add($normalizedExt)
}

$files = New-Object System.Collections.Generic.List[object]
foreach ($scanPath in $config.scanPaths) {
  $scanFullPath = Resolve-RepoPath -Path $scanPath
  if (Test-Path -LiteralPath $scanFullPath -PathType Leaf) {
    $item = Get-Item -LiteralPath $scanFullPath
    if (-not $extensionSet.Contains($item.Extension)) {
      continue
    }

    $raw = Get-Content -Path $item.FullName -Raw
    $relative = Get-RelativePath -Root $repoRoot -FullPath $item.FullName
    $relative = $relative -replace '\\', '/'
    $lines = if ($raw.Length -eq 0) { 0 } else { ($raw -split "`r?`n").Count }
    $chars = $raw.Length
    $files.Add([pscustomobject]@{
        RelativePath = $relative
        Raw          = $raw
        Lines        = $lines
        Chars        = $chars
      })
    continue
  }

  if (-not (Test-Path -LiteralPath $scanFullPath -PathType Container)) { continue }

  Get-ChildItem -Path $scanFullPath -Recurse -File | Where-Object {
    $extensionSet.Contains($_.Extension)
  } | ForEach-Object {
    $full = $_.FullName
    $raw = Get-Content -Path $full -Raw
    $relative = Get-RelativePath -Root $repoRoot -FullPath $full
    $relative = $relative -replace '\\', '/'
    $lines = if ($raw.Length -eq 0) { 0 } else { ($raw -split "`r?`n").Count }
    $chars = $raw.Length

    $files.Add([pscustomobject]@{
        RelativePath = $relative
        Raw          = $raw
        Lines        = $lines
        Chars        = $chars
      })
  }
}

$warnings = New-Object System.Collections.Generic.List[string]
$criticals = New-Object System.Collections.Generic.List[string]

foreach ($f in $files) {
  if ($f.Lines -gt $warnMaxLines -or $f.Chars -gt $warnMaxChars) {
    $warnings.Add("[WARN] Exceso de tamano: $($f.RelativePath) | lines=$($f.Lines) chars=$($f.Chars)")
  }
}

$quickSet = @{}
foreach ($q in $config.quickLayerFiles) { $quickSet[$q -replace '\\', '/'] = $true }

foreach ($f in $files) {
  if ($quickSet.ContainsKey($f.RelativePath)) {
    if ($f.Lines -gt $criticalQuickLines -or $f.Chars -gt $criticalQuickChars) {
      $criticals.Add("[CRITICAL] Quick layer excedida: $($f.RelativePath) | lines=$($f.Lines)/$criticalQuickLines chars=$($f.Chars)/$criticalQuickChars")
    }
  }
}

$dupMap = @{}
$previewMap = @{}

foreach ($f in $files) {
  $paragraphs = Get-Paragraphs -Raw $f.Raw -MinChars $dupMinParagraphChars
  foreach ($p in $paragraphs) {
    if (-not $dupMap.ContainsKey($p.Normalized)) {
      $dupMap[$p.Normalized] = New-Object System.Collections.Generic.HashSet[string]
      $previewMap[$p.Normalized] = $p.Preview
    }
    [void]$dupMap[$p.Normalized].Add($f.RelativePath)
  }
}

foreach ($key in $dupMap.Keys) {
  $fileCount = $dupMap[$key].Count
  if ($fileCount -ge $dupMinFiles) {
    $fileList = ($dupMap[$key] | Sort-Object) -join ', '
    $preview = $previewMap[$key]
    $criticals.Add("[CRITICAL] Duplicacion fuerte ($fileCount archivos): `"$preview`" | files: $fileList")
  }
}

Write-Host 'check-context-budget: resumen' -ForegroundColor Cyan
Write-Host " - archivos escaneados: $($files.Count)"
Write-Host " - warnings: $($warnings.Count)"
Write-Host " - criticals: $($criticals.Count)"

if ($warnings.Count -gt 0) {
  Write-Host 'check-context-budget: WARNINGS' -ForegroundColor Yellow
  $warnings | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
}

if ($criticals.Count -gt 0) {
  Write-Host 'check-context-budget: CRITICALS' -ForegroundColor Red
  Write-Host 'AGENT INSTRUCTION: El Context Budget ha sido superado. Resume, consolida o archiva contenido para reducir el tamano ANTES de continuar.' -ForegroundColor Red
  $criticals | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
  exit 1
}

Write-Host 'check-context-budget: OK (sin criticals)' -ForegroundColor Green
exit 0
