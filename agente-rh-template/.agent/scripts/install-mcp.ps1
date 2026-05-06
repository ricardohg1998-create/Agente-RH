param(
    [string]$ConfigPath = "$env:USERPROFILE\.gemini\antigravity\mcp_config.json"
)

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$McpEntryPath = Resolve-Path (Join-Path $RootDir "..\mcp\semantic-server\build\index.js") -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path

if (-not $McpEntryPath) {
    Write-Error "[Install-MCP] No se pudo resolver la ruta de compilacion. Ejecuta 'npm run build' en .agent/mcp/semantic-server/ primero."
    exit 1
}

if (Test-Path $ConfigPath) {
    $jsonContent = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
    
    if (-not $jsonContent.mcpServers) {
        $jsonContent | Add-Member -MemberType NoteProperty -Name 'mcpServers' -Value @{}
    }
    
    $mcpServerConfig = @{
        command = "node"
        args = @($McpEntryPath)
        env = @{}
    }

    $ProjectRoot = Resolve-Path (Join-Path $RootDir "..\..") -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path
    $ProjectName = "Agente-RH-Semantic"
    if ($ProjectRoot) {
        $PkgPath = Join-Path $ProjectRoot "package.json"
        if (Test-Path $PkgPath) {
            $pkg = Get-Content $PkgPath | ConvertFrom-Json
            if ($pkg.name) {
                $ProjectName = $pkg.name + "-Semantic"
            }
        }
    }
    
    if ($jsonContent.mcpServers.PSObject.Properties.Match($ProjectName).Count -gt 0) {
        $jsonContent.mcpServers.$ProjectName = $mcpServerConfig
    } else {
        $jsonContent.mcpServers | Add-Member -MemberType NoteProperty -Name $ProjectName -Value $mcpServerConfig
    }

    $jsonStr = $jsonContent | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($ConfigPath, $jsonStr, (New-Object System.Text.UTF8Encoding($False)))
    Write-Host "[Install-MCP] Servidor '$ProjectName' enganchado exitosamente a tu IDE con ruta dinamica: $McpEntryPath"
} else {
    Write-Warning "[Install-MCP] No se encontro archivo MCP de Antigravity en $ConfigPath. Configuracion manual requerida apuntando a: $McpEntryPath"
}
