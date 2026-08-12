[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\airborne-ammo-parking-correlation\src\01-airborne-ammo-parking-correlation.lua'
$distDir = Join-Path $repoRoot 'mission\tests\airborne-ammo-parking-correlation\dist'
$outputFile = Join-Path $distDir 'OMW_Airborne_Ammo_Parking_Correlation.lua'
$builderVersion = 'AIRBORNE-AMMO-PARKING-CORRELATION-3'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/airborne-ammo-partial-consumption'
$baseCommit = '5efe2bd558aa989528f0454d887b9a8f807c3b4f'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Required source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'AIRBORNE-AMMO-PARKING-CORRELATION-3',
    'KAF_A10C_GAU8',
    'BGRM_F16C_M61',
    'BGRM_F15E_M61',
    'JBAD_UH60_GUNS',
    'JBAD_CH47_GUNS',
    'JBAD_OH58D_M3P',
    'SHND_AH64D_M230',
    'TPL_AIR_US_KAF_A10C_CAS_2SHIP',
    'TPL_AIR_US_BGRM_F16C_CAS_2SHIP',
    'TPL_AIR_US_BGRM_F15E_CAS_2SHIP',
    'TPL_AIR_US_JBAD_UH60_MEDEVAC_1SHIP',
    'TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP',
    'KANDAHAR_',
    'KANDAHAR_HP_',
    'SET_GROUP:New():FilterPrefixes',
    'group:GetTemplate()',
    'airbase:GetParkingSpotsTable()',
    'mooseTerminalID',
    'exactIdMatch',
    'PARKING_MAP',
    'PARKING_CORRELATION_RESULT',
    'AUFTRAG:NewSTRAFING',
    'FlightGroup:SetOptionLandingRestrictPair()',
    'flightGroup:GetAmmoTot()',
    'storage:GetInventory()',
    'realExpenditure=true'
)

foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "Source is missing required marker: $marker"
    }
}

$caseIds = @(
    'KAF_A10C_GAU8',
    'BGRM_F16C_M61',
    'BGRM_F15E_M61',
    'JBAD_UH60_GUNS',
    'JBAD_CH47_GUNS',
    'JBAD_OH58D_M3P',
    'SHND_AH64D_M230'
)
foreach ($caseId in $caseIds) {
    $count = ([regex]::Matches($source, 'id = "' + [regex]::Escape($caseId) + '"')).Count
    if ($count -ne 1) {
        throw "Expected exactly one case id $caseId, found $count"
    }
}

$forbiddenPatterns = @(
    'STORAGE\s*:\s*SetItem',
    'STORAGE\s*:\s*AddItem',
    'STORAGE\s*:\s*RemoveItem',
    'STORAGE\s*:\s*SetLiquid',
    'STORAGE\s*:\s*AddLiquid',
    'STORAGE\s*:\s*RemoveLiquid',
    'CampaignState\s*[\.:]',
    'coalition\.addGroup',
    'world\.searchObjects',
    '_DATABASE',
    'io\.',
    'lfs\.',
    'os\.',
    'ReturnToLegion\s*\(',
    'SetTeleport\s*\(',
    'FlightGroup:Destroy\s*\(',
    'SetDespawnAfterLanding\s*\(',
    'SetDespawnAfterHolding\s*\('
)

foreach ($pattern in $forbiddenPatterns) {
    if ($source -match $pattern) {
        throw "Source contains forbidden pattern: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = [DateTime]::UtcNow.ToString('o')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-airborne-ammo-parking-correlation.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: real DCS onboard gun expenditure and native AIRWING return correlation for seven cases plus read-only Kandahar ME parking/MOOSE TerminalID correlation.
-- Exclusions: no STORAGE mutation; no CampaignState mutation; no native DCS spawning; no custom return/despawn/parking controller.

"@

$content = $header + $source
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: AIRBORNE_AMMO_AND_KANDAHAR_PARKING_CORRELATION"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "CasesExpected: 7"
Write-Host "Cases: A10C_GAU8,F16C_M61,F15E_M61,UH60_GUNS,CH47_GUNS,OH58D_M3P,AH64D_M230"
Write-Host "A10Role: GATE"
Write-Host "F16F15UH60CH47Role: DISCOVERY"
Write-Host "OH58AH64Role: REGRESSION"
Write-Host "ParkingNodes: Kandahar,Kandahar Heliport"
Write-Host "ParkingPrefixes: KANDAHAR_,KANDAHAR_HP_"
Write-Host "ParkingCorrelation: ME_PARKING_ID_TO_MIZ_PARKING_TO_MOOSE_TERMINAL_ID"
Write-Host "ParkingMatchToleranceMeters: 5"
Write-Host "TargetTemplate: TPL_TEST_RED_VEHICLE_02_01"
Write-Host "TargetPlacement: MOOSE_ROAD_FLAT_SEARCH"
Write-Host "MissionType: STRAFING"
Write-Host "WeaponType: GUNPOD_PLUS_BUILTIN_CANNON"
Write-Host "WeaponExpend: QUARTER"
Write-Host "LandingPairPolicy: RESTRICT_PAIR_PER_ASSIGNED_FLIGHTGROUP"
Write-Host "StorageWeaponObservation: REQUIRED"
Write-Host "JetFuelObservation: SECONDARY"
Write-Host "RealExpenditure: REQUIRED"
Write-Host "StorageMutation: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "DirectNativeSpawn: ABSENT"
Write-Host "CustomReturnToLegionCall: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
