[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\army-ground-foundation\src\06-army-ground-acceptance-7.lua'
$campaignStateSourceFile = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
$groundAdapterSourceFile = Join-Path $repoRoot 'scripts\ground\OMW_GroundCampaignStateAdapter.lua'
$distDir = Join-Path $repoRoot 'mission\tests\army-ground-foundation\dist'
$outputFile = Join-Path $distDir 'OMW_Army_Ground_Acceptance_7.lua'

$builderVersion = 'ARMY-GROUND-ACCEPTANCE-7-1'
$testId = 'ARMY-GROUND-ACCEPTANCE-7-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
  throw "Required Ground Acceptance source not found: $sourceFile"
}
if (-not (Test-Path -LiteralPath $campaignStateSourceFile -PathType Leaf)) {
  throw "Required CampaignState source not found: $campaignStateSourceFile"
}
if (-not (Test-Path -LiteralPath $groundAdapterSourceFile -PathType Leaf)) {
  throw "Required Ground CampaignState adapter source not found: $groundAdapterSourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8
$campaignStateSource = Get-Content -LiteralPath $campaignStateSourceFile -Raw -Encoding UTF8
$groundAdapterSource = Get-Content -LiteralPath $groundAdapterSourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
  'ARMY-GROUND-ACCEPTANCE-7-1',
  'ARMY-GROUND-ACCEPTANCE-7-1',
  'GROUND_NODE_JALALABAD',
  'GROUND_NODE_JOYCE',
  'GROUND_NODE_WRIGHT',
  'GROUND:GROUND_NODE_JALALABAD:VEHICLE',
  'GROUND:GROUND_NODE_JALALABAD:PERSONNEL',
  'GroundCampaignStateAdapter.New',
  'OnMaterialized',
  'OnReturned',
  'OnLost',
  'ReconcileRestore',
  'CAMPAIGNSTATE_DEPLOYMENT_COMMITTED',
  'CAMPAIGNSTATE_LOSS_RECORDED',
  'CAMPAIGNSTATE_RETURN_CREDIT',
  'CAMPAIGNSTATE_RESTART_RECONCILED',
  'CAMPAIGNSTATE_EXACTLY_ONCE',
  'PARTIAL_LOSS',
  'PARTIAL_LOSS_WITH_DAMAGE',
  'SCENARIO_LOSS_APPLIED',
  'SCENARIO_DAMAGE_APPLIED',
  'SCENARIO_DAMAGE_CONFIRMED',
  ':Destroy(false)',
  ':SetLife(50)',
  'SCENARIO_READY_FOR_RETURN',
  'WH_BLUE_GND_FENTY',
  'WH_BLUE_GND_JOYCE',
  'WH_BLUE_GND_WRIGHT',
  'BDE_BLUE_GND_FENTY_A7_NORMAL_RETURN',
  'BDE_BLUE_GND_JOYCE_A7_PARTIAL_LOSS',
  'BDE_BLUE_GND_WRIGHT_A7_PARTIAL_LOSS_DAMAGE',
  'PLT_BLUE_GND_FENTY_A7_MATV',
  'PLT_BLUE_GND_JOYCE_A7_MATV',
  'PLT_BLUE_GND_WRIGHT_A7_MATV',
  'TPL_BLUE_GND_PATROL_MATV_4',
  'ZON_BLUE_GND_FENTY_ACCESS',
  'ZON_BLUE_GND_JOYCE_ACCESS',
  'ZON_BLUE_GND_WRIGHT_ACCESS',
  'ZON_BLUE_GND_FENTY_PATROL_TEST_01',
  'ZON_BLUE_GND_JOYCE_PATROL_TEST_01',
  'ZON_BLUE_GND_WRIGHT_PATROL_TEST_01',
  'BRIGADE:New(',
  ':SetSpawnZone(',
  'PLATOON:New(',
  ':AddMissionCapability(AUFTRAG.Type.ARMOREDGUARD',
  'AUFTRAG:NewARMOREDGUARD(',
  'ENUMS.Formation.Vehicle.OnRoad',
  'SetMissionSpeed(ROAD_SPEED_KNOTS)',
  'SetReturnToLegion(false)',
  ':__Cancel(APPROACH_HOLD_SEC)',
  ':RTZ(site.accessZoneObject, ENUMS.Formation.Vehicle.OnRoad)',
  'RETURN_SETTLEMENT_DELAY_SEC = 30',
  'RETURN_RTZ_ISSUED',
  'RETURN_RTZ_ACTIVE',
  'RETURN_IN_PROGRESS',
  'RETURN_TIMEOUT',
  'OnAfterRTZ',
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

$requiredGroundAdapterMarkers = @(
  'local Adapter = {}',
  'function Adapter:OnMaterialized(spec)',
  'function Adapter:OnReturned(runtimeId, returnedVehicleCount)',
  'function Adapter:OnLost(runtimeId, lostVehicleCount, lossResourceIds)',
  'function Adapter:ReconcileRestore()',
  'return Adapter'
)
foreach ($marker in $requiredGroundAdapterMarkers) {
  if (-not $groundAdapterSource.Contains($marker)) {
    throw "Ground CampaignState adapter source is missing required marker: $marker"
  }
}

$requiredCampaignStateMarkers = @(
  'local CampaignState = {}',
  'function Store:ReserveResource(spec)',
  'function Store:Consume(transactionId)',
  'function Store:CreditResourceOnce(spec)',
  'return CampaignState'
)
foreach ($marker in $requiredCampaignStateMarkers) {
  if (-not $campaignStateSource.Contains($marker)) {
    throw "CampaignState source is missing required marker: $marker"
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
-- Builder: tools/build-army-ground-acceptance-7.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: combined production-shaped three-site settlement: every M-ATV reserves 1 VEHICLE and 3 PERSONNEL from the approved node baseline. Fenty returns 4; Joyce returns 3 after 1 confirmed loss; Wright returns 3 including 1 damaged survivor. The bundle also verifies a separate restored CampaignState snapshot recredits an unresolved 4-vehicle/12-personnel commitment exactly once.
-- Approved exception: unchanged, per-BRIGADE road-aligned Warehouse spawn adapter from Acceptance 3-2. It preserves the Warehouse request, asset reservation, callbacks and ARMYGROUP/AUFTRAG lifecycle. No new private return adapter is used.
-- Exclusions: no persistent production-state mutation, no DCS group continuation/respawn after restart, no OPSTRANSPORT, no QRF, no artillery, and no MIZ mutation. Test-only MOOSE loss/damage injection is included.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$embeddedCampaignState = "local CampaignState = (function()`n" + $campaignStateSource + "`nend)()`n`n"
$embeddedGroundAdapter = "local GroundCampaignStateAdapter = (function()`n" + $groundAdapterSource + "`nend)()`n`n"
[System.IO.File]::WriteAllText($outputFile, $header + $embeddedCampaignState + $embeddedGroundAdapter + $source, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "Sites: FENTY,JOYCE,WRIGHT"
Write-Host "Template: TPL_BLUE_GND_PATROL_MATV_4"
Write-Host "Outbound: ARMOREDGUARD / On Road / 27 kt"
Write-Host "MissionDone: physical group retained; 30 s settlement; test-only MOOSE loss/damage injection where required"
Write-Host "Return: ARMYGROUP:RTZ / On Road / each site existing ACCESS zone; state/progress diagnostics; timeout 900 s"
Write-Host "WarehouseReturn: Returned -> __AddAsset(10) -> physical group removal"
Write-Host "RoadAlignedWarehouseSpawn: reused Acceptance-3-2 adapter; 18 m spacing; 30 m maximum road snap"
Write-Host "ApprovedPrivateWarehouseException: unchanged existing adapter only"
Write-Host "CampaignState: approved-node-shaped isolated stores; each M-ATV consumes 1 VEHICLE + 3 PERSONNEL; Fenty 4->4, Joyce/Wright 4->3; confirmed loss audit and restart reconciliation verified exactly once"
Write-Host "VisualAcceptanceRequired: true"
Write-Host "ProductionBaselineMutation: false"
Write-Host "MizMutation: false"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"