-- Operation Mountain Watch - physical aircraft loss / STORAGE recovery correlation.
-- Read-only STORAGE observer. Deliberate aircraft destruction uses public MOOSE
-- UNIT:Explode(), which creates a real DCS explosion at each aircraft position.

local TAG = "[OMW][StoragePhysicalLossRecovery]"
local TEST_ID = "STORAGE-PHYSICAL-LOSS-RECOVERY-1"
local START_DELAY_S = 20
local POLL_INTERVAL_S = 5
local EXPLOSION_DELAY_S = 5
local POST_EXPLOSION_OBSERVE_S = 30
local SAFETY_TIMEOUT_S = 600
local HEARTBEAT_INTERVAL_S = 60
local STATUS_MESSAGE_DURATION_S = 12
local FINAL_MESSAGE_DURATION_S = 30
local MISSION_DURATION_S = 300
local EXPLOSION_POWER_KG_TNT = 1500

local ITEM_M151 = "weapons.nurs.HYDRA_70_M151"
local ITEM_AGM114K = "weapons.missiles.AGM_114K"
local ITEM_COMBOPAK = "weapons.droptanks.{IAFS_ComboPak_100}"

local EXPECTED_AH64_DEBIT = {
  [ITEM_M151] = 76,
  [ITEM_AGM114K] = 4,
  [ITEM_COMBOPAK] = 2,
}

