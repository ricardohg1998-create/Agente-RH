# Catálogo de Habilidades (Skills Available)

Este documento centraliza el estado de las herramientas especializadas y habilidades disponibles para el agente. 

La **única fuente de verdad** (SSoT) sobre las habilidades locales activas e instaladas físicamente en el workspace del repositorio se encuentra en el [Catálogo de Skills del Repositorio](../CATALOG.md), generado y actualizado dinámicamente mediante el script `generate-catalog.ps1`.

## Estado y Disponibilidad de Habilidades

* **Habilidades Nativas y Especiales:**
  - **Servidor Semántico MCP:** Activo y cargado nativamente en el entorno IDE (según [stack.md](stack.md#parametros-de-entorno-de-desarrollo-ide)), lo que permite una navegación semántica profunda en el código.
  - **pdf-official:** Utilidades de manipulación de archivos PDF locales.
* **Instalación y Configuración:**
  - La selección, descarga e instalación de nuevos paquetes de habilidades a demanda para proyectos específicos se orquesta mediante el workflow [buscar-skills](../.agent/workflows/buscar-skills.md).
  - Los orígenes y fuentes remotas de descarga están definidos formalmente en el archivo de configuración `.agent/config/skills-sources.json`.

## Soporte Multiagente Especializado (Swarm Core v2.0)

El repositorio cuenta con prompts de sistema y checklists de tareas dedicados para orquestar agentes coordinadores y de calidad:
- **Supervisor de Enjambre (SwarmSupervisor)**: Especialista en sincronización reactiva, monitorización ágil en tiempo real e intercomunicación a través de callbacks.
- **Validador de Calidad / QA (QualityValidator)**: Compuerta de calidad encargada de realizar críticas intelectuales rigurosas y ejecutar suites de validación (`run-checks.ps1` o Pester).
