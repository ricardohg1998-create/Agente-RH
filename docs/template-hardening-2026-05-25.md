# Informe de endurecimiento de la plantilla

Fecha: 2026-05-25

## Objetivo

Este documento explica en detalle los cambios aplicados a la plantilla de agente para acercarla al objetivo operativo definido:

- Uso principal en Antigravity Desktop 2.0.
- Entorno real: Windows 11 en este PC.
- Plantilla lo mas eficaz y eficiente posible.
- Cero errores conocidos.
- Cero puntos de friccion evitables.

La intervencion no se limito a hacer que el repositorio maestro pasara checks. Tambien se probo el caso que mas importa para una plantilla: exportarla como copia virgen, inicializarla como repositorio nuevo y ejecutar la suite de validacion dentro de ese clon limpio.

## Resumen ejecutivo

Se modificaron areas de validacion, exportacion, higiene, presupuesto de contexto, generacion documental y memoria operativa.

Los resultados verificados fueron:

- `scripts/run-checks.ps1 -KeepGoing` en el repo maestro: OK.
- `scripts/run-checks.ps1 -KeepGoing` en un clon temporal exportado: OK.
- Tests Pester: 32/32 pasando.
- Warnings del presupuesto de contexto: 0.
- Criticals del presupuesto de contexto: 0.
- `check-cleanliness`: OK.
- `check-links`: OK.
- Export limpio via `scripts/deploy.ps1`: OK.
- Inicializacion de clon con `init-project.ps1 -InitGit -InstallHook -CreateCatalog -SkipChecks`: OK.

## Problemas encontrados

### 1. Los tests eran demasiado lentos en Windows

El primer bloqueo practico fue `scripts/test-scripts.ps1`.

Antes del cambio, el comando excedia 180 segundos en este entorno. Al analizar los tests de Pester se vio que cada workspace temporal copiaba el repo entero de forma recursiva, incluyendo dependencias y caches anidadas como:

- `.agent/mcp/semantic-server/node_modules`
- `node_modules`
- `.venv`
- `dist`
- `build`
- `out`
- `agente-rh-template`

Esto convertia cada test en una copia pesada de miles de archivos que no aportaban valor a la prueba.

### 2. El presupuesto de contexto tenia un warning permanente

`scripts/check-context-budget.ps1` avisaba siempre por el tamano de:

` .agent/skills/pdf-official/reference.md`

Ese archivo es una referencia larga de una skill externa. No es parte de la memoria rapida ni deberia cargarse de forma rutinaria. El warning era ruido operativo: no indicaba un problema real, pero hacia que la suite no quedara limpia visualmente.

### 3. `check-links` trataba `node_modules` como ruta interna obligatoria

Al documentar o mencionar rutas bajo `node_modules`, el validador de enlaces podia interpretarlas como rutas internas que debian existir.

Eso es una mala experiencia en una plantilla limpia porque `node_modules` debe estar excluido del repo. Un clon sano no debe tener dependencias vendorizadas.

### 4. Habia riesgo de mojibake en documentacion generada

Se detecto texto corrupto de codificacion en el indice generado de workflows y en algunos workflows:

- `brain/workflows-index.md`
- `.agent/workflows/code-review.md`
- `.agent/workflows/desarrollador-profundidad.md`
- `.agent/workflows/retrospectiva.md`

El problema no era solo estetico. En Windows, una mezcla de lecturas por defecto y contenido UTF-8 puede degradar la confianza en la plantilla y hacer que los agentes interpreten mal instrucciones o documenten basura.

### 5. `deploy.ps1` tenia fricciones propias de repo maestro

El script de exportacion tenia tres problemas:

- Usaba una ruta absoluta personal como valor por defecto.
- Excluia archivos que el manifiesto estructural marcaba como requeridos.
- Eliminaba por completo `brain/swarm`, aunque workflows internos referencian esa ruta.

Esto hacia que un export limpio pudiera fallar en `check-links` o depender de una ruta local concreta.

### 6. La prueba importante no estaba cubierta

El repo maestro podia pasar checks, pero eso no probaba que la plantilla funcionara al ser usada como plantilla.

