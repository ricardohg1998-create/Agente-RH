# Now

<!-- QUICK-NOW:START -->
## Estado actual

- Refactorizacion agnostica v1 completada. Checks operativos endurecidos en raiz y template para tolerar paquetes npm con scope y archivos con longitud nula.

## Siguiente accion recomendada

- Resolver la politica de duplicados intencionales entre raiz y `agente-rh-template/` para que `scripts/run-checks.ps1` del repo principal vuelva a quedar completamente en verde.

## Bloqueos activos

- `check-cleanliness.ps1` del repo principal sigue marcando como duplicados intencionales los archivos espejo de `agente-rh-template/`.

## Cambios recientes

- [2026-03-12] Mejora de rendimiento en `agente-rh-template/scripts/generate-catalog.ps1` reemplazando el operador `+=` de arrays con `System.Collections.Generic.List[string]`.
- [2026-03-10 16:32] Hardening de `check-links.ps1` y `check-cleanliness.ps1` en raiz y template.
- [2026-03-10 13:46] Actualizacion rapida por agent.
- [2026-03-11] Nueva instruccion persistente: No actualizar la memoria de agente-rh-template; esa carpeta debe mantenerse como una copia virgen e identica del repo, lista para iniciar un nuevo proyecto.
<!-- QUICK-NOW:END -->


