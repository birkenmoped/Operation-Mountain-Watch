-- Operation Mountain Watch - production AAR demand and tanker lifecycle controller.
--
-- MOOSE-first boundary:
--   * OMW selects the operational AAR area/profile from MissionDemand.
--   * MOOSE SPAWN/FLIGHTGROUP/AUFTRAG/SCHEDULER execute the physical lifecycle.
--   * Strategic availability remains external and must be supplied by CampaignState
--     through SetStrategicAdapter before SubmitDemand is used.

OMW = OMW or {}

local Controller = {}

local TAG = "[OMW][AAR.Controller]"
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"
local SOURCE_SPAWN_INTERVAL_SEC = 60
local HANDOFF_RADIUS_NM = 10
local DISPATCH_INTERVAL_SEC = 5
local TRANSIT_SPEED_KT = 300
local LEG_NM = 35

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
    lat = 33.44219603, lon = 65.46466360, headingDeg = 63.607,
    sourceDomain = "AL_UDEID", transitProfile = "AL_UDEID_NORTH_HIGH",
    frequencyMHz = 272.600, tacanChannel = 58, tacanIdent = "MIL",
    fuelLowPct = 27, initialFuelPct = 90,
    profiles = { SLOW = { altitudeFt = 22000, speedKt = 220 } },
  },
  KRUSTY = {
    template = "OMW_AAR_KC135_KRUSTY",
    lat = 32.65123012, lon = 68.15946309, headingDeg = 212.350,
    sourceDomain = "AL_UDEID", transitProfile = "AL_UDEID_NORTH_HIGH",
    frequencyMHz = 258.300, tacanChannel = 42, tacanIdent = "KRU",
    fuelLowPct = 27, initialFuelPct = 90,
    profiles = { SLOW = { altitudeFt = 22000, speedKt = 220 } },
  },
  PATTY = {
    template = "OMW_AAR_KC135_PATTY",
    lat = 34.97134133, lon = 71.47789605, headingDeg = 89.662,
    sourceDomain = "MANAS", transitProfile = "MANAS_EAST_HIGH",
    frequencyMHz = 237.300, tacanChannel = 48, tacanIdent = "PAT",
    fuelLowPct = 21, initialFuelPct = 96,
    profiles = { SLOW = { altitudeFt = 24000, speedKt = 220 } },
  },
  NELSON = {
    template = "OMW_AAR_KC135_NELSON",
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
  activeByKey = {},
  lastSpawnAtBySource = {},
  spawnersByArea = {},
  dispatcher = nil,
  handoffMonitor = nil,
}

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

local function getSpawner(area, template)
  local spawner = state.spawnersByArea[area]
  if not spawner then
    spawner = SPAWN:New(template)
    state.spawnersByArea[area] = spawner
  end
  return spawner
end

local function materialize(selection)
  requireMoose()
  local areaSpec = AREAS[selection.area]
  local profile = areaSpec.profiles[selection.receiverProfile]
  local transit = TRANSIT[areaSpec.transitProfile]
  local gate = GATES[areaSpec.sourceDomain]
  local template = areaSpec.template
  local key = activeKey(selection)

  local existing = state.activeByKey[key]
  if existing and existing.flightGroup and existing.flightGroup:IsAlive() then
    log(string.format("REUSE demand=%s area=%s profile=%s group=%s",
      selection.missionDemandId, selection.area, selection.receiverProfile, existing.group:GetName()))
    return existing
  end

  local spawnCoord = COORDINATE:NewFromLLDD(gate.lat, gate.lon)
  spawnCoord:SetAltitude(UTILS.FeetToMeters(transit.ingressFt), true)
  local ingressCoord = COORDINATE:NewFromLLDD(gate.lat, gate.lon)
  local egressCoord = COORDINATE:NewFromLLDD(gate.lat, gate.lon)
  local trackCoord = COORDINATE:NewFromLLDD(areaSpec.lat, areaSpec.lon)
  local spawnHeadingDeg = spawnCoord:HeadingTo(trackCoord)

  local spawner = getSpawner(selection.area, template)
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
  mission:SetRadio(areaSpec.frequencyMHz, 0)
  mission:SetTACAN(areaSpec.tacanChannel, areaSpec.tacanIdent, nil, "Y")
  mission:SetMissionIngressCoord(ingressCoord, transit.ingressFt, TRANSIT_SPEED_KT)
  mission:SetMissionEgressCoord(egressCoord, transit.egressFt, TRANSIT_SPEED_KT)

  flightGroup:SetFuelLowRTB(false)
  flightGroup:SetFuelLowThreshold(areaSpec.fuelLowPct)

  local runtime = {
    selection = selection,
    areaSpec = areaSpec,
    profile = profile,
    transit = transit,
    template = template,
    initialFuelPct = areaSpec.initialFuelPct,
    group = group,
    flightGroup = flightGroup,
    mission = mission,
    ingressCoord = ingressCoord,
    egressCoord = egressCoord,
    trackCoord = trackCoord,
    egressOrdered = false,
    handoffComplete = false,
  }

  function flightGroup:OnAfterFuelLow(From, Event, To)
    if runtime.egressOrdered then
      return
    end
    runtime.egressOrdered = true
    log(string.format(
      "FUEL_LOW demand=%s area=%s profile=%s thresholdPct=%d action=CANCEL_TO_EGRESS",
      selection.missionDemandId, selection.area, selection.receiverProfile, areaSpec.fuelLowPct
    ))
    mission:Cancel()
  end

  flightGroup:AddMission(mission)
  state.activeByKey[key] = runtime
  state.strategicAdapter:OnMaterialized(selection, runtime)

  log(string.format(
    "MATERIALIZED demand=%s area=%s profile=%s source=%s template=%s group=%s ingressFL=%d trackAltFt=%d trackSpeedKt=%d egressFL=%d radioMHz=%.3f tacan=%dY fuelLowPct=%d expectedInitialFuelPct=%d",
    selection.missionDemandId,
    selection.area,
    selection.receiverProfile,
    selection.sourceDomain,
    template,
    group:GetName(),
    transit.ingressFt / 100,
    profile.altitudeFt,
    profile.speedKt,
    transit.egressFt / 100,
    areaSpec.frequencyMHz,
    areaSpec.tacanChannel,
    areaSpec.fuelLowPct,
    areaSpec.initialFuelPct
  ))

  return runtime
