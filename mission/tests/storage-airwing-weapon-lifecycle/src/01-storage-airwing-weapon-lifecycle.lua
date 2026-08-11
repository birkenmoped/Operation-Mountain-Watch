-- Operation Mountain Watch - combined STORAGE/AIRWING lifecycle gate.
-- Read-only STORAGE observer. The only deliberate runtime mutation is the MOOSE
-- OPSGROUP:Destroy() call used to exercise the native aircraft-loss path.

local TAG = "[OMW][StorageAirwingWeaponLifecycle]"
local TEST_ID = "STORAGE-AIRWING-WEAPON-LIFECYCLE-6"
local START_DELAY_S = 20
local POLL_INTERVAL_S = 5
local POST_EVENT_OBSERVE_S = 15
local NEXT_PHASE_DELAY_S = 10
local LOSS_DESTROY_DELAY_S = 2
local SAFETY_TIMEOUT_S = 1800
local HEARTBEAT_INTERVAL_S = 120
local STATUS_MESSAGE_DURATION_S = 12
local FINAL_MESSAGE_DURATION_S = 30
local MISSION_DURATION_S = 120

local ITEM_M151 = "weapons.nurs.HYDRA_70_M151"
local ITEM_AGM114K = "weapons.missiles.AGM_114K"
local ITEM_COMBOPAK = "weapons.droptanks.{IAFS_ComboPak_100}"
local DROPTANK_PREFIX = "weapons.droptanks."

local EXPECTED_AH64_DEBIT = {
  [ITEM_M151] = 76,
  [ITEM_AGM114K] = 4,
  [ITEM_COMBOPAK] = 2,
}

