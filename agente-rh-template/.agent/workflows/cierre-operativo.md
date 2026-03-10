---
id: cierre-operativo
name: Cierre operativo
version: 1.0.0
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

## Pasos internos

1. Leer capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
2. Expandir a capa profunda solo si hay gatillos de cierre.
3. Verificar cumplimiento de objetivo y alcance final.
4. Enumerar entregables y pendientes reales.
5. Revisar riesgos residuales y acciones de seguimiento.
6. Validar checks operativos requeridos.
7. Preparar resumen de handoff accionable.

## Output obligatorio

1. Estado final de la tarea.
2. Entregables completados.
3. Pendientes reales con prioridad.
4. Riesgos residuales.
5. Resultado de validaciones/checks.
6. Proximos pasos recomendados.
7. Nota de handoff lista para ejecutar.

## Criterios de calidad

- Diferenciar claramente hecho vs pendiente.
- No cerrar con riesgos criticos sin visibilidad.
- El handoff debe ser accionable en un solo bloque.

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/backlog.md`, `brain/changelog.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/backlog.md`, `brain/changelog.md`, `brain/milestones.md` (si aplica).

