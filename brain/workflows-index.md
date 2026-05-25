# Indice de Workflows Operativos

Este documento sirve como mapa relacional y de navegacion rapido para los workflows de la suite operativa del agente. El registro maestro, los criterios de despacho automaticos, las topologias de Swarm y las senales de desempate estan centralizados en la **unica fuente de verdad** (SSoT): [Workflow Dispatch Rule](../.agent/rules/workflow-dispatch.md).

## Catalogo de Despacho Rapido

| Workflow | Identificador | Cuando Utilizar (Senal Rapida) | Guia Detallada |
| :--- | :--- | :--- | :--- |
| **Autista cafeinado** | `autista-cafeinado` | Antes de release relevante | [Ver Guia](../.agent/workflows/autista-cafeinado.md) |
| **Buscar skills** | `buscar-skills` | Inicio de proyecto nuevo | [Ver Guia](../.agent/workflows/buscar-skills.md) |
| **Cierre operativo** | `cierre-operativo` | Al terminar una tarea tecnica o documental | [Ver Guia](../.agent/workflows/cierre-operativo.md) |
| **Code Review** | `code-review` | Antes de merge o deploy | [Ver Guia](../.agent/workflows/code-review.md) |
| **Desarrollador de profundidad** | `desarrollador-profundidad` | Producto parece incompleto o superficial | [Ver Guia](../.agent/workflows/desarrollador-profundidad.md) |
| **Higiene de contexto** | `higiene-contexto` | Se detecta ruido, duplicidad o documentos largos sin accion | [Ver Guia](../.agent/workflows/higiene-contexto.md) |
| **Implementacion quirurgica** | `implementacion-quirurgica` | Se pide desglose de implementacion paso a paso | [Ver Guia](../.agent/workflows/implementacion-quirurgica.md) |
| **Inicio de proyecto** | `inicio-proyecto` | Repo recien clonado con esqueleto base | [Ver Guia](../.agent/workflows/inicio-proyecto.md) |
| **Mr Problem Solver** | `mr-problem-solver` | Hay errores, caidas, regresiones o comportamiento inestable | [Ver Guia](../.agent/workflows/mr-problem-solver.md) |
| **Pre-lanzamiento** | `pre-release` | Antes de deploy a produccion o staging | [Ver Guia](../.agent/workflows/pre-release.md) |
| **QA y Pruebas** | `qa-testing` | Feature nueva que necesita cobertura de tests | [Ver Guia](../.agent/workflows/qa-testing.md) |
| **Retrospectiva** | `retrospectiva` | Al cerrar un hito, fase o sprint relevante | [Ver Guia](../.agent/workflows/retrospectiva.md) |
| **Spike de investigacion** | `spike-investigacion` | Se necesita elegir entre varias tecnologias o librerias | [Ver Guia](../.agent/workflows/spike-investigacion.md) |

---

## Directiva de Uso Recomendado

1. **Definir Alcance:** Determina que cambio o feature vas a acometer.
2. **Seleccionar el Workflow:** Consulta la tabla anterior y dirigete a [Workflow Dispatch](../.agent/rules/workflow-dispatch.md) para alinearte con las topologias de Swarm recomendadas.
3. **Ejecutar e Integrar:** Genera la salida estructurada solicitada por el workflow seleccionado.
4. **Cierre Higienico:** Finaliza siempre la sesion utilizando la secuencia del workflow de [Cierre Operativo](../.agent/workflows/cierre-operativo.md).