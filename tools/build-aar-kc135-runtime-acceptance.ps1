[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\aar-kc135-runtime\src\01-aar-kc135-runtime-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\aar-kc135-runtime\dist'
$outputFile = Join-Path $distDir 'OMW_AAR_KC135_Runtime_Acceptance.lua'

$builderVersion = 'AAR-KC135-RUNTIME-ACCEPTANCE-5'
$testId = 'AAR-KC135-RUNTIME-ACCEPTANCE-5'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
  throw "Required AAR acceptance source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
  'AAR-KC135-RUNTIME-ACCEPTANCE-5',
  'OMW_AAR_KC135_CLANCY',
  'OMW_AAR_KC135_NELSON',
  'TPL_AIR_US_BGRM_F16C_CAS_2SHIP',
  'SQ_US_BGRM_F16C_121_EFS',
  'RECEIVER_MISSION_RANGE_NM = 250',
  'POST_REFUEL_DWELL_SEC = 60',
  'mission:SetMissionRange(RECEIVER_MISSION_RANGE_NM)',
  'gate = { lat = 38.83163, lon = 70.95271 }',
  'gateCoord:HeadingTo(trackCoord)',
  'spawner:InitHeading(spawnHeadingDeg)',
  'spawner:SpawnFromCoordinate(gateCoord)',
  'speedKt = 220',
  'tacanBand = "Y"',
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
  'receiver.mission:CountOpsGroups()',
  'receiver.flightGroup:Refuel(clancy.trackCoord)',
  'function FlightGroup:OnAfterRefueled',
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
-- Scope: two KC-135 Boom exemplars in different gate domains; Nelson materialization approximately 50 km NNE of EGPAN in Tajikistan; spawn heading toward each track; DCS-runtime Y-band A/A TACAN; Clancy 220-KIAS SLOW exemplar and Nelson 300-KIAS FAST exemplar; explicit 250-NM MOOSE receiver mission-range override for the existing Bagram F-16C; 60-second post-refuel dwell before accelerated FuelLow; FuelLow/Cancel/Egress/Despawn gate verification.
-- Active tanker templates: OMW_AAR_KC135_CLANCY, OMW_AAR_KC135_NELSON.
-- AI receiver template: TPL_AIR_US_BGRM_F16C_CAS_2SHIP via existing SQ_US_BGRM_F16C_121_EFS; no new Mission Editor template and no MIZ mutation.
-- Production policy: same gate/domain materializations require at least 60 seconds separation; different gate domains may materialize simultaneously; maxConcurrentSupportMissions remains 2.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

[System.IO.File]::WriteAllText($outputFile, $header + $source, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "ActiveTankers: CLANCY,NELSON"
Write-Host "DifferentGateDomainsMaySpawnSimultaneously: true"
Write-Host "SameGateMinimumSpawnSeparationSec: 60"
Write-Host "SouthGateCandidate: 28.90264890,64.61166667"
Write-Host "NelsonGateCandidate: 38.83163,70.95271"
Write-Host "NelsonGateReference: approximately 50 km NNE of EGPAN"
Write-Host "SpawnHeadingTowardTrack: true"
Write-Host "RuntimeTacan: CLANCY=60Y,NELSON=47Y"
Write-Host "TankerOrbitSpeedKt: CLANCY=220,NELSON=300"
Write-Host "ReceiverMissionRangeNm: 250"
Write-Host "PostRefuelDwellSec: 60"
Write-Host "ManualRadioTacanExemplars: CLANCY,NELSON"
Write-Host "AIBoomReceiverTemplate: TPL_AIR_US_BGRM_F16C_CAS_2SHIP"
Write-Host "AcceleratedFuelLowAfterAiBoomRefueled: true"
Write-Host "EgressGateRadiusNm: 10"
Write-Host "NewMissionEditorTemplates: 0"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
