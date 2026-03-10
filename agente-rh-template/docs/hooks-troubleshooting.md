# Troubleshooting hooks y commit

## Error: cannot spawn .git/hooks/pre-commit

Causa comun en Windows: archivo hook con BOM o shell no disponible.

### Solucion rapida

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-hook.ps1
```

## El hook falla por comandos no encontrados

El hook busca `pwsh` y si no existe usa `powershell`.

Verifica:

```powershell
where powershell
```

## El commit se bloquea por checks

1. Ejecuta manualmente:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1
```

2. Corrige los `CRITICAL` reportados.
3. Reintenta commit.

## Permisos/line endings del hook

El instalador escribe en ASCII sin BOM para evitar fallos de ejecucion en Git.
