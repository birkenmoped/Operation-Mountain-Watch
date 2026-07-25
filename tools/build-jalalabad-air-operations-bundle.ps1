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
    '05a-validate-squadron-parking-pools.lua',
    '05b-validate-runtime-name-contract.lua',
    '05c-package-contracts.lua',
    '06-construct-oh58d-squadron.lua',
    '07-construct-ah64d-squadron.lua',
    '08-construct-uh60-squadron.lua',
    '09-construct-ch47-squadron.lua',
    '10-validate-static-parking-clearance.lua',
    '10-validate-and-start-complete-node.lua',
    '11-phase1-test-manifest.lua',
    '12-phase1-runtime-observer.lua',
    '13-phase1-mission-factory.lua',
    '14-phase1-test-controller.lua',
    '14a-phase1-lifecycle-corrections.lua',
    '14b-phase1-sequence-finalization.lua',
    '15-phase1-f10-and-acceptance.lua',
    '16-phase1-moose-compatibility.lua',
    '17-phase1-operational-safety.lua',
    '18-phase1-readiness-and-recon-telemetry.lua',
    '19-phase1-oh58-formation-recovery-counting.lua',
    '20-phase1-uh60-transport-lifecycle.lua'
)

if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
    throw "Source directory not found: $sourceDir"
}

# Pinned MOOSE commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
# implements SQUADRON:SetDespawnAfterLanding(false) as an enable operation.
# UH-60 transport assets must leave the squadron-level option unset so pickup
# and drop-off landings do not despawn the active FLIGHTGROUP.
$uh60SquadronPath = Join-Path $sourceDir '08-construct-uh60-squadron.lua'
$uh60SquadronSource = Get-Content -LiteralPath $uh60SquadronPath -Raw -Encoding UTF8
$forbiddenFalseSetter = '(?m)^\s*squadron:SetDespawnAfterLanding\s*\(\s*false\s*\)\s*$'
if ($uh60SquadronSource -match $forbiddenFalseSetter) {
    throw 'UH-60 regression: SetDespawnAfterLanding(false) enables despawn in the pinned MOOSE version. Omit the setter entirely.'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'JBAD-AIR-OPS-PHASE1-9-HOTFIX1'
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
