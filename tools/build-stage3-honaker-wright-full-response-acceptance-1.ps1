[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sources = [ordered]@{
  OMW_STAGE3_CAMPAIGN_STATE = 'scripts\campaign\OMW_CampaignState.lua'
  OMW_STAGE3_MISSION_DEMAND = 'scripts\campaign\OMW_MissionDemand.lua'
  OMW_STAGE3_RESOURCE_DEMAND_POLICY = 'scripts\campaign\OMW_ResourceDemandPolicy.lua'
  OMW_STAGE3_RESOURCE_DEMAND_COORDINATOR = 'scripts\campaign\OMW_ResourceDemandCoordinator.lua'
  OMW_STAGE3_FOB_ATTACK_DEMAND_POLICY = 'scripts\campaign\OMW_FobAttackDemandPolicy.lua'
  OMW_STAGE3_FIRE_SUPPORT_DEMAND_POLICY = 'scripts\campaign\OMW_FobAttackFireSupportDemandPolicy.lua'
  OMW_STAGE3_FOB_THREAT_OPSZONE_ADAPTER = 'scripts\ground\OMW_FobThreatOpsZoneAdapter.lua'
  OMW_STAGE3_FUNCTIONAL_ARTY_DISPATCH_ADAPTER = 'scripts\ground\OMW_FobAttackFunctionalArtyDispatchAdapter.lua'
  OMW_STAGE3_PERSONNEL_LEDGER = 'scripts\ground\OMW_GroundPersonnelDeploymentLedger.lua'
  OMW_STAGE3_GROUND_AMMO_REARM_ADAPTER = 'scripts\ground\OMW_GroundAmmoRearmAdapter.lua'
  OMW_STAGE3_FIXED_FIRE_SUPPORT_AMMO_SUPPORT = 'scripts\ground\OMW_FixedFireSupportAmmoSupport.lua'
  OMW_STAGE3_FIXED_FIRE_SUPPORT_AMMO_REARM_SERVICE = 'scripts\ground\OMW_FixedFireSupportAmmoRearmService.lua'
  OMW_STAGE3_GROUND_SUPPORT_MATERIALIZER = 'scripts\ground\OMW_GroundSupportMaterializer.lua'
  OMW_STAGE3_FOB_ATTACK_CAS_DISPATCH_ADAPTER = 'scripts\air-operations\OMW_FobAttackCasDispatchAdapter.lua'
  OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR = 'scripts\air-operations\OMW_HelicopterFlightPathCorridor.lua'
}
$acceptanceRelative = 'mission\tests\stage3-honaker-wright-full-response\src\01-honaker-wright-full-response-acceptance.lua'
$acceptanceFile = Join-Path $repoRoot $acceptanceRelative
$distDir = Join-Path $repoRoot 'mission\tests\stage3-honaker-wright-full-response\dist'
$outputFile = Join-Path $distDir 'OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua'
$builderVersion = 'STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-2'
$testId = 'STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$resolved = [ordered]@{}
foreach ($name in $sources.Keys) {
  $path = Join-Path $repoRoot $sources[$name]
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required Stage 3 source not found: $path" }
  $resolved[$name] = $path
}
if (-not (Test-Path -LiteralPath $acceptanceFile -PathType Leaf)) { throw "Acceptance source not found: $acceptanceFile" }

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) { throw 'Unable to resolve Git HEAD.' }
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- Scope: Honaker attack -> own QRF + CAS + physically verified Wright L118 -> local M1083 rearm -> CampaignState AMMO reorder -> Jalalabad CH47 Air-AMMO -> Wright.
-- CASRoute: OMW_FlightPath -> OMW_FlightPath_WEST outbound AND reverse return.
-- AirAmmoRoute: OMW_FlightPath outbound AND return.
-- StrategicAuthority: existing OMW CampaignState only.
-- PhysicalAirCargo: one ammo_cargo static represents complete 15-package transfer manifest; 1000 kg acceptance-only physical parameter.
-- MizMutation: false.

"@

