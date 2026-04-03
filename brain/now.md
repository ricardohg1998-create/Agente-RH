# Now

<!-- QUICK-NOW:START -->
## Estado actual

- Completada mejora integral de workflows (v2.0.0 para autista-cafeinado y desarrollador-profundidad).
- Añadidos 2 nuevos workflows: code-review y retrospectiva.
- Campo `description` en todos los workflows para compatibilidad Antigravity.
- Fix de `create-workflow.ps1` alineado con estructura canónica.

## Siguiente accion recomendada

- Revisar y resolver el timeout de `check-links.ps1` (issue preexistente agravado por archivos más largos).
- Probar los nuevos slash commands `/Code Review` y `/Retrospectiva`.

## Bloqueos activos

- `check-links.ps1` se cuelga con archivos .md largos (bug preexistente, regex de `Test-PathToken` o I/O lento).

## Cambios recientes

- [2026-04-03] **Mejora integral de workflows**: Reescritura profunda de `autista-cafeinado` (obsesión por el detalle) y `desarrollador-profundidad` (completitud UX). Nuevos workflows `code-review` (seguridad como pilar) y `retrospectiva`. Fix de `create-workflow.ps1`. Campo `description` en todos. Normalización `modes`. [Registro detallado](brain/session_logs/2026-04-03_16-24_mejora_workflows.md)
- [2026-03-21] **Backport de comparador v2**: Implementado anexo de Infraestructura en `AGENTS.md` y suavizado el control de limpieza (`check-cleanliness.ps1`) permitiendo extensiones vivas (`.log`, `.bak`). Generación de placeholder (`access.md`).
- [2026-03-20] Primera ejecución exitosa de la skill mediante test sobre un dominio real.
<!-- QUICK-NOW:END -->
