[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$nameContractFile = Join-Path $repoRoot 'scripts\air-operations\OMW_FlightPathNameContract.lua'
$corridorFile = Join-Path $repoRoot 'scripts\air-operations\OMW_HelicopterFlightPathCorridor.lua'
$transportCorridorFile = Join-Path $repoRoot 'scripts\air-operations\OMW_OpsTransportCorridorAdapter.lua'
$acceptanceFile = Join-Path $repoRoot 'mission\tests\stage3-cas-resupply-focused\src\02-stage3-cas-resupply-opstransport-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\stage3-cas-resupply-focused\dist'
$outputFile = Join-Path $distDir 'OMW_Stage3_CAS_Resupply_Focused_Acceptance_1.lua'

$builderVersion = 'STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-8'
$testId = 'STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

foreach ($file in @($nameContractFile,$corridorFile,$transportCorridorFile,$acceptanceFile)) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Required focused acceptance source not found: $file" }
}

$nameContractSource = Get-Content -LiteralPath $nameContractFile -Raw -Encoding UTF8
$corridorSource = Get-Content -LiteralPath $corridorFile -Raw -Encoding UTF8
$transportCorridorSource = Get-Content -LiteralPath $transportCorridorFile -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $acceptanceFile -Raw -Encoding UTF8
$combined = $nameContractSource + $corridorSource + $transportCorridorSource + $acceptanceSource

foreach ($marker in @(
  'OMW-FLIGHTPATH-NAME-CONTRACT-1',
  'OMW-HELICOPTER-FLIGHTPATH-CORRIDOR-8',
  'OMW-OPSTRANSPORT-CORRIDOR-ADAPTER-1',
  'STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1',
  'TPL_AIR_US_JBAD_AH64D_CAS_2SHIP',
  'TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP',
  'OMW_FlightPath',
  'OMW_FlightPath_WEST',
  'FlightPathNameContract.SelectFromRegistry',
  'ZON_BLUE_GND_HONAKER_ACCESS',
  'ZON_BLUE_LOG_SLG_JALALABAD_01',
  'OMW_BLUE_LZ_WRIGHT_01',
  'AUFTRAG:NewCAS',
  'SetMissionIngressCoord',
  'SetMissionEgressCoord',
  'SetMissionWaypointRandomization(0)',
  'SetEngageDetected',
  'SetROE(ENUMS.ROE.OpenFire)',
  'SetROT(ENUMS.ROT.PassiveDefense)',
  'OPSTRANSPORT:New',
  'AddCargoStorage',
  'LEGION.RecruitCohortAssets',
  'CARRIER_RECRUIT_MAX_ATTEMPTS',
  'GetMissionCapability(AUFTRAG.Type.OPSTRANSPORT)',
  'CountAssets(true,{AUFTRAG.Type.OPSTRANSPORT})',
  'CountPayloadsInStock({AUFTRAG.Type.OPSTRANSPORT},state.carrierUnitType)',
  '[STAGE3 FOCUSED][RESUPPLY RECRUIT RESULT]',
  'LEGION.UnRecruitAssets(assets)',
  'for _,legion in pairs(legions) do',
  'legionCount==1',
  'recruitedLegion==state.airwing',
  'TransportAssign',
  'OnAfterAssetSpawned',
  'OnAfterTransport',
  'OnAfterDelivered',
  'OMW_STAGE3_OPSTRANSPORT_SOURCE_STORAGE_001',
  'OMW_STAGE3_OPSTRANSPORT_WRIGHT_STORAGE_001',
  'CAS and RESUPPLY have independent failure state',
  'No IncidentParticipants or KNOWN_ATTACKERS_NEUTRALIZED completion gate is used'
)) {
  if (-not $combined.Contains($marker)) { throw "Focused acceptance missing required marker: $marker" }
}

foreach ($marker in @(
  'local R500 = "OMW_FlightPath_R500"',
  '#legions',
  'AUFTRAG:NewCARGOTRANSPORT',
  'PauseMission(',
  'CargoTransportation',
  'OnBeforeUnpauseMission',
  'BLOCKED_AUTO_UNPAUSE',
  'Controller:setTask',
  'coalition.addGroup',
  'coalition.addStaticObject',
  ':Teleport(',
  'MissionScripting.lua',
  'mist.',
  'MIST'
)) {
  if ($combined.Contains($marker)) { throw "Focused acceptance contains forbidden/deprecated marker: $marker" }
}

function Embed-Module([string]$Name,[string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) { throw 'Unable to resolve Git HEAD.' }
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-stage3-cas-resupply-focused-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- Scope: frozen AH-64 CAS path + CH-47 MOOSE OPSTRANSPORT storage transfer over the configured OMW_FlightPath[_Rnnn/_Lnnn].
-- Excluded: Guard/QRF/ARTY/CampaignState strategic accounting.
-- CASCompletion: acceptance-only release 90 seconds after first real AH-64 shot; no IncidentParticipants completion gate.
-- RESUPPLYLifecycle: MOOSE OPSTRANSPORT owns pickup/loading/transport/unloading/delivery; a public FLIGHTGROUP waypoint adapter supplies the configured FlightPath for Wright field-LZ routing and return.
-- RESUPPLYStorage: temporary Mk-82 STORAGE fixture proves source-to-destination weapon transfer; it is not a production OMW inventory decision.
-- RESUPPLYRecruitment: bounded public-MOOSE carrier readiness/recruitment window; diagnostics distinguish cohort duty/capability/stock/payload readiness and exact recruitment result.
-- FlightPathContract: logical route identity is OMW_FlightPath; _Rnnn/_Lnnn suffix is mission-editor lateral-offset configuration and is not hard-coded by this acceptance.
-- Isolation: CAS and RESUPPLY failure states are independent and cannot suppress the other subsystem execution.
-- MizMutation: false.

"@

$bundle = $header
$bundle += Embed-Module 'OMW_STAGE3_FLIGHTPATH_NAME_CONTRACT' $nameContractSource
$bundle += Embed-Module 'OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR' $corridorSource
$bundle += Embed-Module 'OMW_STAGE3_OPSTRANSPORT_CORRIDOR_ADAPTER' $transportCorridorSource
$bundle += $acceptanceSource

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
[System.IO.File]::WriteAllText($outputFile,$bundle,[System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GitCommit: $commit"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $($mooseSha256.ToUpperInvariant())"
Write-Host 'FlightPath contract: logical route OMW_FlightPath; mission-editor suffix _Rnnn/_Lnnn selects lateral offset dynamically'
Write-Host 'CAS: frozen path - NewCAS + configured FlightPath + WEST ingress/egress + EngageDetected + OpenFire + PassiveDefense + randomization 0'
Write-Host 'RESUPPLY: MOOSE OPSTRANSPORT + STORAGE; CH-47 carries ammunition Jalalabad -> configured FlightPath -> Wright -> configured FlightPath reverse -> Jalalabad'
Write-Host 'RESUPPLY carrier recruitment: bounded public-MOOSE readiness/retry window with duty/capability/stock/payload and exact recruitment diagnostics'
Write-Host 'RESUPPLY route adapter: public FLIGHTGROUP AddWaypoint/UpdateRoute only; no PauseMission, legacy CargoTransportation task or manual delivery completion'
Write-Host 'CarrierLegionContract: alias-keyed MOOSE legion map validated without Lua length operator'
Write-Host 'DiagnosticGate: false'
Write-Host 'SubsystemIsolation: CAS and RESUPPLY failures do not suppress the other execution path'
Write-Host 'FullStage3Required: false'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"
