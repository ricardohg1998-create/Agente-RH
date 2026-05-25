# User Instructions (persistentes)

## Politica

- Este archivo guarda instrucciones permanentes del usuario.
- Nuevas instrucciones deben registrarse con fecha y sin duplicados.

## Instrucciones activas

- **Idiomas:** RESPONDER SIEMPRE EN ESPAÑOL, sin excepciones.
- **Formato:** Usar listas concretas y respuestas accionables.
- **Deploy:** Cuando el usuario pida hacer "deploy" o "desplegar", el agente **no** debe intentar subir codigo a ningun servidor de produccion ni levantar servicios. "Deploy" en este repositorio significa unica y exclusivamente empaquetar una copia limpia y "virgen" del esqueleto (borrando historiales, logs, temporales y carpetas de despliegue anteriores) y guardarla en la carpeta raiz `agente-rh-template`. Para ello, el agente siempre debe ejecutar el script `scripts/export-template.ps1`.
- **Registro de sesiones:** A partir de ahora, todas las conversaciones o sesiones de trabajo generaran su propio registro.
  1. Se creara un `.md` de registro de cambios en `brain/session_logs` con formato de titulo de fecha y hora inicial, ej. `2026-03-14_09-30_registro_cambios_sesion.md` (o se utilizara uno generico temporal que debera reubicarse al final).
  2. Este archivo se debe iterar para llevar un conteo de los cambios solicitados y describir brevemente como se han resuelto en la sesion en cuestion (a modo de registro directo, sin extender textos largos ni verbosidades).
  3. Cuando la conversacion finalice y se tenga que actualizar `brain`, el agente vinculara los resumenes en la memoria corta (`now.md`, `current-state.md`) a traves de enlaces directos de markdown hacia este archivo profundo de registro detallado.
