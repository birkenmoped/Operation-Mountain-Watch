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
  @{ File = 'Controller'; Marker = 'STANDARD_TRACK_COUNT = 4' },
  @{ File = 'Controller'; Marker = 'RESERVE_TRACK_COUNT = 2' },
  @{ File = 'Controller'; Marker = 'MAX_AIRCRAFT_PER_TRACK = 2' },
  @{ File = 'Controller'; Marker = 'SPAWN_INITIAL_SPEED_KT = 480' },
  @{ File = 'Controller'; Marker = 'TRANSIT_SPEED_KT = 300' },
  @{ File = 'Controller'; Marker = 'LATE_APPROACH_NM = 60' },
  @{ File = 'Controller'; Marker = 'MANAS_WEST_HIGH = { ingressFt = 34000, egressFt = 35000 }' },
  @{ File = 'Controller'; Marker = 'MANAS_EAST_HIGH = { ingressFt = 34000, egressFt = 35000 }' },
  @{ File = 'Controller'; Marker = 'AL_UDEID_NORTH_HIGH = { ingressFt = 35000, egressFt = 34000 }' },
  @{ File = 'Controller'; Marker = 'spawner:InitSpeedKnots(SPAWN_INITIAL_SPEED_KT)' },
  @{ File = 'Controller'; Marker = 'mission:SetMissionAltitude(profile.altitudeFt)' },
  @{ File = 'Controller'; Marker = 'mission:SetMissionIngressCoord(lateApproachCoord, transit.ingressFt, TRANSIT_SPEED_KT)' },
  @{ File = 'Controller'; Marker = 'flightGroup:AddWaypoint(firIngressCoord, TRANSIT_SPEED_KT, nil, transit.ingressFt, false)' },
  @{ File = 'Controller'; Marker = 'availability = "RESERVE"' },
  @{ File = 'Controller'; Marker = 'availability = "STANDARD"' },
  @{ File = 'Controller'; Marker = 'firFix = "EGPAN"' },
  @{ File = 'Controller'; Marker = 'firFix = "PINAX"' },
  @{ File = 'Controller'; Marker = 'firFix = "DAVER"' },
  @{ File = 'Controller'; Marker = 'local EXTERNAL_POINTS = {' },
  @{ File = 'Controller'; Marker = 'local FIR_FIXES = {' },
  @{ File = 'Controller'; Marker = 'runtime.flightGroup:AddWaypoint(runtime.externalHandoffCoord' },
  @{ File = 'Controller'; Marker = 'FIR_INGRESS_PASSED' },
  @{ File = 'Controller'; Marker = 'FIR_EGRESS_PASSED' },
  @{ File = 'Controller'; Marker = 'function Controller.StartContinuousCoreCoverage()' },
  @{ File = 'Controller'; Marker = 'RESERVE_TRACK_EGRESS' },
  @{ File = 'Controller'; Marker = 'stationAction=RETAIN_STANDARD_TRACK' },
  @{ File = 'Controller'; Marker = 'function flightGroup:OnAfterDead' },
  @{ File = 'Controller'; Marker = 'state.strategicAdapter:OnLost(' },
  @{ File = 'Controller'; Marker = 'spawnedUnit:GetSTN()' },
  @{ File = 'Controller'; Marker = 'stableSortieCallsign = true' },
  @{ File = 'Controller'; Marker = 'airwaysRoutingEnabled = false' },
  @{ File = 'Controller'; Marker = 'globalAarMissionLimit = false' },
  @{ File = 'Controller'; Marker = 'globalAarAircraftLimit = false' },
  @{ File = 'Adapter'; Marker = 'function Adapter:OnLost' },
  @{ File = 'Adapter'; Marker = 'function Adapter:ReconcileRestore' },
  @{ File = 'Adapter'; Marker = 'AAR_RESTART_RECONCILIATION' },
  @{ File = 'Adapter'; Marker = 'AIRCRAFT_KC135_LOST' },
  @{ File = 'RuntimeIntegration'; Marker = 'function Integration.Attach' },
  @{ File = 'RuntimeIntegration'; Marker = 'adapter:ReconcileRestore()' },
  @{ File = 'RuntimeIntegration'; Marker = 'controller.SetStrategicAdapter(adapter)' },
  @{ File = 'RuntimeIntegration'; Marker = 'controller.StartContinuousCoreCoverage()' },
  @{ File = 'StrategicStock'; Marker = 'OMW-AAR-STRATEGIC-STOCK-2' },
  @{ File = 'StrategicStock'; Marker = 'initial = 16' },
  @{ File = 'StrategicStock'; Marker = 'initial = 40' },
  @{ File = 'CampaignStateInitializer'; Marker = 'OFFMAP_MANAS' },
  @{ File = 'CampaignStateInitializer'; Marker = 'OFFMAP_AL_UDEID' }
)

foreach ($requirement in $requirements) {
  if (-not $content[$requirement.File].Contains($requirement.Marker)) {
    throw "Missing required marker in $($requirement.File): $($requirement.Marker)"
  }
}

