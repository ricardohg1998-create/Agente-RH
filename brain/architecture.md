# Architecture

## Bloques principales

- `/.agent`: capa operativa del agente (reglas, workflows, templates, config).
- `/brain`: memoria viva del proyecto.
- `/scripts`: automatizacion minima de estructura, higiene y memoria.
- `/docs`: guias de uso y handoff.

## Flujo principal

1. Leer `brain/now.md`, `brain/current-state.md`, `brain/stack.md` y `brain/deep-summary.md`.
2. Ejecutar tarea con reglas/workflows de `.agent/`.
3. Actualizar capa rapida del cerebro y sincronizar `brain/deep-summary.md` si cambia la capa profunda.
4. Registrar decision/changelog si aplica.
5. Ejecutar checks de estructura y limpieza.

## Arquitectura de Enjambre Jerárquico (Swarm Core v2.0)

El orquestador de **Agente RH** soporta una topología multiagente avanzada para implementaciones complejas:
- **Orquestador Principal (Lead Architect)**: Dirige la sesión, planifica la implementación técnica y fusiona cambios validados.
- **Supervisor del Enjambre (SwarmSupervisor)**: Coordina de forma interactiva en tiempo real al resto de agentes, mitiga bloqueos y arbitra la secuencia de merges.
- **Validador de Calidad (QualityValidator)**: Compuerta técnica crítica encargada de auditar intelectualmente, criticar de forma rigurosa y constructiva, y validar por tests de regresión todo el código antes de la fusión final.
- **Desarrolladores Especialistas (FeatureDevelopers, CodebaseResearchers)**: Ejecutan tareas quirúrgicas y acotadas en workspaces aislados (`share`/`branch`).
