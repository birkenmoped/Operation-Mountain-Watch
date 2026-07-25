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
    '12a-phase1-moose-logistics.lua',
    '13-phase1-mission-factory.lua',
    '14-phase1-test-controller.lua',
    '15-phase1-f10-and-acceptance.lua',
    '16-phase1-moose-first-readiness-routing.lua'
)

$obsoleteOverrideFiles = @(
    '14a-phase1-lifecycle-corrections.lua',
    '14b-phase1-sequence-finalization.lua',
    '16-phase1-moose-compatibility.lua',
    '17-phase1-operational-safety.lua',
    '18-phase1-readiness-and-recon-telemetry.lua',
    '19-phase1-oh58-formation-recovery-counting.lua',
    '20-phase1-uh60-transport-lifecycle.lua'
)

if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
    throw "Source directory not found: $sourceDir"
}

foreach ($obsolete in $obsoleteOverrideFiles) {
    if (Test-Path -LiteralPath (Join-Path $sourceDir $obsolete) -PathType Leaf) {
        throw "MOOSE-first regression: obsolete override source still exists: $obsolete"
    }
}

$sourceText = @{}
foreach ($fileName in $sourceFiles) {
    $path = Join-Path $sourceDir $fileName
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required source file not found: $path"
    }
    $sourceText[$fileName] = Get-Content -LiteralPath $path -Raw -Encoding UTF8
}

$allCanonicalSource = [string]::Join("`n", ($sourceFiles | ForEach-Object { $sourceText[$_] }))

# Pinned MOOSE 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54 implements
# SQUADRON:SetDespawnAfterLanding(false) as an enable operation. A false call is
# therefore forbidden. Carrier squadrons leave the option unset and arm the
# exact FLIGHTGROUP only after native delivery confirmation.
if ($allCanonicalSource -match '(?m)^\s*[^-\r\n]*:SetDespawnAfterLanding\s*\(\s*false\s*\)') {
    throw 'Regression: SetDespawnAfterLanding(false) enables despawn in the pinned MOOSE version. Omit the setter.'
}

# MOOSE-first architecture gate: canonical runtime code must not read the listed
# internal implementation tables or restore the removed parallel mission FSM.
$forbiddenInternalPatterns = @(
    '\.missionqueue',
    'squadron\.assets',
    '_DATABASE\.Templates\.Groups',
    'mission\.groupdata',
    'opsgroup\.groupname',
    'opsgroup\.group',
    'RefreshMissionGroups',
    'MarkObjectiveDrivenSuccess',
    'runtime\.ObjectiveCheck',
    'MissionStateSeen'
)
foreach ($pattern in $forbiddenInternalPatterns) {
    if ($allCanonicalSource -match $pattern) {
        throw "MOOSE-first regression: forbidden custom/internal pattern '$pattern'."
    }
}

$requiredMooseApis = @(
    'CountMissionsInQueue',
    'CountAssetsOnMission',
    'CountAssets',
    'OnAfterFlightOnMission',
    'AddConditionSuccess',
    'OPSTRANSPORT:New',
    'LEGION.RecruitCohortAssets',
    'RecruitAssetsForTransport',
    'TransportAssign',
    'OnAfterLoaded',
    'OnAfterUnloaded',
    'OnAfterDelivered',
    'DynamicCargoLoaded',
    'DynamicCargoUnloaded'
)
foreach ($api in $requiredMooseApis) {
    if ($allCanonicalSource -notmatch [regex]::Escape($api)) {
        throw "MOOSE-first regression: required API '$api' not found in canonical sources."
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'JBAD-AIR-OPS-PHASE1-11-MOOSE-FIRST'
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
-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
-- Architecture: AUFTRAG/OPSTRANSPORT/FLIGHTGROUP native authority
-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))

"@

$chunks = New-Object System.Collections.Generic.List[string]
$chunks.Add($header)
foreach ($fileName in $sourceFiles) {
    $chunks.Add("-- BEGIN SOURCE: $fileName`r`n")
    $chunks.Add($sourceText[$fileName])
    $chunks.Add("`r`n-- END SOURCE: $fileName`r`n`r`n")
}

$content = [string]::Concat($chunks)
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
