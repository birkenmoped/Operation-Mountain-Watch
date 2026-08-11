[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$harnessFile = Join-Path $repoRoot 'mission\tests\storage-airwing-weapon-lifecycle\src\01-storage-airwing-weapon-lifecycle.lua'
$distDir = Join-Path $repoRoot 'mission\tests\storage-airwing-weapon-lifecycle\dist'
$outputFile = Join-Path $distDir 'OMW_Storage_Airwing_Weapon_Lifecycle_Test.lua'
$builderVersion = 'STORAGE-AIRWING-WEAPON-LIFECYCLE-5'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/storage-weapon-consumption-correlation'
$baseCommit = '503467665e9810398b0c9f20c29019bf958a589b'

if (-not (Test-Path -LiteralPath $harnessFile -PathType Leaf)) {
    throw "Required harness file not found: $harnessFile"
}

$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'STORAGE-AIRWING-WEAPON-LIFECYCLE-5',
    'Bagram',
    'Jalalabad',
    'Kandahar',
    'Kandahar Heliport',
    'FOB Salerno',
    'Tarinkot',
    'Shindand Heliport',
    'STORAGE:FindByName',
    'local aircraft, liquids, weapons = storage:GetInventory()',
    'AH64_CONTROL_DEBIT_VALIDATED',
    'AH64_LOSS_DESTROY_REQUEST',
    'FlightGroup:Destroy()',
    'CountAssets(true)',
    'AH64_LOSS_RESULT',
    'F16_PRE_DISPATCH_CAPTURED',
    'F16_DROPTANK_DEBIT_RESULT',
    'F16_DROPTANK_RECREDIT_RESULT',
    'ownerConfirmedExternalTanks=4',
    'tankDebitExpectedMatched',
    'NOT_OBSERVED',
    'weapons.droptanks.',
    'AUFTRAG:NewCAS',
    'AssignSquadrons',
    'SetROE',
    'ENUMS.ROE.WeaponHold',
    'GetAmmoTot',
    'OnAfterLanded',
    'OnAfterArrived',
    'MESSAGE:New',
    'HEARTBEAT_INTERVAL_S',
    'TEST COMPLETE - PASS',
    'TEST FAILED',
    'returnToLegionCalledByTest=false',
    'deliberateLossMethod=OPSGROUP_Destroy',
    'directSpawn=false'
)
foreach ($marker in $requiredMarkers) {
    if (-not $harness.Contains($marker)) {
        throw "Harness is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'local\s+inventory\s*=\s*storage:GetInventory\s*\(',
    'inventory\.weapon',
    'inventory\.weapons',
    'trigger\.action\.outText',
    'STORAGE\s*:\s*SetItem',
    'STORAGE\s*:\s*AddItem',
    'STORAGE\s*:\s*RemoveItem',
    'STORAGE\s*:\s*SetLiquid',
    'STORAGE\s*:\s*AddLiquid',
    'STORAGE\s*:\s*RemoveLiquid',
    'SetItem\s*\(',
    'AddItem\s*\(',
    'RemoveItem\s*\(',
    'SetLiquid\s*\(',
    'AddLiquid\s*\(',
    'RemoveLiquid\s*\(',
    'ReturnToLegion\s*\(',
    '_DATABASE',
    'getWarehouse\s*\(',
    'world\.searchObjects',
    'coalition\.addGroup',
    'SPAWN\s*:',
    'OPSTRANSPORT\s*:',
    'CTLD\s*:',
    'CampaignState\s*[\.:]',
    'SaveToFile',
    'LoadFromFile',
    'StartAutoSave',
    'io\.',
    'lfs\.',
    'os\.'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($harness -match $pattern) {
        throw "Weapon lifecycle harness contains forbidden pattern: $pattern"
    }
}

$forbiddenF16TankAssumptions = @(
    'ITEM_F16_TANK',
    'EXPECTED_F16_TANK_KEY',
    'fuel_tank_370gal',
    'F-16-PTB-N2'
)
foreach ($marker in $forbiddenF16TankAssumptions) {
    if ($harness.Contains($marker)) {
        throw "Harness hard-codes an F-16 tank key instead of discovering it from STORAGE deltas: $marker"
    }
}

# Semantic outcomes must be recorded rather than aborting the whole manual DCS run.
if ($harness -match 'tankDebitTotal\s*~=\s*4\s*then\s*error') {
    throw 'F-16 tank debit semantic mismatch must not abort the combined gate.'
}
if ($harness -match 'assetLoss\s*~=\s*"CONFIRMED"\s*then\s*error') {
    throw 'AH-64 asset-loss semantic mismatch must not abort the combined gate.'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-storage-airwing-weapon-lifecycle.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: read-only STORAGE observation across AH-64 normal return, deliberate MOOSE OPSGROUP loss and Bagram F-16C TwoShip external-tank return comparison.

"@

$content = $header + $harness
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: STORAGE_AIRWING_RETURN_LOSS_AND_DROPTANK_LIFECYCLE"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "NodesExpected: 7"
Write-Host "AH64NormalReturnLegsExpected: 1"
Write-Host "AH64DeliberateLossLegsExpected: 1"
Write-Host "AH64LossMethod: MOOSE_OPSGROUP_DESTROY_UNITLOST"
Write-Host "F16ReturnLegsExpected: 1"
Write-Host "F16TwoShipExpected: 2"
Write-Host "F16ExternalTanksExpectedByTemplate: 4"
Write-Host "DynamicF16DroptankKeyDiscovery: REQUIRED"
Write-Host "SemanticMismatchEarlyAbort: DISABLED"
Write-Host "PollIntervalSeconds: 5"
Write-Host "SafetyTimeoutSeconds: 1800"
Write-Host "HeartbeatIntervalSeconds: 120"
Write-Host "UserVisibleStatus: MOOSE_MESSAGE_REQUIRED"
Write-Host "GetInventoryContract: THREE_RETURN_VALUES_REQUIRED"
Write-Host "AH64NormalReturnDebitControl: REQUIRED"
Write-Host "AH64LossAssetCountObservation: REQUIRED"
Write-Host "AH64LossStoreRecoveryClassification: REQUIRED"
Write-Host "F16TankDebitObservation: REQUIRED"
Write-Host "F16TankExpectedDebitComparison: RECORDED_NOT_FATAL"
Write-Host "F16TankRecreditClassification: FULL_NONE_PARTIAL_NOT_OBSERVED"
Write-Host "LandedCallback: OPTIONAL_TELEMETRY"
Write-Host "ArrivedCallback: REQUIRED_FOR_RETURN_LEGS"
Write-Host "StorageMutation: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "CustomReturnToLegionCall: ABSENT"
Write-Host "DirectSpawn: ABSENT"
Write-Host "NativeOutTextCall: ABSENT"
Write-Host "OPSTRANSPORT: ABSENT"
Write-Host "CTLD: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
