[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\airborne-ammo-partial-consumption\src\01-airborne-ammo-partial-consumption.lua'
$distDir = Join-Path $repoRoot 'mission\tests\airborne-ammo-partial-consumption\dist'
$outputFile = Join-Path $distDir 'OMW_Airborne_Ammo_Partial_Consumption.lua'
$builderVersion = 'AIRBORNE-AMMO-PARTIAL-CONSUMPTION-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/airops-storage-fuel-template-census'
$baseCommit = 'baa92e90ef41ca3a2ec1f99ed278c8a834473c20'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Required source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'AIRBORNE-AMMO-PARTIAL-CONSUMPTION-1',
    'TPL_TEST_RED_VEHICLE_02_01',
    'TARGET_DISTANCE_M = 10000',
    'SPAWN:NewWithAlias',
    'SpawnFromCoordinate',
    'AUFTRAG:NewSTRAFING',
    'ENUMS.WeaponFlag.GunPod + ENUMS.WeaponFlag.BuiltInCannon',
    'AI.Task.WeaponExpend.QUARTER',
    'SetEngageQuantity(2)',
    'FlightGroup:AddMission(strafe)',
    'flightGroup:GetAmmoTot()',
    'local aircraft, liquids, weapons = storage:GetInventory()',
    'STORAGE.Liquid.JETFUEL',
    'TPL_AIR_US_KAF_A10C_CAS_2SHIP',
    'TPL_AIR_US_JBAD_OH58D_RECON_2SHIP',
    'TPL_AIR_US_SHND_AH64D_CAS_2SHIP',
    'NO_GUN_CONSUMPTION',
    'realExpenditure=true'
)

foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "Source is missing required marker: $marker"
    }
}

$caseCount = ([regex]::Matches($source, 'id = "(KAF_A10C_GAU8|JBAD_OH58D_M3P|SHND_AH64D_M230)"')).Count
if ($caseCount -ne 3) {
    throw "Expected exactly 3 targeted cannon cases, found $caseCount"
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
    'trigger\.action\.outText',
    'OPSTRANSPORT\s*:',
    'CTLD\s*:',
    '_DATABASE',
    'world\.searchObjects',
    'io\.',
    'lfs\.',
    'os\.',
    'ReturnToLegion\s*\(',
    'SetTeleport\s*\(',
    'FlightGroup:Destroy\s*\('
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
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-airborne-ammo-partial-consumption.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: real DCS cannon expenditure against test-local RED target clones; read-only onboard ammo/STORAGE/fuel observation.

"@

$content = $header + $source
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: AIRBORNE_AMMO_PARTIAL_CONSUMPTION"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "CasesExpected: 3"
Write-Host "Cases: A10C_GAU8,OH58D_M3P,AH64D_M230"
Write-Host "TargetTemplate: TPL_TEST_RED_VEHICLE_02_01"
Write-Host "TargetDistanceMeters: 10000"
Write-Host "TargetSpawn: MOOSE_SPAWN_FROM_COORDINATE"
Write-Host "MissionType: STRAFING"
Write-Host "WeaponType: GUNPOD_PLUS_BUILTIN_CANNON"
Write-Host "WeaponExpend: QUARTER"
Write-Host "EngageQuantity: 2"
Write-Host "OnboardAmmoObservation: ASSIGNED_AND_LANDED_OR_ARRIVED"
Write-Host "StorageWeaponObservation: REQUIRED"
Write-Host "JetFuelObservation: SECONDARY"
Write-Host "RealExpenditure: REQUIRED"
Write-Host "StorageMutation: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "DirectNativeSpawn: ABSENT"
Write-Host "CustomReturnToLegionCall: ABSENT"
Write-Host "AssignmentTimeoutSeconds: 600"
Write-Host "LifecycleTimeoutSeconds: 3600"
Write-Host "GlobalTimeoutSeconds: 7200"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
