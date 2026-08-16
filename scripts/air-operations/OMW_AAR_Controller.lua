-- Operation Mountain Watch - production AAR demand and tanker lifecycle controller.
--
-- MOOSE-first boundary:
--   * OMW maintains four standard AAR tracks and two demand-driven reserve tracks.
--   * MOOSE SPAWN/FLIGHTGROUP/AUFTRAG/SCHEDULER execute the physical lifecycle.
--   * OMW orchestrates track ownership, relief timing, stable sortie identity and FIR/off-map routing.
--   * CampaignState remains the strategic availability authority through the injected adapter.

OMW = OMW or {}

local Controller = {}

local TAG = "[OMW][AAR.Controller]"
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"
local SOURCE_SPAWN_INTERVAL_SEC = 60
local HANDOFF_RADIUS_NM = 10
local FIR_FIX_RADIUS_NM = 5
local TRACK_ENTRY_RADIUS_NM = 5
local DISPATCH_INTERVAL_SEC = 5
local SPAWN_INITIAL_SPEED_KT = 480
local TRANSIT_SPEED_KT = 300
local LATE_APPROACH_NM = 60
local LEG_NM = 35
local STATION_CYCLE_SEC = 3 * 60 * 60
local RELIEF_HANDOVER_ETA_SEC = 5 * 60
local STANDARD_TRACK_COUNT = 4
local RESERVE_TRACK_COUNT = 2
local MAX_AIRCRAFT_PER_TRACK = 2

local EXTERNAL_POINTS = {
  MANAS = { lat = 38.83163, lon = 70.95271 },
  AL_UDEID = { lat = 28.90264890, lon = 64.61166667 },
}

local FIR_FIXES = {
  EGPAN = { lat = 38.41666667, lon = 70.73333333 },
  PINAX = { lat = 37.25000000, lon = 69.10000000 },
  DAVER = { lat = 29.57166667, lon = 64.67666667 },
}

local TRANSIT = {
  MANAS_WEST_HIGH = { ingressFt = 34000, egressFt = 35000 },
  MANAS_EAST_HIGH = { ingressFt = 34000, egressFt = 35000 },
  AL_UDEID_NORTH_HIGH = { ingressFt = 35000, egressFt = 34000 },
}

local AREAS = {
  LISA = {
    template = "OMW_AAR_KC135_LISA",
    callsignId = CALLSIGN.Tanker.Texaco, callsignName = "Texaco", callsignNumber = 3,
    lat = 33.66624916, lon = 61.81294477, headingDeg = 4.269,
    sourceDomain = "AL_UDEID", transitProfile = "AL_UDEID_NORTH_HIGH", firFix = "DAVER",
    availability = "RESERVE", coreProfile = "FAST",
    frequencyMHz = 235.900, tacanChannel = 50, tacanIdent = "LIS",
    fuelLowPct = 38, initialFuelPct = 79.4558,
    profiles = { SLOW = { altitudeFt = 22000, speedKt = 220 }, FAST = { altitudeFt = 25000, speedKt = 300 } },
  },
  MOE = {
    template = "OMW_AAR_KC135_MOE",
    callsignId = CALLSIGN.Tanker.Texaco, callsignName = "Texaco", callsignNumber = 4,
    lat = 35.07603944, lon = 65.32603438, headingDeg = 304.682,
    sourceDomain = "MANAS", transitProfile = "MANAS_WEST_HIGH", firFix = "PINAX",
    availability = "RESERVE", coreProfile = "FAST",
    frequencyMHz = 243.400, tacanChannel = 52, tacanIdent = "MOE",
    fuelLowPct = 31, initialFuelPct = 91.4067,
    profiles = { SLOW = { altitudeFt = 24000, speedKt = 220 }, FAST = { altitudeFt = 27000, speedKt = 300 } },
  },
  MILHOUSE = {
    template = "OMW_AAR_KC135_MILHOUSE",
    callsignId = CALLSIGN.Tanker.Shell, callsignName = "Shell", callsignNumber = 2,
    lat = 33.44219603, lon = 65.46466360, headingDeg = 63.607,
    sourceDomain = "AL_UDEID", transitProfile = "AL_UDEID_NORTH_HIGH", firFix = "DAVER",
    availability = "STANDARD", coreProfile = "SLOW",
    frequencyMHz = 272.600, tacanChannel = 58, tacanIdent = "MIL",
    fuelLowPct = 36, initialFuelPct = 79.4558,
    profiles = { SLOW = { altitudeFt = 22000, speedKt = 220 } },
  },
  KRUSTY = {
    template = "OMW_AAR_KC135_KRUSTY",
    callsignId = CALLSIGN.Tanker.Arco, callsignName = "Arco", callsignNumber = 2,
    lat = 32.65123012, lon = 68.15946309, headingDeg = 212.350,
    sourceDomain = "AL_UDEID", transitProfile = "AL_UDEID_NORTH_HIGH", firFix = "DAVER",
    availability = "STANDARD", coreProfile = "SLOW",
    frequencyMHz = 258.300, tacanChannel = 42, tacanIdent = "KRU",
    fuelLowPct = 36, initialFuelPct = 79.4558,
    profiles = { SLOW = { altitudeFt = 22000, speedKt = 220 } },
  },
  PATTY = {
    template = "OMW_AAR_KC135_PATTY",
    callsignId = CALLSIGN.Tanker.Texaco, callsignName = "Texaco", callsignNumber = 2,
    lat = 34.97134133, lon = 71.47789605, headingDeg = 89.662,
    sourceDomain = "MANAS", transitProfile = "MANAS_EAST_HIGH", firFix = "EGPAN",
    availability = "STANDARD", coreProfile = "SLOW",
    frequencyMHz = 237.300, tacanChannel = 48, tacanIdent = "PAT",
    fuelLowPct = 26, initialFuelPct = 91.4067,
    profiles = { SLOW = { altitudeFt = 24000, speedKt = 220 } },
  },
  NELSON = {
    template = "OMW_AAR_KC135_NELSON",
    callsignId = CALLSIGN.Tanker.Texaco, callsignName = "Texaco", callsignNumber = 1,
    lat = 36.37666667, lon = 71.01833333, headingDeg = 10.428,
    sourceDomain = "MANAS", transitProfile = "MANAS_EAST_HIGH", firFix = "EGPAN",
    availability = "STANDARD", coreProfile = "FAST",
    frequencyMHz = 384.400, tacanChannel = 47, tacanIdent = "NEL",
    fuelLowPct = 24, initialFuelPct = 91.4067,
    profiles = { FAST = { altitudeFt = 27500, speedKt = 300 } },
  },
}

