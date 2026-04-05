# Pitfalls and Errors

## Registros

- **check-links.ps1 se cuelga con archivos .md largos**: El script entra en un bucle de lectura o timeout cuando procesa archivos markdown con muchas lineas (>500). Workaround actual: saltar el check manualmente o ejecutar `run-checks.ps1` sabiendo que puede colgar en ese paso. Bug preexistente, pendiente de fix con timeout por archivo.
- **Encoding mixto LF/CRLF en archivos del repo**: Algunos archivos tienen `\n` y otros `\r\n`, lo que genera diffs innecesarios en git. El `.editorconfig` define `lf` pero no todos los archivos lo respetan. Workaround: normalizar con `dos2unix` o un script de formateo.
