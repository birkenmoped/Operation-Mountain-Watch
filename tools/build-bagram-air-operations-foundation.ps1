[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_Bagram.lua'
$parkingCsv = Join-Path $repoRoot 'docs\data\bagram-parking-policy.csv'
$distDir = Join-Path $repoRoot 'mission\tests\bagram-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Bagram.lua'
$lifecycleGuard = Join-Path $repoRoot 'tools\Test-AirOpsLifecycleGuards.ps1'
$builderVersion = 'BGRAM-AIR-OPS-BASE-1'

foreach ($requiredFile in @($sourceFile, $parkingCsv, $lifecycleGuard)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required Bagram AirOps build input not found: $requiredFile"
    }
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8
$rows = @(Import-Csv -LiteralPath $parkingCsv)
if ($rows.Count -ne 187) {
    throw "Bagram parking policy must contain exactly 187 rows, found $($rows.Count)"
}

$allowedStatuses = @('AI', 'Static', 'Client', 'BLOCKED')
foreach ($row in $rows) {
    if ($allowedStatuses -notcontains $row.Status) {
        throw "Unsupported Bagram parking status '$($row.Status)' at $($row.Stellplatzkennung)"
    }
}

$terminalIds = @($rows | ForEach-Object { [int]$_.'MOOSE TerminalID' })
if (($terminalIds | Sort-Object -Unique).Count -ne 187) {
    throw 'Bagram parking policy TerminalIDs are not unique'
}

$aiRows = @($rows | Where-Object { $_.Status -eq 'AI' })
$excludedRows = @($rows | Where-Object { $_.Status -ne 'AI' })
if ($aiRows.Count -ne 69 -or $excludedRows.Count -ne 118) {
    throw "Bagram parking partition mismatch: AI=$($aiRows.Count) excluded=$($excludedRows.Count), expected 69/118"
}

$profileMap = [ordered]@{
    F15E = 'F-15E'
    F16C = 'F-16'
    MQ1A = 'MQ-1A'
    C130 = 'C-130J-30'
    UH60 = 'UH-60'
    CH47 = 'CH-47F'
}

foreach ($entry in $profileMap.GetEnumerator()) {
    $profileRows = @($aiRows | Where-Object { $_.Asset -eq $entry.Value })
    if ($profileRows.Count -eq 0) {
        throw "No AI parking rows found for CSV asset $($entry.Value)"
    }

    $expectedLabels = ($profileRows | ForEach-Object { $_.Stellplatzkennung }) -join ', '
    $expectedIds = ($profileRows | ForEach-Object { [int]$_.'MOOSE TerminalID' }) -join ', '

    if (-not $source.Contains("csvAsset = `"$($entry.Value)`"")) {
        throw "Source missing CSV asset profile $($entry.Value)"
    }
    if (-not $source.Contains("parkingLabels = `"$expectedLabels`"")) {
        throw "Source parking labels drift from CSV for $($entry.Value)"
    }
    if (-not $source.Contains("parkingIDs = { $expectedIds }")) {
        throw "Source parking IDs drift from CSV for $($entry.Value)"
    }
}

$expectedBlacklist = ($excludedRows | ForEach-Object { [int]$_.'MOOSE TerminalID' }) -join ', '
if (-not $source.Contains("parkingBlacklist = { $expectedBlacklist }")) {
    throw 'Source parking blacklist drifts from CSV Static/Client/BLOCKED rows'
}

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
    'logicalAirframes = 83',
    'representedAirframes = 81',
    'logicalReserve = 2',
    'PARKING_POLICY_SOURCE = "docs/data/bagram-parking-policy.csv"',
    'SetParkingSpotBlacklist',
    'SetParkingIDs',
    'function airwing:OnAfterNewAsset',
    'validateNewAssetParking',
    'lifecycle=WAREHOUSE_NEWASSET',
    'lifecycle=AWAITING_WAREHOUSE_NEWASSET',
    'AIRWING_SQUADRON_BASE_WITH_OWNER_PARKING_POLICY',
    'usafAirwing:Start()',
    'armyAirwing:Start()'
)
foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "Bagram AirOps base source is missing required marker: $marker"
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
    'ALERT5_TEST_PREP',
    'BAGRAM_PARKING_FINAL_RESULT',
    'TIMEOUT_120S',
    'directSpawnRequested=true'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($source -match $pattern) {
        throw "Production Bagram AirOps base contains forbidden test/dispatch pattern: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-bagram-air-operations-foundation.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- ParkingPolicy: docs/data/bagram-parking-policy.csv`n-- Scope: production Bagram AIRWING/SQUADRON base; no test dispatch.`n`n"
$content = $header + $source

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

& $lifecycleGuard `
    -SourceFile $sourceFile `
    -GeneratedFile $outputFile `
    -PreStartFunctionName 'constructFoundation' `
    -PostStartFunctionName 'inspectIdleFoundation' `
    -RequirePostStartAssetValidation `
    -FoundationScope

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
$csvHash = (Get-FileHash -LiteralPath $parkingCsv -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: AIRWING_SQUADRON_BASE_WITH_OWNER_PARKING_POLICY"
Write-Host "Airwings: 2"
Write-Host "Squadrons: 7"
Write-Host "RegisteredGroups: 69"
Write-Host "RepresentedAirframes: 81"
Write-Host "LogicalAirframes: 83"
Write-Host "LogicalReserve: 2"
Write-Host "RolePayloadsExpected: 8"
Write-Host "ParkingCsvRows: 187"
Write-Host "ParkingAiRows: 69"
Write-Host "ParkingExcludedRows: 118"
Write-Host "ParkingAssetProfiles: 6"
Write-Host "ParkingPolicyCsvCheck: PASS"
Write-Host "LifecycleGuard: PASS"
Write-Host "PostStartAssetValidation: NEWASSET_EVENT"
Write-Host "TestDispatch: ABSENT"
Write-Host "AUFTRAGInstances: ABSENT"
Write-Host "OPSTRANSPORTInstances: ABSENT"
Write-Host "Commander: ABSENT"
Write-Host "BundleSHA256: $hash"
Write-Host "ParkingCsvSHA256: $csvHash"
Write-Host "GitCommit: $commit"
