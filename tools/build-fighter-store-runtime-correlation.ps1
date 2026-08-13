[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\fighter-store-runtime-correlation\src\01-fighter-store-runtime-correlation.lua'
$distDir = Join-Path $repoRoot 'mission\tests\fighter-store-runtime-correlation\dist'
$outputFile = Join-Path $distDir 'OMW_Fighter_Store_Runtime_Correlation.lua'
$builderVersion = 'FIGHTER-STORE-RUNTIME-CORRELATION-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/warehouse-resource-final-acceptance'
$baseCommit = '1c74146641bc8ca21e0f39240754391cf7ce28b7'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Required source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'FIGHTER-STORE-RUNTIME-CORRELATION-1',
    'TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP',
    'weapons.bombs.GBU_31',
    'weapons.bombs.GBU_31_V_3B',
    'F15_STRIKE_MAPPING_PASS',
    'F16_PHASE_READY',
    'F16_AIM9_MAPPING_PASS',
    'Add exactly one AIM-9M on station 2 and one AIM-9M on station 8',
    'airwing:NewPayload',
    'AUFTRAG:NewORBIT',
    'mission:AddRequiredPayload',
    'airwing:AddMission',
    'runtime.storage:GetInventory()',
    'SET_CLIENT:New()',
    'client:GetAmmo()',
    'EVENTS.WeaponRearm',
    'storageMutation=false',
    'campaignStateMutation=false',
    'nativeDcs=false'
)

foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "Source is missing required marker: $marker"
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
    'ReturnToLegion\s*\(',
    'Destroy\s*\(',
    'io\.',
    'lfs\.',
    'os\.'
)

foreach ($pattern in $forbiddenPatterns) {
    if ($source -match $pattern) {
        throw "Source contains forbidden pattern: $pattern"
    }
}

if (([regex]::Matches($source, [regex]::Escape('F15_GBU31_V1_CANDIDATE = "weapons.bombs.GBU_31"'))).Count -ne 1) {
    throw 'Expected exactly one F-15E GBU-31(V)1 candidate mapping declaration.'
}
if (([regex]::Matches($source, [regex]::Escape('F15_GBU31_V3_CANDIDATE = "weapons.bombs.GBU_31_V_3B"'))).Count -ne 1) {
    throw 'Expected exactly one F-15E GBU-31(V)3 candidate mapping declaration.'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = [DateTime]::UtcNow.ToString('o')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-fighter-store-runtime-correlation.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: Bagram F-15E STRIKE GBU-31(V)1/V3 STORAGE debit correlation plus F-16 client AIM-9M STORAGE item correlation.
-- Exclusions: no STORAGE mutation; no CampaignState mutation; no native DCS spawn; no custom AIRWING return/rearm implementation.

"@

$content = $header + $source
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: F15E_STRIKE_GBU31_AND_F16_DEPLOYMENT_AIM9_ITEM_CORRELATION"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "F15Template: TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP"
Write-Host "F15Mission: MOOSE_AIRWING_ORBIT_NO_FIRE"
Write-Host "F15ExpectedGBU31V1Debit: 2"
Write-Host "F15ExpectedGBU31V3Debit: 2"
Write-Host "F16Action: CLIENT_NORMAL_GROUND_CREW_REARM"
Write-Host "F16RequiredChange: ADD_AIM9M_STATION_2_AND_8_ONLY"
Write-Host "F16ExpectedAIM9Debit: 2"
Write-Host "StorageMutation: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "DirectNativeSpawn: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
