$env:TEMP='/tmp'
$ErrorActionPreference = 'Stop'
. ./tests/Pester/TestHelpers.ps1
$workspace = New-TestWorkspace

$result = Invoke-WorkspaceScript -Workspace $workspace -RelativeScript 'scripts/init-project.ps1' -Arguments @(
  '-InitGit',
  '-CreateCatalog',
  '-Stack', 'node-api',
  '-ProjectName', 'Demo API',
  '-ProjectVision', 'Crear una API base',
  '-FirstDeliverable', 'endpoint'
)
Write-Host "ExitCode: $($result.ExitCode)"
Write-Host "Output: $($result.Output)"
