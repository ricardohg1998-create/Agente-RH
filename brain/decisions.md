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

## [2026-05-22] Adopción de Swarm Core v2.0 y Orquestación Asíncrona Concurrente

- **Contexto**: El repositorio necesitaba adaptarse al nuevo stack tecnológico (Antigravity 2.0 y Gemini 3.5 Flash). Gemini 3.5 Flash destaca por su alta velocidad de procesamiento, pero requiere un modelo de trabajo asíncrono y paralelo para maximizar su rendimiento.
- **Alternativas Estudiadas**:
  - Opción A: Mantener el desarrollo secuencial monoproceso (más simple pero subóptimo en cuanto a tiempos).
  - Opción B: Transicionar a un esquema de enjambre descentralizado (Swarm Core v2.0) donde el Orquestador principal delega tareas en background a subagentes especialistas que corren sobre `Workspace: inherit` (potente, veloz, libre de bloqueos de Git/Windows).
- **Decision Adoptada**:
  - Opción B. Se adaptaron las reglas (`core.md`, `swarm-orchestration.md`), workflows (`cierre-operativo.md`, `implementacion-quirurgica.md`) y scripts para admitir la coordinación asíncrona de subagentes especialistas (CodebaseAuditor, FeatureDeveloper, QASpecialist, CleanlinessGuardian).
- **Consecuencias Esperadas**:
  - Bueno: Reducción drástica del consumo de contexto y los tiempos de ejecución. Capacidad para resolver tareas complejas de forma concurrente.
  - Malo: Requiere un control riguroso de sincronización y memoria por parte del Orquestador principal, además de evitar la coordinación anidada por parte de los especialistas (resuelto mediante directiva de contención).

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

---

### DEC-20260524-005147

- Fecha: 2026-05-24
- Estado: accepted
- Titulo: Endurecer plantilla Antigravity Desktop 2.0

Contexto:
La plantilla necesitaba reducir friccion al clonarse en Windows 11: habia enlaces file:/// absolutos al repo maestro, payloads efimeros de brain/swarm podian filtrarse al export y la suite detectaba deep-summary desincronizado.

Decision:
Usar rutas relativas en reglas y plantillas, limpiar brain/swarm en scripts de exportacion, ignorar artefactos efimeros y hacer que check-cleanliness falle si quedan planes o payloads temporales al cierre.

Consecuencias:
La plantilla queda mas portable para nuevos repositorios Antigravity Desktop 2.0 y los checks capturan residuos antes de distribuir o cerrar una sesion.
