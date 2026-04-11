# AGENTS.md

Este archivo define reglas de colaboración para agentes en este repo.

## Prioridades

1. Hablar siempre en español.
2. Mantener el repo limpio y sin basura.
3. No crear complejidad artificial.
4. Actualizar memoria operativa en `brain/` tras cambios relevantes.

## Fuente de verdad

- Reglas operativas: `.agent/rules/`
- Workflows: `.agent/workflows/`
- Plantillas: `.agent/templates/`
- Políticas configurables: `.agent/config/`
- Memoria del proyecto: `brain/`

## Modo de trabajo

- Antes de cambios relevantes: leer `brain/now.md`, `brain/current-state.md`, `brain/stack.md` y `brain/deep-summary.md`.
- Después de cambios relevantes:
  - actualizar capa rápida (`now.md`, `current-state.md`, `stack.md` si aplica)
  - si cambia cualquier archivo de memoria profunda (`deepLayer.files`), actualizar `deep-summary.md` en la misma tarea
  - registrar decisión o hito si aplica
  - registrar en changelog si aplica

## Higiene

- Reutilizar documentos existentes antes de crear nuevos.
- Evitar duplicidad semántica entre `brain/` y docs históricos.
- Proponer archivado o borrado de restos obsoletos.
- Ejecutar checks con scripts de `scripts/`.

## Compatibilidad IDE

Este repo está alineado con Antigravity:

- Workspace rules en `.agent/rules/`.
- Skills workspace en `.agent/skills/`.
- Workflows documentados para planning mode.

## Herramientas del entorno

- IDE principal: Google Antigravity
- Modelo preferido: Gemini 3.1 Pro
- Shell: PowerShell (Windows 11)

## Infraestructura de producción (Template)

- **Servidor**: [Por definir]
- **BBDD**: [Por definir]. Credenciales en `brain/access.md` u otro sistema.
- **SSH/Deploy**: [Por definir].
- **Errores conocidos**: Leer SIEMPRE `brain/pitfalls-and-errors.md` antes de despliegue.
- **Deuda técnica activa**: Consultar `brain/technical-debt.md`.
