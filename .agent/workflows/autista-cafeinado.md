---
id: autista-cafeinado
name: Autista cafeinado
version: 1.0.0
mode: planning
---

# Workflow: Autista cafeinado

## Proposito

Ejecutar una revision extrema, hipercritica y util del proyecto o modulo, con foco en defectos, deuda y coherencia de producto/arquitectura.

## Cuando usarlo

- Antes de release relevante.
- Proyecto con sintomas de fragilidad o deuda acumulada.
- Necesidad de auditoria profunda con plan de mejora por fases.

## Input esperado

- Alcance concreto (repo completo, servicio, modulo, feature).
- Objetivo de calidad.
- Restricciones (tiempo, riesgo, compatibilidad).

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Por ser auditoria amplia, expandir desde inicio a capa profunda relevante.
- Priorizar `brain/architecture.md`, `brain/technical-debt.md` y `brain/pitfalls-and-errors.md`.

## Pasos internos

1. Leer capa rapida y expandir a capa profunda relevante.
2. Hacer lectura global de arquitectura y convenciones.
3. Detectar hallazgos criticos, importantes y micromejoras.
4. Buscar incoherencias tecnicas y de producto.
5. Cuantificar deuda y riesgo operativo.
6. Proponer mejoras priorizadas por impacto/esfuerzo.
7. Definir plan de implementacion por fases.

## Output obligatorio

1. Alcance revisado.
2. Lectura global del estado.
3. Hallazgos criticos.
4. Hallazgos importantes.
5. Detalles finos y micromejoras.
6. Incoherencias tecnicas o de producto.
7. Deuda detectada.
8. Oportunidades de mejora profundas.
9. Propuesta priorizada.
10. Plan por fases.

## Criterios de calidad

- Cada hallazgo con evidencia y accion concreta.
- Priorizacion defendible tecnicamente.
- Critica constructiva sin ambiguedad.

## Brain read/write

- Leer: `brain/current-state.md`, `brain/architecture.md`, `brain/technical-debt.md`, `brain/pitfalls-and-errors.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/technical-debt.md`, `brain/backlog.md`, `brain/changelog.md`.


