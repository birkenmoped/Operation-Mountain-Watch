[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\army-ground-foundation\src\04-army-ground-acceptance-4.lua'
$distDir = Join-Path $repoRoot 'mission\tests\army-ground-foundation\dist'
$outputFile = Join-Path $distDir 'OMW_Army_Ground_Acceptance_4.lua'

$builderVersion = 'ARMY-GROUND-ACCEPTANCE-4-1'
$testId = 'ARMY-GROUND-ACCEPTANCE-4-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
  throw "Required Ground Acceptance source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
  'ARMY-GROUND-ACCEPTANCE-4-1',
  'WH_BLUE_GND_FENTY',
  'BDE_BLUE_GND_JALALABAD_RETURN_ACCEPTANCE',
  'PLT_BLUE_GND_JALALABAD_RETURN_MATV',
  'TPL_BLUE_GND_PATROL_MATV_4',
  'ZON_BLUE_GND_FENTY_ACCESS',
  'ZON_BLUE_GND_FENTY_PATROL_TEST_01',
  'ZON_BLUE_GND_FENTY_RETURN_HANDOFF_01',
  'BRIGADE:New(',
  ':SetSpawnZone(',
  'PLATOON:New(',
  ':AddMissionCapability(AUFTRAG.Type.ARMOREDGUARD',
  'AUFTRAG:NewARMOREDGUARD(',
  'ENUMS.Formation.Vehicle.OnRoad',
  'SetMissionSpeed(ROAD_SPEED_KNOTS)',
  'SetReturnToLegion(false)',
  ':__Cancel(APPROACH_HOLD_SEC)',
  ':RTZ(site.returnZoneObject, ENUMS.Formation.Vehicle.OnRoad)',
  'OnAfterReturned',
  'OnAfterAddAsset',
  'WAREHOUSE_ADD_ASSET',
  'PHYSICAL_GROUP_NOT_REMOVED_AFTER_WAREHOUSE_ADD',
  'SITE_RUNTIME_PASS',
  'RUNTIME_PASS_VISUAL_PENDING',
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
-- Builder: tools/build-army-ground-acceptance-4.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: one Fenty road-aligned BRIGADE/Warehouse materialization; ARMOREDGUARD On Road 27 kt; MissionDone physical retention; public ARMYGROUP:RTZ to a non-observable owner-defined handoff zone; Returned -> delayed Warehouse AddAsset -> physical group removal.
-- Approved exception: unchanged, per-BRIGADE road-aligned Warehouse spawn adapter from Acceptance 3-2. It preserves the Warehouse request, asset reservation, callbacks and ARMYGROUP/AUFTRAG lifecycle. No new private return adapter is used.
-- Exclusions: no CampaignState settlement; no production resource credit; no restart/reconstitution; no cross-session state; no OPSTRANSPORT; no QRF; no artillery; no combat-loss settlement; no MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

[System.IO.File]::WriteAllText($outputFile, $header + $source, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "Site: FENTY"
Write-Host "Template: TPL_BLUE_GND_PATROL_MATV_4"
Write-Host "Outbound: ARMOREDGUARD / On Road / 27 kt"
Write-Host "MissionDone: physical group retained"
Write-Host "Return: ARMYGROUP:RTZ / On Road / owner return handoff zone"
Write-Host "WarehouseReturn: Returned -> __AddAsset(10) -> physical group removal"
Write-Host "RoadAlignedWarehouseSpawn: reused Acceptance-3-2 adapter; 18 m spacing; 30 m maximum road snap"
Write-Host "ApprovedPrivateWarehouseException: unchanged existing adapter only"
Write-Host "CampaignStateAuthority: PRESERVED_NO_SETTLEMENT"
Write-Host "VisualAcceptanceRequired: true"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
