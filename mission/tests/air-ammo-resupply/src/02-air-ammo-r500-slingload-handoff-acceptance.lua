-- Operation Mountain Watch - isolated CH-47 R500 slingload handoff acceptance.
-- Test-ID: AIR-AMMO-R500-SLINGLOAD-HANDOFF-ACCEPTANCE-1
--
-- Scope is deliberately narrow after the Stage 3 Build 1-17 route failure:
-- physical pickup -> public MOOSE task release -> R500 outbound -> Wright delivery
-- -> R500 reverse -> Jalalabad landing/AIRWING recovery.
--
-- This test does not exercise Honaker, Guard, QRF, CAS, ARTY or CampaignState.

local TEST_ID = "AIR-AMMO-R500-SLINGLOAD-HANDOFF-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"

local PICKUP_ZONE_NAME = "ZON_BLUE_LOG_SLG_JALALABAD_01"
local DROP_ZONE_NAME = "OMW_BLUE_LZ_WRIGHT_01"
local PATHLINE_NAME = "OMW_FlightPath_R500"
local AIR_TEMPLATE_NAME = "TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP"
local CARGO_NAME = "CARGO-AIR-AMMO-R500-SLINGLOAD-HANDOFF-ACCEPTANCE-001"
local ALTITUDE_FT_AGL = 500
local CHECK_INTERVAL_SEC = 5
local MAX_HANDOFF_ATTEMPTS = 12

local Corridor = OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR
local Handoff = OMW_STAGE3_SLINGLOAD_CORRIDOR_HANDOFF

local state = {
  failed=false,
  passed=false,
  airwing=nil,
  squadron=nil,
  pickupZone=nil,
  dropZone=nil,
  cargo=nil,
  mission=nil,
  flight=nil,
  asset=nil,
  pickupConfirmed=false,
  handoffInstalled=false,
  handoffAttempts=0,
  deliveryConfirmed=false,
  homeLanded=false,
  assetReturned=false,
  monitor=nil,
}

local function log(text)
  env.info(TAG .. " " .. tostring(text), false)
end

local function msg(text, seconds)
  log(text)
  MESSAGE:New("[AIR-AMMO R500] " .. tostring(text), seconds or 10):ToAll()
end

local function stopMonitor()
  if state.monitor and type(state.monitor.Stop)=="function" then state.monitor:Stop() end
  state.monitor=nil
end

local function fail(reason)
  if state.failed or state.passed then return end
  state.failed=true
  stopMonitor()
  msg("FAIL " .. tostring(reason), 20)
end

local function requireValue(value, label)
  if value == nil then fail("missing " .. tostring(label)) end
  return value
end

local function maybePass()
  if state.failed or state.passed then return end
  if not (state.pickupConfirmed and state.handoffInstalled and state.deliveryConfirmed and state.homeLanded and state.assetReturned) then return end
  state.passed=true
  stopMonitor()
  msg("PASS pickup -> MOOSE task release -> R500 outbound -> Wright physical delivery -> R500 reverse -> Jalalabad landing/AIRWING recovery", 30)
end

local function resolveR500()
  return Corridor.Resolve({
    pathlineName=PATHLINE_NAME,
    originCoordinate=state.flight:GetCoordinate(),
    destinationCoordinate=state.dropZone:GetCoordinate(),
    offsetMode=Corridor.OffsetMode.PATHLINE_SUFFIX,
  })
end

local function tryHandoff()
  if state.failed or state.handoffInstalled or not state.pickupConfirmed then return end
  state.handoffAttempts=state.handoffAttempts+1

  local resolved=resolveR500()
  local installed, ok, reason=Handoff.Install(state.flight, state.mission, resolved, ALTITUDE_FT_AGL, {
    cargo=state.cargo,
    dropZone=state.dropZone,
  })

  if ok == true then
    state.handoffInstalled=true
    msg(string.format("R500 handoff installed after %d attempt(s); pauseMode=%s activeTaskCleared=%s outbound=%s return=%s",
      state.handoffAttempts,
      tostring(installed.pauseMode),
      tostring(installed.activeTaskClearedBeforeRoute),
      tostring(installed.outboundWaypointCount),
      tostring(installed.returnWaypointCount)), 15)
    return
  end

  if reason == "CARGOTRANSPORT_PAUSE_REQUESTED" or reason == "CARGOTRANSPORT_TASK_STILL_EXECUTING" then
    log("HANDOFF_WAIT attempt=" .. tostring(state.handoffAttempts) .. " reason=" .. tostring(reason))
    if state.handoffAttempts >= MAX_HANDOFF_ATTEMPTS then
      fail("MOOSE CARGOTRANSPORT task did not release within bounded handoff window; lastReason=" .. tostring(reason))
    end
    return
  end

  if reason == "CURRENT_WAYPOINT_UID_UNAVAILABLE_AFTER_PICKUP" then
    log("HANDOFF_WAIT attempt=" .. tostring(state.handoffAttempts) .. " reason=" .. tostring(reason))
    if state.handoffAttempts >= MAX_HANDOFF_ATTEMPTS then
      fail("waypoint UID unavailable after bounded handoff window")
    end
    return
  end

  fail("R500 handoff failed: " .. tostring(reason))
end

