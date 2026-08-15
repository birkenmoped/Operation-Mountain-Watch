[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\aar-production-integration\src'
$distDir = Join-Path $repoRoot 'mission\tests\aar-production-integration\dist'
$outputFile = Join-Path $distDir 'OMW_AAR_Production_Final_Acceptance.lua'

$builderVersion = 'AAR-PRODUCTION-FINAL-ACCEPTANCE-3'
$testId = 'AAR-PRODUCTION-FINAL-ACCEPTANCE-3'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = [ordered]@{
  CampaignState = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
  StrategicStock = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
  Initializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
  Adapter = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_CampaignStateAdapter.lua'
  RuntimeIntegration = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_RuntimeIntegration.lua'
  Controller = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_Controller.lua'
  Harness = Join-Path $sourceDir '02-aar-production-final-acceptance.lua'
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
  @{ File = 'Controller'; Marker = 'CORE_TRACK_COUNT = 6' },
  @{ File = 'Controller'; Marker = 'MAX_AIRCRAFT_PER_TRACK = 2' },
  @{ File = 'Controller'; Marker = 'coreProfile = "FAST"' },
  @{ File = 'Controller'; Marker = 'function Controller.StartContinuousCoreCoverage()' },
  @{ File = 'Controller'; Marker = 'CORE_TRACK_RETAINED' },
  @{ File = 'Controller'; Marker = 'spawnedUnit:GetSTN()' },
  @{ File = 'Controller'; Marker = 'globalAarMissionLimit = false' },
  @{ File = 'Controller'; Marker = 'globalAarAircraftLimit = false' },
  @{ File = 'Controller'; Marker = 'function flightGroup:OnAfterDead' },
  @{ File = 'Harness'; Marker = 'AAR-PRODUCTION-FINAL-ACCEPTANCE-3' },
  @{ File = 'Harness'; Marker = 'AAR_POLICY_BASELINE_PASS' },
  @{ File = 'Harness'; Marker = 'RESTORE_RECONCILIATION_PASS' },
  @{ File = 'Harness'; Marker = 'POOL_BASELINE_PASS' },
  @{ File = 'Harness'; Marker = 'SOURCE_INDEPENDENCE_PASS' },
  @{ File = 'Harness'; Marker = 'CORE_TRACKS_6_SIMULTANEOUS_PASS' },
  @{ File = 'Harness'; Marker = 'MISSION_DEMAND_ATTACH_PASS' },
  @{ File = 'Harness'; Marker = 'RELIEF_6_TRACKS_12_AIRCRAFT_PASS' },
  @{ File = 'Harness'; Marker = 'STATION_IDENTITY_PASS' },
  @{ File = 'Harness'; Marker = 'SCHEDULED_HANDOFF_SETTLEMENT_PASS' },
  @{ File = 'Harness'; Marker = 'FUEL_LOW_RELIEF_PASS' },
  @{ File = 'Harness'; Marker = 'unit:Explode(LOSS_EXPLOSION_POWER)' },
  @{ File = 'Harness'; Marker = 'AIRCRAFT_LOSS_PASS' },
  @{ File = 'Harness'; Marker = 'DEMAND_END_PASS' },
  @{ File = 'Harness'; Marker = 'FINAL_STEADY_STATE_PASS' },
  @{ File = 'Harness'; Marker = 'RESULT PASS' }
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
  'spawner:InitSTN\('
)

foreach ($entry in $content.GetEnumerator()) {
  foreach ($pattern in $forbiddenPatterns) {
    if ($entry.Value -match $pattern) {
      throw "Forbidden pattern in AAR final acceptance $($entry.Key): $pattern"
    }
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-aar-production-final-acceptance.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: final combined AAR production acceptance for continuous six-track coverage, LISA/MOE FAST, source spacing, CampaignState pools/accounting, per-track active+relief lifecycle, transit/station identity, scheduled/FuelLow relief, MissionDemand attachment/end without core shutdown, handoff, loss replacement and restore reconciliation.
-- Current availability policy: the six selected core tracks are treated as continuously available until a later ATO/time-window policy is approved; this test does not claim historical 24/7 coverage or perform a 24-hour endurance run.
-- Test acceleration: track-entry coordinates and scheduled-relief timestamps are controlled by the harness; no physical aircraft is teleported.
-- Egress settlement: outgoing tankers must still reach the productive external gate before handoff/recredit.
-- Loss injection: public MOOSE UNIT:Explode() is used only on the designated test tanker to exercise the real FLIGHTGROUP Dead/OnAfterDead path.
-- Restore: CampaignState snapshot/Restore is exercised in-process; this is not a physical DCS server restart.
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
$bundle += $content.Harness

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "CoreTracks: 6"
Write-Host "LISAProfile: FAST"
Write-Host "MOEProfile: FAST"
Write-Host "ContinuousAvailabilityPolicy: true"
Write-Host "GlobalAarMissionLimit: false"
Write-Host "GlobalAarAircraftLimit: false"
Write-Host "MaxAircraftPerTrack: 2"
Write-Host "ExpectedMaxPhysicalDuringAllTrackRelief: 12"
Write-Host "MooseManagedSpawnSTN: true"
Write-Host "ControlledTrackEntry: true"
Write-Host "ControlledReliefTiming: true"
Write-Host "PhysicalTeleport: false"
Write-Host "NaturalIngressGateTransitRequired: false"
Write-Host "NaturalEgressGateHandoffRequired: true"
Write-Host "LossInjection: MOOSE UNIT:Explode"
Write-Host "RestoreMode: in-process CampaignState Snapshot/Restore"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"

foreach ($entry in $files.GetEnumerator()) {
  $hash = (Get-FileHash -LiteralPath $entry.Value -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Host "$($entry.Key)SHA256: $hash"
}
$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "BundleSHA256: $bundleHash"
