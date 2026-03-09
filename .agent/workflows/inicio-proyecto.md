---
id: inicio-proyecto
name: Inicio de proyecto
version: 1.0.0
modes: [planning, execution]
---

# Workflow: Inicio de proyecto

## Proposito

Guiar desde repo clonado hasta proyecto inicializado y listo para desarrollar, con estado verificable y cerebro actualizado.

## Cuando usarlo

- Repo recien clonado con esqueleto base.
- Inicio de proyecto nuevo sobre la plantilla.
- Reseteo de proyecto existente para rearrancar.

## Input esperado

- Nombre y vision del proyecto.
- Stack candidato o restricciones de stack.
- Alcance del primer entregable.
- Restricciones (tiempo, equipo, entorno).

## Politica de lectura de memoria

- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
- Expandir a `brain/project-overview.md` y `brain/stack.md` para verificar estado previo.
- Si hay decisiones anteriores relevantes, leer `brain/decisions.md`.

## Pasos internos

1. Ejecutar `scripts/bootstrap.ps1` y verificar estructura completa.
2. Definir vision y alcance inicial -> actualizar `brain/project-overview.md`.
3. Seleccionar stack -> rellenar `brain/stack.md` con eleccion, razon y versiones.
4. Registrar decision de stack en `brain/decisions.md`.
5. Ejecutar workflow `buscar-skills` para el stack elegido.
6. Scaffoldear proyecto en `src/` segun stack.
7. Actualizar `brain/architecture.md` con estructura real del proyecto.
8. Actualizar capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
9. Ejecutar `scripts/run-checks.ps1` -> todo en verde.
10. Primer commit con checks pasando.

## Output obligatorio

1. Estructura scaffoldeada y funcional en `src/`.
2. `brain/project-overview.md` con vision y alcance definidos.
3. `brain/stack.md` completo con eleccion razonada.
4. Decision registrada en `brain/decisions.md`.
5. Skills instaladas segun stack.
6. `brain/architecture.md` actualizado.
7. Resultado de checks (estructura + limpieza + context budget).
8. Primer commit verificable.

## Criterios de calidad

- El proyecto debe arrancar localmente tras completar el workflow.
- Toda decision de stack debe estar justificada y registrada.
- El cerebro debe reflejar el estado real del proyecto, no el estado plantilla.

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/project-overview.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/project-overview.md`, `brain/architecture.md`, `brain/decisions.md`, `brain/skills-available.md`, `brain/changelog.md`.

