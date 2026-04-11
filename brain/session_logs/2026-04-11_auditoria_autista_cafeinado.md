# Auditoría Autista Cafeinado — Saneamiento Completo (11 Abril 2026)

## Objetivo Original
1. Ejecutar auditoría obsesiva del repo "Agente RH" completo.
2. Corregir todos los bugs detectados hasta obtener 22/22 tests verdes.
3. Resolver TODA la deuda técnica accionable — no dejar nada sin resolver.

## Acciones Tomadas

### Bugs Corregidos (6)
- **sync-brain.ps1** (parsing): Envuelta concatenación en paréntesis.
- **sync-brain.ps1** (marcadores): Restaurados marcadores START/END en Replace-MarkedSection.
- **check-links.ps1** (scoping): `$script:localIssues` dentro del Job ScriptBlock.
- **check-links.ps1** (filtro inline): Refinados filtros de backtick para evitar falsos positivos.
- **bootstrap.ps1**: Creación del directorio padre antes de `.gitkeep`.
- **init-project.ps1**: Añadido flag `-SkipChecks` para evitar hang por Jobs anidados.

### Deuda Técnica Resuelta

#### Duplicación de `Resolve-RepoPath` eliminada
Refactorizados 6 scripts para importar `fs-utils.psm1` en vez de definir copias locales:
- `add-instruction.ps1`, `bootstrap.ps1`, `check-context-budget.ps1`, `check-skills-catalog.ps1`, `check-structure.ps1`, `update-brain-deep-summary.ps1`
- `check-links.ps1` mantiene copia local por null-safety y por requerimiento del Job ScriptBlock.

#### Duplicación de `Normalize-Eol` eliminada
Las 3 copias locales renombradas a `ConvertTo-TrimmedEol` (tienen `.Trim()`, distinta a la del módulo).

#### 11 funciones con verbos no aprobados → 0
| Antes | Después | Script |
|---|---|---|
| `Normalize-Eol` (export) | `ConvertTo-NormalizedEol` | fs-utils.psm1 |
| `Normalize-Text` | `ConvertTo-NormalizedText` | add-instruction.ps1 |
| `Normalize-ComparablePath` | `ConvertTo-ComparablePath` | check-cleanliness.ps1 |
| `Should-SkipDirectory` | `Test-SkipDirectory` | check-cleanliness.ps1 |
| `Normalize-Paragraph` | `ConvertTo-NormalizedParagraph` | check-context-budget.ps1 |
| `Normalize-Eol` (3 locales) | `ConvertTo-TrimmedEol` | 3 scripts |
| `Normalize-ShortText` | `ConvertTo-NormalizedShortText` | update-brain-deep-summary.ps1 |
| `Parse-Workflow` | `ConvertFrom-WorkflowFile` | generate-workflows-docs.ps1 |
| `Replace-MarkedSection` | `Set-MarkedSection` | sync-brain.ps1, update-brain-deep-summary.ps1 |

### Contenido corregido
- Corregido typo `.scripts/` en session log.
- Eliminada referencia fantasma a `compact-memory.ps1` en workflow.

## Deuda Residual (NO accionable)
Solo quedan 2 items que **no se pueden resolver** sin cambios externos:
1. Duplicación en Job ScriptBlock de `check-links.ps1` — limitación técnica de PS Jobs.
2. Pester 3.4 limita tests — requiere actualización del entorno base.

## Verificación Final
- `run-checks.ps1`: **OK** (todos los checks pasan)
- `Invoke-Pester`: **22/22 tests verdes, 0 fallos**
- Verbos no aprobados: **0** en todo el repo
- `Import-Module fs-utils.psm1`: **Sin warnings**
