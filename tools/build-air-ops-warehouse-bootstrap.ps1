[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$campaignStateFile = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
$manifestFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsResourceManifest.lua'
$initialStockFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsInitialStock.lua'
$fuelSupplementFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsInitialFuelSupplement.lua'
$campaignInitializerFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
$storageInitializerFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsStorageInitializer.lua'
$technicalAvailabilityFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsTechnicalAvailability.lua'
$technicalInitializerFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsTechnicalAvailabilityInitializer.lua'
$fuelAdapterFile = Join-Path $repoRoot 'scripts\logistics\OMW_StorageFuelAdapter.lua'
$fuelSyncFile = Join-Path $repoRoot 'scripts\logistics\OMW_CampaignStateStorageSync.lua'
$bootstrapFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsWarehouseBootstrap.lua'
$harnessFile = Join-Path $repoRoot 'mission\tests\air-ops-warehouse-bootstrap\src\01-air-ops-warehouse-bootstrap-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\air-ops-warehouse-bootstrap\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Warehouse_Bootstrap.lua'

$builderVersion = 'AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE-1'
$testId = 'AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = @(
  $campaignStateFile,
  $manifestFile,
  $initialStockFile,
  $fuelSupplementFile,
  $campaignInitializerFile,
  $storageInitializerFile,
  $technicalAvailabilityFile,
  $technicalInitializerFile,
  $fuelAdapterFile,
  $fuelSyncFile,
  $bootstrapFile,
  $harnessFile
)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Warehouse acceptance source not found: $file"
  }
}

$campaignState = Get-Content -LiteralPath $campaignStateFile -Raw -Encoding UTF8
$manifest = Get-Content -LiteralPath $manifestFile -Raw -Encoding UTF8
$initialStock = Get-Content -LiteralPath $initialStockFile -Raw -Encoding UTF8
$fuelSupplement = Get-Content -LiteralPath $fuelSupplementFile -Raw -Encoding UTF8
$campaignInitializer = Get-Content -LiteralPath $campaignInitializerFile -Raw -Encoding UTF8
$storageInitializer = Get-Content -LiteralPath $storageInitializerFile -Raw -Encoding UTF8
$technicalAvailability = Get-Content -LiteralPath $technicalAvailabilityFile -Raw -Encoding UTF8
$technicalInitializer = Get-Content -LiteralPath $technicalInitializerFile -Raw -Encoding UTF8
$fuelAdapter = Get-Content -LiteralPath $fuelAdapterFile -Raw -Encoding UTF8
$fuelSync = Get-Content -LiteralPath $fuelSyncFile -Raw -Encoding UTF8
$bootstrap = Get-Content -LiteralPath $bootstrapFile -Raw -Encoding UTF8
$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$combined = $campaignState + "`n" + $manifest + "`n" + $initialStock + "`n" + $fuelSupplement + "`n" + $campaignInitializer + "`n" + $storageInitializer + "`n" + $technicalAvailability + "`n" + $technicalInitializer + "`n" + $fuelAdapter + "`n" + $fuelSync + "`n" + $bootstrap + "`n" + $harness

$requiredMarkers = @(
  'function CampaignState.New(initialState)',
  'function CampaignState.Restore(snapshot)',
  'function Store:ExportSnapshot()',
  'OMW-AIROPS-INITIAL-STOCK-1',
  'OMW-AIROPS-INITIAL-FUEL-SUPPLEMENT-1',
  '20270.13583056',
  '12065.557042',
  '6032.778521',
  'OMW-AIROPS-CAMPAIGNSTATE-INITIALIZER-2',
  'OMW-AIROPS-STORAGE-INITIALIZER-2',
  'OMW-AIROPS-TECHNICAL-AVAILABILITY-DATA-1',
  'OMW-AIROPS-TECHNICAL-AVAILABILITY-1',
  'FUEL_JP8',
  'FUEL_AVGAS',
  'STORAGE.Liquid.JETFUEL',
  'STORAGE.Liquid.GASOLINE',
  'OMW-AIROPS-WAREHOUSE-BOOTSTRAP-1',
  'AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE-1',
  'NEW_PREFLIGHT_PASS',
  'NEW_APPLY_PASS',
  'RESTORE_PASS',
  'RESULT status=PASS'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Warehouse acceptance source is missing required marker: $marker"
  }
}

$bootstrapForbiddenPatterns = @(
  'SCHEDULER\s*:',
  'timer\.scheduleFunction',
  'world\.addEventHandler',
  'MissionScripting\.lua',
  'io\.',
  'lfs\.',
  'os\.execute'
)
foreach ($pattern in $bootstrapForbiddenPatterns) {
  if ($bootstrap -match $pattern) {
    throw "Productive Warehouse bootstrap contains forbidden pattern: $pattern"
  }
}

if ($bootstrap -match 'CampaignState\s*[:.]\s*New' -or $bootstrap -match 'CampaignState\s*[:.]\s*Restore') {
  throw 'Productive Warehouse bootstrap must not own CampaignState NEW/RESTORE lifecycle'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-air-ops-warehouse-bootstrap.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: central one-shot AirOps Warehouse initial-stock bootstrap, NEW/RESTORE and STORAGE readback acceptance.
-- Exclusions: no stock recalculation; no reverse STORAGE authority; no persistence transport; no AIRWING mission dispatch.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$content = $header
$content += "local OMWCampaignState = (function()`n$campaignState`nend)()`n`n"
$content += "local OMWAirOpsResourceManifest = (function()`n$manifest`nend)()`n`n"
$content += "local OMWAirOpsInitialStock = (function()`n$initialStock`nend)()`n`n"
$content += "local OMWAirOpsInitialFuelSupplement = (function()`n$fuelSupplement`nend)()`n`n"
$content += "local OMWAirOpsCampaignStateInitializer = (function()`n$campaignInitializer`nend)()`n`n"
$content += "local OMWAirOpsStorageInitializer = (function()`n$storageInitializer`nend)()`n`n"
$content += "local OMWAirOpsTechnicalAvailability = (function()`n$technicalAvailability`nend)()`n`n"
$content += "local OMWAirOpsTechnicalAvailabilityInitializer = (function()`n$technicalInitializer`nend)()`n`n"
$content += "local OMWStorageFuelAdapter = (function()`n$fuelAdapter`nend)()`n`n"
$content += "local OMWCampaignStateStorageSync = (function()`n$fuelSync`nend)()`n`n"
$content += "local OMWAirOpsWarehouseBootstrap = (function()`n$bootstrap`nend)()`n`n"
$content += $harness

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "Scope: AIROPS_WAREHOUSE_BOOTSTRAP_ACCEPTANCE"
Write-Host "CampaignStateAuthority: REQUIRED"
Write-Host "InitialStockModule: PRESENT"
Write-Host "AVGASSupplement: PRESENT"
Write-Host "JP8ClosedBaseline: PRESERVE_EXISTING_TEST_FIXTURE_ONLY"
Write-Host "StrategicItemMirror: PREFLIGHT_APPLY_READBACK"
Write-Host "FuelMirror: PREFLIGHT_APPLY_READBACK"
Write-Host "TechnicalAvailability: PREFLIGHT_APPLY_READBACK"
Write-Host "NewRestore: REQUIRED"
Write-Host "ReverseOverwrite: ABSENT"
Write-Host "ProductiveScheduler: ABSENT"
Write-Host "AirOpsStartGate: READY_ONLY"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
