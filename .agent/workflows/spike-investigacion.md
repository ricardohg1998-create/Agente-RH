---
id: spike-investigacion
name: Spike de investigacion
description: Explorar tecnologias, evaluar alternativas y tomar decisiones tecnicas informadas antes de comprometerse con una implementacion.
version: 1.0.0
modes: [planning, execution]
---

# Workflow: Spike de investigacion

## Proposito

Investigar antes de comprometerse. Evaluar tecnologias, librerias, patrones o enfoques arquitectonicos mediante analisis comparativo y PoC minimos. Producir una decision documentada y defendible que evite retrabajo posterior.

## Cuando usarlo

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

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a `brain/stack.md` y `brain/decisions.md` para verificar decisiones previas y evitar re-evaluar lo ya decidido.
- Si hay arquitectura relevante, leer `brain/architecture.md`.

## Pasos internos

1. Leer capa rapida y verificar que no hay decision previa que cubra la pregunta.
2. **Definir pregunta de investigacion** con precision: que se quiere resolver, que NO se quiere resolver.
3. **Definir criterios de evaluacion** ponderados: rendimiento, DX, comunidad, madurez, compatibilidad con stack actual, coste, curva de aprendizaje.
4. **Investigar estado del arte**: `search_web` + `read_url_content` para recoger alternativas, benchmarks, opiniones y documentacion oficial.
5. **Construir matriz de comparacion** con pros/cons/fit para cada alternativa evaluada contra los criterios definidos.
6. **PoC minimo** si aplica: implementar lo justo para validar la hipotesis mas critica (no construir un proyecto entero).
7. **Evaluar riesgo de cada alternativa**: lockin, mantenibilidad, longevidad del proyecto, dependencias transitivas.
8. **Formular recomendacion** con justificacion tecnica defendible.
9. **Registrar decision** en `brain/decisions.md` con contexto, alternativas evaluadas y razon de la eleccion.

## Herramientas sugeridas

- **Investigar alternativas**: `search_web` para buscar comparativas, benchmarks, opiniones de la comunidad y documentacion oficial.
- **Leer documentacion**: `read_url_content` para extraer contenido relevante de paginas de documentacion, READMEs de GitHub, articulos tecnicos.
- **PoC rapido**: `run_command` para instalar dependencias, ejecutar scripts de prueba, medir rendimiento o validar compatibilidad.
- **Verificar compatibilidad**: `grep_search` para buscar en el proyecto actual patrones que puedan entrar en conflicto con la nueva tecnologia.
- **Inspeccionar librerias candidatas**: `view_file` para revisar codigo fuente de dependencias si hay dudas de calidad.
- **Comparar visualmente**: `browser_subagent` si la investigacion incluye herramientas con interfaz web o demos online.

## Output obligatorio

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

## Composicion

- **Suele preceder a**: `implementacion-quirurgica`, `inicio-proyecto`, `buscar-skills`.
- **Suele seguir a**: bloqueo tecnico detectado por `mr-problem-solver` o necesidad emergida de `autista-cafeinado`.
- **Workflow sugerido al completar**: `implementacion-quirurgica` (para planificar la implementacion de la decision tomada).

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/decisions.md`, `brain/architecture.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/decisions.md`, `brain/changelog.md`.
