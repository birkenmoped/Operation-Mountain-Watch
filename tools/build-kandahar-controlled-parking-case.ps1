[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('OH58D', 'AH64D', 'UH60', 'CH47', 'MQ1', 'MQ9', 'HH60G', 'A10C', 'C130')]
    [string]$Case = 'OH58D'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFiles = @(
    (Join-Path $repoRoot 'mission\tests\kandahar-air-operations\src\05-kandahar-dual-airwing-registration-preflight.lua'),
    (Join-Path $repoRoot 'mission\tests\kandahar-air-operations\src\06-kandahar-dual-airwing-parking-contract-preflight.lua'),
    (Join-Path $repoRoot 'mission\tests\kandahar-air-operations\src\07-kandahar-controlled-parking-case.lua')
)

foreach ($sourceFile in $sourceFiles) {
    if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
        throw "Required source file not found: $sourceFile"
    }
}

$cases = @{
    OH58D = [ordered]@{
        AirwingKey = 'Heliport'
        SquadronName = 'SQ_US_KAF_OH58D_7_17_CAV'
        Template = 'TPL_AIR_US_KAF_OH58D_RECON_2SHIP'
        Type = 'OH58D'
        ExpectedAssetGroups = 1
        ExpectedUnits = 2
        MaxNodeDistance = 12
    }
    AH64D = [ordered]@{
        AirwingKey = 'Heliport'
        SquadronName = 'SQ_US_KAF_AH64_4_227_AVN'
        Template = 'TPL_AIR_US_KAF_AH64D_CAS_2SHIP'
        Type = 'AH-64D_BLK_II'
        ExpectedAssetGroups = 1
        ExpectedUnits = 2
        MaxNodeDistance = 12
    }
    UH60 = [ordered]@{
        AirwingKey = 'Heliport'
        SquadronName = 'SQ_US_KAF_UH60_7_101_GSAB'
        Template = 'TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP'
        Type = 'UH-60A'
        ExpectedAssetGroups = 1
        ExpectedUnits = 1
        MaxNodeDistance = 12
    }
    CH47 = [ordered]@{
        AirwingKey = 'Heliport'
        SquadronName = 'SQ_US_KAF_CH47_7_101_GSAB'
        Template = 'TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP'
        Type = 'CH-47Fbl1'
        ExpectedAssetGroups = 1
        ExpectedUnits = 1
        MaxNodeDistance = 12
    }
    MQ1 = [ordered]@{
        AirwingKey = 'Main'
        SquadronName = 'SQ_US_KAF_MQ1_361_ERS'
        Template = 'TPL_AIR_US_KAF_MQ1A_RECON_1SHIP'
        Type = 'RQ-1A Predator'
        ExpectedAssetGroups = 1
        ExpectedUnits = 1
        MaxNodeDistance = 12
    }
    MQ9 = [ordered]@{
        AirwingKey = 'Main'
        SquadronName = 'SQ_US_KAF_MQ9_361_ERS'
        Template = 'TPL_AIR_US_KAF_MQ9_RECON_1SHIP'
        Type = 'MQ-9 Reaper'
        ExpectedAssetGroups = 1
        ExpectedUnits = 1
        MaxNodeDistance = 12
    }
    HH60G = [ordered]@{
        AirwingKey = 'Main'
        SquadronName = 'SQ_US_KAF_HH60G_26_ERQS'
        Template = 'TPL_AIR_US_KAF_HH60G_CSAR_1SHIP'
        Type = 'UH-60A'
        ExpectedAssetGroups = 1
        ExpectedUnits = 1
        MaxNodeDistance = 12
    }
    A10C = [ordered]@{
        AirwingKey = 'Main'
        SquadronName = 'SQ_US_KAF_A10C_74_EFS'
        Template = 'TPL_AIR_US_KAF_A10C_CAS_2SHIP'
        Type = 'A-10C_2'
        ExpectedAssetGroups = 1
        ExpectedUnits = 2
        MaxNodeDistance = 12
    }
    C130 = [ordered]@{
        AirwingKey = 'Main'
        SquadronName = 'SQ_US_KAF_C130_772_EAS'
        Template = 'TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP'
        Type = 'C-130J-30'
        ExpectedAssetGroups = 1
        ExpectedUnits = 1
        MaxNodeDistance = 12
    }
}

$caseSpec = $cases[$Case]
$caseSpec.Assignment = "KAF-CONTROLLED-PARKING-$Case"