end

local function canSpawnSource(sourceDomain, timestamp)
  local last = state.lastSpawnAtBySource[sourceDomain]
  return last == nil or (timestamp - last) >= SOURCE_SPAWN_INTERVAL_SEC
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
        materialize(request.selection)
        state.lastSpawnAtBySource[source] = timestamp
        spawnedSource[source] = true
      else
        log(string.format("DEFERRED demand=%s source=%s reason=%s",
          request.selection.missionDemandId, source, tostring(reason or "STRATEGIC_UNAVAILABLE")))
        remaining[#remaining + 1] = request
      end
    else
      remaining[#remaining + 1] = request
    end
  end

  state.queue = remaining
end

local function monitorHandoffs()
  for key, runtime in pairs(state.activeByKey) do
    if runtime.egressOrdered and not runtime.handoffComplete then
      local distanceNm = getDistanceNm(runtime.flightGroup, runtime.egressCoord)
      if distanceNm and distanceNm <= HANDOFF_RADIUS_NM then
        runtime.handoffComplete = true
        log(string.format(
          "OFFMAP_HANDOFF demand=%s area=%s profile=%s distanceGateNm=%.2f action=DESPAWN",
          runtime.selection.missionDemandId,
          runtime.selection.area,
          runtime.selection.receiverProfile,
          distanceNm
        ))
        runtime.flightGroup:Despawn(1, true)
        state.strategicAdapter:OnHandoff(runtime.selection, runtime)
        state.activeByKey[key] = nil
      end
    end
  end
end

local function ensureSchedulers()
  requireMoose()
  if not state.dispatcher then
    state.dispatcher = SCHEDULER:New(nil, processQueue, {}, 0, DISPATCH_INTERVAL_SEC)
  end
  if not state.handoffMonitor then
    state.handoffMonitor = SCHEDULER:New(nil, monitorHandoffs, {}, DISPATCH_INTERVAL_SEC, DISPATCH_INTERVAL_SEC)
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

  local key = activeKey(selection)
  local existing = state.activeByKey[key]
  if existing and existing.flightGroup and existing.flightGroup:IsAlive() then
    log(string.format("DEMAND_SATISFIED_BY_ACTIVE demand=%s area=%s profile=%s group=%s",
      selection.missionDemandId, selection.area, selection.receiverProfile, existing.group:GetName()))
    return existing, "ACTIVE_REUSED"
  end

  state.queue[#state.queue + 1] = { selection = selection }
  ensureSchedulers()
  log(string.format(
    "QUEUED demand=%s area=%s profile=%s source=%s priority=%s",
    selection.missionDemandId,
    selection.area,
    selection.receiverProfile,
    selection.sourceDomain,
    tostring(selection.priority)
  ))
  return selection, "QUEUED"
end

function Controller.GetActive(area, receiverProfile)
  return state.activeByKey[tostring(area):upper() .. ":" .. tostring(receiverProfile):upper()]
end

function Controller.GetConfig()
  return {
    mooseCommit = MOOSE_COMMIT,
    mooseSha256 = MOOSE_SHA256,
    sourceSpawnIntervalSec = SOURCE_SPAWN_INTERVAL_SEC,
    handoffRadiusNm = HANDOFF_RADIUS_NM,
  }
end

OMW.AAR = Controller
log("LOADED MOOSE commit=" .. MOOSE_COMMIT .. " sha256=" .. MOOSE_SHA256)

return Controller