# Technical Debt

## Actual

- ~~**Bug check-links.ps1**~~: **RESUELTO 2026-04-05** — Implementado timeout de 10s por archivo (Start-Job) y skip de archivos >200KB. El script ya no se cuelga.
- ~~**Encoding mixto LF/CRLF**~~: **RESUELTO 2026-04-05** — Normalizados 29 archivos a LF. `.editorconfig` define `end_of_line = lf`.
- ~~**Headings de reglas en ingles**~~: **RESUELTO 2026-04-05** — Traducidos a español en `core.md`, `brain-maintenance.md` y `repo-hygiene.md`.

## Riesgos de deuda futura

- Si el template crece a >20 workflows, `workflow-dispatch.md` podria superar el presupuesto de contexto. Monitorear con `check-context-budget.ps1`.
- ~~**Los tests Pester existen pero no se ejecutan automaticamente**~~: **RESUELTO 2026-04-06** — Autista Cafeinado inyectó la dependencia en run-checks.ps1.
