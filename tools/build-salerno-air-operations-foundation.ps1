[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_Salerno_Bootstrap.lua'
$distDir = Join-Path $repoRoot 'mission\tests\salerno-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Salerno.lua'
$builderVersion = 'SAL-AIR-OPS-FOUNDATION-ONLY-1'

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'AW_US_SALERNO',
    'SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK',
    'SQ_US_SAL_OH58D_B_6_6_CAV',
    'SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT',
    'SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN',
    'SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT',
    'parkingState = "DEFERRED"',
    'airwing:Start()',
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
    'SAL-COMMANDER',
    'MISSION_ADDED',
    'FLIGHT_ON_MISSION',
    'TAKEOFF_TIMEOUT'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($source -match $pattern) {
        throw "Foundation-only regression: forbidden test/dispatch pattern found: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-salerno-air-operations-foundation.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: AIRWING/SQUADRON foundation only; Salerno parking remains deferred; no test dispatch.`n-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))`n`n"
$content = $header + $source
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: AIRWING_SQUADRON_FOUNDATION_ONLY"
Write-Host "ParkingState: DEFERRED"
Write-Host "TestDispatch: ABSENT"
Write-Host "AUFTRAGInstances: ABSENT"
Write-Host "OPSTRANSPORTInstances: ABSENT"
Write-Host "Commander: ABSENT"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
