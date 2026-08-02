[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\kandahar-air-operations\src'
$distDir = Join-Path $repoRoot 'mission\tests\kandahar-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Kandahar_Diagnostic.lua'

$sourceFiles = @(
    '01-kandahar-diagnostic-bootstrap.lua',
    '02-kandahar-object-contract-audit.lua',
    '03-kandahar-dual-airbase-parking-dump.lua'
)

if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
    throw "Source directory not found: $sourceDir"
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'KAF-DUAL-AIRBASE-NOSPAWN-1'
$sourceMission = 'OMW_Template_v4_Kandahar(1).miz'
$sourceMissionSha256 = '07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a'
$expectedMooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-kandahar-air-operations-diagnostic.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- SourceMission: $sourceMission
-- SourceMissionSha256: $sourceMissionSha256
-- ExpectedMooseSha256: $expectedMooseSha256
-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))

"@

$chunks = New-Object System.Collections.Generic.List[string]
$chunks.Add($header)

foreach ($fileName in $sourceFiles) {
    $path = Join-Path $sourceDir $fileName
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required source file not found: $path"
    }

    $chunks.Add("-- BEGIN SOURCE: $fileName`r`n")
    $chunks.Add((Get-Content -LiteralPath $path -Raw -Encoding UTF8))
    $chunks.Add("`r`n-- END SOURCE: $fileName`r`n`r`n")
}

$content = [string]::Concat($chunks)

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