La prueba relevante era:

1. Exportar una copia virgen.
2. Ejecutar checks dentro de esa copia.
3. Inicializar Git y hook.
4. Regenerar catalogo.
5. Ejecutar la suite completa dentro del clon.

Esa ruta no estaba validada hasta esta iteracion.

## Cambios por archivo

### `tests/Pester/TestHelpers.ps1`

Se reescribio la funcion de creacion de workspaces temporales.

Antes:

- Copiaba elementos de primer nivel con `Copy-Item -Recurse`.
- Excluia algunos nombres solo en el nivel superior.
- No evitaba dependencias anidadas, por ejemplo `.agent/mcp/semantic-server/node_modules`.

Ahora:

- Recorre el arbol manualmente con una pila.
- Aplica exclusiones a cualquier nivel del arbol.
- Usa un `HashSet` case-insensitive para nombres de directorio excluidos.
- Respeta `-IncludeGit` cuando un test necesita copiar `.git`.

Por que:

- Reduce drasticamente el tiempo de tests.
- Hace que los tests sean mas representativos de un repo limpio.
- Evita copiar basura operativa a cada workspace temporal.

Impacto medido:

- `test-scripts.ps1` paso de exceder 180 segundos a completar en torno a 40 segundos.
- La suite completa queda dentro de un tiempo razonable para uso diario.

### `scripts/check-links.ps1`

Se anadio una exclusion para tokens bajo `node_modules`.

Antes:

- Un fragmento inline como `node_modules/...` podia ser tratado como ruta interna rota.

Ahora:

- Cualquier token que apunte a `node_modules` se ignora en validacion de enlaces.

Por que:

- `node_modules` no debe existir en un repo limpio.
- Mencionar una ruta de dependencias en docs no debe obligar a versionarla.
- Evita falsos positivos en clones nuevos.

### `scripts/check-context-budget.ps1`

Se anadio soporte para exclusiones configurables mediante `excludePaths`.

Antes:

- Todos los archivos bajo los `scanPaths` entraban en el calculo.
- Referencias externas largas generaban warnings permanentes.

Ahora:

- El script lee `excludePaths` desde la configuracion.
- Normaliza rutas con `/`.
- Omite archivos excluidos tanto si el scan path apunta a un archivo como si apunta a un directorio.

Por que:

- El presupuesto de contexto debe vigilar memoria y docs operativas, no penalizar referencias externas que se consultan bajo demanda.
- Un warning permanente deja de ser senal util.

### `.agent/config/context-budget.json`

Se anadio:

```json
"excludePaths": [
  ".agent/skills/pdf-official/reference.md"
]
```

Por que:

- `reference.md` es una referencia larga de una skill PDF externa.
- No debe cargarse de forma rutinaria en contexto.
- Su tamano no representa un problema de memoria operativa.

Resultado:

- `check-context-budget` queda en `warnings: 0` y `criticals: 0`.

### `scripts/check-cleanliness.ps1`

Se reforzo la higiene del repo.

Cambios principales:

- Lectura explicita UTF-8 sin BOM.
- Deteccion de patrones tipicos de mojibake.
- Revision de archivos de texto operativos:
  - `.md`
  - `.ps1`
  - `.psm1`
  - `.json`
  - `.yml`
  - `.yaml`
  - `.txt`
- Exclusion de `.agent/skills/*` para no penalizar assets externos o referencias de skills.

Por que:

- Windows PowerShell puede mostrar o leer mal contenido si no se fuerza UTF-8.
- El mojibake es una friccion muy visible para una plantilla de agente.
- Si vuelve a entrar texto corrupto, la suite debe fallar pronto.

Detalle tecnico:

- Los tokens de mojibake se definen por codigo Unicode con `[char]`.
- Esto evita introducir literalmente secuencias corruptas dentro del propio script.

### `scripts/generate-workflows-docs.ps1`

Se corrigio el bloque que genera `brain/workflows-index.md`.

Antes:

- El indice generado contenia texto con mojibake.
- Al regenerar documentos, el problema podia volver.

Ahora:

