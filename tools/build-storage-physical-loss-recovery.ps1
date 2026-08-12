[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$harnessFile = Join-Path $repoRoot 'mission\tests\storage-physical-loss-recovery\src\01-storage-physical-loss-recovery.lua'
$distDir = Join-Path $repoRoot 'mission\tests\storage-physical-loss-recovery\dist'
$outputFile = Join-Path $distDir 'OMW_Storage_Physical_Loss_Recovery_Test.lua'
$builderVersion = 'STORAGE-PHYSICAL-LOSS-RECOVERY-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/airborne-ammo-parking-correlation'
$baseCommit = '8724c670f2898f5ed14aee676afb365e126ca7a8'

if (-not (Test-Path -LiteralPath $harnessFile -PathType Leaf)) {
    throw "Required harness file not found: $harnessFile"
}

$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'STORAGE-PHYSICAL-LOSS-RECOVERY-1',
    'UNIT:Explode',
    'unit:Explode(EXPLOSION_POWER_KG_TNT)',
    'group:GetUnits()',
    'runtime.flightGroup:GetGroup()',
    'STORAGE:FindByName',
    'local aircraft, liquids, weapons = storage:GetInventory()',
    'weapons.nurs.HYDRA_70_M151',
    'weapons.missiles.AGM_114K',
    'weapons.droptanks.{IAFS_ComboPak_100}',
    'SPAWN_DEBIT',
    'KNOWN_STORE_RECOVERY',
    'RECOVERY_ITEM family=%s',
    'physicalLossMethod=MOOSE_UNIT_EXPLODE',
    'storageMutation=false',
    'campaignStateMutation=false',
    'EXPLOSION_POWER_KG_TNT = 1500',
    'ENUMS.ROE.WeaponHold',
    'AssignSquadrons',
    'SetRequiredAssets',
    'CountAssets(true)',
    'MESSAGE:New',
    'SAFETY_TIMEOUT_S = 600'
)
foreach ($marker in $requiredMarkers) {
    if (-not $harness.Contains($marker)) {
        throw "Harness is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'OPSGROUP\s*:\s*Destroy',
    'FlightGroup\s*:\s*Destroy',
    'unit\s*:\s*destroy\s*\(',
    'trigger\.action\.explosion',
    'coalition\.addGroup',
    'SPAWN\s*:',
    '_DATABASE',
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
    'CampaignState\s*[\.:]',
    'io\.',
    'lfs\.',
    'os\.'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($harness -match $pattern) {
        throw "Physical-loss harness contains forbidden pattern: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-storage-physical-loss-recovery.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: read-only STORAGE correlation around real DCS explosions generated through public MOOSE UNIT:Explode().

"@

$content = $header + $harness
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: STORAGE_PHYSICAL_AIRCRAFT_LOSS_RECOVERY"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "AircraftType: AH-64D"
Write-Host "Node: Shindand Heliport"
Write-Host "ExpectedM151Debit: 76"
Write-Host "ExpectedAGM114KDebit: 4"
Write-Host "ExpectedIAFSComboPakDebit: 2"
Write-Host "PhysicalLossMethod: MOOSE_UNIT_EXPLODE"
Write-Host "ExplosionPowerKgTNT: 1500"
Write-Host "PostExplosionObservationSeconds: 30"
Write-Host "SafetyTimeoutSeconds: 600"
Write-Host "StorageMutation: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "CustomReturnToLegionCall: ABSENT"
Write-Host "OPSGROUPDestroy: ABSENT"
Write-Host "NativeExplosionCall: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
