[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$roadSpawnFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundRoadSpawnAdapter.lua'
$materializerFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundSupportMaterializer.lua'
$bostickSupportFile = Join-Path $repoRoot 'scripts\ground\OMW_BostickAmmoSupport.lua'
$rearmAdapterFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundAmmoRearmAdapter.lua'
$bostickRearmFile = Join-Path $repoRoot 'scripts\ground\OMW_BostickAmmoRearmService.lua'
$harnessFile = Join-Path $repoRoot 'mission\tests\ground-ammo-rearm-integration\src\01-bostick-m1083-rearm-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\ground-ammo-rearm-integration\dist'
$outputFile = Join-Path $distDir 'OMW_Ground_Ammo_Rearm_Acceptance_1.lua'

$builderVersion = 'GROUND-AMMO-REARM-ACCEPTANCE-1'
$testId = 'GROUND-AMMO-REARM-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = @(
  $roadSpawnFile,
  $materializerFile,
  $bostickSupportFile,
  $rearmAdapterFile,
  $bostickRearmFile,
  $harnessFile
)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Ground ammo rearm acceptance source not found: $file"
  }
}

$roadSpawn = Get-Content -LiteralPath $roadSpawnFile -Raw -Encoding UTF8
$materializer = Get-Content -LiteralPath $materializerFile -Raw -Encoding UTF8
$bostickSupport = Get-Content -LiteralPath $bostickSupportFile -Raw -Encoding UTF8
$rearmAdapter = Get-Content -LiteralPath $rearmAdapterFile -Raw -Encoding UTF8
$bostickRearm = Get-Content -LiteralPath $bostickRearmFile -Raw -Encoding UTF8
$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8
$combined = $roadSpawn + $materializer + $bostickSupport + $rearmAdapter + $bostickRearm + $harness

$requiredMarkers = @(
  'GROUND-AMMO-REARM-ACCEPTANCE-1',
  'WH_BLUE_GND_BOSTICK',
  'ZON_BLUE_GND_BOSTICK_ACCESS',
  'ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET',
  'TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2',
  'TPL_BLUE_GND_SUP_M1083',
  'GROUND_NODE_BOSTICK',
  'GROUND_AMMO_PACKAGE',
  'BOSTICK-AMMO-SUPPORT-M1083',
  'ARTY:New(',
  'AssignTargetCoord(',
  'GetAmmo(',
  'SetRearmingGroup',
  'OnAfterCeaseFire',
  'OnAfterRearmed',
  'startArty = false',
  'WAREHOUSE.Descriptor.GROUPNAME',
  'PLATOON:New(',
  'BRIGADE:New(',
  'OMW_GROUND_READY',
  'OMW.Ground.Base.GetContext()',
  'M1083_REARM_CONFIRMED=true'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Ground ammo rearm acceptance sources are missing required marker: $marker"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  'mist\.',
  'MIST',
  '(?<![A-Za-z0-9_])io\.',
  'lfs\.',
  'os\.execute',
  ':Teleport\s*\(',
  'LoadBackAssetInPosition',
  'SpawnFromCoordinate',
  'AMMOTRUCK:'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($combined -match $pattern) {
    throw "Ground ammo rearm acceptance sources contain forbidden pattern: $pattern"
  }
}

$privateSpawnMatches = [regex]::Matches($combined, '_DATABASE:Spawn\(template\)')
if ($privateSpawnMatches.Count -ne 1) {
  throw "Ground ammo rearm acceptance must contain exactly one approved RoadSpawnAdapter private database spawn call; found: $($privateSpawnMatches.Count)"
}

if ($roadSpawn -notmatch 'brigade\._SpawnAssetGroundNaval\s*=\s*function') {
  throw 'Ground RoadSpawnAdapter approved Warehouse spawn override was not found.'
}
if ($rearmAdapter -notmatch 'if startArty then\s+arty:Start\(\)') {
  throw 'Ground ammo rearm adapter is missing the guarded ARTY Start path.'
}
if ($harness -notmatch 'startArty\s*=\s*false') {
  throw 'Acceptance harness must preserve the prestarted ARTY full-ammo baseline.'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Ground ammo rearm acceptance build.'
}
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-ground-ammo-rearm-acceptance.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: Bostick fixed L118 firing -> M1083 Warehouse self-request materialization -> CampaignState GROUND_AMMO_PACKAGE consumption -> ARTY rearm -> Rearmed/full-ammo confirmation.
-- Strategic authority: existing OMW.Ground.Base authoritative CampaignState store only.
-- Approved private exception: existing OMW_GroundRoadSpawnAdapter Warehouse per-unit road geometry injection only.
-- MIZ mutation: false. Target geometry is supplied by ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET in the owner mission.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'GroundRoadSpawnAdapter' $roadSpawn
$bundle += Embed-Module 'GroundSupportMaterializer' $materializer
$bundle += Embed-Module 'BostickAmmoSupport' $bostickSupport
$bundle += Embed-Module 'GroundAmmoRearmAdapter' $rearmAdapter
$bundle += Embed-Module 'BostickAmmoRearmService' $bostickRearm
$bundle += $harness

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "Battery: TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2"
Write-Host "SupportTemplate: TPL_BLUE_GND_SUP_M1083"
Write-Host "AccessZone: ZON_BLUE_GND_BOSTICK_ACCESS"
Write-Host "TargetZone: ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET"
Write-Host "StrategicNode: GROUND_NODE_BOSTICK"
Write-Host "StrategicResource: GROUND_AMMO_PACKAGE"
Write-Host "StrategicQuantity: 1"
Write-Host "FireShells: 4"
Write-Host "PrestartedARTYPreserved: true"
Write-Host "ApprovedRoadSpawnException: true"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
