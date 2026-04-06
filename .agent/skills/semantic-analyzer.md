---
id: semantic-analyzer
name: Semantic Analyzer (LSP)
description: Instruye al Agente para priorizar la comprension de codigo basada en AST y relaciones semanticas mediante el servidor MCP, deprecando el uso abusivo de grep_search.
version: 1.0.0
---

# Skill: Semantic Analyzer (LSP)

## Proposito
Transformar el paradigma de descubrimiento de codigo del agente, pasando de busquedas de texto plano (grep) a resolucion formal de simbolos mediante el Servidor Semantico MCP local.

## Cuando usar esta Skill
- Cuando necesites entender dependencias cruzadas entre modulos.
- Al buscar "donde se utiliza esta funcion/clase".
- Al necesitar la definicion estricta o las firmas de tipos de un componente.
- Durante cualquier refactor grande donde la precision absoluta sea critica.

## Reglas de Comportamiento Sensorial
1. **Deprecacion de `grep_search` para logica**: No uses `grep_search` para buscar funciones, clases, tipos o exportaciones en proyectos con tipado fuerte (TypeScript, Python moderno). Usa `grep_search` EXCLUSIVAMENTE para buscar strings planos, css, o contenido markdown.
2. **Prioridad MCP**: Si el servidor MCP Semantico esta activo, invoca sus herramientas (`find_references`, `get_ast_signature`, `resolve_module`, etc.) para todo descubrimiento estatico.
3. **Pausar e invocar**: Si te pasas un prompt entero leyendo archivos y haciendo greps sintiendo que estas perdiendo el contexto general, DETENTE. Usa la herramienta del analizador semantico para que te decodifique la jerarquia limpiamente.

## Flujo Operativo Esperado
1. En lugar de: `grep_search("interface UserProfile")`
2. Usar: `get_type_definition("UserProfile")` (a traves de la herramienta inyectada si esta disponible, o invocando el script del servidor semantico).
3. Asegurate de leer las firmas y tipos antes de escribir codigo, igual que haria un humano con el tooltip de su IDE.
