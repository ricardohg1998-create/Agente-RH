[CmdletBinding()]
param(
    [string]$PlanPath,
    [string]$SwarmOutDir,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

# 1. Resolver rutas por defecto de forma segura
if ([string]::IsNullOrWhiteSpace($PlanPath)) {
    # Buscar implementation_plan.md en el directorio de artefactos activo
    # Usando la carpeta de conversación más reciente o un fallback local
    $brainDir = Join-Path $env:USERPROFILE ".gemini\antigravity\brain"
    $newestPlan = $null
    if (Test-Path -LiteralPath $brainDir -PathType Container) {
        $newestPlan = Get-ChildItem -LiteralPath $brainDir -Directory | 
            ForEach-Object { Join-Path $_.FullName 'implementation_plan.md' } | 
            Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | 
            ForEach-Object { Get-Item -LiteralPath $_ } | 
            Sort-Object LastWriteTime -Descending | 
            Select-Object -First 1 -ExpandProperty FullName
    }
    
    if ($newestPlan) {
        $PlanPath = $newestPlan
    } else {
        # Fallback al directorio raíz si existe localmente
        $PlanPath = Join-Path $repoRoot 'implementation_plan.md'
    }
}

if ([string]::IsNullOrWhiteSpace($SwarmOutDir)) {
    $SwarmOutDir = Join-Path $repoRoot 'brain/swarm'
}

Write-Host "spawn-swarm: Cargando plan desde $PlanPath" -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $PlanPath -PathType Leaf)) {
    Write-Error "No se encontro el plan de implementacion en: $PlanPath"
    exit 1
}

# 2. Crear directorio de enjambre si no existe
if (-not (Test-Path -LiteralPath $SwarmOutDir -PathType Container)) {
    New-Item -ItemType Directory -Path $SwarmOutDir -Force | Out-Null
    Write-Host "spawn-swarm: Directorio de Swarm creado en $SwarmOutDir" -ForegroundColor Green
} elseif ($Force) {
    # Limpieza higiénica previa si se especifica Force
    Get-ChildItem -Path $SwarmOutDir -File | Remove-Item -Force
    Write-Host "spawn-swarm: Limpieza de $SwarmOutDir completada." -ForegroundColor Yellow
}

# 3. Leer y parsear el markdown buscando bloques JSON de definición del Swarm
$planContent = Get-Content -LiteralPath $PlanPath -Raw -Encoding UTF8

$swarmDefinition = $null

# Intentar extraer bloque JSON específico de Swarm
if ($planContent -match '(?ms)```json\s*(\{\s*"swarm":.*?\})\s*```') {
    try {
        $jsonStr = $Matches[1]
        $swarmDefinition = ConvertFrom-Json $jsonStr
        Write-Host "spawn-swarm: Detectado bloque de definicion JSON explicito de Swarm." -ForegroundColor Green
    } catch {
        Write-Warning "spawn-swarm: Se encontro un bloque de definicion de Swarm pero tenia formato JSON invalido."
    }
}

# 4. Si no hay bloque JSON explícito, inferir a partir del parseo de archivos del plan
if ($null -eq $swarmDefinition -or $null -eq $swarmDefinition.swarm) {
    Write-Host "spawn-swarm: No se encontro definicion de Swarm JSON explicita. Infiriendo componentes y archivos..." -ForegroundColor Yellow
    
    # Expresión regular para buscar secciones de archivos modificados/creados
    # Ej: #### [MODIFY] [file basename](file:///absolute/path)
    $matchesFiles = [regex]::Matches($planContent, '(?mi)####\s+\[(MODIFY|NEW|DELETE)\]\s+\[([^\]]+)\]\(file:///([^\)]+)\)')
    
    $swarmList = @()
    $seenRoles = @{}
    
    foreach ($m in $matchesFiles) {
        $action = $m.Groups[1].Value
        $fileName = $m.Groups[2].Value
        $filePath = $m.Groups[3].Value -replace '%20', ' '
        
        # Inferir un rol y scope basado en la extensión y directorio del archivo
        $extension = [System.IO.Path]::GetExtension($fileName).ToLower()
        $roleName = "General Specialist"
        $roleKey = "general"
        
        if ($extension -eq '.ps1' -or $extension -eq '.psm1') {
            $roleName = "PowerShell Engineer"
            $roleKey = "powershell"
        } elseif ($extension -eq '.ts' -or $extension -eq '.js' -or $extension -eq '.json') {
            if ($filePath -match 'semantic-server') {
                $roleName = "MCP Semantic Specialist"
                $roleKey = "semantic"
            } else {
                $roleName = "Node TypeScript Developer"
                $roleKey = "typescript"
            }
        } elseif ($extension -eq '.md') {
            $roleName = "Technical Writer"
            $roleKey = "doc"
        }
        
        # Agrupar alcances por rol
        if (-not $seenRoles.ContainsKey($roleKey)) {
            $seenRoles[$roleKey] = @{
                role = $roleName
                roleKey = $roleKey
                scope = @($fileName)
                instruction = "Revisar e implementar los cambios correspondientes para los archivos: $fileName"
            }
        } else {
            $seenRoles[$roleKey].scope += $fileName
            $seenRoles[$roleKey].instruction += ", $fileName"
        }
    }
    
    # Consolidar
    foreach ($key in $seenRoles.Keys) {
        $roleObj = $seenRoles[$key]
        $scopeStr = $roleObj.scope -join ', '
        $swarmList += [PSCustomObject]@{
            role = $roleObj.role
            roleKey = $roleObj.roleKey
            scope = $scopeStr
            instruction = $roleObj.instruction + " conforme a las especificaciones dadas en el plan de implementacion general."
        }
    }
    
    if ($swarmList.Count -eq 0) {
        Write-Warning "spawn-swarm: No se pudieron inferir roles ni se encontro configuracion JSON de Swarm."
        # Crear un rol genérico por defecto para no romper el flujo
        $swarmList += [PSCustomObject]@{
            role = "General Developer"
            roleKey = "dev"
            scope = "Todo el repositorio"
            instruction = "Ejecutar las directivas descritas en el plan de implementacion general."
        }
    }
    
    $swarmDefinition = [PSCustomObject]@{
        swarm = $swarmList
    }
}

