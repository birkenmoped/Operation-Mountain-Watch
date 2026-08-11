-- Operation Mountain Watch - STORAGE/AIRWING weapon lifecycle correlation.
-- Read-only STORAGE observer plus two native AIRWING/AUFTRAG AH-64D CAS sorties.

local TAG = "[OMW][StorageAirwingWeaponLifecycle]"
local TEST_ID = "STORAGE-AIRWING-WEAPON-LIFECYCLE-2"
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

local ITEM_M151 = "weapons.nurs.HYDRA_70_M151"
local ITEM_AGM114K = "weapons.missiles.AGM_114K"
local ITEM_COMBOPAK = "weapons.droptanks.{IAFS_ComboPak_100}"

local EXPECTED_FIRST_DEBIT = {
  [ITEM_M151] = 76,
  [ITEM_AGM114K] = 4,
  [ITEM_COMBOPAK] = 2,
}

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
  baseline = {},
  deltaCount = 0,
  phase = "INIT",
  first = {},
  second = {},
  secondDispatchScheduled = false,
  finished = false,
  baselineValidated = false,
  firstDebitValidated = false,
  storageObservationValid = false,
  startedAt = timer.getTime(),
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message), false)
end

local function failResult(stage, message)
  if runtime.finished then return end
  runtime.finished = true
  fail(string.format(
    "RESULT testId=%s status=FAIL stage=%s phase=%s baselineValidated=%s firstDebitValidated=%s storageObservationValid=%s firstAssigned=%s firstLanded=%s firstArrived=%s secondAssigned=%s secondLanded=%s secondArrived=%s deltasObserved=%d error=%s",
    TEST_ID,
    tostring(stage),
    tostring(runtime.phase),
    tostring(runtime.baselineValidated),
    tostring(runtime.firstDebitValidated),
    tostring(runtime.storageObservationValid),
    tostring(runtime.first.assigned == true),
    tostring(runtime.first.landed == true),
    tostring(runtime.first.arrived == true),
    tostring(runtime.second.assigned == true),
    tostring(runtime.second.landed == true),
    tostring(runtime.second.arrived == true),
    runtime.deltaCount,
    tostring(message)
  ))
end

local function copyMap(source)
  local result = {}
  for key, value in pairs(source or {}) do
    if type(value) == "number" then
      result[tostring(key)] = value
    end
  end
  return result
end

local function mapCount(source)
  local count = 0
  for _ in pairs(source or {}) do
    count = count + 1
  end
  return count
end

local function readWeapons(storage, nodeId)
  local aircraft, liquids, weapons = storage:GetInventory()
  if type(aircraft) ~= "table" or type(liquids) ~= "table" or type(weapons) ~= "table" then
    error(string.format(
      "GetInventory returned invalid types nodeId=%s aircraft=%s liquids=%s weapons=%s",
      tostring(nodeId), type(aircraft), type(liquids), type(weapons)
    ))
  end
  return copyMap(weapons)
end

local function resolveStorages()
  for _, node in ipairs(NODES) do
    local airbase = AIRBASE:FindByName(node.airbase)
    if not airbase then error("AIRBASE unresolved: " .. node.airbase) end
    local storageA = airbase:GetStorage()
    local storageB = STORAGE:FindByName(node.airbase)
    if not storageA or not storageB then error("STORAGE unresolved: " .. node.airbase) end
    if storageA ~= storageB then error("STORAGE wrapper identity mismatch: " .. node.airbase) end
    runtime.storages[node.id] = storageA
    log(string.format("NODE_READY nodeId=%s airbase=%s", node.id, node.airbase))
  end
end

