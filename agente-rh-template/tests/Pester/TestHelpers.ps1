$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

function New-TestWorkspace {
  param(
    [switch]$IncludeGit
  )

  $workspace = Join-Path $env:TEMP ('agente-rh-tests-' + [guid]::NewGuid().ToString())
  New-Item -ItemType Directory -Path $workspace -Force | Out-Null

  Get-ChildItem -LiteralPath $repoRoot -Force | Where-Object {
    $IncludeGit -or $_.Name -ne '.git'
  } | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $workspace -Recurse -Force
  }

  return $workspace
}

function Remove-TestWorkspace {
  param([string]$Workspace)

  if ($Workspace -and (Test-Path -LiteralPath $Workspace)) {
    Remove-Item -LiteralPath $Workspace -Recurse -Force
  }
}

function Invoke-WorkspaceScript {
  param(
    [string]$Workspace,
    [string]$RelativeScript,
    [string[]]$Arguments = @(),
    [hashtable]$Environment = @{}
  )

  $scriptPath = Join-Path $Workspace $RelativeScript
  $backups = @{}
  foreach ($key in $Environment.Keys) {
    $backups[$key] = [Environment]::GetEnvironmentVariable($key, 'Process')
    [Environment]::SetEnvironmentVariable($key, [string]$Environment[$key], 'Process')
  }

  try {
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
      $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath @Arguments 2>&1
      $exitCode = $LASTEXITCODE
    } catch {
      $output = @($_)
      $exitCode = if ($LASTEXITCODE -ne 0) { $LASTEXITCODE } else { 1 }
    } finally {
      $ErrorActionPreference = $previousErrorActionPreference
    }
  } finally {
    foreach ($key in $Environment.Keys) {
      [Environment]::SetEnvironmentVariable($key, $backups[$key], 'Process')
    }
  }

  return [pscustomobject]@{
    ExitCode = $exitCode
    Output = ($output | ForEach-Object { $_.ToString() }) -join "`n"
  }
}

function Invoke-GitCommand {
  param(
    [string]$Workspace,
    [string[]]$Arguments,
    [hashtable]$Environment = @{}
  )

  $backups = @{}
  foreach ($key in $Environment.Keys) {
    $backups[$key] = [Environment]::GetEnvironmentVariable($key, 'Process')
    [Environment]::SetEnvironmentVariable($key, [string]$Environment[$key], 'Process')
  }

  Push-Location $Workspace
  try {
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
      $output = & git @Arguments 2>&1
      $exitCode = $LASTEXITCODE
    } catch {
      $output = @($_)
      $exitCode = if ($LASTEXITCODE -ne 0) { $LASTEXITCODE } else { 1 }
    } finally {
      $ErrorActionPreference = $previousErrorActionPreference
    }
  } finally {
    Pop-Location
    foreach ($key in $Environment.Keys) {
      [Environment]::SetEnvironmentVariable($key, $backups[$key], 'Process')
    }
  }

  return [pscustomobject]@{
    ExitCode = $exitCode
    Output = ($output | ForEach-Object { $_.ToString() }) -join "`n"
  }
}

function Get-WorkspaceFileRaw {
  param(
    [string]$Workspace,
    [string]$RelativePath
  )

  return Get-Content -Path (Join-Path $Workspace $RelativePath) -Raw
}

function Set-WorkspaceFileRaw {
  param(
    [string]$Workspace,
    [string]$RelativePath,
    [string]$Content
  )

  Set-Content -Path (Join-Path $Workspace $RelativePath) -Encoding UTF8 -Value $Content
}
