[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$resolvePsBinPath = Join-Path $PSScriptRoot 'lib/resolve-ps-bin.ps1'
. $resolvePsBinPath
$psBin = Resolve-PowerShellBinary

$utf8IoPath = Join-Path $PSScriptRoot 'lib/utf8-io.psm1'
Import-Module $utf8IoPath -Force
$fsUtilsPath = Join-Path $PSScriptRoot 'lib/fs-utils.psm1'
Import-Module $fsUtilsPath -Force

$templatePath = Resolve-RepoPath -Path '.agent/templates/session-log.md'
if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
  throw "No existe la plantilla de sesion en $templatePath"
}

# Obtener fecha y hora actual en formatos limpios
$now = Get-Date
$filenameDate = $now.ToString('yyyy-MM-dd_HH-mm')
$displayDate = $now.ToString('yyyy-MM-dd')
$displayTime = $now.ToString('HH:mm:ss')

$logDir = Resolve-RepoPath -Path 'brain/session_logs'
if (-not (Test-Path -LiteralPath $logDir -PathType Container)) {
  New-Item -ItemType Directory -Path $logDir | Out-Null
}

$targetFileName = "${filenameDate}_registro_cambios_sesion.md"
$targetPath = Join-Path $logDir $targetFileName

$templateContent = Read-Utf8File -Path $templatePath
$content = $templateContent -replace '%DATE%', $displayDate
$content = $content -replace '%TIME%', $displayTime

Write-Utf8File -Path $targetPath -Content $content

Write-Host "Sesion creada: [session_logs/$targetFileName](file:///$($targetPath -replace '\\', '/'))" -ForegroundColor Green
exit 0
