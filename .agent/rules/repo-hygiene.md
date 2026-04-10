---
id: repo-hygiene
name: Repository Hygiene
activation: always-on
version: 1.0.0
---

# Repository Hygiene Rule

## Objetivo

Evitar deriva documental, residuos tecnicos y ruido estructural.

## Hacer

- Reutilizar archivos existentes antes de crear nuevos.
- Detectar temporales, duplicados y experimentos abandonados.
- Proponer borrado o archivado con criterio.
- Verificar estructura y limpieza con scripts.

## No hacer

- Dejar logs, tmp o backups sin justificacion.
- Duplicar contexto vigente en varios archivos.
- Mantener documentos en conflicto sin marcar uno como vigente.

## Checks obligatorios

- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-context-budget.ps1`

## Archivar vs borrar

- Archivar en `brain/archive/` si tiene valor historico.
- **Log Rotation**: Mover proactivamente los registros antiguos de `brain/session_logs/` a `brain/archive/session_logs/` periódicamente para evitar saturación.
- Borrar si solo es residuo tecnico o ruido sin valor.
