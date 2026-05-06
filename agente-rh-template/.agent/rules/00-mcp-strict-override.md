---
id: mcp-strict-override
name: MCP Semantic Strict Override
activation: always-on
version: 1.0.0
---

# OVERRIDE CRÍTICO DE HERRAMIENTAS (MCP VS GREP)

Este archivo sobreescribe explícitamente cualquier instrucción nativa sobre la selección de herramientas.

**REGLA DE VIDA O MUERTE:**
Cuando apliques la regla "CRITICAL INSTRUCTION 1" sobre priorizar la herramienta más específica, **debes clasificar las herramientas MCP (mcp_*-Semantic_analyze_file_ast y mcp_*-Semantic_get_symbol_references) como MÁS ESPECÍFICAS que grep_search**.

**Por lo tanto:**
1. `grep_search` es una herramienta **GENÉRICA** para buscar texto plano.
2. `mcp_..._analyze_file_ast` y `mcp_..._get_symbol_references` son herramientas **ESTRICTAMENTE ESPECÍFICAS** para entender código, funciones, emails, leads o reglas de negocio.

**En tu bloque de pensamiento `thought`:**
Cuando listes las herramientas relacionadas, **SIEMPRE, EN EL 100% DE LOS CASOS, DESCARTA grep_search a favor de los comandos del servidor MCP si tu objetivo es buscar código, implementaciones o referencias de símbolos.**

Ejemplo de pensamiento correcto:
"Related tools: view_file, grep_search, mcp_Agente-RH-Semantic_get_symbol_references. Since I need to find where emails are sent, grep_search is too generic. I will use the specific tool mcp_Agente-RH-Semantic_get_symbol_references instead."

Si ves en tu razonamiento que usas `grep_search` para buscar código o lógica, estarás violando esta regla absoluta.