-- The two AH-64 legs execute sequentially. V2 already demonstrated full no-fire
-- recredit for M151 and AGM-114K, so those stores only need one TwoShip debit at
-- baseline. IAFS did not recredit in V2 and therefore needs stock for both legs.
local BASELINE_MINIMUM_AH64_STOCK = {
  [ITEM_M151] = 76,
  [ITEM_AGM114K] = 4,
  [ITEM_COMBOPAK] = 4,
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
  ah64Control = {
    assigned = false,
    arrived = false,
    debitValidated = false,
    recredit = "UNKNOWN",
  },
  ah64Loss = {
    assigned = false,
    destroyRequested = false,
    observed = false,
    preDispatch = nil,
    postSpawn = nil,
    stockBefore = nil,
    totalBefore = nil,
    stockAfter = nil,
    totalAfter = nil,
    assetLoss = "UNKNOWN",
    storeRecovery = "UNKNOWN",
  },
  f16 = {
    assigned = false,
    arrived = false,
    preDispatch = nil,
    tankDebits = {},
    tankDebitTotal = 0,
    tankDebitExpectedMatched = false,
    tankRecoveredTotal = 0,
    tankRecredit = "UNKNOWN",
  },
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function notify(message, duration)
  MESSAGE:New(tostring(message), duration or STATUS_MESSAGE_DURATION_S, "OMW Test"):ToAll()
end

local function bool(value)
  return value == true
end

local function failResult(stage, message)
  if runtime.finished then return end
  runtime.finished = true
  env.error(TAG .. " FAIL " .. tostring(message), false)
  log(string.format(
    "RESULT testId=%s status=FAIL stage=%s phase=%s baselineValidated=%s storageObservationValid=%s ah64ControlAssigned=%s ah64ControlArrived=%s ah64ControlDebitValidated=%s ah64LossAssigned=%s ah64LossDestroyRequested=%s ah64LossObserved=%s ah64AssetLoss=%s ah64LossStoreRecovery=%s f16Assigned=%s f16Arrived=%s f16TankDebitTotal=%d f16TankDebitExpectedMatched=%s f16TankRecoveredTotal=%d f16TankRecredit=%s deltasObserved=%d error=%s",
    TEST_ID,
    tostring(stage),
    tostring(runtime.phase),
    tostring(runtime.baselineValidated),
    tostring(runtime.storageObservationValid),
    tostring(bool(runtime.ah64Control.assigned)),
    tostring(bool(runtime.ah64Control.arrived)),
    tostring(bool(runtime.ah64Control.debitValidated)),
    tostring(bool(runtime.ah64Loss.assigned)),
    tostring(bool(runtime.ah64Loss.destroyRequested)),
    tostring(bool(runtime.ah64Loss.observed)),
    tostring(runtime.ah64Loss.assetLoss),
    tostring(runtime.ah64Loss.storeRecovery),
    tostring(bool(runtime.f16.assigned)),
    tostring(bool(runtime.f16.arrived)),
    tonumber(runtime.f16.tankDebitTotal) or 0,
    tostring(bool(runtime.f16.tankDebitExpectedMatched)),
    tonumber(runtime.f16.tankRecoveredTotal) or 0,
    tostring(runtime.f16.tankRecredit),
    runtime.deltaCount,
    tostring(message)
  ))
  notify(string.format("STORAGE/AIRWING TEST FAILED\nStage: %s\nPhase: %s\nSend dcs.log + debrief.", tostring(stage), tostring(runtime.phase)), FINAL_MESSAGE_DURATION_S)
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
  for item, minimum in pairs(BASELINE_MINIMUM_AH64_STOCK) do
    local amount = shindand and shindand[item] or nil
    if type(amount) ~= "number" then error("Required Shindand key missing: " .. tostring(item)) end
    log(string.format("BASELINE_REQUIREMENT item=%s amount=%s minimum=%d", item, tostring(amount), minimum))
    if amount < minimum then
      error(string.format("Insufficient Shindand stock item=%s amount=%s minimum=%d", item, tostring(amount), minimum))
    end
  end

  runtime.baselineValidated = true
  runtime.storageObservationValid = true
  log(string.format("BASELINE_VALIDATED shindandWeaponKeys=%d bagramWeaponKeys=%d m151=%s agm114k=%s comboPak=%s minimumM151=76 minimumAgm114k=4 minimumComboPak=4", mapCount(shindand), mapCount(runtime.baseline.BAGRAM), tostring(shindand[ITEM_M151]), tostring(shindand[ITEM_AGM114K]), tostring(shindand[ITEM_COMBOPAK])))
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

local function ammoSummary(flightGroup, label, family)
  local ammo = flightGroup and flightGroup.GetAmmoTot and flightGroup:GetAmmoTot() or nil
  if not ammo then
    log(string.format("AMMO_SNAPSHOT family=%s label=%s unavailable=true", family, label))
    return nil
  end
  local summary = {
    missilesAG = tonumber(ammo.MissilesAG) or 0,
    rockets = tonumber(ammo.Rockets) or 0,
    bombs = tonumber(ammo.Bombs) or 0,
    guns = tonumber(ammo.Guns) or 0,
  }
  log(string.format("AMMO_SNAPSHOT family=%s label=%s missilesAG=%d rockets=%d bombs=%d guns=%d", family, label, summary.missilesAG, summary.rockets, summary.bombs, summary.guns))
  return summary
end

local function ammoEqual(a, b)
  return a and b and a.missilesAG == b.missilesAG and a.rockets == b.rockets and a.bombs == b.bombs and a.guns == b.guns
end

local function exactDebit(before, after, expected, label)
  for item, expectedDebit in pairs(expected) do
    local a = tonumber(before[item])
    local b = tonumber(after[item])
    if not a or not b then error(label .. " value missing item=" .. tostring(item)) end
    local actualDebit = a - b
    if actualDebit ~= expectedDebit then
      error(string.format("%s mismatch item=%s expected=%d actual=%d", label, item, expectedDebit, actualDebit))
    end
  end
end

local function classifyKnownRecovery(postSpawn, finalInventory)
  local debited = 0
  local recovered = 0
  for item, expectedDebit in pairs(EXPECTED_AH64_DEBIT) do
    local spawnValue = tonumber(postSpawn[item]) or 0
    local finalValue = tonumber(finalInventory[item]) or 0
    local itemRecovery = finalValue - spawnValue
    if itemRecovery < 0 then itemRecovery = 0 end
    if itemRecovery > expectedDebit then itemRecovery = expectedDebit end
    debited = debited + expectedDebit
    recovered = recovered + itemRecovery
    log(string.format("AH64_LOSS_STORE_RECOVERY item=%s postSpawn=%d final=%d maxDebit=%d recovered=%d", item, spawnValue, finalValue, expectedDebit, itemRecovery))
  end
  if recovered == 0 then return "NONE", recovered, debited end
  if recovered == debited then return "FULL", recovered, debited end
  return "PARTIAL", recovered, debited
end

local function captureF16TankDebit()
  local current = readWeapons(runtime.storages.BAGRAM, "BAGRAM")
  local total = 0
  local debits = {}
  for key, before in pairs(runtime.f16.preDispatch or {}) do
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
  runtime.f16.tankDebitExpectedMatched = total == 4
  log(string.format("F16_DROPTANK_DEBIT_RESULT total=%d expected=4 expectedMatched=%s keys=%d", total, tostring(runtime.f16.tankDebitExpectedMatched), mapCount(debits)))
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
  if runtime.f16.tankDebitTotal == 0 then
    runtime.f16.tankRecredit = "NOT_OBSERVED"
  elseif recovered == runtime.f16.tankDebitTotal then
    runtime.f16.tankRecredit = "FULL"
  elseif recovered == 0 then
    runtime.f16.tankRecredit = "NONE"
  else
    runtime.f16.tankRecredit = "PARTIAL"
  end
  log(string.format("F16_DROPTANK_RECREDIT_RESULT debitTotal=%d recoveredTotal=%d status=%s expectedDebitMatched=%s", runtime.f16.tankDebitTotal, runtime.f16.tankRecoveredTotal, runtime.f16.tankRecredit, tostring(runtime.f16.tankDebitExpectedMatched)))
end

local function makeNoFireCAS(airbase, name, altitudeFt, speedKts)
  local targetCoordinate = airbase:GetCoordinate():Translate(10000, 90)
  local zone = ZONE_RADIUS:New(name, targetCoordinate:GetVec2(), 1500)
  local mission = AUFTRAG:NewCAS(zone, altitudeFt, speedKts)
  mission:SetRequiredAssets(1, 1)
  mission:SetTime(5, MISSION_DURATION_S)
  mission:SetROE(ENUMS.ROE.WeaponHold)
  return mission
end

local dispatchAH64Control
local dispatchAH64Loss
local dispatchF16
local finishResult

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

local function bindOptionalLanded(flightGroup, family)
  local previous = flightGroup.OnAfterLanded
  flightGroup.OnAfterLanded = function(self, From, Event, To, Airbase)
    if previous then previous(self, From, Event, To, Airbase) end
    if runtime.finished then return end
    log(string.format("LIFECYCLE_EVENT family=%s event=Landed airbase=%s state=%s", family, Airbase and Airbase:GetName() or "nil", tostring(self:GetState())))
  end
end

dispatchAH64Control = function()
  local shindand = requireFoundations()
  local preDispatch = readWeapons(runtime.storages.SHINDAND_HELIPORT, "SHINDAND_HELIPORT")
  local mission = makeNoFireCAS(shindand.Airbase, "OMW_SHND_STORAGE_AH64_CONTROL", 5500, 100)
  mission:AssignSquadrons({ shindand.Squadrons.AH64D })
  runtime.phase = "AH64_CONTROL_DISPATCH_REQUEST"
  log("AH64_CONTROL_DISPATCH_REQUEST")

  local previousFlightOnMission = shindand.Airwing.OnAfterFlightOnMission
  shindand.Airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then previousFlightOnMission(self, From, Event, To, FlightGroup, Mission) end
    if runtime.finished or runtime.ah64Control.assigned or Mission ~= mission then return end
    runtime.ah64Control.assigned = true
    runtime.phase = "AH64_CONTROL_ASSIGNED"
    runtime.ah64Control.assignedAmmo = ammoSummary(FlightGroup, "ASSIGNED", "AH64_CONTROL")
    local ok, err = pcall(function()
      pollDeltas()
      local postSpawn = readWeapons(runtime.storages.SHINDAND_HELIPORT, "SHINDAND_HELIPORT")
      exactDebit(preDispatch, postSpawn, EXPECTED_AH64_DEBIT, "AH64_CONTROL_DEBIT")
      runtime.ah64Control.debitValidated = true
      runtime.ah64Control.postSpawn = postSpawn
      log("AH64_CONTROL_DEBIT_VALIDATED m151=-76 agm114k=-4 comboPak=-2")
    end)
    if not ok then return failResult("AH64_CONTROL_ASSIGNMENT", err) end

    bindOptionalLanded(FlightGroup, "AH64_CONTROL")
    local previousArrived = FlightGroup.OnAfterArrived
    FlightGroup.OnAfterArrived = function(fg, AFrom, AEvent, ATo)
      if previousArrived then previousArrived(fg, AFrom, AEvent, ATo) end
      if runtime.finished or runtime.ah64Control.arrived then return end
      runtime.ah64Control.arrived = true
      runtime.ah64Control.arrivedAmmo = ammoSummary(fg, "ARRIVED", "AH64_CONTROL")
      runtime.phase = "AH64_CONTROL_ARRIVED"
      log(string.format("LIFECYCLE_EVENT family=AH64_CONTROL event=Arrived state=%s", tostring(fg:GetState())))
      SCHEDULER:New(nil, function()
        if runtime.finished then return end
        local returnedOk, returnedErr = pcall(function()
          runtime.phase = "AH64_CONTROL_POST_RETURN"
          pollDeltas()
          local final = readWeapons(runtime.storages.SHINDAND_HELIPORT, "SHINDAND_HELIPORT")
          local status = classifyKnownRecovery(runtime.ah64Control.postSpawn, final)
          runtime.ah64Control.recredit = status
          log(string.format("AH64_CONTROL_RECREDIT_RESULT status=%s noFire=%s", status, tostring(ammoEqual(runtime.ah64Control.assignedAmmo, runtime.ah64Control.arrivedAmmo))))
          logSnapshot("AH64_CONTROL_POST_RETURN")
        end)
        if not returnedOk then return failResult("AH64_CONTROL_POST_RETURN", returnedErr) end
        notify("AH-64 normal return observed. Starting deliberate AH-64 asset-loss leg.")
        SCHEDULER:New(nil, dispatchAH64Loss, {}, NEXT_PHASE_DELAY_S)
      end, {}, POST_EVENT_OBSERVE_S)
    end
    notify("AH-64 normal-return control assigned. Waiting for native Arrived/ReturnToLegion.")
  end
  shindand.Airwing:AddMission(mission)
end

dispatchAH64Loss = function()
  local shindand = requireFoundations()
  runtime.ah64Loss.preDispatch = readWeapons(runtime.storages.SHINDAND_HELIPORT, "SHINDAND_HELIPORT")
  runtime.ah64Loss.stockBefore = shindand.Squadrons.AH64D:CountAssets(true)
  runtime.ah64Loss.totalBefore = shindand.Squadrons.AH64D:CountAssets()
  log(string.format("AH64_LOSS_PRE_DISPATCH stock=%d total=%d", runtime.ah64Loss.stockBefore, runtime.ah64Loss.totalBefore))

  local mission = makeNoFireCAS(shindand.Airbase, "OMW_SHND_STORAGE_AH64_LOSS", 5500, 100)
  mission:AssignSquadrons({ shindand.Squadrons.AH64D })
  runtime.phase = "AH64_LOSS_DISPATCH_REQUEST"
  log("AH64_LOSS_DISPATCH_REQUEST")

  local previousFlightOnMission = shindand.Airwing.OnAfterFlightOnMission
  shindand.Airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then previousFlightOnMission(self, From, Event, To, FlightGroup, Mission) end
    if runtime.finished or runtime.ah64Loss.assigned or Mission ~= mission then return end
    runtime.ah64Loss.assigned = true
    runtime.phase = "AH64_LOSS_ASSIGNED"
    local ok, err = pcall(function()
      pollDeltas()
      runtime.ah64Loss.postSpawn = readWeapons(runtime.storages.SHINDAND_HELIPORT, "SHINDAND_HELIPORT")
      exactDebit(runtime.ah64Loss.preDispatch, runtime.ah64Loss.postSpawn, EXPECTED_AH64_DEBIT, "AH64_LOSS_DEBIT")
      log(string.format("AH64_LOSS_DEBIT_VALIDATED stockAfterSpawn=%d totalAfterSpawn=%d", shindand.Squadrons.AH64D:CountAssets(true), shindand.Squadrons.AH64D:CountAssets()))
    end)
    if not ok then return failResult("AH64_LOSS_ASSIGNMENT", err) end

    notify("AH-64 loss asset materialized. MOOSE OPSGROUP loss event will be triggered.")
    SCHEDULER:New(nil, function()
      if runtime.finished then return end
      runtime.phase = "AH64_LOSS_DESTROY"
      runtime.ah64Loss.destroyRequested = true
      log("AH64_LOSS_DESTROY_REQUEST method=OPSGROUP:Destroy expectedEvent=UnitLost")
      FlightGroup:Destroy()
      SCHEDULER:New(nil, function()
        if runtime.finished then return end
        local observeOk, observeErr = pcall(function()
          runtime.phase = "AH64_LOSS_POST_EVENT"
          pollDeltas()
          runtime.ah64Loss.stockAfter = shindand.Squadrons.AH64D:CountAssets(true)
          runtime.ah64Loss.totalAfter = shindand.Squadrons.AH64D:CountAssets()
          runtime.ah64Loss.observed = true
          if runtime.ah64Loss.totalAfter == runtime.ah64Loss.totalBefore - 1 then
            runtime.ah64Loss.assetLoss = "CONFIRMED"
          else
            runtime.ah64Loss.assetLoss = "NOT_CONFIRMED"
          end
          local final = readWeapons(runtime.storages.SHINDAND_HELIPORT, "SHINDAND_HELIPORT")
          local recovery, recovered, debited = classifyKnownRecovery(runtime.ah64Loss.postSpawn, final)
          runtime.ah64Loss.storeRecovery = recovery
          log(string.format("AH64_LOSS_RESULT assetLoss=%s totalBefore=%d totalAfter=%d stockBefore=%d stockAfter=%d storeRecovery=%s recoveredKnown=%d debitedKnown=%d", runtime.ah64Loss.assetLoss, runtime.ah64Loss.totalBefore, runtime.ah64Loss.totalAfter, runtime.ah64Loss.stockBefore, runtime.ah64Loss.stockAfter, recovery, recovered, debited))
          logSnapshot("AH64_LOSS_POST_EVENT")
        end)
        if not observeOk then return failResult("AH64_LOSS_POST_EVENT", observeErr) end
        notify(string.format("AH-64 loss leg observed: asset=%s, storeRecovery=%s. Starting F-16 tank comparison.", runtime.ah64Loss.assetLoss, runtime.ah64Loss.storeRecovery))
        SCHEDULER:New(nil, dispatchF16, {}, NEXT_PHASE_DELAY_S)
      end, {}, POST_EVENT_OBSERVE_S)
    end, {}, LOSS_DESTROY_DELAY_S)
  end
  shindand.Airwing:AddMission(mission)
end

dispatchF16 = function()
  local _, bagram = requireFoundations()
  runtime.f16.preDispatch = readWeapons(runtime.storages.BAGRAM, "BAGRAM")
  log(string.format("F16_PRE_DISPATCH_CAPTURED weaponKeys=%d", mapCount(runtime.f16.preDispatch)))

  local mission = makeNoFireCAS(bagram.Airbases.USAF, "OMW_BGRM_STORAGE_F16_TANK", 12000, 300)
  mission:AssignSquadrons({ bagram.Squadrons.F16C })
  runtime.phase = "F16_DISPATCH_REQUEST"
  log("F16_DISPATCH_REQUEST expectedAircraft=2 ownerConfirmedExternalTanks=4")

  local previousFlightOnMission = bagram.Airwings.USAF.OnAfterFlightOnMission
  bagram.Airwings.USAF.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then previousFlightOnMission(self, From, Event, To, FlightGroup, Mission) end
    if runtime.finished or runtime.f16.assigned or Mission ~= mission then return end
    runtime.f16.assigned = true
    runtime.phase = "F16_ASSIGNED"
    runtime.f16.assignedAmmo = ammoSummary(FlightGroup, "ASSIGNED", "F16")
    local ok, err = pcall(function()
      pollDeltas()
      captureF16TankDebit()
      logSnapshot("F16_ASSIGNED")
    end)
    if not ok then return failResult("F16_ASSIGNMENT", err) end

    bindOptionalLanded(FlightGroup, "F16")
    local previousArrived = FlightGroup.OnAfterArrived
    FlightGroup.OnAfterArrived = function(fg, AFrom, AEvent, ATo)
      if previousArrived then previousArrived(fg, AFrom, AEvent, ATo) end
      if runtime.finished or runtime.f16.arrived then return end
      runtime.f16.arrived = true
      runtime.f16.arrivedAmmo = ammoSummary(fg, "ARRIVED", "F16")
      runtime.phase = "F16_ARRIVED"
      log(string.format("LIFECYCLE_EVENT family=F16 event=Arrived state=%s", tostring(fg:GetState())))
      SCHEDULER:New(nil, function()
        if runtime.finished then return end
        local returnedOk, returnedErr = pcall(function()
          runtime.phase = "F16_POST_RETURN"
          pollDeltas()
          assessF16TankRecredit()
          logSnapshot("F16_POST_RETURN")
        end)
        if not returnedOk then return failResult("F16_POST_RETURN", returnedErr) end
        finishResult()
      end, {}, POST_EVENT_OBSERVE_S)
    end
    notify(string.format("F-16 TwoShip assigned. Observed droptank debit=%d (expected 4, match=%s). Waiting for native return.", runtime.f16.tankDebitTotal, tostring(runtime.f16.tankDebitExpectedMatched)))
  end
  bagram.Airwings.USAF:AddMission(mission)
end

finishResult = function()
  if runtime.finished then return end
  local ah64ControlNoFire = ammoEqual(runtime.ah64Control.assignedAmmo, runtime.ah64Control.arrivedAmmo)
  local f16NoFire = ammoEqual(runtime.f16.assignedAmmo, runtime.f16.arrivedAmmo)
  local structuralComplete = runtime.baselineValidated
    and runtime.storageObservationValid
    and runtime.ah64Control.assigned
    and runtime.ah64Control.arrived
    and runtime.ah64Control.debitValidated
    and runtime.ah64Loss.assigned
    and runtime.ah64Loss.destroyRequested
    and runtime.ah64Loss.observed
    and runtime.f16.assigned
    and runtime.f16.arrived

  if not structuralComplete then
    return failResult("FINAL_ASSERT", "Required combined lifecycle phases did not complete")
  end

  runtime.phase = "FINAL"
  local ok, err = pcall(function()
    pollDeltas()
    logSnapshot("FINAL")
  end)
  if not ok then return failResult("FINAL_STORAGE", err) end

  runtime.finished = true
  log(string.format(
    "RESULT testId=%s status=PASS nodesExpected=7 nodesReady=7 baselineValidated=true storageObservationValid=true ah64ControlAssigned=true ah64ControlArrived=true ah64ControlDebitValidated=true ah64ControlNoFire=%s ah64ControlRecredit=%s ah64LossAssigned=true ah64LossDestroyRequested=true ah64LossObserved=true ah64AssetLoss=%s ah64LossStoreRecovery=%s f16Assigned=true f16Arrived=true f16NoFire=%s f16TankDebitTotal=%d f16TankDebitExpected=4 f16TankDebitExpectedMatched=%s f16TankRecoveredTotal=%d f16TankRecredit=%s storageMutation=false campaignStateMutation=false returnToLegionCalledByTest=false deliberateLossMethod=OPSGROUP_Destroy directSpawn=false opstransport=false ctld=false deltasObserved=%d",
    TEST_ID,
    tostring(ah64ControlNoFire),
    tostring(runtime.ah64Control.recredit),
    tostring(runtime.ah64Loss.assetLoss),
    tostring(runtime.ah64Loss.storeRecovery),
    tostring(f16NoFire),
    runtime.f16.tankDebitTotal,
    tostring(runtime.f16.tankDebitExpectedMatched),
    runtime.f16.tankRecoveredTotal,
    tostring(runtime.f16.tankRecredit),
    runtime.deltaCount
  ))
  notify(string.format("STORAGE/AIRWING TEST COMPLETE - PASS\nAH-64 normal return: %s\nAH-64 loss asset: %s / stores: %s\nF-16 tanks: debit %d (expected 4), recredit %s (%d/%d)\nSend dcs.log + debrief.", runtime.ah64Control.recredit, runtime.ah64Loss.assetLoss, runtime.ah64Loss.storeRecovery, runtime.f16.tankDebitTotal, runtime.f16.tankRecredit, runtime.f16.tankRecoveredTotal, runtime.f16.tankDebitTotal), FINAL_MESSAGE_DURATION_S)
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

  log("TEST_BEGIN phases=AH64_NORMAL_RETURN,AH64_ASSET_LOSS,F16_DROPTANK_RETURN")
  notify("STORAGE/AIRWING TEST STARTED\n1 AH-64 normal return\n2 AH-64 deliberate loss\n3 F-16 external-tank return")

  SCHEDULER:New(nil, function()
    if runtime.finished then return end
    local pollOk, pollErr = pcall(pollDeltas)
    if not pollOk then return failResult("POLL", pollErr) end
    local now = timer.getTime()
    if now >= runtime.nextHeartbeatAt then
      runtime.nextHeartbeatAt = now + HEARTBEAT_INTERVAL_S
      notify(string.format("OMW combined lifecycle test running\nPhase: %s\nElapsed: %ds", runtime.phase, math.floor(now - runtime.startedAt)), 8)
    end
  end, {}, POLL_INTERVAL_S, POLL_INTERVAL_S)

  SCHEDULER:New(nil, function()
    if not runtime.finished then failResult("SAFETY_TIMEOUT", "Combined lifecycle did not complete within safety timeout") end
  end, {}, SAFETY_TIMEOUT_S)

  dispatchAH64Control()
end

SCHEDULER:New(nil, beginTest, {}, START_DELAY_S)
