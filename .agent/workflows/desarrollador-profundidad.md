---
id: desarrollador-profundidad
name: Desarrollador de profundidad
description: Detector exhaustivo de falta de profundidad en UX, flujos, contenido y funcionalidad, con Implementation Plan completisimo.
version: 2.0.0
modes: [planning, execution]
---

# Workflow: Desarrollador de profundidad

## Proposito

Detectar falta de profundidad real en la experiencia de usuario y la funcionalidad del proyecto. Busca sistematicamente: botones que no llevan a ningun sitio, secciones sin desarrollar, paginas incompletas, funciones por implementar, estados vacios sin manejar y flujos rotos. El objetivo final es generar un **Implementation Plan completisimo y detallado** que defina exactamente que implementar, donde y en que orden para completar todo lo que falta.

## Cuando usarlo

- Producto parece incompleto o superficial.
- Hay CTAs sin destino o pantallas no rematadas.
- Se sospecha de funciones anunciadas pero no implementadas.
- Usuarios reportan "esto no hace nada" o "esto esta vacio".
- Se requiere plan de implementacion detallado para completar un producto.

## Input esperado

- Alcance (todo el proyecto o modulo/feature especifico).
- Objetivo de negocio o UX esperado.
- Restricciones tecnicas y temporales.
- Estado actual (si existe en `brain/current-state.md`).

## Politica de lectura de memoria

<!-- GENERATED:WORKFLOW-QUICK-LAYER:START -->
- Leer siempre capa rapida (`brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`).
<!-- GENERATED:WORKFLOW-QUICK-LAYER:END -->
- Expandir a capa profunda cuando falte contexto de arquitectura/producto o haya contradicciones.
- Si el alcance es pequeno y claro, mantener lectura profunda selectiva.

## Pasos internos

1. Leer capa rapida y expandir si hay gatillos de contexto.
2. **Mapear todas las areas funcionales, rutas y componentes** del alcance definido.
3. **Detectar botones/CTAs sin destino**:
   - onClick vacios o con `console.log` placeholder.
   - Links a `#`, `javascript:void(0)` o rutas inexistentes.
   - Botones con texto de accion ("Guardar", "Exportar", "Configurar") que no hacen nada.
   - Menu items que no navegan a ninguna pagina real.
4. **Detectar secciones no desarrolladas**:
   - Componentes con contenido placeholder ("Coming soon", "Lorem ipsum", textos genericos).
   - Tabs o acordeones con cuerpo vacio.
   - Dashboards con cards sin datos reales.
   - Paneles laterales o modales sin contenido funcional.
5. **Detectar paginas incompletas**:
   - Layouts a medias (footer faltante, sidebar sin items, headers estaticos).
   - Formularios sin validacion, sin feedback de error, sin confirmacion de exito.
   - Tablas sin paginacion, sin ordenamiento, sin busqueda cuando deberian tenerlos.
   - Paginas de detalle sin todas las secciones esperadas.
6. **Detectar funciones por implementar**:
   - TODOs y FIXMEs en codigo.
   - Handlers vacios o con `// TODO: implement`.
   - Endpoints mencionados en frontend pero inexistentes en backend.
   - Features mencionadas en docs/UI pero sin codigo detras.
7. **Detectar estados UX sin manejar**:
   - Empty states: que ve el usuario cuando no hay datos?
   - Loading states: hay indicador de carga o se queda congelado?
   - Error states: que pasa cuando falla una API, un form, una carga?
   - Edge cases: que pasa con textos muy largos, listas vacias, permisos insuficientes?
8. **Detectar flujos rotos**:
   - Navegacion sin retorno (se puede volver atras?).
   - Modales sin boton de cierre o sin escape.
   - Formularios multi-paso sin indicador de progreso.
   - Flujos de onboarding que no se completan.
   - Acciones destructivas sin confirmacion.
9. **Estimar impacto por hueco**:
   - Bloquea funcionalidad critica? (alto)
   - Afecta experiencia de usuario? (medio)
   - Es cosmetico/menor? (bajo)
10. **Priorizar**: quick wins primero (esfuerzo bajo + impacto alto), luego cambios estructurales.
11. **Generar Implementation Plan completisimo y detallado**:
    - Descripcion exacta de que implementar en cada punto.
    - Archivos afectados y cambios esperados.
    - Dependencias entre tareas.
    - Orden de ejecucion recomendado.
    - Criterios de aceptacion verificables.

## Output obligatorio

1. **Diagnostico general** del nivel de completitud del producto/modulo.
2. **Mapa de zonas superficiales/rotas** (vista general de donde estan los huecos).
3. **Lista de CTAs/botones sin destino** (archivo, linea, que deberian hacer).
4. **Lista de secciones sin desarrollar** (componente, que falta, que deberia contener).
5. **Lista de paginas incompletas** (ruta, que le falta para estar completa).
6. **Lista de funciones por implementar** (archivo, linea, que deberia hacer).
7. **Lista de estados UX sin manejar** (componente, que estado falta, como deberia verse).
8. **Lista de flujos rotos** (flujo, donde se rompe, como deberia funcionar).
9. **Quick wins** (esfuerzo bajo, impacto alto — hacer primero).
10. **Cambios estructurales necesarios** (requieren mas trabajo pero son fundamentales).
11. **Implementation Plan detallado por fases** (ENTREGABLE PRINCIPAL):
    - Cada tarea con descripcion precisa de que hacer.
    - Archivos involucrados y cambios esperados.
    - Dependencias claras entre tareas.
    - Orden de ejecucion que no rompa nada.
    - El plan debe ser tan detallado que se pueda ejecutar sin preguntar nada.

## Criterios de calidad

- **Evidencia exacta**: cada hueco con archivo, linea y componente senalado.
- **Sin feedback superficial**: si reportas un problema, explica por que importa y como resolverlo con detalle.
- **Implementation Plan ejecutable sin ambiguedad**: un desarrollador (o agente) debe poder coger el plan y ejecutarlo de principio a fin sin necesitar contexto adicional.
- **Priorizacion accionable** con dependencias reales, no teoricas.

## Brain read/write

- Leer: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/project-overview.md`, `brain/architecture.md`.
- Escribir: `brain/now.md`, `brain/current-state.md`, `brain/stack.md`, `brain/deep-summary.md`, `brain/backlog.md`, `brain/open-questions.md`, `brain/changelog.md`.
