# Workflows Index

## Resumen

- `Desarrollador de profundidad` (`desarrollador-profundidad`) -> profundidad funcional y UX.
- `Autista cafeinado` (`autista-cafeinado`) -> auditoria extrema tecnica y de producto.
- `Buscar skills` (`buscar-skills`) -> seleccion e instalacion minima util de skills.
- `Implementacion quirurgica` (`implementacion-quirurgica`) -> plan tecnico atomico por dependencias.
- `Mr Problem Solver` (`mr-problem-solver`) -> triage de incidentes con causa raiz.
- `Higiene de contexto` (`higiene-contexto`) -> limpieza de deriva documental y duplicidad.
- `Cierre operativo` (`cierre-operativo`) -> cierre de tarea y handoff verificable.
- `Inicio de proyecto` (`inicio-proyecto`) -> arranque guiado desde repo clonado hasta proyecto funcional.
- `context-budget` -> control de deriva documental y consumo de contexto.

## Dispatch rapido

- Errores, caidas o regresiones -> `mr-problem-solver` (prioridad por defecto).
- Plan tecnico detallado paso a paso -> `implementacion-quirurgica`.
- Limpieza documental, tokens o duplicidad -> `higiene-contexto`.
- Cierre y handoff de tarea -> `cierre-operativo`.
- Profundidad funcional/UX -> `desarrollador-profundidad`.
- Auditoria extrema completa -> `autista-cafeinado`.
- Seleccion o instalacion de skills -> `buscar-skills`.
- Arranque de proyecto nuevo -> `inicio-proyecto`.

## Uso recomendado

1. Definir alcance.
2. Seleccionar workflow por objetivo.
3. Ejecutar con output obligatorio.
4. Actualizar capa rapida de `brain/` (`now.md`, `current-state.md`, `stack.md` si aplica).
5. Si cambia memoria profunda, sincronizar `deep-summary.md` en la misma tarea.

## Ubicacion fuente

- `.agent/workflows/desarrollador-profundidad.md`
- `.agent/workflows/autista-cafeinado.md`
- `.agent/workflows/buscar-skills.md`
- `.agent/workflows/implementacion-quirurgica.md`
- `.agent/workflows/mr-problem-solver.md`
- `.agent/workflows/higiene-contexto.md`
- `.agent/workflows/cierre-operativo.md`
- `.agent/workflows/inicio-proyecto.md`
- `.agent/rules/context-budget.md`