local function captureBaseline()
  for _, node in ipairs(NODES) do
    local inventory = readWeapons(runtime.storages[node.id], node.id)
    local count = mapCount(inventory)
    if count <= 0 then error("Weapon inventory unexpectedly empty at baseline nodeId=" .. tostring(node.id)) end
    runtime.baseline[node.id] = inventory
    runtime.lastInventory[node.id] = copyMap(inventory)
    log(string.format("BASELINE_CAPTURED nodeId=%s weaponKeys=%d", node.id, count))
  end

  local shindand = runtime.baseline.SHINDAND_HELIPORT
  if not shindand then error("Shindand baseline missing") end
  for item, required in pairs(EXPECTED_FIRST_DEBIT) do
    local amount = shindand[item]
    if type(amount) ~= "number" then error("Required Shindand baseline weapon key missing: " .. tostring(item)) end
    if amount < required then
      error(string.format("Insufficient Shindand baseline item=%s amount=%s required=%s", item, tostring(amount), tostring(required)))
    end
  end

  runtime.baselineValidated = true
  runtime.storageObservationValid = true
  log(string.format(
    "BASELINE_VALIDATED nodeId=SHINDAND_HELIPORT weaponKeys=%d m151=%s agm114k=%s comboPak=%s",
    mapCount(shindand), tostring(shindand[ITEM_M151]), tostring(shindand[ITEM_AGM114K]), tostring(shindand[ITEM_COMBOPAK])
  ))
end

local function logInventorySnapshot(label)
  for _, node in ipairs(NODES) do
    local inventory = readWeapons(runtime.storages[node.id], node.id)
    log(string.format(
      "SNAPSHOT label=%s nodeId=%s m151=%s agm114k=%s comboPak=%s weaponKeys=%d",
      label, node.id, tostring(inventory[ITEM_M151]), tostring(inventory[ITEM_AGM114K]), tostring(inventory[ITEM_COMBOPAK]), mapCount(inventory)
    ))
  end
end

local function pollDeltas()
  if not runtime.storageObservationValid then error("STORAGE observation is not valid") end
  for _, node in ipairs(NODES) do
    local current = readWeapons(runtime.storages[node.id], node.id)
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
          runtime.phase, node.id, key, tostring(before), tostring(after), tostring(after - before), timer.getTime() - runtime.startedAt
        ))
      end
    end
    runtime.lastInventory[node.id] = current
  end
end

local function validateFirstDebit()
  local current = readWeapons(runtime.storages.SHINDAND_HELIPORT, "SHINDAND_HELIPORT")
  local baseline = runtime.baseline.SHINDAND_HELIPORT
  for item, expectedDebit in pairs(EXPECTED_FIRST_DEBIT) do
    local before = tonumber(baseline[item])
    local after = tonumber(current[item])
    if not before or not after then error("First-debit validation missing numeric value for item=" .. tostring(item)) end
    local actualDebit = before - after
    if actualDebit ~= expectedDebit then
      error(string.format("First-debit control mismatch item=%s expectedDebit=%d actualDebit=%d before=%s after=%s", item, expectedDebit, actualDebit, tostring(before), tostring(after)))
    end
  end
  runtime.firstDebitValidated = true
  log(string.format("FIRST_DEBIT_VALIDATED m151=-%d agm114k=-%d comboPak=-%d", EXPECTED_FIRST_DEBIT[ITEM_M151], EXPECTED_FIRST_DEBIT[ITEM_AGM114K], EXPECTED_FIRST_DEBIT[ITEM_COMBOPAK]))
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
  log(string.format("AMMO_SNAPSHOT sortie=%d label=%s missilesAG=%d rockets=%d bombs=%d guns=%d", sortie, label, summary.missilesAG, summary.rockets, summary.bombs, summary.guns))
  return summary
end

local function ammoEqual(a, b)
  if not a or not b then return false end
  return a.missilesAG == b.missilesAG and a.rockets == b.rockets and a.bombs == b.bombs and a.guns == b.guns
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
  local firstNoFire = ammoEqual(runtime.first.assignedAmmo, runtime.first.arrivedAmmo)
  local secondNoFire = ammoEqual(runtime.second.assignedAmmo, runtime.second.arrivedAmmo)
  local lifecycleComplete = runtime.baselineValidated and runtime.storageObservationValid and runtime.firstDebitValidated
    and runtime.first.assigned and runtime.first.arrived and runtime.second.assigned and runtime.second.arrived
    and firstNoFire and secondNoFire

  if not lifecycleComplete then
    failResult("FINAL_ASSERT", "Required lifecycle or no-fire invariant not satisfied")
    return
  end

  runtime.phase = "FINAL"
  local ok, err = pcall(function()
    pollDeltas()
    logInventorySnapshot("FINAL")
  end)
  if not ok then
    failResult("FINAL_STORAGE", err)
    return
  end

  runtime.finished = true
  log(string.format(
    "RESULT testId=%s status=PASS nodesExpected=7 nodesReady=7 baselineValidated=true firstDebitValidated=true storageObservationValid=true firstAssigned=true firstLanded=%s firstArrived=true secondAssigned=true secondLanded=%s secondArrived=true firstNoFire=true secondNoFire=true deltasObserved=%d mutation=false campaignStateMutation=false returnToLegionCalledByTest=false opstransport=false ctld=false",
    TEST_ID, tostring(runtime.first.landed == true), tostring(runtime.second.landed == true), runtime.deltaCount
  ))
