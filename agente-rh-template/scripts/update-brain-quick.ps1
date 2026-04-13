[CmdletBinding()]
param(
  [string]$SummaryNow = 'Sin resumen nuevo.',
  [string]$NextAction = 'Pendiente definir.',
  [string[]]$Blockers = @('Ninguno.'),
  [string]$CurrentState = 'activo',
  [string]$Risk = 'no definido',
  [string]$UpdatedBy = 'agent',
  [string]$Phase,
  [string]$ProjectVision,
  [string[]]$ProjectGoals,
  [string[]]$ScopeIn,
  [string[]]$ScopeOut,
  [string]$StackFrontend,
  [string]$StackBackend,
  [string]$StackDatabase,
  [string]$StackInfrastructure,
  [string]$StackHosting,
  [string]$StackRationale,
  [string[]]$StackAlternatives,
  [string[]]$StackVersions,
  [string[]]$StackCriticalDependencies,
  [switch]$SyncDeepSummary
)

$ErrorActionPreference = 'Stop'
$syncScript = Join-Path $PSScriptRoot 'sync-brain.ps1'
& $syncScript @PSBoundParameters
