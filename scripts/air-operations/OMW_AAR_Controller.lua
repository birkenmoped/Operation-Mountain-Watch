-- Operation Mountain Watch - production AAR demand and tanker lifecycle controller.
--
-- MOOSE-first boundary:
--   * OMW selects the operational AAR area/profile from MissionDemand.
--   * MOOSE SPAWN/FLIGHTGROUP/AUFTRAG/SCHEDULER execute the physical lifecycle.
--   * OMW only orchestrates station ownership, relief timing, identity handover and bounded concurrency.
--   * CampaignState remains the strategic availability authority through the injected adapter.

OMW = OMW or {}

local Controller = {}

local TAG = "[OMW][AAR.Controller]"
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"
local SOURCE_SPAWN_INTERVAL_SEC = 60
local HANDOFF_RADIUS_NM = 10
local TRACK_ENTRY_RADIUS_NM = 5
local DISPATCH_INTERVAL_SEC = 5
local TRANSIT_SPEED_KT = 300
local LEG_NM = 35
local STATION_CYCLE_SEC = 3 * 60 * 60
local RELIEF_HANDOVER_ETA_SEC = 5 * 60
local MAX_CONCURRENT_SUPPORT_MISSIONS = 2
local MAX_AIRCRAFT_PER_SUPPORT_MISSION = 2
local MAX_CONCURRENT_SUPPORT_AIRCRAFT = 4

local GATES = {
  MANAS = { lat = 38.83163, lon = 70.95271 },
  AL_UDEID = { lat = 28.90264890, lon = 64.61166667 },
}

local TRANSIT = {
  MANAS_WEST_HIGH = { ingressFt = 34000, egressFt = 33000 },
  MANAS_EAST_HIGH = { ingressFt = 33000, egressFt = 34000 },
  AL_UDEID_NORTH_HIGH = { ingressFt = 33000, egressFt = 34000 },
}

local AREAS = {
  LISA = {
    template = "OMW_AAR_KC135_LISA",
    callsignId = CALLSIGN.Tanker.Texaco, callsignName = "Texaco", callsignMinor = 3, callsignMajor = 1,
    lat = 33.66624916, lon = 61.81294477, headingDeg = 4.269,
    sourceDomain = "MANAS", transitProfile = "MANAS_WEST_HIGH",
    frequencyMHz = 235.900, tacanChannel = 50, tacanIdent = "LIS",
    fuelLowPct = 24, initialFuelPct = 96,
    profiles = { SLOW = { altitudeFt = 22000, speedKt = 220 }, FAST = { altitudeFt = 25000, speedKt = 300 } },
  },
  MOE = {
    template = "OMW_AAR_KC135_MOE",
    callsignId = CALLSIGN.Tanker.Texaco, callsignName = "Texaco", callsignMinor = 4, callsignMajor = 1,
    lat = 35.07603944, lon = 65.32603438, headingDeg = 304.682,
    sourceDomain = "MANAS", transitProfile = "MANAS_WEST_HIGH",
    frequencyMHz = 243.400, tacanChannel = 52, tacanIdent = "MOE",
    fuelLowPct = 22, initialFuelPct = 96,
    profiles = { SLOW = { altitudeFt = 24000, speedKt = 220 }, FAST = { altitudeFt = 27000, speedKt = 300 } },
  },
  MILHOUSE = {
    template = "OMW_AAR_KC135_MILHOUSE",
    callsignId = CALLSIGN.Tanker.Shell, callsignName = "Shell", callsignMinor = 2, callsignMajor = 1,
    lat = 33.44219603, lon = 65.46466360, headingDeg = 63.607,
    sourceDomain = "AL_UDEID", transitProfile = "AL_UDEID_NORTH_HIGH",
    frequencyMHz = 272.600, tacanChannel = 58, tacanIdent = "MIL",
    fuelLowPct = 27, initialFuelPct = 90,
    profiles = { SLOW = { altitudeFt = 22000, speedKt = 220 } },
  },
  KRUSTY = {
    template = "OMW_AAR_KC135_KRUSTY",
    callsignId = CALLSIGN.Tanker.Arco, callsignName = "Arco", callsignMinor = 2, callsignMajor = 1,
    lat = 32.65123012, lon = 68.15946309, headingDeg = 212.350,
    sourceDomain = "AL_UDEID", transitProfile = "AL_UDEID_NORTH_HIGH",
    frequencyMHz = 258.300, tacanChannel = 42, tacanIdent = "KRU",
    fuelLowPct = 27, initialFuelPct = 90,
    profiles = { SLOW = { altitudeFt = 22000, speedKt = 220 } },
  },
  PATTY = {
    template = "OMW_AAR_KC135_PATTY",
    callsignId = CALLSIGN.Tanker.Texaco, callsignName = "Texaco", callsignMinor = 2, callsignMajor = 1,
    lat = 34.97134133, lon = 71.47789605, headingDeg = 89.662,
    sourceDomain = "MANAS", transitProfile = "MANAS_EAST_HIGH",
    frequencyMHz = 237.300, tacanChannel = 48, tacanIdent = "PAT",
    fuelLowPct = 21, initialFuelPct = 96,
    profiles = { SLOW = { altitudeFt = 24000, speedKt = 220 } },
  },
  NELSON = {
    template = "OMW_AAR_KC135_NELSON",
    callsignId = CALLSIGN.Tanker.Texaco, callsignName = "Texaco", callsignMinor = 1, callsignMajor = 1,
    lat = 36.37666667, lon = 71.01833333, headingDeg = 10.428,
    sourceDomain = "MANAS", transitProfile = "MANAS_EAST_HIGH",
    frequencyMHz = 384.400, tacanChannel = 47, tacanIdent = "NEL",
    fuelLowPct = 20, initialFuelPct = 96,
    profiles = { FAST = { altitudeFt = 27500, speedKt = 300 } },
  },
}

