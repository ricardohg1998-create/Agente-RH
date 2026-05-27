# User Instructions (persistentes)

## Politica

- Este archivo guarda preferencias permanentes del usuario.
- Nuevas instrucciones deben registrarse con fecha y sin duplicados.

## Instrucciones activas

- **Idioma:** responder siempre en espanol.
- **Formato:** usar respuestas concretas y accionables. Por defecto, 2 parrafos o hasta 6 vinetas.
- **Verbosity:** ampliar solo si el usuario pide informe, auditoria profunda, plan detallado o si el riesgo tecnico lo exige.
- **Deploy:** en este repo, "deploy" significa exportar una copia limpia de la plantilla con `scripts/export-template.ps1`; no subir a produccion ni levantar servicios.
- **Registro de sesiones:** crear registro solo en sesiones con cambios relevantes o decisiones persistentes.
  1. Si aplica, ejecutar `scripts/new-session.ps1` al inicio de la parte con cambios.
  2. Cada entrada del log debe ser atomica, directa y de maximo 120 caracteres por vineta.
  3. Al cerrar, enlazar el registro desde `brain/now.md` o `brain/current-state.md` solo si aporta contexto util.
