# Decisiones Tecnicas

<!-- EJEMPLO: (Manten este bloque comentado. Solo para guiar al agente de como redactar tareas).
## [YYYY-MM-DD] Titulo de la Decision

- **Contexto**: Relatos breves de por que se toma la decision.
- **Alternativas Estudiadas**:
  - Opcion 1: Pros vs contras.
  - Opcion 2: Pros vs contras.
- **Decision Adoptada**: 
  - Que se decidio finalmente.
- **Consecuencias Esperadas**:
  - Bueno: que hemos ganado.
  - Malo: que hemos cedido (deuda tecnica).
-->

## [2026-04-05] Acoplamiento directo de workflows con Antigravity

- **Contexto**: Los workflows referencian herramientas de forma generica. Se evaluo si hacer los pasos portables a otros IDEs o acoplarlos directamente con las herramientas de Antigravity.
- **Alternativas Estudiadas**:
  - Opcion A: Hints opcionales en seccion separada (portable, menos potente).
  - Opcion B: Herramientas como parte integral de los pasos (potente, no portable).
- **Decision Adoptada**: 
  - Opcion B — acoplamiento directo. Cada workflow mapea herramientas especificas (`grep_search`, `browser_subagent`, `search_web`, `run_command`, `view_file`, `list_dir`, `command_status`) a pasos concretos.
- **Consecuencias Esperadas**:
  - Bueno: Workflows mucho mas precisos y ejecutables. El modelo sabe exactamente que herramienta usar para cada paso.
  - Malo: Los workflows no son portables a otros IDEs. Si se migra de Antigravity, habria que adaptar la seccion de herramientas.

## [2026-04-05] Sistema de composicion y encadenamiento de workflows

- **Contexto**: Los workflows operaban de forma aislada. Se evaluo si implementar un sistema de cadenas predefinidas.
- **Alternativas Estudiadas**:
  - Sin encadenamiento (mas simple, menos poderoso).
  - Composicion con cadenas predefinidas + senales de dispatch (mas complejo, mucho mas potente).
- **Decision Adoptada**: 
  - Composicion completa con 5 cadenas predefinidas, senales/anti-senales y prioridad por workflow.
- **Consecuencias Esperadas**:
  - Bueno: Flujos de trabajo naturales, el agente sugiere el siguiente paso automaticamente.
  - Malo: `workflow-dispatch.md` ha crecido significativamente (~200 lineas). Monitorear presupuesto de contexto.
