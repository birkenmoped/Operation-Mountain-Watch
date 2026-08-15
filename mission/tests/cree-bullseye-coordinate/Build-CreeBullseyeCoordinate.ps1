param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$BuilderVersion = '1.0.0'
$TestId = 'OMW_CREE_BULLSEYE_COORDINATE'
$MooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$MooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$sourceFile = Join-Path $PSScriptRoot 'src\cree_bullseye_coordinate.lua'
$distDir = Join-Path $PSScriptRoot 'dist'
$bundleFile = Join-Path $distDir 'cree_bullseye_coordinate.lua'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Source file not found: $sourceFile"
}

$gitCommit = (& git -C $repoRoot rev-parse HEAD).Trim()
if (-not $gitCommit -or $LASTEXITCODE -ne 0) {
    throw 'Unable to resolve current Git commit.'
}

$source = [System.IO.File]::ReadAllText($sourceFile)
foreach ($requiredToken in @('COORDINATE:NewFromLLDD', 'GetVec2()', 'GetLLDDM()', '[OMW][%s][PASS]')) {
    if (-not $source.Contains($requiredToken)) {
        throw "Source guard failed; missing token: $requiredToken"
    }
}

New-Item -ItemType Directory -Force -Path $distDir | Out-Null
$generatedUtc = [DateTime]::UtcNow.ToString('o')
$header = @"
-- Builder: Build-CreeBullseyeCoordinate.ps1
-- BuilderVersion: $BuilderVersion
-- GitCommit: $gitCommit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $TestId
-- Scope: Convert Graveyard CREE WGS84 N35 17.00 E070 16.00 to the native DCS Afghanistan mission Vec2 using MOOSE COORDINATE:NewFromLLDD/GetVec2.
-- Exclusions: Does not mutate the mission bullseye, does not validate DCS avionics behavior, and does not establish historical ISAF bullseye authenticity.
-- MOOSE-Commit: $MooseCommit
-- Moose.lua-SHA-256: $MooseSha256

"@

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($bundleFile, $header + $source, $utf8NoBom)

$bundleHash = (Get-FileHash -LiteralPath $bundleFile -Algorithm SHA256).Hash
$sourceHash = (Get-FileHash -LiteralPath $sourceFile -Algorithm SHA256).Hash

Write-Host "RESULT=PASS"
Write-Host "TEST_ID=$TestId"
Write-Host "BUILDER_VERSION=$BuilderVersion"
Write-Host "GIT_COMMIT=$gitCommit"
Write-Host "SOURCE=$sourceFile"
Write-Host "SOURCE_SHA256=$sourceHash"
Write-Host "BUNDLE=$bundleFile"
Write-Host "BUNDLE_SHA256=$bundleHash"
Write-Host "MOOSE_COMMIT=$MooseCommit"
Write-Host "MOOSE_SHA256=$MooseSha256"
Write-Host "GENERATED_UTC=$generatedUtc"
