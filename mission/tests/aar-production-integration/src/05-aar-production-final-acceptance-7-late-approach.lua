local TEST_ID = "AAR-PRODUCTION-FINAL-ACCEPTANCE-7"
local TAG = "[OMW][" .. TEST_ID .. "][LateApproach]"
local POLL_SEC = 5
local TIMEOUT_SEC = 12 * 60 * 60
local HIGH_HOLD_MIN_NM = 65
local HIGH_HOLD_MAX_NM = 85
local HIGH_HOLD_ALT_TOLERANCE_FT = 2000
local TRACK_ALT_TOLERANCE_FT = 1500

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message))
  error(TAG .. " " .. tostring(message), 2)
end

local function assertTrue(condition, message)
  if not condition then fail(message) end
end

local function assertEqual(actual, expected, label)
  if actual ~= expected then
    fail(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual)))
  end
end

local config = OMW.AAR.GetConfig()
assertEqual(config.lateApproachNm, 60, "config.lateApproachNm")
assertEqual(config.sourceDomainByArea.LISA, "AL_UDEID", "config.sourceDomain.LISA")
assertEqual(config.firFixByArea.LISA, "DAVER", "config.firFix.LISA")
assertEqual(config.initialFuelPctByArea.LISA, 79.4558, "config.initialFuelPct.LISA")
assertEqual(config.fuelLowPctByArea.LISA, 38, "config.fuelLowPct.LISA")

local targets = {
  NELSON = { profile = "FAST", source = "MANAS", firFix = "EGPAN" },
  PATTY = { profile = "SLOW", source = "MANAS", firFix = "EGPAN" },
  KRUSTY = { profile = "SLOW", source = "AL_UDEID", firFix = "DAVER" },
  MILHOUSE = { profile = "SLOW", source = "AL_UDEID", firFix = "DAVER" },
  LISA = { profile = "FAST", source = "AL_UDEID", firFix = "DAVER" },
}

local observed = {}
for area in pairs(targets) do
  observed[area] = { highHold = false, trackAltitude = false, runtimeId = nil }
end

local startedAt = timer.getAbsTime()

local function altitudeFt(runtime)
  local coordinate = runtime and runtime.flightGroup and runtime.flightGroup:GetCoordinate() or nil
  return coordinate and UTILS.MetersToFeet(coordinate.y) or nil
end

local function distanceToTrackNm(runtime)
  local coordinate = runtime and runtime.flightGroup and runtime.flightGroup:GetCoordinate() or nil
  return coordinate and coordinate:Get2DDistance(runtime.trackCoord) / 1852 or nil
end

local function inspectRuntime(area, runtime)
  if not runtime or runtime.egressOrdered or runtime.lossHandled or not runtime.flightGroup:IsAlive() then return end
  local spec = targets[area]
  local state = observed[area]

  assertEqual(runtime.selection.sourceDomain, spec.source, area .. ".sourceDomain")
  assertEqual(runtime.firFixName, spec.firFix, area .. ".firFix")
  assertEqual(runtime.lateApproachNm, 60, area .. ".lateApproachNm")
  assertTrue(runtime.lateApproachCoord ~= nil, area .. " lateApproachCoord missing")

  local lateDistanceNm = runtime.lateApproachCoord:Get2DDistance(runtime.trackCoord) / 1852
  assertTrue(math.abs(lateDistanceNm - 60) <= 0.25,
    string.format("%s late approach geometry invalid distanceNm=%.3f", area, lateDistanceNm))

  local distanceNm = distanceToTrackNm(runtime)
  local altFt = altitudeFt(runtime)
  if not distanceNm or not altFt then return end

  if runtime.firIngressPassed and not state.highHold
      and distanceNm >= HIGH_HOLD_MIN_NM and distanceNm <= HIGH_HOLD_MAX_NM then
    local delta = math.abs(altFt - runtime.transit.ingressFt)
    assertTrue(delta <= HIGH_HOLD_ALT_TOLERANCE_FT,
      string.format("%s descended before 60-NM late approach distanceNm=%.1f altitudeFt=%.0f expectedTransitFt=%d deltaFt=%.0f",
        area, distanceNm, altFt, runtime.transit.ingressFt, delta))
    state.highHold = true
    state.runtimeId = runtime.runtimeId
    log(string.format("HIGH_HOLD_PASS area=%s runtime=%s distanceToTrackNm=%.1f altitudeFt=%.0f transitFt=%d lateApproachNm=60",
      area, runtime.runtimeId, distanceNm, altFt, runtime.transit.ingressFt))
  end

  if state.highHold and not state.trackAltitude and runtime.onStationAt then
    local delta = math.abs(altFt - runtime.profile.altitudeFt)
    assertTrue(delta <= TRACK_ALT_TOLERANCE_FT,
      string.format("%s track altitude mismatch altitudeFt=%.0f expectedTrackFt=%d deltaFt=%.0f",
        area, altFt, runtime.profile.altitudeFt, delta))
    state.trackAltitude = true
    log(string.format("TRACK_ALTITUDE_PASS area=%s runtime=%s altitudeFt=%.0f trackFt=%d",
      area, runtime.runtimeId, altFt, runtime.profile.altitudeFt))
  end
end

local function complete()
  for area in pairs(targets) do
    if not observed[area].highHold or not observed[area].trackAltitude then return false end
  end
  return true
end

log("CONFIG_PASS lateApproachNm=60 LISA_source=AL_UDEID LISA_firFix=DAVER LISA_initialFuelPct=79.4558 LISA_fuelLowPct=38")

SCHEDULER:New(nil, function()
  if timer.getAbsTime() - startedAt > TIMEOUT_SEC then
    local missing = {}
    for area, state in pairs(observed) do
      if not state.highHold or not state.trackAltitude then
        missing[#missing + 1] = string.format("%s(highHold=%s,trackAltitude=%s)", area,
          tostring(state.highHold), tostring(state.trackAltitude))
      end
    end
    fail("TIMEOUT missing=" .. table.concat(missing, ","))
  end

  for area, spec in pairs(targets) do
    local station = OMW.AAR.GetStation(area, spec.profile)
    if station then
      inspectRuntime(area, station.activeRuntime)
      inspectRuntime(area, station.reliefRuntime)
    end
  end

  if complete() then
    log("LATE_APPROACH_PASS areas=NELSON,PATTY,KRUSTY,MILHOUSE,LISA highHoldBefore60Nm=true exactTrackAltitude=true LISA_southDomain=true")
    log("RESULT PASS")
    return false
  end
end, {}, 0, POLL_SEC)
