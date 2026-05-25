---
id: autista-cafeinado
name: Autista cafeinado
description: Revision obsesiva, hiper-detallada y profunda del proyecto con critica constructiva despiadada y un Implementation Plan completo de mejoras.
version: 2.0.0
modes: [planning, execution]
---

# Workflow: Autista cafeinado

## Propósito

Ejecutar una revision obsesiva, hiper-detallada y profunda del proyecto (o de una parte especifica si se indica en el prompt). Funciona como lo haria un friki autista sobreexcitado de cafeina: analisis de altas capacidades que busca hasta el mas minimo detalle, critica constructiva despiadada pero util, y nada se le escapa. El objetivo final es generar un **Implementation Plan completo de mejoras** priorizado y accionable.

## Cuándo usarlo

- Antes de release relevante.
- Proyecto con sintomas de fragilidad, deuda acumulada o falta de calidad.
- Necesidad de auditoria profunda con plan de mejora por fases.
- Sospecha de que "algo no huele bien" pero no se sabe exactamente que.
- Se quiere elevar la calidad general del proyecto de forma sistematica.

## Input esperado

- Alcance concreto: repo completo, servicio, modulo, feature o archivo (si no se especifica, se audita todo).
- Objetivo de calidad o area de foco preferente (opcional).
- Restricciones (tiempo, riesgo, compatibilidad).

## Política de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Por ser auditoria amplia, expandir desde inicio a capa profunda relevante.
- Priorizar `brain/architecture.md`, `brain/technical-debt.md` y `brain/pitfalls-and-errors.md`.

## Pasos internos (Swarm Core v2.0 - Topología de Auditoría)

1. **Mapeo de Alcance y Despliegue**: El Orquestador Principal analiza la estructura general del repositorio y lo divide en sectores o áreas de foco (ej. código core, seguridad/tokens, UI/UX, configuración).
2. **Invocación de Investigadores en Paralelo**: El Orquestador define e invoca en background a **múltiples subagentes especialistas `CodebaseResearcher` en paralelo** (usando workspace `inherit`). Les inyecta el Context Payload delimitándoles el directorio exacto a auditar:
   * **`CodebaseResearcher-1 (Core)`**: Audita la lógica y arquitectura en `/src` o directorios funcionales.
   * **`CodebaseResearcher-2 (Security)`**: Realiza barrido estricto de secretos, tokens y dependencias vulnerables.
   * **`CodebaseResearcher-3 (Scripts & DX)`**: Evalúa la salud de automatizaciones y DX locales en `/scripts`.
3. **Callbacks de Hallazgos**: Los investigadores auditan su sector de forma autónoma empleando las herramientas MCP semánticas locales y devuelven reportes sintéticos de hallazgos mediante sus callbacks `[COMPLETED]`.
4. **Consolidación Crítica**: El Orquestador Principal recopila los reportes de los subagentes, analiza discrepancias de arquitectura y redacta un diagnóstico consolidado despiadado pero extremadamente útil.
5. **Emisión de Plan**: Redacta el artefacto `implementation_plan.md` y `task.md` detallando las fases del plan de correcciones y mejoras priorizadas por impacto/esfuerzo.
6. **Cierre de Auditoría**: El Orquestador delega el cierre operativo y almacenamiento permanente del walkthrough al subagente `CleanlinessGuardian`.


## Herramientas sugeridas

