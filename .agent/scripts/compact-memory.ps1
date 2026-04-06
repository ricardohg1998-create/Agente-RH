param (
    [string]$SessionName = "auto-session-$(Get-Date -Format 'yyyy-MM-dd_HH-mm')"
)

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BrainDir = Resolve-Path "$RootDir\..\..\brain" | Select-Object -ExpandProperty Path
$NowFile = "$BrainDir\now.md"
$SessionLogsDir = "$BrainDir\session_logs"

if (!(Test-Path $SessionLogsDir)) {
    New-Item -ItemType Directory -Path $SessionLogsDir | Out-Null
}

$GitStatus = git status -s
$GitLog = git log -3 --oneline 2>$null

$Report = @"
# Now

<!-- QUICK-NOW:START -->
## Estado actual

- Extraccion automatizada procedimental de contexto (v4.0).
- Ultimos movimientos en Git:
$($GitLog | Out-String)
- Archivos sucios en la rama temporal actual:
$($GitStatus | Out-String)

## Siguiente accion recomendada
- Validar `brain/task.md` o solicitar el comienzo de una nueva etapa de implementacion.

<!-- QUICK-NOW:END -->
"@

Set-Content -Path $NowFile -Value $Report -Encoding UTF8

$LogContent = @"
# Auto-Extracted Session Log: $SessionName
Date: $(Get-Date)

*(Este archivo fue generado asincronamente por \`.agent/scripts/compact-memory.ps1\` para higiene de contexto, eludiendo la redaccion manual del LLM).*

## Extraccion Diferencial de Git
$($GitStatus | Out-String)

## Historial de Commits Relacionados
$($GitLog | Out-String)
"@

Set-Content -Path "$SessionLogsDir\$SessionName.md" -Value $LogContent -Encoding UTF8

# Limpieza circular (Mantenemos maximo 15 sesiones viejas)
$MaxSessions = 15
$SessionFiles = Get-ChildItem -Path $SessionLogsDir -Filter "*.md" | Sort-Object CreationTime -Descending
if ($SessionFiles.Count -gt $MaxSessions) {
    $SessionFiles | Select-Object -Skip $MaxSessions | Remove-Item -Force -ErrorAction SilentlyContinue
}

Write-Host "Contexto compactado procedimentalmente en brain/now.md (Tokens cognitivos ahorrados exitosamente)."
