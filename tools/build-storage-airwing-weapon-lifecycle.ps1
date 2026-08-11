[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$harnessFile = Join-Path $repoRoot 'mission\tests\storage-airwing-weapon-lifecycle\src\01-storage-airwing-weapon-lifecycle.lua'
$distDir = Join-Path $repoRoot 'mission\tests\storage-airwing-weapon-lifecycle\dist'
$outputFile = Join-Path $distDir 'OMW_Storage_Airwing_Weapon_Lifecycle_Test.lua'
$builderVersion = 'STORAGE-AIRWING-WEAPON-LIFECYCLE-3'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/storage-weapon-consumption-correlation'
$baseCommit = '503467665e9810398b0c9f20c29019bf958a589b'

if (-not (Test-Path -LiteralPath $harnessFile -PathType Leaf)) {
    throw "Required harness file not found: $harnessFile"
}

$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'STORAGE-AIRWING-WEAPON-LIFECYCLE-3',
    'Bagram',
    'Jalalabad',
    'Kandahar',
    'Kandahar Heliport',
    'FOB Salerno',
    'Tarinkot',
    'Shindand Heliport',
    'STORAGE:FindByName',
    'local aircraft, liquids, weapons = storage:GetInventory()',
    'BASELINE_VALIDATED',
    'FIRST_DEBIT_VALIDATED',
    'storageObservationValid',
    'AUFTRAG:NewCAS',
    'AIRWING_STATE',
    'CountAssetsOnMission',
    'GetAmmoTot',
    'OnAfterLanded',
    'OnAfterArrived',
    'FIRST_POST_RETURN',
    'SECOND_DISPATCH_REQUEST',
    'SECOND_POST_RETURN',
    'MESSAGE:New',
    'HEARTBEAT_INTERVAL_S',
    'TEST COMPLETE - PASS',
    'TEST FAILED',
    'returnToLegionCalledByTest=false'
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
-- Scope: validated read-only STORAGE observation plus native AIRWING/AUFTRAG no-fire recovery and redispatch lifecycle with MOOSE MESSAGE status.

"@

$content = $header + $harness
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: STORAGE_AIRWING_WEAPON_LIFECYCLE_READ_ONLY"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "NodesExpected: 7"
Write-Host "SortiesExpected: 2"
Write-Host "NoFireSortiesExpected: 2"
Write-Host "PollIntervalSeconds: 5"
Write-Host "SafetyTimeoutSeconds: 1800"
Write-Host "HeartbeatIntervalSeconds: 120"
Write-Host "UserVisibleStatus: MOOSE_MESSAGE_REQUIRED"
Write-Host "CompletionMessage: REQUIRED"
Write-Host "FailureMessage: REQUIRED"
Write-Host "GetInventoryContract: THREE_RETURN_VALUES_REQUIRED"
Write-Host "BaselineWeaponInventoryValidation: REQUIRED"
Write-Host "FirstDebitControlValidation: REQUIRED"
Write-Host "LandedCallback: OPTIONAL_TELEMETRY"
Write-Host "ArrivedCallback: REQUIRED_RECOVERY_ANCHOR"
Write-Host "StorageMutation: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "CustomReturnToLegionCall: ABSENT"
Write-Host "NativeOutTextCall: ABSENT"
Write-Host "OPSTRANSPORT: ABSENT"
Write-Host "CTLD: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
