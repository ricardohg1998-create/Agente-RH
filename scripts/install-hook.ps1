[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$gitDir = Join-Path $repoRoot '.git'
$hookDir = Join-Path $gitDir 'hooks'
$hookPath = Join-Path $hookDir 'pre-commit'

if (-not (Test-Path -LiteralPath $gitDir -PathType Container)) {
  throw "No se detecta carpeta .git en $repoRoot. Inicializa git antes de instalar el hook."
}

if (-not (Test-Path -LiteralPath $hookDir -PathType Container)) {
  New-Item -ItemType Directory -Path $hookDir -Force | Out-Null
}

$lines = @(
  '#!/usr/bin/env bash',
  'set -euo pipefail',
  '',
  'if command -v pwsh >/dev/null 2>&1; then',
  '  PS_BIN="pwsh"',
  'elif command -v powershell >/dev/null 2>&1; then',
  '  PS_BIN="powershell"',
  'else',
  '  echo "No se encontro pwsh/powershell en PATH"',
  '  exit 1',
  'fi',
  '',
  '"$PS_BIN" -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1',
  '"$PS_BIN" -NoProfile -ExecutionPolicy Bypass -File scripts/check-context-budget.ps1'
)

$content = ($lines -join "`n")
Set-Content -Path $hookPath -Encoding Ascii -Value $content -NoNewline

Write-Host 'Hook pre-commit instalado en .git/hooks/pre-commit' -ForegroundColor Green
Write-Host 'Nota: en algunos entornos puede requerir permisos de ejecucion (chmod +x).' -ForegroundColor Yellow
exit 0
