[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\aar-production-integration\src'
$distDir = Join-Path $repoRoot 'mission\tests\aar-production-integration\dist'
$outputFile = Join-Path $distDir 'OMW_AAR_Production_Final_Acceptance.lua'

$builderVersion = 'AAR-PRODUCTION-FINAL-ACCEPTANCE-7'
$testId = 'AAR-PRODUCTION-FINAL-ACCEPTANCE-7'
$priorTestId = 'AAR-PRODUCTION-FINAL-ACCEPTANCE-5'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = [ordered]@{
  CampaignState = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
  StrategicStock = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
  Initializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
  Adapter = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_CampaignStateAdapter.lua'
  RuntimeIntegration = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_RuntimeIntegration.lua'
  Controller = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_Controller.lua'
  Harness = Join-Path $sourceDir '03-aar-production-final-acceptance-5.lua'
  CycleControl = Join-Path $sourceDir '04-aar-production-final-acceptance-5-cycle-control.lua'
  LateApproach = Join-Path $sourceDir '05-aar-production-final-acceptance-7-late-approach.lua'
}

foreach ($entry in $files.GetEnumerator()) {
  if (-not (Test-Path -LiteralPath $entry.Value -PathType Leaf)) {
    throw "Required AAR final-acceptance source not found: $($entry.Value)"
  }
}

& (Join-Path $repoRoot 'tools\validate-aar-production-finalization.ps1')

$content = @{}
foreach ($entry in $files.GetEnumerator()) {
  $content[$entry.Key] = Get-Content -LiteralPath $entry.Value -Raw -Encoding UTF8
}

$requirements = @(
  @{ File = 'StrategicStock'; Marker = 'initial = 16' },
  @{ File = 'StrategicStock'; Marker = 'initial = 40' },
  @{ File = 'Adapter'; Marker = 'function Adapter:OnMaterialized' },
  @{ File = 'Adapter'; Marker = 'function Adapter:OnHandoff' },
  @{ File = 'Adapter'; Marker = 'function Adapter:OnLost' },
  @{ File = 'Adapter'; Marker = 'function Adapter:ReconcileRestore' },
  @{ File = 'RuntimeIntegration'; Marker = 'controller.StartContinuousCoreCoverage()' },
  @{ File = 'Controller'; Marker = 'STANDARD_TRACK_COUNT = 4' },
  @{ File = 'Controller'; Marker = 'RESERVE_TRACK_COUNT = 2' },
  @{ File = 'Controller'; Marker = 'MAX_AIRCRAFT_PER_TRACK = 2' },
  @{ File = 'Controller'; Marker = 'SPAWN_INITIAL_SPEED_KT = 480' },
  @{ File = 'Controller'; Marker = 'TRANSIT_SPEED_KT = 300' },
  @{ File = 'Controller'; Marker = 'LATE_APPROACH_NM = 60' },
  @{ File = 'Controller'; Marker = 'mission:SetMissionAltitude(profile.altitudeFt)' },
  @{ File = 'Controller'; Marker = 'mission:SetMissionIngressCoord(lateApproachCoord, transit.ingressFt, TRANSIT_SPEED_KT)' },
  @{ File = 'Controller'; Marker = 'flightGroup:AddWaypoint(firIngressCoord, TRANSIT_SPEED_KT, nil, transit.ingressFt, false)' },
  @{ File = 'Controller'; Marker = 'stableSortieCallsign = true' },
  @{ File = 'Controller'; Marker = 'firFixRoutingEnabled = true' },
  @{ File = 'Controller'; Marker = 'airwaysRoutingEnabled = false' },
  @{ File = 'Controller'; Marker = 'RESERVE_TRACK_EGRESS' },
  @{ File = 'Controller'; Marker = 'runtime.flightGroup:AddWaypoint(runtime.externalHandoffCoord' },
  @{ File = 'Controller'; Marker = 'spawnedUnit:GetSTN()' },
  @{ File = 'Controller'; Marker = 'function flightGroup:OnAfterDead' },
  @{ File = 'Harness'; Marker = $priorTestId },
  @{ File = 'Harness'; Marker = 'AAR_POLICY_BASELINE_PASS' },
  @{ File = 'Harness'; Marker = 'RESTORE_RECONCILIATION_PASS' },
  @{ File = 'Harness'; Marker = 'POOL_BASELINE_PASS' },
  @{ File = 'Harness'; Marker = 'STANDARD_TRACKS_4_PASS' },
  @{ File = 'Harness'; Marker = 'FIR_INGRESS_STANDARD_PASS' },
  @{ File = 'Harness'; Marker = 'NATURAL_STANDARD_TRACK_ENTRY_PASS' },
  @{ File = 'Harness'; Marker = 'RELIEF_TRANSIT_OVERLAP_PASS' },
  @{ File = 'Harness'; Marker = 'SINGLE_SCHEDULED_RELIEF_PASS' },
  @{ File = 'Harness'; Marker = 'FUEL_LOW_RELIEF_PASS' },
  @{ File = 'Harness'; Marker = 'RESERVE_NATURAL_INGRESS_AND_TRACK_PASS' },
  @{ File = 'Harness'; Marker = 'RESERVE_DEMAND_LIFECYCLE_PASS' },
  @{ File = 'Harness'; Marker = 'unit:Explode(LOSS_EXPLOSION_POWER)' },
  @{ File = 'Harness'; Marker = 'AIRCRAFT_LOSS_PASS' },
  @{ File = 'Harness'; Marker = 'FINAL_STEADY_STATE_PASS' },
  @{ File = 'Harness'; Marker = 'RESULT PASS' },
  @{ File = 'CycleControl'; Marker = 'HOLD_BACKGROUND_SCHEDULED_RELIEF' },
  @{ File = 'CycleControl'; Marker = 'TEST_ISOLATION' },
  @{ File = 'LateApproach'; Marker = 'HIGH_HOLD_PASS' },
  @{ File = 'LateApproach'; Marker = 'TRACK_ALTITUDE_PASS' },
  @{ File = 'LateApproach'; Marker = 'LATE_APPROACH_PASS' },
  @{ File = 'LateApproach'; Marker = 'config.sourceDomainByArea.LISA' },
  @{ File = 'LateApproach'; Marker = 'config.firFixByArea.LISA' }
)

foreach ($requirement in $requirements) {
  if (-not $content[$requirement.File].Contains($requirement.Marker)) {
    throw "Missing AAR final-acceptance marker in $($requirement.File): $($requirement.Marker)"
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
  'os\.execute',
  'MAX_CONCURRENT_SUPPORT_MISSIONS',
  'MAX_CONCURRENT_SUPPORT_AIRCRAFT',
  'spawner:InitSTN\(',
  'forceControlledTrackEntry',
  'runtime\.trackCoord\s*=',
  'CORE_TRACKS_6_SIMULTANEOUS_PASS',
  'RELIEF_6_TRACKS_12_AIRCRAFT_PASS'
)

foreach ($entry in $content.GetEnumerator()) {
  foreach ($pattern in $forbiddenPatterns) {
    if ($entry.Value -match $pattern) {
      throw "Forbidden pattern in AAR final acceptance $($entry.Key): $pattern"
    }
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) { Remove-Item -LiteralPath $outputFile -Force }

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-aar-production-final-acceptance.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: final combined AAR production acceptance for the owner-approved LRC/fuel calibration, LISA south-domain correction and 60-NM late approach plus four standard tracks, two demand-driven FAST reserve tracks, stable callsign families, source spacing, CampaignState pools/accounting, natural FIR-fix ingress, natural track entry, one scheduled relief, FuelLow relief, reserve start/stop, loss replacement and restore reconciliation.
-- Calibration: spawn 480 kt; route 300 kt; MANAS in/out FL340/FL350; AL_UDEID in/out FL350/FL340; exact track mission altitude; 60-NM late approach; FuelLow NELSON/PATTY/LISA/MOE/MILHOUSE/KRUSTY 24/26/38/31/36/36 percent.
-- Initial-fuel contract: MANAS 91.4067 percent; AL_UDEID 79.4558 percent. LISA now belongs to AL_UDEID and therefore uses the southern initial-fuel contract. Physical template fuel remains Mission Editor configuration; no MOOSE InitFuel API is assumed.
-- FIR routing: NELSON/PATTY via EGPAN, MOE via PINAX, LISA/KRUSTY/MILHOUSE via DAVER. External spawn/handoff remains separate. Full ATS-airway routing is deferred.
-- Late approach: the real FIR fix remains an explicit public MOOSE FLIGHTGROUP waypoint at inbound LRC altitude. AUFTRAG ingress is the point 60 NM before the actual AAR track; descent to exact track altitude occurs on the final mission leg.
-- Track routing: physical tankers must reach their configured production AAR track naturally; the harness does not rewrite runtime.trackCoord and does not teleport aircraft.
-- Scheduled relief: only MILHOUSE is accelerated, and only by advancing the relief launch time after a short station dwell. The relief then flies naturally from the external spawn through DAVER and the 60-NM late approach to the real MILHOUSE track. During that transit two MILHOUSE-assigned physical sorties are expected, but only the outgoing tanker owns station radio/TACAN until final relief ingress.
-- Test isolation: background scheduled relief cycles are held beyond the test window so the combined acceptance exercises only the explicitly selected MILHOUSE scheduled relief and NELSON FuelLow relief. This changes test timing only, not physical routing or production controller constants.
-- FuelLow relief: NELSON replacement also flies naturally through EGPAN and the 60-NM late approach to the real NELSON track.
-- Reserve routing: LISA is demand-driven from AL_UDEID via DAVER; MOE remains demand-driven from MANAS via PINAX. Neither reserve track auto-starts.
-- Egress settlement: outgoing tankers must pass their FIR egress fix and then reach the external handoff point before recredit/despawn.
-- Loss injection: public MOOSE UNIT:Explode() is used only on the designated test tanker to exercise the real FLIGHTGROUP Dead/OnAfterDead path.
-- Restore: CampaignState snapshot/Restore is exercised in-process; this is not a physical DCS server restart.
-- Timeout: 12 simulation hours to permit natural physical transit through all combined acceptance phases.
-- No automated MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$harness = $content.Harness.Replace($priorTestId, $testId)
$harness = $harness.Replace('assertEqual(config.firFixByArea.LISA, "PINAX", "config.fir.LISA")', 'assertEqual(config.firFixByArea.LISA, "DAVER", "config.fir.LISA")')
$harness = $harness.Replace('assertEqual(observed.lisa.firFixName, "PINAX", "LISA reserve firFix")', 'assertEqual(observed.lisa.firFixName, "DAVER", "LISA reserve firFix")')
$harness = $harness.Replace('log("RESERVE_NATURAL_INGRESS_AND_TRACK_PASS LISA=PINAX MOE=PINAX")', 'log("RESERVE_NATURAL_INGRESS_AND_TRACK_PASS LISA=DAVER MOE=PINAX")')
$harness = $harness.Replace('assertTrue(observed.lisa.firEgressPassed and observed.moe.firEgressPassed, "reserve tanker missed PINAX egress")', 'assertTrue(observed.lisa.firEgressPassed and observed.moe.firEgressPassed, "reserve tanker missed configured FIR egress")')
$harness = $harness.Replace('log("RESERVE_DEMAND_LIFECYCLE_PASS LISA=FAST MOE=FAST PINAX_ingressEgress=true externalHandoff=true")', 'log("RESERVE_DEMAND_LIFECYCLE_PASS LISA=FAST AL_UDEID_DAVER=true MOE=FAST MANAS_PINAX=true externalHandoff=true")')
$cycleControl = $content.CycleControl.Replace($priorTestId, $testId)

$bundle = $header
$bundle += "local OMW_AAR_TEST_CampaignState = (function()`n" + $content.CampaignState + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_StrategicStock = (function()`n" + $content.StrategicStock + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Initializer = (function()`n" + $content.Initializer + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Adapter = (function()`n" + $content.Adapter + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_RuntimeIntegration = (function()`n" + $content.RuntimeIntegration + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Controller = (function()`n" + $content.Controller + "`nend)()`n"
$bundle += $harness + "`n"
$bundle += $cycleControl + "`n"
$bundle += $content.LateApproach

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host 'StandardTracks: 4'
Write-Host 'ReserveTracks: 2'
Write-Host 'SpawnInitialSpeedKt: 480'
Write-Host 'TransitRouteSpeedKt: 300'
Write-Host 'LateApproachNm: 60'
Write-Host 'LateApproachMode: FIR_WAYPOINT_THEN_AUFTRAG_INGRESS'
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
Write-Host 'LISAProfile: FAST'
Write-Host 'LISAAvailability: RESERVE'
Write-Host 'LISASourceDomain: AL_UDEID'
Write-Host 'LISAFIRFix: DAVER'
Write-Host 'MOEProfile: FAST'
Write-Host 'MOEAvailability: RESERVE'
Write-Host 'StableSortieCallsign: true'
Write-Host 'FIRFixRouting: true'
Write-Host 'AirwaysRouting: false'
Write-Host 'SingleScheduledRelief: true'
Write-Host 'BackgroundScheduledReliefIsolation: true'
Write-Host 'ScheduledReliefLaunchAccelerationOnly: true'
Write-Host 'NaturalStandardTrackEntryRequired: true'
Write-Host 'NaturalReliefTrackEntryRequired: true'
Write-Host 'LateApproachHighHoldRequired: true'
Write-Host 'ControlledTrackEntryAfterFIR: false'
Write-Host 'RuntimeTrackCoordMutation: false'
Write-Host 'PhysicalTeleport: false'
Write-Host 'NaturalFIRIngressRequired: true'
Write-Host 'NaturalFIREgressAndExternalHandoffRequired: true'
Write-Host 'ReliefTransitPhysicalOverlapExpected: true'
Write-Host 'ReliefTransitStationOwners: 1'
Write-Host 'GlobalAarMissionLimit: false'
Write-Host 'GlobalAarAircraftLimit: false'
Write-Host 'MaxAircraftPerTrack: 2'
Write-Host 'MooseManagedSpawnSTN: true'
Write-Host 'LossInjection: MOOSE UNIT:Explode'
Write-Host 'RestoreMode: in-process CampaignState Snapshot/Restore'
Write-Host 'MizMutation: false'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"

foreach ($entry in $files.GetEnumerator()) {
  $hash = (Get-FileHash -LiteralPath $entry.Value -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Host "$($entry.Key)SHA256: $hash"
}
$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "BundleSHA256: $bundleHash"