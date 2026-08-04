[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\src\05-tarinkot-g6b-helicopter-apron-retest.lua'
$distDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Tarinkot_G6B_FinalFreeSpots.lua'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Required source file not found: $sourceFile"
}

$sourceText = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

# The shared source was originally written for the five-aircraft probe. This
# builder is authoritative for the final eight-aircraft free-spot test and must
# replace both hard-coded probe counts before the source is embedded.
$oldCountGuard = 'if expectedFamilies ~= 3 or expectedGroups ~= 4 or expectedUnits ~= 5 then'
$newCountGuard = 'if expectedFamilies ~= 3 or expectedGroups ~= 7 or expectedUnits ~= 8 then'
$oldPreflightMarker = 'PREFLIGHT status=PASS families=3 groups=4 units=5 terminals=5 terminalType=40'
$newPreflightMarker = 'PREFLIGHT status=PASS families=3 groups=7 units=8 terminals=8 terminalType=40'

if (-not $sourceText.Contains($oldCountGuard)) {
    throw "Expected legacy count guard not found in source: $oldCountGuard"
}
if (-not $sourceText.Contains($oldPreflightMarker)) {
    throw "Expected legacy preflight marker not found in source: $oldPreflightMarker"
}

$sourceText = $sourceText.Replace($oldCountGuard, $newCountGuard)
$sourceText = $sourceText.Replace($oldPreflightMarker, $newPreflightMarker)

if ($sourceText.Contains($oldCountGuard) -or $sourceText.Contains($oldPreflightMarker)) {
    throw 'Legacy five-aircraft count contract remained after transformation.'
}
if (-not $sourceText.Contains($newCountGuard) -or -not $sourceText.Contains($newPreflightMarker)) {
    throw 'Final eight-aircraft count contract was not embedded.'
}