local runtime = {
  finished = false,
  phase = "INIT",
  startedAt = 0,
  nextHeartbeatAt = 0,
  storage = nil,
  baseline = nil,
  postSpawn = nil,
  final = nil,
  flightGroup = nil,
  assigned = false,
  explosionRequested = false,
  unitsExploded = 0,
  unitsAliveAfter = -1,
  assetStockBefore = -1,
  assetTotalBefore = -1,
  assetStockAfter = -1,
  assetTotalAfter = -1,
  storeRecovery = "UNKNOWN",
  aircraftRecovery = "UNKNOWN",
  liquidRecovery = "UNKNOWN",
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function notify(message, duration)
  MESSAGE:New(tostring(message), duration or STATUS_MESSAGE_DURATION_S, "OMW Test"):ToAll()
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

local function readInventory(storage)
  local aircraft, liquids, weapons = storage:GetInventory()
  if type(aircraft) ~= "table" or type(liquids) ~= "table" or type(weapons) ~= "table" then
    error(string.format("GetInventory invalid aircraft=%s liquids=%s weapons=%s", type(aircraft), type(liquids), type(weapons)))
  end
  return {
    aircraft = copyMap(aircraft),
    liquids = copyMap(liquids),
    weapons = copyMap(weapons),
  }
end

local function collectKeys(a, b)
  local keys = {}
  for key in pairs(a or {}) do keys[key] = true end
  for key in pairs(b or {}) do keys[key] = true end
  return keys
end

local function logMapDeltas(family, before, after)
  local changed = 0
  for key in pairs(collectKeys(before, after)) do
    local a = tonumber(before and before[key]) or 0
    local b = tonumber(after and after[key]) or 0
    if a ~= b then
      changed = changed + 1
      log(string.format("INVENTORY_DELTA phase=%s family=%s item=%s before=%s after=%s delta=%s", runtime.phase, family, key, tostring(a), tostring(b), tostring(b - a)))
    end
  end
  return changed
end

local function logInventoryDeltas(label, before, after)
  log(string.format("INVENTORY_COMPARE label=%s", label))
  logMapDeltas("aircraft", before.aircraft, after.aircraft)
  logMapDeltas("liquids", before.liquids, after.liquids)
  logMapDeltas("weapons", before.weapons, after.weapons)
end

local function exactWeaponDebit(before, after)
  for item, expectedDebit in pairs(EXPECTED_AH64_DEBIT) do
    local a = tonumber(before.weapons[item])
    local b = tonumber(after.weapons[item])
    if not a or not b then
      error("Required weapon key missing: " .. tostring(item))
    end
    local actualDebit = a - b
    log(string.format("SPAWN_DEBIT item=%s expected=%d actual=%d", item, expectedDebit, actualDebit))
    if actualDebit ~= expectedDebit then
      error(string.format("AH64 spawn debit mismatch item=%s expected=%d actual=%d", item, expectedDebit, actualDebit))
    end
  end
end

local function classifyRecovery(before, postSpawn, final, family)
  local debitTotal = 0
  local recoveredTotal = 0
  local changedKeys = 0
  for key in pairs(collectKeys(before, postSpawn)) do
    local baseline = tonumber(before[key]) or 0
    local spawned = tonumber(postSpawn[key]) or 0
    local debit = baseline - spawned
    if debit > 0 then
      changedKeys = changedKeys + 1
      local finalValue = tonumber(final[key]) or 0
      local recovered = finalValue - spawned
      if recovered < 0 then recovered = 0 end
      if recovered > debit then recovered = debit end
      debitTotal = debitTotal + debit
      recoveredTotal = recoveredTotal + recovered
      log(string.format("RECOVERY_ITEM family=%s item=%s baseline=%s postSpawn=%s final=%s debit=%s recovered=%s", family, key, tostring(baseline), tostring(spawned), tostring(finalValue), tostring(debit), tostring(recovered)))
    end
  end
  if changedKeys == 0 then return "NOT_OBSERVED", 0, 0 end
  if recoveredTotal == 0 then return "NONE", recoveredTotal, debitTotal end
  if recoveredTotal == debitTotal then return "FULL", recoveredTotal, debitTotal end
  return "PARTIAL", recoveredTotal, debitTotal
end

local function classifyKnownWeaponRecovery()
  local debited = 0
  local recovered = 0
  for item, expectedDebit in pairs(EXPECTED_AH64_DEBIT) do
    local spawned = tonumber(runtime.postSpawn.weapons[item]) or 0
    local final = tonumber(runtime.final.weapons[item]) or 0
    local itemRecovery = final - spawned
    if itemRecovery < 0 then itemRecovery = 0 end
    if itemRecovery > expectedDebit then itemRecovery = expectedDebit end
    debited = debited + expectedDebit
    recovered = recovered + itemRecovery
    log(string.format("KNOWN_STORE_RECOVERY item=%s postSpawn=%d final=%d debit=%d recovered=%d", item, spawned, final, expectedDebit, itemRecovery))
  end
  if recovered == 0 then return "NONE", recovered, debited end
  if recovered == debited then return "FULL", recovered, debited end
  return "PARTIAL", recovered, debited
end

local function finish(status, errorText)
  if runtime.finished then return end
  runtime.finished = true
  log(string.format(
    "RESULT testId=%s status=%s phase=%s assigned=%s explosionRequested=%s unitsExploded=%d unitsAliveAfter=%d assetStockBefore=%d assetStockAfter=%d assetTotalBefore=%d assetTotalAfter=%d storeRecovery=%s aircraftRecovery=%s liquidRecovery=%s physicalLossMethod=MOOSE_UNIT_EXPLODE storageMutation=false campaignStateMutation=false error=%s",
    TEST_ID,
    tostring(status),
    tostring(runtime.phase),
    tostring(runtime.assigned),
    tostring(runtime.explosionRequested),
    runtime.unitsExploded,
    runtime.unitsAliveAfter,
    runtime.assetStockBefore,
    runtime.assetStockAfter,
    runtime.assetTotalBefore,
    runtime.assetTotalAfter,
    tostring(runtime.storeRecovery),
    tostring(runtime.aircraftRecovery),
    tostring(runtime.liquidRecovery),
    tostring(errorText or "none")
  ))
  notify(string.format("PHYSICAL LOSS TEST %s\nStores: %s\nAircraft: %s\nLiquids: %s\nSend dcs.log + debrief.", tostring(status), tostring(runtime.storeRecovery), tostring(runtime.aircraftRecovery), tostring(runtime.liquidRecovery)), FINAL_MESSAGE_DURATION_S)
end

local function fail(stage, err)
  env.error(TAG .. " FAIL stage=" .. tostring(stage) .. " error=" .. tostring(err), false)
  finish("FAIL", tostring(stage) .. ":" .. tostring(err))
end

local function requireFoundation()
  local shindand = OMW and OMW.AirOps and OMW.AirOps.Shindand or nil
  if not shindand or shindand.Status ~= "RUNNING" then
    error("Shindand AirOps foundation is not RUNNING")
  end
  if not shindand.Airwing or not shindand.Airbase or not shindand.Squadrons or not shindand.Squadrons.AH64D then
    error("Shindand AH-64 foundation incomplete")
  end
  return shindand
end

local function makeNoFireCAS(airbase)
  local targetCoordinate = airbase:GetCoordinate():Translate(10000, 90)
  local zone = ZONE_RADIUS:New("OMW_SHND_PHYSICAL_LOSS_ZONE", targetCoordinate:GetVec2(), 1500)
  local mission = AUFTRAG:NewCAS(zone, 5500, 100)
  mission:SetRequiredAssets(1, 1)
  mission:SetTime(5, MISSION_DURATION_S)
  mission:SetROE(ENUMS.ROE.WeaponHold)
  return mission
end

local function explodeFlightGroup()
  if runtime.finished then return end
  runtime.phase = "PHYSICAL_EXPLOSION"
  runtime.explosionRequested = true

  local group = runtime.flightGroup and runtime.flightGroup.GetGroup and runtime.flightGroup:GetGroup() or nil
  if not group then return fail("EXPLOSION", "FLIGHTGROUP:GetGroup() returned nil") end
  local units = group:GetUnits()
  if type(units) ~= "table" or #units == 0 then return fail("EXPLOSION", "GROUP:GetUnits() returned no units") end

  for _, unit in ipairs(units) do
    if unit and unit:IsAlive() then
      local result = unit:Explode(EXPLOSION_POWER_KG_TNT)
      if result then
        runtime.unitsExploded = runtime.unitsExploded + 1
        log(string.format("UNIT_EXPLODE unit=%s powerKgTNT=%d", tostring(unit:GetName()), EXPLOSION_POWER_KG_TNT))
      end
    end
  end

  if runtime.unitsExploded == 0 then return fail("EXPLOSION", "No live unit accepted UNIT:Explode()") end

  SCHEDULER:New(nil, function()
    if runtime.finished then return end
    local ok, err = pcall(function()
      runtime.phase = "POST_EXPLOSION_OBSERVE"
      local shindand = requireFoundation()
      local groupAfter = runtime.flightGroup and runtime.flightGroup.GetGroup and runtime.flightGroup:GetGroup() or nil
      local alive = 0
      if groupAfter then
        local unitsAfter = groupAfter:GetUnits() or {}
        for _, unit in ipairs(unitsAfter) do
          if unit and unit:IsAlive() then alive = alive + 1 end
        end
      end
      runtime.unitsAliveAfter = alive
      runtime.assetStockAfter = shindand.Squadrons.AH64D:CountAssets(true)
      runtime.assetTotalAfter = shindand.Squadrons.AH64D:CountAssets()
      runtime.final = readInventory(runtime.storage)
      logInventoryDeltas("POST_EXPLOSION_VS_POST_SPAWN", runtime.postSpawn, runtime.final)

      local storeRecovery, storeRecovered, storeDebited = classifyKnownWeaponRecovery()
      runtime.storeRecovery = storeRecovery
      local aircraftRecovery, aircraftRecovered, aircraftDebited = classifyRecovery(runtime.baseline.aircraft, runtime.postSpawn.aircraft, runtime.final.aircraft, "aircraft")
      local liquidRecovery, liquidRecovered, liquidDebited = classifyRecovery(runtime.baseline.liquids, runtime.postSpawn.liquids, runtime.final.liquids, "liquids")
      runtime.aircraftRecovery = aircraftRecovery
      runtime.liquidRecovery = liquidRecovery

      log(string.format("PHYSICAL_LOSS_OBSERVATION unitsAliveAfter=%d storeRecovery=%s storeRecovered=%s storeDebited=%s aircraftRecovery=%s aircraftRecovered=%s aircraftDebited=%s liquidRecovery=%s liquidRecovered=%s liquidDebited=%s", alive, storeRecovery, tostring(storeRecovered), tostring(storeDebited), aircraftRecovery, tostring(aircraftRecovered), tostring(aircraftDebited), liquidRecovery, tostring(liquidRecovered), tostring(liquidDebited)))
    end)
    if not ok then return fail("POST_EXPLOSION_OBSERVE", err) end
    finish("PASS")
  end, {}, POST_EXPLOSION_OBSERVE_S)
end

local function startTest()
  local ok, err = pcall(function()
    runtime.startedAt = timer.getTime()
    runtime.nextHeartbeatAt = runtime.startedAt + HEARTBEAT_INTERVAL_S
    runtime.phase = "BASELINE"

    local shindand = requireFoundation()
    runtime.storage = shindand.Airbase:GetStorage()
    if not runtime.storage then error("Shindand STORAGE unresolved") end
    local storageByName = STORAGE:FindByName("Shindand Heliport")
    if not storageByName or storageByName ~= runtime.storage then error("Shindand STORAGE wrapper identity mismatch") end

    runtime.baseline = readInventory(runtime.storage)
    runtime.assetStockBefore = shindand.Squadrons.AH64D:CountAssets(true)
    runtime.assetTotalBefore = shindand.Squadrons.AH64D:CountAssets()
    log(string.format("BASELINE_READY assetStock=%d assetTotal=%d m151=%s agm114k=%s comboPak=%s", runtime.assetStockBefore, runtime.assetTotalBefore, tostring(runtime.baseline.weapons[ITEM_M151]), tostring(runtime.baseline.weapons[ITEM_AGM114K]), tostring(runtime.baseline.weapons[ITEM_COMBOPAK])))

    for item, expectedDebit in pairs(EXPECTED_AH64_DEBIT) do
      local amount = tonumber(runtime.baseline.weapons[item])
      if not amount or amount < expectedDebit then
        error(string.format("Insufficient baseline stock item=%s amount=%s minimum=%d", item, tostring(amount), expectedDebit))
      end
    end

    local mission = makeNoFireCAS(shindand.Airbase)
    mission:AssignSquadrons({ shindand.Squadrons.AH64D })

    local previousFlightOnMission = shindand.Airwing.OnAfterFlightOnMission
    shindand.Airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
      if previousFlightOnMission then previousFlightOnMission(self, From, Event, To, FlightGroup, Mission) end
      if runtime.finished or runtime.assigned or Mission ~= mission then return end
      runtime.assigned = true
      runtime.flightGroup = FlightGroup
      runtime.phase = "ASSIGNED"
      local assignedOk, assignedErr = pcall(function()
        runtime.postSpawn = readInventory(runtime.storage)
        exactWeaponDebit(runtime.baseline, runtime.postSpawn)
        logInventoryDeltas("SPAWN_VS_BASELINE", runtime.baseline, runtime.postSpawn)
        local ammo = FlightGroup:GetAmmoTot()
        if ammo then
          log(string.format("AMMO_ASSIGNED missilesAG=%s rockets=%s guns=%s", tostring(ammo.MissilesAG), tostring(ammo.Rockets), tostring(ammo.Guns)))
        end
      end)
      if not assignedOk then return fail("ASSIGNED", assignedErr) end
      notify("AH-64 materialized. Physical MOOSE UNIT:Explode loss in 5 seconds.")
      SCHEDULER:New(nil, explodeFlightGroup, {}, EXPLOSION_DELAY_S)
    end

    runtime.phase = "DISPATCH_REQUEST"
    shindand.Airwing:AddMission(mission)
    notify("Physical aircraft-loss recovery test started. Waiting for AH-64 materialization.")
  end)
  if not ok then fail("START", err) end
end

SCHEDULER:New(nil, function()
  if not runtime.finished then startTest() end
end, {}, START_DELAY_S)

SCHEDULER:New(nil, function()
  if runtime.finished then return end
  local now = timer.getTime()
  if now >= runtime.nextHeartbeatAt then
    runtime.nextHeartbeatAt = now + HEARTBEAT_INTERVAL_S
    log(string.format("HEARTBEAT phase=%s elapsed=%.1f assigned=%s explosionRequested=%s unitsExploded=%d", runtime.phase, now - runtime.startedAt, tostring(runtime.assigned), tostring(runtime.explosionRequested), runtime.unitsExploded))
  end
end, {}, POLL_INTERVAL_S, POLL_INTERVAL_S)

SCHEDULER:New(nil, function()
  if not runtime.finished then
    fail("SAFETY_TIMEOUT", "Harness exceeded " .. tostring(SAFETY_TIMEOUT_S) .. " seconds")
  end
end, {}, SAFETY_TIMEOUT_S)
