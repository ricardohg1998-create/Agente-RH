---
id: workflow-dispatch
name: Workflow Dispatch
activation: model-decision
version: 1.2.0
---

# Workflow Dispatch Rule

## Goal

Seleccionar workflow correcto y mantener salida accionable.

## Workflow map

- `Desarrollador de profundidad` (`desarrollador-profundidad`): profundidad funcional/UX/producto.
- `Autista cafeinado` (`autista-cafeinado`): revision extrema tecnica + producto.
- `Buscar skills` (`buscar-skills`): seleccion e instalacion minima util de skills.
- `Implementacion quirurgica` (`implementacion-quirurgica`): plan tecnico atomico con dependencias y validacion.
- `Mr Problem Solver` (`mr-problem-solver`): triage de incidentes de sintoma a causa raiz.
- `Higiene de contexto` (`higiene-contexto`): limpieza de deriva documental y duplicidades.
- `Cierre operativo` (`cierre-operativo`): cierre de tarea y handoff verificable.
- `Inicio de proyecto` (`inicio-proyecto`): arranque guiado desde repo clonado hasta proyecto funcional.

## Dispatch criteria

- Si se pide profundidad de implementacion en producto/UX -> `Desarrollador de profundidad` (`desarrollador-profundidad`).
- Si se pide revision radicalmente minuciosa -> `Autista cafeinado` (`autista-cafeinado`).
- Si se pide instalar skills -> `Buscar skills` (`buscar-skills`).
- Si hay errores, caidas o regresiones -> `Mr Problem Solver` (`mr-problem-solver`) como prioridad por defecto.
- Si se pide plan tecnico detallado de ejecucion -> `Implementacion quirurgica` (`implementacion-quirurgica`).
- Si se pide limpieza documental/contexto/tokens -> `Higiene de contexto` (`higiene-contexto`).
- Si se pide cierre o handoff de tarea -> `Cierre operativo` (`cierre-operativo`).
- Si se arranca proyecto nuevo -> `Inicio de proyecto` (`inicio-proyecto`).

## Priority and tie-break

- Incidentes siempre priorizan `mr-problem-solver`, aunque exista solicitud secundaria de auditoria.
- Si hay empate entre `desarrollador-profundidad` e `implementacion-quirurgica`:
  - usar `desarrollador-profundidad` para detectar huecos funcionales.
  - usar `implementacion-quirurgica` para secuenciar ejecucion tecnica.
- `autista-cafeinado` queda como auditoria amplia, no como triage primario.

## Memory depth policy

- Siempre leer capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
- Lectura profunda alta desde inicio para:
  - `mr-problem-solver`
  - `autista-cafeinado`
  - `higiene-contexto`
- Lectura profunda selectiva por gatillo para:
  - `implementacion-quirurgica`
  - `desarrollador-profundidad`
  - `cierre-operativo`
  - `buscar-skills`
  - `inicio-proyecto`
- Gatillos de expansion profunda:
  - riesgo/incidente alto
  - contradiccion entre fuentes
  - cambio estructural de alcance o arquitectura
  - evidencia insuficiente para decidir

## Output minimum

Cada workflow debe producir:

- diagnostico
- problemas priorizados
- plan de implementacion accionable
- riesgos y dudas abiertas

## Brain sync

Tras ejecutar workflow, actualizar:

- `brain/now.md`
- `brain/current-state.md`
- `brain/stack.md` (si aplica)
- `brain/deep-summary.md` (obligatorio si cambia cualquier archivo de `deepLayer.files`)
- `brain/workflows-index.md` (si cambia criterio o alcance)

## Context budget

Ademas del workflow elegido, aplicar siempre la regla `context-budget` para mantener salida concisa y evitar deriva documental.
