---
id: buscar-skills
name: Buscar skills
description: Seleccionar e instalar el conjunto minimo util de skills para el stack real del proyecto, sin ruido ni redundancias.
version: 1.1.0
modes: [planning, execution]
---

# Workflow: Buscar skills

## Propósito

Seleccionar e instalar el conjunto minimo util de skills para el stack real del proyecto, sin ruido ni redundancias.

## Cuándo usarlo

- Inicio de proyecto nuevo.
- Cambio de stack o dominio.
- Exceso de skills instaladas o solapadas.

## Input esperado

- Stack real y objetivo del proyecto.
- Restricciones de entorno.
- Fuentes de catalogo configuradas.

## Política de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a capa profunda solo si hay duda de stack real, overlap no resuelto o conflicto con decisiones previas.
- Si no hay gatillos, mantener lectura minima para evitar ruido.

## Pasos internos

1. Leer capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`).
2. Analizar el bloque nativo `<skills>` inyectado por Antigravity en las instrucciones de sistema.
3. Filtrar cuáles de esas skills disponibles aplican al stack técnico y dominio del negocio actual.
4. Revisar `CATALOG.md` preferente (si el template lo ofrece) por si hubiera skills personalizadas o cerradas.
5. Usar `view_file` para leer el `SKILL.md` de las candidatas finales si se duda de su utilidad.
6. Eliminar solapes y crear una seleccion del "core tecnico" estrictamente util para el repositorio actual.
7. Instalar las skills no presentes en local copiando sus recursos a `.agent/skills/` o usando herramientas de CLI aplicables.
8. Registrar el entorno final en `brain/skills-available.md`.

## Herramientas sugeridas

- **Auditar entorno activo**: Revisión directa del bloque `<skills>` en memoria para ver las rutas absolutas.
- **Evaluar candidatas**: `view_file` de la ruta `SKILL.md` inyectada en el prompt para evaluar si resuelve la necesidad operativa.
- **Buscar y Añadir externas**: `search_web` y `run_command` (con npm/npx o git clone) para descargar skills comunitarias a `.agent/skills/`. **// turbo**
- **Verificar solapamientos**: Análisis lógico comparando descripciones para asegurar que solo haya 1 skill activa por dominio funcional.

## Output obligatorio

1. Lista final core.
2. Skills opcionales.
3. Conflictos, duplicidades o descartes y motivo.

## Criterios de calidad

- Priorizar utilidad real sobre cantidad.
- Mantener maximo una skill por dominio cuando haya overlap.
- Evitar repetir busquedas largas si ya hay catalogo local util.

## Composición

- **Suele preceder a**: `implementacion-quirurgica`.
- **Suele seguir a**: `inicio-proyecto`, cambio de stack.
- **Workflow sugerido al completar**: `implementacion-quirurgica` (para comenzar el desarrollo con el stack equipado).

## Brain read/write

- Leer: `brain/current-state.md`, `brain/skills-available.md`.
- Escribir: `brain/skills-available.md`, `brain/changelog.md`, `brain/now.md`.

## Comandos de instalacion y validacion

El IDE de Antigravity agrupa las globales y locales.
Si hace falta volcar una skill a la "mochila" del proyecto específico localmente:

```bash
# Ejemplo: Instalación en local via CLI
npx skills add "<ruta_o_url>" -g -a antigravity --copy -y -s <skills...>
# La skill terminara residiendo operativamente en .agent/skills/<nombre>/SKILL.md
```