local STANDARD_AREA_ORDER = { "NELSON", "KRUSTY", "PATTY", "MILHOUSE" }

local state = {
  strategicAdapter = nil,
  queue = {},
  stationsByKey = {},
  runtimesById = {},
  lastSpawnAtBySource = {},
  spawnersByArea = {},
  callsignInUse = {},
  dispatcher = nil,
  stationMonitor = nil,
  nextRuntimeId = 0,
  continuousCoreStarted = false,
}

local ensureRelief
local handleRuntimeLoss

local function log(message) env.info(TAG .. " " .. tostring(message)) end
local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function now() return timer.getAbsTime() end

local function requireString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

local function requireMoose()
  if not SPAWN or not FLIGHTGROUP or not AUFTRAG or not COORDINATE or not SCHEDULER or not UTILS then
    fail("required MOOSE classes are unavailable")
  end
  if not CALLSIGN or not CALLSIGN.Tanker then fail("required MOOSE tanker callsign enumerator is unavailable") end
  if not Unit or not Unit.RefuelingSystem or Unit.RefuelingSystem.BOOM_AND_RECEPTACLE == nil then
    fail("DCS refueling-system enum is unavailable")
  end
end

local function normalizeDemand(demand)
  if type(demand) ~= "table" then fail("MissionDemand must be a table") end
  return {
    missionDemandId = requireString(demand.missionDemandId, "missionDemandId"),
    receiverProfile = requireString(demand.receiverProfile, "receiverProfile"):upper(),
    operationsArea = requireString(demand.operationsArea, "operationsArea"):upper(),
    supportMode = requireString(demand.supportMode, "supportMode"):upper(),
    priority = demand.priority,
  }
end

local function trackSelection(area, missionDemandId)
  local areaSpec = AREAS[area]
  if not areaSpec then fail("unknown AAR area=" .. tostring(area)) end
  local profile = areaSpec.coreProfile
  if not areaSpec.profiles[profile] then fail("missing profile for area=" .. tostring(area)) end
  local continuous = areaSpec.availability == "STANDARD"
  return {
    missionDemandId = missionDemandId or (continuous and ("AAR-CORE-" .. area) or ("AAR-RESERVE-" .. area)),
    receiverProfile = profile,
    requestedReceiverProfile = profile,
    operationsArea = continuous and "CORE" or "RESERVE",
    supportMode = continuous and "CONTINUOUS" or "DEMAND",
    priority = continuous and "CORE_CONTINUOUS" or "RESERVE_DEMAND",
    area = area,
    sourceDomain = areaSpec.sourceDomain,
    transitProfile = areaSpec.transitProfile,
    firFix = areaSpec.firFix,
    continuousCore = continuous,
    availability = areaSpec.availability,
  }
end

function Controller.SelectArea(demand)
  local d = normalizeDemand(demand)
  local area
  if d.operationsArea == "EAST" and d.supportMode == "SUPPORT" and d.receiverProfile == "SLOW" then area = "PATTY"
  elseif d.operationsArea == "SOUTH_CENTRAL" and d.supportMode == "RECOVERY" and d.receiverProfile == "SLOW" then area = "MILHOUSE"
  elseif d.operationsArea == "SOUTHEAST" and d.supportMode == "RECOVERY" and d.receiverProfile == "SLOW" then area = "KRUSTY"
  elseif d.operationsArea == "NORTHEAST" and d.supportMode == "SUPPORT" and d.receiverProfile == "FAST" then area = "NELSON"
  elseif d.operationsArea == "CENTRAL" then area = "MOE"
  elseif d.operationsArea == "WEST" then area = "LISA"
  else
    return nil, string.format("NO_AAR_POLICY receiverProfile=%s operationsArea=%s supportMode=%s", d.receiverProfile, d.operationsArea, d.supportMode)
  end

  local areaSpec = AREAS[area]
  local trackProfile = areaSpec.coreProfile
  if d.receiverProfile ~= trackProfile then
    return nil, string.format("TRACK_PROFILE_MISMATCH area=%s requested=%s trackProfile=%s", area, d.receiverProfile, trackProfile)
  end

  local selection = trackSelection(area, d.missionDemandId)
  selection.requestedReceiverProfile = d.receiverProfile
  selection.operationsArea = d.operationsArea
  selection.supportMode = d.supportMode
  selection.priority = d.priority
  return selection
end

function Controller.SetStrategicAdapter(adapter)
  if type(adapter) ~= "table" or type(adapter.CanMaterialize) ~= "function"
      or type(adapter.OnMaterialized) ~= "function" or type(adapter.OnHandoff) ~= "function"
      or type(adapter.OnLost) ~= "function" then
    fail("strategic adapter requires CanMaterialize, OnMaterialized, OnHandoff and OnLost")
  end
  state.strategicAdapter = adapter
  return Controller
end

local function activeKey(selection) return selection.area .. ":" .. selection.receiverProfile end

local function getOrCreateStation(selection)
  local key = activeKey(selection)
  local station = state.stationsByKey[key]
  if not station then
    station = {
      key = key,
      selection = selection,
      demandsById = {},
      continuousCore = selection.continuousCore == true,
      closed = false,
      closedReason = nil,
      coverageClaimed = false,
      activeRuntime = nil,
      activeQueued = false,
      reliefRuntime = nil,
      reliefQueued = false,
      reliefReason = nil,
      handoverArmed = false,
      nextPlannedHandoverAt = nil,
      reliefLaunchAt = nil,
    }
    state.stationsByKey[key] = station
  end
  return station
end

local function countPhysicalRuntimes()
  local count = 0
  for _, runtime in pairs(state.runtimesById) do
    if not runtime.handoffComplete and not runtime.lossHandled then count = count + 1 end
  end
  return count
end

local function countTrackRuntimes(stationKey)
  local count = 0
  for _, runtime in pairs(state.runtimesById) do
    if not runtime.handoffComplete and not runtime.lossHandled and activeKey(runtime.selection) == stationKey then
      count = count + 1
    end
  end
  return count
