# Checklist de Ejecución: [Título de la Tarea]

> [!NOTE]
> Esta checklist se gestiona de forma interactiva durante la sesión de trabajo. El agente principal y los subagentes deben marcar el progreso secuencial de cada bloque operativo.

## 📊 Estado de Avance General
```
[░░░░░░░░░░░░░░░░░░░░] 0% Completado
```

---

## 🛠️ Bloques de Trabajo

- [ ] **1. Fase de Preparación y Alineación**
  - [ ] Validar prerrequisitos locales en Windows y dependencias en `brain/stack.md`
  - [ ] Sincronizar capa rápida de memoria (`now.md`, `current-state.md`)
  - [ ] Confirmar aprobación formal del `implementation_plan.md`

- [ ] **2. Fase de Desarrollo Quirúrgico**
  - [ ] Implementar cambios lógicos en los componentes acotados
  - [ ] Ejecutar re-estructuración o refactorización incremental
  - [ ] Asegurar higiene documental (comentarios y cabeceras)

- [ ] **3. Fase de Calidad y Verificación (QA)**
  - [ ] Escribir o expandir suite de tests locales
  - [ ] Ejecutar validadores automáticos y suite completa (`run-checks.ps1`)
  - [ ] Realizar pruebas manuales de regresión en entorno local

- [ ] **4. Fase de Cierre y Handoff Operativo**
  - [ ] Generar el reporte `walkthrough.md` interactivo en la raíz
  - [ ] Invocar al subagente `CleanlinessGuardian` en modo `inherit`
  - [ ] Limpiar archivos efímeros o temporales (`*.tmp`, `.bak`, etc.)
  - [ ] Compactar log histórico bajo `brain/session_logs/`
  - [ ] Sincronizar y actualizar memoria rápida del cerebro (`now.md`, `current-state.md`, `deep-summary.md`)
