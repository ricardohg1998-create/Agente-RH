# CI opcional (no obligatoria)

## Objetivo

Dejar preparada una guia para activar validaciones remotas sin forzarlas en esta iteracion.

## Recomendacion

Cuando quieras endurecer control de calidad remoto:

1. Usa el workflow versionado en `.github/workflows/windows-checks.yml` o tomalo como base.
2. Ejecuta en CI:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/test-scripts.ps1
```

3. Configurar regla de proteccion de rama para exigir CI en PR.

## Estado actual

- Hook local opcional (se activa al ejecutar `scripts/install-hook.ps1`).
- Workflow Windows disponible, pero CI remota sigue siendo opcional.
