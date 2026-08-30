[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$campaignStateFile = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
$missionDemandFile = Join-Path $repoRoot 'scripts\campaign\OMW_MissionDemand.lua'
$resourceDemandPolicyFile = Join-Path $repoRoot 'scripts\campaign\OMW_ResourceDemandPolicy.lua'
$acceptanceSourceFile = Join-Path $repoRoot 'mission\tests\air-ammo-resupply\src\01-air-ammo-resupply-cargotransport-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\air-ammo-resupply\dist'
$outputFile = Join-Path $distDir 'OMW_Air_AMMO_CargoTransport_Acceptance_1.lua'

$builderVersion = 'AIR-AMMO-CARGOTRANSPORT-ACCEPTANCE-1-1'
$testId = 'AIR-AMMO-CARGOTRANSPORT-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = @(
  $campaignStateFile,
  $missionDemandFile,
  $resourceDemandPolicyFile,
  $acceptanceSourceFile
)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Air-AMMO CARGOTRANSPORT acceptance source not found: $file"
  }
}

$campaignState = Get-Content -LiteralPath $campaignStateFile -Raw -Encoding UTF8
$missionDemand = Get-Content -LiteralPath $missionDemandFile -Raw -Encoding UTF8
$resourceDemandPolicy = Get-Content -LiteralPath $resourceDemandPolicyFile -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $acceptanceSourceFile -Raw -Encoding UTF8
$combined = $campaignState + $missionDemand + $resourceDemandPolicy + $acceptanceSource

$requiredMarkers = @(
  'CAMPAIGNSTATE-SNAPSHOT-1',
  'OMW-MISSION-DEMAND-1',
  'OMW-RESOURCE-DEMAND-POLICY-1',
  'AIR-AMMO-CARGOTRANSPORT-ACCEPTANCE-1',
  'GROUND_AMMO_PACKAGE',
  'GROUND_NODE_JALALABAD',
  'GROUND_NODE_WRIGHT',
  'SQ_US_JBAD_CH47_HEAVYLIFT',
  'TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP',
  'OMW_LOG_NODE_JALALABAD',
  'OMW_BLUE_LZ_WRIGHT_01',
  'AUFTRAG:NewCARGOTRANSPORT',
  'SPAWNSTATIC:NewFromType',
  ':InitCargo(true)',
  ':InitCargoMass(',
  ':InitValidateAndRepositionStatic(',
  'ammo_cargo',
  'MarkLoading',
  'MarkInTransit',
  'MarkDelivered',
  'MarkLost',
  'OnAfterFlightOnMission',
  'OnAfterLanded',
  'OnAfterLegionAssetReturned',
  'strategicKgConversion=false'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Air-AMMO CARGOTRANSPORT acceptance sources are missing required marker: $marker"
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
  'AddCargoStorage',
  'NewFREIGHTTRANSPORT',
  'NewTROOPTRANSPORT',
  'coalition\.addGroup',
  'coalition\.addStaticObject'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($acceptanceSource -match $pattern) {
    throw "Air-AMMO CARGOTRANSPORT acceptance contains forbidden runtime pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Air-AMMO CARGOTRANSPORT acceptance build.'
}
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-air-ammo-cargotransport-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- Scope: Isolated Jalalabad->Wright Ground-AMMO manifest using MOOSE AUFTRAG CARGOTRANSPORT and one physical slingload static.
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- StrategicAuthority: existing OMW CampaignState only.
-- PhysicalManifest: one ammo_cargo static represents the complete transfer manifest; no kg-to-GROUND_AMMO_PACKAGE conversion.
-- PhysicalCargoMassKg: 1000 acceptance-only DCS slingload parameter; non-normative.
-- Pickup: OMW_LOG_NODE_JALALABAD.
-- Drop: OMW_BLUE_LZ_WRIGHT_01 Mission Editor zone.
-- InTransitProof: exact manifest cargo leaves pickup zone after AIRWING FlightOnMission/LOADING.
-- DeliveryProof: exact cargo in Wright drop zone plus MOOSE AUFTRAG CARGOTRANSPORT Success.
-- PhysicalReturnProof: Jalalabad OnAfterLanded before LegionAssetReturned.
-- No automated MIZ mutation.

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'OMW_AIR_AMMO_CAMPAIGN_STATE' $campaignState
$bundle += Embed-Module 'OMW_AIR_AMMO_MISSION_DEMAND' $missionDemand
$bundle += Embed-Module 'OMW_AIR_AMMO_RESOURCE_DEMAND_POLICY' $resourceDemandPolicy
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
Write-Host 'Resource: GROUND_AMMO_PACKAGE'
Write-Host 'AirOrigin: GROUND_NODE_JALALABAD'
Write-Host 'AirDestination: GROUND_NODE_WRIGHT'
Write-Host 'Initial: Jalalabad 100; Wright 30'
Write-Host 'AcceptanceShortage: Wright 30 -> 15'
Write-Host 'Reorder: 15 AT_OR_BELOW'
Write-Host 'TransferQuantity: 15'
Write-Host 'FinalExpected: Jalalabad 85; Wright 30'
Write-Host 'AirPhysicalMission: MOOSE AUFTRAG CARGOTRANSPORT'
Write-Host 'AirSquadron: SQ_US_JBAD_CH47_HEAVYLIFT'
Write-Host 'AirPhysicalTemplate: TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP'
Write-Host 'PhysicalCargoType: ammo_cargo'
Write-Host 'PhysicalCargoCount: 1'
Write-Host 'PhysicalCargoMassKg: 1000 (acceptance-only; non-normative)'
Write-Host 'StrategicKgConversion: false'
Write-Host 'PickupZone: OMW_LOG_NODE_JALALABAD'
Write-Host 'DropZone: OMW_BLUE_LZ_WRIGHT_01'
Write-Host 'InTransitCheckIntervalSec: 5'
Write-Host 'AirPhysicalReturnProof: Jalalabad OnAfterLanded then LegionAssetReturned'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"

foreach ($file in $files) {
  $fileHash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToUpperInvariant()
  $relative = $file.Substring($repoRoot.Length).TrimStart('\')
  Write-Host "SourceSHA256: $relative = $fileHash"
}
