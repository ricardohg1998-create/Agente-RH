---
id: pre-release
name: Pre-lanzamiento
description: Checklist exhaustivo de validacion antes de deploy a produccion, combinando checks automaticos, security review y smoke test visual.
version: 1.0.0
modes: [planning, execution]
---

# Workflow: Pre-lanzamiento

## Propósito

Validacion exhaustiva antes de deploy a produccion. Combina checks automaticos del repo, security review focalizado, validacion de build, verificacion de configuracion de entorno y smoke test visual. Funciona como gate final que bloquea o autoriza el deploy con evidencia objetiva.

## Cuándo usarlo

- Antes de deploy a produccion o staging.
- Antes de entregar version final a cliente.
- Despues de un sprint de desarrollo intensivo que va a produccion.
- Cuando se quiere validar que el proyecto esta listo para release.

## Input esperado

- Entorno destino (produccion, staging, preview).
- URL del entorno si ya existe.
- Cambios incluidos en el release (changelog o lista de PRs/commits).
- Criterios de bloqueo especificos del proyecto (si existen).

## Política de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a capa profunda completa: `brain/architecture.md`, `brain/technical-debt.md`, `brain/pitfalls-and-errors.md`.
- Leer `brain/access.md` para verificar configuracion de entornos.

## Pasos internos

1. Leer capa rapida y expandir a capa profunda completa.
2. **Ejecutar todos los checks del repo**: `scripts/run-checks.ps1` y cualquier linter/formatter configurado.
3. **Security review focalizado** (invocando pasos clave de `code-review`):
   - Buscar credenciales hardcodeadas con patrones de `grep_search`.
   - Verificar `.gitignore` incluye archivos sensibles.
   - Verificar CORS y configuraciones de produccion.
   - Verificar que no hay `DEBUG=true`, `verbose`, o configuraciones de desarrollo activas.
4. **Validar build de produccion**: ejecutar el build command y verificar que completa sin errores ni warnings criticos.
5. **Verificar variables de entorno**: confirmar que todas las variables requeridas estan configuradas para el entorno destino.
6. **Ejecutar tests** si existen: suite completa con reporte de resultados.
7. **Smoke test visual**: `browser_subagent` para navegar los flujos criticos de la aplicacion y verificar que funcionan.
8. **Verificar deuda tecnica critica**: revisar `brain/technical-debt.md` para confirmar que no hay deuda que bloquee el release.
9. **Generar changelog del release** con los cambios incluidos.
10. **Emitir veredicto**: LISTO / BLOQUEADO (con motivos).

## Herramientas sugeridas

- **Ejecutar checks**: `run_command` con `scripts/run-checks.ps1`, linters, formatters.
- **Buscar credenciales**: `grep_search` con patrones de API keys y secrets (heredados de `code-review`).
- **Validar build**: `run_command` con `npm run build`, `next build`, o equivalente del stack.
- **Ejecutar tests**: `run_command` con el test runner configurado.
- **Smoke test visual**: `browser_subagent` para navegar flujos criticos en el entorno local o de preview.
- **Verificar configuracion**: `view_file` de archivos `.env.production`, configs de deploy, etc.
- **Buscar configs de debug**: `grep_search` con `DEBUG`, `verbose`, `console.log`, `NODE_ENV.*development`.
- **Verificar deuda critica**: `view_file` de `brain/technical-debt.md` y `brain/pitfalls-and-errors.md`.

## Output obligatorio

1. **Checklist de validacion** con resultado por item (PASS / FAIL / SKIP + motivo).
2. **Resultado de checks automaticos** (output de scripts).
3. **Resultado de security review** (hallazgos criticos si los hay).
4. **Resultado del build** (exito, warnings, errores).
5. **Resultado de tests** (pasados, fallidos, cobertura).
6. **Resultado de smoke test** (flujos verificados y su estado).
7. **Deuda tecnica critica** que afecta al release (si existe).
8. **Changelog del release**.
9. **Veredicto final**: LISTO PARA DEPLOY / BLOQUEADO (con bloqueadores listados).

## Criterios de calidad

- **Cero tolerancia en seguridad**: cualquier credencial expuesta o endpoint critico sin auth bloquea el release.
- **Build limpio**: warnings tolerables deben estar documentados; errores bloquean.
- **Evidencia objetiva**: cada item del checklist debe tener evidencia verificable, no opinion subjetiva.
- **Veredicto binario**: LISTO o BLOQUEADO, sin zonas grises. Si hay dudas, es BLOQUEADO hasta que se resuelvan.

## Composición

- **Suele preceder a**: deploy (ejecucion de `scripts/deploy.ps1`) y `cierre-operativo`.
- **Suele seguir a**: `qa-testing`, `code-review`, `desarrollador-profundidad`.
- **Workflow sugerido al completar**: `cierre-operativo` (para documentar el release).

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/architecture.md`, `brain/technical-debt.md`, `brain/pitfalls-and-errors.md`, `brain/access.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/deep-summary.md`, `brain/changelog.md`, `brain/milestones.md`.