- El texto generado queda en ASCII limpio.
- Las etiquetas del indice usan formas sin acento:
  - `Indice`
  - `Catalogo`
  - `Guia`
  - `Senal`
  - `Higienico`

Por que:

- La prioridad aqui es robustez en Windows y evitar friccion de codificacion.
- El repo ya contiene politica practica de salidas sin diacriticos en scripts.

### `brain/workflows-index.md`

Se regenero el indice de workflows con texto limpio.

Antes:

- Contenia texto corrupto equivalente a `navegacion` y `Guia`.

Ahora:

- Contiene texto estable y legible:
  - `navegacion`
  - `Guia`
  - `Catalogo de Despacho Rapido`

Por que:

- Es un documento operativo que los agentes consultan.
- Si esta corrupto, contamina la memoria y el `deep-summary`.

### `.agent/workflows/code-review.md`

Se sanearon fragmentos corruptos:

- Guiones largos corruptos.
- Iconos de severidad corruptos.
- Texto con mojibake en la descripcion.

Ejemplo de mejora:

- Antes: secuencias corruptas para severidades.
- Ahora:
  - `Critico`
  - `Importante`
  - `Mejora`
  - `Nit`

Por que:

- `code-review` es un workflow central.
- Una severidad corrupta reduce claridad justo donde se necesita precision.

### `.agent/workflows/desarrollador-profundidad.md`

Se corrigio una secuencia corrupta en la linea de quick wins.

Por que:

- Es un workflow clave para detectar producto incompleto.
- Su salida debe ser clara, accionable y sin ruido visual.

### `.agent/workflows/retrospectiva.md`

Se corrigieron guiones largos corruptos en el texto.

Por que:

- La retrospectiva se usa para aprendizaje operativo.
- Texto corrupto en documentos de proceso degrada confianza y legibilidad.

### `scripts/deploy.ps1`

Se endurecio el flujo de exportacion.

Cambios principales:

1. Ruta por defecto portable.

Antes:

```powershell
[string]$TargetDirectory = "R:\Escritorio\Ricardo Huertas\Repos GitHub\Agente RH - copia limpia actualizada"
```

Ahora:

- Si no se pasa `-TargetDirectory`, exporta a `agente-rh-template` dentro del repo.
- Si se pasa una ruta, usa esa ruta.

Por que:

- Una plantilla no debe depender de una ruta personal.
- Facilita uso en cualquier clon o maquina Windows.

2. No se excluye el workflow de GitHub requerido.

Antes:

- Se excluia `.github/workflows/windows-checks.yml`.

Problema:

- Ese archivo esta listado como requerido en `.agent/config/repo-structure.json`.

Ahora:

- Se conserva en el export.

Por que:

- El export debe respetar el manifiesto estructural.

3. No se elimina `scripts/deploy.ps1` del clon.

Antes:

- El script borraba `scripts/deploy.ps1`.

Problema:

- `scripts/deploy.ps1` esta en el manifiesto de archivos requeridos.
- Un clon limpio podia quedar inconsistente con `check-structure`.

Ahora:

- Solo se elimina el script obsoleto `update-template.ps1` si existiera.

Por que:

- `deploy.ps1` es parte de la herramienta de distribucion de la plantilla.

4. `brain/swarm` se limpia pero se conserva.

Antes:

- Se eliminaba todo `brain/swarm`.

Problema:

- Algunos workflows referencian `brain/swarm`.
- `check-links` fallaba en el export limpio porque la ruta no existia.

Ahora:

- Se borran archivos temporales dentro de `brain/swarm`.
- Se conserva o crea el directorio.
- Se asegura `brain/swarm/.gitkeep`.

Por que:

- Mantiene higiene sin romper enlaces internos.

5. Mensaje final preciso.

Antes:

- El mensaje final siempre decia que exportaba en `agente-rh-template`, aunque se usara otra ruta.

Ahora:

- Muestra la ruta real de exportacion.

Por que:

- En pruebas smoke y uso real, la salida debe ser fiable.

### `brain/now.md`

Se actualizo la capa rapida para reflejar el estado actual:

- Plantilla validada.
- Pester acelerado.
- Export limpio probado.
- Inicializacion de clon validada.

