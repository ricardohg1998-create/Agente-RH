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

Antigravity Desktop genera e interactúa con sus propios artefactos oficiales de sesión (`task.md`, `implementation_plan.md`, `walkthrough.md`) guardados físicamente en la raíz del repositorio. Esto asegura que los linters y scripts locales (como `run-checks.ps1` y `check-cleanliness.ps1`) puedan analizarlos y validarlos antes del commit.

- `brain/` del repo = **memoria persistente del proyecto** (sobrevive entre conversaciones y sesiones).
- Artefactos de Antigravity en la raíz = **memoria de conversación y planificación operativa activa** (efímera, ligada a la sesión y sprint actual).

**Regla de cierre**: al terminar una sesión importante, migra las conclusiones o hitos relevantes a la memoria persistente del repo (`brain/`) y archiva o limpia los artefactos activos de la raíz para mantener la higiene del espacio de trabajo.
