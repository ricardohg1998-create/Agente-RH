---
id: spike-investigacion
name: Spike de investigacion
description: Explorar tecnologias, evaluar alternativas y tomar decisiones tecnicas informadas antes de comprometerse con una implementacion.
version: 2.0.0
modes: [planning, execution]
---

# Workflow: Spike de investigacion

## Propósito

Investigar antes de comprometerse. Evaluar tecnologias, librerias, patrones o enfoques arquitectonicos mediante analisis comparativo y PoC minimos. Producir una decision documentada y defendible que evite retrabajo posterior.

## Cuándo usarlo

- Se necesita elegir entre varias tecnologias o librerias.
- Hay incertidumbre tecnica que bloquea una decision de implementacion.
- Se quiere hacer un PoC antes de comprometerse con un enfoque.
- Se evalua migrar de una tecnologia a otra.
- Hay que decidir si construir vs comprar vs integrar.

## Input esperado

- Pregunta de investigacion precisa (que se quiere resolver).
- Contexto del problema (por que surge la necesidad).
- Restricciones conocidas (tiempo, presupuesto, compatibilidad, equipo).
- Criterios de decision (que factores importan mas: rendimiento, DX, comunidad, coste, etc.).

## Política de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a `brain/stack.md` y `brain/decisions.md` para verificar decisiones previas y evitar re-evaluar lo ya decidido.
- Si hay arquitectura relevante, leer `brain/architecture.md`.

## Pasos internos (Swarm Core v2.0 - Topología de Investigación)

1. **Análisis de Pregunta y Aprobación**: El Orquestador Principal lee la capa rápida y verifica que no haya una decisión previa que cubra la pregunta. Define la pregunta de investigación precisa y los criterios de evaluación ponderados (rendimiento, DX, comunidad, madurez, compatibilidad con stack actual).
2. **Invocación de Investigadores en Paralelo**: El Orquestador define e invoca en background a **subagentes especialistas `CodebaseResearcher`** en paralelo (usando workspace `inherit` o `branch` si requiere instalar paquetes de prueba). Les inyecta el Context Payload detallando la alternativa específica a analizar y probar.
   * **`CodebaseResearcher-1 (Alternativa A)`**: Realiza la investigación de la alternativa A, lee documentación oficial y construye un PoC mínimo aislado.
   * **`CodebaseResearcher-2 (Alternativa B)`**: Investiga la alternativa B en paralelo de manera aislada, analizando la viabilidad de integración.
3. **Callbacks de Hallazgos**: Los investigadores devuelven sus reportes sintéticos de viabilidad, matriz de pros/contras y riesgos de lock-in a través de sus callbacks `[COMPLETED]`.
4. **Consolidación de Matriz**: El Orquestador Principal unifica los reportes de los subagentes, construye la matriz de comparación (tabla de alternativas vs criterios) y formula la recomendación final.
5. **Registro de Decisión y Cierre**: Registra la decisión definitiva en `brain/decisions.md` y delega el Cierre Operativo y la higiene al subagente `CleanlinessGuardian`.

## Herramientas sugeridas

- **Investigar alternativas**: `search_web` para buscar comparativas, benchmarks, opiniones de la comunidad y documentacion oficial.
- **Leer documentacion**: `read_url_content` para extraer contenido relevante de paginas de documentacion, READMEs de GitHub, articulos tecnicos.
- **PoC rapido**: `run_command` para instalar dependencias, ejecutar scripts de prueba, medir rendimiento o validar compatibilidad.
- **Verificar compatibilidad**: PRIORIZAR la consulta del AST mediante `mcp_[NombreServidor]-Semantic...` para evaluar dependencias estructurales en TS/JS, y usar `grep_search` unicamente para encontrar patrones de configuracion global o busquedas textuales planas.
- **Inspeccionar librerias candidatas**: `view_file` para revisar codigo fuente de dependencias si hay dudas de calidad.
- **Comparar visualmente**: `browser_subagent` si la investigacion incluye herramientas con interfaz web o demos online.

## Output obligatorio
*(Todo el volcado debera articularse en un Artifact nativo de tipo "research_notes" o similar, asegurando compatibilidad con Antigravity)*

1. **Pregunta de investigacion** definida con precision.
2. **Criterios de evaluacion** ponderados.
3. **Alternativas evaluadas** (minimo 2-3) con resumen de cada una.
4. **Matriz de comparacion** (tabla con alternativas vs criterios).
5. **PoC realizado** (si aplica): que se probo, resultado, conclusiones.
6. **Riesgos por alternativa** (lockin, mantenibilidad, dependencias).
7. **Recomendacion final** con justificacion tecnica.
8. **Decision registrada** en `brain/decisions.md`.

## Criterios de calidad

- **Pregunta precisa**: si la pregunta es vaga, el spike sera inutil. Acotar antes de investigar.
- **No rabbit holes**: limitar el tiempo de investigacion. Si en 30 minutos no hay claridad, escalar la decision o definir un PoC.
- **Evidencia sobre opinion**: cada recomendacion debe estar respaldada por datos, benchmarks o documentacion, no por preferencia personal.
- **Decision registrada**: un spike sin decision documentada es trabajo perdido.

## Composición

- **Suele preceder a**: `implementacion-quirurgica`, `inicio-proyecto`, `buscar-skills`.
- **Suele seguir a**: bloqueo tecnico detectado por `mr-problem-solver` o necesidad emergida de `autista-cafeinado`.
- **Workflow sugerido al completar**: `implementacion-quirurgica` (para planificar la implementacion de la decision tomada).

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/decisions.md`, `brain/architecture.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/decisions.md`, `brain/changelog.md`.