local TRANSIT_CALLSIGNS = {
  { id = CALLSIGN.Tanker.Texaco, name = "Texaco", number = 5, stn = 50000 },
  { id = CALLSIGN.Tanker.Texaco, name = "Texaco", number = 6, stn = 50001 },
  { id = CALLSIGN.Tanker.Texaco, name = "Texaco", number = 7, stn = 50002 },
  { id = CALLSIGN.Tanker.Texaco, name = "Texaco", number = 8, stn = 50003 },
  { id = CALLSIGN.Tanker.Texaco, name = "Texaco", number = 9, stn = 50004 },
  { id = CALLSIGN.Tanker.Arco, name = "Arco", number = 5, stn = 50005 },
  { id = CALLSIGN.Tanker.Arco, name = "Arco", number = 6, stn = 50006 },
  { id = CALLSIGN.Tanker.Arco, name = "Arco", number = 7, stn = 50007 },
  { id = CALLSIGN.Tanker.Arco, name = "Arco", number = 8, stn = 50010 },
  { id = CALLSIGN.Tanker.Arco, name = "Arco", number = 9, stn = 50011 },
  { id = CALLSIGN.Tanker.Shell, name = "Shell", number = 5, stn = 50012 },
  { id = CALLSIGN.Tanker.Shell, name = "Shell", number = 6, stn = 50013 },
  { id = CALLSIGN.Tanker.Shell, name = "Shell", number = 7, stn = 50014 },
  { id = CALLSIGN.Tanker.Shell, name = "Shell", number = 8, stn = 50015 },
  { id = CALLSIGN.Tanker.Shell, name = "Shell", number = 9, stn = 50016 },
}

