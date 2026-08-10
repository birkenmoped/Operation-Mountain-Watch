-- Operation Mountain Watch - Shindand final combined AIRWING/SQUADRON foundation acceptance.
--
-- Intended load order when built as the final combined bundle:
--   1. Moose.lua
--   2. OMW_AirOps_Shindand_FinalFoundationAcceptance.lua
--
-- This is the final DCS runtime gate for the current Shindand AIRWING/SQUADRON
-- foundation scope. It validates the already accepted AH-64 native CAS path as a
-- regression and adds the remaining native UH-60 and CH-47 LANDATCOORDINATE
-- capability/runtime checks in the same DCS run.
--
-- Parking ownership is deliberately excluded from acceptance. Taxiing to the
-- Shindand Heliport runway is allowed and is telemetry only. No COMMANDER,
-- OPSTRANSPORT, native spawn, F10 control, CampaignState mutation, persistence,
-- CSAR or MEDEVAC specialization is introduced by this test.

local TAG = "[OMW][AirOps.SHND.FinalFoundation]"
local EXPECTED_AIRBASE = "Shindand Heliport"
local EXPECTED_AIRBASE_ID = 14
local START_DELAY_S = 25
local DISPATCH_SPACING_S = 20
local MONITOR_INTERVAL_S = 5
local FINAL_TIMEOUT_S = 1200

local EXPECTED = {
  AH64D = {
    squadron = "SQ_US_SHND_AH64D_ATTACK",
    missionType = AUFTRAG.Type.CAS,
    requireLandedAt = false,
  },
  UH60 = {
    squadron = "SQ_US_SHND_UH60_UTILITY_MEDEVAC",
    missionType = AUFTRAG.Type.LANDATCOORDINATE,
    requireLandedAt = true,
  },
  CH47 = {
    squadron = "SQ_US_SHND_CH47_HEAVYLIFT",
    missionType = AUFTRAG.Type.LANDATCOORDINATE,
    requireLandedAt = true,
  },
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message), false)
end

local function boolText(value)
  return value == true and "true" or "false"
end

local function countTable(value)
  local count = 0
  if type(value) == "table" then
    for _ in pairs(value) do
      count = count + 1
    end
  end
  return count
end

