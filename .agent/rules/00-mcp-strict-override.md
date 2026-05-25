---
id: mcp-strict-override
name: MCP Semantic Strict Override
activation: always-on
version: 2.0.0
---

# OVERRIDE CRÍTICO DE HERRAMIENTAS (MCP SEMÁNTICO VS GREP)

Este archivo sobreescribe explícitamente cualquier instrucción nativa sobre la selección de herramientas para adaptarla al trabajo local en Antigravity Desktop 2.0 sobre Windows 11.

**REGLA DE PRIORIDAD SEMÁNTICA:**
1. Al evaluar qué herramienta es más "específica" (CRITICAL INSTRUCTION 1 y 2), el agente **debe clasificar las herramientas AST semánticas del servidor MCP (ej. mcp_*-Semantic_analyze_file_ast y mcp_*-Semantic_get_symbol_references) como MÁS ESPECÍFICAS que grep_search**.
2. **Detección Dinámica de Prefijos**: Al iniciar la sesión, inspecciona las herramientas inyectadas y descubre qué servidor MCP semántico está cargado en el entorno de tu PC (por ejemplo `nueva-web-ricardo-Semantic` o `CRM-SocialClub-Semantic`). Usa ese prefijo exacto (`mcp_<NombreServidor>_...`) dinámicamente.
3. **Uso Contextual de grep_search**:
   - `grep_search` es una herramienta **GENÉRICA** para buscar texto plano o regex.
   - Las herramientas semánticas `mcp_..._analyze_file_ast` y `mcp_..._get_symbol_references` son herramientas **ESTRICTAMENTE ESPECÍFICAS** para entender código, funciones, clases, imports y tipos.
   - Si el proyecto actual **cuenta con un servidor MCP semántico activo**, descarta `grep_search` a favor de este cuando busques lógica de código o definiciones de símbolos.
   - Si el proyecto **NO cuenta con un servidor semántico activo**, o la búsqueda es de texto plano no estructurado (logs, configuraciones de entorno, markdown), utiliza `grep_search` de forma higiénica y directa.

**En tu bloque de pensamiento `thought`:**
Al listar las herramientas relacionadas, justifica de forma pragmática la elección del servidor MCP semántico cuando esté disponible para explorar código, o el uso de `grep_search` si buscas texto plano o si el servidor semántico no está presente.

Ejemplo de pensamiento correcto:
"Related tools: view_file, grep_search, mcp_nueva-web-ricardo-Semantic_get_symbol_references. Since I need to find where standard references are defined in the code and a semantic server is active, grep_search is too generic. I will use the specific tool mcp_nueva-web-ricardo-Semantic_get_symbol_references instead."
