[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\ground-native-homezone-return\src\01-ground-native-homezone-return-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\ground-native-homezone-return\dist'
$outputFile = Join-Path $distDir 'OMW_Ground_Native_Homezone_Return_Acceptance_1.lua'

$builderVersion = 'GROUND-NATIVE-HOMEZONE-RETURN-ACCEPTANCE-1-1'
$testId = 'GROUND-NATIVE-HOMEZONE-RETURN-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
  throw "Required acceptance source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
  'GROUND-NATIVE-HOMEZONE-RETURN-ACCEPTANCE-1',
  'WH_BLUE_GND_JOYCE',
  'TPL_BLUE_GND_PATROL_MATV_4',
  'ZON_BLUE_GND_JOYCE_PATROL_TEST_01',
  'Warehouse WH_BLUE_GND_JOYCE spawn zone',
  'BRIGADE:New(',
  'PLATOON:New(',
  'AddMissionCapability(AUFTRAG.Type.NOTHING',
  'AUFTRAG:NewNOTHING(',
  'SetDuration(MISSION_DURATION_SEC)',
  'OnAfterMissionDone',
  'OnAfterRTZ',
  'OnAfterReturned',
  'OnAfterAddAsset',
  'NATIVE_RTZ_ACTIVE',
  'WAREHOUSE_ADD_ASSET',
  'returnMode=NATIVE_MOOSE'
)
foreach ($marker in $requiredMarkers) {
  if (-not $source.Contains($marker)) {
    throw "Acceptance source is missing required marker: $marker"
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
  ':SetSpawnZone\s*\(',
  'SetReturnToLegion\s*\(\s*false\s*\)',
  ':RTZ\s*\(',
  ':Teleport\s*\(',
  'LoadBackAssetInPosition',
  'SpawnFromCoordinate'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($source -match $pattern) {
    throw "Acceptance source contains forbidden pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$sourceHash = (Get-FileHash -LiteralPath $sourceFile -Algorithm SHA256).Hash.ToUpperInvariant()

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-ground-native-homezone-return-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- Scope: isolated native MOOSE Ground return-to-origin via default Joyce Warehouse spawnzone; no SetSpawnZone override; no SetReturnToLegion(false); no explicit RTZ command.
-- Required ME objects: WH_BLUE_GND_JOYCE, TPL_BLUE_GND_PATROL_MATV_4, ZON_BLUE_GND_JOYCE_PATROL_TEST_01.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

[System.IO.File]::WriteAllText($outputFile, $header + $source, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GitCommit: $commit"
Write-Host "OriginWarehouse: WH_BLUE_GND_JOYCE"
Write-Host "Template: TPL_BLUE_GND_PATROL_MATV_4"
Write-Host "DestinationZone: ZON_BLUE_GND_JOYCE_PATROL_TEST_01"
Write-Host "ExpectedDefaultHomezone: Warehouse WH_BLUE_GND_JOYCE spawn zone"
Write-Host "MissionType: AUFTRAG.Type.NOTHING"
Write-Host "MissionSpeedKts: 27"
Write-Host "MissionDurationSec: 30"
Write-Host "SpawnZoneOverride: false"
Write-Host "SetReturnToLegionFalse: false"
Write-Host "ExplicitRTZ: false"
Write-Host "DirectSpawn: false"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SourceSHA256: $sourceHash"
Write-Host "SHA256: $hash"
