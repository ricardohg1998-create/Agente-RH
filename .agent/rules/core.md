---
id: core
name: Core Operating Rules
activation: always-on
version: 2.1.0
---

# Core Operating Rules

## Proposito

Definir el comportamiento diario del agente en Antigravity 2.0: util, autonomo, conciso y estable. Esta regla prevalece sobre workflows, plantillas y memoria cuando haya friccion operativa.

## Contrato de comportamiento

- **Responder siempre en espanol**.
- Ser directo y conciso por defecto: 2 parrafos o hasta 6 vinetas en respuestas normales.
- Ampliar solo si el usuario pide informe, auditoria profunda, plan detallado o si el riesgo tecnico lo exige.
- Evitar superlativos como "exito absoluto", "impecable" o "100%" salvo que describan un resultado medido.
- Priorizar soluciones funcionales y simples. No crear complejidad artificial.
- Si falta contexto critico, pedirlo de forma breve; si puede descubrirse leyendo el repo, descubrirlo primero.

## Memoria operativa

- Leer `brain/now.md`, `brain/current-state.md`, `brain/stack.md` y `brain/deep-summary.md` solo antes de cambios relevantes, cierre de tarea, incidentes, cambios de alcance o decisiones persistentes.
- Para consultas, auditorias de solo lectura o respuestas conceptuales, no actualizar `brain/` ni crear logs.
- Expandir a memoria profunda solo si hay incidente, contradiccion, cambio de arquitectura/alcance o evidencia insuficiente.
- Si hubo cambios relevantes, actualizar memoria corta al final y enlazar el registro de sesion si existe.
- Crear registro de sesion con `scripts/new-session.ps1` solo cuando vaya a haber cambios relevantes en archivos o decisiones persistentes.

## Workflows

- Los workflows son guias bajo demanda, no obligaciones automaticas.
- Activar un workflow completo si el usuario lo pide por nombre o si la tarea encaja claramente y aporta valor real.
- Para tareas pequenas, resolver directamente sin `implementation_plan.md`, `task.md`, `walkthrough.md` ni cadena de workflows.
- El cierre operativo solo aplica cuando hay cambios reales, handoff, commit, release o el usuario pide cerrar.

## Swarm

- Usar swarm solo para investigaciones extensas, auditorias grandes o desarrollo paralelo de multiples piezas.
- No invocar subagentes para tareas sencillas, cambios de un paso, consultas, lectura puntual o correcciones pequenas.
- Si se usa swarm, acotar payload, workspace y retorno esperado antes de invocarlo.

## Herramientas

- Usar MCP semantico para AST, simbolos, tipos, imports y referencias de codigo.
- Usar busqueda textual para markdown, logs, configuraciones, secretos, TODOs, rutas, placeholders y patrones planos.
- Si un MCP no esta activo o su ruta falla, degradar a busqueda textual con criterio y reportarlo brevemente si afecta al resultado.
