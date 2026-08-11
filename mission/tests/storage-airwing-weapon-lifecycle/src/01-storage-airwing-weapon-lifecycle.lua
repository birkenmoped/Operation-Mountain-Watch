-- Operation Mountain Watch - STORAGE/AIRWING weapon lifecycle correlation.
-- Read-only STORAGE observer for AH-64D external stores / IAFS and F-16 external tanks.

local TAG = "[OMW][StorageAirwingWeaponLifecycle]"
local TEST_ID = "STORAGE-AIRWING-WEAPON-LIFECYCLE-4"
local START_DELAY_S = 20
local POLL_INTERVAL_S = 5
local POST_RETURN_OBSERVE_S = 15
local NEXT_DISPATCH_DELAY_S = 10
local SAFETY_TIMEOUT_S = 1800
local HEARTBEAT_INTERVAL_S = 120
local STATUS_MESSAGE_DURATION_S = 12
local FINAL_MESSAGE_DURATION_S = 30
local MISSION_DURATION_S = 120

local ITEM_M151 = "weapons.nurs.HYDRA_70_M151"
local ITEM_AGM114K = "weapons.missiles.AGM_114K"
local ITEM_COMBOPAK = "weapons.droptanks.{IAFS_ComboPak_100}"
local DROPTANK_PREFIX = "weapons.droptanks."

