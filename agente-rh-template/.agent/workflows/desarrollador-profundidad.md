---
id: desarrollador-profundidad
name: Desarrollador de profundidad
version: 1.0.0
mode: planning
---

# Workflow: Desarrollador de profundidad

## Proposito

Detectar falta de profundidad real en UX, flujos, rutas, contenido funcional y propuesta de valor.

## Cuando usarlo

- Producto parece incompleto o superficial.
- Hay CTAs sin destino o pantallas no rematadas.
- Se requiere plan de implementacion detallado y priorizado.

## Input esperado

- Alcance (todo el proyecto o modulo).
- Objetivo de negocio o UX.
- Restricciones tecnicas y temporales.
- Estado actual (si existe en `brain/current-state.md`).

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a capa profunda cuando falte contexto de arquitectura/producto o haya contradicciones.
- Si el alcance es pequeno y claro, mantener lectura profunda selectiva.

## Pasos internos

1. Leer capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
2. Expandir a capa profunda solo si hay gatillos de contexto.
3. Mapear areas funcionales y rutas.
4. Detectar huecos de continuidad (CTA, estados vacios, navegacion, backends insinuados).
5. Estimar impacto por hueco (UX, negocio, arquitectura, mantenimiento).
6. Definir solucion concreta y dependencias.
7. Priorizar quick wins vs cambios estructurales.
8. Emitir Implementation Plan completo.

## Output obligatorio

1. Diagnostico general.
2. Mapa de zonas superficiales o rotas.
3. Problemas por area.
4. Impacto por problema.
5. Propuesta concreta de mejora.
6. Orden recomendado de implementacion.
7. Dependencias.
8. Quick wins.
9. Mejoras estructurales.
10. Riesgos y dudas abiertas.

## Criterios de calidad

- Sin feedback superficial.
- Cada problema debe incluir por que importa y como resolverlo.
- Priorizacion accionable con dependencias reales.

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/project-overview.md`, `brain/architecture.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/backlog.md`, `brain/open-questions.md`, `brain/changelog.md`.

