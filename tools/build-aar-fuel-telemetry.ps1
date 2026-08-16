[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\aar-fuel-telemetry\src'
$distDir = Join-Path $repoRoot 'mission\tests\aar-fuel-telemetry\dist'
$outputFile = Join-Path $distDir 'OMW_AAR_Fuel_Telemetry.lua'

$builderVersion = 'AAR-FUEL-TELEMETRY-4'
$testId = 'AAR-FUEL-TELEMETRY-4'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$candidateSpawnSpeedKt = 480
$productionTransitRouteSpeedKt = 300
$trackApproachNm = 60
$lrcRouteBuildDelaySec = 5

$files = [ordered]@{
  CampaignState = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
  StrategicStock = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
  Initializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
  Adapter = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_CampaignStateAdapter.lua'
  RuntimeIntegration = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_RuntimeIntegration.lua'
  Controller = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_Controller.lua'
  Harness = Join-Path $sourceDir '01-aar-fuel-telemetry.lua'
}

foreach ($entry in $files.GetEnumerator()) {
  if (-not (Test-Path -LiteralPath $entry.Value -PathType Leaf)) {
    throw "Required AAR fuel-telemetry source not found: $($entry.Value)"
  }
}

& (Join-Path $repoRoot 'tools\validate-aar-production-finalization.ps1')

$content = @{}
foreach ($entry in $files.GetEnumerator()) {
  $content[$entry.Key] = Get-Content -LiteralPath $entry.Value -Raw -Encoding UTF8
}

$requirements = @(
  @{ File = 'RuntimeIntegration'; Marker = 'controller.StartContinuousCoreCoverage()' },
  @{ File = 'Controller'; Marker = 'STANDARD_TRACK_COUNT = 4' },
  @{ File = 'Controller'; Marker = 'RESERVE_TRACK_COUNT = 2' },
  @{ File = 'Controller'; Marker = 'function Controller.GetActive' },
  @{ File = 'Controller'; Marker = 'spawnToFirNm = spawnToFirNm' },
  @{ File = 'Controller'; Marker = 'firToTrackNm = firToTrackNm' },
  @{ File = 'Controller'; Marker = 'local TRANSIT_SPEED_KT = 300' },
  @{ File = 'Controller'; Marker = 'local LEG_NM = 35' },
  @{ File = 'Controller'; Marker = 'spawner:InitSpeedKnots(TRANSIT_SPEED_KT)' },
  @{ File = 'Controller'; Marker = 'mission:SetMissionIngressCoord(firIngressCoord, transit.ingressFt, TRANSIT_SPEED_KT)' },
  @{ File = 'Controller'; Marker = 'flightGroup:AddMission(mission)' },
  @{ File = 'Harness'; Marker = 'AAR-FUEL-TELEMETRY-1' },
  @{ File = 'Harness'; Marker = 'recordSpawn(record, runtime)' },
  @{ File = 'Harness'; Marker = 'fuelLowExcluded=true' },
  @{ File = 'Harness'; Marker = 'RESULT PASS allTracks=6' },
  @{ File = 'Harness'; Marker = 'unit:GetFuel()' },
  @{ File = 'Harness'; Marker = 'unit:GetCurrentFuelKgs()' },
  @{ File = 'Harness'; Marker = 'Get2DDistance' }
)

foreach ($requirement in $requirements) {
  if (-not $content[$requirement.File].Contains($requirement.Marker)) {
    throw "Missing AAR fuel-telemetry marker in $($requirement.File): $($requirement.Marker)"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  '_DATABASE',
  'mist\.',
  'MIST',
  'io\.',
  'lfs\.',
  'os\.execute',
  'runtime\.trackCoord\s*=',
  ':SetFuelLowThreshold\(',
  'fuelLowPct\s*='
)

foreach ($entry in $content.GetEnumerator()) {
  if ($entry.Key -eq 'Controller') { continue }
  foreach ($pattern in $forbiddenPatterns) {
    if ($entry.Value -match $pattern) {
      throw "Forbidden pattern in AAR fuel telemetry $($entry.Key): $pattern"
    }
  }
}

function Replace-ExactOnce {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Old,
    [Parameter(Mandatory = $true)][string]$New,
    [Parameter(Mandatory = $true)][string]$Label
  )

  $count = ([regex]::Matches($Text, [regex]::Escape($Old))).Count
  if ($count -ne 1) {
    throw "Expected exactly one '$Label' marker, found $count"
  }
  return $Text.Replace($Old, $New)
}

# Branch-local candidate only. The production controller source is deliberately not modified here.
# Test 4 restores the accepted FIR-ingress contract exactly: AUFTRAG owns EGPAN/PINAX/DAVER via
# SetMissionIngressCoord(). After MOOSE has built ingress -> mission waypoint, the adapter validates
# that route structure through public APIs and inserts only the late LRC track-approach waypoint
# between the MOOSE FIR ingress and the MOOSE mission waypoint.
$controllerCandidate = $content.Controller

$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate -Old 'local LEG_NM = 35' -New @"
local LEG_NM = 35
local TRACK_APPROACH_NM = $trackApproachNm
local LRC_ROUTE_BUILD_DELAY_SEC = $lrcRouteBuildDelaySec
"@ -Label 'LRC constants'

$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '  MANAS_WEST_HIGH = { ingressFt = 34000, egressFt = 33000 },' `
  -New '  MANAS_WEST_HIGH = { ingressFt = 34000, egressFt = 35000 },' `
  -Label 'MANAS_WEST_HIGH transit altitude'
$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '  MANAS_EAST_HIGH = { ingressFt = 33000, egressFt = 34000 },' `
  -New '  MANAS_EAST_HIGH = { ingressFt = 34000, egressFt = 35000 },' `
  -Label 'MANAS_EAST_HIGH transit altitude'
$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '  AL_UDEID_NORTH_HIGH = { ingressFt = 33000, egressFt = 34000 },' `
  -New '  AL_UDEID_NORTH_HIGH = { ingressFt = 35000, egressFt = 34000 },' `
  -Label 'AL_UDEID_NORTH_HIGH transit altitude'

$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '  spawner:InitSpeedKnots(TRANSIT_SPEED_KT)' `
  -New "  spawner:InitSpeedKnots($candidateSpawnSpeedKt)" `
  -Label 'candidate KC-135 spawn speed'

$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '  local trackCoord = COORDINATE:NewFromLLDD(areaSpec.lat, areaSpec.lon)' `
  -New @"
  local trackCoord = COORDINATE:NewFromLLDD(areaSpec.lat, areaSpec.lon)
  local firToTrackMeters = firIngressCoord:Get2DDistance(trackCoord)
  local trackApproachMeters = UTILS.NMToMeters(TRACK_APPROACH_NM)
  if firToTrackMeters <= trackApproachMeters then
    fail(string.format("LRC track approach exceeds FIR-to-track leg area=%s firFix=%s firToTrackNm=%.1f approachNm=%.1f",
      selection.area, areaSpec.firFix, firToTrackMeters / 1852, TRACK_APPROACH_NM))
  end
  local trackApproachCoord = trackCoord:GetIntermediateCoordinate(firIngressCoord, trackApproachMeters)
  trackApproachCoord:SetAltitude(UTILS.FeetToMeters(transit.ingressFt), true)
"@ -Label 'late track-approach coordinate'

# Preserve the accepted MOOSE FIR-ingress contract. Only correct the mission waypoint altitude.
$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '  mission:SetMissionIngressCoord(firIngressCoord, transit.ingressFt, TRANSIT_SPEED_KT)' `
  -New @"
  mission:SetMissionIngressCoord(firIngressCoord, transit.ingressFt, TRANSIT_SPEED_KT)
  mission:SetMissionAltitude(profile.altitudeFt)
"@ -Label 'preserved FIR mission ingress and exact mission waypoint altitude'

$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '    externalHandoffCoord = externalHandoffCoord, trackCoord = trackCoord,' `
  -New '    externalHandoffCoord = externalHandoffCoord, trackCoord = trackCoord, trackApproachCoord = trackApproachCoord,' `
  -Label 'runtime track approach coordinate'

$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '    externalHandoffRouted = false, stationIdentityActive = false, onStationAt = nil, materializedAt = now(),' `
  -New '    externalHandoffRouted = false, lateApproachWaypointInjected = false, stationIdentityActive = false, onStationAt = nil, materializedAt = now(),' `
  -Label 'runtime late-approach injection state'

$injectHelper = @'
local function injectLateTrackApproachWaypoint(runtime)
  if not runtime or runtime.lossHandled or runtime.egressOrdered or runtime.lateApproachWaypointInjected then return end
  local flightGroup = runtime.flightGroup
  local mission = runtime.mission
  if not flightGroup or not flightGroup:IsAlive() then
    log(string.format("LRC_LATE_APPROACH_SKIPPED runtime=%s reason=FLIGHT_NOT_ALIVE",
      runtime and tostring(runtime.runtimeId) or "UNKNOWN"))
    return
  end
  if not mission then
    fail("LRC late-approach injection has no mission runtime=" .. tostring(runtime.runtimeId))
  end

  -- MOOSE RouteToMission() builds FLIGHTGROUP air routes in this order when an ingress exists:
  -- ingress waypoint -> mission waypoint -> optional egress waypoint. Resolve that structure through
  -- public getters instead of relying on the last-passed/current waypoint.
  local missionWaypointUid = mission:GetGroupWaypointIndex(flightGroup)
  if not missionWaypointUid then
    fail("LRC late-approach injection has no MOOSE mission waypoint UID runtime=" .. tostring(runtime.runtimeId))
  end

  local missionWaypointIndex = flightGroup:GetWaypointIndex(missionWaypointUid)
  if not missionWaypointIndex or missionWaypointIndex <= 1 then
    fail(string.format("LRC late-approach injection cannot resolve mission waypoint runtime=%s uid=%s index=%s",
      tostring(runtime.runtimeId), tostring(missionWaypointUid), tostring(missionWaypointIndex)))
  end

  local ingressWaypointIndex = missionWaypointIndex - 1
  local ingressWaypointUid = flightGroup:GetWaypointID(ingressWaypointIndex)
  local ingressWaypointCoord = flightGroup:GetWaypointCoordinate(ingressWaypointIndex)
  if not ingressWaypointUid or not ingressWaypointCoord then
    fail(string.format("LRC late-approach injection cannot resolve MOOSE ingress waypoint runtime=%s missionIndex=%d",
      tostring(runtime.runtimeId), missionWaypointIndex))
  end

  -- Do not modify the route unless the preceding MOOSE waypoint is the configured published FIR fix.
  local ingressDeltaNm = ingressWaypointCoord:Get2DDistance(runtime.firIngressCoord) / 1852
  if ingressDeltaNm > 0.5 then
    fail(string.format("LRC late-approach FIR contract mismatch runtime=%s area=%s fix=%s deltaNm=%.3f",
      tostring(runtime.runtimeId), tostring(runtime.selection.area), tostring(runtime.firFixName), ingressDeltaNm))
  end

  local waypoint = flightGroup:AddWaypoint(
    runtime.trackApproachCoord,
    TRANSIT_SPEED_KT,
    ingressWaypointUid,
    runtime.transit.ingressFt,
    true
  )
  if not waypoint then
    fail("LRC late-approach waypoint insertion failed runtime=" .. tostring(runtime.runtimeId))
  end

  runtime.lateApproachWaypoint = waypoint
  runtime.lateApproachWaypointInjected = true
  log(string.format(
    "LRC_LATE_APPROACH_INSERTED runtime=%s area=%s firFix=%s ingressDeltaNm=%.3f approachNm=%.1f ingressUid=%s approachUid=%s missionUid=%s",
    runtime.runtimeId, runtime.selection.area, runtime.firFixName, ingressDeltaNm, TRACK_APPROACH_NM,
    tostring(ingressWaypointUid), tostring(waypoint.uid), tostring(missionWaypointUid)))
end

'@
$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old 'local function materialize(request)' `
  -New ($injectHelper + 'local function materialize(request)') `
  -Label 'late track-approach waypoint injection helper'

$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '  flightGroup:AddMission(mission)' `
  -New @"
  flightGroup:AddMission(mission)
  flightGroup:ScheduleOnce(LRC_ROUTE_BUILD_DELAY_SEC, injectLateTrackApproachWaypoint, runtime)
"@ -Label 'scheduled late track-approach insertion'

$harnessCandidate = Replace-ExactOnce -Text $content.Harness -Old 'AAR-FUEL-TELEMETRY-1' -New $testId -Label 'AAR telemetry test ID'

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-aar-fuel-telemetry.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: branch-local KC-135 LRC transit candidate plus SPAWN/INGRESS/TRACK fuel telemetry for all six AAR tracks.
-- CandidateSpawnSpeedKt: $candidateSpawnSpeedKt
-- ProductionTransitRouteSpeedKt: $productionTransitRouteSpeedKt
-- CandidateTransitLevels: MANAS inbound FL340 / outbound FL350; AL_UDEID inbound FL350 / outbound FL340.
-- CandidateTrackApproachNm: $trackApproachNm
-- CandidateIngressContract: preserve AUFTRAG:SetMissionIngressCoord(EGPAN/PINAX/DAVER) exactly as the accepted production path.
-- CandidateRouting: after MOOSE builds FIR ingress -> mission waypoint, validate the FIR waypoint and insert only the late track approach after it.
-- CandidateMissionAltitude: AUFTRAG:SetMissionAltitude(track altitude) suppresses the default ORBIT 90-percent mission-waypoint altitude.
-- CandidateScope: generated test bundle only; production controller source, production fuel and FuelLow remain unchanged.
-- FuelLow is intentionally excluded from telemetry because the threshold remains subject to recalibration.
-- No automated MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$bundle = $header
$bundle += "local OMW_AAR_TEST_CampaignState = (function()`n" + $content.CampaignState + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_StrategicStock = (function()`n" + $content.StrategicStock + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Initializer = (function()`n" + $content.Initializer + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Adapter = (function()`n" + $content.Adapter + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_RuntimeIntegration = (function()`n" + $content.RuntimeIntegration + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Controller = (function()`n" + $controllerCandidate + "`nend)()`n"
$bundle += $harnessCandidate + "`n"

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host 'FuelPoints: SPAWN,INGRESS,TRACK'
Write-Host 'FuelLowIncluded: false'
Write-Host "CandidateSpawnSpeedKt: $candidateSpawnSpeedKt"
Write-Host "ProductionTransitRouteSpeedKt: $productionTransitRouteSpeedKt"
Write-Host 'CandidateManasIngressFt: 34000'
Write-Host 'CandidateManasEgressFt: 35000'
Write-Host 'CandidateAlUdeidIngressFt: 35000'
Write-Host 'CandidateAlUdeidEgressFt: 34000'
Write-Host "CandidateTrackApproachNm: $trackApproachNm"
Write-Host 'CandidateMissionAltitudeMode: EXACT_TRACK_ALTITUDE'
Write-Host 'CandidateIngressContract: PRESERVED_MOOSE_FIR_INGRESS'
Write-Host 'CandidateFirRouting: MOOSE_FIR_INGRESS_THEN_LATE_APPROACH'
Write-Host 'CandidateScope: SPAWN_SPEED_AND_LRC_ROUTE'
Write-Host 'StandardTracks: 4'
Write-Host 'ReserveTracks: 2'
Write-Host 'PollSeconds: 1'
Write-Host 'MizMutation: false'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"

foreach ($entry in $files.GetEnumerator()) {
  $hash = (Get-FileHash -LiteralPath $entry.Value -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Host "$($entry.Key)SHA256: $hash"
}

$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "BundleSHA256: $bundleHash"
