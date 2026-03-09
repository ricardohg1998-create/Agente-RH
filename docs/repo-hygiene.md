# Higiene del repositorio

## Objetivo

Mantener el repo legible, mantenible y sin residuos.

## Reglas

- No crear archivos temporales persistentes.
- Reutilizar archivos y rutas existentes antes de abrir nuevos.
- Evitar duplicar contexto en multiples markdowns.
- Archivar historico util en `brain/archive/`.
- Borrar residuos sin valor historico.

## Comandos

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-context-budget.ps1
```

## Criterio rapido

- Archivar: decisiones viejas, informes cerrados con valor historico.
- Borrar: `.tmp`, `.bak`, logs, snapshots de prueba sin uso.
