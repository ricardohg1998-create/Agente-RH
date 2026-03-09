# Mapa del cerebro

`brain/` es la memoria operativa del proyecto.

## Capa rapida (leer siempre primero)

- `now.md`: que pasa ahora, que sigue y que bloquea.
- `current-state.md`: estado operativo resumido.
- `stack.md`: stack elegido, versiones y razon de la eleccion.
- `deep-summary.md`: resumen ultra-conciso de la memoria profunda.

## Capa profunda (consultar segun necesidad)

- `project-overview.md`
- `architecture.md`
- `decisions.md`
- `milestones.md`
- `backlog.md`
- `open-questions.md`
- `technical-debt.md`
- `pitfalls-and-errors.md`
- `ideas.md`
- `changelog.md`
- `skills-available.md`
- `workflows-index.md`
- `user-instructions.md`

## Regla operativa

1. Actualiza capa rapida tras cambio relevante.
2. Si aplica, registra en capa profunda.
3. Si cambia cualquier archivo listado en `deepLayer.files`, actualiza `deep-summary.md` en la misma tarea.
4. Archiva obsoleto en `archive/`.

## Politica de archivado

- **Cuando archivar**: documento superado por otro, decision revertida, milestone cerrado, o contenido que ya no refleja el estado actual.
- **Formato del nombre**: `YYYY-MM-DD_nombre-original.md` (ejemplo: `2026-03-08_stack-v1.md`).
- **Destino**: mover a `brain/archive/`.
- **Eliminacion vs archivo**: borrar solo residuos tecnicos sin valor historico (logs, temporales). Si tiene valor de trazabilidad, archivar.
- **Responsable**: el agente o el usuario al detectar obsolescencia durante el flujo normal de trabajo.