$bundle = $header
$combinedForValidation = ''
foreach ($name in $resolved.Keys) {
  $source = Get-Content -LiteralPath $resolved[$name] -Raw -Encoding UTF8
  $bundle += Embed-Module $name $source
  $combinedForValidation += $source
}
$acceptanceSource = Get-Content -LiteralPath $acceptanceFile -Raw -Encoding UTF8
$bundle += $acceptanceSource
$combinedForValidation += $acceptanceSource

$requiredMarkers = @(
  'FIRE_SUPPORT_IMMEDIATE','OPSZONE','AUFTRAG:NewGROUNDATTACK','ARTY:New','AssignAttackGroup',
  'verifyFireComplete','PHYSICAL_AMMO_UNCHANGED','GROUND_AMMO_PACKAGE','GROUND_NODE_WRIGHT','GROUND_NODE_JALALABAD',
  'TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2','TPL_BLUE_GND_SUP_M1083','AUFTRAG:NewCARGOTRANSPORT','SQ_US_JBAD_CH47_HEAVYLIFT',
  'OMW_FlightPath','OMW_FlightPath_WEST','ResolveSequence','MarkInTransit','MarkDelivered','MESSAGE:New','active_duplicate'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combinedForValidation.Contains($marker)) { throw "Stage 3 full-response sources missing marker: $marker" }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua','mist\.','\bMIST\b','(?<![A-Za-z0-9_])io\.','lfs\.','os\.execute',':Teleport\s*\(',
  'world\.addEventHandler','timer\.scheduleFunction','coalition\.addGroup','coalition\.addStaticObject','AddCargoStorage','NewFREIGHTTRANSPORT'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($acceptanceSource -match $pattern) { throw "Stage 3 full-response acceptance contains forbidden runtime pattern: $pattern" }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GitCommit: $commit"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $($mooseSha256.ToUpperInvariant())"
Write-Host 'AttackSite: BLUE_GROUND_COP_HONAKER'
Write-Host 'ThreatEvidence: MOOSE OPSZONE Attacked'
Write-Host 'HonakerResponse: own infantry QRF + existing Jalalabad AH64D CAS'
Write-Host 'FireSupport: Wright TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2 via MOOSE Functional ARTY AssignAttackGroup'
Write-Host 'FireSupportCompletionEvidence: physical MOOSE ARTY GetAmmo decrease required before SUCCESS/rearm'
Write-Host 'HonakerMortar: intentionally unavailable / not materialized'
Write-Host 'WrightStrategicPrecondition: 30 -> 16 acceptance-only'
Write-Host 'LocalRearmDebit: 1 GROUND_AMMO_PACKAGE; 16 -> 15'
Write-Host 'Reorder: 15 AT_OR_BELOW'
Write-Host 'StrategicResupply: exactly one RESUPPLY, Jalalabad -> Wright, quantity 15'
Write-Host 'AirPhysicalMission: MOOSE AUFTRAG CARGOTRANSPORT'
Write-Host 'AirSquadron: SQ_US_JBAD_CH47_HEAVYLIFT'
Write-Host 'AirRouteOutbound: OMW_FlightPath'
Write-Host 'AirRouteReturn: OMW_FlightPath'
Write-Host 'CASRouteOutbound: OMW_FlightPath -> OMW_FlightPath_WEST'
Write-Host 'CASRouteReturn: OMW_FlightPath_WEST -> OMW_FlightPath'
Write-Host 'CASRouteJunctionMaxDistanceM: 1000'
Write-Host 'VisibleTelemetry: MOOSE MESSAGE milestones enabled'
Write-Host 'FinalExpected: Jalalabad AMMO 85; Wright AMMO 30'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"
foreach ($name in $resolved.Keys) {
  $fileHash = (Get-FileHash -LiteralPath $resolved[$name] -Algorithm SHA256).Hash.ToUpperInvariant()
  Write-Host "SourceSHA256: $($sources[$name]) = $fileHash"
}
$acceptanceHash = (Get-FileHash -LiteralPath $acceptanceFile -Algorithm SHA256).Hash.ToUpperInvariant()
Write-Host "SourceSHA256: $acceptanceRelative = $acceptanceHash"
