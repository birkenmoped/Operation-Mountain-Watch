-- Operation Mountain Watch - AIROPS-wide STORAGE/fuel lifecycle census.
--
-- Purpose:
--   * exercise every physical AI template currently represented by the productive
--     AIROPS foundations;
--   * observe DCS STORAGE aircraft, JETFUEL and weapon debits on materialization;
--   * observe native AIRWING return/recredit without mutating STORAGE or CampaignState;
--   * capture onboard fuel telemetry at assignment, Landed and Arrived using public MOOSE APIs.
--
-- Test-only MOOSE coordination:
--   AIRWING:NewPayload() registers an ORBIT-capable payload copied from the exact
--   physical Mission Editor template. Every SQUADRON already has ORBIT capability
--   from SQUADRON:New(). AUFTRAG:AddRequiredPayload() pins that exact test payload.
--   This avoids changing production SQUADRON capabilities and avoids inventing
--   transport/cargo/RESCUEHELO targets merely to materialize a loadout.

local TAG = "[OMW][AirOpsStorageFuelTemplateCensus]"
local TEST_ID = "AIROPS-STORAGE-FUEL-TEMPLATE-CENSUS-1"
local START_DELAY_S = 20
local LANE_STAGGER_S = 3
local NEXT_CASE_DELAY_S = 8
local POST_RETURN_OBSERVE_S = 15
local CASE_TIMEOUT_S = 900
local GLOBAL_TIMEOUT_S = 3600
local ORBIT_DURATION_S = 60
local STATUS_MESSAGE_DURATION_S = 10
local FINAL_MESSAGE_DURATION_S = 30
local FUEL_TOLERANCE_KG = 0.5

local PROFILE = {
  FIGHTER = { altitudeFt = 12000, speedKts = 250 },
  FIXED_TRANSPORT = { altitudeFt = 10000, speedKts = 180 },
  UAV = { altitudeFt = 10000, speedKts = 100 },
  HELO = { altitudeFt = 8000, speedKts = 100 },
}

