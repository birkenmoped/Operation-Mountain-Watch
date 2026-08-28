[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_Bagram_Bootstrap.lua'
$distDir = Join-Path $repoRoot 'mission\tests\bagram-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Bagram.lua'
$lifecycleGuard = Join-Path $repoRoot 'tools\Test-AirOpsLifecycleGuards.ps1'
$builderVersion = 'BGRAM-AIR-OPS-DUAL-FOUNDATION-6'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Bagram foundation source not found: $sourceFile"
}
if (-not (Test-Path -LiteralPath $lifecycleGuard -PathType Leaf)) {
    throw "AirOps lifecycle guard not found: $lifecycleGuard"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'AW_US_BGRM_455_AEW',
    'AW_US_BGRM_TF_FALCON_10_CAB',
    'WH_AIR_US_BAGRAM',
    'WH_AIR_US_BAGRAM_ARMY',
    'SQ_US_BGRM_F15E_335_EFS',
    'SQ_US_BGRM_F16C_121_EFS',
    'SQ_US_BGRM_MQ1A_62_ERS',
    'SQ_US_BGRM_C130_774_EAS',
    'SQ_US_BGRM_HH60G_83_ERQS',
    'SQ_US_BGRM_UH60_A_1_169',
    'SQ_US_BGRM_CH47_B_7_158',
    'TPL_AIR_US_BGRM_MQ1A_RECON_1SHIP',
    'TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP',
    'TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP',
    'AUFTRAG.Type.RECON',
    'logicalAirframes = 83',
    'representedAirframes = 81',
    'logicalReserve = 2',
    'parkingBlacklist',
    'SetParkingSpotBlacklist',
    'SetParkingIDs',
    'function airwing:OnAfterNewAsset',
    'validateNewAssetParking',
    'lifecycle=WAREHOUSE_NEWASSET',
    'lifecycle=AWAITING_WAREHOUSE_NEWASSET',
    'PARKING_POLICY_PRESTART status=PASS',
    'PARKING_POLICY_POSTSTART status=%s',
    'parkingPolicy=PASS',
    'parkingLabels = "M01-M12"',
    'parkingLabels = "M13-M24"',
    'parkingLabels = "B01-B08"',
    'parkingLabels = "A10,S01-S05"',
    'parkingLabels = "R15-R16"',
    'parkingLabels = "R17-R18"',
    'parkingLabels = "R19-R20"',
    'SQUADRON_STOCK_PRESTART',
    'usafAirwing:Start()',
    'armyAirwing:Start()',
    'missionsCreated=0',
    'transportsCreated=0',
    'commanderCreated=false',
    'f10Controls=false'
)
foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "Foundation source is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'missionCommands',
    'MENU_COALITION',
    'MENU_MISSION',
    'AUFTRAG\s*:\s*New',
    'OPSTRANSPORT\s*:\s*New',
    'COMMANDER\s*:\s*New',
    'AddMission\s*\(',
    'Bagram-to-Jalalabad',
    'directSpawnRequested=true',
    'HH60G_CSAR_LEAD_1SHIP',
    'HH60G_CSAR_COVER_1SHIP',
    'UH60_TRANSPORT_1SHIP'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($source -match $pattern) {
        throw "Foundation-only regression: forbidden test/dispatch pattern found: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-bagram-air-operations-foundation.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: Bagram dual-AIRWING/SQUADRON foundation with validated parking policy; no test dispatch.`n`n"
$content = $header + $source

foreach ($pattern in $forbiddenPatterns) {
    if ($content -match $pattern) {
        throw "Generated foundation-only bundle contains forbidden pattern: $pattern"
    }
}

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

& $lifecycleGuard `
    -SourceFile $sourceFile `
    -GeneratedFile $outputFile `
    -PreStartFunctionName 'constructFoundation' `
    -PostStartFunctionName 'inspectIdleFoundation' `
    -RequirePostStartAssetValidation `
    -FoundationScope

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: AIRWING_SQUADRON_FOUNDATION_WITH_PARKING_POLICY"
Write-Host "Airwings: 2"
Write-Host "Squadrons: 7"
Write-Host "RegisteredGroups: 69"
Write-Host "RepresentedAirframes: 81"
Write-Host "LogicalAirframes: 83"
Write-Host "LogicalReserve: 2"
Write-Host "RolePayloadsExpected: 8"
Write-Host "ParkingBlacklistEntries: 10"
Write-Host "SquadronParkingPools: 7"
Write-Host "LifecycleGuard: PASS"
Write-Host "PostStartAssetValidation: NEWASSET_EVENT"
Write-Host "TestDispatch: ABSENT"
Write-Host "AUFTRAGInstances: ABSENT"
Write-Host "OPSTRANSPORTInstances: ABSENT"
Write-Host "Commander: ABSENT"
Write-Host "ParkingPolicy: ENABLED"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