$distDir = Join-Path $repoRoot 'mission\tests\kandahar-air-operations\dist'
$outputFile = Join-Path $distDir ("OMW_AirOps_Kandahar_ControlledParking_{0}.lua" -f $Case)
New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'KAF-CONTROLLED-PARKING-CASE-1'
$sourceMission = 'OMW_Template_v4_Kandahar(4).miz'
$sourceMissionSha256 = '0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c'
$expectedMooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}

function ConvertTo-LuaString([string]$Value) {
    return '"' + $Value.Replace('\', '\\').Replace('"', '\"') + '"'
}

$caseLua = @"
OMW_KAF_CONTROLLED_PARKING_CASE = {
  Key = $(ConvertTo-LuaString $Case),
  AirwingKey = $(ConvertTo-LuaString $caseSpec.AirwingKey),
  SquadronName = $(ConvertTo-LuaString $caseSpec.SquadronName),
  Template = $(ConvertTo-LuaString $caseSpec.Template),
  Type = $(ConvertTo-LuaString $caseSpec.Type),
  ExpectedAssetGroups = $($caseSpec.ExpectedAssetGroups),
  ExpectedUnits = $($caseSpec.ExpectedUnits),
  MaxNodeDistance = $($caseSpec.MaxNodeDistance),
  Assignment = $(ConvertTo-LuaString $caseSpec.Assignment)
}

"@

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-kandahar-controlled-parking-case.ps1
-- BuilderVersion: $builderVersion
-- Case: $Case
-- GitCommit: $commit
-- SourceMission: $sourceMission
-- SourceMissionSha256: $sourceMissionSha256
-- ExpectedMooseSha256: $expectedMooseSha256
-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))

$caseLua
"@

$parts = @($header)
foreach ($sourceFile in $sourceFiles) {
    $parts += "`n-- BEGIN SOURCE: $([System.IO.Path]::GetFileName($sourceFile))`n"
    $parts += (Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8)
    $parts += "`n-- END SOURCE: $([System.IO.Path]::GetFileName($sourceFile))`n"
}
$content = $parts -join ''

$requiredTokens = @(
    'KandaharRegistrationPreflight',
    'KandaharParkingContractPreflight',
    'KandaharControlledParkingCase',
    ':SetParkingIDs(',
    ':SetSafeParkingOn(',
    ':SetParkingSpotBlacklist(',
    ':Start(',
    ':AddRequest(',
    'WAREHOUSE.Descriptor.GROUPNAME',
    'OnAfterSelfRequest',
    'UNIT_PARKED',
    'oneAirwingStarted=true',
    'noAUFTRAG=true',
    'noPayloadMutation=true'
)

foreach ($token in $requiredTokens) {
    if (-not $content.Contains($token)) {
        throw "Controlled parking case is missing required token: $token"
    }
}

$forbiddenTokens = @(
    'SPAWN:New',
    'AUFTRAG:New',
    'OPSTRANSPORT:New',
    'COMMANDER:New',
    'CHIEF:New',
    ':AddMission(',
    ':NewPayload(',
    ':StartUncontrolled(',
    ':SetAllowSpawnOnClientParking(',
    ':Spawn('
)

foreach ($token in $forbiddenTokens) {
    if ($content.Contains($token)) {
        throw "Controlled parking case contains forbidden token: $token"
    }
}

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$luaCompiler = Get-Command 'luac' -ErrorAction SilentlyContinue
if ($luaCompiler) {
    & $luaCompiler.Source -p $outputFile
    if ($LASTEXITCODE -ne 0) {
        throw "Lua syntax validation failed with exit code $LASTEXITCODE"
    }
    $luaSyntax = 'PASS'
} else {
    $luaSyntax = 'SKIPPED (luac not installed)'
}

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "Case: $Case"
Write-Host "AirwingKey: $($caseSpec.AirwingKey)"
Write-Host "Squadron: $($caseSpec.SquadronName)"
Write-Host "Template: $($caseSpec.Template)"
Write-Host "ExpectedAssetGroups: $($caseSpec.ExpectedAssetGroups)"
Write-Host "ExpectedUnits: $($caseSpec.ExpectedUnits)"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "SourceMission: $sourceMission"
Write-Host "SourceMissionSha256: $sourceMissionSha256"
Write-Host "ExpectedMooseSha256: $expectedMooseSha256"
Write-Host "LuaSyntax: $luaSyntax"
Write-Host "PreflightGuard: PASS"
Write-Host "RuntimeBoundary: one AIRWING Start plus one exact GROUPNAME self-request; spawned group remains cold and uncontrolled; no AUFTRAG, transport, payload mutation, taxi command, or client-parking override"
