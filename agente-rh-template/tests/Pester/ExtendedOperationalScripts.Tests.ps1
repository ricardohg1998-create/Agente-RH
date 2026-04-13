. "$PSScriptRoot\TestHelpers.ps1"

Describe 'sync-brain.ps1' {
  It 'preserva texto fuera de marcadores y actualiza project-overview' {
    $workspace = New-TestWorkspace
    try {
      $projectOverviewPath = 'brain\project-overview.md'
      $original = Get-WorkspaceFileRaw -Workspace $workspace -RelativePath $projectOverviewPath
      $decorated = "Nota manual previa`r`n`r`n$original`r`nNota manual final"
      Set-WorkspaceFileRaw -Workspace $workspace -RelativePath $projectOverviewPath -Content $decorated

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\sync-brain.ps1' -Arguments @(
        '-ProjectVision', 'Nueva vision del proyecto',
        '-ProjectGoals', 'Meta 1', 'Meta 2',
        '-ScopeIn', 'Incluido 1',
        '-ScopeOut', 'Fuera 1'
      )

      $result.ExitCode | Should Be 0
      $updated = Get-WorkspaceFileRaw -Workspace $workspace -RelativePath $projectOverviewPath
      $updated | Should Match 'Nota manual previa'
      $updated | Should Match 'Nota manual final'
      $updated | Should Match 'Nueva vision del proyecto'
      $updated | Should Match 'Meta 1'
      $updated | Should Match 'Incluido 1'
      $updated | Should Match 'Fuera 1'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'solo sincroniza deep-summary cuando se usa SyncDeepSummary' {
    $workspace = New-TestWorkspace
    try {
      $deepSummaryPath = Join-Path $workspace 'brain\deep-summary.md'
      $corrupted = Get-Content -Path $deepSummaryPath -Raw
      $corrupted = $corrupted -replace '(?s)<!-- QUICK-DEEP:START -->.*?<!-- QUICK-DEEP:END -->', "<!-- QUICK-DEEP:START -->`r`n## Resumen profundo (auto)`r`n`r`n- DESINCRONIZADO`r`n<!-- QUICK-DEEP:END -->"
      Set-Content -Path $deepSummaryPath -Encoding UTF8 -Value $corrupted

      $withoutSync = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\sync-brain.ps1' -Arguments @(
        '-SummaryNow', 'Sin sync profundo'
      )
      $withoutSync.ExitCode | Should Be 0
      (Get-WorkspaceFileRaw -Workspace $workspace -RelativePath 'brain\deep-summary.md') | Should Match 'DESINCRONIZADO'

      $withSync = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\sync-brain.ps1' -Arguments @(
        '-SummaryNow', 'Con sync profundo',
        '-SyncDeepSummary'
      )
      $withSync.ExitCode | Should Be 0
      (Get-WorkspaceFileRaw -Workspace $workspace -RelativePath 'brain\deep-summary.md') | Should Not Match 'DESINCRONIZADO'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }
}

Describe 'generadores y validadores' {
  It 'genera workflows docs y luego CheckOnly pasa' {
    $workspace = New-TestWorkspace
    try {
      $apply = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\generate-workflows-docs.ps1'
      $apply.ExitCode | Should Be 0

      $check = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\generate-workflows-docs.ps1' -Arguments @('-CheckOnly')
      $check.ExitCode | Should Be 0
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'falla si README deriva del bloque generado de workflows' {
    $workspace = New-TestWorkspace
    try {
      $readmePath = Join-Path $workspace 'README.md'
      $readmeRaw = Get-Content -Path $readmePath -Raw
      $readmeRaw = $readmeRaw -replace '\.agent/workflows/buscar-skills\.md', '.agent/workflows/buscar-skills-ausente.md'
      Set-Content -Path $readmePath -Encoding UTF8 -Value $readmeRaw

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\generate-workflows-docs.ps1' -Arguments @('-CheckOnly')
      $result.ExitCode | Should Be 1
      $result.Output | Should Match 'README.md'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'regenera CATALOG.md y refleja skills disponibles' {
    $workspace = New-TestWorkspace
    try {
      Remove-Item -LiteralPath (Join-Path $workspace 'CATALOG.md') -Force

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\generate-catalog.ps1'
      $result.ExitCode | Should Be 0

      $catalogRaw = Get-WorkspaceFileRaw -Workspace $workspace -RelativePath 'CATALOG.md'
      $catalogRaw | Should Match 'Catalogo local generado automaticamente'
      # El workspace copiado tiene skills, asi que el catalogo debe reflejarlas
      $catalogRaw | Should Match 'Skills workspace'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'detecta enlaces internos rotos' {
    $workspace = New-TestWorkspace
    try {
      # Crear un archivo markdown simple con un enlace roto en una ruta escaneada
      $brainTestPath = Join-Path $workspace 'brain\test-broken-link.md'
      Set-Content -Path $brainTestPath -Encoding UTF8 -Value "# Test`r`n`r`n[Enlace roto](docs/no-existe.md)`r`n"

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\check-links.ps1'
      $result.ExitCode | Should Be 1
      $result.Output | Should Match 'no-existe.md'

      # Limpiar archivo temporal
      Remove-Item -LiteralPath $brainTestPath -Force -ErrorAction SilentlyContinue
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'ignora paquetes npm con scope dentro de codigo inline' {
    $workspace = New-TestWorkspace
    try {
      $readmePath = Join-Path $workspace 'README.md'
      $readmeRaw = Get-Content -Path $readmePath -Raw
      $readmeRaw += "`r`n`r`nDependencias utiles: ``@mui/material``, ``@tailwindcss/postcss`` y ``scripts/run-checks.ps1``.`r`n"
      Set-Content -Path $readmePath -Encoding UTF8 -Value $readmeRaw

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\check-links.ps1'
      $result.ExitCode | Should Be 0
      $result.Output | Should Match 'check-links: OK'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'detecta duplicacion fuerte incluyendo README, AGENTS y templates' {
    $workspace = New-TestWorkspace
    try {
      $paragraph = 'Este parrafo de prueba es deliberadamente largo para activar la deteccion de duplicacion fuerte del presupuesto de contexto y comprobar que README, AGENTS y templates forman parte real del escaneo configurado.'
      foreach ($relative in @('README.md', 'AGENTS.md', '.agent\templates\audit-template.md')) {
        $raw = Get-WorkspaceFileRaw -Workspace $workspace -RelativePath $relative
        Set-WorkspaceFileRaw -Workspace $workspace -RelativePath $relative -Content ($raw + "`r`n`r`n" + $paragraph)
      }

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\check-context-budget.ps1'
      $result.ExitCode | Should Be 1
      $result.Output | Should Match 'Duplicacion fuerte'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }
}

# DISABLED - Stack flag removed in v3. Kept as reference for future scaffolding tests.
# xDescribe is not supported in Pester 3.4. Use comment block instead.
#Describe 'init-project.ps1 scaffolding (DISABLED - Stack flag removed)' {
#  ... tests for node-api, next-app, python-cli stacks ...
#}
