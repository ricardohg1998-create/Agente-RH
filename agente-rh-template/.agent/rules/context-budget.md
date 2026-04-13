---
id: context-budget
name: Context Budget
activation: always-on
version: 1.1.0
---

# Context Budget Rule

## Objetivo

Reducir deriva de contexto y consumo innecesario de tokens sin perder calidad tecnica.

## Politica operativa

- Leer primero la capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
- Expandir a capa profunda solo cuando sea necesario.
- Activar capa profunda con gatillos: incidente, riesgo alto, cambio de alcance/arquitectura o evidencia insuficiente.
- Cargar solo archivos profundos relevantes para el objetivo actual.
- Resumir antes de ampliar analisis.
- Evitar duplicar parrafos largos entre multiples documentos.
- Mantener prompts y salidas accionables, con minimo ruido.

## Cumplimiento

Usar checks locales:

- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-context-budget.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1`

## Modelo de severidad

- `WARN`: exceso de longitud en documentos no criticos.
- `CRITICAL`: exceso en quick layer o duplicacion fuerte de parrafos.

## Comportamiento en commits

- Los `CRITICAL` bloquean commit local mediante hook.
- Los `WARN` informan, pero no bloquean.
