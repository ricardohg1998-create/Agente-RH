# Architecture

## Bloques principales

- `/.agent`: capa operativa del agente (reglas, workflows, templates, config).
- `/brain`: memoria viva del proyecto.
- `/scripts`: automatizacion minima de estructura, higiene y memoria.
- `/docs`: guias de uso y handoff.

## Flujo principal

1. Leer `brain/now.md`, `brain/current-state.md`, `brain/stack.md` y `brain/deep-summary.md`.
2. Ejecutar tarea con reglas/workflows de `.agent/`.
3. Actualizar capa rapida del cerebro y sincronizar `brain/deep-summary.md` si cambia la capa profunda.
4. Registrar decision/changelog si aplica.
5. Ejecutar checks de estructura y limpieza.
