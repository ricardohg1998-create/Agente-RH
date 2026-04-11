# Changelog

## Registros

- **2026-04-11**: Auditoría Autista Cafeinado completada — 22/22 tests Pester verdes. 6 bugs críticos resueltos (sync-brain marcadores/parsing, check-links scoping/filtros, bootstrap directorio padre, init-project hang). Renombrado `Normalize-Eol` a `ConvertTo-NormalizedEol` en módulo exportado. Deuda técnica documentada exhaustivamente.
- **2026-04-10**: Saneamiento MCP y Factory Reset — Eliminada contaminación de dominio (`social-content`). Factory Reset en `init-project.ps1` para clones limpios. Servidor Semántico MCP integrado (`ts-morph`) con autoinstalación. Corregido encoding UTF-8 BOM en `install-mcp.ps1`.
- **2026-04-05**: Workflows v3.0 — 13 workflows operativos (10 mejorados + 3 nuevos). Herramientas sugeridas Antigravity-native, composicion y encadenamiento, modos de operacion, dispatch con senales ricas, meta-sistema de metricas. Infraestructura actualizada (create-workflow.ps1, brain-policy.json, implementation-plan-template.md, repo-structure.json).
- **2026-04-03**: Mejora integral de workflows v2.0 — Reescritura profunda de `autista-cafeinado` y `desarrollador-profundidad`. Nuevos workflows `code-review` y `retrospectiva`. Fix de `create-workflow.ps1`. Campo `description` en todos.
- **2026-03-21**: Finalizado el retroceso de mejoras (Backport) desde el proyecto derivado `comparador v2`. Añadida la sección de infraestructura a `AGENTS.md`, creado placeholder en `brain/access.md`, reparados índices faltantes en el catálogo base y relajadas las normas de higiene de logs (`*.log`, `*.bak`).
- **2026-03-20**: Instalación exitosa de `Agentic-SEO-Skill` en el workspace de habilidades del agente (`.agent/skills/seo`). Se ejecutó una validación funcional auditando el sitio `conectayaentuhogar.es`, generando un dashboard en HTML, un Full Audit Report y un Action Plan.
