# User Instructions (persistentes)

## Politica

- Este archivo guarda instrucciones permanentes del usuario.
- Nuevas instrucciones deben registrarse con fecha y sin duplicados.

## Instrucciones activas

- **Idiomas:** Hablar siempre en espanol.
- **Formato:** Usar listas concretas y respuestas accionables.
- **Deploy:** Cuando el usuario pida hacer "deploy" o "desplegar", el agente **no** debe intentar subir codigo a ningun servidor de produccion ni levantar servicios. "Deploy" en este repositorio significa unica y exclusivamente empaquetar una copia limpia y "virgen" del esqueleto (borrando historiales, logs, temporales y carpetas de despliegue anteriores) y guardarla en la carpeta raiz `agente-rh-template`. Para ello, el agente siempre debe ejecutar el script `scripts/deploy.ps1`.
- [x] 2026-03-11 | fuente: usuario | tipo: operativa | texto: No actualizar la memoria de agente-rh-template; esa carpeta debe mantenerse como una copia virgen e identica del repo, lista para iniciar un nuevo proyecto.

