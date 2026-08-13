[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsWarehouseBootstrap.lua'
$distDir = Join-Path $repoRoot 'mission\tests\air-ops-warehouse-bootstrap\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Warehouse_Bootstrap.lua'
$builderVersion = 'AIROPS-WAREHOUSE-BOOTSTRAP-1'

$requiredFiles = @(
    'scripts\campaign\OMW_CampaignState.lua',
    'scripts\logistics\OMW_AirOpsResourceManifest.lua',
    'scripts\logistics\OMW_AirOpsInitialStock.lua',
    'scripts\logistics\OMW_AirOpsInitialFuelSupplement.lua',
    'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua',
    'scripts\logistics\OMW_AirOpsStorageInitializer.lua',
    'scripts\logistics\OMW_AirOpsTechnicalAvailability.lua',
    'scripts\logistics\OMW_AirOpsTechnicalAvailabilityInitializer.lua',
    'scripts\logistics\OMW_StorageFuelAdapter.lua',
    'scripts\logistics\OMW_CampaignStateStorageSync.lua',
    'scripts\logistics\OMW_AirOpsWarehouseBootstrap.lua'
)

foreach ($relativePath in $requiredFiles) {
    $path = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required Warehouse foundation source not found: $path"
    }
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8
$requiredMarkers = @(
    'OMW-AIROPS-WAREHOUSE-BOOTSTRAP-1',
    'WarehouseBootstrap.Plan',
    'WarehouseBootstrap.Apply',
    'storageInitializer.Plan',
    'technicalAvailabilityInitializer.Plan',
    'fuelSync:PlanNode',
    'airOpsStartAllowed = true',
    'reverseOverwrite = false',
    'scheduler = false'
)
foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "Warehouse bootstrap source is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'SCHEDULER\s*:',
    'timer\.scheduleFunction',
    'world\.addEventHandler',
    'MissionScripting\.lua',
    'SetResource\s*\(',
    'AddResource\s*\(',
    'RemoveResource\s*\('
)
foreach ($pattern in $forbiddenPatterns) {
    if ($source -match $pattern) {
        throw "Warehouse bootstrap contains forbidden authority/scheduler pattern: $pattern"
    }
}

$manifest = Get-Content -LiteralPath (Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsResourceManifest.lua') -Raw -Encoding UTF8
foreach ($marker in @('FUEL_JP8', 'FUEL_AVGAS', 'STORAGE', 'TECHNICAL_NON_STRATEGIC')) {
    if (-not $manifest.Contains($marker)) {
        throw "Resource manifest is missing required marker: $marker"
    }
}

$fuelSupplement = Get-Content -LiteralPath (Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsInitialFuelSupplement.lua') -Raw -Encoding UTF8
foreach ($marker in @('KANDAHAR_MAIN', 'FUEL_AVGAS', '20270.13583056', '12065.557042', '6032.778521')) {
    if (-not $fuelSupplement.Contains($marker)) {
        throw "AVGAS supplement is missing approved marker: $marker"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-air-ops-warehouse-bootstrap.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: central one-shot AirOps Warehouse resource bootstrap coordinator.`n-- Dependencies: CampaignState + existing STORAGE item/fuel/technical adapters.`n`n"
[System.IO.File]::WriteAllText($outputFile, $header + $source, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: AIROPS_WAREHOUSE_RESOURCE_BOOTSTRAP"
Write-Host "CampaignStateAuthority: REQUIRED"
Write-Host "StrategicItemMirror: PREFLIGHT_THEN_APPLY"
Write-Host "FuelMirror: EXISTING_CLOSED_FUEL_STATE_ONLY"
Write-Host "AVGASSupplement: KANDAHAR_MAIN_APPROVED"
Write-Host "TechnicalAvailability: EXPLICIT_NON_STRATEGIC"
Write-Host "ReverseOverwrite: ABSENT"
Write-Host "Scheduler: ABSENT"
Write-Host "AirOpsStartGate: READY_ONLY"
Write-Host "MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