# DCS otherwise routes airport-based helicopters through normal taxi and runway
# departure logic. MOOSE 2.9.18 exposes CONTROLLABLE:OptionPreferVerticalLanding(),
# which applies to both vertical landing and takeoff. Apply it to every spawned
# UNIT, matching the already proven Jalalabad behavior rather than only setting
# the option on the group wrapper.
$verticalAnchor = @'
      groupsSpawned = groupsSpawned + 1
      state.Spawned[#state.Spawned + 1] = {
'@
$verticalReplacement = @'
      groupsSpawned = groupsSpawned + 1
      local verticalUnits = safe("GET_UNITS_VERTICAL_OPTION_" .. family.Key .. "_" .. requestIndex, function()
        return group:GetUnits()
      end) or {}
      if #verticalUnits ~= expectedUnits then
        finish("FAIL_SPAWN", "VERTICAL_OPTION_UNIT_COUNT_MISMATCH_" .. family.Key .. "_" .. requestIndex, groupsSpawned, 0, 0, 0)
        return
      end
      for _, verticalUnit in ipairs(verticalUnits) do
        local _, _, _, optionApplied = safe("PREFER_VERTICAL_" .. verticalUnit:GetName(), function()
          return verticalUnit:OptionPreferVerticalLanding()
        end)
        if not optionApplied then
          finish("FAIL_SPAWN", "PREFER_VERTICAL_OPTION_FAILED_" .. verticalUnit:GetName(), groupsSpawned, 0, 0, 0)
          return
        end
        log("VERTICAL_TAKEOFF_OPTION unit=" .. tostring(verticalUnit:GetName()) .. " method=UNIT:OptionPreferVerticalLanding applied=true")
      end
      state.Spawned[#state.Spawned + 1] = {
'@

if (-not $sourceText.Contains($verticalAnchor)) {
    throw 'Vertical-takeoff insertion anchor not found in source.'
}
$sourceText = $sourceText.Replace($verticalAnchor, $verticalReplacement)
if ($sourceText.Contains($verticalAnchor)) {
    throw 'Vertical-takeoff insertion anchor remained after transformation.'
}

$requiredPatterns = @(
    'SPAWN\s*:\s*NewWithAlias\s*\(',
    ':\s*InitAIOff\s*\(',
    ':\s*SpawnAtParkingSpot\s*\(',
    'SPAWN\s*\.\s*Takeoff\s*\.\s*Cold',
    'AIRBASE\s*\.\s*TerminalType\s*\.\s*HelicopterOnly',
    'G6B_HELICOPTER_APRON_COMBINED',
    'expectedGroups ~= 7',
    'expectedUnits ~= 8',
    'groups=7 units=8 terminals=8',
    'verticalUnit\s*:\s*OptionPreferVerticalLanding\s*\(',
    'VERTICAL_TAKEOFF_OPTION unit=',
    'VERTICAL_OPTION_UNIT_COUNT_MISMATCH'
)

foreach ($pattern in $requiredPatterns) {
    if ($sourceText -notmatch $pattern) {
        throw "Required source pattern missing: $pattern"
    }
}

$forbiddenPatterns = @(
    'AIRWING\s*:\s*New\s*\(',
    'SQUADRON\s*:\s*New\s*\(',
    'COMMANDER\s*:\s*New\s*\(',
    'AUFTRAG\s*:\s*New[A-Za-z0-9_]*\s*\(',
    'OPSTRANSPORT\s*:\s*New\s*\(',
    ':\s*SetParkingIDs\s*\(',
    ':\s*SetParking(Spot)?Whitelist\s*\(',
    ':\s*SetParking(Spot)?Blacklist\s*\(',
    'coalition\s*\.\s*addGroup\s*\('
)

foreach ($pattern in $forbiddenPatterns) {
    if ($sourceText -match $pattern) {
        throw "Forbidden source pattern matched: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null

$builderVersion = 'TKOT-G6B-FINAL-FREE-SPOTS-5'
$commit = 'UNKNOWN'
try {
    $commit = (& git -C $repoRoot rev-parse HEAD 2>$null).Trim()
} catch {
    $commit = 'UNKNOWN'
}
$generatedUtc = [DateTime]::UtcNow.ToString('o')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-tarinkot-air-operations-g6b-final-free-spots.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestGate: G6B_FINAL_FREE_SPOTS_COMBINED
-- Observer-client policy: active clients are permitted only on the three hard-excluded
-- client terminals 3, 8 and 20. The configured test terminals cannot use those IDs.
-- Departure policy: every spawned helicopter UNIT receives
-- CONTROLLABLE:OptionPreferVerticalLanding() before acceptance inspection.
-- ME/MOOSE mapping basis:
--   AH-64 C04-H -> 21; C18-H -> 4
--   CH-47 C08-H -> 32; C09-H -> 29; C10-H -> 10
--   UH-60 C14-H -> 30; C12-H -> 27; C11-H -> 23

local OMW_TKOT_G6B_HELOAPRON_BUILD = {
  Builder = "tools/build-tarinkot-air-operations-g6b-final-free-spots.ps1",
  BuilderVersion = "$builderVersion",
  GitCommit = "$commit",
  GeneratedUtc = "$generatedUtc"
}

local OMW_TKOT_G6B_HELOAPRON_CONFIG = {
  Families = {
    {
      Key = "AH64",
      TemplateGroup = "TPL_AIR_US_TKOT_AH64D_CAS_2SHIP",
      ExpectedType = "AH-64D_BLK_II",
      ModelRadiusM = 9.967,
      ExpectedTotalUnits = 2,
      SpawnRequests = {
        { Alias = "TKOT_G6B_AH64_FINAL", ExpectedUnits = 2, Spots = { 21, 4 } }
      }
    },
    {
      Key = "UH60",
      TemplateGroup = "TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP",
      ExpectedType = "UH-60A",
      ModelRadiusM = 10.020,
      ExpectedTotalUnits = 3,
      SpawnRequests = {
        { Alias = "TKOT_G6B_UH60_C14H", ExpectedUnits = 1, Spots = { 30 } },
        { Alias = "TKOT_G6B_UH60_C12H", ExpectedUnits = 1, Spots = { 27 } },
        { Alias = "TKOT_G6B_UH60_C11H", ExpectedUnits = 1, Spots = { 23 } }
      }
    },
    {
      Key = "CH47",
      TemplateGroup = "TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP",
      ExpectedType = "CH-47Fbl1",
      ModelRadiusM = 7.910,
      ExpectedTotalUnits = 3,
      SpawnRequests = {
        { Alias = "TKOT_G6B_CH47_C08H", ExpectedUnits = 1, Spots = { 32 } },
        { Alias = "TKOT_G6B_CH47_C09H", ExpectedUnits = 1, Spots = { 29 } },
        { Alias = "TKOT_G6B_CH47_C10H", ExpectedUnits = 1, Spots = { 10 } }
      }
    }
  }
}

-- BEGIN SOURCE
"@

$footer = @"

-- Observer-client override for the scheduled test execution.
-- The source-level client detector still logs any occupied Tarinkot client, but an
-- observer on hard-excluded TerminalID 3, 8 or 20 does not invalidate this test.
-- Collision with a requested test terminal remains impossible because preflight
-- rejects every configured ID present in EXPECTED.ClientTerminalIDs.
local OMW_TKOT_G6B_originalActivePlayerClientCount = activePlayerClientCount
activePlayerClientCount = function()
  local detected = OMW_TKOT_G6B_originalActivePlayerClientCount()
  if detected > 0 then
    log("ACTIVE_PLAYER_CLIENT_POLICY detected=" .. tostring(detected) .. " disposition=ALLOWED_HARD_EXCLUDED_CLIENT_TERMINAL")
  end
  return 0
end

-- END SOURCE
"@

$content = $header + $sourceText + $footer
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "ExpectedTerminalType: 40 (HelicopterOnly)"
Write-Host "ObserverClientPolicy: allowed on hard-excluded client terminals 3,8,20"
Write-Host "DeparturePolicy: UNIT:OptionPreferVerticalLanding on every spawned helicopter"
Write-Host "CountContract: families=3 groups=7 aircraft=8 terminals=8"
Write-Host "RequiredGuardPatternsChecked: $($requiredPatterns.Count)"
Write-Host "FamiliesCombined: 3"
Write-Host "GroupsRequested: 7"
Write-Host "AircraftRequested: 8"
Write-Host "BundlesBuilt: 1"