local function startMonitor()
  if state.monitor then return end
  state.monitor=SCHEDULER:New(nil, function()
    if state.failed or state.passed then stopMonitor(); return end
    if not state.cargo or state.cargo:IsAlive() ~= true then fail("physical slingload cargo lost") return end

    if not state.pickupConfirmed then
      if state.cargo:IsInZone(state.pickupZone) then return end
      state.pickupConfirmed=true
      msg("Physical slingload pickup confirmed; requesting public MOOSE CARGOTRANSPORT task release before any route update", 12)
    end

    tryHandoff()
  end, {}, CHECK_INTERVAL_SEC, CHECK_INTERVAL_SEC)
end

local function installObservers()
  local previousFlightOnMission=state.airwing.OnAfterFlightOnMission
  function state.airwing:OnAfterFlightOnMission(From,Event,To,FlightGroup,Mission)
    if previousFlightOnMission then previousFlightOnMission(self,From,Event,To,FlightGroup,Mission) end
    if Mission ~= state.mission then return end
    if state.flight then fail("multiple CH-47 flights assigned to isolated handoff acceptance") return end
    state.flight=FlightGroup
    state.asset=Mission:GetAssetByName(FlightGroup:GetName())
    if not state.asset then fail("CH-47 mission asset unavailable") return end

    local previousLanded=FlightGroup.OnAfterLanded
    function FlightGroup:OnAfterLanded(F,E,T,Airbase)
      if previousLanded then previousLanded(self,F,E,T,Airbase) end
      if state.deliveryConfirmed and Airbase and Airbase:GetName()==state.airwing:GetAirbaseName() then
        state.homeLanded=true
        msg("CH-47 landed at Jalalabad after delivery", 10)
        maybePass()
      end
    end

    startMonitor()
    msg("CH-47 assigned to isolated CARGOTRANSPORT; waiting for physical pickup", 10)
  end

  local previousReturned=state.airwing.OnAfterLegionAssetReturned
  function state.airwing:OnAfterLegionAssetReturned(From,Event,To,Cohort,Asset)
    if previousReturned then previousReturned(self,From,Event,To,Cohort,Asset) end
    if state.asset and Asset==state.asset then
      if not state.homeLanded then fail("AIRWING asset returned before confirmed Jalalabad landing") return end
      state.assetReturned=true
      msg("CH-47 recovered by Jalalabad AIRWING", 10)
      maybePass()
    end
  end
end

local function start()
  local air=OMW and OMW.AirOps and OMW.AirOps.Jalalabad or nil
  if type(air)~="table" or air.Status~="RUNNING" or not air.Airwing then fail("Jalalabad AIRWING not running") return end
  if not air.Squadrons or not air.Squadrons.CH47 then fail("Jalalabad CH-47 squadron unavailable") return end

  state.airwing=air.Airwing
  state.squadron=air.Squadrons.CH47
  requireValue(GROUP:FindByName(AIR_TEMPLATE_NAME), AIR_TEMPLATE_NAME)
  state.pickupZone=requireValue(ZONE:FindByName(PICKUP_ZONE_NAME), PICKUP_ZONE_NAME)
  state.dropZone=requireValue(ZONE:FindByName(DROP_ZONE_NAME), DROP_ZONE_NAME)
  requireValue(PATHLINE:FindByName(PATHLINE_NAME), PATHLINE_NAME)
  if state.failed then return end
  if type(state.dropZone.ZoneID)~="number" then fail("Wright drop zone requires numeric ZoneID") return end

  state.cargo=SPAWNSTATIC:NewFromType("ammo_cargo","Cargos",country.id.USA)
    :InitCargo(true)
    :InitCargoMass(1000)
    :InitCoordinate(state.pickupZone:GetCoordinate())
    :InitValidateAndRepositionStatic(false)
    :Spawn(0,CARGO_NAME)
  if not state.cargo or state.cargo:IsAlive()~=true then fail("physical slingload cargo spawn failed") return end
  if not state.cargo:IsInZone(state.pickupZone) then fail("physical cargo not inside exact pickup zone") return end

  installObservers()

  state.mission=AUFTRAG:NewCARGOTRANSPORT(state.cargo,state.dropZone)
  state.mission:SetName("OMW_AIR_AMMO_R500_SLINGLOAD_HANDOFF_ACCEPTANCE")
  state.mission:SetRequiredAssets(1,1)
  state.mission:AssignSquadrons({state.squadron})
  state.mission:SetPriority(20,true)

  local previousSuccess=state.mission.OnAfterSuccess
  function state.mission:OnAfterSuccess(From,Event,To)
    if previousSuccess then previousSuccess(self,From,Event,To) end
    if state.failed then return end
    if not state.pickupConfirmed or not state.handoffInstalled then fail("CARGOTRANSPORT succeeded before R500 handoff") return end
    if not state.cargo:IsAlive() or not state.cargo:IsInZone(state.dropZone) then fail("mission success lacks physical Wright delivery") return end
    state.deliveryConfirmed=true
    msg("Physical slingload delivery at Wright confirmed; awaiting R500 reverse and Jalalabad recovery", 12)
    maybePass()
  end

  local previousFailed=state.mission.OnAfterFailed
  function state.mission:OnAfterFailed(From,Event,To)
    if previousFailed then previousFailed(self,From,Event,To) end
    fail("MOOSE CARGOTRANSPORT failed")
  end

  state.airwing:AddMission(state.mission)
  msg("READY isolated CH-47 test only: pickup -> task release -> R500 outbound -> Wright -> R500 reverse -> Jalalabad", 20)
end

SCHEDULER:New(nil,start,{},5)
