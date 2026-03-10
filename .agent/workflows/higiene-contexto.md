---
id: higiene-contexto
name: Higiene de contexto
version: 1.0.0
modes: [planning, execution]
---

# Workflow: Higiene de contexto

## Proposito

Reducir deriva documental y consumo innecesario de contexto manteniendo la memoria operativa util y compacta.

## Cuando usarlo

- Se detecta ruido, duplicidad o documentos largos sin accion.
- El presupuesto de contexto marca warnings o riesgo de criticals.
- Hay necesidad de consolidar y limpiar memoria/documentacion.

## Input esperado

- Alcance de limpieza (brain/docs/rules/workflows o repo completo).
- Restricciones de preservacion historica.
- Estado de checks actuales (si existe).

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Por naturaleza del workflow, expandir desde inicio a capa profunda del alcance definido.
- Limitar lectura a documentos del alcance para no introducir ruido adicional.

## Pasos internos

1. Leer capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
2. Expandir a capa profunda del alcance de limpieza.
3. Revisar documentos en alcance y detectar duplicidad semantica.
4. Identificar contenido obsoleto, redundante o sin accion.
5. Proponer consolidacion y destino (mantener, archivar, borrar).
6. Verificar alineacion con `context-budget` y `repo-hygiene`.
7. Emitir plan de limpieza priorizado.

## Output obligatorio

1. Diagnostico de deriva documental.
2. Mapa de duplicidades relevantes.
3. Lista de contenidos obsoletos.
4. Propuesta de consolidacion por documento.
5. Propuesta de archivado/borrado con motivo.
6. Impacto esperado en contexto y mantenibilidad.
7. Plan por fases de limpieza.
8. Riesgos y dudas abiertas.

## Criterios de calidad

- Mantener una sola fuente vigente por tema.
- Priorizar claridad operativa sobre volumen de texto.
- No borrar historial con valor tecnico sin alternativa.

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/workflows-index.md`, `brain/changelog.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/changelog.md`, `brain/archive/` (si aplica).

