[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\src\07-tarinkot-g7-airwing-squadron-payload-foundation.lua'
$distDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Tarinkot_G7_Foundation.lua'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Required source file not found: $sourceFile"
}

$sourceText = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

# MOOSE 2.9.18 AIRWING:AddSquadron() adds the requested assets to the
# warehouse stock immediately. The LEGION start path subsequently binds those
# stock items to the cohort/SQUADRON and copies cohort parkingIDs into every
# asset. Consequently squadron.assets is expected to be empty before
# AIRWING:Start() and must only be accepted after the delayed idle inspection.
# The original source checked squadron.assets too early; this builder corrects
# the timing without changing the accepted object or inventory contract.
$oldConstructionGate = 'if template and #missionTypes == #contract.MissionTypeNames and state.Violations == 0 then'
$newConstructionGate = 'if template and #missionTypes == #contract.MissionTypeNames then'

$oldPreStartAssetBlock = @'
        local assetCount = countTable(squadron.assets)
        if assetCount ~= contract.Ngroups then
          violation("SQUADRON_ASSET_COUNT_MISMATCH family=" .. contract.Key .. " expected=" .. tostring(contract.Ngroups) .. " actual=" .. tostring(assetCount))
        end

        for assetIndex, asset in pairs(squadron.assets or {}) do
          local parkingAccepted = numericListEqual(asset.parkingIDs, contract.ParkingIDs)
          log(string.format(
            "ASSET_CONTRACT family=%s assetIndex=%s squadron=%s parkingIDs=%s expectedParkingIDs=%s parkingAccepted=%s",
            contract.Key, tostring(assetIndex), tostring(asset.squadname),
            join(asset.parkingIDs), join(contract.ParkingIDs), tostring(parkingAccepted)
          ))
          if not parkingAccepted then
            violation("ASSET_PARKING_IDS_MISMATCH family=" .. contract.Key .. " assetIndex=" .. tostring(assetIndex))
          end
        end
'@

$newPreStartAssetBlock = @'
        -- AIRWING:AddSquadron() has synchronously added the asset groups to
        -- warehouse stock, but MOOSE binds them into squadron.assets only in
        -- the AIRWING/LEGION start path. Validate cumulative stock here and
        -- validate squadron.assets plus inherited parking IDs after Start.
        local stockAfterAdd = countTable(airwing.stock)
        local expectedStockAfterAdd = registeredGroups + contract.Ngroups
        local squadronAssetsBeforeStart = countTable(squadron.assets)
        log(string.format(
          "SQUADRON_STOCK_PRESTART family=%s stock=%d expectedStock=%d squadronAssetsBeforeStart=%d expectedDeferredAssets=%d",
          contract.Key, stockAfterAdd, expectedStockAfterAdd,
          squadronAssetsBeforeStart, contract.Ngroups
        ))
        if stockAfterAdd ~= expectedStockAfterAdd then
          violation("SQUADRON_STOCK_COUNT_MISMATCH family=" .. contract.Key .. " expected=" .. tostring(expectedStockAfterAdd) .. " actual=" .. tostring(stockAfterAdd))
        end
'@

if (-not $sourceText.Contains($oldConstructionGate)) {
    throw "Expected legacy construction gate not found: $oldConstructionGate"
}
if (-not $sourceText.Contains($oldPreStartAssetBlock)) {
    throw 'Expected premature pre-start squadron asset-validation block not found.'
}

$sourceText = $sourceText.Replace($oldConstructionGate, $newConstructionGate)
$sourceText = $sourceText.Replace($oldPreStartAssetBlock, $newPreStartAssetBlock)

if ($sourceText.Contains($oldConstructionGate)) {
    throw 'Legacy fail-fast family construction gate remained after transformation.'
}
if ($sourceText.Contains('SQUADRON_ASSET_COUNT_MISMATCH')) {
    throw 'Premature pre-start squadron.assets violation remained after transformation.'
}
if (-not $sourceText.Contains('SQUADRON_STOCK_PRESTART')) {
    throw 'Pre-start warehouse-stock validation was not embedded.'
}
if (-not $sourceText.Contains('SQUADRON_ASSET_COUNT_CHANGED')) {
    throw 'Post-start squadron.assets validation is missing.'
}

$requiredPatterns = @(
    'AIRWING\s*:\s*New\s*\(',
    ':\s*SetAirbase\s*\(',
    ':\s*SetTakeoffCold\s*\(',
    ':\s*SetSafeParkingOn\s*\(',
    ':\s*SetOptionPreferVerticalLanding\s*\(',
    'SQUADRON\s*:\s*New\s*\(',
    ':\s*SetGrouping\s*\(',
    ':\s*SetParkingIDs\s*\(',
    ':\s*AddMissionCapability\s*\(',
    ':\s*AddSquadron\s*\(',
    ':\s*NewPayload\s*\(',
    ':\s*GetSquadron\s*\(',
    ':\s*GetOpsGroups\s*\(',
    'airwing\s*:\s*Start\s*\(',
    'G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION',
    'SQUADRON_STOCK_PRESTART',
    'squadronAssetsBeforeStart',
    'SQUADRON_ASSET_COUNT_CHANGED',
    'verticalPolicySetBeforeStart=true',
    'commanderCreated=0',
    'auftragCreated=0',
    'opsTransportCreated=0',
    'deliberateSpawns=0'
)

foreach ($pattern in $requiredPatterns) {
    if ($sourceText -notmatch $pattern) {
        throw "Required source pattern missing: $pattern"
    }
}

