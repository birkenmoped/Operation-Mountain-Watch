[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\army-ground-foundation\src\03-army-ground-acceptance-3.lua'
$distDir = Join-Path $repoRoot 'mission\tests\army-ground-foundation\dist'
$outputFile = Join-Path $distDir 'OMW_Army_Ground_Acceptance_3.lua'

$builderVersion = 'ARMY-GROUND-ACCEPTANCE-3-2'
$testId = 'ARMY-GROUND-ACCEPTANCE-3-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
  throw "Required Ground Acceptance source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
  'ARMY-GROUND-ACCEPTANCE-3-2',
  'WH_BLUE_GND_FENTY',
  'WH_BLUE_GND_FORTRESS',
  'WH_BLUE_GND_JOYCE',
  'WH_BLUE_GND_WRIGHT',
  'WH_BLUE_GND_HONAKER',
  'WH_BLUE_GND_BOSTICK',
  'BDE_BLUE_GND_JALALABAD',
  'BDE_BLUE_GND_FORTRESS',
  'BDE_BLUE_GND_JOYCE',
  'BDE_BLUE_GND_WRIGHT',
  'BDE_BLUE_GND_HONAKER',
  'BDE_BLUE_GND_BOSTICK',
  'TPL_BLUE_GND_PATROL_MATV_4',
  'ZON_BLUE_GND_FENTY_ACCESS',
  'ZON_BLUE_GND_FORTRESS_ACCESS',
  'ZON_BLUE_GND_JOYCE_ACCESS',
  'ZON_BLUE_GND_WRIGHT_ACCESS',
  'ZON_BLUE_GND_HONAKER_ACCESS',
  'ZON_BLUE_GND_BOSTICK_ACCESS',
  'ZON_BLUE_GND_FENTY_PATROL_TEST_01',
  'ZON_BLUE_GND_FORTRESS_PATROL_TEST_01',
  'ZON_BLUE_GND_JOYCE_PATROL_TEST_01',
  'ZON_BLUE_GND_WRIGHT_PATROL_TEST_01',
  'ZON_BLUE_GND_HONAKER_PATROL_TEST_01',
  'ZON_BLUE_GND_BOSTICK_PATROL_TEST_01',
  'BRIGADE:New(',
  ':SetSpawnZone(',
  'PLATOON:New(',
  ':AddMissionCapability(AUFTRAG.Type.ARMOREDGUARD',
  'AUFTRAG:NewARMOREDGUARD(',
  'ENUMS.Formation.Vehicle.OnRoad',
  'ENUMS.Formation.Vehicle.Vee',
  'SetMissionSpeed(ROAD_SPEED_KNOTS)',
  'SetMissionSpeed(TACTICAL_SPEED_KNOTS)',
  'SetReturnToLegion(false)',
  ':__Cancel(APPROACH_HOLD_SEC)',
  ':CountAssets(true, AUFTRAG.Type.ARMOREDGUARD)',
  'ROAD_SPEED_KNOTS = 27',
  'TACTICAL_SPEED_KNOTS = 8',
  'OMW_GND_A3',
  'SITE_RUNTIME_PASS',
  'RUNTIME_PASS_VISUAL_PENDING',
  'GROUP_CROSS_SITE_COLLISION',
  'DUPLICATE_GROUP',
  'ROAD_ALIGNED_WAREHOUSE_SPAWN',
  '_SpawnAssetGroundNaval',
  '_SpawnAssetPrepareTemplate',
  'GetPathOnRoad',
  'GetInitialSize',
  'ROAD_SPAWN_VEHICLE_SPACING_M = 18',
  'ROAD_SPAWN_MAX_SNAP_M = 30'
)
foreach ($marker in $requiredMarkers) {
  if (-not $source.Contains($marker)) {
    throw "Ground Acceptance source is missing required marker: $marker"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  'mist\.',
  'MIST',
  'io\.',
  'lfs\.',
  'os\.execute',
  'LoadBackAssetInPosition',
  'SpawnFromCoordinate',
  ':Teleport\s*\(',
  'PATROLZONE'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($source -match $pattern) {
    throw "Ground Acceptance source contains forbidden pattern: $pattern"
  }
}

$privateSpawnMatches = [regex]::Matches($source, '_DATABASE:Spawn\(template\)')
if ($privateSpawnMatches.Count -ne 1) {
  throw "Ground Acceptance source must contain exactly one approved private warehouse spawn call; found: $($privateSpawnMatches.Count)"
}

if ($source -notmatch 'site\.brigade\._SpawnAssetGroundNaval\s*=\s*function') {
  throw 'Ground Acceptance source is missing the approved per-site warehouse spawn adapter.'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-army-ground-acceptance-3.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: six concurrent Kunar/Jalalabad mounted ground domains; TM01M-derived road-aligned per-unit Warehouse spawn adapter; ARMOREDGUARD On Road 27 kt approach; same-group Vee 8 kt tactical leg; stable observation halt; SetReturnToLegion(false).
-- Approved exception: per-site override of WAREHOUSE:_SpawnAssetGroundNaval and one _DATABASE:Spawn call only, preserving the existing BRIGADE/Warehouse request, asset, callback and ARMYGROUP lifecycle. MOOSE public WAREHOUSE API has no individual absolute-position/heading spawn hook.
-- Exclusions: no final Fortress/Honaker property-book quantity; no full CampaignState adapter; no restart/reconstitution; no Returned->Warehouse acceptance; no OPSTRANSPORT; no QRF; no artillery; no combat-loss settlement; no MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

[System.IO.File]::WriteAllText($outputFile, $header + $source, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "Sites: FENTY,FORTRESS,JOYCE,WRIGHT,HONAKER,BOSTICK"
Write-Host "Template: TPL_BLUE_GND_PATROL_MATV_4"
Write-Host "Mission1: ARMOREDGUARD / On Road / 27 kt"
Write-Host "Mission2: ARMOREDGUARD / Vee / 8 kt"
Write-Host "ApproachStandoffM: 1500"
Write-Host "MinimumTacticalLegM: 1050"
Write-Host "HoldStabilitySec: 20"
Write-Host "ReturnToLegion: false"
Write-Host "RoadAlignedWarehouseSpawn: TM01M-derived absolute unit positions; 18 m spacing; 30 m maximum road snap"
Write-Host "ApprovedPrivateWarehouseException: true"
Write-Host "CampaignStateAuthority: PRESERVED_TEST_BOOKKEEPING_ONLY"
Write-Host "FortressHonakerAllocation: TEST_ONLY_NO_PRODUCTION_QUANTITY"
Write-Host "VisualAcceptanceRequired: true"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
