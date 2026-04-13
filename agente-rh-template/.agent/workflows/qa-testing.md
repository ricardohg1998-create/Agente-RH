---
id: qa-testing
name: QA y Pruebas
description: Disenar, implementar y ejecutar pruebas sistematicas para garantizar calidad de codigo y prevenir regresiones.
version: 1.0.0
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

## Pasos internos

1. Leer capa rapida y expandir si hay gatillos de contexto.
2. **Auditar cobertura actual**: detectar que areas tienen tests y cuales no.
3. **Identificar areas criticas sin cobertura**: logica de negocio, integraciones, flujos de usuario core, edge cases conocidos.
4. **Disenar test plan por capas**:
   - Unit: funciones puras, utilidades, transformaciones de datos.
   - Integration: interaccion entre modulos, API endpoints, base de datos.
   - E2E: flujos completos de usuario criticos.
   - Visual: regresion visual en componentes UI clave.
5. **Priorizar** por riesgo: que es mas probable que falle y que impacto tendria.
6. **Implementar tests prioritarios** siguiendo el plan.
7. **Ejecutar suite completa** y documentar resultados.
8. **Reportar cobertura** con metricas y areas pendientes.
9. **Definir umbral minimo** de cobertura para CI si no existe.

## Herramientas sugeridas

- **Buscar funciones sin test**: `grep_search` buscando `export function`, `export const`, `export default` y cruzar con archivos `.test.` o `.spec.` existentes.
- **Ejecutar tests**: `run_command` con el test runner del stack (`npm test`, `pytest`, `go test`, etc.).
- **Verificar cobertura**: `run_command` con flags de cobertura (`--coverage`, `--cov`, etc.) para obtener metricas.
- **Inspeccionar codigo a testear**: `view_file` para entender la logica antes de disenar tests.
- **Buscar edge cases documentados**: `grep_search` en `brain/pitfalls-and-errors.md` y en comentarios del codigo.
- **Validacion visual e2e**: `browser_subagent` para navegar flujos criticos y verificar que el comportamiento es correcto.
- **Monitorear ejecucion larga**: `command_status` para seguir suites de tests que tardan en completarse.

## Output obligatorio

1. **Diagnostico de cobertura actual** (que areas tienen tests, cuales no).
2. **Mapa de riesgo** (areas criticas sin cobertura priorizadas).
3. **Test plan** por capas (unit, integration, e2e, visual).
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