local EXPECTED_AH64_FIRST_DEBIT = {
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
  baseline = {},
  lastInventory = {},
  deltaCount = 0,
  phase = "INIT",
  finished = false,
  startedAt = 0,
  nextHeartbeatAt = 0,
  baselineValidated = false,
  storageObservationValid = false,
  ah64FirstDebitValidated = false,
  ah64 = { first = {}, second = {} },
  f16 = { sortie = {}, preDispatch = nil, tankDebits = nil, tankDebitTotal = 0, tankRecoveredTotal = 0, tankRecredit = "UNKNOWN" },
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function notify(message, duration)
  MESSAGE:New(tostring(message), duration or STATUS_MESSAGE_DURATION_S, "OMW Test"):ToAll()
end

local function failResult(stage, message)
  if runtime.finished then return end
  runtime.finished = true
  env.error(TAG .. " FAIL " .. tostring(message), false)
  log(string.format(
    "RESULT testId=%s status=FAIL stage=%s phase=%s baselineValidated=%s storageObservationValid=%s ah64FirstDebitValidated=%s ah64FirstAssigned=%s ah64FirstArrived=%s ah64SecondAssigned=%s ah64SecondArrived=%s f16Assigned=%s f16Arrived=%s f16TankDebitTotal=%d f16TankRecoveredTotal=%d f16TankRecredit=%s deltasObserved=%d error=%s",
    TEST_ID,
    tostring(stage),
    tostring(runtime.phase),
    tostring(runtime.baselineValidated),
    tostring(runtime.storageObservationValid),
    tostring(runtime.ah64FirstDebitValidated),
    tostring(runtime.ah64.first.assigned == true),
    tostring(runtime.ah64.first.arrived == true),
    tostring(runtime.ah64.second.assigned == true),
    tostring(runtime.ah64.second.arrived == true),
    tostring(runtime.f16.sortie.assigned == true),
    tostring(runtime.f16.sortie.arrived == true),
    tonumber(runtime.f16.tankDebitTotal) or 0,
    tonumber(runtime.f16.tankRecoveredTotal) or 0,
    tostring(runtime.f16.tankRecredit),
    runtime.deltaCount,
    tostring(message)
  ))
  notify(string.format("STORAGE/AIRWING TEST FAILED\nStage: %s\nPhase: %s\nYou may stop the mission and send dcs.log + debrief.", tostring(stage), tostring(runtime.phase)), FINAL_MESSAGE_DURATION_S)
end

local function copyMap(source)
  local result = {}
  for key, value in pairs(source or {}) do
    if type(value) == "number" then result[tostring(key)] = value end
  end
  return result
end

local function mapCount(source)
  local count = 0
  for _ in pairs(source or {}) do count = count + 1 end
  return count
end

local function readWeapons(storage, nodeId)
  local aircraft, liquids, weapons = storage:GetInventory()
  if type(aircraft) ~= "table" or type(liquids) ~= "table" or type(weapons) ~= "table" then
    error(string.format("GetInventory invalid nodeId=%s aircraft=%s liquids=%s weapons=%s", tostring(nodeId), type(aircraft), type(liquids), type(weapons)))
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
    if count <= 0 then error("Weapon inventory unexpectedly empty nodeId=" .. tostring(node.id)) end
    runtime.baseline[node.id] = copyMap(inventory)
    runtime.lastInventory[node.id] = copyMap(inventory)
    log(string.format("BASELINE_CAPTURED nodeId=%s weaponKeys=%d", node.id, count))
  end

  local shindand = runtime.baseline.SHINDAND_HELIPORT
  for item, required in pairs(EXPECTED_AH64_FIRST_DEBIT) do
    local amount = shindand and shindand[item] or nil
    if type(amount) ~= "number" then error("Required Shindand key missing: " .. tostring(item)) end
    if amount < required then error(string.format("Insufficient Shindand stock item=%s amount=%s required=%d", item, tostring(amount), required)) end
  end

  runtime.baselineValidated = true
  runtime.storageObservationValid = true
  log(string.format("BASELINE_VALIDATED shindandWeaponKeys=%d bagramWeaponKeys=%d m151=%s agm114k=%s comboPak=%s", mapCount(runtime.baseline.SHINDAND_HELIPORT), mapCount(runtime.baseline.BAGRAM), tostring(shindand[ITEM_M151]), tostring(shindand[ITEM_AGM114K]), tostring(shindand[ITEM_COMBOPAK])))
end

local function logSnapshot(label)
  for _, node in ipairs(NODES) do
    local inventory = readWeapons(runtime.storages[node.id], node.id)
    log(string.format("SNAPSHOT label=%s nodeId=%s m151=%s agm114k=%s comboPak=%s weaponKeys=%d", label, node.id, tostring(inventory[ITEM_M151]), tostring(inventory[ITEM_AGM114K]), tostring(inventory[ITEM_COMBOPAK]), mapCount(inventory)))
  end
end

local function pollDeltas()
  if not runtime.storageObservationValid then error("STORAGE observation invalid") end
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
        log(string.format("WEAPON_DELTA phase=%s nodeId=%s item=%s before=%s after=%s delta=%s elapsed=%.1f", runtime.phase, node.id, key, tostring(before), tostring(after), tostring(after - before), timer.getTime() - runtime.startedAt))
      end
    end
    runtime.lastInventory[node.id] = current
  end
end

local function ammoSummary(flightGroup, label, family, sortie)
  local ammo = flightGroup and flightGroup.GetAmmoTot and flightGroup:GetAmmoTot() or nil
  if not ammo then
    log(string.format("AMMO_SNAPSHOT family=%s sortie=%s label=%s unavailable=true", family, tostring(sortie), label))
    return nil
  end
  local summary = {
    missilesAG = tonumber(ammo.MissilesAG) or 0,
    rockets = tonumber(ammo.Rockets) or 0,
    bombs = tonumber(ammo.Bombs) or 0,
    guns = tonumber(ammo.Guns) or 0,
  }
  log(string.format("AMMO_SNAPSHOT family=%s sortie=%s label=%s missilesAG=%d rockets=%d bombs=%d guns=%d", family, tostring(sortie), label, summary.missilesAG, summary.rockets, summary.bombs, summary.guns))
  return summary
end

local function ammoEqual(a, b)
  return a and b and a.missilesAG == b.missilesAG and a.rockets == b.rockets and a.bombs == b.bombs and a.guns == b.guns
end

local function validateAH64FirstDebit()
  local current = readWeapons(runtime.storages.SHINDAND_HELIPORT, "SHINDAND_HELIPORT")
  local baseline = runtime.baseline.SHINDAND_HELIPORT
  for item, expectedDebit in pairs(EXPECTED_AH64_FIRST_DEBIT) do
    local before = tonumber(baseline[item])
    local after = tonumber(current[item])
    if not before or not after then error("AH-64 debit value missing item=" .. tostring(item)) end
    local actualDebit = before - after
    if actualDebit ~= expectedDebit then error(string.format("AH-64 debit mismatch item=%s expected=%d actual=%d", item, expectedDebit, actualDebit)) end
  end
  runtime.ah64FirstDebitValidated = true
  log("AH64_FIRST_DEBIT_VALIDATED m151=-76 agm114k=-4 comboPak=-2")
end

local function captureF16PreDispatch()
  runtime.f16.preDispatch = readWeapons(runtime.storages.BAGRAM, "BAGRAM")
  log(string.format("F16_PRE_DISPATCH_CAPTURED weaponKeys=%d", mapCount(runtime.f16.preDispatch)))
end

local function validateF16TankDebit()
  local current = readWeapons(runtime.storages.BAGRAM, "BAGRAM")
  local baseline = runtime.f16.preDispatch
  local debits = {}
  local total = 0
  for key, before in pairs(baseline or {}) do
    if string.sub(key, 1, #DROPTANK_PREFIX) == DROPTANK_PREFIX then
      local after = tonumber(current[key]) or 0
      local debit = (tonumber(before) or 0) - after
      if debit > 0 then
        debits[key] = { before = tonumber(before) or 0, afterSpawn = after, debit = debit }
        total = total + debit
        log(string.format("F16_DROPTANK_DEBIT item=%s before=%s after=%s debit=%s", key, tostring(before), tostring(after), tostring(debit)))
      end
    end
  end
  runtime.f16.tankDebits = debits
  runtime.f16.tankDebitTotal = total
  if total ~= 4 then
    error(string.format("Expected F-16 TwoShip external-tank debit total=4, observed=%d", total))
  end
  log("F16_DROPTANK_DEBIT_VALIDATED total=-4 expectedTwoShipTanks=4")
end

local function assessF16TankRecredit()
  local current = readWeapons(runtime.storages.BAGRAM, "BAGRAM")
  local recovered = 0
  for key, observation in pairs(runtime.f16.tankDebits or {}) do
    local final = tonumber(current[key]) or 0
    local recovery = final - observation.afterSpawn
    if recovery < 0 then recovery = 0 end
    if recovery > observation.debit then recovery = observation.debit end
    recovered = recovered + recovery
    log(string.format("F16_DROPTANK_RECREDIT item=%s pre=%d afterSpawn=%d final=%d debit=%d recovered=%d", key, observation.before, observation.afterSpawn, final, observation.debit, recovery))
  end
  runtime.f16.tankRecoveredTotal = recovered
  if recovered == runtime.f16.tankDebitTotal then
    runtime.f16.tankRecredit = "FULL"
  elseif recovered == 0 then
    runtime.f16.tankRecredit = "NONE"
  else
    runtime.f16.tankRecredit = "PARTIAL"
  end
  log(string.format("F16_DROPTANK_RECREDIT_RESULT debitTotal=%d recoveredTotal=%d status=%s", runtime.f16.tankDebitTotal, runtime.f16.tankRecoveredTotal, runtime.f16.tankRecredit))
end

local function makeCAS(airbase, name, altitudeFt, speedKts)
  local targetCoordinate = airbase:GetCoordinate():Translate(10000, 90)
  local zone = ZONE_RADIUS:New(name, targetCoordinate:GetVec2(), 1500)
  local mission = AUFTRAG:NewCAS(zone, altitudeFt, speedKts)
  mission:SetRequiredAssets(1, 1)
  mission:SetTime(5, MISSION_DURATION_S)
  mission:SetROE(ENUMS.ROE.WeaponHold)
  return mission
end

local dispatchAH64
local dispatchF16

local function finishPass()
  if runtime.finished then return end
  local ah1NoFire = ammoEqual(runtime.ah64.first.assignedAmmo, runtime.ah64.first.arrivedAmmo)
  local ah2NoFire = ammoEqual(runtime.ah64.second.assignedAmmo, runtime.ah64.second.arrivedAmmo)
  local f16NoFire = ammoEqual(runtime.f16.sortie.assignedAmmo, runtime.f16.sortie.arrivedAmmo)
  local complete = runtime.baselineValidated and runtime.storageObservationValid and runtime.ah64FirstDebitValidated
    and runtime.ah64.first.assigned and runtime.ah64.first.arrived
    and runtime.ah64.second.assigned and runtime.ah64.second.arrived
    and runtime.f16.sortie.assigned and runtime.f16.sortie.arrived
    and runtime.f16.tankDebitTotal == 4 and ah1NoFire and ah2NoFire and f16NoFire
  if not complete then return failResult("FINAL_ASSERT", "Required combined lifecycle invariant not satisfied") end

  runtime.phase = "FINAL"
  local ok, err = pcall(function()
    pollDeltas()
    assessF16TankRecredit()
    logSnapshot("FINAL")
  end)
  if not ok then return failResult("FINAL_STORAGE", err) end

  runtime.finished = true
  log(string.format("RESULT testId=%s status=PASS nodesExpected=7 nodesReady=7 baselineValidated=true storageObservationValid=true ah64FirstDebitValidated=true ah64FirstAssigned=true ah64FirstArrived=true ah64SecondAssigned=true ah64SecondArrived=true ah64FirstNoFire=true ah64SecondNoFire=true f16Assigned=true f16Arrived=true f16NoFire=true f16TankDebitTotal=%d f16TankRecoveredTotal=%d f16TankRecredit=%s storageMutation=false campaignStateMutation=false returnToLegionCalledByTest=false directSpawn=false opstransport=false ctld=false deltasObserved=%d", TEST_ID, runtime.f16.tankDebitTotal, runtime.f16.tankRecoveredTotal, runtime.f16.tankRecredit, runtime.deltaCount))
  notify(string.format("STORAGE/AIRWING TEST COMPLETE - PASS\nAH-64 lifecycle + F-16 tank comparison complete.\nF-16 tank recredit: %s (%d/%d)\nYou may stop the mission and send dcs.log + debrief.", runtime.f16.tankRecredit, runtime.f16.tankRecoveredTotal, runtime.f16.tankDebitTotal), FINAL_MESSAGE_DURATION_S)
end

local function bindArrived(slot, flightGroup, family, sortie, onReturned)
  slot.flightGroup = flightGroup
  slot.assigned = true
  slot.assignedAmmo = ammoSummary(flightGroup, "ASSIGNED", family, sortie)

  local previousLanded = flightGroup.OnAfterLanded
  flightGroup.OnAfterLanded = function(self, From, Event, To, Airbase)
    if previousLanded then previousLanded(self, From, Event, To, Airbase) end
    if runtime.finished then return end
    slot.landed = true
    slot.landedAmmo = ammoSummary(self, "LANDED", family, sortie)
    log(string.format("LIFECYCLE_EVENT family=%s sortie=%s event=Landed airbase=%s state=%s", family, tostring(sortie), Airbase and Airbase:GetName() or "nil", tostring(self:GetState())))
  end

  local previousArrived = flightGroup.OnAfterArrived
  flightGroup.OnAfterArrived = function(self, From, Event, To)
    if previousArrived then previousArrived(self, From, Event, To) end
    if runtime.finished or slot.arrived then return end
    slot.arrived = true
    slot.arrivedAmmo = ammoSummary(self, "ARRIVED", family, sortie)
    runtime.phase = string.upper(family) .. "_" .. tostring(sortie) .. "_ARRIVED"
    log(string.format("LIFECYCLE_EVENT family=%s sortie=%s event=Arrived state=%s landedObserved=%s", family, tostring(sortie), tostring(self:GetState()), tostring(slot.landed == true)))
    local ok, err = pcall(function() pollDeltas(); logSnapshot(runtime.phase) end)
    if not ok then return failResult("ARRIVED_STORAGE", err) end
    SCHEDULER:New(nil, function()
      if runtime.finished then return end
      local returnedOk, returnedErr = pcall(function()
        runtime.phase = string.upper(family) .. "_" .. tostring(sortie) .. "_POST_RETURN"
        pollDeltas()
        logSnapshot(runtime.phase)
        onReturned()
      end)
      if not returnedOk then failResult("POST_RETURN", returnedErr) end
    end, {}, POST_RETURN_OBSERVE_S)
  end
end

local function requireFoundations()
  local shindand = OMW and OMW.AirOps and OMW.AirOps.Shindand or nil
  local bagram = OMW and OMW.AirOps and OMW.AirOps.Bagram or nil
  if not shindand or shindand.Status ~= "RUNNING" or not shindand.Airwing or not shindand.Squadrons or not shindand.Squadrons.AH64D then
    error("Shindand AH-64 foundation is not RUNNING")
  end
  if not bagram or bagram.Status ~= "RUNNING" or not bagram.Airwings or not bagram.Airwings.USAF or not bagram.Squadrons or not bagram.Squadrons.F16C then
    error("Bagram F-16 foundation is not RUNNING")
  end
  return shindand, bagram
end

function dispatchAH64(sortie)
  local shindand = requireFoundations()
  local slot = sortie == 1 and runtime.ah64.first or runtime.ah64.second
  local mission = makeCAS(shindand.Airbase, "OMW_SHND_STORAGE_AH64_" .. tostring(sortie), 5500, 100)
  mission:AssignSquadrons({ shindand.Squadrons.AH64D })
  runtime.phase = "AH64_" .. tostring(sortie) .. "_DISPATCH_REQUEST"
  log(string.format("AH64_DISPATCH_REQUEST sortie=%d squadron=%s", sortie, tostring(shindand.Squadrons.AH64D.name)))

  local previous = shindand.Airwing.OnAfterFlightOnMission
  shindand.Airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if previous then previous(self, From, Event, To, FlightGroup, Mission) end
    if runtime.finished or slot.assigned or Mission ~= mission then return end
    runtime.phase = "AH64_" .. tostring(sortie) .. "_ASSIGNED"
    local ok, err = pcall(function()
      pollDeltas()
      if sortie == 1 then validateAH64FirstDebit() end
      logSnapshot(runtime.phase)
    end)
    if not ok then return failResult("AH64_ASSIGNMENT_STORAGE", err) end
    bindArrived(slot, FlightGroup, "AH64", sortie, function()
      if sortie == 1 then
        notify("AH-64 first return observed. Dispatching second AH-64 lifecycle leg.")
        SCHEDULER:New(nil, function() dispatchAH64(2) end, {}, NEXT_DISPATCH_DELAY_S)
      else
        notify("AH-64 lifecycle complete. Dispatching Bagram F-16 TwoShip tank comparison.")
        SCHEDULER:New(nil, function() dispatchF16() end, {}, NEXT_DISPATCH_DELAY_S)
      end
    end)
    notify(string.format("AH-64 sortie %d assigned. Waiting for native Arrived/ReturnToLegion.", sortie))
  end
  shindand.Airwing:AddMission(mission)
end

function dispatchF16()
  local _, bagram = requireFoundations()
  captureF16PreDispatch()
  local mission = makeCAS(bagram.Airbases.USAF, "OMW_BGRM_STORAGE_F16_TANK", 12000, 300)
  mission:AssignSquadrons({ bagram.Squadrons.F16C })
  runtime.phase = "F16_DISPATCH_REQUEST"
  log(string.format("F16_DISPATCH_REQUEST squadron=%s expectedAircraft=2 expectedExternalTanks=4", tostring(bagram.Squadrons.F16C.name)))

  local previous = bagram.Airwings.USAF.OnAfterFlightOnMission
  bagram.Airwings.USAF.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if previous then previous(self, From, Event, To, FlightGroup, Mission) end
    if runtime.finished or runtime.f16.sortie.assigned or Mission ~= mission then return end
    runtime.phase = "F16_ASSIGNED"
    local ok, err = pcall(function()
      pollDeltas()
      validateF16TankDebit()
      logSnapshot(runtime.phase)
    end)
    if not ok then return failResult("F16_ASSIGNMENT_STORAGE", err) end
    bindArrived(runtime.f16.sortie, FlightGroup, "F16", 1, function()
      local assessOk, assessErr = pcall(assessF16TankRecredit)
      if not assessOk then return failResult("F16_TANK_RECREDIT", assessErr) end
      finishPass()
    end)
    notify("F-16 TwoShip assigned and -4 external-tank debit validated. Waiting for native return/recredit.")
  end
  bagram.Airwings.USAF:AddMission(mission)
end

local function beginTest()
  if runtime.finished then return end
  runtime.startedAt = timer.getTime()
  runtime.nextHeartbeatAt = runtime.startedAt + HEARTBEAT_INTERVAL_S
  runtime.phase = "BASELINE"
  local ok, err = pcall(function()
    requireFoundations()
    resolveStorages()
    captureBaseline()
    logSnapshot("BASELINE")
  end)
  if not ok then return failResult("BASELINE", err) end

  log("TEST_BEGIN combined AH-64 lifecycle and F-16 external-tank comparison")
  notify("STORAGE/AIRWING TEST STARTED\nBaseline validated.\nPhase 1: AH-64 lifecycle. Phase 2: F-16 external-tank comparison.")

  SCHEDULER:New(nil, function()
    if runtime.finished then return end
    local pollOk, pollErr = pcall(pollDeltas)
    if not pollOk then return failResult("POLL", pollErr) end
    local now = timer.getTime()
    if now >= runtime.nextHeartbeatAt then
      runtime.nextHeartbeatAt = now + HEARTBEAT_INTERVAL_S
      notify(string.format("OMW lifecycle test running\nPhase: %s\nElapsed: %ds", runtime.phase, math.floor(now - runtime.startedAt)), 8)
    end
  end, {}, POLL_INTERVAL_S, POLL_INTERVAL_S)

  SCHEDULER:New(nil, function()
    if not runtime.finished then failResult("SAFETY_TIMEOUT", "Combined lifecycle did not complete within safety timeout") end
  end, {}, SAFETY_TIMEOUT_S)

  dispatchAH64(1)
end

SCHEDULER:New(nil, beginTest, {}, START_DELAY_S)
