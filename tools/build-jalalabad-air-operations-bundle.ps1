[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\jalalabad-air-operations\src'
$distDir = Join-Path $repoRoot 'mission\tests\jalalabad-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Jalalabad.lua'

# A failed build must never leave an older apparently usable bundle behind.
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$sourceFiles = @(
    '01-jalalabad-bootstrap.lua',
    '02-dump-airbase-parking.lua',
    '03-probe-warehouse-anchor.lua',
    '04-dump-aircraft-types.lua',
    '05-validate-mission-templates.lua',
    '05a-validate-squadron-parking-pools.lua',
    '05c-package-contracts.lua',
    '05b-validate-runtime-name-contract.lua',
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

function Assert-SourceBefore {
    param(
        [Parameter(Mandatory = $true)][string]$Dependency,
        [Parameter(Mandatory = $true)][string]$Dependent
    )

    $dependencyIndex = [Array]::IndexOf($sourceFiles, $Dependency)
    $dependentIndex = [Array]::IndexOf($sourceFiles, $Dependent)
    if ($dependencyIndex -lt 0 -or $dependentIndex -lt 0) {
        throw "Builder dependency gate references an unknown source: dependency=$Dependency dependent=$Dependent"
    }
    if ($dependencyIndex -ge $dependentIndex) {
        throw "Builder dependency order invalid: '$Dependency' must be embedded before '$Dependent'."
    }
}

# Runtime-name validation reads package contracts and produces the prefixes that
# the Phase-1 manifest consumes. The order is therefore a hard build contract.
Assert-SourceBefore -Dependency '05c-package-contracts.lua' -Dependent '05b-validate-runtime-name-contract.lua'
Assert-SourceBefore -Dependency '05b-validate-runtime-name-contract.lua' -Dependent '11-phase1-test-manifest.lua'
Assert-SourceBefore -Dependency '11-phase1-test-manifest.lua' -Dependent '12-phase1-runtime-observer.lua'
Assert-SourceBefore -Dependency '12-phase1-runtime-observer.lua' -Dependent '12a-phase1-moose-logistics.lua'
Assert-SourceBefore -Dependency '12a-phase1-moose-logistics.lua' -Dependent '13-phase1-mission-factory.lua'
Assert-SourceBefore -Dependency '13-phase1-mission-factory.lua' -Dependent '14-phase1-test-controller.lua'
Assert-SourceBefore -Dependency '14-phase1-test-controller.lua' -Dependent '15-phase1-f10-and-acceptance.lua'

$sourceText = @{}
foreach ($fileName in $sourceFiles) {
    $path = Join-Path $sourceDir $fileName
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required source file not found: $path"
    }
    $sourceText[$fileName] = Get-Content -LiteralPath $path -Raw -Encoding UTF8
}

# File order alone is insufficient when a dependency is scheduled for later.
# The runtime-name contract must complete while the bundle is evaluated because
# the manifest, observer, factory, controller and F10 menu are initialized next.
$nameContractSource = $sourceText['05b-validate-runtime-name-contract.lua']
if ($nameContractSource -match '\bSCHEDULER\b|timer\.scheduleFunction') {
    throw "Builder dependency timing invalid: 05b runtime-name validation must not be scheduled."
}
if ($nameContractSource -notmatch 'pcall\s*\(\s*main\s*\)' -or $nameContractSource -notmatch 'INITIALIZATION mode=SYNCHRONOUS') {
    throw "Builder dependency timing invalid: 05b must invoke main synchronously and emit the synchronous initialization marker."
}

$manifestSource = $sourceText['11-phase1-test-manifest.lua']
if ($manifestSource -notmatch 'NameContractInitialized' -or $manifestSource -notmatch 'NameContractOK') {
    throw "Builder dependency gate invalid: Phase-1 manifest must require the initialized runtime-name contract."
}

# Canonical Mission Editor object contract from OMW_Jalalabad_AirOps_Phase1_Test.miz.
# A Lua-only refactor must not silently rename Mission Editor objects. Any future
# migration requires an explicit Mission Editor change and a deliberate contract update.
$canonicalMissionObjects = @(
    'ZONE_TEST_US_JBAD_RECON_01',
    'ZONE_TEST_US_JBAD_RECON_02',
    'ZONE_TEST_US_JBAD_RECON_03',
    'ZONE_TEST_US_JBAD_CAS',
    'TPL_GROUND_RED_JBAD_PHASE1_CAS_TARGET',
    'TPL_GROUND_BLUE_JBAD_PHASE1_UH60_TROOPS',
    'ZONE_AIR_US_JBAD_LOGISTICS_LOAD',
    'ZONE_TEST_US_JBAD_UH60_DROPOFF',
    'TEST_CARGO_BLUE_JBAD_CH47_01',
    'ZONE_AIR_US_JBAD_SLING_PICKUP',
    'ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD'
)
foreach ($objectName in $canonicalMissionObjects) {
    if ($manifestSource -notmatch [regex]::Escape($objectName)) {
        throw "Mission Editor object contract regression: canonical object '$objectName' is missing from the Phase-1 manifest."
    }
}
$inventedMissionObjectAliases = @(
    'TZ_AIR_US_JBAD_',
    'TG_RED_JBAD_CAS_TARGET_01',
    'TG_BLUE_JBAD_UH60_TROOPS_01',
    'ST_BLUE_JBAD_CH47_CARGO_01'
)
foreach ($alias in $inventedMissionObjectAliases) {
    if ($manifestSource -match [regex]::Escape($alias)) {
        throw "Mission Editor object contract regression: invented alias '$alias' must not replace the canonical .miz object names."
    }
}
if ($manifestSource -notmatch 'missionEditorObjectContract=CANONICAL') {
    throw "Mission Editor object contract regression: canonical readiness marker missing."
}

# The observer is loaded before the delayed AIRWING construction/activation has
# completed. It may define an attachment API, but it must not dereference
# cfg.Airwing while the bundle is evaluated.
$observerSource = $sourceText['12-phase1-runtime-observer.lua']
if ($observerSource -match 'local\s+previousFlightOnMission\s*=\s*cfg\.Airwing\.') {
    throw "Initialization smoke test failed: observer dereferences cfg.Airwing at bundle load time."
}
if ($observerSource -notmatch 'function\s+observer:AttachAirwing\s*\(' -or
    $observerSource -notmatch 'airwing\.OnAfterFlightOnMission' -or
    $observerSource -notmatch 'airwingHook=DEFERRED') {
    throw "Initialization smoke test failed: observer must expose a deferred AIRWING hook attachment."
}

# The complete-node activation must attach the observer callback to the exact
# AIRWING object before AIRWING:Start() can emit FlightOnMission events.
$completeNodeSource = $sourceText['10-validate-and-start-complete-node.lua']
$attachIndex = $completeNodeSource.IndexOf('observer:AttachAirwing')
$airwingStartIndex = $completeNodeSource.IndexOf('cfg.Airwing:Start()')
if ($attachIndex -lt 0 -or $airwingStartIndex -lt 0 -or $attachIndex -ge $airwingStartIndex) {
    throw "Initialization smoke test failed: observer AIRWING hook must be attached before AIRWING:Start()."
}

# The F10 diagnostic/control menu is deliberately baseline-independent. This
# guarantees a visible status surface even if later AIRWING validation blocks.
$menuSource = $sourceText['15-phase1-f10-and-acceptance.lua']
$immediateMenuIndex = $menuSource.IndexOf('local menuInitialized = createMenus()')
$menuSchedulerIndex = $menuSource.IndexOf('SCHEDULER:New')
if ($immediateMenuIndex -lt 0 -or $menuSchedulerIndex -lt 0 -or $immediateMenuIndex -ge $menuSchedulerIndex) {
    throw "Initialization smoke test failed: F10 menu must be created immediately before the acceptance scheduler."
}
if ($menuSource -match 'BaselineReady\s*==\s*true\s*then\s*createMenus') {
    throw "Initialization smoke test failed: F10 menu creation must not depend on AIRWING baseline readiness."
}
if ($menuSource -notmatch 'commands=8 availability=IMMEDIATE baselineIndependent=true') {
    throw "Initialization smoke test failed: immediate F10 menu readiness marker missing."
}

$allCanonicalSource = [string]::Join("`n", ($sourceFiles | ForEach-Object { $sourceText[$_] }))

function Get-SourcePatternHits {
    param(
        [Parameter(Mandatory = $true)][string]$Pattern,
        [Parameter(Mandatory = $true)][string]$Label
    )

    $hits = New-Object System.Collections.Generic.List[string]
    foreach ($fileName in $sourceFiles) {
        $lineNumber = 0
        foreach ($line in ($sourceText[$fileName] -split "`r?`n")) {
            $lineNumber++
            if ($line -match $Pattern) {
                $hits.Add("$fileName`:$lineNumber [$Label]")
            }
        }
    }
    return $hits
}

# Pinned MOOSE 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54 implements
# SQUADRON:SetDespawnAfterLanding(false) as an enable operation. A false call is
# therefore forbidden. Carrier squadrons leave the option unset and arm the
# exact FLIGHTGROUP only after native delivery confirmation.
$regressionHits = New-Object System.Collections.Generic.List[string]
foreach ($hit in (Get-SourcePatternHits -Pattern '^\s*[^-\r\n]*:SetDespawnAfterLanding\s*\(\s*false\s*\)' -Label 'SetDespawnAfterLanding(false)')) {
    $regressionHits.Add($hit)
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
    foreach ($hit in (Get-SourcePatternHits -Pattern $pattern -Label $pattern)) {
        $regressionHits.Add($hit)
    }
}

if ($regressionHits.Count -gt 0) {
    throw ("MOOSE-first source regressions found:`n - " + [string]::Join("`n - ", $regressionHits))
}

$requiredMooseApis = @(
    'GetGroupTemplate',
    'CountMissionsInQueue',
    'CountAssetsOnMission',
    'CountAssets',
    'OnAfterFlightOnMission',
    'AddConditionSuccess',
    'AddRequiredPayload',
    'OPSTRANSPORT:New',
    'LEGION.RecruitCohortAssets',
    'RecruitAssetsForTransport',
    'TransportAssign',
    'OnAfterLoaded',
    'OnAfterLoadingDone',
    'OnAfterUnloaded',
    'OnAfterUnloadingDone',
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

$builderVersion = 'JBAD-AIR-OPS-PHASE1-15-MOOSE-FIRST'
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
-- InitializationSmoke: synchronous-name-contract/deferred-airwing-hook/immediate-f10-menu
-- MissionObjectContract: canonical-OMW_Jalalabad_AirOps_Phase1_Test
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
Write-Host "InitializationSmoke: PASS"
Write-Host "MissionObjectContract: PASS"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