-- One case per physical AI payload/template seed. Repeated logical roles that use
-- the same physical template are intentionally represented once. Distinct physical
-- payload templates on one SQUADRON (Bagram F-15E, Kandahar UH-60) are separate cases.
local CASES = {
  -- Bagram - one STORAGE lane because USAF and Army AIRWINGs share DCS Bagram storage.
  { id="BGRAM_F15E_CAS", lane="BAGRAM", foundation="Bagram", wing="USAF", squadron="F15E", template="TPL_AIR_US_BGRM_F15E_CAS_2SHIP", profile="FIGHTER" },
  { id="BGRAM_F15E_STRIKE", lane="BAGRAM", foundation="Bagram", wing="USAF", squadron="F15E", template="TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP", profile="FIGHTER" },
  { id="BGRAM_F16C_CAS", lane="BAGRAM", foundation="Bagram", wing="USAF", squadron="F16C", template="TPL_AIR_US_BGRM_F16C_CAS_2SHIP", profile="FIGHTER" },
  { id="BGRAM_C130_TRANSPORT", lane="BAGRAM", foundation="Bagram", wing="USAF", squadron="C130", template="TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP", profile="FIXED_TRANSPORT" },
  { id="BGRAM_HH60G_CSAR", lane="BAGRAM", foundation="Bagram", wing="USAF", squadron="HH60G", template="TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP", profile="HELO" },
  { id="BGRAM_UH60_UTILITY", lane="BAGRAM", foundation="Bagram", wing="Army", squadron="UH60", template="TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP", profile="HELO" },
  { id="BGRAM_CH47_TRANSPORT", lane="BAGRAM", foundation="Bagram", wing="Army", squadron="CH47", template="TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP", profile="HELO" },

  -- Jalalabad / FOB Fenty.
  { id="JBAD_OH58D_RECON", lane="JALALABAD", foundation="Jalalabad", squadron="OH58D", template="TPL_AIR_US_JBAD_OH58D_RECON_2SHIP", profile="HELO" },
  { id="JBAD_AH64D_CAS", lane="JALALABAD", foundation="Jalalabad", squadron="AH64D", template="TPL_AIR_US_JBAD_AH64D_CAS_2SHIP", profile="HELO" },
  { id="JBAD_UH60_MEDEVAC", lane="JALALABAD", foundation="Jalalabad", squadron="UH60", template="TPL_AIR_US_JBAD_UH60_MEDEVAC_1SHIP", profile="HELO" },
  { id="JBAD_CH47_HEAVYLIFT", lane="JALALABAD", foundation="Jalalabad", squadron="CH47", template="TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP", profile="HELO" },

  -- Kandahar main airfield.
  { id="KAF_A10C_CAS", lane="KANDAHAR_MAIN", foundation="Kandahar", wing="Main", squadron="A10C", template="TPL_AIR_US_KAF_A10C_CAS_2SHIP", profile="FIGHTER" },
  { id="KAF_HH60G_CSAR", lane="KANDAHAR_MAIN", foundation="Kandahar", wing="Main", squadron="HH60G", template="TPL_AIR_US_KAF_HH60G_CSAR_1SHIP", profile="HELO" },
  { id="KAF_C130_TRANSPORT", lane="KANDAHAR_MAIN", foundation="Kandahar", wing="Main", squadron="C130", template="TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP", profile="FIXED_TRANSPORT" },
  { id="KAF_MQ1A_RECON", lane="KANDAHAR_MAIN", foundation="Kandahar", wing="Main", squadron="MQ1", template="TPL_AIR_US_KAF_MQ1A_RECON_1SHIP", profile="UAV" },
  { id="KAF_MQ9_RECON", lane="KANDAHAR_MAIN", foundation="Kandahar", wing="Main", squadron="MQ9", template="TPL_AIR_US_KAF_MQ9_RECON_1SHIP", profile="UAV" },

  -- Kandahar Heliport.
  { id="KAF_AH64D_CAS", lane="KANDAHAR_HELIPORT", foundation="Kandahar", wing="Heliport", squadron="AH64D", template="TPL_AIR_US_KAF_AH64D_CAS_2SHIP", profile="HELO" },
  { id="KAF_OH58D_RECON", lane="KANDAHAR_HELIPORT", foundation="Kandahar", wing="Heliport", squadron="OH58D", template="TPL_AIR_US_KAF_OH58D_RECON_2SHIP", profile="HELO" },
  { id="KAF_CH47_TRANSPORT", lane="KANDAHAR_HELIPORT", foundation="Kandahar", wing="Heliport", squadron="CH47", template="TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP", profile="HELO" },
  { id="KAF_UH60_TRANSPORT", lane="KANDAHAR_HELIPORT", foundation="Kandahar", wing="Heliport", squadron="UH60", template="TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP", profile="HELO" },
  { id="KAF_UH60_MEDEVAC", lane="KANDAHAR_HELIPORT", foundation="Kandahar", wing="Heliport", squadron="UH60", template="TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP", profile="HELO" },

  -- FOB Salerno.
  { id="SAL_AH64D_CAS", lane="SALERNO", foundation="Salerno", squadron="AH64D", template="TPL_AIR_US_SAL_AH64D_CAS_2SHIP", profile="HELO" },
  { id="SAL_OH58D_RECON", lane="SALERNO", foundation="Salerno", squadron="OH58D", template="TPL_AIR_US_SAL_OH58D_RECON_2SHIP", profile="HELO" },
  { id="SAL_UH60_ASSAULT", lane="SALERNO", foundation="Salerno", squadron="UH60_ASSAULT", template="TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP", profile="HELO" },
  { id="SAL_UH60_MEDEVAC", lane="SALERNO", foundation="Salerno", squadron="UH60_MEDEVAC", template="TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP", profile="HELO" },
  { id="SAL_CH47_TRANSPORT", lane="SALERNO", foundation="Salerno", squadron="CH47", template="TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP", profile="HELO" },

  -- Shindand Heliport.
  { id="SHND_AH64D_CAS", lane="SHINDAND_HELIPORT", foundation="Shindand", squadron="AH64D", template="TPL_AIR_US_SHND_AH64D_CAS_2SHIP", profile="HELO" },
  { id="SHND_UH60_UTILITY", lane="SHINDAND_HELIPORT", foundation="Shindand", squadron="UH60", template="TPL_AIR_US_SHND_UH60_UTILITY_1SHIP", profile="HELO" },
  { id="SHND_CH47_HEAVYLIFT", lane="SHINDAND_HELIPORT", foundation="Shindand", squadron="CH47", template="TPL_AIR_US_SHND_CH47_HEAVYLIFT_1SHIP", profile="HELO" },

  -- Tarinkot.
  { id="TKOT_AH64D_CAS", lane="TARINKOT", foundation="Tarinkot", squadron="AH64D", template="TPL_AIR_US_TKOT_AH64D_CAS_2SHIP", profile="HELO" },
  { id="TKOT_UH60_MEDEVAC", lane="TARINKOT", foundation="Tarinkot", squadron="UH60", template="TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP", profile="HELO" },
  { id="TKOT_CH47_HEAVYLIFT", lane="TARINKOT", foundation="Tarinkot", squadron="CH47", template="TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP", profile="HELO" },
}

