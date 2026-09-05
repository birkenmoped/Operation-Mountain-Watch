[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$corridorFile = Join-Path $repoRoot 'scripts\air-operations\OMW_HelicopterFlightPathCorridor.lua'
$handoffFile = Join-Path $repoRoot 'scripts\air-operations\OMW_SlingloadCorridorHandoff.lua'
$acceptanceFile = Join-Path $repoRoot 'mission\tests\stage3-cas-resupply-focused\src\01-stage3-cas-resupply-focused-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\stage3-cas-resupply-focused\dist'
$outputFile = Join-Path $distDir 'OMW_Stage3_CAS_Resupply_Focused_Acceptance_1.lua'

$builderVersion = 'STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-3'
$testId = 'STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

foreach ($file in @($corridorFile,$handoffFile,$acceptanceFile)) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Required focused acceptance source not found: $file" }
}

$corridorSource = Get-Content -LiteralPath $corridorFile -Raw -Encoding UTF8
$handoffSource = Get-Content -LiteralPath $handoffFile -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $acceptanceFile -Raw -Encoding UTF8
$combined = $corridorSource + $handoffSource + $acceptanceSource

foreach ($marker in @(
  'OMW-HELICOPTER-FLIGHTPATH-CORRIDOR-8',
  'OMW-SLINGLOAD-CORRIDOR-HANDOFF-5',
  'STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1',
  'TPL_AIR_US_JBAD_AH64D_CAS_2SHIP',
  'TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP',
  'OMW_FlightPath_R500',
  'OMW_FlightPath_WEST',
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
  'AUFTRAG:NewCARGOTRANSPORT',
  'cargoId=state.cargo:GetID()',
  'zoneId=state.drop.ZoneID',
  'CARGOTRANSPORT_PAUSE_REQUESTED',
  'CARGOTRANSPORT_TASK_STILL_EXECUTING',
  'LIFECYCLE label=',
  'BEFORE_PauseMission',
  'EVENT_OnAfterPauseMission',
  'EVENT_OnAfterTaskDone',
  'EVENT_OnAfterMissionDone',
  'POST_PAUSE_T+',
  'DELIVERY_MONITOR_MISSION_IS_OVER',
  'CAS and RESUPPLY have independent failure state',
  'No IncidentParticipants or KNOWN_ATTACKERS_NEUTRALIZED completion gate is used'
)) {
  if (-not $combined.Contains($marker)) { throw "Focused acceptance missing required marker: $marker" }
}

foreach ($marker in @(
  'cargo numeric ID unavailable',
  'type(state.cargo:GetID())~="number"',
  'if missionState',
  'if groupStatus',
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
-- Scope: frozen DCS-proven AH-64 CAS path + CH-47 slingload PAUSED-to-OVER lifecycle diagnostics.
-- Excluded: Guard/QRF/ARTY/CampaignState strategic accounting.
-- CASCompletion: acceptance-only release 90 seconds after first real AH-64 shot; no IncidentParticipants completion gate.
-- RESUPPLYDiagnostics: observation-only snapshots around PauseMission/TaskDone/MissionDone/UpdateRoute; no diagnostic state is a runtime gate.
-- Isolation: CAS and RESUPPLY failure states are independent and cannot suppress the other subsystem execution.
-- MizMutation: false.

"@

$bundle = $header
$bundle += Embed-Module 'OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR' $corridorSource
$bundle += Embed-Module 'OMW_STAGE3_SLINGLOAD_CORRIDOR_HANDOFF' $handoffSource
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
Write-Host 'CAS: frozen proven path - NewCAS + explicit WEST ingress/egress + EngageDetected + OpenFire + PassiveDefense + randomization 0'
Write-Host 'CAS route: Jalalabad -> R500 -> WEST -> ingress -> CAS -> egress -> WEST reverse -> R500 reverse -> Jalalabad'
Write-Host 'RESUPPLY: physical pickup -> PauseMission -> observation-only lifecycle snapshots -> existing R500 handoff -> Wright -> R500 reverse -> Jalalabad'
Write-Host 'RESUPPLY diagnostics: mission state/group status/current mission/current task plus pinned-MOOSE paused/current/task fields at pause events and T+1/2/3/5s'
Write-Host 'DiagnosticGate: false'
Write-Host 'SubsystemIsolation: CAS and RESUPPLY failures do not suppress the other execution path'
Write-Host 'FullStage3Required: false'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"
