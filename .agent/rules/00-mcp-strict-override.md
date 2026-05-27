---
id: mcp-strict-override
name: MCP Semantic Tooling
activation: always-on
version: 2.1.0
---

# MCP Semantic Tooling

## Regla practica

Usa la herramienta mas especifica para el tipo de busqueda:

- **MCP semantico** para codigo estructurado: AST, exports, clases, funciones, tipos, imports y referencias de simbolos.
- **Busqueda textual** para texto plano: markdown, logs, configuraciones, secretos, TODO/FIXME, rutas, placeholders, strings y patrones regex.

## Prefijos dinamicos

Los servidores MCP semanticos tienen prefijos por proyecto, por ejemplo `nueva-web-ricardo-Semantic` o `CRM-SocialClub-Semantic`. Usa el prefijo realmente disponible en la sesion actual.

## Degradacion segura

- Si el MCP semantico existe y la tarea es de AST/simbolos, priorizalo.
- Si el MCP no esta disponible, su ruta falla o la busqueda es textual, usa busqueda textual sin bloquearte.
- No conviertas esta regla en ceremonia: la seleccion de herramienta debe ahorrar tiempo y mejorar precision.
