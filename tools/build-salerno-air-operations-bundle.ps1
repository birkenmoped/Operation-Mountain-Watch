[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\salerno-air-operations\src'
$distDir = Join-Path $repoRoot 'mission\tests\salerno-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Salerno_Diagnostics.lua'
$sourceFiles = @(
    '01-salerno-bootstrap.lua',
    '02-resolve-airbase-and-parking.lua',
    '03-probe-warehouse-and-objects.lua',
    '04-construct-airwing-anchor.lua',
    '05-construct-squadrons.lua',
    '06-register-squadrons-with-airwing.lua',
    '07-configure-squadron-baseline.lua',
    '08-activate-operational-baseline.lua',
    '09-validate-dispatch-readiness.lua',
    '10-dispatch-controlled-missions.lua'
)

if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
    throw "Source directory not found: $sourceDir"
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
$builderVersion = 'SAL-SQUADRON-PARKING-SECTORS-10'
$commit = 'UNKNOWN'
try { $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim() } catch { $commit = 'UNKNOWN' }

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-salerno-air-operations-bundle.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))

"@

$chunks = New-Object System.Collections.Generic.List[string]
$chunks.Add($header)
foreach ($fileName in $sourceFiles) {
    $path = Join-Path $sourceDir $fileName
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required source file not found: $path" }
    $chunks.Add("-- BEGIN SOURCE: $fileName`r`n")
    $chunks.Add((Get-Content -LiteralPath $path -Raw -Encoding UTF8))
    $chunks.Add("`r`n-- END SOURCE: $fileName`r`n`r`n")
}

[System.IO.File]::WriteAllText($outputFile, [string]::Concat($chunks), [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
