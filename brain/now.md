# Now

<!-- QUICK-NOW:START -->
## Estado actual

- Completada mejora integral de workflows v3.0: 13 workflows operativos (10 mejorados + 3 nuevos).
- Cada workflow incluye: herramientas sugeridas (Antigravity-native), composicion, y brain read/write.
- 3 workflows de auditoria con modos de operacion por alcance (archivo/modulo/repo).
- Sistema de dispatch con senales ricas y anti-senales para seleccion automatica.
- 5 cadenas predefinidas de composicion (auditoria, feature, inicio, release, cierre de ciclo).
- Meta-sistema de metricas de uso en `brain/workflow-metrics.md`.

## Siguiente accion recomendada

- Probar los nuevos slash commands (`/Spike de investigacion`, `/QA y Pruebas`, `/Pre-lanzamiento`).
- Probar las cadenas de composicion en un proyecto real.
- Resolver timeout de `check-links.ps1` (bug preexistente).

## Bloqueos activos

- `check-links.ps1` se cuelga con archivos .md largos (bug preexistente, no bloquea desarrollo).

## Cambios recientes

- [2026-04-05] **Workflows v3.0**: Herramientas sugeridas Antigravity-native en 13 workflows. Modos de operacion en 3 workflows de auditoria. Composicion y encadenamiento en 13 workflows. 3 nuevos workflows (spike-investigacion, qa-testing, pre-release). Dispatch con senales ricas. Meta-sistema de metricas. Infraestructura actualizada (create-workflow.ps1, brain-policy.json, implementation-plan-template).
- [2026-04-03] **Mejora integral de workflows**: Reescritura profunda de `autista-cafeinado` y `desarrollador-profundidad`. Nuevos workflows `code-review` y `retrospectiva`. Fix de `create-workflow.ps1`. Campo `description` en todos.
<!-- QUICK-NOW:END -->
