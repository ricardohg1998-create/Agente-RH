# Auditoría Autista Cafeinado — brain/ + .agent/ (11 Abril 2026)

## Objetivo Original
1. Auditar obsesivamente `brain/` y documentos del agente (`.agent/`, `AGENTS.md`, `GEMINI.md`).
2. Corregir inconsistencias detectadas.
3. Parchear bug crítico en `deploy.ps1`.

## Acciones Tomadas

### CRIT-01: deploy.ps1 no limpiaba capa profunda del brain
- Parchado `deploy.ps1` para resetear 6 archivos de capa profunda (changelog, decisions, technical-debt, pitfalls, workflow-metrics, deep-summary) al exportar copias vírgenes.

### Coherencia de idioma (IMP-01, IT-04, MD-03)
- Traducidos 5 headings en `context-budget.md` (Goal→Objetivo, Operating policy→Política operativa, etc.)
- Traducidos 8 headings en `workflow-dispatch.md` (Goal→Objetivo, Workflow map→Mapa de workflows, etc.)
- Traducido `brain/access.md` íntegramente al español.

### Corrección de documentación (IMP-02, IMP-03, IMP-06, IMP-07, MD-01)
- Completado `brain/README.md` con `workflow-metrics.md`, `access.md` y sección `Subdirectorios`.
- Eliminada entrada huérfana de `context-budget` como workflow de `workflows-index.md`.
- Corregido backslash roto en `workflows-index.md` línea 42.
- Añadido enlace a session log en `now.md`.
- Eliminada sección "Extensiones recordatorio" de `AGENTS.md`.

### Datos actualizados (IMP-04, MD-05, MD-06, MD-08)
- `workflow-metrics.md`: autista-cafeinado 4 usos, cierre-operativo 4 usos.
- `deep-summary.md`: actualizadas fechas de workflow-metrics y access.
- Eliminadas 6 líneas vacías al final de `workflow-dispatch.md`.
- Eliminadas 2 líneas vacías extra de `stack.md`.

## Hallazgo descartado
- **IMP-05 (changelog con refs a proyectos derivados)**: No es contaminación. Es historia legítima de la evolución del template. El deploy ya la limpia para los clones.

## Verificación
- Pendiente: `run-checks.ps1` + `deploy.ps1` + verificar copia limpia.
