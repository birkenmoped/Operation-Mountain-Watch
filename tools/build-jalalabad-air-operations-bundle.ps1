[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\jalalabad-air-operations\src'
$distDir = Join-Path $repoRoot 'mission\tests\jalalabad-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Jalalabad.lua'

$sourceFiles = @(
    '01-jalalabad-bootstrap.lua',
    '02-dump-airbase-parking.lua',
    '03-probe-warehouse-anchor.lua',
    '04-dump-aircraft-types.lua',
    '05-validate-mission-templates.lua',
    '06-construct-oh58d-squadron.lua',
    '07-construct-ah64d-squadron.lua',
    '08-construct-uh60-squadron.lua',
    '09-construct-ch47-squadron.lua',
    '10-validate-static-parking-clearance.lua',
    '10-validate-and-start-complete-node.lua'
)

if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
    throw "Source directory not found: $sourceDir"
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'JBAD-AIR-OPS-COMPLETE-4'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-jalalabad-air-operations-bundle.ps1
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