local function startsWith(value, prefix)
  value = tostring(value or "")
  prefix = tostring(prefix or "")
  return string.sub(value, 1, #prefix) == prefix
end

local function newTelemetry(key, mission)
  return {
    key = key,
    mission = mission,
    assigned = false,
    assignedGroup = nil,
    engineOnObserved = false,
    taxiObserved = false,
    takeoffObserved = false,
    airborneObserved = false,
    landedAtObserved = false,
    missionSuccess = false,
    missionFailed = false,
    coldConfigured = false,
    verticalPolicyApplied = false,
  }
end

local function validateFoundation(state)
  if not state or state.Status ~= "RUNNING" then
    error("Shindand foundation is not RUNNING")
  end
  if not state.Airbase or state.Airbase:GetName() ~= EXPECTED_AIRBASE then
    error("Unexpected or missing Shindand Airbase")
  end
  if state.Airbase:GetID() ~= EXPECTED_AIRBASE_ID then
    error("Unexpected Shindand Heliport Airbase ID: " .. tostring(state.Airbase:GetID()))
  end
  if not state.Airwing or not state.Airwing:IsRunning() then
    error("Shindand AIRWING is not running")
  end
  if not state.Squadrons or not state.Squadrons.AH64D or not state.Squadrons.UH60 or not state.Squadrons.CH47 then
    error("Shindand SQUADRON set is incomplete")
  end
  if state.RegisteredGroups ~= 16 or state.RepresentedAirframes ~= 20 or state.LogicalAirframes ~= 20 or state.LogicalReserve ~= 0 then
    error("Foundation inventory totals do not match the Shindand contract")
  end
  if countTable(state.Squadrons.AH64D.assets) ~= 4 then
    error("AH-64 post-start asset count mismatch")
  end
  if countTable(state.Squadrons.UH60.assets) ~= 8 then
    error("UH-60 post-start asset count mismatch")
  end
  if countTable(state.Squadrons.CH47.assets) ~= 4 then
    error("CH-47 post-start asset count mismatch")
  end
  if state.Airwing.OptionPreferVerticalLanding ~= true then
    error("AIRWING vertical preference is not configured")
  end

  log("FOUNDATION_REGRESSION status=PASS airbase=Shindand_Heliport airbaseID=14 airwingRunning=true squadrons=3 registeredGroups=16 representedAirframes=20 logicalAirframes=20 logicalReserve=0")
end

local function createMissions(state)
  local baseCoordinate = state.Airbase:GetCoordinate()
  if not baseCoordinate then
    error("Shindand Heliport coordinate unavailable")
  end

  local casCoordinate = baseCoordinate:Translate(10000, 90)
  local casZone = ZONE_RADIUS:New("OMW_SHND_FINAL_AH64_CAS_ZONE", casCoordinate:GetVec2(), 1500)
  local ah64Mission = AUFTRAG:NewCAS(casZone, 5500, 100)
  ah64Mission:SetRequiredAssets(1, 1)
  ah64Mission:AssignSquadrons({ state.Squadrons.AH64D })
  ah64Mission:SetTime(5, FINAL_TIMEOUT_S)

  local uh60Coordinate = baseCoordinate:Translate(2500, 110)
  local uh60Mission = AUFTRAG:NewLANDATCOORDINATE(uh60Coordinate, nil, nil, 20, 90, 700, false)
  uh60Mission:SetRequiredAssets(1, 1)
  uh60Mission:AssignSquadrons({ state.Squadrons.UH60 })
  uh60Mission:SetTime(5, FINAL_TIMEOUT_S)

  local ch47Coordinate = baseCoordinate:Translate(3500, 250)
  local ch47Mission = AUFTRAG:NewLANDATCOORDINATE(ch47Coordinate, nil, nil, 20, 90, 700, false)
  ch47Mission:SetRequiredAssets(1, 1)
  ch47Mission:AssignSquadrons({ state.Squadrons.CH47 })
  ch47Mission:SetTime(5, FINAL_TIMEOUT_S)

  return {
    AH64D = newTelemetry("AH64D", ah64Mission),
    UH60 = newTelemetry("UH60", uh60Mission),
    CH47 = newTelemetry("CH47", ch47Mission),
  }
end

local function attachMissionCallbacks(telemetry)
  local mission = telemetry.mission

  function mission:OnAfterSuccess(From, Event, To)
    telemetry.missionSuccess = true
    log(string.format("MISSION_SUCCESS key=%s missionType=%s state=%s", telemetry.key, tostring(self:GetType()), tostring(self:GetState())))
  end

  function mission:OnAfterFailed(From, Event, To)
    telemetry.missionFailed = true
    fail(string.format("MISSION_FAILED key=%s missionType=%s state=%s", telemetry.key, tostring(self:GetType()), tostring(self:GetState())))
  end
end

local function attachFlightCallbacks(telemetry, flightGroup)
  local previousElementEngineOn = flightGroup.OnAfterElementEngineOn
  function flightGroup:OnAfterElementEngineOn(From, Event, To, Element)
    if previousElementEngineOn then
      previousElementEngineOn(self, From, Event, To, Element)
    end
    telemetry.engineOnObserved = true
    log(string.format("ELEMENT_ENGINE_ON key=%s group=%s element=%s", telemetry.key, tostring(self:GetName()), tostring(Element and Element.name or "unknown")))
  end

  local previousTaxiing = flightGroup.OnAfterTaxiing
  function flightGroup:OnAfterTaxiing(From, Event, To)
    if previousTaxiing then
      previousTaxiing(self, From, Event, To)
    end
    telemetry.taxiObserved = true
    log(string.format("TAXIING key=%s group=%s", telemetry.key, tostring(self:GetName())))
  end

  local previousTakeoff = flightGroup.OnAfterTakeoff
  function flightGroup:OnAfterTakeoff(From, Event, To, Airbase)
    if previousTakeoff then
      previousTakeoff(self, From, Event, To, Airbase)
    end
    telemetry.takeoffObserved = true
    log(string.format("TAKEOFF key=%s group=%s airbase=%s", telemetry.key, tostring(self:GetName()), tostring(Airbase and Airbase:GetName() or "unknown")))
  end

  local previousAirborne = flightGroup.OnAfterAirborne
  function flightGroup:OnAfterAirborne(From, Event, To)
    if previousAirborne then
      previousAirborne(self, From, Event, To)
    end
    telemetry.airborneObserved = true
    log(string.format("AIRBORNE key=%s group=%s", telemetry.key, tostring(self:GetName())))
  end

  local previousLandedAt = flightGroup.OnAfterLandedAt
  function flightGroup:OnAfterLandedAt(From, Event, To)
    if previousLandedAt then
      previousLandedAt(self, From, Event, To)
    end
    telemetry.landedAtObserved = true
    log(string.format("LANDED_AT_COORDINATE key=%s group=%s state=%s", telemetry.key, tostring(self:GetName()), tostring(self:GetState())))
  end
end

local function validateAssignment(telemetry, flightGroup, mission)
  local expected = EXPECTED[telemetry.key]
  local group = flightGroup and flightGroup:GetGroup() or nil
  local groupName = group and group:GetName() or (flightGroup and flightGroup:GetName()) or "unknown"
  local leader = group and group:GetUnit(1) or nil
  local unitType = leader and leader:GetTypeName() or "unknown"

  if telemetry.assigned then
    error("More than one FLIGHTGROUP assigned for " .. telemetry.key)
  end
  if mission ~= telemetry.mission then
    error("Mission identity mismatch for " .. telemetry.key)
  end
  if mission:GetType() ~= expected.missionType then
    error("Mission type mismatch for " .. telemetry.key .. ": " .. tostring(mission:GetType()))
  end
  if not startsWith(groupName, expected.squadron) then
    error("Unexpected squadron/group assignment for " .. telemetry.key .. ": " .. tostring(groupName))
  end

  telemetry.assigned = true
  telemetry.assignedGroup = groupName
  telemetry.coldConfigured = flightGroup.IsTakeoffCold and flightGroup:IsTakeoffCold() or false
  telemetry.verticalPolicyApplied = flightGroup.OptionPreferVertical == true

  if not telemetry.coldConfigured then
    error("Cold takeoff configuration missing on assigned " .. telemetry.key .. " FLIGHTGROUP")
  end
  if not telemetry.verticalPolicyApplied then
    error("AIRWING vertical preference was not propagated to " .. telemetry.key .. " FLIGHTGROUP")
  end

  attachFlightCallbacks(telemetry, flightGroup)

  log(string.format(
    "FLIGHT_ON_MISSION key=%s group=%s missionType=%s unitType=%s coldConfigured=true verticalPolicyApplied=true parkingAcceptance=false taxiRequired=false",
    telemetry.key,
    tostring(groupName),
    tostring(mission:GetType()),
    tostring(unitType)
  ))
end

local function missionReady(telemetry)
  local expected = EXPECTED[telemetry.key]
  if telemetry.missionFailed then
    return false
  end
  if not telemetry.assigned or not telemetry.coldConfigured or not telemetry.verticalPolicyApplied then
    return false
  end
  if not telemetry.engineOnObserved or not telemetry.takeoffObserved or not telemetry.airborneObserved then
    return false
  end
  if expected.requireLandedAt and not telemetry.landedAtObserved then
    return false
  end
  if not telemetry.missionSuccess then
    return false
  end
  return true
end

local function resultDetails(telemetry)
  return string.format(
    "%s{assigned=%s,cold=%s,vertical=%s,engine=%s,taxi=%s,takeoff=%s,airborne=%s,landedAt=%s,success=%s,failed=%s,group=%s}",
    telemetry.key,
    boolText(telemetry.assigned),
    boolText(telemetry.coldConfigured),
    boolText(telemetry.verticalPolicyApplied),
    boolText(telemetry.engineOnObserved),
    boolText(telemetry.taxiObserved),
    boolText(telemetry.takeoffObserved),
    boolText(telemetry.airborneObserved),
    boolText(telemetry.landedAtObserved),
    boolText(telemetry.missionSuccess),
    boolText(telemetry.missionFailed),
    tostring(telemetry.assignedGroup or "nil")
  )
end

local function run()
  if not OMW or not OMW.AirOps or not OMW.AirOps.Shindand then
    error("Shindand foundation state not loaded")
  end
  if not AUFTRAG or not AIRWING or not SQUADRON or not ZONE_RADIUS or not SCHEDULER or not FLIGHTGROUP then
    error("Required pinned MOOSE classes are unavailable")
  end
  if not AUFTRAG.NewLANDATCOORDINATE or not AUFTRAG.AssignSquadrons then
    error("Required pinned MOOSE AUFTRAG final-acceptance APIs are unavailable")
  end

  local state = OMW.AirOps.Shindand
  validateFoundation(state)

  local telemetry = createMissions(state)
  attachMissionCallbacks(telemetry.AH64D)
  attachMissionCallbacks(telemetry.UH60)
  attachMissionCallbacks(telemetry.CH47)

  local missionByObject = {
    [telemetry.AH64D.mission] = telemetry.AH64D,
    [telemetry.UH60.mission] = telemetry.UH60,
    [telemetry.CH47.mission] = telemetry.CH47,
  }

  local airwing = state.Airwing
  local previousFlightOnMission = airwing.OnAfterFlightOnMission
  function airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then
      previousFlightOnMission(self, From, Event, To, FlightGroup, Mission)
    end

    local entry = missionByObject[Mission]
    if not entry then
      return
    end

    local ok, err = pcall(validateAssignment, entry, FlightGroup, Mission)
    if not ok then
      entry.missionFailed = true
      fail("RESULT status=FAIL_ASSIGNMENT key=" .. tostring(entry.key) .. " error=" .. tostring(err))
    end
  end

  log("FINAL_TEST_BEGIN oneDcsRun=true parkingAcceptance=false taxiRequired=false commander=false opstransport=false campaignStateMutation=false directSpawn=false")

  airwing:AddMission(telemetry.AH64D.mission)
  log("DISPATCH key=AH64D path=AIRWING_ADD_MISSION missionType=CAS squadronPinned=true")

  SCHEDULER:New(nil, function()
    airwing:AddMission(telemetry.UH60.mission)
    log("DISPATCH key=UH60 path=AIRWING_ADD_MISSION missionType=LANDATCOORDINATE squadronPinned=true")
  end, {}, DISPATCH_SPACING_S)

  SCHEDULER:New(nil, function()
    airwing:AddMission(telemetry.CH47.mission)
    log("DISPATCH key=CH47 path=AIRWING_ADD_MISSION missionType=LANDATCOORDINATE squadronPinned=true")
  end, {}, DISPATCH_SPACING_S * 2)

  local elapsed = 0
  SCHEDULER:New(nil, function()
    elapsed = elapsed + MONITOR_INTERVAL_S

    if telemetry.AH64D.missionFailed or telemetry.UH60.missionFailed or telemetry.CH47.missionFailed then
      fail("RESULT status=FAIL_FINAL_FOUNDATION_ACCEPTANCE elapsedS=" .. tostring(elapsed) .. " " .. resultDetails(telemetry.AH64D) .. " " .. resultDetails(telemetry.UH60) .. " " .. resultDetails(telemetry.CH47))
      return false
    end

    if missionReady(telemetry.AH64D) and missionReady(telemetry.UH60) and missionReady(telemetry.CH47) then
      local running = state.Airwing.IsRunning and state.Airwing:IsRunning() or false
      if not running then
        fail("RESULT status=FAIL_FINAL_FOUNDATION_ACCEPTANCE reason=AIRWING_NOT_RUNNING_AFTER_MISSIONS")
        return false
      end

      log("RESULT status=PASS_FINAL_FOUNDATION_ACCEPTANCE airwingRunning=true parkingAcceptance=false taxiRequired=false " .. resultDetails(telemetry.AH64D) .. " " .. resultDetails(telemetry.UH60) .. " " .. resultDetails(telemetry.CH47))
      return false
    end

    if elapsed >= FINAL_TIMEOUT_S then
      fail("RESULT status=FAIL_FINAL_FOUNDATION_TIMEOUT elapsedS=" .. tostring(elapsed) .. " " .. resultDetails(telemetry.AH64D) .. " " .. resultDetails(telemetry.UH60) .. " " .. resultDetails(telemetry.CH47))
      return false
    end

    return true
  end, {}, MONITOR_INTERVAL_S, MONITOR_INTERVAL_S)
end

SCHEDULER:New(nil, function()
  local ok, err = pcall(run)
  if not ok then
    fail("RESULT status=FAIL_FINAL_FOUNDATION_SETUP error=" .. tostring(err))
  end
end, {}, START_DELAY_S)
