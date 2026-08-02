[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\salerno-air-operations\calibration\01-map-me-parking-to-moose-terminal.lua'
$distDir = Join-Path $repoRoot 'mission\tests\salerno-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_Salerno_Parking_Calibration.lua'
$builderVersion = 'SAL-ME-TERMINAL-CALIBRATION-1'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Calibration source file not found: $sourceFile"
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-salerno-parking-calibration.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))

"@

$content = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8
[System.IO.File]::WriteAllText(
    $outputFile,
    $header + $content,
    [System.Text.UTF8Encoding]::new($false)
)

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
