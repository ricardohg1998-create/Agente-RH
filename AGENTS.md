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
Para buscar lógica, funciones o código, **`grep_search` está estrictamente prohibido si un servidor MCP semántico está activo**, debiendo priorizar las herramientas específicas `mcp_*`. Consulta los detalles y la directiva completa en [00-mcp-strict-override.md](file:///r:/Escritorio/Ricardo%20Huertas/Repos%20GitHub/Agente%20RH/.agent/rules/00-mcp-strict-override.md).

## Herramientas del entorno

- IDE principal: Google Antigravity
- Modelo preferido: Gemini 3.1 Pro
- Shell: PowerShell (Windows 11)

## Infraestructura de producción (Template)

- **Entorno de Despliegue**: Por definir de forma dinámica en cada clon de acuerdo con las especificaciones del cliente.
- **Base de Datos**: Por definir (PostgreSQL o SQLite según la arquitectura de stack seleccionada).
- **Credenciales y Secretos**: Consultar de forma segura en [access.md](file:///r:/Escritorio/Ricardo%20Huertas/Repos%20GitHub/Agente%20RH/brain/access.md) o en el sistema configurado del entorno.
- **Gestión de Riesgos y Despliegue**:
  - Leer siempre [pitfalls-and-errors.md](file:///r:/Escritorio/Ricardo%20Huertas/Repos%20GitHub/Agente%20RH/brain/pitfalls-and-errors.md) antes de cada paso a producción.
  - Revisar y mitigar la deuda técnica activa documentada en [technical-debt.md](file:///r:/Escritorio/Ricardo%20Huertas/Repos%20GitHub/Agente%20RH/brain/technical-debt.md).
