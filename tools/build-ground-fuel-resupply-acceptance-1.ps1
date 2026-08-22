[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$missionDemandFile = Join-Path $repoRoot 'scripts\campaign\OMW_MissionDemand.lua'
$resourceDemandPolicyFile = Join-Path $repoRoot 'scripts\campaign\OMW_ResourceDemandPolicy.lua'
$roadSpawnAdapterFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundRoadSpawnAdapter.lua'
$acceptanceSourceFile = Join-Path $repoRoot 'mission\tests\ground-resupply-execution\src\02-ground-fuel-resupply-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\ground-resupply-execution\dist'
$outputFile = Join-Path $distDir 'OMW_Ground_Fuel_Resupply_Acceptance_1.lua'

$builderVersion = 'GROUND-FUEL-RESUPPLY-ACCEPTANCE-1-1'
$testId = 'GROUND-FUEL-RESUPPLY-ACCEPTANCE-1'
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
    throw "Required Ground FUEL RESUPPLY acceptance source not found: $file"
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
  'reorder',
  'critical',
  '[OMW][Ground.RoadSpawnAdapter]',
  'AUFTRAG:NewFUELSUPPLY',
  'AUFTRAG.Type.FUELSUPPLY',
  'SetFormation(ENUMS.Formation.Vehicle.OnRoad)',
  'SetReturnToLegion(false)',
  'MarkLoading',
  'MarkInTransit',
  'MarkDelivered',
  'OnAfterMissionExecute',
  'IsInZone(state.destinationZone)',
  'MISSION_EXECUTE_OUTSIDE_DESTINATION',
  'OnAfterReturned',
  'RTZ(state.originZone, ENUMS.Formation.Vehicle.OnRoad)',
  'OUTBOUND_TIMEOUT_SEC',
  'RETURN_TIMEOUT_SEC',
  'RETURN_ISSUE_DELAY_SEC',
  'RETURN_SETTLEMENT_DELAY_SEC',
  'GROUND_NODE_JOYCE',
  'GROUND_NODE_HONAKER',
  'GROUND_FUEL_PACKAGE',
  'TPL_BLUE_CONVOY_FUEL_LIGHT_06'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Ground FUEL RESUPPLY acceptance sources are missing required marker: $marker"
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
  'SPAWN:'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($acceptanceSource -match $pattern) {
    throw "Ground FUEL RESUPPLY acceptance contains forbidden runtime pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Ground FUEL RESUPPLY acceptance build.'
}
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-ground-fuel-resupply-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- Scope: Joyce -> Honaker CampaignState FUEL shortage / MissionDemand / MOOSE FUELSUPPLY / protected fuel-light convoy delivery / return acceptance.
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- StrategicAuthority: existing OMW.AirOps.CampaignContext / OMW.Ground.Base CampaignState only.
-- PhysicalRepresentation: existing TPL_BLUE_CONVOY_FUEL_LIGHT_06; no package-per-tanker capacity is defined by this acceptance.
-- ExplicitExclusions: OPSTRANSPORT, generic SUPPLY, CAS, CSAR, native-DCS dispatcher, MIST, MissionScripting.lua mutation.

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
Write-Host 'Resource: GROUND_FUEL_PACKAGE'
Write-Host 'TransferQuantity: 18'
Write-Host 'PhysicalMission: MOOSE AUFTRAG FUELSUPPLY'
Write-Host 'PhysicalTemplate: TPL_BLUE_CONVOY_FUEL_LIGHT_06'
Write-Host 'PhysicalTemplateUnits: 6'
Write-Host 'PhysicalTankers: 2 x M978 HEMTT Tanker'
Write-Host 'PhysicalCargoAuthority: false'
Write-Host 'PackagePerTankerCapacityDefined: false'
Write-Host 'OutboundTimeoutSec: 1800'
Write-Host 'ReturnTimeoutSec: 1800'
Write-Host 'ReturnIssueDelaySec: 30'
Write-Host 'ReturnSettlementDelaySec: 12'
Write-Host 'OPSTRANSPORT: false'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"

foreach ($file in $files) {
  $fileHash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToUpperInvariant()
  $relative = $file.Substring($repoRoot.Length).TrimStart('\')
  Write-Host "SourceSHA256: $relative = $fileHash"
}
