---
id: context-budget
name: Context Budget
activation: always-on
version: 2.0.0
---

# Context Budget Rule

## Objetivo

Reducir la deriva de contexto y el consumo innecesario de tokens en prompts de Antigravity 2.0 mediante una gestión estructurada del conocimiento del repositorio.

## Política Operativa

- La política formal de lectura y expansión de memoria está unificada y detallada en [core.md](./core.md#Capa-de-Memoria-R%C3%A1pida-y-Estrategia-de-Lectura). El agente debe remitirse estrictamente a esa sección como única fuente de verdad operativa.
- Evita duplicar párrafos largos o explicaciones redundantes entre documentos de la carpeta `brain/` u otros archivos del repositorio.
- Mantener los prompts del sistema y las respuestas al usuario con un diseño minimalista, pragmático y orientado a la acción inmediata.

## Cumplimiento

Usar checks locales de PowerShell recomendados:

- Ejecutar directamente [run-checks.ps1](../../scripts/run-checks.ps1) que engloba todas las validaciones (incluido el budget de contexto).

## Modelo de Severidad

- `WARN`: Exceso de longitud en documentos markdown históricos o complementarios.
- `CRITICAL`: Exceso en el tamaño de la capa rápida (`now.md`, `current-state.md`) o duplicación evidente de secciones.

## Comportamiento en Commits

- Los fallos `CRITICAL` bloquean de forma automática la confirmación de cambios (pre-commit hook).
- Los avisos `WARN` informan en la salida del hook, pero no impiden el commit.
