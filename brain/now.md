# Now

<!-- QUICK-NOW:START -->
## Estado actual

- **Reglas maestras** (`core.md` y la skill semántica) parcheadas con instrucciones duras **anti-grep_search** cuando se trate de navegación de AST o lectura de código avanzado.
- Aclaración explícita del prefijo dinámico inyectado por el servidor MCP en sus herramientas (ej. `mcp_[NombreServidor]_analyze_file_ast`).

## Siguiente accion recomendada

- Aplicar estos cambios a los demás repos, asegurándose de que al usar Antigravity lea conscientemente los prefijos del servidor MCP y priorice `mcp_*` antes de su instinto de fall-back a `grep_search`.

## Bloqueos activos

- Ninguno.

## Cambios recientes

- [2026-04-13] **Parche anti-grep**: Actualizado `SKILL.md` (v1.1.1) y `core.md` con advertencias enérgicas y explícitas sobre cómo invocar las herramientas de MCP y por qué evitar usar grep de forma automática.
- [2026-04-13 11:53] Instrucciones del agente alineadas con servidor MCP y ecosistema local. Ver [registro detallado](session_logs/2026-04-13_alineacion_mcp_skills.md).
- [2026-04-11 15:14] Auditoria brain + .agent. Ver [registro detallado](session_logs/2026-04-11_auditoria_brain_agent.md).
<!-- QUICK-NOW:END -->
