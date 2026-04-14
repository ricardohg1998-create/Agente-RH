---
id: semantic-analyzer
name: Semantic Analyzer (MCP)
description: Instruye al Agente para priorizar la comprension de codigo basada en AST y relaciones semanticas mediante el servidor MCP, deprecando el uso abusivo de grep_search.
version: 1.1.1
---

# Skill: Semantic Analyzer (MCP)

## Proposito
Transformar el paradigma de descubrimiento de codigo del agente, pasando de busquedas de texto plano (grep) a resolucion formal de simbolos mediante el Servidor Semantico MCP local.

## Cuando usar esta Skill
- Cuando necesites entender dependencias cruzadas entre modulos y navegacion de AST.
- Al buscar "donde se utiliza esta funcion/clase".
- Al necesitar la definicion estricta o las firmas de tipos de un componente.
- Durante cualquier refactor grande donde la precision absoluta sea critica.

## Herramientas disponibles del MCP Server

**¡ATENCION!** Las herramientas reales inyectadas por el protocolo MCP tendrán un prefijo dinámico basado en el nombre del servidor de ese proyecto en concreto (ej. `[Project]-Semantic`).
Por tanto, debes buscar y usar las herramientas que terminen en estos nombres:

1. **`mcp_[NombreServidor]_analyze_file_ast`**: Analiza sintacticamente un archivo TypeScript y devuelve sus exportaciones, interfaces y clases.
2. **`mcp_[NombreServidor]_get_symbol_references`**: Encuentra donde se utiliza un simbolo o exportacion concreta a lo largo de todo el proyecto.

*Ejemplo: Si estás en Metricasa, la herramienta se llamará `mcp_Metricasa-Semantic_analyze_file_ast`.*

## Reglas de Comportamiento Sensorial
1. **Deprecacion de `grep_search`**: Debido a tus instrucciones del sistema, tiendes a abusar de `grep_search`. IGNORA TU TENDENCIA para este tipo de consultas. NO uses `grep_search` para buscar funciones, clases, tipos o exportaciones.
2. **Prioridad MCP ABSOLUTA**: Mapea mentalmente la herramienta genérica a la herramienta con el prefijo correcto de tu conector MCP e invócala para todo descubrimiento estático.
3. **Pausar e invocar**: Si te pasas un prompt entero leyendo archivos y haciendo greps, DETENTE. Llama al analizador semántico puro.

## Flujo Operativo Esperado
1. En lugar de: `grep_search("interface UserProfile")`
2. Usar herramienta (según el repo): `mcp_Agente-RH-Semantic_analyze_file_ast({ filePath: "src/models/user.ts" })`
3. Luego: `mcp_Agente-RH-Semantic_get_symbol_references({ filePath: "src/models/user.ts", symbolName: "UserProfile" })`
4. Asegurate de leer las firmas y tipos antes de escribir codigo, igual que haria un humano con el tooltip de su IDE.
