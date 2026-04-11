# Technical Debt

## Actual

- **Duplicación de funciones en Job ScriptBlock de `check-links.ps1`**: las funciones `Resolve-RepoPath`, `Get-RelativeRepoPath`, `Test-IgnoreLinkTarget` y `Test-PathToken` están duplicadas entre el scope principal y el Job ScriptBlock. Esto es un requisito técnico de PowerShell Jobs (no comparten scope con el invocador) y NO se puede eliminar sin cambiar la arquitectura de concurrencia.

- **Pester 3.4 limita la suite de tests**: el sistema usa Pester 3.4 (incluida con PowerShell 5.1 de Windows) que no soporta `xDescribe`, `Mock -ParameterFilter`, ni ejecución de Jobs anidados de forma fiable. Workaround aplicado: `init-project.ps1` tiene `-SkipChecks`. Requiere actualización del entorno de ejecución base para resolver.

## Resuelto

- ~~**Duplicación de `Resolve-RepoPath` en 7 scripts**~~: **RESUELTO 2026-04-11** — Refactorizados 6 scripts para importar `fs-utils.psm1`. `check-links.ps1` mantiene copia local por null-safety adicional y por requerimiento del Job.
- ~~**Duplicación de `Normalize-Eol` en 3 scripts**~~: **RESUELTO 2026-04-11** — Renombradas a `ConvertTo-TrimmedEol` (firma con `.Trim()` local distinta a la del módulo). Duplicación reducida a implementación interna coherente.
- ~~**11 funciones con verbos no aprobados**~~: **RESUELTO 2026-04-11** — Todas renombradas a verbos aprobados (`ConvertTo-*`, `Test-*`, `Set-*`, `ConvertFrom-*`).
- ~~**Warning de verbo no aprobado en `fs-utils.psm1`**~~: **RESUELTO 2026-04-11** — `Normalize-Eol` renombrada a `ConvertTo-NormalizedEol`.
- ~~**Bug check-links.ps1**~~: **RESUELTO 2026-04-05** — Timeout y skip de archivos grandes.
- ~~**Encoding mixto LF/CRLF**~~: **RESUELTO 2026-04-05** — Normalizados 29 archivos a LF.
- ~~**Headings de reglas en ingles**~~: **RESUELTO 2026-04-05** — Traducidos a español.
- ~~**Tests Pester no se ejecutan automaticamente**~~: **RESUELTO 2026-04-06** — Inyectada dependencia en `run-checks.ps1`.
- ~~**Bug sync-brain.ps1 parsing de `+`**~~: **RESUELTO 2026-04-11** — Envuelta concatenación en paréntesis.
- ~~**Bug sync-brain.ps1 marcadores destruidos**~~: **RESUELTO 2026-04-11** — Restaurados marcadores START/END.
- ~~**Bug check-links.ps1 scoping en Jobs**~~: **RESUELTO 2026-04-11** — `$script:localIssues`.
- ~~**Bug check-links.ps1 filtro inline code**~~: **RESUELTO 2026-04-11** — Filtros refinados.
- ~~**Bug bootstrap.ps1 directorio padre**~~: **RESUELTO 2026-04-11** — Creación previa del directorio.

## Riesgos de deuda futura

- Si el template crece a >20 workflows, `workflow-dispatch.md` podria superar el presupuesto de contexto. Monitorear con `check-context-budget.ps1`.
