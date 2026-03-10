---
id: implementacion-quirurgica
name: Implementacion quirurgica
version: 1.0.0
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
4. Descomponer en unidades atomicas por dependencia real.
5. Definir interfaces, contratos y datos que cambian.
6. Detectar riesgos por paso y mitigaciones.
7. Definir verificacion tecnica por cada bloque.
8. Emitir plan de implementacion secuenciado.

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

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/architecture.md`, `brain/backlog.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/backlog.md`, `brain/open-questions.md`, `brain/changelog.md`.

