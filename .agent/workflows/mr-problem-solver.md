---
id: mr-problem-solver
name: Mr Problem Solver
description: Resolver incidentes de forma sistematica, del sintoma a la causa raiz, con contencion y validacion.
version: 1.1.0
modes: [planning, execution]
---

# Workflow: Mr Problem Solver

## Proposito

Resolver incidentes de forma sistematica: del sintoma a la causa raiz, con contencion y validacion.

## Cuando usarlo

- Hay errores, caidas, regresiones o comportamiento inestable.
- Se necesita priorizar por severidad e impacto real.
- Hace falta plan de fix con validacion y seguimiento.

## Input esperado

- Sintoma observado y entorno afectado.
- Momento del incidente y cambios recientes conocidos.
- Impacto en usuario/negocio.
- Restricciones de disponibilidad o despliegue.

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Por criticidad de incidente, ampliar pronto a capa profunda relevante.
- Priorizar `brain/pitfalls-and-errors.md`, `brain/technical-debt.md` y `brain/changelog.md`.

## Pasos internos

1. Leer capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
2. Expandir a capa profunda relevante para acelerar triage.
3. Clasificar severidad e impacto del incidente.
4. Definir estrategia minima de reproduccion.
5. Recoger evidencia tecnica y delimitar alcance.
6. Formular hipotesis de causa raiz y priorizarlas.
7. Proponer contencion inmediata y fix estructural.
8. Definir validacion, monitoreo y criterios de cierre.

## Output obligatorio

1. Resumen del incidente.
2. Severidad y alcance del impacto.
3. Evidencia y sintomas observados.
4. Hipotesis priorizadas.
5. Causa raiz probable o confirmada.
6. Contencion inmediata recomendada.
7. Fix propuesto con orden de ejecucion.
8. Plan de validacion post-fix.
9. Riesgos residuales y monitoreo.
10. Dudas abiertas.

## Criterios de calidad

- No confundir sintoma con causa raiz.
- Toda accion debe estar justificada por evidencia.
- Incluir contencion y solucion de fondo.

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/pitfalls-and-errors.md`, `brain/technical-debt.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/pitfalls-and-errors.md`, `brain/backlog.md`, `brain/changelog.md`.