end

local function countActiveTracks()
  local count = 0
  for _, station in pairs(state.stationsByKey) do
    if station.coverageClaimed and not station.closed then count = count + 1 end
  end
  return count
end

local function countDemands(station)
  local count = 0
  for _ in pairs(station.demandsById) do count = count + 1 end
  return count
end

local function canMaterializeOperationally(station)
  if countTrackRuntimes(station.key) >= MAX_AIRCRAFT_PER_TRACK then
    return false, "MAX_AIRCRAFT_PER_TRACK"
  end
  return true
end

local function getDistanceNm(flightGroup, coordinate)
  if not flightGroup or not flightGroup:IsAlive() then return nil end
  local current = flightGroup:GetCoordinate()
  return current and current:Get2DDistance(coordinate) / 1852 or nil
end

local function estimateEtaSec(flightGroup, coordinate)
  local distanceNm = getDistanceNm(flightGroup, coordinate)
  return distanceNm and (distanceNm / TRANSIT_SPEED_KT) * 3600 or nil, distanceNm
end

local function callsignKey(name, number)
  return tostring(name) .. ":" .. tostring(number)
end

local function allocateSortieCallsign(areaSpec, runtimeId)
  local preferred = areaSpec.callsignNumber
  for offset = 0, 8 do
    local number = ((preferred - 1 + offset) % 9) + 1
    local key = callsignKey(areaSpec.callsignName, number)
    if not state.callsignInUse[key] then
      state.callsignInUse[key] = runtimeId
      return { key = key, id = areaSpec.callsignId, name = areaSpec.callsignName, number = number, stn = nil }
    end
  end
  fail("no free tanker callsign in family=" .. tostring(areaSpec.callsignName))
end

local function releaseSortieCallsign(runtime)
  local callsign = runtime and runtime.sortieCallsign
  if callsign and state.callsignInUse[callsign.key] == runtime.runtimeId then
    state.callsignInUse[callsign.key] = nil
  end
end

local function getSpawner(area, areaSpec)
  local spawner = state.spawnersByArea[area]
  if not spawner then
    spawner = SPAWN:New(areaSpec.template)
    state.spawnersByArea[area] = spawner
  end
  return spawner
end

local function deactivateStationIdentity(runtime)
  if not runtime or not runtime.stationIdentityActive then return end
  runtime.flightGroup:TurnOffRadio()
  runtime.flightGroup:TurnOffTACAN()
  runtime.stationIdentityActive = false
  log(string.format("STATION_IDENTITY_OFF runtime=%s area=%s callsign=%s%d-1", runtime.runtimeId,
    runtime.selection.area, runtime.sortieCallsign.name, runtime.sortieCallsign.number))
end

local function activateStationIdentity(runtime)
  if runtime.stationIdentityActive then return end
  local areaSpec = runtime.areaSpec
  runtime.flightGroup:SwitchRadio(areaSpec.frequencyMHz, 0)
  runtime.flightGroup:SwitchTACAN(areaSpec.tacanChannel, areaSpec.tacanIdent, nil, "Y")
  runtime.stationIdentityActive = true
  log(string.format("STATION_IDENTITY_ON runtime=%s area=%s callsign=%s%d-1 radioMHz=%.3f tacan=%dY ident=%s",
    runtime.runtimeId, runtime.selection.area, runtime.sortieCallsign.name, runtime.sortieCallsign.number,
    areaSpec.frequencyMHz, areaSpec.tacanChannel, areaSpec.tacanIdent))
end

local function cancelToEgress(runtime, reason)
  if not runtime or runtime.egressOrdered or runtime.lossHandled then return false end
  deactivateStationIdentity(runtime)
  runtime.egressOrdered = true
  runtime.egressReason = reason
  if not runtime.missionAdded then
    runtime.missionAdded = true
    runtime.missionAddedAt = now()
    runtime.flightGroup:AddMission(runtime.mission)
    log(string.format("MISSION_ADDED runtime=%s area=%s reason=PRETRACK_EGRESS", runtime.runtimeId, runtime.selection.area))
  end
  runtime.mission:Cancel()
  log(string.format("EGRESS_ORDERED runtime=%s demand=%s area=%s profile=%s firFix=%s reason=%s",
    runtime.runtimeId, runtime.selection.missionDemandId, runtime.selection.area,
    runtime.selection.receiverProfile, runtime.firFixName, tostring(reason)))
  return true
end

