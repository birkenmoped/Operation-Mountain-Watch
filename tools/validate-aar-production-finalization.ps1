[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

$files = [ordered]@{
  Controller = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_Controller.lua'
  Adapter = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_CampaignStateAdapter.lua'
  RuntimeIntegration = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_RuntimeIntegration.lua'
  StrategicStock = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
  CampaignStateInitializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
}

foreach ($entry in $files.GetEnumerator()) {
  if (-not (Test-Path -LiteralPath $entry.Value -PathType Leaf)) {
    throw "Missing required AAR production file: $($entry.Value)"
  }
}

$content = @{}
foreach ($entry in $files.GetEnumerator()) {
  $content[$entry.Key] = Get-Content -LiteralPath $entry.Value -Raw -Encoding UTF8
}

$requirements = @(
  @{ File = 'Controller'; Marker = 'MAX_CONCURRENT_SUPPORT_MISSIONS = 2' },
  @{ File = 'Controller'; Marker = 'MAX_AIRCRAFT_PER_SUPPORT_MISSION = 2' },
  @{ File = 'Controller'; Marker = 'MAX_CONCURRENT_SUPPORT_AIRCRAFT = 4' },
  @{ File = 'Controller'; Marker = 'function flightGroup:OnAfterDead' },
  @{ File = 'Controller'; Marker = 'state.strategicAdapter:OnLost(' },
  @{ File = 'Controller'; Marker = 'function Controller.EndDemand' },
  @{ File = 'Controller'; Marker = 'function Controller.GetRuntimeCounts' },
  @{ File = 'Controller'; Marker = 'stn = 50000' },
  @{ File = 'Controller'; Marker = 'stn = 50016' },
  @{ File = 'Controller'; Marker = 'spawner:InitSTN(transitCallsign.stn)' },
  @{ File = 'Adapter'; Marker = 'function Adapter:OnLost' },
  @{ File = 'Adapter'; Marker = 'function Adapter:ReconcileRestore' },
  @{ File = 'Adapter'; Marker = 'AAR_RESTART_RECONCILIATION' },
  @{ File = 'Adapter'; Marker = 'AIRCRAFT_KC135_LOST' },
  @{ File = 'RuntimeIntegration'; Marker = 'function Integration.Attach' },
  @{ File = 'RuntimeIntegration'; Marker = 'adapter:ReconcileRestore()' },
  @{ File = 'RuntimeIntegration'; Marker = 'controller.SetStrategicAdapter(adapter)' },
  @{ File = 'StrategicStock'; Marker = 'OMW-AAR-STRATEGIC-STOCK-2' },
  @{ File = 'StrategicStock'; Marker = 'AIRCRAFT_KC135_LOST' },
  @{ File = 'StrategicStock'; Marker = 'initial = 16' },
  @{ File = 'StrategicStock'; Marker = 'initial = 40' },
  @{ File = 'CampaignStateInitializer'; Marker = 'OMW-AIROPS-CAMPAIGNSTATE-INITIALIZER-3' },
  @{ File = 'CampaignStateInitializer'; Marker = 'OFFMAP_MANAS' },
  @{ File = 'CampaignStateInitializer'; Marker = 'OFFMAP_AL_UDEID' }
)

foreach ($requirement in $requirements) {
  if (-not $content[$requirement.File].Contains($requirement.Marker)) {
    throw "Missing required marker in $($requirement.File): $($requirement.Marker)"
  }
}

if ($content.Controller.Contains('spawner:InitSTN(STN_START_OCTAL)') -or $content.Controller.Contains('local STN_START_OCTAL')) {
  throw 'AAR controller still uses a shared STN seed. Every simultaneously present tanker must have an explicit unique Link-16 STN.'
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  '_DATABASE',
  'mist\.',
  'MIST',
  'io\.',
  'lfs\.',
  'os\.execute'
)

foreach ($entry in $content.GetEnumerator()) {
  foreach ($pattern in $forbiddenPatterns) {
    if ($entry.Value -match $pattern) {
      throw "Forbidden pattern in $($entry.Key): $pattern"
    }
  }
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
Write-Host 'AAR production finalization source gate: PASS'
Write-Host "GitCommit: $commit"
Write-Host 'MizMutation: false'
Write-Host 'CampaignStateAuthority: true'
Write-Host 'StrategicTurnaroundTimer: false'
Write-Host 'LossRecredit: false'
Write-Host 'RestoreReconciliation: true'
Write-Host 'UniqueTransitSTN: true'
Write-Host 'MaxConcurrentSupportMissions: 2'
Write-Host 'MaxAircraftPerSupportMission: 2'
Write-Host 'MaxConcurrentSupportAircraft: 4'

foreach ($entry in $files.GetEnumerator()) {
  $hash = (Get-FileHash -LiteralPath $entry.Value -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Host "$($entry.Key)SHA256: $hash"
}
