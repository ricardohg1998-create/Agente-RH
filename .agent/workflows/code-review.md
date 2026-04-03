---
id: code-review
name: Code Review
description: Revision tecnica de codigo desde un archivo hasta el repo completo, con foco en seguridad, credenciales, APIs y auth.
version: 1.0.0
modes: [planning, execution]
---

# Workflow: Code Review

## Proposito

Revision tecnica de codigo — desde un archivo o componente concreto hasta el repo completo. Inspeccion por capas de calidad, patrones y **seguridad** (credenciales, APIs, auth, tokens expuestos, manejo de secretos). Cada hallazgo viene con severidad, ubicacion exacta y fix propuesto.

## Cuando usarlo

- Antes de merge o deploy.
- Sospecha de problemas de seguridad o credenciales expuestas.
- Codigo nuevo o refactorizado que necesita segunda opinion.
- Revision periodica de calidad del repo completo.
- Se quiere validar que el codigo cumple patrones y convenciones del proyecto.

## Input esperado

- Alcance: archivo, modulo, feature, o repo completo (si no se especifica, se revisa el alcance natural del prompt).
- Foco preferente (opcional): seguridad, rendimiento, patrones, legibilidad.
- Restricciones: lenguaje, framework, convenciones del proyecto.

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Si el review es de repo completo, expandir a `brain/architecture.md` y `brain/technical-debt.md`.
- Si es focalizado, mantener lectura minima para no cargar contexto innecesario.

## Pasos internos

1. Leer capa rapida y expandir si el alcance lo requiere.
2. **Identificar alcance del review**: archivo -> modulo -> feature -> repo completo (segun prompt).
3. **Revisar por capas** (en este orden de prioridad):
   - **Correctitud**: bugs, edge cases no manejados, logica incorrecta, condiciones de carrera, errores de concurrencia.
   - **Seguridad** (pilar principal):
     - Credenciales hardcodeadas (passwords, API keys, tokens en codigo fuente).
     - Tokens expuestos en logs, consola o respuestas HTTP.
     - API keys en repositorio o en archivos no protegidos por `.gitignore`.
     - Endpoints sin autenticacion o autorizacion.
     - Secrets en repos (`.env` commiteados, config con credenciales).
     - `.env` o archivos de configuracion sin proteger.
     - CORS permisivo (wildcard `*` en produccion).
     - Inyecciones SQL, XSS, command injection.
     - Manejo inseguro de sesiones (tokens sin expirar, sin refresh, sin invalidacion).
     - Dependencias con vulnerabilidades conocidas.
   - **Patrones**: anti-patrones, codigo duplicado, acoplamiento excesivo, violaciones de SOLID/DRY, abstracciones incorrectas.
   - **Legibilidad**: naming inconsistente, estructura confusa, comentarios utiles vs ruido, complejidad ciclomatica excesiva.
   - **Rendimiento**: queries N+1, re-renders innecesarios, cargas no lazy, bundles pesados, assets sin optimizar.
4. **Clasificar hallazgos** por severidad:
   - 🔴 **Critico**: bugs/seguridad — debe corregirse antes de deploy.
   - 🟡 **Importante**: smell/patron — afecta mantenibilidad o escalabilidad.
   - 🟢 **Mejora**: oportunidad de hacer algo mejor.
   - ⚪ **Nit**: detalle menor, cosmetico.
5. **Proponer fix concreto** para cada hallazgo (con codigo cuando aplique).
6. **Emitir resumen ejecutivo** con veredicto general y nivel de riesgo de seguridad.

## Output obligatorio

1. **Resumen ejecutivo**: veredicto general (aprobado / aprobado con observaciones / requiere cambios / bloqueado por seguridad).
2. **Nivel de riesgo de seguridad**: alto / medio / bajo / ninguno detectado.
3. **Seccion de seguridad dedicada**: todos los hallazgos de seguridad agrupados con detalle.
4. **Hallazgos criticos** (con archivo, linea, contexto y fix propuesto).
5. **Hallazgos importantes**.
6. **Mejoras y nits**.
7. **Patrones positivos detectados** (que se esta haciendo bien — refuerzo positivo).
8. **Recomendaciones de seguimiento** (lo que no es urgente pero conviene abordar).

## Criterios de calidad

- **Evidencia exacta**: cada hallazgo con archivo, linea y fragmento de codigo.
- **Fix accionable**: no basta con senalar el problema, hay que proponer la solucion.
- **Seguridad sin excepciones**: cualquier credencial expuesta o endpoint sin auth es automaticamente critico.
- **Equilibrio**: incluir lo positivo ademas de lo negativo para dar perspectiva completa.

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/architecture.md`, `brain/technical-debt.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/deep-summary.md`, `brain/technical-debt.md`, `brain/pitfalls-and-errors.md`, `brain/changelog.md`.
