---
id: cierre-operativo
name: Cierre operativo
description: Estandarizar el cierre de tarea para dejar estado verificable, handoff claro y cero ambiguedad operativa.
version: 1.1.0
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
3. Confirmar mediante revisión exhaustiva que se ha implementado TODO lo mencionado en el Implementation Plan (si aplicase), de forma correcta y sin omisiones.
4. Analizar de forma profunda el estado resultante del repositorio para garantizar que es excelente, sin puntos de fricción ni errores (compilación, linting o coherencia).
5. Enumerar entregables y pendientes reales.
5. Revisar riesgos residuales y acciones de seguimiento.
6. Validar checks operativos requeridos.
7. Eliminar los archivos efímeros o temporales creados durante la sesión que ya hayan cumplido su función y no se necesiten más.
8. **Automatizacion de Memoria**: Si existe un script de compactacion de memoria en el repositorio, ejecutarlo para que extraiga el diff y context de forma procedimental, eximiendo al agente de redactar los logs/now manualmente.
9. Actualizar `brain/workflow-metrics.md` registrando que workflows se usaron en la sesion, con que resultado y satisfaccion.

## Herramientas sugeridas

- **Ejecutar checks del repo**: `run_command` con `scripts/run-checks.ps1` para validar estado final.
- **Detectar archivos temporales**: `list_dir` para auditar el repo y encontrar archivos efimeros (`.tmp`, `.bak`, `.log`, carpetas de build).
- **Verificar entregables**: `view_file` para confirmar que los archivos modificados tienen el contenido esperado.
- **Validar compilacion/build**: `run_command` con el build command del stack para asegurar que todo compila limpio.
- **Verificar Implementation Plan**: `view_file` del plan original para cruzar cada punto con lo implementado.

## Output obligatorio

1. Estado final de la tarea.
2. Entregables completados.
3. Pendientes reales con prioridad.
4. Riesgos residuales.
5. Resultado de validaciones/checks.
6. Eliminación confirmada de archivos basura secundarios.
7. Registro creado en `brain/session_logs` (con el walkthrough completo de la sesión).
8. Proximos pasos recomendados.

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

