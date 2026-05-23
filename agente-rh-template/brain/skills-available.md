# Catálogo de Habilidades (Skills Available)

Este documento centraliza el estado de las herramientas especializadas y habilidades disponibles para el agente. 

La **única fuente de verdad** (SSoT) sobre las habilidades locales activas e instaladas físicamente en el workspace del repositorio se encuentra en el [Catálogo de Skills del Repositorio](../CATALOG.md), generado y actualizado dinámicamente mediante el script `generate-catalog.ps1`.

## Estado y Disponibilidad de Habilidades

* **Habilidades Nativas y Especiales:**
  - **Servidor Semántico MCP:** Activo y cargado nativamente en el entorno IDE (según [stack.md](stack.md#estado-de-servidores-mcp)), lo que permite una navegación semántica profunda en el código.
  - **pdf-official:** Utilidades de manipulación de archivos PDF locales.
  - **seo:** Herramientas de auditoría SEO determinista.
* **Instalación y Configuración:**
  - La selección, descarga e instalación de nuevos paquetes de habilidades a demanda para proyectos específicos se orquesta mediante el workflow [buscar-skills](../.agent/workflows/buscar-skills.md).
  - Los orígenes y fuentes remotas de descarga están definidos formalmente en el archivo de configuración `.agent/config/skills-sources.json`.
