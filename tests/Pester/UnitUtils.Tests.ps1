# tests/Pester/UnitUtils.Tests.ps1
$libPath = Join-Path $PSScriptRoot '../../scripts/lib'
Import-Module (Join-Path $libPath 'brain-utils.psm1') -Force
Import-Module (Join-Path $libPath 'link-utils.psm1') -Force

Describe 'Unit Tests - brain-utils' {
  Context 'Get-BrainBlock / Set-BrainBlock' {
    It 'Extrae correctamente un bloque multilínea de prueba' {
      $content = @"
# Titulo
<!-- TEST-BLOCK:START -->
Contenido del Bloque
Segunda linea
<!-- TEST-BLOCK:END -->
Resto del archivo
"@
      $block = Get-BrainBlock -Content $content -BlockId 'TEST-BLOCK'
      $block | Should Match 'Contenido del Bloque'
      $block | Should Match 'Segunda linea'
    }

    It 'Reemplaza limpiamente el bloque manteniendo el contexto exterior' {
      $content = "Antes<!-- TEST-BLOCK:START -->Viejo<!-- TEST-BLOCK:END -->Despues"
      $new = "<!-- TEST-BLOCK:START -->Nuevo<!-- TEST-BLOCK:END -->"
      $result = Set-BrainBlock -Content $content -BlockId 'TEST-BLOCK' -NewBlockContent $new
      $result | Should Be 'Antes<!-- TEST-BLOCK:START -->Nuevo<!-- TEST-BLOCK:END -->Despues'
    }
  }

  Context 'Resolve-MergedValue' {
    It 'Extrae valor simple' {
      $block = @"
- Estado: Exito
- Fase: Sprint 3
"@
      $val = Resolve-MergedValue -CurrentBlock $block -RegexPattern '- Estado:\s*(.*)' -NewValue ''
      $val | Should Be 'Exito'
    }
  }

  Context 'Resolve-MergedList' {
    It 'Parsea listas ignorando placeholders vacíos y saltos de carro' {
      $block = "## Integrantes`r`n- Juan Perez`r`n- (sin registros)`r`n- Maria Gomez`r`n"
      $list = Resolve-MergedList -CurrentBlock $block -RegexHeader 'Integrantes'
      $list.Count | Should Be 2
      $list[0] | Should Be 'Juan Perez'
      $list[1] | Should Be 'Maria Gomez'
    }
  }
}

Describe 'Unit Tests - link-utils' {
  Context 'Test-IgnoreLinkTarget' {
    It 'Ignora correctamente URLs externas y anclas' {
      (Test-IgnoreLinkTarget -Target 'https://github.com') | Should Be $true
      (Test-IgnoreLinkTarget -Target '#seccion-local') | Should Be $true
      (Test-IgnoreLinkTarget -Target 'mailto:admin@repo.com') | Should Be $true
      (Test-IgnoreLinkTarget -Target 'http://google.es') | Should Be $true
    }

    It 'Ignora archivos de planificación efímeros de Antigravity' {
      (Test-IgnoreLinkTarget -Target 'implementation_plan.md') | Should Be $true
      (Test-IgnoreLinkTarget -Target 'task.md') | Should Be $true
    }

    It 'NO ignora enlaces absolutos locales a la raíz del repositorio' {
      (Test-IgnoreLinkTarget -Target '/brain/now.md') | Should Be $false
    }
  }

  Context 'Test-PathToken' {
    It 'Resuelve correctamente enlaces relativos a la raiz' {
      $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
      $testFile = Join-Path $repoRoot 'README.md'
      
      # Link absoluto local /README.md debería retornar null (éxito) ya que README.md existe
      $res = Test-PathToken -SourcePath $testFile -Token '/README.md' -repoRoot $repoRoot
      [string]::IsNullOrWhiteSpace($res) | Should Be $true
    }

    It 'Resuelve correctamente hipervínculos con codificación URL de espacios (%20)' {
      $fakeRepoRoot = Join-Path $env:TEMP ('agente-rh-fake-repo-' + [guid]::NewGuid().ToString())
      New-Item -ItemType Directory -Path $fakeRepoRoot -Force | Out-Null
      $tempFile = Join-Path $fakeRepoRoot 'test archivo temp.md'
      New-Item -ItemType File -Path $tempFile -Force | Out-Null
      try {
        $res = Test-PathToken -SourcePath $tempFile -Token 'test%20archivo%20temp.md' -repoRoot $fakeRepoRoot
        [string]::IsNullOrWhiteSpace($res) | Should Be $true
      } finally {
        Remove-Item -LiteralPath $fakeRepoRoot -Recurse -Force -ErrorAction SilentlyContinue
      }
    }
  }
}