local function queueMaterialization(selection, role, reliefReason)
  state.queue[#state.queue + 1] = { selection = selection, role = role, reliefReason = reliefReason }
end

local function removeQueuedForStation(station)
  local remaining = {}
  for _, request in ipairs(state.queue) do
    if activeKey(request.selection) == station.key then
      if request.role == "RELIEF" then station.reliefQueued = false else station.activeQueued = false end
    else
      remaining[#remaining + 1] = request
    end
  end
  state.queue = remaining
end

local function queueActiveReplacement(station, reason)
  if station.closed or station.activeQueued then return false end
  station.activeQueued = true
  queueMaterialization(station.selection, "ACTIVE", reason)
  log(string.format("ACTIVE_REPLACEMENT_QUEUED area=%s profile=%s reason=%s",
    station.selection.area, station.selection.receiverProfile, tostring(reason)))
  return true
end

local function scheduleCycle(station, runtime, timestamp)
  local transitSec = (runtime.routeDistanceNm / TRANSIT_SPEED_KT) * 3600
  runtime.onStationAt = timestamp
  if station.closed then
    cancelToEgress(runtime, "TRACK_DISABLED")
    return
  end
  station.nextPlannedHandoverAt = timestamp + STATION_CYCLE_SEC
  station.reliefLaunchAt = station.nextPlannedHandoverAt - math.max(0, transitSec - RELIEF_HANDOVER_ETA_SEC)
  station.handoverArmed = false
  log(string.format("ON_STATION runtime=%s area=%s profile=%s cycleSec=%d reliefLaunchInSec=%.0f",
    runtime.runtimeId, runtime.selection.area, runtime.selection.receiverProfile, STATION_CYCLE_SEC,
    station.reliefLaunchAt - timestamp))
end

local function promoteReliefOnTrack(station, relief, reason, timestamp)
  if station.closed then
    cancelToEgress(relief, "TRACK_DISABLED")
    return
  end
  local outgoing = station.activeRuntime
  if outgoing and outgoing ~= relief and not outgoing.egressOrdered then
    cancelToEgress(outgoing, reason == "FUEL_LOW" and "FUEL_LOW_RELIEF" or "SCHEDULED_RELIEF")
  end
  station.reliefRuntime = nil
  station.reliefQueued = false
  station.reliefReason = nil
  station.activeRuntime = relief
  station.coverageClaimed = true
  relief.role = "ACTIVE"
  relief.reliefReason = reason
  activateStationIdentity(relief)
  scheduleCycle(station, relief, timestamp)
  log(string.format("RELIEF_ON_STATION runtime=%s area=%s profile=%s callsign=%s%d-1 reason=%s outgoingRuntime=%s",
    relief.runtimeId, relief.selection.area, relief.selection.receiverProfile,
    relief.sortieCallsign.name, relief.sortieCallsign.number, tostring(reason),
    outgoing and outgoing.runtimeId or "NONE"))
end

handleRuntimeLoss = function(runtime, reason)
  if not runtime or runtime.lossHandled or runtime.handoffComplete then return false end
  runtime.lossHandled = true
  runtime.stationIdentityActive = false
  local station = state.stationsByKey[activeKey(runtime.selection)]

  state.strategicAdapter:OnLost(runtime.selection, runtime, reason or "DEAD")
  releaseSortieCallsign(runtime)
  state.runtimesById[runtime.runtimeId] = nil

  if station then
    if station.activeRuntime == runtime then station.activeRuntime = nil end
    if station.reliefRuntime == runtime then
      station.reliefRuntime = nil
      station.reliefQueued = false
      station.reliefReason = nil
    end

    if not station.closed then
      local active = station.activeRuntime
      local relief = station.reliefRuntime
      if active and active.flightGroup and active.flightGroup:IsAlive() and not active.egressOrdered then
        if not relief then ensureRelief(station, "LOSS_REPLACEMENT") end
      elseif relief and relief.flightGroup and relief.flightGroup:IsAlive() and not relief.egressOrdered then
      else
        queueActiveReplacement(station, "AIRCRAFT_LOSS")
      end
    end
  end

  log(string.format("AIRCRAFT_LOST runtime=%s demand=%s area=%s profile=%s reason=%s action=NO_RECREDIT",
    runtime.runtimeId, runtime.selection.missionDemandId, runtime.selection.area,
    runtime.selection.receiverProfile, tostring(reason or "DEAD")))
  return true
end

local function materialize(request)
  requireMoose()
  local selection = request.selection
  local role = request.role or "ACTIVE"
  local areaSpec = AREAS[selection.area]
  local profile = areaSpec.profiles[selection.receiverProfile]
  local transit = TRANSIT[areaSpec.transitProfile]
  local externalPoint = EXTERNAL_POINTS[areaSpec.sourceDomain]
  local firFix = FIR_FIXES[areaSpec.firFix]
  local station = getOrCreateStation(selection)

  if station.closed then fail("refusing materialization for disabled track=" .. station.key) end

  state.nextRuntimeId = state.nextRuntimeId + 1
  local runtimeId = string.format("AAR-%04d", state.nextRuntimeId)
  local sortieCallsign = allocateSortieCallsign(areaSpec, runtimeId)

  local spawnCoord = COORDINATE:NewFromLLDD(externalPoint.lat, externalPoint.lon)
  spawnCoord:SetAltitude(UTILS.FeetToMeters(transit.ingressFt), true)
  local firIngressCoord = COORDINATE:NewFromLLDD(firFix.lat, firFix.lon)
  firIngressCoord:SetAltitude(UTILS.FeetToMeters(transit.ingressFt), true)
  local firEgressCoord = COORDINATE:NewFromLLDD(firFix.lat, firFix.lon)
  local externalHandoffCoord = COORDINATE:NewFromLLDD(externalPoint.lat, externalPoint.lon)
  externalHandoffCoord:SetAltitude(UTILS.FeetToMeters(transit.egressFt), true)
  local trackCoord = COORDINATE:NewFromLLDD(areaSpec.lat, areaSpec.lon)
  local spawnToFirNm = spawnCoord:Get2DDistance(firIngressCoord) / 1852
  local firToTrackNm = firIngressCoord:Get2DDistance(trackCoord) / 1852
  if firToTrackNm <= LATE_APPROACH_NM then
    fail(string.format("FIR-to-track distance %.1f NM must exceed late-approach distance %.1f NM area=%s",
      firToTrackNm, LATE_APPROACH_NM, selection.area))
  end
  local lateApproachCoord = trackCoord:GetIntermediateCoordinate(firIngressCoord, LATE_APPROACH_NM / firToTrackNm)
  lateApproachCoord:SetAltitude(UTILS.FeetToMeters(transit.ingressFt), true)
  local firToLateApproachNm = firIngressCoord:Get2DDistance(lateApproachCoord) / 1852
  local routeDistanceNm = spawnToFirNm + firToTrackNm

  local spawner = getSpawner(selection.area, areaSpec)
  spawner:InitCallSign(sortieCallsign.id, sortieCallsign.name, sortieCallsign.number, 1)
  spawner:InitHeading(spawnCoord:HeadingTo(firIngressCoord))
  spawner:InitSpeedKnots(SPAWN_INITIAL_SPEED_KT)
  local group = spawner:SpawnFromCoordinate(spawnCoord)
  if not group then
    releaseSortieCallsign({ runtimeId = runtimeId, sortieCallsign = sortieCallsign })
    fail("failed to materialize tanker template=" .. tostring(areaSpec.template))
  end

  local spawnedUnit = group:GetUnit(1)
  local spawnedStn = spawnedUnit and spawnedUnit:GetSTN() or nil
  if not spawnedStn or tostring(spawnedStn) == "" then
    releaseSortieCallsign({ runtimeId = runtimeId, sortieCallsign = sortieCallsign })
    fail("spawned tanker has no Link-16 STN template=" .. tostring(areaSpec.template))
  end
  sortieCallsign.stn = tostring(spawnedStn)

  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then fail("failed to create FLIGHTGROUP group=" .. tostring(group:GetName())) end

  local mission = AUFTRAG:NewTANKER(trackCoord, profile.altitudeFt, profile.speedKt, areaSpec.headingDeg, LEG_NM,
    Unit.RefuelingSystem.BOOM_AND_RECEPTACLE)
  mission:SetMissionAltitude(profile.altitudeFt)
  mission:SetMissionEgressCoord(firEgressCoord, transit.egressFt, TRANSIT_SPEED_KT)

  flightGroup:SetFuelLowRTB(false)
  flightGroup:SetFuelLowThreshold(areaSpec.fuelLowPct)

  local runtime = {
    runtimeId = runtimeId, selection = selection, areaSpec = areaSpec, profile = profile, transit = transit,
    template = areaSpec.template, role = role, reliefReason = request.reliefReason, initialFuelPct = areaSpec.initialFuelPct,
    group = group, flightGroup = flightGroup, mission = mission,
    spawnCoord = spawnCoord, firFixName = areaSpec.firFix, firIngressCoord = firIngressCoord, firEgressCoord = firEgressCoord,
    lateApproachCoord = lateApproachCoord, lateApproachNm = LATE_APPROACH_NM,
    externalHandoffCoord = externalHandoffCoord, trackCoord = trackCoord,
    spawnToFirNm = spawnToFirNm, firToTrackNm = firToTrackNm, firToLateApproachNm = firToLateApproachNm,
    routeDistanceNm = routeDistanceNm,
    sortieCallsign = sortieCallsign, transitCallsign = sortieCallsign,
    firIngressWaypointUid = nil, lateApproachWaypointUid = nil,
    firIngressPassed = false, firIngressPassedAt = nil,
    lateApproachPassed = false, lateApproachPassedAt = nil,
    missionAdded = false, missionAddedAt = nil,
    firEgressPassed = false, firEgressPassedAt = nil,
    externalHandoffRouted = false, stationIdentityActive = false, onStationAt = nil, materializedAt = now(),
    egressOrdered = false, egressReason = nil, handoffComplete = false, lossHandled = false,
  }

  function flightGroup:OnAfterFuelLow(From, Event, To)
    if runtime.egressOrdered or runtime.lossHandled then return end
    log(string.format("FUEL_LOW runtime=%s demand=%s area=%s profile=%s thresholdPct=%.4f action=ENSURE_RELIEF_AND_EGRESS",
      runtime.runtimeId, selection.missionDemandId, selection.area, selection.receiverProfile, areaSpec.fuelLowPct))
    if not station.closed then
      if station.activeRuntime == runtime then
        station.nextPlannedHandoverAt = nil
        station.reliefLaunchAt = nil
        station.handoverArmed = true
        ensureRelief(station, "FUEL_LOW")
      elseif station.reliefRuntime == runtime then
        station.reliefRuntime = nil
        station.reliefQueued = false
        station.reliefReason = nil
        ensureRelief(station, "FUEL_LOW")
      end
    end
    cancelToEgress(runtime, station.closed and "TRACK_DISABLED" or "FUEL_LOW")
  end

  function flightGroup:OnAfterDead(From, Event, To)
    handleRuntimeLoss(runtime, "MOOSE_FLIGHTGROUP_DEAD")
  end

  function flightGroup:OnAfterPassingWaypoint(From, Event, To, Waypoint)
    if not Waypoint or runtime.egressOrdered or runtime.lossHandled then return end
    if Waypoint.uid == runtime.firIngressWaypointUid and not runtime.firIngressPassed then
      runtime.firIngressPassed = true
      runtime.firIngressPassedAt = now()
      local distanceNm = getDistanceNm(runtime.flightGroup, runtime.firIngressCoord) or -1
      log(string.format("FIR_INGRESS_PASSED runtime=%s area=%s role=%s fix=%s waypointUid=%d distanceNm=%.2f",
        runtime.runtimeId, runtime.selection.area, runtime.role, runtime.firFixName, Waypoint.uid, distanceNm))
      return
    end
    if Waypoint.uid == runtime.lateApproachWaypointUid and not runtime.lateApproachPassed then
      if not runtime.firIngressPassed then
        fail(string.format("late approach reached before FIR ingress runtime=%s area=%s", runtime.runtimeId, runtime.selection.area))
      end
      runtime.lateApproachPassed = true
      runtime.lateApproachPassedAt = now()
      if not runtime.missionAdded then
        runtime.missionAdded = true
        runtime.missionAddedAt = runtime.lateApproachPassedAt
        runtime.flightGroup:AddMission(runtime.mission)
      end
      log(string.format("LATE_APPROACH_PASSED runtime=%s area=%s role=%s waypointUid=%d distanceToTrackNm=%.1f action=ADD_TANKER_MISSION",
        runtime.runtimeId, runtime.selection.area, runtime.role, Waypoint.uid, runtime.lateApproachNm))
    end
  end

  local firWaypoint = flightGroup:AddWaypoint(firIngressCoord, TRANSIT_SPEED_KT, nil, transit.ingressFt, false)
  local lateWaypoint = flightGroup:AddWaypoint(lateApproachCoord, TRANSIT_SPEED_KT, firWaypoint.uid, transit.ingressFt, true)
  runtime.firIngressWaypointUid = firWaypoint.uid
  runtime.lateApproachWaypointUid = lateWaypoint.uid
  flightGroup:TurnOffRadio()
  flightGroup:TurnOffTACAN()

  state.runtimesById[runtime.runtimeId] = runtime
  if role == "RELIEF" then
    station.reliefRuntime = runtime
    station.reliefQueued = false
    station.reliefReason = request.reliefReason or "SCHEDULED"
  else
    station.activeRuntime = runtime
    station.activeQueued = false
    station.coverageClaimed = true
  end
  state.strategicAdapter:OnMaterialized(selection, runtime)

  log(string.format("MATERIALIZED runtime=%s role=%s demand=%s area=%s profile=%s availability=%s source=%s firFix=%s firWaypointUid=%d lateApproachWaypointUid=%d lateApproachNm=%.1f firToLateApproachNm=%.1f group=%s callsign=%s%d-1 stn=%s activeTracks=%d aircraft=%d",
    runtime.runtimeId, runtime.role, selection.missionDemandId, selection.area, selection.receiverProfile,
    areaSpec.availability, selection.sourceDomain, areaSpec.firFix, runtime.firIngressWaypointUid, runtime.lateApproachWaypointUid,
    LATE_APPROACH_NM, firToLateApproachNm, group:GetName(), sortieCallsign.name, sortieCallsign.number, sortieCallsign.stn,
    countActiveTracks(), countPhysicalRuntimes()))
  return runtime
end

local function canSpawnSource(sourceDomain, timestamp)
  local last = state.lastSpawnAtBySource[sourceDomain]
  return last == nil or (timestamp - last) >= SOURCE_SPAWN_INTERVAL_SEC
end

ensureRelief = function(station, reason)
  if station.closed then return nil, false end
  if station.reliefRuntime and station.reliefRuntime.flightGroup and station.reliefRuntime.flightGroup:IsAlive()
      and not station.reliefRuntime.egressOrdered and not station.reliefRuntime.lossHandled then
    if reason == "FUEL_LOW" then station.reliefReason = "FUEL_LOW"; station.reliefRuntime.reliefReason = "FUEL_LOW" end
    return station.reliefRuntime, false
  end
  if station.reliefQueued then
    if reason == "FUEL_LOW" then
      station.reliefReason = "FUEL_LOW"
      for _, request in ipairs(state.queue) do
        if request.role == "RELIEF" and activeKey(request.selection) == station.key then request.reliefReason = "FUEL_LOW" end
      end
    end
    return nil, false
  end
  station.reliefQueued = true
  station.reliefReason = reason
  queueMaterialization(station.selection, "RELIEF", reason)
  log(string.format("RELIEF_QUEUED area=%s profile=%s reason=%s", station.selection.area,
    station.selection.receiverProfile, tostring(reason)))
  return nil, true
end

local function processQueue()
  if #state.queue == 0 then return end
  local timestamp = now()
  local spawnedSource, remaining = {}, {}
  for _, request in ipairs(state.queue) do
    local station = state.stationsByKey[activeKey(request.selection)]
    if station and station.closed then
      if request.role == "RELIEF" then station.reliefQueued = false else station.activeQueued = false end
      log(string.format("QUEUE_DROPPED demand=%s role=%s station=%s reason=TRACK_DISABLED",
        request.selection.missionDemandId, tostring(request.role), station.key))
    else
      local operational, operationalReason = canMaterializeOperationally(station)
      if not operational then
        remaining[#remaining + 1] = request
      else
        local source = request.selection.sourceDomain
        if not spawnedSource[source] and canSpawnSource(source, timestamp) then
          local allowed, reason = state.strategicAdapter:CanMaterialize(request.selection)
          if allowed then
            materialize(request)
            state.lastSpawnAtBySource[source] = timestamp
            spawnedSource[source] = true
          else
            log(string.format("DEFERRED demand=%s role=%s source=%s reason=%s", request.selection.missionDemandId,
              tostring(request.role), source, tostring(reason or "STRATEGIC_UNAVAILABLE")))
            remaining[#remaining + 1] = request
          end
        else
          remaining[#remaining + 1] = request
        end
      end
      if not operational and operationalReason then
        log(string.format("DEFERRED demand=%s role=%s station=%s reason=%s",
          request.selection.missionDemandId, tostring(request.role), station.key, operationalReason))
      end
    end
  end
  state.queue = remaining
end

local function monitorStations()
  local timestamp = now()
  for _, station in pairs(state.stationsByKey) do
    if not station.closed then
      local active = station.activeRuntime
      if active and active.flightGroup and active.flightGroup:IsAlive() and not active.egressOrdered and not active.lossHandled then
        if active.firIngressPassed and active.lateApproachPassed and active.missionAdded and not active.onStationAt then
          local distanceNm = getDistanceNm(active.flightGroup, active.trackCoord)
          if distanceNm and distanceNm <= TRACK_ENTRY_RADIUS_NM then
            activateStationIdentity(active)
            scheduleCycle(station, active, timestamp)
          end
        end
      end

      if active and active.onStationAt and not active.egressOrdered and not active.lossHandled
          and station.reliefLaunchAt and timestamp >= station.reliefLaunchAt then
        ensureRelief(station, "SCHEDULED")
      end

      local relief = station.reliefRuntime
      if relief and relief.flightGroup and relief.flightGroup:IsAlive() and not relief.egressOrdered and not relief.lossHandled then
        if relief.firIngressPassed and relief.lateApproachPassed and relief.missionAdded then
          local etaSec, distanceNm = estimateEtaSec(relief.flightGroup, relief.trackCoord)
          local reason = station.reliefReason or relief.reliefReason or "SCHEDULED"
          if etaSec and etaSec <= RELIEF_HANDOVER_ETA_SEC and not station.handoverArmed then
            station.handoverArmed = true
            log(string.format("RELIEF_HANDOVER_ARMED runtime=%s area=%s reason=%s etaSec=%.0f distanceNm=%.1f",
              relief.runtimeId, relief.selection.area, tostring(reason), etaSec, distanceNm or -1))
          end
          if distanceNm and distanceNm <= TRACK_ENTRY_RADIUS_NM then
            promoteReliefOnTrack(station, relief, reason, timestamp)
          end
        end
      end
    end
  end

  for runtimeId, runtime in pairs(state.runtimesById) do
    if runtime.egressOrdered and not runtime.handoffComplete and not runtime.lossHandled and runtime.flightGroup:IsAlive() then
      if not runtime.firEgressPassed then
        local firDistanceNm = getDistanceNm(runtime.flightGroup, runtime.firEgressCoord)
        if firDistanceNm and firDistanceNm <= FIR_FIX_RADIUS_NM then
          runtime.firEgressPassed = true
          runtime.firEgressPassedAt = timestamp
          runtime.flightGroup:AddWaypoint(runtime.externalHandoffCoord, TRANSIT_SPEED_KT, nil, runtime.transit.egressFt)
          runtime.externalHandoffRouted = true
          log(string.format("FIR_EGRESS_PASSED runtime=%s area=%s fix=%s distanceNm=%.2f action=ROUTE_EXTERNAL_HANDOFF",
            runtime.runtimeId, runtime.selection.area, runtime.firFixName, firDistanceNm))
        end
      else
        local distanceNm = getDistanceNm(runtime.flightGroup, runtime.externalHandoffCoord)
        if distanceNm and distanceNm <= HANDOFF_RADIUS_NM then
          runtime.handoffComplete = true
          deactivateStationIdentity(runtime)
          state.strategicAdapter:OnHandoff(runtime.selection, runtime)
          runtime.flightGroup:Despawn(1, true)
          releaseSortieCallsign(runtime)
          state.runtimesById[runtimeId] = nil
          local station = state.stationsByKey[activeKey(runtime.selection)]
          if station then
            if station.activeRuntime == runtime then station.activeRuntime = nil end
            if station.reliefRuntime == runtime then station.reliefRuntime = nil end
          end
          log(string.format("OFFMAP_HANDOFF runtime=%s demand=%s area=%s distanceExternalNm=%.2f action=DESPAWN",
            runtime.runtimeId, runtime.selection.missionDemandId, runtime.selection.area, distanceNm))
        end
      end
    end
  end
end

local function ensureSchedulers()
  requireMoose()
  if not state.dispatcher then state.dispatcher = SCHEDULER:New(nil, processQueue, {}, 0, DISPATCH_INTERVAL_SEC) end
  if not state.stationMonitor then
    state.stationMonitor = SCHEDULER:New(nil, monitorStations, {}, DISPATCH_INTERVAL_SEC, DISPATCH_INTERVAL_SEC)
  end
end

function Controller.StartContinuousCoreCoverage()
  if not state.strategicAdapter then fail("SetStrategicAdapter must be called before StartContinuousCoreCoverage") end
  for _, area in ipairs(STANDARD_AREA_ORDER) do
    local selection = trackSelection(area)
    local station = getOrCreateStation(selection)
    station.selection = selection
    station.continuousCore = true
    station.closed = false
    station.closedReason = nil
    if not station.activeRuntime and not station.reliefRuntime and not station.activeQueued then
      station.activeQueued = true
      queueMaterialization(selection, "ACTIVE", "CORE_START")
      log(string.format("STANDARD_TRACK_QUEUED area=%s profile=%s source=%s firFix=%s",
        selection.area, selection.receiverProfile, selection.sourceDomain, selection.firFix))
    end
  end
  state.continuousCoreStarted = true
  ensureSchedulers()
  return Controller
end

function Controller.SubmitDemand(demand)
  if not state.strategicAdapter then fail("SetStrategicAdapter must be called before SubmitDemand") end
  local selection, reason = Controller.SelectArea(demand)
  if not selection then
    log("REJECTED demand=" .. tostring(demand and demand.missionDemandId) .. " reason=" .. tostring(reason))
    return nil, reason
  end

  local track = trackSelection(selection.area, selection.missionDemandId)
  local station = getOrCreateStation(track)
  station.selection = track
  station.continuousCore = track.continuousCore == true
  station.closed = false
  station.closedReason = nil
  station.demandsById[selection.missionDemandId] = selection

  local existing = station.activeRuntime
  if existing and existing.flightGroup and existing.flightGroup:IsAlive()
      and not existing.egressOrdered and not existing.lossHandled then
    ensureSchedulers()
    log(string.format("DEMAND_ATTACHED demand=%s area=%s profile=%s availability=%s action=ACTIVE_REUSED",
      selection.missionDemandId, selection.area, selection.receiverProfile, track.availability))
    return existing, "ACTIVE_REUSED"
  end
  if station.reliefRuntime and station.reliefRuntime.flightGroup and station.reliefRuntime.flightGroup:IsAlive()
      and not station.reliefRuntime.egressOrdered and not station.reliefRuntime.lossHandled then
    ensureSchedulers()
    return station.reliefRuntime, "RELIEF_INBOUND"
  end
  if not station.activeQueued then
    station.activeQueued = true
    queueMaterialization(track, "ACTIVE", track.continuousCore and "CORE_RECOVERY" or "RESERVE_DEMAND")
    log(string.format("TRACK_QUEUED demand=%s area=%s profile=%s availability=%s",
      selection.missionDemandId, selection.area, selection.receiverProfile, track.availability))
  end
  ensureSchedulers()
  return track, track.continuousCore and "CORE_TRACK_QUEUED" or "RESERVE_TRACK_QUEUED"
end

function Controller.EndDemand(demand, terminalStatus)
  terminalStatus = requireString(terminalStatus, "terminalStatus"):upper()
  if terminalStatus ~= "COMPLETE" and terminalStatus ~= "CANCELLED" and terminalStatus ~= "ABORTED" then
    fail("terminalStatus must be COMPLETE, CANCELLED or ABORTED")
  end

  local selection, reason = Controller.SelectArea(demand)
  if not selection then
    log("END_DEMAND_REJECTED demand=" .. tostring(demand and demand.missionDemandId) .. " reason=" .. tostring(reason))
    return nil, reason
  end

  local track = trackSelection(selection.area, selection.missionDemandId)
  local station = state.stationsByKey[activeKey(track)]
  if not station then return nil, "NO_STATION" end

  station.demandsById[selection.missionDemandId] = nil
  if station.continuousCore then
    log(string.format("DEMAND_ENDED demand=%s status=%s area=%s profile=%s stationAction=RETAIN_STANDARD_TRACK",
      selection.missionDemandId, terminalStatus, selection.area, selection.receiverProfile))
    ensureSchedulers()
    return station, "CORE_TRACK_RETAINED"
  end

  if countDemands(station) > 0 then
    log(string.format("DEMAND_ENDED demand=%s status=%s area=%s profile=%s stationAction=RETAIN_RESERVE_OTHER_DEMAND",
      selection.missionDemandId, terminalStatus, selection.area, selection.receiverProfile))
    return station, "RESERVE_TRACK_RETAINED"
  end

  station.closed = true
  station.closedReason = "RESERVE_DEMAND_ENDED"
  station.coverageClaimed = false
  station.nextPlannedHandoverAt = nil
  station.reliefLaunchAt = nil
  station.handoverArmed = false
  removeQueuedForStation(station)
  if station.activeRuntime then cancelToEgress(station.activeRuntime, "RESERVE_DEMAND_ENDED") end
  if station.reliefRuntime then cancelToEgress(station.reliefRuntime, "RESERVE_DEMAND_ENDED") end
  log(string.format("DEMAND_ENDED demand=%s status=%s area=%s profile=%s stationAction=RESERVE_EGRESS",
    selection.missionDemandId, terminalStatus, selection.area, selection.receiverProfile))
  ensureSchedulers()
  return station, "RESERVE_TRACK_EGRESS"
end

local function resolveTrackKey(area, receiverProfile)
  local areaName = tostring(area):upper()
  local areaSpec = AREAS[areaName]
  if not areaSpec then return areaName .. ":" .. tostring(receiverProfile):upper() end
  local profile = receiverProfile and tostring(receiverProfile):upper() or areaSpec.coreProfile
  return areaName .. ":" .. profile
end

function Controller.GetActive(area, receiverProfile)
  local station = state.stationsByKey[resolveTrackKey(area, receiverProfile)]
  return station and station.activeRuntime or nil
end

function Controller.GetStation(area, receiverProfile)
  return state.stationsByKey[resolveTrackKey(area, receiverProfile)]
end

function Controller.GetRuntimeCounts()
  local activeTracks = countActiveTracks()
  return {
    activeTracks = activeTracks,
    supportMissions = activeTracks,
    supportAircraft = countPhysicalRuntimes(),
    queued = #state.queue,
  }
end

function Controller.GetConfig()
  return {
    mooseCommit = MOOSE_COMMIT,
    mooseSha256 = MOOSE_SHA256,
    sourceSpawnIntervalSec = SOURCE_SPAWN_INTERVAL_SEC,
    handoffRadiusNm = HANDOFF_RADIUS_NM,
    firFixRadiusNm = FIR_FIX_RADIUS_NM,
    trackEntryRadiusNm = TRACK_ENTRY_RADIUS_NM,
    lateApproachNm = LATE_APPROACH_NM,
    stationCycleSec = STATION_CYCLE_SEC,
    reliefHandoverEtaSec = RELIEF_HANDOVER_ETA_SEC,
    spawnInitialSpeedKt = SPAWN_INITIAL_SPEED_KT,
    transitSpeedKt = TRANSIT_SPEED_KT,
    standardTrackCount = STANDARD_TRACK_COUNT,
    reserveTrackCount = RESERVE_TRACK_COUNT,
    continuousCoreTrackCount = STANDARD_TRACK_COUNT,
    continuousAvailabilityPolicy = true,
    reserveDemandDriven = true,
    maxAircraftPerTrack = MAX_AIRCRAFT_PER_TRACK,
    globalAarMissionLimit = false,
    globalAarAircraftLimit = false,
    mooseManagedSpawnStn = true,
    stableSortieCallsign = true,
    firFixRoutingEnabled = true,
    lateApproachRoutingMode = "FIR_THEN_LATE_APPROACH_THEN_AUFTRAG",
    externalSpawnHandoffSeparated = true,
    airwaysRoutingEnabled = false,
    coreProfiles = {
      LISA = AREAS.LISA.coreProfile,
      MOE = AREAS.MOE.coreProfile,
      MILHOUSE = AREAS.MILHOUSE.coreProfile,
      KRUSTY = AREAS.KRUSTY.coreProfile,
      PATTY = AREAS.PATTY.coreProfile,
      NELSON = AREAS.NELSON.coreProfile,
    },
    availabilityByArea = {
      LISA = AREAS.LISA.availability,
      MOE = AREAS.MOE.availability,
      MILHOUSE = AREAS.MILHOUSE.availability,
      KRUSTY = AREAS.KRUSTY.availability,
      PATTY = AREAS.PATTY.availability,
      NELSON = AREAS.NELSON.availability,
    },
    sourceDomainByArea = {
      LISA = AREAS.LISA.sourceDomain,
      MOE = AREAS.MOE.sourceDomain,
      MILHOUSE = AREAS.MILHOUSE.sourceDomain,
      KRUSTY = AREAS.KRUSTY.sourceDomain,
      PATTY = AREAS.PATTY.sourceDomain,
      NELSON = AREAS.NELSON.sourceDomain,
    },
    firFixByArea = {
      LISA = AREAS.LISA.firFix,
      MOE = AREAS.MOE.firFix,
      MILHOUSE = AREAS.MILHOUSE.firFix,
      KRUSTY = AREAS.KRUSTY.firFix,
      PATTY = AREAS.PATTY.firFix,
      NELSON = AREAS.NELSON.firFix,
    },
    callsignFamilyByArea = {
      LISA = AREAS.LISA.callsignName,
      MOE = AREAS.MOE.callsignName,
      MILHOUSE = AREAS.MILHOUSE.callsignName,
      KRUSTY = AREAS.KRUSTY.callsignName,
      PATTY = AREAS.PATTY.callsignName,
      NELSON = AREAS.NELSON.callsignName,
    },
    initialFuelPctByArea = {
      LISA = AREAS.LISA.initialFuelPct,
      MOE = AREAS.MOE.initialFuelPct,
      MILHOUSE = AREAS.MILHOUSE.initialFuelPct,
      KRUSTY = AREAS.KRUSTY.initialFuelPct,
      PATTY = AREAS.PATTY.initialFuelPct,
      NELSON = AREAS.NELSON.initialFuelPct,
    },
    fuelLowPctByArea = {
      LISA = AREAS.LISA.fuelLowPct,
      MOE = AREAS.MOE.fuelLowPct,
      MILHOUSE = AREAS.MILHOUSE.fuelLowPct,
      KRUSTY = AREAS.KRUSTY.fuelLowPct,
      PATTY = AREAS.PATTY.fuelLowPct,
      NELSON = AREAS.NELSON.fuelLowPct,
    },
    transitByArea = {
      LISA = TRANSIT[AREAS.LISA.transitProfile],
      MOE = TRANSIT[AREAS.MOE.transitProfile],
      MILHOUSE = TRANSIT[AREAS.MILHOUSE.transitProfile],
      KRUSTY = TRANSIT[AREAS.KRUSTY.transitProfile],
      PATTY = TRANSIT[AREAS.PATTY.transitProfile],
      NELSON = TRANSIT[AREAS.NELSON.transitProfile],
    },
  }
end

OMW.AAR = Controller
log("LOADED MOOSE commit=" .. MOOSE_COMMIT .. " sha256=" .. MOOSE_SHA256)
return Controller