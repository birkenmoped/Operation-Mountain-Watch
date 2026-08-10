[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$commanderSource = Join-Path $repoRoot 'scripts\command\OMW_Blue_Commander.lua'
$guard = Join-Path $repoRoot 'tools\Test-BlueCommanderFoundation.ps1'
$distDir = Join-Path $repoRoot 'mission\tests\blue-commander-foundation\dist'
$outputFile = Join-Path $distDir 'OMW_Blue_Commander_Foundation.lua'
$builderVersion = 'BLUE-COMMANDER-FOUNDATION-1'

$airOpsSources = @(
    'scripts\air-operations\OMW_AirOps_Bagram_Bootstrap.lua',
    'scripts\air-operations\OMW_AirOps_Jalalabad_Bootstrap.lua',
    'scripts\air-operations\OMW_AirOps_Kandahar_Bootstrap.lua',
    'scripts\air-operations\OMW_AirOps_Salerno_Bootstrap.lua',
    'scripts\air-operations\OMW_AirOps_Shindand_Bootstrap.lua',
    'scripts\air-operations\OMW_AirOps_Tarinkot_Bootstrap.lua'
)

foreach ($relative in $airOpsSources) {
    $path = Join-Path $repoRoot $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required AIRWING foundation source not found: $path" }
}
if (-not (Test-Path -LiteralPath $commanderSource -PathType Leaf)) { throw "BLUE COMMANDER source not found: $commanderSource" }
if (-not (Test-Path -LiteralPath $guard -PathType Leaf)) { throw "BLUE COMMANDER guard not found: $guard" }

& $guard -SourceFile $commanderSource

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- Builder: tools/build-blue-commander-foundation.ps1`n-- BuilderVersion: $builderVersion`n-- GitCommit: $commit`n-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Scope: combined BLUE AIRWING + central COMMANDER foundation; no mission generation.`n`n"

$parts = New-Object System.Collections.Generic.List[string]
$parts.Add($header)
foreach ($relative in $airOpsSources) {
    $parts.Add((Get-Content -LiteralPath (Join-Path $repoRoot $relative) -Raw -Encoding UTF8))
    $parts.Add("`n")
}
$parts.Add((Get-Content -LiteralPath $commanderSource -Raw -Encoding UTF8))
$content = [string]::Concat($parts)
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

& $guard -SourceFile $commanderSource -GeneratedFile $outputFile

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host 'Scope: BLUE_COMMANDER_FOUNDATION_ONLY'
Write-Host 'ExpectedAirwings: 8'
Write-Host 'GeneratedMissions: 0'
Write-Host 'GeneratedTransports: 0'
Write-Host 'CampaignStateMutation: false'
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
