---
id: workflow-dispatch
name: Workflow Dispatch
activation: model-decision
version: 1.2.0
---

# Workflow Dispatch Rule

## Goal

Seleccionar workflow correcto y mantener salida accionable.

## Workflow map

<!-- GENERATED:WORKFLOW-MAP:START -->
- `Autista cafeinado` (`autista-cafeinado`): Ejecutar una revision extrema, hipercritica y util del proyecto o modulo, con foco en defectos, deuda y coherencia de producto/arquitectura.
- `Buscar skills` (`buscar-skills`): Seleccionar e instalar el conjunto minimo util de skills para el stack real del proyecto, sin ruido ni redundancias.
- `Cierre operativo` (`cierre-operativo`): Estandarizar el cierre de tarea para dejar estado verificable, handoff claro y cero ambiguedad operativa.
- `Desarrollador de profundidad` (`desarrollador-profundidad`): Detectar falta de profundidad real en UX, flujos, rutas, contenido funcional y propuesta de valor.
- `Higiene de contexto` (`higiene-contexto`): Reducir deriva documental y consumo innecesario de contexto manteniendo la memoria operativa util y compacta.
- `Implementacion quirurgica` (`implementacion-quirurgica`): Transformar un objetivo en un plan tecnico atomico, ejecutable y verificable, sin saltos de complejidad.
- `Inicio de proyecto` (`inicio-proyecto`): Guiar desde repo clonado hasta proyecto inicializado y listo para desarrollar, con estado verificable y cerebro actualizado.
- `Mr Problem Solver` (`mr-problem-solver`): Resolver incidentes de forma sistematica: del sintoma a la causa raiz, con contencion y validacion.
<!-- GENERATED:WORKFLOW-MAP:END -->

## Dispatch criteria

<!-- GENERATED:WORKFLOW-DISPATCH:START -->
- Usar `Autista cafeinado` (`autista-cafeinado`) cuando: Antes de release relevante.
- Usar `Buscar skills` (`buscar-skills`) cuando: Inicio de proyecto nuevo.
- Usar `Cierre operativo` (`cierre-operativo`) cuando: Al terminar una tarea tecnica o documental.
- Usar `Desarrollador de profundidad` (`desarrollador-profundidad`) cuando: Producto parece incompleto o superficial.
- Usar `Higiene de contexto` (`higiene-contexto`) cuando: Se detecta ruido, duplicidad o documentos largos sin accion.
- Usar `Implementacion quirurgica` (`implementacion-quirurgica`) cuando: Se pide desglose de implementacion paso a paso.
- Usar `Inicio de proyecto` (`inicio-proyecto`) cuando: Repo recien clonado con esqueleto base.
- Usar `Mr Problem Solver` (`mr-problem-solver`) cuando: Hay errores, caidas, regresiones o comportamiento inestable.
<!-- GENERATED:WORKFLOW-DISPATCH:END -->

## Priority and tie-break

- Incidentes siempre priorizan `mr-problem-solver`, aunque exista solicitud secundaria de auditoria.
- Si hay empate entre `desarrollador-profundidad` e `implementacion-quirurgica`:
  - usar `desarrollador-profundidad` para detectar huecos funcionales.
  - usar `implementacion-quirurgica` para secuenciar ejecucion tecnica.
- `autista-cafeinado` queda como auditoria amplia, no como triage primario.

## Memory depth policy

- Siempre leer capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
- Lectura profunda alta desde inicio para:
  - `mr-problem-solver`
  - `autista-cafeinado`
  - `higiene-contexto`
- Lectura profunda selectiva por gatillo para:
  - `implementacion-quirurgica`
  - `desarrollador-profundidad`
  - `cierre-operativo`
  - `buscar-skills`
  - `inicio-proyecto`
- Gatillos de expansion profunda:
  - riesgo/incidente alto
  - contradiccion entre fuentes
  - cambio estructural de alcance o arquitectura
  - evidencia insuficiente para decidir

## Output minimum

Cada workflow debe producir:

- diagnostico
- problemas priorizados
- plan de implementacion accionable
- riesgos y dudas abiertas

## Brain sync

Tras ejecutar workflow, actualizar:

- `brain/now.md`
- `brain/current-state.md`
- `brain/stack.md` (si aplica)
- `brain/deep-summary.md` (obligatorio si cambia cualquier archivo de `deepLayer.files`)
- `brain/workflows-index.md` (si cambia criterio o alcance)

## Context budget

Ademas del workflow elegido, aplicar siempre la regla `context-budget` para mantener salida concisa y evitar deriva documental.




