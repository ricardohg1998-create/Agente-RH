$RootDir = Resolve-Path (Join-Path $PSScriptRoot "..\..") -ErrorAction Stop | Select-Object -ExpandProperty Path
$DirName = Split-Path $RootDir -Leaf

# 1. Idempotencia y protección de plantilla base
if ($DirName -match "Agente RH$|Agente-RH$") {
    # Estamos en la plantilla original, no truncamos nada.
    exit 0
}

$FlagFile = Join-Path $RootDir ".agent\.init_done"
if (Test-Path $FlagFile) {
    # El clon ya fue inicializado anteriormente
    exit 0
}

# 2. Generación automática de variables basadas en la carpeta clon
$DisplayName = $DirName
$ProjectName = $DirName.ToLower() -replace '\s+', '-' -replace '[^a-z0-9\-]', ''

Write-Host "[Auto-Init] Detectado nuevo clon '$DisplayName'. Parametrizando plantilla..." -ForegroundColor Cyan

# 3. Update package.json
$PkgPath = Join-Path $RootDir "package.json"
if (Test-Path $PkgPath) {
    $json = Get-Content $PkgPath -Raw | ConvertFrom-Json
    $OldName = $json.name
    $json.name = $ProjectName
    $json | ConvertTo-Json -Depth 10 | Set-Content $PkgPath -Encoding UTF8
    Write-Host "[OK] package.json actualizado (De '$OldName' a '$ProjectName')" -ForegroundColor Green
}

# 4. Update index.ts MCP Server
$IndexTsPath = Join-Path $RootDir ".agent\mcp\semantic-server\src\index.ts"
if (Test-Path $IndexTsPath) {
    $content = Get-Content $IndexTsPath -Raw
    $content = $content -replace '"agente-rh-semantic-server"', "`"$ProjectName-semantic-server`""
    $content = $content -replace 'Agente RH\s*-\s*Semantic MCP Server iniciado', "$DisplayName - Semantic MCP Server iniciado"
    Set-Content $IndexTsPath $content -Encoding UTF8
    Write-Host "[OK] .agent/mcp/semantic-server/src/index.ts parcheado." -ForegroundColor Green
}

# 5. Update SKILL.md
$SkillMdPath = Join-Path $RootDir ".agent\skills\semantic-analyzer\SKILL.md"
if (Test-Path $SkillMdPath) {
    $content = Get-Content $SkillMdPath -Raw
    $McpPrefix = "mcp_$($ProjectName)-Semantic"
    $content = $content -replace 'mcp_Agente-RH-Semantic', $McpPrefix
    Set-Content $SkillMdPath $content -Encoding UTF8
    Write-Host "[OK] SKILL.md adaptado al prefijo $McpPrefix." -ForegroundColor Green
}

# 6. Compilar y enlazar en background
Write-Host "[Auto-Init] Compilando e integrando MCP Server..." -ForegroundColor Cyan
$McpDir = Join-Path $RootDir ".agent\mcp\semantic-server"
if (Test-Path $McpDir) {
    Push-Location $McpDir
    if (!(Test-Path "node_modules")) {
        npm install --silent
    }
    npm run build --silent
    Pop-Location
}

# 7. Registrar MCP al IDE
$InstallMcpCmd = Join-Path $RootDir ".agent\scripts\install-mcp.ps1"
if (Test-Path $InstallMcpCmd) {
    & powershell.exe -ExecutionPolicy Bypass -File $InstallMcpCmd
}

# 8. Sellar para idempotencia
New-Item -Path $FlagFile -ItemType File -Value "Inicializado el $(Get-Date) para $DisplayName" -Force | Out-Null
Write-Host "`n[Auto-Init] Finalizado. Clon de plantilla desplegado existosamente y desvinculado de $ProjectName." -ForegroundColor DarkGreen
