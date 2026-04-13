---
id: autista-cafeinado
name: Autista cafeinado
description: Revision obsesiva, hiper-detallada y profunda del proyecto con critica constructiva despiadada y un Implementation Plan completo de mejoras.
version: 2.0.0
modes: [planning, execution]
---

# Workflow: Autista cafeinado

## Proposito

Ejecutar una revision obsesiva, hiper-detallada y profunda del proyecto (o de una parte especifica si se indica en el prompt). Funciona como lo haria un friki autista sobreexcitado de cafeina: analisis de altas capacidades que busca hasta el mas minimo detalle, critica constructiva despiadada pero util, y nada se le escapa. El objetivo final es generar un **Implementation Plan completo de mejoras** priorizado y accionable.

## Cuando usarlo

- Antes de release relevante.
- Proyecto con sintomas de fragilidad, deuda acumulada o falta de calidad.
- Necesidad de auditoria profunda con plan de mejora por fases.
- Sospecha de que "algo no huele bien" pero no se sabe exactamente que.
- Se quiere elevar la calidad general del proyecto de forma sistematica.

## Input esperado

- Alcance concreto: repo completo, servicio, modulo, feature o archivo (si no se especifica, se audita todo).
- Objetivo de calidad o area de foco preferente (opcional).
- Restricciones (tiempo, riesgo, compatibilidad).

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Por ser auditoria amplia, expandir desde inicio a capa profunda relevante.
- Priorizar `brain/architecture.md`, `brain/technical-debt.md` y `brain/pitfalls-and-errors.md`.

## Pasos internos

1. Leer capa rapida y expandir a capa profunda relevante.
2. **Mapear el alcance completo**: cada archivo, cada ruta, cada componente, cada flujo. No dejar nada sin revisar.
3. **Revision obsesiva por capas** (de lo macro a lo micro):
   - **Arquitectura**: estructura del proyecto, separacion de responsabilidades, patrones usados vs optimos.
   - **Codigo**: correctitud, edge cases, manejo de errores, anti-patrones, dead code, imports sin usar.
   - **UX/UI**: coherencia visual, estados faltantes, flujos incompletos, feedback al usuario.
   - **Datos**: modelos, validaciones, integridad, queries ineficientes, migraciones pendientes.
   - **Seguridad**: credenciales hardcodeadas, tokens expuestos, endpoints sin auth, inyecciones, CORS.
   - **Rendimiento**: cargas innecesarias, re-renders, assets sin optimizar, bundles pesados.
4. **Detectar inconsistencias tecnicas y de producto**: naming incoherente, patrones mixtos, convenciones rotas, comportamiento contradictorio.
5. **Caza de micro-detalles**: typos, TODOs abandonados, comentarios obsoletos, estilos huerfanos, logs de debug olvidados, configuraciones por defecto inseguras.
6. **Cuantificar deuda tecnica**: estimar impacto por cada elemento de deuda (bloquea, ralentiza, molesta, es cosmetico).
7. **Identificar oportunidades de mejora profundas**: no solo bugs, sino "esto podria ser mucho mejor si..." — mejoras de DX, automatizacion, simplificacion.
8. **Buscar incoherencias de producto**: features que se contradicen, flujos que no tienen sentido juntos, prioridades desalineadas.
9. **Priorizar por impacto/esfuerzo** con justificacion tecnica defendible.
10. **Generar Implementation Plan completo** por fases, accionable y secuenciado.

## Herramientas sugeridas

- **Mapeo de estructura**: `list_dir` para recorrer el arbol completo del proyecto y detectar archivos huerfanos, convenciones de naming rotas o carpetas sin sentido.
- **Deteccion de secrets y credenciales**: `grep_search` con patrones: `AKIA`, `sk-`, `ghp_`, `password\s*=`, `secret`, `token`, `apiKey`, archivos `.env` fuera de `.gitignore`.
- **Deteccion de dead code y deuda**: `grep_search` con `TODO`, `FIXME`, `HACK`, `XXX`, `console.log`, `debugger`, `// eslint-disable`.
- **Inspeccion de archivos concretos**: `view_file` para revisar logica, imports sin usar, complejidad ciclomatica y anti-patrones.
- **Validacion visual de UX/UI**: `browser_subagent` para navegar la app localmente y detectar estados rotos, layouts descuadrados, flujos incompletos.
- **Investigacion de buenas practicas**: `search_web` cuando se detecte un patron dudoso y haga falta contrastar con el estado del arte.
- **Ejecucion de checks**: `run_command` para ejecutar linters, tests, builds de produccion y scripts de higiene del repo.

## Output obligatorio

1. Alcance revisado (que se audito exactamente).
2. Lectura global del estado del proyecto/modulo.
3. **Hallazgos criticos** (con evidencia: archivo, linea, contexto, por que es critico).
4. **Hallazgos importantes** (con evidencia y justificacion de por que importa).
5. **Micro-detalles y mejoras finas** (typos, dead code, TODOs, etc.).
6. **Inconsistencias tecnicas y de producto** detectadas.
7. **Deuda tecnica cuantificada** (estimacion de impacto por item).
8. **Oportunidades de mejora profundas** (lo que podria ser mucho mejor).
9. **Propuesta priorizada** con justificacion tecnica.
10. **Implementation Plan completo por fases** (ENTREGABLE PRINCIPAL):
    - Descripcion detallada de cada cambio.
    - Archivos afectados.
    - Dependencias entre tareas.
    - Orden de ejecucion recomendado.
    - Criterios de aceptacion por fase.

## Criterios de calidad

- **Evidencia exacta**: cada hallazgo debe senalar archivo, linea y contexto. Si no puedes decir donde esta, no lo reportes.
- **Nada generico**: "el codigo podria mejorar" NO es un hallazgo valido. "La funcion X en archivo Y linea Z tiene un edge case sin manejar cuando el input es null" SI lo es.
- **Priorizacion defendible**: cada posicion en el ranking debe estar justificada tecnicamente.
- **Critica constructiva**: ser despiadado con los problemas, pero siempre proponer solucion concreta.
- **Implementation Plan ejecutable**: debe poder ejecutarse sin ambiguedad, sin preguntas pendientes, sin decisiones ocultas.

## Modos de operacion

### Modo archivo/componente (alcance < 5 archivos)
- Saltar pasos de mapeo global (paso 2).
- Lectura de memoria: solo quick layer.
- Output reducido: hallazgos + quick fixes, sin Implementation Plan por fases.
- Objetivo: feedback rapido y accionable.

### Modo modulo/feature (alcance 5-30 archivos)
- Mapeo del modulo y sus dependencias directas.
- Lectura de memoria: quick layer + `brain/architecture.md`.
- Output estandar completo.

### Modo repo completo (alcance > 30 archivos o sin especificar)
- Mapeo exhaustivo de toda la estructura.
- Lectura de memoria: quick + deep layer completo.
- Output completo con Implementation Plan por fases.
- Priorizacion por impacto/esfuerzo obligatoria.

## Composicion

- **Suele preceder a**: `implementacion-quirurgica`, `code-review`.
- **Suele seguir a**: solicitud directa del usuario o sospecha de fragilidad.
- **Workflow sugerido al completar**: `implementacion-quirurgica` (para planificar la correccion de los hallazgos).

## Brain read/write

- Leer: `brain/current-state.md`, `brain/architecture.md`, `brain/technical-debt.md`, `brain/pitfalls-and-errors.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/technical-debt.md`, `brain/backlog.md`, `brain/changelog.md`.
