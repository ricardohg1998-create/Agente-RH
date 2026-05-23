# Ãndice de Workflows Operativos

Este documento sirve como mapa relacional y de navegaciÃ³n rÃ¡pido para los workflows de la suite operativa del agente. El registro maestro, los criterios de despacho automÃ¡ticos, las topologÃ­as de Swarm y las seÃ±ales de desempate estÃ¡n centralizados en la **Ãºnica fuente de verdad** (SSoT): [Workflow Dispatch Rule](../.agent/rules/workflow-dispatch.md).

## CatÃ¡logo de Despacho RÃ¡pido

| Workflow | Identificador | CuÃ¡ndo Utilizar (SeÃ±al RÃ¡pida) | GuÃ­a Detallada |
| :--- | :--- | :--- | :--- |
| **Autista cafeinado** | `autista-cafeinado` | Antes de release relevante | [Ver GuÃ­a](../.agent/workflows/autista-cafeinado.md) |
| **Buscar skills** | `buscar-skills` | Inicio de proyecto nuevo | [Ver GuÃ­a](../.agent/workflows/buscar-skills.md) |
| **Cierre operativo** | `cierre-operativo` | Al terminar una tarea tecnica o documental | [Ver GuÃ­a](../.agent/workflows/cierre-operativo.md) |
| **Code Review** | `code-review` | Antes de merge o deploy | [Ver GuÃ­a](../.agent/workflows/code-review.md) |
| **Desarrollador de profundidad** | `desarrollador-profundidad` | Producto parece incompleto o superficial | [Ver GuÃ­a](../.agent/workflows/desarrollador-profundidad.md) |
| **Higiene de contexto** | `higiene-contexto` | Se detecta ruido, duplicidad o documentos largos sin accion | [Ver GuÃ­a](../.agent/workflows/higiene-contexto.md) |
| **Implementacion quirurgica** | `implementacion-quirurgica` | Se pide desglose de implementacion paso a paso | [Ver GuÃ­a](../.agent/workflows/implementacion-quirurgica.md) |
| **Inicio de proyecto** | `inicio-proyecto` | Repo recien clonado con esqueleto base | [Ver GuÃ­a](../.agent/workflows/inicio-proyecto.md) |
| **Mr Problem Solver** | `mr-problem-solver` | Hay errores, caidas, regresiones o comportamiento inestable | [Ver GuÃ­a](../.agent/workflows/mr-problem-solver.md) |
| **Pre-lanzamiento** | `pre-release` | Antes de deploy a produccion o staging | [Ver GuÃ­a](../.agent/workflows/pre-release.md) |
| **QA y Pruebas** | `qa-testing` | Feature nueva que necesita cobertura de tests | [Ver GuÃ­a](../.agent/workflows/qa-testing.md) |
| **Retrospectiva** | `retrospectiva` | Al cerrar un hito, fase o sprint relevante | [Ver GuÃ­a](../.agent/workflows/retrospectiva.md) |
| **Spike de investigacion** | `spike-investigacion` | Se necesita elegir entre varias tecnologias o librerias | [Ver GuÃ­a](../.agent/workflows/spike-investigacion.md) |

---

## Directiva de Uso Recomendado

1. **Definir Alcance:** Determina quÃ© cambio o feature vas a acometer.
2. **Seleccionar el Workflow:** Consulta la tabla anterior y dirÃ­gete a [Workflow Dispatch](../.agent/rules/workflow-dispatch.md) para alinearte con las topologÃ­as de Swarm recomendadas.
3. **Ejecutar e Integrar:** Genera la salida estructurada solicitada por el workflow seleccionado.
4. **Cierre HigiÃ©nico:** Finaliza siempre la sesiÃ³n utilizando la secuencia del workflow de [Cierre Operativo](../.agent/workflows/cierre-operativo.md).