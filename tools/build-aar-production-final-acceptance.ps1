[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\aar-production-integration\src'
$distDir = Join-Path $repoRoot 'mission\tests\aar-production-integration\dist'
$outputFile = Join-Path $distDir 'OMW_AAR_Production_Final_Acceptance.lua'

$builderVersion = 'AAR-PRODUCTION-FINAL-ACCEPTANCE-5'
$testId = 'AAR-PRODUCTION-FINAL-ACCEPTANCE-5'
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
  @{ File = 'Controller'; Marker = 'stableSortieCallsign = true' },
  @{ File = 'Controller'; Marker = 'firFixRoutingEnabled = true' },
  @{ File = 'Controller'; Marker = 'airwaysRoutingEnabled = false' },
  @{ File = 'Controller'; Marker = 'RESERVE_TRACK_EGRESS' },
  @{ File = 'Controller'; Marker = 'runtime.flightGroup:AddWaypoint(runtime.externalHandoffCoord' },
  @{ File = 'Controller'; Marker = 'spawnedUnit:GetSTN()' },
  @{ File = 'Controller'; Marker = 'function flightGroup:OnAfterDead' },
  @{ File = 'Harness'; Marker = 'AAR-PRODUCTION-FINAL-ACCEPTANCE-5' },
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
  @{ File = 'CycleControl'; Marker = 'TEST_ISOLATION' }
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
-- Scope: final combined AAR production acceptance for four standard tracks, two demand-driven FAST reserve tracks, stable callsign families, source spacing, CampaignState pools/accounting, natural FIR-fix ingress, natural track entry, one scheduled relief, FuelLow relief, reserve start/stop, loss replacement and restore reconciliation.
-- FIR routing: NELSON/PATTY via EGPAN, KRUSTY/MILHOUSE via DAVER, LISA/MOE via PINAX. External spawn/handoff remains separate. Full ATS-airway routing is deferred.
-- Track routing: physical tankers must reach their configured production AAR track naturally; the harness does not rewrite runtime.trackCoord and does not teleport aircraft.
-- Scheduled relief: only MILHOUSE is accelerated, and only by advancing the relief launch time after a short station dwell. The relief then flies naturally from the external spawn through DAVER to the real MILHOUSE track. During that transit two MILHOUSE-assigned physical sorties are expected, but only the outgoing tanker owns station radio/TACAN until final relief ingress.
-- Test isolation: background scheduled relief cycles are held beyond the test window so the combined acceptance exercises only the explicitly selected MILHOUSE scheduled relief and NELSON FuelLow relief. This changes test timing only, not physical routing or production controller constants.
-- FuelLow relief: NELSON replacement also flies naturally through EGPAN to the real NELSON track.
-- Egress settlement: outgoing tankers must pass their FIR egress fix and then reach the external handoff point before recredit/despawn.
-- Loss injection: public MOOSE UNIT:Explode() is used only on the designated test tanker to exercise the real FLIGHTGROUP Dead/OnAfterDead path.
-- Restore: CampaignState snapshot/Restore is exercised in-process; this is not a physical DCS server restart.
-- Timeout: 12 simulation hours to permit natural physical transit through all combined acceptance phases.
-- No automated MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$bundle = $header
$bundle += "local OMW_AAR_TEST_CampaignState = (function()`n" + $content.CampaignState + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_StrategicStock = (function()`n" + $content.StrategicStock + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Initializer = (function()`n" + $content.Initializer + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Adapter = (function()`n" + $content.Adapter + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_RuntimeIntegration = (function()`n" + $content.RuntimeIntegration + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Controller = (function()`n" + $content.Controller + "`nend)()`n"
$bundle += $content.Harness + "`n"
$bundle += $content.CycleControl

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host 'StandardTracks: 4'
Write-Host 'ReserveTracks: 2'
Write-Host 'LISAProfile: FAST'
Write-Host 'LISAAvailability: RESERVE'
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
