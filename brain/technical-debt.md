# Technical Debt

## Actual

- **Bug check-links.ps1**: Se cuelga con archivos .md largos. Necesita implementar timeout por archivo (10s max). Impacto: bloquea `run-checks.ps1`. Prioridad: media.
- **Encoding mixto LF/CRLF**: Varios archivos mezclan `\n` y `\r\n`. Causa diffs innecesarios. Prioridad: baja.
- **Headings de reglas en ingles**: Las 3 reglas (`core.md`, `brain-maintenance.md`, `repo-hygiene.md`) tienen headings en ingles cuando AGENTS.md dice "hablar siempre en espanol". Prioridad: baja (cosmetico pero incoherente).

## Riesgos de deuda futura

- Si el template crece a >20 workflows, `workflow-dispatch.md` podria superar el presupuesto de contexto. Monitorear con `check-context-budget.ps1`.
- Los tests Pester existen pero no se ejecutan automaticamente en `run-checks.ps1`. Riesgo de regresion silenciosa en scripts.
