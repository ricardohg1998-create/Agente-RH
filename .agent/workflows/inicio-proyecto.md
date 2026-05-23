---
id: inicio-proyecto
name: Inicio de proyecto
description: Guiar desde repo clonado hasta proyecto inicializado y listo para desarrollar, con estado verificable y cerebro actualizado.
version: 1.1.0
modes: [planning, execution]
---

# Workflow: Inicio de proyecto

## Propósito

Guiar desde repo clonado hasta proyecto inicializado y listo para desarrollar, con estado verificable y cerebro actualizado.

## Cuándo usarlo

- Repo recien clonado con esqueleto base.
- Inicio de proyecto nuevo sobre la plantilla.
- Reseteo de proyecto existente para rearrancar.

## Input esperado

- Nombre y vision del proyecto.
- Stack candidato o restricciones de stack.
- Alcance del primer entregable.
- Restricciones (tiempo, equipo, entorno).

## Política de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a `brain/project-overview.md` y `brain/stack.md` para verificar estado previo.
- Si hay decisiones anteriores relevantes, leer `brain/decisions.md`.


## Pasos internos

1. Verificar el entorno. Si el repo es virgen, ejecutar `scripts/init-project.ps1` automatizado proporcionando todos los parametros (`-ProjectName`, `-ProjectVision`, `-FirstDeliverable`, `-InitGit`, `-InstallHook`, `-CreateCatalog`, etc.) para que haga el factory reset del cerebro e instale el MCP Server.
2. Definir y asentar la vision de producto en `brain/project-overview.md` (si el script de inicio no ha volcado todo el detalle).
3. Seleccionar e inicializar el entorno técnico con CLIs oficiales (ej. `npx create-next-app@latest . --ts --tailwind --eslint --app --src-dir --import-alias "@/*" --use-npm`). Usar siempre modos no interactivos.
4. Rellenar `brain/stack.md` detallando las decisiones tecnologicas adoptadas y registrar la eleccion general en `brain/decisions.md`.
5. Ejecutar workflow `buscar-skills` para integrar en el agente el conocimiento necesario para el stack configurado.
6. Actualizar `brain/architecture.md` documentando la estructura base que ha generado el CLI.
7. Verificar que el Servidor MCP Semántico se instaló correctamente (`.agent/mcp/semantic-server/build/index.js`). Si falló el build automático, compilarlo manualmente.
8. Modificar la capa rapida (`brain/now.md`, `brain/current-state.md` y `brain/deep-summary.md`) declarando el hito de "Setup" como cerrado.
9. Ejecutar `scripts/run-checks.ps1` -> todo debe estar en verde.
10. Comprobar que en Git ya consta el commit fundacional.

## Herramientas sugeridas

- **Bootstrap**: `run_command` utilizando el script `scripts/init-project.ps1` con sus parametros nombrados. **// turbo**
- **Generacion del Boilerplate**: `run_command` con `npx -y` (o equivalente) asegurando que es no interactivo.
- **Evaluar stack**: `search_web` para buscar tendencias antes de fijar las herramientas.
- **Test de Servidor local**: `run_command` (async) para probar `npm run dev` y confirmar que responde sin errores.
- **Checks automáticos**: `run_command` con `scripts/run-checks.ps1`. **// turbo**

## Criterios de calidad

- El proyecto debe arrancar localmente tras completar el workflow.
- Toda decision de stack debe estar justificada y registrada.
- El cerebro debe reflejar el estado real del proyecto, no el estado plantilla.

## Composición

- **Suele preceder a**: `buscar-skills`, `implementacion-quirurgica`.
- **Suele seguir a**: clonado de repo o arranque de proyecto nuevo.
- **Workflow sugerido al completar**: `buscar-skills` (para equipar al agente con skills relevantes).

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/project-overview.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/project-overview.md`, `brain/architecture.md`, `brain/decisions.md`, `brain/skills-available.md`, `brain/changelog.md`.

