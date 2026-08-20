[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\army-ground-foundation\src\01-army-ground-acceptance-1.lua'
$distDir = Join-Path $repoRoot 'mission\tests\army-ground-foundation\dist'
$outputFile = Join-Path $distDir 'OMW_Army_Ground_Acceptance_1.lua'

$builderVersion = 'ARMY-GROUND-ACCEPTANCE-1-1'
$testId = 'ARMY-GROUND-ACCEPTANCE-1-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
  throw "Required Ground Acceptance source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
  'ARMY-GROUND-ACCEPTANCE-1-1',
  'WH_BLUE_GND_JOYCE',
  'BDE_BLUE_GND_JOYCE',
  'PLT_BLUE_GND_JOYCE_PATROL',
  'TPL_BLUE_GND_PATROL_MATV_4',
  'ZON_BLUE_GND_JOYCE_ACCESS',
  'ZON_BLUE_GND_JOYCE_PATROL_TEST_01',
  'BRIGADE:New(',
  'brigade:SetSpawnZone(',
  'PLATOON:New(',
  'platoon:AddMissionCapability(AUFTRAG.Type.PATROLZONE',
  'AUFTRAG:NewPATROLZONE(',
  'SetReturnToLegion(false)',
  'state.mission1:__Cancel(',
  'function brigade:OnAfterAssetSpawned',
  'function brigade:OnAfterArmyOnMission',
  'function armyGroup:OnAfterMissionDone',
  'platoon:CountAssets(true, AUFTRAG.Type.PATROLZONE)',
  'OMW_GND_A1',
  'GROUP_MATERIALIZED',
  'MISSION1_DONE',
  'GROUP_STILL_ALIVE',
  'MISSION2_QUEUED',
  'SAME_GROUP_REUSED',
  'DUPLICATE_GROUP',
  'PASS reservation='
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
  '_DATABASE',
  'mist\.',
  'MIST',
  'io\.',
  'lfs\.',
  'os\.execute',
  'LoadBackAssetInPosition',
  'SpawnFromCoordinate',
  ':Teleport\s*\('
)
foreach ($pattern in $forbiddenPatterns) {
  if ($source -match $pattern) {
    throw "Ground Acceptance source contains forbidden pattern: $pattern"
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
-- Builder: tools/build-army-ground-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: Joyce single-BRIGADE / single-PLATOON ground lifecycle acceptance; PATROLZONE dispatch; SetReturnToLegion(false); MissionDone field persistence; same-group follow-up reuse.
-- Exclusions: no full CampaignState adapter; no restart/reconstitution; no Returned->Warehouse acceptance; no OPSTRANSPORT; no QRF; no artillery; no combat-loss settlement; no MIZ mutation.
-- Required ME objects: WH_BLUE_GND_JOYCE, TPL_BLUE_GND_PATROL_MATV_4, ZON_BLUE_GND_JOYCE_ACCESS, ZON_BLUE_GND_JOYCE_PATROL_TEST_01.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

[System.IO.File]::WriteAllText($outputFile, $header + $source, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GroundNode: GROUND_NODE_JOYCE"
Write-Host "Warehouse: WH_BLUE_GND_JOYCE"
Write-Host "Brigade: BDE_BLUE_GND_JOYCE"
Write-Host "Platoon: PLT_BLUE_GND_JOYCE_PATROL"
Write-Host "Template: TPL_BLUE_GND_PATROL_MATV_4"
Write-Host "AccessZone: ZON_BLUE_GND_JOYCE_ACCESS"
Write-Host "PatrolZone: ZON_BLUE_GND_JOYCE_PATROL_TEST_01"
Write-Host "MissionType: PATROLZONE"
Write-Host "ReturnToLegion: false"
Write-Host "CampaignStateAuthority: PRESERVED_TEST_BOOKKEEPING_ONLY"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