local LANE_DEFS = {
  BAGRAM = { storageName="Bagram" },
  JALALABAD = { storageName="Jalalabad" },
  KANDAHAR_MAIN = { storageName="Kandahar" },
  KANDAHAR_HELIPORT = { storageName="Kandahar Heliport" },
  SALERNO = { storageName="FOB Salerno" },
  SHINDAND_HELIPORT = { storageName="Shindand Heliport" },
  TARINKOT = { storageName="Tarinkot" },
}

local runtime = {
  startedAt = 0,
  finished = false,
  lanes = {},
  casesTotal = #CASES,
  casesObserved = 0,
  casesFailed = 0,
  lanesBlocked = 0,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function notify(message, duration)
  MESSAGE:New(tostring(message), duration or STATUS_MESSAGE_DURATION_S, "OMW Census"):ToAll()
end

local function sortedKeys(map)
  local keys = {}
  for key in pairs(map or {}) do keys[#keys + 1] = tostring(key) end
  table.sort(keys)
  return keys
end

local function copyNumericMap(source)
  local result = {}
  for key, value in pairs(source or {}) do
    if type(value) == "number" then result[tostring(key)] = value end
  end
  return result
end

local function readInventory(storage, laneId)
  local aircraft, liquids, weapons = storage:GetInventory()
  if type(aircraft) ~= "table" or type(liquids) ~= "table" or type(weapons) ~= "table" then
    error(string.format("GetInventory invalid lane=%s aircraft=%s liquids=%s weapons=%s", tostring(laneId), type(aircraft), type(liquids), type(weapons)))
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

local function resolveStorage(laneId, definition)
  local airbase = AIRBASE:FindByName(definition.storageName)
  if not airbase then error("AIRBASE unresolved lane=" .. laneId .. " name=" .. definition.storageName) end
  local fromAirbase = airbase:GetStorage()
  local fromRegistry = STORAGE:FindByName(definition.storageName)
  if not fromAirbase or not fromRegistry then error("STORAGE unresolved lane=" .. laneId .. " name=" .. definition.storageName) end
  if fromAirbase ~= fromRegistry then error("STORAGE wrapper identity mismatch lane=" .. laneId .. " name=" .. definition.storageName) end
  return airbase, fromAirbase
end

local function resolveFoundation(case)
  local state = OMW and OMW.AirOps and OMW.AirOps[case.foundation] or nil
  if not state or state.Status ~= "RUNNING" then
    error("Foundation is not RUNNING: " .. tostring(case.foundation))
  end
  local squadron = state.Squadrons and state.Squadrons[case.squadron] or nil
  if not squadron then error("SQUADRON unresolved case=" .. case.id .. " key=" .. tostring(case.squadron)) end

  local airwing = nil
  local airbase = nil
  if state.Airwings then
    airwing = state.Airwings[case.wing]
    airbase = state.Airbases and state.Airbases[case.wing] or nil
  else
    airwing = state.Airwing
    airbase = state.Airbase
  end
  if not airwing then error("AIRWING unresolved case=" .. case.id .. " wing=" .. tostring(case.wing)) end
  if not airbase then error("AIRBASE state unresolved case=" .. case.id) end

  local template = GROUP:FindByName(case.template)
  if not template then error("Physical AI template unresolved case=" .. case.id .. " template=" .. case.template) end
  return state, airwing, squadron, airbase, template
end

local function logMapDelta(caseId, family, before, after, phase)
  local seen = {}
  for key in pairs(before or {}) do seen[tostring(key)] = true end
  for key in pairs(after or {}) do seen[tostring(key)] = true end
  local keys = sortedKeys(seen)
  local changes = 0
  for _, key in ipairs(keys) do
    local a = tonumber(before and before[key]) or 0
    local b = tonumber(after and after[key]) or 0
    if a ~= b then
      changes = changes + 1
      log(string.format("MAP_DELTA case=%s phase=%s family=%s item=%s before=%.3f after=%.3f delta=%.3f", caseId, phase, family, key, a, b, b-a))
    end
  end
  return changes
end

local function collectDebits(before, after)
  local result = {}
  local total = 0
  for key, value in pairs(before or {}) do
    local a = tonumber(value) or 0
    local b = tonumber(after and after[key]) or 0
    local debit = a - b
    if debit > 0 then
      result[tostring(key)] = debit
      total = total + debit
    end
  end
  return result, total
end

local function classifyMapRecovery(caseId, debits, postSpawn, finalMap)
  local debited = 0
  local recovered = 0
  local over = false
  for _, key in ipairs(sortedKeys(debits)) do
    local debit = tonumber(debits[key]) or 0
    local post = tonumber(postSpawn and postSpawn[key]) or 0
    local final = tonumber(finalMap and finalMap[key]) or 0
    local raw = final - post
    local itemRecovered = math.max(0, math.min(raw, debit))
    if raw > debit then over = true end
    debited = debited + debit
    recovered = recovered + itemRecovered
    log(string.format("STORE_RECOVERY case=%s item=%s debit=%.3f postSpawn=%.3f final=%.3f rawRecovery=%.3f recovered=%.3f", caseId, key, debit, post, final, raw, itemRecovered))
  end
  if debited <= 0 then return "NOT_DEBITED", recovered, debited end
  if over then return "OVER_RECREDIT", recovered, debited end
  if math.abs(recovered - debited) <= 0.001 then return "FULL", recovered, debited end
  if recovered <= 0.001 then return "NONE", recovered, debited end
  return "PARTIAL", recovered, debited
end

local function classifyFuel(pre, post, final)
  local debit = pre - post
  local recovery = final - post
  local netLoss = pre - final
  if debit <= FUEL_TOLERANCE_KG then
    return "NOT_DEBITED", debit, recovery, netLoss
  end
  if recovery > debit + FUEL_TOLERANCE_KG then
    return "OVER_RECREDIT", debit, recovery, netLoss
  end
  if math.abs(recovery - debit) <= FUEL_TOLERANCE_KG then
    return "FULL", debit, recovery, netLoss
  end
  if recovery <= FUEL_TOLERANCE_KG then
    return "NONE", debit, recovery, netLoss
  end
  return "PARTIAL", debit, recovery, netLoss
end

local function flightFuelTelemetry(flightGroup, label, caseId)
  local minPercent = nil
  local totalKg = 0
  local unitsMeasured = 0
  if flightGroup and flightGroup.GetFuelMin then
    minPercent = flightGroup:GetFuelMin()
  end
  local group = flightGroup and flightGroup.GetGroup and flightGroup:GetGroup() or nil
  if group and group.GetUnits then
    for _, unit in pairs(group:GetUnits() or {}) do
      if unit and unit.IsAlive and unit:IsAlive() and unit.GetCurrentFuelKgs then
        local kg = tonumber(unit:GetCurrentFuelKgs())
        if kg then
          totalKg = totalKg + kg
          unitsMeasured = unitsMeasured + 1
        end
      end
    end
  end
  log(string.format("FLIGHT_FUEL case=%s label=%s minPercent=%s currentFuelKg=%.3f unitsMeasured=%d", caseId, label, tostring(minPercent), totalKg, unitsMeasured))
  return { minPercent=minPercent, totalKg=totalKg, unitsMeasured=unitsMeasured }
end

local function selectReturnFuelReference(observation)
  if observation.landedFuel and observation.landedFuel.unitsMeasured > 0 then
    return "LANDED", observation.landedFuel
  end
  if observation.arrivedFuel and observation.arrivedFuel.unitsMeasured > 0 then
    return "ARRIVED", observation.arrivedFuel
  end
  return "UNAVAILABLE", { totalKg=0, unitsMeasured=0 }
end

local function finishIfDone()
  if runtime.finished then return end
  local allDone = true
  for _, lane in pairs(runtime.lanes) do
    if not lane.done and not lane.blocked then allDone = false break end
  end
  if not allDone then return end

  runtime.finished = true
  local status = (runtime.casesFailed == 0 and runtime.lanesBlocked == 0 and runtime.casesObserved == runtime.casesTotal)
    and "COMPLETE"
    or "COMPLETE_WITH_GAPS"
  log(string.format("RESULT testId=%s status=%s casesTotal=%d casesObserved=%d casesFailed=%d lanesBlocked=%d storageMutation=false campaignStateMutation=false directSpawn=false testPayloadRegistration=true missionType=ORBIT parallelByStorageLane=true partialExpenditure=false elapsed=%.1f", TEST_ID, status, runtime.casesTotal, runtime.casesObserved, runtime.casesFailed, runtime.lanesBlocked, timer.getTime()-runtime.startedAt))
  notify(string.format("AIROPS STORAGE/FUEL CENSUS COMPLETE\n%s\nObserved %d/%d templates; failures %d; blocked lanes %d\nSend dcs.log + debrief.", status, runtime.casesObserved, runtime.casesTotal, runtime.casesFailed, runtime.lanesBlocked), FINAL_MESSAGE_DURATION_S)
end

local dispatchNextCase

local function markCaseFailure(lane, case, stage, message, blockLane)
  runtime.casesFailed = runtime.casesFailed + 1
  log(string.format("CASE_RESULT case=%s lane=%s status=ERROR stage=%s blockLane=%s error=%s", case.id, case.lane, tostring(stage), tostring(blockLane == true), tostring(message)))
  if blockLane then
    lane.blocked = true
    runtime.lanesBlocked = runtime.lanesBlocked + 1
    log(string.format("LANE_BLOCKED lane=%s case=%s reason=%s", case.lane, case.id, tostring(message)))
    finishIfDone()
  else
    SCHEDULER:New(nil, dispatchNextCase, {lane}, NEXT_CASE_DELAY_S)
  end
end

local function completeCase(lane, case, observation)
  runtime.casesObserved = runtime.casesObserved + 1
  lane.active = nil
  local fuelReferenceLabel, fuelReference = selectReturnFuelReference(observation)
  log(string.format(
    "CASE_RESULT case=%s lane=%s status=OBSERVED template=%s weaponDebitTotal=%.3f weaponRecredit=%s weaponRecovered=%.3f weaponDebited=%.3f fuelDebitKg=%.3f fuelRecoveryKg=%.3f fuelNetLossKg=%.3f fuelRecredit=%s assignedFuelKg=%.3f landedFuelKg=%.3f arrivedFuelKg=%.3f fuelReference=%s fuelReferenceKg=%.3f recoveryMinusReferenceKg=%.3f aircraftDeltaChanges=%d weaponSpawnChanges=%d",
    case.id,
    case.lane,
    case.template,
    observation.weaponDebitTotal,
    observation.weaponRecredit,
    observation.weaponRecovered,
    observation.weaponDebited,
    observation.fuelDebit,
    observation.fuelRecovery,
    observation.fuelNetLoss,
    observation.fuelRecredit,
    observation.assignedFuel and observation.assignedFuel.totalKg or 0,
    observation.landedFuel and observation.landedFuel.totalKg or 0,
    observation.arrivedFuel and observation.arrivedFuel.totalKg or 0,
    fuelReferenceLabel,
    fuelReference.totalKg,
    observation.fuelRecovery - fuelReference.totalKg,
    observation.aircraftDeltaChanges,
    observation.weaponSpawnChanges
  ))
  SCHEDULER:New(nil, dispatchNextCase, {lane}, NEXT_CASE_DELAY_S)
end

dispatchNextCase = function(lane)
  if runtime.finished or lane.blocked then return end
  lane.index = lane.index + 1
  local case = lane.cases[lane.index]
  if not case then
    lane.done = true
    log(string.format("LANE_COMPLETE lane=%s observed=%d total=%d", lane.id, lane.observed or 0, #lane.cases))
    finishIfDone()
    return
  end
  lane.active = case

  local ok, stateOrErr, airwing, squadron, airbase, template = pcall(resolveFoundation, case)
  if not ok then
    return markCaseFailure(lane, case, "RESOLVE", stateOrErr, false)
  end
  local profile = PROFILE[case.profile]
  if not profile then
    return markCaseFailure(lane, case, "PROFILE", "Unknown profile " .. tostring(case.profile), false)
  end

  local pre = nil
  local readOk, readErr = pcall(function() pre = readInventory(lane.storage, lane.id) end)
  if not readOk then return markCaseFailure(lane, case, "PRE_DISPATCH_INVENTORY", readErr, true) end

  local testPayload = airwing:NewPayload(template, -1, { AUFTRAG.Type.ORBIT }, 100)
  if not testPayload then
    return markCaseFailure(lane, case, "TEST_PAYLOAD", "AIRWING:NewPayload returned nil", false)
  end

  local orbitCoordinate = airbase:GetCoordinate():Translate(6000, 90)
  local mission = AUFTRAG:NewORBIT(orbitCoordinate, profile.altitudeFt, profile.speedKts)
  mission:SetRequiredAssets(1, 1)
  mission:AssignSquadrons({ squadron })
  mission:AddRequiredPayload(testPayload)
  mission:SetTime(5)
  mission:SetDuration(ORBIT_DURATION_S)
  mission:SetROE(ENUMS.ROE.WeaponHold)
  mission:SetROT(ENUMS.ROT.NoReaction)

  local observation = {
    pre = pre,
    mission = mission,
    weaponDebits = {},
    weaponDebitTotal = 0,
    weaponSpawnChanges = 0,
    aircraftDeltaChanges = 0,
    assigned = false,
    arrived = false,
  }
  case.observation = observation

  log(string.format("CASE_DISPATCH case=%s lane=%s foundation=%s wing=%s squadron=%s template=%s profile=%s storage=%s preJetFuelKg=%.3f testPayloadRegistered=true", case.id, case.lane, case.foundation, tostring(case.wing), case.squadron, case.template, case.profile, lane.storageName, pre.jetfuel))

  local previousFlightOnMission = airwing.OnAfterFlightOnMission
  airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then previousFlightOnMission(self, From, Event, To, FlightGroup, Mission) end
    if runtime.finished or Mission ~= mission or observation.assigned then return end
    observation.assigned = true

    local assignedOk, assignedErr = pcall(function()
      observation.assignedFuel = flightFuelTelemetry(FlightGroup, "ASSIGNED", case.id)
      observation.postSpawn = readInventory(lane.storage, lane.id)
      observation.aircraftDeltaChanges = logMapDelta(case.id, "AIRCRAFT", pre.aircraft, observation.postSpawn.aircraft, "SPAWN")
      logMapDelta(case.id, "LIQUID", pre.liquids, observation.postSpawn.liquids, "SPAWN")
      observation.weaponSpawnChanges = logMapDelta(case.id, "WEAPON", pre.weapons, observation.postSpawn.weapons, "SPAWN")
      observation.weaponDebits, observation.weaponDebitTotal = collectDebits(pre.weapons, observation.postSpawn.weapons)
      observation.fuelDebitRaw = pre.jetfuel - observation.postSpawn.jetfuel
      log(string.format("SPAWN_SUMMARY case=%s jetFuelBeforeKg=%.3f jetFuelAfterKg=%.3f jetFuelDebitKg=%.3f weaponDebitTotal=%.3f weaponDebitKeys=%d", case.id, pre.jetfuel, observation.postSpawn.jetfuel, observation.fuelDebitRaw, observation.weaponDebitTotal, #sortedKeys(observation.weaponDebits)))
    end)
    if not assignedOk then return markCaseFailure(lane, case, "ASSIGNMENT", assignedErr, true) end

    local previousLanded = FlightGroup.OnAfterLanded
    FlightGroup.OnAfterLanded = function(fg, LFrom, LEvent, LTo, LandAirbase)
      if runtime.finished then
        if previousLanded then previousLanded(fg, LFrom, LEvent, LTo, LandAirbase) end
        return
      end
      observation.landedFuel = flightFuelTelemetry(fg, "LANDED", case.id)
      log(string.format("LIFECYCLE case=%s event=Landed airbase=%s state=%s", case.id, LandAirbase and LandAirbase:GetName() or "nil", tostring(fg:GetState())))
      if previousLanded then previousLanded(fg, LFrom, LEvent, LTo, LandAirbase) end
    end

    local previousArrived = FlightGroup.OnAfterArrived
    FlightGroup.OnAfterArrived = function(fg, AFrom, AEvent, ATo)
      if runtime.finished or observation.arrived then
        if previousArrived then previousArrived(fg, AFrom, AEvent, ATo) end
        return
      end
      observation.arrived = true
      observation.arrivedFuel = flightFuelTelemetry(fg, "ARRIVED", case.id)
      log(string.format("LIFECYCLE case=%s event=Arrived state=%s", case.id, tostring(fg:GetState())))
      if previousArrived then previousArrived(fg, AFrom, AEvent, ATo) end

      SCHEDULER:New(nil, function()
        if runtime.finished or lane.blocked then return end
        local returnOk, returnErr = pcall(function()
          observation.final = readInventory(lane.storage, lane.id)
          logMapDelta(case.id, "AIRCRAFT", observation.postSpawn.aircraft, observation.final.aircraft, "RETURN")
          logMapDelta(case.id, "LIQUID", observation.postSpawn.liquids, observation.final.liquids, "RETURN")
          logMapDelta(case.id, "WEAPON", observation.postSpawn.weapons, observation.final.weapons, "RETURN")
          observation.weaponRecredit, observation.weaponRecovered, observation.weaponDebited = classifyMapRecovery(case.id, observation.weaponDebits, observation.postSpawn.weapons, observation.final.weapons)
          observation.fuelRecredit, observation.fuelDebit, observation.fuelRecovery, observation.fuelNetLoss = classifyFuel(pre.jetfuel, observation.postSpawn.jetfuel, observation.final.jetfuel)
          local fuelReferenceLabel, fuelReference = selectReturnFuelReference(observation)
          log(string.format("FUEL_RESULT case=%s preKg=%.3f postSpawnKg=%.3f finalKg=%.3f debitKg=%.3f recoveryKg=%.3f netLossKg=%.3f recredit=%s assignedOnboardKg=%.3f landedOnboardKg=%.3f arrivedOnboardKg=%.3f fuelReference=%s fuelReferenceKg=%.3f recoveryMinusReferenceKg=%.3f", case.id, pre.jetfuel, observation.postSpawn.jetfuel, observation.final.jetfuel, observation.fuelDebit, observation.fuelRecovery, observation.fuelNetLoss, observation.fuelRecredit, observation.assignedFuel and observation.assignedFuel.totalKg or 0, observation.landedFuel and observation.landedFuel.totalKg or 0, observation.arrivedFuel and observation.arrivedFuel.totalKg or 0, fuelReferenceLabel, fuelReference.totalKg, observation.fuelRecovery - fuelReference.totalKg))
          log(string.format("STORE_RESULT case=%s debitKeys=%d debitTotal=%.3f recovered=%.3f status=%s", case.id, #sortedKeys(observation.weaponDebits), observation.weaponDebited, observation.weaponRecovered, observation.weaponRecredit))
        end)
        if not returnOk then return markCaseFailure(lane, case, "POST_RETURN", returnErr, true) end
        lane.observed = (lane.observed or 0) + 1
        completeCase(lane, case, observation)
      end, {}, POST_RETURN_OBSERVE_S)
    end
  end

  airwing:AddMission(mission)

  SCHEDULER:New(nil, function()
    if runtime.finished or lane.blocked or lane.active ~= case then return end
    if not observation.assigned then
      if mission.Cancel then mission:Cancel() end
      return markCaseFailure(lane, case, "ASSIGN_TIMEOUT", "No FlightOnMission within case timeout", false)
    end
    if not observation.arrived then
      return markCaseFailure(lane, case, "ARRIVAL_TIMEOUT", "Assigned flight did not reach Arrived within case timeout", true)
    end
  end, {}, CASE_TIMEOUT_S)
end

local function initializeLanes()
  for laneId, definition in pairs(LANE_DEFS) do
    local airbase, storage = resolveStorage(laneId, definition)
    runtime.lanes[laneId] = {
      id = laneId,
      storageName = definition.storageName,
      airbase = airbase,
      storage = storage,
      cases = {},
      index = 0,
      observed = 0,
      done = false,
      blocked = false,
    }
    local baseline = readInventory(storage, laneId)
    log(string.format("LANE_READY lane=%s storage=%s baselineJetFuelKg=%.3f aircraftKeys=%d weaponKeys=%d", laneId, definition.storageName, baseline.jetfuel, #sortedKeys(baseline.aircraft), #sortedKeys(baseline.weapons)))
  end
  for _, case in ipairs(CASES) do
    local lane = runtime.lanes[case.lane]
    if not lane then error("Case references undefined lane: " .. case.id .. " -> " .. tostring(case.lane)) end
    lane.cases[#lane.cases + 1] = case
  end
end

local function beginTest()
  if runtime.finished then return end
  runtime.startedAt = timer.getTime()

  local ok, err = pcall(initializeLanes)
  if not ok then
    runtime.finished = true
    env.error(TAG .. " FATAL " .. tostring(err), false)
    log(string.format("RESULT testId=%s status=FATAL casesTotal=%d casesObserved=0 casesFailed=0 lanesBlocked=0 error=%s", TEST_ID, runtime.casesTotal, tostring(err)))
    notify("AIROPS STORAGE/FUEL CENSUS FATAL PRECONDITION\nSend dcs.log.", FINAL_MESSAGE_DURATION_S)
    return
  end

  log(string.format("TEST_BEGIN testId=%s cases=%d lanes=7 mode=parallel_by_storage_lane mission=ORBIT storageMutation=false campaignStateMutation=false partialExpenditure=false", TEST_ID, runtime.casesTotal))
  notify(string.format("AIROPS STORAGE/FUEL CENSUS STARTED\n%d physical AI templates across 7 STORAGE lanes\nStores + JETFUEL + onboard fuel telemetry", runtime.casesTotal), FINAL_MESSAGE_DURATION_S)

  local laneIds = { "BAGRAM", "JALALABAD", "KANDAHAR_MAIN", "KANDAHAR_HELIPORT", "SALERNO", "SHINDAND_HELIPORT", "TARINKOT" }
  for index, laneId in ipairs(laneIds) do
    local lane = runtime.lanes[laneId]
    SCHEDULER:New(nil, dispatchNextCase, {lane}, (index - 1) * LANE_STAGGER_S)
  end

  SCHEDULER:New(nil, function()
    if runtime.finished then return end
    for _, lane in pairs(runtime.lanes) do
      if not lane.done and not lane.blocked then
        lane.blocked = true
        runtime.lanesBlocked = runtime.lanesBlocked + 1
        log(string.format("LANE_BLOCKED lane=%s reason=GLOBAL_TIMEOUT", lane.id))
      end
    end
    finishIfDone()
  end, {}, GLOBAL_TIMEOUT_S)
end

SCHEDULER:New(nil, beginTest, {}, START_DELAY_S)