end

local function bindFlightLifecycle(state, flightGroup, mission, sortie)
  local slot = sortie == 1 and runtime.first or runtime.second
  slot.flightGroup = flightGroup
  slot.mission = mission
  slot.assigned = true
  slot.assignedAmmo = ammoSummary(flightGroup, "ASSIGNED", sortie)
  runtime.phase = sortie == 1 and "FIRST_ASSIGNED" or "SECOND_ASSIGNED"

  local ok, err = pcall(function()
    pollDeltas()
    if sortie == 1 then validateFirstDebit() end
    logInventorySnapshot(runtime.phase)
  end)
  if not ok then
    failResult("ASSIGNMENT_STORAGE", err)
    return
  end

  local previousLanded = flightGroup.OnAfterLanded
  flightGroup.OnAfterLanded = function(self, From, Event, To, Airbase)
    if previousLanded then previousLanded(self, From, Event, To, Airbase) end
    if runtime.finished then return end
    slot.landed = true
    slot.landedAmmo = ammoSummary(self, "LANDED", sortie)
    runtime.phase = sortie == 1 and "FIRST_LANDED" or "SECOND_LANDED"
    log(string.format("LIFECYCLE_EVENT sortie=%d event=Landed airbase=%s state=%s", sortie, Airbase and Airbase:GetName() or "nil", tostring(self:GetState())))
    local landedOk, landedErr = pcall(function()
      pollDeltas()
      logInventorySnapshot(runtime.phase)
    end)
    if not landedOk then failResult("LANDED_STORAGE", landedErr) end
  end

  local previousArrived = flightGroup.OnAfterArrived
  flightGroup.OnAfterArrived = function(self, From, Event, To)
    if previousArrived then previousArrived(self, From, Event, To) end
    if runtime.finished then return end
    slot.arrived = true
    slot.arrivedAmmo = ammoSummary(self, "ARRIVED", sortie)
    runtime.phase = sortie == 1 and "FIRST_ARRIVED" or "SECOND_ARRIVED"
    log(string.format("LIFECYCLE_EVENT sortie=%d event=Arrived state=%s landedObserved=%s", sortie, tostring(self:GetState()), tostring(slot.landed == true)))

    local arrivedOk, arrivedErr = pcall(function()
      pollDeltas()
      logInventorySnapshot(runtime.phase)
    end)
    if not arrivedOk then
      failResult("ARRIVED_STORAGE", arrivedErr)
      return
    end

    if sortie == 1 then
      SCHEDULER:New(nil, function()
        if runtime.finished then return end
        runtime.phase = "FIRST_POST_RETURN"
        local postOk, postErr = pcall(function()
          pollDeltas()
          logInventorySnapshot("FIRST_POST_RETURN")
        end)
        if not postOk then
          failResult("FIRST_POST_RETURN_STORAGE", postErr)
          return
        end
        log(string.format("AIRWING_STATE label=FIRST_POST_RETURN totalAssets=%s assetsOnMission=%s landedObserved=%s", tostring(state.Airwing:CountAssets()), tostring(select(1, state.Airwing:CountAssetsOnMission())), tostring(slot.landed == true)))
        if not runtime.secondDispatchScheduled then
          runtime.secondDispatchScheduled = true
          SCHEDULER:New(nil, function()
            if not runtime.finished then dispatchSortie(state, 2) end
          end, {}, SECOND_DISPATCH_DELAY_S)
        end
      end, {}, POST_RETURN_OBSERVE_S)
    else
      SCHEDULER:New(nil, function()
        if runtime.finished then return end
        runtime.phase = "SECOND_POST_RETURN"
        local postOk, postErr = pcall(function()
          pollDeltas()
          logInventorySnapshot("SECOND_POST_RETURN")
        end)
        if not postOk then
          failResult("SECOND_POST_RETURN_STORAGE", postErr)
          return
        end
        log(string.format("AIRWING_STATE label=SECOND_POST_RETURN totalAssets=%s assetsOnMission=%s landedObserved=%s", tostring(state.Airwing:CountAssets()), tostring(select(1, state.Airwing:CountAssetsOnMission())), tostring(slot.landed == true)))
        SCHEDULER:New(nil, finishPass, {}, FINAL_OBSERVE_S)
      end, {}, POST_RETURN_OBSERVE_S)
    end
  end
