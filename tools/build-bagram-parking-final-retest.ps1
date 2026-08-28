[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$foundationSource = Join-Path $repoRoot 'scripts\air-operations\OMW_AirOps_Bagram_Bootstrap.lua'
$retestPrepSource = Join-Path $repoRoot 'mission\tests\bagram-air-operations\src\OMW_Bagram_Parking_Final_Retest_Alert5.lua'
$acceptanceSource = Join-Path $repoRoot 'mission\tests\bagram-air-operations\src\OMW_Bagram_Parking_Final_Acceptance.lua'
$validatedCsv = Join-Path $repoRoot 'docs\data\bagram-me-parking-to-moose-terminalid-validated.csv'
$lifecycleGuard = Join-Path $repoRoot 'tools\Test-AirOpsLifecycleGuards.ps1'
$distDir = Join-Path $repoRoot 'mission\tests\bagram-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Bagram.lua'
$builderVersion = 'BGRAM-PARKING-FINAL-ACCEPTANCE-2'
$testId = 'BAGRAM-PARKING-FINAL-ACCEPTANCE-1-RETEST-1'

foreach ($requiredFile in @($foundationSource, $retestPrepSource, $acceptanceSource, $validatedCsv, $lifecycleGuard)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required final retest input not found: $requiredFile"
    }
}

$foundation = Get-Content -LiteralPath $foundationSource -Raw -Encoding UTF8
$retestPrep = Get-Content -LiteralPath $retestPrepSource -Raw -Encoding UTF8
$acceptance = Get-Content -LiteralPath $acceptanceSource -Raw -Encoding UTF8
$rows = @(Import-Csv -LiteralPath $validatedCsv)

if ($rows.Count -ne 187) {
    throw "Expected 187 validated Bagram parking rows, found $($rows.Count)."
}

$seenLabels = @{}
$seenTerminalIDs = @{}
$luaRows = New-Object System.Collections.Generic.List[string]

foreach ($row in $rows) {
    $groupLabel = [string]$row.group_label
    $meParkingID = [string]$row.mission_editor_parking_id
    $terminalText = [string]$row.moose_terminal_id

    if ([string]::IsNullOrWhiteSpace($groupLabel) -or [string]::IsNullOrWhiteSpace($meParkingID)) {
        throw 'Validated Bagram parking row has an empty label.'
    }

    $terminalID = 0
    if (-not [int]::TryParse($terminalText, [ref]$terminalID)) {
        throw "Validated Bagram parking row '$groupLabel' has invalid TerminalID '$terminalText'."
    }
    if ($seenLabels.ContainsKey($groupLabel)) {
        throw "Duplicate group_label in validated Bagram parking CSV: $groupLabel"
    }
    if ($seenTerminalIDs.ContainsKey($terminalID)) {
        throw "Duplicate TerminalID in validated Bagram parking CSV: $terminalID"
    }

    $seenLabels[$groupLabel] = $true
    $seenTerminalIDs[$terminalID] = $true
    $escapedGroup = $groupLabel.Replace('\', '\\').Replace('"', '\"')
    $escapedParking = $meParkingID.Replace('\', '\\').Replace('"', '\"')
    $luaRows.Add("  { groupLabel = `"$escapedGroup`", meParkingID = `"$escapedParking`", terminalID = $terminalID },")
}

if (-not $seenLabels.ContainsKey('D09') -or -not $seenLabels.ContainsKey('D09-1')) {
    throw 'Validated Bagram parking baseline must contain both D09 and D09-1.'
}
if (-not $seenTerminalIDs.ContainsKey(0)) {
    throw 'Validated Bagram parking baseline must contain TerminalID 0.'
}

$luaTable = "{`n" + ($luaRows -join "`n") + "`n}"
if (-not $acceptance.Contains('__BAGRAM_PARKING_CANDIDATES__')) {
    throw 'Final acceptance source is missing the Bagram parking candidate placeholder.'
}
$acceptance = $acceptance.Replace('__BAGRAM_PARKING_CANDIDATES__', $luaTable)

$combinedSource = $foundation + "`n`n-- === FINAL PARKING RETEST ALERT5 PREP ===`n`n" + $retestPrep + "`n`n-- === FINAL PARKING ACCEPTANCE HARNESS ===`n`n" + $acceptance

$requiredMarkers = @(
    'PARKING_POLICY_PRESTART status=PASS',
    'PARKING_POLICY_POSTSTART status=%s',
    'function airwing:OnAfterNewAsset',
    'ALERT5_TEST_PREP status=PASS',
    'squadron:AddMissionCapability({ AUFTRAG.Type.ALERT5 })',
    'airwing:NewPayload(seed, -1, { AUFTRAG.Type.ALERT5, missionType }, 100)',
    'AUFTRAG:NewALERT5',
    'SetRequiredAssets(1, 1)',
    'AssignSquadrons({ squadron })',
    'OnAfterOpsOnMission',
    'GetParkingSpotsTable',
    'Get2DDistance',
    'PHYSICAL_PARKING status=%s',
    'PARKING_RUNTIME_BASELINE status=%s',
    'OBJECT_CONTRACT status=%s',
    'BAGRAM_PARKING_FINAL_RESULT status=%s',
    'TIMEOUT_120S'
)
foreach ($marker in $requiredMarkers) {
    if (-not $combinedSource.Contains($marker)) {
        throw "Final retest source is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'SPAWN\s*:',
    'FLIGHTGROUP\s*:\s*New\s*\(',
    'COMMANDER\s*:\s*New\s*\(',
    'OPSTRANSPORT\s*:\s*New\s*\(',
    'missionCommands',
    'coalition\.addGroup',
    'mist\.',
    '_FindParkingForAssets\s*='
)
foreach ($pattern in $forbiddenPatterns) {
    if ($combinedSource -match $pattern) {
        throw "Final parking retest contains forbidden non-MOOSE/override path: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-bagram-parking-final-retest.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestID: $testId
-- MOOSE-Pin: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
-- MOOSE-SHA256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
-- Scope: Bagram foundation + source-verified ALERT5 test capability/payload prep + 187/187 parking baseline + 69/69 parking propagation + seven controlled MOOSE ALERT5 materializations + physical TerminalID verification.
-- Excludes: tactical mission completion, taxi, takeoff, landing, recovery, persistence, COMMANDER and OPSTRANSPORT.

"@
$content = $header + $combinedSource
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

& $lifecycleGuard `
    -SourceFile $foundationSource `
    -GeneratedFile $outputFile `
    -PreStartFunctionName 'constructFoundation' `
    -PostStartFunctionName 'inspectIdleFoundation' `
    -RequirePostStartAssetValidation `
    -FoundationScope

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "Scope: BAGRAM_PARKING_FINAL_ACCEPTANCE_RETEST"
Write-Host "LifecycleGuard: PASS"
Write-Host "ParkingCandidates: 187"
Write-Host "FoundationAssetsExpected: 69"
Write-Host "MaterializedGroupsExpected: 7"
Write-Host "MaterializedUnitsExpected: 9"
Write-Host "DispatchMethod: MOOSE_AUFTRAG_ALERT5"
Write-Host "Alert5SquadronCapabilityPrep: TEST_ONLY"
Write-Host "Alert5PayloadCapabilityPrep: TEST_ONLY"
Write-Host "NativeSpawn: ABSENT"
Write-Host "SPAWNClass: ABSENT"
Write-Host "Commander: ABSENT"
Write-Host "OPSTRANSPORT: ABSENT"
Write-Host "OneBundle: YES"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "GeneratedUtc: $generatedUtc"
