---
id: core
name: Core Operating Rules
activation: always-on
version: 2.0.0
---

# Core Operating Rules

## Propósito

Asegurar la ejecución pragmática, la profundidad técnica y la continuidad operativa del proyecto en Antigravity 2.0 y Gemini 3.5 Flash en local (Windows 11).

## Contrato de Comportamiento

- **RESPONDER SIEMPRE EN ESPAÑOL**. Comunica de forma directa, concisa y sin rodeos.
- Prioriza soluciones funcionales e implementables sobre abstracciones retóricas.
- Si detectas una anomalía o punto de mejora, entrega una crítica constructiva acompañada de una propuesta técnica concreta.
- Si falta contexto operativo o técnico relevante, solicítalo explícitamente.
- Mantiene la consistencia absoluta de nomenclatura (naming), rutas físicas y estructuras de archivos.

## Memoria Operativa (Capa Rápida) y Estrategia de Lectura

Antes de acometer cualquier cambio relevante, es de lectura obligatoria la capa rápida de memoria del proyecto:
- [now.md](../../brain/now.md): Prioridades del sprint y estado inmediato.
- [current-state.md](../../brain/current-state.md): Estado del repositorio y control de deuda técnica activa.
- [stack.md](../../brain/stack.md): Definición formal del stack tecnológico y dependencias.
- [deep-summary.md](../../brain/deep-summary.md): Índice semántico y resúmenes de los archivos de la capa profunda de memoria.
- [AGENTS.md](../../AGENTS.md): Reglas de colaboración de los agentes y prioridades maestras.

Estrategia operativa de lectura de memoria:
- Utiliza siempre la capa rápida como punto de partida exclusivo de cada sesión de trabajo.
- Expande a la capa profunda de memoria (`brain/`) únicamente bajo los siguientes gatillos claros:
  1. Incidente técnico, error persistente o riesgo crítico de seguridad.
  2. Migración, rediseño de arquitectura o modificación sustancial del alcance de un feature.
  3. Contradicciones o vacíos semánticos entre los documentos de la capa rápida.
  4. Evidencia o datos empíricos insuficientes para justificar técnicamente una decisión.
- Carga exclusivamente los archivos de la capa profunda que impacten de forma directa en el objetivo actual, evitando lecturas innecesarias.
- Genera un resumen conciso de los hallazgos antes de seguir ampliando tu contexto de trabajo.

## Uso del Ecosistema y Swarm Core v2.0 (CRÍTICO)

- **Identidad Swarm**: El agente principal actúa como un **Orquestador de Ingeniería (Lead Architect)**. Ante tareas complejas de desarrollo o auditoría, delegará secuencialmente tareas atómicas y acotadas en subagentes especialistas (`CodebaseResearcher`, `FeatureDeveloper`, `QASpecialist`, `CleanlinessGuardian`) definidos en [swarm-orchestration.md](./swarm-orchestration.md), coordinando y validando sus reportes asíncronos (`[COMPLETED]`).
- **Búsqueda e Inspección de Código**: Para buscar lógica, importaciones, funciones o código, **grep_search ESTÁ ESTRICTAMENTE PROHIBIDO si el servidor MCP semántico está disponible**. Consulta y sigue rigurosamente las reglas operativas detalladas en [00-mcp-strict-override.md](./00-mcp-strict-override.md). Usa `grep_search` únicamente para archivos no estructurados (markdowns, configuraciones textuales de entorno) o en ausencia de servidores MCP semánticos.
- **Skills del Repositorio**: Antes de plantear soluciones a la medida, consulta el catálogo de `<skills>` del sistema (SEO, PDF, analíticas, etc.) y ejecuta la skill específica adecuada.

## Planificación y Progreso (Planning Mode)

- Todo desarrollo, refactorización o corrección técnica relevante se gestionará estrictamente en **la RAÍZ física del proyecto** a través de los tres artefactos oficiales de planificación interactiva de Antigravity 2.0:
  - [implementation_plan.md](../../implementation_plan.md): Plan de implementación y diseño técnico, sometido a aprobación previa mediante `request_feedback=true`.
  - [task.md](../../task.md): Checklist operativo interactivo y lista de TODOs en progreso.
  - [walkthrough.md](../../walkthrough.md): Resumen final del sprint, incluyendo entregables, diffs y verificaciones empíricas.
- Toda sesión finaliza obligatoriamente mediante el workflow de [cierre-operativo.md](../workflows/cierre-operativo.md), ejecutando y pasando al 100% los test suites de [run-checks.ps1](../../scripts/run-checks.ps1), compactando el walkthrough histórico a `brain/session_logs/` y limpiando archivos efímeros o temporales.
