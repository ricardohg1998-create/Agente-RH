# Ãndice de Workflows Operativos

Este documento sirve como mapa relacional y de navegación rápido para los workflows de la suite operativa del agente. El registro maestro, los criterios de despacho automáticos, las topologías de Swarm y las señales de desempate están centralizados en la **única fuente de verdad** (SSoT): [Workflow Dispatch Rule](../.agent/rules/workflow-dispatch.md).

## Catálogo de Despacho Rápido

| Workflow | Identificador | Cuándo Utilizar (Señal Rápida) | Guía Detallada |
| :--- | :--- | :--- | :--- |
| **Autista cafeinado** | `autista-cafeinado` | Antes de release relevante | [Ver Guía](../.agent/workflows/autista-cafeinado.md) |
| **Buscar skills** | `buscar-skills` | Inicio de proyecto nuevo | [Ver Guía](../.agent/workflows/buscar-skills.md) |
| **Cierre operativo** | `cierre-operativo` | Al terminar una tarea tecnica o documental | [Ver Guía](../.agent/workflows/cierre-operativo.md) |
| **Code Review** | `code-review` | Antes de merge o deploy | [Ver Guía](../.agent/workflows/code-review.md) |
| **Desarrollador de profundidad** | `desarrollador-profundidad` | Producto parece incompleto o superficial | [Ver Guía](../.agent/workflows/desarrollador-profundidad.md) |
| **Higiene de contexto** | `higiene-contexto` | Se detecta ruido, duplicidad o documentos largos sin accion | [Ver Guía](../.agent/workflows/higiene-contexto.md) |
| **Implementacion quirurgica** | `implementacion-quirurgica` | Se pide desglose de implementacion paso a paso | [Ver Guía](../.agent/workflows/implementacion-quirurgica.md) |
| **Inicio de proyecto** | `inicio-proyecto` | Repo recien clonado con esqueleto base | [Ver Guía](../.agent/workflows/inicio-proyecto.md) |
| **Mr Problem Solver** | `mr-problem-solver` | Hay errores, caidas, regresiones o comportamiento inestable | [Ver Guía](../.agent/workflows/mr-problem-solver.md) |
| **Pre-lanzamiento** | `pre-release` | Antes de deploy a produccion o staging | [Ver Guía](../.agent/workflows/pre-release.md) |
| **QA y Pruebas** | `qa-testing` | Feature nueva que necesita cobertura de tests | [Ver Guía](../.agent/workflows/qa-testing.md) |
| **Retrospectiva** | `retrospectiva` | Al cerrar un hito, fase o sprint relevante | [Ver Guía](../.agent/workflows/retrospectiva.md) |
| **Spike de investigacion** | `spike-investigacion` | Se necesita elegir entre varias tecnologias o librerias | [Ver Guía](../.agent/workflows/spike-investigacion.md) |

---

## Directiva de Uso Recomendado

1. **Definir Alcance:** Determina qué cambio o feature vas a acometer.
2. **Seleccionar el Workflow:** Consulta la tabla anterior y dirígete a [Workflow Dispatch](../.agent/rules/workflow-dispatch.md) para alinearte con las topologías de Swarm recomendadas.
3. **Ejecutar e Integrar:** Genera la salida estructurada solicitada por el workflow seleccionado.
4. **Cierre Higiénico:** Finaliza siempre la sesión utilizando la secuencia del workflow de [Cierre Operativo](../.agent/workflows/cierre-operativo.md).