[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$distDir = Join-Path $repoRoot 'mission\runtime\logistics'
$outputFile = Join-Path $distDir 'OMW_AirOps_Warehouse_Base.lua'

$builderVersion = 'OMW-AIROPS-WAREHOUSE-BASE-3'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = [ordered]@{
  CampaignState = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
  ResourceManifest = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsResourceManifest.lua'
  InitialStock = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsInitialStock.lua'
  InitialJP8Stock = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsInitialJP8Stock.lua'
  FuelSupplement = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsInitialFuelSupplement.lua'
  AARStrategicStock = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
  GroundInitialStock = Join-Path $repoRoot 'scripts\logistics\OMW_GroundInitialStock.lua'
  CampaignStateInitializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
  StorageInitializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsStorageInitializer.lua'
  TechnicalAvailability = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsTechnicalAvailability.lua'
  TechnicalAvailabilityInitializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsTechnicalAvailabilityInitializer.lua'
  StorageFuelAdapter = Join-Path $repoRoot 'scripts\logistics\OMW_StorageFuelAdapter.lua'
  CampaignStateStorageSync = Join-Path $repoRoot 'scripts\logistics\OMW_CampaignStateStorageSync.lua'
  WarehouseBootstrap = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsWarehouseBootstrap.lua'
  WarehouseProduction = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsWarehouseProduction.lua'
}

foreach ($entry in $files.GetEnumerator()) {
  if (-not (Test-Path -LiteralPath $entry.Value -PathType Leaf)) {
    throw "Required Warehouse production-base source not found: $($entry.Value)"
  }
}

$content = @{}
foreach ($entry in $files.GetEnumerator()) {
  $content[$entry.Key] = Get-Content -LiteralPath $entry.Value -Raw -Encoding UTF8
}

$requiredMarkers = @(
  @{ File = 'CampaignState'; Marker = 'function CampaignState.New(initialState)' },
  @{ File = 'CampaignState'; Marker = 'function CampaignState.Restore(snapshot)' },
  @{ File = 'ResourceManifest'; Marker = 'function AirOpsResourceManifest.GetEntries()' },
  @{ File = 'InitialStock'; Marker = 'OMW-AIROPS-INITIAL-STOCK-1' },
  @{ File = 'InitialJP8Stock'; Marker = 'OMW-AIROPS-INITIAL-JP8-STOCK-1' },
  @{ File = 'InitialJP8Stock'; Marker = 'v0.3-RELEASE' },
  @{ File = 'InitialJP8Stock'; Marker = 'initial = 5000000' },
  @{ File = 'InitialJP8Stock'; Marker = 'initial = 3500000' },
  @{ File = 'InitialJP8Stock'; Marker = 'initial = 575000' },
  @{ File = 'InitialJP8Stock'; Marker = 'initial = 180000' },
  @{ File = 'InitialJP8Stock'; Marker = 'initial = 1200000' },
  @{ File = 'InitialJP8Stock'; Marker = 'initial = 950000' },
  @{ File = 'InitialJP8Stock'; Marker = 'initial = 450000' },
  @{ File = 'FuelSupplement'; Marker = 'OMW-AIROPS-INITIAL-FUEL-SUPPLEMENT-1' },
  @{ File = 'AARStrategicStock'; Marker = 'OMW-AAR-STRATEGIC-STOCK-2' },
  @{ File = 'AARStrategicStock'; Marker = 'OFFMAP_MANAS' },
  @{ File = 'AARStrategicStock'; Marker = 'OFFMAP_AL_UDEID' },
  @{ File = 'GroundInitialStock'; Marker = 'OMW-GROUND-INITIAL-STOCK-2' },
  @{ File = 'GroundInitialStock'; Marker = 'GROUND_NODE_JALALABAD' },
  @{ File = 'GroundInitialStock'; Marker = 'GROUND_NODE_BOSTICK' },
  @{ File = 'GroundInitialStock'; Marker = 'GROUND_AMMO_PACKAGE' },
  @{ File = 'CampaignStateInitializer'; Marker = 'function Initializer.CreateStore' },
  @{ File = 'CampaignStateInitializer'; Marker = 'GROUND_NODE_JALALABAD' },
  @{ File = 'StorageInitializer'; Marker = 'function StorageInitializer.Apply' },
  @{ File = 'TechnicalAvailabilityInitializer'; Marker = 'function TechnicalAvailabilityInitializer.Apply' },
  @{ File = 'StorageFuelAdapter'; Marker = 'StorageFuelAdapter.ReadbackToleranceKg = 0.5' },
  @{ File = 'StorageFuelAdapter'; Marker = 'STORAGE.Liquid.JETFUEL' },
  @{ File = 'StorageFuelAdapter'; Marker = 'STORAGE.Liquid.GASOLINE' },
  @{ File = 'CampaignStateStorageSync'; Marker = 'function CampaignStateStorageSync.New' },
  @{ File = 'CampaignStateStorageSync'; Marker = 'resourceIdsByNode' },
  @{ File = 'WarehouseBootstrap'; Marker = 'OMW-AIROPS-WAREHOUSE-BOOTSTRAP-1' },
  @{ File = 'WarehouseProduction'; Marker = 'OMW-AIROPS-WAREHOUSE-PRODUCTION-3' },
  @{ File = 'WarehouseProduction'; Marker = 'READY_FLAG_NAME = "OMW_WAREHOUSE_READY"' },
  @{ File = 'WarehouseProduction'; Marker = 'groundInitialStock' },
  @{ File = 'WarehouseProduction'; Marker = 'readyFlag:Set(0)' },
  @{ File = 'WarehouseProduction'; Marker = 'readyFlag:Set(1)' },
  @{ File = 'WarehouseProduction'; Marker = 'Scope = "PRODUCTION_WAREHOUSE_BASE"' },
  @{ File = 'WarehouseProduction'; Marker = 'TestHarness = false' }
)

foreach ($requirement in $requiredMarkers) {
  if (-not $content[$requirement.File].Contains($requirement.Marker)) {
    throw "Missing Warehouse production-base marker in $($requirement.File): $($requirement.Marker)"
  }
}

$forbiddenPatterns = @(
  'AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE',
  '\[OMW-TEST\]',
  'JP8_PRESERVATION_FIXTURE',
  'TEST_PRESERVE_EXISTING_CLOSED_JP8',
  'NEW_PREFLIGHT_PASS',
  'NEW_APPLY_PASS',
  'RESTORE_PASS',
  'AIR_OPS_START_GATE_PASS',
  'RESULT status=PASS',
  'MissionScripting\.lua',
  'mist\.',
  '\bMIST\b',
  'io\.',
  'lfs\.',
  'os\.execute'
)

foreach ($entry in $content.GetEnumerator()) {
  foreach ($pattern in $forbiddenPatterns) {
    if ($entry.Value -match $pattern) {
      throw "Forbidden acceptance/native marker in Warehouse production source $($entry.Key): $pattern"
    }
  }
}

if ($content.WarehouseProduction -match 'SCHEDULER\s*:' -or
    $content.WarehouseProduction -match 'timer\.scheduleFunction' -or
    $content.WarehouseProduction -match 'world\.addEventHandler') {
  throw 'Warehouse production bootstrap must remain one-shot and scheduler-free'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-air-ops-warehouse-production-base.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- Scope: permanent OMW AirOps Warehouse production base.
-- CampaignState: sole strategic resource authority; single OMW.AirOps.CampaignContext.
-- Strategic domains seeded at NEW context creation: AirOps, AAR, Ground.
-- Ground stock schema: OMW-GROUND-INITIAL-STOCK-2.
-- STORAGE: one-shot physical/technical mirror with existing readback contracts.
-- JP-8 baseline: owner-approved OMW v0.3-RELEASE strategic design values.
-- Ready gate: OMW_WAREHOUSE_READY is fail-closed and opens only after verified bootstrap completion.
-- Acceptance/test mechanisms: absent.
-- No automated MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$bundle = $header
$bundle += "local OMW_WAREHOUSE_BASE_CampaignState = (function()`n" + $content.CampaignState + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_ResourceManifest = (function()`n" + $content.ResourceManifest + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_InitialStock = (function()`n" + $content.InitialStock + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_InitialJP8Stock = (function()`n" + $content.InitialJP8Stock + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_FuelSupplement = (function()`n" + $content.FuelSupplement + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_AARStrategicStock = (function()`n" + $content.AARStrategicStock + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_GroundInitialStock = (function()`n" + $content.GroundInitialStock + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_CampaignStateInitializer = (function()`n" + $content.CampaignStateInitializer + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_StorageInitializer = (function()`n" + $content.StorageInitializer + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_TechnicalAvailability = (function()`n" + $content.TechnicalAvailability + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_TechnicalAvailabilityInitializer = (function()`n" + $content.TechnicalAvailabilityInitializer + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_StorageFuelAdapter = (function()`n" + $content.StorageFuelAdapter + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_CampaignStateStorageSync = (function()`n" + $content.CampaignStateStorageSync + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_WarehouseBootstrap = (function()`n" + $content.WarehouseBootstrap + "`nend)()`n"
$bundle += "local OMW_WAREHOUSE_BASE_Production = (function()`n" + $content.WarehouseProduction + "`nend)()`n"
$bundle += @"
OMW_WAREHOUSE_BASE_Production.Start({
  campaignState = OMW_WAREHOUSE_BASE_CampaignState,
  resourceManifest = OMW_WAREHOUSE_BASE_ResourceManifest,
  initialStock = OMW_WAREHOUSE_BASE_InitialStock,
  initialJP8Stock = OMW_WAREHOUSE_BASE_InitialJP8Stock,
  fuelSupplement = OMW_WAREHOUSE_BASE_FuelSupplement,
  aarStrategicStock = OMW_WAREHOUSE_BASE_AARStrategicStock,
  groundInitialStock = OMW_WAREHOUSE_BASE_GroundInitialStock,
  campaignStateInitializer = OMW_WAREHOUSE_BASE_CampaignStateInitializer,
  storageInitializer = OMW_WAREHOUSE_BASE_StorageInitializer,
  technicalAvailability = OMW_WAREHOUSE_BASE_TechnicalAvailability,
  technicalAvailabilityInitializer = OMW_WAREHOUSE_BASE_TechnicalAvailabilityInitializer,
  fuelAdapter = OMW_WAREHOUSE_BASE_StorageFuelAdapter,
  fuelSyncModule = OMW_WAREHOUSE_BASE_CampaignStateStorageSync,
  warehouseBootstrap = OMW_WAREHOUSE_BASE_WarehouseBootstrap,
})
"@

foreach ($pattern in $forbiddenPatterns) {
  if ($bundle -match $pattern) {
    throw "Generated Warehouse production base contains forbidden marker: $pattern"
  }
}

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host 'DeterministicBundleForCommit: true'
Write-Host 'Scope: PRODUCTION_WAREHOUSE_BASE'
Write-Host 'CampaignStateAuthority: OMW.AirOps.CampaignContext'
Write-Host 'CampaignStateAdditionalStocks: OMW_AirOpsInitialJP8Stock,OMW_AirOpsInitialFuelSupplement,OMW_AARStrategicStock,OMW_GroundInitialStock'
Write-Host 'GroundInitialStockSchema: OMW-GROUND-INITIAL-STOCK-2'
Write-Host 'GroundNodesSeeded: GROUND_NODE_JALALABAD,GROUND_NODE_FORTRESS,GROUND_NODE_JOYCE,GROUND_NODE_WRIGHT,GROUND_NODE_HONAKER,GROUND_NODE_BOSTICK'
Write-Host 'GroundTransferableResources: GROUND_SUPPLY_PACKAGE,GROUND_AMMO_PACKAGE,GROUND_FUEL_PACKAGE'
Write-Host 'JP8BaselineRelease: v0.3-RELEASE'
Write-Host 'FuelNodeIds: BAGRAM,JALALABAD,KANDAHAR_MAIN,KANDAHAR_HELI,SALERNO,SHINDAND_HELI,TARINKOT'
Write-Host 'FuelReadbackToleranceKg: 0.5'
Write-Host 'ReverseOverwrite: false'
Write-Host 'ProductionScheduler: false'
Write-Host 'AcceptanceHarness: false'
Write-Host 'AirOpsReadyFlag: OMW_WAREHOUSE_READY'
Write-Host 'AirOpsReadyFailClosed: true'
Write-Host 'MizMutation: false'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"

foreach ($entry in $files.GetEnumerator()) {
  $hash = (Get-FileHash -LiteralPath $entry.Value -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Host "$($entry.Key)SHA256: $hash"
}

$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "BundleSHA256: $bundleHash"
