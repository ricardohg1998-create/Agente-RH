# Registro de cambios - Sesión 2026-04-03 16:24 - Mejora integral de workflows

## Resumen

Mejora integral del sistema de workflows del repo: reescrituras profundas, nuevos workflows, normalización y fix de infraestructura.

## Cambios realizados

1. **Fix `create-workflow.ps1`**: Reescrito template interno para generar estructura canónica de 8 secciones (antes generaba tags XML incompatibles). Añadido parámetro `-Description`.

2. **Reescritura `autista-cafeinado.md` (v2.0.0)**: Revisión obsesiva por capas (arquitectura→código→UX→datos→seguridad→rendimiento). Caza de micro-detalles. Implementation Plan como entregable principal. `modes: [planning, execution]`.

3. **Reescritura `desarrollador-profundidad.md` (v2.0.0)**: Detector exhaustivo de CTAs sin destino, secciones sin desarrollar, páginas incompletas, funciones por implementar, estados UX sin manejar, flujos rotos. Implementation Plan completísimo. `modes: [planning, execution]`.

4. **Normalización de 6 workflows**: Añadido campo `description` al frontmatter. Corrección numeración duplicada en `inicio-proyecto.md`. Bump versión a 1.1.0.

5. **Nuevo workflow `code-review.md`**: Revisión técnica desde archivo hasta repo completo. Seguridad como pilar (credenciales, APIs, auth, tokens, CORS, inyecciones).

6. **Nuevo workflow `retrospectiva.md`**: Análisis post-ciclo con lecciones aprendidas, patrones a repetir/evitar, ajustes concretos.

7. **Actualización `generate-workflows-docs.ps1`**: Parsear campo `description` del frontmatter como fuente preferente para Summary.

8. **Registro workflows nuevos en `repo-structure.json`**.

9. **Fix regex `check-links.ps1`**: Simplificada regex de inline-code tokens para evitar backtracking catastrófico (mejora parcial, el hang persiste por otra causa: I/O lento en `Test-Path`).

10. **Regeneración automática**: `workflow-dispatch.md`, `workflows-index.md`, `README.md`, `CATALOG.md` sincronizados vía scripts.

## Issue detectado (preexistente)

- `check-links.ps1` se cuelga procesando archivos .md largos. No es causado por los cambios de esta sesión (se reproduce con el repo anterior). Candidato para arreglar en siguiente sesión.
