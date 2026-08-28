[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_Kandahar_Bootstrap.lua'
$distDir = Join-Path $repoRoot 'mission\tests\kandahar-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Kandahar.lua'
$lifecycleGuard = Join-Path $repoRoot 'tools\Test-AirOpsLifecycleGuards.ps1'
$builderVersion = 'KAF-AIR-OPS-FOUNDATION-ONLY-1'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Kandahar foundation source not found: $sourceFile"
}
if (-not (Test-Path -LiteralPath $lifecycleGuard -PathType Leaf)) {
    throw "AirOps lifecycle guard not found: $lifecycleGuard"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'AW_US_KAF_451_AEW',
    'AW_US_KAF_159_CAB_TF_THUNDER',
    'SQ_US_KAF_A10C_74_EFS',
    'SQ_US_KAF_HH60G_26_ERQS',
    'SQ_US_KAF_C130_772_EAS',
    'SQ_US_KAF_MQ1_361_ERS',
    'SQ_US_KAF_MQ9_361_ERS',
    'SQ_US_KAF_AH64_4_227_AVN',
    'SQ_US_KAF_OH58D_7_17_CAV',
    'SQ_US_KAF_CH47_7_101_GSAB',
    'SQ_US_KAF_UH60_7_101_GSAB',
    'registeredAirframes = 112',
    'deferredMC12 = 6',
    'deferredRolePayloads = 2',
    'SQUADRON_STOCK_PRESTART',
    'mainAirwing:Start()',
    'heliportAirwing:Start()',
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
    'MISSION_ADDED',
    'FLIGHT_ON_MISSION',
    'TAKEOFF_TIMEOUT',
    'directSpawnRequested=true'
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
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-kandahar-air-operations-foundation.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: Kandahar dual-AIRWING/SQUADRON foundation only; no test dispatch.`n`n"
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
    -FoundationScope

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: AIRWING_SQUADRON_FOUNDATION_ONLY"
Write-Host "Airwings: 2"
Write-Host "Squadrons: 9"
Write-Host "RegisteredAirframes: 112"
Write-Host "DeferredMC12: 6"
Write-Host "RolePayloadsExpected: 8"
Write-Host "DeferredRolePayloads: 2"
Write-Host "LifecycleGuard: PASS"
Write-Host "TestDispatch: ABSENT"
Write-Host "AUFTRAGInstances: ABSENT"
Write-Host "OPSTRANSPORTInstances: ABSENT"
Write-Host "Commander: ABSENT"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