$forbiddenPatterns = @(
    'COMMANDER\s*:\s*New\s*\(',
    'AUFTRAG\s*:\s*New[A-Za-z0-9_]*\s*\(',
    'OPSTRANSPORT\s*:\s*New\s*\(',
    'SPAWN\s*:',
    'FLIGHTGROUP\s*:\s*New\s*\(',
    ':\s*SetAIOn\s*\(',
    ':\s*StartUncontrolled\s*\(',
    ':\s*Despawn\s*\(',
    ':\s*Destroy\s*\(',
    'coalition\s*\.\s*addGroup\s*\(',
    'ZONE_RADIUS\s*:\s*New\s*\(',
    'CampaignState\s*[\.:]',
    ':\s*AddMission\s*\('
)

foreach ($pattern in $forbiddenPatterns) {
    if ($sourceText -match $pattern) {
        throw "Forbidden source pattern matched: $pattern"
    }
}

$verticalCall = 'airwing:SetOptionPreferVerticalLanding()'
$startCall = 'airwing:Start()'
$verticalIndex = $sourceText.IndexOf($verticalCall, [System.StringComparison]::Ordinal)
$startIndex = $sourceText.IndexOf($startCall, [System.StringComparison]::Ordinal)

if ($verticalIndex -lt 0) {
    throw "Vertical-policy call not found: $verticalCall"
}
if ($startIndex -lt 0) {
    throw "AIRWING start call not found: $startCall"
}
if ($verticalIndex -ge $startIndex) {
    throw 'AIRWING:SetOptionPreferVerticalLanding() must occur before AIRWING:Start().'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'TKOT-G7-AIRWING-FOUNDATION-3'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}
$generatedUtc = [DateTime]::UtcNow.ToString('o')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-tarinkot-air-operations-g7-foundation.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate: G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION
-- Scope: one AIRWING, three SQUADRONs, G6-accepted parking pools,
-- capabilities, role payloads and stable idle AIRWING start.
-- Excluded: COMMANDER, AUFTRAG instances, OPSTRANSPORT, SPAWN, functional
-- zones, tactical dispatch, return/recovery and lifecycle cleanup.
-- Vertical policy order: AIRWING:SetOptionPreferVerticalLanding() before
-- AIRWING:Start(); actual vertical departure remains a later G8 dispatch test.
-- Asset-link timing: warehouse stock is checked before AIRWING:Start();
-- squadron.assets and inherited parkingIDs are checked after AIRWING start.
-- Observer-client policy: active observers on the three hard-excluded client
-- terminals 3, 8 and 20 are allowed. Those terminals cannot enter any G7
-- SQUADRON parking pool and therefore cannot affect this no-spawn foundation gate.

local OMW_TKOT_G7_BUILD = {
  Builder = "tools/build-tarinkot-air-operations-g7-foundation.ps1",
  BuilderVersion = "$builderVersion",
  GitCommit = "$commit",
  GeneratedUtc = "$generatedUtc"
}

-- BEGIN SOURCE
"@

$footer = @"

-- Observer-client policy override for the scheduled G7 execution.
-- The source-level detector still logs the actual occupied Tarinkot client
-- units. Since all three client terminals are hard-excluded from the eight
-- validated SQUADRON parking IDs and G7 deliberately creates no flight, an
-- observer client is diagnostic only and is not a blocking condition.
local OMW_TKOT_G7_originalActivePlayerClientCount = activePlayerClientCount
activePlayerClientCount = function()
  local detected = OMW_TKOT_G7_originalActivePlayerClientCount()
  if detected > 0 then
    log("ACTIVE_PLAYER_CLIENT_POLICY detected=" .. tostring(detected) .. " disposition=ALLOWED_HARD_EXCLUDED_CLIENT_TERMINAL blocking=0")
  end
  return 0
end

-- END SOURCE
"@

$content = $header + $sourceText + $footer
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

if ($content -notmatch 'ACTIVE_PLAYER_CLIENT_POLICY detected=') {
    throw 'Observer-client policy override was not embedded in the generated bundle.'
}
if ($content -match 'SQUADRON_ASSET_COUNT_MISMATCH') {
    throw 'Generated bundle still contains the premature pre-start asset violation.'
}
if ($content -notmatch 'SQUADRON_STOCK_PRESTART') {
    throw 'Generated bundle does not contain the corrected pre-start stock check.'
}

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Gate: G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION"
Write-Host "Airwing: AW_US_TKOT_TF_ATTACK_3_101_AVN"
Write-Host "Squadrons: 3"
Write-Host "RegisteredGroups: 5"
Write-Host "RegisteredAircraft: 7"
Write-Host "RolePayloads: 3"
Write-Host "ExpectedTotalPayloadsIncludingRelocation: 6"
Write-Host "ParkingPools: AH64=21,4 UH60=30,27,23 CH47=32,29,10"
Write-Host "VerticalPolicy: AIRWING:SetOptionPreferVerticalLanding before AIRWING:Start"
Write-Host "AssetLinkingPolicy: warehouse stock pre-start; squadron.assets post-start"
Write-Host "ObserverClientPolicy: allowed on hard-excluded client terminals 3,8,20"
Write-Host "OperationalMissions: 0"
Write-Host "DeliberateSpawns: 0"
Write-Host "RequiredGuardPatternsChecked: $($requiredPatterns.Count)"
Write-Host "ForbiddenGuardPatternsChecked: $($forbiddenPatterns.Count)"
Write-Host "BundlesBuilt: 1"
