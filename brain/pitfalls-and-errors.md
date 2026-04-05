# Pitfalls and Errors

## Registros

- ~~**check-links.ps1 se cuelga con archivos .md largos**~~: **RESUELTO 2026-04-05** — Implementado timeout de 10s por archivo (Start-Job) y skip de archivos >200KB. El script completa sin cuelgues.
- **Encoding mixto LF/CRLF en archivos del repo**: Algunos editores o herramientas pueden reintroducir `\r\n`. El `.editorconfig` define `end_of_line = lf`. Si aparecen diffs con solo cambios de line ending, normalizar con: `(Get-Content -Raw $file) -replace "\r\n", "\n" | Set-Content $file -NoNewline`.
