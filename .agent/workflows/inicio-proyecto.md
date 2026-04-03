---
id: inicio-proyecto
name: Inicio de proyecto
description: Guiar desde repo clonado hasta proyecto inicializado y listo para desarrollar, con estado verificable y cerebro actualizado.
version: 1.1.0
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

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a `brain/project-overview.md` y `brain/stack.md` para verificar estado previo.
- Si hay decisiones anteriores relevantes, leer `brain/decisions.md`.


## Pasos internos

1. Ejecutar `scripts/bootstrap.ps1` y verificar estructura completa.
2. Definir vision y alcance inicial -> actualizar `brain/project-overview.md`.
3. Seleccionar stack -> rellenar `brain/stack.md` con eleccion, razon y versiones.
4. Registrar decision de stack en `brain/decisions.md`.
5. Ejecutar workflow `buscar-skills` para el stack elegido.
6. Inicializar proyecto usando CLIs oficiales del stack (ej. `npx create-next-app@latest`, `pip init`, etc).
7. Actualizar `brain/architecture.md` con estructura real del proyecto.
8. Actualizar capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
9. Ejecutar `scripts/run-checks.ps1` -> todo en verde.
10. Primer commit verificable.

## Criterios de calidad

- El proyecto debe arrancar localmente tras completar el workflow.
- Toda decision de stack debe estar justificada y registrada.
- El cerebro debe reflejar el estado real del proyecto, no el estado plantilla.

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/project-overview.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/project-overview.md`, `brain/architecture.md`, `brain/decisions.md`, `brain/skills-available.md`, `brain/changelog.md`.

