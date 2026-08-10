[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$harnessFile = Join-Path $repoRoot 'mission\tests\storage-weapon-item-matrix\src\01-storage-weapon-item-matrix.lua'
$distDir = Join-Path $repoRoot 'mission\tests\storage-weapon-item-matrix\dist'
$outputFile = Join-Path $distDir 'OMW_Storage_Weapon_Item_Matrix_Test.lua'
$builderVersion = 'STORAGE-WEAPON-ITEM-MATRIX-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/campaignstate-resource-transaction-contract'
$baseCommit = 'a1f2c5997f07e164dddc839665cb83c321bfd4ae'

if (-not (Test-Path -LiteralPath $harnessFile -PathType Leaf)) {
    throw "Required harness file not found: $harnessFile"
}

$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'STORAGE-WEAPON-ITEM-MATRIX-1',
    'Bagram',
    'Jalalabad',
    'Kandahar',
    'Kandahar Heliport',
    'FOB Salerno',
    'Tarinkot',
    'Shindand Heliport',
    'STORAGE:FindByName',
    'GetInventory',
    'GetItemAmount',
    'ENUM_CANDIDATES_PASS',
    'NODE_RESOLVE_PASS',
    'STORAGE_IDENTITY_PASS',
    'INVENTORY_READ_PASS',
    'CANDIDATE_READ_PASS',
    'NODE_PASS',
    'nodesExpected=%d'
)
foreach ($marker in $requiredMarkers) {
    if (-not $harness.Contains($marker)) {
        throw "Harness is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'STORAGE\s*:\s*SetItem',
    'STORAGE\s*:\s*AddItem',
    'STORAGE\s*:\s*RemoveItem',
    'STORAGE\s*:\s*IsUnlimited',
    'STORAGE\s*:\s*IsUnlimitedWeapons',
    'SetItem\s*\(',
    'AddItem\s*\(',
    'RemoveItem\s*\(',
    'IsUnlimited\s*\(',
    '_DATABASE',
    'getWarehouse\s*\(',
    'world\.searchObjects',
    'OPSTRANSPORT\s*:',
    'CTLD\s*:',
    'AIRWING\s*:',
    'SCHEDULER\s*:',
    'timer\.scheduleFunction',
    'SaveToFile',
    'LoadFromFile',
    'StartAutoSave',
    'io\.',
    'lfs\.',
    'os\.'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($harness -match $pattern) {
        throw "Read-only weapon item matrix harness contains forbidden pattern: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-storage-weapon-item-matrix.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: read-only seven-node MOOSE STORAGE weapon/item inventory and candidate mapping diagnostic.

"@

$content = $header + $harness
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: STORAGE_WEAPON_ITEM_MATRIX_READ_ONLY"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "NodesExpected: 7"
Write-Host "Airbases: Bagram;Jalalabad;Kandahar;Kandahar Heliport;FOB Salerno;Tarinkot;Shindand Heliport"
Write-Host "Mutation: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "OPSTRANSPORT: ABSENT"
Write-Host "CTLD: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
