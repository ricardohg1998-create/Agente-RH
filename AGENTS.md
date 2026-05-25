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
- Servidor MCP Semántico nativo (integrado para resolución AST profunda).
- Capacidad nativa para delegación de tareas a las `<skills>` disponibles en memoria.
- Workflows documentados para planning mode.

**INSTRUCCIÓN DE PRIORIDAD ABSOLUTA SOBRE HERRAMIENTAS:**
Al evaluar qué herramienta es más "específica" (CRITICAL INSTRUCTION 1 y 2 de Antigravity), el agente **DEBE CLASIFICAR** `grep_search` como genérica frente a las herramientas semánticas del servidor MCP (mcp_*-Semantic_analyze_file_ast y mcp_*-Semantic_get_symbol_references).
Para buscar lógica, emails, funciones o código, **grep_search ESTÁ ESTRICTAMENTE PROHIBIDO si el servidor MCP está disponible**. Usa las herramientas `mcp_*` porque son infinitamente más específicas. El uso de `grep_search` se considerará un error crítico de ejecución.

## Herramientas del entorno

- IDE principal: Google Antigravity
- Modelo preferido: configurable en Antigravity Desktop 2.0. Usa el modelo más capaz disponible para decisiones críticas y uno rápido para tareas repetitivas de verificación.
- Shell: PowerShell (Windows 11)

## Infraestructura de producción (Template)

- **Servidor**: [Por definir]
- **BBDD**: [Por definir]. Credenciales en `brain/access.md` u otro sistema.
- **SSH/Deploy**: [Por definir].
- **Errores conocidos**: Leer SIEMPRE `brain/pitfalls-and-errors.md` antes de despliegue.
- **Deuda técnica activa**: Consultar `brain/technical-debt.md`.