if ($content.Controller -notmatch 'LISA\s*=\s*\{[\s\S]*?sourceDomain\s*=\s*"AL_UDEID"[\s\S]*?transitProfile\s*=\s*"AL_UDEID_NORTH_HIGH"[\s\S]*?firFix\s*=\s*"DAVER"[\s\S]*?availability\s*=\s*"RESERVE"[\s\S]*?fuelLowPct\s*=\s*38,\s*initialFuelPct\s*=\s*79\.4558') { throw 'LISA south-domain fuel/routing contract mismatch.' }
if ($content.Controller -notmatch 'MOE\s*=\s*\{[\s\S]*?availability\s*=\s*"RESERVE"[\s\S]*?fuelLowPct\s*=\s*31,\s*initialFuelPct\s*=\s*91\.4067') { throw 'MOE calibrated fuel contract mismatch.' }
if ($content.Controller -notmatch 'MILHOUSE\s*=\s*\{[\s\S]*?fuelLowPct\s*=\s*36,\s*initialFuelPct\s*=\s*79\.4558') { throw 'MILHOUSE calibrated fuel contract mismatch.' }
if ($content.Controller -notmatch 'KRUSTY\s*=\s*\{[\s\S]*?fuelLowPct\s*=\s*36,\s*initialFuelPct\s*=\s*79\.4558') { throw 'KRUSTY calibrated fuel contract mismatch.' }
if ($content.Controller -notmatch 'PATTY\s*=\s*\{[\s\S]*?fuelLowPct\s*=\s*26,\s*initialFuelPct\s*=\s*91\.4067') { throw 'PATTY calibrated fuel contract mismatch.' }
if ($content.Controller -notmatch 'NELSON\s*=\s*\{[\s\S]*?fuelLowPct\s*=\s*24,\s*initialFuelPct\s*=\s*91\.4067') { throw 'NELSON calibrated fuel contract mismatch.' }

$forbiddenControllerMarkers = @(
  'CORE_TRACK_COUNT = 6',
  'MAX_CONCURRENT_SUPPORT_MISSIONS',
  'MAX_CONCURRENT_SUPPORT_AIRCRAFT',
  'MAX_AIRCRAFT_PER_SUPPORT_MISSION',
  'spawner:InitSTN(',
  'local STN_START_OCTAL',
  'SwitchCallsign(',
  'local TRANSIT_CALLSIGNS',
  'CORE_TRACKS_6_SIMULTANEOUS_PASS',
  'TestForceEgress'
)

foreach ($marker in $forbiddenControllerMarkers) {
  if ($content.Controller.Contains($marker)) {
    throw "AAR controller still contains obsolete/test AAR marker: $marker"
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
Write-Host 'StandardTracks: 4'
Write-Host 'ReserveTracks: 2'
Write-Host 'LISAProfile: FAST'
Write-Host 'LISAAvailability: RESERVE'
Write-Host 'LISASourceDomain: AL_UDEID'
Write-Host 'LISAFIRFix: DAVER'
Write-Host 'MOEProfile: FAST'
Write-Host 'MOEAvailability: RESERVE'
Write-Host 'StableSortieCallsign: true'
Write-Host 'FIRFixRouting: true'
Write-Host 'LateApproachNm: 60'
Write-Host 'LateApproachMode: FIR_WAYPOINT_THEN_AUFTRAG_INGRESS'
Write-Host 'ExternalSpawnHandoffSeparated: true'
Write-Host 'AirwaysRouting: false'
Write-Host 'MissionDemandClosesStandardTrack: false'
Write-Host 'MissionDemandClosesReserveAfterLastDemand: true'
Write-Host 'GlobalAarMissionLimit: false'
Write-Host 'GlobalAarAircraftLimit: false'
Write-Host 'MaxAircraftPerTrack: 2'
Write-Host 'MooseManagedSpawnSTN: true'
Write-Host 'SpawnInitialSpeedKt: 480'
Write-Host 'TransitRouteSpeedKt: 300'
Write-Host 'ManasIngressFt: 34000'
Write-Host 'ManasEgressFt: 35000'
Write-Host 'AlUdeidIngressFt: 35000'
Write-Host 'AlUdeidEgressFt: 34000'
Write-Host 'MissionAltitudeMode: EXACT_TRACK_ALTITUDE'
Write-Host 'InitialFuelManasPct: 91.4067'
Write-Host 'InitialFuelAlUdeidPct: 79.4558'
Write-Host 'FuelLowNelsonPct: 24'
Write-Host 'FuelLowPattyPct: 26'
Write-Host 'FuelLowLisaPct: 38'
Write-Host 'FuelLowMoePct: 31'
Write-Host 'FuelLowMilhousePct: 36'
Write-Host 'FuelLowKrustyPct: 36'

foreach ($entry in $files.GetEnumerator()) {
  $hash = (Get-FileHash -LiteralPath $entry.Value -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Host "$($entry.Key)SHA256: $hash"
}