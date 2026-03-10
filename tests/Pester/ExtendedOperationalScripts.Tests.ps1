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

  It 'regenera CATALOG.md minimo cuando no hay skills locales' {
    $workspace = New-TestWorkspace
    try {
      Remove-Item -LiteralPath (Join-Path $workspace 'CATALOG.md') -Force

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\generate-catalog.ps1'
      $result.ExitCode | Should Be 0

      $catalogRaw = Get-WorkspaceFileRaw -Workspace $workspace -RelativePath 'CATALOG.md'
      $catalogRaw | Should Match 'Catalogo local generado automaticamente'
      $catalogRaw | Should Match '\(sin registros\)'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'detecta enlaces internos rotos' {
    $workspace = New-TestWorkspace
    try {
      $readmePath = Join-Path $workspace 'README.md'
      $readmeRaw = Get-Content -Path $readmePath -Raw
      $readmeRaw += "`r`n`r`n[Enlace roto](docs/no-existe.md)`r`n"
      Set-Content -Path $readmePath -Encoding UTF8 -Value $readmeRaw

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\check-links.ps1'
      $result.ExitCode | Should Be 1
      $result.Output | Should Match 'docs/no-existe.md'
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

Describe 'init-project.ps1' {
  $stacks = @(
    @{
      Id = 'node-api'
      ProjectName = 'Demo API'
      Vision = 'Crear una API base para pruebas'
      Deliverable = 'endpoint de health'
      ExpectedPath = 'src\index.ts'
    },
    @{
      Id = 'next-app'
      ProjectName = 'Demo Web'
      Vision = 'Crear una web base para pruebas'
      Deliverable = 'pantalla inicial'
      ExpectedPath = 'app\page.tsx'
    },
    @{
      Id = 'python-cli'
      ProjectName = 'Demo CLI'
      Vision = 'Crear una CLI base para pruebas'
      Deliverable = 'comando principal'
      ExpectedPath = 'src\demo_cli\cli.py'
    }
  )

  foreach ($stackCase in $stacks) {
    It "scaffoldea $($stackCase.Id) y deja checks en verde" {
      $workspace = New-TestWorkspace
      try {
        $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\init-project.ps1' -Arguments @(
          '-InitGit',
          '-CreateCatalog',
          '-Stack', $stackCase.Id,
          '-ProjectName', $stackCase.ProjectName,
          '-ProjectVision', $stackCase.Vision,
          '-FirstDeliverable', $stackCase.Deliverable
        )

        $result.ExitCode | Should Be 0
        (Test-Path -LiteralPath (Join-Path $workspace $stackCase.ExpectedPath) -PathType Leaf) | Should Be $true

        $checks = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\run-checks.ps1'
        $checks.ExitCode | Should Be 0
      } finally {
        Remove-TestWorkspace -Workspace $workspace
      }
    }
  }

  It 'falla si hay colision de scaffold sin ForceScaffold' {
    $workspace = New-TestWorkspace
    try {
      Set-Content -Path (Join-Path $workspace 'package.json') -Encoding UTF8 -Value '{}'

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\init-project.ps1' -Arguments @(
        '-Stack', 'node-api',
        '-ProjectName', 'Colision API',
        '-ProjectVision', 'Probar colisiones',
        '-FirstDeliverable', 'endpoint inicial'
      )

      $result.ExitCode | Should Be 1
      $result.Output | Should Match 'Scaffold abortado por colisiones'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'crea commit inicial solo si no existe HEAD' {
    $workspace = New-TestWorkspace
    $gitEnv = @{
      GIT_AUTHOR_NAME = 'Codex Test'
      GIT_AUTHOR_EMAIL = 'codex@example.com'
      GIT_COMMITTER_NAME = 'Codex Test'
      GIT_COMMITTER_EMAIL = 'codex@example.com'
    }

    try {
      $firstRun = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\init-project.ps1' -Environment $gitEnv -Arguments @(
        '-InitGit',
        '-CreateCatalog',
        '-Stack', 'node-api',
        '-ProjectName', 'Commit API',
        '-ProjectVision', 'Validar commit inicial',
        '-FirstDeliverable', 'endpoint inicial',
        '-CreateInitialCommit'
      )

      $firstRun.ExitCode | Should Be 0
      $head = Invoke-GitCommand -Workspace $workspace -Arguments @('rev-parse', '--verify', 'HEAD') -Environment $gitEnv
      $head.ExitCode | Should Be 0

      $secondRun = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\init-project.ps1' -Environment $gitEnv -Arguments @(
        '-CreateInitialCommit'
      )

      $secondRun.ExitCode | Should Be 1
      $secondRun.Output | Should Match 'ya tiene commits'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }
}
