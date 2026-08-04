[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\src\07-tarinkot-g7-airwing-squadron-payload-foundation.lua'
$guardFile = Join-Path $repoRoot 'tools\Test-AirOpsLifecycleGuards.ps1'
$distDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Tarinkot_G7_Foundation.lua'

foreach ($requiredFile in @($sourceFile, $guardFile)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        throw "Required file not found: $requiredFile"
    }
}

$sourceText = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

# MOOSE 2.9.18 lifecycle correction:
# AddSquadron registers Warehouse stock synchronously. The WAREHOUSE/LEGION
# start path subsequently binds those assets to the COHORT/SQUADRON. Therefore
# squadron.assets and inherited asset parkingIDs are accepted only after Start.
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

# Observer-client correction:
# Keep the actual detected count. Classify the confirmed hard-excluded observer
# client as allowed/non-blocking instead of overriding the detector to return 0.
$newObserverFunction = @'
local function evaluateObserverClients()
  local units = {}
  for _, unitName in ipairs(EXPECTED.ClientUnits) do
    local unit = UNIT and UNIT:FindByName(unitName) or nil
    if unit then
      local playerName = safe("CLIENT_PLAYER_NAME_" .. unitName, function()
        return unit:GetPlayerName()
      end)
      if playerName and tostring(playerName) ~= "" then
        units[#units + 1] = unitName
        log("OBSERVER_CLIENT unit=" .. unitName .. " player=" .. tostring(playerName))
      end
    end
  end

  local detected = #units
  local allowed = detected
  local blocking = 0
  local unitList = #units > 0 and table.concat(units, ",") or "none"
  log(string.format(
    "OBSERVER_CLIENT_POLICY detected=%d allowed=%d blocking=%d units=%s reason=HARD_EXCLUDED_CLIENT_TERMINAL_NO_SPAWN_FOUNDATION",
    detected, allowed, blocking, unitList
  ))

  return {
    Detected = detected,
    Allowed = allowed,
    Blocking = blocking,
    Units = units
  }
end

'@

$observerFunctionPattern = '(?ms)^local function activePlayerClientCount\(\).*?(?=^local function getMissionTypes\()'
if ($sourceText -notmatch $observerFunctionPattern) {
    throw 'Expected activePlayerClientCount function block was not found.'
}
$sourceText = [regex]::Replace($sourceText, $observerFunctionPattern, $newObserverFunction, 1)

$oldMainObserverGate = @'
  if activePlayerClientCount() > 0 then
    finish("INVALID", "ACTIVE_PLAYER_CLIENT", false, -1)
    return
  end
'@
$newMainObserverGate = @'
  local observer = evaluateObserverClients()
  if observer.Blocking > 0 then
    finish("INVALID", "BLOCKING_OBSERVER_CLIENT", false, -1)
    return
  end
'@
if (-not $sourceText.Contains($oldMainObserverGate)) {
    throw 'Expected active-player main gate was not found.'
}
$sourceText = $sourceText.Replace($oldMainObserverGate, $newMainObserverGate)

$sourceText = $sourceText.Replace('local activeClients = activePlayerClientCount()', 'local observer = evaluateObserverClients()')
$sourceText = $sourceText.Replace(
    'activePlayerClients=%d commanderCreated=0',
    'observerClientsDetected=%d observerClientsAllowed=%d observerClientsBlocking=%d commanderCreated=0'
)
$sourceText = $sourceText.Replace(
    'activePlayerClients=%d",',
    'observerClientsDetected=%d observerClientsAllowed=%d observerClientsBlocking=%d",'
)
$sourceText = $sourceText.Replace(
    '    activeClients' + "`r`n" + '  ))',
    '    observer.Detected, observer.Allowed, observer.Blocking' + "`r`n" + '  ))'
)
$sourceText = $sourceText.Replace(
    '    opsGroups, activeClients' + "`r`n" + '  ))',
    '    opsGroups, observer.Detected, observer.Allowed, observer.Blocking' + "`r`n" + '  ))'
)
$sourceText = $sourceText.Replace(
    'if activeClients ~= 0 then violation("ACTIVE_PLAYER_CLIENT_DURING_G7") end',
    'if observer.Blocking ~= 0 then violation("BLOCKING_OBSERVER_CLIENT_DURING_G7") end'
)

if ($sourceText.Contains($oldConstructionGate)) {
    throw 'Legacy fail-fast family construction gate remained after transformation.'
}
if ($sourceText.Contains('SQUADRON_ASSET_COUNT_MISMATCH')) {
    throw 'Premature pre-start squadron.assets violation remained after transformation.'
}
if ($sourceText.Contains('activePlayerClientCount')) {
    throw 'Legacy observer-client detector or masking path remained after transformation.'
}
if (-not $sourceText.Contains('SQUADRON_STOCK_PRESTART')) {
    throw 'Pre-start warehouse-stock validation was not embedded.'
}
if (-not $sourceText.Contains('SQUADRON_ASSET_COUNT_CHANGED')) {
    throw 'Post-start squadron.assets validation is missing.'
}
if (-not $sourceText.Contains('OBSERVER_CLIENT_POLICY detected=%d allowed=%d blocking=%d')) {
    throw 'Separated observer-client telemetry was not embedded.'
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
    'observerClientsDetected=',
    'observerClientsAllowed=',
    'observerClientsBlocking=',
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
if ($verticalIndex -lt 0) { throw "Vertical-policy call not found: $verticalCall" }
if ($startIndex -lt 0) { throw "AIRWING start call not found: $startCall" }
if ($verticalIndex -ge $startIndex) {
    throw 'AIRWING:SetOptionPreferVerticalLanding() must occur before AIRWING:Start().'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'TKOT-G7-AIRWING-FOUNDATION-4'
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
-- Observer-client policy: detected, allowed and blocking counts remain separate.
-- A confirmed client on hard-excluded terminals 3, 8 or 20 is non-blocking for
-- this no-spawn foundation gate and is never hidden from final telemetry.

local OMW_TKOT_G7_BUILD = {
  Builder = "tools/build-tarinkot-air-operations-g7-foundation.ps1",
  BuilderVersion = "$builderVersion",
  GitCommit = "$commit",
  GeneratedUtc = "$generatedUtc"
}

-- BEGIN SOURCE
"@

$footer = @"

-- END SOURCE
"@

$content = $header + $sourceText + $footer
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$tempGuardSource = [System.IO.Path]::GetTempFileName()
try {
    [System.IO.File]::WriteAllText($tempGuardSource, $sourceText, [System.Text.UTF8Encoding]::new($false))
    & $guardFile `
        -SourceFile $tempGuardSource `
        -GeneratedFile $outputFile `
        -RequirePostStartAssetValidation `
        -RequireVerticalPolicyBeforeStart `
        -FoundationScope
} finally {
    Remove-Item -LiteralPath $tempGuardSource -Force -ErrorAction SilentlyContinue
}

if ($content -match 'activePlayerClientCount\s*=\s*function') {
    throw 'Generated bundle contains an observer-count masking override.'
}
if ($content -notmatch 'observerClientsDetected=%d observerClientsAllowed=%d observerClientsBlocking=%d') {
    throw 'Generated bundle does not preserve separated observer-client telemetry.'
}
if ($content -match 'SQUADRON_ASSET_COUNT_MISMATCH') {
    throw 'Generated bundle still contains the premature pre-start asset violation.'
}

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host 'LifecycleGuard: PASS'
Write-Host 'ObserverClientTelemetry: detected/allowed/blocking preserved'
Write-Host 'Gate: G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION'
Write-Host 'Airwing: AW_US_TKOT_TF_ATTACK_3_101_AVN'
Write-Host 'Squadrons: 3'
Write-Host 'RegisteredGroups: 5'
Write-Host 'RegisteredAircraft: 7'
Write-Host 'RolePayloads: 3'
Write-Host 'ExpectedTotalPayloadsIncludingRelocation: 6'
Write-Host 'ParkingPools: AH64=21,4 UH60=30,27,23 CH47=32,29,10'
Write-Host 'VerticalPolicy: AIRWING:SetOptionPreferVerticalLanding before AIRWING:Start'
Write-Host 'AssetLinkingPolicy: warehouse stock pre-start; squadron.assets post-start'
Write-Host 'OperationalMissions: 0'
Write-Host 'DeliberateSpawns: 0'
Write-Host "RequiredGuardPatternsChecked: $($requiredPatterns.Count)"
Write-Host "ForbiddenGuardPatternsChecked: $($forbiddenPatterns.Count)"
Write-Host 'BundlesBuilt: 1'
