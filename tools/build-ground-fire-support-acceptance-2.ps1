[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$roadSpawnFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundRoadSpawnAdapter.lua'
$materializerFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundSupportMaterializer.lua'
$fixedSupportFile = Join-Path $repoRoot 'scripts\ground\OMW_FixedFireSupportAmmoSupport.lua'
$rearmAdapterFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundAmmoRearmAdapter.lua'
$fixedRearmFile = Join-Path $repoRoot 'scripts\ground\OMW_FixedFireSupportAmmoRearmService.lua'
$harnessFile = Join-Path $repoRoot 'mission\tests\ground-ammo-rearm-integration\src\02-fixed-fire-support-combined-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\ground-ammo-rearm-integration\dist'
$outputFile = Join-Path $distDir 'OMW_Ground_Fire_Support_Acceptance_2.lua'

$builderVersion = 'GROUND-FIRE-SUPPORT-ACCEPTANCE-2-1'
$testId = 'GROUND-FIRE-SUPPORT-ACCEPTANCE-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = @(
  $roadSpawnFile,
  $materializerFile,
  $fixedSupportFile,
  $rearmAdapterFile,
  $fixedRearmFile,
  $harnessFile
)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Ground fire-support acceptance source not found: $file"
  }
}

$roadSpawn = Get-Content -LiteralPath $roadSpawnFile -Raw -Encoding UTF8
$materializer = Get-Content -LiteralPath $materializerFile -Raw -Encoding UTF8
$fixedSupport = Get-Content -LiteralPath $fixedSupportFile -Raw -Encoding UTF8
$rearmAdapter = Get-Content -LiteralPath $rearmAdapterFile -Raw -Encoding UTF8
$fixedRearm = Get-Content -LiteralPath $fixedRearmFile -Raw -Encoding UTF8
$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8
$combined = $roadSpawn + $materializer + $fixedSupport + $rearmAdapter + $fixedRearm + $harness

$requiredMarkers = @(
  'GROUND-FIRE-SUPPORT-ACCEPTANCE-2',
  'WH_BLUE_GND_BOSTICK',
  'WH_BLUE_GND_WRIGHT',
  'WH_BLUE_GND_FORTRESS',
  'WH_BLUE_GND_HONAKER',
  'ZON_BLUE_GND_BOSTICK_ACCESS',
  'ZON_BLUE_GND_WRIGHT_ACCESS',
  'ZON_BLUE_GND_FORTRESS_ACCESS',
  'ZON_BLUE_GND_HONAKER_ACCESS',
  'ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET',
  'ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET',
  'ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET',
  'ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET',
  'TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2',
  'TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2',
  'TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1',
  'TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2',
  'TPL_BLUE_GND_SUP_M1083',
  'GROUND_NODE_BOSTICK',
  'GROUND_NODE_WRIGHT',
  'GROUND_NODE_FORTRESS',
  'GROUND_NODE_HONAKER',
  'GROUND_AMMO_PACKAGE',
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
  'SITE_PASS site=',
  'FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Ground fire-support acceptance sources are missing required marker: $marker"
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
    throw "Ground fire-support acceptance sources contain forbidden pattern: $pattern"
  }
}

$privateSpawnMatches = [regex]::Matches($combined, '_DATABASE:Spawn\(template\)')
if ($privateSpawnMatches.Count -ne 1) {
  throw "Ground fire-support acceptance must contain exactly one approved RoadSpawnAdapter private database spawn call; found: $($privateSpawnMatches.Count)"
}

if ($roadSpawn -notmatch 'brigade\._SpawnAssetGroundNaval\s*=\s*function') {
  throw 'Ground RoadSpawnAdapter approved Warehouse spawn override was not found.'
}
if ($rearmAdapter -notmatch 'if startArty then\s+arty:Start\(\)') {
  throw 'Ground ammo rearm adapter is missing the guarded ARTY Start path.'
}
if ($harness -notmatch 'startArty\s*=\s*false') {
  throw 'Combined acceptance harness must preserve prestarted ARTY full-ammo baselines.'
}
if ($harness -notmatch 'for _, spec in ipairs\(SITE_SPECS\) do\s+startSite') {
  throw 'Combined acceptance harness must launch all configured site legs in the same run.'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) {
  throw 'Unable to resolve Git HEAD for Ground fire-support acceptance build.'
}
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-ground-fire-support-acceptance-2.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: concurrent Bostick/Wright/Fortress L118 plus Honaker 2B11 firing -> local M1083 Warehouse self-request materialization -> local CampaignState GROUND_AMMO_PACKAGE consumption -> MOOSE ARTY RearmingGroup rearm -> per-site and aggregate confirmation.
-- Bostick role: regression of the already accepted fixed-battery path after source hardening/generalization.
-- Strategic authority: existing OMW.Ground.Base authoritative CampaignState store only.
-- Approved private exception: existing OMW_GroundRoadSpawnAdapter Warehouse per-unit road geometry injection only.
-- MIZ mutation: false. Safe target geometry must be supplied by the four named Mission Editor target zones.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'GroundRoadSpawnAdapter' $roadSpawn
$bundle += Embed-Module 'GroundSupportMaterializer' $materializer
$bundle += Embed-Module 'FixedFireSupportAmmoSupport' $fixedSupport
$bundle += Embed-Module 'GroundAmmoRearmAdapter' $rearmAdapter
$bundle += Embed-Module 'FixedFireSupportAmmoRearmService' $fixedRearm
$bundle += $harness

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "Sites: BOSTICK,WRIGHT,FORTRESS,HONAKER"
Write-Host "BostickBattery: TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2"
Write-Host "WrightBattery: TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2"
Write-Host "FortressBattery: TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1"
Write-Host "HonakerBattery: TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2"
Write-Host "SupportTemplate: TPL_BLUE_GND_SUP_M1083"
Write-Host "StrategicResource: GROUND_AMMO_PACKAGE"
Write-Host "StrategicQuantityPerSite: 1"
Write-Host "FireShellsPerSite: 4"
Write-Host "ConcurrentSiteLegs: true"
Write-Host "PrestartedARTYPreserved: true"
Write-Host "ApprovedRoadSpawnException: true"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
