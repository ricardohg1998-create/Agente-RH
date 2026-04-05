# Workflow Metrics

## Uso por workflow

| Workflow | Veces usado | Ultima vez | Satisfaccion |
|----------|-------------|------------|--------------|
| autista-cafeinado | 2 | 2026-04-05 | Alta — detecto 5 criticos + 7 importantes, todos corregidos |
| implementacion-quirurgica | 1 | 2026-04-05 | Alta — plan de 7 fases ejecutado al 100% |
| cierre-operativo | 2 | 2026-04-05 | Alta — checks limpios, handoff claro |
| code-review | 1 | 2026-04-03 | Alta |
| retrospectiva | 0 | - | - |
| desarrollador-profundidad | 0 | - | - |
| mr-problem-solver | 0 | - | - |
| higiene-contexto | 0 | - | - |
| buscar-skills | 0 | - | - |
| inicio-proyecto | 0 | - | - |
| spike-investigacion | 0 | - | Nuevo, sin uso aun |
| qa-testing | 0 | - | Nuevo, sin uso aun |
| pre-release | 0 | - | Nuevo, sin uso aun |

## Patrones detectados

- `autista-cafeinado` + `implementacion-quirurgica` + `cierre-operativo` es la cadena mas natural y usada.
- Los 3 workflows nuevos (spike, qa, pre-release) estan pendientes de validacion con uso real.

## Ajustes pendientes

- Monitorear si las senales de dispatch del `workflow-dispatch.md` seleccionan correctamente con inputs ambiguos.
- Evaluar si `retrospectiva` se subutiliza (0 usos) — podria necesitar senales mas agresivas.
