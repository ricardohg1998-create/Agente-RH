. "$PSScriptRoot/TestHelpers.ps1"

Describe 'bootstrap.ps1' {
  It 'devuelve OK con CheckOnly en un repo sano' {
    $workspace = New-TestWorkspace
    try {
      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\bootstrap.ps1' -Arguments @('-CheckOnly')
      $result.ExitCode | Should -Be 0
      $result.Output | Should -Match 'Estructura minima OK'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'crea directorios y gitkeep seguros cuando faltan' {
    $workspace = New-TestWorkspace
    try {
      Remove-Item -LiteralPath (Join-Path $workspace 'src') -Recurse -Force

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\bootstrap.ps1'

      $result.ExitCode | Should -Be 0
      (Test-Path -LiteralPath (Join-Path $workspace 'src') -PathType Container) | Should -Be $true
      (Test-Path -LiteralPath (Join-Path $workspace 'src\.gitkeep') -PathType Leaf) | Should -Be $true
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'falla si faltan archivos versionados y no crea placeholders' {
    $workspace = New-TestWorkspace
    try {
      Remove-Item -LiteralPath (Join-Path $workspace 'AGENTS.md') -Force

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\bootstrap.ps1'

      $result.ExitCode | Should -Be 1
      (Test-Path -LiteralPath (Join-Path $workspace 'AGENTS.md')) | Should -Be $false
      $result.Output | Should -Match 'no genera placeholders'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }
}

Describe 'log-decision.ps1' {
  It 'falla si no existe brain/decisions.md' {
    $workspace = New-TestWorkspace
    try {
      Remove-Item -LiteralPath (Join-Path $workspace 'brain\decisions.md') -Force

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\log-decision.ps1' -Arguments @(
        '-Title', 'Test',
        '-Context', 'Ctx',
        '-Decision', 'Dec',
        '-Consequences', 'Cons'
      )

      $result.ExitCode | Should -Be 1
      $result.Output | Should -Match 'No existe'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'falla si no existe brain/changelog.md' {
    $workspace = New-TestWorkspace
    try {
      Remove-Item -LiteralPath (Join-Path $workspace 'brain\changelog.md') -Force

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\log-decision.ps1' -Arguments @(
        '-Title', 'Test',
        '-Context', 'Ctx',
        '-Decision', 'Dec',
        '-Consequences', 'Cons'
      )

      $result.ExitCode | Should -Be 1
      $result.Output | Should -Match 'No existe'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }
}

Describe 'update-brain-quick.ps1' {
  It 'mantiene la fase existente si no se pasa Phase' {
    $workspace = New-TestWorkspace
    try {
      $beforeState = Get-WorkspaceFileRaw -Workspace $workspace -RelativePath 'brain\current-state.md'
      $phaseMatch = [regex]::Match($beforeState, '(?m)^- Fase:\s*(.+?)\s*$')
      $expectedPhase = $phaseMatch.Groups[1].Value

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\update-brain-quick.ps1' -Arguments @(
        '-SummaryNow', 'Base revisada',
        '-NextAction', 'Preparar primer entregable'
      )

      $result.ExitCode | Should -Be 0
      (Get-WorkspaceFileRaw -Workspace $workspace -RelativePath 'brain\current-state.md') | Should -Match ('- Fase: ' + [regex]::Escape($expectedPhase))
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'actualiza la fase cuando se pasa Phase' {
    $workspace = New-TestWorkspace
    try {
      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\update-brain-quick.ps1' -Arguments @(
        '-Phase', 'implementacion'
      )

      $result.ExitCode | Should -Be 0
      (Get-WorkspaceFileRaw -Workspace $workspace -RelativePath 'brain\current-state.md') | Should -Match '- Fase: implementacion'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'no toca stack.md si no se pasan parametros de stack' {
    $workspace = New-TestWorkspace
    try {
      $before = Get-WorkspaceFileRaw -Workspace $workspace -RelativePath 'brain\stack.md'
      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\update-brain-quick.ps1' -Arguments @(
        '-SummaryNow', 'Sin tocar stack'
      )

      $result.ExitCode | Should -Be 0
      (Get-WorkspaceFileRaw -Workspace $workspace -RelativePath 'brain\stack.md') | Should -Be $before
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'actualiza stack.md solo cuando se pasan parametros de stack' {
    $workspace = New-TestWorkspace
    try {
      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\update-brain-quick.ps1' -Arguments @(
        '-StackFrontend', 'Next.js',
        '-StackBackend', 'Fastify',
        '-StackDatabase', 'PostgreSQL',
        '-StackRationale', 'Eleccion para arrancar el proyecto',
        '-StackVersions', 'Node 22', 'Next 15'
      )

      $result.ExitCode | Should -Be 0
      $stackRaw = Get-WorkspaceFileRaw -Workspace $workspace -RelativePath 'brain\stack.md'
      $stackRaw | Should -Match 'Frontend: Next.js'
      $stackRaw | Should -Match 'Backend: Fastify'
      $stackRaw | Should -Match 'Base de datos: PostgreSQL'
      $stackRaw | Should -Match 'Node 22'
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

      $withoutSync = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\update-brain-quick.ps1' -Arguments @(
        '-SummaryNow', 'Sin sync profundo'
      )
      $withoutSync.ExitCode | Should -Be 0
      (Get-WorkspaceFileRaw -Workspace $workspace -RelativePath 'brain\deep-summary.md') | Should -Match 'DESINCRONIZADO'

      $withSync = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\update-brain-quick.ps1' -Arguments @(
        '-SummaryNow', 'Con sync profundo',
        '-SyncDeepSummary'
      )
      $withSync.ExitCode | Should -Be 0
      (Get-WorkspaceFileRaw -Workspace $workspace -RelativePath 'brain\deep-summary.md') | Should -Not -Match 'DESINCRONIZADO'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }
}

Describe 'check-crossrefs.ps1' {
  It 'pasa en un repo consistente' {
    $workspace = New-TestWorkspace
    try {
      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\check-crossrefs.ps1'
      $result.ExitCode | Should -Be 0
      $result.Output | Should -Match 'check-crossrefs: OK'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'falla si README deja de referenciar un workflow real' {
    $workspace = New-TestWorkspace
    try {
      $readmePath = Join-Path $workspace 'README.md'
      $readmeRaw = Get-Content -Path $readmePath -Raw
      $readmeRaw = $readmeRaw -replace '\.agent/workflows/buscar-skills\.md', '.agent/workflows/buscar-skills-ausente.md'
      Set-Content -Path $readmePath -Encoding UTF8 -Value $readmeRaw

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\check-crossrefs.ps1'

      $result.ExitCode | Should -Be 1
      $result.Output | Should -Match 'README.md'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }
}

Describe 'check-skills-catalog.ps1' {
  It 'pasa cuando el catalogo local existe' {
    $workspace = New-TestWorkspace
    try {
      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\check-skills-catalog.ps1'
      $result.ExitCode | Should -Be 0
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'emite warning y no falla si falta el catalogo local pero existe fuente de sesion' {
    $workspace = New-TestWorkspace
    try {
      Remove-Item -LiteralPath (Join-Path $workspace 'CATALOG.md') -Force

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\check-skills-catalog.ps1'

      $result.ExitCode | Should -Be 0
      $result.Output | Should -Match 'WARN'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }

  It 'falla si falta el catalogo local y no hay fuente de sesion habilitada' {
    $workspace = New-TestWorkspace
    try {
      Remove-Item -LiteralPath (Join-Path $workspace 'CATALOG.md') -Force

      $configPath = Join-Path $workspace '.agent\config\skills-sources.json'
      $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
      foreach ($source in @($config.sessionSources)) {
        $source.enabled = $false
      }
      Set-Content -Path $configPath -Encoding UTF8 -Value ($config | ConvertTo-Json -Depth 10)

      $result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\check-skills-catalog.ps1'

      $result.ExitCode | Should -Be 1
      $result.Output | Should -Match 'Catalogo local faltante'
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }
}

Describe 'init-project.ps1' {
  It 'inicializa git, hook y catalogo de forma idempotente' {
    $workspace = New-TestWorkspace
    try {
      Remove-Item -LiteralPath (Join-Path $workspace 'CATALOG.md') -Force

      $firstRun = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\init-project.ps1' -Arguments @(
        '-InitGit',
        '-InstallHook',
        '-CreateCatalog'
      )

      $firstRun.ExitCode | Should -Be 0
      (Test-Path -LiteralPath (Join-Path $workspace '.git') -PathType Container) | Should -Be $true
      (Test-Path -LiteralPath (Join-Path $workspace '.git\hooks\pre-commit') -PathType Leaf) | Should -Be $true
      (Test-Path -LiteralPath (Join-Path $workspace 'CATALOG.md') -PathType Leaf) | Should -Be $true

      $secondRun = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts\init-project.ps1' -Arguments @(
        '-InitGit',
        '-InstallHook',
        '-CreateCatalog'
      )

      $secondRun.ExitCode | Should -Be 0

      # Clean up so we don't pollute subsequent tests if any exist that scan globally
      Remove-Item -LiteralPath (Join-Path $workspace '.git') -Recurse -Force
    } finally {
      Remove-TestWorkspace -Workspace $workspace
    }
  }
}
