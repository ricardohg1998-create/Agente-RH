---
id: semantic-analyzer
name: Semantic Analyzer (MCP)
description: Instruye al Agente para priorizar la comprension de codigo basada en AST y relaciones semanticas mediante el servidor MCP, deprecando el uso abusivo de grep_search.
version: 1.1.0
---

# Skill: Semantic Analyzer (MCP)

## Proposito
Transformar el paradigma de descubrimiento de codigo del agente, pasando de busquedas de texto plano (grep) a resolucion formal de simbolos mediante el Servidor Semantico MCP local.

## Cuando usar esta Skill
- Cuando necesites entender dependencias cruzadas entre modulos.
- Al buscar "donde se utiliza esta funcion/clase".
- Al necesitar la definicion estricta o las firmas de tipos de un componente.
- Durante cualquier refactor grande donde la precision absoluta sea critica.

## Herramientas disponibles del MCP Server

Las herramientas reales expuestas por el servidor son:

1. **`analyze_file_ast`**: Analiza sintacticamente un archivo TypeScript y devuelve sus exportaciones, interfaces y clases.
2. **`get_symbol_references`**: Encuentra donde se utiliza un simbolo o exportacion concreta a lo largo de todo el proyecto.

## Reglas de Comportamiento Sensorial
1. **Deprecacion de `grep_search` para logica**: No uses `grep_search` para buscar funciones, clases, tipos o exportaciones en proyectos con tipado fuerte (TypeScript, Python moderno). Usa `grep_search` EXCLUSIVAMENTE para buscar strings planos, css, o contenido markdown.
2. **Prioridad MCP**: Si el servidor MCP Semantico esta activo, invoca sus herramientas (`analyze_file_ast`, `get_symbol_references`) para todo descubrimiento estatico.
3. **Pausar e invocar**: Si te pasas un prompt entero leyendo archivos y haciendo greps sintiendo que estas perdiendo el contexto general, DETENTE. Usa la herramienta del analizador semantico para que te decodifique la jerarquia limpiamente.

## Flujo Operativo Esperado
1. En lugar de: `grep_search("interface UserProfile")`
2. Usar: `analyze_file_ast("src/models/user.ts")` (para obtener todas las exportaciones del archivo).
3. Luego: `get_symbol_references("src/models/user.ts", "UserProfile")` (para encontrar todos los usos).
4. Asegurate de leer las firmas y tipos antes de escribir codigo, igual que haria un humano con el tooltip de su IDE.
