[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$missionDemandFile = Join-Path $repoRoot 'scripts\campaign\OMW_MissionDemand.lua'
$resourceDemandPolicyFile = Join-Path $repoRoot 'scripts\campaign\OMW_ResourceDemandPolicy.lua'
$roadSpawnAdapterFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundRoadSpawnAdapter.lua'
$acceptanceSourceFile = Join-Path $repoRoot 'mission\tests\ground-resupply-execution\src\06-ground-air-personnel-resupply-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\ground-resupply-execution\dist'
$outputFile = Join-Path $distDir 'OMW_Ground_Air_PERSONNEL_Resupply_Acceptance_1.lua'

$builderVersion = 'GROUND-AIR-PERSONNEL-RESUPPLY-ACCEPTANCE-1-1'
$testId = 'GROUND-AIR-PERSONNEL-RESUPPLY-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = @(
  $missionDemandFile,
  $resourceDemandPolicyFile,
  $roadSpawnAdapterFile,
  $acceptanceSourceFile
)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Stage 1D-P PERSONNEL acceptance source not found: $file"
  }
}

$missionDemand = Get-Content -LiteralPath $missionDemandFile -Raw -Encoding UTF8
$resourceDemandPolicy = Get-Content -LiteralPath $resourceDemandPolicyFile -Raw -Encoding UTF8
$roadSpawnAdapter = Get-Content -LiteralPath $roadSpawnAdapterFile -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $acceptanceSourceFile -Raw -Encoding UTF8
$combined = $missionDemand + $resourceDemandPolicy + $roadSpawnAdapter + $acceptanceSource

$requiredMarkers = @(
  'OMW-MISSION-DEMAND-1',
  'OMW-RESOURCE-DEMAND-POLICY-1',
  'reorderComparison',
  '[OMW][Ground.RoadSpawnAdapter]',
  'GROUND-AIR-PERSONNEL-RESUPPLY-ACCEPTANCE-1',
  'GROUND_PERSONNEL',
  'GROUND_NODE_JOYCE',
  'GROUND_NODE_HONAKER',
  'GROUND_NODE_JALALABAD',
  'GROUND_NODE_FORTRESS',
  'TPL_BLUE_CONVOY_LIGHT_06',
  'TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP',
  'SQ_US_JBAD_CH47_HEAVYLIFT',
  'OMW_BLUE_LZ_FORTRESS_01',
  'AUFTRAG:NewNOTHING',
  'SetReturnToLegion(false)',
  ':RTZ(ground.originZone, ENUMS.Formation.Vehicle.OnRoad)',
  'AUFTRAG:NewLANDATCOORDINATE',
  'AssignSquadrons({ air.squadron })',
  'SetRequiredAssets(1, 1)',
  'OnAfterFlightOnMission',
  'OnAfterTakeoff',
  'OnAfterMissionDone',
  'OnAfterLegionAssetReturned',
  'MarkLoading',
  'MarkInTransit',
  'MarkDelivered',
  'AIR_DELIVERY_CONFIRMED',
  'GROUND_DELIVERY_CONFIRMED',
  'personnelFloor=80_PERCENT_STRICT_BELOW'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Stage 1D-P PERSONNEL acceptance sources are missing required marker: $marker"
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
    throw "Stage 1D-P PERSONNEL acceptance contains forbidden runtime pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Stage 1D-P PERSONNEL acceptance build.'
}
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-ground-air-personnel-resupply-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- Scope: combined PERSONNEL meta-resource resupply acceptance: Joyce->Honaker Ground NOTHING plus Jalalabad->Fortress CH-47 LANDATCOORDINATE.
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- StrategicAuthority: existing OMW CampaignState only; GROUND_PERSONNEL is shared and transferable.
-- ReadinessRule: below 80 percent target creates RESUPPLY; requested quantity refills to target.
-- GroundPhysicalRepresentation: TPL_BLUE_CONVOY_LIGHT_06, accepted NOTHING + delayed explicit OnRoad RTZ lifecycle.
-- AirPhysicalRepresentation: existing Jalalabad CH-47 AIRWING/SQUADRON asset, LANDATCOORDINATE to existing Fortress invisible FARP, normal MOOSE aircraft return.
-- PhysicalInfantryCargo: false; TROOPTRANSPORT is intentionally excluded from meta-PERSONNEL resupply.
-- AcceptanceCompletion: event-driven; no hard Ground or Air travel-time failure gate.
-- No automated MIZ mutation.

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'OMW_PERSONNEL_RESUPPLY_MISSION_DEMAND' $missionDemand
$bundle += Embed-Module 'OMW_PERSONNEL_RESUPPLY_RESOURCE_DEMAND_POLICY' $resourceDemandPolicy
$bundle += Embed-Module 'OMW_PERSONNEL_RESUPPLY_ROAD_SPAWN_ADAPTER' $roadSpawnAdapter
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
Write-Host 'ResourceClass: GROUND_PERSONNEL'
Write-Host 'StrategicResourceModel: CampaignState transferable PERSONNEL headcount'
Write-Host 'PersonnelReorderRule: strictly below 80 percent target; refill to 100 percent target'
Write-Host 'GroundOrigin: GROUND_NODE_JOYCE'
Write-Host 'GroundDestination: GROUND_NODE_HONAKER'
Write-Host 'GroundInitial: 180 -> 120'
Write-Host 'GroundAcceptanceShortage: 25; Honaker 120 -> 95'
Write-Host 'GroundReorderFloor: 96'
Write-Host 'GroundTransferQuantity: 25'
Write-Host 'GroundFinalExpected: Joyce 155; Honaker 120'
Write-Host 'GroundPhysicalMission: MOOSE AUFTRAG NOTHING'
Write-Host 'GroundPhysicalTemplate: TPL_BLUE_CONVOY_LIGHT_06'
Write-Host 'GroundReturnMode: explicit MOOSE ARMYGROUP RTZ to Joyce ACCESS after MissionDone'
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
Write-Host 'AirLandingTarget: OMW_BLUE_LZ_FORTRESS_01'
Write-Host 'AirLandingDwellSec: 30'
Write-Host 'AirLandingAcceptanceRadiusM: 100'
Write-Host 'AirReturnMode: normal MOOSE aircraft return to Jalalabad AIRWING/LEGION'
Write-Host 'GroundTravelTimeoutSec: none'
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