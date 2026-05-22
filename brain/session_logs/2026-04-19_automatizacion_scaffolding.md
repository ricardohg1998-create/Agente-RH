# Automatización de Scaffolding para Clones del Template

## Objetivo Original
Evitar depender de la memoria del usuario para ejecutar el flujo de desvinculación de la plantilla base tras clonar el repositorio "Agente RH" para nuevos proyectos SAAS.

## Tareas Realizadas
- Creación de un script `init-new-project.ps1` en `.agent/scripts` que es completamente autónomo y no requiere inputs por bandera.
  - Extrae el nombre final del proyecto a partir del nombre en formato _slug_ del directorio contenedor.
  - Verifica **idempotencia** mediante el flag file .agent/.init_done.
  - Verifica seguridad para no auto-sabotear la carpeta maestra (`Agente RH`).
  - Ejecuta las sustituciones de `package.json`, MCP estático e inyección en Antigravity y `SKILL.md`.
- Vinculación a nivel de IDE (`.vscode/tasks.json`): se implementó la directiva `"runOn": "folderOpen"`. Esto provoca que el script sea desencadenado en segundo plano por el IDE automáticamente tan pronto como el desarrollador abre la copia clonada del repositorio.

## Entregables
- `.agent/scripts/init-new-project.ps1`
- `.vscode/tasks.json`

## Riesgos y Pendientes
- **Riesgo Mitigado**: La colisión de identidad del MCP en proyectos paralelos clonados de este repositorio se ha mitigado formalmente.

## Resultados
La inicialización y desvinculación de un clon de la plantilla a un proyecto particular es ahora de factor "cero comandos" (0-click / Zero-touch) activada on-load por el editor con protecciones de idempotencia.
