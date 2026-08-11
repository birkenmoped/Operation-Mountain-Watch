-- Operation Mountain Watch - STORAGE/AIRWING weapon lifecycle correlation.
-- Read-only observer plus two native AIRWING/AUFTRAG AH-64D CAS sorties.

local TAG = "[OMW][StorageAirwingWeaponLifecycle]"
local TEST_ID = "STORAGE-AIRWING-WEAPON-LIFECYCLE-1"
local EXPECTED_AIRBASE = "Shindand Heliport"
local EXPECTED_SQUADRON = "SQ_US_SHND_AH64D_ATTACK"
local TARGET_DISTANCE_M = 10000
local TARGET_HEADING_DEG = 90
local CAS_RADIUS_M = 1500
local CAS_ALTITUDE_FT = 5500
local CAS_SPEED_KTS = 100
local MISSION_DURATION_S = 120
local START_DELAY_S = 20
local POLL_INTERVAL_S = 5
local POST_RETURN_OBSERVE_S = 15
local SECOND_DISPATCH_DELAY_S = 20
local FINAL_OBSERVE_S = 15
local SAFETY_TIMEOUT_S = 1800

local NODES = {
  { id = "BAGRAM", airbase = "Bagram" },
  { id = "JALALABAD", airbase = "Jalalabad" },
  { id = "KANDAHAR", airbase = "Kandahar" },
  { id = "KANDAHAR_HELIPORT", airbase = "Kandahar Heliport" },
  { id = "SALERNO", airbase = "FOB Salerno" },
  { id = "TARINKOT", airbase = "Tarinkot" },
  { id = "SHINDAND_HELIPORT", airbase = "Shindand Heliport" },
}

local runtime = {
  storages = {},
  lastInventory = {},
  deltaCount = 0,
  phase = "INIT",
  first = {},
  second = {},
  secondDispatchScheduled = false,
  finished = false,
  startedAt = timer.getTime(),
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message), false)
end

local function copyWeaponInventory(storage)
  local result = {}
  local inventory = storage:GetInventory() or {}
  local weapons = inventory.weapon or inventory.weapons or {}
  for item, amount in pairs(weapons) do
    if type(amount) == "number" then
      result[tostring(item)] = amount
    end
  end
  return result
end

local function resolveStorages()
  for _, node in ipairs(NODES) do
    local airbase = AIRBASE:FindByName(node.airbase)
    if not airbase then
      error("AIRBASE unresolved: " .. node.airbase)
    end
    local storageA = airbase:GetStorage()
    local storageB = STORAGE:FindByName(node.airbase)
    if not storageA or not storageB then
      error("STORAGE unresolved: " .. node.airbase)
    end
    if storageA ~= storageB then
      error("STORAGE wrapper identity mismatch: " .. node.airbase)
    end
    runtime.storages[node.id] = storageA
    runtime.lastInventory[node.id] = copyWeaponInventory(storageA)
    log(string.format("NODE_READY nodeId=%s airbase=%s", node.id, node.airbase))
  end
end

local function logInventorySnapshot(label)
  for _, node in ipairs(NODES) do
    local storage = runtime.storages[node.id]
    local inventory = copyWeaponInventory(storage)
    local m151 = inventory["weapons.nurs.HYDRA_70_M151"]
    local hellfire = inventory["weapons.missiles.AGM_114K"]
    local combo = inventory["weapons.droptanks.{IAFS_ComboPak_100}"]
    log(string.format(
      "SNAPSHOT label=%s nodeId=%s m151=%s agm114k=%s comboPak=%s weaponKeys=%d",
      label,
      node.id,
      tostring(m151),
      tostring(hellfire),
      tostring(combo),
      (function() local n=0 for _ in pairs(inventory) do n=n+1 end return n end)()
    ))
  end
end

local function pollDeltas()
  for _, node in ipairs(NODES) do
    local current = copyWeaponInventory(runtime.storages[node.id])
    local previous = runtime.lastInventory[node.id] or {}
    local keys = {}
    for key in pairs(previous) do keys[key] = true end
    for key in pairs(current) do keys[key] = true end
    for key in pairs(keys) do
      local before = tonumber(previous[key]) or 0
      local after = tonumber(current[key]) or 0
      if before ~= after then
        runtime.deltaCount = runtime.deltaCount + 1
        log(string.format(
          "WEAPON_DELTA phase=%s nodeId=%s item=%s before=%s after=%s delta=%s elapsed=%.1f",
          runtime.phase,
          node.id,
          key,
          tostring(before),
          tostring(after),
          tostring(after - before),
          timer.getTime() - runtime.startedAt
        ))
      end
    end
    runtime.lastInventory[node.id] = current
  end
end

