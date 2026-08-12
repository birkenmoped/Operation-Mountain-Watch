-- Operation Mountain Watch - airborne gun/ammunition lifecycle and Kandahar parking correlation test.
-- MOOSE-first. Real DCS expenditure; read-only STORAGE and parking observation.

local TAG = "[OMW][AirborneAmmoParkingCorrelation]"
local TEST_ID = "AIRBORNE-AMMO-PARKING-CORRELATION-3"
local START_DELAY_S = 20
local LANE_STAGGER_S = 5
local POST_RETURN_OBSERVE_S = 30
local ASSIGN_TIMEOUT_S = 600
local LIFECYCLE_TIMEOUT_S = 3600
local GLOBAL_TIMEOUT_S = 7200
local ORBIT_DURATION_S = 30
local TARGET_BEARING_OFFSETS = { 0, 30, -30, 60, -60, 90, -90, 120, -120, 180 }
local TARGET_DISTANCE_OFFSETS_M = { 0, 2000, -2000, 4000, -4000 }
local TARGET_FLAT_RADIUS_M = 35
local TARGET_MAX_STEEPNESS_PERCENT = 8
local STRAFE_ALTITUDE_FT = 1200
local STRAFE_LENGTH_M = 500
local TARGET_TEMPLATE = "TPL_TEST_RED_VEHICLE_02_01"
local GUN_WEAPON_TYPE = ENUMS.WeaponFlag.GunPod + ENUMS.WeaponFlag.BuiltInCannon
local PARKING_MATCH_MAX_DISTANCE_M = 5

local CASES = {
  {
    id = "KAF_A10C_GAU8",
    evidenceRole = "GATE",
    foundation = "Kandahar",
    wing = "Main",
    squadron = "A10C",
    template = "TPL_AIR_US_KAF_A10C_CAS_2SHIP",
    storageName = "Kandahar",
    targetBearing = 45,
    targetDistanceM = 20000,
  },
  {
    id = "BGRM_F16C_M61",
    evidenceRole = "DISCOVERY",
    foundation = "Bagram",
    wing = "USAF",
    squadron = "F16C",
    template = "TPL_AIR_US_BGRM_F16C_CAS_2SHIP",
    storageName = "Bagram",
    targetBearing = 315,
    targetDistanceM = 20000,
  },
  {
    id = "BGRM_F15E_M61",
    evidenceRole = "DISCOVERY",
    foundation = "Bagram",
    wing = "USAF",
    squadron = "F15E",
    template = "TPL_AIR_US_BGRM_F15E_CAS_2SHIP",
    storageName = "Bagram",
    targetBearing = 45,
    targetDistanceM = 20000,
  },
  {
    id = "JBAD_UH60_GUNS",
    evidenceRole = "DISCOVERY",
    foundation = "Jalalabad",
    squadron = "UH60",
    template = "TPL_AIR_US_JBAD_UH60_MEDEVAC_1SHIP",
    storageName = "Jalalabad",
    targetBearing = 180,
    targetDistanceM = 12000,
  },
  {
    id = "JBAD_CH47_GUNS",
    evidenceRole = "DISCOVERY",
    foundation = "Jalalabad",
    squadron = "CH47",
    template = "TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP",
    storageName = "Jalalabad",
    targetBearing = 225,
    targetDistanceM = 12000,
  },
  {
    id = "JBAD_OH58D_M3P",
    evidenceRole = "REGRESSION",
    foundation = "Jalalabad",
    squadron = "OH58D",
    template = "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP",
    storageName = "Jalalabad",
    targetBearing = 135,
    targetDistanceM = 12000,
  },
  {
    id = "SHND_AH64D_M230",
    evidenceRole = "REGRESSION",
    foundation = "Shindand",
    squadron = "AH64D",
    template = "TPL_AIR_US_SHND_AH64D_CAS_2SHIP",
    storageName = "Shindand Heliport",
    targetBearing = 225,
    targetDistanceM = 12000,
  },
}

local PARKING_NODES = {
  {
    node = "Kandahar",
    prefix = "KANDAHAR_",
    excludePrefix = "KANDAHAR_HP_",
  },
  {
    node = "Kandahar Heliport",
    prefix = "KANDAHAR_HP_",
  },
}

