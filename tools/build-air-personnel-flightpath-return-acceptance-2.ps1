[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$missionDemandFile = Join-Path $repoRoot 'scripts\campaign\OMW_MissionDemand.lua'
$resourceDemandPolicyFile = Join-Path $repoRoot 'scripts\campaign\OMW_ResourceDemandPolicy.lua'
$acceptanceSourceFile = Join-Path $repoRoot 'mission\tests\ground-resupply-execution\src\08-air-personnel-resupply-flightpath-return-acceptance-2.lua'
$distDir = Join-Path $repoRoot 'mission\tests\ground-resupply-execution\dist'
$outputFile = Join-Path $distDir 'OMW_Air_PERSONNEL_FlightPath_Return_Acceptance_2.lua'

$builderVersion = 'AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-2-1'
$testId = 'AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = @(
  $missionDemandFile,
  $resourceDemandPolicyFile,
  $acceptanceSourceFile
)

foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Air PERSONNEL FlightPath acceptance-2 source not found: $file"
  }
}

$missionDemand = Get-Content -LiteralPath $missionDemandFile -Raw -Encoding UTF8
$resourceDemandPolicy = Get-Content -LiteralPath $resourceDemandPolicyFile -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $acceptanceSourceFile -Raw -Encoding UTF8
$combined = $missionDemand + $resourceDemandPolicy + $acceptanceSource

$requiredMarkers = @(
  'OMW-MISSION-DEMAND-1',
  'OMW-RESOURCE-DEMAND-POLICY-1',
  'reorderComparison',
  'AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-2',
  'GROUND_PERSONNEL',
  'GROUND_NODE_JALALABAD',
  'GROUND_NODE_FORTRESS',
  'TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP',
  'SQ_US_JBAD_CH47_HEAVYLIFT',
  'OMW_BLUE_LZ_FORTRESS_01',
  'OMW_FlightPath',
  'PATHLINE:FindByName',
  'AUFTRAG:NewLANDATCOORDINATE',
  'SetMissionEgressCoord',
  'AssignSquadrons({ air.squadron })',
  'SetRequiredAssets(1, 1)',
  'OnAfterFlightOnMission',
  'OnAfterTakeoff',
  'OnAfterMissionDone',
  'OnAfterLanded',
  'OnAfterLegionAssetReturned',
  'heading + AIR_RIGHT_OFFSET_HEADING_DELTA_DEG',
  'AIR_DELIVERY_CONFIRMED_ON_DEPARTURE',
  'SECOND_TAKEOFF_NEAR_LZ',
  'leaveMode=NEAREST_OWNER_PATHLINE_WAYPOINT',
  'personnelFloor=80_PERCENT_STRICT_BELOW'
)

foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Air PERSONNEL FlightPath acceptance-2 sources are missing required marker: $marker"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'mist\.',
  '\bMIST\b',
  '(?<![A-Za-z0-9_])io\.',
  'lfs\.',
  'os\.execute',
  ':Teleport\s*\(',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  'OPSTRANSPORT:New',
  'AUFTRAG:NewOPSTRANSPORT',
  'NewTROOPTRANSPORT',
  'AddCargoStorage',
  'SPAWN:',
  'OUTBOUND_TIMEOUT',
  'RETURN_TIMEOUT'
)

foreach ($pattern in $forbiddenPatterns) {
  if ($acceptanceSource -match $pattern) {
    throw "Air PERSONNEL FlightPath acceptance-2 contains forbidden runtime pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Air PERSONNEL FlightPath acceptance-2 build.'
}
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-air-personnel-flightpath-return-acceptance-2.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- Scope: Air-only PERSONNEL resupply acceptance using OMW_FlightPath, runtime-calibrated 500 m right-hand lanes, normal Fortress LZ, second-takeoff delivery proof, and physical Jalalabad return.
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- StrategicAuthority: existing OMW CampaignState only; GROUND_PERSONNEL is shared and transferable.
-- ReadinessRule: below 80 percent target creates RESUPPLY; requested quantity refills to target.
-- FlightPath: OMW_FlightPath; leave/rejoin at nearest owner-authored PATHLINE waypoint.
-- DirectionalLane: 500 m right; DCS runtime-calibrated as heading + 90 degrees for this OMW coordinate path.
-- DeliveryProof: second physical takeoff near OMW_BLUE_LZ_FORTRESS_01 after LANDATCOORDINATE dwell.
-- ReturnProof: physical Jalalabad OnAfterLanded before AIRWING LegionAssetReturned.
-- PhysicalInfantryCargo: false; TROOPTRANSPORT is intentionally excluded from meta-PERSONNEL resupply.
-- AcceptanceCompletion: event-driven; no hard Air travel-time failure gate.
-- No automated MIZ mutation.

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'OMW_PERSONNEL_FLIGHTPATH_MISSION_DEMAND' $missionDemand
$bundle += Embed-Module 'OMW_PERSONNEL_FLIGHTPATH_RESOURCE_DEMAND_POLICY' $resourceDemandPolicy
$bundle += $acceptanceSource

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GitCommit: $commit"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $($mooseSha256.ToUpperInvariant())"
Write-Host 'Resource: GROUND_PERSONNEL'
Write-Host 'AirOrigin: GROUND_NODE_JALALABAD'
Write-Host 'AirDestination: GROUND_NODE_FORTRESS'
Write-Host 'AirInitial: 480 -> 160'
Write-Host 'AirAcceptanceShortage: 33; Fortress 160 -> 127'
Write-Host 'AirReorderFloor: 128'
Write-Host 'AirTransferQuantity: 33'
Write-Host 'AirFinalExpected: Jalalabad 447; Fortress 160'
Write-Host 'AirPhysicalMission: MOOSE AUFTRAG LANDATCOORDINATE'
Write-Host 'AirSquadron: SQ_US_JBAD_CH47_HEAVYLIFT'
Write-Host 'AirPhysicalTemplate: TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP'
Write-Host 'AirLandingTarget: OMW_BLUE_LZ_FORTRESS_01 (normal trigger-zone LZ)'
Write-Host 'AirFlightPath: OMW_FlightPath'
Write-Host 'AirFlightPathLeaveMode: nearest owner-authored PATHLINE waypoint'
Write-Host 'AirFlightPathDirectionalOffsetRightM: 500'
Write-Host 'AirFlightPathRightHeadingDeltaDeg: +90 (DCS runtime calibration from Acceptance-1)'
Write-Host 'AirCorridorAltitudeFtAGL: 500'
Write-Host 'AirLandingDwellSec: 30'
Write-Host 'AirDeliveryProof: second physical takeoff near Fortress LZ'
Write-Host 'AirDepartureAcceptanceRadiusM: 250'
Write-Host 'AirPhysicalReturnProof: Jalalabad OnAfterLanded then LegionAssetReturned'
Write-Host 'AirTravelTimeoutSec: none'
Write-Host 'TROOPTRANSPORT: false'
Write-Host 'PhysicalInfantryCargo: false'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"

foreach ($file in $files) {
  $fileHash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToUpperInvariant()
  $relative = $file.Substring($repoRoot.Length).TrimStart('\')
  Write-Host "SourceSHA256: $relative = $fileHash"
}