local function ammoSummary(flightGroup, label, sortie)
  local ammo = flightGroup and flightGroup.GetAmmoTot and flightGroup:GetAmmoTot() or nil
  if not ammo then
    log(string.format("AMMO_SNAPSHOT sortie=%d label=%s unavailable=true", sortie, label))
    return nil
  end
  local summary = {
    missilesAG = tonumber(ammo.MissilesAG) or 0,
    rockets = tonumber(ammo.Rockets) or 0,
    bombs = tonumber(ammo.Bombs) or 0,
    guns = tonumber(ammo.Guns) or 0,
  }
  log(string.format(
    "AMMO_SNAPSHOT sortie=%d label=%s missilesAG=%d rockets=%d bombs=%d guns=%d",
    sortie, label, summary.missilesAG, summary.rockets, summary.bombs, summary.guns
  ))
  return summary
end

local function ammoEqual(a, b)
  if not a or not b then return nil end
  return a.missilesAG == b.missilesAG
    and a.rockets == b.rockets
    and a.bombs == b.bombs
    and a.guns == b.guns
end

local function buildMission(state, sortie)
  local baseCoordinate = state.Airbase:GetCoordinate()
  local targetCoordinate = baseCoordinate:Translate(TARGET_DISTANCE_M, TARGET_HEADING_DEG)
  local zone = ZONE_RADIUS:New("OMW_SHND_WEAPON_LIFECYCLE_CAS_" .. tostring(sortie), targetCoordinate:GetVec2(), CAS_RADIUS_M)
  local mission = AUFTRAG:NewCAS(zone, CAS_ALTITUDE_FT, CAS_SPEED_KTS)
  mission:SetRequiredAssets(1, 1)
  mission:SetTime(5, MISSION_DURATION_S)
  log(string.format("MISSION_PREPARED sortie=%d type=%s requiredAssets=1 durationS=%d", sortie, tostring(mission:GetType()), MISSION_DURATION_S))
  return mission
end

local dispatchSortie

local function finishPass()
  if runtime.finished then return end
  runtime.finished = true
  runtime.phase = "FINAL"
  pollDeltas()
  logInventorySnapshot("FINAL")

  local firstNoFire = ammoEqual(runtime.first.assignedAmmo, runtime.first.arrivedAmmo)
  local secondNoFire = ammoEqual(runtime.second.assignedAmmo, runtime.second.arrivedAmmo)
  log(string.format(
    "RESULT testId=%s status=PASS nodesExpected=7 nodesReady=7 firstAssigned=%s firstLanded=%s firstArrived=%s secondAssigned=%s secondLanded=%s secondArrived=%s firstNoFire=%s secondNoFire=%s deltasObserved=%d mutation=false campaignStateMutation=false returnToLegionCalledByTest=false opstransport=false ctld=false",
    TEST_ID,
    tostring(runtime.first.assigned == true),
    tostring(runtime.first.landed == true),
    tostring(runtime.first.arrived == true),
    tostring(runtime.second.assigned == true),
    tostring(runtime.second.landed == true),
    tostring(runtime.second.arrived == true),
    tostring(firstNoFire),
    tostring(secondNoFire),
    runtime.deltaCount
  ))
end

local function bindFlightLifecycle(state, flightGroup, mission, sortie)
  local slot = sortie == 1 and runtime.first or runtime.second
  slot.flightGroup = flightGroup
  slot.mission = mission
  slot.assigned = true
  slot.assignedAmmo = ammoSummary(flightGroup, "ASSIGNED", sortie)
  runtime.phase = sortie == 1 and "FIRST_ASSIGNED" or "SECOND_ASSIGNED"
  pollDeltas()
  logInventorySnapshot(runtime.phase)

  flightGroup.OnAfterLanded = function(self, From, Event, To, Airbase)
    slot.landed = true
    slot.landedAmmo = ammoSummary(self, "LANDED", sortie)
    runtime.phase = sortie == 1 and "FIRST_LANDED" or "SECOND_LANDED"
    log(string.format("LIFECYCLE_EVENT sortie=%d event=Landed airbase=%s state=%s", sortie, Airbase and Airbase:GetName() or "nil", tostring(self:GetState())))
    pollDeltas()
    logInventorySnapshot(runtime.phase)
  end

  flightGroup.OnAfterArrived = function(self, From, Event, To)
    slot.arrived = true
    slot.arrivedAmmo = ammoSummary(self, "ARRIVED", sortie)
    runtime.phase = sortie == 1 and "FIRST_ARRIVED" or "SECOND_ARRIVED"
    log(string.format("LIFECYCLE_EVENT sortie=%d event=Arrived state=%s", sortie, tostring(self:GetState())))
    pollDeltas()
    logInventorySnapshot(runtime.phase)

    if sortie == 1 then
      SCHEDULER:New(nil, function()
        runtime.phase = "FIRST_POST_RETURN"
        pollDeltas()
        logInventorySnapshot("FIRST_POST_RETURN")
        log(string.format(
          "AIRWING_STATE label=FIRST_POST_RETURN totalAssets=%s assetsOnMission=%s",
          tostring(state.Airwing:CountAssets()),
          tostring(select(1, state.Airwing:CountAssetsOnMission()))
        ))
        if not runtime.secondDispatchScheduled then
          runtime.secondDispatchScheduled = true
          SCHEDULER:New(nil, function()
            dispatchSortie(state, 2)
          end, {}, SECOND_DISPATCH_DELAY_S)
        end
      end, {}, POST_RETURN_OBSERVE_S)
    else
      SCHEDULER:New(nil, function()
        runtime.phase = "SECOND_POST_RETURN"
        pollDeltas()
        logInventorySnapshot("SECOND_POST_RETURN")
        log(string.format(
          "AIRWING_STATE label=SECOND_POST_RETURN totalAssets=%s assetsOnMission=%s",
          tostring(state.Airwing:CountAssets()),
          tostring(select(1, state.Airwing:CountAssetsOnMission()))
        ))
        SCHEDULER:New(nil, finishPass, {}, FINAL_OBSERVE_S)
      end, {}, POST_RETURN_OBSERVE_S)
    end
  end
