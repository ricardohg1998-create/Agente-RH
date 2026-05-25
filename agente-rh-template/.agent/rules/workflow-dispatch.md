---
id: workflow-dispatch
name: Workflow Dispatch
activation: model-decision
version: 2.0.0
---

# Workflow Dispatch Rule

## Objetivo

Seleccionar workflow correcto y mantener salida accionable.

## Mapa de workflows

<!-- GENERATED:WORKFLOW-MAP:START -->
- `Autista cafeinado` (`autista-cafeinado`): Revision obsesiva, hiper-detallada y profunda del proyecto con critica constructiva despiadada y un Implementation Plan completo de mejoras.
- `Buscar skills` (`buscar-skills`): Seleccionar e instalar el conjunto minimo util de skills para el stack real del proyecto, sin ruido ni redundancias.
- `Cierre operativo` (`cierre-operativo`): Estandarizar el cierre de tarea para dejar estado verificable, handoff claro y cero ambiguedad operativa.
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
- Usar `Cierre operativo` (`cierre-operativo`) cuando: Al terminar una tarea tecnica o documental.
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

## Prioridad y desempate

- Incidentes siempre priorizan `mr-problem-solver`, aunque exista solicitud secundaria de auditoria.
- Si hay empate entre `desarrollador-profundidad` e `implementacion-quirurgica`:
  - usar `desarrollador-profundidad` para detectar huecos funcionales.
  - usar `implementacion-quirurgica` para secuenciar ejecucion tecnica.
- `autista-cafeinado` queda como auditoria amplia, no como triage primario.

## Politica de profundidad de memoria

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

## Output minimo

Cada workflow debe producir:

- diagnostico
- problemas priorizados
- plan de implementacion accionable
- riesgos y dudas abiertas

## Sincronizacion del brain

Tras ejecutar workflow, actualizar:

- `brain/now.md`
- `brain/current-state.md`
- `brain/stack.md` (si aplica)
- `brain/deep-summary.md` (obligatorio si cambia cualquier archivo de `deepLayer.files`)
- `brain/workflows-index.md` (si cambia criterio o alcance)

## Topologías de Swarm Recomendadas (Swarm Core v2.0)

El despachador, al seleccionar un workflow, sugerirá e instanciará una de las siguientes **Topologías de Enjambre** para maximizar la velocidad local en Antigravity Desktop 2.0:

### A. Topología de Auditoría (Investigación Intensiva)
* **Workflows**: `autista-cafeinado`, `spike-investigacion`, `code-review`.
* **Especialistas**: `CodebaseResearcher` (1 o más instancias en paralelo en `inherit`) + `CleanlinessGuardian` (secuencial terminal).
* **Flujo**: El Orquestador Principal delega la exploración densa y búsquedas a los investigadores y consolida el reporte final.

### B. Topología de Desarrollo (Feature Sprint)
* **Workflows**: `implementacion-quirurgica`, `qa-testing`, `desarrollador-profundidad`.
* **Especialistas**: `FeatureDeveloper` (en `share` o `branch`) + `QASpecialist` (en `share` en paralelo) + `CleanlinessGuardian` (en `inherit` secuencial al final).
* **Flujo**: Desarrollo y testing ocurren de forma asíncrona y paralela en sandbox. El Orquestador valida diffs e integra al final.

### C. Topología de Cierre y Mantenimiento
* **Workflows**: `cierre-operativo`, `higiene-contexto`, `retrospectiva`.
* **Especialistas**: `CleanlinessGuardian` (en `inherit` secuencial).
* **Flujo**: El Orquestador Principal delega el 100% de la limpieza física y actualización documental al guardián, quien ejecuta checks locales en background.

## Cadenas predefinidas

Secuencias de workflows que se complementan naturalmente. Al completar un workflow, sugerir el siguiente paso de la cadena si aplica.

### Cadena de auditoria completa
1. `autista-cafeinado` -> detectar problemas
2. `implementacion-quirurgica` -> planificar correcciones
3. (ejecucion del plan)
4. `code-review` -> validar correcciones
5. `cierre-operativo` -> cerrar y documentar

### Cadena de feature nueva
1. `implementacion-quirurgica` -> planificar
2. (ejecucion del plan)
3. `desarrollador-profundidad` -> detectar huecos UX
4. `code-review` -> validar calidad
5. `cierre-operativo` -> cerrar

### Cadena de inicio de proyecto
1. `inicio-proyecto` -> bootstrap
2. `buscar-skills` -> equipar agente
3. `implementacion-quirurgica` -> primer sprint

