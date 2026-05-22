---
id: cierre-operativo
name: Cierre operativo
description: Estandarizar el cierre de tarea para dejar estado verificable, handoff claro y cero ambiguedad operativa.
version: 2.0.0
modes: [planning, execution]
---

# Workflow: Cierre operativo

## Proposito

Estandarizar el cierre de tarea para dejar estado verificable, handoff claro y cero ambiguedad operativa.

## Cuando usarlo

- Al terminar una tarea tecnica o documental.
- Antes de handoff entre agentes/personas.
- Antes de commit o cierre de sesion de trabajo.

## Input esperado

- Objetivo original de la tarea.
- Cambios realizados o previstos.
- Restricciones de cierre (tiempo, riesgos, dependencias externas).

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a capa profunda solo si hay dudas de trazabilidad, riesgos residuales o dependencias abiertas.
- Limitar lectura profunda a backlog/changelog/milestones segun necesidad.

## Pasos internos (Swarm Core v2.0)

1. **Revisión del Orquestador**: Confirmar que se ha implementado TODO lo especificado en el artefacto interactivo oficial `implementation_plan.md` y que la checklist en `task.md` está completamente marcada.
2. **Generación del Walkthrough**: El Orquestador redacta el artefacto `walkthrough.md` en el directorio de la sesión resumiendo los entregables, tests unitarios ejecutados y diffs.
3. **Delegación de Cierre**: El Orquestador define e invoca en background al subagente especialista **`CleanlinessGuardian`** (en workspace `inherit`) pasándole el Context Payload correspondiente.
4. **Ejecución del Guardian**: El `CleanlinessGuardian` ejecuta de forma 100% automatizada:
   * **Auditoría de Calidad**: Ejecuta `scripts/run-checks.ps1` en background. Si falla, reporta los errores inmediatamente al Orquestador para su triage.
   * **Higiene Física**: Identifica y elimina cualquier residuo efímero de la sesión (`*.tmp`, `.bak`, `.log`, y metadatos del editor/subagentes).
   * **Registro Histórico**: Compacta el walkthrough en una entrada impecable de historial permanente bajo `brain/session_logs/` en formato de fecha y hora actual `YYYY-MM-DD_HH-MM_registro_cambios_sesion.md`.
   * **Compactación de Memoria Rápida**: Actualiza con precisión milimétrica `brain/now.md`, `brain/current-state.md` y `brain/deep-summary.md` vinculando al log histórico creado.
5. **Reporte Final**: El Guardian envía el callback `[COMPLETED]` con el reporte final de cierre. El Orquestador valida la higiene y ofrece el handoff limpio al desarrollador.

## Herramientas sugeridas

- **Delegación**: `define_subagent` e `invoke_subagent` asignando el rol `CleanlinessGuardian` en `inherit`.
- **Comunicación**: `send_message` para recibir el reporte final.
- **Checks manuales alternativos**: `run_command` con `scripts/run-checks.ps1` en caso de fallo del subagente.

## Output obligatorio (Swarm Core v2.0)

1. Checklist `task.md` completamente resuelta (`[x]`).
2. Artefacto `walkthrough.md` nativo del editor generado con el resumen del sprint.
3. Subagente `CleanlinessGuardian` invocado y completado con éxito.
4. Historial permanente actualizado en `brain/session_logs/` sin duplicidad.
5. Memoria rápida (`now.md`, `current-state.md` y `deep-summary.md`) en verde y sincronizada.
6. Eliminación de todos los archivos residuales o temporales del editor.


## Criterios de calidad

- Diferenciar claramente hecho vs pendiente.
- No cerrar con riesgos criticos sin visibilidad.

## Composicion

- **Suele preceder a**: handoff, commit final, fin de sesion.
- **Suele seguir a**: `code-review`, `pre-release`, `implementacion-quirurgica`, `qa-testing`.
- **Workflow sugerido al completar**: ninguno (es terminal). Puede sugerir `retrospectiva` si se cierra un ciclo largo.

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/backlog.md`, `brain/changelog.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/backlog.md`, `brain/changelog.md`, `brain/milestones.md` (si aplica), `brain/session_logs/`.

