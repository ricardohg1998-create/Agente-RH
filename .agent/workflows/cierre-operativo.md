---
id: cierre-operativo
name: Cierre operativo
description: Cerrar tareas con cambios reales dejando estado verificable, memoria util y handoff claro.
version: 2.1.0
modes: [planning, execution]
---

# Workflow: Cierre operativo

## Proposito

Cerrar una tarea cuando hubo cambios reales, handoff, commit, release o peticion explicita de cierre. No se usa para consultas, auditorias de solo lectura ni respuestas conceptuales.

## Cuando usarlo

- Al terminar una tarea tecnica o documental con cambios en archivos.
- Antes de commit, merge, release o handoff.
- Cuando el usuario pida cerrar la sesion o dejar estado final.

## Cuando no usarlo

- Preguntas simples.
- Auditorias sin cambios.
- Lectura o diagnostico que no modifica archivos.
- Tareas pequenas que ya tienen una respuesta final clara.

## Lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a capa profunda solo si hay riesgos, decisiones persistentes o pendientes que documentar.

## Pasos internos

1. Verificar que el objetivo original esta resuelto o que los pendientes quedan explicitados.
2. Ejecutar checks adecuados al alcance. Usar `scripts/run-checks.ps1` para cambios de plantilla o repo; usar checks mas pequenos para cambios acotados.
3. Si hubo cambios relevantes, actualizar `brain/now.md` y `brain/current-state.md`.
4. Si cambio un archivo de memoria profunda, actualizar `brain/deep-summary.md`.
5. Crear o completar registro en `brain/session_logs/` solo si la sesion tuvo cambios relevantes.
6. Limpiar artefactos efimeros del repo (`implementation_plan.md`, `task.md`, `walkthrough.md`, `brain/swarm/*`) si existen y ya no son necesarios.

## Swarm

- No invocar `CleanlinessGuardian` por defecto.
- Usarlo solo si hubo swarm real, limpieza extensa, muchos archivos o cierre de release.
- Para cierres pequenos, el orquestador principal realiza los pasos directamente.

## Salida esperada

- Estado final breve.
- Cambios principales.
- Validaciones ejecutadas y resultado.
- Pendientes o riesgos residuales, si existen.

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/deep-summary.md` y `brain/session_logs/` solo si aplica.