Por que:

- `now.md` debe decir al siguiente agente donde esta el trabajo realmente.

### `brain/current-state.md`

Se actualizo el estado operativo:

- Fecha de actualizacion.
- Riesgo principal bajo.
- Sin warnings activos en suite oficial.
- Proxima validacion recomendada antes de distribuir o clonar.

Por que:

- Es memoria rapida obligatoria para cambios relevantes.

### `brain/changelog.md`

Se registro el hito de optimizacion de validacion en Windows 11.

Incluye:

- Aceleracion de Pester.
- Exclusion configurable de referencias largas.
- Barrera anti-mojibake.
- Endurecimiento de `deploy.ps1`.
- Validacion de export temporal y clon inicializado.

Por que:

- El cambio afecta al modo de distribucion y validacion de la plantilla.
- Es un hito real de calidad operativa.

### `brain/deep-summary.md`

Se regenero con `scripts/update-brain-deep-summary.ps1`.

Por que:

- `brain/changelog.md` es archivo de capa profunda.
- La regla del repo exige mantener `deep-summary.md` sincronizado cuando cambia la capa profunda.

## Validaciones ejecutadas

### Validacion en repo maestro

Comando:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1 -KeepGoing
```

Resultado:

- `check-structure`: OK.
- `generate-workflows-docs`: OK.
- `generate-catalog`: OK.
- `check-crossrefs`: OK.
- `check-links`: OK.
- `check-skills-catalog`: OK.
- `check-cleanliness`: OK.
- `check-brain-deep-summary-sync`: OK.
- `check-context-budget`: OK.
- `test-scripts`: OK.
- Pester: 32/32 tests pasando.
- Warnings: 0.
- Criticals: 0.

### Validacion de export limpio

Se creo un export temporal en:

```text
C:\Users\34634\AppData\Local\Temp\agente-rh-template-smoke-32f78b81-d1c9-4445-a586-0ae4c01214be
```

Comando base usado desde el repo maestro:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/deploy.ps1 -TargetDirectory <ruta-temporal>
```

Resultado:

- Export completado correctamente.
- `brain/deep-summary.md` regenerado dentro del export.
- Sin rutas personales obligatorias.

### Validacion rapida dentro del export

Comando:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1 -Fast -KeepGoing
```

Resultado:

- Checks rapidos OK.
- `check-links`: OK.
- `check-cleanliness`: OK.
- `check-context-budget`: warnings 0, criticals 0.

### Inicializacion de clon limpio

Comando dentro del export temporal:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/init-project.ps1 -InitGit -InstallHook -CreateCatalog -SkipChecks
```

Resultado:

- `git init`: OK.
- Hook pre-commit instalado: OK.
- `CATALOG.md` generado: OK.
- Inicializacion sin prompts: OK.
- No se activo la ruta de instalacion MCP porque no se proporciono metadata de proyecto.

### Validacion completa dentro del clon inicializado

