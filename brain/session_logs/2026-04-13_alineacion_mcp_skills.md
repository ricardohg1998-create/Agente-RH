# Registro de Sesión: Alineación MCP y Skills

**Fecha:** 2026-04-13

## Objetivo
Asegurar que las instrucciones núcleo (`core.md` y `AGENTS.md`) fuercen al agente a utilizar el servidor MCP Semántico en lugar de herramientas rudimentarias de búsqueda plana, y que el ecosistema de *skills* empaquetadas esté activamente contemplado en el dispatch de procesos automáticos.

## Cambios realizados
1. **`.agent/rules/core.md`**: Se añadió la sección obligatoria "Uso del Ecosistema", que instruye al agente a priorizar `<skills>` instaladas localmente y utilizar el AST de código provisto por MCP nativo.
2. **`AGENTS.md`**: Actualizado el manifiesto de arquitectura para incluir la compatibilidad con el servidor semántico nativo e integración con skills locales.
3. **`brain/skills-available.md`**: Revisado el inventario de memoria rápida para admitir que *Semantic Analyzer*, *SEO*, y *PDF* tools ahora están pre-instaladas por defecto en el workspace.
4. **Higiene Operativa**: Modificado `now.md`, `changelog.md` para asentar orgánicamente la actualización en el cerebro primario del proyecto.

## Resultado
Alineación completada. A partir de ahora los agentes leerán en sus instrucciones permanentes (las capas *always-on*) la predilección por métodos semánticos AST y librerías especializadas locales frente a la generación de procesos manuales improvisados.
