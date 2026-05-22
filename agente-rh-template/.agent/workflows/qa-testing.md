---
id: qa-testing
name: QA y Pruebas
description: Disenar, implementar y ejecutar pruebas sistematicas para garantizar calidad de codigo y prevenir regresiones.
version: 2.0.0
modes: [planning, execution]
---

# Workflow: QA y Pruebas

## Proposito

Garantizar calidad mediante testing sistematico. Disenar estrategia de pruebas, implementar tests prioritarios, ejecutar y reportar resultados. Cubrir desde unit tests hasta validacion visual end-to-end. El objetivo es construir una red de seguridad que prevenga regresiones y aumente la confianza en cada deploy.

## Cuando usarlo

- Feature nueva que necesita cobertura de tests.
- Se detecta falta de tests en areas criticas.
- Antes de release como complemento de `pre-release`.
- Despues de un incidente para prevenir regresion.
- Se quiere establecer o mejorar la estrategia de testing del proyecto.

## Input esperado

- Alcance: feature, modulo, o proyecto completo.
- Tipo de testing deseado (unit, integration, e2e, visual, performance).
- Stack de testing actual (si existe).
- Areas criticas o con historial de bugs.

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a `brain/architecture.md` para entender la topologia y priorizar areas criticas.
- Revisar `brain/pitfalls-and-errors.md` para cubrir errores conocidos con tests.

## Pasos internos (Swarm Core v2.0 - Topología de QA)

1. **Diseño de Estrategia**: El Orquestador Principal lee la capa rápida, audita la cobertura actual identificando áreas críticas sin testear (con el apoyo de herramientas semánticas) y diseña el Test Plan por capas en un artefacto `implementation_plan.md`.
2. **Invocación del Especialista QA**: Tras recibir feedback del usuario, el Orquestador define e invoca en background al subagente especialista **`QASpecialist`** en modo de workspace **`share`** (para poder acceder directamente al código en desarrollo e implementar tests en paralelo).
3. **Escritura e Implementación de Tests**: El `QASpecialist` implementa de forma 100% aislada la suite de pruebas unitarias, de integración o e2e (según lo acordado en el plan), y ejecuta el test runner de forma continua.
4. **Callback de Resultados**: El `QASpecialist` devuelve el callback `[COMPLETED]` inyectando el reporte exacto de ejecución (tests pasados, fallidos, cobertura y cualquier regresión detectada).
5. **Consolidación y Cierre**: El Orquestador consolida los tests en la rama principal, ejecuta los tests de integración globales, actualiza las métricas y delega el Cierre Operativo e higiene final al subagente `CleanlinessGuardian`.

## Herramientas sugeridas

- **Buscar funciones sin test**: USAR servidor Semantico MCP (`mcp_[NombreServidor]-Semantic_analyze_file_ast`) para listar exports exactos de modulos TS/JS y cruzar con archivos `.test.` o `.spec.`. Solo usar `grep_search` si MCP no esta disponible o como ultimo recurso.
- **Ejecutar tests**: `run_command` con el test runner del stack (`npm test`, `pytest`, `go test`, etc.).
- **Verificar cobertura**: `run_command` con flags de cobertura (`--coverage`, `--cov`, etc.) para obtener metricas.
- **Inspeccionar codigo a testear**: `view_file` para entender la logica antes de disenar tests.
- **Buscar edge cases documentados**: `grep_search` en `brain/pitfalls-and-errors.md` y en comentarios del codigo.
- **Validacion visual e2e**: `browser_subagent` para navegar flujos criticos y verificar que el comportamiento es correcto.
- **Monitorear ejecucion larga**: `command_status` para seguir suites de tests que tardan en completarse.

## Output obligatorio

1. **Diagnostico de cobertura actual** (que areas tienen tests, cuales no).
2. **Mapa de riesgo** (areas criticas sin cobertura priorizadas).
3. **Test plan** por capas (unit, integration, e2e, visual). Debe emitirse formalmente mediante un Artifact nativo de ruteo de Antigravity (`implementation_plan.md` con `request_feedback=true`).
4. **Tests implementados** (cuantos, de que tipo, que cubren).
5. **Resultados de ejecucion** (tests pasados, fallidos, skipped).
6. **Metricas de cobertura** (porcentaje por modulo si el runner lo soporta).
7. **Areas pendientes** con plan de cobertura progresiva.
8. **Recomendaciones de CI** (umbrales, gates, test automaticos).

## Criterios de calidad

- **Tests utiles, no cosmeticos**: cada test debe proteger contra un fallo real, no inflar metricas.
- **Priorizacion por riesgo**: cubrir primero lo que mas puede fallar y mas impacto tiene.
- **Tests mantenibles**: naming claro, setup minimo, sin acoplamiento a implementacion interna.
- **Evidencia de ejecucion**: no basta con escribir tests, hay que ejecutarlos y reportar resultados.

## Composicion

- **Suele preceder a**: `pre-release`, `cierre-operativo`.
- **Suele seguir a**: `implementacion-quirurgica`, `desarrollador-profundidad`, `code-review`.
- **Workflow sugerido al completar**: `pre-release` (si se prepara un deploy) o `cierre-operativo` (si es tarea aislada).

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/architecture.md`, `brain/pitfalls-and-errors.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/deep-summary.md`, `brain/technical-debt.md`, `brain/changelog.md`.