end

dispatchSortie = function(state, sortie)
  if runtime.finished then return end
  local mission = buildMission(state, sortie)
  local assigned = false
  local previousCallback = state.Airwing.OnAfterFlightOnMission

  state.Airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if previousCallback then previousCallback(self, From, Event, To, FlightGroup, Mission) end
    if runtime.finished or Mission ~= mission then return end
    if assigned then
      failResult("DISPATCH", "duplicate FlightOnMission for sortie=" .. tostring(sortie))
      return
    end
    assigned = true
    if not FlightGroup then
      failResult("DISPATCH", "missing FLIGHTGROUP for sortie=" .. tostring(sortie))
      return
    end
    local group = FlightGroup:GetGroup()
    local leader = group and group:GetUnit(1) or nil
    log(string.format("FLIGHT_ON_MISSION sortie=%d group=%s missionType=%s unitType=%s state=%s", sortie, tostring(FlightGroup:GetName()), tostring(Mission:GetType()), tostring(leader and leader:GetTypeName() or "nil"), tostring(FlightGroup:GetState())))
    bindFlightLifecycle(state, FlightGroup, mission, sortie)
  end

  runtime.phase = sortie == 1 and "FIRST_DISPATCH_REQUEST" or "SECOND_DISPATCH_REQUEST"
  log(string.format("DISPATCH_REQUEST sortie=%d exactlyOneMission=true commander=false directSpawn=false campaignStateMutation=false", sortie))
  state.Airwing:AddMission(mission)
end

local function run()
  if not OMW or not OMW.AirOps or not OMW.AirOps.Shindand then error("Shindand foundation state not loaded") end
  if not AIRBASE or not STORAGE or not AIRWING or not AUFTRAG or not ZONE_RADIUS or not SCHEDULER then error("Required pinned MOOSE classes unavailable") end

  local state = OMW.AirOps.Shindand
  if state.Status ~= "RUNNING" then error("Shindand foundation is not RUNNING: " .. tostring(state.Status)) end
  if not state.Airbase or state.Airbase:GetName() ~= EXPECTED_AIRBASE then error("Unexpected Shindand airbase") end
  local squadron = state.Squadrons and state.Squadrons.AH64D or nil
  if not squadron or squadron.name ~= EXPECTED_SQUADRON then error("Unexpected AH-64D squadron") end

  log("TEST_BEGIN testId=" .. TEST_ID .. " scope=NO_FIRE_RETURN_RECREDIT_REDISPATCH readOnlyStorage=true")
  resolveStorages()
  runtime.phase = "BASELINE"
  captureBaseline()
  logInventorySnapshot("BASELINE")

  SCHEDULER:New(nil, function()
    if runtime.finished then return false end
    local ok, err = pcall(pollDeltas)
    if not ok then
      failResult("POLL_STORAGE", err)
      return false
    end
    if timer.getTime() - runtime.startedAt >= SAFETY_TIMEOUT_S then
      failResult("TIMEOUT", "Safety timeout exceeded")
      return false
    end
    return true
  end, {}, POLL_INTERVAL_S, POLL_INTERVAL_S)

  dispatchSortie(state, 1)
end

SCHEDULER:New(nil, function()
  local ok, err = pcall(run)
  if not ok then failResult("HARNESS", err) end
end, {}, START_DELAY_S)
