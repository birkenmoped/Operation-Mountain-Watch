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
  @{ File = 'Controller'; Marker = 'CORE_TRACK_COUNT = 6' },
  @{ File = 'Controller'; Marker = 'MAX_AIRCRAFT_PER_TRACK = 2' },
  @{ File = 'Controller'; Marker = 'LISA = {' },
  @{ File = 'Controller'; Marker = 'MOE = {' },
  @{ File = 'Controller'; Marker = 'coreProfile = "FAST"' },
  @{ File = 'Controller'; Marker = 'function Controller.StartContinuousCoreCoverage()' },
  @{ File = 'Controller'; Marker = 'CORE_TRACK_RETAINED' },
  @{ File = 'Controller'; Marker = 'stationAction=RETAIN_CONTINUOUS_CORE' },
  @{ File = 'Controller'; Marker = 'function flightGroup:OnAfterDead' },
  @{ File = 'Controller'; Marker = 'state.strategicAdapter:OnLost(' },
  @{ File = 'Controller'; Marker = 'function Controller.EndDemand' },
  @{ File = 'Controller'; Marker = 'function Controller.GetRuntimeCounts' },
  @{ File = 'Controller'; Marker = 'spawnedUnit:GetSTN()' },
  @{ File = 'Controller'; Marker = 'continuousAvailabilityPolicy = true' },
  @{ File = 'Controller'; Marker = 'globalAarMissionLimit = false' },
  @{ File = 'Controller'; Marker = 'globalAarAircraftLimit = false' },
  @{ File = 'Controller'; Marker = 'mooseManagedSpawnStn = true' },
  @{ File = 'Adapter'; Marker = 'function Adapter:OnLost' },
  @{ File = 'Adapter'; Marker = 'function Adapter:ReconcileRestore' },
  @{ File = 'Adapter'; Marker = 'AAR_RESTART_RECONCILIATION' },
  @{ File = 'Adapter'; Marker = 'AIRCRAFT_KC135_LOST' },
  @{ File = 'RuntimeIntegration'; Marker = 'function Integration.Attach' },
  @{ File = 'RuntimeIntegration'; Marker = 'adapter:ReconcileRestore()' },
  @{ File = 'RuntimeIntegration'; Marker = 'controller.SetStrategicAdapter(adapter)' },
  @{ File = 'RuntimeIntegration'; Marker = 'controller.StartContinuousCoreCoverage()' },
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

if ($content.Controller -notmatch 'LISA\s*=\s*\{[\s\S]*?coreProfile\s*=\s*"FAST"') {
  throw 'LISA continuous core profile is not FAST.'
}
if ($content.Controller -notmatch 'MOE\s*=\s*\{[\s\S]*?coreProfile\s*=\s*"FAST"') {
  throw 'MOE continuous core profile is not FAST.'
}

$forbiddenControllerMarkers = @(
  'MAX_CONCURRENT_SUPPORT_MISSIONS',
  'MAX_CONCURRENT_SUPPORT_AIRCRAFT',
  'MAX_AIRCRAFT_PER_SUPPORT_MISSION',
  'spawner:InitSTN(',
  'local STN_START_OCTAL',
  'return station, "STATION_CLOSED"'
)

foreach ($marker in $forbiddenControllerMarkers) {
  if ($content.Controller.Contains($marker)) {
    throw "AAR controller still contains obsolete AAR marker: $marker"
  }
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
Write-Host 'ContinuousCoreTracks: 6'
Write-Host 'LISAProfile: FAST'
Write-Host 'MOEProfile: FAST'
Write-Host 'MissionDemandClosesCoreTrack: false'
Write-Host 'GlobalAarMissionLimit: false'
Write-Host 'GlobalAarAircraftLimit: false'
Write-Host 'MaxAircraftPerTrack: 2'
Write-Host 'ExpectedMaxPhysicalDuringAllTrackRelief: 12'
Write-Host 'MooseManagedSpawnSTN: true'

foreach ($entry in $files.GetEnumerator()) {
  $hash = (Get-FileHash -LiteralPath $entry.Value -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Host "$($entry.Key)SHA256: $hash"
}
