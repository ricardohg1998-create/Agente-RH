# Prompts eficientes y control de contexto

## Principios

- Pide una sola cosa por turno cuando sea posible.
- Da alcance explicito (archivo, modulo o workflow).
- Evita repetir contexto ya presente en `brain/`.
- Prefiere referencias concretas a rutas en vez de texto largo.

## Patrones cortos utiles

## Desarrollador de profundidad (`desarrollador-profundidad`)

"Aplica el workflow Desarrollador de profundidad (`desarrollador-profundidad`) al modulo X. Devuelveme diagnostico, impacto y plan por fases."

## Autista cafeinado (`autista-cafeinado`)

"Ejecuta el workflow Autista cafeinado (`autista-cafeinado`) sobre X y prioriza hallazgos criticos e importantes."

## Buscar skills (`buscar-skills`)

"Ejecuta el workflow Buscar skills (`buscar-skills`) para stack X, con lista core, opcionales y descartes justificados."

## Implementacion quirurgica (`implementacion-quirurgica`)

"Desglosame la implementacion tecnica de X con el workflow Implementacion quirurgica (`implementacion-quirurgica`), incluyendo dependencias, riesgos y plan de pruebas por fase."

## Mr Problem Solver (`mr-problem-solver`)

"Tengo una caida en X; aplica el workflow Mr Problem Solver (`mr-problem-solver`) y devuelve severidad, hipotesis, causa raiz probable y plan de fix."

## Higiene de contexto (`higiene-contexto`)

"Ejecuta Higiene de contexto (`higiene-contexto`) sobre `brain/` y `docs/` con propuestas de consolidacion y archivado/borrado justificadas."

## Cierre operativo (`cierre-operativo`)

"Cierra esta tarea con el workflow Cierre operativo (`cierre-operativo`) y entregame estado final, pendientes, riesgos residuales y handoff."

## Inicio de proyecto (`inicio-proyecto`)

"Arranca proyecto nuevo con el workflow Inicio de proyecto (`inicio-proyecto`). Stack candidato: X. Vision: Y. Primer entregable: Z."

## Reglas anti-deriva

- Si un documento crece mucho, resumir y mover detalle a archivo profundo.
- No duplicar el mismo parrafo largo en varios archivos.
- Mantener `now.md`, `current-state.md`, `stack.md` y `deep-summary.md` cortos y accionables.
- Si cambias cualquier archivo profundo, actualiza `deep-summary.md` en la misma tarea.

## Check tecnico

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-context-budget.ps1
```
