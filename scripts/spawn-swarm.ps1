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
    # 1. Comprobar primero en la raiz del proyecto local
    $localPlan = Join-Path $repoRoot 'implementation_plan.md'
    if (Test-Path -LiteralPath $localPlan -PathType Leaf) {
        $PlanPath = $localPlan
    } else {
        # 2. Si no hay local, buscar recursivamente pero filtrando solo carpetas modificadas en las ultimas 48 horas para evitar lag
        $brainDir = Join-Path $env:USERPROFILE ".gemini\antigravity\brain"
        $newestPlan = $null
        if (Test-Path -LiteralPath $brainDir -PathType Container) {
            $cutoff = (Get-Date).AddDays(-2)
            $newestPlan = Get-ChildItem -LiteralPath $brainDir -Directory | 
                Where-Object { $_.LastWriteTime -ge $cutoff } |
                ForEach-Object { Join-Path $_.FullName 'implementation_plan.md' } | 
                Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | 
                ForEach-Object { Get-Item -LiteralPath $_ } | 
                Sort-Object LastWriteTime -Descending | 
                Select-Object -First 1 -ExpandProperty FullName
        }
        
        if ($newestPlan) {
            $PlanPath = $newestPlan
        } else {
            # Fallback final a la raiz del proyecto
            $PlanPath = $localPlan
        }
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
        $filePath = [System.Uri]::UnescapeDataString($m.Groups[3].Value)
        
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
    } elseif ($swarmList.Count -gt 1) {
        # Si hay más de un desarrollador/especialista, inyectar el supervisor y el validador automáticamente
        Write-Host "spawn-swarm: Detectado enjambre concurrente. Inyectando Supervisor y Validador de Calidad." -ForegroundColor Cyan
        
        $swarmList += [PSCustomObject]@{
            role = "Swarm Supervisor"
            roleKey = "supervisor"
            scope = "Todo el enjambre"
            instruction = "Coordinar, monitorizar en tiempo real el progreso de los subagentes, guiar ante bloqueos y arbitrar el orden de integracion."
        }
        
        $swarmList += [PSCustomObject]@{
            role = "Quality Validator"
            roleKey = "validator"
            scope = "Archivos modificados en el plan"
            instruction = "Auditar críticamente, comprobar, criticar intelectualmente y validar todos los diffs de codigo y tests locales de regresion."
        }
    }
    
    $swarmDefinition = [PSCustomObject]@{
        swarm = $swarmList
    }
}

# 5. Cargar plantillas y procesar cada rol e instanciar archivos
$bootstrapPayloads = @()

foreach ($member in $swarmDefinition.swarm) {
    $roleName = $member.role
    # Sanitización silenciosa de roleKey para evitar caracteres extraños o errores de tipado
    $roleKey = ($member.roleKey -replace '[^a-zA-Z0-9_-]', '').ToLower()
    if ([string]::IsNullOrWhiteSpace($roleKey)) { $roleKey = 'specialist' }
    $scope = $member.scope
    $instruction = $member.instruction
    
    Write-Host "  -> Procesando especialista: $roleName ($roleKey)" -ForegroundColor Cyan
    
    # Seleccionar plantilla de forma dinámica
    $templateName = 'swarm-bootstrap-template.md'
    if ($roleKey -eq 'supervisor') {
        $templateName = 'swarm-supervisor-bootstrap-template.md'
    } elseif ($roleKey -eq 'validator') {
        $templateName = 'swarm-validator-bootstrap-template.md'
    }
    
    $templatePath = Join-Path $repoRoot ".agent/templates/$templateName"
    if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
        Write-Error "No se encontro la plantilla de sistema en: $templatePath"
        exit 1
    }
    $templateContent = Get-Content -LiteralPath $templatePath -Raw -Encoding UTF8
    
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
        $taskContent = ""
        if ($roleKey -eq 'supervisor') {
            $taskContent = "# Checklist Operativo - $roleName`n`n"
            $taskContent += "Ambito de Trabajo: $scope`n`n"
            $taskContent += "## Tareas Asignadas`n`n"
            $taskContent += "- [ ] **Fase 1: Preparacion y Analisis**`n"
            $taskContent += "  - [ ] Leer el plan de implementacion general y el catalogo de subagentes.`n"
            $taskContent += "  - [ ] Validar la consistencia de los checklists del resto de subagentes tecnicos.`n"
            $taskContent += "- [ ] **Fase 2: Supervision e Intercomunicacion**`n"
            $taskContent += "  - [ ] Monitorizar periodicamente el avance de los checklists en brain/swarm/task-*.md.`n"
            $taskContent += "  - [ ] Mitigar bloqueos y arbitrar el orden de integracion secuencial.`n"
            $taskContent += "- [ ] **Fase 3: Consolidacion de Avances**`n"
            $taskContent += "  - [ ] Elaborar informe periodico de estado y actualizar el checklist general.`n"
            $taskContent += "  - [ ] Reportar al Orquestador Principal una vez finalizado todo el trabajo de desarrollo y QA.`n"
        } elseif ($roleKey -eq 'validator') {
            $taskContent = "# Checklist Operativo - $roleName`n`n"
            $taskContent += "Ambito de Trabajo: $scope`n`n"
            $taskContent += "## Tareas Asignadas`n`n"
            $taskContent += "- [ ] **Fase 1: Preparacion e Inspeccion de Criterios**`n"
            $taskContent += "  - [ ] Estudiar a fondo los diffs de codigo propuestos por los desarrolladores.`n"
            $taskContent += "  - [ ] Comprobar que no se introducen Mojibakes, BOMs ni duplicidades.`n"
            $taskContent += "- [ ] **Fase 2: Auditoria Critica y Validacion**`n"
            $taskContent += "  - [ ] Criticar e intelectualizar el trabajo realizado, emitiendo revisiones rigurosas de codigo.`n"
            $taskContent += "  - [ ] Correr la suite de tests locales mediante scripts/run-checks.ps1 u otros tests aplicables.`n"
            $taskContent += "- [ ] **Fase 3: Veredicto de Calidad**`n"
            $taskContent += "  - [ ] Emitir callback correspondiente ([APPROVED] o [REFACT_NEEDED]).`n"
            $taskContent += "  - [ ] Informar los resultados y la critica al Supervisor y al Orquestador.`n"
        } else {
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
        }
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
