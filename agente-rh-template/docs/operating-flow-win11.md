# Flujo diario en Antigravity Desktop (Win11)

## Objetivo

Tener un flujo estable para trabajar, validar y confirmar cambios sin friccion innecesaria.

## Secuencia recomendada

1. Abrir workspace en Antigravity Desktop.
2. Revisar `brain/now.md`, `brain/current-state.md`, `brain/stack.md` y `brain/deep-summary.md`.
3. Ejecutar tarea con workflow adecuado.
4. Actualizar capa rapida del cerebro si hubo cambio relevante.
5. Si se modifico cualquier archivo de memoria profunda, actualizar `brain/deep-summary.md` en la misma tarea.
6. Ejecutar:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1
```

7. Confirmar cambios con commit.

## Si el commit se bloquea

- Revisa salida de `run-checks`.
- Corrige `CRITICAL` primero.
- Los `WARN` de contexto no bloquean commit, pero deben tratarse pronto.

## Rutina corta de cierre

- `brain/now.md` actualizado.
- `brain/current-state.md` actualizado.
- `brain/deep-summary.md` sincronizado (si hubo cambios profundos).
- `brain/changelog.md` actualizado si aplica.
- Checks en verde o warnings entendidos.

## Coexistencia con artefactos de Antigravity

Antigravity Desktop genera sus propios artefactos de sesion (`task.md`, `implementation_plan.md`, `walkthrough.md`) en `~/.gemini/antigravity/brain/<conversation-id>/`. Esto no entra en conflicto con `brain/` del repo.

- `brain/` del repo = **memoria persistente del proyecto** (sobrevive entre conversaciones y sesiones).
- Artefactos de Antigravity = **memoria de conversacion** (efimera, ligada a una sesion de trabajo).

**Regla de cierre**: al terminar una sesion importante, migrar conclusiones relevantes de Antigravity hacia `brain/` del repo para que no se pierdan entre sesiones.
