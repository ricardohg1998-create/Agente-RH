---
id: implementacion-quirurgica
name: Implementacion quirurgica
description: Transformar un objetivo en un plan tecnico atomico, ejecutable y verificable, sin saltos de complejidad.
version: 1.1.0
modes: [planning, execution]
---

# Workflow: Implementacion quirurgica

## Proposito

Transformar un objetivo en un plan tecnico atomico, ejecutable y verificable, sin saltos de complejidad.

## Cuando usarlo

- Se pide desglose de implementacion paso a paso.
- Hay dependencias tecnicas y riesgo de orden incorrecto.
- Se requiere plan con pruebas y criterios de aceptacion por bloque.

## Input esperado

- Objetivo funcional o tecnico concreto.
- Alcance incluido/excluido.
- Restricciones (tiempo, compatibilidad, deuda, riesgo).
- Estado actual disponible en `brain/current-state.md`.

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a capa profunda por gatillo: dependencia no clara, impacto arquitectonico o evidencia insuficiente.
- Mantener enfoque en archivos profundos directamente implicados en el objetivo.

## Pasos internos

1. Leer capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
2. Expandir a capa profunda solo si hay gatillos de contexto.
3. Definir alcance operativo y criterio de exito.
4. Aislar entorno: Ejecutar `git checkout -b feature/[nombre-tarea]` para asilar el riesgo espacialmente.
5. Descomponer en unidades atomicas por dependencia real.
6. Definir interfaces, contratos y datos que cambian.
7. Detectar riesgos por paso y mitigaciones.
8. Definir verificacion tecnica por cada bloque.
9. Emitir plan de implementacion secuenciado y ejecutarlo.
10. Integrar: Al validar el exito, hacer checkout a main, merge y destruir la rama efimera (`git branch -D`).

## Herramientas sugeridas

- **Mapear estructura afectada**: `list_dir` para entender la topologia de archivos del alcance y sus dependencias.
- **Inspeccionar contratos e interfaces**: `view_file` para revisar tipos, interfaces, schemas y puntos de integracion que cambiaran.
- **Buscar dependencias inversas**: `grep_search` para encontrar todos los consumidores de la funcion/modulo que se va a modificar.
- **Validar por paso**: `run_command` para ejecutar tests/build tras cada bloque atomico y verificar que no se rompe nada.
- **Investigar patrones**: `search_web` cuando la implementacion requiera una decision tecnica no obvia.

## Output obligatorio

1. Objetivo y alcance confirmado.
2. Supuestos y restricciones activas.
3. Secuencia atomica de trabajo.
4. Dependencias tecnicas y orden recomendado.
5. Riesgos por fase y mitigaciones.
6. Plan de pruebas por fase.
7. Criterios de aceptacion verificables.
8. Dudas abiertas.

## Criterios de calidad

- Cada paso debe ser ejecutable sin decisiones ocultas.
- El orden debe ser defendible por dependencias reales.
- La verificacion debe ser objetiva y repetible.

## Composicion

- **Suele preceder a**: ejecucion del plan, `code-review`, `qa-testing`.
- **Suele seguir a**: `autista-cafeinado`, `desarrollador-profundidad`, `mr-problem-solver`, `spike-investigacion`.
- **Workflow sugerido al completar**: `code-review` (tras ejecutar el plan) o `qa-testing` (si incluye funcionalidad nueva).

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/architecture.md`, `brain/backlog.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/backlog.md`, `brain/open-questions.md`, `brain/changelog.md`.