local state = {
  strategicAdapter = nil,
  queue = {},
  stationsByKey = {},
  runtimesById = {},
  lastSpawnAtBySource = {},
  spawnersByArea = {},
  transitCallsignInUse = {},
  dispatcher = nil,
  stationMonitor = nil,
  nextRuntimeId = 0,
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
  if not areaSpec.profiles[d.receiverProfile] then
    return nil, string.format("AREA_PROFILE_UNAVAILABLE area=%s receiverProfile=%s", area, d.receiverProfile)
  end
  return {
    missionDemandId = d.missionDemandId, receiverProfile = d.receiverProfile, operationsArea = d.operationsArea,
    supportMode = d.supportMode, priority = d.priority, area = area, sourceDomain = areaSpec.sourceDomain,
    transitProfile = areaSpec.transitProfile,
  }
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
      closed = false,
      closedReason = nil,
      missionSlotClaimed = false,
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

local function firstDemandSelection(station)
  for _, selection in pairs(station.demandsById) do return selection end
  return nil
end

local function countPhysicalRuntimes()
  local count = 0
  for _, runtime in pairs(state.runtimesById) do
    if not runtime.handoffComplete and not runtime.lossHandled then count = count + 1 end
  end
  return count
end

local function countStationRuntimes(stationKey)
  local count = 0
  for _, runtime in pairs(state.runtimesById) do
    if not runtime.handoffComplete and not runtime.lossHandled and activeKey(runtime.selection) == stationKey then
      count = count + 1
    end
  end
  return count
end

local function countMissionSlots()
  local count = 0
  for _, station in pairs(state.stationsByKey) do
    if station.missionSlotClaimed then count = count + 1 end
  end
  return count
end

local function canMaterializeOperationally(request, station)
  if countPhysicalRuntimes() >= MAX_CONCURRENT_SUPPORT_AIRCRAFT then
    return false, "MAX_CONCURRENT_SUPPORT_AIRCRAFT"
  end
  if countStationRuntimes(station.key) >= MAX_AIRCRAFT_PER_SUPPORT_MISSION then
    return false, "MAX_AIRCRAFT_PER_SUPPORT_MISSION"
  end
  if request.role ~= "RELIEF" and not station.missionSlotClaimed
      and countMissionSlots() >= MAX_CONCURRENT_SUPPORT_MISSIONS then
    return false, "MAX_CONCURRENT_SUPPORT_MISSIONS"
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

local function allocateTransitCallsign(runtimeId)
  for index, slot in ipairs(TRANSIT_CALLSIGNS) do
    if not state.transitCallsignInUse[index] then
      state.transitCallsignInUse[index] = runtimeId
      return { index = index, id = slot.id, name = slot.name, number = slot.number, stn = slot.stn }
    end
  end
  fail("no free transit tanker callsign slot")
end

local function releaseTransitCallsign(runtime)
  local transit = runtime and runtime.transitCallsign
  if transit and state.transitCallsignInUse[transit.index] == runtime.runtimeId then
    state.transitCallsignInUse[transit.index] = nil
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
  runtime.flightGroup:SwitchCallsign(runtime.transitCallsign.id, runtime.transitCallsign.number)
  runtime.stationIdentityActive = false
  log(string.format("STATION_IDENTITY_OFF runtime=%s area=%s transitCallsign=%s%d", runtime.runtimeId,
    runtime.selection.area, runtime.transitCallsign.name, runtime.transitCallsign.number))
end

local function activateStationIdentity(runtime)
  if runtime.stationIdentityActive then return end
  local areaSpec = runtime.areaSpec
  runtime.flightGroup:SwitchCallsign(areaSpec.callsignId, areaSpec.callsignMinor)
  runtime.flightGroup:SwitchRadio(areaSpec.frequencyMHz, 0)
  runtime.flightGroup:SwitchTACAN(areaSpec.tacanChannel, areaSpec.tacanIdent, nil, "Y")
  runtime.stationIdentityActive = true
  log(string.format("STATION_IDENTITY_ON runtime=%s area=%s callsign=%s%d-1 radioMHz=%.3f tacan=%dY ident=%s",
    runtime.runtimeId, runtime.selection.area, areaSpec.callsignName, areaSpec.callsignMinor,
    areaSpec.frequencyMHz, areaSpec.tacanChannel, areaSpec.tacanIdent))
end

local function cancelToEgress(runtime, reason)
  if not runtime or runtime.egressOrdered or runtime.lossHandled then return false end
  deactivateStationIdentity(runtime)
  runtime.egressOrdered = true
  runtime.egressReason = reason
  runtime.mission:Cancel()
  log(string.format("EGRESS_ORDERED runtime=%s demand=%s area=%s profile=%s reason=%s", runtime.runtimeId,
    runtime.selection.missionDemandId, runtime.selection.area, runtime.selection.receiverProfile, tostring(reason)))
  return true
end

local function clearQueuedForStation(station, replacementSelection)
  local remaining = {}
  local removed = 0
  for _, request in ipairs(state.queue) do
    if activeKey(request.selection) == station.key then
      if replacementSelection then
        request.selection = replacementSelection
        remaining[#remaining + 1] = request
      else
        removed = removed + 1
      end
    else
      remaining[#remaining + 1] = request
    end
  end
  state.queue = remaining
  if not replacementSelection then
    station.activeQueued = false
    station.reliefQueued = false
    station.reliefReason = nil
  end
  return removed
end

local function closeStation(station, terminalStatus)
  station.closed = true
  station.closedReason = terminalStatus
  station.missionSlotClaimed = false
  station.nextPlannedHandoverAt = nil
  station.reliefLaunchAt = nil
  station.handoverArmed = true
  local removed = clearQueuedForStation(station, nil)
  local activeEgress = cancelToEgress(station.activeRuntime, "DEMAND_" .. terminalStatus)
  local reliefEgress = cancelToEgress(station.reliefRuntime, "DEMAND_" .. terminalStatus)
  log(string.format("STATION_CLOSED area=%s profile=%s status=%s queuedRemoved=%d activeEgress=%s reliefEgress=%s",
    station.selection.area, station.selection.receiverProfile, terminalStatus, removed,
    tostring(activeEgress), tostring(reliefEgress)))
end

local function queueMaterialization(selection, role, reliefReason)
  state.queue[#state.queue + 1] = { selection = selection, role = role, reliefReason = reliefReason }
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
  local transitSec = (runtime.gateDistanceNm / TRANSIT_SPEED_KT) * 3600
  runtime.onStationAt = timestamp
  if station.closed then
    cancelToEgress(runtime, "DEMAND_" .. tostring(station.closedReason or "ENDED"))
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
    cancelToEgress(relief, "DEMAND_" .. tostring(station.closedReason or "ENDED"))
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
  station.missionSlotClaimed = true
  relief.role = "ACTIVE"
  relief.reliefReason = reason
  activateStationIdentity(relief)
  scheduleCycle(station, relief, timestamp)
  log(string.format("RELIEF_ON_STATION runtime=%s area=%s profile=%s reason=%s outgoingRuntime=%s",
    relief.runtimeId, relief.selection.area, relief.selection.receiverProfile, tostring(reason),
    outgoing and outgoing.runtimeId or "NONE"))
end

handleRuntimeLoss = function(runtime, reason)
  if not runtime or runtime.lossHandled or runtime.handoffComplete then return false end
  runtime.lossHandled = true
  runtime.stationIdentityActive = false
  local station = state.stationsByKey[activeKey(runtime.selection)]

  state.strategicAdapter:OnLost(runtime.selection, runtime, reason or "DEAD")
  releaseTransitCallsign(runtime)
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
        -- Existing inbound relief can become the next active tanker; no duplicate materialization.
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
  local gate = GATES[areaSpec.sourceDomain]
  local station = getOrCreateStation(selection)

  if station.closed then fail("refusing materialization for closed station=" .. station.key) end

  state.nextRuntimeId = state.nextRuntimeId + 1
  local runtimeId = string.format("AAR-%04d", state.nextRuntimeId)
  local transitCallsign = allocateTransitCallsign(runtimeId)

  local spawnCoord = COORDINATE:NewFromLLDD(gate.lat, gate.lon)
  spawnCoord:SetAltitude(UTILS.FeetToMeters(transit.ingressFt), true)
  local ingressCoord = COORDINATE:NewFromLLDD(gate.lat, gate.lon)
  local egressCoord = COORDINATE:NewFromLLDD(gate.lat, gate.lon)
  local trackCoord = COORDINATE:NewFromLLDD(areaSpec.lat, areaSpec.lon)
  local gateDistanceNm = spawnCoord:Get2DDistance(trackCoord) / 1852

  local spawner = getSpawner(selection.area, areaSpec)
  spawner:InitCallSign(transitCallsign.id, transitCallsign.name, transitCallsign.number, 1)
  spawner:InitSTN(transitCallsign.stn)
  spawner:InitHeading(spawnCoord:HeadingTo(trackCoord))
  spawner:InitSpeedKnots(TRANSIT_SPEED_KT)
  local group = spawner:SpawnFromCoordinate(spawnCoord)
  if not group then
    releaseTransitCallsign({ runtimeId = runtimeId, transitCallsign = transitCallsign })
    fail("failed to materialize tanker template=" .. tostring(areaSpec.template))
  end

  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then fail("failed to create FLIGHTGROUP group=" .. tostring(group:GetName())) end

  local mission = AUFTRAG:NewTANKER(trackCoord, profile.altitudeFt, profile.speedKt, areaSpec.headingDeg, LEG_NM,
    Unit.RefuelingSystem.BOOM_AND_RECEPTACLE)
  mission:SetMissionIngressCoord(ingressCoord, transit.ingressFt, TRANSIT_SPEED_KT)
  mission:SetMissionEgressCoord(egressCoord, transit.egressFt, TRANSIT_SPEED_KT)

  flightGroup:SetFuelLowRTB(false)
  flightGroup:SetFuelLowThreshold(areaSpec.fuelLowPct)

  local runtime = {
    runtimeId = runtimeId, selection = selection, areaSpec = areaSpec, profile = profile, transit = transit,
    template = areaSpec.template, role = role, reliefReason = request.reliefReason, initialFuelPct = areaSpec.initialFuelPct,
    group = group, flightGroup = flightGroup, mission = mission, ingressCoord = ingressCoord, egressCoord = egressCoord,
    trackCoord = trackCoord, gateDistanceNm = gateDistanceNm, transitCallsign = transitCallsign,
    stationIdentityActive = false, onStationAt = nil, egressOrdered = false, egressReason = nil,
    handoffComplete = false, lossHandled = false,
  }

  function flightGroup:OnAfterFuelLow(From, Event, To)
    if runtime.egressOrdered or runtime.lossHandled then return end
    log(string.format("FUEL_LOW runtime=%s demand=%s area=%s profile=%s thresholdPct=%d action=ENSURE_RELIEF_AND_EGRESS",
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
    cancelToEgress(runtime, station.closed and ("DEMAND_" .. tostring(station.closedReason or "ENDED")) or "FUEL_LOW")
  end

  function flightGroup:OnAfterDead(From, Event, To)
    handleRuntimeLoss(runtime, "MOOSE_FLIGHTGROUP_DEAD")
  end

  flightGroup:AddMission(mission)
  flightGroup:TurnOffRadio()
  flightGroup:TurnOffTACAN()
  flightGroup:SwitchCallsign(transitCallsign.id, transitCallsign.number)

  state.runtimesById[runtime.runtimeId] = runtime
  if role == "RELIEF" then
    station.reliefRuntime = runtime
    station.reliefQueued = false
    station.reliefReason = request.reliefReason or "SCHEDULED"
  else
    station.activeRuntime = runtime
    station.activeQueued = false
    station.missionSlotClaimed = true
  end
  state.strategicAdapter:OnMaterialized(selection, runtime)

  log(string.format("MATERIALIZED runtime=%s role=%s demand=%s area=%s profile=%s source=%s group=%s transitCallsign=%s%d stn=%05d missions=%d aircraft=%d",
    runtime.runtimeId, runtime.role, selection.missionDemandId, selection.area, selection.receiverProfile,
    selection.sourceDomain, group:GetName(), transitCallsign.name, transitCallsign.number, transitCallsign.stn,
    countMissionSlots(), countPhysicalRuntimes()))
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
      log(string.format("QUEUE_DROPPED demand=%s role=%s station=%s reason=STATION_CLOSED",
        request.selection.missionDemandId, tostring(request.role), station.key))
    else
      local operational, operationalReason = canMaterializeOperationally(request, station)
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
      if active and active.flightGroup and active.flightGroup:IsAlive() and not active.onStationAt
          and not active.egressOrdered and not active.lossHandled then
        local distanceNm = getDistanceNm(active.flightGroup, active.trackCoord)
        if distanceNm and distanceNm <= TRACK_ENTRY_RADIUS_NM then
          activateStationIdentity(active)
          scheduleCycle(station, active, timestamp)
        end
      end

      if active and active.onStationAt and not active.egressOrdered and not active.lossHandled
          and station.reliefLaunchAt and timestamp >= station.reliefLaunchAt then
        ensureRelief(station, "SCHEDULED")
      end

      local relief = station.reliefRuntime
      if relief and relief.flightGroup and relief.flightGroup:IsAlive() and not relief.egressOrdered and not relief.lossHandled then
        local etaSec, distanceNm = estimateEtaSec(relief.flightGroup, relief.trackCoord)
        local reason = station.reliefReason or relief.reliefReason or "SCHEDULED"
        if etaSec and etaSec <= RELIEF_HANDOVER_ETA_SEC and not station.handoverArmed then
          station.handoverArmed = true
          if active and not active.egressOrdered and not active.lossHandled then
            cancelToEgress(active, reason == "FUEL_LOW" and "FUEL_LOW_RELIEF" or "SCHEDULED_RELIEF")
          end
          log(string.format("RELIEF_FINAL_INGRESS runtime=%s area=%s reason=%s etaSec=%.0f distanceNm=%.1f",
            relief.runtimeId, relief.selection.area, tostring(reason), etaSec, distanceNm or -1))
        end
        if distanceNm and distanceNm <= TRACK_ENTRY_RADIUS_NM then
          promoteReliefOnTrack(station, relief, reason, timestamp)
        end
      end
    end
  end

  for runtimeId, runtime in pairs(state.runtimesById) do
    if runtime.egressOrdered and not runtime.handoffComplete and not runtime.lossHandled then
      local distanceNm = getDistanceNm(runtime.flightGroup, runtime.egressCoord)
      if distanceNm and distanceNm <= HANDOFF_RADIUS_NM then
        runtime.handoffComplete = true
        deactivateStationIdentity(runtime)
        state.strategicAdapter:OnHandoff(runtime.selection, runtime)
        runtime.flightGroup:Despawn(1, true)
        releaseTransitCallsign(runtime)
        state.runtimesById[runtimeId] = nil
        local station = state.stationsByKey[activeKey(runtime.selection)]
        if station then
          if station.activeRuntime == runtime then station.activeRuntime = nil end
          if station.reliefRuntime == runtime then station.reliefRuntime = nil end
        end
        log(string.format("OFFMAP_HANDOFF runtime=%s demand=%s area=%s distanceGateNm=%.2f action=DESPAWN",
          runtime.runtimeId, runtime.selection.missionDemandId, runtime.selection.area, distanceNm))
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

function Controller.SubmitDemand(demand)
  if not state.strategicAdapter then fail("SetStrategicAdapter must be called before SubmitDemand") end
  local selection, reason = Controller.SelectArea(demand)
  if not selection then
    log("REJECTED demand=" .. tostring(demand and demand.missionDemandId) .. " reason=" .. tostring(reason))
    return nil, reason
  end
  local station = getOrCreateStation(selection)
  station.demandsById[selection.missionDemandId] = selection
  station.selection = selection
  station.closed = false
  station.closedReason = nil
  clearQueuedForStation(station, selection)

  local existing = station.activeRuntime
  if existing and existing.flightGroup and existing.flightGroup:IsAlive()
      and not existing.egressOrdered and not existing.lossHandled then
    ensureSchedulers()
    return existing, "ACTIVE_REUSED"
  end
  if station.reliefRuntime and station.reliefRuntime.flightGroup and station.reliefRuntime.flightGroup:IsAlive()
      and not station.reliefRuntime.egressOrdered and not station.reliefRuntime.lossHandled then
    ensureSchedulers()
    return station.reliefRuntime, "RELIEF_INBOUND"
  end
  if station.activeQueued then ensureSchedulers(); return selection, "ACTIVE_QUEUED" end
  station.activeQueued = true
  queueMaterialization(selection, "ACTIVE", nil)
  ensureSchedulers()
  log(string.format("QUEUED demand=%s role=ACTIVE area=%s profile=%s source=%s priority=%s", selection.missionDemandId,
    selection.area, selection.receiverProfile, selection.sourceDomain, tostring(selection.priority)))
  return selection, "QUEUED"
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

  local station = state.stationsByKey[activeKey(selection)]
  if not station then return nil, "NO_STATION" end

  station.demandsById[selection.missionDemandId] = nil
  local replacementSelection = firstDemandSelection(station)
  if replacementSelection then
    station.selection = replacementSelection
    clearQueuedForStation(station, replacementSelection)
    log(string.format("DEMAND_ENDED demand=%s status=%s area=%s profile=%s stationAction=RETAIN_ACTIVE_DEMANDS",
      selection.missionDemandId, terminalStatus, selection.area, selection.receiverProfile))
    return station, "STATION_RETAINED"
  end

  station.selection = selection
  closeStation(station, terminalStatus)
  ensureSchedulers()
  return station, "STATION_CLOSED"
end

function Controller.GetActive(area, receiverProfile)
  local station = state.stationsByKey[tostring(area):upper() .. ":" .. tostring(receiverProfile):upper()]
  return station and station.activeRuntime or nil
end

function Controller.GetStation(area, receiverProfile)
  return state.stationsByKey[tostring(area):upper() .. ":" .. tostring(receiverProfile):upper()]
end

function Controller.GetRuntimeCounts()
  return {
    supportMissions = countMissionSlots(),
    supportAircraft = countPhysicalRuntimes(),
    queued = #state.queue,
  }
end

function Controller.GetConfig()
  return {
    mooseCommit = MOOSE_COMMIT, mooseSha256 = MOOSE_SHA256, sourceSpawnIntervalSec = SOURCE_SPAWN_INTERVAL_SEC,
    handoffRadiusNm = HANDOFF_RADIUS_NM, trackEntryRadiusNm = TRACK_ENTRY_RADIUS_NM, stationCycleSec = STATION_CYCLE_SEC,
    reliefHandoverEtaSec = RELIEF_HANDOVER_ETA_SEC, transitSpeedKt = TRANSIT_SPEED_KT, transitStnSlots = #TRANSIT_CALLSIGNS,
    maxConcurrentSupportMissions = MAX_CONCURRENT_SUPPORT_MISSIONS,
    maxAircraftPerSupportMission = MAX_AIRCRAFT_PER_SUPPORT_MISSION,
    maxConcurrentSupportAircraft = MAX_CONCURRENT_SUPPORT_AIRCRAFT,
  }
end

OMW.AAR = Controller
log("LOADED MOOSE commit=" .. MOOSE_COMMIT .. " sha256=" .. MOOSE_SHA256)
return Controller
