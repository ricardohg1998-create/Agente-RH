---
id: implementacion-quirurgica
name: Implementacion quirurgica
description: Transformar un objetivo en un plan tecnico atomico, ejecutable y verificable, sin saltos de complejidad.
version: 2.0.0
modes: [planning, execution]
---

# Workflow: Implementacion quirurgica

## Proposito

Transformar un objetivo en un plan tecnico atomico, ejecutable y verificable, sin saltos de complejidad.

## Cuando usarlo

- Se pide desglose de implementacion paso a paso.
- Hay dependencias tecnicas y riesgo de orden incorrecto.
- Se requiere plan con pruebas y criterios de aceptacion por bloque.

## Input esperado

- Objetivo funcional o tecnico concreto.
- Alcance incluido/excluido.
- Restricciones (tiempo, compatibilidad, deuda, riesgo).
- Estado actual disponible en `brain/current-state.md`.

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a capa profunda por gatillo: dependencia no clara, impacto arquitectonico o evidencia insuficiente.
- Mantener enfoque en archivos profundos directamente implicados en el objetivo.

## Pasos internos (Swarm Core v2.0)

1. **Diseño de Plan y Aprobación**: El Orquestador Principal diseña el plan técnico y emite el artefacto `implementation_plan.md` (con `request_feedback=true`) junto con la checklist de tareas `task.md`.
2. **Definición e Invocación de Desarrolladores**: Tras recibir la aprobación del usuario, el Orquestador define e invoca en background al subagente especialista **`FeatureDeveloper`** en modo de workspace **`share`** (para desarrollo aislado de componentes). Le inyecta el Context Payload detallado delimitando el alcance de los archivos a modificar.
3. **Definición e Invocación de QA**: De manera paralela o secuencial según el alcance, el Orquestador define e invoca en background al subagente **`QASpecialist`** en modo **`share`**. Le inyecta el Context Payload para que escriba las pruebas unitarias y de integración del componente en paralelo.
4. **Callbacks de Sincronización**: El Orquestador monitorea de forma reactiva y asíncrona los callbacks `[READY]` -> `[IN_PROGRESS]` -> `[COMPLETED]` de ambos subagentes.
5. **Consolidación y Verificación**: El Orquestador revisa los diffs de código de `FeatureDeveloper`, los fusiona de manera segura y ejecuta las pruebas de `QASpecialist` para verificar el 100% de éxito.
6. **Cierre de Ciclo**: Emite el `walkthrough.md` consolidando los entregables y delega el Cierre Operativo al subagente `CleanlinessGuardian`.


## Herramientas sugeridas

- **Mapear estructura afectada**: `list_dir` para entender la topologia de archivos del alcance y sus dependencias.
- **Inspeccionar contratos e interfaces**: `view_file` para revisar tipos, interfaces, schemas y puntos de integracion que cambiaran, preferiblemente apoyado de `mcp_[NombreServidor]-Semantic_analyze_file_ast`.
- **Buscar dependencias inversas**: SIEMPRE elegir `mcp_[NombreServidor]-Semantic_get_symbol_references` o la herramienta Semantica equivalente ANTES que basarte en `grep_search`. `grep_search` solo como ultimo recurso o para busquedas puramente textuales no ligadas al arbol AST.
- **Validar por paso**: `run_command` para ejecutar tests/build tras cada bloque atomico y verificar que no se rompe nada.
- **Investigar patrones**: `search_web` cuando la implementacion requiera una decision tecnica no obvia.

## Output obligatorio

1. Objetivo y alcance confirmado.
2. Supuestos y restricciones activas.
3. Secuencia atomica de trabajo.
4. Dependencias tecnicas y orden recomendado.
5. Riesgos por fase y mitigaciones.
6. Plan de pruebas por fase.
7. Criterios de aceptacion verificables.
8. Dudas abiertas.

## Criterios de calidad

- Cada paso debe ser ejecutable sin decisiones ocultas.
- El orden debe ser defendible por dependencias reales.
- La verificacion debe ser objetiva y repetible.

## Composicion

- **Suele preceder a**: ejecucion del plan, `code-review`, `qa-testing`.
- **Suele seguir a**: `autista-cafeinado`, `desarrollador-profundidad`, `mr-problem-solver`, `spike-investigacion`.
- **Workflow sugerido al completar**: `code-review` (tras ejecutar el plan) o `qa-testing` (si incluye funcionalidad nueva).

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/architecture.md`, `brain/backlog.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/backlog.md`, `brain/open-questions.md`, `brain/changelog.md`.

