[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\aar-kc135-runtime\src\01-aar-kc135-runtime-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\aar-kc135-runtime\dist'
$outputFile = Join-Path $distDir 'OMW_AAR_KC135_Runtime_Acceptance.lua'

$builderVersion = 'AAR-KC135-RUNTIME-ACCEPTANCE-6'
$testId = 'AAR-KC135-RUNTIME-ACCEPTANCE-6'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
  throw "Required AAR acceptance source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
  'AAR-KC135-RUNTIME-ACCEPTANCE-6',
  'OMW_AAR_KC135_CLANCY',
  'OMW_AAR_KC135_PATTY',
  'TPL_AIR_US_KAF_A10C_CAS_2SHIP',
  'SQ_US_KAF_A10C_74_EFS',
  'TPL_AIR_US_BGRM_F16C_CAS_2SHIP',
  'SQ_US_BGRM_F16C_121_EFS',
  'MIN_VERTICAL_SEPARATION_FT = 3000',
  'DUAL_TANKER_SPAWN_STAGGER_SEC = 60',
  'altitudeFt = 22000',
  'altitudeFt = 25000',
  'speedKt = 220',
  'speedKt = 300',
  'tacanChannel = 60',
  'tacanChannel = 48',
  'tacanBand = "Y"',
  'RECEIVER_MISSION_RANGE_NM = 250',
  'POST_REFUEL_DWELL_SEC = 60',
  'mission:SetMissionRange(RECEIVER_MISSION_RANGE_NM)',
  'gateCoord:HeadingTo(trackCoord)',
  'spawner:InitHeading(spawnHeadingDeg)',
  'spawner:SpawnFromCoordinate(gateCoord)',
  'FLIGHTGROUP:New(group)',
  'AUFTRAG:NewTANKER(',
  'Unit.RefuelingSystem.BOOM_AND_RECEPTACLE',
  'mission:SetRadio(spec.frequencyMHz, 0)',
  'mission:SetTACAN(',
  'mission:SetMissionEgressCoord(',
  'flightGroup:SetFuelLowThreshold(SAFE_FUEL_LOW_PCT)',
  'function flightGroup:OnAfterFuelLow',
  'mission:Cancel()',
  'state.flightGroup:Despawn(1, true)',
  'AUFTRAG:NewCAS(',
  'mission:AssignSquadrons({ squadron })',
  'mission:AddRequiredPayload(payload)',
  'mission:SetRequiredAssets(1, 1)',
  'receiverSpec.flightGroup:Refuel(targetTanker.trackCoord)',
  'function FlightGroup:OnAfterRefueled',
  'Get3DDistance(',
  'RECEIVER_TANKER_PROXIMITY_',
  'DUAL_TANKER_STACK_PASS',
  'DUAL_RECEIVER_REFUEL_PASS',
  'AI_BOOM_REFUEL_ORDER_PASS',
  'AI_BOOM_REFUELED_PASS',
  'POST_REFUEL_DWELL_PASS',
  'ACCELERATED_FUEL_LOW_ARMED',
  'EGRESS_GATE_PASS',
  'HARNESS_READY'
)
foreach ($marker in $requiredMarkers) {
  if (-not $source.Contains($marker)) {
    throw "AAR acceptance source is missing required marker: $marker"
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
  'os\.execute'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($source -match $pattern) {
    throw "AAR acceptance source contains forbidden pattern: $pattern"
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
-- Builder: tools/build-aar-kc135-runtime-acceptance.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: one combined same-area dual-KC-135 Boom acceptance in CLANCY; A-10 -> SLOW lower tanker at FL220/220 KIAS; F-16 -> FAST upper tanker at FL250/300 KIAS; 3000-ft vertical separation; 60-second acceptance-only spawn stagger; 3D proximity inference after Refueled; 60-second post-both-receivers dwell before accelerated FuelLow/Egress.
-- Tanker templates: OMW_AAR_KC135_CLANCY (SLOW), OMW_AAR_KC135_PATTY (FAST).
-- Receiver templates: TPL_AIR_US_KAF_A10C_CAS_2SHIP via existing Kandahar foundation; TPL_AIR_US_BGRM_F16C_CAS_2SHIP via existing Bagram foundation.
-- No new Mission Editor templates and no automated MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

[System.IO.File]::WriteAllText($outputFile, $header + $source, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "AARArea: CLANCY"
Write-Host "SlowTanker: template=OMW_AAR_KC135_CLANCY altitudeFt=22000 speedKt=220 radio=241.600AM tacan=60Y/CLA"
Write-Host "FastTanker: template=OMW_AAR_KC135_PATTY altitudeFt=25000 speedKt=300 radio=237.300AM tacan=48Y/TX2"
Write-Host "VerticalSeparationFt: 3000"
Write-Host "MinimumVerticalSeparationFt: 3000"
Write-Host "DualTankerSpawnStaggerSec: 60"
Write-Host "A10Receiver: TPL_AIR_US_KAF_A10C_CAS_2SHIP -> SLOW"
Write-Host "F16Receiver: TPL_AIR_US_BGRM_F16C_CAS_2SHIP -> FAST"
Write-Host "ReceiverMissionRangeNm: 250"
Write-Host "DonorEvidence: 3D_PROXIMITY_INFERENCE_NOT_DONOR_ID"
Write-Host "PostRefuelDwellSec: 60"
Write-Host "EgressGateRadiusNm: 10"
Write-Host "NewMissionEditorTemplates: 0"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
