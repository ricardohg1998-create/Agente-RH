---
id: workflow-dispatch
name: Workflow Dispatch
activation: model-decision
version: 2.1.0
---

# Workflow Dispatch Rule

## Objetivo

Servir como catalogo de referencia para elegir workflows cuando aporten valor real. Esta regla no obliga a ejecutar workflows en tareas pequenas ni a producir salidas largas por defecto.

## Mapa de workflows

<!-- GENERATED:WORKFLOW-MAP:START -->
- `Autista cafeinado` (`autista-cafeinado`): Revision obsesiva, hiper-detallada y profunda del proyecto con critica constructiva despiadada y un Implementation Plan completo de mejoras.
- `Buscar skills` (`buscar-skills`): Seleccionar e instalar el conjunto minimo util de skills para el stack real del proyecto, sin ruido ni redundancias.
- `Cierre operativo` (`cierre-operativo`): Cerrar tareas con cambios reales dejando estado verificable, memoria util y handoff claro.
- `Code Review` (`code-review`): Revision tecnica de codigo desde un archivo hasta el repo completo, con foco en seguridad, credenciales, APIs y auth.
- `Desarrollador de profundidad` (`desarrollador-profundidad`): Detector exhaustivo de falta de profundidad en UX, flujos, contenido y funcionalidad, con Implementation Plan completisimo.
- `Higiene de contexto` (`higiene-contexto`): Reducir deriva documental y consumo innecesario de contexto manteniendo la memoria operativa util y compacta.
- `Implementacion quirurgica` (`implementacion-quirurgica`): Transformar un objetivo en un plan tecnico atomico, ejecutable y verificable, sin saltos de complejidad.
- `Inicio de proyecto` (`inicio-proyecto`): Guiar desde repo clonado hasta proyecto inicializado y listo para desarrollar, con estado verificable y cerebro actualizado.
- `Mr Problem Solver` (`mr-problem-solver`): Resolver incidentes de forma sistematica, del sintoma a la causa raiz, con contencion y validacion.
- `Pre-lanzamiento` (`pre-release`): Checklist exhaustivo de validacion antes de deploy a produccion, combinando checks automaticos, security review y smoke test visual.
- `QA y Pruebas` (`qa-testing`): Disenar, implementar y ejecutar pruebas sistematicas para garantizar calidad de codigo y prevenir regresiones.
- `Retrospectiva` (`retrospectiva`): Analizar que funciono, que fallo y que mejorar al cierre de un ciclo de trabajo.
- `Spike de investigacion` (`spike-investigacion`): Explorar tecnologias, evaluar alternativas y tomar decisiones tecnicas informadas antes de comprometerse con una implementacion.
<!-- GENERATED:WORKFLOW-MAP:END -->

## Criterios de dispatch

<!-- GENERATED:WORKFLOW-DISPATCH:START -->
- Usar `Autista cafeinado` (`autista-cafeinado`) cuando: Antes de release relevante.
- Usar `Buscar skills` (`buscar-skills`) cuando: Inicio de proyecto nuevo.
- Usar `Cierre operativo` (`cierre-operativo`) cuando: Al terminar una tarea tecnica o documental con cambios en archivos.
- Usar `Code Review` (`code-review`) cuando: Antes de merge o deploy.
- Usar `Desarrollador de profundidad` (`desarrollador-profundidad`) cuando: Producto parece incompleto o superficial.
- Usar `Higiene de contexto` (`higiene-contexto`) cuando: Se detecta ruido, duplicidad o documentos largos sin accion.
- Usar `Implementacion quirurgica` (`implementacion-quirurgica`) cuando: Se pide desglose de implementacion paso a paso.
- Usar `Inicio de proyecto` (`inicio-proyecto`) cuando: Repo recien clonado con esqueleto base.
- Usar `Mr Problem Solver` (`mr-problem-solver`) cuando: Hay errores, caidas, regresiones o comportamiento inestable.
- Usar `Pre-lanzamiento` (`pre-release`) cuando: Antes de deploy a produccion o staging.
- Usar `QA y Pruebas` (`qa-testing`) cuando: Feature nueva que necesita cobertura de tests.
- Usar `Retrospectiva` (`retrospectiva`) cuando: Al cerrar un hito, fase o sprint relevante.
- Usar `Spike de investigacion` (`spike-investigacion`) cuando: Se necesita elegir entre varias tecnologias o librerias.
<!-- GENERATED:WORKFLOW-DISPATCH:END -->

## Activacion

- Ejecuta un workflow completo solo si el usuario lo pide por nombre o si el caso encaja claramente con sus senales.
- Para preguntas, auditorias ligeras, cambios pequenos o lectura puntual, responde directamente.
- No encadenes workflows automaticamente. Sugiere otro workflow solo si aporta un siguiente paso evidente y no alarga la respuesta.
- Si activas un workflow, adapta su salida al tamano real de la tarea.

## Memoria y artefactos

- Leer capa rapida antes de workflows con cambios, incidentes o decisiones persistentes.
- No crear `implementation_plan.md`, `task.md` ni `walkthrough.md` para consultas o auditorias de solo lectura.
- Actualizar `brain/` solo si hubo cambios relevantes, cambio de alcance, bloqueo/desbloqueo o instruccion persistente.

## Swarm

- Las topologias de swarm son opcionales y solo para trabajo amplio o paralelo.
- Resolver directamente tareas sencillas aunque coincidan con una senal de workflow.
- Si se usa swarm, mantener un unico orquestador y payloads acotados.

## Senales de dispatch

- `mr-problem-solver`: errores, caidas, regresiones, excepciones, fallos reproducibles.
- `code-review`: revision de codigo, seguridad, credenciales, auth, merge o deploy.
- `autista-cafeinado`: auditoria amplia o revision profunda explicitamente solicitada.
- `desarrollador-profundidad`: producto superficial, flujos incompletos, estados vacios, UX pobre.
- `implementacion-quirurgica`: desglose tecnico, plan de ejecucion o secuencia de implementacion.
- `higiene-contexto`: ruido documental, duplicidad, brain desordenado, exceso de contexto.
- `cierre-operativo`: cierre pedido, handoff, commit, release o final de sesion con cambios.
- `buscar-skills`: seleccion o instalacion de skills.
- `inicio-proyecto`: repo recien clonado o bootstrap inicial.
- `qa-testing`: pruebas, cobertura o regresion.
- `pre-release`: release, staging, produccion o checklist pre-deploy.
- `retrospectiva`: cierre de ciclo o aprendizaje.
- `spike-investigacion`: comparativas, PoC o decision tecnologica.