### Cadena de release
1. `qa-testing` -> validar cobertura
2. `code-review` -> revision final
3. `pre-release` -> checklist pre-deploy
4. (deploy)
5. `cierre-operativo` -> documentar release

### Cadena de cierre de ciclo
1. `retrospectiva` -> analizar que funciono y que no
2. `higiene-contexto` -> limpiar ruido detectado
3. `cierre-operativo` -> cerrar y documentar

## Senales de dispatch

Sistema de senales para seleccion automatica de workflow con mayor precision. Cada workflow tiene senales positivas (activar), anti-senales (no activar) y prioridad base.

### autista-cafeinado
- **Senales**: "revision profunda", "auditoria", "calidad general", "antes de release", "algo no huele bien", "critica honesta", "evaluacion completa", "analisis exhaustivo"
- **Anti-senales**: "arregla este bug", "implementa esto", "cambia el color", "pon un boton"
- **Prioridad base**: 3 (se eleva a 5 si se menciona "release" o "produccion")

### code-review
- **Senales**: "revisa el codigo", "security review", "busca credenciales", "antes de merge", "review", "tokens expuestos", "vulnerabilidades"
- **Anti-senales**: "diseno UX", "arquitectura general", "nueva feature"
- **Prioridad base**: 4 (se eleva a 5 si se menciona "seguridad", "credentials", "deploy")

### desarrollador-profundidad
- **Senales**: "esto parece incompleto", "botones que no hacen nada", "falta profundidad", "superficial", "completar producto", "estados vacios"
- **Anti-senales**: "bug en produccion", "error critico", "revision de codigo"
- **Prioridad base**: 3

### mr-problem-solver
- **Senales**: "error", "no funciona", "crash", "se rompio", "regresion", "fallo", "caido", "bug", "500", "exception"
- **Anti-senales**: "mejora", "refactor", "nuevo feature", "revision general"
- **Prioridad base**: 5 (siempre maxima ante incidente)

### implementacion-quirurgica
- **Senales**: "implementa esto", "plan de ejecucion", "paso a paso", "como hago", "desglose tecnico", "secuencia de trabajo"
- **Anti-senales**: "que esta mal", "audita", "revisa el codigo"
- **Prioridad base**: 4

### cierre-operativo
- **Senales**: "he terminado", "cierra la tarea", "handoff", "antes de commit", "fin de sesion", "cerrar"
- **Anti-senales**: "empezar", "investigar", "auditar"
- **Prioridad base**: 3

### higiene-contexto
- **Senales**: "mucho ruido", "documentos largos", "duplicados", "limpiar contexto", "deriva documental", "brain desordenado"
- **Anti-senales**: "implementar feature", "arreglar bug", "deploy"
- **Prioridad base**: 2

### inicio-proyecto
- **Senales**: "proyecto nuevo", "arrancar", "inicializar", "bootstrap", "repo recien clonado", "empezar de cero"
- **Anti-senales**: "proyecto existente", "ya tengo codigo", "corregir"
- **Prioridad base**: 4

### buscar-skills
- **Senales**: "que skills necesito", "instalar skills", "equipar agente", "stack nuevo", "skills solapadas"
- **Anti-senales**: "codigo", "bug", "feature", "deploy"
- **Prioridad base**: 2

### retrospectiva
- **Senales**: "que aprendimos", "que funciono", "que fallo", "retrospectiva", "fin de sprint", "cierre de ciclo", "balance"
- **Anti-senales**: "implementar", "arreglar", "deploy", "empezar"
- **Prioridad base**: 2

### spike-investigacion
- **Senales**: "investigar", "evaluar alternativas", "que tecnologia usar", "PoC", "comparar librerias", "merece la pena", "spike"
- **Anti-senales**: "implementar ya", "arreglar bug", "deploy"
- **Prioridad base**: 3

### qa-testing
- **Senales**: "tests", "testing", "cobertura", "pruebas", "TDD", "regresion", "quality assurance", "testear"
- **Anti-senales**: "deploy", "diseno", "investigar"
- **Prioridad base**: 3

### pre-release
- **Senales**: "deploy", "produccion", "release", "lanzar", "staging", "pre-deploy", "checklist", "listo para subir"
- **Anti-senales**: "investigar", "empezar proyecto", "retrospectiva"
- **Prioridad base**: 4 (se eleva a 5 si se menciona "produccion" o "staging")