Comando:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1 -KeepGoing
```

Resultado:

- Suite completa OK.
- Pester: 32/32 tests pasando.
- Warnings: 0.
- Criticals: 0.

### Validacion de diff

Comando:

```powershell
git diff --check
```

Resultado:

- Sin errores de whitespace.
- Solo avisos de normalizacion CRLF/LF en algunos archivos, esperables por configuracion Git.

## Por que estos cambios mejoran la plantilla

### Mejoran eficacia

La plantilla ahora detecta mas problemas reales:

- Mojibake en archivos operativos.
- Links rotos en export limpio.
- Presupuesto de contexto mal senalizado.
- Falta de directorios requeridos en clones.

Tambien reduce falsos positivos:

- `node_modules` deja de tratarse como ruta que debe existir.
- Referencias largas externas no generan ruido permanente.

### Mejoran eficiencia

La suite Pester ya no copia dependencias ni caches anidadas en cada test.

Esto hace que:

- Los checks se puedan ejecutar con mas frecuencia.
- La friccion para validar sea menor.
- El ciclo de feedback sea mas corto.

### Mejoran portabilidad

`deploy.ps1` ya no depende de una ruta absoluta personal.

El export funciona con una ruta temporal arbitraria y conserva los archivos requeridos por el manifiesto.

### Mejoran higiene

La plantilla conserva directorios estructurales como `brain/swarm`, pero elimina contenido efimero.

Esto mantiene el balance correcto:

- Repo limpio.
- Links internos validos.
- Estructura preparada para uso real.

### Mejoran robustez en Windows

Los cambios fuerzan lectura UTF-8 donde importaba y evitan texto generado con mojibake.

Esto es especialmente importante porque el entorno objetivo es Windows 11 y PowerShell.

## Riesgos y decisiones conscientes

### Se uso texto ASCII en nuevos bloques generados

En algunos textos generados se prefirio:

- `Indice` en vez de `Indice` con acento.
- `Guia` en vez de `Guia` con acento.
- `Senal` en vez de `Senal` con tilde.

Decision:

- Priorizar estabilidad de codificacion en scripts y documentos generados.

Razon:

- El repo ya tiene historial de friccion por encoding.
- Para una plantilla de agente, legibilidad estable es mas importante que tipografia perfecta.

### No se excluyo toda `.agent/skills` del presupuesto

Solo se excluyo una referencia concreta:

` .agent/skills/pdf-official/reference.md`

Decision:

- Mantener vigilancia sobre skills locales salvo referencias largas justificadas.

Razon:

- Excluir demasiado podria ocultar deuda real.
- La exclusion concreta elimina ruido sin debilitar el control general.

### No se instalo MCP en la prueba smoke

La prueba de inicializacion uso:

```powershell
init-project.ps1 -InitGit -InstallHook -CreateCatalog -SkipChecks
```

No se pasaron `ProjectName`, `ProjectVision` ni `FirstDeliverable`.

Decision:

- Evitar modificar configuracion global del IDE durante una prueba temporal.

Razon:

- La ruta de instalacion MCP toca configuracion de Antigravity/Gemini en el perfil de usuario.
- Para validar export e inicializacion base, no era necesario registrar un MCP temporal.

## Estado final

La plantilla queda en un estado significativamente mas fuerte:

- Repo maestro validado.
- Export limpio validado.
- Clon inicializado validado.
- Suite completa limpia.
- Barreras nuevas contra regresiones de encoding.
- Tests mas rapidos.
- Presupuesto de contexto sin ruido.
- Export mas portable y consistente con el manifiesto.

## Comandos recomendados antes de cerrar la iteracion

Antes de commit:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1 -KeepGoing
git diff --check
```

Antes de distribuir la plantilla:

```powershell
$target = Join-Path $env:TEMP ('agente-rh-template-smoke-' + [guid]::NewGuid().ToString())
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/deploy.ps1 -TargetDirectory $target
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $target 'scripts/run-checks.ps1') -KeepGoing
```

Para probar inicializacion de un clon:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/init-project.ps1 -InitGit -InstallHook -CreateCatalog -SkipChecks
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/run-checks.ps1 -KeepGoing
```

## Archivos modificados por esta iteracion

Lista de archivos con cambios relevantes:

- `.agent/config/context-budget.json`
- `.agent/workflows/code-review.md`
- `.agent/workflows/desarrollador-profundidad.md`
- `.agent/workflows/retrospectiva.md`
- `brain/changelog.md`
- `brain/current-state.md`
- `brain/deep-summary.md`
- `brain/now.md`
- `brain/workflows-index.md`
- `docs/template-hardening-2026-05-25.md`
- `scripts/check-cleanliness.ps1`
- `scripts/check-context-budget.ps1`
- `scripts/check-links.ps1`
- `scripts/deploy.ps1`
- `scripts/generate-workflows-docs.ps1`
- `tests/Pester/TestHelpers.ps1`

## Conclusion

La intervencion redujo friccion real en tres puntos criticos:

1. Validacion local mas rapida.
2. Export de plantilla mas portable y correcto.
3. Clon limpio verificable de extremo a extremo.

La plantilla queda mas cerca del objetivo de ser una base de agente eficaz, eficiente y sin sorpresas para Antigravity Desktop 2.0 en Windows 11.
