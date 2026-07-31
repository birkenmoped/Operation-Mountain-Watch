[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\kandahar-air-operations\src\04-kandahar-heliport-warehouse-audit.lua'
$distDir = Join-Path $repoRoot 'mission\tests\kandahar-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Kandahar_HeliWarehouse_Diagnostic.lua'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Required source file not found: $sourceFile"
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'KAF-HELIPORT-WAREHOUSE-NOSPAWN-1'
$sourceMission = 'OMW_Template_v4_Kandahar(3).miz'
$sourceMissionSha256 = '15e63ef55f260ba35fb07bb4c99cc23df7193b595fbdd5be13bc4b8a9b0af0cc'
$expectedMooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-kandahar-heliport-warehouse-diagnostic.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- SourceMission: $sourceMission
-- SourceMissionSha256: $sourceMissionSha256
-- ExpectedMooseSha256: $expectedMooseSha256
-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))

"@

$content = $header + (Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8)

$forbiddenTokens = @(
    'AIRWING:New',
    'SQUADRON:New',
    'SPAWN:New',
    'AUFTRAG:New',
    'OPSTRANSPORT:New',
    'SetParkingSpotBlacklist'
)

foreach ($token in $forbiddenTokens) {
    if ($content.Contains($token)) {
        throw "No-spawn diagnostic contains forbidden token: $token"
    }
}

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "SourceMission: $sourceMission"
Write-Host "SourceMissionSha256: $sourceMissionSha256"
Write-Host "ExpectedMooseSha256: $expectedMooseSha256"
Write-Host "NoSpawnGuard: PASS"
