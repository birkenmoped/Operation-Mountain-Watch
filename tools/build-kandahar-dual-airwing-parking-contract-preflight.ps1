[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFiles = @(
    (Join-Path $repoRoot 'mission\tests\kandahar-air-operations\src\05-kandahar-dual-airwing-registration-preflight.lua'),
    (Join-Path $repoRoot 'mission\tests\kandahar-air-operations\src\06-kandahar-dual-airwing-parking-contract-preflight.lua')
)
$distDir = Join-Path $repoRoot 'mission\tests\kandahar-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Kandahar_DualAirwing_Parking_Contract_Preflight.lua'

foreach ($sourceFile in $sourceFiles) {
    if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
        throw "Required source file not found: $sourceFile"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'KAF-DUAL-AIRWING-PARKING-CONTRACT-PREFLIGHT-1'
$sourceMission = 'OMW_Template_v4_Kandahar(4).miz'
$sourceMissionSha256 = '0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c'
$expectedMooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-kandahar-dual-airwing-parking-contract-preflight.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- SourceMission: $sourceMission
-- SourceMissionSha256: $sourceMissionSha256
-- ExpectedMooseSha256: $expectedMooseSha256
-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))

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
    'AIRWING:New',
    ':SetAirbase(',
    'SQUADRON:New',
    ':SetParkingIDs(',
    ':SetSafeParkingOn(',
    ':SetParkingSpotBlacklist(',
    'CLIENT_RESERVED',
    'STATIC_CLEARANCE_RADIUS',
    'STATIC_AIR_US_KAF_',
    'mainTotal=',
    'heliportTotal=',
    'noStart=true',
    'noSpawn=true'
)

foreach ($token in $requiredTokens) {
    if (-not $content.Contains($token)) {
        throw "Parking contract preflight is missing required token: $token"
    }
}

$forbiddenTokens = @(
    ':Start(',
    ':__Start(',
    'SPAWN:New',
    'AUFTRAG:New',
    'OPSTRANSPORT:New',
    'COMMANDER:New',
    'CHIEF:New',
    ':AddMission(',
    ':NewPayload(',
    ':Spawn(',
    ':SetAllowSpawnOnClientParking('
)

foreach ($token in $forbiddenTokens) {
    if ($content.Contains($token)) {
        throw "Parking contract preflight contains forbidden token: $token"
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
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "SourceMission: $sourceMission"
Write-Host "SourceMissionSha256: $sourceMissionSha256"
Write-Host "ExpectedMooseSha256: $expectedMooseSha256"
Write-Host "LuaSyntax: $luaSyntax"
Write-Host "PreflightGuard: PASS"
Write-Host "RuntimeBoundary: AIRWING/SQUADRON construction plus parking allow/block registration only; no Start, spawn, mission, transport, payload, or client-parking override"
