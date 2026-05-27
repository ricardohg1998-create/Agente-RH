# AGENTS.md

Este archivo define las reglas maestras para agentes en este repo. La fuente dominante de comportamiento diario es `.agent/rules/core.md`.

## Prioridades

1. Responder siempre en espanol.
2. Ser conciso por defecto.
3. Mantener el repo limpio y sin basura.
4. No crear complejidad artificial.
5. Actualizar `brain/` solo tras cambios relevantes.

## Fuente de verdad

- Comportamiento diario: `.agent/rules/core.md`
- Reglas complementarias: `.agent/rules/`
- Workflows bajo demanda: `.agent/workflows/`
- Plantillas: `.agent/templates/`
- Politicas configurables: `.agent/config/`
- Memoria del proyecto: `brain/`
- Preferencias persistentes del usuario: `brain/user-instructions.md`

## Modo de trabajo

- Para consultas o auditorias de solo lectura: responder directamente, sin crear logs ni artefactos.
- Antes de cambios relevantes: leer `brain/now.md`, `brain/current-state.md`, `brain/stack.md` y `brain/deep-summary.md`.
- Despues de cambios relevantes:
  - actualizar `brain/now.md` y `brain/current-state.md`
  - actualizar `brain/stack.md` si cambia el stack
  - actualizar `brain/deep-summary.md` si cambia memoria profunda
  - registrar decision, changelog o log de sesion solo si aporta trazabilidad real

## Compatibilidad Antigravity

- Workspace rules en `.agent/rules/`.
- Skills workspace en `.agent/skills/`.
- Servidor MCP semantico para AST, simbolos, tipos, imports y referencias de codigo.
- Busqueda textual permitida para markdown, logs, configs, secretos, TODOs, rutas y patrones planos.
- Workflows documentados para planning mode, pero no obligatorios para tareas pequenas.

## Herramientas del entorno

- IDE principal: Google Antigravity.
- Shell: PowerShell en Windows 11.
- Modelo: configurable desde Antigravity Desktop.

## Deploy de la plantilla

Cuando el usuario pida "deploy" o "desplegar" en este repo, no subir a produccion. Aqui significa exportar una copia limpia de la plantilla ejecutando `scripts/export-template.ps1`.

## Higiene

- Reutilizar documentos existentes antes de crear nuevos.
- Evitar duplicidad semantica entre `AGENTS.md`, `.agent/rules/` y `brain/`.
- Proponer archivado o borrado de restos obsoletos.
- Ejecutar `scripts/run-checks.ps1` cuando haya cambios relevantes en la plantilla.