# 5. Cargar plantilla de bootstrap de subagente
$templatePath = Join-Path $repoRoot '.agent/templates/swarm-bootstrap-template.md'
if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
    Write-Error "No se encontro la plantilla de sistema en: $templatePath"
    exit 1
}
$templateContent = Get-Content -LiteralPath $templatePath -Raw -Encoding UTF8


# 6. Procesar cada rol e instanciar archivos
$bootstrapPayloads = @()

foreach ($member in $swarmDefinition.swarm) {
    $roleName = $member.role
    $roleKey = $member.roleKey
    $scope = $member.scope
    $instruction = $member.instruction
    
    Write-Host "  -> Procesando especialista: $roleName ($roleKey)" -ForegroundColor Cyan
    
    # Generar System Prompt a partir de la plantilla
    $systemPrompt = $templateContent
    $systemPrompt = $systemPrompt -replace '\{\{ROLE\}\}', $roleName
    $systemPrompt = $systemPrompt -replace '\{\{ROLE_KEY\}\}', $roleKey
    $systemPrompt = $systemPrompt -replace '\{\{SCOPE\}\}', $scope
    $systemPrompt = $systemPrompt -replace '\{\{SPECIFIC_INSTRUCTION\}\}', $instruction
    $systemPrompt = $systemPrompt -replace '\{\{WORKSPACE_ROOT\}\}', ($repoRoot -replace '\\', '/')
    
    $sysPromptPath = Join-Path $SwarmOutDir "system-prompt-$roleKey.md"
    [System.IO.File]::WriteAllText($sysPromptPath, $systemPrompt, (New-Object System.Text.UTF8Encoding($False)))
    
    # Generar Checklist de tareas vacío (o con la instrucción)
    $taskPath = Join-Path $SwarmOutDir "task-$roleKey.md"
    if (-not (Test-Path -LiteralPath $taskPath -PathType Leaf) -or $Force) {
        $taskContent = "# Checklist Operativo - $roleName`n`n"
        $taskContent += "Ambito de Trabajo: $scope`n`n"
        $taskContent += "## Tareas Asignadas`n`n"
        $taskContent += "- [ ] **Fase 1: Analisis y Preparacion**`n"
        $taskContent += "  - [ ] Leer el plan de implementacion general.`n"
        $taskContent += "  - [ ] Analizar el estado actual de los archivos asignados.`n"
        $taskContent += "- [ ] **Fase 2: Ejecucion Quirurgica**`n"
        $taskContent += "  - [ ] $instruction`n"
        $taskContent += "- [ ] **Fase 3: Verificacion e Informe**`n"
        $taskContent += "  - [ ] Ejecutar comprobaciones basicas sobre el codigo.`n"
        $taskContent += "  - [ ] Reportar de forma concisa al Orquestador.`n"
        [System.IO.File]::WriteAllText($taskPath, $taskContent, (New-Object System.Text.UTF8Encoding($False)))
    }
    
    # Estructurar payload de bootstrap para el Orquestador de Antigravity
    $bootstrapPayloads += @{
        TypeName = "self"  # O "research" segun se requiera, preferimos "self" por compatibilidad
        Role     = $roleName
        Prompt   = "Eres el especialista '$roleName' asignado al enjambre. Tu plan de trabajo y tareas estan definidos en: [task-$roleKey.md](file:///$($taskPath -replace '\\', '/')). Tus instrucciones completas de comportamiento estan en: [system-prompt-$roleKey.md](file:///$($sysPromptPath -replace '\\', '/')). Por favor, lee ambos archivos de inmediato, ejecuta tus tareas de forma meticulosa y reporta tus resultados."
    }
}

# 7. Guardar el payload consolidado
$payloadPath = Join-Path $SwarmOutDir "bootstrap-payload.json"
$payloadJson = ConvertTo-Json -InputObject $bootstrapPayloads -Depth 10
[System.IO.File]::WriteAllText($payloadPath, $payloadJson, (New-Object System.Text.UTF8Encoding($False)))

# 8. Copiar al portapapeles si es posible en sesion interactiva
try {
    $payloadJson | Set-Clipboard -ErrorAction SilentlyContinue
    $clipMsg = "(Copiado al portapapeles con exito)"
} catch {
    $clipMsg = ""
}

Write-Host "`n=======================================================" -ForegroundColor Green
Write-Host "Swarm Scaffolder completado con exito!" -ForegroundColor Green
Write-Host "Archivos generados en: $SwarmOutDir" -ForegroundColor Green
Write-Host "Se detectaron e instanciaron $($swarmDefinition.swarm.Count) especialistas." -ForegroundColor Green
Write-Host "Consumible de inicializacion listo en bootstrap-payload.json $clipMsg" -ForegroundColor Yellow
Write-Host "=======================================================`n" -ForegroundColor Green

exit 0