local runtime = {
  finished = false,
  observed = 0,
  failed = 0,
  cases = {},
  parking = { groups = 0, mapped = 0, exactIdMatches = 0, failed = 0 },
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function notify(message, duration)
  MESSAGE:New(tostring(message), duration or 10, "OMW Ammo/Parking Test"):ToAll()
end

local function startsWith(value, prefix)
  return type(value) == "string" and value:sub(1, #prefix) == prefix
end

local function copyNumericMap(source)
  local result = {}
  for key, value in pairs(source or {}) do
    if type(value) == "number" then result[tostring(key)] = value end
  end
  return result
end

local function sortedKeys(map)
  local keys = {}
  for key in pairs(map or {}) do keys[#keys + 1] = tostring(key) end
  table.sort(keys)
  return keys
end

local function readInventory(storage, caseId)
  local aircraft, liquids, weapons = storage:GetInventory()
  if type(aircraft) ~= "table" or type(liquids) ~= "table" or type(weapons) ~= "table" then
    error("GetInventory invalid case=" .. tostring(caseId))
  end
  if not STORAGE or not STORAGE.Liquid or STORAGE.Liquid.JETFUEL == nil then
    error("Pinned STORAGE.Liquid.JETFUEL is unavailable")
  end
  local copiedLiquids = copyNumericMap(liquids)
  return {
    aircraft = copyNumericMap(aircraft),
    liquids = copiedLiquids,
    weapons = copyNumericMap(weapons),
    jetfuel = tonumber(liquids[STORAGE.Liquid.JETFUEL]) or tonumber(copiedLiquids[tostring(STORAGE.Liquid.JETFUEL)]) or 0,
  }
end

local function logMapDelta(caseId, family, before, after, phase)
  local seen = {}
  for key in pairs(before or {}) do seen[tostring(key)] = true end
  for key in pairs(after or {}) do seen[tostring(key)] = true end
  for _, key in ipairs(sortedKeys(seen)) do
    local a = tonumber(before and before[key]) or 0
    local b = tonumber(after and after[key]) or 0
    if a ~= b then
      log(string.format("MAP_DELTA case=%s phase=%s family=%s item=%s before=%.3f after=%.3f delta=%.3f", caseId, phase, family, key, a, b, b-a))
    end
  end
end

local function resolveFoundation(case)
  local state = OMW and OMW.AirOps and OMW.AirOps[case.foundation] or nil
  if not state or state.Status ~= "RUNNING" then error("Foundation is not RUNNING: " .. tostring(case.foundation)) end
  local squadron = state.Squadrons and state.Squadrons[case.squadron] or nil
  if not squadron then error("SQUADRON unresolved case=" .. case.id) end
  local airwing, airbase
  if state.Airwings then
    airwing = state.Airwings[case.wing]
    airbase = state.Airbases and state.Airbases[case.wing] or nil
  else
    airwing = state.Airwing
    airbase = state.Airbase
  end
  if not airwing then error("AIRWING unresolved case=" .. case.id) end
  if not airbase then error("AIRBASE unresolved case=" .. case.id) end
  local template = GROUP:FindByName(case.template)
  if not template then error("BLUE template unresolved case=" .. case.id .. " template=" .. case.template) end
  local storageAirbase = AIRBASE:FindByName(case.storageName)
  if not storageAirbase then error("Storage AIRBASE unresolved case=" .. case.id .. " name=" .. case.storageName) end
  local storage = storageAirbase:GetStorage()
  local registryStorage = STORAGE:FindByName(case.storageName)
  if not storage or not registryStorage or storage ~= registryStorage then
    error("STORAGE unresolved/identity mismatch case=" .. case.id .. " name=" .. case.storageName)
  end
  return airwing, squadron, airbase, template, storage
end

local function resolveTargetCoordinate(airbase, case)
  local origin = airbase:GetCoordinate()
  if not origin then error("AIRBASE coordinate unavailable case=" .. case.id) end
  for _, distanceOffset in ipairs(TARGET_DISTANCE_OFFSETS_M) do
    local distanceM = case.targetDistanceM + distanceOffset
    if distanceM > 1000 then
      for _, bearingOffset in ipairs(TARGET_BEARING_OFFSETS) do
        local bearing = (case.targetBearing + bearingOffset) % 360
        local candidate = origin:Translate(distanceM, bearing)
        local roadCoord = candidate and candidate:GetClosestPointToRoad() or nil
        if roadCoord then
          local flat, steepness = roadCoord:IsInFlatArea(TARGET_FLAT_RADIUS_M, TARGET_MAX_STEEPNESS_PERCENT)
          if flat then
            log(string.format("TARGET_RESOLVED case=%s placement=ROAD_FLAT_SEARCH preferredDistanceM=%d actualDistanceM=%d preferredBearing=%d actualBearing=%d flatRadiusM=%d maxSteepnessPercent=%d measuredSteepness=%s", case.id, case.targetDistanceM, distanceM, case.targetBearing, bearing, TARGET_FLAT_RADIUS_M, TARGET_MAX_STEEPNESS_PERCENT, tostring(steepness)))
            return roadCoord, distanceM, bearing, steepness
          end
        end
      end
    end
  end
  error("No flat road target coordinate found within bounded MOOSE search case=" .. case.id)
end

local function nearestParkingSpot(spots, x, y)
  local nearest, nearestDistance = nil, math.huge
  for _, spot in pairs(spots or {}) do
    local vec3 = spot.Vec3
    if vec3 and vec3.x and vec3.z then
      local dx, dy = x - vec3.x, y - vec3.z
      local distance = math.sqrt(dx * dx + dy * dy)
      if distance < nearestDistance then nearest, nearestDistance = spot, distance end
    end
  end
  return nearest, nearestDistance
end

local function correlateParkingNode(definition)
  local airbase = AIRBASE:FindByName(definition.node)
  if not airbase then error("AIRBASE unresolved node=" .. definition.node) end
  local spots = airbase:GetParkingSpotsTable()
  if type(spots) ~= "table" or #spots == 0 then error("Parking table empty node=" .. definition.node) end
  local set = SET_GROUP:New():FilterPrefixes(definition.prefix):FilterOnce()
  local nodeGroups, nodeMapped, nodeExactIdMatches, nodeFailed = 0, 0, 0, 0
  set:ForEachGroup(function(group)
    local groupName = group:GetName()
    if startsWith(groupName, definition.prefix) and (not definition.excludePrefix or not startsWith(groupName, definition.excludePrefix)) then
      nodeGroups = nodeGroups + 1
      runtime.parking.groups = runtime.parking.groups + 1
      local template = group:GetTemplate()
      local unit = template and template.units and template.units[1] or nil
      if not unit or type(unit.x) ~= "number" or type(unit.y) ~= "number" then
        nodeFailed = nodeFailed + 1
        runtime.parking.failed = runtime.parking.failed + 1
        log(string.format("PARKING_MAP node=%s markerGroup=%s status=ERROR error=TEMPLATE_POSITION_UNAVAILABLE", definition.node, groupName))
        return
      end
      local spot, distanceM = nearestParkingSpot(spots, unit.x, unit.y)
      if not spot then
        nodeFailed = nodeFailed + 1
        runtime.parking.failed = runtime.parking.failed + 1
        log(string.format("PARKING_MAP node=%s markerGroup=%s meParkingId=%s mizParking=%s status=ERROR error=NO_MOOSE_SPOT", definition.node, groupName, tostring(unit.parking_id), tostring(unit.parking)))
        return
      end
      local mizParking = tonumber(unit.parking)
      local mooseTerminalID = tonumber(spot.TerminalID)
      local exactIdMatch = mizParking ~= nil and mooseTerminalID ~= nil and mizParking == mooseTerminalID
      local positionMatch = distanceM <= PARKING_MATCH_MAX_DISTANCE_M
      local status = exactIdMatch and positionMatch and "MATCH" or "MISMATCH"
      nodeMapped = nodeMapped + 1
      runtime.parking.mapped = runtime.parking.mapped + 1
      if exactIdMatch then
        nodeExactIdMatches = nodeExactIdMatches + 1
        runtime.parking.exactIdMatches = runtime.parking.exactIdMatches + 1
      end
      if status ~= "MATCH" then
        nodeFailed = nodeFailed + 1
        runtime.parking.failed = runtime.parking.failed + 1
      end
      log(string.format("PARKING_MAP node=%s markerGroup=%s meParkingId=%s mizParking=%s mooseTerminalID=%s terminalID0=%s terminalType=%s distanceM=%.3f exactIdMatch=%s positionMatch=%s status=%s", definition.node, groupName, tostring(unit.parking_id), tostring(unit.parking), tostring(spot.TerminalID), tostring(spot.TerminalID0), tostring(spot.TerminalType), distanceM, tostring(exactIdMatch), tostring(positionMatch), status))
    end
  end)
  log(string.format("PARKING_NODE_RESULT node=%s status=%s groups=%d mapped=%d exactIdMatches=%d failed=%d matchToleranceM=%d", definition.node, nodeFailed == 0 and "COMPLETE" or "COMPLETE_WITH_GAPS", nodeGroups, nodeMapped, nodeExactIdMatches, nodeFailed, PARKING_MATCH_MAX_DISTANCE_M))
end

local function runParkingCorrelation()
  log(string.format("PARKING_CORRELATION_BEGIN nodes=%d matchToleranceM=%d", #PARKING_NODES, PARKING_MATCH_MAX_DISTANCE_M))
  for _, definition in ipairs(PARKING_NODES) do
    local ok, err = pcall(correlateParkingNode, definition)
    if not ok then
      runtime.parking.failed = runtime.parking.failed + 1
      log(string.format("PARKING_NODE_RESULT node=%s status=ERROR error=%s", definition.node, tostring(err)))
    end
  end
  log(string.format("PARKING_CORRELATION_RESULT status=%s groups=%d mapped=%d exactIdMatches=%d failed=%d", runtime.parking.failed == 0 and "COMPLETE" or "COMPLETE_WITH_GAPS", runtime.parking.groups, runtime.parking.mapped, runtime.parking.exactIdMatches, runtime.parking.failed))
end

local function ammoSnapshot(flightGroup, label, caseId)
  local ammo = flightGroup:GetAmmoTot()
  local result = {
    Total = tonumber(ammo and ammo.Total) or 0,
    Shells = tonumber(ammo and ammo.Shells) or 0,
    Guns = tonumber(ammo and ammo.Guns) or 0,
    Cannons = tonumber(ammo and ammo.Cannons) or 0,
    Rockets = tonumber(ammo and ammo.Rockets) or 0,
    Bombs = tonumber(ammo and ammo.Bombs) or 0,
    Missiles = tonumber(ammo and ammo.Missiles) or 0,
  }
  log(string.format("AMMO case=%s label=%s total=%d shells=%d guns=%d cannons=%d rockets=%d bombs=%d missiles=%d", caseId, label, result.Total, result.Shells, result.Guns, result.Cannons, result.Rockets, result.Bombs, result.Missiles))
  return result
end

local function ammoConsumed(before, after)
  return {
    Total = math.max(0, (before.Total or 0) - (after.Total or 0)),
    Shells = math.max(0, (before.Shells or 0) - (after.Shells or 0)),
    Guns = math.max(0, (before.Guns or 0) - (after.Guns or 0)),
    Cannons = math.max(0, (before.Cannons or 0) - (after.Cannons or 0)),
    Rockets = math.max(0, (before.Rockets or 0) - (after.Rockets or 0)),
    Bombs = math.max(0, (before.Bombs or 0) - (after.Bombs or 0)),
    Missiles = math.max(0, (before.Missiles or 0) - (after.Missiles or 0)),
  }
end

local function finishIfDone()
  if runtime.finished then return end
  local done = 0
  for _, state in pairs(runtime.cases) do if state.done then done = done + 1 end end
  if done < #CASES then return end
  runtime.finished = true
  local status = runtime.failed == 0 and runtime.observed == #CASES and "COMPLETE" or "COMPLETE_WITH_GAPS"
  log(string.format("RESULT testId=%s status=%s casesTotal=%d casesObserved=%d casesFailed=%d parkingGroups=%d parkingMapped=%d parkingExactIdMatches=%d parkingFailed=%d targetTemplate=%s targetPlacement=ROAD_FLAT_SEARCH landingRestrictPair=true realExpenditure=true storageMutation=false campaignStateMutation=false", TEST_ID, status, #CASES, runtime.observed, runtime.failed, runtime.parking.groups, runtime.parking.mapped, runtime.parking.exactIdMatches, runtime.parking.failed, TARGET_TEMPLATE))
  notify(string.format("AIRBORNE AMMO/PARKING TEST COMPLETE\n%s\nObserved %d/%d; failures %d\nParking mapped %d/%d; gaps %d\nSend dcs.log + debrief.", status, runtime.observed, #CASES, runtime.failed, runtime.parking.mapped, runtime.parking.groups, runtime.parking.failed), 30)
end

local function failCase(case, state, stage, message)
  if state.done then return end
  state.done = true
  runtime.failed = runtime.failed + 1
  log(string.format("CASE_RESULT case=%s role=%s status=ERROR stage=%s error=%s", case.id, case.evidenceRole, tostring(stage), tostring(message)))
  finishIfDone()
end

local function completeCase(case, state)
  if state.done then return end
  state.done = true
  runtime.observed = runtime.observed + 1
  local landedAmmo = state.landedAmmo or state.arrivedAmmo
  local consumed = landedAmmo and ammoConsumed(state.assignedAmmo, landedAmmo) or { Total=0, Shells=0, Guns=0, Cannons=0, Rockets=0, Bombs=0, Missiles=0 }
  local gunConsumption = (consumed.Guns or 0) + (consumed.Cannons or 0)
  local gunStatus = gunConsumption > 0 and "CONSUMED" or "NO_GUN_CONSUMPTION"
  log(string.format("CASE_RESULT case=%s role=%s status=OBSERVED gunStatus=%s consumedTotal=%d consumedShells=%d consumedGuns=%d consumedCannons=%d consumedRockets=%d consumedBombs=%d consumedMissiles=%d jetFuelDebitKg=%.3f jetFuelRecoveryKg=%.3f", case.id, case.evidenceRole, gunStatus, consumed.Total, consumed.Shells, consumed.Guns, consumed.Cannons, consumed.Rockets, consumed.Bombs, consumed.Missiles, state.pre.jetfuel - state.postSpawn.jetfuel, state.final.jetfuel - state.postSpawn.jetfuel))
  finishIfDone()
end

local function runCase(case)
  local state = { done=false, assigned=false, arrived=false }
  runtime.cases[case.id] = state
  local ok, airwing, squadron, airbase, template, storage = pcall(resolveFoundation, case)
  if not ok then return failCase(case, state, "RESOLVE", airwing) end
  local readOk, readErr = pcall(function() state.pre = readInventory(storage, case.id) end)
  if not readOk then return failCase(case, state, "PRE_INVENTORY", readErr) end
  local targetOk, targetCoord, actualTargetDistanceM, actualTargetBearing, measuredSteepness = pcall(resolveTargetCoordinate, airbase, case)
  if not targetOk then return failCase(case, state, "TARGET_RESOLVE", targetCoord) end
  local spawner = SPAWN:NewWithAlias(TARGET_TEMPLATE, "OMW_TEST_TARGET_" .. case.id)
  spawner:InitDelayOff()
  state.targetGroup = spawner:SpawnFromCoordinate(targetCoord)
  if not state.targetGroup then return failCase(case, state, "TARGET_SPAWN", "SpawnFromCoordinate returned nil") end
  log(string.format("TARGET_SPAWN case=%s role=%s template=%s spawned=%s placement=ROAD_FLAT_SEARCH distanceM=%d bearing=%d steepness=%s", case.id, case.evidenceRole, TARGET_TEMPLATE, state.targetGroup:GetName(), actualTargetDistanceM, actualTargetBearing, tostring(measuredSteepness)))
  local testPayload = airwing:NewPayload(template, -1, { AUFTRAG.Type.ORBIT }, 100)
  if not testPayload then return failCase(case, state, "PAYLOAD", "AIRWING:NewPayload returned nil") end
  local orbitCoord = airbase:GetCoordinate():Translate(math.min(8000, math.floor(actualTargetDistanceM * 0.6)), actualTargetBearing)
  local orbit = AUFTRAG:NewORBIT(orbitCoord, 5000, 150)
  orbit:SetRequiredAssets(1, 1)
  orbit:AssignSquadrons({ squadron })
  orbit:AddRequiredPayload(testPayload)
  orbit:SetTime(5)
  orbit:SetDuration(ORBIT_DURATION_S)
  orbit:SetROE(ENUMS.ROE.WeaponHold)
  orbit:SetROT(ENUMS.ROT.NoReaction)
  state.orbit = orbit
  log(string.format("CASE_DISPATCH case=%s role=%s template=%s storage=%s preJetFuelKg=%.3f targetDistanceM=%d targetBearing=%d", case.id, case.evidenceRole, case.template, case.storageName, state.pre.jetfuel, actualTargetDistanceM, actualTargetBearing))
  local previousFlightOnMission = airwing.OnAfterFlightOnMission
  airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then previousFlightOnMission(self, From, Event, To, FlightGroup, Mission) end
    if runtime.finished or Mission ~= orbit or state.assigned then return end
    state.assigned = true
    state.flightGroup = FlightGroup
    local assignedOk, assignedErr = pcall(function()
      if not FlightGroup.SetOptionLandingRestrictPair then error("Pinned FLIGHTGROUP:SetOptionLandingRestrictPair is unavailable") end
      FlightGroup:SetOptionLandingRestrictPair()
      log(string.format("LANDING_OPTION case=%s restrictPair=true productiveGroupingPreserved=true", case.id))
      state.assignedAmmo = ammoSnapshot(FlightGroup, "ASSIGNED", case.id)
      state.postSpawn = readInventory(storage, case.id)
      logMapDelta(case.id, "AIRCRAFT", state.pre.aircraft, state.postSpawn.aircraft, "SPAWN")
      logMapDelta(case.id, "LIQUID", state.pre.liquids, state.postSpawn.liquids, "SPAWN")
      logMapDelta(case.id, "WEAPON", state.pre.weapons, state.postSpawn.weapons, "SPAWN")
      local strafe = AUFTRAG:NewSTRAFING(targetCoord, STRAFE_ALTITUDE_FT, STRAFE_LENGTH_M)
      strafe:SetWeaponType(GUN_WEAPON_TYPE)
      strafe:SetWeaponExpend(AI.Task.WeaponExpend.QUARTER)
      strafe:SetEngageQuantity(2)
      strafe:SetROE(ENUMS.ROE.OpenFire)
      strafe:SetROT(ENUMS.ROT.NoReaction)
      strafe:SetDuration(600)
      state.strafe = strafe
      FlightGroup:AddMission(strafe)
      log(string.format("STRAFE_QUEUED case=%s target=%s weaponType=%d expend=QUARTER engageQuantity=2", case.id, state.targetGroup:GetName(), GUN_WEAPON_TYPE))
    end)
    if not assignedOk then return failCase(case, state, "ASSIGNMENT", assignedErr) end
    local previousLanded = FlightGroup.OnAfterLanded
    FlightGroup.OnAfterLanded = function(fg, LFrom, LEvent, LTo, LandAirbase)
      if not runtime.finished and not state.done then
        state.landedAmmo = ammoSnapshot(fg, "LANDED", case.id)
        log(string.format("LIFECYCLE case=%s event=Landed airbase=%s state=%s", case.id, LandAirbase and LandAirbase:GetName() or "nil", tostring(fg:GetState())))
      end
      if previousLanded then previousLanded(fg, LFrom, LEvent, LTo, LandAirbase) end
    end
    local previousArrived = FlightGroup.OnAfterArrived
    FlightGroup.OnAfterArrived = function(fg, AFrom, AEvent, ATo)
      if runtime.finished or state.done or state.arrived then
        if previousArrived then previousArrived(fg, AFrom, AEvent, ATo) end
        return
      end
      state.arrived = true
      state.arrivedAmmo = ammoSnapshot(fg, "ARRIVED", case.id)
      log(string.format("LIFECYCLE case=%s event=Arrived state=%s", case.id, tostring(fg:GetState())))
      if previousArrived then previousArrived(fg, AFrom, AEvent, ATo) end
      SCHEDULER:New(nil, function()
        if runtime.finished or state.done then return end
        local finalOk, finalErr = pcall(function()
          state.final = readInventory(storage, case.id)
          logMapDelta(case.id, "AIRCRAFT", state.postSpawn.aircraft, state.final.aircraft, "RETURN")
          logMapDelta(case.id, "LIQUID", state.postSpawn.liquids, state.final.liquids, "RETURN")
          logMapDelta(case.id, "WEAPON", state.postSpawn.weapons, state.final.weapons, "RETURN")
        end)
        if not finalOk then return failCase(case, state, "POST_RETURN", finalErr) end
        completeCase(case, state)
      end, {}, POST_RETURN_OBSERVE_S)
    end
    SCHEDULER:New(nil, function()
      if runtime.finished or state.done or state.arrived then return end
      local fgState = state.flightGroup and state.flightGroup:GetState() or "nil"
      local ammoNow = state.flightGroup and ammoSnapshot(state.flightGroup, "TIMEOUT", case.id) or nil
      log(string.format("TIMEOUT case=%s stage=LIFECYCLE flightState=%s strafeState=%s ammoShells=%s ammoGuns=%s ammoCannons=%s", case.id, tostring(fgState), state.strafe and tostring(state.strafe:GetState()) or "nil", ammoNow and tostring(ammoNow.Shells) or "nil", ammoNow and tostring(ammoNow.Guns) or "nil", ammoNow and tostring(ammoNow.Cannons) or "nil"))
      failCase(case, state, "LIFECYCLE_TIMEOUT", "Assigned flight did not reach Arrived within lifecycle timeout")
    end, {}, LIFECYCLE_TIMEOUT_S)
  end
  airwing:AddMission(orbit)
  SCHEDULER:New(nil, function()
    if runtime.finished or state.done or state.assigned then return end
    if orbit.Cancel then orbit:Cancel() end
    failCase(case, state, "ASSIGN_TIMEOUT", "No FlightOnMission within assignment timeout")
  end, {}, ASSIGN_TIMEOUT_S)
end

local function beginTest()
  local targetSeed = GROUP:FindByName(TARGET_TEMPLATE)
  if not targetSeed then
    runtime.finished = true
    log(string.format("RESULT testId=%s status=FATAL error=TARGET_TEMPLATE_UNRESOLVED template=%s", TEST_ID, TARGET_TEMPLATE))
    notify("AIRBORNE AMMO/PARKING TEST FATAL\nRED target seed missing.", 30)
    return
  end
  local parkingOk, parkingErr = pcall(runParkingCorrelation)
  if not parkingOk then
    runtime.parking.failed = runtime.parking.failed + 1
    log(string.format("PARKING_CORRELATION_RESULT status=ERROR error=%s", tostring(parkingErr)))
  end
  log(string.format("TEST_BEGIN testId=%s cases=%d targetTemplate=%s targetPlacement=ROAD_FLAT_SEARCH landingRestrictPair=true weaponType=%d expend=QUARTER engageQuantity=2 realExpenditure=true parkingCorrelation=true", TEST_ID, #CASES, TARGET_TEMPLATE, GUN_WEAPON_TYPE))
  notify("AIRBORNE AMMO/PARKING TEST STARTED\nA-10C / F-16C / F-15E / UH-60 / CH-47\nOH-58D / AH-64D regression", 30)
  for index, case in ipairs(CASES) do
    SCHEDULER:New(nil, runCase, {case}, (index - 1) * LANE_STAGGER_S)
  end
  SCHEDULER:New(nil, function()
    if runtime.finished then return end
    for _, case in ipairs(CASES) do
      local state = runtime.cases[case.id]
      if state and not state.done then failCase(case, state, "GLOBAL_TIMEOUT", "Global safety timeout reached") end
    end
  end, {}, GLOBAL_TIMEOUT_S)
end

SCHEDULER:New(nil, beginTest, {}, START_DELAY_S)