- **Mapeo de estructura**: `list_dir` para recorrer el arbol completo del proyecto y detectar archivos huerfanos, convenciones de naming rotas o carpetas sin sentido.
- **Deteccion de dependencias ocultas o resolucion AST**: USAR SIEMPRE servidor MCP Semantico (`mcp_[NombreServidor]-Semantic_analyze_file_ast` / `get_symbol_references`) frente a `grep_search` cuando se busquen integraciones de TypeScript.
- **Deteccion de secrets y credenciales**: `grep_search` con patrones: `AKIA`, `sk-`, `ghp_`, `password\s*=`, `secret`, `token`, `apiKey`, archivos `.env` fuera de `.gitignore`.
- **Deteccion de dead code y deuda textuaL**: `grep_search` con `TODO`, `FIXME`, `HACK`, `XXX`, `console.log`, `debugger`, `// eslint-disable`.
- **Inspeccion de archivos concretos**: `view_file` para revisar logica, imports sin usar, complejidad ciclomatica y anti-patrones.
- **Validacion visual de UX/UI**: `browser_subagent` para navegar la app localmente y detectar estados rotos, layouts descuadrados, flujos incompletos.
- **Investigacion de buenas practicas**: `search_web` cuando se detecte un patron dudoso y haga falta contrastar con el estado del arte.
- **Ejecucion de checks**: `run_command` para ejecutar linters, tests, builds de produccion y scripts de higiene del repo.

## Output obligatorio

1. Alcance revisado (que se audito exactamente).
2. Lectura global del estado del proyecto/modulo.
3. **Hallazgos criticos** (con evidencia: archivo, linea, contexto, por que es critico).
4. **Hallazgos importantes** (con evidencia y justificacion de por que importa).
5. **Micro-detalles y mejoras finas** (typos, dead code, TODOs, etc.).
6. **Inconsistencias tecnicas y de producto** detectadas.
7. **Deuda tecnica cuantificada** (estimacion de impacto por item).
8. **Oportunidades de mejora profundas** (lo que podria ser mucho mejor).
9. **Propuesta priorizada** con justificacion tecnica.
10. **Implementation Plan completo por fases** en un Artifact nativo de Antigravity (`implementation_plan.md`):
    - Descripcion detallada de cada cambio.
    - Archivos afectados.
    - Dependencias entre tareas.
    - Orden de ejecucion recomendado.
    - Criterios de aceptacion por fase.

## Criterios de calidad

- **Evidencia exacta**: cada hallazgo debe senalar archivo, linea y contexto. Si no puedes decir donde esta, no lo reportes.
- **Nada generico**: "el codigo podria mejorar" NO es un hallazgo valido. "La funcion X en archivo Y linea Z tiene un edge case sin manejar cuando el input es null" SI lo es.
- **Priorizacion defendible**: cada posicion en el ranking debe estar justificada tecnicamente.
- **Critica constructiva**: ser despiadado con los problemas, pero siempre proponer solucion concreta.
- **Implementation Plan ejecutable**: debe poder ejecutarse sin ambiguedad, sin preguntas pendientes, sin decisiones ocultas.

## Modos de operación

### Modo archivo/componente (alcance < 5 archivos)
- Saltar pasos de mapeo global (paso 2).
- Lectura de memoria: solo quick layer.
- Output reducido: hallazgos + quick fixes, sin Implementation Plan por fases.
- Objetivo: feedback rapido y accionable.

### Modo modulo/feature (alcance 5-30 archivos)
- Mapeo del modulo y sus dependencias directas.
- Lectura de memoria: quick layer + `brain/architecture.md`.
- Output estandar completo.

### Modo repo completo (alcance > 30 archivos o sin especificar)
- Mapeo exhaustivo de toda la estructura.
- Lectura de memoria: quick + deep layer completo.
- Output completo con Implementation Plan por fases.
- Priorizacion por impacto/esfuerzo obligatoria.

## Composición

- **Suele preceder a**: `implementacion-quirurgica`, `code-review`.
- **Suele seguir a**: solicitud directa del usuario o sospecha de fragilidad.
- **Workflow sugerido al completar**: `implementacion-quirurgica` (para planificar la correccion de los hallazgos).

## Brain read/write

- Leer: `brain/current-state.md`, `brain/architecture.md`, `brain/technical-debt.md`, `brain/pitfalls-and-errors.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/technical-debt.md`, `brain/backlog.md`, `brain/changelog.md`.
