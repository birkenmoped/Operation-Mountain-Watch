[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\bagram-air-operations\src'
$distDir = Join-Path $repoRoot 'mission\tests\bagram-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Bagram.lua'

$sourceFiles = @(
    '01-bagram-bootstrap.lua',
    '02-dump-airbase-parking.lua',
    '03-validate-bagram-parking-contract.lua',
    '05-construct-bagram-squadrons.lua',
    '11-validate-and-start-complete-node.lua',
    '20-test-hh60g-controlled-spawn-cleanup.lua'
)

if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
    throw "Source directory not found: $sourceDir"
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'BGRAM-HH60G-ALERT5-CAPABILITY-FIX-5'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-bagram-air-operations-bundle.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
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
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"