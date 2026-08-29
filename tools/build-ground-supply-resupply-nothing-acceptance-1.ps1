[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$missionDemandFile = Join-Path $repoRoot 'scripts\campaign\OMW_MissionDemand.lua'
$resourceDemandPolicyFile = Join-Path $repoRoot 'scripts\campaign\OMW_ResourceDemandPolicy.lua'
$roadSpawnAdapterFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundRoadSpawnAdapter.lua'
$acceptanceSourceFile = Join-Path $repoRoot 'mission\tests\ground-resupply-execution\src\05-ground-supply-resupply-nothing-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\ground-resupply-execution\dist'
$outputFile = Join-Path $distDir 'OMW_Ground_SUPPLY_Resupply_NOTHING_Acceptance_1.lua'

$builderVersion = 'GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1-2'
$testId = 'GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1'
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
    throw "Required Stage 1D-S Ground SUPPLY acceptance source not found: $file"
  }
}

$missionDemand = Get-Content -LiteralPath $missionDemandFile -Raw -Encoding UTF8
$resourceDemandPolicy = Get-Content -LiteralPath $resourceDemandPolicyFile -Raw -Encoding UTF8
$roadSpawnAdapter = Get-Content -LiteralPath $roadSpawnAdapterFile -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $acceptanceSourceFile -Raw -Encoding UTF8
$combined = $missionDemand + $resourceDemandPolicy + $roadSpawnAdapter + $acceptanceSource

$requiredMarkers = @(
  'OMW-MISSION-DEMAND-1',
  'MissionDemand.Type',
  'RESUPPLY',
  'OMW-RESOURCE-DEMAND-POLICY-1',
  'function Policy.Evaluate',
  '[OMW][Ground.RoadSpawnAdapter]',
  'GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1',
  'GROUND_SUPPLY_PACKAGE',
  'GROUND_SUPPLY',
  'AUFTRAG:NewNOTHING',
  'AUFTRAG.Type.NOTHING',
  'SetFormation(ENUMS.Formation.Vehicle.OnRoad)',
  'SetReturnToLegion(false)',
  'state.armyGroup:RTZ(state.originZone, ENUMS.Formation.Vehicle.OnRoad)',
  'MarkLoading',
  'MarkInTransit',
  'MarkDelivered',
  'MISSION_EXECUTE_OBSERVED',
  'DESTINATION_ZONE_ENTERED',
  'DELIVERY_CONFIRMED',
  'OnAfterMissionDone',
  'RETURN_RTZ_ISSUED',
  'OnAfterReturned',
  'WAREHOUSE_ADD_ASSET',
  'GROUND_NODE_JOYCE',
  'GROUND_NODE_HONAKER',
  'TPL_BLUE_CONVOY_LIGHT_06'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Stage 1D-S Ground SUPPLY acceptance sources are missing required marker: $marker"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'mist\.',
  'MIST',
  '(?<![A-Za-z0-9_])io\.',
  'lfs\.',
  'os\.execute',
  ':Teleport\s*\(',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  'OPSTRANSPORT:New',
  'AUFTRAG:NewOPSTRANSPORT',
  'AddCargoStorage',
  'NewTROOPTRANSPORT',
  'RelocateCohort',
  'SPAWN:',
  'OUTBOUND_TIMEOUT',
  'RETURN_TIMEOUT'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($acceptanceSource -match $pattern) {
    throw "Stage 1D-S Ground SUPPLY acceptance contains forbidden runtime pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Stage 1D-S Ground SUPPLY acceptance build.'
}
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-ground-supply-resupply-nothing-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- Scope: Stage 1D-S Joyce -> Honaker CampaignState SUPPLY shortage / MissionDemand / MOOSE AUFTRAG NOTHING / accepted Stage 1C delayed explicit OnRoad RTZ lifecycle acceptance.
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- StrategicAuthority: existing OMW Ground CampaignState only.
-- PhysicalRepresentation: existing TPL_BLUE_CONVOY_LIGHT_06; no DCS/MOOSE Warehouse cargo quantity authority is introduced.
-- AcceptanceCompletion: observation/event-driven; no hard outbound or return travel-time failure gate.
-- ExplicitExclusions: PERSONNEL, VEHICLE, TROOPTRANSPORT, cohort relocation, OPSTRANSPORT storage transfer, native-DCS dispatcher, MIST, MissionScripting.lua mutation.

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'OMW_GROUND_RESUPPLY_MISSION_DEMAND' $missionDemand
$bundle += Embed-Module 'OMW_GROUND_RESUPPLY_RESOURCE_DEMAND_POLICY' $resourceDemandPolicy
$bundle += Embed-Module 'OMW_GROUND_RESUPPLY_ROAD_SPAWN_ADAPTER' $roadSpawnAdapter
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
Write-Host 'Origin: GROUND_NODE_JOYCE'
Write-Host 'Destination: GROUND_NODE_HONAKER'
Write-Host 'Resource: GROUND_SUPPLY_PACKAGE'
Write-Host 'ResourceClass: GROUND_SUPPLY'
Write-Host 'StrategicResourceModel: CampaignState normalized general sustainment unit'
Write-Host 'OriginInitial: 48'
Write-Host 'DestinationInitial: 40'
Write-Host 'AcceptanceShortage: 20'
Write-Host 'DestinationAfterShortage: 20'
Write-Host 'TransferQuantity: 20'
Write-Host 'OriginFinalExpected: 28'
Write-Host 'DestinationFinalExpected: 40'
Write-Host 'PhysicalMission: MOOSE AUFTRAG NOTHING'
Write-Host 'PhysicalTemplate: TPL_BLUE_CONVOY_LIGHT_06'
Write-Host 'DcsWarehouseCargoAuthority: false'
Write-Host 'MooseWarehouseCargoAuthority: false'
Write-Host 'PersistentService: false'
Write-Host 'ReturnMode: explicit MOOSE ARMYGROUP RTZ to Joyce ACCESS after MissionDone'
Write-Host 'OutboundTravelTimeoutSec: none'
Write-Host 'DestinationCheckIntervalSec: 15'
Write-Host 'DestinationExecutionGraceSec: 90 after destination-zone observation only'
Write-Host 'ReturnIssueDelaySec: 30'
Write-Host 'ReturnTravelTimeoutSec: none'
Write-Host 'ReturnSettlementDelaySec: 12'
Write-Host 'AcceptanceCompletion: event-driven'
Write-Host 'PERSONNEL: excluded'
Write-Host 'VEHICLE: excluded'
Write-Host 'OPSTRANSPORT: false'
Write-Host 'TROOPTRANSPORT: false'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"

foreach ($file in $files) {
  $fileHash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToUpperInvariant()
  $relative = $file.Substring($repoRoot.Length).TrimStart('\')
  Write-Host "SourceSHA256: $relative = $fileHash"
}
