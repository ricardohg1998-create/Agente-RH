---
id: retrospectiva
name: Retrospectiva
description: Analizar que funciono, que fallo y que mejorar al cierre de un ciclo de trabajo.
version: 1.0.0
modes: [planning, execution]
---

# Workflow: Retrospectiva

## Propósito

Analisis post-ciclo de trabajo: que funciono, que fallo, que cambiar. Diferente del `cierre-operativo` (que cierra una tarea puntual) â€” esto mira el panorama general de un sprint, fase o proyecto completo. Revisa el proceso, las herramientas, las decisiones tomadas y propone ajustes concretos para mejorar el siguiente ciclo.

## Cuándo usarlo

- Al cerrar un hito, fase o sprint relevante.
- Despues de un periodo de trabajo intenso con resultados mixtos.
- Cuando se quiere iterar el proceso de trabajo de forma consciente.
- Al terminar un proyecto o subproyecto completo.
- Periodicamente (mensual, trimestral) como habito de mejora continua.

## Input esperado

- Periodo o ciclo a analizar (fechas, hito, nombre del proyecto/fase).
- Objetivo original del ciclo.
- Percepcion general del resultado (fue bien, fue mal, mixto).
- Areas de interes especifico (opcional).

## Política de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a capa profunda: `brain/changelog.md`, `brain/milestones.md`, `brain/decisions.md`.
- Revisar session logs del periodo si existen (`brain/session_logs/`).

## Pasos internos

1. Leer capa rapida y expandir a changelog, milestones y decisions.
2. **Reconstruir timeline del ciclo**: que se hizo, en que orden, con que resultado, cuanto tiempo llevo.
3. **Identificar lo que funciono bien** (patrones a repetir):
   - Decisiones que ahorraron tiempo o evitaron problemas.
   - Herramientas o workflows que fueron utiles.
   - Procesos que dieron buen resultado.
4. **Identificar lo que fallo o fue ineficiente** (patrones a evitar):
   - Decisiones que causaron retrabajo o regresiones.
   - Bloqueos que podrian haberse evitado.
   - Procesos que fueron lentos, confusos o innecesarios.
   - Estimaciones que fallaron y por que.
5. **Identificar sorpresas** (positivas y negativas):
   - Lo que no se esperaba y funciono.
   - Lo que no se esperaba y fue un problema.
6. **Evaluar herramientas y workflows utilizados**:
   - Que workflows del repo se usaron y cuales no.
   - Que herramientas fueron utiles y cuales sobraron.
7. **Proponer ajustes concretos** al proceso/herramientas/workflows:
   - Cambios especificos, no genericos ("usar mas tests" NO, "anadir test de integracion para el modulo X antes de deploy" SI).
8. **Registrar lecciones aprendidas** en brain para futuras referencias.
9. **Analizar metricas de workflows** en `brain/workflow-metrics.md`: cuales se usaron, cuales no, cuales dieron buen resultado, y proponer ajustes a workflows subutilizados o ineficientes.

## Herramientas sugeridas

- **Revisar session logs**: `view_file` de archivos en `brain/session_logs/` para reconstruir la timeline del ciclo.
- **Auditar artifacts generados**: `list_dir` para ver que se creo, modifico o dejo pendiente.
- **Revisar changelog y decisiones**: `view_file` de `brain/changelog.md` y `brain/decisions.md` para trazar historial.
- **Buscar patrones en el trabajo**: `grep_search` en session logs buscando palabras como `error`, `revert`, `workaround`, `bloqueado` para detectar fricciones recurrentes.
- **Verificar estado de workflows**: `view_file` de `brain/workflow-metrics.md` para analizar datos de uso.

## Output obligatorio

1. **Resumen del ciclo**: que se propuso y que se logro.
2. **Lo que funciono** (repetir): lista concreta con evidencia.
3. **Lo que fallo** (evitar): lista concreta con causa raiz.
4. **Sorpresas**: positivas y negativas.
5. **Evaluacion de proceso y herramientas**.
6. **Ajustes propuestos** (accionables y especificos).
7. **Lecciones aprendidas** (destiladas, sin relleno).
8. **Metricas del ciclo** (si hay datos): tiempo real vs estimado, tareas completadas vs planificadas, incidentes, regresiones.

## Criterios de calidad

- **Honestidad sin drama**: identificar problemas reales sin exagerar ni minimizar.
- **Ajustes accionables**: cada propuesta debe ser especifica y ejecutable.
- **Balance**: incluir lo positivo y lo negativo â€” la retrospectiva no es solo buscar fallos.
- **Sin culpas**: foco en procesos y decisiones, no en personas.

## Composición

- **Suele preceder a**: `higiene-contexto`, ajustes de proceso.
- **Suele seguir a**: cierre de hito, sprint o proyecto; `cierre-operativo`.
- **Workflow sugerido al completar**: `higiene-contexto` (para limpiar lo que la retrospectiva identifique como ruido).

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/changelog.md`, `brain/milestones.md`, `brain/decisions.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/deep-summary.md`, `brain/decisions.md` (si se proponen cambios de proceso), `brain/changelog.md`.
