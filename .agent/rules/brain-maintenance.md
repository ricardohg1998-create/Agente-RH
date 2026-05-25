---
id: brain-maintenance
name: Brain Maintenance
activation: always-on
version: 2.0.0
---

# Brain Maintenance Rule

## Objetivo

Mantener `brain/` como memoria operativa viva, util y sin duplicidades.

## Orden de actualizacion (estricto)

1. Actualizar capa rapida:
   - `brain/now.md`
   - `brain/current-state.md`
   - `brain/stack.md` (si cambia stack o decisiones de stack)
2. Si aplica, actualizar capa profunda (`deepLayer.files` en `.agent/config/brain-policy.json`).
3. Si cambia cualquier archivo de `deepLayer.files`, actualizar `brain/deep-summary.md` en la misma tarea.

## Politica de escritura minima

- Resumir, no copiar y pegar conversaciones.
- Enlazar documentos relacionados en vez de duplicar texto.
- Mover contenido obsoleto a `brain/archive/`. ANTE LA DUDA COMO AGENTE, ARCHIVAR, NO BORRAR, para preservar la trazabilidad.

## Ejemplos de activacion

Actualizar cerebro cuando exista alguno de estos eventos:

- Decision tecnica nueva.
- Cambio de alcance o prioridad.
- Bloqueo nuevo o desbloqueo.
- Error repetible identificado y solucionado.
- Instruccion persistente del usuario agregada o modificada.

## Hooks de automatizacion

Usar scripts:

- `scripts/update-brain-quick.ps1`
- `scripts/update-brain-deep-summary.ps1`
- `scripts/log-decision.ps1`
- `scripts/add-instruction.ps1`
