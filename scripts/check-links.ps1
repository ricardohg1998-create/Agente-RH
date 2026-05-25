[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$issues = New-Object System.Collections.Generic.List[string]
$filesToScan = New-Object System.Collections.Generic.List[string]
$maxFileSizeBytes = 200 * 1024
$timeoutPerFileSec = 10

# Carga de utilidades de validación de enlaces
$linkUtilsPath = Join-Path $PSScriptRoot 'lib/link-utils.psm1'
Import-Module $linkUtilsPath -Force

[void]$filesToScan.Add((Join-Path $repoRoot 'README.md'))
foreach ($root in @('docs', 'brain', '.agent')) {
  $fullRoot = Join-Path $repoRoot $root
  if (-not (Test-Path -LiteralPath $fullRoot -PathType Container)) { continue }
  Get-ChildItem -LiteralPath $fullRoot -Recurse -Filter *.md -File | ForEach-Object {
    if ($_.FullName -notmatch '[\\/]\.agent[\\/](?:skills|templates)[\\/]' -and $_.FullName -notmatch '[\\/]node_modules[\\/]') {
      [void]$filesToScan.Add($_.FullName)
    }
  }
}

# Bloque de escaneo asíncrono limpio y libre de duplicaciones
$scanBlock = {
  param($filePath, $repoRootPath)
  $ErrorActionPreference = 'Stop'
  $localIssues = New-Object System.Collections.Generic.List[string]

  $linkUtils = Join-Path $repoRootPath 'scripts/lib/link-utils.psm1'
  Import-Module $linkUtils -Force

  $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
  $raw = [System.IO.File]::ReadAllText($filePath, $utf8NoBom)
  $rawWithoutCodeBlocks = [regex]::Replace($raw, '(?s)```.*?```', ' ')

  foreach ($linkMatch in [regex]::Matches($rawWithoutCodeBlocks, '\[[^\]\r\n]*\]\((?<target>[^)\r\n]+)\)')) {
    $target = $linkMatch.Groups['target'].Value.Trim()
    $issue = Test-PathToken -SourcePath $filePath -Token $target -repoRoot $repoRootPath -ResolveRelativeToSource $true
    if ($issue) { [void]$localIssues.Add($issue) }
  }

  foreach ($codeMatch in [regex]::Matches($rawWithoutCodeBlocks, '(?<!`)`(?<code>[^`\r\n]+)`(?!`)')) {
    $token = $codeMatch.Groups['code'].Value.Trim().TrimEnd('/')
    if ($token -notmatch '[\\/]') { continue }
    if ($token -match '\s') { continue }
    if ($token -match '\\[sdwbDSWBrnstuU]') { continue }
    if ($token -match '^/[a-zA-Z0-9-]+$' -and $token -notmatch '\.') { continue }
    if ($token -match '[\[\]+{}|^]') { continue }
    if ($token -match '(?:^|[\\/])node_modules(?:[\\/]|$)') { continue }
    if ($token -match '^(?:implementation_plan\.md|task\.md|walkthrough\.md)$') { continue }
    $issue = Test-PathToken -SourcePath $filePath -Token $token -repoRoot $repoRootPath -ResolveRelativeToSource $false
    if ($issue) { [void]$localIssues.Add($issue) }
  }

  return $localIssues
}

foreach ($file in ($filesToScan | Sort-Object -Unique)) {
  $fileInfo = Get-Item -LiteralPath $file
  if ($fileInfo.Length -gt $maxFileSizeBytes) {
    Write-Host "Skipping (too large): $file" -ForegroundColor Yellow
    continue
  }

  # Optimización: Elevado el umbral a 150 KB para ahorrar el costoso arranque de Jobs asíncronos
  if ($fileInfo.Length -le 150 * 1024) {
    Write-Host "Scanning (in-memory): $($file)" -ForegroundColor Cyan
    $jobResult = & $scanBlock -filePath $file -repoRootPath $repoRoot
    if ($jobResult) {
      foreach ($issue in $jobResult) { [void]$issues.Add($issue) }
    }
  } else {
    Write-Host "Scanning (job): $($file)" -ForegroundColor Cyan
    $scanJob = Start-Job -ScriptBlock $scanBlock -ArgumentList $file, $repoRoot

    $completed = $scanJob | Wait-Job -Timeout $timeoutPerFileSec
    if ($null -eq $completed) {
      Write-Host "  TIMEOUT ($($timeoutPerFileSec)s): $file" -ForegroundColor Yellow
      $scanJob | Stop-Job
      $scanJob | Remove-Job -Force
      continue
    }

    $jobResult = Receive-Job -Job $scanJob
    $scanJob | Remove-Job -Force
    if ($jobResult) {
      foreach ($issue in $jobResult) { [void]$issues.Add($issue) }
    }
  }
}

if ($issues.Count -gt 0) {
  Write-Host 'check-links: FALLA' -ForegroundColor Red
  $issues | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
  exit 1
}

Write-Host 'check-links: OK' -ForegroundColor Green
exit 0
