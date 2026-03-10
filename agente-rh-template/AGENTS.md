# AGENTS.md

Este archivo define reglas de colaboracion para agentes en este repo.

## Prioridades

1. Hablar siempre en espanol.
2. Mantener el repo limpio y sin basura.
3. No crear complejidad artificial.
4. Actualizar memoria operativa en `brain/` tras cambios relevantes.

## Fuente de verdad

- Reglas operativas: `.agent/rules/`
- Workflows: `.agent/workflows/`
- Plantillas: `.agent/templates/`
- Politicas configurables: `.agent/config/`
- Memoria del proyecto: `brain/`

## Modo de trabajo

- Antes de cambios relevantes: leer `brain/now.md`, `brain/current-state.md`, `brain/stack.md` y `brain/deep-summary.md`.
- Despues de cambios relevantes:
  - actualizar capa rapida (`now.md`, `current-state.md`, `stack.md` si aplica)
  - si cambia cualquier archivo de memoria profunda (`deepLayer.files`), actualizar `deep-summary.md` en la misma tarea
  - registrar decision o hito si aplica
  - registrar en changelog si aplica

## Higiene

- Reutilizar documentos existentes antes de crear nuevos.
- Evitar duplicidad semantica entre `brain/` y docs historicos.
- Proponer archivado o borrado de restos obsoletos.
- Ejecutar checks con scripts de `scripts/`.

## Compatibilidad IDE

Este repo esta alineado con Antigravity:

- Workspace rules en `.agent/rules/`.
- Skills workspace en `.agent/skills/`.
- Workflows documentados para planning mode.

## Extensiones recordatorio

- `ms-python.python`
- `ms-azuretools.vscode-docker`
