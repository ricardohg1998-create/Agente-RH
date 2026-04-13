---
id: buscar-skills
name: Buscar skills
description: Seleccionar e instalar el conjunto minimo util de skills para el stack real del proyecto, sin ruido ni redundancias.
version: 1.1.0
modes: [planning, execution]
---

# Workflow: Buscar skills

## Proposito

Seleccionar e instalar el conjunto minimo util de skills para el stack real del proyecto, sin ruido ni redundancias.

## Cuando usarlo

- Inicio de proyecto nuevo.
- Cambio de stack o dominio.
- Exceso de skills instaladas o solapadas.

## Input esperado

- Stack real y objetivo del proyecto.
- Restricciones de entorno.
- Fuentes de catalogo configuradas.

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a capa profunda solo si hay duda de stack real, overlap no resuelto o conflicto con decisiones previas.
- Si no hay gatillos, mantener lectura minima para evitar ruido.

## Pasos internos

1. Leer capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
2. Leer `.agent/config/skills-sources.json`.
3. Revisar skills disponibles en sesion.
4. Revisar `CATALOG.md` preferente (si existe).
5. Leer `SKILL.md` de candidatas.
6. Eliminar solapes/incompatibilidades.
7. Seleccionar core minimo + opcionales.
8. Instalar y validar.

## Herramientas sugeridas

- **Leer skills candidatas**: `view_file` de cada `SKILL.md` para evaluar utilidad, calidad y compatibilidad.
- **Evaluar alternativas externas**: `search_web` para buscar skills o herramientas que cubran necesidades no resueltas por el catalogo local.
- **Listar skills instaladas**: `run_command` con `npx skills list -g -a antigravity` para ver el estado actual.
- **Instalar skills seleccionadas**: `run_command` con `npx skills add` y los parametros correctos.
- **Verificar solapamientos**: `view_file` comparando las descripciones de skills similares para decidir cual mantener.

## Output obligatorio

1. Lista final core.
2. Skills opcionales.
3. Conflictos, duplicidades o descartes y motivo.

## Criterios de calidad

- Priorizar utilidad real sobre cantidad.
- Mantener maximo una skill por dominio cuando haya overlap.
- Evitar repetir busquedas largas si ya hay catalogo local util.

## Composicion

- **Suele preceder a**: `implementacion-quirurgica`.
- **Suele seguir a**: `inicio-proyecto`, cambio de stack.
- **Workflow sugerido al completar**: `implementacion-quirurgica` (para comenzar el desarrollo con el stack equipado).

## Brain read/write

- Leer: `brain/current-state.md`, `brain/skills-available.md`.
- Escribir: `brain/skills-available.md`, `brain/changelog.md`, `brain/now.md`.

## Comandos de instalacion y validacion

```bash
npx skills add "<ruta_repo_skills>" -g -a antigravity --copy -y -s <skills...>
npx skills list -g -a antigravity
```

