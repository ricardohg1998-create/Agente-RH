param (
    [Parameter(Mandatory=$true)]
    [string]$CommandToRun,
    
    [string]$LogFile = ".agent\scripts\worker-output.log"
)

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ResolvedLogPath = Join-Path $RootDir "..\..\$LogFile"

Write-Host "[Dispatch Worker] Despachando orquestacion paralela: $CommandToRun"
Write-Host "[Dispatch Worker] Reportando progreso vivo en: $ResolvedLogPath"

# Iniciamos el Job en background independiente para el sistema anfitrion
Start-Job -ScriptBlock {
    param($cmd, $log)
    Write-Output "[$((Get-Date).ToString("HH:mm:ss"))] Iniciando trabajador asincrono: $cmd..." | Out-File -FilePath $log -Encoding UTF8
    
    # Ejecuta capturando todo
    Invoke-Expression $cmd 2>&1 | Out-File -FilePath $log -Append -Encoding UTF8
    
    Write-Output "[$((Get-Date).ToString("HH:mm:ss"))] Trabajador completado exitosamente." | Out-File -FilePath $log -Append -Encoding UTF8
} -ArgumentList $CommandToRun, $ResolvedLogPath | Out-Null

Write-Host "[Dispatch Worker] El núcleo ha delegado la tarea exitosamente. Puedes volver al código fuente."