end

dispatchSortie = function(state, sortie)
  local mission = buildMission(state, sortie)
  local assigned = false
  local previousCallback = state.Airwing.OnAfterFlightOnMission

  state.Airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if previousCallback then
      previousCallback(self, From, Event, To, FlightGroup, Mission)
    end
    if Mission ~= mission then return end
    if assigned then
      fail("duplicate FlightOnMission for sortie=" .. tostring(sortie))
      return
    end
    assigned = true
    if not FlightGroup then
      fail("missing FLIGHTGROUP for sortie=" .. tostring(sortie))
      return
    end
    local group = FlightGroup:GetGroup()
    local leader = group and group:GetUnit(1) or nil
    log(string.format(
      "FLIGHT_ON_MISSION sortie=%d group=%s missionType=%s unitType=%s state=%s",
      sortie,
      tostring(FlightGroup:GetName()),
      tostring(Mission:GetType()),
      tostring(leader and leader:GetTypeName() or "nil"),
      tostring(FlightGroup:GetState())
    ))
    bindFlightLifecycle(state, FlightGroup, mission, sortie)
  end

  runtime.phase = sortie == 1 and "FIRST_DISPATCH_REQUEST" or "SECOND_DISPATCH_REQUEST"
  log(string.format("DISPATCH_REQUEST sortie=%d exactlyOneMission=true commander=false directSpawn=false campaignStateMutation=false", sortie))
  state.Airwing:AddMission(mission)
end

local function run()
  if not OMW or not OMW.AirOps or not OMW.AirOps.Shindand then
    error("Shindand foundation state not loaded")
  end
  if not AIRBASE or not STORAGE or not AIRWING or not AUFTRAG or not ZONE_RADIUS or not SCHEDULER then
    error("Required pinned MOOSE classes unavailable")
  end

  local state = OMW.AirOps.Shindand
  if state.Status ~= "RUNNING" then
    error("Shindand foundation is not RUNNING: " .. tostring(state.Status))
  end
  if not state.Airbase or state.Airbase:GetName() ~= EXPECTED_AIRBASE then
    error("Unexpected Shindand airbase")
  end
  local squadron = state.Squadrons and state.Squadrons.AH64D or nil
  if not squadron or squadron.name ~= EXPECTED_SQUADRON then
    error("Unexpected AH-64D squadron")
  end

  log("TEST_BEGIN testId=" .. TEST_ID .. " scope=NO_FIRE_RETURN_RECREDIT_REDISPATCH readOnlyStorage=true")
  resolveStorages()
  runtime.phase = "BASELINE"
  logInventorySnapshot("BASELINE")

  SCHEDULER:New(nil, function()
    if runtime.finished then return false end
    pollDeltas()
    if timer.getTime() - runtime.startedAt >= SAFETY_TIMEOUT_S then
      fail(string.format(
        "RESULT testId=%s status=FAIL_TIMEOUT phase=%s firstAssigned=%s firstLanded=%s firstArrived=%s secondAssigned=%s secondLanded=%s secondArrived=%s deltasObserved=%d",
        TEST_ID,
        runtime.phase,
        tostring(runtime.first.assigned == true),
        tostring(runtime.first.landed == true),
        tostring(runtime.first.arrived == true),
        tostring(runtime.second.assigned == true),
        tostring(runtime.second.landed == true),
        tostring(runtime.second.arrived == true),
        runtime.deltaCount
      ))
      runtime.finished = true
      return false
    end
    return true
  end, {}, POLL_INTERVAL_S, POLL_INTERVAL_S)

  dispatchSortie(state, 1)
end

SCHEDULER:New(nil, function()
  local ok, err = pcall(run)
  if not ok then
    fail("ERROR " .. tostring(err))
  end
end, {}, START_DELAY_S)
