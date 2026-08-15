-- Operation Mountain Watch - production AAR demand and tanker lifecycle controller.
--
-- MOOSE-first boundary:
--   * OMW selects the operational AAR area/profile from MissionDemand.
--   * MOOSE SPAWN/FLIGHTGROUP/AUFTRAG/SCHEDULER execute the physical lifecycle.
--   * OMW only orchestrates station ownership, scheduled relief and the FuelLow fallback.
--   * Strategic availability remains external and must be supplied by CampaignState
--     through SetStrategicAdapter before SubmitDemand is used.

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
    profiles = {
      SLOW = { altitudeFt = 22000, speedKt = 220 },
      FAST = { altitudeFt = 25000, speedKt = 300 },
    },
  },
  MOE = {
    template = "OMW_AAR_KC135_MOE",
    callsignId = CALLSIGN.Tanker.Texaco, callsignName = "Texaco", callsignMinor = 4, callsignMajor = 1,
    lat = 35.07603944, lon = 65.32603438, headingDeg = 304.682,
    sourceDomain = "MANAS", transitProfile = "MANAS_WEST_HIGH",
    frequencyMHz = 243.400, tacanChannel = 52, tacanIdent = "MOE",
    fuelLowPct = 22, initialFuelPct = 96,
    profiles = {
      SLOW = { altitudeFt = 24000, speedKt = 220 },
      FAST = { altitudeFt = 27000, speedKt = 300 },
    },
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

local state = {
  strategicAdapter = nil,
  queue = {},
  stationsByKey = {},
  runtimesById = {},
  lastSpawnAtBySource = {},
  spawnersByArea = {},
  dispatcher = nil,
  stationMonitor = nil,
  nextRuntimeId = 0,
}

local ensureRelief

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function now()
  return timer.getAbsTime()
end

local function requireMoose()
  if not SPAWN or not FLIGHTGROUP or not AUFTRAG or not COORDINATE or not SCHEDULER or not UTILS then
    fail("required MOOSE classes are unavailable")
  end
  if not CALLSIGN or not CALLSIGN.Tanker then
    fail("required MOOSE tanker callsign enumerator is unavailable")
  end
  if not Unit or not Unit.RefuelingSystem or Unit.RefuelingSystem.BOOM_AND_RECEPTACLE == nil then
    fail("DCS refueling-system enum is unavailable")
  end
end

local function normalizeDemand(demand)
  if type(demand) ~= "table" then
    fail("MissionDemand must be a table")
  end
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

  if d.operationsArea == "EAST" and d.supportMode == "SUPPORT" and d.receiverProfile == "SLOW" then
    area = "PATTY"
  elseif d.operationsArea == "SOUTH_CENTRAL" and d.supportMode == "RECOVERY" and d.receiverProfile == "SLOW" then
    area = "MILHOUSE"
  elseif d.operationsArea == "SOUTHEAST" and d.supportMode == "RECOVERY" and d.receiverProfile == "SLOW" then
    area = "KRUSTY"
  elseif d.operationsArea == "NORTHEAST" and d.supportMode == "SUPPORT" and d.receiverProfile == "FAST" then
    area = "NELSON"
  elseif d.operationsArea == "CENTRAL" then
    area = "MOE"
  elseif d.operationsArea == "WEST" then
    area = "LISA"
  else
    return nil, string.format(
      "NO_AAR_POLICY receiverProfile=%s operationsArea=%s supportMode=%s",
      d.receiverProfile, d.operationsArea, d.supportMode
    )
  end

  local areaSpec = AREAS[area]
  local profile = areaSpec.profiles[d.receiverProfile]
  if not profile then
    return nil, string.format("AREA_PROFILE_UNAVAILABLE area=%s receiverProfile=%s", area, d.receiverProfile)
  end

  return {
    missionDemandId = d.missionDemandId,
    receiverProfile = d.receiverProfile,
    operationsArea = d.operationsArea,
    supportMode = d.supportMode,
    priority = d.priority,
    area = area,
    sourceDomain = areaSpec.sourceDomain,
    transitProfile = areaSpec.transitProfile,
  }
end

function Controller.SetStrategicAdapter(adapter)
  if type(adapter) ~= "table"
      or type(adapter.CanMaterialize) ~= "function"
      or type(adapter.OnMaterialized) ~= "function"
      or type(adapter.OnHandoff) ~= "function" then
    fail("strategic adapter requires CanMaterialize, OnMaterialized and OnHandoff")
  end
  state.strategicAdapter = adapter
  return Controller
end

local function activeKey(selection)
  return selection.area .. ":" .. selection.receiverProfile
end

local function getOrCreateStation(selection)
  local key = activeKey(selection)
  local station = state.stationsByKey[key]
  if not station then
    station = {
      key = key,
      selection = selection,
      activeRuntime = nil,
      activeQueued = false,
      reliefRuntime = nil,
      reliefQueued = false,
      reliefReason = nil,
      nextPlannedHandoverAt = nil,
      reliefLaunchAt = nil,
    }
    state.stationsByKey[key] = station
  end
  return station
end

local function getDistanceNm(flightGroup, coordinate)
  if not flightGroup or not flightGroup:IsAlive() then
    return nil
  end
  local current = flightGroup:GetCoordinate()
  if not current then
    return nil
  end
  return current:Get2DDistance(coordinate) / 1852
end

local function estimateEtaSec(flightGroup, coordinate)
  local distanceNm = getDistanceNm(flightGroup, coordinate)
  if not distanceNm then
    return nil, nil
  end
  return (distanceNm / TRANSIT_SPEED_KT) * 3600, distanceNm
end

local function getSpawner(area, areaSpec)
  local spawner = state.spawnersByArea[area]
  if not spawner then
    spawner = SPAWN:New(areaSpec.template)
    spawner:InitCallSign(areaSpec.callsignId, areaSpec.callsignName, areaSpec.callsignMinor, areaSpec.callsignMajor)
    state.spawnersByArea[area] = spawner
  end
  return spawner
end

local function cancelToEgress(runtime, reason)
  if runtime.egressOrdered then
    return false
  end
  runtime.egressOrdered = true
  runtime.egressReason = reason
  runtime.mission:Cancel()
  log(string.format(
    "EGRESS_ORDERED runtime=%s demand=%s area=%s profile=%s reason=%s",
    runtime.runtimeId,
    runtime.selection.missionDemandId,
    runtime.selection.area,
    runtime.selection.receiverProfile,
    tostring(reason)
  ))
  return true
end

local function activateStationIdentity(runtime)
  if runtime.stationIdentityActive then
    return
  end
  local areaSpec = runtime.areaSpec
  runtime.flightGroup:SwitchRadio(areaSpec.frequencyMHz, 0)
  runtime.flightGroup:SwitchTACAN(areaSpec.tacanChannel, areaSpec.tacanIdent, nil, "Y")
  runtime.stationIdentityActive = true
  log(string.format(
    "STATION_IDENTITY_ACTIVE runtime=%s area=%s radioMHz=%.3f tacan=%dY ident=%s",
    runtime.runtimeId,
    runtime.selection.area,
    areaSpec.frequencyMHz,
    areaSpec.tacanChannel,
    areaSpec.tacanIdent
  ))
end

local function scheduleCycle(station, runtime, timestamp)
  local gateDistanceNm = runtime.gateDistanceNm
  local transitSec = (gateDistanceNm / TRANSIT_SPEED_KT) * 3600
  local leadFromHandoverSec = math.max(0, transitSec - RELIEF_HANDOVER_ETA_SEC)

  runtime.onStationAt = timestamp
  station.nextPlannedHandoverAt = timestamp + STATION_CYCLE_SEC
  station.reliefLaunchAt = station.nextPlannedHandoverAt - leadFromHandoverSec

  log(string.format(
    "ON_STATION runtime=%s area=%s profile=%s cycleSec=%d gateDistanceNm=%.1f reliefLaunchInSec=%.0f plannedHandoverInSec=%d",
    runtime.runtimeId,
    runtime.selection.area,
    runtime.selection.receiverProfile,
    STATION_CYCLE_SEC,
    gateDistanceNm,
    station.reliefLaunchAt - timestamp,
    STATION_CYCLE_SEC
  ))
end

local function promoteRelief(station, relief, reason)
  local outgoing = station.activeRuntime
  if outgoing == relief then
    return
  end

  station.reliefRuntime = nil
  station.reliefQueued = false
  station.reliefReason = nil
  station.nextPlannedHandoverAt = nil
  station.reliefLaunchAt = nil

  relief.role = "ACTIVE"
  relief.reliefReason = reason
  activateStationIdentity(relief)
  station.activeRuntime = relief

  if outgoing and outgoing ~= relief then
    cancelToEgress(outgoing, reason == "FUEL_LOW" and "FUEL_LOW_RELIEF" or "SCHEDULED_RELIEF")
  end

  log(string.format(
    "RELIEF_PROMOTED runtime=%s area=%s profile=%s reason=%s outgoingRuntime=%s",
    relief.runtimeId,
    relief.selection.area,
    relief.selection.receiverProfile,
    tostring(reason),
    outgoing and outgoing.runtimeId or "NONE"
  ))
end

local function materialize(request)
  requireMoose()
  local selection = request.selection
  local role = request.role or "ACTIVE"
  local areaSpec = AREAS[selection.area]
  local profile = areaSpec.profiles[selection.receiverProfile]
  local transit = TRANSIT[areaSpec.transitProfile]
  local gate = GATES[areaSpec.sourceDomain]
  local template = areaSpec.template
  local station = getOrCreateStation(selection)

  local spawnCoord = COORDINATE:NewFromLLDD(gate.lat, gate.lon)
  spawnCoord:SetAltitude(UTILS.FeetToMeters(transit.ingressFt), true)
  local ingressCoord = COORDINATE:NewFromLLDD(gate.lat, gate.lon)
  local egressCoord = COORDINATE:NewFromLLDD(gate.lat, gate.lon)
  local trackCoord = COORDINATE:NewFromLLDD(areaSpec.lat, areaSpec.lon)
  local spawnHeadingDeg = spawnCoord:HeadingTo(trackCoord)
  local gateDistanceNm = spawnCoord:Get2DDistance(trackCoord) / 1852

  local spawner = getSpawner(selection.area, areaSpec)
  spawner:InitHeading(spawnHeadingDeg)
  spawner:InitSpeedKnots(TRANSIT_SPEED_KT)
  local group = spawner:SpawnFromCoordinate(spawnCoord)
  if not group then
    fail("failed to materialize tanker template=" .. tostring(template))
  end

  local flightGroup = FLIGHTGROUP:New(group)
  if not flightGroup then
    fail("failed to create FLIGHTGROUP group=" .. tostring(group:GetName()))
  end

  local mission = AUFTRAG:NewTANKER(
    trackCoord,
    profile.altitudeFt,
    profile.speedKt,
    areaSpec.headingDeg,
    LEG_NM,
    Unit.RefuelingSystem.BOOM_AND_RECEPTACLE
  )

  if role == "ACTIVE" then
    mission:SetRadio(areaSpec.frequencyMHz, 0)
    mission:SetTACAN(areaSpec.tacanChannel, areaSpec.tacanIdent, nil, "Y")
  end

  mission:SetMissionIngressCoord(ingressCoord, transit.ingressFt, TRANSIT_SPEED_KT)
  mission:SetMissionEgressCoord(egressCoord, transit.egressFt, TRANSIT_SPEED_KT)

  flightGroup:SetFuelLowRTB(false)
  flightGroup:SetFuelLowThreshold(areaSpec.fuelLowPct)

  state.nextRuntimeId = state.nextRuntimeId + 1
  local runtime = {
    runtimeId = string.format("AAR-%04d", state.nextRuntimeId),
    selection = selection,
    areaSpec = areaSpec,
    profile = profile,
    transit = transit,
    template = template,
    role = role,
    reliefReason = request.reliefReason,
    initialFuelPct = areaSpec.initialFuelPct,
    group = group,
    flightGroup = flightGroup,
    mission = mission,
    ingressCoord = ingressCoord,
    egressCoord = egressCoord,
    trackCoord = trackCoord,
    gateDistanceNm = gateDistanceNm,
    stationIdentityActive = role == "ACTIVE",
    onStationAt = nil,
    egressOrdered = false,
    egressReason = nil,
    handoffComplete = false,
  }

  function flightGroup:OnAfterFuelLow(From, Event, To)
    if runtime.egressOrdered then
      return
    end

    log(string.format(
      "FUEL_LOW runtime=%s demand=%s area=%s profile=%s thresholdPct=%d action=ENSURE_RELIEF_AND_EGRESS",
      runtime.runtimeId,
      selection.missionDemandId,
      selection.area,
      selection.receiverProfile,
      areaSpec.fuelLowPct
    ))

    if station.activeRuntime == runtime then
      station.nextPlannedHandoverAt = nil
      station.reliefLaunchAt = nil
      ensureRelief(station, "FUEL_LOW")
    elseif station.reliefRuntime == runtime then
      station.reliefRuntime = nil
      station.reliefQueued = false
      station.reliefReason = nil
      if station.activeRuntime and station.activeRuntime.flightGroup and station.activeRuntime.flightGroup:IsAlive() then
        ensureRelief(station, "FUEL_LOW")
      end
    end
    cancelToEgress(runtime, "FUEL_LOW")
  end

  flightGroup:AddMission(mission)
  if role == "RELIEF" then
    flightGroup:TurnOffRadio()
    flightGroup:TurnOffTACAN()
  end
  state.runtimesById[runtime.runtimeId] = runtime

  if role == "RELIEF" then
    station.reliefRuntime = runtime
    station.reliefQueued = false
    station.reliefReason = request.reliefReason or "SCHEDULED"
  else
    station.activeQueued = false
    station.activeRuntime = runtime
  end

  state.strategicAdapter:OnMaterialized(selection, runtime)

  log(string.format(
    "MATERIALIZED runtime=%s role=%s reliefReason=%s demand=%s area=%s profile=%s source=%s template=%s group=%s callsign=%s%d%d ingressFL=%d trackAltFt=%d trackSpeedKt=%d egressFL=%d radioMHz=%.3f tacan=%dY fuelLowPct=%d expectedInitialFuelPct=%d gateDistanceNm=%.1f",
    runtime.runtimeId,
    runtime.role,
    tostring(runtime.reliefReason),
    selection.missionDemandId,
    selection.area,
    selection.receiverProfile,
    selection.sourceDomain,
    template,
    group:GetName(),
    areaSpec.callsignName,
    areaSpec.callsignMinor,
    areaSpec.callsignMajor,
    transit.ingressFt / 100,
    profile.altitudeFt,
    profile.speedKt,
    transit.egressFt / 100,
    areaSpec.frequencyMHz,
    areaSpec.tacanChannel,
    areaSpec.fuelLowPct,
    areaSpec.initialFuelPct,
    gateDistanceNm
  ))

  return runtime
end

local function canSpawnSource(sourceDomain, timestamp)
  local last = state.lastSpawnAtBySource[sourceDomain]
  return last == nil or (timestamp - last) >= SOURCE_SPAWN_INTERVAL_SEC
end

local function queueMaterialization(selection, role, reliefReason)
  state.queue[#state.queue + 1] = {
    selection = selection,
    role = role,
    reliefReason = reliefReason,
  }
end

ensureRelief = function(station, reason)
  if station.reliefRuntime and station.reliefRuntime.flightGroup and station.reliefRuntime.flightGroup:IsAlive() then
    if reason == "FUEL_LOW" and station.reliefReason ~= "FUEL_LOW" then
      station.reliefReason = "FUEL_LOW"
      station.reliefRuntime.reliefReason = "FUEL_LOW"
      log(string.format(
        "RELIEF_PROMOTED_TO_URGENT runtime=%s area=%s profile=%s",
        station.reliefRuntime.runtimeId,
        station.selection.area,
        station.selection.receiverProfile
      ))
    end
    return station.reliefRuntime, false
  end

  if station.reliefQueued then
    if reason == "FUEL_LOW" then
      station.reliefReason = "FUEL_LOW"
      for _, request in ipairs(state.queue) do
        if request.role == "RELIEF" and activeKey(request.selection) == station.key then
          request.reliefReason = "FUEL_LOW"
        end
      end
    end
    return nil, false
  end

  station.reliefQueued = true
  station.reliefReason = reason
  queueMaterialization(station.selection, "RELIEF", reason)
  log(string.format(
    "RELIEF_QUEUED area=%s profile=%s reason=%s",
    station.selection.area,
    station.selection.receiverProfile,
    tostring(reason)
  ))
  return nil, true
end

local function processQueue()
  if #state.queue == 0 then
    return
  end

  local timestamp = now()
  local spawnedSource = {}
  local remaining = {}

  for _, request in ipairs(state.queue) do
    local source = request.selection.sourceDomain
    if not spawnedSource[source] and canSpawnSource(source, timestamp) then
      local allowed, reason = state.strategicAdapter:CanMaterialize(request.selection)
      if allowed then
        materialize(request)
        state.lastSpawnAtBySource[source] = timestamp
        spawnedSource[source] = true
      else
        log(string.format("DEFERRED demand=%s role=%s source=%s reason=%s",
          request.selection.missionDemandId,
          tostring(request.role),
          source,
          tostring(reason or "STRATEGIC_UNAVAILABLE")))
        remaining[#remaining + 1] = request
      end
    else
      remaining[#remaining + 1] = request
    end
  end

  state.queue = remaining
end

local function monitorStations()
  local timestamp = now()

  for _, station in pairs(state.stationsByKey) do
    local active = station.activeRuntime

    if active and active.flightGroup and active.flightGroup:IsAlive() and not active.onStationAt and not active.egressOrdered then
      local distanceNm = getDistanceNm(active.flightGroup, active.trackCoord)
      if distanceNm and distanceNm <= TRACK_ENTRY_RADIUS_NM then
        scheduleCycle(station, active, timestamp)
      end
    end

    if active and active.onStationAt and not active.egressOrdered
        and station.reliefLaunchAt and timestamp >= station.reliefLaunchAt then
      ensureRelief(station, "SCHEDULED")
    end

    local relief = station.reliefRuntime
    if relief and relief.flightGroup and relief.flightGroup:IsAlive() and not relief.egressOrdered then
      local etaSec, distanceNm = estimateEtaSec(relief.flightGroup, relief.trackCoord)
      if etaSec and etaSec <= RELIEF_HANDOVER_ETA_SEC then
        local reason = station.reliefReason or relief.reliefReason or "SCHEDULED"
        log(string.format(
          "RELIEF_HANDOVER_TRIGGER runtime=%s area=%s profile=%s reason=%s etaSec=%.0f distanceNm=%.1f",
          relief.runtimeId,
          relief.selection.area,
          relief.selection.receiverProfile,
          tostring(reason),
          etaSec,
          distanceNm
        ))
        promoteRelief(station, relief, reason)
      end
    end
  end

  for runtimeId, runtime in pairs(state.runtimesById) do
    if runtime.egressOrdered and not runtime.handoffComplete then
      local distanceNm = getDistanceNm(runtime.flightGroup, runtime.egressCoord)
      if distanceNm and distanceNm <= HANDOFF_RADIUS_NM then
        runtime.handoffComplete = true
        log(string.format(
          "OFFMAP_HANDOFF runtime=%s demand=%s area=%s profile=%s distanceGateNm=%.2f action=DESPAWN",
          runtime.runtimeId,
          runtime.selection.missionDemandId,
          runtime.selection.area,
          runtime.selection.receiverProfile,
          distanceNm
        ))
        runtime.flightGroup:Despawn(1, true)
        state.strategicAdapter:OnHandoff(runtime.selection, runtime)
        state.runtimesById[runtimeId] = nil

        local station = state.stationsByKey[activeKey(runtime.selection)]
        if station then
          if station.activeRuntime == runtime then
            station.activeRuntime = nil
          end
          if station.reliefRuntime == runtime then
            station.reliefRuntime = nil
          end
        end
      end
    end
  end
end

local function ensureSchedulers()
  requireMoose()
  if not state.dispatcher then
    state.dispatcher = SCHEDULER:New(nil, processQueue, {}, 0, DISPATCH_INTERVAL_SEC)
  end
  if not state.stationMonitor then
    state.stationMonitor = SCHEDULER:New(nil, monitorStations, {}, DISPATCH_INTERVAL_SEC, DISPATCH_INTERVAL_SEC)
  end
end

function Controller.SubmitDemand(demand)
  if not state.strategicAdapter then
    fail("SetStrategicAdapter must be called before SubmitDemand")
  end

  local selection, reason = Controller.SelectArea(demand)
  if not selection then
    log("REJECTED demand=" .. tostring(demand and demand.missionDemandId) .. " reason=" .. tostring(reason))
    return nil, reason
  end

  local station = getOrCreateStation(selection)
  station.selection = selection

  local existing = station.activeRuntime
  if existing and existing.flightGroup and existing.flightGroup:IsAlive() then
    log(string.format("DEMAND_SATISFIED_BY_ACTIVE demand=%s area=%s profile=%s runtime=%s group=%s",
      selection.missionDemandId, selection.area, selection.receiverProfile, existing.runtimeId, existing.group:GetName()))
    ensureSchedulers()
    return existing, "ACTIVE_REUSED"
  end

  if station.reliefRuntime and station.reliefRuntime.flightGroup and station.reliefRuntime.flightGroup:IsAlive() then
    log(string.format("DEMAND_SATISFIED_BY_RELIEF demand=%s area=%s profile=%s runtime=%s",
      selection.missionDemandId, selection.area, selection.receiverProfile, station.reliefRuntime.runtimeId))
    ensureSchedulers()
    return station.reliefRuntime, "RELIEF_INBOUND"
  end

  if station.activeQueued then
    ensureSchedulers()
    return selection, "ACTIVE_QUEUED"
  end

  station.activeQueued = true
  queueMaterialization(selection, "ACTIVE", nil)
  ensureSchedulers()
  log(string.format(
    "QUEUED demand=%s role=ACTIVE area=%s profile=%s source=%s priority=%s",
    selection.missionDemandId,
    selection.area,
    selection.receiverProfile,
    selection.sourceDomain,
    tostring(selection.priority)
  ))
  return selection, "QUEUED"
end

function Controller.GetActive(area, receiverProfile)
  local station = state.stationsByKey[tostring(area):upper() .. ":" .. tostring(receiverProfile):upper()]
  return station and station.activeRuntime or nil
end

function Controller.GetStation(area, receiverProfile)
  return state.stationsByKey[tostring(area):upper() .. ":" .. tostring(receiverProfile):upper()]
end

function Controller.GetConfig()
  return {
    mooseCommit = MOOSE_COMMIT,
    mooseSha256 = MOOSE_SHA256,
    sourceSpawnIntervalSec = SOURCE_SPAWN_INTERVAL_SEC,
    handoffRadiusNm = HANDOFF_RADIUS_NM,
    trackEntryRadiusNm = TRACK_ENTRY_RADIUS_NM,
    stationCycleSec = STATION_CYCLE_SEC,
    reliefHandoverEtaSec = RELIEF_HANDOVER_ETA_SEC,
    transitSpeedKt = TRANSIT_SPEED_KT,
  }
end

OMW.AAR = Controller
log("LOADED MOOSE commit=" .. MOOSE_COMMIT .. " sha256=" .. MOOSE_SHA256)

return Controller
