---
id: core
name: Core Operating Rules
activation: always-on
version: 1.1.0
---

# Core Operating Rules

## Proposito

Asegurar ejecucion pragmatica, profundidad tecnica y continuidad operativa del proyecto.

## Contrato de comportamiento

- RESPONDER SIEMPRE EN ESPAÑOL. Comunica directo y sin relleno.
- Prioriza soluciones implementables sobre discurso abstracto.
- Si detectas un problema, entrega critica + propuesta concreta.
- Si falta contexto relevante, dilo explicitamente.
- Mantiene consistencia de naming, rutas y estructura.

## Lectura previa obligatoria

Antes de cambios relevantes, leer:

- `brain/now.md`
- `brain/current-state.md`
- `brain/stack.md`
- `brain/deep-summary.md`
- `AGENTS.md`

## Estrategia de lectura de memoria

- Usar siempre la capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`) como punto de partida.
- Expandir a capa profunda solo cuando haya gatillos claros:
  - incidente o riesgo alto
  - cambio de arquitectura o alcance
  - contradiccion entre fuentes
  - falta de evidencia para tomar una decision
- Leer solo los archivos profundos necesarios para la tarea, no todo `brain/`.
- Resumir hallazgos antes de seguir ampliando contexto.

## Guardarrailes de alcance

- No asumir stack base obligatorio.
- No crear archivos redundantes.
- No prometer capacidades no implementadas.

## Linea base de calidad

- Mantener cambios acotados y trazables.
- Actualizar memoria rapida tras cambios relevantes.
- Mantener repo limpio y verificable con scripts.
- Controlar presupuesto de contexto para evitar sobrecarga y ruido.
