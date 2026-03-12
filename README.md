# Repo Base Operativo para Agente (Antigravity + Win11)

Este repositorio es un esqueleto operativo, listo para clonar y arrancar, para proyectos de desarrollo asistidos por agente.

- Stack-agnostico: no depende de Node, Python, Go o PHP como base.
- Fuente de verdad del agente: `.agent/`.
- Memoria operativa del proyecto: `brain/`.
- Flujo principal recomendado: Google Antigravity en modo Planning para tareas complejas.

## Arranque en menos de 30 segundos

1. Clona el repo.
2. Abre el workspace en Antigravity.
3. Ejecuta:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/bootstrap.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1
```

Si prefieres PowerShell 7, puedes sustituir `powershell` por `pwsh`.

Arranque asistido opcional:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/init-project.ps1 -CreateCatalog
```

4. Lee `brain/now.md`, `brain/current-state.md`, `brain/stack.md` y `brain/deep-summary.md`.

## Estructura del nucleo

```text
/
  README.md
  AGENTS.md
  GEMINI.md
  .gitignore
  .agent/
    rules/
    workflows/
    templates/
    config/
    skills/
  brain/
    now.md
    current-state.md
    stack.md
    deep-summary.md
    ...
  docs/
  scripts/
  src/
  tests/
  tools/
```

## Mini cerebro (`brain/`)

Regla operativa: capa rapida estricta.

- Siempre actualiza primero:
  - `brain/now.md`
  - `brain/current-state.md`
  - `brain/stack.md` (si aplica)
- Si cambia cualquier archivo de memoria profunda (`deepLayer.files`), actualiza `brain/deep-summary.md` en la misma tarea.
- Despues actualiza capa profunda si aplica (decisiones, deuda, hitos, etc.).

Scripts utiles:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/update-brain-quick.ps1 -SummaryNow "..." -NextAction "..."
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/update-brain-deep-summary.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/log-decision.ps1 -Title "..." -Context "..." -Decision "..." -Consequences "..."
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/init-project.ps1 -InitGit -InstallHook -CreateCatalog
```

## Instrucciones persistentes del usuario

Las instrucciones permanentes viven en:

- `brain/user-instructions.md`

Alta deduplicada:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/add-instruction.ps1 -Instruction "Hablar siempre en espanol" -AffectsNow
```

## Catalogo local de skills

- `CATALOG.md` mantiene una fuente local valida para `.agent/config/skills-sources.json`.
- Si el repo no define skills propias aun, el catalogo puede permanecer en estado base.

## Workflows disponibles

<!-- GENERATED:README-WORKFLOWS:START -->
- `Autista cafeinado` (id: autista-cafeinado) -> `.agent/workflows/autista-cafeinado.md`
- `Buscar skills` (id: buscar-skills) -> `.agent/workflows/buscar-skills.md`
- `Cierre operativo` (id: cierre-operativo) -> `.agent/workflows/cierre-operativo.md`
- `Desarrollador de profundidad` (id: desarrollador-profundidad) -> `.agent/workflows/desarrollador-profundidad.md`
- `Higiene de contexto` (id: higiene-contexto) -> `.agent/workflows/higiene-contexto.md`
- `Implementacion quirurgica` (id: implementacion-quirurgica) -> `.agent/workflows/implementacion-quirurgica.md`
- `Inicio de proyecto` (id: inicio-proyecto) -> `.agent/workflows/inicio-proyecto.md`
- `Mr Problem Solver` (id: mr-problem-solver) -> `.agent/workflows/mr-problem-solver.md`
<!-- GENERATED:README-WORKFLOWS:END -->

Regla de dispatch clave: incidentes (errores/caidas/regresiones) priorizan `mr-problem-solver`.

Indice funcional en: `brain/workflows-index.md`.

## Higiene y anti-basura

Chequeos manuales:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-context-budget.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-scripts.ps1
```

Hook opcional pre-commit:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-hook.ps1
```

Guia de higiene: `docs/repo-hygiene.md`.

## Flujo diario en Antigravity (Win11)

> [!NOTE]
> Este repositorio depende fuertemente de PowerShell y esta disenado primariamente para Windows y Antigravity. Si se desea usar en entornos Linux o Docker, los scripts de `scripts/` deberan ser migrados a Bash o Node.js. PowerShell 7 es multiplataforma, pero se recomienda revision en rutas al usar otros OS.

- Flujo operativo: `docs/operating-flow-win11.md`
- Prompts eficientes y anti-deriva: `docs/prompt-efficiency.md`
- Troubleshooting de hooks/commit: `docs/hooks-troubleshooting.md`
- CI opcional (no obligatoria): `docs/ci-optional.md`
- Workflow Windows listo para activar: `.github/workflows/windows-checks.yml`

## Limites y realismo

- Este repo no promete autonomia magica.
- Lo automatico depende de scripts y reglas definidas aqui.
- Si algo no esta automatizado, se documenta como manual u opcion futura.

## Coexistencia con Antigravity

- `brain/` del repo = memoria persistente del proyecto.
- Artefactos de Antigravity (`~/.gemini/antigravity/brain/`) = memoria de conversacion efimera.
- Al cerrar sesion importante, migrar conclusiones relevantes a `brain/`.

## Checklist de handoff

Ver `docs/handoff-checklist.md`.

